package neuroproc

import chisel3._
import chisel3.util._

// The output core is for now hardcoded to deal with the specific showcase network
class OutputCore(coreID : Int) extends Module {
  val io = IO(new Bundle{
    // To off chip communication
    val offCCData  = Output(UInt(8.W))
    val offCCValid = Output(Bool())
    val offCCReady = Input(Bool())

    // To bus 
    val grant = Input(Bool())
    val req   = Output(Bool())
    val tx    = Output(UInt(GLOBALADDRWIDTH.W))
    val rx    = Input(UInt(GLOBALADDRWIDTH.W))
  })

  // Valid/ready for off chip communication
  val offCCData  = RegInit(0.U(8.W))
  val offCCValid = RegInit(false.B)

  // Bus interface
  val interface  = Module(new BusInterface(coreID))

  // Queue memory - a circular FIFO
  val queMem    = SyncReadMem(16, UInt(8.W))
  val addr      = Wire(UInt(4.W))
  val wr        = Wire(Bool()) //false: read, true: write
  val ena       = Wire(Bool())
  val readData  = Wire(UInt(8.W))
  val writeData = Wire(UInt(8.W))

  val readComing = RegInit(false.B)

  val rAddr = RegInit(0.U(4.W))
  val wAddr = RegInit(0.U(4.W))
  val items = RegInit(0.U(4.W))

  // Default assignments
  ena := false.B
  wr := false.B
  addr := rAddr
  writeData := interface.io.axonID(7,0)
  readData := DontCare

  readComing := false.B

  // Interface default
  interface.io.grant      := io.grant
  io.req                  := interface.io.reqOut
  io.tx                   := interface.io.tx
  interface.io.rx         := io.rx
  interface.io.reqIn      := false.B // Never sends anything
  interface.io.spikeID    := 0.U // Never sends anything

  io.offCCValid := offCCValid
  io.offCCData  := offCCData

  // Control synchronous FIFO
  when(ena) {
    when(wr) {
      queMem(addr) := writeData
    }.otherwise {
      readData := queMem(addr)
    }
  }

  // Update valid signal on handshake
  when(offCCValid && io.offCCReady){
    offCCValid := false.B
  }

  when (interface.io.valid) {
    // When a spike is being signaled, add it to the FIFO if there is room
    when(items < 16.U){
      ena := true.B
      wr := true.B
      addr := wAddr
      wAddr := wAddr + 1.U
      items := items + 1.U
    }
  }.elsewhen(!offCCValid && !readComing && items > 0.U) {
    // When the off chip communication is ready, and there is a spike available;
    // transfer it out of the output core
    ena := true.B
    wr := false.B
    addr := rAddr
    rAddr := rAddr + 1.U
    items := items - 1.U
    readComing := true.B
  }

  // Output correct data from the FIFO
  when(readComing) {
    offCCValid := true.B
    offCCData := readData
  }
}

object OutputCore extends App {
  chisel3.Driver.execute(Array("--target-dir", "build"), () => new OutputCore(6))
}
