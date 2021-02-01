import neuroproc._

import org.scalatest._
import chisel3._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.WriteVcdAnnotation

class OffChipComTester extends FlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Off-chip Communication"

  // Change these values for the tests - keep FREQ_L and BAUDRATE_L relatively low!
  val SCALE      = 8192
  val FREQ_L     = FREQ / SCALE
  val BAUDRATE_L = BAUDRATE / SCALE
  val bitDelay   = FREQ_L / BAUDRATE_L + 1

  // Method to clear the inputs of the dut
  def resetInputs(dut: OffChipCom) = {
    dut.io.rx.poke(true.B)
    dut.io.inC0Ready.poke(false.B)
    dut.io.inC1Ready.poke(false.B)
    dut.io.outCData.poke(0.U)
    dut.io.outCValid.poke(false.B)
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
        dut.clock.setTimeout(40*bitDelay)
        resetInputs(dut)

        // For the first input core
        print("Receiving word for core 0 --- ")
        var index = 151.U(16.W)
        var freq  = 42.U
        var res = (((index.litValue & 0xff) << 16) | freq.litValue).U

        receiveByte(dut, index(15, 8))
        receiveByte(dut, index( 7, 0))
        receiveByte(dut, freq(15, 8))
        receiveByte(dut, freq( 7, 0))
        print("received --- ")

        while (!dut.io.inC0Valid.peek.litToBoolean)
          dut.clock.step()
        dut.io.inC0Data.expect(res)
        dut.io.inC0Ready.poke(true.B)
        dut.clock.step()
        dut.io.inC0Ready.poke(false.B)
        println("handshake complete")

        // For the second input core
        print("Receiving word for core 1 --- ")
        index = 333.U(16.W)
        freq  = 197.U
        res = (((index.litValue & 0xff) << 16) | freq.litValue).U

        receiveByte(dut, index(15, 8))
        receiveByte(dut, index( 7, 0))
        receiveByte(dut, freq(15, 8))
        receiveByte(dut, freq( 7, 0))
        print("received --- ")

        while (!dut.io.inC1Valid.peek.litToBoolean)
          dut.clock.step()
        dut.io.inC1Data.expect(res)
        dut.io.inC1Ready.poke(true.B)
        dut.clock.step()
        dut.io.inC1Ready.poke(false.B)
        println("handshake completed")
    }
  }

  it should "transfer a spike" in {
    test(new OffChipCom(FREQ_L, BAUDRATE_L)).withAnnotations(Seq(WriteVcdAnnotation)) {
      dut =>
        dut.clock.setTimeout(10*bitDelay)
        resetInputs(dut)
        dut.io.inC0HSin.poke(true.B)

        val testData = 42.U
        
        // Load a spike into the module
        dut.io.outCValid.poke(true.B)
        dut.io.outCData.poke(testData)
        do {
          dut.clock.step()
        } while (!dut.io.outCReady.peek.litToBoolean)
        dut.io.outCValid.poke(false.B)
        dut.io.outCData.poke(0.U)
        println("Loaded data")

        // Wait for start bit
        while (dut.io.tx.peek.litToBoolean)
          dut.clock.step()
        println("Start bit transmitted")
        
        // Check remaining bits
        dut.clock.step(bitDelay)
        for (i <- 0 until 8) {
          dut.io.tx.expect(testData(i))
          println(s"Found bit $i")
          dut.clock.step(bitDelay)
        }
        dut.io.tx.expect(true.B)
    }
  }

  it should "receive a full image" in {
    test(new OffChipCom(FREQ_L, BAUDRATE_L)) {
      dut =>
        dut.clock.setTimeout(INPUTSIZE*40*bitDelay)
        resetInputs(dut)

        // Receive a full image
        val rng = new scala.util.Random(42)
        for (i <- 0 until INPUTSIZE) {
          print(s"Receiving word $i --- ")
          val index = i.U(16.W)
          val freq  = BigInt(16, rng).U
          
          // Receive the index
          receiveByte(dut, index(15, 8))
          receiveByte(dut, index( 7, 0))

          // Receive the frequency
          receiveByte(dut, freq(15, 8))
          receiveByte(dut, freq( 7, 0))
          print("received --- ")

          // Check that the data was received
          while (!dut.io.inC0Valid.peek.litToBoolean && !dut.io.inC1Valid.peek.litToBoolean)
            dut.clock.step()
          val res = (((index.litValue & 0xff) << 16) | freq.litValue).U
          if (i < NEURONSPRCORE) {
            // Data transferred to input core 0
            dut.io.inC0Data.expect(res)
            dut.io.inC0Ready.poke(true.B)
            dut.clock.step()
            dut.io.inC0Ready.poke(false.B)
          } else {
            // Data transferred to input core 1
            dut.io.inC1Data.expect(res)
            dut.io.inC1Ready.poke(true.B)
            dut.clock.step()
            dut.io.inC1Ready.poke(false.B)
          }
          println("handshake completed")
        }

        // Check that the phase has updated
        dut.io.inC0HSout.expect(true.B)
        dut.io.inC1HSout.expect(true.B)
    }
  }
}
