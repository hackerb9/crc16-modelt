;;; modelt-generic.asm

;;; A routine which can be called from BASIC to get a checksum for any
;;; buffer region.
;;; Usage:
;;; 	CALL 60003, 0, buffer-address
;;; 	CALL 60006, 0, buffer-length
;;; 	CALL 60000
;;; 	?PEEK(60009)+256*PEEK(60010)

	.8085			; Hint to asmx

;; Macro "HDR" generates 6-byte Model-T .CO header: 
;; * START - Where the program is ORG'd to run from.
;; * LENGTH - Size of executable data sans this 6 byte header.
;; * ENTRY - Where the program will be entered (entry point).
;; Executable data - 8085 machine code ORG'ed at START.
HDR:	MACRO 	P1
	DW 	P1, ENDP-BEGINP, P1
	RORG	P1
	ENDM

	ORG	60000			; Use CLEAR 255,60000
	HDR	60000
BEGINP:	

	;; Jump table for passing values to this routine
	JP	MAIN
	JP	SETADDR
	JP	SETLEN

RESULT	DW	0000h		; place to store return result.
SVDE	DW	0000h		; stash DE since CALL only sets HL.
SVBC	DW	00FFh		; likewise for BC.

SETADDR:
	SHLD	(SVDE)
	RET

SETLEN:
	SHLD	(SVBC)
	RET

MAIN:	
	XCHG			; Stash HL ( = initial checksum)
	LHLD	(SVBC)		; BC = length of buffer to checksum
	MOV	B, H
	MOV	C, L
	LHLD	(SVDE)
	XCHG			; DE = address of buffer to checksum

;;; What follows is mostly a cut and paste from crc16-pushpop.asm
CRC16_MAINLOOP:
	LDAX 	D		; Get each byte from memory
	XRA 	H		; XOR the high byte of the checksum
	MOV 	H, A
	
	PUSH 	D
	MVI 	D, 8
BITLOOP:	
	DAD 	H	 ; Add HL to HL (shift CRC left, pushes bit 15 to Carry)
	JNC 	NEXTBIT	 ; If Carry is clear, skip XOR.
	; XOR HL with Xmodem's polynomial (1021H).
	MOV 	A,H
	XRI 	10H
	MOV 	H,A
	MOV	A,L
	XRI	21H
	MOV	L,A
NEXTBIT:	
	DCR	D
	JNZ	BITLOOP
	POP	D

DONE8BITS:	
	;;; Done with all 8 bits, get next byte
	INX	D		; DE points to next byte 
	DCX	B		; BC is length of buffer remaining
	MOV	A,B
	ORA	C
	JNZ	CRC16_MAINLOOP	; Keep going until BC is 0

	;; End of CRC-16 routine. Result is in HL.
	SHLD	(RESULT)
	RET

ENDP
