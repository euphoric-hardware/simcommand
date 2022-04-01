package neuroproc.systemtests

import neuroproc._

import chisel3._
import chiseltest._
import chiseltest.experimental.UncheckedClockPoke._
import chiseltest.experimental.UncheckedClockPeek._
import org.scalatest._

class OutputCoretoMemTester extends FlatSpec with ChiselScalatestTester {
  behavior of "Output core to memory"

  it should "work with FIFO queue" in {
    test(new Module {
      val io = IO(new Bundle {
        val grant = Input(Bool())
        val req   = Output(Bool())
        val tx    = Output(UInt(GLOBALADDRWIDTH.W))
        val rx    = Input(UInt(GLOBALADDRWIDTH.W))

        val clko  = Input(Clock())
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
      val fifo = Module(new TrueDualPortFIFO(4, 8))
      fifo.io.clki := clock
      fifo.io.clko := io.clko
      fifo.io.rst  := reset.asBool
      fifo.io.en   := io.en
      io.datao     := fifo.io.datao
      io.empty     := fifo.io.empty

      // Interconnect
      fifo.io.we    := oc.io.qWe
      fifo.io.datai := oc.io.qDi
      oc.io.qFull   := fifo.io.full

    }).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        def stepClko(cycles: Int = 1) = {
          for (_ <- 0 until cycles) {
            dut.io.clko.high()
            dut.io.clko.low()
          }
        }

        // Reset inputs
        dut.io.grant.poke(false.B)
        dut.io.rx.poke(0.U)

        dut.io.clko.low()
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
        dut.io.en.poke(true.B)
        stepClko()
        dut.io.datao.expect(87.U)
        dut.io.empty.expect(false.B)
        dut.clock.step() // advance time for VCD
        dut.io.en.poke(false.B)

        // Fill up FIFO
        dut.clock.step() // advance time for VCD
        dut.io.rx.poke(599.U)
        for (_ <- 0 until 16) {
          dut.clock.step() // one to pass interface, and subsequently write to FIFO
        }
        dut.io.rx.poke(0.U)
        dut.clock.step() // write last spike to FIFO

        // Empty FIFO
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
