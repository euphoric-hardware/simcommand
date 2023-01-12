package simcommand

import chisel3._
import chisel3.util.Counter
import chiseltest.{ChiselScalatestTester, VerilatorBackendAnnotation, WriteVcdAnnotation, testableClock}
import chiseltest.internal.NoThreadingAnnotation
import org.scalatest.flatspec.AnyFlatSpec

class LibrarySpec extends AnyFlatSpec with ChiselScalatestTester {
  class LongDelay extends Module {
    val a = IO(Output(Bool()))
    val b = IO(Output(UInt(32.W)))
    val c = Counter(2 << 16)
    c.inc()
    a := c.value > 100000.U
    b := c.value
  }

  "repeatCollect" should "collect values" in {
    test(new LongDelay()).withAnnotations(Seq(WriteVcdAnnotation, VerilatorBackendAnnotation, NoThreadingAnnotation)) { c =>
      val program = repeatCollect(for {
        r <- peek(c.b)
        _ <- step(1)
      } yield r.litValue, 10000)
      c.clock.setTimeout(200000)

      val result = unsafeRun(program, c.clock)
      val expected = Seq.range(0, 10000)

      assert(result.retval == expected)
    }
  }

  "doWhile" should "not overflow the stack" in {
    test(new LongDelay()).withAnnotations(Seq(WriteVcdAnnotation, VerilatorBackendAnnotation, NoThreadingAnnotation)) { c =>
      val program = waitForValue(c.a, 1.B)
      c.clock.setTimeout(200000)
      val result = unsafeRun(program, c.clock)
      assert(result.cycles > 100000)
      assert(result.threadsSpawned == 1)
    }
  }
}
