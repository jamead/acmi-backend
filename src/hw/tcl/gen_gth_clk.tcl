##################################################################
# CHECK VIVADO VERSION
##################################################################

set scripts_vivado_version 2022.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
  catch {common::send_msg_id "IPS_TCL-100" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_ip_tcl to create an updated script."}
  return 1
}

##################################################################
# START
##################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source gen_gth_clk.tcl
# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
  create_project vivado vivado -part xck26-sfvc784-2LV-c
  set_property BOARD_PART xilinx.com:k26c:part0:1.4 [current_project]
  set_property BOARD_CONNECTIONS som240_1_connector xilinx.com:kr260_carrier:som240_1_connector:1.0 som240_2_connector xilinx.com:kr260_carrier:som240_2_connector:1.0 [current_project]
  set_property target_language VHDL [current_project]
  set_property simulator_language Mixed [current_project]
}

##################################################################
# CHECK IPs
##################################################################

set bCheckIPs 1
set bCheckIPsPassed 1
if { $bCheckIPs == 1 } {
  set list_check_ips { xilinx.com:ip:clk_wiz:6.0 }
  set list_ips_missing ""
  common::send_msg_id "IPS_TCL-1001" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

  foreach ip_vlnv $list_check_ips {
  set ip_obj [get_ipdefs -all $ip_vlnv]
  if { $ip_obj eq "" } {
    lappend list_ips_missing $ip_vlnv
    }
  }

  if { $list_ips_missing ne "" } {
    catch {common::send_msg_id "IPS_TCL-105" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
    set bCheckIPsPassed 0
  }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "IPS_TCL-102" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 1
}

##################################################################
# CREATE IP gen_gth_clk
##################################################################

set_property BOARD_PART xilinx.com:k26c_som240_1_connector_kr260_carrier_som240_1_connector_som240_2_connector_kr260_carrier_som240_2_connector:part0:1.4 [current_project]
set_property BOARD_CONNECTIONS  [current_project]
set gen_gth_clk [create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name gen_gth_clk]

# User Parameters
set_property -dict [list \
  CONFIG.CLKOUT1_JITTER {253.603} \
  CONFIG.CLKOUT1_PHASE_ERROR {226.541} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {44.375} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {44.375} \
  CONFIG.MMCM_DIVCLK_DIVIDE {4} \
] [get_ips gen_gth_clk]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $gen_gth_clk

##################################################################

