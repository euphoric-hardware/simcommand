package jmhbenchmarks

import chisel3._
import chisel3.util.Counter
import chiseltest._
import org.openjdk.jmh.annotations.{Benchmark, Level, Scope, Setup, State, Fork => JMHFork}
import simcommand._

class Staller extends Module {
  val a = IO(Output(Bool()))
  val c = Counter(1<<24)
  c.inc()
  a := c.value >= 100000.U
}

@State(Scope.Thread)
class BenchmarkStateStaller() extends BenchmarkState[Staller](() => new Staller()) {
  final val ITER: Int = 100000
  @Setup(Level.Trial)
  override def setup(): Unit = {
    super.setup()
  }
}

class TailRecTester {
  @Benchmark
  @JMHFork(value = 1, warmups = 0)
  def testbenchRecursive(state: BenchmarkStateStaller) {
    state.test { c =>
      c.clock.setTimeout(state.ITER * 10)
      val program = lift(()).tailRecM(_ => for {
        time <- step(1)
        ok <- peek(c.a)
      } yield if (ok.litToBoolean) Right(time) else Left(()))
      val res = unsafeRun(program, c.clock)
      assert(res.retval == 100000)
    }
  }

  @Benchmark
  @JMHFork(value = 1, warmups = 0)
  def testbenchImperative(state: BenchmarkStateStaller) {
    state.test { c =>
      c.clock.setTimeout(state.ITER * 10)
      val program = lift(()).tailRec(_ => for {
        time <- step(1)
        ok <- peek(c.a)
      } yield if (ok.litToBoolean) Right(time) else Left(()))
      val res = unsafeRun(program, c.clock)
      assert(res.retval == 100000)
    }
  }
}
