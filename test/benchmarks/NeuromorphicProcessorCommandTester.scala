package benchmarks

import simcommand._
import chisel3._
import chiseltest._
import chiseltest.internal.NoThreadingAnnotation
import simcommand.UARTCommands

class NeuromorphicProcessorCommandTester extends NeuromorphicProcessorTester {
  it should "process an image" in {
    val startElab = System.nanoTime()
    test(new NeuromorphicProcessorBBWrapper())
      .withAnnotations(Seq(VerilatorBackendAnnotation, NoThreadingAnnotation)) { dut =>
        println(s"Took ${(System.nanoTime() - startElab) / 1e9d}s to elaborate, compile and create simulation")
        val startTest = System.nanoTime()
        dut.clock.setTimeout(FREQ)

        // Reset inputs
        dut.io.io_uartRx.poke(true.B)
        dut.io.io_uartTx.expect(true.B)
        dut.reset.poke(true.B)
        dut.clock.step()
        dut.reset.poke(false.B)
        dut.io.io_uartTx.expect(true.B)

        // Load an image into the accelerator ...
        val bytes = image.indices.flatMap { i =>
          Seq((i >> 8) & 0xff, i & 0xff, (image(i) >> 8) & 0xff, image(i) & 0xff)
        }
        val commands = new UARTCommands(dut.io.io_uartRx, dut.io.io_uartTx, bitDelay)
        val receiver = commands.receiveBytes(110)
        val sender = commands.sendBytes(bytes)

        val program: Command[Seq[Int]] =
          for {
            rxThread <- simcommand.fork(receiver, "receiver")
            txThread <- simcommand.fork(sender, "sender")
            _ <- {
              println("Loading image into accelerator")
              noop()
            }
            _ <- join(txThread)
            _ <- {
              println("Done loading image")
              println("getting accelerator's response")
              noop()
            }
            resp <- join(rxThread) // Step(FREQ/2) used in original testbench
            _ <- {
              println("Response received - comparing results")
              noop()
            }
          } yield resp

        val result = unsafeRun(program, dut.clock)
        val spikes = result.retval.filter(_ < 200)
        assert(spikes.length == results.length, "number of spikes does not match expected")
        assert(spikes.zip(results).map(x => x._1 == x._2).reduce(_ && _), "spikes do not match expected")

        val deltaSeconds = (System.nanoTime() - startTest) / 1e9d
        println(s"Took ${deltaSeconds}s to run test with the Command API using the chiseltest interface with the NoThreadingAnnotation")
        println(s"Executed ${result.cycles} cycles at an average frequency of ${result.cycles / deltaSeconds} Hz")
      }
  }
}
