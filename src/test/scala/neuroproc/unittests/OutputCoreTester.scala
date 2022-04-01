package neuroproc.unittests

import neuroproc._

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest._

class OutputCoreTester extends FlatSpec with ChiselScalatestTester {
  behavior of "Output Core"

  it should "accept and transfer spikes" in {
    test(new OutputCore(4)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.io.qFull.poke(false.B)
        dut.io.grant.poke(false.B)
        dut.io.rx.poke(0.U)

        val rng = new scala.util.Random(42)

        // Check that spikes are passed through correctly
        var spikes = List[BigInt]()
        val inj = fork {
          for (_ <- 0 until 1024) {
            if (rng.nextInt(10) <= 1) {
              val rand = BigInt(GLOBALADDRWIDTH, rng)
              dut.io.rx.poke(rand.U)
              if ((rand >> (GLOBALADDRWIDTH - log2Up(CORES))) == 2) {
                spikes = spikes :+ rand
                println(s"Injected $rand")
              }
            }
            dut.clock.step()
            dut.io.rx.poke(0.U)
          }
        }

        for (_ <- 0 until 1024) {
          if (dut.io.qWe.peek.litToBoolean) {
            val rand = spikes.head & 0xFF
            dut.io.qWe.expect(true.B)
            dut.io.qDi.expect(rand.U)
            println(s"Read $rand")
            spikes = spikes.tail
          }
          dut.clock.step()
        }
        inj.join
    }
  }

  it should "ignore spikes when full" in {
    test(new OutputCore(4)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.io.qFull.poke(false.B)
        dut.io.grant.poke(false.B)
        dut.io.rx.poke(0.U)

        // Check that a spike is passed through first
        dut.io.rx.poke(599.U)
        dut.clock.step()
        dut.io.qWe.expect(true.B)
        dut.io.qDi.expect(87.U)

        // Flag that queue is full and check that nothing is passed through
        dut.io.qFull.poke(true.B)
        dut.io.qWe.expect(false.B)
        dut.io.qDi.expect(87.U)
    }
  }
}
