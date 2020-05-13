import Constants._
import chisel3._
import spray.json._
import util._

import scala.math.pow

object Constants {
  val FREQ             = 80 //in MHz
  val TIMESTEP         = 1000 //micro seconds
  val CYCLESPRSTEP     = (FREQ * pow(10, 6).toInt) / TIMESTEP
  val CORES            = 7
  val NEUDATAWIDTH     = 16
  val AXONNR           = 1024
  val AXONIDWIDTH      = log2Up(AXONNR)
  val TMNEURONS        = 32
  val N                = log2Up(TMNEURONS)
  val EVALUNITS        = 8
  val GLOBALADDRWIDTH  = log2Up(CORES) + log2Up(EVALUNITS) + N
  val AXONMSBWIDTH     = GLOBALADDRWIDTH - AXONIDWIDTH
  val EVALMEMADDRWIDTH = log2Up(7 * TMNEURONS + TMNEURONS * AXONNR)

  //offsets
  val OSREFRAC    = 0
  val OSPOTENTIAL = TMNEURONS
  val OSWEIGHT    = 2 * TMNEURONS
  val OSBIAS      = 2 * TMNEURONS + TMNEURONS * AXONNR
  val OSDECAY     = 3 * TMNEURONS + TMNEURONS * AXONNR
  val OSTHRESH    = 4 * TMNEURONS + TMNEURONS * AXONNR
  val OSREFRACSET = 5 * TMNEURONS + TMNEURONS * AXONNR
  val OSPOTSET    = 6 * TMNEURONS + TMNEURONS * AXONNR

  //Hardcoded - consider chancing to be part of conf files or similar
  val neuronsInCore = Array(64, 64, 64, 64, 64) // Dummy Conf
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
    if (coreID == 2 || coreID == 3){
      allData = l1(name)(0)
      if (coreID == 3) offset = 100
    }else if (coreID == 4 || coreID == 5){
      allData = l2(name)(0)
      if (coreID == 5) offset = 100
    }

    for (i <- 0 until TMNEURONS) {
      if (100 > i*EVALUNITS + evalID) {
        memData(i) = allData(i*EVALUNITS + evalID + offset)
      }
    }

    return memData.toVector
  }

  def getMemWeights(coreID: Int, evalID: Int) : Vector[Int] = {
    var memData = Array.fill(TMNEURONS*AXONNR)(0)
    var allData1 : Array[Array[Int]] = Array()
    var allData2 : Array[Array[Int]] = Array()
    var offset = 0
    if (coreID == 2 || coreID == 3){
      allData1 = l1("w1")
      allData2 = l1("w2")
      if (coreID == 3) offset = 100
      for (i <- 0 until TMNEURONS) {
        if (100 > i*EVALUNITS + evalID) {
          for (j <- 0 until AXONNR) {
            if (j < 484) {
              memData(i*AXONNR + j) = allData1(j)(i*EVALUNITS + evalID + offset)
            }else if (j >= 512 && j < 512+100){
              memData(i*AXONNR + j) = allData2(j-512)(i*EVALUNITS + evalID + offset)
            }else if (j >= 768 && j < 768+100){
              memData(i*AXONNR + j) = allData2(j-768+100)(i*EVALUNITS + evalID + offset)
            }
          }
        }
      }
    }else if (coreID == 4 || coreID == 5){
      allData1 = l2("w")
      if (coreID == 5) offset = 100
      for (i <- 0 until TMNEURONS) {
        if (100 > i*EVALUNITS + evalID) {
          for (j <- 0 until AXONNR) {
            if (j < 100) {
              memData(i*AXONNR + j) = allData1(j)(i*EVALUNITS + evalID + offset)
            }else if (j >=256 && j < 256+100) {
              memData(i*AXONNR + j) = allData2(j-256+100)(i*EVALUNITS + evalID + offset)
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