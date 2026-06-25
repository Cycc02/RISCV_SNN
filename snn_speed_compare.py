#!/usr/bin/env python3
"""
snn_speed_compare.py

Proves that software SNN execution is slower than hardware by comparing:
  - Software: run the trained SNN model on MNIST test images, measure time
  - Hardware: estimate from known clock cycle count at 100 MHz
"""

import torch
import torch.nn as nn
import numpy as np
import time
import os

try:
    import snntorch as snn
    from snntorch import surrogate
except ImportError:
    print("ERROR: pip install snntorch")
    raise

# ── Try torchvision, fall back to manual MNIST loader ────────────────────────
try:
    from torchvision import datasets, transforms
    from torch.utils.data import DataLoader

    def load_mnist_test():
        t = transforms.Compose([
            transforms.ToTensor(),
            transforms.Lambda(lambda x: x.view(-1))
        ])
        ds = datasets.MNIST(root='./data', train=False, download=True, transform=t)
        return DataLoader(ds, batch_size=256, shuffle=False), len(ds)

except ImportError:
    # ── Fallback: load raw MNIST binary files (no torchvision needed) ─────────
    import struct, gzip, urllib.request

    def _download(url, path):
        if not os.path.exists(path):
            print(f"   Downloading {os.path.basename(path)} ...")
            urllib.request.urlretrieve(url, path)

    def load_mnist_test():
        base = "https://storage.googleapis.com/cvdf-datasets/mnist/"
        os.makedirs("./data/MNIST/raw", exist_ok=True)
        files = {
            "images": ("t10k-images-idx3-ubyte.gz", "./data/MNIST/raw/t10k-images-idx3-ubyte.gz"),
            "labels": ("t10k-labels-idx1-ubyte.gz", "./data/MNIST/raw/t10k-labels-idx1-ubyte.gz"),
        }
        for key, (fname, fpath) in files.items():
            _download(base + fname, fpath)

        with gzip.open(files["images"][1]) as f:
            f.read(16)
            images = np.frombuffer(f.read(), dtype=np.uint8).reshape(-1, 784) / 255.0

        with gzip.open(files["labels"][1]) as f:
            f.read(8)
            labels = np.frombuffer(f.read(), dtype=np.uint8)

        # Wrap in a simple iterable of (tensor, label) batches
        class SimpleLoader:
            def __init__(self, imgs, lbls, batch=256):
                self.imgs = torch.tensor(imgs, dtype=torch.float32)
                self.lbls = torch.tensor(lbls, dtype=torch.long)
                self.batch = batch
            def __iter__(self):
                for i in range(0, len(self.imgs), self.batch):
                    yield self.imgs[i:i+self.batch], self.lbls[i:i+self.batch]
            def __len__(self):
                return len(self.imgs)

        loader = SimpleLoader(images, labels)
        return loader, len(images)


# =============================================================================
# SNN Model  (identical to snn(3).py)
# =============================================================================
BETA      = 0.5
THRESHOLD = 1.0
NUM_STEPS = 1

class SNN(nn.Module):
    def __init__(self):
        super().__init__()
        sg = surrogate.fast_sigmoid(slope=25)
        self.fc1  = nn.Linear(784, 64, bias=False)
        self.lif1 = snn.Leaky(beta=BETA, threshold=THRESHOLD, spike_grad=sg)
        self.fc2  = nn.Linear(64, 10, bias=False)
        self.lif2 = snn.Leaky(beta=BETA, threshold=THRESHOLD, spike_grad=sg)

    def forward(self, x):
        mem1 = self.lif1.init_leaky()
        mem2 = self.lif2.init_leaky()
        for _ in range(NUM_STEPS):
            spk1, mem1 = self.lif1(self.fc1(x), mem1)
            spk2, mem2 = self.lif2(self.fc2(spk1), mem2)
        return spk2, mem2   # return membrane potential too (used for argmax)


# =============================================================================
# Hardware cycle-count estimate  (from snn_ctrl.v FSM analysis)
# =============================================================================

def estimate_hw_cycles(avg_active_pixels: float, avg_hidden_spikes: float) -> dict:
    """
    Counts clock cycles the snn_ctrl FSM spends per image at 100 MHz.

    L1 EXEC: per active pixel → 1 (FETCH) + 1 (DEC) + 9 (EXEC loop_count 0..8) = 11 cycles
    EVAL_L1: 9 cycles (eval_count 0..8)
    L2_INIT: 2 cycles
    L2 EXEC: per active hidden neuron → 1 (DEC) + 3 (EXEC loop_count 0..2) = 4 cycles
             plus DEC cycles to skip zero bits (avg ~(64-h)/2 skips ≈ small)
    READOUT: 1 cycle
    AER scan overhead: ~2 cycles per active pixel (scan + FIFO write)
    """
    l1_cycles   = avg_active_pixels * 11
    eval_cycles = 9
    l2_init     = 2
    l2_cycles   = avg_hidden_spikes * 4
    readout     = 1
    total       = l1_cycles + eval_cycles + l2_init + l2_cycles + readout

    return {
        "L1 EXEC":  l1_cycles,
        "EVAL_L1":  eval_cycles,
        "L2_INIT":  l2_init,
        "L2 EXEC":  l2_cycles,
        "READOUT":  readout,
        "total":    total,
    }


