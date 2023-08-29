package simcommand.user

import chisel3._
import chisel3.experimental.BundleLiterals._
import chisel3.util.{ShiftRegister, Valid}
import chiseltest.{ChiselScalatestTester, WriteVcdAnnotation}
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.Assertions.{assert => scalaAssert}
import simcommand._

class ForkSpec extends AnyFlatSpec with ChiselScalatestTester {
  class ValidDelayLine(delay: Int) extends Module {
    val a = IO(Input(Valid(UInt(10.W))))
    val b = IO(Output(Valid(UInt(10.W))))
    val default = Valid(UInt(10.W)).Lit(_.valid -> false.B, _.bits -> 0.U)
    b := ShiftRegister(a, delay, default, 1.B)
  }

  class ValidDelayLineVIPs(a: Valid[UInt], b: Valid[UInt], proto: Valid[UInt]) {
    def poker(nElems: Int): Command[Unit] = {
      def pokeOneElem(value: Int): Command[Unit] = for {
        _ <- poke(a, proto.Lit(_.valid -> 1.B, _.bits -> value.U))
        _ <- step(1)
      } yield ()
      val pokeCmds = (0 until nElems).map(i => pokeOneElem(i))
      for {
        _ <- sequence(pokeCmds).map(_ => ())
        _ <- poke(a, proto.Lit(_.valid -> 0.B, _.bits -> 0.U))
        _ <- step(1)
      } yield ()
    }

    def peeker(nElems: Int): Command[Seq[Int]] = {
      def peekCmd(): Command[Int] = {
        for {
          valid <- peek(b.valid)
          data <- peek(b.bits)
          _ <- step(1)
          bits <- {
            if (!valid.litToBoolean)
              peekCmd() // TODO: recursive call in flatMap, will blow up stack eventually
            else
              lift(data.litValue.toInt)
          }
        } yield bits
      }
      val peekCmds = Seq.fill(nElems)(peekCmd())
      sequence(peekCmds)
    }

    def program(nElems: Int): Command[Seq[Int]] = {
      for {
        _ <- step(1)
        peekerThread <- fork(peeker(nElems))
        pokerThread <- fork(poker(nElems))
        pokerJoin <- join(pokerThread)
        peekerJoin <- join(peekerThread)
      } yield peekerJoin
    }
  }

  "fork" should "create a thread that operates independently of the main thread" in {
    val nElems = 10
    test(new ValidDelayLine(delay=nElems/2)).withAnnotations(Seq(WriteVcdAnnotation)) { c =>
      val vips = new ValidDelayLineVIPs(c.a, c.b, Valid(UInt(10.W)))
      val result = unsafeRun(vips.program(nElems), c.clock)
      scalaAssert(result.retval == (0 until nElems))
    }
  }

  "fork" should "support threads that terminate on the same cycle they are spawned" in {
    val program = for {
      _ <- fork(lift(()))
      _ <- fork(lift(()))
      _ <- fork(lift(()))
      _ <- fork(lift(()))
    } yield ()
    val retval = unsafeRun(program, FakeClock(), Config().copy(recordActions = true))
    scalaAssert(retval.actions.isDefined)
    retval.actions.foreach { actions =>
      scalaAssert(actions.isEmpty)
    }
    scalaAssert(retval.threadsSpawned == 5)
  }

  "fork" should "terminate the child threads when the parent terminates" in {
    val program = for {
      _ <- fork(step(10))
      _ <- step(4)
    } yield ()
    val retval = unsafeRun(program, FakeClock(), Config().copy(recordActions = true))
    scalaAssert(retval.actions.isDefined)
    retval.actions.foreach { actions =>
      scalaAssert(true)
      println(actions)
    }
    scalaAssert(retval.cycles == 4)
    scalaAssert(retval.threadsSpawned == 2)
  }
}
