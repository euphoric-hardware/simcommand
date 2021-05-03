package neuroproc

import chisel3._
import chisel3.util._

class InputCore(coreID: Int) extends Module {
  val io = IO(new Bundle {
    val pmClkEn = Output(Bool())
    val newTS   = Input(Bool())

    // To off chip communication
    val offCCHSin  = Input(Bool())
    val offCCHSout = Output(Bool())

    // Memory interface
    val memEn   = Output(Bool())
    val memAddr = Output(UInt((RATEADDRWIDTH+1).W))
    val memDo   = Input(UInt(RATEWIDTH.W))

    // Bus interface
    val grant = Input(Bool())
    val req   = Output(Bool())
    val tx    = Output(UInt(GLOBALADDRWIDTH.W))
    val rx    = Input(UInt(GLOBALADDRWIDTH.W))

    val nothing = Output(UInt(log2Up(CORES).W))
  })

  // Unique unused output to make sure this module is made in multiple copies
  io.nothing := coreID.U

  // Interface to/from bus
  val interface = Module(new BusInterface(coreID))
  interface.io.grant := io.grant
  io.req             := interface.io.reqOut
  io.tx              := interface.io.tx
  interface.io.rx    := io.rx

  // Spike transmission to/from interface
  val spikeTrans = Module(new TransmissionSystem(coreID))
  interface.io.spikeID    := spikeTrans.io.data
  spikeTrans.io.ready     := interface.io.ready
  interface.io.reqIn      := spikeTrans.io.valid

  // Control FSM internal signals
  val idle :: firstr :: spikegen :: lastgen :: done :: Nil = Enum(5)
  val state  = RegInit(idle)
  val ts     = RegInit(0.U(RATEWIDTH.W))
  val pixCnt = RegInit(0.U(RATEADDRWIDTH.W))
  val pixCntLate  = RegNext(pixCnt)
  val pixCntLater = RegNext(pixCntLate)
  
  val shouldSpike  = Wire(Bool())
  val spikePulse   = RegInit(VecInit(Seq.fill(EVALUNITS)(false.B)))
  val sPulseDecSig = WireDefault(EVALUNITS.U((log2Up(EVALUNITS)+1).W))

  val phase = RegInit(false.B)
  io.offCCHSout := phase

  // Methods for spike generation
  def ratePeriodSpiker() = {
    val res = Mux(ts === 0.U || io.memDo === 0.U, 1.U, ts % io.memDo)
    res === 0.U
  }
  def rankOrderPeriodSpiker() = ts === io.memDo

  // Spike rates are encoded with periods
  if (RANKORDERENC)
    shouldSpike := rankOrderPeriodSpiker()
  else
    shouldSpike := ratePeriodSpiker()

  // Control FSM
  io.pmClkEn := true.B
  io.memEn   := false.B
  io.memAddr := Mux(phase, pixCnt + NEURONSPRCORE.U, pixCnt)
  switch(state) {
    // State 0 - resets counters and waits for next time step
    is(idle) {
      io.pmClkEn := false.B
      ts := 0.U
      pixCnt := 0.U

      when(io.offCCHSin =/= phase && io.newTS) {
        io.pmClkEn := true.B
        state := firstr
        phase := !phase
      }
    }

    // State 1 - enables the memory for reading the first period
    is(firstr) {
      io.memEn := true.B
      pixCnt := pixCnt + 1.U

      state := spikegen
    }

    // State 2 - spikes for NEURONSPRCORE-1 neurons and enables the memory
    // for reading the last period
    is(spikegen) {
      io.memEn := true.B
      pixCnt := pixCnt + 1.U
      when(shouldSpike) {
        sPulseDecSig := 0.U(1.W) ## pixCntLate(log2Up(EVALUNITS)-1,0)
      }

      when(pixCnt === (NEURONSPRCORE-1).U){
        state := lastgen
      }
    }

    // State 3 - spikes the last time and increments the time step count
    is(lastgen) {
      ts := ts + 1.U
      when(shouldSpike) {
        sPulseDecSig := 0.U(1.W) ## pixCntLate(log2Up(EVALUNITS)-1,0)
      }

      state := done
    }

    // State 4 - disables the clock if this block has finished transmission of
    // all its generated spikes (i.e., based on request from its bus interface)
    is(done) {
      when(!interface.io.reqOut && !io.newTS) {
        io.pmClkEn := false.B
      }

      when(io.newTS) {
        io.pmClkEn := true.B
        when(ts === 499.U) {
          state := idle
        }.otherwise {
          state := firstr
        }
      }
    }
  }

  // Spike pulse decoder
  for (i <- 0 until EVALUNITS) {
    spikePulse(i) := false.B
    when (sPulseDecSig === i.U) {
      spikePulse(i) := true.B
    }
  }

  // Transmission connections
  spikeTrans.io.n := pixCntLater(RATEADDRWIDTH-1, RATEADDRWIDTH-N)
  for (i <- 0 until EVALUNITS) {
    spikeTrans.io.spikes(i) := spikePulse(i)
  }
}
