# SNN Accelerator — Standalone Subproject

Self-contained MNIST SNN accelerator originally developed alongside the RV32I
core in this repo. Packaged here as an AXI4-Lite IP-style block for
integration with Xilinx MicroBlaze (or any AXI4-Lite master).

## Layout

```
snn_accel/
├── rtl/                Core SNN RTL (copies of files also used by the RV32I project)
│   ├── snn_top.v
│   ├── snn_ctrl.v
│   ├── snn_pe.v
│   ├── learning_unit.v
│   ├── stdp.v
│   ├── spike_time_mem.v
│   ├── aer_fifo.v
│   ├── aer_scan.v
│   ├── simd_8.v
│   └── dual_port_RAM.v
├── wrapper/
│   └── axi4lite_snn_wrapper.v   AXI4-Lite slave + 4 KB image BRAM
├── tb/
│   └── learning_unit_tb.sv
└── docs/
    └── README.md (this file)
```

The RTL files are **copies** of the originals under `RISCV_SNN.srcs/sources_1/new/`
so the existing Vivado project still builds untouched.

## Top-level: `axi4lite_snn_wrapper`

AXI4-Lite slave. 15-bit AXI address (32 KB aperture):

- `0x0000–0x3FFF` → CSR window (only low 8 bits decoded)
- `0x4000–0x4FFF` → 4 KB image BRAM (1024 × 32b)

### Register map

| Offset | Name      | Acc | Bits  | Notes                                          |
|--------|-----------|-----|-------|------------------------------------------------|
| 0x0000 | CTRL      | RW  | [0]   | `ap_start` (kick) — self-clearing, starts inference |
|        |           |     | [1]   | `soft_reset` — held while 1, releases SNN core |
| 0x0004 | STATUS    | RO  | [0]   | `ap_done`  (= done_l2 sticky, HLS ap_ctrl_hs)  |
|        |           |     | [1]   | `ap_idle`  (= ~busy)                           |
|        |           |     | [2]   | `ap_ready` (= ~busy, can accept next ap_start) |
|        |           |     | [3]   | `busy` (1 between ap_start and done_l2)        |
|        |           |     | [4]   | `done_l1` (sticky, cleared on ap_start)        |
|        |           |     | [5]   | `done_learn` (sticky)                          |
| 0x0008 | TIMESTEP  | RW  | [7:0] | Drives `snn_top.timestep_i`                    |
| 0x000C | IMG_BASE  | RW  | [11:0]| Base offset into image BRAM                    |
| 0x0010 | HIDDEN_LO | RO  | [31:0]| `hidden_spike_o[31:0]`                         |
| 0x0014 | HIDDEN_HI | RO  | [31:0]| `hidden_spike_o[63:32]`                        |
| 0x0018 | OUTPUT    | RO  | [9:0] | `output_spike_o`                               |
| 0x4000 | IMG_BUF   | RW  | [31:0]| Word 0 of image BRAM                           |
| 0x4004 | …         | RW  |       | Word 1                                         |
| …      | …         | RW  |       | up to word 1023 at 0x4FFC                      |

### Typical MicroBlaze flow

```c
// AXI base address as assigned in Vivado Address Editor
#define SNN_BASE   0x44A00000
#define REG(o)     (*(volatile uint32_t *)(SNN_BASE + (o)))

// 1. Load image (784 bytes packed into 196 words, or however your scanner expects)
for (int i = 0; i < N_WORDS; i++)
    REG(0x4000 + i*4) = image_words[i];

// 2. Set timestep and base
REG(0x0008) = timestep;
REG(0x000C) = 0;       // start at word 0 of IMG_BUF

// 3. Kick
REG(0x0000) = 0x1;     // ap_start, self-clears

// 4. Poll (HLS ap_ctrl_hs: bit 0 = ap_done)
while ((REG(0x0004) & 0x1) == 0) ;

// 5. Read result
uint32_t out = REG(0x0018) & 0x3FF;
```

### Using the packaged IP in a Vivado MicroBlaze project

The IP is pre-packaged at `snn_accel/ip_repo/axi4lite_snn_wrapper_1.0/`.
If it's missing or you want to rebuild from source, regenerate it with:

```tcl
# In Vivado Tcl console, from the repo root:
cd <repo_root>
source snn_accel/package_ip.tcl
```

#### Step 1 — Register the IP repository

In your MicroBlaze Vivado project:

`Project Settings → IP → Repository → +` and add the absolute path to
`snn_accel/ip_repo/`. Click **OK**; Vivado scans and reports 1 IP found
("SNN Accelerator (AXI4-Lite)").

#### Step 2 — Add the IP to the Block Design

1. Open your Block Design.
2. **Add IP** (`+` icon) → search **"SNN Accelerator"** → double-click.
3. The cell appears with one slave AXI interface `S_AXI` plus the clock/reset.

#### Step 3 — Connect AXI, clock, reset

- **`S_AXI`** → connect to MicroBlaze `M_AXI_DP` directly, OR to a slave port
  of an **AXI Interconnect** downstream of the LMB→AXI bridge if you already
  have multiple AXI peripherals.
- **`S_AXI_ACLK`** → same clock that drives MicroBlaze's AXI side
  (typically the `clk_wiz` output, e.g. 100 MHz).
- **`S_AXI_ARESETN`** → the `peripheral_aresetn` output of the
  `Processor System Reset` block tied to the MicroBlaze AXI clock.

Run **Run Connection Automation** if you'd rather Vivado handle the
interconnect/reset plumbing for you.

#### Step 4 — Assign address

Open the **Address Editor** tab. Under MicroBlaze → Data, the new IP appears
as **Unmapped**. Right-click → **Assign Address**. Defaults to a Xilinx user-IP
slot (e.g. `0x44A0_0000`, range **32K**). Note the address — your software
uses it as `SNN_BASE`.

#### Step 5 — Validate, generate, export

1. **Validate Design** (`F6`) — should pass with no errors.
2. **Generate Bitstream**.
3. **File → Export → Export Hardware** (include bitstream) to produce the
   `.xsa` for the Vitis software side.

#### Step 6 — Software (Vitis)

Use the MMIO pattern from the example above, with `SNN_BASE` set to the
address you assigned in Step 4. No BSP driver is shipped — the register map
is small enough that direct `volatile uint32_t *` access is the simplest path.

## Notes vs. original RV32I integration

| Item              | Original (RV32I)                       | This wrapper                        |
|-------------------|----------------------------------------|-------------------------------------|
| Image source      | CPU's DTCM                             | Internal 4 KB BRAM in wrapper       |
| Kick              | Memory-mapped store from CPU           | Write `0x1` to CTRL                 |
| Result readback   | Memory-mapped load                     | Read HIDDEN_LO/HI, OUTPUT regs      |
| Reset             | Global `rstn`                          | `aresetn` AND-ed with `soft_reset`  |

The SNN core itself is unchanged: it still uses its `dtcm_rd_en_o` /
`dtcm_addr_o` / `dtcm_data_i` port — the wrapper just routes that port to
its internal image BRAM instead of the RV32I DTCM.
