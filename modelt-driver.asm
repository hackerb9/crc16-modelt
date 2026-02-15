;;; tandy-driver: Exercise the CRC-16 routine
;;; Hackerb9, January 2026

;;; This program prints the checksum of the system ROM. Requires 8K of RAM. 
;;; Use CLEAR 256,60000 to reserve space before running.

;;; This should work for any computer related to the Kyotronic-85. 
;;; KC-85, M10, M100, T102, PC8201: All work without special handling. 
;;; Tandy 200: Recognized and checks all 72K of ROM via bank selection. 
;;; PC-8300: Recognized and checks all 128K of ROM via bank selection.

;;; For machine detection, currently two memory addresses are checked:

	.8080			; Hint to asmx

;;; Machine architecture specific addresses
CHGET	EQU	12CBH		; wait for key - Model 100/102
CH200	EQU	12F7H		; wait for key - Tandy 200
CHNEC	EQU	174DH		; wait for key - NEC PC-8201 & 8300
; Note: LCD routine not used as RST 4 works on all Kyotronic Sisters.
;LCD	EQU	4B44H		; Model 100 print to LCD screen
; Note: PRT0 routine implemented below to make this cross platform.
;PRT0	EQU	11A2H		; Model 100 print string up to NULL

	;; Quick ID: PEEK(1) and PEEK(21358) uniquely identify the
	;; machine architecture (E.g. "NEC PC-8201/A") so we use that
	;; to print the make and model . This saves bytes in the CRC
	;; lookup table as it only needs to contain variations (such
	;; as "North America", "Y2K patched" or "Virtual-T 7.1").
	LXI H, 1
	MOV E, M		; D=PEEK(1)
	LXI H, 21358
	MOV D, M		; E=PEEK(21358)
	LXI H, QIDTABLE
	CALL PRTLOOKUP		; Print make and model
	CALL PRTNL

	;; Model-Ts have 3 different ROM layouts: T200, PC8300, and all else.
	;; Tandy 200 if peek(1) == 171, ROM is 72K (40K + 32K).
	LXI D, 1
	LDAX D
	CPI 171			; T200
	JZ TANDY200

	;; PC8300 if peek(21358) == 235, ROM is 128K (4x 32K).
	LXI D, 21358
	LDAX D
	CPI 235			; PC8300
	JZ PC8300

KYOTRONIC:	
	;; All other Kyotronic Sisters (m100, m10, pc8201) have 32KB of ROM.
	LXI D, 0     ; DE: Address to start checksumming (0 for ROM)
	LXI B, 8000H ; BC: Length of buffer (8000H for 32K ROM)

	;; Calculate checksum of BC bytes at addr DE and put result in HL.
	CALL CRC16
	JMP ALLDONE

TANDY200:	
	;; Handle the Tandy 200 specially to checksum all three ROM chips.
	LXI H, M15
	CALL PRT0
	LXI H, CRCIS
	CALL PRT0

	LXI D, 0     ; DE: T200's M15 chip starts at address 0...
	LXI B, 8000H ; BC: ...and is 32K long
	CALL CRCANDLOOKUP

;	XCHG
	LXI H, M13
	CALL PRT0
	LXI H, CRCIS
	CALL PRT0
;	XCHG

	LXI D, 8000H ; DE: T200's M13 chip starts at address 32768...
	LXI B, 2000H ; BC: ...and is 8K long
	CALL CRCANDLOOKUP

;	XCHG
	LXI H, M14
	CALL PRT0
	LXI H, CRCIS
	CALL PRT0
;	XCHG

	;; Switch to the Multiplan ROM bank
        ; first, disable interrupts and keep them off,
        ; then send a specific byte to a specific IO port to see multiplan 
	DI
	IN 0D8h
	ANI 00001100b		; keep the ram bits, zero out the rom bits
	ORI 00000001b		; enable multiplan rom
	OUT 0D8H
	
	LXI D, 0     ; Multiplan ROM starts address 0...
	LXI B, 8000H ; ... and is 32K long
	CALL CRC16

	;; Switch back to normal BASIC ROM 
        ; send a specific byte to a specific IO port to get back
        ; to the main rom, enable interrupts
	IN  0D8h
	ANI 00001100b		; keep the ram bits, zero out the rom bits
	OUT 0D8H	
	EI

	CALL PRTHEX16
	CALL PRTCRCLOOKUP
	CALL PRTNL

	JMP WAITEXIT
	
