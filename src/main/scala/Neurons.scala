import chisel3._
import chisel3.util._
import Constants._

/*NOTES
Look through this design again

Controls har done by the big control unit.

NOTES*/


class EvalCntrSigs() extends Bundle() {
  val potSel = UInt(2.W)
  val spikeSel = UInt(1.W)
  val refracSel = UInt(1.W)
  val writeDataSel = UInt(2.W)
}

class NeuronEvaluator extends Module {
  val io = IO(new Bundle {
      val dataIn = Input(UInt(NEUDATAWIDTH.W))
      val dataOut = Output(UInt(NEUDATAWIDTH.W))
      
      val spikeIndi = Output(Bool())
      val refracIndi = Output(Bool())
      
      val cntrSels = Input(new EvalCntrSigs())
  }
  )
  
  //internal signals:
  val sum = Wire(UInt(NEUDATAWIDTH.W))
  val refracRegNext = Wire(UInt(NEUDATAWIDTH.W))
  
  val membPotReg = RegInit(0.U(NEUDATAWIDTH.W)) //TODO consider SInt
  val refracCntReg = RegNext(refracRegNext)
  val spikeIndiReg = RegInit(false.B)
  
  //default assignment
  io.dataOut := io.dataIn
  
  sum := membPotReg + io.dataIn

  switch(io.cntrSels.potSel) {
    is(0.U) {
      membPotReg := io.dataIn
    }
    is(1.U) {
      membPotReg := sum
    }
    is(2.U) {
      membPotReg := membPotReg
    }
  }

  when(io.cntrSels.refracSel === 0.U) {
    refracRegNext := io.dataIn
  }.otherwise {
    refracRegNext := refracCntReg
  }

  when(io.cntrSels.spikeSel === 0.U) {
    spikeIndiReg := membPotReg > io.dataIn
  } //otherwise keeps its value

  switch(io.cntrSels.writeDataSel) {
    is(0.U) {
      io.dataOut := io.dataIn
    }
    is(1.U) {
      when(~spikeIndiReg) { //TODO maybe chance this chosing of potential to write back
        io.dataOut := sum
      }.otherwise {
        io.dataOut := 0.U
      }
    }
    is(2.U) {
      io.dataOut := refracCntReg - 1.U
    }
  }
  
  io.refracIndi := refracRegNext === 0.U
  io.spikeIndi := spikeIndiReg


}

class EvaluationMemory(coreID : Int, evalID : Int) extends Module{
  val io = IO(new Bundle {
    val addr      = Input(UInt(EVALMEMADDRWIDTH.W))
    val wr        = Input(Bool()) //false: read, true: write
    val ena       = Input(Bool())
    val readData  = Output(UInt(NEUDATAWIDTH.W))
    val writeData = Input(UInt(NEUDATAWIDTH.W))
  }
  )

  val refracPotMem = SyncReadMem(2*N, UInt(NEUDATAWIDTH.W))
  val memRead = Wire(UInt(NEUDATAWIDTH.W))
  val syncOut = RegInit(false.B)
  
  //TODO - make mapping functions to fill memories
  val weights     = (0 until N*AXONNR).map(i => i)
  val weightsUInt = weights.map(i => i.asUInt(NEUDATAWIDTH.W))
  val weightsROM  = VecInit(weightsUInt)

  val biases     = (0 until N).map(i => i)
  val biasesUInt = biases.map(i => i.asUInt(NEUDATAWIDTH.W))
  val biasesROM  = VecInit(biasesUInt)
  
  val decays     = (0 until N).map(i => i)
  val decaysUInt = decays.map(i => i.asUInt(NEUDATAWIDTH.W))
  val decaysROM  = VecInit(decaysUInt)
  
  val thresholds     = (0 until N).map(i => i)
  val thresholdsUInt = thresholds.map(i => i.asUInt(NEUDATAWIDTH.W))
  val thresholdsROM  = VecInit(thresholdsUInt)

  val refracSets     = (0 until N).map(i => i)
  val refracSetsUInt = refracSets.map(i => i.asUInt(NEUDATAWIDTH.W))
  val refracSetsROM  = VecInit(refracSetsUInt)
  //TODO - make mapping functions to fill memories
  
  val romRead = RegInit(0.U(NEUDATAWIDTH.W))

  syncOut := false.B
  when(io.ena){
    when(io.addr < (2*N).U){
      val rdwrPort = refracPotMem(io.addr)
      when(io.wr) {
        rdwrPort := io.writeData
      }.otherwise{
        syncOut := true.B
        memRead := rdwrPort
      }
    }.elsewhen(io.addr < (2*N+N*AXONNR).U){ //TODO: try to do this without subtracting
      romRead := weightsROM(io.addr - (2*N).U)
    }.elsewhen(io.addr < (3*N+N*AXONNR).U){
      romRead := biasesROM(io.addr - (2*N+N*AXONNR).U)
    }.elsewhen(io.addr < (4*N+N*AXONNR).U){
      romRead := decaysROM(io.addr - (3*N+N*AXONNR).U)
    }.elsewhen(io.addr < (5*N+N*AXONNR).U){
      romRead := thresholdsROM(io.addr - (4*N+N*AXONNR).U)
    }.otherwise{
      romRead := refracSetsROM(io.addr - (5*N+N*AXONNR).U)
    }
  }

  io.readData := romRead
  when(syncOut) {
    io.readData := memRead
  }


}