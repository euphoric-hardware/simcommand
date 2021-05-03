package neuroproc

import chisel3._
import chisel3.util._

class ControlUnit(coreID: Int) extends Module {
  val io = IO(new Bundle {
    val done = Output(Bool())
    val newTS = Input(Bool())

    // For evaluation memories
    val addr       = Output(new MemAddr)
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

  // Control FSM - runs once per time step
  val idle :: rRefrac :: rPot :: rDecay :: rWeight1 :: rWeight2 :: rBias :: rThresh :: rRefracSet :: wRefrac :: rPotSet :: wPot :: Nil = Enum(12)
  val state = RegInit(idle)

  // For easier addressing
  val rst :: refrac :: decay :: Nil = Enum(3)

  // Used to deliver spike pulses to transmission
  val spikePulse = RegInit(VecInit(Seq.fill(EVALUNITS)(false.B))) // used to deliver spike pulses to transmission

  // Time multiplex counters for evaluations and axons
  val n     = RegInit(0.U(N.W))
  io.n     := n
  val a     = RegInit(0.U(AXONIDWIDTH.W))
  io.aAddr := a
  // Register to sample incoming spike count from axon system
  val spikeCnt = RegInit(0.U(AXONIDWIDTH.W))
  // Used for new time step signaling
  val inOut = RegInit(false.B)
  io.inOut := inOut
  // Vector of evaluation units active state
  val evalUnitActive = RegInit(VecInit(Seq.fill(EVALUNITS)(false.B)))
  val localCntrSels  = Wire(Vec(EVALUNITS, new EvalCntrSigs()))
  // Register storing number of neurons mapped to this core
  val nrNeuMapped = RegInit(neuronsInCore(coreID).U)

  // Default assignments
  for (i <- 0 until EVALUNITS) {
    spikePulse(i)                 := false.B
    localCntrSels(i).potSel       := 2.U
    localCntrSels(i).spikeSel     := 2.U
    localCntrSels(i).refracSel    := 1.U
    localCntrSels(i).writeDataSel := 0.U
    localCntrSels(i).decaySel     := false.B

    // Ensure evaluation units are still when all neurons have been evaluated
    evalUnitActive(i) := nrNeuMapped > ((n << log2Up(EVALUNITS)) + i.U)
    when(evalUnitActive(i)) {
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

    // Connect spike transmission system
    io.spikes(i) := spikePulse(i)
  }

  io.addr.sel := const
  io.addr.pos := 0.U
  io.ena := false.B
  io.wr  := false.B

  io.evalEnable := true.B

  io.aEna := false.B

  // Control FSM - runs once per time step
  io.done := false.B
  switch(state) {
    // State 0 - disables evaluators and waits for next time step
    is(idle) {
      io.done := true.B
      n := 0.U
      a := 0.U
      io.evalEnable := false.B
      when(io.newTS) {
        io.done  := false.B
        spikeCnt := io.spikeCnt
        inOut    := ~inOut
        state    := rRefrac
      }
    }

    // State 1 - read refrac counter
    is(rRefrac) {
      io.ena      := true.B
      io.wr       := false.B
      io.addr.sel := dynamic
      io.addr.pos := n

      for (i <- 0 until EVALUNITS)
        localCntrSels(i).spikeSel := 1.U

      state := rPot
    }

    // State 2 - read membrane potential
    is(rPot) {
      io.ena      := true.B
      io.wr       := false.B
      io.addr.sel := dynamic
      io.addr.pos := n + TMNEURONS.U

      for (i <- 0 until EVALUNITS)
        localCntrSels(i).refracSel := 0.U
      
      state := rDecay
    }

    // State 3 - read decay factor
    is(rDecay) {
      io.ena      := true.B
      io.wr       := false.B
      io.addr.sel := const
      io.addr.pos := decay

      a := a + 1.U
      io.aEna := true.B

      for (i <- 0 until EVALUNITS)
        localCntrSels(i).potSel := 0.U

      when(spikeCnt === 0.U) { 
        state := rBias
      }.otherwise {
        state := rWeight1
      }
    }

    // State 4 - read weight number 1
    is(rWeight1) {
      io.ena      := true.B
      io.wr       := false.B
      io.addr.sel := weights
      if (MEMCHEAT) {
        io.addr.pos := (n * (3*256).U) + io.aData 
      } else {
        io.addr.pos := n ## io.aData 
      }

      io.aEna := true.B
      a := a + 1.U

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
      io.ena      := true.B
      io.wr       := false.B
      io.addr.sel := weights
      if (MEMCHEAT) {
        io.addr.pos := (n * (3*256).U) + io.aData 
      } else {
        io.addr.pos := n ## io.aData 
      }

      a := a + 1.U
      io.aEna := true.B

      for (i <- 0 until EVALUNITS) {
        when(io.refracIndi(i)) {
          localCntrSels(i).potSel := 1.U
        }
      }

      when(spikeCnt === a - 1.U) { 
        state := rBias
      }.otherwise {
        state := rWeight2
      }
    }

    // State 6 - read bias
    is(rBias) {
      io.ena      := true.B
      io.wr       := false.B
      io.addr.sel := biasthresh
      io.addr.pos := n

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
      io.addr.sel  := biasthresh
      io.addr.pos  := n + TMNEURONS.U

      for (i <- 0 until EVALUNITS) {
        when(io.refracIndi(i)) {
          localCntrSels(i).potSel := 1.U
        }
      }
      
      state := rRefracSet
    }

    // State 8 - read refractory counter set value
    is(rRefracSet) {
      io.ena      := true.B
      io.wr       := false.B
      io.addr.sel := const
      io.addr.pos := refrac

      for (i <- 0 until EVALUNITS)
        localCntrSels(i).spikeSel := 0.U

      state := wRefrac
    }

    // State 9 - write refractory counter
    is(wRefrac) {
      io.ena      := true.B
      io.wr       := true.B
      io.addr.sel := dynamic
      io.addr.pos := n

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
      io.addr.sel := const
      io.addr.pos := rst

      state     := wPot
    }

    // State B - write membrane potential
    is(wPot) {
      io.ena      := true.B
      io.wr       := true.B
      io.addr.sel := dynamic
      io.addr.pos := n + TMNEURONS.U

      for (i <- 0 until EVALUNITS)
        localCntrSels(i).writeDataSel := 1.U

      a := 0.U
      val nNext = n + 1.U
      n := nNext
      when((nNext << log2Up(EVALUNITS)) >= nrNeuMapped ) {
        state := idle
      }.otherwise {
        state := rRefrac
      }
    }
  }
}
