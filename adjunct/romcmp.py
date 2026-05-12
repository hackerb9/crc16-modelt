#!/usr/bin/python

# It is well known that PEEK(1) can distinguish between the Model T's.
# However, it cannot tell nationalized models apart. (Tandy 102
# US vs M100 UK/NO; NEC PC-8201 vs PC-8201A/PC-8300).
#
# Is there any single byte address that would uniquely identify every.
# Kyotronic Sister? This program shows the answer is "No".

# At least two, maybe three peeks are needed to fully distinguish the
# set of ROMs hackerb9 has collected (so far).
# Recommended: PEEK(21358), PEEK(6468), PEEK(31444)

from glob import glob as glob
from collections import defaultdict
import os, sys


# Addresses which are already being used to disambiguate. Can be empty.
# Set this array to try out the effect of having multiple PEEKs.
#already_given = [ 1, 31444 ]
already_given = [ 21358, 31444 ]
already_given = [ 6468 ]

rom = {}

if len(sys.argv) == 1:
    files = glob("ROMs/*orig.bin")
else:
    files = sys.argv[1:]

if len(files) == 0: raise ValueError("Could not open ROMs")
files = sorted(files)

model=defaultdict(dict)         # "Model" is part before '+' ("Tandy_102_uk")
				# "Variant" is part after '+' ("y2k")
namemv=defaultdict(dict)
removed=defaultdict(dict)
for f in files:
    if os.path.isdir(f):
        continue
    name=f.rstrip(".bin")
    rom[name] = open(f, "rb").read(32768)
    if len(rom[name]) == 32768:
        if name.find('+') != -1:
            (m, v) = name.split('+')
        else:
            m = name
            v = ""
        if m.rfind('/') != -1:
            m = m[m.rfind('/')+1:]
        model[m][v]=name
        namemv[name]=(m,v)
    else:
        del rom[name]


# Ignore addresses where variants differ.
modelrom = defaultdict(dict)

for m in model:
    print(f"Merging variants of model {m}: {list(model[m].keys())}")
    modelrom[m] = defaultdict(dict)
    for i in range(0, 32768):
        for var,name in model[m].items():
            # Presume PEEK(x) is also being used
            value = rom[name][i]
            for x in already_given: 
                value = value<<8 + rom[name][x]
            if i in modelrom[m]:
                modelrom[m][i].append( value )
            else:
                modelrom[m][i] = [ value ]

    # Keep only one of the ROM variants.
#    x = list(model[m].keys())[0]
#    rom[m] = rom[model[m][x]]

#    for v in model[m]:
#        removed[model[m][v]] = rom[model[m][v]]
#        del rom[model[m][v]]

print("")
# Main routine

# For every address, check each model's set of values at that address
# and make sure there is no overlap (intersection) with the other models..
count = {}
seen = {}
for i in range(0, 32768):
    seen[i] = set()
    count[i] = 0
    for m in modelrom:
        # Count unique values for PEEK(i) for each model of ROM. 
        if seen[i].isdisjoint( modelrom[m][i] ):
            count[i]=count[i]+1
        seen[i].update( modelrom[m][i] )
       
best = max( count.items(), key = lambda x: x[1] )[1]
if best < len(model):
    print( f'At best can distinguish {best} of the {len(model)} models ({len(rom)} ROMs)' )
else:
    print( f'Can distinguish all of the {len(model)} models ({len(rom)} ROMs)' )

if best <= 1: raise ValueError
 
for i in range(32768):
    if count[i] >= best:
#        if rom['NEC_PC-8201+A_orig'][i] == rom['NEC_PC-8201+Japan_orig'][i]: continue
#        if rom['Tandy_102_uk+orig'][i] == rom['Tandy_102_us+orig'][i]: continue

        print("PEEK ", end='')
        print( ''.join( [ f"{'('+str(x)+')':>8s}"
                          for x in already_given +[i] ]))
        output = []
        for name in rom:
            line = [ rom[name][j] for j in already_given+[i] ]
            output.append( [line , f'\t{name}' ])
        for name in removed:
            line = [ removed[name][j] for j in already_given+[i] ]
            output.append( [line , f'\t\u2003\t({name})' ])
        output=sorted(output)
        for line in output:
            print( '   ',
                   ''.join( [ f'{id:8d}' for id in line[0] ] ),
                   line[1] )
            
            

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

# 5. What PEEK can tell me the date format is?

#    Grouping ROMs by date order (MMDDYY, DDMMYY, YYMMDD), 
#    this program shows a single PEEK suffices.

