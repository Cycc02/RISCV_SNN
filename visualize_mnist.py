"""
Visualize the single MNIST test image currently being fed to the SNN.

Mirrors gen_mnist_header.py exactly (same cache, same index, same
binarization) so what you see is precisely what the hardware classifies.

Usage:
    python visualize_mnist.py [IMAGE_INDEX]

Default index: 6767 (matches gen_mnist_header.py).

Outputs:
    - ASCII art of the binarized 28x28 image to the terminal (always)
    - mnist_preview.png  (grayscale + binarized side by side) if matplotlib
      is available; skipped silently otherwise.
"""
import gzip
import os
import sys
import urllib.request

IMAGE_INDEX = int(sys.argv[1]) if len(sys.argv) > 1 else 6767

CACHE_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "mnist_cache")
os.makedirs(CACHE_DIR, exist_ok=True)

URLS = {
    "images": "https://ossci-datasets.s3.amazonaws.com/mnist/t10k-images-idx3-ubyte.gz",
    "labels": "https://ossci-datasets.s3.amazonaws.com/mnist/t10k-labels-idx1-ubyte.gz",
}

def fetch(name, url):
    path = os.path.join(CACHE_DIR, os.path.basename(url))
    if not os.path.exists(path):
        print(f"Downloading {name} -> {path}")
        urllib.request.urlretrieve(url, path)
    return path

img_path = fetch("images", URLS["images"])
lbl_path = fetch("labels", URLS["labels"])

with gzip.open(img_path, "rb") as f:
    f.read(16)
    img_data = f.read()
with gzip.open(lbl_path, "rb") as f:
    f.read(8)
    lbl_data = f.read()

base       = IMAGE_INDEX * 784
img_bytes  = img_data[base:base + 784]
true_label = lbl_data[IMAGE_INDEX]

# 28x28 grayscale rows and binarized rows (pixel > 127 -> spike).
img_array = [list(img_bytes[r * 28:(r + 1) * 28]) for r in range(28)]
binary_2d = [[1 if px > 127 else 0 for px in row] for row in img_array]
active    = sum(sum(row) for row in binary_2d)

# ---------------------------------------------------------------------------
# ASCII art of the binarized image (what the SNN actually receives)
# ---------------------------------------------------------------------------
print()
print(f"MNIST test index {IMAGE_INDEX}  |  true label = {true_label}  |  "
      f"{active}/784 active pixels ({100*active/784:.1f}% dense)")
print("Binarized 28x28 input fed to the SNN (# = spike):")
print("+" + "-" * 56 + "+")
for row in binary_2d:
    line = "".join("##" if px else "  " for px in row)
    print("|" + line + "|")
print("+" + "-" * 56 + "+")

# ---------------------------------------------------------------------------
# Optional PNG for slides: original grayscale + binarized side by side
# ---------------------------------------------------------------------------
try:
    import matplotlib
    matplotlib.use("Agg")  # headless-safe
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(1, 2, figsize=(7, 3.6))
    ax[0].imshow(img_array, cmap="gray")
    ax[0].set_title(f"Original grayscale\n(MNIST[{IMAGE_INDEX}], label {true_label})")
    ax[0].axis("off")
    ax[1].imshow(binary_2d, cmap="gray")
    ax[1].set_title(f"Binarized SNN input\n{active} active pixels")
    ax[1].axis("off")
    fig.tight_layout()
    out_png = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                           "mnist_preview.png")
    fig.savefig(out_png, dpi=120)
    print(f"Saved preview image -> {out_png}")
except ImportError:
    print("(matplotlib not installed - skipping PNG; ASCII art above is the input.)")
