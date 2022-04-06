package simapi

import chisel3._
import chisel3.experimental.{DataMirror, Direction}

class UARTCommands(uartIn: chisel3.Bool, uartOut: chisel3.Bool) {
  assert(DataMirror.directionOf(uartIn) == Direction.Input)
  assert(DataMirror.directionOf(uartOut) == Direction.Output)
  // sending a UART byte using cocotb
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
  */
  def sendBit(bit: Int, bitDelay: Int): Command[Unit] = {
    Poke(uartIn, bit.B, () =>
      Step(bitDelay, () =>
        Return(Unit)
      )
    )
  }

  // @tailrec - NOT tail recursive - will blow up eventually, what is trampolining?
  private def sendByteInner(bitDelay: Int, byte: Int, bitsToGo: Int): Command[Unit] = {
    if (bitsToGo == 0)
      Return(Unit)
    else
      Concat(sendBit(byte & 0x1, bitDelay), (_: Unit) => sendByteInner(bitDelay, byte >> 1, bitsToGo - 1))
  }

  def sendByte(bitDelay: Int, byte: Int): Command[Unit] = {
    sendByteInner(bitDelay, ((byte & 0xff) << 1) | (1 << 10), 10)
  }

  // receiving a UART byte using cocotb
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

  def receiveBytes(bitDelay: Int, nBytes: Int): Command[Seq[Int]] = {
    def receiveBytesInner(bitDelay: Int, nBytes: Int, seenSoFar: Seq[Int]): Command[Seq[Int]] = {
      if (nBytes == 0)
        Return(seenSoFar)
      else {
        Concat(receiveByte(bitDelay), (byte: Int) =>
          receiveBytesInner(bitDelay, nBytes-1, seenSoFar :+  byte)
        )
      }
    }
    receiveBytesInner(bitDelay, nBytes, Seq.empty[Int])
  }

  // @tailrec - also not tail recursive
  def receiveByte(bitDelay: Int): Command[Int] = {
    Peek(uartOut, (txBit: Bool) =>
      if (txBit.litValue == 0) Step(bitDelay / 2, () => // start bit is seen, shift time to center-of-symbol
        Concat(receiveByteInner(bitDelay), (byte: Int) =>
          Step(bitDelay + bitDelay / 2, () => // advance time past 1/2 of last bit and stop bit
            Return(byte)
          )
        )
      ) else Step(1, () => receiveByte(bitDelay)) // UART line is still high, check on next cycle
    )
  }

  def receiveByteInner(bitDelay: Int, byte: Int = 0, nBits: Int = 8): Command[Int] = {
    if (nBits == 0) Return(byte)
    else {
      Concat(receiveBit(bitDelay), (bit: Int) =>
        receiveByteInner(bitDelay, byte | (bit << (8 - nBits)), nBits - 1))
    }
  }

  def receiveBit(bitDelay: Int): Command[Int] = {
    // Assuming that a start bit has already been seen and current time is at the midpoint of the start bit
    Step(bitDelay, () =>
      Peek(uartOut, (b: Bool) => Return(b.litValue.toInt))
    )
  }
}
