import chisel3.iotesters.PeekPokeTester
import org.scalatest._
import Constants._

class InputCoreTest(dut: InputCore) extends PeekPokeTester(dut) {
  
  for (i <- 0 until 256){
    poke(dut.io.offCCData, (i << 16) | i)
    poke(dut.io.offCCValid, 1)
    step(1)
    poke(dut.io.offCCValid, 0)
    step(9)
  }
  
  step(79990-256*10)
  poke(dut.io.offCCHSin, 1)
  step(100000)
  expect(dut.io.req, true)
  poke(dut.io.grant,1)
  expect(dut.io.req, false)
  expect(dut.io.tx, (1 << 8)|1)
  step(1)
  poke(dut.io.grant,0)
  step(100000)
  expect(dut.io.req, true)
  poke(dut.io.grant,1)
  expect(dut.io.req, false)
  expect(dut.io.tx, (1 << 8)|2)
  step(1)
  poke(dut.io.grant,0)
  step(100000)
  poke(dut.io.grant,1)
  step(1)
  poke(dut.io.grant,0)
  step(10)
}

class InputCoreSpec extends FlatSpec with Matchers {
  "InputCore " should "pass" in {
    chisel3.iotesters.Driver.execute(Array("--generate-vcd-output", "on"), () => new InputCore(1)) { c => new InputCoreTest(c) } should be(true)
  }
}