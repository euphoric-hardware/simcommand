package simcommand.vips

import chisel3._
import simcommand._

class UART(uartIn: Interactable[chisel3.Bool], uartOut: Interactable[chisel3.Bool], cyclesPerBit: Int) {
  val bitsPerSymbol = 10

  def sendReset(): Command[Unit] = {
    // Keep idle high for an entire symbol period to reset any downstream receivers
    for {
      _ <- poke(uartIn, 1.B)
      _ <- step(cyclesPerBit * (bitsPerSymbol + 1))
    } yield ()
  }

  def sendBit(bit: Int): Command[Unit] = {
    for {
      _ <- poke(uartIn, bit.B)
      _ <- step(cyclesPerBit)
    } yield ()
  }

  def sendByte(byte: Int): Command[Unit] = {
    for {
      _ <- sendBit(0)
      _ <- concat((0 until 8).map(i => sendBit((byte >> i) & 0x1)))
      _ <- sendBit(1)
    } yield ()
  }

  def sendBytes(bytes: Seq[Int]): Command[Unit] = {
    val cmds = bytes.map(b => sendByte(b))
    concat(cmds)
  }

  def receiveBit(): Command[Int] = {
    // Assuming that a start bit has already been seen and current time is at the midpoint of the start bit
    for {
      _ <- step(cyclesPerBit)
      b <- peek(uartOut)
    } yield b.litValue.toInt
  }

  def receiveByte(): Command[Int] = {
    for {
      _ <- waitForValue(uartOut, false.B, cyclesPerBit/4) // Wait for the start bit // TODO: reduce polling frequency
      _ <- step(cyclesPerBit / 2) // shift time to center-of-symbol
      bits <- sequence(Seq.fill(8)(receiveBit()))
      _ <- step(cyclesPerBit + cyclesPerBit / 2) // advance time past 1/2 of last data bit and stop bit
      byte = bits.zipWithIndex.foldLeft(0) {
        case (byte, (bit, index)) => byte | (bit << index)
      }
    } yield byte
  }

  def receiveBytes(nBytes: Int): Command[Seq[Int]] = {
    val cmds = Seq.fill(nBytes)(receiveByte())
    sequence(cmds)
  }
}

class UARTChecker(serialLine: Interactable[chisel3.Bool]) {
  def checkByte(bitDelay: Int): Command[Boolean] = {
    for {
      _ <- waitForValue(serialLine, false.B) // Wait for the start bit
      stableStartBit <- checkStable(serialLine, false.B, bitDelay) // Start bit should be stable until symbol edge
      _ <- step(bitDelay*8) // Let the 8 data bits pass
      stableStopBit <- checkStable(serialLine, true.B, bitDelay) // Stop bit should be stable until byte finished
    } yield stableStartBit && stableStopBit
  }

  def checkBytes(nBytes: Int, bitDelay: Int): Command[Boolean] = {
    val checks = Seq.fill(nBytes)(checkByte(bitDelay))
    for {
      checks <- sequence(checks)
    } yield checks.forall(b => b)
  }
}
