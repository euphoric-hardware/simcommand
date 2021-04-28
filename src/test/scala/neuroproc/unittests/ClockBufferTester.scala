// Please note, this test uses very experimental clock peek/poke constructs
package neuroproc.unittests

import neuroproc._

import chisel3._
import chisel3.util._
import chiseltest._
import chiseltest.experimental.UncheckedClockPoke._
import chiseltest.experimental.UncheckedClockPeek._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.{WriteVcdAnnotation, VerilatorBackendAnnotation}
import org.scalatest._

class ClockBufferTester extends FlatSpec with ChiselScalatestTester {
  behavior of "Clock buffer"

  it should "enable/disable clock" in {
    test(ClockBuffer())
      .withAnnotations(Seq(VerilatorBackendAnnotation, WriteVcdAnnotation)) {
      dut =>
        // Default values
        dut.reset.poke(false.B)
        dut.io.I.low()
        dut.io.CE.poke(false.B)
        dut.clock.step()

        // Force transition with CE=0
        dut.io.I.high()
        dut.clock.step()
        assert(!dut.io.O.peekClock, "expected low output clock when CE=false")

        // Take I low again
        dut.io.I.low()
        dut.clock.step()
        assert(!dut.io.O.peekClock, "expected low output clock when CE=false")

        // Assert CE, wait a little and then force a clock transition
        dut.io.CE.poke(true.B)
        dut.clock.step()
        dut.io.I.high()
        assert(dut.io.O.peekClock, "expected high output clock when CE=true")
    }
  }
}
