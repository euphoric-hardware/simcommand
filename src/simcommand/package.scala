import chisel3.{Data}

import scala.collection.mutable.ArrayBuffer
import sourcecode.{Line, FileName, Enclosing}

package object simcommand {

  // Below is inspired by the trampolined continuation in TailCalls.scala (in the Scala stdlib)
  /**
    * This class represents an RTL simulation command and its return value
    * @tparam R Type of the command's return value
    */
  sealed abstract class Command[R](implicit val line: Line, val filename: FileName, val enclosing: Enclosing) {
    final def map[R2](f: R => R2): Command[R2] = {
      flatMap(r => Return(f(r)))
    }

    final def flatMap[R2](f: R => Command[R2]): Command[R2] = {
      this match {
        case Return(retval) => f(retval)
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
        case Left(_) => tailRecM(f)
        case Right(result) => lift(result)
      }
    }

    def debugInfo: String = {
      this.getClass.getSimpleName + "(" + filename.value + ":" + line.value + ")"
    }
  }

  sealed trait Interactable[I] {
    def set(value: I): Unit
    def get(): I
    def compare(value: I): Command[Boolean]
  }

  implicit class Chisel3Interactor[I <: Data](value: I) extends Interactable[I] {
    val tester = chiseltest.testableData(value)
    override def set(p: I): Unit = tester.poke(p)
    override def get(): I = tester.peek()
    // TODO: Implement a better comparator for chisel3 datatypes
    override def compare(v: I): Command[Boolean] = peek(this).map(_.litValue == v.litValue)
  }

  private case class PrimitiveInteractor[I](var value: I) extends Interactable[I] {
    override def set(p: I): Unit = value = p
    override def get(): I = value
    override def compare(v: I): Command[Boolean] = value match {
      case x: Data => peek(this).map(_.asInstanceOf[Data].litValue == v.asInstanceOf[Data].litValue)
      case _ => peek(this).map(_ == v)
    }
    override def hashCode(): Int = System.identityHashCode(this)
  }

  trait Steppable {
    def step(cycles: Int): Unit
  }
  private case class Chisel3Clock(clock: chisel3.Clock) extends Steppable {
    def step(cycles: Int): Unit = chiseltest.testableClock(clock).step(cycles)
  }
  case class FakeClock() extends Steppable {
    def step(cycles: Int): Unit = {}
  }

  // Command sum type
  //// DUT interaction
  private[simcommand] case class Poke[I](signal: Interactable[I], value: I)(implicit line: Line, filename: FileName, enclosing: Enclosing) extends Command[Unit]
  private[simcommand] case class Peek[I](signal: Interactable[I])(implicit line: Line, filename: FileName, enclosing: Enclosing) extends Command[I]

  //// Simulator synchronization points
  private[simcommand] case class Step(cycles: Int)(implicit line: Line, filename: FileName, enclosing: Enclosing) extends Command[Unit]

  //// End of a command sequence / Pure value
  private[simcommand] case class Return[R](retval: R)(implicit line: Line, filename: FileName, enclosing: Enclosing) extends Command[R]

  //// Continuation
  private[simcommand] case class Cont[R1, R2](a: Command[R1], f: R1 => Command[R2])(implicit line: Line, filename: FileName, enclosing: Enclosing) extends Command[R2]
  private[simcommand] case class Rec[R1, R2](st: R1, f: R1 => Command[Either[R1, R2]])(implicit line: Line, filename: FileName, enclosing: Enclosing) extends Command[R2]

  //// fork/join synchronization
  private[simcommand] case class ThreadHandle[R](id: Int)
  private[simcommand] case class Fork[R](c: Command[R], name: Option[String], order: Int)(implicit line: Line, filename: FileName, enclosing: Enclosing) extends Command[ThreadHandle[R]] {
    def makeThreadHandle(id: Int): ThreadHandle[R] = ThreadHandle[R](id)
  }
  private[simcommand] case class Join[R](threadHandle: ThreadHandle[R])(implicit line: Line, filename: FileName, enclosing: Enclosing) extends Command[R]
  private[simcommand] case class Kill[R](threadHandle: ThreadHandle[R])(implicit line: Line, filename: FileName, enclosing: Enclosing) extends Command[R]

  // Inter-thread communication channels
  private[simcommand] case class ChannelHandle[T](id: Int)
  private[simcommand] case class MakeChannel[T](size: Int)(implicit line: Line, filename: FileName, enclosing: Enclosing) extends Command[ChannelHandle[T]]
  private[simcommand] case class Put[T](chan: ChannelHandle[T], data: T)(implicit line: Line, filename: FileName, enclosing: Enclosing) extends Command[Unit]
  private[simcommand] case class GetBlocking[T](chan: ChannelHandle[T])(implicit line: Line, filename: FileName, enclosing: Enclosing) extends Command[T]
  private[simcommand] case class NonEmpty[T](chan: ChannelHandle[T])(implicit line: Line, filename: FileName, enclosing: Enclosing) extends Command[Boolean]

  // Public API

  def unsafeRun[R](cmd: Command[R], clock: chisel3.Clock, cfg: Config = Config()): Result[R] = {
    unsafeRun(cmd, Chisel3Clock(clock), cfg)
  }

  def unsafeRun[R](cmd: Command[R], clock: Steppable, cfg: Config): Result[R] = {
    Imperative.unsafeRun(cmd, clock, cfg)
  }

  def poke[I](signal: Interactable[I], value: I)(implicit line: Line, filename: FileName, enclosing: Enclosing): Command[Unit] = {
    Poke(signal, value)
  }

  def peek[I](signal: Interactable[I])(implicit line: Line, filename: FileName, enclosing: Enclosing): Command[I] = {
    Peek(signal)
  }

  def step(cycles: Int)(implicit line: Line, filename: FileName, enclosing: Enclosing): Command[Unit] = {
    Step(cycles)
  }

  def lift[R](value: R)(implicit line: Line, filename: FileName, enclosing: Enclosing): Command[R] = {
    Return(value)
  }

  def noop()(implicit line: Line, filename: FileName, enclosing: Enclosing): Command[Unit] = {
    lift(())
  }

  def fork[R](cmd: Command[R])(implicit line: Line, filename: FileName, enclosing: Enclosing): Command[ThreadHandle[R]] = {
    Fork(cmd, None, order = 0)
  }

  def fork[R](cmd: Command[R], name: String, order: Int = 0)(implicit line: Line, filename: FileName, enclosing: Enclosing): Command[ThreadHandle[R]] = {
    Fork(cmd, Some(name), order)
  }

  def join[R](handle: ThreadHandle[R])(implicit line: Line, filename: FileName, enclosing: Enclosing): Command[R] = {
    Join(handle)
  }

  def makeChannel[R](size: Int)(implicit line: Line, filename: FileName, enclosing: Enclosing): Command[ChannelHandle[R]] = {
    MakeChannel(size)
  }

  def put[R](chan: ChannelHandle[R], data: R)(implicit line: Line, filename: FileName, enclosing: Enclosing): Command[Unit] = {
    Put(chan, data)
  }

  def getBlocking[R](chan: ChannelHandle[R])(implicit line: Line, filename: FileName, enclosing: Enclosing): Command[R] = {
    GetBlocking(chan)
  }

  def nonEmpty[R](chan: ChannelHandle[R])(implicit line: Line, filename: FileName, enclosing: Enclosing): Command[Boolean] = {
    NonEmpty(chan)
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

  class CombinatorialDependencyException(name: Option[String], order: Int, cmd: Command[_])
    extends Exception("Detected combinatorial loop in thread '" + name + "' with order " + order + " caused by command " + cmd.debugInfo)
}
