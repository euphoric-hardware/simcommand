package neuroproc

import chisel3._
import chisel3.util._

class ClockBufferIO extends Bundle {
  val i  = Input(Clock())
  val ce = Input(Bool())
  val o  = Output(Clock())
}

class ClockBufferSim extends Module {
  val io = IO(new ClockBufferIO)
  io.o := Mux(io.ce, io.i, false.B.asClock())
}

class ClockBufferSynth extends BlackBox with HasBlackBoxInline {
  val io = IO(new ClockBufferIO)
  setInline("ClockBufferSynth.v",
  s"""
    |module ClockBufferSynth (
    |  input i,
    |  input ce,
    |  output o
    |);
    |
    |BUFGCE buf_inst (
    |  .O(o),
    |  .CE(ce),
    |  .I(i) 
    |);
  """.stripMargin)
}

object ClockBuffer {
  def apply(synth: Boolean = false) {
    if (synth)
      Module(new ClockBufferSynth)
    else
      Module(new ClockBufferSim)
  }
}
