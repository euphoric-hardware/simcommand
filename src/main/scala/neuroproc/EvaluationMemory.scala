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
  val constmem = SyncReadMem(4, SInt(NEUDATAWIDTH.W))
  val dynamem  = SyncReadMem(2*TMNEURONS, SInt(NEUDATAWIDTH.W))
  val btmem    = SyncReadMem(2*TMNEURONS, SInt(NEUDATAWIDTH.W))
  val wghtmem  = SyncReadMem((512+256)*TMNEURONS, SInt(NEUDATAWIDTH.W))

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
  //val constRead = WireDefault(0.S(NEUDATAWIDTH.W))
  //val dynaRead  = WireDefault(0.S(NEUDATAWIDTH.W))
  //val btRead    = WireDefault(0.S(NEUDATAWIDTH.W))
  //val wghtRead  = WireDefault(0.S(NEUDATAWIDTH.W))
  //val memRead   = WireDefault(0.S(NEUDATAWIDTH.W))
  val constRead = WireDefault(SInt(NEUDATAWIDTH.W), DontCare)
  val dynaRead  = WireDefault(SInt(NEUDATAWIDTH.W), DontCare)
  val btRead    = WireDefault(SInt(NEUDATAWIDTH.W), DontCare)
  val wghtRead  = WireDefault(SInt(NEUDATAWIDTH.W), DontCare)
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
        wghtRead := wghtmem(io.addr.pos)
      }
    }
  }
  switch(selPipe) {
    is(const) {
      memRead := constRead
    }
    is(dynamic) {
      memRead := dynaRead
    }
    is(biasthresh) {
      memRead := btRead
    }
    is(weights) {
      memRead := wghtRead
    }
  }
  io.readData := memRead
}
