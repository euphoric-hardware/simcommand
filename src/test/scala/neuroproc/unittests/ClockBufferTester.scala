// Please note, this test uses very experimental clock peek/poke constructs
package neuroproc.unittests

import neuroproc._

import org.scalatest.flatspec.AnyFlatSpec
import chisel3._
import chisel3.util._
import chiseltest._
import chiseltest.experimental.UncheckedClockPoke._
import chiseltest.experimental.UncheckedClockPeek._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.{WriteVcdAnnotation, VcsBackendAnnotation}

class ClockBufferTester extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "Clock buffer"

  it should "enable/disable clock" taggedAs(VcsTest) in {
    test(ClockBuffer())
      .withAnnotations(Seq(VcsBackendAnnotation, WriteVcdAnnotation)) {
      dut =>
        dut.io.I.high()
        dut.io.CE.poke(true.B)
        assert(dut.io.O.peekClock, "expected high output clock when i=true and ce=true")
        dut.clock.step()
        dut.io.I.low()
        assert(!dut.io.O.peekClock, "expected low output clock when i=false and ce=true")
        dut.clock.step()
        dut.io.CE.poke(false.B)
        assert(!dut.io.O.peekClock, "expected low output clock when i=false and ce=false")
        dut.clock.step()
        dut.io.I.high()
        assert(!dut.io.O.peekClock, "expected low output clock when i=true and ce=false")
        dut.clock.step()
    }
  }
}
