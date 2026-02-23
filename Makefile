all:  	CRCBYTE.CO CRCBIT.CO CRCPSH.CO CRC16.CO CRC16.DO crc16 table.md sanity

# ORG is the address where the programs are assembled to load.
# * Can't be too low or 8K machines can't load the file. (About 59500 minimum).
# * Can't be too high or it'll tromple the system area on the Tandy 200. (MAXRAM=61104).
# * The filesize of CRC16BYTEWISE.CO is 1485 bytes with only 24 ROMs listed, 
#   which means ORG has to be less than 61104-1485 = 59619.
# * If ORG + filesize > 61104, this program would crash the whole computer!
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

# M/L encoded as BASIC for easy loading on any machine. (RUN "COM:...")
CRC16.DO: CRC16.CO
	adjunct/co2do CRC16.CO

# Symlink CRC16 to CRCBIT because (at least right now) CRCBYTE is too
# big to fit within the Tandy 200 memory.
CRC16.CO: CRCBIT.CO
	ln -sf CRCBIT.CO CRC16.CO 

# These are the executables for the Kyotronic Sisters (Model T computers)
CRCBYTE.CO: modelt-bytewise.asm modelt-driver.asm crc16-bytewise.asm crctable.asm
	asmx -e -w -b$(ORG) modelt-bytewise.asm && mv modelt-bytewise.asm.bin CRCBYTE.CO
	cp -p CRCBYTE.CO ../VirtualT/ || true

CRCBIT.CO: modelt-bitwise.asm modelt-driver.asm crc16-bitwise.asm crctable.asm
	asmx -e -w -b$(ORG) modelt-bitwise.asm && mv modelt-bitwise.asm.bin CRCBIT.CO
	cp -p CRCBIT.CO ../VirtualT/ || true

CRCPSH.CO: modelt-pushpop.asm modelt-driver.asm crc16-pushpop.asm crctable.asm
	asmx -e -w -b$(ORG) modelt-pushpop.asm && mv modelt-pushpop.asm.bin CRCPSH.CO
	cp -p CRCPSH.CO ../VirtualT/ || true

crctable.asm: mkcrctable.awk crc16 ROMs/* ROMs/ adjunct/extrasums.txt
	./mkcrctable.awk > crctable.asm

adjunct/extrasums.txt:
	touch adjunct/extrasums.txt


.PHONY: sanity
sanity: CRCPSH.CO CRCBIT.CO CRCBYTE.CO
	@for f in CRCPSH.CO CRCBIT.CO CRCBYTE.CO; do \
		echo -n ./sanitycheck "$$f ... "; \
		./sanitycheck "$$f"; \
	done

# This is a C program for checking that the CRC-16 is being calculated correctly. 
crc16: adjunct/crc16xmodem.h adjunct/crc16.c
	gcc -Wall -g -o $@ $+


# List of all ROMs linked by documentation
table.md: ROMs/ ROMs/* ROMs/other/* adjunct/mkmdtable
	adjunct/mkmdtable > table.md

clean:
	rm modelt-*.lst modelt-*.bin \
	   crc16*.bin crc16-*.lst CRC*.CO \
	   crc16 crctable.asm \
	   *~ 2>/dev/null || true

