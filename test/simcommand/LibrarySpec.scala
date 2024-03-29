package simcommand

import chisel3._
import chisel3.util.Counter
import chiseltest.{VerilatorBackendAnnotation, WriteVcdAnnotation, testableClock}
import org.scalatest.flatspec.AnyFlatSpec

class LibrarySpec extends AnyFlatSpec with SimcommandScalatestTester {
  class PokeCounter extends Module {
    val in = IO(Input(Bool()))
    val out = IO(Output(UInt(32.W)))
    val ct = Counter(2 << 16)

    when(in) { ct.inc() }
    out := ct.value
  }

  class LongDelay extends Module {
    val a = IO(Output(Bool()))
    val b = IO(Output(UInt(32.W)))
    val c = Counter(2 << 16)
    c.inc()
    a := c.value > 100000.U
    b := c.value
  }

  "repeat" should "run command repeatedly" in {
    testChisel(new PokeCounter()).withAnnotations(Seq(WriteVcdAnnotation, VerilatorBackendAnnotation)) { c =>
      val program = for {
        _ <- repeat(for {
          _ <- poke(c.in, true.B)
          _ <- step(1)
          _ <- poke(c.in, false.B)
          _ <- step(1)
        } yield (), 1000)
        pokeCount <- peek(c.out)
      } yield pokeCount
      val result = unsafeRun(program, c.clock)
      assert(result.retval.litValue == 1000)
    }
  }

  "repeatCollect" should "collect values" in {
    testChisel(new LongDelay()).withAnnotations(Seq(WriteVcdAnnotation, VerilatorBackendAnnotation)) { c =>
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
    testChisel(new LongDelay()).withAnnotations(Seq(WriteVcdAnnotation, VerilatorBackendAnnotation)) { c =>
      val program = waitForValue(c.a, 1.B)
      c.clock.setTimeout(200000)
      val result = unsafeRun(program, c.clock)
      assert(result.cycles > 100000)
      assert(result.threadsSpawned == 1)
    }
  }
}
