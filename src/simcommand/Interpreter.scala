package simcommand

import chisel3.{Clock, Data, assert}
import chiseltest._

import scala.collection.mutable

case class Config(
  print: Boolean = false, // Controls debug printing for the interpreter
  recordActions: Boolean = false // Controls whether the interpreter should record the actions the program takes
)

sealed trait Action
case class StepAct(cycles: Int) extends Action
case class PokeAct(signal: Data, value: Data) extends Action
case class PeekAct(signal: Data, value: Data) extends Action

case class Result[R](retval: R, cycles: Int, threadsSpawned: Int, actions: Option[Seq[Action]])

trait Interpreter {
  def unsafeRun[R](cmd: Command[R], clock: Clock, cfg: Config): Result[R]
}

object Recursive extends Interpreter {
  private class ThreadIdGenerator {
    var count = 0
    def getNewThreadId: Int = {
      count = count + 1
      count
    }
  }
  private case class ThreadData(cmd: Command[_], name: String, id: Int)
  private case class InterpreterCfg(print: Boolean)
  private case class EC(clock: Clock, threads: Seq[ThreadData])

  override def unsafeRun[R](cmd: Command[R], clock: Clock, cfg: Config): Result[R] = {
    runInner(cmd, clock, cfg.print, new ThreadIdGenerator())
  }

  private def completedThread(t: ThreadData): Boolean = {
    t match {
      case ThreadData(Return(_), _, _) => true
      case _ => false
    }
  }

  private def debug(cfg: InterpreterCfg, thread: ThreadData, time: Int, message: String): Unit = {
    if (cfg.print) println(s"[$time] [${thread.name} (${thread.id})]: $message")
  }

  private def runInner[R](cmd: Command[R], clock: Clock, print: Boolean, threadIdGen: ThreadIdGenerator): Result[R] = {
    val cfg = InterpreterCfg(print)
    var time = 0
    var ec = EC(clock, Seq(ThreadData(cmd, "MAIN", 0)))
    val retVals = mutable.Map.empty[Int, Any] // TODO: seems like a hack but I can't carry type information of inner Commands into this function
    while (true) { // Until the main thread returns
      // Go through all threads and run them until they hit a sync state
      // Do this recursively to handle new thread spawning on this timestep
      val newThreadHandles = runThreadsUntilSync(ec.threads, time, cfg, threadIdGen, retVals)

      // Remove all completed threads from the thread list
      val completedThreads = newThreadHandles.filter(completedThread)
      completedThreads.foreach {
        case t @ ThreadData(Return(retval), name, id) =>
          debug(cfg, t, time, s"Return to top-level with value $retval")
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
        debug(cfg, ec.threads.head, time, s"Main thread returned at time $time with value ${done.get}")
        if (ec.threads.length > 1) debug(cfg, ec.threads.head, time, s"[FISHY] Main thread returning while child threads ${ec.threads.tail} aren't finished!")
        return Result(done.get.asInstanceOf[R], time, retVals.keys.size, None)
      }

      // Are there any threads waiting on a join and we have data ready for it
      /*
      val nextThreadHandlesAfterJoin: Seq[ThreadData] = nextThreadHandles.map {
        case t @ ThreadData(Join(threadHandle), name, id) =>
          debug(cfg, t, time, s"Waiting on join from ${threadHandle.id}")
          if (retVals.contains(threadHandle.id)) { // the thread that's being waited on has returned
            val (newHandle, cycles, newThreads) = runUntilSync(t.copy(cmd = next(retVals(threadHandle.id))), time, cfg, Seq.empty, threadIdGen)
            assert(newThreads.isEmpty) // I'll support spawning from join return later
            newHandle
          } else { // the thread that's being waited on hasn't returned yet
            t
          }
        case t @ ThreadData(_, _, _) => t
      }
       */

      // Advance time by 1 cycle (TODO: do we need to know the cycle advancement for each thread?)
      ec.clock.step(1)
      debug(cfg, ec.threads.head, time, "Stepping 1 cycle")
      time = time + 1

      //ec = ec.copy(threads=nextThreadHandlesAfterJoin)
      ec = ec.copy(threads=nextThreadHandles)
    }
    ??? // should never get here
  }

