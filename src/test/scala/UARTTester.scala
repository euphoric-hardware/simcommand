import neuroproc._

import org.scalatest._
import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.WriteVcdAnnotation

// Inspired by https://github.com/schoeberl/chisel-examples/blob/master/src/test/scala/uart/UartTester.scala

class RxTester extends FlatSpec with ChiselScalatestTester with Matchers {
  behavior of "UART Rx"

  val bitDelay = FREQ / BAUDRATE + 1

  it should "receive a byte" in {
    test(new Rx(FREQ, BAUDRATE)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        val testData = 42.U
        dut.clock.setTimeout(10*bitDelay)

        // Reset the receive line to the default value
        dut.io.ready.poke(false.B)
        dut.io.rx.poke(true.B)
        dut.clock.step()

        // Receive start bit
        dut.io.rx.poke(false.B)
        dut.clock.step(bitDelay)

        // Receive the data
        for (i <- 0 until 8) {
          dut.io.rx.poke(testData(i))
          println(s"Received bit $i")
          dut.clock.step(bitDelay)
        }

        // Receive stop bit
        dut.io.rx.poke(true.B)
        while (!dut.io.valid.peek.litToBoolean)
          dut.clock.step()
        dut.io.data.expect(testData)

        // Read out the data
        dut.io.ready.poke(true.B)
        dut.clock.step()
        dut.io.valid.expect(false.B)
    }
  }
}

class TxTester extends FlatSpec with ChiselScalatestTester with Matchers {
  behavior of "UART Tx"

  val bitDelay = FREQ / BAUDRATE + 1

  it should "send a byte" in {
    test(new Tx(FREQ, BAUDRATE)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        val testData = 42.U
        dut.clock.setTimeout(10*bitDelay)

        // Load a byte of data into the Tx module
        dut.io.valid.poke(true.B)
        dut.io.data.poke(testData)
        // Wait for ready signal to be asserted
        while (!dut.io.ready.peek.litToBoolean)
          dut.clock.step()
        // Perform handshake
        dut.clock.step()
        dut.io.valid.poke(false.B)
        dut.io.data.poke(0.U)
        println("Loaded data")
        
        // Wait for start bit
        while (dut.io.tx.peek.litToBoolean)
          dut.clock.step()
        println("Start bit transmitted")
        
        // Check remaining bits
        dut.clock.step(bitDelay)
        for (i <- 0 until 8) {
          dut.io.tx.expect(testData(i))
          println(s"Found bit $i")
          dut.clock.step(bitDelay)
        }
        dut.io.tx.expect(true.B)
    }
  }
}

class UartEchoTester extends FlatSpec with ChiselScalatestTester with Matchers {
  behavior of "UART Echo"

  val bitDelay = FREQ / BAUDRATE + 1

  it should "echo a byte" in {
    test(new UartEcho(FREQ, BAUDRATE)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        val testData = 42.U
        dut.clock.setTimeout(20*bitDelay)

        // Receive start bit
        dut.io.rxd.poke(false.B)
        dut.clock.step(bitDelay)

        // Receive the data
        for (i <- 0 until 8) {
          dut.io.rxd.poke(testData(i))
          println(s"Received bit $i")
          dut.clock.step(bitDelay)
        }

        // Receive stop bit
        dut.io.rxd.poke(true.B)
        dut.clock.step(bitDelay)

        // Transfer start bit
        dut.clock.step(bitDelay)
        dut.io.txd.expect(false.B)
        dut.clock.step(bitDelay)

        // Transfer the data
        for (i <- 0 until 8) {
          dut.io.txd.expect(testData(i))
          println(s"Found bit $i")
          dut.clock.step(bitDelay)
        }

        // Transfer stop bit
        dut.io.txd.expect(true.B)
    }
  }
}
