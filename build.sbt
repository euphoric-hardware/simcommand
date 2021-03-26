scalaVersion := "2.12.12"

scalacOptions := Seq("-Xsource:2.11", "-deprecation")

resolvers ++= Seq(
  Resolver.sonatypeRepo("snapshots"),
  Resolver.sonatypeRepo("releases")
)

libraryDependencies ++= Seq(
  "edu.berkeley.cs" %% "chisel3" % "3.4.2",
  "edu.berkeley.cs" %% "chiseltest" % "0.3.2",
  "org.scalatest" %% "scalatest" % "3.0.8",
  "io.spray" %%  "spray-json" % "1.3.5"
)
