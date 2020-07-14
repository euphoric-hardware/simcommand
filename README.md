# NeuromorphicProcessor
Neuromorphic processor implementation for Master thesis


## Install guide (Tested only with Ubuntu 18.04 and 19.04):
### Java 8

    $sudo apt update
    $sudo apt install openjdk-8-jdk openjdk-8-jre

Make java 8 the default java version 

    $sudo update-alternatives --config java
    $sudo update-alternatives --config javac

Choose java 8 for both

### Scala build tool (SBT):

    $echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
    $curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
    $sudo apt-get update
    $sudo apt-get install sbt


### Verilator

    $sudo apt-get install verilator


## Run Demo

The demo requires [Digilents Genesys 2 board](https://reference.digilentinc.com/reference/programmable-logic/genesys-2/reference-manual) and the Design Edition of Vivado installed (there is a 30 day trail).



Once above is installed the demo is set up by following steps

- Clone this repository to a your machine

- Run the make command:

    $make kintexDemo

    - This generates Verilog and set up a tcl script for Vivado

- Open Vivado 

    - click: tools -> run tcl script
    - Choose the file "vivadoBuild.tcl" in this repository (This creates the demo Vivado Project in the repository folder and generates a bitstream file)
    - Program the FPGA through the hardware manager and download the generated bit stream
    - reset the circuit by pressing the button BTNU
    - Run the [Python3 script](https://github.com/Thonner/bindsnet/blob/master/examples/mnist/BNSupervised_mnistTransfer.py) from [this forked version of BindsNET](https://github.com/Thonner/bindsnet) to feed the system inputs. The forked BindsNET must be cloned and its dependencies installed with pip beforehand
    