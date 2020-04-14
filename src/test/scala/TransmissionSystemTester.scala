import chisel3.iotesters.PeekPokeTester
import org.scalatest._
import Constants._

class PriorityMaskRstEncoderTest(dut: PriorityMaskRstEncoder) extends PeekPokeTester(dut) {
  //test no reqs
  for (i <- 0 to EVALUNITS - 1) {
    poke(dut.io.reqs(i), false)
  }

  step(1)
  expect(dut.io.valid, false)
  expect(dut.io.value, 0)
  for (i <- 0 to EVALUNITS - 1) {
    expect(dut.io.mask(i), true)
    expect(dut.io.rst(i), false)
  }

  //test reqs
  for (i <- 0 to EVALUNITS - 1) {
    for (j <- 0 to EVALUNITS - 1) {
      poke(dut.io.reqs(j), false)
    }

    for (j <- 1 to EVALUNITS - 1) {
      if (i % j == 0) {
        poke(dut.io.reqs(j), true)
      }
    }
    step(1)
    expect(dut.io.valid, true)
    if (i == 0) {
      expect(dut.io.value, EVALUNITS - 1)
    } else {
      expect(dut.io.value, i)
    }

    for (j <- 0 to EVALUNITS - 1) {
      if (i == 0) { //stupid causation of above loop
        if (j == EVALUNITS - 1) {
          expect(dut.io.rst(j), true)
        } else {
          expect(dut.io.rst(j), false)
        }
      } else if (i == j) {
        expect(dut.io.rst(j), true)
      } else {
        expect(dut.io.rst(j), false)
      }
    }
  }


}

class PriorityMaskRstEncoderSpec extends FlatSpec with Matchers {
  "PriorityMaskRstEncoder " should "pass" in {
    chisel3.iotesters.Driver.execute(Array("--generate-vcd-output", "on"), () => new PriorityMaskRstEncoder()) { c => new PriorityMaskRstEncoderTest(c) } should be(true)
  }
}