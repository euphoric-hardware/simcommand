package neuroproc

import chisel3._
import chisel3.util._

class TrueDualPortFIFOIO(val addrW: Int, val dataW: Int) extends Bundle {
  require(addrW > 0, "address width must be greater than 0")
  require(dataW > 0, "data width must be greater than 0")

  // clki and clko must be of type Bool to work correctly in ChiselTest
  val clki  = Input(Clock())
  val we    = Input(Bool())
  val datai = Input(UInt(dataW.W))
  val full  = Output(Bool())

  val clko  = Input(Clock())
  val en    = Input(Bool())
  val datao = Output(UInt(dataW.W))
  val empty = Output(Bool())

  val rst = Input(Bool())
}

class TrueDualPortFIFO(addrW: Int, dataW: Int) extends RawModule {
  val io = IO(new TrueDualPortFIFOIO(addrW, dataW))

  private[TrueDualPortFIFO] def grayIncrement(c: UInt, n: Int) = {
    val b1 = Wire(UInt(n.W))
    val bVec = VecInit((0 until n).map( i => c(n-1, i).xorR() ).toSeq) // Gray to Binary
    b1 := bVec.asUInt + 1.U                                            // Binary increment
    b1 ^ (0.U(1.W) ## b1(n-1, 1))                                      // Binary to Gray
  }

  private[TrueDualPortFIFO] class WriteControl(addrW: Int) extends RawModule {
    val io = IO(new Bundle {
      val clkw   = Input(Clock())
      val resetw = Input(Bool())
      val wr     = Input(Bool())
      val rPtr   = Input(UInt((addrW+1).W))
      val full   = Output(Bool())
      val wPtr   = Output(UInt((addrW+1).W))
      val wAddr  = Output(UInt(addrW.W))
    })

    withClockAndReset(io.clkw, io.resetw.asAsyncReset) {
      // Internal signals
      val wPtrNext = Wire(UInt((addrW+1).W))
      val gray1 = Wire(UInt((addrW+1).W))
      val wAddr = Wire(UInt(addrW.W))
      val wAddrMsb = Wire(Bool())
      val rAddrMsb = Wire(Bool())
      val fullFlag = Wire(Bool())

      // Write pointer register
      val wPtr = RegNext(wPtrNext, 0.U)
      
      // (N+1)-bit Gray counter
      gray1 := grayIncrement(wPtr, addrW+1)

      // Update write pointer
      wPtrNext := Mux(io.wr && !fullFlag, gray1, wPtr)

      // N-bit Gray counter
      wAddrMsb := wPtr(addrW) ^ wPtr(addrW-1)
      wAddr    := wAddrMsb ## wPtr(addrW-2, 0)

      // Full flag generation
      rAddrMsb := io.rPtr(addrW) ^ io.rPtr(addrW-1)
      fullFlag := (io.rPtr(addrW) =/= wPtr(addrW)) && (io.rPtr(addrW-2, 0) === wPtr(addrW-2, 0)) && (rAddrMsb === wAddrMsb)

      // Output
      io.wAddr := wAddr
      io.wPtr  := wPtr
      io.full  := fullFlag
    }
  }

  private[TrueDualPortFIFO] class ReadControl(addrW: Int) extends RawModule {
    val io = IO(new Bundle {
      val clkr   = Input(Clock())
      val resetr = Input(Bool())
      val rd     = Input(Bool())
      val wPtr   = Input(UInt((addrW+1).W))
      val empty  = Output(Bool())
      val rPtr   = Output(UInt((addrW+1).W))
      val rAddr  = Output(UInt(addrW.W))
    })

    withClockAndReset(io.clkr, io.resetr.asAsyncReset) {
      // Internal signals
      val rPtrNext = Wire(UInt((addrW+1).W))
      val gray1 = Wire(UInt((addrW+1).W))
      val rAddr = Wire(UInt(addrW.W))
      val rAddrMsb  = Wire(Bool())
      val wAddrMsb  = Wire(Bool())
      val emptyFlag = Wire(Bool())

      // Read pointer register
      val rPtr = RegNext(rPtrNext, 0.U)

      // (N+1)-bit Gray counter
      gray1 := grayIncrement(rPtr, addrW+1)

      // Update read pointer
      rPtrNext := Mux(io.rd && !emptyFlag, gray1, rPtr)

      // N-bit Gray counter
      rAddrMsb := rPtr(addrW) ^ rPtr(addrW-1)
      rAddr    := rAddrMsb ## rPtr(addrW-2, 0)

      // Empty flag generation
      wAddrMsb  := io.wPtr(addrW) ^ io.wPtr(addrW-1)
      emptyFlag := (io.wPtr(addrW) === rPtr(addrW)) && (io.wPtr(addrW-2, 0) === rPtr(addrW-2, 0)) && (wAddrMsb === rAddrMsb)

      // Output
      io.rAddr := rAddr
      io.rPtr  := rPtr
      io.empty := emptyFlag
    }
  }

  // Instantiating and interconnecting components
  val ram   = Module(new TrueDualPortMemory(addrW, dataW))
  val wctrl = Module(new WriteControl(addrW))
  val rctrl = Module(new ReadControl(addrW))
  val wAddr = Wire(UInt(addrW.W))
  val wPtr  = Wire(UInt((addrW+1).W))
  val rAddr = Wire(UInt(addrW.W))
  val rPtr  = Wire(UInt((addrW+1).W))

  // Write side (port A)
  ram.io.clka  := io.clki
  ram.io.addra := wAddr
  ram.io.dia   := io.datai
  ram.io.ena   := io.we && !wctrl.io.full
  ram.io.wea   := io.we && !wctrl.io.full

  wctrl.io.clkw := io.clki
  wctrl.io.resetw := io.rst
  wctrl.io.wr := io.we
  wctrl.io.rPtr := rPtr
  io.full := wctrl.io.full
  wPtr := wctrl.io.wPtr
  wAddr := wctrl.io.wAddr

  // Read side (port B)
  ram.io.clkb  := io.clko
  ram.io.addrb := rAddr
  ram.io.dib   := 0.U
  ram.io.enb   := io.en && !rctrl.io.empty
  ram.io.web   := false.B
  io.datao     := ram.io.dob

  rctrl.io.clkr := io.clko
  rctrl.io.resetr := io.rst
  rctrl.io.rd := io.en
  rctrl.io.wPtr := wPtr
  io.empty := rctrl.io.empty
  rPtr := rctrl.io.rPtr
  rAddr := rctrl.io.rAddr
}
