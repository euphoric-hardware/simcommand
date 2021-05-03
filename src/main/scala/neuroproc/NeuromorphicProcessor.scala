package neuroproc

import chisel3._
import chisel3.util._
import chisel3.experimental.{annotate, ChiselAnnotation}

class NeuromorphicProcessor(synth: Boolean = false) extends Module{
  val io = IO(new Bundle{
    val uartTx = Output(Bool())
    val uartRx = Input(Bool())
  })

  val clkEn  = Wire(Bool())
  val newTS = Wire(Bool())
  Seq(clkEn, newTS).foreach { sig =>
    annotate(new ChiselAnnotation {
      override def toFirrtl = firrtl.AttributeAnnotation(sig.toTarget, "dont_touch = \"yes\"")
    })
  }

  // Global clock gating
  val resCnt = 50.U
  val enCnt  = RegInit(resCnt)
  when(clkEn && enCnt =/= resCnt) {
    enCnt := resCnt
  }.elsewhen(!clkEn && enCnt =/= 0.U) {
    enCnt := enCnt - 1.U
  }
  val coreEn = newTS || enCnt =/= 0.U
  
  val topClock = Wire(Clock())
  val cBufTop  = Module(ClockBuffer(synth)) // for clock tree balance
  cBufTop.io.CE := true.B
  cBufTop.io.I  := clock
  topClock := cBufTop.io.O

  val coreClock = Wire(Clock())
  val cBufCore  = Module(ClockBuffer(synth))
  cBufCore.io.CE := coreEn
  cBufCore.io.I  := clock
  coreClock := cBufCore.io.O

  // Relevant true dual port memories
  val inC0Mem = Module(new TrueDualPortMemory(RATEADDRWIDTH+1, RATEWIDTH))
  inC0Mem.io.clka := topClock
  inC0Mem.io.clkb := coreClock
  inC0Mem.io.web  := false.B
  inC0Mem.io.dib  := 0.U

  val inC1Mem = Module(new TrueDualPortMemory(RATEADDRWIDTH+1, RATEWIDTH))
  inC1Mem.io.clka := topClock
  inC1Mem.io.clkb := coreClock
  inC1Mem.io.web  := false.B
  inC1Mem.io.dib  := 0.U

  val outMem = Module(new TrueDualPortFIFO(4, 8))
  outMem.io.clki := coreClock
  outMem.io.clko := topClock
  outMem.io.rst  := reset.asBool

  // Off chip communication and input core phase synchronization
  val inC0HSin = Wire(Bool())
  val inC1HSin = Wire(Bool())
  val offCCHSin0 = Wire(Bool())
  val offCCHSin1 = Wire(Bool())

  /*************** start withClock(topClock) ****************/
  withClock(topClock) {
    // Time step cycle counter
    val tsCycleCnt = RegInit(CYCLESPRSTEP.U)
    newTS := tsCycleCnt === 0.U
    tsCycleCnt := Mux(newTS, CYCLESPRSTEP.U, tsCycleCnt - 1.U)

    // Off chip communication module
    val offCC = Module(new OffChipCom(FREQ,BAUDRATE))
    io.uartTx := offCC.io.tx
    offCC.io.rx := io.uartRx
    offCC.io.inC0HSin := inC0HSin
    offCC.io.inC1HSin := inC1HSin
    offCCHSin0 := offCC.io.inC0HSout
    offCCHSin1 := offCC.io.inC1HSout

    // Memory interconnect
    inC0Mem.io.dia := offCC.io.inC0Di
    inC0Mem.io.ena := offCC.io.inC0We
    inC0Mem.io.wea := offCC.io.inC0We
    inC0Mem.io.addra := offCC.io.inC0Addr

    inC1Mem.io.dia := offCC.io.inC1Di
    inC1Mem.io.ena := offCC.io.inC1We
    inC1Mem.io.wea := offCC.io.inC1We
    inC1Mem.io.addra := offCC.io.inC1Addr

    outMem.io.en     := offCC.io.qEn
    offCC.io.qData   := outMem.io.datao
    offCC.io.qEmpty  := outMem.io.empty
  }
  /**************** end withClock(topClock) *****************/

  // The following is gated with respect to the global clock gating unit
  /*************** start withClock(coreClock) ***************/
  withClock(coreClock) {
    // Bus arbiter
    val arbiter = Module(new BusArbiter)
    val txVec = Wire(Vec(CORES, UInt(GLOBALADDRWIDTH.W)))
    val busTx = Wire(UInt(GLOBALADDRWIDTH.W))
    val enVec = Wire(Vec(CORES, Bool()))

    // ALl relevant cores and their interconnect
    val inCores = (0 until 2).map(i => Module(new InputCore(i)))
    val neuCores = (2 until 4).map(i => Module(new NeuronCore(i, synth)))
    val outCore = Module(new OutputCore(4))

    // Interconnect memories and in/-out cores
    inC0HSin := inCores(0).io.offCCHSout
    inC0Mem.io.enb      := inCores(0).io.memEn
    inC0Mem.io.addrb    := inCores(0).io.memAddr
    inCores(0).io.memDo := inC0Mem.io.dob
    inCores(0).io.newTS := newTS
    inCores(0).io.offCCHSin := offCCHSin0

    inC1HSin := inCores(1).io.offCCHSout
    inC1Mem.io.enb      := inCores(1).io.memEn
    inC1Mem.io.addrb    := inCores(1).io.memAddr
    inCores(1).io.memDo := inC1Mem.io.dob
    inCores(1).io.newTS := newTS
    inCores(1).io.offCCHSin := offCCHSin1

    neuCores(0).io.newTS := newTS

    neuCores(1).io.newTS := newTS
    
    outMem.io.we     := outCore.io.qWe
    outMem.io.datai  := outCore.io.qDi
    outCore.io.qFull := outMem.io.full

    // Generate bus interconnect and enables
    val cores = inCores ++ neuCores :+ outCore
    for (c <- cores.zipWithIndex) {
      c._1 match {
        case i: InputCore  =>
          i.io.rx := busTx
          arbiter.io.reqs(c._2) := i.io.req
          i.io.grant := arbiter.io.grants(c._2)
          txVec(c._2) := i.io.tx
          enVec(c._2) := i.io.pmClkEn
        case n: NeuronCore =>
          n.io.rx := busTx
          arbiter.io.reqs(c._2) := n.io.req
          n.io.grant := arbiter.io.grants(c._2)
          txVec(c._2) := n.io.tx
          enVec(c._2) := n.io.pmClkEn
        case o: OutputCore =>
          o.io.rx := busTx
          arbiter.io.reqs(c._2) := o.io.req
          o.io.grant := arbiter.io.grants(c._2)
          txVec(c._2) := o.io.tx
          enVec(c._2) := o.io.pmClkEn
        }
    }
    busTx := txVec.reduceTree(_ | _)
    clkEn := enVec.reduceTree(_ || _)
  }
  /**************** end withClock(coreClock) ****************/
}

object NeuromorphicProcessor extends App {
  (new chisel3.stage.ChiselStage)
    .emitVerilog(new NeuromorphicProcessor(true), Array("--target-dir", "build"))
}
