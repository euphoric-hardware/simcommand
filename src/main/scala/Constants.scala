import Constants._
import chisel3._
import spray.json._
import util._
import java.io._

import scala.math.pow

object Constants {
  val FREQ             = 80000000 //in Hz
  val BAUDRATE         = 115200
  val TIMESTEP         = 0.001 //in seconds
  val CYCLESPRSTEP     = (FREQ*TIMESTEP).toInt
  val MEMCHEAT         = true // make memories smaller to fit Kintex-7
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
  val EVALMEMSIZEC      = (7 * TMNEURONS + TMNEURONS * 768)//Cheating to fit to board 
  val EVALMEMADDRWIDTHC = log2Up(EVALMEMSIZEC)
  val RATEWIDTH        = log2Up(500)
  val RATEADDRWIDTH    = log2Up(NEURONSPRCORE)
  val INPUTSIZE        = 22*22

  //offsets
  val OSREFRAC    = 0
  val OSPOTENTIAL = TMNEURONS 
  val OSWEIGHT    = 2 * TMNEURONS
  val OSBIAS      = if (MEMCHEAT) (2 * TMNEURONS + TMNEURONS * AXONNRCHEAT) else (2 * TMNEURONS + TMNEURONS * AXONNR)
  val OSDECAY     = if (MEMCHEAT) (3 * TMNEURONS + TMNEURONS * AXONNRCHEAT) else (3 * TMNEURONS + TMNEURONS * AXONNR)
  val OSTHRESH    = if (MEMCHEAT) (4 * TMNEURONS + TMNEURONS * AXONNRCHEAT) else (4 * TMNEURONS + TMNEURONS * AXONNR)
  val OSREFRACSET = if (MEMCHEAT) (5 * TMNEURONS + TMNEURONS * AXONNRCHEAT) else (5 * TMNEURONS + TMNEURONS * AXONNR)
  val OSPOTSET    = if (MEMCHEAT) (6 * TMNEURONS + TMNEURONS * AXONNRCHEAT) else (6 * TMNEURONS + TMNEURONS * AXONNR)

  //Hardcoded - consider chancing to be part of conf files or similar
  val neuronsInCore = Array(256, 228, 200, 200, 200) // Neurons mapped to each core, in/outcores doesnt matter as they are used controlunit in neuron core
}

class ParameterReader { //Only for showcase
  var l1 = Map.empty[String, Array[Array[Int]]]
  var l2 = Map.empty[String, Array[Array[Int]]]

  def JsArrayTo1DArray (jarray: JsArray) : Array[Int] = {
    val jsonvallist = jarray.elements.toArray
    var returnArray : Array[Int] = Array()
    for (elem <- jsonvallist) returnArray = returnArray :+ elem.asInstanceOf[JsNumber].value.toInt
    return returnArray
  }

  def JsArrayTo2DArray (jarray:JsArray) : Array[Array[Int]] = {
    val jsonvallist = jarray.elements.toArray
    var returnArray : Array[Array[Int]] = Array()
    for (arr <- jsonvallist){
      var tempArr : Array[Int] = Array()
      for (elem <- arr.asInstanceOf[JsArray].elements.toArray) tempArr = tempArr :+ elem.asInstanceOf[JsNumber].value.toInt
      returnArray = returnArray :+ tempArr
    }
    return returnArray
  }

  def getMemData(name: String ,coreID: Int, evalID: Int) : Vector[Int] = {
    var memData = Array.fill(TMNEURONS)(0)
    var allData : Array[Int] = Array()
    var offset = 0
    if (coreID == 2){
      allData = l1(name)(0)
    }else if (coreID == 3){
      allData = l2(name)(0)
    }

    for (i <- 0 until TMNEURONS) {
      if (200 > i*EVALUNITS + evalID) {
        memData(i) = allData(i*EVALUNITS + evalID)
      }
    }

    return memData.toVector
  }

  def getMemWeights(coreID: Int, evalID: Int) : Vector[Int] = {
    var memData = Array.fill(TMNEURONS*256*3)(0)
    var allData1 : Array[Array[Int]] = Array()
    var allData2 : Array[Array[Int]] = Array()
    var offset = 0
    if (coreID == 2){
      allData1 = l1("w1")
      allData2 = l1("w2")
      for (i <- 0 until TMNEURONS) {
        if (200 > i*EVALUNITS + evalID) {
          for (j <- 0 until 3*256) {
            if (j < 484) {
              memData(i*3*256 + j) = allData1(j)(i*EVALUNITS + evalID)
            }else if (j >= 512 && j < 512+200){
              memData(i*3*256 + j) = allData2(j-512)(i*EVALUNITS + evalID)
            }
          }
        }
      }
    }else if (coreID == 3){
      allData1 = l2("w")
      for (i <- 0 until TMNEURONS) {
        if (200 > i*EVALUNITS + evalID) {
          for (j <- 0 until 3*256) {
            if (j < 200) {
              memData(i*3*256 + j) = allData1(j)(i*EVALUNITS + evalID + offset)
            }
          }
        }
      }
    }
    return memData.toVector
  }

