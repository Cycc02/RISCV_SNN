import matplotlib.pyplot as plt

# 1. Grab one batch of test data
data, targets = next(iter(test_loader))

# 2. Pick the very first image in the batch
img = data[0]
label = targets[0].item()

# 3. Binarize it (Input pixels > 0.5 become 1)
img_bin = (img > 0.5).int().view(-1).numpy()

# 4. Convert it into a 784-bit Verilog string 
# (Reversed so Pixel 0 is on the far right, matching Verilog vectors)
verilog_bits = "".join(str(b) for b in reversed(img_bin))

print(f"\n// Actual Handwritten Digit: {label}")
print(f"tx.img_pxl = 784'b{verilog_bits};")