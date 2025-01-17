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
connect_debug_port u_ila_0/clk [get_nets [list chaina_io/artix_link/gth_rxusr_clk]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {chaina_io/artix_link/gth_rxctrl0[0]} {chaina_io/artix_link/gth_rxctrl0[1]} {chaina_io/artix_link/gth_rxctrl0[2]} {chaina_io/artix_link/gth_rxctrl0[3]} {chaina_io/artix_link/gth_rxctrl0[4]} {chaina_io/artix_link/gth_rxctrl0[5]} {chaina_io/artix_link/gth_rxctrl0[6]} {chaina_io/artix_link/gth_rxctrl0[7]} {chaina_io/artix_link/gth_rxctrl0[8]} {chaina_io/artix_link/gth_rxctrl0[9]} {chaina_io/artix_link/gth_rxctrl0[10]} {chaina_io/artix_link/gth_rxctrl0[11]} {chaina_io/artix_link/gth_rxctrl0[12]} {chaina_io/artix_link/gth_rxctrl0[13]} {chaina_io/artix_link/gth_rxctrl0[14]} {chaina_io/artix_link/gth_rxctrl0[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {chaina_io/artix_link/gth_rx_userdata[0]} {chaina_io/artix_link/gth_rx_userdata[1]} {chaina_io/artix_link/gth_rx_userdata[2]} {chaina_io/artix_link/gth_rx_userdata[3]} {chaina_io/artix_link/gth_rx_userdata[4]} {chaina_io/artix_link/gth_rx_userdata[5]} {chaina_io/artix_link/gth_rx_userdata[6]} {chaina_io/artix_link/gth_rx_userdata[7]} {chaina_io/artix_link/gth_rx_userdata[8]} {chaina_io/artix_link/gth_rx_userdata[9]} {chaina_io/artix_link/gth_rx_userdata[10]} {chaina_io/artix_link/gth_rx_userdata[11]} {chaina_io/artix_link/gth_rx_userdata[12]} {chaina_io/artix_link/gth_rx_userdata[13]} {chaina_io/artix_link/gth_rx_userdata[14]} {chaina_io/artix_link/gth_rx_userdata[15]} {chaina_io/artix_link/gth_rx_userdata[16]} {chaina_io/artix_link/gth_rx_userdata[17]} {chaina_io/artix_link/gth_rx_userdata[18]} {chaina_io/artix_link/gth_rx_userdata[19]} {chaina_io/artix_link/gth_rx_userdata[20]} {chaina_io/artix_link/gth_rx_userdata[21]} {chaina_io/artix_link/gth_rx_userdata[22]} {chaina_io/artix_link/gth_rx_userdata[23]} {chaina_io/artix_link/gth_rx_userdata[24]} {chaina_io/artix_link/gth_rx_userdata[25]} {chaina_io/artix_link/gth_rx_userdata[26]} {chaina_io/artix_link/gth_rx_userdata[27]} {chaina_io/artix_link/gth_rx_userdata[28]} {chaina_io/artix_link/gth_rx_userdata[29]} {chaina_io/artix_link/gth_rx_userdata[30]} {chaina_io/artix_link/gth_rx_userdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {chaina_io/from_artix/fifo_rdcnt[0]} {chaina_io/from_artix/fifo_rdcnt[1]} {chaina_io/from_artix/fifo_rdcnt[2]} {chaina_io/from_artix/fifo_rdcnt[3]} {chaina_io/from_artix/fifo_rdcnt[4]} {chaina_io/from_artix/fifo_rdcnt[5]} {chaina_io/from_artix/fifo_rdcnt[6]} {chaina_io/from_artix/fifo_rdcnt[7]} {chaina_io/from_artix/fifo_rdcnt[8]} {chaina_io/from_artix/fifo_rdcnt[9]} {chaina_io/from_artix/fifo_rdcnt[10]} {chaina_io/from_artix/fifo_rdcnt[11]} {chaina_io/from_artix/fifo_rdcnt[12]} {chaina_io/from_artix/fifo_rdcnt[13]} {chaina_io/from_artix/fifo_rdcnt[14]} {chaina_io/from_artix/fifo_rdcnt[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 32 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {chaina_io/from_artix/gth_rx_data[0]} {chaina_io/from_artix/gth_rx_data[1]} {chaina_io/from_artix/gth_rx_data[2]} {chaina_io/from_artix/gth_rx_data[3]} {chaina_io/from_artix/gth_rx_data[4]} {chaina_io/from_artix/gth_rx_data[5]} {chaina_io/from_artix/gth_rx_data[6]} {chaina_io/from_artix/gth_rx_data[7]} {chaina_io/from_artix/gth_rx_data[8]} {chaina_io/from_artix/gth_rx_data[9]} {chaina_io/from_artix/gth_rx_data[10]} {chaina_io/from_artix/gth_rx_data[11]} {chaina_io/from_artix/gth_rx_data[12]} {chaina_io/from_artix/gth_rx_data[13]} {chaina_io/from_artix/gth_rx_data[14]} {chaina_io/from_artix/gth_rx_data[15]} {chaina_io/from_artix/gth_rx_data[16]} {chaina_io/from_artix/gth_rx_data[17]} {chaina_io/from_artix/gth_rx_data[18]} {chaina_io/from_artix/gth_rx_data[19]} {chaina_io/from_artix/gth_rx_data[20]} {chaina_io/from_artix/gth_rx_data[21]} {chaina_io/from_artix/gth_rx_data[22]} {chaina_io/from_artix/gth_rx_data[23]} {chaina_io/from_artix/gth_rx_data[24]} {chaina_io/from_artix/gth_rx_data[25]} {chaina_io/from_artix/gth_rx_data[26]} {chaina_io/from_artix/gth_rx_data[27]} {chaina_io/from_artix/gth_rx_data[28]} {chaina_io/from_artix/gth_rx_data[29]} {chaina_io/from_artix/gth_rx_data[30]} {chaina_io/from_artix/gth_rx_data[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list chaina_io/from_artix/gth_rx_data_enb]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 4096 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list chaina_io/artix_link/gth_txusr_clk]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 2 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {chaina_io/to_artix/state[0]} {chaina_io/to_artix/state[1]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets fp_out_OBUF[2]]
