package neuroproc.unittests

import neuroproc._

import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.{VerilatorBackendAnnotation, WriteVcdAnnotation}
import org.scalatest._

class EvaluationMemoryTester extends FlatSpec with ChiselScalatestTester {
  behavior of "Evaluation Memory"

  val coreID = 2
  val evalID = 0

  def fetch(file: String) = scala.io.Source.fromFile(file).getLines.map { Integer.parseInt(_, 2) }.toArray
  val constLines  = fetch("mapping/meminit/constc2.mem")
  val dynaLines   = fetch("mapping/meminit/potrefc2.mem")
  val weightLines = fetch("mapping/meminit/weightsc2e0.mem")
  val btLines     = fetch("mapping/meminit/biasthreshc2e0.mem")

  it should "read and write" in {
    test(new EvaluationMemory(coreID, evalID))
      .withAnnotations(Seq(VerilatorBackendAnnotation, WriteVcdAnnotation)) {
      dut =>
        // Reset input signals
        dut.io.addr.sel.poke(const)
        dut.io.addr.pos.poke(0.U)
        dut.io.wr.poke(false.B)
        dut.io.ena.poke(true.B)
        dut.io.writeData.poke(0.S)

        // Read a few random addresses
        val rng = new scala.util.Random(42)
        for (_ <- 0 until 256) {
          val sel = rng.nextInt(4)
          val pos = sel match {
            case 0 => rng.nextInt(constLines.length)
            case 1 => rng.nextInt(dynaLines.length)
            case 2 => rng.nextInt(btLines.length)
            case _ => rng.nextInt(weightLines.length)
          }
          dut.io.addr.sel.poke(sel.U)
          dut.io.addr.pos.poke(pos.U)
          dut.clock.step()
          dut.io.readData.expect(
            sel match {
              case 0 => constLines(pos).S
              case 1 => dynaLines(pos).S
              case 2 => btLines(pos).S
              // Weights can be negative but will be read as positive from the file, thus they need conversion
              case _ => if (weightLines(pos) > ((1 << (NEUDATAWIDTH-1)) - 1))
                  (weightLines(pos) - (1 << NEUDATAWIDTH)).S
                else 
                  weightLines(pos).S
            }
          )
        }
        
        // Write a few random addresses in the dynamic memory
        val windexes = Array.fill(32) { rng.nextInt(2*TMNEURONS) }
        var mem  = dynaLines.clone.map(BigInt(_))
        val data = Array.fill(32) { BigInt(NEUDATAWIDTH, rng) - (BigInt(1) << (NEUDATAWIDTH-1)) }
        dut.io.addr.sel.poke(dynamic)
        dut.io.wr.poke(true.B)
        for (elem <- windexes zip data) {
          dut.io.addr.pos.poke(elem._1.U)
          dut.io.writeData.poke(elem._2.S(NEUDATAWIDTH.W))
          dut.clock.step()
          mem(elem._1) = elem._2
        }

        // Read the values back
        dut.io.wr.poke(false.B)
        for (elem <- windexes zip data) {
          dut.io.addr.pos.poke(elem._1.U)
          dut.clock.step()
          dut.io.readData.expect(mem(elem._1).S(NEUDATAWIDTH.W))
        }
    }
  }

  it should "work with changing selects" in {
    test(new EvaluationMemory(coreID, evalID))
      .withAnnotations(Seq(VerilatorBackendAnnotation, WriteVcdAnnotation)) {
      dut =>
        // Reset input signals
        dut.io.addr.sel.poke(const)
        dut.io.addr.pos.poke(0.U)
        dut.io.wr.poke(false.B)
        dut.io.ena.poke(true.B)
        dut.io.writeData.poke(0.S)

        // Read out from one memory and then another
        dut.clock.step()
        dut.io.addr.sel.poke(dynamic)
        dut.io.readData.expect(constLines(0).S)
        dut.clock.step()
        dut.io.addr.sel.poke(biasthresh)
        dut.io.readData.expect(dynaLines(0).S)
        dut.clock.step()
        dut.io.addr.sel.poke(weights)
        dut.io.readData.expect(btLines(0).S)
        dut.clock.step()
        dut.io.addr.sel.poke(const)
        dut.io.readData.expect(weightLines(0).S)
    }
  }
}
