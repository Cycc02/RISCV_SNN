connect
targets -set -filter {name =~ "APU*"}
source C:/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/RISCV_SNN.gen/sources_1/bd/ps_stub/ip/ps_stub_ps7_0_0/ps7_init.tcl
ps7_init
ps7_post_config
mwr 0xF8000240 0x0
disconnect
