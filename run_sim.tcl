set PROJ_ROOT [file dirname [info script]]
open_project [file join $PROJ_ROOT RISCV_SNN.xpr]
set_property top coremark_tb [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {0ns} -objects [get_filesets sim_1]
launch_simulation
run 20ms
puts "=== sim done ==="
close_sim -force
close_project
