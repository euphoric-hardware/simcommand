import chisel3._
import util._

object Constants{
    val CORES        = 16
    val NEUDATAWIDTH = 16
    val AXONNR       = 1024
    val AXONIDWIDTH  = log2Up(AXONNR)
    val TMPNEURONS   = 32
    val N            = log2Up(TMPNEURONS)
    val EVALUNITS    = 8
}