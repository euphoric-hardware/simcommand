import chisel3.iotesters.PeekPokeTester
import org.scalatest._
import Constants._

class PriorityMaskEncoderTest(dut: PriorityMaskEncoder) extends PeekPokeTester(dut) {
  //test no reqs
  for(i <- 0 to EVALUNITS-1){
    poke(dut.io.reqs(i), false)
  }
  
  step(1)
  expect(dut.io.valid, false)
  expect(dut.io.value, 0)
  for(i <- 0 to EVALUNITS-1){
    expect(dut.io.mask(i), false)
  }

  for(i <- 0 to EVALUNITS-1){
    for(j <- 0 to EVALUNITS-1){
      poke(dut.io.reqs(j), false)
    }

    for(j <- 1 to EVALUNITS-1){
      if(i%j == 0){
        poke(dut.io.reqs(j), true)
      }
    }
    step(1)
    expect(dut.io.valid, true)
    if(i == 0){
      expect(dut.io.value, EVALUNITS-1)
    }else{
      expect(dut.io.value, i)
    }
  }


  
}

class PriorityMaskEncoderSpec extends FlatSpec with Matchers {
  "PriorityMaskEncoder " should "pass" in {
    chisel3.iotesters.Driver.execute(Array("--generate-vcd-output", "on"), () => new PriorityMaskEncoder()) { c => new PriorityMaskEncoderTest(c) } should be(true)
  }
}