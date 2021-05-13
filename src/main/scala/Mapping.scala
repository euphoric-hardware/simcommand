import neuroproc._

import java.io._
import spray.json._

/** Generates memory initialization files from a JSON file
  * 
  * @param #1 the JSON file to read
  * 
  * Run this script with SBT as
  * {{{
  * sbt "runMain MakeDataFiles path/to/json/file.json"
  * }}}
  * Output files are stored in ./mapping/meminit
  * 
  * @note The encoding is custom and network specific. For now, the following is used:
  * - Reset potential, refrac period, and decay are 5 bits (converted on-the-fly)
  * - Potentials and refrac counts are 17 bits (7.10 and 17.0, respectively)
  * - Biases and thresholds are 17 bits (7.10)
  * - Weights are 11 bits (two different formats; learnt weights 0.10, constant weights 
  *   6.4), MSB decides between the two
  */
object MakeDataFiles extends App {
  require(args.length > 0)

  /** Returns a binary string representation of an integer
    * 
    * @param x the integer to convert
    * @param len the desired length of the string representation
    * @return a binary string representation of `x` of length `len`
    */
  def to2aryString(x: Int, len: Int) = {
    val binStr = x.toBinaryString
    if (binStr.length >= len) binStr.substring(binStr.length - len)
    else s"${if (x >= 0) 0 else 1}" * (len - binStr.length) + binStr
  }

  // Fetch the parameters from the specified JSON file
  val params = new ParameterReader(args(0), USEROUNDEDWGHTS)

  // Create a directory for the files
  val dir = new File("mapping/meminit")
  dir.mkdir()

  // Generate memory initialization files
  for (core <- 2 until 4) {
    // Constant memories
    val cpw = new PrintWriter(new File(s"mapping/meminit/constc${core}.mem"))
    cpw.write(to2aryString(params.getMemData("reset", core)(0), 5)+"\n")
    cpw.write(to2aryString(params.getMemData("refrac", core)(0), 5)+"\n")
    cpw.write(to2aryString(params.getMemData("decay", core)(0), 5)+"\n")
    cpw.write(to2aryString(0, 5)+"\n")
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
      val wghts = params.getMemWeights(core, eval)
      wpw.write(wghts.map { p =>
        (if (p._1) "1" else "0") + to2aryString(p._2, 10)
      }.deep.mkString("\n")+"\n")
      wpw.close
    }
  }
}

/** Provides easy access to a ShowCaseNet instance stored as a JSON file
  * 
  * @param file the JSON file to read
  */
class ParameterReader(file: String, round: Boolean = true) {
  // Integer methods
  /** Converts a JsArray to a 1D Int-array
    * 
    * @param jarray the JsArray instance to convert
    * @return an Array[Int] object with the contents of `jarray`
    */
  def JsArrayTo1DIntArray(jarray: JsArray) = {
    jarray.elements.toArray.map(_.asInstanceOf[JsNumber].value.toInt)
  }

  /** Converts a JsArray to a 2D Int-array
    * 
    * @param jarray the JsArray instance to convert
    * @return an Array[Array[Int]] object with the contents of `jarray`
    */
  def JsArrayTo2DIntArray(jarray: JsArray) = {
    jarray.elements.toArray.map(x => JsArrayTo1DIntArray(x.asInstanceOf[JsArray]))
  }

  /** Converts a JsObject's specified field to a 1D Int-array
    * 
    * @param obj the JsObject instance to look up into and convert from
    * @param field the specific field to look up
    * @return an Array[Int] object with the contents of `field` in `obj`
    */
  def JsFieldToIntArray(obj: JsObject, field: String) = {
    Array(JsArrayTo1DIntArray(obj.getFields(field)(0).asInstanceOf[JsArray]))
  }

  // Float methods
  /** Converts a JsArray to a 1D Float-array
    * 
    * @param jarray the JsArray instance to convert
    * @return an Array[Float] object with the contents of `jarray`
    */
  def JsArrayTo1DFloatArray(jarray: JsArray) = {
    jarray.elements.toArray.map(_.asInstanceOf[JsNumber].value.toFloat)
  }

  /** Converts a JsArray to a 2D Float-array
    * 
    * @param jarray the JsArray instance to convert
    * @return an Array[Array[Float]] object with the contents of `jarray`
    */
  def JsArrayTo2DFloatArray(jarray: JsArray) = {
    jarray.elements.toArray.map(x => JsArrayTo1DFloatArray(x.asInstanceOf[JsArray]))
  }

  /** Converts a JsObject's specified field to a 1D Float-array
    * 
    * @param obj the JsObject instance to look up into and convert from
    * @param field the specific field to look up
    * @return an Array[Float] object with the contents of `field` in `obj`
    */
  def JsFieldToFloatArray(obj: JsObject, field: String) = {
    Array(JsArrayTo1DFloatArray(obj.getFields(field)(0).asInstanceOf[JsArray]))
  }

