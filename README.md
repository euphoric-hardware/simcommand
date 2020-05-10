# NeuromorphicProcessor
Neuromorphic processor implementation for Master thesis


## Install guide (assuming ubuntu, install equivalent on other OS):
java 8

    $sudo apt update
    $sudo apt install openjdk-8-jdk openjdk-8-jre

scala build tool (SBT):

    $echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
    $curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
    $sudo apt-get update
    $sudo apt-get install sbt

