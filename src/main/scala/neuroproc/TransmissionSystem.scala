package neuroproc

import chisel3._
import chisel3.util._

class TransmissionSystem(coreID: Int) extends Module {
  val io = IO(new Bundle {
    // For communication fabric interface
    val data   = Output(UInt(GLOBALADDRWIDTH.W))
    val ready  = Input(Bool())
    val valid  = Output(Bool())

    // For neurons control
    val n      = Input(UInt(N.W))
    val spikes = Input(Vec(EVALUNITS, Bool()))
  })

  val spikeRegs    = RegInit(VecInit(Seq.fill(EVALUNITS)(false.B)))
  val neuronIdMSB  = RegInit(VecInit(Seq.fill(EVALUNITS)(0.U(N.W))))
  val maskRegs     = RegInit(VecInit(Seq.fill(EVALUNITS)(true.B)))

  val spikeEncoder = Module(new PriorityMaskRstEncoder)
  val encoderReqs  = Wire(Vec(EVALUNITS, Bool()))
  val rstReadySel  = Wire(Vec(EVALUNITS, Bool()))
  val spikeUpdate  = Wire(Vec(EVALUNITS, Bool()))

  // Default assignments
  io.data  := 0.U
  io.valid := spikeEncoder.io.valid
  spikeEncoder.io.reqs := encoderReqs

  for (i <- 0 to EVALUNITS - 1) {
    encoderReqs(i) := maskRegs(i) && spikeRegs(i)

    rstReadySel(i) := ~(spikeEncoder.io.rst(i) && io.ready)
    spikeUpdate(i) := rstReadySel(i) && spikeRegs(i)

    when(io.ready) {
      maskRegs(i) := spikeEncoder.io.mask(i)
    }.elsewhen(!spikeEncoder.io.valid) {// prevent deadlock
      maskRegs(i) := true.B
    }

    when(~spikeUpdate(i)) {
      neuronIdMSB(i) := io.n
      spikeRegs(i) := io.spikes(i)
    }

    when(i.U === spikeEncoder.io.value) {
      io.data := coreID.U(log2Up(CORES).W) ## neuronIdMSB(i) ## spikeEncoder.io.value 
    }
  }
}
