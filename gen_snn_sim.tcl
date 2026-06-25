# Regenerate behavioral sim scripts with snn_e2e_tb as the top.
open_project C:/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/RISCV_SNN.xpr
set_property top snn_e2e_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1
puts "SIM TOP: [get_property top [get_filesets sim_1]]"
# scripts_only: write compile/elaborate/simulate .bat without spawning xsim
launch_simulation -scripts_only -mode behavioral
puts "DONE generating sim scripts"
close_project
