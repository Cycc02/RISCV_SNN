//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
//Date        : Mon Jun 15 15:25:29 2026
//Host        : LAPTOP-3DEM65C9 running 64-bit major release  (build 9200)
//Command     : generate_target ps_stub_wrapper.bd
//Design      : ps_stub_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module ps_stub_wrapper
   (FCLK_CLK0_0,
    FCLK_RESET0_N_0,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb);
  output FCLK_CLK0_0;
  output FCLK_RESET0_N_0;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;

  wire FCLK_CLK0_0;
  wire FCLK_RESET0_N_0;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;

  ps_stub ps_stub_i
       (.FCLK_CLK0_0(FCLK_CLK0_0),
        .FCLK_RESET0_N_0(FCLK_RESET0_N_0),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb));
endmodule
