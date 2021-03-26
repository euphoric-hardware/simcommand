// Please note, this test uses very experimental clock peek/poke constructs
package neuroproc.unittests

import neuroproc._

import org.scalatest._
import chisel3._
import chisel3.util._
import chiseltest._
import chiseltest.experimental.UncheckedClockPoke._
import chiseltest.experimental.UncheckedClockPeek._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.{WriteVcdAnnotation, VcsBackendAnnotation}

class ClockBufferTester extends FlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Clock buffer"

  it should "enable/disable clock" taggedAs(VcsTest) in {
    test(ClockBuffer())
      .withAnnotations(Seq(VcsBackendAnnotation, WriteVcdAnnotation)) {
      dut =>
        dut.io.i.high()
        dut.io.ce.poke(true.B)
        assert(dut.io.o.peekClock, "expected high output clock when i=true and ce=true")
        dut.clock.step()
        dut.io.i.low()
        assert(!dut.io.o.peekClock, "expected low output clock when i=false and ce=true")
        dut.clock.step()
        dut.io.ce.poke(false.B)
        assert(!dut.io.o.peekClock, "expected low output clock when i=false and ce=false")
        dut.clock.step()
        dut.io.i.high()
        assert(!dut.io.o.peekClock, "expected low output clock when i=true and ce=false")
        dut.clock.step()
    }
  }
}
