import neuroproc._

import org.scalatest._
import chisel3._
import chisel3.util._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.WriteVcdAnnotation

class TransmissionSystemTester extends FlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Transmission System"

  it should "transmit spikes" in {
    test(new TransmissionSystem(0)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        // Without spikes
        dut.io.ready.poke(false.B)
        dut.io.n.poke(0.U)
        for (i <- 0 until EVALUNITS)
          dut.io.spikes(i).poke(false.B)
        dut.clock.step()
        dut.io.data.expect(0.U)
        dut.io.valid.expect(false.B)
        
        // With spikes
        for (i <- 0 until EVALUNITS) {
          for (j <- 0 until EVALUNITS)
            dut.io.spikes(j).poke(false.B)
          dut.io.spikes(i).poke(true.B)
          dut.clock.step()
          for (j <- 0 until EVALUNITS)
            dut.io.spikes(j).poke(false.B)

          while (!dut.io.valid.peek.litToBoolean)
            dut.clock.step()
          dut.io.data.expect(i.U)
          dut.io.ready.poke(true.B)
          dut.clock.step()
          dut.io.ready.poke(false.B)
        }
    }
  }
  
  it should "match a software model" in {
    test(new TransmissionSystem(0)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        // Reset inputs
        dut.io.ready.poke(false.B)
        dut.io.n.poke(0.U)
        for (i <- 0 until EVALUNITS)
          dut.io.spikes(i).poke(false.B)
        
        // Local state variables similar to those of the module
        var spikeRegs = Array.fill(EVALUNITS) { false }
        var neuronIdMSB = Array.fill(EVALUNITS) { 0 }
        var maskRegs = Array.fill(EVALUNITS) { true }

        // I/O signal values
        var ready = false
        var n = 0
        var spikes = Array.fill(EVALUNITS) { false }
        var data = 0

        def priorityMask(reqs: Array[Boolean]) = {
          require(reqs.length == EVALUNITS)
          val valid = reqs.reduce(_ || _)
          var value = 0
          for (i <- EVALUNITS-1 to 0 by -1)
            if (reqs(i))
              value = i
          var mask = Array(value == 0)
          for (i <- EVALUNITS-2 to 0 by -1) {
            mask = (reqs(i+1) || mask.head) +: mask
          }
          val rst = (0 until EVALUNITS).map { _ == value && valid }.toArray
          (value, mask, rst, valid)
        }

        def updateRegs() = {
          // Wire values
          val reqs = maskRegs zip spikeRegs map { e => e._1 && e._2 }
          val resp = priorityMask(reqs)
          val rstReadySel = resp._3.map { e => !(e && ready) }
          val spikeUpdate = rstReadySel zip spikeRegs map { e => e._1 && e._2 }
        
          // Next step values
          var newMaskRegs = maskRegs
          if (ready) {
            newMaskRegs = resp._2
          } else if (!resp._4) {
            newMaskRegs = Array.fill(EVALUNITS) { true }
          }
          val newNeuronIdMSB = spikeUpdate zip neuronIdMSB map { e => if (!e._1) n else e._2 }
          val newSpikeRegs = spikeUpdate zip (spikeRegs zip spikes) map { e => if (!e._1) e._2._2 else e._2._1 }
        
          // Store new values
          spikeRegs = newSpikeRegs
          neuronIdMSB = newNeuronIdMSB
          maskRegs = newMaskRegs
        }

        def genData() = {
          val reqs = maskRegs zip spikeRegs map { e => e._1 && e._2 }
          val resp = priorityMask(reqs)
          data = (neuronIdMSB(resp._1) << log2Up(EVALUNITS)) | resp._1
        }

        def step() = {
          dut.clock.step()
          updateRegs()
          genData()
        }

        // Without spikes
        dut.io.ready.poke(true.B)
        ready = true
        for (_ <- 0 until EVALUNITS) {
          step()
          dut.io.data.expect(data.U)
        }

        // With different n
        val rng = new scala.util.Random(42)
        for (_ <- 0 until TMNEURONS/2) {
          n = rng.nextInt & ((1 << N) - 1)
          dut.io.n.poke(n.U)

          for (i <- 0 until EVALUNITS) {
            spikes = (0 until EVALUNITS).map { _ == i }.toArray
            for (j <- 0 until EVALUNITS)
              dut.io.spikes(j).poke(spikes(j).B)
            step()

            while (!dut.io.valid.peek.litToBoolean) {
              step()
              println("Model values:")
              println("\tspikeRegs   = " + spikeRegs.deep.mkString(" "))
              println("\tneuronIdMSB = " + neuronIdMSB.deep.mkString(" "))
              println("\tmaskRegs    = " + maskRegs.deep.mkString(" "))
              println("\tdata        = " + data)
              println()
            }
            dut.io.data.expect(data.U)
          }
        }
    }
  }
}
