## Sanity test: program the BACKED-UP CoreMark bitstream and capture UART
## via the SAME ILA flow. If this works, the SNN integration broke fetch.
## If this also fails, the breakage is in our programming pipeline.
set PROJ_ROOT [file dirname [info script]]
set BITFILE   [file join $PROJ_ROOT _coremark riscv_top_coremark.bit]
set LTXFILE   [file join $PROJ_ROOT _coremark riscv_top_coremark.ltx]
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
puts "\[OK\] CoreMark PL programmed"

set xsdb_script [file join $PROJ_ROOT _ps7_init_run.tcl]
set fh [open $xsdb_script w]
puts $fh "connect"
puts $fh "targets -set -filter {name =~ \"APU*\"}"
puts $fh "source {$PS7_INIT}"
puts $fh "ps7_init"
puts $fh "ps7_post_config"
puts $fh "disconnect"
close $fh
catch {exec xsdb $xsdb_script}
puts "\[OK\] ps7_init invoked"

refresh_hw_device $dev

set ila [lindex [get_hw_ilas] 0]
set p_v [get_hw_probes *dbg_uart_tx_valid* -of_objects $ila]
set_property CONTROL.CAPTURE_MODE BASIC $ila
set_property CAPTURE_COMPARE_VALUE eq1'b1 $p_v
set_property TRIGGER_COMPARE_VALUE eq1'b1 $p_v
set_property CONTROL.TRIGGER_POSITION 0 $ila
run_hw_ila $ila
puts "ILA armed. Waiting 15 s for UART chars..."
after 15000
catch {wait_on_hw_ila -timeout 1 $ila}
upload_hw_ila_data $ila
write_hw_ila_data -force -csv_file [file join $PROJ_ROOT ila_coremark_test.csv] hw_ila_data_1
puts "RESULT: ila_coremark_test.csv written"
close_hw_manager
