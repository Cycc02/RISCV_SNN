#!/usr/bin/env python3
"""
snn_hw_sim.py  —  Hardware-Architecture-Accurate SNN Software Simulation

Mirrors the exact RTL execution flow of every submodule in snn_top.v:

  aer_scan  ──► AER FIFO  ──► snn_ctrl (FSM)
                                   │
                      ┌────────────┼────────────┐
                   dual_port_RAM  simd_8       snn_top latches
                   (weight RAM)   (8×snn_pe)   (hidden/output spikes)

FSM sequence per image
  IDLE → [FETCH → DEC → EXEC(×8 groups)] × active pixels  → EVAL_L1
       → L2_INIT → [DEC → EXEC(×2 groups)] × active hidden neurons → READOUT → IDLE

The purpose of this script is to prove that running the identical algorithm
in software — where every hardware-parallel operation must execute
sequentially — is orders of magnitude slower than the RTL hardware.
"""

import numpy as np
import torch
import torch.nn as nn
import time
import sys

from torchvision import datasets, transforms
from torch.utils.data import DataLoader

# ─── snntorch is only needed if we load the trained model ─────────────────────
try:
    import snntorch as snn_torch
    from snntorch import surrogate
    HAS_SNNTORCH = True
except ImportError:
    HAS_SNNTORCH = False

# =============================================================================
# Hardware constants  (match snn_top.v localparam values)
# =============================================================================
LANE_COUNT   = 8     # SIMD width  (simd_8 LANE_COUNT)
L1_HIDDEN    = 64    # hidden neurons
L1_GROUPS    = L1_HIDDEN // LANE_COUNT   # 8  (stp_idx 0..7 for L1)
L2_OUT       = 10    # output neurons
L2_GROUPS    = 2     # stp_idx 0 (neurons 0-7) and 1 (neurons 8-9)
L2_BASE_ADDR = 6272  # weight RAM offset for L2  (L1_DEPTH = 6272)

# =============================================================================
# Weight RAM builder  (identical layout to generate_hardware_hex in snn(3).py)
# =============================================================================

def build_weight_ram(w1_q: np.ndarray, w2_q: np.ndarray) -> np.ndarray:
    """
    Construct the 64-bit dual_port_RAM contents (depth=6400, width=8×INT8).

    Layout (mirrors the .hex export):
      L1  addr = pixel*8 + step   →  8 INT8 weights for hidden neurons step*8 .. step*8+7
      L2  addr = 6272 + hidden*2  →  group-0: output neurons 0-7
          addr = 6272 + hidden*2+1→  group-1: output neurons 8-9 (+6 zero-padded lanes)
    """
    ram = np.zeros((6400, LANE_COUNT), dtype=np.int8)

    # Layer 1
    for p in range(784):
        for s in range(L1_GROUPS):
            for lane in range(LANE_COUNT):
                ram[p * L1_GROUPS + s, lane] = w1_q[s * LANE_COUNT + lane, p]

    # Layer 2
    for h in range(L1_HIDDEN):
        # group 0: lanes 0-7 → output neurons 0-7
        for lane in range(LANE_COUNT):
            ram[L2_BASE_ADDR + h * 2, lane] = w2_q[lane, h]
        # group 1: lanes 0-1 → output neurons 8-9 ; lanes 2-7 → 0 (padding)
        for lane in range(LANE_COUNT):
            out_idx = 8 + lane
            ram[L2_BASE_ADDR + h * 2 + 1, lane] = w2_q[out_idx, h] if out_idx < L2_OUT else 0

    return ram


# =============================================================================
# AER Scanner  (aer_scan.v)
# =============================================================================

def aer_scan(image_binary: np.ndarray) -> list:
    """
    Scan 25 × 32-bit chunks (=800 bits, first 784 used) for set bits.
    Returns active pixel addresses in hardware scan order (LSB-first per chunk).

    Mirrors aer_scan.v:
      - chunk_num iterates 0..24  (5-bit counter, pixel p = chunk_num*32 + bit_pos)
      - combinational priority-encoder finds lowest set bit, emits AER address,
        clears that bit; repeats until chunk==0, then fetches next chunk
      - aer_data_o = (chunk_num << 5) + first_idx
    """
    flat = image_binary.flatten()

    active = []
    for chunk_num in range(25):
        base = chunk_num * 32
        for bit in range(32):        # bit 0 = LSB (first_idx priority)
            addr = base + bit
            if addr < 784 and flat[addr] == 1:
                active.append(addr)
    return active


