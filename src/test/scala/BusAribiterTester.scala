import chisel3.iotesters.PeekPokeTester
import org.scalatest._
import Constants._

class BusArbiterTest(dut: BusArbiter) extends PeekPokeTester(dut) {
  //test no reqs
  for (i <- 0 to CORES - 1) {
    poke(dut.io.reqs(i), false)
  }

  step(1)
  for (i <- 0 to CORES - 1) {
    expect(dut.io.grants(i), false)
  }

  //test reqs
  for (i <- 0 to CORES - 1) {
    poke(dut.io.reqs(i), true)
  }
  step(1)
  expect(dut.io.grants(CORES - 1), true)
  for (i <- 0 to CORES - 2) {
    expect(dut.io.grants(i), false)
  }

  for (i <- CORES - 1 to 0 by -1) {
    poke(dut.io.reqs(i), false)
    step(1)

    if (i > 0) {
      for (j <- 0 to CORES - 1) {
        if (j == i - 1) {
          expect(dut.io.grants(j), true)
        } else {
          expect(dut.io.grants(j), false)
        }
      }
    }
  }

}

class BusArbiterSpec extends FlatSpec with Matchers {
  "BusArbiter " should "pass" in {
    chisel3.iotesters.Driver.execute(Array("--generate-vcd-output", "on"), () => new BusArbiter()) { c => new BusArbiterTest(c) } should be(true)
  }
}