package neuroproc

import chisel3._
import chisel3.util._

class NeuromorphicProcessor extends Module {
  val io = IO(new Bundle{
    val uartTx = Output(Bool())
    val uartRx = Input(Bool())
  })

  // Off chip communication module
  val offCC = Module(new OffChipCom(FREQ, BAUDRATE))

  // Cores - two input cores, two neuron cores, and one output core
  val inCores = (0 until 2).map(i => Module(new InputCore(i)))
  val neuCores = (2 until 4).map(i => Module(new NeuronCore(i)))
  val outCore = Module(new OutputCore(4))
  
  // Connecting off chip communication to in/output cores and UART port
  io.uartTx := offCC.io.tx
  offCC.io.rx := io.uartRx

  inCores(0).io.offCCData  := offCC.io.inC0Data
  inCores(0).io.offCCValid := offCC.io.inC0Valid
  offCC.io.inC0Ready       := inCores(0).io.offCCReady
  inCores(0).io.offCCHSin  :=  offCC.io.inC0HSout
  offCC.io.inC0HSin        := inCores(0).io.offCCHSout
  
  inCores(1).io.offCCData  := offCC.io.inC1Data
  inCores(1).io.offCCValid := offCC.io.inC1Valid
  offCC.io.inC1Ready       := inCores(1).io.offCCReady
  inCores(1).io.offCCHSin  :=  offCC.io.inC1HSout
  offCC.io.inC1HSin        := inCores(1).io.offCCHSout

  offCC.io.outCData        := outCore.io.offCCData
  offCC.io.outCValid       := outCore.io.offCCValid
  outCore.io.offCCReady    := offCC.io.outCReady

  // Communication fabric - a simple bus
  val busArbiter = Module(new BusArbiter)
  //val dataBusOr = Wire(Vec(CORES - 1, UInt(GLOBALADDRWIDTH.W)))
  val busTx = Wire(UInt(GLOBALADDRWIDTH.W))

  // Connecting cores to the communication fabric
  // Could be replaced by generic:
  val cores = inCores ++ neuCores :+ outCore
  busTx := cores.map(_.io.tx).reduce(_ | _)
  //dataBusOr(0) := inCores(0).io.tx | inCores(1).io.tx
  //for (i <- 1 until CORES - 1) {
  //  if (i < 3) {
  //    dataBusOr(i) := dataBusOr(i-1) | neuCores(i-1).io.tx
  //  } else {
  //    dataBusOr(i) := dataBusOr(i-1) | outCore.io.tx
  //  }
  //}
  //busTx := dataBusOr(CORES-2)

  for (c <- cores.zipWithIndex) {
    c._1.io.rx := busTx
    busArbiter.io.reqs(c._2) := c._1.io.req
    c._1.io.grant := busArbiter.io.grants(c._2)
  }
  //for (i <- 0 until CORES) {
  //  if (i < 2) {
  //    inCores(i).io.rx       := busTx
  //    busArbiter.io.reqs(i)  := inCores(i).io.req
  //    inCores(i).io.grant    := busArbiter.io.grants(i)
  //  } else if (i < 4) {
  //    neuCores(i-2).io.rx    := busTx
  //    busArbiter.io.reqs(i)  := neuCores(i-2).io.req
  //    neuCores(i-2).io.grant := busArbiter.io.grants(i)
  //  } else {
  //    outCore.io.rx          := busTx
  //    busArbiter.io.reqs(i)  := outCore.io.req
  //    outCore.io.grant       := busArbiter.io.grants(i)
  //  }
  //}
}

object NeuromorphicProcessor extends App {
  (new chisel3.stage.ChiselStage).emitVerilog(new NeuromorphicProcessor, Array("--target-dir", "build"))
}
