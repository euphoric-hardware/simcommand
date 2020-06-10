scalaVersion := "2.11.12"

resolvers ++= Seq(
  Resolver.sonatypeRepo("snapshots"),
  Resolver.sonatypeRepo("releases")
)
libraryDependencies += "edu.berkeley.cs" %% "chisel3" % "3.3.1"
libraryDependencies += "edu.berkeley.cs" %% "chisel-iotesters" % "1.3.2"
libraryDependencies += "org.scalatest" %% "scalatest" % "3.0.5" % "test"
libraryDependencies += "io.spray" %%  "spray-json" % "1.3.5"
// chisel testers 2: 0.1.2
