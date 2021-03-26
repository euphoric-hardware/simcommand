package neuroproc.systemtests

import neuroproc._

import org.scalatest._
import chisel3._
import chisel3.util._
import chiseltest._
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.VcsBackendAnnotation

class DerivedClocksTester extends FlatSpec with ChiselScalatestTester with Matchers {
  behavior of "Derived clock system"

  it should "work with multiple clocks" taggedAs(VcsTest, SlowTest) in {
    test(new Module {
      val io = IO(new Bundle {
        val uartTx = Output(Bool())
      })

      // First clock
      val clock1 = Wire(Clock())
      val buf1   = Module(ClockBuffer())
      buf1.io.ce := true.B
      buf1.io.i  := clock
      clock1 := buf1.io.o

      // Second clock
      val en2    = WireDefault(true.B)
      val clock2 = Wire(Clock())
      val buf2   = Module(ClockBuffer())
      buf2.io.ce := en2
      buf2.io.i  := clock
      clock2 := buf2.io.o

      // A test memory
      val mem = Module(TrueDualPortFIFO(16, 8))
      mem.io.clki := clock2.asBool
      mem.io.clko := clock1.asBool

      // First clock domain manages transfers
      val newTS = Wire(Bool())
      withClock(clock1) {
        val tsCycleCnt = RegInit(CYCLESPRSTEP.U)
        newTS := tsCycleCnt === 0.U
        tsCycleCnt := Mux(newTS, CYCLESPRSTEP.U, tsCycleCnt - 1.U)

        val occ = Module(new OffChipCom(FREQ, BAUDRATE))
        io.uartTx := occ.io.tx
        occ.io.rx := true.B

        mem.io.en := occ.io.qEn
        occ.io.qEmpty := mem.io.empty
        occ.io.qData  := mem.io.datao

        occ.io.inC0HSin := true.B
        occ.io.inC1HSin := false.B
      }

      // Second clock domain produces inputs values
      withClock(clock2) {
        val cnt = RegInit(255.U(8.W))
        mem.io.we := false.B
        mem.io.datai := cnt

        val idle :: enq :: Nil = Enum(2)
        val state = RegInit(idle)
        switch(state) {
          is(idle) {
            en2 := false.B
            when(newTS && !mem.io.full) {
              en2 := true.B
              state := enq
            }
          }
          is(enq) {
            mem.io.we := true.B
            cnt := (cnt ^ (cnt(4,0) ## 0.U(3.W))) + 1.U
            state := idle
          }
        }
      }
    }).withAnnotations(Seq(VcsBackendAnnotation)) {
      dut =>
        val nTests = 10
        dut.clock.setTimeout((nTests+2)*CYCLESPRSTEP)

        val bitDelay = FREQ / BAUDRATE + 1

        def transferByte() = {
          var byte = 0
          // Assumes start bit has already been seen
          dut.clock.step(bitDelay)
          // Byte
          for (i <- 0 until 8) {
            byte = (dut.io.uartTx.peek.litToBoolean << i) | byte
            dut.clock.step(bitDelay)
          }
          // Stop bit
          dut.io.uartTx.expect(true.B)
          dut.clock.step(bitDelay)
          byte
        }
        
        // Receive 100 values from the circuit
        dut.reset.poke(true.B)
        dut.clock.step()
        dut.reset.poke(false.B)
        dut.clock.step()
        dut.io.uartTx.expect(true.B)
        var nextV = 255
        for (_ <- 0 until nTests) {
          while (dut.io.uartTx.peek.litToBoolean)
            dut.clock.step()
          val v = transferByte()
          println(s"Received ${v}, expected ${nextV}")
          assert(v == nextV)
          nextV = ((nextV ^ (nextV << 3)) + 1) & 0xff
          dut.clock.step()
        }
    }
  }
}
