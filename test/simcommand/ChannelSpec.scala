package simcommand

import chisel3._
import chiseltest.ChiselScalatestTester
import chisel3.util.Counter
import org.scalatest.flatspec.AnyFlatSpec

class ChannelSpec extends AnyFlatSpec with ChiselScalatestTester {
  "getBlocking" should "inspect the circuit IO and get its value" in {
    class Noop extends Module {}

    test(new Noop()) { c =>
      def putter(ch: ChannelHandle[Integer]): Command[Unit] = for {
        _ <- put[Integer](ch, 1)
        _ <- put[Integer](ch, 2)
        _ <- step(1)
        _ <- put[Integer](ch, 3)
        _ <- put[Integer](ch, 4)
        _ <- step(1)
        _ <- put[Integer](ch, 5)
        _ <- put[Integer](ch, 6)
        _ <- step(1)
        _ <- put[Integer](ch, 7)
        _ <- put[Integer](ch, 8)
        _ <- step(1)
      } yield ()

      def getter(ch: ChannelHandle[Integer]): Command[Seq[Integer]] = for {
        v1 <- getBlocking(ch)
        v2 <- getBlocking(ch)
        v3 <- getBlocking(ch)
        v4 <- getBlocking(ch)
        v5 <- getBlocking(ch)
        v6 <- getBlocking(ch)
        v7 <- getBlocking(ch)
        v8 <- getBlocking(ch)
      } yield (Seq(v1, v2, v3, v4, v5, v6, v7, v8))

      val program = for {
        ch <- makeChannel[Integer](1)
        // Spawn thread which will put two elements repeatedly into a channel
        t1 <- fork(putter(ch), "put")
        // Spawn thread which pops whenever an element is available
        t2 <- fork(getter(ch), "getter")
        result <- join(t2)
      } yield (result)

      val result = unsafeRun(program, c.clock)

      assert(result.retval == (1, 2, 3, 4, 5, 6, 7, 8))
    }
  }
}
