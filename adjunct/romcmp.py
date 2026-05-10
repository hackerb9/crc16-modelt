#!/usr/bin/python

# It is well known that PEEK(1) can distinguish between the Model T's.
# However, it cannot tell nationalized models apart. (Tandy 102
# US/UK/NO; NEC PC-8201/PC-8201A/PC-8300).
#
# Is there any single byte address that would uniquely identify every
# Kyotronic Sister? This program shows the answer is "No".

# At least two peeks are needed to fully distinguish the ROMs hackerb9
# has collected. PEEK(21333) and PEEK(31444) work. See notes below.

from glob import glob as glob
import sys

# Addresses which are already being used to disambiguate. Can be empty.
#already_given = [1]
#already_given = [ 21358, 31439 ]
already_given = [ 31444 ]

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
        print (f"{'('+str(i)+')':<8s}")
        for name in rom:
            for x in already_given:
                print (f"{rom[name][x]:8d}", end="")
            print(f'{rom[name][i]:8d}\t{name}')



# 1. PEEK(1) is still quite useful for the most common Model-T
#    computers and is still recommended.

#    PEEK(1) 
#         35      Olivetti_M10_Eur
#         51      TRS-80_Model_100
#        125      Olivetti_M10_North_America
#        148      NEC_PC-8201 (Japan) / NEC_PC-8201A / NEC_PC-8300
#        167      Tandy_102_us / Tandy_102_uk / Televerket_Modell_100
#        171      Tandy_200_us
#        225      Kyocera_Kyotronic_85

# 2. A second PEEK can distinguish the Tandy 102 US/UK/NO.

#    I currently use PEEK(21333) even though it is not very useful on
#    its own. It works here and is easier to remember. It also
#    separates the PC-8201 and 8201A from the PC-8300.
#
#    PEEK(1)     (21333)
#        148       244        NEC_PC-8201 (Japan) / NEC_PC-8201A
#        148        83        NEC_PC-8300
#        167       105        Tandy_102_uk
#        167       254        Televerket_Modell_100
#        167         2        Tandy_102_us

# 3. A third PEEK can distinguish between the NEC PC-8201 and PC-8201A.
#    I use 31444.
#
#    PEEK(1) (21333) (31444)                
#        148     83      37        NEC_PC-8300
#        148    244      37        NEC_PC-8201+A
#        148    244     126        NEC_PC-8201+Japan

#  * Note that the previous two PEEKs actually provide a unique ID for
#    every model of ROM hackerb9 has found, as of May 2026. 
#
#    PEEK(21333) (31444)
#            2      82        TRS-80_Model_100
#            2     127        Tandy_102_us
#           26     255        Kyocera_Kyotronic_85
#           83      37        NEC_PC-8300
#           83     124        Olivetti_M10_North_America
#          105     127        Tandy_102_uk
#          205     244        Tandy_200
#          213      33        Olivetti_M10_Eur
#          244      37        NEC_PC-8201+A
#          244     126        NEC_PC-8201+Japan
#          254     127        Televerket_Modell_100

# 4. Is there a single best PEEK? Yes and no. 
#
#    For the ROMs I currently have, only a handful of addresses have
#    the maximum discerning power on their own: 21351, 21356..8.
#    However, I cannot recommend any of them as they can not
#    distinguish two of the most common Model-Ts: the TRS-80 Model 100
#    and the Tandy 102.

#    PEEK(21358)
#           9        Tandy_200+M15
#          35        Olivetti_M10_Eur
#          83        Tandy_102_us / TRS-80_Model_100
#          96        Tandy_102_uk
#         101        NEC_PC-8201+A  / NEC_PC-8201+Japan
#         123        Televerket_Modell_100
#         194        Kyocera_Kyotronic_85
#         205        Olivetti_M10_North_America
#         235        NEC_PC-8300
