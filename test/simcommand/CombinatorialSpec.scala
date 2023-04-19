package simcommand

import org.scalatest.flatspec.AnyFlatSpec

class CombinatorialSpec extends AnyFlatSpec with SimcommandScalatestTester {
  "combinatorial detection" should "allow same thread read then write" in {
    val a = binding(0)

    val program = for {
      _ <- poke(a, 6)
      r <- peek(a)
    } yield r

    val result = unsafeRun(program, FakeClock(), Config())
    assert(result.retval == 6)
  }

  "combinatorial detection" should "detect simple combinatorial dependency" in {
    val a = binding(0)

    val t0 = poke(a, 5)
    val t1 = for {
      v <- peek(a)
      _ <- poke(a, v+1)
      r <- peek(a)
    } yield r

    val program = for {
      a <- fork(t0, "t0")
      b <- fork(t1, "t1")
      _ <- join(a)
      r <- join(b)
    } yield r

    assertThrows[CombinatorialDependencyException] { unsafeRun(program, FakeClock(), Config()) }
  }
}
