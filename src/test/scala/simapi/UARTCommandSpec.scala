package simapi

import chisel3._
import chiseltest.{ChiselScalatestTester, WriteVcdAnnotation}
import chisel3.util.log2Ceil
import org.scalatest.flatspec.AnyFlatSpec

class UARTCommandSpec extends AnyFlatSpec with ChiselScalatestTester {
  class UARTMock(txBytes: Seq[Int], bitDelay: Int) extends Module {
    val rx = IO(Input(Bool()))
    val tx = IO(Output(Bool()))

    def byteToPerCycleBits(bitDelay: Int, byte: Int): Seq[Bool] = {
      Seq.fill(bitDelay)(1.B) ++ // Idle
        Seq.fill(bitDelay)(0.B) ++ // start bit
        (0 until 8).flatMap { i => Seq.fill(bitDelay)(((byte >> i) & 0x1).B) } ++
        Seq.fill(bitDelay)(1.B) // stop bit
    }

    if (txBytes.isEmpty) {
      tx := 1.B
    } else {
      val bitsToSend = VecInit(txBytes.flatMap(byteToPerCycleBits(bitDelay, _)))
      val cycle = RegInit(0.U(log2Ceil(bitsToSend.length).W))
      cycle := cycle + 1.U
      tx := bitsToSend(cycle)
    }
  }

  "sendByte" should "produce the right sequence" in {
    test(new UARTMock(Seq.empty, 10)) { c =>
      val cmds = new UARTCommands(uartIn=c.rx, uartOut=c.tx)
      Command.run(cmds.sendByte(10, 0x55), c.clock, print=true)
    }
  }
  "receiveByte" should "receive a single byte sent by the UART" in {
    test(new UARTMock(Seq(0x55), 4)) { c =>
      val cmds = new UARTCommands(uartIn = c.rx, uartOut = c.tx)
      val byteReceived = Command.run(cmds.receiveByte(4), c.clock, print = true)
      assert(byteReceived == 0x55)
    }
  }

  "receiveBytes" should "receive multiple bytes sent by the UART" in {
    val testBytes = Seq(0x55, 0xff) // 0x00, 0xaa
    test(new UARTMock(testBytes, 4)).withAnnotations(Seq(WriteVcdAnnotation)) { c =>
      val cmds = new UARTCommands(uartIn = c.rx, uartOut = c.tx)
      val bytesReceived = Command.run(cmds.receiveBytes(4, testBytes.length), c.clock, print = true)
      print(bytesReceived)
      assert(bytesReceived == testBytes)
    }
  }
}
