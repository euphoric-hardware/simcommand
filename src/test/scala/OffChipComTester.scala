import chisel3.iotesters.PeekPokeTester
import org.scalatest._
import Constants._

class OffChipComTest(dut: OffChipCom) extends PeekPokeTester(dut) {
  poke(dut.io.rx, 1)  
  step(10000)
  val baud = 115200*4
  var addr = 1
  var period = 1
  var temp = 0
  for(i <- 0 until 4){
    temp = addr >> 8
    poke(dut.io.rx, 0) // start
    step(80000000/baud+1)
    for (j <- 0 until 8){
      poke(dut.io.rx, (temp >> j) & 1) // data
      step(80000000/baud+1)
    }
    poke(dut.io.rx, 1) // stop
    step((80000000/baud+1)*2)

    temp = addr & 0xff
    poke(dut.io.rx, 0) // start
    step(80000000/baud+1)
    for (j <- 0 until 8){
      poke(dut.io.rx, (temp >> j) & 1) // data
      step(80000000/baud+1)
    }
    poke(dut.io.rx, 1) // stop
    step((80000000/baud+1)*2)

    temp = period >> 8
    poke(dut.io.rx, 0) // start
    step(80000000/baud+1)
    for (j <- 0 until 8){
      poke(dut.io.rx, (temp >> j) & 1) // data
      step(80000000/baud+1)
    }
    poke(dut.io.rx, 1) // stop
    step((80000000/baud+1)*2)

    temp = period & 0xff
    poke(dut.io.rx, 0) // start
    step(80000000/baud+1)
    for (j <- 0 until 8){
      poke(dut.io.rx, (temp >> j) & 1) // data
      step(80000000/baud+1)
    }
    poke(dut.io.rx, 1) // stop
    step((80000000/baud+1)*2)
    
    addr += 1
    period += 1
  }

}

class OffChipComSpec extends FlatSpec with Matchers {
  "OffChipCom " should "pass" in {
    chisel3.iotesters.Driver.execute(Array("--generate-vcd-output", "on"), () => new OffChipCom(80000000, 115200*4)) { c => new OffChipComTest(c) } should be(true)
  }
}