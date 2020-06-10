import chisel3._
import chisel3.util._
import Constants._

// The output core is for now hardcoded to deal with the specific showcase network
class OutputCore(coreID : Int) extends Module{
  val io = IO(new Bundle{
    // to off chip communication
    val offCCData  = Output(UInt(8.W))
    val offCCValid = Output(Bool())
    val offCCReady = Input(Bool())

    //to bus 
    val grant = Input(Bool())
    val req   = Output(Bool())
    val tx    = Output(UInt(GLOBALADDRWIDTH.W))
    val rx    = Input(UInt(GLOBALADDRWIDTH.W))
  })

  //valid ready for OCC
  val offCCData  = RegInit(0.U(8.W))
  val offCCValid = RegInit(false.B)

  //interface to/from bus
  val interface  = Module(new BusInterface(coreID))

  // Queue memory
  val queMem  = SyncReadMem(16, UInt(8.W))
  val addr      = Wire(UInt(4.W))
  val wr        = Wire(Bool()) //false: read, true: write
  val ena       = Wire(Bool())
  val readData  = Wire(UInt(8.W))
  val writeData = Wire(UInt(8.W))

  val readComing = RegInit(false.B)


  val rAddr = RegInit(0.U(4.W))
  val wAddr = RegInit(0.U(4.W))
  val items = RegInit(0.U(4.W))

  // default assignments
  ena := false.B
  wr := false.B
  addr := rAddr
  writeData := interface.io.axonID(7,0)
  readData := DontCare

  readComing := false.B

  //interface default
  interface.io.grant      := io.grant
  io.req                  := interface.io.reqOut
  io.tx                   := interface.io.tx
  interface.io.rx         := io.rx
  interface.io.reqIn      := false.B //Never sends anything
  interface.io.spikeID    := 0.U //Never sends anything

  io.offCCValid := offCCValid
  io.offCCData  := offCCData

  when(ena) {
    val rdwrPort = queMem(addr)
    when(wr) {
      rdwrPort := writeData
    }.otherwise {
      readData := rdwrPort
    }
  }


  when(offCCValid && io.offCCReady){
    offCCValid := false.B
  }

  when (interface.io.valid){
    when(items < 16.U){
      ena := true.B
      wr := true.B
      addr := wAddr
      wAddr := wAddr + 1.U
      items := items + 1.U
    }
  }.elsewhen(!offCCValid && !readComing && items > 0.U){
    ena := true.B
    wr := false.B
    addr := rAddr
    rAddr := rAddr + 1.U
    items := items - 1.U
    readComing := true.B
    //offCCValid := true.B
    //offCCData := readData
  }

  when(readComing){
    offCCValid := true.B
    offCCData := readData
  }
}

object OutputCore extends App {
  chisel3.Driver.execute(Array("--target-dir", "build"), () => new OutputCore(6))
}