#!/usr/bin/python
from glob import glob as glob

# February 2026
# Hackerb9 believes PEEK(1) and PEEK(21358) are best for uniquely
# identifying the different ROMs of the Kyotronic Sisters.

# This program simply reads byte 1 and 21358 of each ROM file and prints them.
romfiles = glob("*.bin")

results=[]
for f in romfiles:
    data=open(f, "rb").read()
    if len(data)<32767: continue
    results.append(f"{data[1]:5d}{data[21358]:8d}     {f}")

print("PEEK(1)\t(21358)   ROM FILE")
print('\n'.join(sorted(results)))

# PEEK(1) lumps together T102 regardless of country (US, UK, and Norway);
#	  also lumps together PC8201A and PC8300.
# PEEK(21358) lumps together US M100 and US T102, but not UK or NO.
#
# Both correctly lump together the y2k variation with the original ROM.

# PEEK(1) (21358)   ROM FILE
#    35      35     M10_System_ROM_EU.orig.bin
#    35      35     M10_System_ROM_EU.y2k.bin
#    51      83     TRS-80_Model_100.orig.bin
#    51      83     TRS-80_Model_100.y2k.bin
#    72     209     NEC_PC-8300_Beckman-E3.2.bin
#   125     205     M10_System_ROM_NorthAmerica.orig.bin
#   125     205     M10_System_ROM_NorthAmerica.y2k.bin
#   144     254     TANDY_600_BASIC.bin
#   148     101     NEC_PC-8201A.orig.bin
#   148     101     NEC_PC-8201A.y2k.bin
#   148     235     NEC_PC-8300.orig.bin
#   148     235     NEC_PC-8300.y2k.bin
#   167      83     TANDY_Model_102.us.orig.bin
#   167      83     TANDY_Model_102.us.y2k.bin
#   167      96     TANDY_Model_102.uk.orig.bin
#   167      96     TANDY_Model_102.uk.y2k.bin
#   167     123     Televerket-Modell100.orig.bin
#   171       9     TANDY_Model_200.M15.orig.bin
#   171       9     TANDY_Model_200.M15.y2k.bin
#   225     194     KC-85.orig.bin
#   225     194     KC-85.y2k.bin
