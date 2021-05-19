## Generated SDC file "sky-tracker.out.sdc"

## Copyright (C) 2020  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 20.1.1 Build 720 11/11/2020 SJ Lite Edition"

## DATE    "Thu May 13 16:37:22 2021"

##
## DEVICE  "EP4CE22F17C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK_50}]
create_clock -name {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk} -period 20.000 -waveform { 0.000 10.00 } [get_registers {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}]
create_clock -name {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf} -period 6.000 -waveform { 0.000 3.00 } [get_registers {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}]
create_clock -name {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk} -period 20.000 -waveform { 0.000 10.00 } [get_registers {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}]
create_clock -name {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk} -period 20.000 -waveform { 0.000 10.00 } [get_registers {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}]
create_clock -name {debounce:\key_gen:0:debounce_key|result} -period 1.000 -waveform { 0.000 0.500 } [get_registers {debounce:\key_gen:0:debounce_key|result}]
create_clock -name {debounce:\key_gen:1:debounce_key|result} -period 1.000 -waveform { 0.000 0.500 } [get_registers {debounce:\key_gen:1:debounce_key|result}]
create_clock -name {spi_clock} -period 20.000 -waveform { 0.000 10.000 } [get_ports {GPIO_1[0] GPIO_1[1] GPIO_1[2] GPIO_1[3] GPIO_1[4] GPIO_1[5] GPIO_1[6] GPIO_1[7]}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {pll|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 2 -master_clock {CLOCK_50} [get_pins {pll|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {pll|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 3 -master_clock {CLOCK_50} [get_pins {pll|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {pll|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 4 -divide_by 5 -master_clock {CLOCK_50} [get_pins {pll|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {pll|altpll_component|auto_generated|pll1|clk[3]} -source [get_pins {pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 25 -master_clock {CLOCK_50} [get_pins {pll|altpll_component|auto_generated|pll1|clk[3]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:1:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -setup 0.060  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:1:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:1:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -setup 0.060  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:1:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:1:debounce_key|result}] -rise_to [get_clocks {CLOCK_50}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:1:debounce_key|result}] -fall_to [get_clocks {CLOCK_50}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:1:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -setup 0.060  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:1:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:1:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -setup 0.060  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:1:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:1:debounce_key|result}] -rise_to [get_clocks {CLOCK_50}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:1:debounce_key|result}] -fall_to [get_clocks {CLOCK_50}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}] -rise_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}] -fall_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}] -rise_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}] -fall_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {debounce:\key_gen:0:debounce_key|result}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {debounce:\key_gen:0:debounce_key|result}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {debounce:\key_gen:0:debounce_key|result}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {debounce:\key_gen:0:debounce_key|result}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -rise_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {debounce:\key_gen:0:debounce_key|result}] -fall_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}] -rise_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}] -fall_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}] -rise_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}] -fall_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}] -rise_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}] -fall_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}] -rise_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}] -fall_to [get_clocks {CLOCK_50}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -rise_to [get_clocks {debounce:\key_gen:1:debounce_key|result}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -rise_to [get_clocks {debounce:\key_gen:1:debounce_key|result}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -fall_to [get_clocks {debounce:\key_gen:1:debounce_key|result}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -fall_to [get_clocks {debounce:\key_gen:1:debounce_key|result}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -rise_to [get_clocks {debounce:\key_gen:1:debounce_key|result}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -rise_to [get_clocks {debounce:\key_gen:1:debounce_key|result}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -fall_to [get_clocks {debounce:\key_gen:1:debounce_key|result}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -fall_to [get_clocks {debounce:\key_gen:1:debounce_key|result}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {CLOCK_50}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {CLOCK_50}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {CLOCK_50}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {CLOCK_50}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {CLOCK_50}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {CLOCK_50}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {CLOCK_50}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {CLOCK_50}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {debounce:\key_gen:1:debounce_key|result}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {debounce:\key_gen:1:debounce_key|result}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {debounce:\key_gen:0:debounce_key|result}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {debounce:\key_gen:0:debounce_key|result}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {CLOCK_50}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {CLOCK_50}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {debounce:\key_gen:1:debounce_key|result}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {debounce:\key_gen:1:debounce_key|result}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_RA|\stepper_count:counter_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {debounce:\key_gen:0:debounce_key|result}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {debounce:\key_gen:0:debounce_key|result}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_DE|\stepper_count:counter_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|sky_tracker:\SKYTRACKER:U_SKYTRACKER|drv8825:\drv_ips:DRV_FC|\stepper_count:counter_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[3]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {CLOCK_50}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {CLOCK_50}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {spi_clock}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}]  0.010  
set_clock_uncertainty -rise_from [get_clocks {spi_clock}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}]  0.010  
set_clock_uncertainty -rise_from [get_clocks {spi_clock}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.060  
set_clock_uncertainty -rise_from [get_clocks {spi_clock}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {spi_clock}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.060  
set_clock_uncertainty -rise_from [get_clocks {spi_clock}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {spi_clock}] -rise_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}]  0.010  
set_clock_uncertainty -fall_from [get_clocks {spi_clock}] -fall_to [get_clocks {SKY_TOP:SKY_TOP_uint|spislave:\SPI_INTERFACE:u_spislave|spi_clk_buf}]  0.010  
set_clock_uncertainty -fall_from [get_clocks {spi_clock}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.060  
set_clock_uncertainty -fall_from [get_clocks {spi_clock}] -rise_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {spi_clock}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.060  
set_clock_uncertainty -fall_from [get_clocks {spi_clock}] -fall_to [get_clocks {pll|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.090  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