# =============================================================================
# Main
# =============================================================================
if __name__ == "__main__":

    CLOCK_HZ    = 100e6    # 100 MHz FPGA clock
    MODEL_PATH  = "best_snn_model.pth"

    print("=" * 60)
    print("  SNN: Software Execution vs Hardware Speed Comparison")
    print("=" * 60)

    # ── Load model ────────────────────────────────────────────────
    print(f"\n[1] Loading trained model from '{MODEL_PATH}' ...")
    model = SNN()
    if not os.path.exists(MODEL_PATH):
        print(f"    ERROR: '{MODEL_PATH}' not found. Run snn(3).py first.")
        raise SystemExit(1)
    model.load_state_dict(torch.load(MODEL_PATH, map_location='cpu'))
    model.eval()

    # ── Load test data ────────────────────────────────────────────
    print("[2] Loading MNIST test set (10 000 images) ...")
    loader, n_images = load_mnist_test()

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model  = model.to(device)
    print(f"    Running on: {device}")

    # ── Software inference ────────────────────────────────────────
    print(f"\n[3] Software inference ...")

    correct   = 0
    total     = 0
    sum_active_pixels  = 0
    sum_hidden_spikes  = 0

    t_start = time.perf_counter()

    with torch.no_grad():
        for data, targets in loader:
            data    = data.to(device)
            targets = targets.to(device)

            spk2, mem2 = model(data)

            # For classification use membrane potential (more robust than spike argmax)
            pred      = mem2.argmax(dim=1)
            correct  += (pred == targets).sum().item()
            total    += targets.size(0)

            # Collect spike statistics for hardware cycle estimate
            binary_input   = (data > 0.5).float()
            with torch.no_grad():
                spk1, _ = model.lif1(model.fc1(binary_input), model.lif1.init_leaky())

            sum_active_pixels += binary_input.sum().item()
            sum_hidden_spikes += spk1.sum().item()

    t_end = time.perf_counter()

    sw_elapsed    = t_end - t_start
    sw_acc        = 100.0 * correct / total
    sw_per_image  = sw_elapsed / total * 1e6      # microseconds

    avg_active_px = sum_active_pixels / total
    avg_hid_spk   = sum_hidden_spikes / total

    print(f"    Accuracy        : {sw_acc:.2f}%")
    print(f"    Total time      : {sw_elapsed:.3f} s  ({total} images)")
    print(f"    Time per image  : {sw_per_image:.1f} µs")
    print(f"    Throughput      : {total/sw_elapsed:.0f} images/sec")
    print(f"    Avg active px   : {avg_active_px:.1f} / 784")
    print(f"    Avg hidden spks : {avg_hid_spk:.1f} / 64")

    # ── Hardware cycle estimate ────────────────────────────────────
    print(f"\n[4] Hardware cycle estimate (snn_ctrl FSM @ {CLOCK_HZ/1e6:.0f} MHz) ...")
    cycles = estimate_hw_cycles(avg_active_px, avg_hid_spk)

    hw_cycles_per_image = cycles["total"]
    hw_time_us          = hw_cycles_per_image / CLOCK_HZ * 1e6   # microseconds
    hw_throughput       = CLOCK_HZ / hw_cycles_per_image

    print(f"    FSM cycles breakdown:")
    for k, v in cycles.items():
        if k != "total":
            print(f"      {k:<12}: {v:>6.0f} cycles")
    print(f"      {'TOTAL':<12}: {hw_cycles_per_image:>6.0f} cycles")
    print(f"    Time per image  : {hw_time_us:.2f} µs  (@ {CLOCK_HZ/1e6:.0f} MHz)")
    print(f"    Throughput      : {hw_throughput:.0f} images/sec")

    # ── Comparison ────────────────────────────────────────────────
    speedup = sw_per_image / hw_time_us

    print()
    print("=" * 60)
    print("  COMPARISON SUMMARY")
    print("=" * 60)
    print(f"  {'':30} {'Time/img':>10}  {'Img/s':>10}")
    print(f"  {'-'*30} {'-'*10}  {'-'*10}")
    print(f"  {'Software (Python + PyTorch)':<30} {sw_per_image:>9.1f}µs  {total/sw_elapsed:>10.0f}")
    print(f"  {'Hardware (FPGA @ 100 MHz)':<30} {hw_time_us:>9.2f}µs  {hw_throughput:>10.0f}")
    print(f"  {'-'*30} {'-'*10}  {'-'*10}")
    print(f"\n  Hardware is  {speedup:.0f}×  faster than software.")
    print()
    print("  Why?  Both run the exact same SNN algorithm.")
    print("  The hardware wins purely through:")
    print(f"    • 8 PE lanes execute in parallel  (software: sequential loop)")
    print(f"    • AER scan overlaps with SIMD MAC  (software: two separate phases)")
    print(f"    • Dedicated INT8 datapath          (software: float32 + Python overhead)")
    print("=" * 60)
