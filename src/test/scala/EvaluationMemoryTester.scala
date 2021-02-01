import neuroproc._

import org.scalatest._
import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.WriteVcdAnnotation

class EvaluationMemoryTester extends FlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Evaluation Memory"

  it should "read and write" in {
    test(new EvaluationMemory2(2, 0)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        // Reset input signals
        dut.io.addr.poke(0.U)
        dut.io.wr.poke(false.B)
        dut.io.ena.poke(true.B)
        dut.io.writeData.poke(0.S)

        // Read a few random addresses
        val rng = new scala.util.Random(42)
        val indexes = Array.fill(128) { rng.nextInt(EVALMEMSIZE) }.sorted
        val lines = scala.io.Source.fromFile("mapping/evaldatac2e0.mem").getLines.map { Integer.parseInt(_, 2) }
        var count = 0
        for (elem <- lines) {
          if (count < indexes.length && count == indexes(count)) {
            dut.io.addr.poke(count.U)
            dut.clock.step()
            dut.io.readData.expect(elem.S)
          }
          count += 1
        }

        // Write a few random addresses
        val windexes = Array.fill(128) { rng.nextInt(EVALMEMSIZE) }
        val data = Array.fill(128) { BigInt(NEUDATAWIDTH, rng) - (BigInt(1) << (NEUDATAWIDTH-1)) }
        dut.io.wr.poke(true.B)
        for (elem <- windexes zip data) {
          dut.io.addr.poke(elem._1.U)
          dut.io.writeData.poke(elem._2.S(NEUDATAWIDTH.W))
          dut.clock.step()
        }

        // Read the values back
        dut.io.wr.poke(false.B)
        for (elem <- windexes zip data) {
          dut.io.addr.poke(elem._1.U)
          dut.clock.step()
          dut.io.readData.expect(elem._2.S(NEUDATAWIDTH.W))
        }
    }
  }
}
