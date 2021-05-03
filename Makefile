# Environment variables
SBT := sbt

.PHONY : all
all : proc vivado

proc :
	$(SBT) "runMain neuroproc.MakeDataFiles mapping/networkData.json"
	$(SBT) "runMain neuroproc.NeuromorphicProcessor"

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
