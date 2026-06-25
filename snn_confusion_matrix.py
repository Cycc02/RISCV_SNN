#!/usr/bin/env python3
"""
snn_confusion_matrix.py

Loads the trained SNN model, runs inference on the MNIST test set,
and plots a confusion matrix showing which digits get misclassified.
"""

import torch
import torch.nn as nn
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import os

try:
    import snntorch as snn
    from snntorch import surrogate
except ImportError:
    print("ERROR: pip install snntorch")
    raise

try:
    from torchvision import datasets, transforms
    from torch.utils.data import DataLoader

    def load_mnist_test():
        t = transforms.Compose([
            transforms.ToTensor(),
            transforms.Lambda(lambda x: x.view(-1))
        ])
        ds = datasets.MNIST(root='./data', train=False, download=True, transform=t)
        return DataLoader(ds, batch_size=256, shuffle=False)

except ImportError:
    import gzip, urllib.request

    def load_mnist_test():
        base = "https://storage.googleapis.com/cvdf-datasets/mnist/"
        os.makedirs("./data/MNIST/raw", exist_ok=True)
        files = {
            "images": ("t10k-images-idx3-ubyte.gz", "./data/MNIST/raw/t10k-images-idx3-ubyte.gz"),
            "labels": ("t10k-labels-idx1-ubyte.gz", "./data/MNIST/raw/t10k-labels-idx1-ubyte.gz"),
        }
        for _, (fname, fpath) in files.items():
            if not os.path.exists(fpath):
                print(f"   Downloading {fname} ...")
                urllib.request.urlretrieve(base + fname, fpath)

        with gzip.open(files["images"][1]) as f:
            f.read(16)
            images = np.frombuffer(f.read(), dtype=np.uint8).reshape(-1, 784) / 255.0
        with gzip.open(files["labels"][1]) as f:
            f.read(8)
            labels = np.frombuffer(f.read(), dtype=np.uint8)

        class SimpleLoader:
            def __init__(self, imgs, lbls, batch=256):
                self.imgs = torch.tensor(imgs, dtype=torch.float32)
                self.lbls = torch.tensor(lbls, dtype=torch.long)
                self.batch = batch
            def __iter__(self):
                for i in range(0, len(self.imgs), self.batch):
                    yield self.imgs[i:i+self.batch], self.lbls[i:i+self.batch]

        return SimpleLoader(images, labels)


# =============================================================================
# Model  (identical to snn(3).py)
# =============================================================================
class SNN(nn.Module):
    def __init__(self):
        super().__init__()
        sg = surrogate.fast_sigmoid(slope=25)
        self.fc1  = nn.Linear(784, 64, bias=False)
        self.lif1 = snn.Leaky(beta=0.5, threshold=1.0, spike_grad=sg)
        self.fc2  = nn.Linear(64, 10, bias=False)
        self.lif2 = snn.Leaky(beta=0.5, threshold=1.0, spike_grad=sg)

    def forward(self, x):
        mem1 = self.lif1.init_leaky()
        mem2 = self.lif2.init_leaky()
        spk1, mem1 = self.lif1(self.fc1(x), mem1)
        spk2, mem2 = self.lif2(self.fc2(spk1), mem2)
        return mem2   # membrane potential → more reliable than spike argmax


# =============================================================================
# Main
# =============================================================================
MODEL_PATH = "best_snn_model.pth"
NUM_CLASSES = 10
DIGIT_NAMES = [str(i) for i in range(NUM_CLASSES)]

print("Loading model ...")
model = SNN()
if not os.path.exists(MODEL_PATH):
    print(f"ERROR: '{MODEL_PATH}' not found. Run snn(3).py first.")
    raise SystemExit(1)
model.load_state_dict(torch.load(MODEL_PATH, map_location='cpu'))
model.eval()

print("Running inference on MNIST test set ...")
loader = load_mnist_test()

all_preds  = []
all_labels = []

with torch.no_grad():
    for data, targets in loader:
        output = model(data)
        preds  = output.argmax(dim=1)
        all_preds.append(preds.cpu().numpy())
        all_labels.append(targets.cpu().numpy())

