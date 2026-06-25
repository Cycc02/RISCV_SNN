set PROJ_ROOT [file dirname [info script]]
open_hw_manager
connect_hw_server -url localhost:3121 -allow_non_jtag
set_property PARAM.FREQUENCY 500000 [lindex [get_hw_targets] 0]
open_hw_target
set dev [lindex [get_hw_devices xc7z030*] 0]
current_hw_device $dev
set_property PROBES.FILE [file join $PROJ_ROOT RISCV_SNN.runs impl_1 riscv_top.ltx] $dev
set_property FULL_PROBES.FILE [file join $PROJ_ROOT RISCV_SNN.runs impl_1 riscv_top.ltx] $dev
refresh_hw_device $dev

set ila [lindex [get_hw_ilas] 0]
puts "ILA: $ila"

## Capture 1 — immediate, where is the PC right now?
set_property CONTROL.TRIGGER_POSITION 0 $ila
run_hw_ila $ila -trigger_now
wait_on_hw_ila $ila
upload_hw_ila_data $ila
write_hw_ila_data -force -csv_file [file join $PROJ_ROOT ila_now.csv] hw_ila_data_1
puts "\[OK\] immediate capture -> ila_now.csv"

## Capture 2 — armed on UART address write
set p_uart [get_hw_probes *dbg_uart_addr* -of_objects $ila]
set_property TRIGGER_COMPARE_VALUE eq1'b1 $p_uart
set_property CONTROL.TRIGGER_POSITION 256 $ila
run_hw_ila $ila
puts "\[OK\] ILA armed on dbg_uart_addr==1, restarting CPU..."

## Restart CPU
set xs [file join $PROJ_ROOT _restart_cpu.tcl]
set fh [open $xs w]
puts $fh "connect"
puts $fh "targets -set -filter {name =~ \"APU*\"}"
puts $fh "source {$PROJ_ROOT/RISCV_SNN.gen/sources_1/bd/ps_stub/ip/ps_stub_ps7_0_0/ps7_init.tcl}"
puts $fh "ps7_init"
puts $fh "ps7_post_config"
puts $fh "disconnect"
close $fh
catch {exec xsdb $xs} out
puts "xsdb: $out"

## Wait up to 2 min for trigger
set fired 1
if {[catch {wait_on_hw_ila -timeout 2 $ila} werr]} {
    puts "wait_on_hw_ila: $werr"
    set fired 0
}
if {$fired} {
    upload_hw_ila_data $ila
    write_hw_ila_data -force -csv_file [file join $PROJ_ROOT ila_uart.csv] hw_ila_data_1
    puts "\[OK\] UART trigger FIRED -> ila_uart.csv"
} else {
    puts "\[NO\] UART trigger did NOT fire in 60s — CPU never writes 0x40000000"
}
close_hw_manager
