package neuroproc.systemtests

import neuroproc._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import java.io.{FileNotFoundException, IOException}

abstract class NeuromorphicProcessorTester extends AnyFlatSpec with ChiselScalatestTester {
  behavior of s"Neuromorphic Processor"

  val bitDelay = FREQ / BAUDRATE + 1

  def fetch(file: String) = {
    val src = scala.io.Source.fromFile(file)
    val lines = try {
      src.mkString
    } catch {
      case e: FileNotFoundException => {
        println("Incorrect path to image file")
        ""
      }
      case e: IOException => {
        println("Cannot open image file")
        ""
      }
    } finally {
      src.close
    }
    lines.split(",").map(_.toInt)
  }

  // Reference image and results
  val image = fetch("./src/test/scala/neuroproc/systemtests/image.txt")
  val results = if (USEROUNDEDWGHTS) {
    fetch("./src/test/scala/neuroproc/systemtests/results_round.txt")
  } else {
    fetch("./src/test/scala/neuroproc/systemtests/results_toInt.txt")
  }
}