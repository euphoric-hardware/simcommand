package simcommand.runtime

import simcommand.runtime.Bridges._
import sourcecode.{Enclosing, FileName, Line}

object Primitives {
  case class SourceInfo(line: Line, fileName: FileName, enclosing: Enclosing)
  object SourceInfo {
    def getSourceInfo(implicit line: Line, fileName: FileName, enclosing: Enclosing): SourceInfo = {
      SourceInfo(line, fileName, enclosing)
    }
  }

  /**
   * This class represents an RTL simulation command and its return value
   *
   * @tparam R Type of the command's return value
   */
  sealed abstract class Command[R](implicit sourceInfo: SourceInfo) {
    val name: String

    final def map[R2](f: R => R2): Command[R2] = {
      flatMap(r => Return(f(r)))
    }

    final def flatMap[R2](f: R => Command[R2]): Command[R2] = {
      this match {
        case Return(retval) => f(retval)
        case c: Command[R] => Cont(c, f)
      }
    }

    // tailRec provides an efficient tail recursion primitive. If the provided
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
        case Right(result) => Return(result)
      }
    }

    def sourceInfoString: String = {
      name + "(" + sourceInfo.fileName.value + ":" + sourceInfo.line.value + ")"
    }
  }

  // Lift a pure value into the Command monad
  private[simcommand] case class Return[R](retval: R)(implicit sourceInfo: SourceInfo) extends Command[R] {
    override val name: String = "return"
  }

  // Continuations, recursion primitives
  private[simcommand] case class Cont[R1, R2](a: Command[R1], f: R1 => Command[R2])(implicit sourceInfo: SourceInfo) extends Command[R2] {
    override val name: String = "cont"
  }
  private[simcommand] case class Rec[R1, R2](st: R1, f: R1 => Command[Either[R1, R2]])(implicit sourceInfo: SourceInfo) extends Command[R2] {
    override val name: String = "rec"
  }

  // Basic DUT interaction
  private[simcommand] case class Poke[I](signal: Interactable[I], value: I)(implicit sourceInfo: SourceInfo) extends Command[Unit] {
    override val name: String = "poke"
  }
  private[simcommand] case class Peek[I](signal: Interactable[I])(implicit sourceInfo: SourceInfo) extends Command[I] {
    override val name: String = "peek"
  }
  private[simcommand] case class Step(cycles: Int)(implicit sourceInfo: SourceInfo) extends Command[Unit] {
    override val name: String = "step"
  }

  // Fork/Join simulation threading
  private[simcommand] case class ThreadHandle[R](id: Int)
  private[simcommand] case class Fork[R](c: Command[R], threadName: Option[String], order: Int)(implicit sourceInfo: SourceInfo) extends Command[ThreadHandle[R]] {
    def makeThreadHandle(id: Int): ThreadHandle[R] = ThreadHandle[R](id)
    override val name: String = "fork"
  }
  private[simcommand] case class Join[R](threadHandle: ThreadHandle[R])(implicit sourceInfo: SourceInfo) extends Command[R] {
    override val name: String = "join"
  }
  private[simcommand] case class Kill[R](threadHandle: ThreadHandle[R])(implicit sourceInfo: SourceInfo) extends Command[R] {
    override val name: String = "kill"
  }

  // Inter-thread communication via channels
  private[simcommand] case class ChannelHandle[T](id: Int)
  private[simcommand] case class MakeChannel[T](size: Int)(implicit sourceInfo: SourceInfo) extends Command[ChannelHandle[T]] {
    override val name: String = "makeChannel"
  }
  private[simcommand] case class Put[T](chan: ChannelHandle[T], data: T)(implicit sourceInfo: SourceInfo) extends Command[Unit] {
    override val name: String = "put"
  }
  private[simcommand] case class GetBlocking[T](chan: ChannelHandle[T])(implicit sourceInfo: SourceInfo) extends Command[T] {
    override val name: String = "getBlocking"
  }
  private[simcommand] case class NonEmpty[T](chan: ChannelHandle[T])(implicit sourceInfo: SourceInfo) extends Command[Boolean] {
    override val name: String = "nonEmpty"
  }
}