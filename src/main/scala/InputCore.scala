import chisel3._
import chisel3.util._
import Constants._

class InputCore(coreID : Int) extends Module{
  val io = IO(new Bundle{
    // to off chip communication
    val offCCData  = Input(UInt(24.W))
    val offCCValid = Input(Bool())
    val offCCReady = Output(Bool())

    val offCCHSin  = Input(Bool())
    val offCCHSout = Output(Bool())

    //to bus 
    val grant = Input(Bool())
    val req   = Output(Bool())
    val tx    = Output(UInt(GLOBALADDRWIDTH.W))
    val rx    = Input(UInt(GLOBALADDRWIDTH.W))

    val nothing = Output(UInt())
  })
  io.nothing := coreID.U

  
  io.offCCReady := true.B //due to dual memory always ready

  //interface to/from bus
  val interface  = Module(new BusInterface(coreID))
  interface.io.grant      := io.grant
  io.req                  := interface.io.reqOut
  io.tx                   := interface.io.tx
  interface.io.rx         := io.rx
  
  // Spike transmission to/from interface
  val spikeTrans = Module(new TransmissionSystem(coreID))
  interface.io.spikeID    := spikeTrans.io.data
  spikeTrans.io.ready     := interface.io.ready
  interface.io.reqIn      := spikeTrans.io.valid

  //control FSM signals
  val ts           = RegInit(0.U(RATEWIDTH.W))                       //rate cannot larger that nr of timesteps per input
  val pixcnt       = RegInit(0.U(RATEADDRWIDTH.W))                   // same as log2Up(NEURONSPRCORE)
  val pixcntLate   = RegNext(pixcnt)
  val pixcntLater  = RegNext(pixcntLate)
  val tsCycleCnt   = RegInit(CYCLESPRSTEP.U)                         //count time step cycles down to 0
  val phase        = RegInit(true.B)                                // Init to in phase. download first
  val cntrEna      = WireDefault(false.B)
  val cntrRateData = Wire(UInt(RATEWIDTH.W))
  val spikePulse   = RegInit(VecInit(Seq.fill(EVALUNITS)(false.B)))  // used to deliver spike pulses to transmission
  val idle :: firstr :: spikegen :: lastgen :: sWait :: Nil = Enum(5)
  val stateReg     = RegInit(idle)
  val sPulseDecSig = WireDefault(EVALUNITS.U((log2Up(EVALUNITS)+1).W))

  io.offCCHSout := phase

  //Memories when phase = 0 write to mem 1 read mem 0, when phase = 1 write to mem 0 read mem 1
  val ena0     = Wire(Bool())
  val wr0      = Wire(Bool()) //0: read, 1: write
  val rdata0   = Wire(UInt(RATEWIDTH.W))
  val wdata0   = Wire(UInt(RATEWIDTH.W))
  val addr0    = Wire(UInt(RATEADDRWIDTH.W))
  val rateMem0 = SyncReadMem(TMNEURONS * EVALUNITS, UInt(RATEWIDTH.W))

  rateMem0.suggestName("rateMem0"+coreID.toString)
  rdata0 := DontCare
  when(ena0) {
    val rdwrPort0 = rateMem0(addr0)
    when(wr0) {
      rdwrPort0 := wdata0
    }.otherwise {
      rdata0 := rdwrPort0
    }
  }

  val ena1     = Wire(Bool())
  val wr1      = Wire(Bool())
  val rdata1   = Wire(UInt(RATEWIDTH.W))
  val wdata1   = Wire(UInt(RATEWIDTH.W))
  val addr1    = Wire(UInt(RATEADDRWIDTH.W))
  val rateMem1 = SyncReadMem(TMNEURONS * EVALUNITS, UInt(RATEWIDTH.W))

  rdata1 := DontCare
  when(ena1) {
    val rdwrPort1 = rateMem1(addr1)
    when(wr1) {
      rdwrPort1 := wdata1
    }.otherwise {
      rdata1 := rdwrPort1
    }
  }

  //mem selection logic
  wdata0 := io.offCCData(RATEWIDTH-1, 0)
  wdata1 := io.offCCData(RATEWIDTH-1, 0)

  when (phase) {
    ena0 := io.offCCValid
    wr0  := true.B
    addr0 := io.offCCData(23, 16)

    ena1 := cntrEna
    wr1 := false.B
    cntrRateData := rdata1 
    addr1 := pixcnt
  }.otherwise {
    ena0 := cntrEna
    wr0 := false.B
    cntrRateData := rdata0 
    addr0 := pixcnt

    ena1 := io.offCCValid
    wr1  := true.B
    addr1 := io.offCCData(23, 16)
  }

  //time step cycle counter
  tsCycleCnt := tsCycleCnt - 1.U
  when(tsCycleCnt === 0.U) {
    tsCycleCnt := CYCLESPRSTEP.U
  }

  //fsm
  val modRes = Wire(UInt(RATEWIDTH.W))
  when(ts === 0.U || cntrRateData === 0.U){
    modRes := 1.U
  }.otherwise{
    modRes := ts % cntrRateData //TODO what about modulus with 0
  }

  switch(stateReg) {
    is(idle) {
      ts := 0.U
      pixcnt := 0.U
      when(io.offCCHSin =/= phase && tsCycleCnt === 0.U) {
        stateReg := firstr
        phase := ~phase
      }
    }
    is(firstr) {
      cntrEna := true.B
      pixcnt := pixcnt + 1.U
      stateReg := spikegen
    }
    is(spikegen) {
      cntrEna := true.B
      pixcnt := pixcnt + 1.U
      when(modRes === 0.U){
        sPulseDecSig := 0.U(1.W) ## pixcntLate(log2Up(EVALUNITS)-1,0)
      }

      when(pixcnt === (NEURONSPRCORE-1).U){
        stateReg := lastgen
      }

    }
    is(lastgen) {
      ts := ts + 1.U
      when(cntrRateData =/= 0.U && modRes === 0.U){
        sPulseDecSig := 0.U(1.W) ## pixcntLate(log2Up(EVALUNITS)-1,0)
      }

      when(ts === 499.U){// all input steps done
        stateReg := idle
      }.otherwise {
        stateReg := sWait
      }
    }
    is(sWait) {
      pixcnt := 0.U
      when(tsCycleCnt === 0.U) {
        stateReg := firstr
      }
    }
  }

  // spike pulse decoder
  for (i <- 0 until EVALUNITS) {
    spikePulse(i) := false.B
    when (sPulseDecSig === i.U) {
      spikePulse(i) := true.B
    }
  }

  // transmission last connections
  spikeTrans.io.n         := pixcntLater(RATEADDRWIDTH-1, RATEADDRWIDTH-N)
  for (i <- 0 until EVALUNITS) {
    spikeTrans.io.spikes(i) := spikePulse(i)
  }
}

object InputCore extends App {
  chisel3.Driver.execute(Array("--target-dir", "build"), () => new InputCore(0))
}