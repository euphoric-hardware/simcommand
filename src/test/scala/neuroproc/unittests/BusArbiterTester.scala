package neuroproc.unittests

import neuroproc._

import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.WriteVcdAnnotation
import org.scalatest._

class BusArbiterTester extends FlatSpec with ChiselScalatestTester {
  behavior of "Bus Arbiter"

  it should "handle requests" in {
    test(new BusArbiter()).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        // No requests
        for (i <- 0 until CORES)
          dut.io.reqs(i).poke(false.B)
        dut.clock.step()
        for (i <- 0 until CORES)
          dut.io.grants(i).expect(false.B)
        
        // Test requests
        for (i <- 0 until CORES)
          dut.io.reqs(i).poke(true.B)
        dut.clock.step()
        dut.io.grants(CORES-1).expect(true.B)
        for (i <- 0 until CORES-1)
          dut.io.grants(i).expect(false.B)
        
        for (i <- CORES-1 to 0 by -1) {
          dut.io.reqs(i).poke(false.B)
          dut.clock.step()
          if (i > 0)
            for (j <- 0 until CORES)
              dut.io.grants(j).expect((j == i - 1).B)
        }
    }
  }
}
