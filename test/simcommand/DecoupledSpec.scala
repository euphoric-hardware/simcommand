package simcommand

import chisel3._
import chisel3.util.Queue
import chiseltest.{ChiselScalatestTester, WriteVcdAnnotation}
import chiseltest.internal.NoThreadingAnnotation
import org.scalatest.flatspec.AnyFlatSpec
import simcommand.vips.Decoupled

class DecoupledSpec extends AnyFlatSpec with ChiselScalatestTester {
  "decoupled commands" should "drive and fetch from a FIFO" in {
    val proto = UInt(16.W)
    val data = (0 until 100).map(_.U)
    test(new Queue(proto, 16)).withAnnotations(Seq(NoThreadingAnnotation, WriteVcdAnnotation)) { c =>
      val enqCmds = new Decoupled(c.io.enq)
      val deqCmds = new Decoupled(c.io.deq)
      val test = for {
        enqThread <- fork(enqCmds.enqueueSeq(data), "enqueue")
        _ <- step(10)
        deqThread <- fork(deqCmds.dequeueN(data.length), "dequeue")
        _ <- join(enqThread)
        out <- join(deqThread)
      } yield out
      val result = unsafeRun(test, c.clock)
      assert(result.retval.map(_.litValue) == data.map(_.litValue))
    }
  }
}
