package simapi

import chisel3._
import chiseltest.{ChiselScalatestTester, WriteVcdAnnotation}
import org.scalatest.flatspec.AnyFlatSpec

class ForkSpec extends AnyFlatSpec with ChiselScalatestTester {
  class ForkExample(b: UInt) {
    def increment(cycle: Int = 0): Command[Unit] = {
      if (cycle == 10) Return(Unit)
      else
        Poke(b, cycle.U, () =>
          Step(1, () =>
            increment(cycle + 1)
          )
        )
    }

    def inspect(cycle: Int = 0, values: Seq[Int]): Command[Seq[Int]] = {
      if (cycle == 10) Return(values)
      else
        Peek(b, (value: UInt) =>
          Step(1, () =>
            inspect(cycle + 1, values :+ value.litValue.toInt)
          )
        )
    }

    def program(): Command[Seq[Int]] = {
      Step(1, () =>
        Fork(increment(), "poker", (h1: ThreadHandle[Unit]) => // fork off poking thread
          Fork(inspect(0, Seq.empty), "peeker", (h2: ThreadHandle[Seq[Int]]) => // fork off peeking thread
            // TODO: join both threads and return result (TODO: have join_all - default and join_any functionality)
            // Step(11, () => Return(())) // step on main thread
            Join(h2, (peeked: Seq[Int]) => Return(peeked))
          )
        )
      )
    }
  }

  class ForkModule extends Module {
    val b = IO(Input(UInt(10.W)))
  }

  "Fork" should "create a thread that operates independently of the main thread" in {
    test(new ForkModule()).withAnnotations(Seq(WriteVcdAnnotation)) { c =>
      val cmds = new ForkExample(c.b)
      val retval = Command.run(cmds.program(), c.clock, print=true)
      println(retval)
    }
  }
}
