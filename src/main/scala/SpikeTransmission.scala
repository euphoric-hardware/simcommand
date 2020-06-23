import chisel3._
import util._
import Constants._

class TransmissionSystem(coreID: Int) extends Module {
  val io = IO(new Bundle {
    //For Communication fabric interface
    val data   = Output(UInt(GLOBALADDRWIDTH.W))
    val ready  = Input(Bool())
    val valid  = Output(Bool())

    // For Neurons control
    val n      = Input(UInt(N.W))
    val spikes = Input(Vec(EVALUNITS, Bool()))
  }
  )

  val spikeRegs    = RegInit(VecInit(Seq.fill(EVALUNITS)(false.B)))
  val neuronIdMSB  = RegInit(VecInit(Seq.fill(EVALUNITS)(0.U(N.W))))
  val maskRegs     = RegInit(VecInit(Seq.fill(EVALUNITS)(true.B)))

  val spikeEncoder = Module(new PriorityMaskRstEncoder)
  val encoderReqs  = Wire(Vec(EVALUNITS, Bool()))
  val rstReadySel    = Wire(Vec(EVALUNITS, Bool()))
  val spikeUpdate  = Wire(Vec(EVALUNITS, Bool()))

  spikeEncoder.io.reqs := encoderReqs

  io.data  := 0.U //Default assignment for compiler - never the case
  io.valid := spikeEncoder.io.valid


  for (i <- 0 to EVALUNITS - 1) {

    when(io.ready) {
      maskRegs(i) := spikeEncoder.io.mask(i)
    }.elsewhen(!spikeEncoder.io.valid){// prevent deadlock
      maskRegs(i) := true.B
    }

    encoderReqs(i) := maskRegs(i) && spikeRegs(i)

    rstReadySel(i)   := ~(spikeEncoder.io.rst(i) && io.ready)
    spikeUpdate(i) := rstReadySel(i) && spikeRegs(i)

    when(~spikeUpdate(i)) {
      neuronIdMSB(i) := io.n

      when(io.spikes(i)) {
        spikeRegs(i) := true.B
      }.otherwise {
        spikeRegs(i) := false.B
      }
    }

    when(i.U === spikeEncoder.io.value) {
      io.data := coreID.U(log2Up(CORES).W) ## neuronIdMSB(i) ## spikeEncoder.io.value 
    }
  }

  //Priority encoder and mask

}

class PriorityMaskRstEncoder extends Module {
  val io = IO(new Bundle {
    val reqs  = Input(Vec(EVALUNITS, Bool()))
    val value = Output(UInt(log2Up(EVALUNITS).W))
    val mask  = Output(Vec(EVALUNITS, Bool()))
    val rst   = Output(Vec(EVALUNITS, Bool()))
    val valid = Output(Bool())
  })

  // default assignments
  io.value := 0.U
  io.valid := false.B


  when(io.value === 0.U) {
    io.mask(EVALUNITS - 1) := true.B
  }.otherwise {
    io.mask(EVALUNITS - 1) := false.B
  }
  for (i <- 0 to EVALUNITS - 2) {
    io.mask(i) := io.mask(i + 1) || io.reqs(i + 1)
  }

  for (j <- 0 to EVALUNITS - 1) {
    when(io.reqs(j)) {
      io.valid := true.B
      io.value := j.U
    }
  }

  for (j <- 0 to EVALUNITS - 1) {
    when(j.U === io.value && io.valid) {
      io.rst(j) := true.B
    }.otherwise {
      io.rst(j) := false.B
    }
  }

}


object TransmissionSystem extends App {
  chisel3.Driver.execute(Array("--target-dir", "build/"), () => new TransmissionSystem(0))
}