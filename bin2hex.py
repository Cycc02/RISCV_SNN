"""Convert a raw binary file to Verilog $readmemh hex format.
Usage: python bin2hex.py input.bin output.hex
Reads 32-bit little-endian words and writes them as big-endian hex values
(the format that matches how $readmemh loads into reg [31:0] memory arrays).
"""
import sys, struct

def bin_to_hex(bin_file, hex_file):
    with open(bin_file, "rb") as f:
        data = f.read()
    while len(data) % 4:
        data += b"\x00"
    with open(hex_file, "w", newline="\n") as f:
        f.write("@00000000\n")
        row = []
        for i in range(0, len(data), 4):
            word = struct.unpack_from("<I", data, i)[0]
            row.append("%08X" % word)
            if len(row) == 4:
                f.write(" ".join(row) + "\n")
                row = []
        if row:
            f.write(" ".join(row) + "\n")
    print("[OK] %s written (%d lines)" % (hex_file, len(open(hex_file).readlines())))

bin_to_hex(sys.argv[1], sys.argv[2])
