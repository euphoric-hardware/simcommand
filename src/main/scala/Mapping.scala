import neuroproc._

import java.io._
import spray.json._

// Expects a JSON file path as its first argument
object MakeDataFiles extends App {
  require(args.length > 0)

  def to2aryString(x: Int, len: Int) = {
    val binStr = x.toBinaryString
    if (binStr.length >= len) binStr.substring(binStr.length - len)
    else s"${if (x >= 0) 0 else 1}" * (len - binStr.length) + binStr
  }

  // Fetch the parameters from the specified JSON file
  val params = new ParameterReader(args(0))

  // Generate memory initialization files
  for (core <- 2 until 4) {
    // Constant memories
    val cpw = new PrintWriter(new File(s"mapping/meminit/constc${core}.mem"))
    cpw.write(to2aryString(params.getMemData("reset", core)(0), 17)+"\n")
    cpw.write(to2aryString(params.getMemData("refrac", core)(0), 17)+"\n")
    cpw.write(to2aryString(params.getMemData("decay", core)(0), 17)+"\n")
    cpw.write(to2aryString(0, 17)+"\n")
    cpw.close

    // Potentials and refrac counters
    val ppw = new PrintWriter(new File(s"mapping/meminit/potrefc${core}.mem"))
    ppw.write(Array.fill(2*TMNEURONS)(to2aryString(0, 17)).deep.mkString("\n")+"\n")
    ppw.close

    for (eval <- 0 until EVALUNITS) {
      // Biases and thresholds
      val bpw = new PrintWriter(new File(s"mapping/meminit/biasthreshc${core}e${eval}.mem"))
      bpw.write(params.getMemData("biases", core, eval).map(to2aryString(_, 17)).deep.mkString("\n")+"\n")
      bpw.write(params.getMemData("thresh", core, eval).map(to2aryString(_, 17)).deep.mkString("\n")+"\n")
      bpw.close

      // Weights
      val wpw = new PrintWriter(new File(s"mapping/meminit/weightsc${core}e${eval}.mem"))
      wpw.write(params.getMemWeights(core, eval).map(to2aryString(_, 17)).deep.mkString("\n")+"\n")
      wpw.close
    }
  }
}

class ParameterReader(file: String) {
  var l1 = Map.empty[String, Array[Array[Int]]]
  var l2 = Map.empty[String, Array[Array[Int]]]

  def JsArrayTo1DArray(jarray: JsArray) = {
    jarray.elements.toArray.map(_.asInstanceOf[JsNumber].value.toInt)
  }

  def JsArrayTo2DArray(jarray: JsArray) = {
    jarray.elements.toArray.map(x => JsArrayTo1DArray(x.asInstanceOf[JsArray]))
  }

  def JsFieldToArray(obj: JsObject, field: String) = {
    Array(JsArrayTo1DArray(obj.getFields(field)(0).asInstanceOf[JsArray]))
  }

  def getMemData(name: String, coreID: Int, evalID: Int = 0) = {
    require(coreID == 2 || coreID == 3)
    var memData = Array.fill(TMNEURONS)(0)
    val allData = if (coreID == 2) l1(name)(0) else l2(name)(0)

    for (i <- 0 until TMNEURONS)
      if (i*EVALUNITS + evalID < 200) // Data only available for 200 neurons
        memData(i) = allData(i*EVALUNITS + evalID)
    
    memData
  }

  def getMemWeights(coreID: Int, evalID: Int) = {
    require(coreID == 2 || coreID == 3)
    var memData = Array.fill(TMNEURONS*256*3)(0)
    val allData1 = if (coreID == 2) l1("w1") else l2("w")
    val allData2 = l1("w2")
    
    if (coreID == 2) {
      for (i <- 0 until TMNEURONS) {
        val idx = i*EVALUNITS + evalID
        if (idx < 200) {                          // Data only available for 200 neurons
          for (j <- 0 until 3*256) {
            if (j < 484) {                        // Weights for X_to_Ae connection
              memData(i*3*256 + j) = allData1(j)(idx)
            } else if (j >= 512 && j < 512+200) { // Weights for Ai_to_Ae connection
              memData(i*3*256 + j) = allData2(j-512)(idx)
            }
          }
        }
      }
    } else {
      for (i <- 0 until TMNEURONS) {
        val idx = i*EVALUNITS + evalID
        if (idx < 200) {                          // Data only available for 200 neurons
          for (j <- 0 until 3*256) {
            if (j < 200) {                        // Weights for Ae_to_Ai connection
              memData(i*3*256 + j) = allData1(j)(idx)
            }
          }
        }
      }
    }
    
    memData
  }

  // Initialization code
  val source = scala.io.Source.fromFile(file)
  val lines = try source.mkString.parseJson.asInstanceOf[JsObject] finally source.close()
  val l1Json = lines.getFields("l1")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject]
  l1 += ("biases" -> JsFieldToArray(l1Json, "biases"))
  l1 += ("thresh" -> JsFieldToArray(l1Json, "thresh"))
  l1 += ("reset"  -> JsFieldToArray(l1Json, "reset"))
  l1 += ("refrac" -> JsFieldToArray(l1Json, "refrac"))
  l1 += ("decay"  -> JsFieldToArray(l1Json, "decay"))
  l1 += ("w1"     -> JsArrayTo2DArray(l1Json.getFields("w1")(0).asInstanceOf[JsArray]))
  l1 += ("w2"     -> JsArrayTo2DArray(l1Json.getFields("w2")(0).asInstanceOf[JsArray]))

  val l2Json = lines.getFields("l2")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject]
  l2 += ("biases" -> JsFieldToArray(l2Json, "biases"))
  l2 += ("thresh" -> JsFieldToArray(l2Json, "thresh"))
  l2 += ("reset"  -> JsFieldToArray(l2Json, "reset"))
  l2 += ("refrac" -> JsFieldToArray(l2Json, "refrac"))
  l2 += ("decay"  -> JsFieldToArray(l2Json, "decay"))
  l2 += ("w"      -> JsArrayTo2DArray(l2Json.getFields("w")(0).asInstanceOf[JsArray]))
}
