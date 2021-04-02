package neuroproc

import chisel3._
import chisel3.util._

class TrueDualPortFIFOIO(val addrW: Int, val dataW: Int) extends Bundle {
  require(addrW > 0, "address width must be greater than 0")
  require(dataW > 0, "data width must be greater than 0")

  // clki and clko must be of type Bool to work correctly in ChiselTest
  val clki  = Input(Bool())
  val we    = Input(Bool())
  val datai = Input(UInt(dataW.W))
  val full  = Output(Bool())

  val clko  = Input(Bool())
  val en    = Input(Bool())
  val datao = Output(UInt(dataW.W))
  val empty = Output(Bool())
}

abstract class TrueDualPortFIFO(addrW: Int, dataW: Int) extends Module {
  val io = IO(new TrueDualPortFIFOIO(addrW, dataW))
}

class TrueDualPortFIFOBB(addrW: Int, dataW: Int) extends BlackBox with HasBlackBoxInline {
  val io_ = IO(new TrueDualPortFIFOIO(addrW, dataW)).suggestName("io") // chisel3 3.5-SNAPSHOT bug
  val numElements = ((1 << addrW) - 1)
  setInline("TrueDualPortFIFOBB.v",
  s"""
  |module TrueDualPortFIFOBB(clki, we, datai, full,
  |                          clko, en, datao, empty,
  |                          reset);
  |input clki, we, clko, en, reset;
  |input  [${dataW-1}:0] datai;
  |output full, empty;
  |output reg [${dataW-1}:0] datao;
  |reg    [${dataW-1}:0] ram [${((1 << addrW) - 1)}:0];
  |wire   [${addrW-1}:0] wAddrNext, rAddrNext;
  |reg    [${addrW-1}:0] wAddr, rAddr;
  |reg emptyReg, fullReg;
  |initial emptyReg = 1'b1;
  |initial fullReg  = 1'b0;
  |
  |// Combinational logic
  |assign wAddrNext = wAddr == ${numElements} ? ${addrW}'b${"0"*addrW} : wAddr + 1;
  |assign rAddrNext = rAddr == ${numElements} ? ${addrW}'b${"0"*addrW} : rAddr + 1;
  |
  |assign full  = fullReg;
  |assign empty = emptyReg;
  |
  |// Write port
  |always @(posedge clki)
  |begin
  |  if (reset)
  |  begin
  |    fullReg <= 1'b0;
  |    wAddr   <= ${addrW}'b${"0"*addrW};
  |  end else begin
  |    if (we)
  |    begin
  |      ram[wAddr] <= datai;
  |      wAddr <= wAddrNext;
  |    end
  |
  |    if (we && wAddrNext == rAddr)
  |      fullReg <= 1'b1;
  |    else if (fullReg && wAddr != rAddr)
  |      fullReg <= 1'b0;
  |  end
  |end
  |
  |// Read port
  |always @(posedge clko)
  |begin
  |  if (reset)
  |  begin
  |    emptyReg <= 1'b1;
  |    rAddr    <= ${addrW}'b${"0"*addrW};
  |  end else begin
  |    if (en)
  |    begin
  |      datao <= ram[rAddr];
  |      rAddr <= rAddrNext;
  |    end
  |      
  |    if (emptyReg && rAddr != wAddr)
  |      emptyReg <= 1'b0;
  |    else if (en && rAddrNext == wAddr)
  |      emptyReg <= 1'b1;
  |  end
  |end
  |
  |endmodule
  """.stripMargin)
}

class TrueDualPortFIFOVerilog(addrW: Int, dataW: Int) extends TrueDualPortFIFO(addrW, dataW) {
  val fifo = Module(new TrueDualPortFIFOBB(addrW, dataW))
  io <> fifo.io_
}

class TrueDualPortFIFOChisel(addrW: Int, dataW: Int) extends TrueDualPortFIFO(addrW, dataW) {
  val numElements = ((1 << addrW) - 1)

  // The queue is implemented as a true dual port RAM
  val ram = Module(TrueDualPortMemory(addrW, dataW))
  val wAddr = Wire(UInt(addrW.W))
  val rAddr = Wire(UInt(addrW.W))
  ram.io.clka  := io.clki
  ram.io.ena   := io.we
  ram.io.wea   := io.we
  ram.io.addra := wAddr
  ram.io.dia   := io.datai

  ram.io.clkb  := io.clko
  ram.io.enb   := io.en
  ram.io.web   := false.B
  ram.io.addrb := rAddr
  ram.io.dib   := 0.U
  io.datao     := ram.io.dob

  // Write port
  withClock(io.clki.asClock) {
    // Write address counter
    val cntNext = Wire(UInt(addrW.W))
    val cntReg  = RegEnable(cntNext, 0.U, io.we)
    when(cntReg === numElements.U) {
      cntNext := 0.U
    }.otherwise {
      cntNext := cntReg + 1.U
    }
    wAddr := cntReg

    // Generate full signal
    val full = RegInit(false.B)
    when(io.we && cntNext === rAddr) {
      full := true.B
    }.elsewhen(full && cntReg =/= rAddr) {
      full := false.B
    }
    io.full := full
  }

  // Read port
  withClock(io.clko.asClock) {
    // Read address counter
    val cntNext = Wire(UInt(addrW.W))
    val cntReg  = RegEnable(cntNext, 0.U, io.en)
    when(cntReg === numElements.U) {
      cntNext := 0.U
    }.otherwise {
      cntNext := cntReg + 1.U
    }
    rAddr := cntReg

    // Generate empty signal
    val empty = RegInit(true.B)
    when(empty && cntReg =/= wAddr) {
      empty := false.B
    }.elsewhen(io.en && cntNext === wAddr) {
      empty := true.B
    }
    io.empty := empty
  }
}

object TrueDualPortFIFO {
  def apply(numElements: Int, dataW: Int, synth: Boolean = false) = {
    require(isPow2(numElements), "number of elements must be a power of 2")
    val addrW = log2Up(numElements)
    if (synth)
      new TrueDualPortFIFOVerilog(addrW, dataW)
    else
      new TrueDualPortFIFOChisel(addrW, dataW)
  }
}
