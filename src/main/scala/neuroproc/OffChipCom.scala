package neuroproc

import chisel3._
import chisel3.util._

class OffChipCom(frequency: Int, baudRate: Int) extends Module {
  val io = IO(new Bundle {
    val tx = Output(Bool())
    val rx = Input(Bool())

    // Memory interface
    val inC0We    = Output(Bool())
    val inC0Addr  = Output(UInt((RATEADDRWIDTH+1).W))
    val inC0Di    = Output(UInt(RATEWIDTH.W))

    val inC1We    = Output(Bool())
    val inC1Addr  = Output(UInt((RATEADDRWIDTH+1).W))
    val inC1Di    = Output(UInt(RATEWIDTH.W))

    // FIFO interface
    val qEn    = Output(Bool())
    val qData  = Input(UInt(8.W))
    val qEmpty = Input(Bool())

    // Synchronization ports for input cores
    val inC0HSin  = Input(Bool())
    val inC0HSout = Output(Bool())

    val inC1HSin  = Input(Bool())
    val inC1HSout = Output(Bool())
  })

  // UART module and relevant registers and wires
  val uart = Module(new Uart(frequency, baudRate))
  val txBuf = RegInit(0.U(8.W))
  val txV = RegInit(false.B)

  // RX logic
  uart.io.rxd := io.rx
  uart.io.rxReady := false.B

  // TX logic
  io.tx := uart.io.txd
  uart.io.txValid := txV
  uart.io.txByte := txBuf
  when(uart.io.txReady && txV) {
    txV := false.B
  }

  // From FIFO queue
  val en = Wire(Bool())
  val enReg = RegInit(false.B)
  en := !io.qEmpty && !txV && !enReg
  enReg := en
  io.qEn := en
  when(enReg) {
    txBuf := io.qData
    txV := true.B
  }

  // Data buffer registers
  val addr1 = RegInit(0.U(8.W))
  val addr0 = RegInit(0.U(8.W))
  val rate1 = RegInit(0.U(8.W))
  val rate0 = RegInit(0.U(8.W))

  // Synchronization with input cores - init to in-phase, download first
  val phase = RegInit(false.B)

  // IO default values
  val defAddr  = Mux(phase, addr0, addr0 + NEURONSPRCORE.U)(RATEADDRWIDTH, 0)
  val defData  = (rate1 ## rate0)(RATEWIDTH-1, 0)
  io.inC0HSout := phase
  io.inC0We    := false.B
  io.inC0Addr  := defAddr
  io.inC0Di    := defData

  io.inC1HSout := phase
  io.inC1We    := false.B
  io.inC1Addr  := defAddr
  io.inC1Di    := defData

  // Control FSM
  val idle :: start :: receiveW :: toCore :: Nil = Enum(4)
  val stateReg = RegInit(idle)
  val byteCnt  = RegInit(0.U(2.W))
  val pixCnt   = RegInit(0.U(log2Up(INPUTSIZE).W))
  switch(stateReg) {
    is(idle) {
      // When the input cores are in phase, transfers can begin
      when(phase === io.inC0HSin && io.inC0HSin === io.inC1HSin) {
        stateReg := start
      }
    }
    is(start) {
      // When the UART has completed a transfer, receive an image;
      // otherwise reset the counters and transfer
      when(uart.io.txReady) {
        stateReg := receiveW
      }.otherwise {
        pixCnt := 0.U
        byteCnt := 0.U
        txBuf := 255.U //start msg never the case for spike as they are 0-199
        txV := true.B
      }
    }
    is(receiveW) {
      // When a new byte has been received, shift it into the registers
      when(uart.io.rxValid) {
        addr1 := addr0
        addr0 := rate1
        rate1 := rate0
        rate0 := uart.io.rxByte
        uart.io.rxReady := true.B

        byteCnt := byteCnt + 1.U 

        when(byteCnt === 3.U) {
          stateReg := toCore
        }.otherwise {
          stateReg := receiveW
        }
      }
    }
    is(toCore) {
      // Transfer the received word to one of the input cores
      when(addr1 === 0.U) {
        io.inC0We := true.B
      }.otherwise {
        io.inC1We := true.B
      }
      pixCnt := pixCnt + 1.U
      
      // If a full image has been received, go back to idle;
      // otherwise, receive more words
      when(pixCnt === (INPUTSIZE-1).U) {
        stateReg := idle
        phase := ~phase
      }.otherwise {
        stateReg := receiveW
      }
    }
  }
}
