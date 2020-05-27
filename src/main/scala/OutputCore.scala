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

  //interface to/from bus
  val interface  = Module(new BusInterface(coreID))
  interface.io.grant      := io.grant
  io.req                  := interface.io.reqOut
  io.tx                   := interface.io.tx
  interface.io.rx         := io.rx
  interface.io.reqIn      := false.B //Never sends anything
  interface.io.spikeID    := 0.U //Never sends anything

  //deal with
  val offCCData  = RegInit(0.U(8.W))
  val offCCValid = RegInit(false.B)
  
  io.offCCValid := offCCValid
  io.offCCData  := offCCData

  when(offCCValid && io.offCCReady){
    offCCValid := false.B
  }

  when (interface.io.valid){
    offCCValid := true.B
    offCCData := interface.io.axonID(7,0)
  }.elsewhen(offCCValid && io.offCCReady){
    offCCValid := false.B
  }
}

object OutputCore extends App {
  chisel3.Driver.execute(Array("--target-dir", "build"), () => new OutputCore(6))
}