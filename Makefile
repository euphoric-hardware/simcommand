
kintexDemo:
	-sbt "runMain MakeDataFiles"
	-sbt "runMain NeuromorphicProcessor"
	-python3 mapping/InsertLines.py