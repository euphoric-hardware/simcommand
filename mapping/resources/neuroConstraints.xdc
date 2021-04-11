## Clock Signal
set_property -dict {PACKAGE_PIN AD11 IOSTANDARD LVDS} [get_ports sysclk_n]
set_property -dict {PACKAGE_PIN AD12 IOSTANDARD LVDS} [get_ports sysclk_p]
create_clock -period 5.000 -name sysclk_p -waveform {0.000 2.500} [get_ports sysclk_p]

## Reset Button
set_property -dict {PACKAGE_PIN B19 IOSTANDARD LVCMOS12} [get_ports reset]

## UART
set_property -dict {PACKAGE_PIN Y23 IOSTANDARD LVCMOS33} [get_ports uartTx]
set_property -dict {PACKAGE_PIN Y20 IOSTANDARD LVCMOS33} [get_ports uartRx]