PC8300:	
	;; The PC8300 has four ROM banks of 32K each.
	DI			; Disable interrupts before switching banks

	LXI H, 0		; Initialize CRC to 0 so we can use _CONTINUE
	MVI D, 0		; Rom bank counter 000b to 100b
PC8300_BANK_LOOP:
	PUSH D
	LXI D, 0     ; DE: Address to start checksumming
	LXI B, 8000H ; BC: Length of buffer (8000H is 32K)
	CALL CRC16_CONTINUE
	POP D

	IN 0A3h
	ANI 11111100b		; keep the ram bits, zero out the rom bits
	INR D
	ORA D			; enable bank 01, 10, 11, then 00
	OUT 0A3H

	MOV A, D
	CPI 00000100b
	JNZ PC8300_BANK_LOOP

	;; We're back to ROM bank 00, so enable interrupts
	EI

;	JMP ALLDONE


ALLDONE:
	;;; All done with entire buffer. Checksum result is in HL.
	XCHG			; DE=HL
	LXI H, CRCIS		; Print "CRC-16 is "
	CALL PRT0
	XCHG			; HL=DE

	;; Print HL as four hexadecimal nybbles
	CALL PRTHEX16
	CALL PRTNL

	CALL PRTCRCLOOKUP	; Look up CRC in table and print match

WAITEXIT:
	LXI H, HITAKEY
	CALL PRT0

	;; Do we know how to wait for a key?
	LXI D, 1
	LDAX D
	CPI 171			; T200
	JZ WAIT200
	CPI 51			; M100
	JZ WAIT100
	CPI 167			; M102
	JZ WAIT100
	CPI 148			; PC-8201 or 8300
	JZ WAITNEC

	;; Unrecognized machine, let's just pause for about 5 seconds.
	LXI H, PAUSING
	CALL PRT0

	LXI B, 10H
PAUSE1:	
	LXI H, FFFFH
PAUSE2:	DCX H
	MOV A, L
	ORA H
	JNZ PAUSE2
	DCX B
	MOV A, C
	ORA B
	JNZ PAUSE1
	RET

WAIT200:
	CALL CH200
	RET

WAIT100:
	CALL CHGET
	RET

WAITNEC:
	CALL CHNEC
	RET

;; ;;; Print a null-terminated string pointed to by HL.
;; ;;; Modifes A and HL
;; PRT0:	
;; 	MOV A, M
;; 	ANA A
;; 	JZ PRT0DONE
;; 	RST 4
;; 	INX H
;; 	JMP PRT0
;; PRT0DONE:
;; 	RET

;;; Print newline (carriage return + line feed)
;;; Modifes A
PRTNL:	
	MVI A, 13
	RST 4
	MVI A, 10
	RST 4
	RET

;;; Print a null-terminated string pointed to by HL.
;;; If any characters have the high-bit set, 
;;; look them up in the HIGHASCIITABLE and print the associated string.
;;; Modifes A and HL
PRT0:	
	MOV A, M
	ANA A
	JZ PRT0DONE
	CPI 7FH
	JP PRTHIGHASCII
	RST 4
	INX H
	JMP PRT0
PRT0DONE:
	RET
PRTHIGHASCII:
	PUSH H
	PUSH D
	LXI H, HIGHASCIITABLE
	SUI 128
	MOV E, A
	MVI D, 0
	DAD D
	DAD D
	MOV E, M
	INX H
	MOV D, M
	XCHG
	CALL PRT0
	POP D
	POP H
	INX H
	JMP PRT0


;;; Print HL as four hexadecimal hexits
;;; Modifies A
PRTHEX16:
	MOV A, H
	CALL PRTHEX
	MOV A, L
	CALL PRTHEX
	MVI A, ' '
	RST 4
	RET

;;; Given a byte in A, print it as two hexits. 
PRTHEX:	
	PUSH D
	MOV D, A
	ANI F0H
	RAR
	RAR
	RAR
	RAR
	CALL PRTNYBHEX
	MOV A, D
	CALL PRTNYBHEX
	POP D
	RET

;;; Print the low nybble of A as hexadecimal
PRTNYBHEX:
	PUSH B
	PUSH H
	ANI 0FH
	MVI B, 0
	MOV C, A
	LXI H, HEXITS
	DAD B
	MOV A, M
	RST 4
	POP H
	POP B
	RET