  private def runThreadsUntilSync(threads: Seq[ThreadData], time: Int, cfg: InterpreterCfg, threadIdGen: ThreadIdGenerator, retvals: mutable.Map[Int, Any]): Seq[ThreadData] = {
    val iteration = threads.map { t =>
      val (newThreadHandle, cycles, newThreads) = runUntilSync(t, time, cfg, Seq.empty, threadIdGen, retvals)
      Predef.assert(cycles == 1 || cycles == 0)
      (newThreadHandle, cycles, newThreads)
    }
    if (iteration.map(_._3.length).sum == 0) { // no new threads spawned, we're done
      iteration.map(_._1)
    } else { // all the current threads are done, but they have spawned new threads which need to be run until a syncpoint is hit
      val existingThreads = iteration.map(_._1)
      val newThreads = iteration.flatMap(_._3)
      val newThreadsRun = runThreadsUntilSync(newThreads, time, cfg, threadIdGen, retvals)
      existingThreads ++ newThreadsRun
    }
  }

  private def runUntilSync(thread: ThreadData, time: Int, cfg: InterpreterCfg, newThreads: Seq[ThreadData], threadIdGen: ThreadIdGenerator, retvals: mutable.Map[Int, Any]): (ThreadData, Int, Seq[ThreadData]) = {
    thread.cmd match {
      case Cont(a, next) =>
        val retval = runUntilSync(thread.copy(cmd=a), time, cfg, newThreads, threadIdGen, retvals)
        // retval will contain a Return() or a Command[_] from a pending step which means 'a' is not yet complete
        //debug(cfg, thread, time, s"[Cont] Got retval $retval")
        retval match {
          case (ThreadData(Return(retval), _, _), 0, newTs) => // a is 'complete' so continue executing next
            //debug(cfg, thread, time, s"[Cont] a is complete, executing next")
            runUntilSync(thread.copy(cmd=next(retval)), time, cfg, newTs, threadIdGen, retvals) // TODO: recursive thread spawning won't work without appending newThreads to newTs
          case (ThreadData(c: Command[_], _, _), cycles, newTs) => // a has hit a step so we should save next in a new Concat
            //debug(cfg, thread, time, s"[Cont] a is not complete, saving pointer at $c")
            (thread.copy(cmd=Cont(c, next)), cycles, newTs)
        }
      case f @ Fork(c, name) =>
        val forkedThreadId = threadIdGen.getNewThreadId
        val forkedThreadHandle = f.makeThreadHandle(forkedThreadId)
        debug(cfg, thread, time, s"[Fork] Forking thread $name ($forkedThreadId)")
        runUntilSync(thread.copy(cmd=Return(forkedThreadHandle)), time, cfg, newThreads :+ ThreadData(c, name, forkedThreadId), threadIdGen, retvals)
      // runUntilSync(thread.copy(cmd=next(forkedThreadHandle)), time, cfg, newThreads :+ ThreadData(c, name, forkedThreadId), threadIdGen)
      case Step(cycles) =>
        if (cycles == 0) { // this Step is a nop
          debug(cfg, thread, time, "[Step] 0 cycles (NOP)")
          //runUntilSync(thread.copy(cmd=noop()), time, cfg, newThreads, threadIdGen, retvals)
          ???
        } else if (cycles == 1) { // this Step will complete in 1 more cycle
          debug(cfg, thread, time, "[Step] 1 cycle")
          (thread.copy(cmd=noop()), 1, newThreads)
        } else { // this Step requires 2 or more cycles to complete
          debug(cfg, thread, time, "[Step] 1 cycle")
          (thread.copy(cmd=Step(cycles - 1)), 1, newThreads)
        }
      case Poke(signal, value) =>
        debug(cfg, thread, time, s"[Poke] $signal <- $value")
        signal.poke(value)
        runUntilSync(thread.copy(cmd=noop()), time, cfg, newThreads, threadIdGen, retvals)
      case Peek(signal) =>
        val value = signal.peek()
        debug(cfg, thread, time, s"[Peek] $signal -> $value")
        runUntilSync(thread.copy(cmd=Return(value)), time, cfg, newThreads, threadIdGen, retvals)
      case Return(retval) =>
        debug(cfg, thread, time, s"[Return] $retval")
        (thread.copy(cmd=Return(retval)), 0, newThreads)
      case Join(threadHandle) =>
        debug(cfg, thread, time, s"[Join] Requesting join on thread ${threadHandle.id}")
        if (retvals.contains(threadHandle.id)) {
          // TODO: this isn't right - you don't necessarily need to step a cycle before a join can take place (it can happen on this same timestep)
          (thread.copy(cmd=Return(retvals(threadHandle.id))), 1, newThreads)
        } else { // We're still waiting on the join
          (thread, 1, newThreads)
        }
    }
  }
}

