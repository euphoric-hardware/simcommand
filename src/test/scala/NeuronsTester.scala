import chisel3.iotesters.PeekPokeTester
import org.scalatest._
import Constants._

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


class EvaluationMemoryTest(dut: EvaluationMemory) extends PeekPokeTester(dut) {

  //default is all zero
  step(1)

  expect(dut.io.readData, 0)

  // write to writeable part

  poke(dut.io.addr, 5)
  poke(dut.io.wr, true)
  poke(dut.io.ena, true)
  poke(dut.io.writeData, 5)

  step(1)

  //read the written data non written then written address

  poke(dut.io.addr, 15)
  poke(dut.io.wr, false)
  poke(dut.io.writeData, 0)
  
  step(1)

  expect(dut.io.readData, 0)
  
  poke(dut.io.addr, 5)
  poke(dut.io.wr, false)
  
  step(1)

  expect(dut.io.readData, 5)

  //read from ROMs

  poke(dut.io.addr, OSWEIGHT + 1)
  poke(dut.io.wr, false)

  step(1)

  expect(dut.io.readData, 1)

  poke(dut.io.addr, OSBIAS + 2)
  poke(dut.io.wr, false)

  step(1)

  expect(dut.io.readData, 2)
  
  poke(dut.io.addr, OSDECAY + 3)
  poke(dut.io.wr, false)

  step(1)

  expect(dut.io.readData, 3)

  poke(dut.io.addr, OSTHRESH + 4)
  poke(dut.io.wr, false)

  step(1)

  expect(dut.io.readData, 4)

  poke(dut.io.addr, OSREFRACSET + 5)
  poke(dut.io.wr, false)

  step(1)

  expect(dut.io.readData, 5)

  poke(dut.io.addr, OSPOTSET + 6)
  poke(dut.io.wr, false)

  step(1)

  expect(dut.io.readData, 6)


}

class EvaluationMemorySpec extends FlatSpec with Matchers {
  "EvaluationMemory " should "pass" in {
    chisel3.iotesters.Driver.execute(Array("--generate-vcd-output", "on"), () => new EvaluationMemory(0, 0)) { c => new EvaluationMemoryTest(c) } should be(true)
  }
}