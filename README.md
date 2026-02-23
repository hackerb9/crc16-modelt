# CRC-16 ROM check for the TRS-80 Model 100 and Kindred

Quickly check the ROM on any of computer related to the TRS-80
Model 100. (The Kyotronic Sisters are: Kyocera Kyotronic 85, TRS-80
Model 100, Tandy 102, Tandy 200, Olivetti M10, NEC PC-8201, NEC
PC-8201A, and NEC PC-8300.)

The program [CRC16.CO](CRC16.CO) uses [an 8080 assembly][crc16-8080]
routine to calculates the 16-bit Cyclic Redundancy Check.

[crc16-8080]: https://github.com/hackerb9/crc16-8080

## Usage

Use the [CRC16.DO](CRC16.DO) file if you want to run a check on
your Model T to see if you have a standard ROM installed.

* Download [CRC16.DO](CRC16.DO) to your device. 
* From BASIC type `run "CRC16"` 

If your Model T is recognized using a quick id check (see below), the
machine's name will be displayed first. The CRC16 checksum will be
shown next and the ROM variant will be looked up in the table below.
If your variant is not recognized, you'll be encouraged to create a
new bug report so your ROM can be added to the list.

Note: 8K machines may have to use `run "COM:88N1"` and send the file
over the serial port.

## Related

See below for a C program which can calculate the same checksum on a
PC or UNIX host.

If you wish to use just the CRC-16 routine in your own 8080 program,
see [crc16-8080][crc16-8080].

## Source code

The main driver program in [modelt-driver.asm](modelt-driver.asm)
identifies the type of "Model T" computer using the Quick ID (see
below) so that the correct ROM size and bank selection can be done.

The algorithm currently handles two computers specially: The Tandy 200
and the NEC PC-8300. 

* The NEC PC-8300 has 128K of ROM instead of 32K. Although this
  appears to developers as four 32K banks, it is on a single chip and
  so it makes sense to concatenate the banks and checksum them as one
  long file. A single checksum is shown.

* The Tandy 200 has three separate ROM chips M15, M13, and M14. While
  the developer sees M15 and M13 as a contiguous address space, this
  program treats them as distinct. Three checksums will be shown.

Option ROMs are currently not examined but should not be difficult as
the bank selection scheme is the same as for the Tandy 200. 

The driver program calls the `CRC16` and `CRC16_CONTINUE` routines
from [crc16-8080][crc16-8080].

The program "CRC16.CO" is created from the file
[modelt-bytewise.asm][tbytewise], which is a wrapper that sets up the
necessary .CO file header and INCLUDEs both
[modelt-driver.asm](modelt-driver.asm) and
[crc16-bytewise.asm](crc16-bytewise.asm).

### Alternative .CO programs

There are actually three wrapper programs available that have the same
functionality and simply include alternative CRC16 implementations.
The only difference is in the file size and speed of execution.

| Source                           | .CO executable           | Compiled Size | Features   |
|----------------------------------|--------------------------|--------------:|------------|
| [modelt-bytewise.asm][tbytewise] | [CRCBYTE.CO](CRCBYTE.CO) |    1881 bytes | Fastest    |
| [modelt-bitwise.asm][tbitwise]   | [CRCBIT.CO](CRCBIT.CO)   |    1443 bytes | Reasonable |
| [modelt-pushpop.asm][tpushpop]   | [CRCPSH.CO](CRCPSH.CO)   |    1367 bytes | Smallest   |

(The file [CRC16.CO](CRC16.CO) is merely a symlink to CRCBIT.CO.)

[tbytewise]: modelt-bytewise.asm
[tbitwise]: modelt-bitwise.asm
[tpushpop]: modelt-pushpop.asm

## CRC16.DO

The .DO version of the CRC16.CO is a BASIC wrapper around the .CO file
created by [co2do][co2do]. Although the file is quite a bit larger,
using precious RAM and adds significant time due to unpacking, it can
be transferred easily to any Model T, even if it doesn't have any
other software installed. 

[co2do]: https://github.com/hackerb9/co2do

The .DO file can be loaded on machines with little memory by using RUN
"COM:88N1" and sending the file to the Model-T over the serial port at
9600 baud. The ^Z to signal EOF is already included in the file so no
special program is needed for sending. (Personally, I use `cat
CRC16.DO > /dev/ttyUSB0`).

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

Here is the short list of the original system ROMs for the most
popular machines.

| Machine Name     | ROM size | CRC-16 |
|:-----------------|---------:|:------:|
| TRS-80 Model 100 |      32K | 34F5   |
| Tandy 102 (US)   |      32K | 1C6F   |
| Tandy 200 M15    |      32K | 9535   |
| Tandy 200 M13    |       8K | 3D1A   |
| Tandy 200 M14    |      32K | 958C   |
| NEC PC-8201A     |      32K | A48D   |

Please see [table.md](table.md) for the full list of all machines,
including patched variants.

## CRC-16 in C

One can use the [included C program](adjunct/crc16.c) to double-check
that the assembly language is getting the right answer or to create a
[table of expected values](table.md). Compilation can be done using:

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
