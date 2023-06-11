import mill._
import scalalib._
import publish._

object simcommand extends ScalaModule with PublishModule {
  override def millSourcePath = os.pwd

  def scalaVersion = "2.13.8"

  def publishVersion = "0.0.1"

  def chiselVersion = "3.5.4"

  override def ivyDeps = Agg(
    ivy"edu.berkeley.cs::chisel3:$chiselVersion",
    ivy"edu.berkeley.cs::chiseltest:0.5.4",
    ivy"org.scala-lang.modules::scala-async:0.10.0",
    ivy"com.lihaoyi::sourcecode:0.3.0",
  )

  override def scalacOptions = Seq(
    "-language:reflectiveCalls",
    "-deprecation",
    "-feature",
    "-Xcheckinit",
    "-Xasync",
  )

  override def scalacPluginIvyDeps = Agg(ivy"edu.berkeley.cs:::chisel3-plugin:$chiselVersion")

  def pomSettings = PomSettings(
    description = "A monadic embedded-DSL for testing circuits",
    organization = "edu.berkeley.cs",
    url = "https://github.com/vighneshiyer/simcommand",
    licenses = Seq(License.`BSD-3-Clause-Attribution`),
    versionControl = VersionControl.github("vighneshiyer", "simcommand"),
    developers = Seq(
      Developer("vighneshiyer", "Vighnesh Iyer", "https://github.com/vighneshiyer"),
      Developer("yjp20", "Young-Jin Park", "https://github.com/yjp20"),
    )
  )

  override def scalaDocOptions = Seq(
    "-siteroot",
    "docs",
    "-no-link-warnings"
  )

  object test extends Tests with TestModule.ScalaTest {
    override def millSourcePath = os.pwd / "test"
    override def sources = T.sources { millSourcePath }

    override def ivyDeps = Agg(ivy"org.scalatest::scalatest:3.2.9")
  }
}

def docs = T {
  os.remove.all(T.workspace / "docs")
  simcommand.docJar()
  os.makeDir(T.workspace / "docs")
  os.copy.into(T.workspace / "out" / "simcommand" / "docJar.dest" / "javadoc", T.workspace / "docs", mergeFolders = true)
}



