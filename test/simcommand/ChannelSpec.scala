package simcommand

import chisel3._
import chiseltest.ChiselScalatestTester
import chisel3.util.Counter
import org.scalatest.flatspec.AnyFlatSpec

class ChannelSpec extends AnyFlatSpec with ChiselScalatestTester {
  class Timer extends Module {
    val a = IO(Output(UInt(32.W)))
    val c = Counter(16)
    c.inc()
    a := c.value
  }

  "getBlocking" should "inspect the circuit IO and get its value" in {
    test(new Timer()) { c =>
      def putter(ch: ChannelHandle[BigInt]): Command[Unit] = for {
        _ <- put(ch, BigInt(1))
        _ <- put(ch, BigInt(2))
        _ <- step(1)
        _ <- put(ch, BigInt(3))
        _ <- put(ch, BigInt(4))
        _ <- step(1)
        _ <- put(ch, BigInt(5))
        _ <- put(ch, BigInt(6))
        _ <- step(1)
        _ <- put(ch, BigInt(7))
        _ <- put(ch, BigInt(8))
        _ <- step(1)
      } yield ()

      def getter(ch: ChannelHandle[BigInt]): Command[Seq[BigInt]] = for {
        t0 <- peek(c.a)
        v1 <- getBlocking(ch)
        t1 <- peek(c.a)
        v2 <- getBlocking(ch)
        t2 <- peek(c.a)
        v3 <- getBlocking(ch)
        t3 <- peek(c.a)
        v4 <- getBlocking(ch)
        t4 <- peek(c.a)
        v5 <- getBlocking(ch)
        t5 <- peek(c.a)
        v6 <- getBlocking(ch)
        t6 <- peek(c.a)
        v7 <- getBlocking(ch)
        t7 <- peek(c.a)
        v8 <- getBlocking(ch)
      } yield (Seq(t0.litValue, v1, t1.litValue, v2, t2.litValue, v3, t3.litValue, v4, t4.litValue, v5, t5.litValue, v6, t6.litValue, v7, t7.litValue, v8))

      val program = for {
        ch <- makeChannel[BigInt](1)
        // Spawn thread which will put two elements repeatedly into a channel
        t1 <- fork(putter(ch), "put")
        // Spawn thread which pops whenever an element is available
        t2 <- fork(getter(ch), "getter")
        result <- join(t2)
      } yield (result)

      val result = unsafeRun(program, c.clock)

      assert(result.retval == Seq(0, 1, 0, 2, 0, 3, 1, 4, 1, 5, 2, 6, 2, 7, 3, 8))
    }
  }

  "nonEmpty" should "test whether or not a channel is empty" in {
    test(new Timer()) { c =>
      val program = for {
        ch <- makeChannel[BigInt](1)
        v1 <- nonEmpty(ch)
        _ <- put[BigInt](ch, 2)
        v2 <- nonEmpty(ch)
        _ <- getBlocking(ch)
        v3 <- nonEmpty(ch)
      } yield (v1, v2, v3)

      val result = unsafeRun(program, c.clock)

      assert(result.retval == (false, true, false))
    }
  }
}
