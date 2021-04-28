package neuroproc

import org.scalatest.Tag

package object systemtests {
  object SlowTest extends Tag("neuroproc.systemtests.SlowTest")

  implicit def boolean2int(bool: Boolean) = if (bool) 1 else 0
}
