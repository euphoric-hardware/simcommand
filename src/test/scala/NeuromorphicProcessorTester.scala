import scala.io.Source
import chisel3.iotesters.PeekPokeTester
import org.scalatest._
import Constants._
import chisel3.util._

class NeuromorphicProcessorTest(dut: NeuromorphicProcessor) extends PeekPokeTester(dut) {
  poke(dut.io.uartRx, 1)  
  step(10000)
  println((log2Up(EVALUNITS)-1).toString)
  val baud = 115200
  var addr = 0
  var period = 0
  var temp = 0
  for (line <- Source.fromFile("mapping/periods.txt").getLines) {
    period = line.toInt
    temp = addr >> 8
    poke(dut.io.uartRx, 0) // start
    step(80000000/baud+1)
    for (j <- 0 until 8){
      poke(dut.io.uartRx, (temp >> j) & 1) // data
      step(80000000/baud+1)
    }
    poke(dut.io.uartRx, 1) // stop
    step((80000000/baud+1)*2)

    temp = addr & 0xff
    poke(dut.io.uartRx, 0) // start
    step(80000000/baud+1)
    for (j <- 0 until 8){
      poke(dut.io.uartRx, (temp >> j) & 1) // data
      step(80000000/baud+1)
    }
    poke(dut.io.uartRx, 1) // stop
    step((80000000/baud+1)*2)

    temp = period >> 8
    poke(dut.io.uartRx, 0) // start
    step(80000000/baud+1)
    for (j <- 0 until 8){
      poke(dut.io.uartRx, (temp >> j) & 1) // data
      step(80000000/baud+1)
    }
    poke(dut.io.uartRx, 1) // stop
    step((80000000/baud+1)*2)

    temp = period & 0xff
    poke(dut.io.uartRx, 0) // start
    step(80000000/baud+1)
    for (j <- 0 until 8){
      poke(dut.io.uartRx, (temp >> j) & 1) // data
      step(80000000/baud+1)
    }
    poke(dut.io.uartRx, 1) // stop
    step((80000000/baud+1)*2)
    
    addr += 1
  }
  step(50000000)
  

}

class NeuromorphicProcessorSpec extends FlatSpec with Matchers {
  "NeuromorphicProcessor " should "pass" in {
    chisel3.iotesters.Driver.execute(Array("--backend-name", "verilator","--generate-vcd-output", "on"), () => new NeuromorphicProcessor()) { c => new NeuromorphicProcessorTest(c) } should be(true)
  }
}
