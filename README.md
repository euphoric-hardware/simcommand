# NeuromorphicProcessor
Neuromorphic processor implementation for Master thesis - WIP!

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
