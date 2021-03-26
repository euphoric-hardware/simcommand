package neuroproc

import chisel3._
import chisel3.util._

// The output core is for now hardcoded to deal with the specific showcase network
class OutputCore(coreID: Int) extends Module {
  val io = IO(new Bundle {
    val pmClkEn = Output(Bool())

    // To FIFO queue
    val qWe   = Output(Bool())
    val qDi   = Output(UInt(8.W))
    val qFull = Input(Bool())

    // To bus
    val grant = Input(Bool())
    val req   = Output(Bool())
    val tx    = Output(UInt(GLOBALADDRWIDTH.W))
    val rx    = Input(UInt(GLOBALADDRWIDTH.W))
  })

  // Bus interface and default values
  val interface = Module(new BusInterface(coreID))
  interface.io.grant   := io.grant
  io.req               := interface.io.reqOut
  io.tx                := interface.io.tx
  interface.io.rx      := io.rx
  interface.io.reqIn   := false.B // Never sends anything
  interface.io.spikeID := 0.U // Never sends anything

  // When a valid value is received, write it to the queue (if not full)
  io.qWe := interface.io.valid && !io.qFull
  io.qDi := interface.io.axonID(7, 0)

  // Clock gating output
  io.pmClkEn := io.rx.orR || interface.io.valid
}

object OutputCore extends App {
  (new chisel3.stage.ChiselStage).emitVerilog(new OutputCore(4), Array("--target-dir", "build"))
}
