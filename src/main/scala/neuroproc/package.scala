import chisel3._
import chisel3.util._
import spray.json._
import java.io._

package object neuroproc {
  val FREQ             = 80000000             // in Hz
  val BAUDRATE         = 115200
  val TIMESTEP         = 0.001                // in seconds
  val CYCLESPRSTEP     = (FREQ*TIMESTEP).toInt
  val MEMCHEAT         = true                 // make memories smaller to fit Kintex-7?
  val CORES            = 5
  val NEUDATAWIDTH     = 17
  val AXONNR           = 1024
  val AXONNRCHEAT      = 256*3
  val AXONIDWIDTH      = log2Up(AXONNR)
  val TMNEURONS        = 32
  val N                = log2Up(TMNEURONS)
  val EVALUNITS        = 8
  val NEURONSPRCORE    = TMNEURONS * EVALUNITS
  val GLOBALADDRWIDTH  = log2Up(CORES) + log2Up(EVALUNITS) + N
  val AXONMSBWIDTH     = AXONIDWIDTH - log2Up(NEURONSPRCORE)
  val EVALMEMSIZE      = if (MEMCHEAT) (7 * TMNEURONS + TMNEURONS * 768) else (7 * TMNEURONS + TMNEURONS * AXONNR)
  val EVALMEMADDRWIDTH = log2Up(EVALMEMSIZE)
  val EVALMEMSIZEC      = (7 * TMNEURONS + TMNEURONS * 768) // Cheating to fit to board 
  val EVALMEMADDRWIDTHC = log2Up(EVALMEMSIZEC)
  val RATEWIDTH        = log2Up(500)
  val RATEADDRWIDTH    = log2Up(NEURONSPRCORE)
  val INPUTSIZE        = 22*22
  val RANKORDERENC     = false
  val USEROUNDEDWGHTS  = true

  // Hardcoded - consider changing to be part of conf files or similar
  val neuronsInCore = Array(256, 228, 200, 200, 200) // Neurons mapped to each core, in/outcores don't matter as they are used controlunit in neuron core

  // The control signals bundle used for neuron evaluators
  class EvalCntrSigs extends Bundle {
    val potSel = UInt(2.W)        // 0: dataIn, 1: sum, 2: potReg
    val spikeSel = UInt(2.W)      // 0: >thres, 1: reset, 2,3: keep
    val refracSel = UInt(1.W)     // 0: dataIn, 1: RefracReg
    val decaySel = Bool()         // 1: subtract decay, 0: otherwise
    val writeDataSel = UInt(2.W)  // 0: dataIn, 1: potential, 2: refracCnt
  }

  // The memory address and selection bundle used for evaluation memories
  class MemAddr extends Bundle {
    val sel = UInt(2.W)
    val pos = UInt(EVALMEMADDRWIDTH.W)
  }
  val const :: dynamic :: biasthresh :: weights :: Nil = Enum(4)

  // Interface reader returns a ROM for a core's bus interface
  class InterfaceReader {
    var cores = Map.empty[Int, Array[Array[Int]]]

    def JsArrayTo1DArray(jarray: JsArray): Array[Int] = {
      return jarray.elements.toArray.map(_.asInstanceOf[JsNumber].value.toInt)
    }
  
    def getFilter(coreID: Int): Vector[Int] = {
      val source = scala.io.Source.fromFile("mapping/interfaceLut484.json")
      val lines = try source.mkString.parseJson.asInstanceOf[JsObject] finally source.close()
      val paramJson = lines.fields("cores").asInstanceOf[JsObject].fields(coreID.toString).asInstanceOf[JsObject]
  
      val valid = JsArrayTo1DArray(paramJson.fields("valid").asInstanceOf[JsArray])
      val data = JsArrayTo1DArray(paramJson.fields("data").asInstanceOf[JsArray])
  
      var rom : Vector[Int] = Vector()
      for(i <- 0 until valid.size){
        rom = rom.:+((valid(i) << 2) + data(i))(collection.breakOut)
      }
      return rom
    }
  }
}
