# Environment variables
SBT := sbt

.PHONY : all
all : proc

proc :
	$(SBT) "runMain neuroproc.MakeDataFiles"
	$(SBT) "runMain neuroproc.NeuromorphicProcessor"

.PHONY : clean
clean :
	$(SBT) clean
	rm -rf build
	rmdir build
	rm -rf target
	rmdir target
	rm -rf test_run_dir
	rmdir test_run_dir

.PHONY : test
test :
	ifeq (, $(shell which vcs))
		$(SBT) "testOnly neuroproc.unittests.* -- -l neuroproc.unittests.VcsTest"
		$(SBT) "testOnly neuroproc.systemtests.* -- -l neuroproc.systemtests.VcsTest"
	else
		$(SBT) test
	endif
