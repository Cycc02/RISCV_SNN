import struct, sys

with open(sys.argv[1], 'rb') as f:
    data = f.read()

print('@00000000')
words = []
for i in range(0, len(data), 4):
    chunk = data[i:i+4].ljust(4, b'\x00')
    words.append(f'{struct.unpack("<I", chunk)[0]:08x}')

for i in range(0, len(words), 4):
    print(' '.join(words[i:i+4]))
