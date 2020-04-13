import chisel3._
import util._

object Constants{
    val CORES           = 16
    val NEUDATAWIDTH    = 16
    val AXONNR          = 1024
    val AXONIDWIDTH     = log2Up(AXONNR)
    val TMNEURONS       = 32
    val N               = log2Up(TMNEURONS)
    val EVALUNITS       = 8
    val GLOBALADDRWIDTH = log2Up(CORES)+log2Up(EVALUNITS)+N
    val AXONMSBWIDTH    = GLOBALADDRWIDTH - AXONIDWIDTH
}