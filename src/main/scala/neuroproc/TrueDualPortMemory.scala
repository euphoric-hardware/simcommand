// Inspired by HDL templates from Xilinx UG901
package neuroproc

import chisel3._
import chisel3.util._

class TrueDualPortMemoryIO(val addrW: Int, val dataW: Int) extends Bundle {
  require(addrW > 0, "address width must be greater than 0")
  require(dataW > 0, "data width must be greater than 0")

  // clka and clkb must be of type Bool to work correctly in ChiselTest
  val clka  = Input(Bool())
  val ena   = Input(Bool())
  val wea   = Input(Bool())
  val addra = Input(UInt(addrW.W))
  val dia   = Input(UInt(dataW.W))
  val doa   = Output(UInt(dataW.W))

  val clkb  = Input(Bool())
  val enb   = Input(Bool())
  val web   = Input(Bool())
  val addrb = Input(UInt(addrW.W))
  val dib   = Input(UInt(dataW.W))
  val dob   = Output(UInt(dataW.W))
}

abstract class TrueDualPortMemory(addrW: Int, dataW: Int) extends Module {
  val io = IO(new TrueDualPortMemoryIO(addrW, dataW))
}

class TrueDualPortMemoryBB(addrW: Int, dataW: Int) extends BlackBox with HasBlackBoxInline {
  val io_ = IO(new TrueDualPortMemoryIO(addrW, dataW)).suggestName("io") // chisel3 3.5-SNAPSHOT bug
  setInline("TrueDualPortMemoryBB.v",
  s"""
  |module TrueDualPortMemoryBB(clka, ena, wea, addra, dia, doa,
  |                            clkb, enb, web, addrb, dib, dob);
  |input clka, ena, wea, clkb, enb, web;
  |input  [${addrW-1}:0] addra, addrb;
  |input  [${dataW-1}:0] dia, dib;
  |output [${dataW-1}:0] doa, dob;
  |reg    [${dataW-1}:0] ram [${((1 << addrW) - 1)}:0];
  |reg    [${dataW-1}:0] doa, dob;
  |
  |// Port a
  |always @(posedge clka)
  |begin
  |  if (ena)
  |  begin
  |    if (wea)
  |      ram[addra] <= dia;
  |    doa <= ram[addra];
  |  end
  |end
  |
  |// Port b
  |always @(posedge clkb)
  |begin
  |  if (enb)
  |  begin
  |    if (web)
  |      ram[addrb] <= dib;
  |    dob <= ram[addrb];
  |  end
  |end
  |
  |endmodule
  """.stripMargin)
}

class TrueDualPortMemoryVerilog(addrW: Int, dataW: Int) extends TrueDualPortMemory(addrW, dataW) {
  val mem = Module(new TrueDualPortMemoryBB(addrW, dataW))
  io <> mem.io_
}

class TrueDualPortMemoryChisel(addrW: Int, dataW: Int) extends TrueDualPortMemory(addrW, dataW) {
  val ram = SyncReadMem(1 << addrW, UInt(dataW.W))

  // Port a
  withClock(io.clka.asClock) {
    io.doa := DontCare
    when(io.ena) {
      when(io.wea) {
        ram(io.addra) := io.dia
      }
      io.doa := ram(io.addra)
    }
  }

  // Port b
  withClock(io.clkb.asClock) {
    io.dob := DontCare
    when(io.enb) {
      when(io.web) {
        ram(io.addrb) := io.dib
      }
      io.dob := ram(io.addrb)
    }
  }
}

object TrueDualPortMemory {
  def apply(addrW: Int, dataW: Int, synth: Boolean = false) = {
    if (synth)
      new TrueDualPortMemoryVerilog(addrW, dataW)
    else
      new TrueDualPortMemoryChisel(addrW, dataW)
  }
}
