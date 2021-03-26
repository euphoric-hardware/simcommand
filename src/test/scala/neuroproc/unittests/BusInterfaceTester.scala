package neuroproc.unittests

import neuroproc._

import org.scalatest._
import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.WriteVcdAnnotation

class BusInterfaceTester extends FlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Bus Interface"

  it should "work with all-low inputs" in {
    test(new BusInterface(0)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.io.grant.poke(false.B)
        dut.io.rx.poke(0.U)
        dut.io.reqIn.poke(false.B)
        dut.io.spikeID.poke(0.U)
        
        dut.clock.step()

        dut.io.reqOut.expect(false.B)
        dut.io.tx.expect(0.U)
        dut.io.ready.expect(false.B)
        dut.io.valid.expect(false.B)
        dut.io.axonID.expect(0.U)
    }
  }

  it should "perform tx without grant" in {
    test(new BusInterface(0)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.io.grant.poke(false.B)
        dut.io.rx.poke(0.U)
        dut.io.reqIn.poke(true.B)
        dut.io.spikeID.poke("b01010101010".U)

        dut.clock.step()

        dut.io.reqOut.expect(true.B)
        dut.io.tx.expect(0.U)
        dut.io.ready.expect(false.B)
        dut.io.valid.expect(false.B)
        dut.io.axonID.expect(0.U)
    }
  }

  it should "perform tx with grant" in {
    test(new BusInterface(0)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.io.grant.poke(true.B)
        dut.io.rx.poke(0.U)
        dut.io.reqIn.poke(true.B)
        dut.io.spikeID.poke("b01010101010".U)

        dut.clock.step()

        dut.io.reqOut.expect(false.B)
        dut.io.tx.expect("b01010101010".U)
        dut.io.ready.expect(true.B)
        dut.io.valid.expect(false.B)
        dut.io.axonID.expect(0.U)
    }
  }

  it should "perform rx without subscription" in {
    test(new BusInterface(4)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.io.grant.poke(false.B)
        dut.io.rx.poke("b00110101010".U)
        dut.io.reqIn.poke(false.B)
        dut.io.spikeID.poke(0.U)

        dut.clock.step()

        dut.io.reqOut.expect(false.B)
        dut.io.tx.expect(0.U)
        dut.io.ready.expect(false.B)
        dut.io.valid.expect(false.B)
        dut.io.axonID.expect("b10101010".U)
    }
  }

  it should "perform rx with subscription" in {
    test(new BusInterface(4)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.io.grant.poke(false.B)
        dut.io.rx.poke("b01010101010".U)
        dut.io.reqIn.poke(false.B)
        dut.io.spikeID.poke(0.U)

        dut.clock.step()

        dut.io.reqOut.expect(false.B)
        dut.io.tx.expect(0.U)
        dut.io.ready.expect(false.B)
        dut.io.valid.expect(true.B)
        dut.io.axonID.expect("b10101010".U)
    }
  }
}
