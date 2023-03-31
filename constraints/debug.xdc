







create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 8192 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 2 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clock_150]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 3 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {SKYTRACKER.enc/state_b[0]} {SKYTRACKER.enc/state_b[1]} {SKYTRACKER.enc/state_b[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 12 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {SKYTRACKER.enc/position_buffer[0]} {SKYTRACKER.enc/position_buffer[1]} {SKYTRACKER.enc/position_buffer[2]} {SKYTRACKER.enc/position_buffer[3]} {SKYTRACKER.enc/position_buffer[4]} {SKYTRACKER.enc/position_buffer[5]} {SKYTRACKER.enc/position_buffer[6]} {SKYTRACKER.enc/position_buffer[7]} {SKYTRACKER.enc/position_buffer[8]} {SKYTRACKER.enc/position_buffer[9]} {SKYTRACKER.enc/position_buffer[10]} {SKYTRACKER.enc/position_buffer[11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {SKYTRACKER.enc/data_rd[0]} {SKYTRACKER.enc/data_rd[1]} {SKYTRACKER.enc/data_rd[2]} {SKYTRACKER.enc/data_rd[3]} {SKYTRACKER.enc/data_rd[4]} {SKYTRACKER.enc/data_rd[5]} {SKYTRACKER.enc/data_rd[6]} {SKYTRACKER.enc/data_rd[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 3 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {SKYTRACKER.enc/i2c/state[0]} {SKYTRACKER.enc/i2c/state[2]} {SKYTRACKER.enc/i2c/state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 9 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {SKYTRACKER.enc/i2c/count[0]} {SKYTRACKER.enc/i2c/count[1]} {SKYTRACKER.enc/i2c/count[2]} {SKYTRACKER.enc/i2c/count[3]} {SKYTRACKER.enc/i2c/count[4]} {SKYTRACKER.enc/i2c/count[5]} {SKYTRACKER.enc/i2c/count[6]} {SKYTRACKER.enc/i2c/count[7]} {SKYTRACKER.enc/i2c/count[8]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list SKYTRACKER.enc/ack_error]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list SKYTRACKER.enc/busy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list SKYTRACKER.enc/busy_delay]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clock_150]