  /** Generates an array with memory data for a specified (coreID, evalID) pair
    * 
    * @param name the field to look up
    * @param coreID the neuron core ID of the memory
    * @param evalID the neuron evaluator ID of the memory
    * @param binPoint the number of fixed-point decimals to use for Float parameters
    * @return an Array[Int] object with the initialization data for parameter `name`
    *         for core `coreID` evaluator `evalID` with Float parameters mapped to 
    *         fixed-point with `binPoint` decimal bits
    */
  def getMemData(name: String, coreID: Int, evalID: Int = 0, binPoint: Int = 10) = {
    require(name != "w1" && name != "w2" && name != "w")
    require(coreID == 2 || coreID == 3)
    require(l1.contains(name) || l1F.contains(name) || l2.contains(name) || l2F.contains(name))
    var memData = Array.fill(TMNEURONS)(0)

    // Fetch the data from either map, which contains the given key
    val intData = coreID match {
      case 2 => if (l1.contains(name)) Some(l1(name)(0)) else None
      case _ => if (l2.contains(name)) Some(l2(name)(0)) else None
    }
    val floatData = coreID match {
      case 2 => if (l1F.contains(name)) Some(l1F(name)(0)) else None
      case _ => if (l2F.contains(name)) Some(l2F(name)(0)) else None
    }

    // Fill out the memory data for the specified parameters
    (intData, floatData) match {
      case (Some(arr), None) => 
        for (i <- 0 until TMNEURONS)
          if (i*EVALUNITS + evalID < 200) // Data only available for 200 neurons
            memData(i) = arr(i*EVALUNITS + evalID)
      case (None, Some(arr)) => 
        for (i <- 0 until TMNEURONS)
          if (i*EVALUNITS + evalID < 200) // Data only available for 200 neurons
            memData(i) = (arr(i*EVALUNITS + evalID) * (1 << binPoint)).round
            //memData(i) = (arr(i*EVALUNITS + evalID) * (1 << binPoint)).toInt
      case _ => throw new IllegalArgumentException("expects either Int or Float data, but not neither nor both")
    }
    memData
  }

  /** Generates an array with weight memory data for a specified (coreID, evalID) pair
    * 
    * @param coreID the neuron core ID of the memory
    * @param evalID the neuron evaluator ID of the memory
    * @param binPoint1 the number of fixed-point decimals to use for learnt weights
    * @param binPoint2 the number of fixed-point decimals to use for constant weights
    * @return an Array[(Boolean, Int)] object with the initialization weights for core 
    *         `coreID` evaluator `evalID` with learnt weights mapped to fixed-point with 
    *         `binPoint1` decimal bits and constant weights with `binPoint2` decimals
    */
  def getMemWeights(coreID: Int, evalID: Int, binPoint1: Int = 10, binPoint2: Int = 4) = {
    require(coreID == 2 || coreID == 3)
    var memData = Array.fill(TMNEURONS*3*256)((false, 0))
    val allData1 = if (coreID == 2) l1F("w1") else l2F("w")
    val allData2 = l1F("w2")

    // Fill out the memory data for the specified parameters
    coreID match {
      case 2 =>
        for (i <- 0 until TMNEURONS) {
          val idx = i*EVALUNITS + evalID
          if (idx < 200) {                          // Data only available for 200 neurons
            for (j <- 0 until 3*256) {
              if (j < 484)                          // Weights for X_to_Ae connection
                if (round)
                  memData(i*3*256 + j) = (false, (allData1(j)(idx) * (1 << binPoint1)).round)
                else
                  memData(i*3*256 + j) = (false, (allData1(j)(idx) * (1 << 10)).toInt)
              else if (j >= 512 && j < 512+200)     // Weights for Ai_to_Ae connection
                if (round)
                  memData(i*3*256 + j) = (true, (allData2(j-512)(idx) * (1 << binPoint2)).round)
                else
                  memData(i*3*256 + j) = (true, (allData2(j-512)(idx) * (1 << 4)).toInt)
            }
          }
        }
      case _ =>
        for (i <- 0 until TMNEURONS) {
          val idx = i*EVALUNITS + evalID
          if (idx < 200)                            // Data only available for 200 neurons
            for (j <- 0 until 256)
              if (j < 200)                          // Weights for Ae_to_Ai connection
              if (round)
                memData(i*3*256 + j) = (true, (allData1(j)(idx) * (1 << binPoint2)).round)
              else
                memData(i*3*256 + j) = (true, (allData1(j)(idx) * (1 << 4)).toInt)
        }
    }
    memData
  }

  // Initialization code
  var l1  = Map.empty[String, Array[Array[Int]]]
  var l1F = Map.empty[String, Array[Array[Float]]]
  var l2  = Map.empty[String, Array[Array[Int]]]
  var l2F = Map.empty[String, Array[Array[Float]]]

  val source = scala.io.Source.fromFile(file)
  val lines = try source.mkString.parseJson.asInstanceOf[JsObject] finally source.close()
  val l1Json = lines.getFields("l1")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject]
  val l2Json = lines.getFields("l2")(0).asInstanceOf[JsArray].elements(0).asInstanceOf[JsObject]

  // L1 integer parameters
  l1 += ("reset"  -> JsFieldToIntArray(l1Json, "reset"))
  l1 += ("refrac" -> JsFieldToIntArray(l1Json, "refrac"))
  l1 += ("decay"  -> JsFieldToIntArray(l1Json, "decay"))

  // L1 float parameters
  l1F += ("biases" -> JsFieldToFloatArray(l1Json, "biases"))
  l1F += ("thresh" -> JsFieldToFloatArray(l1Json, "thresh"))
  l1F += ("w1"     -> JsArrayTo2DFloatArray(l1Json.getFields("w1")(0).asInstanceOf[JsArray]))
  l1F += ("w2"     -> JsArrayTo2DFloatArray(l1Json.getFields("w2")(0).asInstanceOf[JsArray]))

  // L2 integer parameters
  l2 += ("reset"  -> JsFieldToIntArray(l2Json, "reset"))
  l2 += ("refrac" -> JsFieldToIntArray(l2Json, "refrac"))
  l2 += ("decay"  -> JsFieldToIntArray(l2Json, "decay"))

  // L2 float parameters
  l2F += ("biases" -> JsFieldToFloatArray(l2Json, "biases"))
  l2F += ("thresh" -> JsFieldToFloatArray(l2Json, "thresh"))
  l2F += ("w"      -> JsArrayTo2DFloatArray(l2Json.getFields("w")(0).asInstanceOf[JsArray]))
}
