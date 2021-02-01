package neuroproc

import chisel3._
import chisel3.util._

class PriorityMaskRstEncoder extends Module {
  val io = IO(new Bundle {
    val reqs  = Input(Vec(EVALUNITS, Bool()))
    val value = Output(UInt(log2Up(EVALUNITS).W))
    val mask  = Output(Vec(EVALUNITS, Bool()))
    val rst   = Output(Vec(EVALUNITS, Bool()))
    val valid = Output(Bool())
  })

  // Default assignment
  io.value := 0.U
  io.valid := false.B

  // Generate valid and value outputs
  for (j <- 0 to EVALUNITS - 1) {
    when(io.reqs(j)) {
      io.valid := true.B
      io.value := j.U
    }
  }

  // Generate mask from requests
  for (i <- 0 to EVALUNITS - 2)
    io.mask(i) := io.mask(i + 1) || io.reqs(i + 1)
  io.mask(EVALUNITS - 1) := io.value === 0.U

  // Generate resets
  for (j <- 0 to EVALUNITS - 1)
    io.rst(j) := j.U === io.value && io.valid
}
