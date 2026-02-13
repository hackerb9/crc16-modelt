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

If you wish to use just the CRC-16 routine in your own program, see
[crc16-8080][crc16-8080].

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

Here are the CRC-16 values for all of the original Model T ROMs which
have been reported so far. If you find one not listed, please open an
issue so it can be added to the list. Ideally, include a copy of your
ROM, but at a minimum, please include the calculated CRC and a name to
call your variation.

| Machine Name                   | ROM size | CRC-16 |
|:-------------------------------|---------:|:------:|
| Kyocera Kyotronic KC-85        |      32K | F08D   |
| TRS-80 Model 100               |      32K | 34F5   |
| Tandy 200                      |      72K | C061   |
| Tandy 102 (US)                 |      32K | 1C6F   |
| Tandy 102 (UK)                 |      32K | 5CF0   |
| NEC PC-8201A                   |      32K | A48D   |
| NEC PC-8300                    |     128K | 9FF5   |
| Olivetti M10 (Europe)          |      32K | 5DD2   |
| Olivetti M10 (North America)   |      32K | 5D9F   |
| Televerket Modell 100 (Norway) |      32K | 2A64   |


### ROM Variants

Modified ROMs, for example with Y2K patches, will have different
checksums than the original. The Virtual T emulator can also patch the
ROMs to show the Virtual T version on the Menu. See also the directory
of sample ROMs (mirrored from [tandy.wiki][tandy.wiki]) in
[ROMs](ROMs).

[tandy.wiki]: http://tandy.wiki/Model_T_System_ROMs "List of system ROMs, the builtin software on a chip"

|          Machine Name | ROM size | Y2K patched | Virtual T 1.7 | Y2K+Vir-T 1.7 | LibROM 1.1a |
|----------------------:|---------:|:-----------:|:-------------:|:-------------:|:-----------:|
|  Kyocera Kyotronic 85 |      32K | 64A8        | E71C          |               |             |
| TRS-80 Model 100 (US) |      32K | F6C1        |               | 554D          |             |
| TRS-80 Model 100 (UK) |      32K |             |               |               | 60F0        |
|        Tandy 102 (US) |      32K | DE5B        |               | 7DD7          |             |
|        Tandy 102 (UK) |      32K | 9EC4        |               |               |             |
|             Tandy 200 |      72K | 9534        |               | 0665          |             |
|          NEC PC-8201A |      32K | 8CA0        |               | 91C7          |             |
|           NEC PC-8300 |     128K | E3A9        |               |               |             |
| Olivetti M10 (Europe) |      32K | 1B13        |               | B753          |             |
|     Olivetti M10 (US) |      32K | 5E44        |               |               |             |

## CRC-16 in C

One can use the [included C program](adjunct/crc16.c) to double-check
that the assembly language is getting the right answer or to create a
table of expected values (see below). Compilation can be done using:

``` shell
gcc -Wall -g -o crc16 adjunct/crc16xmodem.h adjunct/crc16.c
```

