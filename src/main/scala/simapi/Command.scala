package simapi

import chisel3._
import chiseltest._

import scala.annotation.tailrec
import scala.collection.mutable

sealed trait Command[R] {
  //def andThen[R2](next: => Command[R2]) = {}
}
case class Step[R](cycles: Int, next: () => Command[R]) extends Command[R]
case class Poke[R, I <: Data](signal: I, value: I, next: () => Command[R]) extends Command[R]
case class Peek[R, I <: Data](signal: I, next: I => Command[R]) extends Command[R]
case class Concat[R1, R2](a: Command[R1], next: R1 => Command[R2]) extends Command[R2]
case class Return[R](retval: R) extends Command[R]
case class Fork[R1, R2](c: Command[R1], next: () => Command[R2]) extends Command[R2]
// semantics of Fork:
// the thread calling Fork continues execution to the next block until a step is seen
// then the Fork'ed thread will execute until a step is seen and hand back control to the main thread, and so forth until the forked thread returns
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
  case class ThreadData(cmd: Command[_], name: String)
  case class InterpreterCfg(print: Boolean)
  case class EC(clock: Clock, threads: mutable.Buffer[ThreadData]) {
    // def run[R](...)
    // decrement
    // for all threads, run until step, for all threads, step them together w/ the simulator
    // repeat until all threads end in return
    // start: assume no joins, assume no thread kills needed
    // features: join, kill all threads when main thread returns
  }

  def run[R](cmd: Command[R], clock: Clock, print: Boolean): R = {
    runInner(cmd, clock, print)
  }

  private def runInner[R](cmd: Command[R], clock: Clock, print: Boolean): R = {
    var time = 0
    val ec = EC(clock, mutable.Buffer(ThreadData(cmd, "MAIN")))
    val cfg = InterpreterCfg(print)
    while (true) { // loop until main thread ends
      //while (true) { // loop per step
        /*
        val iteration = ec.threads.map { t =>
          val (nextCmd, cycles, newThreads) = runUntilSync(t, cfg, Seq.empty)
          ec.threads.append(newThreads:_*)
          t.copy(cmd=Step(cycles - 1, () => nextCmd))
          //(nextCmd, cycles, newThreads)
        }
        clock.step(iteration.head._2)
         */
      //}
      // assume only one thread
      val (nextCmd, cycles, newThreads) = runUntilSync(ec.threads.head, time, cfg, Seq.empty)
      // println(s"[runInner] nextCmd: $nextCmd at time $time")
      nextCmd match {
        case Return(retval) => return retval.asInstanceOf[R]
        case _ =>
          if (cfg.print) println(s"[runInner] Stepping $cycles cycles at time $time")
          clock.step(cycles)
          time = time + cycles
      }
      ec.threads(0) = ec.threads(0).copy(cmd=nextCmd)
    }
    ???
  }



  // @tailrec
  // NO LONGER tail recursive due to Concat
  private def runUntilSync(thread: ThreadData, time: Int, cfg: InterpreterCfg, newThreads: Seq[ThreadData]): (Command[_], Int, Seq[ThreadData]) = {
    thread.cmd match {
      case Fork(c, next) =>
        if (cfg.print) println(s"[runUntilSync] [Fork] Forking off thread from ${thread.name}")
        runUntilSync(thread.copy(cmd=next()), time, cfg, newThreads :+ ThreadData(c, "child"))
      case Step(cycles, next) =>
        if (cfg.print) println(s"[runUntilSync] [Step] Stepping $cycles cycles from ${thread.name}")
        (next(), cycles, newThreads)
      case Poke(signal, value, next) =>
        if (cfg.print) println(s"[runUntilSync] [Poke] Poking $signal = $value from ${thread.name} at time $time")
        signal.poke(value)
        runUntilSync(thread.copy(cmd=next()), time, cfg, newThreads)
      case Peek(signal, next) =>
        val value = signal.peek()
        if (cfg.print) println(s"[runUntilSync] [Peek] Peeking $signal -> $value from ${thread.name} at time $time")
        runUntilSync(thread.copy(cmd=next(value)), time, cfg, newThreads)
      case Concat(a, next) =>
        val retval = runUntilSync(thread.copy(cmd=a), time, cfg, newThreads)
        // if (cfg.print) println(s"[runUntilSync] [Concat] Got retval $retval from ${thread.name} at time $time")
        // retval will contain a Return() or a Command[_] from a pending step which means 'a' is not yet complete
        retval match {
          case (Return(retval), 0, newTs) => // a is 'complete' so continue executing next
            runUntilSync(thread.copy(cmd=next(retval)), time, cfg, newThreads ++ newTs)
          case (c: Command[_], cycles, newTs) => // a has hit a step so we should save next in a new Concat
            (Concat(c, next), cycles, newTs)
        }
      case Return(retval) =>
        if (cfg.print) println(s"[runUntilSync] [Return] Returning with value $retval from ${thread.name} at time $time")
        (Return(retval), 0, newThreads)
    }
  }
}
