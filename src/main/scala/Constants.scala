import chisel3._
import util._

object Constants{
    val CORES            = 16
    val NEUDATAWIDTH     = 16
    val AXONNR           = 1024
    val AXONIDWIDTH      = log2Up(AXONNR)
    val TMNEURONS        = 32
    val N                = log2Up(TMNEURONS)
    val EVALUNITS        = 8
    val GLOBALADDRWIDTH  = log2Up(CORES)+log2Up(EVALUNITS)+N
    val AXONMSBWIDTH     = GLOBALADDRWIDTH - AXONIDWIDTH
    val EVALMEMADDRWIDTH = log2Up(6*TMNEURONS+TMNEURONS*AXONNR)

    //offsets
    val OSWEIGHT    = 2*TMNEURONS
    val OSBIAS      = 2*TMNEURONS+TMNEURONS*AXONNR
    val OSDECAY     = 3*TMNEURONS+TMNEURONS*AXONNR
    val OSTHRESH    = 4*TMNEURONS+TMNEURONS*AXONNR
    val OSREFRACSET = 5*TMNEURONS+TMNEURONS*AXONNR
    
}