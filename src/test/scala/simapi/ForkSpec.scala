package simapi

import chisel3._
import chiseltest.{ChiselScalatestTester, WriteVcdAnnotation}
import org.scalatest.flatspec.AnyFlatSpec

class ForkSpec extends AnyFlatSpec with ChiselScalatestTester {
  class ForkExample(a: UInt, b: UInt) {
    def increment(cycle: Int = 0): Command[Unit] = {
      if (cycle == 10) Return(Unit)
      else
        Poke(b, cycle.U, () =>
          Step(1, () =>
            increment(cycle + 1)
          )
        )
    }

    def program(): Command[Unit] = {
      Step(1, () =>
        Fork(increment(), () => // fork off child thread
          Step(10, () => Return(Unit)) // step on main thread
        )
      )
    }
  }

  class ForkModule extends Module {
    val a = IO(Input(UInt(10.W)))
    val b = IO(Input(UInt(10.W)))
  }

  "Fork" should "create a thread that operates independently of the main thread" in {
    test(new ForkModule()).withAnnotations(Seq(WriteVcdAnnotation)) { c =>
      val cmds = new ForkExample(c.a, c. b)
      Command.run(cmds.program(), c.clock, print=true)
    }
  }
}
