import chisel3._
import util._
import Constants._

class TransmissionSystem extends Module {
  val io = IO(new Bundle {
    //For Communication fabric interface
    val ack = Input(Bool())
    val valid = Output(Bool())
    val data = Output(UInt((log2Up(EVALUNITS)+N).W))

    // For Neurons control
    val ns = Input(Vec(EVALUNITS, UInt(N.W)))
    val spikes = Input(Vec(EVALUNITS, Bool()))
  }
  )

  val spikeRegs   = RegInit(VecInit(Seq.fill(EVALUNITS)(false.B)))
  val neuronIdLSB = RegInit(VecInit(Seq.fill(EVALUNITS)(0.U(N.W))))


  //Priority encoder and mask

}

class PriorityMaskEncoder extends Module{
  val io = IO(new Bundle{
    val reqs = Input(Vec(EVALUNITS, Bool()))
    val value = Output(UInt(log2Up(EVALUNITS).W))
    val mask = Output(Vec(EVALUNITS, Bool()))
    val valid = Output(Bool())
  })

  // default assignments
  io.value := 0.U
  io.valid := false.B


  io.mask(EVALUNITS-1) := false.B
  for(i <- 0 to EVALUNITS-2){
    io.mask(i) := io.mask(i+1) || io.reqs(i+1) 
  }

  for(j <- 0 to EVALUNITS-1){
    when(io.reqs(j)){
      io.valid := true.B
      io.value := j.U
    }
  }

}


object TransmissionSystem extends App {
  chisel3.Driver.execute(Array("--target-dir", "build/"), () => new TransmissionSystem())
}