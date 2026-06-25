connect
targets -set -filter {name =~ "APU*"}
source {./RISCV_SNN.gen/sources_1/bd/ps_stub/ip/ps_stub_ps7_0_0/ps7_init.tcl}
ps7_init
ps7_post_config
disconnect
