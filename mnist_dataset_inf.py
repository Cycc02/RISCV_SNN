import numpy as np
from keras.datasets import mnist
import os

# 1. Load the official MNIST dataset
(_, _), (x_test, y_test) = mnist.load_data()

NUM_SAMPLES = 9999

print(f"Exporting {NUM_SAMPLES} MNIST images for Verilog simulation...")

# Open two text files for writing
with open("mnist_stimulus.mem", "w") as f_img, open("mnist_labels.mem", "w") as f_lbl:
    for i in range(NUM_SAMPLES):
        img_array = x_test[i]
        true_label = y_test[i]
        
        # Binarize (0 or 1)
        binary_2d = np.where(img_array > 127, 1, 0)
        
        # Flatten and reverse (so pixel 0 is LSB, matching your AER scanner)
        flat_vector = binary_2d.flatten()
        sv_string = "".join(map(str, flat_vector))[::-1]
        
        # Write the 784-bit binary string to the stimulus file
        f_img.write(f"{sv_string}\n")
        
        # Write the decimal true label to the label file
        f_lbl.write(f"{true_label:X}\n")

print("Success!")
print("Created: mnist_stimulus.mem (784-bit binary images)")
print("Created: mnist_labels.mem   (Decimal true labels)")