# =============================================================================
# snn_pe  (snn_pe.v)  —  one PE step, combinational logic only
# =============================================================================

def pe_comb(acc: np.int32, weight: np.int32, spike: int, leak_en: bool) -> np.int32:
    """
    Combinational path inside snn_pe:
      v_leaked = acc >> 1  if leak_en  else  acc        (arithmetic shift, beta=0.5)
      add_w    = v_leaked + (weight if spike else 0)
      acc_o   <= add_w                                  (registered; applied immediately in SW)

    Note: the PE never resets on spike (acc_o <= add_w always, comment in RTL).
    Threshold comparison is done externally (EVAL_L1 / READOUT latches).
    """
    v_leaked = np.int32(acc >> 1) if leak_en else np.int32(acc)
    return np.int32(v_leaked + (np.int32(weight) if spike else np.int32(0)))


# =============================================================================
# Full hardware-architecture inference for one image  (snn_top.v FSM)
# =============================================================================

def hw_infer(image: np.ndarray, ram: np.ndarray, thresh_l1: int, thresh_l2: int) -> int:
    """
    Runs one image through the complete hardware FSM sequence.

    snn_ctrl states visited:
      IDLE → (FETCH → DEC → EXEC) × |AER FIFO| → EVAL_L1 →
      L2_INIT → (DEC → EXEC) × |hidden spikes| → READOUT → IDLE

    Returns predicted class (argmax of final L2 accumulated potential).
    """

    # ── Input: binary spike encoding (matches hardware >0.5 threshold) ────────
    image_binary = (image > 0.5).astype(np.uint8)

    # ── AER Scan ──────────────────────────────────────────────────────────────
    # aer_scan.v emits pixel addresses into aer_fifo (depth=64).
    # Hardware interleaves scan + consume; software collects all then processes.
    aer_fifo = aer_scan(image_binary)

    # ── SIMD scratchpads for L1  (simd_8: 8 PEs × 8 stp_idx entries) ─────────
    # scratchpad[s, lane] = membrane potential of hidden neuron s*8+lane
    scratchpad = np.zeros((L1_GROUPS, LANE_COUNT), dtype=np.int32)

    # ── is_first_pixel flag (simd_8.v) ───────────────────────────────────────
    # Set by snn_kick_i, cleared after first pixel's stp_idx==7 pe_en pulse.
    # Controls leak_en_i on every snn_pe in the SIMD array.
    # Effect: on the very first pixel the accumulated potential from the
    # previous timestep is halved (beta=0.5 decay); subsequent pixels just add.
    is_first_pixel = True

    # ─────────────────────────────────────────────────────────────────────────
    # L1 EXEC  (snn_ctrl: IDLE → FETCH → DEC → EXEC loops)
    # For each active pixel p (from AER FIFO):
    #   8 SIMD groups (loop_count 0..8, pe_en on 1..8, stp_idx = loop-1)
    #   RAM addr = p*8 + stp_idx  →  8 INT8 weights for neurons stp_idx*8..+7
    #   spike_to_simd = 1 (snn_ctrl: assign spike_o = 1'b1 always)
    # ─────────────────────────────────────────────────────────────────────────
    for p in aer_fifo:
        for s in range(L1_GROUPS):                   # stp_idx 0..7
            for lane in range(LANE_COUNT):           # 8 parallel PEs
                w = np.int32(ram[p * L1_GROUPS + s, lane])
                scratchpad[s, lane] = pe_comb(
                    scratchpad[s, lane], w,
                    spike=1,
                    leak_en=is_first_pixel           # simd_8: is_first_pixel
                )
        # simd_8: is_first_pixel cleared on pe_en && stp_idx==7
        if is_first_pixel:
            is_first_pixel = False

    # ─────────────────────────────────────────────────────────────────────────
    # EVAL_L1  (snn_ctrl EVAL_L1 state, snn_top eval_l1_o)
    # spike_to_simd forced to 0 → add_w = v_leaked = acc (is_first_pixel=0)
    # spike_trig = acc >= THRESH_L1
    # snn_top latches: hidden_spike_o[(s*8)+:8] <= spike_out  (overwrite each s)
    # ─────────────────────────────────────────────────────────────────────────
    hidden_spikes = np.zeros(L1_HIDDEN, dtype=np.int32)
    for s in range(L1_GROUPS):                       # stp_idx 0..7
        for lane in range(LANE_COUNT):
            hidden_spikes[s * LANE_COUNT + lane] = int(scratchpad[s, lane] >= thresh_l1)

    # ─────────────────────────────────────────────────────────────────────────
    # L2_INIT  (snn_ctrl L2_INIT state, snn_top layer_transition pulse)
    # l2_en_i resets all scratchpad entries to 0 (simd_8: snn_en_i || l2_en_i)
    # is_first_pixel set to 0 by l2_en_i → no leakage in L2
    # ─────────────────────────────────────────────────────────────────────────
    scratchpad = np.zeros((L2_GROUPS, LANE_COUNT), dtype=np.int32)

    # ─────────────────────────────────────────────────────────────────────────
    # L2 EXEC  (snn_ctrl: DEC scans l1_spike_buffer for set bits, EXEC 2 groups)
    # For each active hidden neuron h (l1_spike_buffer bit scan, LSB first):
    #   Group 0 (stp_idx=0): RAM addr = 6272 + h*2   → neurons 0-7
    #   Group 1 (stp_idx=1): RAM addr = 6272 + h*2+1 → neurons 8-9 (lanes 0-1)
    #   spike = 1  (snn_ctrl: assign spike_o = 1'b1)
    #   leak_en = 0  (is_first_pixel=0 after l2_en_i)
    # snn_top latches output_spike_o via OVERWRITE each pe_en_dly pulse
    # ─────────────────────────────────────────────────────────────────────────
    for h in range(L1_HIDDEN):
        if hidden_spikes[h] == 0:
            continue                                 # DEC: skip zero bits

        # Group 0
        for lane in range(LANE_COUNT):
            w = np.int32(ram[L2_BASE_ADDR + h * 2, lane])
            scratchpad[0, lane] = pe_comb(scratchpad[0, lane], w, spike=1, leak_en=False)

        # Group 1
        for lane in range(LANE_COUNT):
            w = np.int32(ram[L2_BASE_ADDR + h * 2 + 1, lane])
            scratchpad[1, lane] = pe_comb(scratchpad[1, lane], w, spike=1, leak_en=False)

    # ─────────────────────────────────────────────────────────────────────────
    # READOUT
    # output_spike_o[7:0]  = spike_out after last hidden neuron's group-0 EXEC
    # output_spike_o[9:8]  = spike_out after last hidden neuron's group-1 EXEC
    # Final accumulated potential used for argmax classification
    # ─────────────────────────────────────────────────────────────────────────
    output_potential = np.empty(L2_OUT, dtype=np.int32)
    output_potential[0:8] = scratchpad[0, 0:8]
    output_potential[8:10] = scratchpad[1, 0:2]

    return int(np.argmax(output_potential))


