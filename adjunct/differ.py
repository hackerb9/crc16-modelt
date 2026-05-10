#!/usr/bin/python


from glob import glob as glob
import sys

rom = {}

if len(sys.argv) == 1:
    files = glob("ROMs/*orig.bin")
else:
    files = sys.argv[1:]

if len(files) == 0: raise ValueError("Could not open ROMs")
files = sorted(files)

for f in files:
    name=f[:f.find(".bin")]
    rom[name] = open(f, "rb").read(32768)
    if len(rom[name])<32768: del rom[name]

# Count unique values for PEEK(i) for each ROM. 
seen = {}
for i in range(0, 32768):
    seen[i] = set()
    for name in rom:
        value = rom[name][i]
        seen[i].add( value )
        
same = []
diff = []


for i in range(0, 32768):
    if len( seen[i] ) == 1:
        same.append(i)
    elif len( seen[i] ) == len(rom):
        diff.append(i)
        
print(f"Same: {len(same)} bytes")
print(f"Diff: {len(diff)} bytes")
for i in diff: print(i)

# start=diff[0]
# p=start
# for i in diff[1:] + [-1]:
#    if i != p+1:
#        output=f'{start:04X}'
#        if start != p:
#            numbats=f'({p-start+1} bytes)'
#            output=output+f'..{p:04X} {numbats:>12s}'
#        print(f'\t{output}')
#        start=i
#        p=start
#    p=i
