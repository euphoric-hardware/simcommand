package simcommand

import scala.collection.mutable

case class Config(
  // Whether or not to print debug output
  print: Boolean = false,
  // Whether or not to record actions the program takes
  recordActions: Boolean = false,
  // How many idle cycles the interpreter should allow. A timeout of zero implies no timeout
  timeout: Int = 0,
  // Fixed point iteration resolves combinatorial dependencies, but is very computationally intensive. (EXPERIMENTAL)
  fixedPointIteration: Boolean = false
)

sealed trait Action
case class StepAct(time: Int, cycles: Int) extends Action
case class PokeAct[I](time: Int, signal: Interactable[I], value: I) extends Action
case class PeekAct[I](time: Int, signal: Interactable[I], value: I) extends Action

case class Result[R](retval: R, cycles: Int, threadsSpawned: Int, actions: Option[Seq[Action]])

trait Interpreter {
  def unsafeRun[R](cmd: Command[R], clock: Steppable, cfg: Config): Result[R]
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
  private val actions = new mutable.ArrayBuffer[Action]()
  private val touched = new mutable.HashMap[Interactable[_], (Int, Int)]()

  private def lookupThread[R1](handle: ThreadHandle[R1]): Thread[R1] = {
    threadMap(handle).asInstanceOf[Thread[R1]]
  }

  private def lookupChannel[R1](handle: ChannelHandle[R1]): Channel[R1] = {
    channelMap(handle).asInstanceOf[Channel[R1]]
  }

  def unsafeRun(cmd: Command[R]): Result[R] = {
    val main = new Thread(cmd, "main", 0)
    while (alive.nonEmpty) {
      stepClock()
      if (cfg.timeout != 0 && cfg.timeout < time) {
        throw new Error("simcommand timed out")
      }
    }
    Result(main.status.get.asInstanceOf[R], time, threadCounter, if (cfg.recordActions) Some(actions.toSeq) else None)
  }

  private def stepClock(): Unit = {
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
          case Rec(st, fn) => frame = new Frame(Some(frame), fn.asInstanceOf[Any => Command[Either[Any,Any]]](st))
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
            if (cfg.recordActions) actions += PokeAct(time, signal, value)
            // 1. If this port has not previously been touched, then we mark it as having changed with the current
            //    thread order.
            // 2. If the mark happened in a lower order, this is still a valid and defined poke ordering,
            //    so we update it with the current thread's order.
            // 3. If the order of the previous poker is the same as the current thread or higher, then this is an
            //    inversion of poke order and is undefined behavior
            touched(signal) =
              if (!touched.contains(signal) || touched(signal)._1 < this.order) (this.order, this.handle.id)
              else throw new CombinatorialDependencyException(this.name, this.order, frame.cmd)
            ret(signal.set(value))
          case Peek(signal) =>
            val value = signal.get()
            if (cfg.recordActions) actions += PeekAct(time, signal, value)
            if (
              touched.contains(signal) &&
              (touched(signal)._1 > this.order || (touched(signal)._1 == this.order && touched(signal)._2 != this.handle.id))
            ) {
              throw new CombinatorialDependencyException(this.name, this.order, frame.cmd)
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
            frame.cmd = cn.asInstanceOf[Any => Command[Any]](value)
          case Rec(_, f) => value match {
            case Left(l) =>
              frame.parent = Some(parent)
              frame.cmd = f.asInstanceOf[Any => Command[Any]](l)
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
