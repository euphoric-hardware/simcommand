import chisel3.iotesters.PeekPokeTester
import org.scalatest._

class NeuronEvaluatorTest(dut: NeuronEvaluator) extends PeekPokeTester(dut) {

  //default
  poke(dut.io.cntrSels.potSel, 2)
  poke(dut.io.cntrSels.spikeSel, 1)
  poke(dut.io.cntrSels.refracSel, 1)
  poke(dut.io.cntrSels.writeDataSel, 0)
  step(1)

  // load potential:
  poke(dut.io.cntrSels.potSel, 0)
  poke(dut.io.dataIn, 12)
  step(1)

  expect(dut.io.spikeIndi, 0)
  expect(dut.io.refracIndi, 1)

  // load 10 weight and check membrane potential
  poke(dut.io.cntrSels.potSel, 1)
  var totalweight = 0
  for (i <- 0 to 10) {
    poke(dut.io.dataIn, i)
    step(1)
    totalweight += i
  }
  poke(dut.io.cntrSels.potSel, 2)
  poke(dut.io.dataIn, 0)
  poke(dut.io.cntrSels.writeDataSel, 1)
  expect(dut.io.dataOut, 12 + totalweight)

  //check threshold/spike indication 

  //not exceeded thres
  poke(dut.io.dataIn, 12 + totalweight + 10)
  poke(dut.io.cntrSels.spikeSel, 0)
  step(1)
  poke(dut.io.cntrSels.spikeSel, 1)
  poke(dut.io.dataIn, 0)
  poke(dut.io.cntrSels.writeDataSel, 1)
  expect(dut.io.dataOut, 12 + totalweight)
  expect(dut.io.spikeIndi, 0)
  step(1)

  //exceeded thres
  poke(dut.io.dataIn, 12 + totalweight - 10)
  poke(dut.io.cntrSels.spikeSel, 0)
  step(1)
  poke(dut.io.cntrSels.spikeSel, 1)
  poke(dut.io.dataIn, 0)
  poke(dut.io.cntrSels.writeDataSel, 1)
  expect(dut.io.dataOut, 0)
  expect(dut.io.spikeIndi, 1)


}

class NeuronEvaluatorSpec extends FlatSpec with Matchers {
  "NeuronEvaluator " should "pass" in {
    chisel3.iotesters.Driver.execute(Array("--generate-vcd-output", "on"), () => new NeuronEvaluator()) { c => new NeuronEvaluatorTest(c) } should be(true)
  }
}


