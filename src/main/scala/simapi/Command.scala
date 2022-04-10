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
case class Fork[R1, R2](c: Command[R1], name: String, next: () => Command[R2]) extends Command[R2]
// semantics of Fork:
// the thread calling Fork continues execution to the next block until a step is seen
// then the Fork'ed thread will execute until a step is seen and hand back control to the main thread, and so forth until the forked thread returns
// case class Join[R1, R2](c: Fork[R1, _], next: R1 => Command[R2]) extends Command[R2]

object Command {
  case class ThreadData(cmd: Command[_], name: String)
  case class InterpreterCfg(print: Boolean)
  case class EC(clock: Clock, threads: Seq[ThreadData]) {
  }

  def run[R](cmd: Command[R], clock: Clock, print: Boolean): R = {
    runInner(cmd, clock, print)
  }

  private def completedThread(t: ThreadData): Boolean = {
    t match {
      case ThreadData(Return(_), _) => true
      case _ => false
    }
  }

  private def runInner[R](cmd: Command[R], clock: Clock, print: Boolean): R = {
    // start: assume no joins, assume no thread kills needed
    // features: join, kill all threads when main thread returns
    val cfg = InterpreterCfg(print)
    var time = 0
    var ec = EC(clock, Seq(ThreadData(cmd, "MAIN")))
    while (true) { // Until the main thread returns
      // Go through all threads and run them until they hit a sync state
      // Do this recursively to handle new thread spawning on this timestep
      val newThreadHandles = runThreadsUntilSync(ec.threads, time, cfg)

      // If the main thread returns, we are done
      assert(newThreadHandles.head.name == "MAIN")
      val done = newThreadHandles.head match {
        case ThreadData(Return(retval), _) => Some(retval)
        case _ => None
      }

      // Remove all completed threads from the thread list
      val completedThreads = newThreadHandles.filter(completedThread)
      completedThreads.foreach {
        case ThreadData(Return(retval), name) =>
          println(s"[runInner] Return to top-level from thread $name with value $retval")
        case _ => Predef.assert(false, "Interpreter error")
      }
      val nextThreadHandles = newThreadHandles.filter{t => !completedThread(t)}

      if (done.isDefined) {
        if (cfg.print) println(s"[runInner] Main thread returned at time $time with value ${done.get}")
        if (ec.threads.length > 1) println(s"[runInner] Main thread returning while child threads ${ec.threads.tail} aren't yet done")
        return done.get.asInstanceOf[R]
      }

      // Advance time by 1 cycle (TODO: do we need to know the cycle advancement for each thread?)
      ec.clock.step(1)
      if (cfg.print) println(s"[runInner] Stepping 1 cycle at time $time")
      time = time + 1

      ec = ec.copy(threads=nextThreadHandles)
      // Single thread implementation
      /*
      val (newThreadHandle, cycles, newThreads) = runUntilSync(ec.threads.head, time, cfg, Seq.empty)
      // println(s"[runInner] nextCmd: $nextCmd at time $time")
      newThreadHandle match {
        case ThreadData(Return(retval), _) => return retval.asInstanceOf[R]
        case _ =>
          if (cfg.print) println(s"[runInner] Stepping $cycles cycles at time $time")
          clock.step(cycles)
          time = time + cycles
      }
      ec.threads(0) = newThreadHandle
      */
    }
    ???
  }
  def runThreadsUntilSync(threads: Seq[ThreadData], time: Int, cfg: InterpreterCfg): Seq[ThreadData] = {
    val iteration = threads.map { t =>
      val (newThreadHandle, cycles, newThreads) = runUntilSync(t, time, cfg, Seq.empty)
      //println(s"cycles: $cycles")
      //println(s"newThreadHandle: $newThreadHandle")
      Predef.assert(cycles == 1 || cycles == 0)
      (newThreadHandle, cycles, newThreads)
    }
    if (iteration.map(_._3.length).sum == 0) { // no new threads spawned, we're done
      iteration.map(_._1)
    } else { // all the current threads are done, but they have spawned new threads which need to be run until a syncpoint is hit
      val existingThreads = iteration.map(_._1)
      val newThreads = iteration.flatMap(_._3)
      val newThreadsRun = runThreadsUntilSync(newThreads, time, cfg)
      existingThreads ++ newThreadsRun
    }
  }

  // @tailrec
  // NO LONGER tail recursive due to Concat
  private def runUntilSync(thread: ThreadData, time: Int, cfg: InterpreterCfg, newThreads: Seq[ThreadData]): (ThreadData, Int, Seq[ThreadData]) = {
    thread.cmd match {
      case Fork(c, name, next) =>
        if (cfg.print) println(s"[runUntilSync] [Fork] Forking off thread from ${thread.name} at time $time")
        runUntilSync(thread.copy(cmd=next()), time, cfg, newThreads :+ ThreadData(c, name))
      case Step(cycles, next) =>
        if (cycles == 0) { // this Step is a nop
          if (cfg.print) println(s"[runUntilSync] [Step] Stepping 0 cycles (NOP) from ${thread.name} at time $time")
          runUntilSync(thread.copy(cmd=next()), time, cfg, newThreads)
        } else if (cycles == 1) { // this Step will complete in 1 more cycle
          if (cfg.print) println(s"[runUntilSync] [Step] Stepping 1 cycle from ${thread.name} at time $time")
          (thread.copy(cmd=next()), 1, newThreads)
        } else { // this Step requires 2 or more cycles to complete
          if (cfg.print) println(s"[runUntilSync] [Step] Stepping 1 cycle from ${thread.name} at time $time")
          (thread.copy(cmd=Step(cycles - 1, next)), 1, newThreads)
        }
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
          case (ThreadData(Return(retval), _), 0, newTs) => // a is 'complete' so continue executing next
            runUntilSync(thread.copy(cmd=next(retval)), time, cfg, newThreads ++ newTs)
          case (ThreadData(c: Command[_], _), cycles, newTs) => // a has hit a step so we should save next in a new Concat
            (thread.copy(cmd=Concat(c, next)), cycles, newTs)
        }
      case Return(retval) =>
        println(s"HERE HERE HERE ${thread.name}")
        if (cfg.print) println(s"[runUntilSync] [Return] Returning with value $retval from ${thread.name} at time $time")
        (thread.copy(cmd=Return(retval)), 0, newThreads)
    }
  }
}
