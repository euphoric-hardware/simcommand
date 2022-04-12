package simapi

import chisel3._
import chiseltest._
import collection.mutable

sealed trait Command[+R] {
  // public API speculation
  // def fork(next => Command[R2]): Command[R2]
  // def andThen[R2](next: => Command[R2]) = {}
  // TODO: have join_all - default and join_any functionality
}
case class Step[R](cycles: Int, next: () => Command[R]) extends Command[R]
case class Poke[R, I <: Data](signal: I, value: I, next: () => Command[R]) extends Command[R]
case class Peek[R, I <: Data](signal: I, next: I => Command[R]) extends Command[R]
case class Concat[R1, R2](a: Command[R1], next: R1 => Command[R2]) extends Command[R2]
case class Return[R](retval: R) extends Command[R]
case class ThreadHandle[R](id: Int)
case class Fork[R1, R2](c: Command[R1], name: String, next: ThreadHandle[R1] => Command[R2]) extends Command[R2] {
  def makeThreadHandle(id: Int): ThreadHandle[R1] = ThreadHandle[R1](id) // should be private, but need access to R1
}
// semantics of Fork:
// the thread calling Fork continues execution to the next block until a step is seen
// then the Fork'ed thread will execute until a step is seen and hand back control to the main thread, and so forth until the forked thread returns
case class Join[R1, R2](threadHandle: ThreadHandle[R1], next: R1 => Command[R2]) extends Command[R2]
// semantics of Join:
// the thread calling Join on another thread will block (allow infinite time advancement) until the thread being joined is complete and returns a value

object Command {
  private class ThreadIdGenerator {
    var count = 0
    def getNewThreadId: Int = {
      count = count + 1
      count
    }
  }
  case class ThreadData(cmd: Command[_], name: String, id: Int)
  case class InterpreterCfg(print: Boolean)
  case class EC(clock: Clock, threads: Seq[ThreadData])

  def combine[R](cmds: Seq[R => Command[R]], initialRetval: R): Command[R] = {
    cmds.tail.foldLeft(Concat(Return(initialRetval), r => cmds.head(r))) { (c1: Command[R], c2: R => Command[R]) =>
      Concat[R, R](c1, (r: R) => c2(r))
    }
  }

  def run[R](cmd: Command[R], clock: Clock, print: Boolean): R = {
    runInner(cmd, clock, print, new ThreadIdGenerator())
  }

  private def completedThread(t: ThreadData): Boolean = {
    t match {
      case ThreadData(Return(_), _, _) => true
      case _ => false
    }
  }

  private def threadWaitingForJoin(t: ThreadData): Boolean = {
    t match {
      case ThreadData(Join(_, _), _, _) => true
      case _ => false
    }
  }

