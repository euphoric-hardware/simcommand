import chisel3.{Clock, Data}

package object simcommand {

  // Below is inspired by the trampolined continuation in TailCalls.scala (in the Scala stdlib)
  /**
    * This class represents an RTL simulation command and its return value
    * @tparam R Type of the command's return value
    */
  sealed abstract class Command[R] {
    final def map[R2](f: R => R2): Command[R2] = {
      flatMap(r => Return(f(r)))
    }

    final def flatMap[R2](f: R => Command[R2]): Command[R2] = {
      this match {
        case Return(retval) => f(retval)
        case c: Cont[a1, a2] => Cont(c.a, (x: a1) => c.f(x) flatMap f)
        case c: Command[R] => Cont(c, f)
      }
    }

    // tailRec provides an efficent tail recursion primitive. If the provided
    // function takes in arguments and returns Command[Left(newArguments)], it
    // flatMaps again with the new arguments. If given a
    // Command[Right(result)], it will instead lift the internal result.
    final def tailRec[R2](f: R => Command[Either[R, R2]]): Command[R2] = {
      this.flatMap(Rec(_, f))
    }

    // tailRecM is the functional version of tailRecM. This version is
    // also safe, but tends to be significantly slower.
    // Similar implementation as cats.Free: https://github.com/typelevel/cats/pull/1041/files#diff-7349edfd077f9612f7181fe1f8caca63ac667c847ce83b53dceae4d08040fd55
    final def tailRecM[R2](f: R => Command[Either[R, R2]]): Command[R2] = {
      this.flatMap(f).flatMap {
        // recursion here is lazy so the stack won't blow up
        case Left(value) => tailRecM(f)
        case Right(result) => lift(result)
      }
    }
  }

  // Command sum type
  //// DUT interaction
  private[simcommand] case class Poke[I <: Data](signal: I, value: I) extends Command[Unit]
  private[simcommand] case class Peek[I <: Data](signal: I) extends Command[I]

  //// Simulator synchronization points
  private[simcommand] case class Step(cycles: Int) extends Command[Int]

  //// End of a command sequence / Pure value
  private[simcommand] case class Return[R](retval: R) extends Command[R]

  //// Continuation
  private[simcommand] case class Cont[R1, R2](a: Command[R1], f: R1 => Command[R2]) extends Command[R2]
  private[simcommand] case class Rec[R1, R2](st: R1, f: R1 => Command[Either[R1, R2]]) extends Command[R2]

  //// fork/join synchronization
  private[simcommand] case class ThreadHandle[R](id: Int)
  private[simcommand] case class Fork[R](c: Command[R], name: String) extends Command[ThreadHandle[R]] {
    def makeThreadHandle(id: Int): ThreadHandle[R] = ThreadHandle[R](id)
  }
  private[simcommand] case class Join[R](threadHandle: ThreadHandle[R]) extends Command[R]
  private[simcommand] case class Kill[R](threadHandle: ThreadHandle[R]) extends Command[R]

  // Inter-thread communication channels
  private[simcommand] case class ChannelHandle[T](id: Int)
  private[simcommand] case class MakeChannel[T](size: Integer) extends Command[ChannelHandle[T]]
  private[simcommand] case class Put[T](chan: ChannelHandle[T], data: T) extends Command[Unit]
  private[simcommand] case class GetBlocking[T](chan: ChannelHandle[T]) extends Command[T]
  private[simcommand] case class NonEmpty[T](chan: ChannelHandle[T]) extends Command[Boolean]

  // Public API

  def unsafeRun[R](cmd: Command[R], clock: Clock, cfg: Config = Config()): Result[R] = {
    Imperative.unsafeRun(cmd, clock, cfg)
  }

  def poke[I <: Data](signal: I, value: I): Command[Unit] = {
    Poke(signal, value)
  }

  def peek[I <: Data](signal: I): Command[I] = {
    Peek(signal)
  }

  def step[I <: Data](cycles: Int): Command[Int] = {
    Step(cycles)
  }

  def lift[R](value: R): Command[R] = {
    Return(value)
  }

  def noop(): Command[Unit] = {
    lift(())
  }

  def fork[R](cmd: Command[R], name: String): Command[ThreadHandle[R]] = {
    Fork(cmd, name)
  }

  def join[R](handle: ThreadHandle[R]): Command[R] = {
    Join(handle)
  }

  def makeChannel[R](size: Integer): Command[ChannelHandle[R]] = {
    MakeChannel(size)
  }

  def put[R](chan: ChannelHandle[R], data: R): Command[Unit] = {
    Put(chan, data)
  }

  def getBlocking[R](chan: ChannelHandle[R]): Command[R] = {
    GetBlocking(chan)
  }

  def nonEmpty[R](chan: ChannelHandle[R]): Command[Boolean] = {
    NonEmpty(chan)
  }

  // Command combinators (functions that take Commands and return Commands)
  def repeat(cmd: Command[_], n: Int): Command[Unit] = {
    lift(0).tailRec { iteration =>
      if (iteration == n) lift(Right(()))
      else for {
        _ <- cmd
      } yield Left(iteration + 1)
    }
  }

  def repeatCollect[R](cmd: Command[R], n: Int): Command[Seq[R]] = {
    lift((0, Vector.empty[R])).tailRec { case (iteration, collection) =>
      if (iteration == n) lift(Right(collection))
      else for {
        retval <- cmd
      } yield Left((iteration + 1, collection :+ retval))
    }
  }

  def doWhile(cmd: Command[Boolean]): Command[Unit] = {
    lift(()).tailRec { _: Unit =>
      cmd.flatMap {if (_) lift(Left(())) else lift(Right(()))}
    }
  }

  def doWhileCollect[R](cmd: Command[(R, Boolean)]): Command[Seq[R]] = {
    lift(Seq[R]()).tailRec { seq: Seq[R] =>
      for {
        result <- cmd
        retval <- {
          val (v, cond) = result
          if (cond) lift(Left(seq :+ v)) else lift(Right(seq))
        }
      } yield retval
    }
  }

  def doWhileCollectLast[R](cmd: Command[(R, Boolean)]): Command[R] = {
    lift(()).tailRec { _: Unit =>
      for {
        result <- cmd
        retval <- {
          val (v, cond) = result
          if (cond) lift(Left(())) else lift(Right(v))
        }
      } yield retval
    }
  }

  def whileM[R, S](cond: S => Boolean, action: Command[(R, S)], initialState: S): Command[Seq[R]] = {
    lift((initialState, Seq[R]())).tailRec { t: (S, Seq[R]) =>
      val (state: S, seq: Seq[R]) = t
      if (cond(state)) for {
        result <- action
        retval <- {
          val (v, newState) = result
          lift(Left((newState, seq :+ v)))
        }
      } yield retval
      else lift(Right(seq))
    }
  }

  def forever(cmd: Command[_]): Command[Nothing] = {
    lift(()).tailRec[Nothing] { _: Unit =>
      lift(Left(()))
    }
  }

  def zip[R1, R2](cmd1: Command[R1], cmd2: Command[R2]): Command[(R1, R2)] = {
    for {
      v1 <- cmd1
      v2 <- cmd2
    } yield (v1, v2)
  }

  def map2[R1, R2, R3](cmd1: Command[R1], cmd2: Command[R2], f: (R1, R2) => R3): Command[R3] = {
    for {
      v1 <- cmd1
      v2 <- cmd2
    } yield f(v1, v2)
  }

  // See Cats 'Traverse' which provides 'sequence' which is exactly this type signature
  def sequence[R](cmds: Seq[Command[R]]): Command[Seq[R]] = {
    lift((cmds, Vector.empty[R])).tailRec { case (cmds, retvalSeq) =>
      if (cmds.isEmpty) lift(Right(retvalSeq))
      else for {
        retval <- cmds.head
      } yield Left((cmds.tail, retvalSeq :+ retval))
    }
  }

  def traverse[R, R2](cmds: Seq[Command[R]])(f: R => Command[R2]): Command[Seq[R2]] = {
    sequence(cmds.map(_.flatMap(f)))
  }

  def concat[R](cmds: Seq[Command[R]]): Command[Unit] = {
    lift(cmds).tailRec { case cmds =>
      if (cmds.isEmpty) lift(Right(()))
      else for {
        _ <- cmds.head
      } yield Left(cmds.tail)
    }
  }

  def chain[R](cmds: Seq[R => Command[R]], initialRetval: R): Command[R] = {
    val initProgram: Command[R] = for {
      r <- lift(initialRetval)
      c <- cmds.head(r)
    } yield c

    cmds.tail.foldLeft(initProgram) { (c1: Command[R], c2: R => Command[R]) =>
      for {
        c1Ret <- c1
        c2Ret <- c2(c1Ret)
      } yield c2Ret
    }
  }

  def waitForValue[I <: Data](signal: I, value: I): Command[Unit] = {
    // TODO: return # of cycles this program waited
    val check: Command[Boolean] = for {
      peekedValue <- peek(signal)
      _ <- {
        if (peekedValue.litValue != value.litValue) // TODO: this won't work for record types
          step(1)
        else
          noop()
      }
    } yield peekedValue.litValue != value.litValue
    doWhile(check)
  }

  def checkSignal[I <: Data](signal: I, value: I): Command[Boolean] = {
    for {
      peeked <- peek(signal)
      _ <- {
        if (peeked.litValue != value.litValue) {Predef.assert(false, s"Signal $signal wasn't the expected value $value")}
        step(1)
      }
    } yield peeked.litValue == value.litValue
  }

  def checkStable[I <: Data](signal: I, value: I, cycles: Int): Command[Boolean] = {
    val checks = Seq.fill(cycles)(checkSignal(signal, value))
    val allPass = sequence(checks).map(_.forall(b => b))
    allPass // TODO: move 'expect' into Command sum type, unify with print (e.g. info), and other debug prints
  }
}
