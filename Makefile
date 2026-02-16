all:  	CRC16.CO CRCBIT.CO CRCPSH.CO crc16 sanity

# ORG is the address where the programs are assembled to load.
# * Can't be too low or 8K machines can't load the file. (About 59500 minimum).
# * Can't be too high or it'll tromple the system area on the Tandy 200. (MAXRAM=61104).
# * The filesize of CRC16BYTEWISE.CO is 1485 bytes with only 24 ROMs listed, 
#   which means ORG has to be less than 61104-1485 = 59619.
# * If ORG + filesize > 61104, even LOADMing this program would crash the whole computer!
# * If ORG changes, it must change here and in the model-*.asm files.
# * See the "sanity" script.
ORG=59595

# These are just the CRC-16 routine assembled, but not part of a usable program.
crc16-bytewise.bin: crc16-bytewise.asm 
	asmx -e -w -C8080 -b0 crc16-bytewise.asm && mv crc16-bytewise.asm.bin crc16-bytewise.bin

crc16-bitwise.bin: crc16-bitwise.asm 
	asmx -e -w -C8080 -b0 crc16-bitwise.asm && mv crc16-bitwise.asm.bin crc16-bitwise.bin

crc16-pushpop.bin: crc16-pushpop.asm 
	asmx -e -w -C8080 -b0 crc16-pushpop.asm && mv crc16-pushpop.asm.bin crc16-pushpop.bin


# These are the executables for the Kyotronic Sisters (Model T computers)
CRC16.CO: modelt-bytewise.asm modelt-driver.asm crc16-bytewise.asm
	asmx -e -w -b$(ORG) modelt-bytewise.asm && mv modelt-bytewise.asm.bin CRC16.CO
	cp -p CRC16.CO ../VirtualT/ || true

CRCBIT.CO: modelt-bitwise.asm modelt-driver.asm crc16-bitwise.asm
	asmx -e -w -b$(ORG) modelt-bitwise.asm && mv modelt-bitwise.asm.bin CRCBIT.CO
	cp -p CRCBIT.CO ../VirtualT/ || true

CRCPSH.CO: modelt-pushpop.asm modelt-driver.asm crc16-pushpop.asm
	asmx -e -w -b$(ORG) modelt-pushpop.asm && mv modelt-pushpop.asm.bin CRCPSH.CO
	cp -p CRCPSH.CO ../VirtualT/ || true

.PHONY: sanity
sanity: CRCPSH.CO CRCBIT.CO CRC16.CO
	@for f in CRCPSH.CO CRCBIT.CO CRC16.CO; do \
		echo -n ./sanitycheck "$$f $(ORG)... "; \
		./sanitycheck "$$f" $(ORG); \
	done

# This is a C program for checking that the CRC-16 is being calculated correctly. 
crc16: adjunct/crc16xmodem.h adjunct/crc16.c
	gcc -Wall -g -o $@ $+


clean:
	rm modelt-*.lst modelt-*.bin \
	   crc16*.bin crc16-*.lst CRC*.CO \
	   crc16 \
	   *~ 2>/dev/null || true




