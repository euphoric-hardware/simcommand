package neuroproc.unittests

import neuroproc._

import chisel3._
import chisel3.util._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.experimental.UncheckedClockPoke._
import chiseltest.experimental.UncheckedClockPeek._
import chiseltest.internal.{VerilatorBackendAnnotation, WriteVcdAnnotation}
import org.scalatest._

class TrueDualPortFIFOTester extends FlatSpec with ChiselScalatestTester {
  behavior of "True dual port FIFO"

  val numElements = 8
  val dataW = 32

  it should "flag empty and full" in {
    test(new Module {
      val io   = IO(new TrueDualPortFIFOIO(log2Up(numElements), dataW))
      val fifo = Module(new TrueDualPortFIFO(log2Up(numElements), dataW))
      io <> fifo.io
    }).withAnnotations(Seq(VerilatorBackendAnnotation, WriteVcdAnnotation)) {
      dut => 
        val clki = dut.io.clki
        val clko = dut.io.clko

        def stepAndAdvance(clk: Clock) = {
          clk.high()
          dut.clock.step()
          clk.low()
        }

        // Default values
        clki.low()
        dut.io.we.poke(false.B)
        dut.io.datai.poke(0.U)
      
        clko.low()
        dut.io.en.poke(false.B)

        // Reset to get the right flags
        dut.io.rst.poke(true.B)
        fork { stepAndAdvance(clko) }
        stepAndAdvance(clki)
        dut.io.rst.poke(false.B)
      
        // Check flags
        dut.io.empty.expect(true.B)
        dut.io.full.expect(false.B)

        // Fork a handler for the read port
        var read = false
        val rPort = fork {
          while (!read)
            stepAndAdvance(clko)
          dut.io.en.poke(true.B)
          for (_ <- 0 until numElements) {
            stepAndAdvance(clko)
            dut.io.datao.expect(42.U)
          }
          dut.io.en.poke(false.B)
        }

        // Fill up the queue from the write port
        dut.io.we.poke(true.B)
        for (i <- 0 until numElements) {
          dut.io.datai.poke(42.U)
          stepAndAdvance(clki)
        }
        dut.io.we.poke(false.B)
      
        // Check flags
        dut.io.empty.expect(false.B)
        dut.io.full.expect(true.B)

        // Empty the queue
        read = true
        for (_ <- 0 until numElements)
          stepAndAdvance(clki)
        rPort.join
      
        // Check flags again
        dut.io.empty.expect(true.B)
        dut.io.full.expect(false.B)
    }
  }

  it should "operate with random inputs" in {
    test(new Module {
      val io = IO(new TrueDualPortFIFOIO(log2Up(numElements), dataW))
      val fifo = Module(new TrueDualPortFIFO(log2Up(numElements), dataW))
      io <> fifo.io
    }).withAnnotations(Seq(VerilatorBackendAnnotation, WriteVcdAnnotation)) {
      dut => 
        val rng = new scala.util.Random(42)
        val data = Array.fill(256) { BigInt(dataW, rng) }

        val clki = dut.io.clki
        val clko = dut.io.clko

        def stepAndAdvance(clk: Clock) = {
          clk.low()
          dut.clock.step()
          clk.high()
        }
      
        // Default values
        clki.low()
        dut.io.we.poke(false.B)
        dut.io.datai.poke(0.U)
      
        clko.low()
        dut.io.en.poke(false.B)
      
        // Reset to get the right flags
        dut.io.rst.poke(true.B)
        fork { stepAndAdvance(clko) }
        stepAndAdvance(clki)
        dut.io.rst.poke(false.B)
      
        // Fork a reader
        val rPort = fork {
          for (v <- data) {
            while (dut.io.empty.peek.litToBoolean)
              stepAndAdvance(clko)
            dut.io.en.poke(true.B)
            stepAndAdvance(clko)
            dut.io.datao.expect(v.U)
            println(s"Read ${dut.io.datao.peek.litValue}, expected $v")
            dut.io.en.poke(false.B)
          }
        }
      
        // Write random values to the FIFO at random points in time
        for (v <- data) {
          while (!rng.nextBoolean)
            stepAndAdvance(clki)
          while (dut.io.full.peek.litToBoolean)
            stepAndAdvance(clki)
          dut.io.we.poke(true.B)
          dut.io.datai.poke(v.U)
          stepAndAdvance(clki)
          println(s"Wrote $v")
          dut.io.we.poke(false.B)
        }
        rPort.join
      }
  }
}
