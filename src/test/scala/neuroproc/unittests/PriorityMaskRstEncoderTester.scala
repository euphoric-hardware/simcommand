package neuroproc.unittests

import neuroproc._

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers
import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.WriteVcdAnnotation

class PriorityMaskRstEncoderTester extends AnyFlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Priority Mask Reset Encoder"

  it should "handle requests" in {
    test(new PriorityMaskRstEncoder()).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        // No requests
        for (i <- 0 until EVALUNITS)
          dut.io.reqs(i).poke(false.B)
        dut.clock.step()
        dut.io.valid.expect(false.B)
        dut.io.value.expect(0.U)
        for (i <- 0 until EVALUNITS) {
          dut.io.mask(i).expect(true.B)
          dut.io.rst(i).expect(false.B)
        }

        // Test requests
        for (i <- 0 until EVALUNITS) {
          for (j <- 0 until EVALUNITS)
            dut.io.reqs(j).poke((i == j).B)

          dut.clock.step()
          dut.io.valid.expect(true.B)
          dut.io.value.expect(i.U)

          for (j <- 0 until EVALUNITS) {
            dut.io.mask(j).expect((i == 0 || i > j).B)
            dut.io.rst(j).expect((i == j).B)
          }
        }
    }
  }

  it should "match a software model" in {
    test(new PriorityMaskRstEncoder()).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        def priorityMask(reqs: Array[Boolean]) = {
          require(reqs.length == EVALUNITS)
          val valid = reqs.foldLeft(false) { (acc, elem) => acc || elem }
          var value = 0
          for (i <- EVALUNITS-1 to 0 by -1)
            if (reqs(i))
              value = i
          var mask = Array(value == 0)
          for (i <- EVALUNITS-2 to 0 by -1) {
            mask = (reqs(i+1) || mask.head) +: mask
          }
          val rst = (0 until EVALUNITS).map { _ == value && valid }.toArray
          (value, mask, rst, valid)
        }

        // No requests
        for (i <- 0 until EVALUNITS)
          dut.io.reqs(i).poke(false.B)
        dut.clock.step()
        val resp = priorityMask(Array.fill(EVALUNITS) { false })
        dut.io.valid.expect(resp._4.B)
        dut.io.value.expect(resp._1.U)
        for (i <- 0 until EVALUNITS) {
          dut.io.mask(i).expect(resp._2(i).B)
          dut.io.rst(i).expect(resp._3(i).B)
        }

        // With requests
        for (i <- 0 until EVALUNITS) {
          for (j <- 0 until EVALUNITS)
            dut.io.reqs(j).poke((i == j).B)

          dut.clock.step()
          val newResp = priorityMask((0 until EVALUNITS).map { i == _ }.toArray)
          dut.io.valid.expect(newResp._4.B)
          dut.io.value.expect(newResp._1.U)

          for (j <- 0 until EVALUNITS) {
            dut.io.mask(j).expect(newResp._2(j).B)
            dut.io.rst(j).expect(newResp._3(j).B)
          }
        }
    }
  }
}