object Imperative extends Interpreter {
  override def unsafeRun[R](cmd: Command[R], clock: Clock, cfg: Config): Result[R] = {
    val vm = new Imperative[R](clock)
    vm.unsafeRun(cmd)
  }
}

class Imperative[R](clock: Clock) {
  private var time = 0
  private val alive = new mutable.TreeSet[Thread[_]]()
  private val queue = new mutable.Queue[Thread[_]]()
  private val waiting = new mutable.TreeSet[Thread[_]]()

  private val channelMap = new mutable.WeakHashMap[ChannelHandle[_], Channel[_]]()
  private var channelCounter = 0
  private val threadMap = new mutable.WeakHashMap[ThreadHandle[_], Thread[_]]()
  private var threadCounter = 0

  def lookupThread[R1](handle: ThreadHandle[R1]): Thread[R1] = {
    threadMap.apply(handle).asInstanceOf[Thread[R1]]
  }

  def lookupChannel[R1](handle: ChannelHandle[R1]): Channel[R1] = {
    channelMap.apply(handle).asInstanceOf[Channel[R1]]
  }

  def unsafeRun(cmd: Command[R]): Result[R] = {
    val main = new Thread(cmd, "main")
    while (alive.nonEmpty) {
      stepClock()
    }
    Result(main.status.get.asInstanceOf[R], time, threadCounter, None)
  }

  def stepClock() = {
    queue.clear()
    waiting.clear()
    queue ++= alive

    while (queue.nonEmpty) {
      while (queue.nonEmpty) {
        val thread = queue.dequeue()
        thread.status = thread.continue()
        if      (thread.status.isDone) alive -= thread
        else if (thread.monitor.forall(_.canRunThisCycle)) waiting += thread
      }

      waiting.foreach {thread => if (thread.monitor.forall(_.isResolved)) {
        queue += thread
        waiting -= thread
      }}
    }

    clock.step(1)
    time += 1
  }

  sealed trait Monitor[M]{
    def isResolved: Boolean
    def canRunThisCycle: Boolean
    def resolve(): M
  }
  case class ThreadMonitor[M](thread: Thread[M]) extends Monitor[M] {
    def isResolved = thread.status.isDone
    def canRunThisCycle = !isResolved
    def resolve() = thread.status.get.asInstanceOf[M]
  }
  case class TimeMonitor(time: Int) extends Monitor[Int] {
    def isResolved = time <= Imperative.this.time
    def canRunThisCycle = false
    def resolve() = Imperative.this.time
  }
  case class SendMonitor[M](channel: Channel[M], data: M) extends Monitor[Unit] {
    var sent = false
    def isResolved = {
      if (!sent && channel.hasSpace) {
        channel.push(data)
        sent = true
      }
      sent
    }
    def canRunThisCycle = true
    def resolve() = ()
  }
  case class RecvMonitor[M](channel: Channel[M]) extends Monitor[M] {
    var item: Option[M] = None
    def isResolved = {
      if (item.isEmpty && !channel.isEmpty) {
        item = Some(channel.pop())
      }
      item.isDefined
    }
    def canRunThisCycle = true
    def resolve() = item.get
  }

  class Frame(val parent: Option[Frame], val cmd: Command[_])

  trait ThreadStatus[+R] {
    val isDone: Boolean
    def get: R
  }
  case class Done[R](v: R) extends ThreadStatus[R] {
    val isDone = true
    def get = v
  }
  case object Running extends ThreadStatus[Nothing] {
    val isDone = false
    def get = ???
  }
  case object Killed extends ThreadStatus[Nothing] {
    val isDone = true
    def get = ???
  }

