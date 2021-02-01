
kintexDemo:
	-sbt "runMain neuroproc.MakeDataFiles"
	-sbt "runMain neuroproc.NeuromorphicProcessor"
	-python3 mapping/InsertLines.py