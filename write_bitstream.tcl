## Generate bitstream from the existing placed+routed design.
## Run from the project root:
##   vivado -mode batch -source write_bitstream.tcl
##
## Prerequisites: impl_1 must already be placed & routed (riscv_top_routed.dcp exists).
## If you have updated itcm.hex/dtcm.hex and need to re-synthesize, use full_build.tcl instead.

set PROJ_ROOT [file dirname [info script]]
set XPR       [file join $PROJ_ROOT RISCV_SNN.xpr]
set IMPL_DIR  [file join $PROJ_ROOT RISCV_SNN.runs impl_1]

open_project $XPR
open_run impl_1 -name impl_1

write_bitstream -force [file join $IMPL_DIR riscv_top.bit]
write_debug_probes -force [file join $IMPL_DIR riscv_top.ltx]

puts "\n=== Done ==="
puts "  Bitfile : [file join $IMPL_DIR riscv_top.bit]"
puts "  Probes  : [file join $IMPL_DIR riscv_top.ltx]"
puts "  Next    : vivado -mode batch -source program_fpga.tcl\n"

close_project
