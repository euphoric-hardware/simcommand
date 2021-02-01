import neuroproc._

import org.scalatest._
import chisel3._
import chisel3.util._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.WriteVcdAnnotation

class OutputCoreTester extends FlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Output Core"

  it should "accept and transfer spikes" in {
    test(new OutputCore(4)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.io.offCCReady.poke(false.B)
        dut.io.grant.poke(false.B)
        dut.io.rx.poke(0.U)

        val rng = new scala.util.Random(42)

        // Spawn a new thread to inject spikes
        var spikes = List[BigInt]()
        val inj = fork {
          for (i <- 0 until 1024) {
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

        // Read injected spikes out
        for (i <- 0 until 1024) {
          if (dut.io.offCCValid.peek.litToBoolean) {
            dut.io.offCCReady.poke(true.B)
            val rand = spikes.head & 0xFF
            dut.io.offCCData.expect(rand.U)
            println(s"Read $rand")
            spikes = spikes.tail
          }
          dut.clock.step()
          dut.io.offCCReady.poke(false.B)
        }

        inj.join()
    }
  }

  it should "ignore spikes when full" in {
    test(new OutputCore(4)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.clock.setTimeout(2000)

        dut.io.offCCReady.poke(false.B)
        dut.io.grant.poke(false.B)

        // Internal queue has 16 entries; try to add 17
        // 599 happens to be a number that the above test used which has the
        // right MSB value which core 4 subscribes to
        for (i <- 0 until 15) {
          dut.io.rx.poke(599.U)
          dut.clock.step()
          dut.io.rx.poke(0.U)
          dut.clock.step()
        }

        // Read out 16 entries
        for (i <- 0 until 15) {
          while (!dut.io.offCCValid.peek.litToBoolean)
            dut.clock.step()
          dut.io.offCCReady.poke(true.B)
          dut.io.offCCData.expect(87.U)
          dut.clock.step()
          dut.io.offCCReady.poke(false.B)
        }

        // Run for a long time with no outputs expected
        for (i <- 0 until 1000) {
          dut.io.offCCValid.expect(false.B)
          dut.clock.step()
        }
    }
  }
}
