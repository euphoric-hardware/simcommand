package neuroproc

import chisel3._
import chisel3.util._
import chisel3.util.experimental.loadMemoryFromFile

class EvaluationMemory2(val coreID: Int, val evalID: Int) extends Module {
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

object OneMem extends App {
  chisel3.Driver.execute(Array("--target-dir", "build/"), () => new EvaluationMemory2(2,0))
}

@deprecated("this memory should not be used")
class EvaluationMemory(coreID: Int, evalID: Int) extends Module {
  val io = IO(new Bundle {
    val addr      = Input(UInt(EVALMEMADDRWIDTH.W))
    val wr        = Input(Bool()) //false: read, true: write
    val ena       = Input(Bool())
    val readData  = Output(SInt(NEUDATAWIDTH.W))
    val writeData = Input(SInt(NEUDATAWIDTH.W))
  })

  val refracPotMem     = SyncReadMem(2 * TMNEURONS, SInt(NEUDATAWIDTH.W))
  val memRead          = Wire(SInt(NEUDATAWIDTH.W))
  val syncOut          = RegInit(false.B)

  
  //Hardcoded mapping for showcase network
  val pROM = Module(new PROM(coreID, evalID))
  //val romRead = RegInit(0.S(NEUDATAWIDTH.W))
  val romRead = Wire(SInt(NEUDATAWIDTH.W))
  val romEna = Wire(Bool())


  //default assignment 
  memRead := DontCare
  syncOut := false.B
  romEna := false.B

  pROM.io.ena := romEna
  pROM.io.addr := io.addr
  romRead := pROM.io.data
  when(io.ena) {
    when(io.addr < (2 * TMNEURONS).U) {
      val rdwrPort = refracPotMem(io.addr)
      when(io.wr) {
        rdwrPort := io.writeData
      }.otherwise {
        syncOut := true.B
        memRead := rdwrPort
      }
    }.otherwise{
      romEna := true.B
    }
  }

  io.readData := romRead
  when(syncOut) {
    io.readData := memRead
  }
}
