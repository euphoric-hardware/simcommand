scalaVersion := "2.12.12"

scalacOptions := Seq("-Xsource:2.11", "-deprecation")

resolvers ++= Seq(
  Resolver.sonatypeRepo("snapshots"),
  Resolver.sonatypeRepo("releases")
)

libraryDependencies ++= Seq(
  "edu.berkeley.cs" %% "chisel3" % "3.5-SNAPSHOT",
  "edu.berkeley.cs" %% "chiseltest" % "0.5-SNAPSHOT",
  "org.scalatest" %% "scalatest" % "3.2.6",
  "io.spray" %%  "spray-json" % "1.3.5"
)
