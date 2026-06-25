## Program PL, run ps7_init (starts CPU), then immediately arm the ILA in
## capture-control mode to record the UART character stream (probe7).
## Single hw_manager session — no reconnect between program and capture.
set PROJ_ROOT [file dirname [info script]]
set IMPL_DIR  [file join $PROJ_ROOT RISCV_SNN.runs impl_1]
set BITFILE   [file join $IMPL_DIR riscv_top.bit]
set LTXFILE   [file join $IMPL_DIR riscv_top.ltx]
set PS7_INIT  [file join $PROJ_ROOT RISCV_SNN.gen sources_1 bd ps_stub ip \
                   ps_stub_ps7_0_0 ps7_init.tcl]

if {![file exists $BITFILE]} { error "Bitfile not found: $BITFILE" }

open_hw_manager
connect_hw_server -url localhost:3121 -allow_non_jtag
set_property PARAM.FREQUENCY 500000 [lindex [get_hw_targets] 0]
open_hw_target
set dev [lindex [get_hw_devices xc7z030*] 0]
current_hw_device $dev
set_property PROGRAM.FILE $BITFILE $dev
set_property PROBES.FILE      $LTXFILE $dev
set_property FULL_PROBES.FILE $LTXFILE $dev
program_hw_devices $dev
puts "\[OK\] PL programmed"

## ps7_init via xsdb (starts FCLK0 -> CPU runs from here)
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
} else {
    puts "\[OK\] ps7_init done — FCLK0 running, CPU active"
}

refresh_hw_device $dev

## Arm ILA: trigger on first UART byte, store ONLY uart_tx_valid==1 samples
set ila [lindex [get_hw_ilas] 0]
set p_valid [get_hw_probes *dbg_uart_tx_valid* -of_objects $ila]
set_property CONTROL.CAPTURE_MODE BASIC $ila
set_property CAPTURE_COMPARE_VALUE eq1'b1 $p_valid
set_property TRIGGER_COMPARE_VALUE eq1'b1 $p_valid
set_property CONTROL.TRIGGER_POSITION 0 $ila
run_hw_ila $ila
## Report (~1-2 KB) won't fill the 4096 buffer, so the ILA never signals
## "full" — wait 4 min for CoreMark to finish, then force-upload partial data.
puts "ILA armed (capture-qualified on uart_tx_valid). Waiting 4 min..."
if {[catch {wait_on_hw_ila -timeout 4 $ila} err]} {
    puts "wait_on_hw_ila: $err"
}
upload_hw_ila_data $ila
write_hw_ila_data -force [file join $PROJ_ROOT ila_uart_chars.ila] hw_ila_data_1
write_hw_ila_data -force -csv_file [file join $PROJ_ROOT ila_uart_chars.csv] hw_ila_data_1
puts "RESULT: ila_uart_chars.csv + .ila written"
close_hw_manager
