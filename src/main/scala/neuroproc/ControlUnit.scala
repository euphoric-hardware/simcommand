package neuroproc

import chisel3._
import chisel3.util._

class ControlUnit(coreID : Int) extends Module {
  val io = IO(new Bundle {
    // For evaluation memories
    val addr       = Output(UInt(EVALMEMADDRWIDTH.W))
    val wr         = Output(Bool()) //false: read, true: write
    val ena        = Output(Bool())

    // For neuron evaluator
    val spikeIndi  = Input(Vec(EVALUNITS, Bool()))
    val refracIndi = Input(Vec(EVALUNITS, Bool()))
    val cntrSels   = Output(Vec(EVALUNITS, new EvalCntrSigs()))
    val evalEnable = Output(Bool())

    // For axon system
    val inOut      = Output(Bool())
    val spikeCnt   = Input(UInt(AXONIDWIDTH.W))
    val aAddr      = Output(UInt(AXONIDWIDTH.W))
    val aEna       = Output(Bool())
    val aData      = Input(UInt(AXONIDWIDTH.W))

    // For spike transmission system
    val n          = Output(UInt(N.W))
    val spikes     = Output(Vec(EVALUNITS, Bool()))
  })

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

  // Default assignments
  for (i <- 0 until EVALUNITS) {
    spikePulse(i)                 := false.B
    localCntrSels(i).potSel       := 2.U
    localCntrSels(i).spikeSel     := 2.U
    localCntrSels(i).refracSel    := 1.U
    localCntrSels(i).writeDataSel := 0.U
    localCntrSels(i).decaySel     := false.B

    when(evalUnitActive(i)) { // ensures that eval unit is still when all its neurons has been evauated
      io.cntrSels(i).potSel       := localCntrSels(i).potSel
      io.cntrSels(i).spikeSel     := localCntrSels(i).spikeSel
      io.cntrSels(i).refracSel    := localCntrSels(i).refracSel
      io.cntrSels(i).writeDataSel := localCntrSels(i).writeDataSel
      io.cntrSels(i).decaySel     := localCntrSels(i).decaySel
    }.otherwise {
      io.cntrSels(i).potSel       := 2.U 
      io.cntrSels(i).spikeSel     := 2.U
      io.cntrSels(i).refracSel    := 1.U
      io.cntrSels(i).writeDataSel := 0.U
      io.cntrSels(i).decaySel     := false.B
    }

    io.spikes(i)                := spikePulse(i)
  }

  io.evalEnable := true.B

  io.addr      := evalAddr
  io.wr        := false.B
  io.ena       := false.B
  io.inOut     := inOut
  io.aAddr     := a
  io.aEna      := false.B
  io.n         := n
       
  nNext        := n
  aNext        := a

  addrOffset   := 0.U
  addrSpecific := 0.U
  evalAddr     := addrOffset + addrSpecific

  // Time step cycle counter
  tsCycleCnt := tsCycleCnt - 1.U
  when(tsCycleCnt === 0.U) {
    tsCycleCnt := CYCLESPRSTEP.U
  }

  // Set evaluations units active state. (Usure still when all mapped neurons are evaluated)
  for (i <- 0 until EVALUNITS) {
    evalUnitActive(i) := nrNeuMapped > ((n << log2Up(EVALUNITS)) + i.U)
  }

  // Control FSM - runs once per time step
  switch(stateReg) { 
    // State 0 - disables evaluators and waits for next time step
    is(idle) {
      nNext := 0.U
      aNext := 0.U
      io.evalEnable := false.B
      when(tsCycleCnt === 0.U) {
        spikeCnt := io.spikeCnt
        inOut    := ~inOut
        stateReg := rRefrac
      }
    }

    // State 1 - read refrac count
    is(rRefrac) {
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSREFRAC.U
      addrSpecific := n

      for (i <- 0 until EVALUNITS) {
        localCntrSels(i).spikeSel := 1.U
      }

      stateReg := rPot
    }

    // State 2 - read membrane potential
    is(rPot) {
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSPOTENTIAL.U
      addrSpecific := n

      for (i <- 0 until EVALUNITS) {
        localCntrSels(i).refracSel := 0.U
      }

      stateReg := rDecay
    }

    // State 3 - read decay factor
    is(rDecay) {
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSDECAY.U
      addrSpecific := n

      aNext := a + 1.U
      io.aEna := true.B

      for (i <- 0 until EVALUNITS) {
        localCntrSels(i).potSel := 0.U
      }

      when(spikeCnt === 0.U) { 
        stateReg := rBias
      }.otherwise {
        stateReg := rWeight1
      }
    }

    // State 4 - read weight number 1
    is(rWeight1) {
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSWEIGHT.U
      if (MEMCHEAT) {
        addrSpecific := (n * (3*256).U) + io.aData 
      } else {
        addrSpecific := n ## io.aData 
      }
      io.aEna := true.B
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

    // State 5 - read weight number 2
    is(rWeight2) {
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
      io.aEna := true.B

      when(spikeCnt === a - 1.U) { 
        stateReg := rBias
      }.otherwise {
        stateReg := rWeight2
      }
    }

    // State 6 - read bias
    is(rBias) {
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

    // State 7 - read threshold set value
    is(rThresh) {
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

    // State 8 - read refractory counter set value
    is(rRefracSet) {
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSREFRACSET.U
      addrSpecific := n

      for (i <- 0 until EVALUNITS) {
        localCntrSels(i).spikeSel := 0.U
      }

      stateReg := wRefrac
    }

    // State 9 - write refractory counter
    is(wRefrac) {
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

    // State A - read membrane potential set value
    is(rPotSet) {
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSPOTSET.U
      addrSpecific := n

      stateReg     := wPot
    }

    // State B - write membrane potential
    is(wPot) {
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
