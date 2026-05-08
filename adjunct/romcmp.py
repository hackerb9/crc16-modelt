#!/usr/bin/python

# It is well known that PEEK(1) can distinguish between the Model T's,
# but it confuses PC8201 and 8300.
# Address: 1
#          pc8201 148
#          pc8300 148
#          kc85 225
#          m10 35
#          m100 51
#          m102 167
#          t200 171
#
# b9 wonders if there is any single byte address that would uniquely
# identify every Kyotronic Sister. The answer is No, and especially NO
# if international ROMs need to be distinguished from US.

# 1. PEEK(1) may not be complete, but it is still useful and I
#    (hackerb9) recommend it for general use. 

# 2. A second PEEK can distinguish the Tandy 102 US from UK and NO.
#    Only a handful of addresses work: 21333, 21356, 21357, & 21358.
#    I use PEEK(21358). It also separates 8201 from 8300.
#    PEEK(1) (21358) [ == 536Eh ]
#        167     96  Tandy_102_uk+orig
#        167     83  Tandy_102_us+orig
#        167    123  Televerket_Modell_100+orig
#        148    101  NEC_PC-8201+A_orig
#        148    101  NEC_PC-8201+Japan_orig
#        148    235  NEC_PC-8300+orig
     
# 3. A third PEEK can distinguish between the NEC PC-8201 and PC-8201A.
#    Many addresses would work. 31456 is an easy one to remember.
#    PEEK(1) (21358) (31456)                
#       148     101     124          PC-8201 
#       148     101      32          PC-8201A
#       148     235      32          PC-8300 

# Note that, as of May 2026,  PEEK(1) is redundant if one is using the latter two peeks
# in

from glob import glob as glob
import sys

# Addresses which are already being used to disambiguate. Can be empty.
# already_given = [ 1 ]
#already_given = [ 21358 ]
already_given = [ 21333 ]

rom = {}

if len(sys.argv) == 1:
    files = glob("ROMs/*orig.bin")
else:
    files = sys.argv[1:]
files = sorted(files)

for f in files:
    name=f[:f.find(".bin")]
    rom[name] = open(f, "rb").read(32768)
    if len(rom[name])<32768: del rom[name]

seen = {}
for i in range(0, 32768):
    seen[i] = set()
    for name in rom:
        # Count unique values for PEEK(i) for each ROM. 
        value = rom[name][i]
        for x in already_given: 	# Presume PEEK(x) is also being used
            value = value<<8 + rom[name][x]
        seen[i].add( value )
       
best = max([ len(seen[s]) for s in seen ])
print( f'At best can distinguish {best} of the {len(rom)} ROMs' )
if best <= 1: raise ValueError
 
for i in range(32768):
    if len(seen[i]) >= best:

#        if rom['NEC_PC-8201+A_orig'][i] == rom['NEC_PC-8201+Japan_orig'][i]: continue
#        if rom['Tandy_102_uk+orig'][i] == rom['Tandy_102_us+orig'][i]: continue

        print  ("PEEK", end="")
        for x in already_given:
            print (f"{'('+str(x)+')':<8s}", end="")
        print (f"{'('+str(i)+')':<8s}", end="")
        print (f"\t[ {i} == {i:04X}h ]")
        for name in rom:
            for x in already_given:
                print (f"{rom[name][x]:8d}", end="")
            print(f'{rom[name][i]:8d}\t{name}')

