package neuroproc.unittests

import neuroproc._

import org.scalatest.flatspec.AnyFlatSpec
import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.{WriteVcdAnnotation, VerilatorBackendAnnotation}

class TrueDualPortMemoryTester extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "True dual port memory"

  val addrW = 10
  val dataW = 32
  val numTests = 256

  val rng = new scala.util.Random(42)
  val writeAddrAs = Array.fill(numTests) { BigInt(addrW, rng) }
  val addrBs = writeAddrAs.map { x => (x + BigInt(addrW, rng)) & ((BigInt(1) << addrW) - 1) }
  val writeAddrBs = writeAddrAs.zip(addrBs)
    .map(x => if (x._1 == x._2) (x._1 + 1) & ((BigInt(1) << addrW) - 1) else x._2)
  val weAs = Array.fill(numTests) { rng.nextBoolean }
  val weBs = Array.fill(numTests) { rng.nextBoolean }
  val writeDatas = Array.fill(numTests) { BigInt(dataW, rng) & ((BigInt(1) << dataW) - 1) }

  it should "work with special clock" in {
    test(new Module {
      val io = IO(new Bundle {
        val inClk = Input(Bool())
        val en = Input(Bool())
        val we = Input(Bool())
        val ad = Input(UInt(10.W))
        val dI = Input(UInt(8.W))
        val dO = Output(UInt(8.W))
      })
      
      val ram = SyncReadMem(1024, UInt(8.W))

      withClock(io.inClk.asClock) {
        io.dO := DontCare
        when(io.en) {
          when(io.we) {
            ram(io.ad) := io.dI
          }
          io.dO := ram(io.ad)
        }
      }
    }).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.io.en.poke(false.B)
        dut.io.we.poke(false.B)
        dut.io.ad.poke(0.U)
        dut.io.dI.poke(0.U)
        dut.io.dO.expect(0.U)
        dut.io.inClk.poke(false.B)

        // Write something
        dut.io.en.poke(true.B)
        dut.io.we.poke(true.B)
        dut.io.ad.poke(42.U)
        dut.io.dI.poke(13.U)
        dut.io.inClk.poke(true.B)
        dut.clock.step()
        dut.io.inClk.poke(false.B)
        dut.io.en.poke(false.B)
        dut.io.we.poke(false.B)
        dut.io.ad.poke(0.U)
        dut.io.dI.poke(0.U)
        dut.io.inClk.poke(true.B)
        dut.clock.step()
        dut.io.inClk.poke(false.B)

        // Read it back
        dut.io.en.poke(true.B)
        dut.io.ad.poke(42.U)
        dut.io.inClk.poke(true.B)
        dut.clock.step()
        dut.io.inClk.poke(false.B)
        dut.io.dO.expect(13.U)
    }
  }

  def testFn(dut: TrueDualPortMemory) = {
    dut.clock.setTimeout(10 * (1 << addrW))
    val clka = dut.io.clka
    val clkb = dut.io.clkb

    def stepAndAdvance(clk: Bool) = {
      clk.poke(true.B)
      dut.clock.step()
      clk.poke(false.B)
    }
      
    // Model the memory as a mutable array
    var ram = Array.fill(1 << addrW) { BigInt(0) }
      
    // Default values
    dut.io.ena.poke(false.B)
    dut.io.wea.poke(false.B)
    dut.io.addra.poke(0.U)
    dut.io.dia.poke(0.U)
    clka.poke(false.B)
  
    dut.io.enb.poke(false.B)
    dut.io.web.poke(false.B)
    dut.io.addrb.poke(0.U)
    dut.io.dib.poke(0.U)
    clkb.poke(false.B)
        
    // Check that the memory is all zeros
    val portBc = fork {
      dut.io.enb.poke(true.B)
      for (i <- 0 until (1 << addrW)) {
        dut.io.addrb.poke(i.U)
        stepAndAdvance(clkb)
        dut.io.dob.expect(0.U)
      }
      dut.io.enb.poke(false.B)
    }
    dut.io.ena.poke(true.B)
    for (i <- 0 until (1 << addrW)) {
      dut.io.addra.poke(i.U)
      stepAndAdvance(clka)
      dut.io.doa.expect(0.U)
    }
    dut.io.ena.poke(false.B)
    portBc.join
      
    // Fork a handler for port b
    val portBw = fork {
      dut.io.enb.poke(true.B)
      (writeAddrBs, writeDatas, weBs).zipped.toArray.foreach { x =>
        dut.io.addrb.poke(x._1.U)
        dut.io.dib.poke(x._2.U)
        dut.io.web.poke(x._3.B)
        if (x._3)
          ram(x._1.toInt) = x._2
        stepAndAdvance(clkb)
      }
      dut.io.enb.poke(false.B)
    } 
      
    // Write on port a
    dut.io.ena.poke(true.B)
    (writeAddrAs, writeDatas, weAs).zipped.toArray.foreach { x =>
      dut.io.addra.poke(x._1.U)
      dut.io.dia.poke(x._2.U)
      dut.io.wea.poke(x._3.B)
      if (x._3)
        ram(x._1.toInt) = x._2
      stepAndAdvance(clka)
    }
    dut.io.ena.poke(false.B)
    portBw.join()
      
    // Fork a handler for port b
    val portBr = fork {
      dut.io.enb.poke(true.B)
      for (i <- 0 until (1 << addrW)) {
        dut.io.addrb.poke(i.U)
        stepAndAdvance(clkb)
        dut.io.dob.expect(ram(i).U)
      }
      dut.io.enb.poke(false.B)
    }
  
    // Read out values on port a
    dut.io.ena.poke(true.B)
    for (i <- 0 until (1 << addrW)) {
      dut.io.addra.poke(i.U)
      stepAndAdvance(clka)
      dut.io.doa.expect(ram(i).U)
    }
    dut.io.ena.poke(false.B)
    portBr.join
  }

  it should "work in Verilog" in {
    test(TrueDualPortMemory(addrW, dataW, true))
      .withAnnotations(Seq(VerilatorBackendAnnotation, WriteVcdAnnotation)) {
        dut => testFn(dut)
      }
  }

  it should "work in Chisel" in {
    test(TrueDualPortMemory(addrW, dataW, false))
      .withAnnotations(Seq(VerilatorBackendAnnotation, WriteVcdAnnotation)) {
        dut => testFn(dut)
      }
  }
}
