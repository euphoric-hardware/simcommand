package neuroproc

import chisel3._
import chisel3.util._

class NeuronCore(coreID: Int, synth: Boolean = false) extends Module {
  val io = IO(new Bundle {
    val pmClkEn = Output(Bool())
    val newTS   = Input(Bool())

    // Bus interface
    val grant = Input(Bool())
    val req   = Output(Bool())
    val tx    = Output(UInt(GLOBALADDRWIDTH.W))
    val rx    = Input(UInt(GLOBALADDRWIDTH.W))
  })

  // Bus interface, axon system, spike transmission, and neuron units
  val interface  = Module(new BusInterface(coreID))
  val axonSystem = Module(new AxonSystem)
  val spikeTrans = Module(new TransmissionSystem(coreID))
  val neurons    = Module(new Neurons(coreID, synth))

  interface.io.grant      := io.grant
  io.req                  := interface.io.reqOut
  io.tx                   := interface.io.tx
  interface.io.rx         := io.rx
  axonSystem.io.axonIn    := interface.io.axonID
  axonSystem.io.axonValid := interface.io.valid
  interface.io.spikeID    := spikeTrans.io.data
  spikeTrans.io.ready     := interface.io.ready
  interface.io.reqIn      := spikeTrans.io.valid

  axonSystem.io.inOut     := neurons.io.inOut
  neurons.io.spikeCnt     := axonSystem.io.spikeCnt
  axonSystem.io.rAddr     := neurons.io.aAddr
  axonSystem.io.rEna      := neurons.io.aEna
  neurons.io.aData        := axonSystem.io.rData

  spikeTrans.io.n         := neurons.io.n
  spikeTrans.io.spikes    := neurons.io.spikes

  io.pmClkEn := !neurons.io.done || interface.io.reqOut
  neurons.io.newTS := io.newTS
}

object NeuronCore extends App {
  (new chisel3.stage.ChiselStage).emitVerilog(new NeuronCore(2), Array("--target-dir", "build"))
}
