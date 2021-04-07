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

  // Memory offsets
  val OSREFRAC    = 0
  val OSPOTENTIAL = TMNEURONS 
  val OSWEIGHT    = 2 * TMNEURONS
  val OSBIAS      = if (MEMCHEAT) (2 * TMNEURONS + TMNEURONS * AXONNRCHEAT) else (2 * TMNEURONS + TMNEURONS * AXONNR)
  val OSDECAY     = if (MEMCHEAT) (3 * TMNEURONS + TMNEURONS * AXONNRCHEAT) else (3 * TMNEURONS + TMNEURONS * AXONNR)
  val OSTHRESH    = if (MEMCHEAT) (4 * TMNEURONS + TMNEURONS * AXONNRCHEAT) else (4 * TMNEURONS + TMNEURONS * AXONNR)
  val OSREFRACSET = if (MEMCHEAT) (5 * TMNEURONS + TMNEURONS * AXONNRCHEAT) else (5 * TMNEURONS + TMNEURONS * AXONNR)
  val OSPOTSET    = if (MEMCHEAT) (6 * TMNEURONS + TMNEURONS * AXONNRCHEAT) else (6 * TMNEURONS + TMNEURONS * AXONNR)

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

  def JsArrayTo1DArray(jarray: JsArray): Array[Int] = {
    return jarray.elements.toArray.map(_.asInstanceOf[JsNumber].value.toInt)
  }

  def JsArrayTo2DArray(jarray: JsArray): Array[Array[Int]] = {
    return jarray.elements.toArray.map(x => JsArrayTo1DArray(x.asInstanceOf[JsArray]))
  }
  
  class ParameterReader { // Only for showcase
    var l1 = Map.empty[String, Array[Array[Int]]]
    var l2 = Map.empty[String, Array[Array[Int]]]
  
    def getMemData(name: String, coreID: Int, evalID: Int): Vector[Int] = {
      require(coreID == 2 || coreID == 3)
      var memData = Array.fill(TMNEURONS)(0)
      var allData : Array[Int] = Array()
      if (coreID == 2) {
        allData = l1(name)(0)
      } else if (coreID == 3) {
        allData = l2(name)(0)
      }
  
      for (i <- 0 until TMNEURONS) {
        if (200 > i*EVALUNITS + evalID) {
          memData(i) = allData(i*EVALUNITS + evalID)
        }
      }
      return memData.toVector
    }
  
    def getMemWeights(coreID: Int, evalID: Int): Vector[Int] = {
      require(coreID == 2 || coreID == 3)
      var memData = Array.fill(TMNEURONS*256*3)(0)
      var allData1 : Array[Array[Int]] = Array()
      var allData2 : Array[Array[Int]] = Array()
      if (coreID == 2) {
        allData1 = l1("w1")
        allData2 = l1("w2")
        for (i <- 0 until TMNEURONS) {
          if (200 > i*EVALUNITS + evalID) {
            for (j <- 0 until 3*256) {
              if (j < 484) {
                memData(i*3*256 + j) = allData1(j)(i*EVALUNITS + evalID)
              } else if (j >= 512 && j < 512+200) {
                memData(i*3*256 + j) = allData2(j-512)(i*EVALUNITS + evalID)
              }
            }
          }
        }
      } else if (coreID == 3) {
        allData1 = l2("w")
        for (i <- 0 until TMNEURONS) {
          if (200 > i*EVALUNITS + evalID) {
            for (j <- 0 until 3*256) {
              if (j < 200) {
                memData(i*3*256 + j) = allData1(j)(i*EVALUNITS + evalID)
              }
            }
          }
        }
      }
      return memData.toVector
    }
  
    // Initialization code
    val source = scala.io.Source.fromFile("mapping/networkData.json")
    val lines = try source.mkString finally source.close()
    val l1Json = lines.parseJson.asInstanceOf[JsObject].getFields("l1")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject]
    l1 += ("bias"   -> Array(JsArrayTo1DArray(l1Json.getFields("biases")(0).asInstanceOf[JsArray])))
    l1 += ("thres"  -> Array(JsArrayTo1DArray(l1Json.getFields("thresh")(0).asInstanceOf[JsArray])))
    l1 += ("reset"  -> Array(JsArrayTo1DArray(l1Json.getFields("reset")(0).asInstanceOf[JsArray])))
    l1 += ("refrac" -> Array(JsArrayTo1DArray(l1Json.getFields("refrac")(0).asInstanceOf[JsArray])))
    l1 += ("decay"  -> Array(JsArrayTo1DArray(l1Json.getFields("decay")(0).asInstanceOf[JsArray])))
    l1 += ("w1"     -> JsArrayTo2DArray(l1Json.getFields("w1")(0).asInstanceOf[JsArray]))
    l1 += ("w2"     -> JsArrayTo2DArray(l1Json.getFields("w2")(0).asInstanceOf[JsArray]))

    val l2Json = lines.parseJson.asInstanceOf[JsObject].getFields("l2")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject]
    l2 += ("bias"   -> Array(JsArrayTo1DArray(l2Json.getFields("biases")(0).asInstanceOf[JsArray])))
    l2 += ("thres"  -> Array(JsArrayTo1DArray(l2Json.getFields("thresh")(0).asInstanceOf[JsArray])))
    l2 += ("reset"  -> Array(JsArrayTo1DArray(l2Json.getFields("reset")(0).asInstanceOf[JsArray])))
    l2 += ("refrac" -> Array(JsArrayTo1DArray(l2Json.getFields("refrac")(0).asInstanceOf[JsArray])))
    l2 += ("decay"  -> Array(JsArrayTo1DArray(l2Json.getFields("decay")(0).asInstanceOf[JsArray])))
    l2 += ("w"      -> JsArrayTo2DArray(l2Json.getFields("w")(0).asInstanceOf[JsArray]))
  }
  
  class InterfaceReader { // Only for showcase
    var cores = Map.empty[Int, Array[Array[Int]]]
  
    def getFilter(coreID: Int): Vector[Int] = {
      val source = scala.io.Source.fromFile("mapping/interfaceLut484.json")
      val lines = try source.mkString finally source.close()
      val paramJson = lines.parseJson
  
      val valid = JsArrayTo1DArray(paramJson.asInstanceOf[JsObject].fields("cores").asInstanceOf[JsObject].fields(coreID.toString).asInstanceOf[JsObject].fields("valid").asInstanceOf[JsArray])
      val data = JsArrayTo1DArray(paramJson.asInstanceOf[JsObject].fields("cores").asInstanceOf[JsObject].fields(coreID.toString).asInstanceOf[JsObject].fields("data").asInstanceOf[JsArray])
  
      var rom : Vector[Int] = Vector()
      for(i <- 0 until valid.size){
        rom = rom.:+((valid(i) << 2) + data(i))(collection.breakOut)
      }
      return rom
    }
  }
  
  object MakeDataFiles extends App {
    def toBinary(x : Int, len : Int): String = {
      // Could be made fully functional like:
      // val binStr = x.toString(2)
      // return "0" * (len - binStr.length) + binStr
      var binStr = ""
      for (i <- (0 to len-1).reverse){
        var mask = 1 << i
        if ((mask & x) != 0){
          binStr = binStr + "1"
        }else{
          binStr = binStr + "0"
        }
      }
      return binStr
    }
  
    def toHex(x : Int, len : Int): String = {
      // Could be made fully functional like:
      // val hexStr = x.toString(16)
      // return "0" * (len - hexStr.length) + hexStr
      var binStr = x.toHexString
      return binStr
    }
  
    val params = new ParameterReader
    val hex = false
    val potNrefrac = Array.fill(OSWEIGHT)(0).toVector
  
    for (i <- 2 until 4) { // Cores
      for (j <- 0 until EVALUNITS){ // Memories in core
        val weights      = params.getMemWeights(i, j)
        val biases       = params.getMemData("bias", i, j)
        val decays       = params.getMemData("decay", i, j)
        val thresholds   = params.getMemData("thres", i, j)
        val refracSets   = params.getMemData("refrac", i, j)
        val potentialSet = params.getMemData("reset", i, j)
      
        val filedata = potNrefrac ++ weights ++ biases ++ decays ++ thresholds ++ refracSets ++ potentialSet
        val file = new PrintWriter(new File("mapping/meminit/evaldata"+"c"+i.toString+"e"+j.toString+".mem"))
        // Could be made fully functional like:
        // file.write(filedata.map(toHex(_, 17)).mkString("\n"))
        for (d <- filedata) {
          if (hex) {
            file.write(toHex(d, 17) + "\n")
          } else {
            file.write(toBinary(d, 17) + "\n")
          }
        }
        file.close
      }
    }
  }
}
