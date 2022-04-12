# NeuromorphicProcessor
- Chiseltest TB: 1655 seconds, 53455000 cycles = 32.3 kHz (with trace dump enabled, with Verilator v4.034)
- Chiseltest TB (no dumping, Verilator v4.034, no threading annotation) = 142s = 376.4 kHz
- Cocotb TB: 1367 seconds, 13.455 M cycles = 9.8 kHz (without trace dump, with Verilator v4.106, ONLY up to the image being sent - test failed with typeError when just starting to wait for response, verified cycle count matches between cocotb and chiseltest TBs)

- cocotb caveats
    - Use timescale 1ps/1ps on top of NP.sv to match chiseltest, use 2ps period clock
    - Remove @(*) after always_latch in ClockBufferBB (event sensitivity lists are automatically inferred)
    - Add iverilog vcd dumping to NP.sv
```
`ifdef COCOTB_SIM
initial begin
  $dumpfile ("NeuromorphicProcessor.vcd");
  $dumpvars (0, NeuromorphicProcessor);
  #1;
end
`endif
```

[![Actions Status](https://github.com/hansemandse/KWSonSNN/actions/workflows/ci.yml/badge.svg)](https://github.com/hansemandse/KWSonSNN/actions)
Neuromorphic processor implementation for Master thesis - WIP!

The accelerator may be built by

    $make all

All possible tests are run by

    $make test

The folder structure may be cleaned by

    $make clean

Accelerator parameters are listed in _src/main/scala/neuroproc/package.scala_ and per default target a Xilinx Kintex-7 FPGA with [BUFGCE](https://www.xilinx.com/support/documentation/user_guides/ug472_7Series_Clocking.pdf) primitives inserted instead of the typical latch-based clock-gating cells used in ASICs.

## Install guide (tested with Ubuntu 20.04)
The accelerator is written in [Chisel3](https://github.com/chipsalliance/chisel3) and tests are run using [ChiselTest](https://github.com/ucb-bar/chisel-testers2) with either the built-in [Treadle](https://github.com/chipsalliance/treadle) backend or the [Verilator](https://github.com/verilator/verilator) backend.

### Java 8
Java 8 is preferred for Chisel3 thus far, although the code runs with Java 11 as well.

    $sudo apt update
    $sudo apt install openjdk-8-jdk openjdk-8-jre

Make java 8 the default java version 

    $sudo update-alternatives --config java
    $sudo update-alternatives --config javac

Choose java 8 for both

### Scala build tool (SBT)

    $echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
    $curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
    $sudo apt-get update
    $sudo apt-get install sbt

### Verilator
Verilator needs to be version >= 4.028.

    $sudo apt-get install verilator

If `apt` cannot provide a new enough version, consider installing directly from GitHub

    $git clone -b v4.028 https://github.com/verilator/verilator.git
    $cd verilator
    $autoconf
    $export VERILATOR_ROOT=`pwd`
    $make

Consider adding `export VERILATOR_ROOT="/path/to/verilator/binary"` to your `.bashrc` file and symlink the binary into `/usr/local/bin` to get access to the `verilator` command directly in bash.

### Python libraries

    $sudo apt-get install python3-pip
    $pip3 install scipy seaborn bindsnet

## Python models
The SNN models are developed in Python using the [BindsNET](https://github.com/BindsNET/bindsnet) library. Pretrained models can be mapped to the accelerator with the mapping functions included in _src/main/scala/neuroproc/package.scala_. Ubuntu 18.04 and newer versions ship with Python3.

The included notebook _netwkdev/KWSonSNN.ipynb_ presents the Google Speech Commands dataset (GSCD) with a number of plots.

The work bases itself on the `DiehlAndCook2015` model included in BindsNET. A similar PyTorch network is included in the repository for comparison. Both training scripts perform checkpointing after each epoch and allow early-stopping by pressing `Ctrl+C`. Trained networks are pickled and stored in _netwkdev/pretrained/_.

### PyTorch model
The model is included in its training script. Instead of modeling excitatory and inhibitory links, the model is a simple FFNN with just one hidden layer; thus, the network has the same number of neurons as the `DiehlAndCook2015` network. Training this model can be done by running the training script

    $python3 ./netwkdev/trainpt.py [--params]

The available parameters are as follows

| Parameter     | Default  | Description                                          |
|---------------|----------|------------------------------------------------------|
| `--gpu`       |  `False` | Enables running on CUDA-based GPUs.                  |
| `--use_mnist` |  `False` | Switches to using MNIST instead of GSCD.             |
| `--seed`      |    `2`   | Seed for the PyTorch random number generation.       |
| `--epochs`    |   `100`  | Number of epochs to train the network for.           |
| `--lr`        | `0.0002` | Learning rate used in the Adam optimizer.            |
| `--n_train`   |   `-1`   | How many training examples to use. `-1` means all.   |
| `--n_valid`   |   `-1`   | How many validation examples to use. `-1` means all. |

This model achieves higher than 95% accuracy on MNIST and roughly 85% accuracy on GSCD.

### BindsNET model
The model is available in _netwkdev/kwsonsnn/model.py_. Training this model can be done by running the training script

    $python3 ./networkdv/train.py [--params]

The available parameters are as follows

| Parameter           | Default | Description                                                                     |
|---------------------|---------|---------------------------------------------------------------------------------|
| `--gpu`             | `False` | Enables running on CUDA-based GPUs.                                             |
| `--use_mnist`       | `False` | Switches to using MNIST instead of GSCD.                                        |
| `--seed`            |   `2`   | Seed for the PyTorch random number generation.                                  |
| `--epochs`          |   `5`   | Number of epochs to train the network for.                                      |
| `--n_clamp`         |   `1`   | Number of neurons to clamp while training.                                      |
| `--n_train`         |   `-1`  | How many training examples to use. `-1` means all.                              |
| `--n_valid`         |   `-1`  | How many validation examples to use. `-1` means all.                            |
| `--exc`             | `22.5`  | Excitatory connection maximum absolute weight (scaled internally).              |
| `--inh`             | `22.5`  | Inhibitory connection maximum absolute weight (scaled internally).              |
| `--time`            | `500`   | Time for a single evaluation run in _ms_.                                       |
| `--dt`              | `1.0`   | Time step length in _ms_. Number of time steps is `time/dt`.                    |
| `--intensity`       | `128.0` | Scaling factor for input images applied before spike encoding.                  |
| `--plot`            | `False` | Enables debug plots during training.                                            |
| `--plot_interval`   | `250`   | Number of examples between updates to debug plots.                              |
| `--update_interval` | `250`   | Number of examples between updates to neuron assignments and statistics prints. |

This model achieves just above 70% accuracy on MNIST and roughly 50% accuracy on GSCD.
