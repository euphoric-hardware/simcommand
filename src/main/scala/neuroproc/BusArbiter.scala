package neuroproc

import chisel3._
import chisel3.util._

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

  // Default assignment
  value  := 0.U 
  oneReq := false.B

  for (i <- 0 until CORES) {
    // Store incoming requests and the mask
    maskRegs(i)  := mask(i)
    grantRegs(i) := grants(i)

    // Mask requests
    maskedReqs(i) := maskRegs(i) && io.reqs(i)

    // Check if a request is high
    when(maskedReqs(i)) {
      oneReq := true.B
      value  := i.U
    }

    // Generate grants
    grants(i) := (i.U === value && oneReq)
  }

  // Generate mask from masked requests
  for (i <- 0 to CORES - 2) {
    mask(i) := mask(i + 1) || maskedReqs(i + 1)
  }
  mask(CORES-1) := value === 0.U

  io.grants := grantRegs
}
