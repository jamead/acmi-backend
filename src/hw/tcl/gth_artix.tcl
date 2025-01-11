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
# source gth_artix.tcl
# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
  create_project zubpm_hw zubpm_hw -part xczu6eg-ffvb1156-1-e
  set_property target_language VHDL [current_project]
  set_property simulator_language Mixed [current_project]
}

##################################################################
# CHECK IPs
##################################################################

set bCheckIPs 1
set bCheckIPsPassed 1
if { $bCheckIPs == 1 } {
  set list_check_ips { xilinx.com:ip:gtwizard_ultrascale:1.7 }
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
# CREATE IP gth_artix
##################################################################

set gth_artix [create_ip -name gtwizard_ultrascale -vendor xilinx.com -library ip -version 1.7 -module_name gth_artix]

# User Parameters
set_property -dict [list \
  CONFIG.CHANNEL_ENABLE {X0Y8} \
  CONFIG.ENABLE_OPTIONAL_PORTS {rxpolarity_in cpllfbclklost_out cplllock_out cpllrefclklost_out} \
  CONFIG.FREERUN_FREQUENCY {25} \
  CONFIG.RX_COMMA_ALIGN_WORD {2} \
  CONFIG.RX_COMMA_M_ENABLE {true} \
  CONFIG.RX_COMMA_P_ENABLE {true} \
  CONFIG.RX_DATA_DECODING {8B10B} \
  CONFIG.RX_LINE_RATE {1.25} \
  CONFIG.RX_MASTER_CHANNEL {X0Y8} \
  CONFIG.RX_PLL_TYPE {CPLL} \
  CONFIG.RX_REFCLK_FREQUENCY {156.25} \
  CONFIG.RX_REFCLK_SOURCE {X0Y8 clk1} \
  CONFIG.TX_DATA_ENCODING {8B10B} \
  CONFIG.TX_LINE_RATE {1.25} \
  CONFIG.TX_MASTER_CHANNEL {X0Y8} \
  CONFIG.TX_PLL_TYPE {CPLL} \
  CONFIG.TX_REFCLK_FREQUENCY {156.25} \
  CONFIG.TX_REFCLK_SOURCE {X0Y8 clk1} \
] [get_ips gth_artix]

# Runtime Parameters
set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $gth_artix

##################################################################

