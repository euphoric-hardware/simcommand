import chisel3._
import Constants._

class AxonSystem extends Module {
  val io = IO(new Bundle {
    //For Communication fabric interface
    val axonIn    = Input(UInt(AXONIDWIDTH.W))
    val axonValid = Input(Bool())

    //For Neurons Controller
    val inOut    = Input(Bool())
    val spikeCnt = Output(UInt(AXONIDWIDTH.W))

    val rAddr = Input(UInt(AXONIDWIDTH.W))
    val rEna  = Input(Bool())
    val rData = Output(UInt(AXONIDWIDTH.W))
  }
  )

  val spikeCntReg = RegInit(0.U(AXONIDWIDTH.W))
  
  io.spikeCnt := spikeCntReg

  //Memories
  val ena0     = Wire(Bool())
  val wr0      = Wire(Bool()) //0: read, 1: write
  val rdata0   = Wire(UInt(AXONIDWIDTH.W))
  val wdata0   = Wire(UInt(AXONIDWIDTH.W))
  val addr0    = Wire(UInt(AXONIDWIDTH.W))
  val axonMem0 = SyncReadMem(AXONNR, UInt(AXONIDWIDTH.W))

  rdata0 := DontCare
  when(ena0) {
    val rdwrPort0 = axonMem0(addr0)
    when(wr0) {
      rdwrPort0 := wdata0
    }.otherwise {
      rdata0 := rdwrPort0
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
    val rdwrPort1 = axonMem1(addr1)
    when(wr1) {
      rdwrPort1 := wdata1
    }.otherwise {
      rdata1 := rdwrPort1
    }
  }

  when(~io.inOut) { // all mem related mux
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


  //Counter logic

  val inOutReg = RegNext(io.inOut)

  when(inOutReg =/= io.inOut) { //new time step
    spikeCntReg := 0.U
  }.elsewhen(io.axonValid) {
    spikeCntReg := spikeCntReg + 1.U
  }

}


object AxonSystem extends App {
  chisel3.Driver.execute(Array("--target-dir", "build/"), () => new AxonSystem())
}