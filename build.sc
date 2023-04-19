import mill._, scalalib._, publish._

object simcommand extends ScalaModule with PublishModule {
  def millSourcePath = os.pwd

  def scalaVersion = "2.13.8"

  def publishVersion = "0.0.1"

  def chiselVersion = "3.5.4"

  def ivyDeps = Agg(
    ivy"edu.berkeley.cs::chisel3:${chiselVersion}",
    ivy"edu.berkeley.cs::chiseltest:0.5.4",
    ivy"org.scala-lang.modules::scala-async:0.10.0",
  )

  def scalacOptions = Seq(
    "-language:reflectiveCalls",
    "-deprecation",
    "-feature",
    "-Xcheckinit",
    "-Xasync",
  )

  def scalacPluginIvyDeps = Agg(ivy"edu.berkeley.cs:::chisel3-plugin:${chiselVersion}")

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

  object test extends Tests with TestModule.ScalaTest {
    def millSourcePath = os.pwd / "test"
    def sources = T.sources { millSourcePath }

    def ivyDeps = Agg(ivy"org.scalatest::scalatest:3.2.9")
  }
}



