# Environment variables
SBT := sbt

.PHONY : all
all : proc vivado

proc :
	python mapping/convert.py mapping/networkData.json
	$(SBT) "runMain MakeDataFiles mapping/networkData_fp.json"
	$(SBT) "runMain neuroproc.NeuromorphicProcessor"
	python mapping/synthesis.py

vivado :
	./mapping/gentcl.sh

.PHONY : clean
clean :
	$(SBT) clean
	rm -rf build
	rmdir build
	rm -rf mapping/meminit
	rmdir mapping/meminit
	rm -rf target
	rmdir target
	rm -rf test_run_dir
	rmdir test_run_dir

.PHONY : test
test :
	$(SBT) test
