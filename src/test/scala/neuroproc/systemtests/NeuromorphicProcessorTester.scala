package neuroproc.systemtests

import neuroproc._

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers
import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.{VcsBackendAnnotation, WriteVcdAnnotation}
import java.io.{FileNotFoundException, IOException}

class NeuromorphicProcessorTester extends AnyFlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Neuromorphic Processor"

  val bitDelay = FREQ / BAUDRATE + 1

  def fetch(file: String) = {
    val src = scala.io.Source.fromFile(file)
    val lines = try {
      src.mkString
    } catch {
      case e: FileNotFoundException => {
        println("Incorrect path to image file")
        ""
      }
      case e: IOException => {
        println("Cannot open image file")
        ""
      }
    } finally {
      src.close
    }
    lines.split(",").map(_.toInt)
  }

  if (!RANKORDERENC) {
    it should "process an image" taggedAs(VcsTest, SlowTest) in {
      test(new NeuromorphicProcessor())
        .withAnnotations(Seq(VcsBackendAnnotation, WriteVcdAnnotation)) {
        dut =>
          dut.clock.setTimeout(FREQ)

          // Reference image and results
          val image = fetch("./src/test/scala/neuroproc/systemtests/image.txt")
          val results = fetch("./src/test/scala/neuroproc/systemtests/results.txt")

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
          dut.reset.poke(true.B)
          dut.clock.step()
          dut.reset.poke(false.B)
          dut.io.uartTx.expect(true.B)

          // Load an image into the accelerator ...
          println("Loading image into accelerator")
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
            println("Done loading image - waiting for phase change")
            while (inject)
              dut.clock.step()
          }
          dut.clock.step(FREQ/2)
          inject = false
          inj.join

          // ... get its response
          println("Phase changed - getting accelerator's response")
          var spikes = Array[Int]()
          var receive = true
          var spiked = false
          dut.io.uartTx.expect(true.B)
          val rec = fork {
            while (receive) {
              if (!dut.io.uartTx.peek.litToBoolean)
                spikes = spikes :+ transferByte()
              dut.clock.step()
            }
          }
          dut.clock.step(FREQ/2)
          receive = false
          rec.join

          println("Response received - comparing results")
          assert(results.length == spikes.length, "number of spikes does not match expected")
          assert(results.zip(spikes).map(x => x._1 == x._2).reduce(_ && _), "spikes do not match expected")
      }
    }
  }
}
