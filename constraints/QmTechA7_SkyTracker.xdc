## This file is a general .xdc for the CmodA7 rev. B
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Clock signal 12 MHz
set_property -dict {PACKAGE_PIN N11 IOSTANDARD LVCMOS33} [get_ports FPGA_CLK0_50]
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} -add [get_ports FPGA_CLK0_50]


## LEDs
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS33} [get_ports {LED[0]}]


# Buttons
set_property -dict {PACKAGE_PIN K5 IOSTANDARD LVCMOS33} [get_ports {KEY[0]}]


## U7 Header
set_property -dict {PACKAGE_PIN M12 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[0]}]
set_property -dict {PACKAGE_PIN N13 IOSTANDARD LVCMOS33} [get_ports ra_enable_n]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[2]}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {ra_mode[0]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports fc_fault_n]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports {ra_mode[1]}]
set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[6]}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {ra_mode[2]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[8]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports ra_rst_n]
#set_property -dict {PACKAGE_PIN P13 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[10]}]
#set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[11]}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports fc_direction]
set_property -dict {PACKAGE_PIN R13 IOSTANDARD LVCMOS33} [get_ports ra_sleep_n]
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVCMOS33} [get_ports fc_step]
set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports ra_step]
set_property -dict {PACKAGE_PIN L13 IOSTANDARD LVCMOS33} [get_ports fc_sleep_n]
set_property -dict {PACKAGE_PIN N12 IOSTANDARD LVCMOS33} [get_ports ra_direction]
set_property -dict {PACKAGE_PIN K12 IOSTANDARD LVCMOS33} [get_ports fc_rst_n]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports ra_fault_n]
set_property -dict {PACKAGE_PIN P10 IOSTANDARD LVCMOS33} [get_ports {fc_mode[2]}]
set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVCMOS33} [get_ports de_fault_n]
set_property -dict {PACKAGE_PIN N9 IOSTANDARD LVCMOS33} [get_ports {fc_mode[1]}]
set_property -dict {PACKAGE_PIN P9 IOSTANDARD LVCMOS33} [get_ports de_enable_n]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {fc_mode[0]}]
set_property -dict {PACKAGE_PIN R11 IOSTANDARD LVCMOS33} [get_ports {de_mode[0]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports fc_enable_n]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports {de_mode[1]}]
#set_property -dict {PACKAGE_PIN T8  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[28]}]
#set_property -dict {PACKAGE_PIN R8  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[29]}]
set_property -dict {PACKAGE_PIN T7  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[30]}]
set_property -dict {PACKAGE_PIN R7 IOSTANDARD LVCMOS33} [get_ports {de_mode[2]}]
set_property -dict {PACKAGE_PIN T5  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[32]}]
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports de_rst_n]
set_property -dict {PACKAGE_PIN P6  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[34]}]
set_property -dict {PACKAGE_PIN R5 IOSTANDARD LVCMOS33} [get_ports de_sleep_n]
set_property -dict {PACKAGE_PIN N6  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[36]}]
set_property -dict {PACKAGE_PIN M6 IOSTANDARD LVCMOS33} [get_ports de_step]
set_property -dict {PACKAGE_PIN L5  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[38]}]
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports de_direction]

set_property -dict {PACKAGE_PIN T4  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[40]}]
set_property -dict {PACKAGE_PIN T3  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[41]}]
set_property -dict {PACKAGE_PIN R3  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[42]}]
set_property -dict {PACKAGE_PIN T2  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[43]}]
set_property -dict {PACKAGE_PIN R2  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[44]}]
set_property -dict {PACKAGE_PIN R1  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[45]}]
set_property -dict {PACKAGE_PIN M5  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[46]}]
set_property -dict {PACKAGE_PIN N4  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[47]}]
set_property -dict {PACKAGE_PIN P4  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[48]}]
set_property -dict {PACKAGE_PIN P3  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[49]}]
set_property -dict {PACKAGE_PIN N1  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[50]}]
set_property -dict {PACKAGE_PIN P1  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[51]}]
set_property -dict {PACKAGE_PIN M2  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[52]}]
set_property -dict {PACKAGE_PIN M1  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[53]}]


## U8 Header

set_property -dict {PACKAGE_PIN B7 IOSTANDARD LVCMOS33} [get_ports pi_pwm_led_out]
set_property -dict {PACKAGE_PIN A7 IOSTANDARD LVCMOS33} [get_ports led_polar]
set_property -dict {PACKAGE_PIN B6 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[2]}]
set_property -dict {PACKAGE_PIN B5 IOSTANDARD LVCMOS33} [get_ports {camera_triggers[1]}]
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[4]}]
set_property -dict {PACKAGE_PIN K5 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[5]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports pi_camera_trigger_out ]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports pi_camera_trigger_in]
set_property -dict {PACKAGE_PIN G5 IOSTANDARD LVCMOS33} [get_ports {camera_triggers[0]}]
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports pi_pwm_led_in]

set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[10]}]
set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[11]}]
set_property -dict {PACKAGE_PIN D6 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[12]}]
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[13]}]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[14]}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[15]}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[16]}]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[17]}]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[18]}]
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[19]}]
set_property -dict {PACKAGE_PIN C3 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[20]}]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[21]}]
set_property -dict {PACKAGE_PIN B2  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[22]}]
set_property -dict {PACKAGE_PIN A2  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[23]}]
set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[24]}]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[25]}]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[26]}]
set_property -dict {PACKAGE_PIN D1  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[27]}]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[28]}]
set_property -dict {PACKAGE_PIN D3  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[29]}]

set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS33} [get_ports PI_MOSI]
set_property -dict {PACKAGE_PIN E5  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[31]}]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports PI_MISO]
set_property -dict {PACKAGE_PIN E1  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[33]}]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports PI_SCLK]
set_property -dict {PACKAGE_PIN F3  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[35]}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {PI_SS_N[1]}]
set_property -dict {PACKAGE_PIN G1  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[37]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {PI_SS_N[0]}]
set_property -dict {PACKAGE_PIN H1  IOSTANDARD LVCMOS33} [get_ports {U7_GPIO[39]}]

set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports {S_LED[0]}]
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {S_LED[1]}]
set_property -dict {PACKAGE_PIN L3 IOSTANDARD LVCMOS33} [get_ports {S_LED[2]}]
set_property -dict {PACKAGE_PIN L2 IOSTANDARD LVCMOS33} [get_ports {S_LED[3]}]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {S_LED[4]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {S_LED[5]}]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {S_LED[6]}]
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33} [get_ports {S_LED[7]}]
set_property -dict {PACKAGE_PIN K3 IOSTANDARD LVCMOS33} [get_ports {CLOCKS[0]}]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {CLOCKS[1]}]
set_property -dict {PACKAGE_PIN L4 IOSTANDARD LVCMOS33} [get_ports {CLOCKS[2]}]
set_property -dict {PACKAGE_PIN M4 IOSTANDARD LVCMOS33} [get_ports {CLOCKS[3]}]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports {CLOCKS[4]}]
set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports {CLOCKS[5]}]



set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets PI_SCLK]
create_clock -period 40.000 -name spi_clk_pin -waveform {0.000 20.000} -add [get_ports PI_SCLK]


set_property BITSTREAM.GENERAL.COMPRESS TRUE [get_designs synth_1]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [get_designs synth_1]
set_property CONFIG_MODE SPIx4 [current_design]
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]


set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {KEY_IBUF[0]}]

