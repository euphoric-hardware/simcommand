package neuroproc

import chisel3._
import chisel3.util._
import chisel3.util.experimental.loadMemoryFromFileInline
import firrtl.annotations.MemoryLoadFileType

class EvaluationMemory(val coreID: Int, val evalID: Int, synth: Boolean = false) extends Module {
  val io = IO(new Bundle {
    val addr = Input(new MemAddr)
    val ena  = Input(Bool())
    val wr   = Input(Bool())
    val readData  = Output(SInt(NEUDATAWIDTH.W))
    val writeData = Input(SInt(NEUDATAWIDTH.W))
    val nothing   = Output(UInt(6.W))
  })

  // The four different memories are mapped to the following
  // addr.sel    | memory
  //  const      |  constants (reset, refrac, decay)
  //  dynamic    |  refrac counters and membrane potentials
  //  biasthresh |  biases and thresholds
  //  weights    |  weights
  val constmem = SyncReadMem(4, UInt(5.W))
  val dynamem  = SyncReadMem(2*TMNEURONS, SInt(NEUDATAWIDTH.W))
  val btmem    = SyncReadMem(2*TMNEURONS, SInt(NEUDATAWIDTH.W))
  val wghtmem  = SyncReadMem((512+256)*TMNEURONS, UInt(11.W))

  // Memory initialization
  val fileType = MemoryLoadFileType.Binary
  val (constfile, dynfile, btfile, wfile) = if (synth) (
    s"constc${coreID}.mem",
    s"potrefc${coreID}.mem",
    s"biasthreshc${coreID}e${evalID}.mem",
    s"weightsc${coreID}e${evalID}.mem"
  ) else (
    s"mapping/meminit/constc${coreID}.mem",
    s"mapping/meminit/potrefc${coreID}.mem",
    s"mapping/meminit/biasthreshc${coreID}e${evalID}.mem",
    s"mapping/meminit/weightsc${coreID}e${evalID}.mem"
  )
  loadMemoryFromFileInline(constmem, constfile, fileType)
  loadMemoryFromFileInline(dynamem, dynfile, fileType)
  loadMemoryFromFileInline(btmem, btfile, fileType)
  loadMemoryFromFileInline(wghtmem, wfile, fileType)

  // Unique unused output to make sure this module is made in multiple copies
  io.nothing := coreID.U ## evalID.U

  // Control synchronous memories
  val selPipe   = RegEnable(io.addr.sel, io.ena)
  val addrPipe  = RegEnable(io.addr.pos(1, 0), io.ena)
  val constRead = WireDefault(UInt(5.W), DontCare)
  val dynaRead  = WireDefault(SInt(NEUDATAWIDTH.W), DontCare)
  val btRead    = WireDefault(SInt(NEUDATAWIDTH.W), DontCare)
  val wghtRead  = WireDefault(UInt(11.W), DontCare)
  val memRead   = WireDefault(SInt(NEUDATAWIDTH.W), DontCare)
  when(io.ena) {
    switch(io.addr.sel) {
      is(const) {
        constRead := constmem(io.addr.pos)
      }
      is(dynamic) {
        when(io.wr) {
          dynamem(io.addr.pos) := io.writeData
        }.otherwise {
          dynaRead := dynamem(io.addr.pos)
        }
      }
      is(biasthresh) {
        btRead := btmem(io.addr.pos)
      }
      is(weights) {
        // Add an unused write port to force width of memory
        when(io.wr) {
          wghtmem(io.addr.pos) := io.writeData(10, 0)
        }.otherwise {
          wghtRead := wghtmem(io.addr.pos)
        }
      }
    }
  }
  switch(selPipe) {
    is(const) {
      val res = (constRead ## 0.U(10.W)).asSInt.pad(NEUDATAWIDTH) // Sign-extend
      val oth = constRead.pad(NEUDATAWIDTH).asSInt                // Pad with zeros
      memRead := Mux(!addrPipe.orR, res, oth)
    }
    is(dynamic) {
      memRead := dynaRead
    }
    is(biasthresh) {
      memRead := btRead
    }
    is(weights) {
      // Convert from 6.4
      val res = (wghtRead(wghtRead.getWidth-2, 0) ## 0.U(6.W)).asSInt.pad(NEUDATAWIDTH)
      val oth = wghtRead.pad(NEUDATAWIDTH).asSInt                 // Convert from 0.10
      memRead := Mux(wghtRead(wghtRead.getWidth-1), res, oth)
    }
  }
  io.readData := memRead
}
