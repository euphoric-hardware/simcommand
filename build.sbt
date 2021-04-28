scalaVersion := "2.12.12"

scalacOptions := Seq("-Xsource:2.11", "-deprecation")

resolvers ++= Seq(
  Resolver.sonatypeRepo("snapshots"),
  Resolver.sonatypeRepo("releases")
)

addCompilerPlugin("edu.berkeley.cs" % "chisel3-plugin" % "3.4.3" cross CrossVersion.full)

libraryDependencies ++= Seq(
  "edu.berkeley.cs" %% "chisel3" % "3.4.3",
  "edu.berkeley.cs" %% "chiseltest" % "0.3.3",
  "io.spray" %%  "spray-json" % "1.3.5"
)
