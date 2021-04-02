package neuroproc.systemtests

import neuroproc._

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers
import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.{VerilatorBackendAnnotation, WriteVcdAnnotation}

class OutputCoretoMemTester extends AnyFlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Output core to memory"

  it should "work with FIFO queue" in {
    test(new Module {
      val io = IO(new Bundle {
        val grant = Input(Bool())
        val req   = Output(Bool())
        val tx    = Output(UInt(GLOBALADDRWIDTH.W))
        val rx    = Input(UInt(GLOBALADDRWIDTH.W))

        val clko  = Input(Bool())
        val en    = Input(Bool())
        val datao = Output(UInt(8.W))
        val empty = Output(Bool())
      })

      // Output core
      val oc = Module(new OutputCore(4))
      oc.io.grant := io.grant
      io.req      := oc.io.req
      io.tx       := oc.io.tx
      oc.io.rx    := io.rx
      
      // True dual port memory-based FIFO
      val fifo = Module(TrueDualPortFIFO(16, 8))
      fifo.io.clki := clock.asBool
      fifo.io.clko := io.clko
      fifo.io.en   := io.en
      io.datao     := fifo.io.datao
      io.empty     := fifo.io.empty

      // Interconnect
      fifo.io.we    := oc.io.qWe
      fifo.io.datai := oc.io.qDi
      oc.io.qFull   := fifo.io.full

    }).withAnnotations(Seq(WriteVcdAnnotation, VerilatorBackendAnnotation)) {
      dut =>
        def stepClko(cycles: Int = 1) = {
          for (_ <- 0 until cycles) {
            dut.io.clko.poke(true.B)
            dut.io.clko.poke(false.B)
          }
        }

        // Reset inputs
        dut.io.grant.poke(false.B)
        dut.io.rx.poke(0.U)

        dut.io.clko.poke(false.B)
        dut.io.en.poke(false.B)

        dut.reset.poke(true.B)
        dut.clock.step()
        stepClko()
        dut.reset.poke(false.B)

        dut.io.req.expect(false.B)
        dut.io.tx.expect(0.U)
        
        dut.io.datao.expect(0.U)
        dut.io.empty.expect(true.B) // reset required to achieve correct flag here

        // Input a spike
        dut.io.rx.poke(599.U)
        dut.clock.step() // one cycle to pass interface
        dut.io.rx.poke(0.U)
        dut.clock.step() // ... and one to write to FIFO

        // Read it out - checking flag first
        stepClko() // one cycle to read wAddr into read port
        stepClko() // ... and one to update empty flag
        dut.io.empty.expect(false.B)
        dut.clock.step() // advance time for VCD

        dut.io.en.poke(true.B)
        stepClko()
        dut.io.en.poke(false.B)
        dut.io.datao.expect(87.U)
        dut.io.empty.expect(true.B)

        // Fill up FIFO
        dut.clock.step() // advance time for VCD
        dut.io.rx.poke(599.U)
        for (_ <- 0 until 16) {
          dut.clock.step() // one to pass interface, and subsequently write to FIFO
          stepClko() // TODO: fix this, required to update flags correctly
        }
        dut.io.rx.poke(0.U)
        dut.clock.step() // write last spike to FIFO

        // Empty FIFO
        stepClko(2) // like above
        dut.io.en.poke(true.B)
        dut.io.empty.expect(false.B)
        for (_ <- 0 until 16) {
          dut.clock.step() // advance time for VCD
          stepClko()
          dut.io.datao.expect(87.U)
        }
        dut.io.en.poke(false.B)
        dut.io.empty.expect(true.B)
    }
  }
}
