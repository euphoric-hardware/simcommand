package neuroproc

import chisel3._
import chisel3.util._

class ClockBufferIO extends Bundle {
  val i  = Input(Clock())
  val ce = Input(Bool())
  val o  = Output(Clock())
}

abstract class ClockBuffer extends Module {
  val io = IO(new ClockBufferIO)
}

// For now, this Xilinx primitive is used. In practice, this should be
// implemented much more involved along the lines of `ClockBufferBB`, as
// seen in "How to Successfully Use Gated Clocking in an ASIC Design" by
// Darren Jones of MIPS Technologies.
class BUFGCE extends BlackBox {
  val io = IO(new ClockBufferIO)
}

class ClockBufferFPGA extends ClockBuffer {
  val bg = Module(new BUFGCE)
  io <> bg.io
}

class ClockBufferBB() extends BlackBox with HasBlackBoxInline {
  val io = IO(new ClockBufferIO)
  setInline("ClockBufferBB.v",
  s"""
  |module ClockBufferBB(i, ce, o);
  |input  i, ce;
  |output o;
  |reg gate;
  |
  |always @(i or ce)
  |begin
  |  if (~i)
  |    gate <= ce; 
  |end
  |
  |assign o = gate & i;
  |
  |endmodule
  """.stripMargin)
}

class ClockBufferVerilog extends ClockBuffer {
  val bb = Module(new ClockBufferBB)
  io <> bb.io
}

object ClockBuffer {
  def apply(synth: Boolean = false) = {
    if (synth)
      new ClockBufferFPGA
    else
      new ClockBufferVerilog
  }
}
