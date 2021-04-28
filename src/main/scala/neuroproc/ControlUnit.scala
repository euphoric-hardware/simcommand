package neuroproc

import chisel3._
import chisel3.util._

class ControlUnit(coreID : Int) extends Module {
  val io = IO(new Bundle {
    val done       = Output(Bool())
    val newTS      = Input(Bool())

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
  val state = RegInit(idle)

  val spikePulse     = RegInit(VecInit(Seq.fill(EVALUNITS)(false.B))) // Used to deliver spike pulses to transmission
  val nNext          = Wire(UInt(N.W))
  val n              = RegNext(nNext)                                 // Time multiplexing evaluation counter
  val aNext          = Wire(UInt(AXONIDWIDTH.W))
  val a              = RegNext(aNext)                                 // Axon system address counter
  val spikeCnt       = RegInit(0.U(AXONIDWIDTH.W))                    // Sample of incoming spike counter
  val inOut          = RegInit(false.B)                               // Used for new time step signaling
  val evalUnitActive = RegInit(VecInit(Seq.fill(EVALUNITS)(false.B))) // Used to decide if a evaluation unit has evaluated all mapped neurons
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

    when(evalUnitActive(i)) { // Ensures that evaluation units are still when all its neurons have been evaluated
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

  // Set evaluations units active state
  for (i <- 0 until EVALUNITS) {
    evalUnitActive(i) := nrNeuMapped > ((n << log2Up(EVALUNITS)) + i.U)
  }

  // Control FSM - runs once per time step
  io.done := false.B
  switch(state) { 
    // State 0 - disables evaluators and waits for next time step
    is(idle) {
      io.done := true.B
      nNext   := 0.U
      aNext   := 0.U
      io.evalEnable := false.B
      when(io.newTS) {
        io.done  := false.B
        spikeCnt := io.spikeCnt
        inOut    := ~inOut
        state    := rRefrac
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

      state := rPot
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

      state := rDecay
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
        state := rBias
      }.otherwise {
        state := rWeight1
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
        state := rBias
      }.otherwise {
        state := rWeight2
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
        state := rBias
      }.otherwise {
        state := rWeight2
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

      state := rThresh
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
      
      state := rRefracSet
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

      state := wRefrac
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

      state := rPotSet
    }

    // State A - read membrane potential set value
    is(rPotSet) {
      io.ena       := true.B
      io.wr        := false.B
      addrOffset   := OSPOTSET.U
      addrSpecific := n

      state     := wPot
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
        state := idle
      }.otherwise {
        state := rRefrac
      }
    }
  }
}
