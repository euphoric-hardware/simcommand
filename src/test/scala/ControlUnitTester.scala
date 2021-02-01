import neuroproc._

import org.scalatest._
import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.WriteVcdAnnotation

class ControlUnitTester extends FlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Control Unit"

  it should "operate" in {
    test(new ControlUnit(0)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.clock.setTimeout(2*CYCLESPRSTEP)

        // Reset input signals
        for (i <- 0 until EVALUNITS) {
          dut.io.spikeIndi(i).poke(false.B)
          dut.io.refracIndi(i).poke(false.B)
        }

        // Assume 0 spikes
        dut.io.spikeCnt.poke(0.U)
        dut.io.aData.poke(0.U)
        
        // Check initial signal values
        dut.io.addr.expect(0.U)
        dut.io.wr.expect(false.B)
        dut.io.ena.expect(false.B)

        for (i <- 0 until EVALUNITS) {
          dut.io.cntrSels(i).potSel.expect(2.U)
          dut.io.cntrSels(i).spikeSel.expect(2.U)
          dut.io.cntrSels(i).refracSel.expect(1.U)
          dut.io.cntrSels(i).writeDataSel.expect(0.U)
          dut.io.cntrSels(i).decaySel.expect(false.B)
        }
        dut.io.evalEnable.expect(false.B)

        dut.io.inOut.expect(false.B)
        dut.io.aAddr.expect(0.U)
        dut.io.aEna.expect(false.B)
        
        dut.io.n.expect(0.U)
        for (i <- 0 until EVALUNITS) {
          dut.io.spikes(i).expect(false.B)
        } 

        // Run through a full cycle of the FSM loop
        do {
          dut.clock.step()
        } while (!dut.io.inOut.peek.litToBoolean)
        println("Run through FSM")
        dut.io.evalEnable.expect(true.B)

        // State 1
        dut.io.ena.expect(true.B)
        dut.io.wr.expect(false.B)
        dut.io.addr.expect(OSREFRAC.U)
        for (i <- 0 until EVALUNITS)
          dut.io.cntrSels(i).spikeSel.expect(1.U)
        dut.clock.step()

        // State 2
        dut.io.ena.expect(true.B)
        dut.io.wr.expect(false.B)
        dut.io.addr.expect(OSPOTENTIAL.U)
        for (i <- 0 until EVALUNITS)
          dut.io.cntrSels(i).refracSel.expect(0.U)
        dut.clock.step()

        // State 3
        dut.io.ena.expect(true.B)
        dut.io.wr.expect(false.B)
        dut.io.addr.expect(OSDECAY.U)
        dut.io.aEna.expect(true.B)
        for (i <- 0 until EVALUNITS)
          dut.io.cntrSels(i).potSel.expect(0.U)
        dut.clock.step()
        
        // Because spikeCnt = 0, skip some states
        // ...
        // State 6
        dut.io.ena.expect(true.B)
        dut.io.wr.expect(false.B)
        dut.io.addr.expect(OSBIAS.U)
        dut.clock.step()

        // State 7
        dut.io.ena.expect(true.B)
        dut.io.wr.expect(false.B)
        dut.io.addr.expect(OSTHRESH.U)
        dut.clock.step()
        // Some outputs unchanged because spikeCnt = 0

        // State 8
        dut.io.ena.expect(true.B)
        dut.io.wr.expect(false.B)
        dut.io.addr.expect(OSREFRACSET.U)
        for (i <- 0 until EVALUNITS)
          dut.io.cntrSels(i).spikeSel.expect(0.U)
        dut.clock.step()
        
        // State 9
        dut.io.ena.expect(true.B)
        dut.io.wr.expect(true.B)
        dut.io.addr.expect(OSREFRAC.U)
        for (i <- 0 until EVALUNITS) {
          dut.io.cntrSels(i).writeDataSel.expect(2.U)
          dut.io.spikes(i).expect(false.B)
        }
        dut.clock.step()

        // State A
        dut.io.ena.expect(true.B)
        dut.io.wr.expect(false.B)
        dut.io.addr.expect(OSPOTSET.U)
        dut.clock.step()

        // State B
        dut.io.ena.expect(true.B)
        dut.io.wr.expect(true.B)
        dut.io.addr.expect(OSPOTENTIAL.U)
        for (i <- 0 until EVALUNITS)
          dut.io.cntrSels(i).writeDataSel.expect(1.U)
        dut.clock.step()
    }
  }

  it should "handle spikes" in {
    test(new ControlUnit(0)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.clock.setTimeout(2*CYCLESPRSTEP)

        // Reset input signals
        val rng = new scala.util.Random(42)
        val spikes = Array.fill(EVALUNITS) { rng.nextBoolean }
        val refrac = Array.fill(EVALUNITS) { rng.nextBoolean }
        for (i <- 0 until EVALUNITS) {
          dut.io.spikeIndi(i).poke(spikes(i).B)
          dut.io.refracIndi(i).poke(refrac(i).B)
        }

        // Assume some spikes
        dut.io.spikeCnt.poke(3.U)
        dut.io.aData.poke(0.U)

        // Run through a full cycle of the FSM loop
        do {
          dut.clock.step()
        } while (!dut.io.inOut.peek.litToBoolean)
        println("Run through FSM")
        dut.io.evalEnable.expect(true.B)
        
        // State 1
        dut.clock.step()

        // State 2
        dut.clock.step()

        // State 3
        dut.clock.step()

        // State 4
        dut.io.ena.expect(true.B)
        dut.io.wr.expect(false.B)
        dut.io.addr.expect(OSWEIGHT.U)
        dut.io.aEna.expect(true.B)
        for (i <- 0 until EVALUNITS) {
          if (refrac(i)) {
            dut.io.cntrSels(i).potSel.expect(1.U)
            dut.io.cntrSels(i).decaySel.expect(true.B)
          }
        }
        dut.clock.step()

        // State 5 - 3 times over
        dut.io.ena.expect(true.B)
        dut.io.wr.expect(false.B)
        dut.io.addr.expect(OSWEIGHT.U)
        dut.io.aEna.expect(true.B)
        for (i <- 0 until EVALUNITS) {
          if (refrac(i)) 
            dut.io.cntrSels(i).potSel.expect(1.U)
        }
        dut.clock.step(3)

        // State 6
        for (i <- 0 until EVALUNITS) {
          if (refrac(i))
            dut.io.cntrSels(i).potSel.expect(1.U)
        }
        dut.clock.step()

        // State 7
        for (i <- 0 until EVALUNITS) {
          if (refrac(i))
            dut.io.cntrSels(i).potSel.expect(1.U)
        }
        dut.clock.step()

        // State 8
        dut.clock.step()

        // State 9
        dut.clock.step()
        for (i <- 0 until EVALUNITS) 
          dut.io.spikes(i).expect(spikes(i).B)

        // State A
        dut.clock.step()

        // State B
        dut.clock.step()
    }
  }
}
