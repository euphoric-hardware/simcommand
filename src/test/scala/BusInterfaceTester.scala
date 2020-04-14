import chisel3.iotesters.PeekPokeTester
import org.scalatest._
import Constants._

class BusInterfaceTest(dut: BusInterface) extends PeekPokeTester(dut) {
  //All low
  poke(dut.io.grant, false)
  poke(dut.io.rx, 0)
  poke(dut.io.reqIn, false)
  poke(dut.io.spikeID, 0)

  step(1)

  expect(dut.io.reqOut, false)
  expect(dut.io.tx, 0)
  expect(dut.io.ack, false)
  expect(dut.io.valid, false)
  expect(dut.io.axonID, 0)

  //Test tx input without grant
  poke(dut.io.grant, false)
  poke(dut.io.rx, 0)
  poke(dut.io.reqIn, true)
  poke(dut.io.spikeID, Integer.parseInt("101010101010", 2))

  step(1)

  expect(dut.io.reqOut, true)
  expect(dut.io.tx, 0)
  expect(dut.io.ack, false)
  expect(dut.io.valid, false)
  expect(dut.io.axonID, 0)

  //Test tx input with grant
  poke(dut.io.grant, true)
  poke(dut.io.rx, 0)
  poke(dut.io.reqIn, true)
  poke(dut.io.spikeID, Integer.parseInt("101010101010", 2))

  step(1)

  expect(dut.io.reqOut, false)
  expect(dut.io.tx, Integer.parseInt("101010101010", 2))
  expect(dut.io.ack, true)
  expect(dut.io.valid, false)
  expect(dut.io.axonID, 0)

  //Test rx with subscription
  poke(dut.io.grant, false)
  poke(dut.io.rx, Integer.parseInt("000010101010", 2))
  poke(dut.io.reqIn, false)
  poke(dut.io.spikeID, 0)

  step(1)

  expect(dut.io.reqOut, false)
  expect(dut.io.tx, 0)
  expect(dut.io.ack, false)
  expect(dut.io.valid, true)
  expect(dut.io.axonID, Integer.parseInt("0010101010", 2))

  //Test rx without subscription
  poke(dut.io.grant, false)
  poke(dut.io.rx, Integer.parseInt("000110101010", 2))
  poke(dut.io.reqIn, false)
  poke(dut.io.spikeID, 0)

  step(1)

  expect(dut.io.reqOut, false)
  expect(dut.io.tx, 0)
  expect(dut.io.ack, false)
  expect(dut.io.valid, false)
  expect(dut.io.axonID, Integer.parseInt("0010101010", 2))

}

class BusInterfaceSpec extends FlatSpec with Matchers {
  "BusInterface " should "pass" in {
    chisel3.iotesters.Driver.execute(Array("--generate-vcd-output", "on"), () => new BusInterface(0)) { c => new BusInterfaceTest(c) } should be(true)
  }
}