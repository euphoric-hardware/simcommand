import chisel3.iotesters.PeekPokeTester
import org.scalatest._
import Constants._

class UartTestTest(dut: UartEcho) extends PeekPokeTester(dut) {
  //test no reqs
  poke(dut.io.rxd, 1)

  step(100)

  for (i <- 0 until 10){
    poke(dut.io.rxd, 0)

    step(80000000/115200+1)

    poke(dut.io.rxd, 1)
    step(80000000/115200+1)
    poke(dut.io.rxd, 0)
    step(80000000/115200+1)
    poke(dut.io.rxd, 0)
    step(80000000/115200+1)
    poke(dut.io.rxd, 0)
    step(80000000/115200+1)
    poke(dut.io.rxd, 1)
    step(80000000/115200+1)
    poke(dut.io.rxd, 0)
    step(80000000/115200+1)
    poke(dut.io.rxd, 0)
    step(80000000/115200+1)
    poke(dut.io.rxd, 0)
    step(80000000/115200+1)
    poke(dut.io.rxd, 1)
    step(80000000/115200+1)



    poke(dut.io.rxd, 0)

    step(80000000/115200+1)

    poke(dut.io.rxd, 1)
    step(80000000/115200+1)
    poke(dut.io.rxd, 0)
    step(80000000/115200+1)
    poke(dut.io.rxd, 1)
    step(80000000/115200+1)
    poke(dut.io.rxd, 0)
    step(80000000/115200+1)
    poke(dut.io.rxd, 1)
    step(80000000/115200+1)
    poke(dut.io.rxd, 0)
    step(80000000/115200+1)
    poke(dut.io.rxd, 1)
    step(80000000/115200+1)
    poke(dut.io.rxd, 0)
    step(80000000/115200+1)
    poke(dut.io.rxd, 1)
    step(80000000/115200+1)
  }


  step((80000000/115200)*15)





}

class UartTestSpec extends FlatSpec with Matchers {
  "UartEcho " should "pass" in {
    chisel3.iotesters.Driver.execute(Array("--generate-vcd-output", "on"), () => new UartEcho(80000000, 115200)) { c => new UartTestTest(c) } should be(true)
  }
}