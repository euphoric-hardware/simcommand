package neuroproc

import chisel3._
import chisel3.util._

class NeuronEvaluator extends Module {
  val io = IO(new Bundle {
    val dataIn     = Input(SInt(NEUDATAWIDTH.W))
    val dataOut    = Output(SInt(NEUDATAWIDTH.W))

    val spikeIndi  = Output(Bool())
    val refracIndi = Output(Bool())

    val cntrSels   = Input(new EvalCntrSigs())
    val evalEnable = Input(Bool())
  })

  // Internal signals
  val sum              = Wire(SInt((NEUDATAWIDTH+1).W))
  val sumSat           = Wire(SInt(NEUDATAWIDTH.W))
  val sumIn1           = Wire(SInt((NEUDATAWIDTH+1).W))
  val sumIn2           = Wire(SInt((NEUDATAWIDTH+1).W))
  val potDecay         = Wire(SInt(NEUDATAWIDTH.W))
  val refracRegNext    = Wire(SInt(NEUDATAWIDTH.W))
  val membPotRegNext   = Wire(SInt(NEUDATAWIDTH.W))
  val spikeIndiRegNext = Wire(Bool())

  val membPotReg    = RegEnable(membPotRegNext, 0.S(NEUDATAWIDTH.W), io.evalEnable) //regEnable only works with a next declaration
  val refracCntReg  = RegEnable(refracRegNext, io.evalEnable)
  val spikeIndiReg  = RegEnable(spikeIndiRegNext, false.B, io.evalEnable)

  // Default assignments
  io.dataOut := io.dataIn
  sumIn1     := membPotReg
  sumIn2     := Mux(io.cntrSels.decaySel, -potDecay, io.dataIn) 
  sum        := sumIn1 + sumIn2

  membPotRegNext   := membPotReg
  spikeIndiRegNext := spikeIndiReg

  // Saturation
  when(sum < (0 - (1 << (NEUDATAWIDTH-1))).S) {
    sumSat := (0 - (1 << (NEUDATAWIDTH-1))).S
  }.elsewhen(sum > ((1 << (NEUDATAWIDTH-1)) - 1).S) {
    sumSat := ((1 << (NEUDATAWIDTH-1)) - 1).S
  }.otherwise {
    sumSat := sum
  }

  // Next membrane potential selection
  switch(io.cntrSels.potSel) {
    is(0.U) {
      membPotRegNext := io.dataIn
    }
    is(1.U) {
      membPotRegNext := sumSat
    }
    is(2.U) {
      membPotRegNext := membPotReg
    }
  }

  // Constant multiplier for estimated decay
  // |--Shift--|--Decay--| //
  // |    0    | 100    %| //
  // |    1    |  50    %| //
  // |    2    |  25    %| //
  // |    3    |  12.5  %| //
  // |    4    |   6.25 %| //
  // |    5    |   3.125%| //
  // |    6    |   1.563%| //
  // |    7    |   0.781%| //
  potDecay := membPotReg >> io.dataIn(2, 0)
  
  // Next refraction count selection
  refracRegNext := Mux(io.cntrSels.refracSel === 0.U, io.dataIn, refracCntReg)

  // Next spike indirection selection
  switch(io.cntrSels.spikeSel) {
    is(0.U) {
      spikeIndiRegNext := membPotReg > io.dataIn
    }
    is(1.U) {
      spikeIndiRegNext := false.B
    }
  }

  // Data out selection
  switch(io.cntrSels.writeDataSel) {
    is(0.U) {
      io.dataOut := io.dataIn
    }
    is(1.U) {
      when(~spikeIndiReg) { //TODO maybe chance this choosing of potential to write back
        io.dataOut := membPotReg
      }.otherwise {
        io.dataOut := io.dataIn
      }
    }
    is(2.U) {
      when(io.refracIndi) {
        when(spikeIndiReg) {
          io.dataOut := io.dataIn
        }.otherwise {
          io.dataOut := refracCntReg
        }
      }.otherwise {
        io.dataOut := refracCntReg - 1.S
      }
    }
  }

  io.refracIndi := refracRegNext === 0.S
  io.spikeIndi  := spikeIndiReg
}
