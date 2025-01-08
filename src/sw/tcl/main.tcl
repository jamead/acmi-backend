proc init {} {}

proc setSources {} {
  variable Sources
  ::fwfwk::printInfo "Set Sources..."
  # path relative to tcl file
  lappend Sources {../inc "includes"}
  lappend Sources {../src "sources"}
  #lappend Sources {../../common/inc "includes"}
  #lappend Sources {../../common/src "sources"}

  # add libraries
  #lappend Sources {../../lib/i2c "includes"}
  #lappend Sources {../../lib/i2c "sources"}
  #lappend Sources {../../lib/spi "includes"}
  #lappend Sources {../../lib/spi "sources"}
  #lappend Sources {../../lib/gpiops "includes"}
  #lappend Sources {../../lib/gpiops "sources"}
  #lappend Sources {../../lib/sysmon "includes"}
  #lappend Sources {../../lib/sysmon "sources"}
}

proc customizeFsblBsp {} {
  #variable Config
  #::fwfwk::printInfo "Customizing FSBL BSP"
  
  #domain active {zynqmp_fsbl}
  # add customizations here
  #if {[string equal $Config(ConsoleUart) "USB"]} {
  #  ::fwfwk::printInfo "Setting console port psu_uart_1"
  #  bsp config stdin "psu_uart_1"
  #  bsp config stdout "psu_uart_1"
  #}
  ##end customizations
  #bsp write
  #bsp reload
  #bsp regenerate
}

proc customizeAppBsp {} {
  #variable Config
  #::fwfwk::printInfo "Customizing application BSP"

  #domain active {app_domain}
  # add customizations here
  #bsp config total_heap_size "1048576"
  #bsp config minimal_stack_size "1024"
  #bsp config max_task_name_len "32"
  #if {[string equal $Config(ConsoleUart) "USB"]} {
  #  ::fwfwk::printInfo "Setting console port psu_uart_1"
  #  bsp config stdin "psu_uart_1"
  #  bsp config stdout "psu_uart_1"
  #}
  ##end customizations
  #bsp write
  #bsp reload
  #bsp regenerate
}

proc doOnCreate {} {
  #variable Config
  #variable Sources
  #addSources Sources
  fwfwk::printInfo "doOnCreate in src/sw/main.tcl - Adding LWIP 211"

  #domain active {app_domain}
  bsp setlib xilpm 
  bsp config total_heap_size "1048576"
  bsp config minimal_stack_size "1024"
  bsp config max_task_name_len "32"

  bsp setlib -name lwip211
  bsp config api_mode "SOCKET_API"
  bsp write
  bsp reload
  bsp regenerate
  #if {[info exists ::fwfwk::ConsoleUart]} {
  #  fwfwk::printInfo "ConsoleUart = ${::fwfwk::ConsoleUart}"
  #  set Config(ConsoleUart) [string toupper ${::fwfwk::ConsoleUart}]
  #} else {
  #  puts "ConsoleUart not defined, default to RS232"
  #  set Config(ConsoleUart) "RS232"
  #}
  #customizeFsblBsp
  #customizeAppBsp
}

proc doOnBuild {} {}