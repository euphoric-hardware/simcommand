import chisel3._
import chisel3.util._
import Constants._
import spray.json._
import chisel3.util.experimental.loadMemoryFromFile
import firrtl.annotations.MemoryLoadFileType



class EvalCntrSigs() extends Bundle() {
  val potSel = UInt(2.W) //0: dataIn, 1: Sum, 2: PotReg
  val spikeSel = UInt(2.W) //0: >thres, 1: reset, 2,3: keep
  val refracSel = UInt(1.W) //0: dataIn, 1: RefracReg
  val decaySel = Bool()  //1: subtract decay, 0: otherwise
  val writeDataSel = UInt(2.W) //0: dataIn, 1: Potential, 2: RefractoryCont
}

class NeuronEvaluator extends Module {
  val io = IO(new Bundle {
    val dataIn     = Input(SInt(NEUDATAWIDTH.W))
    val dataOut    = Output(SInt(NEUDATAWIDTH.W))

    val spikeIndi  = Output(Bool())
    val refracIndi = Output(Bool())

    val cntrSels   = Input(new EvalCntrSigs())
  }
  )

  //internal signals:
  val sum           = Wire(SInt((NEUDATAWIDTH+1).W))
  val sumSat        = Wire(SInt(NEUDATAWIDTH.W))
  val sumIn1        = Wire(SInt((NEUDATAWIDTH+1).W))
  val sumIn2        = Wire(SInt((NEUDATAWIDTH+1).W))
  val refracRegNext = Wire(SInt(NEUDATAWIDTH.W))
  val potDecay      = Wire(SInt(NEUDATAWIDTH.W))

  val membPotReg    = RegInit(0.S(NEUDATAWIDTH.W)) 
  val refracCntReg  = RegNext(refracRegNext)
  val spikeIndiReg  = RegInit(false.B)

  //default assignment
  io.dataOut := io.dataIn
  sumIn1     := membPotReg
  sumIn2     := Mux(io.cntrSels.decaySel, -potDecay, io.dataIn) 
  sum        := sumIn1 + sumIn2


  // saturation
  sumSat := sum
  when(sum < (0-(scala.math.pow(2,NEUDATAWIDTH-1))).asInstanceOf[Int].S){
    sumSat := (0-(scala.math.pow(2,NEUDATAWIDTH-1))).asInstanceOf[Int].S
  }.elsewhen(sum > (scala.math.pow(2,NEUDATAWIDTH-1)-1).asInstanceOf[Int].S){
    sumSat := (scala.math.pow(2,NEUDATAWIDTH-1)-1).asInstanceOf[Int].S
  }


  switch(io.cntrSels.potSel) {
    is(0.U) {
      membPotReg := io.dataIn
    }
    is(1.U) {
      membPotReg := sumSat
    }
    is(2.U) {
      membPotReg := membPotReg
    }
  }

  //constant multiplier
  val decaySwitch = Wire(UInt(3.W))
  decaySwitch := io.dataIn(2,0).asUInt
  potDecay := membPotReg // default
  switch(io.dataIn(2,0).asUInt) { // TODO ensure this works, TODO Should i have no delay
    is(1.U){
      potDecay := membPotReg >> 1  //50%
    }
    is(2.U){
      potDecay := membPotReg >> 2  //25%
    }
    is(3.U){
      potDecay := membPotReg >> 3  //12.5%
    }
    is(4.U){
      potDecay := membPotReg >> 4  //6.25%
    }
    is(5.U){
      potDecay := membPotReg >> 5  //3.125%
    }
    is(6.U){
      potDecay := membPotReg >> 6  //1.563%
    }
    is(7.U){
      potDecay := membPotReg >> 7  //0.781%
    }
  }

  when(io.cntrSels.refracSel === 0.U) {
    refracRegNext := io.dataIn
  }.otherwise {
    refracRegNext := refracCntReg
  }