;;; With DE set to start address and BC set to length to checksum,
;;; Calculate the CRC, print it as HEX, and print out if its known.
CRCANDLOOKUP:	
	CALL CRC16
	CALL PRTHEX16
	CALL PRTCRCLOOKUP
	CALL PRTNL
	RET

;;; Print a string associated with the CRC
;;; Entry: HL=CRC
;;; Modifies A
PRTCRCLOOKUP:
	PUSH H
	PUSH D
	XCHG
	LXI H, CRCTABLE
	CALL PRTLOOKUP		; CRC in DE, table in HL
	POP D
	POP H
	RET

;;; Look up DE in the table at HL and print the associated string (null terminated).
;;; Table is alternating 16-bit words:  ID0, STR0,  ID1, STR1,  ID2, STR2,  0000, STRZ.
;;; If no match is found, STRZ is printed.
;;; Entry: DE=key, HL=table
;;; Exit: Modifies BC, HL, A. See also PRTCRCLOOKUP.
PRTLOOKUP:
LOOKUPLOOP:
	MOV C, M		; Read the bytes at address HL, HL+1 and put them in BC
	INX H
	MOV B, M
	INX H
	MOV A, B
	ORA C
	JZ LOOKUPNOTFOUND	; Are both B and C zero? End of list.
	MOV A, B
	CMP D			; Does BC == DE?
	JNZ NOPENOPE
	MOV A, C
	CMP E
	JZ  FOUNDMATCH		; We have a match!
NOPENOPE:	
	INX H
	INX H
	JMP LOOKUPLOOP
	
LOOKUPNOTFOUND:	
FOUNDMATCH:
	;; HL points to an address which points to a string. Print it.
	MOV E, M
	INX H
	MOV D, M
	XCHG			; Swap HL and DE
	CALL PRT0		; Print *HL 
	RET

HEXITS:	DB "0123456789ABCDEF"

M15:	DB " Main 32K ROM ", 0
M13:	DB " Main  8K ROM ", 0
M14:	DB "Multiplan ROM ", 0
CRCIS:	DB "CRC-16 = ", 0

HITAKEY: DB "        <Hit any key to exit.>", 0
PAUSING: DB "\r\eKPausing...", 0 	; Esc+K is clear to end of line



HIGHASCIITABLE:
	DW C128
	DW C129
	DW C130
	DW C131
	DW C132
	DW C133
	DB 0, 0
	DW CERR

C128:	DB "TRS-80 ", 0
C129:	DB "Model 100", 0
C130:	DB "Tandy ", 0
C131:	DB "Olivetti M10 ", 0
C132:	DB "NEC PC-", 0
C133:	DB "Kyocera Kyotronic 85", 0
CERR:	DB "Error in mkcrctable.awk", 0

QIDKYOTRONIC:	DB 133, 0
QIDTANDY200:	DB 130, "200", 0
QIDMODEL100:	DB 128, 129, 0
QIDTANDY102US:	DB 130, "102 (US)", 0
QIDTANDY102UK:	DB 130, "102 (UK)", 0
QIDM10EU:	DB 131, "(EU)", 0
QIDM10NA:	DB 131, "(NA)", 0
QIDPC8201A:	DB 132, "8201A", 0
QIDPC8300:	DB 132, "8300", 0
QIDBECKMAN:	DB 132, "8300 Beckman E3.2", 0
QIDTANDY600:	DB 130, "600 BASIC", 0
QIDTELEVERKET:	DB 128, "Televerket Modell 100", 0

QIDUNKNOWN:	DB "Unknown model", 0

QIDTABLE:
	DB 35, 35
	DW QIDM10EU
	DB 51, 83
	DW QIDMODEL100
	DB 72, 209
	DW QIDBECKMAN
	DB 125, 205
	DW QIDM10NA
	DB 144, 254
	DW QIDTANDY600
	DB 148, 101
	DW QIDPC8201A
	DB 148, 235
	DW QIDPC8300
	DB 167, 83
	DW QIDTANDY102US
	DB 167, 96
	DW QIDTANDY102UK
	DB 171, 9
	DW QIDTANDY200
	DB 225, 194
	DW QIDKYOTRONIC
	DB 167, 123
	DW QIDTELEVERKET

	DB 0, 0
	DW QIDUNKNOWN

	include "crctable.asm"	; Mapping from CRC16 to ROM variant names

	
