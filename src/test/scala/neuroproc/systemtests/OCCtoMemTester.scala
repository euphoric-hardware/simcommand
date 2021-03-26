package neuroproc.systemtests

import neuroproc._

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers
import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.{VerilatorBackendAnnotation, WriteVcdAnnotation}

class OCCtoMemTester extends AnyFlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Off-chip Communication with memory"

  it should "work with dual-port memory" taggedAs(SlowTest) in {
    test(new Module {
      val io = IO(new Bundle {
        val rx = Input(Bool())
        val inC0HSin  = Input(Bool())
        val inC1HSin  = Input(Bool())

        val clkb   = Input(Bool())

        val enb0   = Input(Bool())
        val addrb0 = Input(UInt((RATEADDRWIDTH+1).W))
        val dob0   = Output(UInt(RATEWIDTH.W))

        val enb1   = Input(Bool())
        val addrb1 = Input(UInt((RATEADDRWIDTH+1).W))
        val dob1   = Output(UInt(RATEWIDTH.W))
      })

      // Off-chip communication
      val oc = Module(new OffChipCom(FREQ, BAUDRATE))
      oc.io.rx     := io.rx
      oc.io.qData  := 0.U
      oc.io.qEmpty := true.B
      oc.io.inC0HSin := io.inC0HSin
      oc.io.inC1HSin := io.inC1HSin

      // True dual port memories
      val mem0 = Module(TrueDualPortMemory(RATEADDRWIDTH+1, RATEWIDTH))
      mem0.io.clka  := clock.asBool
      mem0.io.clkb  := io.clkb
      mem0.io.web   := false.B
      mem0.io.dib   := 0.U
      mem0.io.enb   := io.enb0
      mem0.io.addrb := io.addrb0
      io.dob0 := mem0.io.dob

      val mem1 = Module(TrueDualPortMemory(RATEADDRWIDTH+1, RATEWIDTH))
      mem1.io.clka  := clock.asBool
      mem1.io.clkb  := io.clkb
      mem1.io.web   := false.B
      mem1.io.dib   := 0.U
      mem1.io.enb   := io.enb1
      mem1.io.addrb := io.addrb1
      io.dob1 := mem1.io.dob

      // Interconnect
      mem0.io.ena   := oc.io.inC0We
      mem0.io.wea   := oc.io.inC0We
      mem0.io.addra := oc.io.inC0Addr
      mem0.io.dia   := oc.io.inC0Di

      mem1.io.ena   := oc.io.inC1We
      mem1.io.wea   := oc.io.inC1We
      mem1.io.addra := oc.io.inC0Addr
      mem1.io.dia   := oc.io.inC1Di

    }).withAnnotations(Seq(WriteVcdAnnotation, VerilatorBackendAnnotation)) {
      dut =>
        val delay = FREQ / BAUDRATE + 1
        val numTests = 64

        def recByte(byte: UInt) = {
          dut.io.rx.poke(false.B)
          dut.clock.step(delay)
          for (i <- 0 until 8) {
            dut.io.rx.poke(byte(i))
            dut.clock.step(delay)
          }
          dut.io.rx.poke(true.B)
          dut.clock.step(delay)
        }

        def stepClkb(cycles: Int = 1) = {
          for (_ <- 0 until cycles) {
            dut.io.clkb.poke(true.B)
            dut.io.clkb.poke(false.B)
          }
        }

        // Reset inputs
        dut.clock.setTimeout(10*numTests*delay)
        dut.io.rx.poke(true.B)
        dut.io.inC0HSin.poke(true.B)
        dut.io.inC1HSin.poke(true.B)
        dut.io.clkb.poke(false.B)
        dut.io.enb0.poke(false.B)
        dut.io.addrb0.poke(0.U)
        dut.io.enb1.poke(false.B)
        dut.io.addrb1.poke(0.U)
        dut.clock.step()

        // Force a phase change
        dut.io.inC0HSin.poke(false.B)
        dut.io.inC1HSin.poke(false.B)
        dut.clock.step()

        // Receive a frequency for each memory and check that they are
        // correctly received in either
        var mem0 = Array.fill(1 << (RATEADDRWIDTH+1))(BigInt(0))
        print("Receiving word for memory 0 --- ")
        val ind0 = 151.U(16.W)
        val frq0  = 42.U(16.W)
        recByte(ind0(15, 8))
        recByte(ind0( 7, 0))
        recByte(frq0(15, 8))
        recByte(frq0( 7, 0))
        println("received")
        mem0(ind0.litValue.intValue + NEURONSPRCORE) = frq0.litValue
        
        var mem1 = Array.fill(1 << (RATEADDRWIDTH+1))(BigInt(0))
        print("Receiving word for memory 1 --- ")
        val ind1 = 333.U(16.W)
        val frq1 = 197.U(16.W)
        recByte(ind1(15, 8))
        recByte(ind1( 7, 0))
        recByte(frq1(15, 8))
        recByte(frq1( 7, 0))
        println("received")
        mem1((ind1.litValue.intValue & 0xff) + NEURONSPRCORE) = frq1.litValue

        // Read out the values again
        dut.io.addrb0.poke((ind0.litValue + NEURONSPRCORE).U)
        dut.io.enb0.poke(true.B)
        dut.io.addrb1.poke(((ind1.litValue & 0xff) + NEURONSPRCORE).U)
        dut.io.enb1.poke(true.B)
        stepClkb()
        dut.io.enb0.poke(false.B)
        dut.io.enb1.poke(false.B)
        dut.io.dob0.expect(frq0)
        dut.io.dob1.expect(frq1)

        // Repeat the above for random inputs
        val rng = new scala.util.Random(42)
        val testInds = Array.fill(numTests) { rng.nextInt(INPUTSIZE).U(16.W) }
        val testFrqs = Array.fill(numTests) { BigInt(RATEWIDTH, rng).U(16.W) }
        for (v <- testInds.zip(testFrqs)) {
          recByte(v._1(15, 8))
          recByte(v._1( 7, 0))
          recByte(v._2(15, 8))
          recByte(v._2( 7, 0))
          if (v._1.litValue >= NEURONSPRCORE)
            mem1((v._1.litValue.intValue & 0xff) + NEURONSPRCORE) = v._2.litValue
          else
            mem0(v._1.litValue.intValue + NEURONSPRCORE) = v._2.litValue
        }

        // Check the memories
        for (i <- 0 until (1 << (RATEADDRWIDTH+1))) {
          dut.io.enb0.poke(true.B)
          dut.io.addrb0.poke(i.U)
          dut.io.enb1.poke(true.B)
          dut.io.addrb1.poke(i.U)
          dut.clock.step()
          stepClkb()
          dut.io.dob0.expect(mem0(i).U)
          dut.io.dob1.expect(mem1(i).U)
        }
    }
  }

  it should "work with FIFO queue" in {
    test(new Module {
      val io = IO(new Bundle {
        val clki  = Input(Bool())
        val we    = Input(Bool())
        val datai = Input(UInt(8.W))
        val full  = Output(Bool())

        val tx    = Output(Bool())
      })

      // Off-chip communication
      val oc = Module(new OffChipCom(FREQ, BAUDRATE))
      oc.io.rx       := true.B // \
      oc.io.inC0HSin := true.B // Force staying in idle state without receiving anything
      oc.io.inC1HSin := true.B // /
      io.tx          := oc.io.tx

      // True dual port memory-based FIFO
      val fifo = Module(TrueDualPortFIFO(16, 8))
      fifo.io.clki  := io.clki
      fifo.io.we    := io.we
      fifo.io.datai := io.datai
      io.full       := fifo.io.full
      fifo.io.clko  := clock.asBool

      // Interconnect
      fifo.io.en   := oc.io.qEn
      oc.io.qData  := fifo.io.datao
      oc.io.qEmpty := fifo.io.empty

    }).withAnnotations(Seq(WriteVcdAnnotation, VerilatorBackendAnnotation)) {
      dut =>
        val delay = FREQ / BAUDRATE + 1
        val numTests = 64

        def transferByte() = {
          var byte = 0
          // Assumes start bit has already been seen
          dut.clock.step(delay)
          // Byte
          for (i <- 0 until 8) {
            byte = (dut.io.tx.peek.litToBoolean << i) | byte
            dut.clock.step(delay)
          }
          // Stop bit
          dut.io.tx.expect(true.B)
          dut.clock.step(delay)
          byte
        }

        def stepClki(cycles: Int = 1) = {
          for (_ <- 0 until cycles) {
            dut.io.clki.poke(true.B)
            dut.io.clki.poke(false.B)
          }
        }

        // Reset inputs
        dut.clock.setTimeout(10*numTests*delay)
        dut.io.clki.poke(false.B)
        dut.io.we.poke(false.B)
        dut.io.datai.poke(0.U)
        dut.reset.poke(true.B)
        dut.clock.step()
        stepClki()
        dut.reset.poke(false.B)
        dut.io.full.expect(false.B)
        dut.io.tx.expect(true.B)

        // Write one value to the FIFO and check that it is output correctly
        dut.io.we.poke(true.B)
        dut.io.datai.poke(42.U)
        dut.clock.step()
        stepClki()
        dut.io.we.poke(false.B)
        dut.clock.step()
        stepClki()
        while (dut.io.tx.peek.litToBoolean)
          dut.clock.step()
        val recB = transferByte()
        assert(42 == recB)

        // Repeat the above test with a number of random inputs
        val rng = new scala.util.Random(42)
        val testVals = Array.fill(64) { BigInt(8, rng).U(8.W) }

        // Write the bytes to the queue
        val writer = fork {
          for (v <- testVals) {
            dut.io.we.poke(false.B)
            dut.io.datai.poke(v)
            while (dut.io.full.peek.litToBoolean) {
              dut.clock.step()
              stepClki()
            }
            dut.io.we.poke(true.B)
            dut.clock.step()
            stepClki()
            println(s"Wrote ${v.litValue} to FIFO")
          }
        }
        
        // Receive the transmitted bytes
        for (v <- testVals) {
          while (dut.io.tx.peek.litToBoolean)
            dut.clock.step()
          val b = transferByte()
          assert(v.litValue == b)
          println(s"Received ${b}")
        }
        writer.join
    }
  }
}
