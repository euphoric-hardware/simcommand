This is a benchmark circuit of an SNN accelerator written in Chisel.
The only top-level IOs are clock, reset, and a 2-wire UART.

Build instructions (from https://github.com/ekiwi/simulator-independent-coverage/tree/main/benchmarks/NeuromorphicProcessor):

```shell
git clone https://github.com/hansemandse/KWSonSNN
git checkout f086afeee49a6155d5de13ebaba3ae432c683b7a
cd KWSonSNN
make proc
sbt
sbt:kwsonsnn> testOnly neuroproc.systemtests.NeuromorphicProcessorTester
```

Ctrl+C (the test takes about 30 minutes)

Copy the Verilog sources from `test_run_dir/Neuromorphic_Processor_should_process_an_image/`.

The Verilog also has inline `$readmemb` calls so you will need to copy `KWSonSNN/mapping/meminit` too.

And finally you have to copy over the reference images `KWSonSNN/src/test/scala/neuroproc/systemtests/{image.txt, results_round.txt, results_toInt.txt` to `test/resources/NeuromorphicProcessor/.`.