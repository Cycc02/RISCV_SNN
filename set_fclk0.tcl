## One-shot: change PS7 FCLK0 frequency, regenerate BD output products,
## then exit. Caller (e.g. quick_build.tcl) handles the rebuild.
##
##   vivado.bat -mode batch -source set_fclk0.tcl -tclargs 80
##
set FREQ_MHZ [expr {[llength $argv] >= 1 ? [lindex $argv 0] : 80}]

set PROJ_ROOT [file dirname [info script]]
set XPR       [file join $PROJ_ROOT RISCV_SNN.xpr]
set BD        [file join $PROJ_ROOT RISCV_SNN.srcs sources_1 bd ps_stub ps_stub.bd]

catch {close_project -quiet}
open_project $XPR
open_bd_design $BD

set ps_cell [get_bd_cells -hierarchical -filter {VLNV =~ "*:processing_system7*"}]
puts "Current FCLK0 = [get_property CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ $ps_cell] MHz"
set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ $FREQ_MHZ] $ps_cell
puts "Set FCLK0 = [get_property CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ $ps_cell] MHz"

validate_bd_design
save_bd_design
generate_target all [get_files [file tail $BD]]
puts "\[OK\] BD updated and output products regenerated"

close_project
