package jmhbenchmarks

import chisel3._
import chisel3.util.Counter
import chiseltest._
import org.openjdk.jmh.annotations.{Benchmark, Fork => JMHFork}
import simcommand._
import org.openjdk.jmh.annotations.{Level, Scope, Setup, State}

import java.util.concurrent.Executors
import scala.async.Async.{async, await}
import scala.concurrent.duration._
import scala.concurrent.{Await, ExecutionContext, Future}

class Peekable extends Module {
  val a = IO(Output(UInt(32.W)))
  val c = Counter(128)
  c.inc()
  a := c.value
}

@State(Scope.Thread)
class BenchmarkStatePeekable() extends BenchmarkState[Peekable](() => new Peekable()) {
  final val ITER: Int = 20000
  @Setup(Level.Trial)
  override def setup(): Unit = {
    super.setup()
  }
}

class AsyncAwaitTester {
  @Benchmark
  @JMHFork(value = 1, warmups = 0)
  def testbenchAsync(state: BenchmarkStatePeekable) {
    val executor = Executors.newSingleThreadExecutor()
    implicit val ec = scala.concurrent.ExecutionContext.fromExecutor(executor)
    state.test { c =>
      c.clock.setTimeout(state.ITER * 10)
      for (i <- 0 to state.ITER) {
        val fut = async {
          await(async {
            assert(c.a.peek().litValue == i % 128)
          })
          await(async {
            c.clock.step(1)
          })
        }
        Await.result(fut, 1.seconds)
      }
    }
    executor.shutdown()
  }

  @Benchmark
  @JMHFork(value = 1, warmups = 0)
  def testbenchAsyncRecursive(state: BenchmarkStatePeekable) {
    val executor = Executors.newSingleThreadExecutor()
    implicit val ec = scala.concurrent.ExecutionContext.fromExecutor(executor)

    def f(i: Int, c: Peekable)(implicit ec: ExecutionContext): Future[Int] = if (i < state.ITER) async {
      await(async {
        assert(c.a.peek().litValue == i % 128)
      })
      await(async {
        c.clock.step(1)
      })
      await(f(i + 1, c))
    } else async(i)

    state.test { c =>
      c.clock.setTimeout(state.ITER * 10)
      Await.result(f(0, c)(ec), 1000.seconds)
    }

    executor.shutdown()
  }

  @Benchmark
  @JMHFork(value = 1, warmups = 0)
  def testbenchStraightLineChiselTest(state: BenchmarkStatePeekable) {
    state.test { c =>
      c.clock.setTimeout(state.ITER * 10)
      for (i <- 0 to state.ITER) {
        assert(c.a.peek().litValue == i % 128)
        c.clock.step(1)
      }
    }
  }

  @Benchmark
  @JMHFork(value = 1, warmups = 0)
  def testbenchCommand(state: BenchmarkStatePeekable) {
    state.test { c =>
      c.clock.setTimeout(state.ITER * 10)
      val program = repeatCollect(for {
        y <- peek(c.a)
        _ <- step(1)
      } yield y.litValue, state.ITER)
      val res = unsafeRun(program, c.clock)
      assert(res.retval == Seq.range(0, state.ITER).map(_ % 128))
    }
  }
}
