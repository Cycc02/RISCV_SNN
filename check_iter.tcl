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
set p_pc [get_hw_probes *dbg_pc* -of_objects $ila]

## reset UART probe compare from any earlier session
set p_uart [get_hw_probes *dbg_uart_addr* -of_objects $ila]
set_property TRIGGER_COMPARE_VALUE eq1'bX $p_uart

foreach {label pcval} {matrix_call 15'h0124 state_call 15'h01ac post_bench 15'h21e8} {
    set_property TRIGGER_COMPARE_VALUE eq$pcval $p_pc
    set_property CONTROL.TRIGGER_POSITION 16 $ila
    run_hw_ila $ila
    if {[catch {wait_on_hw_ila -timeout 1 $ila}]} {
        puts "RESULT $label : ERROR"
    } else {
        upload_hw_ila_data $ila
        set n [llength [get_hw_ila_datas]]
        write_hw_ila_data -force -csv_file [file join $PROJ_ROOT ila_$label.csv] hw_ila_data_1
        puts "RESULT $label : captured -> ila_$label.csv"
    }
}
set_property TRIGGER_COMPARE_VALUE eq15'hXXXX $p_pc
close_hw_manager
