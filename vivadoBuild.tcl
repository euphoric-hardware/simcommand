set projPath

create_project KintexDemo ${projPath}VivadoProject/KintexDemo -part xc7k325tffg900-2
set_property board_part digilentinc.com:genesys2:part0:1.1 [current_project]
add_files -norecurse ${projPath}build/NeuromorphicProcessor.v
add_files -norecurse ${projPath}VivadoProject/neuroTop.v
add_files -fileset constrs_1 -norecurse ${projPath}VivadoProject/Genesys-2-Master.xdc
add_files -norecurse ${projPath}VivadoProject/clk_wiz_0.v
add_files -norecurse ${projPath}VivadoProject/clk_wiz_0_clk_wiz.v


add_files -norecurse ${projPath}mapping/evaldatac2e4.mem
add_files -norecurse ${projPath}mapping/evaldatac2e6.mem
add_files -norecurse ${projPath}mapping/evaldatac3e1.mem
add_files -norecurse ${projPath}mapping/evaldatac3e3.mem
add_files -norecurse ${projPath}mapping/evaldatac3e4.mem
add_files -norecurse ${projPath}mapping/evaldatac2e2.mem
add_files -norecurse ${projPath}mapping/evaldatac2e0.mem
add_files -norecurse ${projPath}mapping/evaldatac3e6.mem
add_files -norecurse ${projPath}mapping/evaldatac2e5.mem
add_files -norecurse ${projPath}mapping/evaldatac3e2.mem
add_files -norecurse ${projPath}mapping/evaldatac3e7.mem
add_files -norecurse ${projPath}mapping/evaldatac2e7.mem
add_files -norecurse ${projPath}mapping/evaldatac3e0.mem
add_files -norecurse ${projPath}mapping/evaldatac2e3.mem
add_files -norecurse ${projPath}mapping/evaldatac3e5.mem
add_files -norecurse ${projPath}mapping/evaldatac2e1.mem

launch_runs synth_1
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1