Or just run `make`. The underlying code is from the
[crcany](https://github.com/madler/crcany) project.

### Table of various known ROMs

Here is the list of CRC16 checksums for all the various known ROMs,
originals ands patched variants, as generated by running the C program
as `./crc16 ROMs/*.bin`.

| CRC16 | ROM filename                         |
|-------|--------------------------------------|
| F08D  | Kyocera_Kyotronic_85+orig.bin        |
| 64A8  | Kyocera_Kyotronic_85+y2k.bin         |
| 5DD2  | M10_System_ROM_EU+orig.bin           |
| 1B13  | M10_System_ROM_EU+y2k.bin            |
| 5D9F  | M10_System_ROM_NorthAmerica+orig.bin |
| 5E44  | M10_System_ROM_NorthAmerica+y2k.bin  |
| A48D  | NEC_PC-8201A+orig.bin                |
| 8CA0  | NEC_PC-8201A+y2k.bin                 |
| 4793  | NEC_PC-8300_Beckman-E3.2+orig.bin    |
| 9FF5  | NEC_PC-8300+orig.bin                 |
| E3A9  | NEC_PC-8300+y2k.bin                  |
| 5CF0  | Tandy_102_uk+orig.bin                |
| 9EC4  | Tandy_102_uk+y2k.bin                 |
| 1C6F  | Tandy_102_us+orig.bin                |
| DE5B  | Tandy_102_us+y2k.bin                 |
| 3D1A  | Tandy_200+M13.orig.bin               |
| 958C  | Tandy_200+M14.orig.bin               |
| 25C3  | Tandy_200+M15.orig.bin               |
| 67AB  | Tandy_200+M15.y2k.bin                |
| 9534  | Tandy_200+us.orig.bin                |
| A2B3  | Tandy_600+BASIC.bin                  |
| 2A64  | Televerket_Modell_100+orig.bin       |
| 60F0  | TRS-80_Model_100+LibROM-1.1a.bin     |
| 34F5  | TRS-80_Model_100+orig.bin            |
| 7A77  | TRS-80_Model_100_uk+skl.bin          |
| A010  | TRS-80_Model_100_uk+y2k.bin          |
| 6224  | TRS-80_Model_100_us+26-3802B.bin     |
| F6C1  | TRS-80_Model_100+y2k.bin             |


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

| PEEK(1) | (21358) | ROM FILE                                  |
|--------:|--------:|-------------------------------------------|
|      35 |      35 | M10_System_ROM_EU+orig.bin           |
|      35 |      35 | M10_System_ROM_EU+y2k.bin            |
|      51 |      83 | TRS-80_Model_100+orig.bin            |
|      51 |      83 | TRS-80_Model_100+y2k.bin             |
|      51 |     205 | TRS-80_Model_100+LibROM-1.1a.bin     |
|      72 |     209 | NEC_PC-8300_Beckman-E3.2+orig.bin    |
|     125 |     205 | M10_System_ROM_NorthAmerica+orig.bin |
|     125 |     205 | M10_System_ROM_NorthAmerica+y2k.bin  |
|     144 |     254 | Tandy_600+BASIC.bin                  |
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


|      35 |      35 | M10_System_ROM_EU.orig.bin           |
|      35 |      35 | M10_System_ROM_EU.y2k.bin            |
|      51 |      83 | TRS-80_Model_100.orig.bin            |
|      51 |      83 | TRS-80_Model_100.y2k.bin             |
|      51 |     205 | TRS-80_Model_100+LibROM-1.1a.bin     |
|      72 |     209 | NEC_PC-8300_Beckman-E3.2.bin         |
|     125 |     205 | M10_System_ROM_NorthAmerica.orig.bin |
|     125 |     205 | M10_System_ROM_NorthAmerica.y2k.bin  |
|     144 |     254 | Tandy_600_BASIC.bin                  |
|     148 |     101 | NEC_PC-8201A.orig.bin                |
|     148 |     101 | NEC_PC-8201A.y2k.bin                 |
|     148 |     235 | NEC_PC-8300.orig.bin                 |
|     148 |     235 | NEC_PC-8300.y2k.bin                  |
|     167 |      83 | Tandy_102.us.orig.bin                |
|     167 |      83 | Tandy_102.us.y2k.bin                 |
|     167 |      96 | Tandy_102.uk.orig.bin                |
|     167 |      96 | Tandy_102.uk.y2k.bin                 |
|     167 |     123 | Televerket_Modell_100.orig.bin       |
|     171 |       9 | Tandy_200.M15.orig.bin               |
|     171 |       9 | Tandy_200.M15.y2k.bin                |
|     225 |     194 | KC-85.orig.bin                       |
|     225 |     194 | KC-85.y2k.bin                        |

</ul></details>

Of course, as more ROMs are catalogued, it is possible these addresses
will be insufficient. The list above is correct as of February 2026.
