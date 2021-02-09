scalaVersion := "2.12.12"

scalacOptions := Seq("-Xsource:2.11")

resolvers ++= Seq(
  Resolver.sonatypeRepo("snapshots"),
  Resolver.sonatypeRepo("releases")
)

libraryDependencies ++= Seq(
  "edu.berkeley.cs" %% "chisel3" % "3.3.2",
  "edu.berkeley.cs" %% "chiseltest" % "0.2.3",
  "org.scalatest" %% "scalatest" % "3.0.5" % "test",
  "io.spray" %%  "spray-json" % "1.3.5"
)