  switch(io.cntrSels.spikeSel) {
    is(0.U) {
      spikeIndiReg := membPotReg > io.dataIn
    }
    is(1.U) {
      spikeIndiReg := false.B
    }
  } //otherwise keeps its value

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
        when(spikeIndiReg){
          io.dataOut := io.dataIn
        }.otherwise{
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

class EvaluationMemory(coreID: Int, evalID: Int) extends Module {
  val io = IO(new Bundle {
    val addr      = Input(UInt(EVALMEMADDRWIDTH.W))
    val wr        = Input(Bool()) //false: read, true: write
    val ena       = Input(Bool())
    val readData  = Output(SInt(NEUDATAWIDTH.W))
    val writeData = Input(SInt(NEUDATAWIDTH.W))
  }
  )

  val refracPotMem     = SyncReadMem(2 * TMNEURONS, SInt(NEUDATAWIDTH.W))
  val memRead          = Wire(SInt(NEUDATAWIDTH.W))
  val syncOut          = RegInit(false.B)

  
  //Hardcoded mapping for showcase network
  val pROM = Module(new PROM(coreID, evalID))
  //val romRead = RegInit(0.S(NEUDATAWIDTH.W))
  val romRead = Wire(SInt(NEUDATAWIDTH.W))
  val romEna = Wire(Bool())


  //default assignment 
  memRead := DontCare
  syncOut := false.B
  romEna := false.B

  pROM.io.ena := romEna
  pROM.io.addr := io.addr
  romRead := pROM.io.data
  when(io.ena) {
    when(io.addr < (2 * TMNEURONS).U) {
      val rdwrPort = refracPotMem(io.addr)
      when(io.wr) {
        rdwrPort := io.writeData
      }.otherwise {
        syncOut := true.B
        memRead := rdwrPort
      }
    }.otherwise{
      romEna := true.B
    }
  }

  io.readData := romRead
  when(syncOut) {
    io.readData := memRead
  }


}

class EvaluationMemory2(val coreID: Int, val evalID: Int) extends Module {
  val io = IO(new Bundle {
    val addr      = Input(UInt(EVALMEMADDRWIDTH.W))
    val wr        = Input(Bool()) //false: read, true: write
    val ena       = Input(Bool())
    val readData  = Output(SInt(NEUDATAWIDTH.W))
    val writeData = Input(SInt(NEUDATAWIDTH.W))
    val nothing   = Output(UInt())
  }
  )

  io.nothing := coreID.U ## evalID.U

  val eMem             = SyncReadMem(EVALMEMSIZEC, SInt(NEUDATAWIDTH.W))
  val memRead          = Wire(SInt(NEUDATAWIDTH.W))
  val syncOut          = RegInit(false.B)

  eMem.suggestName("eMem"+coreID.toString+"e"+ evalID.toString)

  loadMemoryFromFile(eMem, "mapping/evaldatac"+coreID.toString+"e"+ evalID.toString+".mem")
  //Hardcoded mapping for showcase network

  //default assignment 
  memRead := DontCare
  syncOut := false.B

  when(io.ena) {
    val rdwrPort = eMem(io.addr)
    when(io.wr) {
      rdwrPort := io.writeData
    }.otherwise {
      syncOut := true.B
      memRead := rdwrPort
    }
  }

  io.readData := memRead


}

object OneMem extends App {
  chisel3.Driver.execute(Array("--target-dir", "build/"), () => new EvaluationMemory2(2,0))
}

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

object PROM extends App {
  chisel3.Driver.execute(Array("--target-dir", "build/"), () => new PROM(4,0))
}

class ControlUnit(coreID : Int) extends Module {
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

  val idle :: rRefrac :: rPot :: rDecay :: rWeight1 :: rWeight2 :: rBias :: rThresh :: rRefracSet :: wRefrac :: rPotSet :: wPot :: Nil = Enum(12)
  val stateReg = RegInit(idle)

  val spikePulse     = RegInit(VecInit(Seq.fill(EVALUNITS)(false.B))) // used to deliver spike pulses to transmission
  val tsCycleCnt     = RegInit(CYCLESPRSTEP.U) //count time step cycles down to 0
  val nNext          = Wire(UInt(N.W))
  val n              = RegNext(nNext) // time multiplex evaluation counter
  val aNext          = Wire(UInt(AXONIDWIDTH.W))
  val a              = RegNext(aNext) //axon system addr counter
  val aLate          = RegNext(a) //axon system addr counter
  val spikeCnt       = RegInit(0.U(AXONIDWIDTH.W)) //register that stores sample of axons incoming spike counter
  val inOut          = RegInit(false.B) //used to inform spike system of new timestep
  val evalUnitActive = RegInit(VecInit(Seq.fill(EVALUNITS)(false.B))) // Used to decide if a evaluation unit have evaluated all mapped neurons
  val localCntrSels  = Wire(Vec(EVALUNITS, new EvalCntrSigs()))


  val evalAddr     = Wire(UInt(EVALMEMADDRWIDTH.W))
  val addrOffset   = Wire(UInt(EVALMEMADDRWIDTH.W))
  val addrSpecific = Wire(UInt(EVALMEMADDRWIDTH.W))

  val nrNeuMapped  = RegInit(neuronsInCore(coreID).U)


  //Default assignments
  for (i <- 0 until EVALUNITS) {
    spikePulse(i)                 := false.B
    localCntrSels(i).potSel       := 2.U //TODO reconsider default of control - should now be okay
    localCntrSels(i).spikeSel     := 2.U
    localCntrSels(i).refracSel    := 1.U
    localCntrSels(i).writeDataSel := 0.U
    localCntrSels(i).decaySel     := false.B

    when(evalUnitActive(i)){ // ensures that eval unit is still when all its neurons has been evauated
      io.cntrSels(i).potSel       := localCntrSels(i).potSel
      io.cntrSels(i).spikeSel     := localCntrSels(i).spikeSel
      io.cntrSels(i).refracSel    := localCntrSels(i).refracSel
      io.cntrSels(i).writeDataSel := localCntrSels(i).writeDataSel
      io.cntrSels(i).decaySel     := localCntrSels(i).decaySel
    }.otherwise{
      io.cntrSels(i).potSel       := 2.U 
      io.cntrSels(i).spikeSel     := 2.U
      io.cntrSels(i).refracSel    := 1.U
      io.cntrSels(i).writeDataSel := 0.U
      io.cntrSels(i).decaySel     := false.B
    }

    io.spikes(i)                := spikePulse(i)
  }
  io.addr      := evalAddr
  io.wr        := false.B
  io.ena       := false.B
  io.inOut     := inOut
  io.aAddr     := a
  io.aEna      := true.B
  io.n         := n
       
  nNext        := n
  aNext        := a

  addrOffset   := 0.U
  addrSpecific := 0.U
  evalAddr     := addrOffset + addrSpecific


  //time step cycle counter
  tsCycleCnt := tsCycleCnt - 1.U
  when(tsCycleCnt === 0.U) {
    tsCycleCnt := CYCLESPRSTEP.U
  }

  //set evaluations units active state. (Usure still when all mapped neurons are evaluated)
  for(i <- 0 until EVALUNITS) {
      evalUnitActive(i) := nrNeuMapped > ((n << log2Up(EVALUNITS)) + i.U)
  }

  switch(stateReg) { 
    is(idle) { //in sim 0
      nNext := 0.U
      aNext := 0.U
      when(tsCycleCnt === 0.U) {
        spikeCnt := io.spikeCnt
        inOut    := ~inOut
        stateReg := rRefrac
      }
    }
    is(rRefrac) {//in sim 1
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSREFRAC.U
      addrSpecific := n

      for (i <- 0 until EVALUNITS) {
        localCntrSels(i).spikeSel := 1.U
      }

      stateReg := rPot
    }
    is(rPot) {//in sim 2
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSPOTENTIAL.U
      addrSpecific := n

      for (i <- 0 until EVALUNITS) {
        localCntrSels(i).refracSel := 0.U
      }
      stateReg := rDecay
    }
    is(rDecay) {//in sim 3
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSDECAY.U
      addrSpecific := n

      aNext := a + 1.U

      for (i <- 0 until EVALUNITS) {
        localCntrSels(i).potSel := 0.U
      }

      when(spikeCnt === 0.U) { 
        stateReg := rBias
      }.otherwise {
        stateReg := rWeight1
      }
    }

    is(rWeight1) {//in sim 4
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSWEIGHT.U
      if (MEMCHEAT) {
        addrSpecific := (n * (3*256).U) + io.aData 
      } else {
        addrSpecific := n ## io.aData 
      }

      aNext := a + 1.U

      for (i <- 0 until EVALUNITS) { 
        when(io.refracIndi(i)) {
          localCntrSels(i).potSel   := 1.U
          localCntrSels(i).decaySel := true.B
        }
      }

      when(spikeCnt === a) { 
        stateReg := rBias
      }.otherwise {
        stateReg := rWeight2
      }
    }
    is(rWeight2) {//in sim 5
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSWEIGHT.U
      if (MEMCHEAT) {
        addrSpecific := (n * (3*256).U) + io.aData 
      } else {
        addrSpecific := n ## io.aData 
      }

      for (i <- 0 until EVALUNITS) {
        when(io.refracIndi(i)) {
          localCntrSels(i).potSel := 1.U
        }
      }
      aNext := a + 1.U

      when(spikeCnt === a) { 
        stateReg := rBias
      }.otherwise {
        stateReg := rWeight2
      }
    }
    is(rBias) {//in sim 6
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSBIAS.U
      addrSpecific := n

      when(spikeCnt === 0.U) {
        for (i <- 0 until EVALUNITS) { 
          when(io.refracIndi(i)) {
            localCntrSels(i).potSel   := 1.U
            localCntrSels(i).decaySel := true.B
          }
        }
      }.otherwise {
        for (i <- 0 until EVALUNITS) {
          when(io.refracIndi(i)) {
            localCntrSels(i).potSel := 1.U
          }
        }
      }

      stateReg := rThresh
    }
    is(rThresh) {//in sim 7
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSTHRESH.U
      addrSpecific := n

      for (i <- 0 until EVALUNITS) {
        when(io.refracIndi(i)) {
          localCntrSels(i).potSel := 1.U
        }
      }
      
      stateReg := rRefracSet

    }
    is(rRefracSet) {//in sim 8
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSREFRACSET.U
      addrSpecific := n

      for (i <- 0 until EVALUNITS) {
        localCntrSels(i).spikeSel := 0.U
      }

      stateReg := wRefrac
    }
    is(wRefrac) {//in sim 9
      io.ena       := true.B
      io.wr        := true.B
      addrOffset   := OSREFRAC.U
      addrSpecific := n

      for (i <- 0 until EVALUNITS) {
        localCntrSels(i).writeDataSel := 2.U
        spikePulse(i) := io.spikeIndi(i)
      }

      stateReg := rPotSet

    }
    is(rPotSet) {//in sim A
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSPOTSET.U
      addrSpecific := n

      stateReg     := wPot
    }
    is(wPot) { //in sim B
      io.ena       := true.B
      io.wr        := true.B
      addrOffset   := OSPOTENTIAL.U
      addrSpecific := n

      for (i <- 0 until EVALUNITS) {
        localCntrSels(i).writeDataSel := 1.U
      }

      aNext      := 0.U
      nNext      := n + 1.U
      when((nNext << log2Up(EVALUNITS)) >= nrNeuMapped ) {
        stateReg := idle
      }.otherwise {
        stateReg := rRefrac
      }
    }
  }
}


class Neurons(coreID: Int) extends Module {
  val io = IO(new Bundle {
    //For axon system
    val inOut    = Output(Bool())
    val spikeCnt = Input(UInt(AXONIDWIDTH.W))
    val aAddr    = Output(UInt(AXONIDWIDTH.W))
    val aEna     = Output(Bool())
    val aData    = Input(UInt(AXONIDWIDTH.W))
    //For spike transmission system
    val n        = Output(UInt(N.W))
    val spikes   = Output(Vec(EVALUNITS, Bool()))
  })

  val controlUnit = Module(new ControlUnit(coreID))
  val evalUnits   = (0 until EVALUNITS).map(i => Module(new NeuronEvaluator))
  val evalMems    = (0 until EVALUNITS).map(i => Module(new EvaluationMemory2(coreID, i)))

  io.inOut                := controlUnit.io.inOut
  controlUnit.io.spikeCnt := io.spikeCnt
  io.aAddr                := controlUnit.io.aAddr
  io.aEna                 := controlUnit.io.aEna
  controlUnit.io.aData    := io.aData

  io.n                    := controlUnit.io.n

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

    evalMems(i).io.addr                   := controlUnit.io.addr
    evalMems(i).io.wr                     := controlUnit.io.wr
    evalMems(i).io.ena                    := controlUnit.io.ena
  }

}