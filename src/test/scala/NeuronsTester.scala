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
  
}

class NeuronEvaluatorSpec extends FlatSpec with Matchers {
  "NeuronEvaluator " should "pass" in {
    chisel3.iotesters.Driver.execute(Array("--generate-vcd-output", "on"), () => new NeuronEvaluator()) { c => new NeuronEvaluatorTest(c) } should be(true)
  }
}