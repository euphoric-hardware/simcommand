package neuroproc

import chisel3._
import chisel3.util._

class BusInterface(coreId: Int) extends Module {
  val io = IO(new Bundle {
    // For bus
    val grant   = Input(Bool())
    val reqOut  = Output(Bool())
    val tx      = Output(UInt(GLOBALADDRWIDTH.W))
    val rx      = Input(UInt(GLOBALADDRWIDTH.W))

    // For axon system valid/ready
    val axonID  = Output(UInt(AXONIDWIDTH.W))
    val valid   = Output(Bool())

    // For spike transmission valid/ready
    val spikeID = Input(UInt(GLOBALADDRWIDTH.W))
    val ready   = Output(Bool())
    val reqIn   = Input(Bool())
  })

  // Create ROM from mapping file
  val lutReader = new InterfaceReader
  val romContent = lutReader.getFilter(coreId)
  val romContChi = romContent.map(i => i.asUInt((AXONMSBWIDTH + 1).W))
  val filterROM  = VecInit(romContChi)

  // Output tx spike ID or zero
  io.tx := Mux(io.grant, io.spikeID, 0.U)
  io.reqOut := io.reqIn && ~io.grant
  io.ready  := io.grant

  // Output subscription info and axon ID
  val axonIDLSBReg = RegInit(0.U((AXONIDWIDTH - AXONMSBWIDTH).W))
  axonIDLSBReg := io.rx(AXONIDWIDTH - AXONMSBWIDTH - 1, 0)

  val synROMReg  = RegInit(0.U((AXONMSBWIDTH + 1).W))
  synROMReg := Mux(io.rx.orR, filterROM(io.rx(GLOBALADDRWIDTH - 1, GLOBALADDRWIDTH - log2Up(CORES))), 0.U)

  io.valid  := synROMReg(AXONMSBWIDTH)
  io.axonID := synROMReg(AXONMSBWIDTH - 1, 0) ## axonIDLSBReg
}