  private def runInner[R](cmd: Command[R], clock: Clock, print: Boolean, threadIdGen: ThreadIdGenerator): R = {
    val cfg = InterpreterCfg(print)
    var time = 0
    var ec = EC(clock, Seq(ThreadData(cmd, "MAIN", 0)))
    val retVals = mutable.Map.empty[Int, Any] // TODO: seems like a hack but I can't carry type information of inner Commands into this function
    while (true) { // Until the main thread returns
      // Go through all threads and run them until they hit a sync state
      // Do this recursively to handle new thread spawning on this timestep
      val newThreadHandles = runThreadsUntilSync(ec.threads, time, cfg, threadIdGen)

      // Remove all completed threads from the thread list
      val completedThreads = newThreadHandles.filter(completedThread)
      completedThreads.foreach {
        case ThreadData(Return(retval), name, id) =>
          if (cfg.print) println(s"[runInner] Return to top-level from thread $name with value $retval")
          retVals(id) = retval
        case _ => Predef.assert(false, "Interpreter error")
      }
      val nextThreadHandles = newThreadHandles.filter{t => !completedThread(t)}

      // See if the main thread has finished
      assert(newThreadHandles.head.name == "MAIN")
      val done = newThreadHandles.head match {
        case ThreadData(Return(retval), _, _) => Some(retval)
        case _ => None
      }

      // If the main thread returns, we are done
      if (done.isDefined) {
        if (cfg.print) println(s"[runInner] Main thread returned at time $time with value ${done.get}")
        if (ec.threads.length > 1 && cfg.print) println(s"[runInner] Main thread returning while child threads ${ec.threads.tail} aren't yet done")
        // println(retVals)
        return done.get.asInstanceOf[R]
      }

      // Are there any threads waiting on a join and have
      val nextThreadHandlesAfterJoin: Seq[ThreadData] = nextThreadHandles.map {
        case t @ ThreadData(Join(threadHandle, next), name, id) =>
          if (cfg.print) println(s"[runInner] Thread $name ($id) waiting on join from thread ${threadHandle.id}")
          if (retVals.contains(threadHandle.id)) { // the thread that's being waited on has returned
            val (newHandle, cycles, newThreads) = runUntilSync(t.copy(cmd = next(retVals(threadHandle.id))), time, cfg, Seq.empty, threadIdGen)
            assert(newThreads.isEmpty) // I'll support spawning from join return later
            newHandle
          } else { // the thread that's being waited on hasn't returned yet
            t
          }
        case t @ ThreadData(_, _, _) => t
      }

      // Advance time by 1 cycle (TODO: do we need to know the cycle advancement for each thread?)
      ec.clock.step(1)
      if (cfg.print) println(s"[runInner] Stepping 1 cycle at time $time")
      time = time + 1

      ec = ec.copy(threads=nextThreadHandlesAfterJoin)
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

  def runThreadsUntilSync(threads: Seq[ThreadData], time: Int, cfg: InterpreterCfg, threadIdGen: ThreadIdGenerator): Seq[ThreadData] = {
    val iteration = threads.map { t =>
      val (newThreadHandle, cycles, newThreads) = runUntilSync(t, time, cfg, Seq.empty, threadIdGen)
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
      val newThreadsRun = runThreadsUntilSync(newThreads, time, cfg, threadIdGen)
      existingThreads ++ newThreadsRun
    }
  }

  // @tailrec
  // NO LONGER tail recursive due to Concat
  private def runUntilSync(thread: ThreadData, time: Int, cfg: InterpreterCfg, newThreads: Seq[ThreadData], threadIdGen: ThreadIdGenerator): (ThreadData, Int, Seq[ThreadData]) = {
    thread.cmd match {
      case f @ Fork(c, name, next) =>
        if (cfg.print) println(s"[runUntilSync] [Fork] Forking off thread $name from ${thread.name} at time $time")
        val forkedThreadId = threadIdGen.getNewThreadId
        val forkedThreadHandle = f.makeThreadHandle(forkedThreadId)
        runUntilSync(thread.copy(cmd=next(forkedThreadHandle)), time, cfg, newThreads :+ ThreadData(c, name, forkedThreadId), threadIdGen)
      case Step(cycles, next) =>
        if (cycles == 0) { // this Step is a nop
          if (cfg.print) println(s"[runUntilSync] [Step] Stepping 0 cycles (NOP) from ${thread.name} at time $time")
          runUntilSync(thread.copy(cmd=next()), time, cfg, newThreads, threadIdGen)
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
        runUntilSync(thread.copy(cmd=next()), time, cfg, newThreads, threadIdGen)
      case Peek(signal, next) =>
        val value = signal.peek()
        if (cfg.print) println(s"[runUntilSync] [Peek] Peeking $signal -> $value from ${thread.name} at time $time")
        runUntilSync(thread.copy(cmd=next(value)), time, cfg, newThreads, threadIdGen)
      case Concat(a, next) =>
        val retval = runUntilSync(thread.copy(cmd=a), time, cfg, newThreads, threadIdGen)
        // if (cfg.print) println(s"[runUntilSync] [Concat] Got retval $retval from ${thread.name} at time $time")
        // retval will contain a Return() or a Command[_] from a pending step which means 'a' is not yet complete
        retval match {
          case (ThreadData(Return(retval), _, _), 0, newTs) => // a is 'complete' so continue executing next
            runUntilSync(thread.copy(cmd=next(retval)), time, cfg, newThreads ++ newTs, threadIdGen)
          case (ThreadData(c: Command[_], _, _), cycles, newTs) => // a has hit a step so we should save next in a new Concat
            (thread.copy(cmd=Concat(c, next)), cycles, newTs)
        }
      case Return(retval) =>
        if (cfg.print) println(s"[runUntilSync] [Return] Returning with value $retval from ${thread.name} at time $time")
        (thread.copy(cmd=Return(retval)), 0, newThreads)
      case Join(threadHandle, next) =>
        if (cfg.print) println(s"[runUntilSync] [Join] Thread ${thread.name} requests join on thread ${threadHandle.id} at time $time")
        (thread, 1, newThreads) // TODO: this isn't right - you don't necessarily need to step a cycle before a join can take place (it can happen on this same timestep)
    }
  }
}
