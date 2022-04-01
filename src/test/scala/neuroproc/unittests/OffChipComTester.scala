package neuroproc.unittests

import neuroproc._

import chisel3._
import chisel3.util.log2Up
import chiseltest._
import org.scalatest._

class OffChipComTester extends FlatSpec with ChiselScalatestTester {
  behavior of "Off-chip Communication"

  // Change these values for the tests - keep FREQ_L and BAUDRATE_L relatively low!
  val SCALE      = 8192
  val FREQ_L     = FREQ / SCALE
  val BAUDRATE_L = BAUDRATE / (SCALE / 8)
  val bitDelay   = FREQ_L / BAUDRATE_L + 1

  // Method to clear the inputs of the dut
  def resetInputs(dut: OffChipCom) = {
    dut.io.rx.poke(true.B)
    dut.io.qData.poke(0.U)
    dut.io.qEmpty.poke(true.B)
    dut.io.inC0HSin.poke(false.B)
    dut.io.inC1HSin.poke(false.B)
  }

  // Generalized transfer of a byte over UART
  def receiveByte(dut: OffChipCom, byte: UInt) = {
    byte.widthOption match {
      case Some(value) => require(value == 8)
      case None => throw new IllegalArgumentException("the byte must be 8 bits")
    }
    // Start bit
    dut.io.rx.poke(false.B)
    dut.clock.step(bitDelay)
    // Byte
    for (i <- 0 until 8) {
      dut.io.rx.poke(byte(i))
      dut.clock.step(bitDelay)
    }
    // Stop bit
    dut.io.rx.poke(true.B)
    dut.clock.step(bitDelay)
  }

  it should "receive a frequency" in {
    test(new OffChipCom(FREQ_L, BAUDRATE_L)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.clock.setTimeout(FREQ_L)
        resetInputs(dut)

        // For the first input core
        print("Receiving word for core 0 --- ")
        var index = 151.U(16.W)
        var freq  = 42.U(16.W)

        val c0w = fork {
          while (!dut.io.inC0We.peek.litToBoolean)
            dut.clock.step()
          dut.io.inC0Addr.expect((index.litValue + NEURONSPRCORE).U)
          dut.io.inC0Di.expect(freq)
          dut.clock.step()
        }

        receiveByte(dut, index(15, 8))
        receiveByte(dut, index( 7, 0))
        receiveByte(dut, freq(15, 8))
        receiveByte(dut, freq( 7, 0))
        print("received --- ")
        c0w.join
        println("data written to memory")

        // For the second input core
        print("Receiving word for core 1 --- ")
        index = 333.U(16.W)
        freq  = 197.U(16.W)

        val c1w = fork {
          while (!dut.io.inC1We.peek.litToBoolean)
            dut.clock.step()
          dut.io.inC1Addr.expect(((index.litValue & 0xff) + NEURONSPRCORE).U)
          dut.io.inC1Di.expect(freq)
          dut.clock.step()
        }

        receiveByte(dut, index(15, 8))
        receiveByte(dut, index( 7, 0))
        receiveByte(dut, freq(15, 8))
        receiveByte(dut, freq( 7, 0))
        print("received --- ")
        c1w.join
        println("data written to memory")
    }
  }

  it should "transfer a spike" in {
    test(new OffChipCom(FREQ_L, BAUDRATE_L)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.clock.setTimeout(FREQ_L)
        resetInputs(dut)
        dut.io.inC0HSin.poke(true.B)

        val testData = 42.U
        
        // Load a spike into the module
        dut.io.qEmpty.poke(false.B)
        dut.io.qData.poke(testData)
        while (!dut.io.qEn.peek.litToBoolean)
          dut.clock.step()
        dut.clock.step() // synchronous memory delay
        dut.clock.step() // buffer data
        dut.io.qData.poke(0.U)
        println("Loaded data")
        
        // Wait for start bit
        while (dut.io.tx.peek.litToBoolean)
          dut.clock.step()
        println("Start bit transmitted")
        
        // Check remaining bits
        dut.clock.step(bitDelay)
        for (i <- 0 until 8) {
          dut.io.tx.expect(testData(i))
          println(s"Found bit $i = ${dut.io.tx.peek.litToBoolean}")
          dut.clock.step(bitDelay)
        }
        dut.io.tx.expect(true.B)
    }
  }

  it should "receive a full image" taggedAs(SlowTest) in {
    test(new OffChipCom(FREQ_L, BAUDRATE_L)) {
      dut =>
        dut.clock.setTimeout(FREQ_L)
        resetInputs(dut)

        // Receive a full image - in phase 0
        val rng = new scala.util.Random(42)
        for (i <- 0 until INPUTSIZE) {
          print(s"Receiving word $i --- ")
          val index = i.U(16.W)
          val freq  = BigInt(RATEWIDTH, rng).U(16.W)

          val cw = fork {
            if (i < NEURONSPRCORE) {
              while (!dut.io.inC0We.peek.litToBoolean)
                dut.clock.step()
              dut.io.inC0Addr.expect((index.litValue + NEURONSPRCORE).U)
              dut.io.inC0Di.expect(freq)
              dut.clock.step()
            } else {
              while (!dut.io.inC1We.peek.litToBoolean)
                dut.clock.step()
              dut.io.inC1Addr.expect(((index.litValue & 0xff) + NEURONSPRCORE).U)
              dut.io.inC1Di.expect(freq)
              dut.clock.step()
            }
          }
          
          // Receive the index
          receiveByte(dut, index(15, 8))
          receiveByte(dut, index( 7, 0))
          receiveByte(dut, freq(15, 8))
          receiveByte(dut, freq( 7, 0))
          print("received --- ")
          cw.join
          println("data written to memory")
        }

        // Check that the phase has updated
        dut.io.inC0HSout.expect(true.B)
        dut.io.inC1HSout.expect(true.B)

        // Change phase
        dut.io.inC0HSin.poke(true.B)
        dut.io.inC1HSin.poke(true.B)

        // Receive a full image - in phase 1
        for (i <- 0 until INPUTSIZE) {
          print(s"Receiving word $i --- ")
          val index = i.U(16.W)
          val freq  = BigInt(RATEWIDTH, rng).U(16.W)

          val cw = fork {
            if (i < NEURONSPRCORE) {
              while (!dut.io.inC0We.peek.litToBoolean)
                dut.clock.step()
              dut.io.inC0Addr.expect(index)
              dut.io.inC0Di.expect(freq)
              dut.clock.step()
            } else {
              while (!dut.io.inC1We.peek.litToBoolean)
                dut.clock.step()
              dut.io.inC1Addr.expect((index.litValue & 0xff).U)
              dut.io.inC1Di.expect(freq)
              dut.clock.step()
            }
          }
          
          // Receive the index
          receiveByte(dut, index(15, 8))
          receiveByte(dut, index( 7, 0))
          receiveByte(dut, freq(15, 8))
          receiveByte(dut, freq( 7, 0))
          print("received --- ")
          cw.join
          println("data written to memory")
        }

        // Check that the phase has updated
        dut.io.inC0HSout.expect(false.B)
        dut.io.inC1HSout.expect(false.B)
    }
  }
}
