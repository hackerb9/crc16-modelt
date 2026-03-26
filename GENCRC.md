# A CRC-16/xmodem algorithm for any purpose

[GENCRC.ASM](GENCRC.ASM) is a wrapper around crc16-pushpop.asm which
can be called from BASIC to easily checksum any region of memory. To
call it, one must create an array of three integers and pass the
address of that array to the routine as HL. 

Usage:

``` BASIC
CLEAR 256,60000: LOADM"GENCRC.CO"
i%[0] = buffer start address
i%[1] = buffer length
i%[2] = 0 (initial checksum / result) 
call 60000, 0, varptr(i%[0])
?i%[2]
```

Note that a large file can be processed in blocks by simply
leaving the result in i%[2] instead of resetting it to zero.
The final checksum will be the same as if it had been processed as a
single piece.

See also: [crcbas.do](crcbas.do) for a version of this which uses
VARPTR to execute out of a string instead of loading to a fixed
address.
