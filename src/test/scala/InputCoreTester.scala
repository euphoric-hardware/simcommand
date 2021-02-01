import neuroproc._

import org.scalatest._
import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.WriteVcdAnnotation

class InputCoreTester extends FlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Input Core"

  it should "load data and generate spikes" in {
    test(new InputCore(0)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.clock.setTimeout(10*CYCLESPRSTEP)

        // Reset inputs
        dut.io.offCCData.poke(0.U)
        dut.io.offCCValid.poke(false.B)
        dut.io.offCCHSin.poke(false.B)
        dut.io.grant.poke(true.B)
        dut.io.rx.poke(0.U)

        // Fork a bus handler in case any bus requests are made during load
        var loaded = false
        val busHandler = fork {
          while (!loaded) {
            dut.io.grant.poke(dut.io.req.peek)
            dut.clock.step()
          }
        }

        // Load values into spike period memory
        for (i <- 1 to NEURONSPRCORE) {
          dut.io.offCCData.poke((((i-1) << 16) | 1).U)
          dut.io.offCCValid.poke(true.B)
          do {
            dut.clock.step()
          } while (!dut.io.offCCReady.peek.litToBoolean)
          dut.io.offCCValid.poke(false.B)
          dut.clock.step()
        }
        println("Memory loaded")
        loaded = true
        busHandler.join()

        // The memory has been loaded completely - force a change in phase
        dut.io.offCCHSin.poke(true.B)
        dut.io.grant.poke(false.B)
        while (!dut.io.offCCHSout.peek.litToBoolean)
          dut.clock.step()
        println("Evaluation ongoing")
        
        // Run through a time step - spikes are not generated for ts = 0
        dut.clock.step(CYCLESPRSTEP)

        // Now run and check for spikes on the output
        // HARDCODED TEST FOR NOW - but expected from TransmissionSystemTester
        var expectedOutput = Array(0, 1, 3, 2, 6, 5, 4, 9, 8, 7, 0xc, 0xb, 0xa, 0xf, 0xe, 0xd)
        for (i <- 16 until 256 by 16) {
          for (j <- 0 until 4) {
            val ofs = i + j * 4
            expectedOutput ++= Array(ofs + 3, ofs + 2, ofs + 1, ofs)
          }
        }
        var index = 0
        for (i <- 0 until CYCLESPRSTEP) {
          if (dut.io.req.peek.litToBoolean) {
            dut.io.grant.poke(true.B)
            dut.io.tx.expect(expectedOutput(index).U)
            index += 1
            dut.clock.step()
          } else {
            dut.clock.step()
          }
          dut.io.grant.poke(false.B)
        }
    }
  }
}
