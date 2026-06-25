## Program the Zynq-7030 PL over JTAG, then run ps7_init to start FCLK0.
## Run from the Vivado GUI Tcl console:
##   source {C:/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/program_fpga.tcl}

set PROJ_ROOT [file dirname [info script]]
set IMPL_DIR  [file join $PROJ_ROOT RISCV_SNN.runs impl_1]
set BITFILE   [file join $IMPL_DIR riscv_top.bit]
set LTXFILE   [file join $IMPL_DIR riscv_top.ltx]
set PS7_INIT  [file join $PROJ_ROOT RISCV_SNN.gen sources_1 bd ps_stub ip \
                   ps_stub_ps7_0_0 ps7_init.tcl]

if {![file exists $BITFILE]} {
    error "Bitfile not found: $BITFILE\nRun quick_build.tcl first."
}

## --- Program PL ---
open_hw_manager
connect_hw_server -url localhost:3121 -allow_non_jtag
## Board JTAG chain only scans reliably at reduced TCK
set_property PARAM.FREQUENCY 500000 [lindex [get_hw_targets] 0]
open_hw_target

set dev [lindex [get_hw_devices xc7z030*] 0]
if {$dev eq ""} {
    set dev [lindex [get_hw_devices] 0]
    puts "WARNING: xc7z030 not found by name, using: $dev"
}
current_hw_device $dev

set_property PROGRAM.FILE $BITFILE $dev
if {[file exists $LTXFILE]} {
    set_property PROBES.FILE      $LTXFILE $dev
    set_property FULL_PROBES.FILE $LTXFILE $dev
    puts "  Probes  : $LTXFILE"
}

program_hw_devices $dev
puts "\[OK\] PL programmed"

## --- Run ps7_init via xsdb ---
## Write a temporary xsdb script then execute it as a subprocess.
set xsdb_script [file join $PROJ_ROOT _ps7_init_run.tcl]
set fh [open $xsdb_script w]
puts $fh "connect"
puts $fh "targets -set -filter {name =~ \"APU*\"}"
puts $fh "source {$PS7_INIT}"
puts $fh "ps7_init"
puts $fh "ps7_post_config"
puts $fh "disconnect"
close $fh

puts "Running ps7_init via xsdb..."
if {[catch {exec xsdb $xsdb_script} xsdb_out]} {
    puts "WARNING: xsdb said: $xsdb_out"
    puts "If the ILA shows no probes, run ps7_init manually in an xsdb session."
} else {
    puts $xsdb_out
    puts "\[OK\] ps7_init done — FCLK0 running, PL CPU active"
}

## Refresh so ILA picks up live probe data after FCLK0 starts
refresh_hw_device $dev

puts "\n=== Done ==="
puts "  Bitfile : $BITFILE"
puts "  ILA     : arm trigger in Hardware Manager, then run CoreMark\n"
