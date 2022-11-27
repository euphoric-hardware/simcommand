package benchmarks

import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

import java.io.{FileNotFoundException, IOException}
import scala.io.Source

abstract class NeuromorphicProcessorTester extends AnyFlatSpec with ChiselScalatestTester {
  behavior of s"Neuromorphic Processor"

  // Copied from https://github.com/hansemandse/KWSonSNN/blob/master/src/main/scala/neuroproc/package.scala#L6
  val FREQ             = 80000000             // in Hz
  val BAUDRATE         = 115200
  val USEROUNDEDWGHTS  = true

  val bitDelay = FREQ / BAUDRATE + 1

  def fetch(resource: String) = {
    Source.fromResource(resource).getLines().mkString.split(",").map(_.toInt)
  }

  // Reference image and results
  val image = fetch("NeuromorphicProcessor/image.txt")
  val results = if (USEROUNDEDWGHTS) {
    fetch("NeuromorphicProcessor/results_round.txt")
  } else {
    fetch("NeuromorphicProcessor/results_toInt.txt")
  }
}
