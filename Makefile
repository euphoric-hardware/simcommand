# Environment variables
SBT := sbt
pyt := python3

.PHONY : all
all : proc map

proc :
	$(SBT) "runMain neuroproc.MakeDataFiles"
	$(SBT) "runMain neuroproc.NeuromorphicProcessor"
	
map :
	$(pyt) ./mapping/insertlines.py

.PHONY : clean
clean :
	$(SBT) clean

.PHONY : test
test :
	ifeq (, $(shell which vcs))
		$(SBT) "testOnly neuroproc.unittests.* -- -l neuroproc.unittests.VcsTest"
		$(SBT) "testOnly neuroproc.systemtests.* -- -l neuroproc.systemtests.VcsTest"
	else
		$(SBT) test
	endif
