import chisel3._
import Constants._
import util._

class BusArbiter extends Module {
  val io = IO(new Bundle {
    val reqs   = Input(Vec(CORES, Bool()))
    val grants = Output(Vec(CORES, Bool()))
  })

  val maskedReqs = Wire(Vec(CORES, Bool()))
  val mask       = Wire(Vec(CORES, Bool()))
  val maskRegs   = RegInit(VecInit(Seq.fill(CORES)(true.B)))
  val grants     = Wire(Vec(CORES, Bool()))
  val grantRegs  = RegInit(VecInit(Seq.fill(CORES)(false.B)))

  val oneReq     = Wire(Bool())
  val value      = Wire(UInt(log2Up(CORES).W))

  value  := 0.U //default assignments
  oneReq := false.B

  for (i <- 0 to CORES - 1) {
    maskRegs(i)  := mask(i)
    grantRegs(i) := grants(i)
  }

  when(value === 0.U) {
    mask(CORES - 1) := true.B
  }.otherwise {
    mask(CORES - 1) := false.B
  }
  for (i <- 0 to CORES - 2) {
    mask(i) := mask(i + 1) || maskedReqs(i + 1)
  }

  for (i <- 0 to CORES - 1) {
    maskedReqs(i) := maskRegs(i) && io.reqs(i)
  }

  for (j <- 0 to CORES - 1) {
    when(maskedReqs(j)) {
      oneReq := true.B
      value  := j.U
    }
  }

  for (j <- 0 to CORES - 1) {
    when(j.U === value && oneReq) {
      grants(j) := true.B
    }.otherwise {
      grants(j) := false.B
    }
  }
  io.grants := grantRegs

}