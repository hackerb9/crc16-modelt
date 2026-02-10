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
# identify every Kyotronic Sister. The answer is no.
# Two PEEKs are needed. b9 suggests PEEK(1) and PEEK(21358). 

from glob import glob as glob

rom = {}

files = sorted(glob("ROMs/*orig.bin"))
for f in files:
    name=f[:f.find(".bin")]
    rom[name] = open(f, "rb").read(32768)
    if len(rom[name])<32768: del rom[name]

for i in range(0, 32768):
    seen = set()
    for name in rom:
        seen.add(rom[name][i])
    if len(seen) >= 9: # and rom['pc8201'][i] != rom['pc8300'][i]:
        print (f"Address: {i}\t ({i:x})")
        for name in rom:
            print(f'\t{rom[name][i]:3d}\t{name}')
        
# PEEK(1) distinguishes all but PC8201 and PC8300
# PEEK(21358) distinguishes all but M100 and M102

# Address: 21358   (536e)
#            194   KC-85.orig
#             35   M10_System_ROM_EU.orig
#            205   M10_System_ROM_NorthAmerica.orig
#            101   NEC_PC-8201A.orig
#            235   NEC_PC-8300.orig
#             96   TANDY_Model_102.uk.orig
#             83   TANDY_Model_102.us.orig
#              9   TANDY_Model_200.M15.orig
#             83   TRS-80_Model_100.orig
#            123   Televerket-Modell100.orig

