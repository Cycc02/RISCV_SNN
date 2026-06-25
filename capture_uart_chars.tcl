## Capture the CoreMark UART character stream over JTAG via ILA.
## Requires bitstream built with C_EN_STRG_QUAL=true and probe7=dbg_uart_char[7:0].
## Capture control: store ONLY samples where dbg_uart_tx_valid==1, so the
## 4096-deep buffer holds 4096 consecutive UART characters.
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
set p_valid [get_hw_probes *dbg_uart_tx_valid* -of_objects $ila]

## Basic capture mode: only store qualifying samples
set_property CONTROL.CAPTURE_MODE BASIC $ila
set_property CAPTURE_COMPARE_VALUE eq1'b1 $p_valid

## Trigger on the first UART byte write, trigger at position 0
set_property TRIGGER_COMPARE_VALUE eq1'b1 $p_valid
set_property CONTROL.TRIGGER_POSITION 0 $ila

run_hw_ila $ila
puts "ILA armed. Waiting up to 10 min for 4096 UART chars..."
if {[catch {wait_on_hw_ila -timeout 10 $ila} err]} {
    puts "wait_on_hw_ila: $err"
}
upload_hw_ila_data $ila
write_hw_ila_data -force -csv_file [file join $PROJ_ROOT ila_uart_chars.csv] hw_ila_data_1
puts "RESULT: ila_uart_chars.csv written"
close_hw_manager
