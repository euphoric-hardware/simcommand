import chisel3.iotesters.PeekPokeTester
import org.scalatest._
class AxonSystemTest(dut: AxonSystem) extends PeekPokeTester(dut) {

   // set all inputs low

    poke(dut.io.axonIn ,0)
    poke(dut.io.axonValid, false)
    poke(dut.io.inOut, false)
    poke(dut.io.rAddr,0)
    poke(dut.io.rEna, false)
    step(5)
    
    //write to one mem
    for(i <- 0 to 1024*5-1){
        if(i % 5 == 0){
            poke(dut.io.axonIn, (i/5))
            poke(dut.io.axonValid, true)

        }else{
            poke(dut.io.axonValid, false)
        }
        step(1)
    }



    //read the other mem
    poke(dut.io.rEna, true)
    for(i <- 0 to 1024-1){
        //println("read step: " + i.toString)
        poke(dut.io.rAddr,i)
        step(1)
        //println("data: " + peek(dut.io.rData).toString)
        expect(dut.io.rData, 0)
    }
    poke(dut.io.rEna, false)

    step(5)

    poke(dut.io.inOut, true)

    step(5)

    poke(dut.io.rEna, true)
    for(i <- 0 to 1024-1){
        //println("2nd read step: " + i.toString)
        poke(dut.io.rAddr,i)
        step(1)
        //println("data expect: " + (i*5).toString + "Get: " + peek(dut.io.rData).toString)
        expect(dut.io.rData, i )
    }
    poke(dut.io.rEna, false)

    step(5)




  

}

class AxonSystemSpec extends FlatSpec with Matchers {
  "AxonSystem " should "pass" in {
    chisel3.iotesters.Driver.execute(Array("--generate-vcd-output", "on"), () => new AxonSystem()) { c => new AxonSystemTest(c)} should be (true)
  }
}