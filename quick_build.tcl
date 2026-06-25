## Full rebuild — synthesis + implementation + bitstream.
## Incremental synthesis removed: it caused repeated DCP-not-found errors.
##
## Run from Vivado GUI Tcl console:
##   source {C:/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/quick_build.tcl}

set PROJ_ROOT [file dirname [info script]]
set XPR       [file join $PROJ_ROOT RISCV_SNN.xpr]
set IMPL_DIR  [file join $PROJ_ROOT RISCV_SNN.runs impl_1]
set JOBS      16

catch {close_project -quiet}
open_project $XPR

## Clear any stale incremental checkpoints left from previous sessions
catch { reset_property INCREMENTAL_CHECKPOINT [get_runs synth_1] }
catch { reset_property INCREMENTAL_CHECKPOINT [get_runs impl_1] }

## Ensure PS7 BD wrapper is in the synthesis fileset
set PS7_WRAP [file join $PROJ_ROOT RISCV_SNN.gen sources_1 bd ps_stub hdl ps_stub_wrapper.v]
if {[llength [get_files -quiet $PS7_WRAP]] == 0} {
    add_files -norecurse $PS7_WRAP
    puts "\[OK\] Added ps_stub_wrapper.v"
}
set_property top riscv_top [current_fileset]

## Regenerate AXI UART IP if XCI parameters changed
generate_target all [get_ips axi_uart] -quiet
puts "\[OK\] AXI UART IP targets up to date"

## Synthesis
reset_run synth_1
launch_runs synth_1 -jobs $JOBS
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    error "Synthesis failed. Check RISCV_SNN.runs/synth_1/runme.log"
}
puts "\[OK\] Synthesis complete"

## Implementation + bitstream
## ILA probe definitions live in riscv_const.xdc — no implement_debug_core needed.
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs $JOBS
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {
    error "Implementation failed. Check RISCV_SNN.runs/impl_1/runme.log"
}
puts "\[OK\] Implementation + bitstream complete"

open_run impl_1 -name impl_1
write_debug_probes -force [file join $IMPL_DIR riscv_top.ltx]

puts "\n=== Build complete ==="
puts "  Bitfile : [file join $IMPL_DIR riscv_top.bit]"
puts "  Probes  : [file join $IMPL_DIR riscv_top.ltx]"
puts "  Next    : source {[file join $PROJ_ROOT program_fpga.tcl]}\n"

close_project
