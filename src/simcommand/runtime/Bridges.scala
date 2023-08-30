package simcommand.runtime

import simcommand.runtime.Primitives._
import chisel3.Data

// Bridges between the pure Scala Command primitives and RTL simulator I/Os and clocks
object Bridges {
  sealed trait Interactable[I] {
    def set(value: I): Unit
    def get(): I
    def compare(value: I): Command[Boolean]
  }

  implicit class Chisel3Interactor[I <: Data](value: I) extends Interactable[I] {
    val tester = chiseltest.testableData(value)
    override def set(p: I): Unit = tester.poke(p)
    override def get(): I = tester.peek()
    // TODO: Implement a better comparator for chisel3 datatypes, this only works for non-aggregate data types
    override def compare(v: I): Command[Boolean] = Peek(this)(SourceInfo.getSourceInfo).map(_.litValue == v.litValue)
  }

  case class PrimitiveInteractor[I](var value: I) extends Interactable[I] {
    override def set(p: I): Unit = value = p
    override def get(): I = value
    override def compare(v: I): Command[Boolean] = value match {
      case x: Data => Peek(this)(SourceInfo.getSourceInfo).map(_.asInstanceOf[Data].litValue == v.asInstanceOf[Data].litValue)
      case _ => Peek(this)(SourceInfo.getSourceInfo).map(_ == v)
    }
    override def hashCode(): Int = System.identityHashCode(this)
  }

  trait Steppable {
    def step(cycles: Int): Unit
  }

  case class Chisel3Clock(clock: chisel3.Clock) extends Steppable {
    def step(cycles: Int): Unit = chiseltest.testableClock(clock).step(cycles)
  }

  case class FakeClock() extends Steppable {
    def step(cycles: Int): Unit = {}
  }
}