# run_coremark.ps1 — Build CoreMark firmware and run xsim from PowerShell
# Usage: cd to project root, then: powershell -ExecutionPolicy Bypass -File run_coremark.ps1

$ErrorActionPreference = "Stop"

$VIVADO_BIN  = "C:\AMDDesignTools\2025.2\Vivado\bin"
$RISCV_BIN   = "C:\AMDDesignTools\2025.2\gnu\riscv\nt\bin"
$PROJ_ROOT   = $PSScriptRoot
$COREMARK    = "$PROJ_ROOT\coremark"
$PORT        = "$COREMARK\coremark-riscv"
$XSIM_DIR    = "$PROJ_ROOT\RISCV_SNN.sim\sim_1\behav\xsim"
$PYTHON      = "C:\Python313\python.exe"

$env:PATH = "$VIVADO_BIN;$RISCV_BIN;$env:PATH"

$CC      = "riscv64-unknown-elf-gcc.exe"
$OBJCOPY = "riscv64-unknown-elf-objcopy.exe"
$OBJDUMP = "riscv64-unknown-elf-objdump.exe"
$SIZE    = "riscv64-unknown-elf-size.exe"

# -----------------------------------------------------------------------
# Step 1 — Build firmware
# -----------------------------------------------------------------------
Write-Host ""
Write-Host "=== Step 1: Building CoreMark firmware ===" -ForegroundColor Cyan

$SRCS = @(
    "$PROJ_ROOT\crt0.S",
    "$COREMARK\core_list_join.c",
    "$COREMARK\core_matrix.c",
    "$COREMARK\core_state.c",
    "$COREMARK\core_util.c",
    "$COREMARK\core_main.c",
    "$PORT\core_portme.c"
)

$CFLAGS = @(
    "-march=rv32i", "-mabi=ilp32",
    "-O2",
    "-ffreestanding", "-nostdlib",
    "-DITERATIONS=20",
    "-DHAS_FLOAT=0",
    "-DPERFORMANCE_RUN=1",
    "-DMAIN_HAS_NOARGC=1",
    "-DSEED_METHOD=2",
    "-DMEM_METHOD=0",
    "-DMULTITHREAD=1",
    "-DTOTAL_DATA_SIZE=2000",
    "-I$PORT",
    "-I$COREMARK",
    "-Wl,--build-id=none"
)

& $CC @CFLAGS -T "$PROJ_ROOT\link.ld" -o "$PROJ_ROOT\coremark.elf" @SRCS -lgcc
Write-Host "[OK] coremark.elf compiled" -ForegroundColor Green

# Verify entry point landed at 0x00000000
$entryLine = (& $OBJDUMP -f "$PROJ_ROOT\coremark.elf") | Select-String "start address"
Write-Host "     $entryLine" -ForegroundColor Yellow
if ($entryLine -notmatch "0x00000000") {
    Write-Host "[ERROR] Entry point is not 0x00000000 - check link.ld!" -ForegroundColor Red
    exit 1
}

# Raw binary output (AMD objcopy verilog hex has reversed byte order vs
# what $readmemh expects, so we use -O binary and convert via bin2hex.py)
& $OBJCOPY -O binary --only-section=.init --only-section=.text `
    "$PROJ_ROOT\coremark.elf" "$PROJ_ROOT\itcm.bin"

& $OBJCOPY -O binary `
    --change-addresses -0x10000 `
    --only-section=.data --only-section=.sdata --only-section=.rodata `
    "$PROJ_ROOT\coremark.elf" "$PROJ_ROOT\dtcm.bin"

# Convert binary -> Verilog hex (little-endian words -> $readmemh format)
& $PYTHON "$PROJ_ROOT\bin2hex.py" "$PROJ_ROOT\itcm.bin" "$PROJ_ROOT\itcm.hex"
& $PYTHON "$PROJ_ROOT\bin2hex.py" "$PROJ_ROOT\dtcm.bin" "$PROJ_ROOT\dtcm.hex"

& $OBJDUMP -d "$PROJ_ROOT\coremark.elf" | Out-File -Encoding utf8 "$PROJ_ROOT\coremark.asm"
Write-Host "[OK] coremark.asm generated" -ForegroundColor Green

& $SIZE "$PROJ_ROOT\coremark.elf"

# -----------------------------------------------------------------------
# Step 2 -- Compile HDL (xvlog) -- incremental
# -----------------------------------------------------------------------
Write-Host ""
Write-Host "=== Step 2: Compiling HDL ===" -ForegroundColor Cyan
Push-Location $XSIM_DIR
& xvlog.bat --incr --relax -L uvm -prj coremark_tb_vlog.prj -log xvlog.log
Write-Host "[OK] xvlog done" -ForegroundColor Green

# -----------------------------------------------------------------------
# Step 3 -- Elaborate with optimisations
#   --debug off : skip waveform recording (big speedup vs 'typical')
#   -O3         : maximum simulator optimisation
#   --mt 8      : use 8 threads (was 2)
# -----------------------------------------------------------------------
Write-Host ""
Write-Host "=== Step 3: Elaborating (--debug off -O3 --mt 8) ===" -ForegroundColor Cyan
& xelab.bat --incr --debug off --relax --mt 8 -O3 `
    -L xil_defaultlib -L uvm -L unisims_ver -L unimacro_ver -L secureip -L xpm `
    --snapshot coremark_tb_behav `
    xil_defaultlib.coremark_tb xil_defaultlib.glbl `
    -log coremark_elaborate.log
Write-Host "[OK] Elaboration done" -ForegroundColor Green

# -----------------------------------------------------------------------
# Step 4 -- Simulate (patch xsim_script.tcl to remove -autoloadwcfg so
#           xsimk runs without -simmode gui / wdb recording — ~10x speedup)
# -----------------------------------------------------------------------
Write-Host ""
Write-Host "=== Step 4: Patching xsim_script.tcl (remove -autoloadwcfg) ===" -ForegroundColor Cyan
$tcl_script = "xsim.dir/coremark_tb_behav/xsim_script.tcl"
Set-Content $tcl_script "xsim {coremark_tb_behav} -runall" -Encoding utf8
Write-Host "[OK] xsim_script.tcl patched" -ForegroundColor Green

Write-Host ""
Write-Host "=== Step 4: Running simulation ===" -ForegroundColor Cyan
Write-Host "    Output will stream below. Ctrl+C to abort."
Write-Host ""
& xsim.bat coremark_tb_behav -runall -log coremark_simulate.log

Pop-Location
Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Green
