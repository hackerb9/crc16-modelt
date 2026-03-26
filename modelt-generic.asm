;;; modelt-generic.asm

;;; This routine can be called from BASIC to get a checksum for any
;;; buffer region. 

;;; Usage:
;;; 	CLEAR 256,60000: LOADM"GENCRC.CO"
;;; 	i%[0] = buffer start address
;;; 	i%[1] = buffer length
;;; 	i%[2] = 0 (initial checksum / result) 
;;; 	call 60000, 0, varptr(i%[0])
;;; 	?i%[2]
;;;
;;; Note that a large file can be processed in blocks by simply
;;; leaving the result in i%[2] instead of resetting it to zero.
;;;
;;; See also: crcbas.do for a version of this which uses VARPTR to run
;;; out of a string instead of loading to a fixed address.

	.8085			; Hint to asmx

;; Macro "HDR" generates 6-byte Model-T .CO header: 
;; * START - Where the program is ORG'd to run from.
;; * LENGTH - Size of executable data sans this 6 byte header.
;; * ENTRY - Where the program will be entered (entry point).
;; Executable data - 8085 machine code ORG'ed at START.
HDR:	MACRO 	P1
	DW 	P1, ENDP-BEGINP, 0 	; 0 = not directly executable
	RORG	P1
	ENDM

	ORG	60000
	HDR	60000
BEGINP:	

MAIN:	
	; HL is pointer to array of three ints
	;; address, length, initial/result
	MOV	E, M		; DE = address of buffer to checksum
	INX	H
	MOV	D, M
	INX	H
	MOV	C, M		; BC = length of buffer 
	INX	H
	MOV	B, M
	INX	H
	PUSH 	H
	MOV	A, M
	INX	H
	MOV	H, M
	MOV	L, A

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
	XCHG
	POP	H
	MOV 	M, E
	INX	H
	MOV 	M, D
	RET

ENDP