# =============================================================================
# Batched evaluation helpers
# =============================================================================

def evaluate_hw_sim(ram, loader, thresh_l1, thresh_l2, verbose=True):
    correct = 0
    total   = 0
    t0 = time.perf_counter()
    for batch_idx, (data, targets) in enumerate(loader):
        data_np    = data.numpy()
        targets_np = targets.numpy()
        for i in range(len(targets_np)):
            pred     = hw_infer(data_np[i], ram, thresh_l1, thresh_l2)
            correct += int(pred == targets_np[i])
            total   += 1
        if verbose and (batch_idx % 5 == 0):
            elapsed = time.perf_counter() - t0
            rate    = total / elapsed
            eta     = (10000 - total) / rate if rate > 0 else 0
            print(f"  [{total:5d}/10000]  acc={100*correct/total:.1f}%  "
                  f"{rate:.0f} img/s  ETA {eta:.0f}s", end='\r')
    elapsed = time.perf_counter() - t0
    if verbose:
        print()
    return correct, total, elapsed


def evaluate_software_snn(model, loader, device):
    """Original floating-point snntorch forward pass (batched)."""
    model.eval()
    correct = 0
    total   = 0
    t0 = time.perf_counter()
    with torch.no_grad():
        for data, targets in loader:
            data    = data.to(device)
            targets = targets.to(device)
            output  = model(data)
            correct += (output.argmax(1) == targets).sum().item()
            total   += targets.size(0)
    elapsed = time.perf_counter() - t0
    return correct, total, elapsed


