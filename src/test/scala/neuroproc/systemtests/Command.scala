package neuroproc.systemtests

import neuroproc.systemtests.Model.{DummyImpl, SignalListImpl}
import org.scalatest.flatspec.AnyFlatSpec

import scala.annotation.tailrec

sealed trait Command[R] {
  //def andThen[R2](next: => Command[R2]) = {}
}
case class Step[R](cycles: Int, next: () => Command[R]) extends Command[R]
case class Poke[R](signal: String, value: BigInt, next: () => Command[R]) extends Command[R]
case class Peek[R](signal: String, next: BigInt => Command[R]) extends Command[R]
case class Concat[R](a: Command[R], next: R => Command[R]) extends Command[R]
case class Return[R](retval: R) extends Command[R]


object Model {
  trait Implementation {
    def getSignal(signal: String): BigInt
    def setSignal(signal: String, value: BigInt): Unit
    def step(cycles: Int): Unit
  }

  class DummyImpl extends Implementation {
    override def getSignal(signal: String): BigInt = 0
    override def setSignal(signal: String, value: BigInt): Unit = {}
    override def step(cycles: Int): Unit = {}
  }

  class SignalListImpl(sigMap: Map[String, Seq[Int]]) extends Implementation {
    var cycle = 0

    override def getSignal(signal: String): BigInt = sigMap(signal)(cycle)
    override def setSignal(signal: String, value: BigInt): Unit = {}
    override def step(cycles: Int): Unit = cycle = cycle + cycles
  }
}


//sealed trait Action
//case class StepAction(cycles: Int) extends Action
//case class PokeAction(signal: String, value: BigInt) extends Action
object Command {
  /*
    val x: BigInt = for {
      _ <- Poke()
      _ <- Step()
      a <- Peek()
      _ <- Poke(a)
    } yield a

    Poke().flatMap { =>
      Step().flatMap { =>
        Peek().flatMap { a =>
          Poke(a).map { => a}
        }
      }
    }
   */

  def run[R](cmd: Command[R], impl: Model.Implementation, print: Boolean): R = {
    cmd match {
      case Step(cycles, next) =>
        if (print) println(s"[Step] Stepping $cycles cycles")
        impl.step(cycles)
        run(next(), impl, print)
      case Poke(signal, value, next) =>
        if (print) println(s"[Poke] Poking $signal = $value")
        impl.setSignal(signal, value)
        run(next(), impl, print)
      case Peek(signal, next) =>
        val value = impl.getSignal(signal)
        if (print) println(s"[Peek] Peeking $signal -> $value")
        run(next(value), impl, print)
      case Concat(a, next) =>
        val retval = run(a, impl, print)
        println(s"[Concat] Running first command and got $retval")
        run(next(retval), impl, print)
      case Return(retval) =>
        if (print) println(s"[Return] Returning with value $retval")
        retval
    }
  }
  /*
    def actionInterpreter(cmd: Command): Seq[Action] = {
      cmd match {
        case Step(cycles, next) => ???
        case Poke(signal, value, next) => ???
        case Nop() => ???
        case Concat(a, next) => ???
      }
    }
   */
}

object UARTCommands {
  /*
  async def receiveByte(dut, bitDelay: int, byte: int):
    print("Sending byte {byte}")
    # Start bit
    dut.io_uartRx.value = 0
    await ClockCycles(dut.clock, bitDelay)
    # Byte
    for i in range(8):
      dut.io_uartRx.value = (byte >> i) & 0x1
      await ClockCycles(dut.clock, bitDelay)
    # Stop bit
    dut.io_uartRx.value = 1
    await ClockCycles(dut.clock, bitDelay)
    print("Sent byte {byte}")
  Below is the translation of this function
  */
  def sendBit(bit: Int, bitDelay: Int): Command[Unit] = {
    Poke("io_uartRx", bit, () =>
      Step(bitDelay, () => Return(Unit))
    )
  }

  def sendByte(bitDelay: Int, byte: Int): Command[Unit] = {
    sendByteInner(bitDelay, ((byte & 0xff) << 1) | (1 << 10), 10)
    /* Concat(sendBit(false, bitDelay), () =>
      Concat(sendBit((byte >> 0) & 0x1, bitDelay), () =>
        Concat(sendBit((byte >> 1) & 0x1, bitDelay), () =>
          sendBit((byte >> 2) & 0x1, bitDelay)
        )
      )
    ) */
  }

  // @tailrec - NOT tail recursive - will blow up eventually, what is trampolining?
  def sendByteInner(bitDelay: Int, byte: Int, bitsToGo: Int): Command[Unit] = {
    if (bitsToGo == 0) Return(Unit) else Concat(sendBit(byte & 0x1, bitDelay), _ => sendByteInner(bitDelay, byte >> 1, bitsToGo - 1))
  }

  /*
  async def transferByte(dut, bitDelay: int) -> int:
    print("Receiving a byte")
    byte = 0
    # Assumes start bit has already been seen
    await ClockCycles(dut.clock, bitDelay)
    # Byte
    for i in range(8):
      byte = dut.io_uartTx.value << i | byte
    await ClockCycles(dut.clock, bitDelay)
    # Stop bit
      assert dut.io_uartTx.value == 1
    await ClockCycles(dut.clock, bitDelay)
    print("Received {byte}")
    return byte
   */

  // @tailrec - also not tail recursive
  def receiveByte(bitDelay: Int): Command[Int] = {
    Peek("io_uartTx", txBit =>
      if (txBit == 0) Step(bitDelay / 2, () => // start bit is seen, shift time to center-of-symbol
        Concat(receiveByteInner(bitDelay), byte => Return(byte))
      ) else Step(1, () => receiveByte(bitDelay)) // UART line is still high, check on next cycle
    )
  }

  def receiveByteInner(bitDelay: Int, byte: Int = 0, nBits: Int = 8): Command[Int] = {
    if (nBits == 0) Return(byte)
    else {
      Concat(receiveBit(bitDelay), bit =>
        receiveByteInner(bitDelay, byte | (bit << (8 - nBits)), nBits - 1))
    }
  }

  def receiveBit(bitDelay: Int): Command[Int] = {
    // Assuming that a start bit has already been seen and current time is at the midpoint of the start bit
    Step(bitDelay, () =>
      Peek("io_uartTx", b => Return(b.toInt))
    )
  }
}


class ActionSpec extends AnyFlatSpec {
  it should "work" in {
    Command.run(UARTCommands.sendByte(10, 0x55), new DummyImpl(), print=true)

    def byteToPerCycleBits(bitDelay: Int, byte: Int): Seq[Int] = {
      Seq.fill(bitDelay)(1) ++ // Idle
        Seq.fill(bitDelay)(0) ++ // start bit
        (0 until 8).flatMap { i => Seq.fill(bitDelay)((byte >> i) & 0x1) } ++
        Seq.fill(bitDelay)(1) // stop bit
    }
    val mockUartTx = new SignalListImpl(Map("io_uartTx" -> byteToPerCycleBits(4, 0x55)))
    val uartRetVal = Command.run(UARTCommands.receiveByte(4), mockUartTx, print=true)
    assert(uartRetVal == 0x55)
  }
}
