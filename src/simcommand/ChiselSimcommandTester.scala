package simcommand

import java.io.File;
import chiseltest.{TestResult, defaults}
import chiseltest.internal.{Context, NoThreadingAnnotation, TestEnvInterface}
import firrtl.AnnotationSeq
import firrtl.options.TargetDirAnnotation
import org.scalatest.Assertions

trait ChiselSimcommandTester extends Assertions {
  val testName: String = s"chisel_test_${System.currentTimeMillis()}"

  class TestBuilder[R <: chisel3.Module](val dutGen: () => R, val annotationSeq: AnnotationSeq) extends TestEnvInterface  {
    def apply(testFn: R => Unit): TestResult = {
      batchedFailures.clear()
      Context.run(defaults.createDefaultTester(dutGen, annotationSeq), this, testFn)
    }

    def withAnnotations(annotationSeq: AnnotationSeq): TestBuilder[R] = {
      new TestBuilder[R](dutGen, this.annotationSeq ++ annotationSeq)
    }

    override def topFileName: Option[String] = None
  }

  def test[T <: chisel3.Module](dutGen: => T): TestBuilder[T] = {
    val annotations = Seq(TargetDirAnnotation("test_run_dir" + File.separator + testName), NoThreadingAnnotation)
    new TestBuilder(() => dutGen, annotations)
  }
}
