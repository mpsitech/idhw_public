# file Zedb.xdc
# ZedBoard pin mapping and constraints
# author Alexander Wirthmueller
# date created: 22 Sep 2017
# modified: 22 Sep 2017

# bank13 3.3V
set_property PACKAGE_PIN Y9 [get_ports extclk]
set_property PACKAGE_PIN Y11 [get_ports {JA[0]}]
set_property PACKAGE_PIN AA11 [get_ports {JA[1]}]
set_property PACKAGE_PIN Y10 [get_ports {JA[2]}]
set_property PACKAGE_PIN AA9 [get_ports {JA[3]}]
set_property PACKAGE_PIN AB11 [get_ports {JA[4]}]
set_property PACKAGE_PIN AB10 [get_ports {JA[5]}]
set_property PACKAGE_PIN AB9 [get_ports {JA[6]}]
set_property PACKAGE_PIN AA8 [get_ports {JA[7]}]
set_property PACKAGE_PIN W12 [get_ports {JB[0]}]
set_property PACKAGE_PIN W11 [get_ports {JB[1]}]
set_property PACKAGE_PIN V10 [get_ports {JB[2]}]
set_property PACKAGE_PIN W8 [get_ports {JB[3]}]
set_property PACKAGE_PIN V12 [get_ports {JB[4]}]
set_property PACKAGE_PIN W10 [get_ports {JB[5]}]
set_property PACKAGE_PIN V9 [get_ports {JB[6]}]
set_property PACKAGE_PIN V8 [get_ports {JB[7]}]
set_property PACKAGE_PIN AB6 [get_ports {JC[0]}]
set_property PACKAGE_PIN AB7 [get_ports {JC[1]}]
set_property PACKAGE_PIN AA4 [get_ports {JC[2]}]
set_property PACKAGE_PIN Y4 [get_ports {JC[3]}]
set_property PACKAGE_PIN T6 [get_ports {JC[4]}]
set_property PACKAGE_PIN R6 [get_ports {JC[5]}]
set_property PACKAGE_PIN U4 [get_ports {JC[6]}]
set_property PACKAGE_PIN T4 [get_ports {JC[7]}]
set_property PACKAGE_PIN W7 [get_ports {JD[0]}]
set_property PACKAGE_PIN V7 [get_ports {JD[1]}]
set_property PACKAGE_PIN V4 [get_ports {JD[2]}]
set_property PACKAGE_PIN V5 [get_ports {JD[3]}]
set_property PACKAGE_PIN W5 [get_ports {JD[4]}]
set_property PACKAGE_PIN W6 [get_ports {JD[5]}]
set_property PACKAGE_PIN U5 [get_ports {JD[6]}]
set_property PACKAGE_PIN U6 [get_ports {JD[7]}]
set_property PACKAGE_PIN U10 [get_ports oledDc]
set_property PACKAGE_PIN U9 [get_ports oledRes]
set_property PACKAGE_PIN AB12 [get_ports oledSclk]
set_property PACKAGE_PIN AA12 [get_ports oledSdin]
set_property PACKAGE_PIN U11 [get_ports oledVbat]
set_property PACKAGE_PIN U12 [get_ports oledVdd]

# bank34 1.8V
set_property PACKAGE_PIN P16 [get_ports btnC]
set_property PACKAGE_PIN N15 [get_ports btnL]
set_property PACKAGE_PIN R18 [get_ports btnR]

# bank35 1.8V
set_property PACKAGE_PIN F22 [get_ports {sw[0]}]
set_property PACKAGE_PIN G22 [get_ports {sw[1]}]
set_property PACKAGE_PIN H22 [get_ports {sw[2]}]
set_property PACKAGE_PIN F21 [get_ports {sw[3]}]
set_property PACKAGE_PIN H19 [get_ports {sw[4]}]
set_property PACKAGE_PIN H18 [get_ports {sw[5]}]
set_property PACKAGE_PIN H17 [get_ports {sw[6]}]
set_property PACKAGE_PIN M15 [get_ports {sw[7]}]

# banks
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];

# IP clks --- BEGIN
# clocks
create_clock -period 10 -waveform {0 5} -add [get_ports extclk]
#create_generated_clock -name clkCmdbus -source [get_ports/get_pins xxxxx] -edges {a b c} [get_pins root/myZedb_ip/myZedb_ip_AXI/myLwiremu_wrp/mySramemu_wrp/myTop/myBufgClkCmdbus/O];
#create_generated_clock -name mclk -source [get_ports/get_pins xxxxx] -edges {a b c} [get_pins root/myZedb_ip/myZedb_ip_AXI/myLwiremu_wrp/mySramemu_wrp/myTop/myBufgMclk/O];
#create_generated_clock -name extclk -source [get_ports/get_pins xxxxx] -edges {a b c} [get_pins root/myZedb_ip/myZedb_ip_AXI/myLwiremu_wrp/mySramemu_wrp/myTop/myBufgExtclk/O];
# IP clks --- END

