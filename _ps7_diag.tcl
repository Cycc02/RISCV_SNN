connect
puts "=== TARGETS ==="
targets
targets -set -filter {name =~ "APU*"}
source C:/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/RISCV_SNN.gen/sources_1/bd/ps_stub/ip/ps_stub_ps7_0_0/ps7_init.tcl
puts "=== RUNNING ps7_init ==="
ps7_init
ps7_post_config
mwr 0xF8000240 0x0
puts "=== FCLK0_CTRL (0xF8000170) ==="
mrd 0xF8000170
puts "=== FPGA_RST_CTRL (0xF8000240) ==="
mrd 0xF8000240
disconnect
