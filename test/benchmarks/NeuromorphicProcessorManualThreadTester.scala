package benchmarks

import chiseltest._
import chisel3._
import chiseltest.internal.NoThreadingAnnotation

import scala.collection.mutable


class NeuromorphicProcessorManualThreadTester extends NeuromorphicProcessorTester {
  it should "process an image" in {
    val startElab = System.nanoTime()
    test(new NeuromorphicProcessorBBWrapper())
      .withAnnotations(Seq(VerilatorBackendAnnotation, NoThreadingAnnotation)) { dut =>
        println(s"Took ${(System.nanoTime() - startElab) / 1e9d}s to elaborate, compile and create simulation")
        val startTest = System.nanoTime()
        var cycles = 1L
        dut.clock.setTimeout(FREQ)

        // Reset inputs
        dut.io.io_uartRx.poke(true.B)
        dut.io.io_uartTx.expect(true.B)
        dut.reset.poke(true.B)
        dut.clock.step()
        cycles += 1
        dut.reset.poke(false.B)
        dut.io.io_uartTx.expect(true.B)

        // Spawn a receiver thread
        val spikeRxThread = new SpikeReceiver(bitDelay)

        // Load an image into the accelerator ...
        val bytes = image.indices.flatMap { i =>
          Seq((i >> 8) & 0xff, i & 0xff, (image(i) >> 8) & 0xff, image(i) & 0xff)
        }
        val txThread = new UartTxThread(bitDelay, bytes)

        def step(): Unit = {
          spikeRxThread.step(dut)
          txThread.step(dut)
          dut.clock.step()
          cycles += 1
        }

        println("Loading image into accelerator")
        while (!txThread.done) {
          step()
        }
        print("Done loading image - ")

        // ... get its response
        println("getting accelerator's response")
        (0 until (FREQ / 2)).foreach { ii =>
          step()
        }
        // join
        while (!spikeRxThread.done) {
          step()
        }

        println("Response received - comparing results")
        val spikes = spikeRxThread.spikes
        assert(spikes.length == results.length, "number of spikes does not match expected")
        assert(spikes.zip(results).map(x => x._1 == x._2).reduce(_ && _), "spikes do not match expected")

        val deltaSeconds = (System.nanoTime() - startTest) / 1e9d
        println(s"Took ${deltaSeconds}s to run test with manual threading and using the chiseltest interface with the NoThreadingAnnotation")
        println(s"Executed $cycles cycles at an average frequency of ${cycles / deltaSeconds} Hz")
      }
  }
}

trait IsThread {
  def done: Boolean
  def step(dut: NeuromorphicProcessorBBWrapper): Unit
}

class SpikeReceiver(bitDelay: Int) extends IsThread {
  private val rx = new UartRxThread(bitDelay)
  var spikes = Array[Int]()
  def done: Boolean = rx.done
  def step(dut: NeuromorphicProcessorBBWrapper): Unit = {
    rx.step(dut)
    rx.get() match {
      case Some(s) =>
        if (s < 200)
          spikes = spikes :+ s
        println(s"Received spike ${s}")
      case None =>
    }
  }
}

class UartTxThread(bitDelay: Int, toSend: Seq[Int]) extends IsThread {
  private var state = 0;
  private var delay_count = 0;
  private var byte = 0;
  private val bytes = mutable.Queue[Int]()
  bytes ++= toSend

  def done: Boolean = bytes.isEmpty && delay_count == 0 && state == 0
  def step(dut: NeuromorphicProcessorBBWrapper): Unit = {
    if (delay_count > 0) {
      delay_count -= 1
    } else {
      state = if (state == 0) {
        if(bytes.nonEmpty) {
          byte = bytes.dequeue()
          // Start bit
          dut.io.io_uartRx.poke(false.B)
          delay_count = bitDelay - 1
          1
        } else {
          0
        }
      } else if(state >= 1 && state < 9) {
        val bit = ((byte >> (state - 1)) & 1) == 1
        dut.io.io_uartRx.poke(bit)
        delay_count = bitDelay - 1
        state + 1
      } else {
        assert(state == 9)
        // Stop bit
        dut.io.io_uartRx.poke(true.B)
        delay_count = bitDelay - 1
        0
      }
    }
  }
}


class UartRxThread(bitDelay: Int) extends IsThread {
  private var state = 0;
  private var delay_count = 0;
  private var byte = 0;
  private val bytes = mutable.Queue[Int]()
  def get(): Option[Int] = if(bytes.isEmpty) { None } else { Some(bytes.dequeue()) }

  def done: Boolean = bytes.isEmpty && delay_count == 0 && state == 0
  def step(dut: NeuromorphicProcessorBBWrapper): Unit = {
    if (delay_count > 0) {
      delay_count -= 1
    } else {
      state = if (state == 0) {
        if (!dut.io.io_uartTx.peekBoolean()) {
          delay_count = bitDelay - 1
          byte = 0
          1
        } else {
          0
        }
      } else if(state >= 1 && state < 9) {
        byte = (dut.io.io_uartTx.peek().litValue.toInt << (state - 1)) | byte
        delay_count = bitDelay - 1
        state + 1
      } else {
        assert(state == 9)
        bytes.enqueue(byte)
        dut.io.io_uartTx.expect(true)
        0
      }
    }
  }
}