# CRC-16 ROM check for the TRS-80 Model 100 and Kindred

Quickly check the ROM on any of computer related to the TRS-80
Model 100. (The Kyotronic Sisters are: Kyocera Kyotronic 85, TRS-80
Model 100, Tandy 102, Tandy 200, Olivetti M10, NEC PC-8201, NEC
PC-8201A, and NEC PC-8300.)

The program [CRC16.CO](CRC16.CO) uses [an 8080 assembly][crc16-8080]
routine to calculates the 16-bit Cyclic Redundancy Check.

[crc16-8080]: https://github.com/hackerb9/crc16-8080

## Usage

Use the [CRC16.CO](CRC16.CO) file if you simply want to run a check on
your Model T to see if you have a standard ROM installed.

* In BASIC run `CLEAR 256, 59595`. 
* Download [CRC16.CO](CRC16.CO) to your device. 
* Run CRC16.CO from the Menu by selecting it and pressing Enter.

If your Model T is recognized using a quick id check (see below), the 
machine's name will be shown. The CRC16 checksum will be shown and the
ROM variant will be looked up in the table below. If your variant is
not recognized, you'll be encouraged to create a new bug report so
your ROM can be added to the list. 

## Related

See below for a C program which can calculate the same checksum on a
PC or UNIX host.

If you wish to use just the CRC-16 routine in your own 8080 program,
see [crc16-8080][crc16-8080].

## Source code

The main driver program in [modelt-driver.asm](modelt-driver.asm)
identifies the type of "Model T" computer — the Model 100 or any of
the Kyotronic kin — that it is being run on so that the correct ROM
size and bank selection can be done. If a computer has multiple system
ROMs, they are concatenated as if they were one long file and a single
checksum is shown. The Option ROM is currently not examined. The
driver program calls the `CRC16` and `CRC16_CONTINUE` routines from
[crc16-8080][crc16-8080].

The program "CRC16.CO" is created from the file
[modelt-bytewise.asm][tbytewise], which is a wrapper that sets up the
necessary .CO file header and INCLUDEs both
[modelt-driver.asm](modelt-driver.asm) and
[crc16-bytewise.asm](crc16-bytewise.asm).

### Alternative .CO programs

There are two other wrapper programs available that have the same
functionality and simply include alternative CRC16 implementations.
The only difference is in the file size and speed of execution.

| Source                           | .CO executable         | Compiled Size | Features   |
|----------------------------------|------------------------|--------------:|------------|
| [modelt-bytewise.asm][tbytewise] | [CRC16.CO](CRC16.CO)   |    1486 bytes | Fastest    |
| [modelt-bitwise.asm][tbitwise]   | [CRCBIT.CO](CRCBIT.CO) |    1048 bytes | Reasonable |
| [modelt-pushpop.asm][tpushpop]   | [CRCPSH.CO](CRCPSH.CO) |     972 bytes | Smallest   |

[tbytewise]: modelt-bytewise.asm
[tbitwise]: modelt-bitwise.asm
[tpushpop]: modelt-pushpop.asm

## Specifics: CRC16/XMODEM

There is not one "CRC-16" algorithm, but actually many different
flavors based on parameter choices. This program uses the XMODEM
variant of CRC-16. In particular: the polynomial 0x1021, an initial
value of zero, and no reflections.

For more information on how Cyclic Redundancy Check (CRC) algorithms
work, I found most helpful Ross Williams' "Painless Guide", aka
["Everything you wanted to know about CRC algorithms, but were afraid
to ask for fear that errors in your understanding might be
detected"](adjunct/crc_v3.txt).


## Table of ROM checksums

Please see [table.md](table.md) for the full list including variants.
Here is the short list of the original system ROMs for the most
popular machines.

| Machine Name                   | ROM size | CRC-16 |
|:-------------------------------|---------:|:------:|
| TRS-80 Model 100               |      32K | 34F5   |
| Tandy 200                      |      72K | C061   |
| Tandy 102 (US)                 |      32K | 1C6F   |
| NEC PC-8201A                   |      32K | A48D   |

## CRC-16 in C

One can use the [included C program](adjunct/crc16.c) to double-check
that the assembly language is getting the right answer or to create a
table of expected values (see below). Compilation can be done using:

``` shell
gcc -Wall -g -o crc16 adjunct/crc16xmodem.h adjunct/crc16.c
```

Or just run `make`. The underlying code is from the
[crcany](https://github.com/madler/crcany) project.


## ID'ing the Kyotronic Sisters via two PEEKs

While the CRC16 will uniquely identify a ROM file, programs that wish
to run on any of the Model T portable computers need a test that can
identify the brand and model quickly and ignore minor modifications,
such as a Y2K patch.

The two ROM values at `PEEK(1)` and `PEEK(21538)`, have been found
empirically by hackerb9's [romcmp.py](ROMs/romcmp.py) program to
distinguish the hardware architectures while being insensitive to
minor patches.

<details><summary>Output from <code><a href="ROMs/id.py">id.py</a></code></summary><ul>

Output from <a href="ROMs/id.py">id.py</a>.

| PEEK(1) | (21358) | ROM FILE                             |
|--------:|--------:|--------------------------------------|
|      35 |      35 | M10_System_ROM_EU+orig.bin           |
|      35 |      35 | M10_System_ROM_EU+y2k.bin            |
|      51 |      83 | TRS-80_Model_100+orig.bin            |
|      51 |      83 | TRS-80_Model_100+y2k.bin             |
|      51 |     205 | TRS-80_Model_100+LibROM-1.1a.bin     |
|      72 |     209 | NEC_PC-8300_Beckman-E3.2+orig.bin    |
|     125 |     205 | M10_System_ROM_NorthAmerica+orig.bin |
|     125 |     205 | M10_System_ROM_NorthAmerica+y2k.bin  |
|     148 |     101 | NEC_PC-8201+orig.bin                 |
|     148 |     101 | NEC_PC-8201A+orig.bin                |
|     148 |     101 | NEC_PC-8201A+y2k.bin                 |
|     148 |     235 | NEC_PC-8300+orig.bin                 |
|     148 |     235 | NEC_PC-8300+y2k.bin                  |
|     167 |      83 | TRS-80_Model_100_uk+y2k.bin          |
|     167 |      83 | TRS-80_Model_100_us+26-3802B.bin     |
|     167 |      83 | Tandy_102_us+orig.bin                |
|     167 |      83 | Tandy_102_us+y2k.bin                 |
|     167 |      96 | Tandy_102_uk+orig.bin                |
|     167 |      96 | Tandy_102_uk+y2k.bin                 |
|     167 |     123 | Televerket_Modell_100+orig.bin       |
|     171 |       9 | Tandy_200+M15.orig.bin               |
|     171 |       9 | Tandy_200+M15.y2k.bin                |
|     171 |       9 | Tandy_200+us.orig.bin                |
|     195 |      84 | Tandy_200+M14.orig.bin               |
|     225 |     194 | Kyocera_Kyotronic_85+orig.bin        |
|     225 |     194 | Kyocera_Kyotronic_85+y2k.bin         |
|     225 |     194 | TRS-80_Model_100_uk+skl.bin          |

</ul></details>

Of course, as more ROMs are catalogued, it is possible these addresses
will be insufficient. The list above is correct as of February 2026.
