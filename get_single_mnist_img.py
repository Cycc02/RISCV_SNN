import numpy as np
import matplotlib.pyplot as plt
from keras.datasets import mnist

# 1. Load the official MNIST dataset
(_, _), (x_test, y_test) = mnist.load_data()

# =======================================================
# CHANGE THIS NUMBER to test different images (0 to 9999)
IMAGE_INDEX = 6767
# =======================================================

# Extract the specific image and its true label
img_array = x_test[IMAGE_INDEX]
true_label = y_test[IMAGE_INDEX]

# 2. Display the image on your screen using Matplotlib
plt.imshow(img_array, cmap='gray')
plt.title(f"MNIST Test Index: {IMAGE_INDEX} | True Label: {true_label}")
plt.axis('off')

# 3. Binarize the image for your SNN (0s and 1s)
# Your SNN takes a 1 for a spike, 0 for no spike.
binary_2d = np.where(img_array > 127, 1, 0)

# 4. Flatten to a 784-bit vector
flat_vector = binary_2d.flatten()

# Reverse the string so pixel 0 is LSB [0], matching standard Verilog vector mapping
sv_string = "".join(map(str, flat_vector))[::-1]

# 5. Print the Verilog Code to the console
print("==========================================================")
print(f"  IMAGE DETAILS")
print(f"  Index: {IMAGE_INDEX}")
print(f"  True Label: {true_label}")
print(f"  Active Pixels (Spikes): {np.sum(binary_2d)}")
print("==========================================================")
print("\nCopy and paste this directly into your snn_top_tb.sv:\n")

print(f"// MNIST Test Image {IMAGE_INDEX} (Label: {true_label})")
print(f"localparam bit [783:0] MNIST_IMG_{IMAGE_INDEX} = 784'b{sv_string};")
print("==========================================================")

# Show the plot window (Execution will pause until you close the image window)
plt.show()