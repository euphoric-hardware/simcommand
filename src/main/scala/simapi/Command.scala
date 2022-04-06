package simapi

import chisel3._
import chiseltest._

sealed trait Command[R] {
  //def andThen[R2](next: => Command[R2]) = {}
}
case class Step[R](cycles: Int, next: () => Command[R]) extends Command[R]
case class Poke[R, I <: Data](signal: I, value: I, next: () => Command[R]) extends Command[R]
case class Peek[R, I <: Data](signal: I, next: I => Command[R]) extends Command[R]
case class Concat[R](a: Command[R], next: R => Command[R]) extends Command[R]
case class Return[R](retval: R) extends Command[R]
case class Fork[R1, R2](c: Command[R1], next: () => Command[R2]) extends Command[R2]
// case class Join[R1, R2](c: Fork[R1, _], next: R1 => Command[R2]) extends Command[R2]

/*
class EC() {
  val threads: mutable.Seq[(Command[_], Status)]
  def step(intf: Module): Unit = {
    for (thread <- threads) {
      // take a Step with cycles > 1 and decrement it and put it back in the processing queue
    }
  }
}
 */

object Command {
  def run[R](cmd: Command[R], clock: Clock, print: Boolean): R = {
    cmd match {
      case Step(cycles, next) =>
        if (print) println(s"[Step] Stepping $cycles cycles")
        //impl.step(cycles)
        clock.step(cycles)
        run(next(), clock, print)
      case Poke(signal, value, next) =>
        if (print) println(s"[Poke] Poking $signal = $value")
        // impl.setSignal(signal, value)
        signal.poke(value)
        run(next(), clock, print)
      case Peek(signal, next) =>
        //val value = impl.getSignal(signal)
        val value = signal.peek()
        if (print) println(s"[Peek] Peeking $signal -> $value")
        run(next(value), clock, print)
      case Concat(a, next) =>
        val retval = run(a, clock, print)
        println(s"[Concat] Running first command and got $retval")
        run(next(retval), clock, print)
      case Return(retval) =>
        if (print) println(s"[Return] Returning with value $retval")
        retval
    }
  }
}
