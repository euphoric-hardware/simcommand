package neuroproc.unittests

import neuroproc._

import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.{VerilatorBackendAnnotation, WriteVcdAnnotation}
import org.scalatest._

class EvaluationMemoryTester extends FlatSpec with ChiselScalatestTester {
  behavior of "Evaluation Memory"

  def fetch(file: String) = scala.io.Source.fromFile(file).getLines.map { Integer.parseInt(_, 2) }.toArray

  def rwTest(dut: EvaluationMemory, core: Int, eval: Int) = {
    val constLines  = fetch(s"mapping/meminit/constc${core}.mem")
    val dynaLines   = fetch(s"mapping/meminit/potrefc${core}.mem")
    val weightLines = fetch(s"mapping/meminit/weightsc${core}e${eval}.mem")
    val btLines     = fetch(s"mapping/meminit/biasthreshc${core}e${eval}.mem")

    // Reset input signals
    dut.io.addr.sel.poke(const)
    dut.io.addr.pos.poke(0.U)
    dut.io.wr.poke(false.B)
    dut.io.ena.poke(true.B)
    dut.io.writeData.poke(0.S)
    
    // Read a few random addresses
    val rng = new scala.util.Random(42)
    for (_ <- 0 until 1024) {
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
      println(s"Reading select=${sel} position=${pos}")
      dut.io.readData.expect(
        sel match {
          // Reset potential is converted to 7.10, but others keep their format
          case 0 => if (pos == 0) (constLines(pos) << 10).S else constLines(pos).S
          case 1 => dynaLines(pos).S
          case 2 => btLines(pos).S
          case _ => if ((weightLines(pos) & (1 << 10)) > 0) {
            // Weight is in 6.4 format and _may_ be negative
            val shift = ((weightLines(pos) & ((1 << 10) - 1)) << 6)
            if (shift > ((1 << 15) - 1)) (shift - (1 << 16)).S else shift.S
          } else {
            // Weight is in 0.10 format and is never negative
            weightLines(pos).S
          }
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

  def selTest(dut: EvaluationMemory, core: Int, eval: Int) = {
    val constLines  = fetch(s"mapping/meminit/constc${core}.mem")
    val dynaLines   = fetch(s"mapping/meminit/potrefc${core}.mem")
    val weightLines = fetch(s"mapping/meminit/weightsc${core}e${eval}.mem")
    val btLines     = fetch(s"mapping/meminit/biasthreshc${core}e${eval}.mem")

    // Reset input signals
    dut.io.addr.sel.poke(const)
    dut.io.addr.pos.poke(0.U)
    dut.io.wr.poke(false.B)
    dut.io.ena.poke(true.B)
    dut.io.writeData.poke(0.S)

    // Read out from one memory and then another
    dut.clock.step()
    dut.io.addr.sel.poke(dynamic)
    dut.io.readData.expect((constLines(0) << 10).S)
    dut.clock.step()
    dut.io.addr.sel.poke(biasthresh)
    dut.io.readData.expect(dynaLines(0).S)
    dut.clock.step()
    dut.io.addr.sel.poke(weights)
    dut.io.readData.expect(btLines(0).S)
    dut.clock.step()
    dut.io.addr.sel.poke(const)
    dut.io.readData.expect(
      if ((weightLines(0) & (1 << 10)) > 0 )
        ((weightLines(0) & ((1 << 10) - 1)) << 4).S
      else
        weightLines(0).S
    )
  }

  Seq(2, 3).foreach { core =>
    it should s"read and write for core $core" in {
      test(new EvaluationMemory(core, core-2))
        .withAnnotations(Seq(VerilatorBackendAnnotation, WriteVcdAnnotation)) {
        dut => rwTest(dut, core, core-2)
      }
    }

    it should s"work with changing selects for core $core" in {
      test(new EvaluationMemory(core, core-2))
        .withAnnotations(Seq(VerilatorBackendAnnotation, WriteVcdAnnotation)) {
        dut => selTest(dut, core, core-2)
      }
    }
  }
}
