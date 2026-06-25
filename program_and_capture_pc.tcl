## DEBUG variant: capture every cycle (no qualifier) so we can see CPU PC
## activity even if no UART byte is ever written. Use this to diagnose
## hangs / stuck CPU.
set PROJ_ROOT [file dirname [info script]]
set IMPL_DIR  [file join $PROJ_ROOT RISCV_SNN.runs impl_1]
set BITFILE   [file join $IMPL_DIR riscv_top.bit]
set LTXFILE   [file join $IMPL_DIR riscv_top.ltx]
set PS7_INIT  [file join $PROJ_ROOT RISCV_SNN.gen sources_1 bd ps_stub ip \
                   ps_stub_ps7_0_0 ps7_init.tcl]

open_hw_manager
connect_hw_server -url localhost:3121 -allow_non_jtag
set_property PARAM.FREQUENCY 500000 [lindex [get_hw_targets] 0]
open_hw_target
set dev [lindex [get_hw_devices xc7z030*] 0]
current_hw_device $dev
set_property PROGRAM.FILE      $BITFILE $dev
set_property PROBES.FILE       $LTXFILE $dev
set_property FULL_PROBES.FILE  $LTXFILE $dev
program_hw_devices $dev
puts "\[OK\] PL programmed"

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
catch {exec xsdb $xsdb_script}
puts "\[OK\] ps7_init invoked"

refresh_hw_device $dev

## Arm ILA to trigger on `jal main` instruction at PC 0x4c. Then capture
## what executes after. dbg_pc is 15 bits wide (word index, lower bits of
## byte PC). 0x4c >> 0 in byte addr; but probe is dbg_pc which appears to
## be the program counter — try both byte and word interpretations.
## We trigger on byte PC 0x4c == 15'h004C.
## TRIGGER_POSITION = 64 so we still see a few cycles before the trigger
## and ~4032 cycles after — plenty to confirm whether next PC is 0x158
## (main entry) or 0x50 (end_loop).
set ila [lindex [get_hw_ilas] 0]
set p_pc    [get_hw_probes *dbg_pc* -of_objects $ila]
set p_rstn  [get_hw_probes *dbg_rstn* -of_objects $ila]
set_property CONTROL.CAPTURE_MODE ALWAYS $ila
## Trigger on trap_trigger rising edge. Both PC=0x0000 and PC=0x004C
## triggers fired never, yet CPU sits at 0x50 (end_loop = mtvec target).
## So a trap must have fired EARLY in crt0 to get CPU there. Catch it
## here. TRIGGER_POSITION 1024 so we see ~1024 pre-trap cycles + ~3072
## post-trap (end_loop) — pre-trap PCs reveal where execution failed.
set p_trap [get_hw_probes *trap_trigger* -of_objects $ila]
set_property TRIGGER_COMPARE_VALUE eq1'b1 $p_trap
set_property CONTROL.TRIGGER_POSITION 1024 $ila
run_hw_ila $ila
puts "ILA armed (ALWAYS capture, trigger on dbg_pc==0x0000, trig pos 16)."
puts "Waiting 10 s for trigger / buffer to fill..."
after 10000
## Force stop and upload — buffer will be full from raw activity.
catch {wait_on_hw_ila -timeout 1 $ila}
upload_hw_ila_data $ila
write_hw_ila_data -force [file join $PROJ_ROOT ila_pc_boot.ila] hw_ila_data_1
write_hw_ila_data -force -csv_file [file join $PROJ_ROOT ila_pc_boot.csv] hw_ila_data_1
puts "RESULT: ila_pc_boot.csv + .ila written"
close_hw_manager
