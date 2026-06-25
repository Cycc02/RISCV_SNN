## Full rebuild: synthesis → implementation → bitstream.
## Use this after updating itcm.hex / dtcm.hex (e.g. after running build_coremark.sh).
##
## Run from the project root:
##   vivado -mode batch -source full_build.tcl
##
## Takes ~15-30 min on a typical laptop.

set PROJ_ROOT [file dirname [info script]]
set XPR       [file join $PROJ_ROOT RISCV_SNN.xpr]
set IMPL_DIR  [file join $PROJ_ROOT RISCV_SNN.runs impl_1]
set JOBS      16

## Open project only if not already open (safe to source from GUI Tcl console)
if {[catch {current_project}]} {
    open_project $XPR
}

## Ensure PS7 block-design wrapper is in the synthesis fileset
set PS7_WRAP [file join $PROJ_ROOT RISCV_SNN.gen sources_1 bd ps_stub hdl ps_stub_wrapper.v]
if {[llength [get_files -quiet $PS7_WRAP]] == 0} {
    add_files -norecurse $PS7_WRAP
    puts "\[OK\] Added ps_stub_wrapper.v"
}
set_property top riscv_top [current_fileset]

## Regenerate AXI UART IP with updated frequency (100 MHz)
generate_target all [get_ips axi_uart] -quiet
puts "\[OK\] AXI UART IP target regenerated"

## Reset runs so Vivado re-reads sources from disk.
reset_run synth_1
reset_run impl_1

launch_runs synth_1 -jobs $JOBS
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    error "Synthesis failed. Check RISCV_SNN.runs/synth_1/runme.log"
}
puts "\[OK\] Synthesis complete"

launch_runs impl_1 -to_step write_bitstream -jobs $JOBS
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {
    error "Implementation failed. Check RISCV_SNN.runs/impl_1/runme.log"
}
puts "\[OK\] Implementation + bitstream complete"

## Generate debug probes file for ILA
open_run impl_1 -name impl_1
write_debug_probes -force [file join $IMPL_DIR riscv_top.ltx]

puts "\n=== Build complete ==="
puts "  Bitfile : [file join $IMPL_DIR riscv_top.bit]"
puts "  Probes  : [file join $IMPL_DIR riscv_top.ltx]"
puts "  Next    : vivado -mode batch -source program_fpga.tcl\n"

close_project
