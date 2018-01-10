# file Bss3.xdc
# Digilent Basys3 pin mapping and constraints
# author Alexander Wirthmueller
# date created: 22 Sep 2017
# modified: 22 Sep 2017

# bank14 3.3V
set_property PACKAGE_PIN U18 [get_ports btnC]
set_property PACKAGE_PIN W19 [get_ports btnL]
set_property PACKAGE_PIN T17 [get_ports btnR]
set_property PACKAGE_PIN K17 [get_ports {JC[0]}]
set_property PACKAGE_PIN M18 [get_ports {JC[1]}]
set_property PACKAGE_PIN N17 [get_ports {JC[2]}]
set_property PACKAGE_PIN P18 [get_ports {JC[3]}]
set_property PACKAGE_PIN L17 [get_ports {JC[4]}]
set_property PACKAGE_PIN M19 [get_ports {JC[5]}]
set_property PACKAGE_PIN P17 [get_ports {JC[6]}]
set_property PACKAGE_PIN R18 [get_ports {JC[7]}]
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]
set_property PACKAGE_PIN V13 [get_ports {led[8]}]
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
set_property PACKAGE_PIN W16 [get_ports {sw[2]}]
set_property PACKAGE_PIN W17 [get_ports {sw[3]}]
set_property PACKAGE_PIN W15 [get_ports {sw[4]}]
set_property PACKAGE_PIN V15 [get_ports {sw[5]}]
set_property PACKAGE_PIN W14 [get_ports {sw[6]}]
set_property PACKAGE_PIN W13 [get_ports {sw[7]}]

# bank16 3.3V
set_property PACKAGE_PIN A14 [get_ports {JB[0]}]
set_property PACKAGE_PIN A16 [get_ports {JB[1]}]
set_property PACKAGE_PIN B15 [get_ports {JB[2]}]
set_property PACKAGE_PIN B16 [get_ports {JB[3]}]
set_property PACKAGE_PIN A15 [get_ports {JB[4]}]
set_property PACKAGE_PIN A17 [get_ports {JB[5]}]
set_property PACKAGE_PIN C15 [get_ports {JB[6]}]
set_property PACKAGE_PIN C16 [get_ports {JB[7]}]
set_property PACKAGE_PIN B18 [get_ports RsRx]
set_property PACKAGE_PIN A18 [get_ports RsTx]

# bank34 3.3V
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]
set_property PACKAGE_PIN V7 [get_ports dp]
set_property PACKAGE_PIN W5 [get_ports extclk]
set_property PACKAGE_PIN W3 [get_ports {led[10]}]
set_property PACKAGE_PIN U3 [get_ports {led[11]}]
set_property PACKAGE_PIN V3 [get_ports {led[9]}]
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
set_property PACKAGE_PIN T2 [get_ports {sw[10]}]
set_property PACKAGE_PIN R3 [get_ports {sw[11]}]
set_property PACKAGE_PIN W2 [get_ports {sw[12]}]
set_property PACKAGE_PIN U1 [get_ports {sw[13]}]
set_property PACKAGE_PIN T1 [get_ports {sw[14]}]
set_property PACKAGE_PIN R2 [get_ports {sw[15]}]
set_property PACKAGE_PIN V2 [get_ports {sw[8]}]
set_property PACKAGE_PIN T3 [get_ports {sw[9]}]

# bank35 3.3V
set_property PACKAGE_PIN J1 [get_ports {JA[0]}]
set_property PACKAGE_PIN L2 [get_ports {JA[1]}]
set_property PACKAGE_PIN J2 [get_ports {JA[2]}]
set_property PACKAGE_PIN G2 [get_ports {JA[3]}]
set_property PACKAGE_PIN H1 [get_ports {JA[4]}]
set_property PACKAGE_PIN K2 [get_ports {JA[5]}]
set_property PACKAGE_PIN H2 [get_ports {JA[6]}]
set_property PACKAGE_PIN G3 [get_ports {JA[7]}]
set_property PACKAGE_PIN J3 [get_ports {JXADC[0]}]
set_property PACKAGE_PIN L3 [get_ports {JXADC[1]}]
set_property PACKAGE_PIN M2 [get_ports {JXADC[2]}]
set_property PACKAGE_PIN N2 [get_ports {JXADC[3]}]
set_property PACKAGE_PIN K3 [get_ports {JXADC[4]}]
set_property PACKAGE_PIN M3 [get_ports {JXADC[5]}]
set_property PACKAGE_PIN M1 [get_ports {JXADC[6]}]
set_property PACKAGE_PIN N1 [get_ports {JXADC[7]}]
set_property PACKAGE_PIN P3 [get_ports {led[12]}]
set_property PACKAGE_PIN N3 [get_ports {led[13]}]
set_property PACKAGE_PIN P1 [get_ports {led[14]}]
set_property PACKAGE_PIN L1 [get_ports {led[15]}]

# banks
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 14]];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 16]];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];

# IP clks --- BEGIN
# clocks
create_clock -period 10 -waveform {0 5} -add [get_ports extclk]
#create_generated_clock -name clkCmdbus -source [get_ports/get_pins xxxxx] -edges {a b c} [get_pins root/myLwiremu_wrp/mySramemu_wrp/myTop/myBufgClkCmdbus/O];
#create_generated_clock -name mclk -source [get_ports/get_pins xxxxx] -edges {a b c} [get_pins root/myLwiremu_wrp/mySramemu_wrp/myTop/myBufgMclk/O];
#create_generated_clock -name extclk -source [get_ports/get_pins xxxxx] -edges {a b c} [get_pins root/myLwiremu_wrp/mySramemu_wrp/myTop/myBufgExtclk/O];
# IP clks --- END

