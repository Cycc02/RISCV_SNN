import csv, sys

path = sys.argv[1] if len(sys.argv) > 1 else "ila_uart_chars.csv"
with open(path, newline="") as f:
    rows = list(csv.reader(f))

hdr = rows[0]
col = next(i for i, h in enumerate(hdr) if "dbg_uart_char" in h)
# row 1 is the radix row in Vivado ILA CSVs; data starts after it
out = []
for r in rows[1:]:
    v = r[col].strip()
    if not v or not all(c in "0123456789abcdefABCDEF" for c in v):
        continue
    out.append(chr(int(v, 16) & 0xFF))
sys.stdout.write("".join(out))
