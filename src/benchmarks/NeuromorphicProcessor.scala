package benchmarks

import chisel3._
import chisel3.util.HasBlackBoxResource

class NeuromorphicProcessorBBWrapper extends Module {
  val io = IO(new Bundle {
    val io_uartTx = Output(Bool())
    val io_uartRx = Input(Bool())
  })
  val bb = Module(new NeuromorphicProcessor())
  bb.io.clock := clock
  bb.io.reset := reset
  io.io_uartTx := bb.io.io_uartTx
  bb.io.io_uartRx := io.io_uartRx
}

class NeuromorphicProcessor extends BlackBox with HasBlackBoxResource {
  val io = IO(new Bundle {
    val clock = Input(Clock())
    val reset = Input(Bool())
    val io_uartTx = Output(Bool())
    val io_uartRx = Input(Bool())
  })
  addResource("NeuromorphicProcessor/NeuromorphicProcessor.sv")
  addResource("NeuromorphicProcessor/ClockBufferBB.v")
}
