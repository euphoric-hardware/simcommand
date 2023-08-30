import scala.collection.mutable.ArrayBuffer
import sourcecode.{Enclosing, FileName, Line}
import simcommand.runtime.Primitives._
import simcommand.runtime.Bridges._
import simcommand.runtime.{Bridges, Config, Imperative, Result}

package object simcommand {
  type Command[R] = simcommand.runtime.Primitives.Command[R]
  type Interactable[I] = simcommand.runtime.Bridges.Interactable[I]
  type ChannelHandle[T] = simcommand.runtime.Primitives.ChannelHandle[T]
  val FakeClock: Bridges.FakeClock.type = simcommand.runtime.Bridges.FakeClock

  // Public API
  def unsafeRun[R](cmd: Command[R], clock: chisel3.Clock, cfg: Config = Config()): Result[R] = {
    unsafeRun(cmd, Chisel3Clock(clock), cfg)
  }

  def unsafeRun[R](cmd: Command[R], clock: Steppable, cfg: Config): Result[R] = {
    Imperative.unsafeRun(cmd, clock, cfg)
  }

  def poke[I](signal: Interactable[I], value: I)(implicit line: Line, fileName: FileName, enclosing: Enclosing): Command[Unit] = {
    Poke(signal, value)(SourceInfo(line, fileName, enclosing))
  }

  def peek[I](signal: Interactable[I])(implicit line: Line, fileName: FileName, enclosing: Enclosing): Command[I] = {
    Peek(signal)(SourceInfo(line, fileName, enclosing))
  }

  def step(cycles: Int)(implicit line: Line, fileName: FileName, enclosing: Enclosing): Command[Unit] = {
    Step(cycles)(SourceInfo(line, fileName, enclosing))
  }

  def lift[R](value: R)(implicit line: Line, fileName: FileName, enclosing: Enclosing): Command[R] = {
    Return(value)(SourceInfo(line, fileName, enclosing))
  }

  def noop()(implicit line: Line, fileName: FileName, enclosing: Enclosing): Command[Unit] = {
    lift(())
  }

  def fork[R](cmd: Command[R])(implicit line: Line, fileName: FileName, enclosing: Enclosing): Command[ThreadHandle[R]] = {
    Fork(cmd, None, order = 0)(SourceInfo(line, fileName, enclosing))
  }

  def fork[R](cmd: Command[R], name: String, order: Int = 0)(implicit line: Line, fileName: FileName, enclosing: Enclosing): Command[ThreadHandle[R]] = {
    Fork(cmd, Some(name), order)(SourceInfo(line, fileName, enclosing))
  }

  def join[R](handle: ThreadHandle[R])(implicit line: Line, fileName: FileName, enclosing: Enclosing): Command[R] = {
    Join(handle)(SourceInfo(line, fileName, enclosing))
  }

  def makeChannel[R](size: Int)(implicit line: Line, fileName: FileName, enclosing: Enclosing): Command[ChannelHandle[R]] = {
    MakeChannel(size)(SourceInfo(line, fileName, enclosing))
  }

  def put[R](chan: ChannelHandle[R], data: R)(implicit line: Line, fileName: FileName, enclosing: Enclosing): Command[Unit] = {
    Put(chan, data)(SourceInfo(line, fileName, enclosing))
  }

  def getBlocking[R](chan: ChannelHandle[R])(implicit line: Line, fileName: FileName, enclosing: Enclosing): Command[R] = {
    GetBlocking(chan)(SourceInfo(line, fileName, enclosing))
  }

  def nonEmpty[R](chan: ChannelHandle[R])(implicit line: Line, fileName: FileName, enclosing: Enclosing): Command[Boolean] = {
    NonEmpty(chan)(SourceInfo(line, fileName, enclosing))
  }

  def binding[I](value: I): Interactable[I] = {
    PrimitiveInteractor(value)
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
    lift((0, ArrayBuffer.empty[R])).tailRec { case (it, buf) =>
      if (it == n) lift(Right(buf.toSeq))
      else cmd.flatMap {value => lift(Left((it + 1, buf += value)))}
    }
  }

  def doWhile(cmd: Command[Boolean]): Command[Unit] = {
    lift(()).tailRec { _: Unit =>
      cmd.flatMap {if (_) lift(Left(())) else lift(Right(()))}
    }
  }

  def doWhileCollect[R](cmd: Command[(R, Boolean)]): Command[Seq[R]] = {
    lift(ArrayBuffer.empty[R]).tailRec { buf: ArrayBuffer[R] =>
      for {
        result <- cmd
        retval <- {
          val (v, cond) = result
          if (cond) lift(Left(buf += v)) else lift(Right(buf.toSeq))
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
        value <- {
          val (v, newState) = result
          lift(Left((newState, seq :+ v)))
        }
      } yield value
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
    lift(cmds).tailRec { cmds =>
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

  def waitForValue[I](signal: Interactable[I], value: I, cycles: Int = 1): Command[Unit] = {
    // TODO: return # of cycles this program waited
    doWhile(for {
      done <- signal.compare(value)
      _ <- {if (!done) step(cycles) else noop()}
    } yield !done)
  }

  def checkStable[I](signal: Interactable[I], value: I, cycles: Int): Command[Boolean] = {
    repeatCollect(
      for {
        good <- signal.compare(value)
        _ <- step(1)
      } yield good,
      cycles
    ).map(_.forall(x => x))
  }
}
