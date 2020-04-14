import chisel3._
import chisel3.util._
import Constants._

/*NOTES
Look through this design again

Controls har done by the big control unit.

NOTES*/


class EvalCntrSigs() extends Bundle() {
  val potSel       = UInt(2.W) //0: dataIn, 1: Sum, 2: PotReg
  val spikeSel     = UInt(2.W) //0: >thres, 1: reset, 2,3: keep
  val refracSel    = UInt(1.W) //0: dataIn, 1: RefracReg
  val writeDataSel = UInt(2.W) //0: dataIn, 1: Potential, 2: RefractoryCont
}

class NeuronEvaluator extends Module {
  val io = IO(new Bundle {
      val dataIn     = Input(UInt(NEUDATAWIDTH.W))
      val dataOut    = Output(UInt(NEUDATAWIDTH.W))
      
      val spikeIndi  = Output(Bool())
      val refracIndi = Output(Bool())
      
      val cntrSels   = Input(new EvalCntrSigs())
  }
  )
  
  //internal signals:
  val sum           = Wire(UInt(NEUDATAWIDTH.W))
  val refracRegNext = Wire(UInt(NEUDATAWIDTH.W))
  
  val membPotReg    = RegInit(0.U(NEUDATAWIDTH.W)) //TODO consider SInt
  val refracCntReg  = RegNext(refracRegNext)
  val spikeIndiReg  = RegInit(false.B)
  
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

  switch(io.cntrSels.spikeSel) {
    is(0.U){
    spikeIndiReg := membPotReg > io.dataIn
    }
    is(1.U){
      spikeIndiReg := false.B
    }
  }//otherwise keeps its value

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
      when(io.refracIndi){
        io.dataOut := refracCntReg
      }.otherwise{
      io.dataOut := refracCntReg - 1.U
    }
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

  val refracPotMem = SyncReadMem(2*TMNEURONS, UInt(NEUDATAWIDTH.W))
  val memRead = Wire(UInt(NEUDATAWIDTH.W))
  val syncOut = RegInit(false.B)
  
  //TODO - make mapping functions to fill memories
  val weights     = (0 until TMNEURONS*AXONNR).map(i => i)
  val weightsUInt = weights.map(i => i.asUInt(NEUDATAWIDTH.W))
  val weightsROM  = VecInit(weightsUInt)

  val biases     = (0 until TMNEURONS).map(i => i)
  val biasesUInt = biases.map(i => i.asUInt(NEUDATAWIDTH.W))
  val biasesROM  = VecInit(biasesUInt)
  
  val decays     = (0 until TMNEURONS).map(i => i)
  val decaysUInt = decays.map(i => i.asUInt(NEUDATAWIDTH.W))
  val decaysROM  = VecInit(decaysUInt)
  
  val thresholds     = (0 until TMNEURONS).map(i => i)
  val thresholdsUInt = thresholds.map(i => i.asUInt(NEUDATAWIDTH.W))
  val thresholdsROM  = VecInit(thresholdsUInt)

  val refracSets     = (0 until TMNEURONS).map(i => i)
  val refracSetsUInt = refracSets.map(i => i.asUInt(NEUDATAWIDTH.W))
  val refracSetsROM  = VecInit(refracSetsUInt)

  val potentialSet     = (0 until TMNEURONS).map(i => i)
  val potentialSetUInt = potentialSet.map(i => i.asUInt(NEUDATAWIDTH.W))
  val potentialSetROM  = VecInit(potentialSetUInt)
  //TODO - make mapping functions to fill memories
  
  val romRead = RegInit(0.U(NEUDATAWIDTH.W))

  syncOut := false.B
  when(io.ena){
    when(io.addr < (2*TMNEURONS).U){
      val rdwrPort = refracPotMem(io.addr)
      when(io.wr) {
        rdwrPort := io.writeData
      }.otherwise{
        syncOut := true.B
        memRead := rdwrPort
      }
    
    }.elsewhen(io.addr < OSBIAS.U){ 
      romRead := weightsROM(io.addr - OSWEIGHT.U) //TODO: try to do this without subtracting
    
    }.elsewhen(io.addr < OSDECAY.U){
      romRead := biasesROM(io.addr - OSBIAS.U)
    
    }.elsewhen(io.addr < OSTHRESH.U){
      romRead := decaysROM(io.addr - OSDECAY.U)
    
    }.elsewhen(io.addr < OSREFRACSET.U){
      romRead := thresholdsROM(io.addr - OSTHRESH.U)
    
    }.elsewhen(io.addr < OSPOTSET.U){
      romRead := refracSetsROM(io.addr - OSREFRACSET.U)

    }.otherwise{
      romRead := potentialSetROM(io.addr - OSPOTSET.U)
    }
  }