  { //init code
    val source = scala.io.Source.fromFile("mapping/networkData.json")
    val lines = try source.mkString finally source.close()
    val paramJson = lines.parseJson
    l1 += ("bias"   -> Array(JsArrayTo1DArray(paramJson.asInstanceOf[JsObject].getFields("l1")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject].getFields("biases")(0).asInstanceOf[JsArray])))
    l1 += ("thres"  -> Array(JsArrayTo1DArray(paramJson.asInstanceOf[JsObject].getFields("l1")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject].getFields("thresh")(0).asInstanceOf[JsArray])))
    l1 += ("reset"  -> Array(JsArrayTo1DArray(paramJson.asInstanceOf[JsObject].getFields("l1")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject].getFields("reset")(0).asInstanceOf[JsArray])))
    l1 += ("refrac" -> Array(JsArrayTo1DArray(paramJson.asInstanceOf[JsObject].getFields("l1")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject].getFields("refrac")(0).asInstanceOf[JsArray])))
    l1 += ("decay"  -> Array(JsArrayTo1DArray(paramJson.asInstanceOf[JsObject].getFields("l1")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject].getFields("decay")(0).asInstanceOf[JsArray])))
    l1 += ("w1"     -> JsArrayTo2DArray(paramJson.asInstanceOf[JsObject].getFields("l1")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject].getFields("w1")(0).asInstanceOf[JsArray]))
    l1 += ("w2"     -> JsArrayTo2DArray(paramJson.asInstanceOf[JsObject].getFields("l1")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject].getFields("w2")(0).asInstanceOf[JsArray]))

    l2 += ("bias"   -> Array(JsArrayTo1DArray(paramJson.asInstanceOf[JsObject].getFields("l2")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject].getFields("biases")(0).asInstanceOf[JsArray])))
    l2 += ("thres"  -> Array(JsArrayTo1DArray(paramJson.asInstanceOf[JsObject].getFields("l2")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject].getFields("thresh")(0).asInstanceOf[JsArray])))
    l2 += ("reset"  -> Array(JsArrayTo1DArray(paramJson.asInstanceOf[JsObject].getFields("l2")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject].getFields("reset")(0).asInstanceOf[JsArray])))
    l2 += ("refrac" -> Array(JsArrayTo1DArray(paramJson.asInstanceOf[JsObject].getFields("l2")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject].getFields("refrac")(0).asInstanceOf[JsArray])))
    l2 += ("decay"  -> Array(JsArrayTo1DArray(paramJson.asInstanceOf[JsObject].getFields("l2")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject].getFields("decay")(0).asInstanceOf[JsArray])))
    l2 += ("w"      -> JsArrayTo2DArray(paramJson.asInstanceOf[JsObject].getFields("l2")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject].getFields("w")(0).asInstanceOf[JsArray]))
  }

}

class InterfaceReader { //Only for showcase
  var cores = Map.empty[Int, Array[Array[Int]]]

  def JsArrayTo1DArray (jarray: JsArray) : Array[Int] = {
    val jsonvallist = jarray.elements.toArray
    var returnArray : Array[Int] = Array()
    for (elem <- jsonvallist) returnArray = returnArray :+ elem.asInstanceOf[JsNumber].value.toInt
    return returnArray
  }

  def getFilter(coreID: Int) : Vector[Int] = {
    val source = scala.io.Source.fromFile("mapping/interfaceLut484c2.json")
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

object MakeDataFiles extends App{
  def toBinary(x : Int, len : Int): String = {
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
    var binStr = x.toHexString
    return binStr
  }

  val params = new ParameterReader
  val hex = false
  val potNrefrac = Array.fill(OSWEIGHT)(0).toVector


  for (i <- 2 until 4){//cores
    for (j <- 0 until EVALUNITS){ // Memories in core
      val weights          = params.getMemWeights(i, j)
      val biases           = params.getMemData("bias", i, j)
      val decays           = params.getMemData("decay", i, j)
      val thresholds       = params.getMemData("thres", i, j)
      val refracSets       = params.getMemData("refrac", i, j)
      val potentialSet     = params.getMemData("reset", i, j)

      val filedata = potNrefrac ++ weights ++ biases ++ decays ++ thresholds ++ refracSets ++ potentialSet
      val file1 = new PrintWriter(new File("mapping/evaldata"+"c"+i.toString+"e"+j.toString+".mem" ))

      for (d <- filedata){
        if(hex){
          file1.write(toHex(d, 17) + "\n")
        }else{
          file1.write(toBinary(d, 17) + "\n")
        }
      }

      file1.close

      /*val file = new PrintWriter(new File("evaldata"+"c"+i.toString+"e"+j.toString+".mif" ))
      file.write("DEPTH = "+ filedata.size.toString+";\nWIDTH = "+NEUDATAWIDTH.toString+";\nADDRESS_RADIX = DEC;\nDATA_RADIX = DEC;\nCONTENT\nBEGIN\n")

      var num = 0
      for (d <- filedata){
        file.write(num.toString + " : " + d.toString + ";\n")
        num = num + 1
      }

      file.write("END;")
      file.close*/

    }
  }
}