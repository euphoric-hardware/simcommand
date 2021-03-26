package neuroproc

import chisel3._
import chisel3.util._
import chisel3.util.experimental.loadMemoryFromFile

class EvaluationMemory(val coreID: Int, val evalID: Int) extends Module {
  val io = IO(new Bundle {
    val addr      = Input(UInt(EVALMEMADDRWIDTH.W))
    val wr        = Input(Bool()) //false: read, true: write
    val ena       = Input(Bool())
    val readData  = Output(SInt(NEUDATAWIDTH.W))
    val writeData = Input(SInt(NEUDATAWIDTH.W))
    val nothing   = Output(UInt())
  })

  val eMem             = SyncReadMem(EVALMEMSIZE, SInt(NEUDATAWIDTH.W))
  eMem.suggestName("eMem"+coreID.toString+"e"+ evalID.toString)
  val memRead          = Wire(SInt(NEUDATAWIDTH.W))

  // Hardcoded mapping for showcase network - simulation only!
  loadMemoryFromFile(eMem, "mapping/evaldatac"+coreID.toString+"e"+ evalID.toString+".mem")

  // Default assignment
  memRead := DontCare

  // Unique unused output to make sure this module is made in multiple copies
  io.nothing := coreID.U ## evalID.U

  // Control synchronous memory
  when(io.ena) {
    when(io.wr) {
      eMem(io.addr) := io.writeData
    }.otherwise {
      memRead := eMem(io.addr)
    }
  }
  io.readData := memRead
}