# =============================================================================
# Model definition  (must match snn(3).py exactly)
# =============================================================================

def make_model():
    assert HAS_SNNTORCH, "snntorch not installed — cannot load model"

    BETA      = 0.5
    THRESHOLD = 1.0
    NUM_STEPS = 1

    class PureSoftwareSNN(nn.Module):
        def __init__(self):
            super().__init__()
            spike_grad = surrogate.fast_sigmoid(slope=25)
            self.fc1  = nn.Linear(784, 64, bias=False)
            self.lif1 = snn_torch.Leaky(beta=BETA, threshold=THRESHOLD, spike_grad=spike_grad)
            self.fc2  = nn.Linear(64, 10, bias=False)
            self.lif2 = snn_torch.Leaky(beta=BETA, threshold=THRESHOLD, spike_grad=spike_grad)

        def forward(self, x):
            mem1 = self.lif1.init_leaky()
            mem2 = self.lif2.init_leaky()
            spk2_rec = []
            for _ in range(NUM_STEPS):
                cur1 = self.fc1(x)
                spk1, mem1 = self.lif1(cur1, mem1)
                cur2 = self.fc2(spk1)
                spk2, mem2 = self.lif2(cur2, mem2)
                spk2_rec.append(spk2)
            return torch.stack(spk2_rec).sum(dim=0)

    return PureSoftwareSNN(), THRESHOLD


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":

    MODEL_PATH = "best_snn_model.pth"

    # ── 1. Load model & quantize weights ─────────────────────────────────────
    print("=" * 65)
    print("  Hardware-Architecture-Accurate SNN Software Simulation")
    print("=" * 65)

    if not HAS_SNNTORCH:
        print("ERROR: snntorch not installed.  Run:  pip install snntorch")
        sys.exit(1)

    print(f"\n[1] Loading model from '{MODEL_PATH}' ...")
    model, threshold_float = make_model()
    try:
        model.load_state_dict(torch.load(MODEL_PATH, map_location='cpu'))
    except FileNotFoundError:
        print(f"ERROR: '{MODEL_PATH}' not found.  Run snn(3).py first to train and save it.")
        sys.exit(1)
    model.eval()

    w1_float = model.fc1.weight.detach().cpu().numpy()   # (64, 784)
    w2_float = model.fc2.weight.detach().cpu().numpy()   # (10, 64)

    scale1 = 127.0 / np.max(np.abs(w1_float))
    scale2 = 127.0 / np.max(np.abs(w2_float))

    w1_q = np.clip(np.round(w1_float * scale1), -128, 127).astype(np.int8)
    w2_q = np.clip(np.round(w2_float * scale2), -128, 127).astype(np.int8)

    thresh_l1 = int(threshold_float * scale1)
    thresh_l2 = int(threshold_float * scale2)

    print(f"   Computed  THRESH_L1 = {thresh_l1}   (RTL hardcoded: 179)")
    print(f"   Computed  THRESH_L2 = {thresh_l2}   (RTL hardcoded: 17)")

    # ── 2. Build weight RAM ───────────────────────────────────────────────────
    print(f"\n[2] Building dual_port_RAM contents (depth=6400, width=64-bit) ...")
    ram = build_weight_ram(w1_q, w2_q)
    print(f"   RAM shape: {ram.shape}  dtype: {ram.dtype}")

    # ── 3. Load MNIST test set ────────────────────────────────────────────────
    print(f"\n[3] Loading MNIST test set ...")
    transform = transforms.Compose([
        transforms.ToTensor(),
        transforms.Lambda(lambda x: x.view(-1))
    ])
    test_dataset = datasets.MNIST(root='./data', train=False, download=True, transform=transform)

    # Smaller batch for hardware sim (processes one image at a time internally)
    hw_loader  = DataLoader(test_dataset, batch_size=100, shuffle=False)
    sw_loader  = DataLoader(test_dataset, batch_size=256, shuffle=False)

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    # ── 4. Software SNN (original snntorch, floating point, batched) ──────────
    print(f"\n[4] Running original floating-point software SNN ({device}) ...")
    model = model.to(device)
    sw_correct, sw_total, sw_elapsed = evaluate_software_snn(model, sw_loader, device)
    sw_acc  = 100.0 * sw_correct / sw_total
    sw_rate = sw_total / sw_elapsed
    print(f"   Accuracy  : {sw_acc:.2f}%")
    print(f"   Time      : {sw_elapsed:.3f}s  ({sw_rate:.0f} images/sec)")

    # ── 5. Hardware-architecture simulation (sequential, integer, AER) ────────
    print(f"\n[5] Running hardware-architecture simulation (CPU, sequential) ...")
    print(f"    FSM: IDLE→FETCH/DEC/EXEC(L1)→EVAL_L1→L2_INIT→EXEC(L2)→READOUT")
    hw_correct, hw_total, hw_elapsed = evaluate_hw_sim(ram, hw_loader, thresh_l1, thresh_l2)
    hw_acc  = 100.0 * hw_correct / hw_total
    hw_rate = hw_total / hw_elapsed
    print(f"   Accuracy  : {hw_acc:.2f}%")
    print(f"   Time      : {hw_elapsed:.3f}s  ({hw_rate:.0f} images/sec)")

    # ── 6. Summary ────────────────────────────────────────────────────────────
    slowdown = hw_elapsed / sw_elapsed
    print()
    print("=" * 65)
    print("  RESULTS SUMMARY")
    print("=" * 65)
    print(f"  {'Method':<42} {'Acc':>7}  {'Time':>8}  {'Img/s':>8}")
    print(f"  {'-'*42} {'-'*7}  {'-'*8}  {'-'*8}")
    print(f"  {'Floating-point SW SNN (snntorch, batched)':<42} {sw_acc:>6.2f}%  "
          f"{sw_elapsed:>7.2f}s  {sw_rate:>7.0f}")
    print(f"  {'HW-Architecture SW Sim (INT8, AER, serial)':<42} {hw_acc:>6.2f}%  "
          f"{hw_elapsed:>7.2f}s  {hw_rate:>7.0f}")
    print(f"  {'-'*42} {'-'*7}  {'-'*8}  {'-'*8}")
    print(f"\n  Software HW-sim is  {slowdown:.1f}×  slower than batched float SW.")
    print()
    print("  WHY the hardware is fast despite the same algorithm:")
    print("  ┌─────────────────────────────────────────────────┐")
    print("  │  Hardware                 Software (this script)│")
    print("  │  8 PEs execute in         8 PEs execute in      │")
    print("  │  parallel (1 clock)       sequence (8 loops)    │")
    print("  │                                                  │")
    print("  │  AER scan overlaps        AER scan then         │")
    print("  │  with SIMD execution      SIMD (2 serial phases)│")
    print("  │                                                  │")
    print("  │  ~100 MHz clock →         ~{:4.0f} MHz equiv on   │".format(hw_rate * 9000 / 1e6))
    print("  │  ~9000 cycles/image       single CPU core       │")
    print("  └─────────────────────────────────────────────────┘")
    print()
    print("  Conclusion: same algorithm, same integer arithmetic,")
    print("  same AER encoding — hardware wins through parallelism.")
    print("=" * 65)
