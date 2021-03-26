import fileinput
import os

def  modify_file(file_name,pattern,value=""):  
    with fileinput.FileInput(file_name, inplace=True, backup='.bak') as file:
        for line in file:
            print(line.replace(pattern, value), end='')  

mappingpath = os.path.dirname(os.path.abspath(__file__))
for i in range(8):
    modify_file("build/NeuromorphicProcessor.v",
                "  reg [16:0] eMem2e"+str(i)+" [0:24799];",
                "  reg [16:0] eMem2e"+str(i)+" [0:24799];\n  initial begin\n  $readmemb(\""+mappingpath+"/evaldatac2e"+str(i)+".mem\", eMem2e"+str(i)+");\n  end")

for i in range(8):
    modify_file("build/NeuromorphicProcessor.v",
                "  reg [16:0] eMem3e"+str(i)+" [0:24799];",
                "  reg [16:0] eMem3e"+str(i)+" [0:24799];\n  initial begin\n  $readmemb(\""+mappingpath+"/evaldatac3e"+str(i)+".mem\", eMem3e"+str(i)+");\n  end")
