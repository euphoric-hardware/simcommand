package neuroproc

import chisel3._

class AxonSystem extends Module {
  val io = IO(new Bundle {
    // Communication Fabric interface
    val axonIn    = Input(UInt(AXONIDWIDTH.W))
    val axonValid = Input(Bool())

    // Neurons Controller interface
    val inOut    = Input(Bool())
    val spikeCnt = Output(UInt(AXONIDWIDTH.W))

    val rAddr = Input(UInt(AXONIDWIDTH.W))
    val rEna  = Input(Bool())
    val rData = Output(UInt(AXONIDWIDTH.W))
  })

  // Counter logic
  val inOutReg = RegNext(io.inOut)
  val spikeCntReg = RegInit(0.U(AXONIDWIDTH.W))
  when(inOutReg =/= io.inOut) { // new time step
    spikeCntReg := 0.U
  }.elsewhen(io.axonValid) {
    spikeCntReg := spikeCntReg + 1.U
  }
  io.spikeCnt := spikeCntReg

  // Memories
  val ena0     = Wire(Bool())
  val wr0      = Wire(Bool())
  val rdata0   = Wire(UInt(AXONIDWIDTH.W))
  val wdata0   = Wire(UInt(AXONIDWIDTH.W))
  val addr0    = Wire(UInt(AXONIDWIDTH.W))
  val axonMem0 = SyncReadMem(AXONNR, UInt(AXONIDWIDTH.W))

  rdata0 := DontCare
  when(ena0) {
    when(wr0) {
      axonMem0(addr0) := wdata0
    }.otherwise {
      rdata0 := axonMem0(addr0)
    }
  }

  val ena1     = Wire(Bool())
  val wr1      = Wire(Bool())
  val rdata1   = Wire(UInt(AXONIDWIDTH.W))
  val wdata1   = Wire(UInt(AXONIDWIDTH.W))
  val addr1    = Wire(UInt(AXONIDWIDTH.W))
  val axonMem1 = SyncReadMem(AXONNR, UInt(AXONIDWIDTH.W))

  rdata1 := DontCare
  when(ena1) {
    when(wr1) {
      axonMem1(addr1) := wdata1
    }.otherwise {
      rdata1 := axonMem1(addr1)
    }
  }

  // Control logic for swapping memories
  when(~io.inOut) {
    ena0   := io.axonValid
    wr0    := true.B
    wdata0 := io.axonIn
    addr0  := spikeCntReg

    ena1     := io.rEna
    wr1      := false.B
    io.rData := rdata1
    wdata1   := 0.U
    addr1    := io.rAddr
  }.otherwise {
    ena0     := io.rEna
    wr0      := false.B
    io.rData := rdata0
    wdata0   := 0.U
    addr0    := io.rAddr

    ena1     := io.axonValid
    wr1      := true.B
    wdata1   := io.axonIn
    addr1    := spikeCntReg
  }
}
