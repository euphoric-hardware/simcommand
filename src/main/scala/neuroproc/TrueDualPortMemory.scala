// Inspired by HDL templates from Xilinx UG901
package neuroproc

import chisel3._
import chisel3.util._

class TrueDualPortMemoryIO(val addrW: Int, val dataW: Int) extends Bundle {
  require(addrW > 0, "address width must be greater than 0")
  require(dataW > 0, "data width must be greater than 0")

  val clka  = Input(Clock())
  val ena   = Input(Bool())
  val wea   = Input(Bool())
  val addra = Input(UInt(addrW.W))
  val dia   = Input(UInt(dataW.W))
  val doa   = Output(UInt(dataW.W))

  val clkb  = Input(Clock())
  val enb   = Input(Bool())
  val web   = Input(Bool())
  val addrb = Input(UInt(addrW.W))
  val dib   = Input(UInt(dataW.W))
  val dob   = Output(UInt(dataW.W))
}

class TrueDualPortMemory(addrW: Int, dataW: Int) extends RawModule {
  val io = IO(new TrueDualPortMemoryIO(addrW, dataW))
  val ram = SyncReadMem(1 << addrW, UInt(dataW.W))

  // Port a
  withClock(io.clka) {
    io.doa := DontCare
    when(io.ena) {
      when(io.wea) {
        ram(io.addra) := io.dia
      }
      io.doa := ram(io.addra)
    }
  }

  // Port b
  withClock(io.clkb) {
    io.dob := DontCare
    when(io.enb) {
      when(io.web) {
        ram(io.addrb) := io.dib
      }
      io.dob := ram(io.addrb)
    }
  }
}
