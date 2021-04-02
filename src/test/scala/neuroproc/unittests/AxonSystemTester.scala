package neuroproc.unittests

import neuroproc._

import org.scalatest.flatspec.AnyFlatSpec
import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.WriteVcdAnnotation

class AxonSystemTester extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "Axon System"

  it should "pass" in {
    test(new AxonSystem()).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        // Set inputs low
        dut.io.axonIn.poke(0.U)
        dut.io.axonValid.poke(false.B)
        dut.io.inOut.poke(false.B)
        dut.io.rAddr.poke(0.U)
        dut.io.rEna.poke(false.B)
        dut.clock.step()

        // Write the first memory
        for (i <- 0 until 5 * 1024) {
          dut.io.axonIn.poke((i/5).U)
          dut.io.axonValid.poke((i % 5 == 0).B)
          dut.clock.step()
        }

        // Read the other memory and check that it is empty
        dut.io.rEna.poke(true.B)
        for (i <- 0 until 1024) {
          dut.io.rAddr.poke(i.U)
          dut.clock.step()
          dut.io.rData.expect(0.U)
        }
        dut.io.rEna.poke(false.B)

        // New time step (swap memories)
        dut.io.inOut.poke(true.B)
        dut.clock.step()

        // Read the first memory and check its content
        dut.io.rEna.poke(true.B)
        for (i <- 0 until 1024) {
          dut.io.rAddr.poke(i.U)
          dut.clock.step()
          dut.io.rData.expect(i.U)
        }
        dut.io.rEna.poke(false.B)

        // Write the second memory
        for (i <- 0 until 5 * 1024) {
          dut.io.axonIn.poke((i/5).U)
          dut.io.axonValid.poke((i % 5 == 0).B)
          dut.clock.step()
        }

        // New time step (swap memories)
        dut.io.inOut.poke(false.B)
        dut.clock.step()

        // Read the second memory
        dut.io.rEna.poke(true.B)
        for (i <- 0 until 1024) {
          dut.io.rAddr.poke(i.U)
          dut.clock.step()
          dut.io.rData.expect(i.U)
        }
        dut.io.rEna.poke(false.B)
    }
  }
}
