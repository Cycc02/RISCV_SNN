# PS7 FCLK0 = 80 MHz — driven by PS PLLs, constrained at the PS7 output pin.
create_clock -period 12.500 -name fclk0 [get_pins -hierarchical -filter {NAME =~ */PS7_i/FCLKCLK[0]}]

set_input_delay -clock fclk0 -max 2.000 [get_ports uart_rx_i]
set_false_path -to [get_ports uart_tx_o]
set_false_path -to [get_ports {gpr_data_o[*]}]

## UART — FT4232HL on Florida carrier board (X10 USB port)
set_property PACKAGE_PIN V19 [get_ports uart_tx_o]
set_property IOSTANDARD LVCMOS18 [get_ports uart_tx_o]

set_property PACKAGE_PIN U16 [get_ports uart_rx_i]
set_property IOSTANDARD LVCMOS18 [get_ports uart_rx_i]
set_property PULLTYPE PULLUP [get_ports uart_rx_i]

##LEDs
set_property PACKAGE_PIN T16 [get_ports {gpr_data_o[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {gpr_data_o[0]}]

set_property PACKAGE_PIN AB19 [get_ports {gpr_data_o[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {gpr_data_o[1]}]

set_property PACKAGE_PIN C4 [get_ports {gpr_data_o[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {gpr_data_o[2]}]

set_property PACKAGE_PIN J6 [get_ports {gpr_data_o[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {gpr_data_o[3]}]

set_property PACKAGE_PIN R7 [get_ports {gpr_data_o[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {gpr_data_o[4]}]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 4096 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 15 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {dbg_pc[0]} {dbg_pc[1]} {dbg_pc[2]} {dbg_pc[3]} {dbg_pc[4]} {dbg_pc[5]} {dbg_pc[6]} {dbg_pc[7]} {dbg_pc[8]} {dbg_pc[9]} {dbg_pc[10]} {dbg_pc[11]} {dbg_pc[12]} {dbg_pc[13]} {dbg_pc[14]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 1 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list dbg_rstn]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list dbg_uart_addr]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list dbg_uart_tx_pre]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list dbg_uart_tx_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list trap_trigger]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 32 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {reg_dec_pc[0]} {reg_dec_pc[1]} {reg_dec_pc[2]} {reg_dec_pc[3]} {reg_dec_pc[4]} {reg_dec_pc[5]} {reg_dec_pc[6]} {reg_dec_pc[7]} {reg_dec_pc[8]} {reg_dec_pc[9]} {reg_dec_pc[10]} {reg_dec_pc[11]} {reg_dec_pc[12]} {reg_dec_pc[13]} {reg_dec_pc[14]} {reg_dec_pc[15]} {reg_dec_pc[16]} {reg_dec_pc[17]} {reg_dec_pc[18]} {reg_dec_pc[19]} {reg_dec_pc[20]} {reg_dec_pc[21]} {reg_dec_pc[22]} {reg_dec_pc[23]} {reg_dec_pc[24]} {reg_dec_pc[25]} {reg_dec_pc[26]} {reg_dec_pc[27]} {reg_dec_pc[28]} {reg_dec_pc[29]} {reg_dec_pc[30]} {reg_dec_pc[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 8 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {dbg_uart_char[0]} {dbg_uart_char[1]} {dbg_uart_char[2]} {dbg_uart_char[3]} {dbg_uart_char[4]} {dbg_uart_char[5]} {dbg_uart_char[6]} {dbg_uart_char[7]}]]




set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
