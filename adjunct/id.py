#!/usr/bin/python
from glob import glob as glob
import sys

# May 2026

# Hackerb9 believes PEEK(1) is good for generally identifying the
# different Model-T models, but inadequate for international use.
# Using the romcmp.py program, it seems that one can distinguish
# models better using two peeks: PEEK(21333) and PEEK(31444).

# This program simply reads bytes 1, 21333, and 31444 from each ROM
# file and prints them.

if len(sys.argv) == 1:
    romfiles = glob("ROMs/*.bin")
else:
    romfiles = sys.argv[1:]

results=[]
for f in romfiles:
    data=open(f, "rb").read()
    if len(data)<32767: continue
    results.append(f"{data[1]:5d}{data[21333]:8d}{data[31444]:8d}\t    {f}")

print("PEEK(1)\t(21333)\t(31444)\t    ROM FILE")
print('\n'.join(sorted(results)))


# PEEK(1)(21333)(31444)	    ROM FILE			VARIANTS ALLOWED
#    35     213      33	    Olivetti_M10_Eur		y2k
#    51       2      82	    TRS-80_Model_100 		y2k, REX+y2k
#    51     202      82	    TRS-80_Model_100+LibROM-1.1a
#   125      83     124	    Olivetti_M10_North_America	y2k
#   148      83      37	    NEC_PC-8300			y2k, y2k_VirT
#   148     244      37	    NEC_PC-8201A		y2k, REX_y2k, y2k_VirT
#   148     244     126	    NEC_PC-8201+Japan

#   167       2     127	    Tandy_102_us		y2k, REX_y2k
#   167       2     127	    TRS-80_Model_100_uk+y2k.bin
#   167       2     127	    TRS-80_Model_100_us+26-3802B.bin

#   167     105     127	    Tandy_102_uk		y2k
#   167     254     127	    Televerket_Modell_100+orig.bin
#   171     205     244	    Tandy_200			y2k, REX, REX_y2k
#   195     102      73	    Tandy_200_Multiplan

#   225      26     255	    Kyocera_Kyotronic_85	y2kk
#   225      26     255	    TRS-80_Model_100_uk+skl.bin
