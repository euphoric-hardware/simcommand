import fileinput
import sys

f = open("mapping/periods.txt", "r")
f2 = open("mapping/in0mem.mem","w")
for i in range(256):
    line = f.readline()
    aint = int(line[0:-1])
    abin = bin(aint)[2:].zfill(9)
    f2.write(abin+"\n")
f2.close()
f3 = open("mapping/in1mem.mem","w")
for i in range(484-256):
    line = f.readline()
    aint = int(line[0:-1])
    abin = bin(aint)[2:].zfill(9)
    f3.write(abin+"\n")
f3.close()
f.close()

