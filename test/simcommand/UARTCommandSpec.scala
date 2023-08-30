package simcommand

import chisel3._
import chiseltest.{VerilatorBackendAnnotation, WriteVcdAnnotation, testableClock}
import chisel3.util.log2Ceil
import chiseltest.internal.NoThreadingAnnotation
import org.scalatest.flatspec.AnyFlatSpec
import simcommand.runtime.{Config, Result}
import simcommand.vips.{UART, UARTChecker}

class UARTCommandSpec extends AnyFlatSpec with SimcommandScalatestTester {
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

  class UARTLoopback() extends Module {
    val rx = IO(Input(Bool()))
    val tx = IO(Output(Bool()))

    tx := RegNext(rx, 1.B)
  }

  "sendByte" should "produce the right sequence" in {
    val testByte = 0x55
    val bitDelay = 4
    testChisel(new UARTMock(Seq.empty, bitDelay)).withAnnotations(Seq(WriteVcdAnnotation)) { c =>
      c.clock.setTimeout(100)
      val cmds = new UART(uartIn=c.rx, uartOut=c.tx, cyclesPerBit = bitDelay)
      val chkr = new UARTChecker(c.rx)
      val program = for {
        _ <- cmds.sendReset()
        checkerHandle <- fork(chkr.checkByte(bitDelay), "checker")
        _ <- cmds.sendByte(testByte)
        _ <- step(bitDelay*5)
        j <- join(checkerHandle)
      } yield j
      val result = unsafeRun(program, c.clock)
      assert(result.retval) // This only checks that the start and stop bits are stable and full
    } // TODO: need a check on the sending itself that doesn't depend on receiveByte
  }

  "receiveByte" should "receive a single byte sent by the UART" in {
    val testByte = Seq(0x55)
    val bitDelay = 4
    testChisel(new UARTMock(testByte, bitDelay)).withAnnotations(Seq(VerilatorBackendAnnotation, NoThreadingAnnotation)) { c =>
      val uart = new UART(uartIn = c.rx, uartOut = c.tx, cyclesPerBit = bitDelay)
      val result = unsafeRun(uart.receiveByte(), c.clock)
      assert(result.retval == testByte.head)
    }
  }

  "receiveByte" should "receive a single byte sent by the UART (command mock)" in {
    val testByte = 0x55
    val rx = binding(0.B)
    val tx = binding(0.B)
    val bitDelay = 4

    val uart = new UART(uartIn = rx, uartOut = tx, cyclesPerBit = bitDelay)
    val mock = for {
      _ <- poke(tx, 0.B)
      _ <- step(bitDelay)
      _ <- concat((0 until 8).map(i => for {
        _ <- poke(tx, ((testByte >> i) & 0x1).B)
        _ <- step(bitDelay)
      } yield ()))
      _ <- poke(tx, 1.B)
      _ <- step(bitDelay)
    } yield ()

    val program = for {
      mockHandle <- fork(mock, name="mock")
      receiveHandle <- fork(uart.receiveByte(), name="receiveByte", order=1)
      _ <- join(mockHandle)
      recv <- join(receiveHandle)
    } yield recv

    val result = unsafeRun(program, FakeClock(), Config(timeout=bitDelay * 10))
    assert(result.retval == testByte)
  }

  "receiveBytes" should "receive multiple bytes sent by the UART" in {
    val testBytes = Seq(0x55, 0xff, 0x00, 0xaa)
    val bitDelay = 4
    testChisel(new UARTMock(testBytes, bitDelay)).withAnnotations(Seq(WriteVcdAnnotation)) { c =>
      val cmds = new UART(uartIn = c.rx, uartOut = c.tx, cyclesPerBit = bitDelay)
      val result = unsafeRun(cmds.receiveBytes(testBytes.length), c.clock)
      assert(result.retval == testBytes)
    }
  }

  "sendBytes" should "successfully send bytes to a forked receiveBytes through a UART loopback" in {
    val testBytes = Seq(0x00, 0x00, 0x55, 0xff, 0x00, 0xaa)
    val bitDelay = 4
    testChisel(new UARTLoopback()).withAnnotations(Seq(WriteVcdAnnotation)) { c =>
      val cmds = new UART(uartIn = c.rx, uartOut = c.tx, cyclesPerBit = bitDelay)
      val rxChk = new UARTChecker(c.rx)
      val txChk = new UARTChecker(c.tx)

      val sender = for {
        _ <- cmds.sendReset()
        _ <- cmds.sendBytes(testBytes)
      } yield ()
      val receiver = cmds.receiveBytes(testBytes.length)
      val rxChecker = rxChk.checkBytes(testBytes.length, bitDelay)
      val txChecker = txChk.checkBytes(testBytes.length, bitDelay)

      val program = for {
        senderThread <- fork(sender, "sender")
        receiverThread <- fork(receiver, "receiver")
        rxCheckerThread <- fork(rxChecker, "rxChecker")
        txCheckerThread <- fork(txChecker, "txChecker")
        _ <- step(bitDelay * cmds.bitsPerSymbol * (testBytes.length + 1))
        receivedBytes <- join(receiverThread)
        rxCheckStatus <- join(rxCheckerThread)
        txCheckStatus <- join(txCheckerThread)
        _ <- join(senderThread)
      } yield (receivedBytes, rxCheckStatus && txCheckStatus)

      val result: Result[(Seq[Int], Boolean)] = unsafeRun(program, c.clock)
      assert(result.retval._1 == testBytes)
      assert(result.retval._2)
    }
  }
}