all_preds  = np.concatenate(all_preds)
all_labels = np.concatenate(all_labels)

accuracy = 100.0 * np.mean(all_preds == all_labels)
print(f"Overall accuracy: {accuracy:.2f}%")

# =============================================================================
# Build confusion matrix
# =============================================================================
cm = np.zeros((NUM_CLASSES, NUM_CLASSES), dtype=np.int32)
for true, pred in zip(all_labels, all_preds):
    cm[true, pred] += 1

# Per-class accuracy
class_acc = cm.diagonal() / cm.sum(axis=1) * 100

print("\nPer-class accuracy:")
for i in range(NUM_CLASSES):
    print(f"  Digit {i}: {class_acc[i]:.1f}%  ({cm[i,i]}/{cm[i].sum()} correct)")

# Worst misclassifications (off-diagonal, top 5)
off_diag = cm.copy()
np.fill_diagonal(off_diag, 0)
flat_idx = np.argsort(off_diag.ravel())[::-1][:5]
print("\nTop 5 misclassifications:")
for idx in flat_idx:
    true_c = idx // NUM_CLASSES
    pred_c = idx  % NUM_CLASSES
    print(f"  Digit {true_c} predicted as {pred_c}: {off_diag[true_c, pred_c]} times")

# =============================================================================
# Plot
# =============================================================================
fig, axes = plt.subplots(1, 2, figsize=(16, 6))
fig.suptitle(f"SNN MNIST Confusion Matrix  —  Accuracy: {accuracy:.2f}%", fontsize=14, fontweight='bold')

# ── Left: raw counts ──────────────────────────────────────────────────────────
ax = axes[0]
im = ax.imshow(cm, interpolation='nearest', cmap='Blues')
plt.colorbar(im, ax=ax, fraction=0.046)
ax.set_title("Raw Counts", fontsize=12)
ax.set_xlabel("Predicted Label", fontsize=11)
ax.set_ylabel("True Label", fontsize=11)
ax.set_xticks(range(NUM_CLASSES))
ax.set_yticks(range(NUM_CLASSES))
ax.set_xticklabels(DIGIT_NAMES)
ax.set_yticklabels(DIGIT_NAMES)

thresh = cm.max() / 2
for i in range(NUM_CLASSES):
    for j in range(NUM_CLASSES):
        color = "white" if cm[i, j] > thresh else "black"
        weight = "bold" if i == j else "normal"
        ax.text(j, i, str(cm[i, j]), ha='center', va='center',
                color=color, fontsize=8, fontweight=weight)

# ── Right: row-normalised (% of each true class) ──────────────────────────────
ax2 = axes[1]
cm_norm = cm.astype(float) / cm.sum(axis=1, keepdims=True) * 100
im2 = ax2.imshow(cm_norm, interpolation='nearest', cmap='Blues', vmin=0, vmax=100)
cbar = plt.colorbar(im2, ax=ax2, fraction=0.046)
cbar.set_label("% of true class", fontsize=10)
ax2.set_title("Normalised (% per true class)", fontsize=12)
ax2.set_xlabel("Predicted Label", fontsize=11)
ax2.set_ylabel("True Label", fontsize=11)
ax2.set_xticks(range(NUM_CLASSES))
ax2.set_yticks(range(NUM_CLASSES))
ax2.set_xticklabels(DIGIT_NAMES)
ax2.set_yticklabels(DIGIT_NAMES)

thresh_n = 50.0
for i in range(NUM_CLASSES):
    for j in range(NUM_CLASSES):
        color = "white" if cm_norm[i, j] > thresh_n else "black"
        weight = "bold" if i == j else "normal"
        ax2.text(j, i, f"{cm_norm[i,j]:.1f}", ha='center', va='center',
                 color=color, fontsize=7, fontweight=weight)

plt.tight_layout()
out_path = "snn_confusion_matrix.png"
plt.savefig(out_path, dpi=150, bbox_inches='tight')
print(f"\nSaved: {out_path}")
plt.show()
