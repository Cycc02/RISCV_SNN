#!/usr/bin/env python3
"""
snn_software_inference.py

Pure software SNN execution. 
Runs a trained Spiking Neural Network (SNN) model on MNIST test images 
and measures accuracy, execution time, and throughput.
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
# SNN Model 
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
        return spk2, mem2   


# =============================================================================
# Main Software Inference
# =============================================================================
if __name__ == "__main__":

    MODEL_PATH  = "best_snn_model.pth"

    print("=" * 60)
    print("  SNN: Pure Software Inference Profiling")
    print("=" * 60)

    # ── Load model ────────────────────────────────────────────────
    print(f"\n[1] Loading trained model from '{MODEL_PATH}' ...")
    model = SNN()
    if not os.path.exists(MODEL_PATH):
        print(f"    ERROR: '{MODEL_PATH}' not found. Please ensure the model is trained and saved.")
        raise SystemExit(1)
    
    model.load_state_dict(torch.load(MODEL_PATH, map_location='cpu'))
    model.eval()

    # ── Load test data ────────────────────────────────────────────
    print("[2] Loading MNIST test set (10,000 images) ...")
    loader, n_images = load_mnist_test()

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model  = model.to(device)
    print(f"    Running on: {device}")

    # ── Software inference ────────────────────────────────────────
    print(f"\n[3] Executing Software Inference ...")

    correct = 0
    total   = 0

    # Start timer
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

    # End timer
    t_end = time.perf_counter()

    sw_elapsed    = t_end - t_start
    sw_acc        = 100.0 * correct / total
    sw_per_image  = sw_elapsed / total * 1e6      # microseconds
    sw_throughput = total / sw_elapsed

    print("\n" + "=" * 60)
    print("  SOFTWARE INFERENCE RESULTS")
    print("=" * 60)
    print(f"    Accuracy        : {sw_acc:.2f}%")
    print(f"    Total test imgs : {total}")
    print(f"    Total run time  : {sw_elapsed:.3f} seconds")
    print(f"    Time per image  : {sw_per_image:.1f} µs")
    print(f"    Throughput      : {sw_throughput:.0f} images/sec")
    print("=" * 60)