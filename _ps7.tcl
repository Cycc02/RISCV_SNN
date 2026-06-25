connect
puts "<<TARGETS>>"
targets
puts "<<SET_APU>>"
if {1} { puts "ERR set_apu: $err" } else { puts "OK set_apu" }
puts "<<SOURCE_PS7>>"
source C:/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/RISCV_SNN.gen/sources_1/bd/ps_stub/ip/ps_stub_ps7_0_0/ps7_init.tcl
puts "<<RUN_PS7_INIT>>"
if {1} { puts "ERR ps7_init: $err" } else { puts "OK ps7_init" }
puts "<<POST_CONFIG>>"
if {1} { puts "ERR post: $err" } else { puts "OK post" }
puts "<<MWR_RST>>"
if {1} { puts "ERR mwr: $err" } else { puts "OK mwr" }
puts "<<FCLK0_CTRL>>"
if {1} { puts "ERR mrd: $err" } else { puts "OK mrd" }
disconnect
