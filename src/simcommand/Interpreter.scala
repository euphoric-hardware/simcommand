package simcommand

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer

case class Config(
  print: Boolean = false, // Controls debug printing for the interpreter
  recordActions: Boolean = false, // Controls whether the interpreter should record the actions the program takes
  timeout: Int = 0,
)

sealed trait Action
case class StepAct(cycles: Int) extends Action
case class PokeAct[I](signal: Interactable[I], value: I) extends Action
case class PeekAct[I](signal: Interactable[I], value: I) extends Action

case class Result[R](retval: R, cycles: Int, threadsSpawned: Int, actions: Option[Seq[Action]])

trait Interpreter {
  def unsafeRun[R](cmd: Command[R], clock: Steppable, cfg: Config): Result[R]
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
  private case class EC(clock: Steppable, threads: Seq[ThreadData])

  override def unsafeRun[R](cmd: Command[R], clock: Steppable, cfg: Config): Result[R] = {
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

  private def runInner[R](cmd: Command[R], clock: Steppable, print: Boolean, threadIdGen: ThreadIdGenerator): Result[R] = {
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
        case _ => Predef.assert(assertion=false, "Interpreter error")
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
      case f @ Fork(c, name, order) =>
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
        signal.set(value)
        runUntilSync(thread.copy(cmd=noop()), time, cfg, newThreads, threadIdGen, retvals)
      case Peek(signal) =>
        val value = signal.get()
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
  override def unsafeRun[R](cmd: Command[R], clock: Steppable, cfg: Config): Result[R] = {
    val vm = new Imperative[R](clock, cfg)
    vm.unsafeRun(cmd)
  }
}

class Imperative[R](clock: Steppable, cfg: Config) {
  // Thread management
  private var time = 0
  private val alive = new mutable.TreeSet[Thread[_]]()
  private val queue = new mutable.Queue[Thread[_]]()
  private val waiting = new mutable.TreeSet[Thread[_]]()

  // Channels
  private val channelMap = new mutable.WeakHashMap[ChannelHandle[_], Channel[_]]()
  private var channelCounter = 0
  private val threadMap = new mutable.WeakHashMap[ThreadHandle[_], Thread[_]]()
  private var threadCounter = 0

  // Debugging
  private var actions = new mutable.ArrayBuffer[Action]()
  private var touched = new mutable.HashMap[Interactable[_], Int]()

  def lookupThread[R1](handle: ThreadHandle[R1]): Thread[R1] = {
    threadMap.apply(handle).asInstanceOf[Thread[R1]]
  }

  def lookupChannel[R1](handle: ChannelHandle[R1]): Channel[R1] = {
    channelMap.apply(handle).asInstanceOf[Channel[R1]]
  }

  def unsafeRun(cmd: Command[R]): Result[R] = {
    val main = new Thread(cmd, "main", 0)
    while (alive.nonEmpty) {
      stepClock()
      if (cfg.timeout != 0 && cfg.timeout < time) {
        throw new Error("simcommand timed out")
      }
    }
    Result(main.status.get.asInstanceOf[R], time, threadCounter, None)
  }

  def stepClock(): Unit = {
    queue.clear()
    waiting.clear()
    touched.clear()

    queue ++= alive
    var nextTime = time + 128

    while (queue.nonEmpty) {
      while (queue.nonEmpty) {
        val thread = queue.dequeue()
        thread.status = thread.continue()
        if (!thread.status.isDone) {
          thread.monitor match {
            case Some(monitor) => monitor match {
              case TimeMonitor(t) => if (t < nextTime) nextTime = t
              case _ => ()
            }
          }
        }
        if      (thread.status.isDone) alive -= thread
        else if (thread.monitor.forall(_.canRunThisCycle)) waiting += thread
      }

      waiting.foreach {thread => if (thread.monitor.forall(_.isResolved)) {
        queue += thread
        waiting -= thread
      }}
    }
    if (alive.nonEmpty) {
      clock.step(nextTime - time)
      time = nextTime
    }
  }

  sealed trait Monitor[M]{
    def isResolved: Boolean
    def canRunThisCycle: Boolean
    def resolve(): M
  }
  case class ThreadMonitor[M](thread: Thread[M]) extends Monitor[M] {
    def isResolved: Boolean = thread.status.isDone
    def canRunThisCycle: Boolean = !isResolved
    def resolve(): M = thread.status.get.asInstanceOf[M]
  }
  case class TimeMonitor(time: Int) extends Monitor[Unit] {
    def isResolved: Boolean = time <= Imperative.this.time
    def canRunThisCycle: Boolean = false
    def resolve(): Unit = ()
  }
  case class SendMonitor[M](channel: Channel[M], data: M) extends Monitor[Unit] {
    var sent = false
    def isResolved: Boolean = {
      if (!sent && channel.hasSpace) {
        channel.push(data)
        sent = true
      }
      sent
    }
    def canRunThisCycle = true
    def resolve(): Unit = ()
  }
  case class RecvMonitor[M](channel: Channel[M]) extends Monitor[M] {
    var item: Option[M] = None
    def isResolved: Boolean = {
      if (item.isEmpty && !channel.isEmpty) {
        item = Some(channel.pop())
      }
      item.isDefined
    }
    def canRunThisCycle = true
    def resolve(): M = item.get
  }

  class Frame(var parent: Option[Frame], var cmd: Command[_])

  sealed trait ThreadStatus[+N] {
    val isDone: Boolean
    def get: N
  }
  case class Done[N](v: N) extends ThreadStatus[N] {
    val isDone = true
    def get: N = v
  }
  case object Running extends ThreadStatus[Nothing] {
    val isDone = false
    def get: Nothing = throw new Error("Cannot call get on a Running thread's ThreadStatus")
  }
  case object Killed extends ThreadStatus[Nothing] {
    val isDone = true
    def get: Nothing = throw new Error("Cannot call get on a Killed thread's ThreadStatus")
  }

  class Channel[M](size: Int) {
    val buffer: mutable.Queue[M] = new mutable.Queue[M]()
    val handle: ChannelHandle[M] = ChannelHandle(threadCounter)

    channelMap += (handle -> this)
    channelCounter += 1

    def push(v: M): Unit = buffer += v
    def pop(): M = buffer.dequeue()
    def hasSpace: Boolean = buffer.size < size
    def isEmpty: Boolean = buffer.isEmpty
  }

  class Thread[R1](start: Command[R1], name: String, val order: Int) extends Ordered[Thread[_]] {
    var frame = new Frame(None, start)
    var monitor: Option[Monitor[_]] = None
    var status: ThreadStatus[_] = Running
    val handle: ThreadHandle[_] = ThreadHandle(threadCounter)

    def compare(other: Thread[_]): Int =
      if (order == other.order)
        handle.id - other.handle.id
      else
        order - other.order

    threadMap += (handle -> this)
    threadCounter += 1
    alive += this
    queue += this

    // Continue execution of the thread until it encounters a yield point or
    // completes execution.
    def continue(): ThreadStatus[R1] = {
      if (status.isDone) return status.asInstanceOf[ThreadStatus[R1]]
      if (!monitor.forall(_.isResolved)) return Running.asInstanceOf[ThreadStatus[R1]]

      while (monitor.forall(_.isResolved) && !status.isDone) {
        if (monitor.isDefined && monitor.get.isResolved) {
          ret(monitor.get.resolve())
          monitor = None
        }

        if (status.isDone)
          status.asInstanceOf[ThreadStatus[R1]]

        frame.cmd match {
          case Cont(cmd, _) => frame = new Frame(Some(frame), cmd)
          case Rec(st, fn) => frame = new Frame(Some(frame), fn(st))
          case Step(cycles) => monitor = Some(TimeMonitor(Imperative.this.time + cycles))
          case Fork(cmd, name, order) =>
            val thread = new Thread(cmd, name, order)
            ret(thread.handle)
          case Join(thread) => lookupThread(thread).status match {
            case Done(v) => ret(v)
            case Killed => throw new RuntimeException("Cannot join on a killed thread")
            case Running => monitor = Some(ThreadMonitor(lookupThread(thread)))
          }
          case Poke(signal, value) =>
            if (cfg.recordActions) actions += PokeAct(signal, value)
            touched(signal) =
              if (touched.contains(signal)) -1
              else this.handle.id
            ret(signal.set(value))
          case Peek(signal) =>
            val value = signal.get()
            if (cfg.recordActions) actions += PeekAct(signal, value)
            if (touched.contains(signal) && touched(signal) != this.handle.id) {
              throw new Error("Combinatorial loop")
            }
            ret(value)
          case Return(r) => ret(r)
          case Kill(thread) =>
            lookupThread(thread).status = Killed
            ret(())
          case MakeChannel(size) =>
            val chan = new Channel(size)
            ret(chan.handle)
          case Put(chan, data) => monitor = Some(SendMonitor(lookupChannel(chan), data))
          case GetBlocking(chan) => monitor = Some(RecvMonitor(lookupChannel(chan)))
          case NonEmpty(chan) => ret(!lookupChannel(chan).isEmpty)
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
        //    the next loop will lift in the next iteration
        case Some(parent) => parent.cmd match {
          case Cont(_, cn) =>
            frame.parent = parent.parent
            frame.cmd = cn(value)
          case Rec(_, f) => value match {
            case Left(l) =>
              frame.parent = Some(parent)
              frame.cmd = f(l)
            case Right(r) =>
              frame = parent
              ret(r)
          }
        }
        // If there is no frame parent, then returning from this frame ends
        // the current thread so we should set the thread's status to Done
        case None => status = Done(value.asInstanceOf[R1])
      }
    }
  }
}
