import chisel3.{Clock, Data}

package object simcommand {

  // Below is inspired by the trampolined continuation in TailCalls.scala (in the Scala stdlib)
  /**
    * This class represents an RTL simulation command and its return value
    * @tparam R Type of the command's return value
    */
  abstract class Command[+R] {
    final def map[R2](f: R => R2): Command[R2] = {
      flatMap(r => Return(f(r)))
    }

    // flatMap is NOT stack safe
    final def flatMap[R2](f: R => Command[R2]): Command[R2] = {
      this match {
        case Return(retval) => f(retval)
        case c: Cont[a1, a2] => Cont(c.a, (x: a1) => c.f(x) flatMap f)
        case c: Command[R] => Cont(c, f)
      }
    }
  }

  // Command sum type
  //// DUT interaction
  private[simcommand] case class Poke[I <: Data](signal: I, value: I) extends Command[Unit]
  private[simcommand] case class Peek[I <: Data](signal: I) extends Command[I]

  //// Simulator synchronization points
  private[simcommand] case class Step(cycles: Int) extends Command[Unit]

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
  // private[simcommand] case class ChannelHandle[T](id: Int)
  // private[simcommand] case class MakeChannel[T]() extends Command[ChannelHandle[T]]
  // private[simcommand] case class Put[T](chan: ChannelHandle[T], data: T) extends Command[Unit]
  // private[simcommand] case class GetBlocking[T](chan: ChannelHandle[T]) extends Command[T]
  // private[simcommand] case class NonEmpty[T](chan: ChannelHandle[T]) extends Command[Boolean]

  // Public API

  def unsafeRun[R](cmd: Command[R], clock: Clock, cfg: Config = Config()): Result[R] = {
    Imperative.unsafeRun(cmd, clock, cfg)
  }

  // tailRecM will continually call f until it returns Command[Right]
  // not tail recursive, but still stack safe
  // similar implementation as cats.Free: https://github.com/typelevel/cats/pull/1041/files#diff-7349edfd077f9612f7181fe1f8caca63ac667c847ce83b53dceae4d08040fd55
  final def tailRecM[R, R2](r: R)(f: R => Command[Either[R, R2]]): Command[R2] = {
    Rec(r, f)
    // f(r).flatMap {
    //   case Left(value) => tailRecM(value)(f) // recursion here is lazy so the stack won't blow up
    //   case Right(value) => lift(value)
    // }
  }

  def poke[I <: Data](signal: I, value: I): Command[Unit] = {
    Poke(signal, value)
  }

  def peek[I <: Data](signal: I): Command[I] = {
    Peek(signal)
  }

  def step[I <: Data](cycles: Int): Command[Unit] = {
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

  // Command combinators (functions that take Commands and return Commands)

  def repeat(cmd: Command[_], n: Int): Command[Unit] = {
    tailRecM(0) { iteration =>
      if (iteration == n) lift(Right(()))
      else for {
        _ <- cmd
      } yield Left(iteration + 1)
    }
  }

  def repeatCollect[R](cmd: Command[R], n: Int): Command[Seq[R]] = {
    tailRecM(0, Vector.empty[R]) { case (iteration, collection) =>
      if (iteration == n) lift(Right(collection))
      else for {
        retval <- cmd
      } yield Left((iteration + 1, collection :+ retval))
    }
  }

  def doWhile(cmd: Command[Boolean]): Command[Unit] = {
    tailRecM(()) { _: Unit =>
      for {
        cond <- cmd
        retval <- {if (cond) lift(Left(())) else lift(Right(()))}
      } yield retval
    }
  }

  def doWhileCollect[R](cmd: Command[(R, Boolean)]): Command[Seq[R]] = {
    ???
  }

  def doWhileCollectLast[R](cmd: Command[(R, Boolean)]): Command[R] = {
    ???
  }

  def doWhile[R, S](cond: S => Boolean, action: Command[(R, S)], initialState: S): Command[Seq[R]] = {
    ???
  }

  def forever(cmd: Command[_]): Command[Nothing] = {
    tailRecM(()){ _: Unit =>
      lift(Left(cmd))
    }
  }

  def zip[R1, R2](cmd1: Command[R1], cmd2: Command[R2]): Command[(R1, R2)] = {
    ???
  }

  def map2[R1, R2, R3](cmd1: Command[R1], cmd2: Command[R2], f: (R1, R2) => R3): Command[R3] = {
    ???
  }

  // See Cats 'Traverse' which provides 'sequence' which is exactly this type signature
  def sequence[R](cmds: Seq[Command[R]]): Command[Seq[R]] = {
    tailRecM((cmds, Vector.empty[R])) { case (cmds, retvalSeq) =>
      if (cmds.isEmpty) lift(Right(retvalSeq))
      else for {
        retval <- cmds.head
      } yield Left((cmds.tail, retvalSeq :+ retval))
    }
  }

  def traverse[R, R2](cmds: Seq[Command[R]])(f: R => Command[R2]): Seq[Command[R2]] = {
    ???
  }

  // specialization of sequence to throw away return values
  // TODO: is this called sequence_ in cats?
  def concat[R](cmds: Seq[Command[R]]): Command[Unit] = {
    tailRecM(cmds) { case cmds =>
      if (cmds.isEmpty) lift(Right(noop()))
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

  // TODO: duplicate
  def ifThenElse[R](cond: Command[Boolean], ifTrue: Command[R], ifFalse: Command[R]): Command[R] = {
    for {
      c <- cond
      result <- {
        if (c) ifTrue
        else ifFalse
      }
    } yield result
  }

  // TODO: should be a member of Command[Boolean]
  def ifM[R](cond: Command[Boolean], ifTrue: Command[R], ifFalse: Command[R]): Command[R] = {
    for {
      c <- cond
      result <- {if (c) ifTrue else ifFalse}
    } yield result
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
