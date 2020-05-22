import chisel3._
import chisel3.util._
import Constants._


class NeuronCore(coreID: Int) extends Module {
  val io = IO(new Bundle {
    val grant = Input(Bool())
    val req   = Output(Bool())
    val tx    = Output(UInt(GLOBALADDRWIDTH.W))
    val rx    = Input(UInt(GLOBALADDRWIDTH.W))
  })

  val interface  = Module(new BusInterface(coreID))
  val axonSystem = Module(new AxonSystem)
  val spikeTrans = Module(new TransmissionSystem(coreID))
  val neurons    = Module(new Neurons(coreID))

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
  for (i <- 0 until EVALUNITS) {
    spikeTrans.io.spikes(i) := neurons.io.spikes(i)
  }


}

object NeuronCore extends App {
  chisel3.Driver.execute(Array("--target-dir", "build/"), () => new NeuronCore(2))
}