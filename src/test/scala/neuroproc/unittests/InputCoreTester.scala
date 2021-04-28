package neuroproc.unittests

import neuroproc._

import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.WriteVcdAnnotation
import org.scalatest._

class InputCoreTester extends FlatSpec with ChiselScalatestTester {
  behavior of "Input Core"

  def resetInputs(dut: InputCore) = {
    dut.clock.setTimeout(CYCLESPRSTEP)

    dut.io.newTS.poke(false.B)
    dut.io.offCCHSin.poke(false.B)
    dut.io.memDo.poke(0.U)
    dut.io.grant.poke(false.B)
    dut.io.rx.poke(0.U)

    dut.io.pmClkEn.expect(false.B)
    dut.io.offCCHSout.expect(false.B)
  }

  def inputPeriods(dut: InputCore, v: Int) = {
    for (i <- 0 until NEURONSPRCORE) {
      dut.io.memAddr.expect((i + (1 << 8)).U)
      dut.clock.step()
      dut.io.memDo.poke(v.U)
    }
    dut.clock.step()
    dut.io.memDo.poke(0.U)
  }

  if (!RANKORDERENC) {
    it should "load data and generate spikes" in {
      test(new InputCore(0)).withAnnotations(Seq(WriteVcdAnnotation)) {
        dut =>
          resetInputs(dut)

          // Force a change of phase
          // Phase should not change till a new time step
          dut.io.offCCHSin.poke(true.B)
          dut.clock.step()
          dut.io.offCCHSout.expect(false.B)
          dut.io.memEn.expect(false.B)
          // New time step
          dut.io.newTS.poke(true.B)
          dut.clock.step()
          dut.io.offCCHSout.expect(true.B)
          dut.io.memEn.expect(true.B)
          dut.io.newTS.poke(false.B)
          println("Started a new phase and new time step")

          // Deliver spike periods and expect outputs
          // HARDCODED TEST FOR NOW - but expected from TransmissionSystemTester
          var expectedOutput = Array(0, 1, 3, 2, 6, 5, 4, 9, 8, 7, 0xc, 0xb, 0xa, 0xf, 0xe, 0xd)
          for (i <- 16 until 256 by 16) {
            for (j <- 0 until 4) {
              val ofs = i + j * 4
              expectedOutput ++= Array(ofs + 3, ofs + 2, ofs + 1, ofs)
            }
          }

          val mem = fork {
            inputPeriods(dut, 1)
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
          mem.join
          println("Generated spikes")

          // Core should be in done state and request disabling the clock
          dut.io.pmClkEn.expect(false.B)
          for (_ <- 0 until 100) {
            dut.clock.step()
            dut.io.pmClkEn.expect(false.B)
          }
          // When a new time step is signalled, it should start reading periods
          dut.io.newTS.poke(true.B)
          dut.io.pmClkEn.expect(true.B)
          dut.clock.step()
          dut.io.newTS.poke(false.B)
          dut.io.memEn.expect(true.B)
          println("Disabled and re-enabled clock when done")
      }
    }

    it should "not request the bus when not spiking" in {
      test(new InputCore(0)).withAnnotations(Seq(WriteVcdAnnotation)) {
        dut =>
          resetInputs(dut)

          // Force a change of phase
          dut.io.offCCHSin.poke(true.B)
          dut.io.newTS.poke(true.B)
          dut.clock.step()
          dut.io.newTS.poke(false.B)
          
          Array(0, 127).foreach { v =>
            // Feed in periods
            val mem = fork {
              inputPeriods(dut, v)
            }

            // Check for requests
            for (i <- 0 until NEURONSPRCORE + 1) {
              dut.io.req.expect(false.B)
              dut.clock.step()
            }
            mem.join

            // New time step
            while (dut.io.pmClkEn.peek.litToBoolean)
              dut.clock.step()
            dut.io.newTS.poke(true.B)
            dut.clock.step()
            dut.io.newTS.poke(false.B)
          }
      }
    }
  }
}
