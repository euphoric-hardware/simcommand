import neuroproc._

import org.scalatest._
import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.{WriteVcdAnnotation, VerilatorBackendAnnotation}

class NeuromorphicProcessorTester extends FlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Neuromorphic Processor"

  val bitDelay = FREQ / BAUDRATE + 1

  it should "process an image" in {
    test(new NeuromorphicProcessor()).withAnnotations(Seq(WriteVcdAnnotation, VerilatorBackendAnnotation)) {
      dut =>
        dut.clock.setTimeout(FREQ)

        def receiveByte(byte: UInt) = {
          // Start bit
          dut.io.uartRx.poke(false.B)
          dut.clock.step(bitDelay)
          // Byte
          for (i <- 0 until 8) {
            dut.io.uartRx.poke(byte(i))
            dut.clock.step(bitDelay)
          }
          // Stop bit
          dut.io.uartRx.poke(true.B)
          dut.clock.step(bitDelay)
        }

        implicit def boolean2int(bool: Boolean) = if (bool) 1 else 0
        def transferByte() = {
          var byte = 0
          // Assumes start bit has already been seen
          dut.clock.step(bitDelay)
          // Byte
          for (i <- 0 until 8) {
            byte = (dut.io.uartTx.peek.litToBoolean << i) | byte
            dut.clock.step(bitDelay)
          }
          // Stop bit
          dut.io.uartTx.expect(true.B)
          dut.clock.step(bitDelay)
          byte
        }

        // Reset inputs
        dut.io.uartRx.poke(true.B)
        dut.io.uartTx.expect(true.B)

        // Load an image into the accelerator ...
        val rng = new scala.util.Random(42)
        val image = Array.fill(INPUTSIZE) { BigInt(RATEWIDTH, rng) }
        var inject = true
        val inj = fork {
          for (i <- 0 until image.length) {
            // Write top byte of index, bottom byte of index, top byte of rate,
            // and bottom byte of rate
            receiveByte((i >> 8).U(8.W))
            receiveByte((i & 0xff).U(8.W))
            receiveByte((image(i) >> 8).U(8.W))
            receiveByte((image(i) & 0xff).U(8.W))
          }
          while (inject)
            dut.clock.step()
        }
        dut.clock.step(FREQ/2)
        inject = false
        inj.join()

        // ... get its response
        var spikes = Array[Int]()
        var receive = true
        val rec = fork {
          while (receive) {
            if (!dut.io.uartTx.peek.litToBoolean)
              spikes = spikes :+ transferByte()
            dut.clock.step()
          }
        }
        dut.clock.step(FREQ/2)
        receive = false
        rec.join()
        println(spikes.deep.mkString(", "))
    }
  }
}
