create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 4096 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clock_50]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {SPI_INTERFACE.u_spislave/wb_data_i0[0]} {SPI_INTERFACE.u_spislave/wb_data_i0[1]} {SPI_INTERFACE.u_spislave/wb_data_i0[2]} {SPI_INTERFACE.u_spislave/wb_data_i0[3]} {SPI_INTERFACE.u_spislave/wb_data_i0[4]} {SPI_INTERFACE.u_spislave/wb_data_i0[5]} {SPI_INTERFACE.u_spislave/wb_data_i0[6]} {SPI_INTERFACE.u_spislave/wb_data_i0[7]} {SPI_INTERFACE.u_spislave/wb_data_i0[8]} {SPI_INTERFACE.u_spislave/wb_data_i0[9]} {SPI_INTERFACE.u_spislave/wb_data_i0[10]} {SPI_INTERFACE.u_spislave/wb_data_i0[11]} {SPI_INTERFACE.u_spislave/wb_data_i0[12]} {SPI_INTERFACE.u_spislave/wb_data_i0[13]} {SPI_INTERFACE.u_spislave/wb_data_i0[14]} {SPI_INTERFACE.u_spislave/wb_data_i0[15]} {SPI_INTERFACE.u_spislave/wb_data_i0[16]} {SPI_INTERFACE.u_spislave/wb_data_i0[17]} {SPI_INTERFACE.u_spislave/wb_data_i0[18]} {SPI_INTERFACE.u_spislave/wb_data_i0[19]} {SPI_INTERFACE.u_spislave/wb_data_i0[20]} {SPI_INTERFACE.u_spislave/wb_data_i0[21]} {SPI_INTERFACE.u_spislave/wb_data_i0[22]} {SPI_INTERFACE.u_spislave/wb_data_i0[23]} {SPI_INTERFACE.u_spislave/wb_data_i0[24]} {SPI_INTERFACE.u_spislave/wb_data_i0[25]} {SPI_INTERFACE.u_spislave/wb_data_i0[26]} {SPI_INTERFACE.u_spislave/wb_data_i0[27]} {SPI_INTERFACE.u_spislave/wb_data_i0[28]} {SPI_INTERFACE.u_spislave/wb_data_i0[29]} {SPI_INTERFACE.u_spislave/wb_data_i0[30]} {SPI_INTERFACE.u_spislave/wb_data_i0[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {SPI_INTERFACE.u_spislave/wb_address[0]} {SPI_INTERFACE.u_spislave/wb_address[1]} {SPI_INTERFACE.u_spislave/wb_address[2]} {SPI_INTERFACE.u_spislave/wb_address[3]} {SPI_INTERFACE.u_spislave/wb_address[4]} {SPI_INTERFACE.u_spislave/wb_address[5]} {SPI_INTERFACE.u_spislave/wb_address[6]} {SPI_INTERFACE.u_spislave/wb_address[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 5 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {SKYTRACKER.U_SKYTRACKER/ctrl_address[0]} {SKYTRACKER.U_SKYTRACKER/ctrl_address[1]} {SKYTRACKER.U_SKYTRACKER/ctrl_address[2]} {SKYTRACKER.U_SKYTRACKER/ctrl_address[3]} {SKYTRACKER.U_SKYTRACKER/ctrl_address[4]} ]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 2 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {SPI_INTERFACE.u_spislave/spi_ce[0]} {SPI_INTERFACE.u_spislave/spi_ce[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 8 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {SPI_INTERFACE.u_spislave/spi_addr_shift_reg[0]} {SPI_INTERFACE.u_spislave/spi_addr_shift_reg[1]} {SPI_INTERFACE.u_spislave/spi_addr_shift_reg[2]} {SPI_INTERFACE.u_spislave/spi_addr_shift_reg[3]} {SPI_INTERFACE.u_spislave/spi_addr_shift_reg[4]} {SPI_INTERFACE.u_spislave/spi_addr_shift_reg[5]} {SPI_INTERFACE.u_spislave/spi_addr_shift_reg[6]} {SPI_INTERFACE.u_spislave/spi_addr_shift_reg[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[0]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[1]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[2]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[3]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[4]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[5]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[6]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[7]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[8]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[9]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[10]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[11]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[12]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[13]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[14]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[15]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[16]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[17]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[18]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[19]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[20]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[21]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[22]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[23]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[24]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[25]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[26]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[27]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[28]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[29]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[30]} {SKYTRACKER.U_SKYTRACKER/de_trackctrl_sync[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 32 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[0]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[1]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[2]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[3]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[4]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[5]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[6]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[7]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[8]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[9]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[10]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[11]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[12]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[13]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[14]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[15]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[16]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[17]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[18]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[19]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[20]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[21]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[22]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[23]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[24]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[25]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[26]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[27]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[28]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[29]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[30]} {SKYTRACKER.U_SKYTRACKER/de_counter_load_sync[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 32 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {SPI_INTERFACE.u_spislave/wb_data_i1[0]} {SPI_INTERFACE.u_spislave/wb_data_i1[1]} {SPI_INTERFACE.u_spislave/wb_data_i1[2]} {SPI_INTERFACE.u_spislave/wb_data_i1[3]} {SPI_INTERFACE.u_spislave/wb_data_i1[4]} {SPI_INTERFACE.u_spislave/wb_data_i1[5]} {SPI_INTERFACE.u_spislave/wb_data_i1[6]} {SPI_INTERFACE.u_spislave/wb_data_i1[7]} {SPI_INTERFACE.u_spislave/wb_data_i1[8]} {SPI_INTERFACE.u_spislave/wb_data_i1[9]} {SPI_INTERFACE.u_spislave/wb_data_i1[10]} {SPI_INTERFACE.u_spislave/wb_data_i1[11]} {SPI_INTERFACE.u_spislave/wb_data_i1[12]} {SPI_INTERFACE.u_spislave/wb_data_i1[13]} {SPI_INTERFACE.u_spislave/wb_data_i1[14]} {SPI_INTERFACE.u_spislave/wb_data_i1[15]} {SPI_INTERFACE.u_spislave/wb_data_i1[16]} {SPI_INTERFACE.u_spislave/wb_data_i1[17]} {SPI_INTERFACE.u_spislave/wb_data_i1[18]} {SPI_INTERFACE.u_spislave/wb_data_i1[19]} {SPI_INTERFACE.u_spislave/wb_data_i1[20]} {SPI_INTERFACE.u_spislave/wb_data_i1[21]} {SPI_INTERFACE.u_spislave/wb_data_i1[22]} {SPI_INTERFACE.u_spislave/wb_data_i1[23]} {SPI_INTERFACE.u_spislave/wb_data_i1[24]} {SPI_INTERFACE.u_spislave/wb_data_i1[25]} {SPI_INTERFACE.u_spislave/wb_data_i1[26]} {SPI_INTERFACE.u_spislave/wb_data_i1[27]} {SPI_INTERFACE.u_spislave/wb_data_i1[28]} {SPI_INTERFACE.u_spislave/wb_data_i1[29]} {SPI_INTERFACE.u_spislave/wb_data_i1[30]} {SPI_INTERFACE.u_spislave/wb_data_i1[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 32 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[0]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[1]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[2]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[3]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[4]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[5]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[6]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[7]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[8]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[9]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[10]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[11]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[12]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[13]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[14]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[15]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[16]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[17]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[18]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[19]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[20]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[21]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[22]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[23]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[24]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[25]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[26]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[27]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[28]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[29]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[30]} {SKYTRACKER.U_SKYTRACKER/de_cmdduration_sync[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 32 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[0]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[1]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[2]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[3]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[4]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[5]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[6]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[7]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[8]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[9]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[10]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[11]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[12]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[13]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[14]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[15]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[16]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[17]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[18]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[19]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[20]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[21]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[22]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[23]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[24]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[25]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[26]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[27]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[28]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[29]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[30]} {SKYTRACKER.U_SKYTRACKER/de_counter_max_sync[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 32 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {SPI_INTERFACE.u_spislave/wb_data_o[0]} {SPI_INTERFACE.u_spislave/wb_data_o[1]} {SPI_INTERFACE.u_spislave/wb_data_o[2]} {SPI_INTERFACE.u_spislave/wb_data_o[3]} {SPI_INTERFACE.u_spislave/wb_data_o[4]} {SPI_INTERFACE.u_spislave/wb_data_o[5]} {SPI_INTERFACE.u_spislave/wb_data_o[6]} {SPI_INTERFACE.u_spislave/wb_data_o[7]} {SPI_INTERFACE.u_spislave/wb_data_o[8]} {SPI_INTERFACE.u_spislave/wb_data_o[9]} {SPI_INTERFACE.u_spislave/wb_data_o[10]} {SPI_INTERFACE.u_spislave/wb_data_o[11]} {SPI_INTERFACE.u_spislave/wb_data_o[12]} {SPI_INTERFACE.u_spislave/wb_data_o[13]} {SPI_INTERFACE.u_spislave/wb_data_o[14]} {SPI_INTERFACE.u_spislave/wb_data_o[15]} {SPI_INTERFACE.u_spislave/wb_data_o[16]} {SPI_INTERFACE.u_spislave/wb_data_o[17]} {SPI_INTERFACE.u_spislave/wb_data_o[18]} {SPI_INTERFACE.u_spislave/wb_data_o[19]} {SPI_INTERFACE.u_spislave/wb_data_o[20]} {SPI_INTERFACE.u_spislave/wb_data_o[21]} {SPI_INTERFACE.u_spislave/wb_data_o[22]} {SPI_INTERFACE.u_spislave/wb_data_o[23]} {SPI_INTERFACE.u_spislave/wb_data_o[24]} {SPI_INTERFACE.u_spislave/wb_data_o[25]} {SPI_INTERFACE.u_spislave/wb_data_o[26]} {SPI_INTERFACE.u_spislave/wb_data_o[27]} {SPI_INTERFACE.u_spislave/wb_data_o[28]} {SPI_INTERFACE.u_spislave/wb_data_o[29]} {SPI_INTERFACE.u_spislave/wb_data_o[30]} {SPI_INTERFACE.u_spislave/wb_data_o[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 2 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {SPI_INTERFACE.u_spislave/wb_strobe[0]} {SPI_INTERFACE.u_spislave/wb_strobe[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 40 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {SPI_INTERFACE.u_spislave/spi_shift_in_reg[0]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[1]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[2]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[3]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[4]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[5]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[6]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[7]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[8]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[9]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[10]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[11]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[12]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[13]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[14]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[15]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[16]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[17]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[18]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[19]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[20]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[21]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[22]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[23]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[24]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[25]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[26]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[27]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[28]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[29]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[30]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[31]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[32]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[33]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[34]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[35]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[36]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[37]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[38]} {SPI_INTERFACE.u_spislave/spi_shift_in_reg[39]} ]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 32 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[0]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[1]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[2]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[3]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[4]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[5]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[6]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[7]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[8]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[9]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[10]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[11]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[12]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[13]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[14]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[15]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[16]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[17]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[18]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[19]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[20]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[21]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[22]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[23]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[24]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[25]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[26]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[27]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[28]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[29]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[30]} {SKYTRACKER.U_SKYTRACKER/ctrl_read_data[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 6 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {SPI_INTERFACE.u_spislave/spi_shift_count[0]} {SPI_INTERFACE.u_spislave/spi_shift_count[1]} {SPI_INTERFACE.u_spislave/spi_shift_count[2]} {SPI_INTERFACE.u_spislave/spi_shift_count[3]} {SPI_INTERFACE.u_spislave/spi_shift_count[4]} {SPI_INTERFACE.u_spislave/spi_shift_count[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list SKYTRACKER.U_SKYTRACKER/ctrl_acknowledge]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list SPI_INTERFACE.u_spislave/spi_miso]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list SPI_INTERFACE.u_spislave/wb_ack]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list SPI_INTERFACE.u_spislave/spi_mosi]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list SPI_INTERFACE.u_spislave/wb_write]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list SKYTRACKER.U_SKYTRACKER/ctrl_bus_enable]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list SPI_INTERFACE.u_spislave/wb_cycle]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list SPI_INTERFACE.u_spislave/spi_clk]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 32 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {SPI_INTERFACE.u_spislave/spi_shift_out_reg[0]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[1]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[2]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[3]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[4]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[5]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[6]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[7]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[8]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[9]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[10]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[11]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[12]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[13]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[14]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[15]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[16]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[17]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[18]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[19]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[20]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[21]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[22]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[23]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[24]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[25]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[26]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[27]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[28]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[29]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[30]} {SPI_INTERFACE.u_spislave/spi_shift_out_reg[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list SPI_INTERFACE.u_spislave/spi_out_en]]



set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clock_50]
