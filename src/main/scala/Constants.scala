import chisel3._
import util._

object Constants{
    val NEUDATAWIDTH = 16
    val AXONNR       = 1024
    val AXONIDWIDTH  = log2Up(AXONNR)
}