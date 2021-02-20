package neuroproc

import chisel3._
import chisel3.util._

@deprecated("this memory should not be used")
class PROM(coreID : Int, evalID : Int) extends Module{ // Deprecated
  val io = IO(new Bundle{
    val ena       = Input(Bool())
    val addr      = Input(UInt(EVALMEMADDRWIDTH.W))
    val data      = Output(SInt(NEUDATAWIDTH.W))
  })

  val params = new ParameterReader

  val weights          = params.getMemWeights(coreID, evalID)
  val weightsSInt      = weights.map(i => i.asSInt(NEUDATAWIDTH.W))
  val weightsROM       = VecInit(weightsSInt)

  val biases           = params.getMemData("bias", coreID, evalID)
  val biasesSInt       = biases.map(i => i.asSInt(NEUDATAWIDTH.W))
  val biasesROM        = VecInit(biasesSInt)

  val decays           = params.getMemData("decay", coreID, evalID)
  val decaysSInt       = decays.map(i => i.asSInt(NEUDATAWIDTH.W))
  val decaysROM        = VecInit(decaysSInt)

  val thresholds       = params.getMemData("thres", coreID, evalID)
  val thresholdsSInt   = thresholds.map(i => i.asSInt(NEUDATAWIDTH.W))
  val thresholdsROM    = VecInit(thresholdsSInt)

  val refracSets       = params.getMemData("refrac", coreID, evalID)
  val refracSetsSInt   = refracSets.map(i => i.asSInt(NEUDATAWIDTH.W))
  val refracSetsROM    = VecInit(refracSetsSInt)

  val potentialSet     = params.getMemData("reset", coreID, evalID)
  val potentialSetSInt = potentialSet.map(i => i.asSInt(NEUDATAWIDTH.W))
  val potentialSetROM  = VecInit(potentialSetSInt)

  io.data := 0.S
  when (io.ena) {
    when (io.addr < OSBIAS.U) {
    /*  for ((value,index) <- weights.zipWithIndex) {
        if (value != 0){
          when(io.addr - OSWEIGHT.U === index.U){
            io.data := weightsROM(io.addr - OSWEIGHT.U)
          }
        }
      }*/
    io.data := RegNext(weightsROM(io.addr - OSWEIGHT.U)) //TODO: try to do this without subtracting

    }.elsewhen(io.addr < OSDECAY.U) {
      io.data := RegNext(biasesROM(io.addr - OSBIAS.U))

    }.elsewhen(io.addr < OSTHRESH.U) {
      io.data := RegNext(decaysROM(io.addr - OSDECAY.U))

    }.elsewhen(io.addr < OSREFRACSET.U) {
      io.data := RegNext(thresholdsROM(io.addr - OSTHRESH.U))

    }.elsewhen(io.addr < OSPOTSET.U) {
      io.data := RegNext(refracSetsROM(io.addr - OSREFRACSET.U))

    }.otherwise {
      io.data := RegNext(potentialSetROM(io.addr - OSPOTSET.U))
    }
  }
}
