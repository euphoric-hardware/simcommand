package jmhbenchmarks

import chisel3._
import chisel3.experimental.BundleLiterals._
import chiseltest._
import org.openjdk.jmh.annotations.{Benchmark, Fork, Level, Scope, Setup, State}
import benchmarks.{DecoupledGcd, GcdInputBundle, GcdOutputBundle}
import simcommand._

@State(Scope.Thread)
class BenchmarkStateDecoupledGcd() extends BenchmarkState[DecoupledGcd](() => new DecoupledGcd(60)) {
  val (maxX, maxY) = (30, 30)
  val testValues = for {x <- 2 to maxX; y <- 2 to maxY} yield (BigInt(x), BigInt(y), BigInt(x).gcd(y))
  val bitWidth = 60
  val inputBundles = testValues.map { case (a, b, _) =>
    new GcdInputBundle(bitWidth).Lit(_.value1 -> a.U, _.value2 -> b.U)
  }
  val outputBundles = testValues.map { case (a, b, c) =>
    new GcdOutputBundle(bitWidth).Lit(_.value1 -> a.U, _.value2 -> b.U, _.gcd -> c.U)
  }
  @Setup(Level.Trial)
  override def setup(): Unit = {
    super.setup()
  }
}

class DecoupledGcdTester {
  @Benchmark
  @Fork(value = 1, warmups = 0)
  def testbenchGCD(state: BenchmarkStateDecoupledGcd): Unit = {
    state.test{ dut =>
      val inputCmds = new DecoupledCommands(dut.input)
      val outputCmds = new DecoupledCommands(dut.output)

      dut.reset.poke(true.B)
      chiseltest.testableClock(dut.clock).step(2)
      dut.reset.poke(false.B)
      dut.clock.setTimeout(1000)

      val program: Command[Seq[GcdOutputBundle]] = for {
        pushThread <- simcommand.fork(inputCmds.enqueueSeq(state.inputBundles.toVector), "push")
        pullThread <- simcommand.fork(outputCmds.dequeueN(state.outputBundles.length),"pull")
        _ <- join(pushThread)
        output <- join(pullThread)
      } yield output

      val result = unsafeRun(program, dut.clock)
      Predef.assert(result.retval.length == state.outputBundles.length)
      result.retval.zip(state.outputBundles).foreach { case (actual, gold) =>
        Predef.assert(actual.gcd.litValue == gold.gcd.litValue)
        Predef.assert(actual.value1.litValue == gold.value1.litValue)
        Predef.assert(actual.value2.litValue == gold.value2.litValue)
      }
    }
  }
}
