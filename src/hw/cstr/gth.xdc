

set_property PACKAGE_PIN R28 [get_ports gth_evr_refclk_n]
set_property PACKAGE_PIN R27 [get_ports gth_evr_refclk_p]
create_clock -period 3.200 -name clk_gth_evr_refclk_0 [get_ports gth_evr_refclk_p]


set_property PACKAGE_PIN J28 [get_ports gth_fe_refclk_n]
set_property PACKAGE_PIN J27 [get_ports gth_fe_refclk_p]
create_clock -period 6.400 -name clk_gth_fe_refclk_0 [get_ports gth_fe_refclk_p]



## SFP4



