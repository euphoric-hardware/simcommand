package neuroproc.systemtests

import chiseltest._
import chisel3._
import chisel3.stage.{ChiselCircuitAnnotation, ChiselGeneratorAnnotation, DesignAnnotation}
import firrtl.options.TargetDirAnnotation
import neuroproc._
import chiseltest.simulator.{SimulatorContext}
import firrtl.{AnnotationSeq, EmittedCircuitAnnotation}
import firrtl.annotations.{Annotation, DeletedAnnotation}
import firrtl.stage.FirrtlCircuitAnnotation
import logger.LogLevelAnnotation

import scala.collection.mutable

class NeuromorphicProcessorRawSimulatorTester extends NeuromorphicProcessorTester {

  def runTest(dut: SimulatorContext): Long = {
    var cycles = 0
    // Reset inputs
    dut.poke("io_uartRx", 1)
    assert(dut.peek("io_uartTx") == 1)
    dut.poke("reset", 1)
    dut.step()
    cycles += 1
    dut.poke("reset", 0)
    assert(dut.peek("io_uartTx") == 1)

    // Spawn a receiver thread
    val spikeRxThread = new SpikeReceiverSim(bitDelay)

    // Load an image into the accelerator ...
    val bytes = image.indices.flatMap { i =>
      Seq((i >> 8) & 0xff, i & 0xff, (image(i) >> 8) & 0xff, image(i) & 0xff)
    }
    val txThread = new UartTxThreadSim(bitDelay, bytes)

    def step(): Unit = {
      spikeRxThread.step(dut)
      txThread.step(dut)
      dut.step()
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
    cycles
  }

  it should "process an image" taggedAs (SlowTest) in {

    val startElab = System.nanoTime()

    // elaborate and compile to low firrtl
    val targetDir = TargetDirAnnotation("test_run_dir/NeuromorphicProcessorRawSimulatorTester")
    val stage = new chisel3.stage.ChiselStage()
    val r = stage.run(Seq(
      ChiselGeneratorAnnotation(() => new NeuromorphicProcessor()),
      targetDir,
    ))
    val state = annosToState(r)
    val dut = VerilatorBackendAnnotation.getSimulator.createContext(state)

    println(s"Took ${(System.nanoTime() - startElab) / 1e9d}s to elaborate, compile and create simulation")

    val startTest = System.nanoTime()
    // perform reset which is normally implicitly done by the chiseltest library
    dut.poke("reset", 1) ; dut.step() ; dut.poke("reset", 0)
    val cycles = runTest(dut) + 1
    val deltaSeconds = (System.nanoTime() - startTest) / 1e9d
    println(s"Took ${deltaSeconds}s to run test with manual threading and raw simulator interface")
    println(s"Executed $cycles cycles at an average frequency of ${cycles / deltaSeconds} Hz")
  }

  // copied over from chiseltest
  private def annosToState(annos: AnnotationSeq): firrtl.CircuitState = {
    val circuit = annos.collectFirst { case FirrtlCircuitAnnotation(c) => c }.get
    val filteredAnnos = annos.filterNot(isInternalAnno)
    firrtl.CircuitState(circuit, filteredAnnos)
  }
  private def isInternalAnno(a: Annotation): Boolean = a match {
    case _: FirrtlCircuitAnnotation | _: DesignAnnotation[_] | _: ChiselCircuitAnnotation | _: DeletedAnnotation |
         _: EmittedCircuitAnnotation[_] | _: LogLevelAnnotation =>
      true
    case _ => false
  }
}

trait IsThreadSim {
  def done: Boolean
  def step(dut: SimulatorContext): Unit
}

class SpikeReceiverSim(bitDelay: Int) extends IsThreadSim {
  private val rx = new UartRxThreadSim(bitDelay)
  var spikes = Array[Int]()
  def done: Boolean = rx.done
  def step(dut: SimulatorContext): Unit = {
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

class UartTxThreadSim(bitDelay: Int, toSend: Seq[Int]) extends IsThreadSim {
  private var state = 0;
  private var delay_count = 0;
  private var byte = 0;
  private val bytes = mutable.Queue[Int]()
  bytes ++= toSend

  def done: Boolean = bytes.isEmpty && delay_count == 0 && state == 0
  def step(dut: SimulatorContext): Unit = {
    if (delay_count > 0) {
      delay_count -= 1
    } else {
      state = if (state == 0) {
        if(bytes.nonEmpty) {
          byte = bytes.dequeue()
          // Start bit
          dut.poke("io_uartRx", 0)
          delay_count = bitDelay - 1
          1
        } else {
          0
        }
      } else if(state >= 1 && state < 9) {
        val bit = ((byte >> (state - 1)) & 1)
        dut.poke("io_uartRx", bit)
        delay_count = bitDelay - 1
        state + 1
      } else {
        assert(state == 9)
        // Stop bit
        dut.poke("io_uartRx", 1)
        delay_count = bitDelay - 1
        0
      }
    }
  }
}


class UartRxThreadSim(bitDelay: Int) extends IsThreadSim {
  private var state = 0;
  private var delay_count = 0;
  private var byte = 0;
  private val bytes = mutable.Queue[Int]()
  def get(): Option[Int] = if(bytes.isEmpty) { None } else { Some(bytes.dequeue()) }

  def done: Boolean = bytes.isEmpty && delay_count == 0 && state == 0
  def step(dut: SimulatorContext): Unit = {
    if (delay_count > 0) {
      delay_count -= 1
    } else {
      state = if (state == 0) {
        if (dut.peek("io_uartTx") == 0) {
          delay_count = bitDelay - 1
          byte = 0
          1
        } else {
          0
        }
      } else if(state >= 1 && state < 9) {
        byte = (dut.peek("io_uartTx").toInt << (state - 1)) | byte
        delay_count = bitDelay - 1
        state + 1
      } else {
        assert(state == 9)
        bytes.enqueue(byte)
        assert(dut.peek("io_uartTx") == 1, "stop bit")
        0
      }
    }
  }
}