#    | PEEK(6468)  | Mnemonic | Format |
#    |-------------|----------|--------|
#    | 5           | < 64     | YYMMDD |
#    | 25, 74, 110 | All else | DDMMYY |
#    | 154, 200    | > 128    | MMDDYY |

    # PEEK   (6468)
    #            5    YYMMDD+8201
    #            5    YYMMDD+8201A
    #            5    YYMMDD+8201A_y2k
    #            5    YYMMDD+8300
    #            5    YYMMDD+8300_y2k
    #           25    DDMMYY+m100_no
    #           25    DDMMYY+m100_uk
    #           25    DDMMYY+m100_uk_y2k
    #           25    DDMMYY+t102_uk
    #           25    DDMMYY+t102_uk_y2k
    #           74    DDMMYY+librom
    #          110    DDMMYY+k85
    #          110    DDMMYY+k85_y2k
    #          110    DDMMYY+m10eu
    #          110    DDMMYY+m10eu_y2k
    #          154    MMDDYY+m100
    #          154    MMDDYY+m100_y2k
    #          154    MMDDYY+t102
    #          154    MMDDYY+t102_y2k
    #          200    MMDDYY+t200
    #          200    MMDDYY+t200_y2k
     
# Here's a chart showing the values for the PEEKs I recommend. 

# PEEK    (1)  (21358)  (6468)

#        *35      35     110    Olivetti_M10_eu+orig
#        *35      35     110    Olivetti_M10_eu+y2k

#         51     *83     154    TRS-80_Model_100+REX_y2k
#         51     *83     154    TRS-80_Model_100+orig
#         51     *83     154    TRS-80_Model_100+y2k

#         51    *205      74    TRS-80_Model_100+LibROM-1.1a

#       *125     205     218    Olivetti_M10_na+orig
#       *125     205     218    Olivetti_M10_na+y2k

#        148     101       5    NEC_PC-8201+A_REX_y2k
#        148     101       5    NEC_PC-8201+A_orig
#        148     101       5    NEC_PC-8201+A_y2k
#        148     101       5    NEC_PC-8201+A_y2k_VirT

#        148     101       5    NEC_PC-8201+jp_orig

#        148    *235       5    NEC_PC-8300+orig
#        148    *235       5    NEC_PC-8300+y2k
#        148    *235       5    NEC_PC-8300+y2k_VirT

#        167      83     *25    TRS-80_Model_100_uk+orig
#        167      83     *25    TRS-80_Model_100_uk+y2k

#        167      83    *154    Tandy_102+REX_y2k
#        167      83    *154    Tandy_102+orig
#        167      83    *154    Tandy_102+y2k

#        167     *96      25    Tandy_102_uk+orig
#        167     *96      25    Tandy_102_uk+y2k

#        167    *123      25    Televerket_Modell_100+orig

#       *171       9     200    Tandy_200+M15_REX_y2k
#       *171       9     200    Tandy_200+M15_orig
#       *171       9     200    Tandy_200+M15_y2k

#       *225     194     110    Kyocera_Kyotronic_85+orig
#       *225     194     110    Kyocera_Kyotronic_85+y2k


# Note that the above does not discern between the PC-8201 and
# PC-8201A which are distinct machines. PEEK(31444) solves that as it
# returns 126 for the PC-8201 (Japanese) and 37 for the PC-8201A and
# PC-8300A (English).

# Note that if PEEK(31444) is added in, PEEK(1) is not needed.

# PEEK  (21358)  (6468) (31444)
#            9     200     244    Tandy_200+M15_REX_y2k
#            9     200     244    Tandy_200+M15_orig
#            9     200     244    Tandy_200+M15_y2k
#           35     110      33    Olivetti_M10_eu+orig
#           35     110      33    Olivetti_M10_eu+y2k
#           83      25     127    TRS-80_Model_100_uk+orig
#           83      25     127    TRS-80_Model_100_uk+y2k
#           83     154      82    TRS-80_Model_100+REX_y2k
#           83     154      82    TRS-80_Model_100+orig
#           83     154      82    TRS-80_Model_100+y2k
#           83     154     127    Tandy_102+REX_y2k
#           83     154     127    Tandy_102+orig
#           83     154     127    Tandy_102+y2k
#           96      25     127    Tandy_102_uk+orig
#           96      25     127    Tandy_102_uk+y2k
#          101       5      37    NEC_PC-8201_A+REX_y2k
#          101       5      37    NEC_PC-8201_A+orig
#          101       5      37    NEC_PC-8201_A+y2k
#          101       5      37    NEC_PC-8201_A+y2k_VirT
#          101       5     126    NEC_PC-8201+jp_orig
#          123      25     127    Televerket_Modell_100+orig
#          194     110     255    Kyocera_Kyotronic_85+orig
#          194     110     255    Kyocera_Kyotronic_85+y2k
#          205      74      82    TRS-80_Model_100+LibROM-1.1a
#          205     218     124    Olivetti_M10_na+orig
#          205     218     124    Olivetti_M10_na+y2k
#          235       5      37    NEC_PC-8300+orig
#          235       5      37    NEC_PC-8300+y2k
#          235       5      37    NEC_PC-8300+y2k_VirT
