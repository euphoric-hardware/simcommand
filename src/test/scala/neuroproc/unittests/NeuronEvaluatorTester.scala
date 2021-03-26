package neuroproc.unittests

import neuroproc._

import org.scalatest._
import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.WriteVcdAnnotation

class NeuronEvaluatorTester extends FlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Neuron Evaluator"

  // Set input signals to their default values
  def resetInputs(dut: NeuronEvaluator) = {
    val cntr = dut.io.cntrSels
    dut.io.evalEnable.poke(true.B)
    cntr.potSel.poke(2.U)
    cntr.spikeSel.poke(1.U)
    cntr.refracSel.poke(1.U)
    cntr.decaySel.poke(false.B)
    cntr.writeDataSel.poke(0.U)
  }

  it should "disable" in {
    test(new NeuronEvaluator()).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        val cntr = dut.io.cntrSels

        // Reset inputs
        resetInputs(dut)
        
        // Load membrane potential
        cntr.potSel.poke(0.U)
        dut.io.dataIn.poke(42.S)
        dut.clock.step()

        // Apply a weight and check that the result has not changed
        dut.io.evalEnable.poke(false.B)
        cntr.potSel.poke(1.U)
        dut.io.dataIn.poke(1.S)
        dut.clock.step()
        cntr.potSel.poke(2.U)
        cntr.writeDataSel.poke(1.U)
        dut.io.dataOut.expect(42.S)
    }
  }

  it should "operate and spike" in {
    test(new NeuronEvaluator()).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        val cntr = dut.io.cntrSels
        val startPot = BigInt(12)

        // Reset inputs
        resetInputs(dut)
        dut.clock.step()

        // Load membrane potential
        cntr.potSel.poke(0.U)
        dut.io.dataIn.poke(startPot.S)
        dut.clock.step()
        dut.io.spikeIndi.expect(false.B)
        dut.io.refracIndi.expect(true.B)

        // Load some weights
        cntr.potSel.poke(1.U)
        var total = startPot
        for (i <- -1000 until 1000 by 50) {
          dut.io.dataIn.poke(i.S)
          dut.clock.step()
          total += i
        }
        cntr.potSel.poke(2.U)
        dut.io.dataIn.poke(0.S)
        cntr.writeDataSel.poke(1.U)
        dut.io.dataOut.expect(total.S)

        // Check spiking - no spike first
        dut.io.dataIn.poke((total + 10).S)
        cntr.spikeSel.poke(0.U)
        dut.clock.step()
        cntr.spikeSel.poke(1.U)
        dut.io.dataIn.poke(0.S)
        cntr.writeDataSel.poke(1.U)
        dut.io.dataOut.expect(total.S)
        dut.io.spikeIndi.expect(false.B)
        dut.clock.step()

        // - now a spike
        dut.io.dataIn.poke((total - 10).S)
        cntr.spikeSel.poke(0.U)
        dut.clock.step()
        cntr.spikeSel.poke(1.U)
        dut.io.dataIn.poke(0.S)
        cntr.writeDataSel.poke(1.U)
        dut.io.dataOut.expect(0.S)
        dut.io.spikeIndi.expect(true.B)
    }
  }

  it should "decay" in {
    test(new NeuronEvaluator()).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        val cntr = dut.io.cntrSels

        // Reset inputs
        resetInputs(dut)
        
        // Load membrane potential
        cntr.potSel.poke(0.U)
        dut.io.dataIn.poke(42.S)
        dut.clock.step()

        cntr.decaySel.poke(true.B)
        cntr.potSel.poke(1.U)
        cntr.writeDataSel.poke(1.U)

        // Perform 50% decay
        dut.io.dataIn.poke(1.S)
        dut.clock.step()
        dut.io.dataOut.expect(21.S)

        // Perform 12.5% decay
        dut.io.dataIn.poke(3.S)
        dut.clock.step()
        dut.io.dataOut.expect(19.S)
    }
  }
}
