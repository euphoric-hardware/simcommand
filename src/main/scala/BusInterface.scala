import chisel3._
import Constants._
import util._
class BusInterface(coreId : Int) extends Module{
  val io = IO(new Bundle{
    val grant   = Input(Bool())
    val reqOut  = Output(Bool())
    val tx      = Output(UInt((log2Up(CORES)+log2Up(EVALUNITS)+N).W))
    val rx      = Input(UInt((log2Up(CORES)+log2Up(EVALUNITS)+N).W))
    
    val spikeID = Input(UInt((log2Up(CORES)+log2Up(EVALUNITS)+N).W))
    val axonID  = Output(UInt(AXONIDWIDTH.W))
    val valid   = Output(Bool())
    val ack     = Output(Bool())
    val reqIn   = Input(Bool())
  })

  io.tx := 0.U
  when(io.grant){
    io.tx := io.spikeID 
  }

  io.reqOut := io.reqIn && io.grant

  //TODO this is a temporary ROM do a function for mapping actual network 
  val romContent = (0 until CORES).map(i=>if (i % log2Up(CORES) == 0) (1 <<  log2Up(CORES)) | i else i)
  val romContChi = romContent.map(i => i.asUInt((log2Up(CORES)+1).W))
  val synROMReg  = RegInit(0.U((log2Up(CORES)+1).W))
  val filterROM  = VecInit(romContChi)
  //TODO this is a temporary ROM do a function for mapping actual network 
  
  val enaROM     = Wire(Bool())
  val axonIDLSB  = RegInit(0.U((AXONIDWIDTH - log2Up(CORES)).W))

  enaROM := io.rx.andR //and reduction
  axonIDLSB := io.rx(AXONIDWIDTH - log2Up(CORES) - 1, 0)

  synROMReg := 0.U //default assigment to dataport
  when(enaROM){
    synROMReg := filterROM(io.rx(AXONIDWIDTH-1, AXONIDWIDTH - log2Up(CORES)))
  }

  io.valid := synROMReg(log2Up(CORES))
  io.axonID := synROMReg(log2Up(CORES)-1, 0) ## axonIDLSB
}