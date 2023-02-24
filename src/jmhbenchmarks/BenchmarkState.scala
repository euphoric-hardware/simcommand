package jmhbenchmarks

import chisel3._
import chiseltest.{HasTestName, VerilatorBackendAnnotation, WriteVcdAnnotation, defaults}
import chiseltest.formal.Formal
import chiseltest.internal.{BackendInstance, Context, NoThreadingAnnotation, TestEnvInterface}
import firrtl.options.TargetDirAnnotation
import org.openjdk.jmh.annotations.{Level, Setup}

import java.io.File


class BenchmarkState[R <: Module](mod: () => R) extends TestEnvInterface with HasTestName with Formal {
  var tester: BackendInstance[R] = null
  var testname: String = null
  var topFileName: Option[String] = null

  def setup() {
    val testname = s"chisel_test_${System.currentTimeMillis()}"
    topFileName = Some(testname)
    batchedFailures.clear()
    val annotation = TargetDirAnnotation("test_run_dir" + File.separator + testname)
    tester = defaults.createDefaultTester(mod, Seq(annotation, VerilatorBackendAnnotation, NoThreadingAnnotation))
  }

  def getTestName = testname

  def test(testFn: R => Unit) {
    Context.run(tester, this, testFn)
  }
}