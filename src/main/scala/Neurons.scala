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