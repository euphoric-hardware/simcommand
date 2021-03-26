package neuroproc

import chisel3._

class Neurons(coreID: Int) extends Module {
  val io = IO(new Bundle {
    val done     = Output(Bool())
    val newTS    = Input(Bool())

    // For axon system
    val inOut    = Output(Bool())
    val spikeCnt = Input(UInt(AXONIDWIDTH.W))
    val aAddr    = Output(UInt(AXONIDWIDTH.W))
    val aEna     = Output(Bool())
    val aData    = Input(UInt(AXONIDWIDTH.W))
    
    // For spike transmission system
    val n        = Output(UInt(N.W))
    val spikes   = Output(Vec(EVALUNITS, Bool()))
  })

  val controlUnit = Module(new ControlUnit(coreID))
  val evalUnits   = (0 until EVALUNITS).map(i => Module(new NeuronEvaluator))
  val evalMems    = (0 until EVALUNITS).map(i => Module(new EvaluationMemory(coreID, i)))

  io.inOut                := controlUnit.io.inOut
  controlUnit.io.spikeCnt := io.spikeCnt
  io.aAddr                := controlUnit.io.aAddr
  io.aEna                 := controlUnit.io.aEna
  controlUnit.io.aData    := io.aData
  io.n                    := controlUnit.io.n

  io.done := controlUnit.io.done
  controlUnit.io.newTS := io.newTS

  for (i <- 0 until EVALUNITS) {
    io.spikes(i) := controlUnit.io.spikes(i)

    evalUnits(i).io.dataIn                := evalMems(i).io.readData
    evalMems(i).io.writeData              := evalUnits(i).io.dataOut
    controlUnit.io.spikeIndi(i)           := evalUnits(i).io.spikeIndi
    controlUnit.io.refracIndi(i)          := evalUnits(i).io.refracIndi
    evalUnits(i).io.cntrSels.potSel       := controlUnit.io.cntrSels(i).potSel
    evalUnits(i).io.cntrSels.spikeSel     := controlUnit.io.cntrSels(i).spikeSel
    evalUnits(i).io.cntrSels.refracSel    := controlUnit.io.cntrSels(i).refracSel
    evalUnits(i).io.cntrSels.writeDataSel := controlUnit.io.cntrSels(i).writeDataSel
    evalUnits(i).io.cntrSels.decaySel     := controlUnit.io.cntrSels(i).decaySel
    evalUnits(i).io.evalEnable            := controlUnit.io.evalEnable

    evalMems(i).io.addr                   := controlUnit.io.addr
    evalMems(i).io.wr                     := controlUnit.io.wr
    evalMems(i).io.ena                    := controlUnit.io.ena
  }
}
