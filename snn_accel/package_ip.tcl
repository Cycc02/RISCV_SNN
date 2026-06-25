# =============================================================================
# package_ip.tcl
# Packages snn_accel/ as a Vivado AXI4-Lite IP (axi4lite_snn_wrapper).
#
# Usage (from Vivado Tcl console, with CWD = repo root or snn_accel/):
#     source snn_accel/package_ip.tcl
#
# Or from cmd:
#     vivado -mode batch -source snn_accel/package_ip.tcl
#
# Output:
#     snn_accel/ip_repo/axi4lite_snn_wrapper_1.0/
#         component.xml, xgui/, src/, ...
# Add that directory to your MicroBlaze project's IP Repository
# (Project Settings -> IP -> Repository -> +).
# =============================================================================

# ---- User-tweakable identity ----
set ip_vendor   "user"
set ip_library  "fyp"
set ip_name     "axi4lite_snn_wrapper"
set ip_version  "1.0"
set ip_display  "SNN Accelerator (AXI4-Lite)"
set ip_taxonomy "/UserIP"

# ---- Locate snn_accel/ relative to this script ----
set script_dir [file normalize [file dirname [info script]]]
set rtl_dir    [file join $script_dir rtl]
set wrap_dir   [file join $script_dir wrapper]
set ip_dir     [file join $script_dir ip_repo ${ip_name}_${ip_version}]

file mkdir $ip_dir

# ---- Close any currently-open project (Vivado allows only one at a time) ----
catch { close_bd_design [current_bd_design] }
catch { close_project }

# ---- Temp packaging project ----
# Part is irrelevant for IP packaging (no synthesis), but Vivado needs one.
# Priority: 1) user override via $ip_part, 2) part from currently open project,
# 3) first installed part.
if {![info exists ip_part] || $ip_part eq ""} {
    set ip_part ""
    catch { set ip_part [get_property PART [current_project]] }
    if {$ip_part eq ""} {
        set parts [get_parts]
        if {[llength $parts] == 0} {
            error "No parts installed in this Vivado. Install device support or set 'ip_part' before sourcing."
        }
        set ip_part [lindex $parts 0]
    }
}
puts "package_ip.tcl: using part = $ip_part"

set proj_name pkg_${ip_name}
set proj_dir  [file join $script_dir .pkg_proj]
file delete -force $proj_dir
create_project $proj_name $proj_dir -part $ip_part -force

# ---- Add sources ----
foreach f [glob -nocomplain [file join $rtl_dir *.v]] {
    add_files -norecurse $f
}
add_files -norecurse [file join $wrap_dir axi4lite_snn_wrapper.v]

set_property top axi4lite_snn_wrapper [current_fileset]
update_compile_order -fileset sources_1

# ---- Package as IP ----
ipx::package_project -root_dir $ip_dir \
    -vendor $ip_vendor -library $ip_library -taxonomy $ip_taxonomy \
    -import_files -set_current true

set core [ipx::current_core]
set_property name             $ip_name    $core
set_property version          $ip_version $core
set_property display_name     $ip_display $core
set_property description      "Standalone SNN accelerator with AXI4-Lite slave interface and 4 KB internal image BRAM. HLS ap_ctrl_hs handshake." $core
set_property vendor_display_name "$ip_vendor"  $core
set_property company_url       "https://github.com/" $core

# ---- Infer AXI4-Lite slave interface from S_AXI_* ports ----
ipx::infer_bus_interface { \
    S_AXI_AWADDR S_AXI_AWPROT S_AXI_AWVALID S_AXI_AWREADY \
    S_AXI_WDATA  S_AXI_WSTRB  S_AXI_WVALID  S_AXI_WREADY  \
    S_AXI_BRESP  S_AXI_BVALID S_AXI_BREADY                \
    S_AXI_ARADDR S_AXI_ARPROT S_AXI_ARVALID S_AXI_ARREADY \
    S_AXI_RDATA  S_AXI_RRESP  S_AXI_RVALID  S_AXI_RREADY  \
} xilinx.com:interface:aximm_rtl:1.0 $core

# Tag it as a Lite slave (no bursts)
set s_axi_if [ipx::get_bus_interfaces S_AXI -of_objects $core]
set_property abstraction_type_vlnv xilinx.com:interface:aximm_rtl:1.0 $s_axi_if
set_property bus_type_vlnv         xilinx.com:interface:aximm:1.0     $s_axi_if
set_property interface_mode        slave                              $s_axi_if

# ---- Associate clock + reset with the AXI interface ----
# The "N" suffix on S_AXI_ARESETN is the Xilinx convention; polarity is inferred.
ipx::associate_bus_interfaces -busif S_AXI -clock S_AXI_ACLK $core
ipx::associate_bus_interfaces -clock S_AXI_ACLK -reset S_AXI_ARESETN $core

# ---- Memory map: 32 KB aperture ----
set mm  [ipx::add_memory_map S_AXI $core]
set blk [ipx::add_address_block reg0 $mm]
set_property base_address    0          $blk
set_property range           32768      $blk
set_property width           32         $blk
set_property usage           register   $blk
set_property access          read-write $blk

# Re-bind the slave interface to that memory map
set_property slave_memory_map_ref S_AXI $s_axi_if

# ---- Finalize ----
ipx::create_xgui_files       $core
ipx::update_checksums        $core
ipx::save_core               $core
ipx::check_integrity         $core

puts ""
puts "=================================================================="
puts " IP packaged at: $ip_dir"
puts " Add this directory to your MicroBlaze project's IP Repository."
puts "=================================================================="
puts ""

close_project
