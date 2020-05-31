import chisel3._
import chisel3.util._

class Tx(frequency: Int, baudRate: Int) extends Module {
  val io = IO(new Bundle {
    val tx = Output(Bool())
    val ready = Output(Bool())
    val valid = Input(Bool())
    val data = Input(UInt(8.W))
  })

  val sampleDiv = (frequency/baudRate).U
  val sstart :: sdata :: sstop :: Nil = Enum(3)

  val clkCnt = RegInit(0.U((log2Up(frequency/baudRate)+1).W))
  val baudtick = RegInit(false.B)
  val state = RegInit(sstart)
  val data = RegInit(0.U(8.W))
  val txBit = RegInit(true.B)
  val bitCnt = RegInit(0.U(3.W))
  val readyR = RegInit(false.B)

  io.tx := txBit
  io.ready := readyR

  when(clkCnt === sampleDiv){
    clkCnt := 0.U
    baudtick := true.B
  }.otherwise{
    clkCnt := clkCnt + 1.U
    baudtick := false.B
  }


  readyR := false.B

  switch(state){
    is(sstart){
      when(baudtick && io.valid){
        txBit := false.B
        state := sdata
        bitCnt := 0.U
        readyR := true.B
        data := io.data
      }
    }
    is(sdata){
      when(baudtick){
        txBit := data(0)
        data := true.B ## data(7,1)
        when(bitCnt < 7.U){
          bitCnt := bitCnt + 1.U
        }.otherwise{
          bitCnt := 0.U
          state := sstop
        }
      }
    }
    is(sstop){
      when(baudtick){
        txBit := true.B
        state := sstart
      }
    }
  }
}

class Rx(frequency: Int, baudRate: Int) extends Module {
  val io = IO(new Bundle {
    val rx = Input(Bool())
    val ready = Input(Bool())
    val valid = Output(Bool())
    val data = Output(UInt(8.W))
  })
  val overSampleDiv = (frequency/(baudRate*16)).U
  val gstart :: gdata :: gstop :: Nil = Enum(3)
  val dataSr   = RegInit("b11".U(2.W)) //make this in another way
  val filter   = RegInit("b11".U(2.W))
  val rxBit    = RegInit(true.B)
  val spaceCnt = RegInit(0.U(4.W))
  val data     = RegInit(0.U(8.W))
  val clkCnt   = RegInit(0.U(log2Up(frequency/(baudRate*16)).W))
  val baudTick = RegInit(false.B)
  val bitTick  = RegInit(false.B)
  val state    = RegInit(gstart)
  val bitCnt   = RegInit(0.U(3.W))
  val validR   = RegInit(false.B)


  io.data := data
  io.valid := validR

  when(validR && io.ready){
    validR := false.B
  }

  when(clkCnt === overSampleDiv){ //oversampled baudTick
    baudTick := true.B
    clkCnt := 0.U
  }.otherwise{
    baudTick := false.B
    clkCnt := clkCnt + 1.U
  }

  bitTick := false.B

  when(baudTick){
    dataSr := dataSr(0) ## io.rx //sync oversample


    when(dataSr(1) && filter < 3.U){//filtering oversample
      filter := filter + 1.U
    }.elsewhen(!dataSr(1) && filter > 0.U){
      filter := filter - 1.U
    }

    when(filter === 3.U){
      rxBit := true.B
    }.elsewhen(filter === 0.U){
      rxBit := false.B
    }


    when(spaceCnt === 15.U){//spacing to match baud
      bitTick := true.B
      spaceCnt := 0.U
    }.otherwise{
      spaceCnt := spaceCnt + 1.U
    }
    when(state === gstart){
      spaceCnt := 0.U
    }
  }

  switch(state){
    is(gstart){
      when(baudTick && !rxBit){
        state := gdata
      }
    }
    is(gdata){
      when(bitTick){
        data := rxBit ## data(7,1)
        when(bitCnt < 7.U){
          bitCnt := bitCnt + 1.U
        }.otherwise{
          bitCnt := 0.U
          state := gstop
        }
      }
    }
    is(gstop){
      when(bitTick && rxBit){
        state := gstart
        validR := true.B
      }
    }
  }

}

class Uart(frequency: Int, baudRate: Int) extends Module {
  val io = IO(new Bundle {
    val rxd = Input(UInt(1.W))
    val txd = Output(UInt(1.W))

    val rxReady = Input(Bool())
    val rxValid = Output(Bool())
    val rxByte  = Output(UInt(8.W))

    val txReady = Output(Bool())
    val txValid = Input(Bool())
    val txByte  = Input(UInt(8.W))
  })

  
  val tx = Module(new Tx(frequency, baudRate))
  val rx = Module(new Rx(frequency, baudRate))

  io.txd := tx.io.tx
  io.txReady := tx.io.ready
  tx.io.valid := io.txValid
  tx.io.data := io.txByte

  rx.io.rx := io.rxd
  rx.io.ready := io.rxReady
  io.rxValid := rx.io.valid
  io.rxByte := rx.io.data
}

class UartEcho(frequency: Int, baudRate: Int) extends Module {
  val io = IO(new Bundle {
    val rxd = Input(Bool())
    val txd = Output(Bool())
  })

  val valid = RegInit(false.B)
  val ready = RegInit(false.B)
  val data = RegInit(0.U(8.W))

  val atx = Module(new Tx(frequency, baudRate))
  val arx = Module(new Rx(frequency, baudRate))


  io.txd := atx.io.tx
  arx.io.rx := io.rxd


  ready := false.B
  atx.io.valid := valid
  atx.io.data := data
  arx.io.ready := ready

  when(arx.io.valid){
    data := arx.io.data
    valid := true.B
    ready := true.B
  }

  when(valid && atx.io.ready){
    valid := false.B
  }
}


object Uart extends App {
  chisel3.Driver.execute(Array("--target-dir", "build"), () => new Uart(80000000, 115200))
}

object UartEcho extends App {
  chisel3.Driver.execute(Array("--target-dir", "build"), () => new UartEcho(80000000, 115200))
}