  class Channel[M](size: Int) {
    val buffer = new mutable.Queue[M]()
    val handle  = new ChannelHandle(threadCounter)

    channelMap += (handle -> this)
    channelCounter += 1

    def push(v: M) = {
      buffer += v
    }

    def pop(): M = {
      buffer.dequeue()
    }

    def hasSpace = {
      buffer.size < size
    }

    def isEmpty = {
      buffer.isEmpty
    }
  }

  class Thread[R1](start: Command[R1], name: String) extends Ordered[Thread[_]] {
    var frame = new Frame(None, start)
    var monitor: Option[Monitor[_]] = None
    var status: ThreadStatus[_] = Running
    val handle: ThreadHandle[_] = new ThreadHandle(threadCounter)

    def compare(other: Thread[_]) = handle.id - other.handle.id

    threadMap += (handle -> this)
    threadCounter += 1
    alive += this
    queue += this

    // Continue execution of the thread until it encounters a yield point or
    // completes execution.
    def continue(): ThreadStatus[R1] = {
      if (status.isDone) return status.asInstanceOf[ThreadStatus[R1]]
      if (!monitor.forall(_.isResolved)) return Running

      while (monitor.forall(_.isResolved) && !status.isDone) {
        if (monitor.isDefined && monitor.get.isResolved) {
          ret(monitor.get.resolve())
          monitor = None
        }

        if (status.isDone)
          status.asInstanceOf[ThreadStatus[R1]]

        frame.cmd match {
          case Cont(cmd, cn) => {
            frame = new Frame(Some(frame), cmd)
          }
          case Rec(st, fn) => {
            frame = new Frame(Some(frame), fn(st))
          }

          case Step(cycles) => {
            monitor = Some(new TimeMonitor(Imperative.this.time + cycles))
          }
          case Fork(cmd, name) => {
            val thread = new Thread(cmd, name)
            ret(thread.handle)
          }
          case Join(thread) => lookupThread(thread).status match {
            case Done(v) => ret(v)
            // FIXME: Consider whether or not this should error, or if we
            // should change the API to be safe regardless of killed status
            case Killed => throw new RuntimeException("Cannot join on a killed thread")
            case Running => {
              monitor = Some(new ThreadMonitor(lookupThread(thread)))
            }
          }
          case Poke(signal, value) => ret(signal.poke(value))
          case Peek(signal) => ret(signal.peek())
          case Return(r) => ret(r)
          case Kill(thread) => {
            lookupThread(thread).status = Killed
            ret(())
          }

          case MakeChannel(size) => {
            val chan = new Channel(size)
            ret(chan.handle)
          }

          case Put(chan, data) => {
            monitor = Some(new SendMonitor(lookupChannel(chan), data))
          }

          case GetBlocking(chan) => {
            monitor = Some(new RecvMonitor(lookupChannel(chan)))
          }

          case NonEmpty(chan) => {
            ret(!lookupChannel(chan).isEmpty)
          }

        }
      }

      status.asInstanceOf[ThreadStatus[R1]]
    }

    def ret(value: Any): Unit = {
      frame.parent match {
        // If there is a parent frame, we check whether or not it is a
        // Continuation or a Recursion parent frame.
        //
        // 1. If it is a continuation frame , we replace the continuation
        //    frame with the command resolved by the continuation function.
        // 2. If it is a recursion frame, we check if we have to continue the
        //    recursion or if we are done. If the continuation function
        //    returns a Left, it indicates we have to rerun this current
        //    frame with new parameters.
        // 3. If it is a recursion frame but the continuation function
        //    returns a Right, then we are done with the recursion and we
        //    replace the recursion frame with a frame with a Value(R) which
        //    the next loop will lift in the next interation
        case Some(parent) => parent.cmd match {
          case Cont(_, cn) => frame = new Frame(parent.parent, cn(value))
          case Rec(st, f) => value match {
            case Left(l) => frame = new Frame(Some(parent), f(l))
            case Right(r) => frame = new Frame(parent.parent, lift(r))
          }
        }
        // If there is no frame parent, then returning from this frame ends
        // the current thread so we should set the thread's status to Done
        case None => status = Done(value.asInstanceOf[R1])
      }
    }
  }
}