  io.readData := romRead
  when(syncOut) {
    io.readData := memRead
  }


}

class ControlUnit extends Module{
  val io = IO(new Bundle {
    //for evaluation memories
    val addr       = Output(UInt(EVALMEMADDRWIDTH.W))
    val wr         = Output(Bool()) //false: read, true: write
    val ena        = Output(Bool())
    //For neuron evaluator
    val spikeIndi  = Input(Vec(EVALUNITS, Bool()))
    val refracIndi = Input(Vec(EVALUNITS, Bool()))
    val cntrSels   = Output(Vec(EVALUNITS, new EvalCntrSigs()))
    //For axon system
    val inOut      = Output(Bool())
    val spikeCnt   = Input(UInt(AXONIDWIDTH.W))
    val aAddr      = Output(UInt(AXONIDWIDTH.W))
    val aEna       = Output(Bool())
    val aData      = Input(UInt(AXONIDWIDTH.W))
    //For spike transmission system
    val n          = Output(UInt(N.W))
    val spikes     = Output(Vec(EVALUNITS, Bool()))
  }
  )

  val idle :: rRefrac :: rPot :: rWeight1 :: rWeight2 :: rBias :: rDecay :: rThresh :: rRefracSet :: wRefrac :: wPot :: Nil = Enum(11)
  val stateReg = RegInit(idle)

  val spikePulse = RegInit(VecInit(Seq.fill(EVALUNITS)(false.B))) // used to deliver spike pulses to transmission
  val tsCycleCnt = RegInit(CYCLESPRSTEP.U)                        //count time step cycles down to 0
  val n          = RegInit(0.U(N.W))                              // time multiplex evaluation counter
  val a          = RegInit(0.U(AXONIDWIDTH.W))                    //axon system addr counter
  val spikeCnt   = RegInit(0.U(AXONIDWIDTH.W))                    //register that stores sample of axons incoming spike counter
  val inOut      = RegInit(false.B)                               //used to inform spike system of new timestep

  val evalAddr     = Wire(UInt(EVALMEMADDRWIDTH.W))
  val addrOffset   = Wire(UInt(EVALMEMADDRWIDTH.W))
  val addrSpecific = Wire(UInt(EVALMEMADDRWIDTH.W))

  //Default assignments
  for(i <- 0 until EVALUNITS){
    spikePulse(i) := false.B
    io.cntrSels(i).potSel       := 0.U //TODO reconsider default of control
    io.cntrSels(i).spikeSel     := 0.U
    io.cntrSels(i).refracSel    := 0.U
    io.cntrSels(i).writeDataSel := 0.U
    
    io.spikes(i)                := spikePulse(i)
  }
  io.addr  := evalAddr
  io.wr    := false.B
  io.ena   := false.B
  io.inOut := inOut
  io.aAddr := 0.U //TODO consider if this should be based on reg - probs no
  io.aEna  := false.B
  io.n     := n

  addrOffset   := 0.U
  addrSpecific := 0.U
  evalAddr     := addrOffset + addrSpecific
  
  
  //time step cycle counter
  tsCycleCnt := tsCycleCnt - 1.U
  when(tsCycleCnt === 0.U){
    tsCycleCnt := CYCLESPRSTEP.U
  }

  

  switch(stateReg){
    is(idle){
      n := 0.U
      a := 0.U
      when(tsCycleCnt === 0.U){
        spikeCnt := io.spikeCnt
        inOut := ~inOut
        stateReg := rRefrac
      }
    }
    is(rRefrac){
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSPOTENTIAL.U
      addrSpecific := n
      stateReg     := rPot
    }
    is(rPot){
      
    }
    is(rWeight1){
      
    }
    is(rWeight2){
      
    }
    is(rBias){
      
    }
    is(rDecay){
      
    }
    is(rThresh){
      
    }
    is(rRefracSet){
      
    }
    is(wRefrac){
      
    }
    is(wPot){
      
    }
  }
}