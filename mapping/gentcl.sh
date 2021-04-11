#!/bin/sh
# Generates a Tcl script suitable for initializing a new Vivado project
FILE=build.tcl
JOBS=$(nproc)

echo "set path\n" > $FILE
echo "# Create Vivado project
create_project KWSonSNN \${path}build/KWSonSNN -part xc7k325tffg900-2
set_property board_part digilentinc.com:genesys2:part0:1.1 [current_project]\n" >> $FILE
echo "# Load source files" >> $FILE
for f in "build"/*.v; do
    echo "add_files -norecurse \${path}$f" >> $FILE
done
echo "" >> $FILE
for f in "mapping/resources"/*.v; do
    echo "add_files -norecurse \${path}$f" >> $FILE
done
echo "" >> $FILE
for f in "mapping/meminit"/*.mem; do
    echo "add_files -norecurse \${path}$f" >> $FILE
done
echo "\nadd_files -norecurse -fileset constrs_1 \${path}resources/neuroConstraints.xdc\n" >> $FILE
echo "add_files -norecurse -fileset sim_1 \${path}resources/neuroproc_tb.vhd\n" >> $FILE
echo "add_files -norecurse -fileset sim_1 \${path}src/test/scala/systemtests/image.txt" >> $FILE
echo "add_files -norecurse -fileset sim_1 \${path}src/test/scala/systemtests/results.txt\n" >> $FILE
echo "# Launch synthesis and implementation
launch_runs -jobs $JOBS synth_1
wait_on_run synth_1

launch_runs -jobs $JOBS -to_step write_bitstream impl_1
wait_on_run impl_1" >> $FILE
