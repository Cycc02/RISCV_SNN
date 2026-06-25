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
set p_uart [get_hw_probes *dbg_uart_addr* -of_objects $ila]
set_property TRIGGER_COMPARE_VALUE eq1'b1 $p_uart
set_property CONTROL.TRIGGER_POSITION 256 $ila
run_hw_ila $ila
puts "\[OK\] armed on dbg_uart_addr==1, waiting up to 10 min (no CPU restart)"

if {[catch {wait_on_hw_ila -timeout 10 $ila} werr]} {
    puts "\[NO\] trigger did not fire: $werr"
} else {
    upload_hw_ila_data $ila
    write_hw_ila_data -force -csv_file [file join $PROJ_ROOT ila_uart.csv] hw_ila_data_1
    puts "\[OK\] capture saved -> ila_uart.csv"
}
close_hw_manager
