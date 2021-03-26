package neuroproc

import org.scalatest.Tag

package object unittests {
  object VcsTest extends Tag("neuroproc.unittests.VcsTest")
  object SlowTest extends Tag("neuroproc.unittests.SlowTest")
}
