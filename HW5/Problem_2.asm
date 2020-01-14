		DQ   	EQU 	P1.0
		CLK  	EQU 	P1.1
		RST  	EQU	P1.2
		THI  	EQU 	P1.3
		TLO  	EQU 	P1.4
		TCOM 	EQU 	P1.5
		FURN 	EQU 	P1.6

		ORG 	0000H
		CLR 	FURN

CONF:		SETB 	RST		; initiate transfer
		MOV 	A, 	#0CH	; write config
		ACALL 	SEND		; send to DS1620
		MOV 	A, 	#0AH	; CPU = 1, 1-SHOT = 0
		ACALL 	SEND		; send to DS1620
		CLR 	RST		; stop transfer

		SETB 	RST		; initiate transfer
		MOV 	A, 	#01H	; write TH
		ACALL 	SEND		; send to DS1620
		MOV 	A, 	#48	; 48 * 0.5 = 24 deg.c
		ACALL 	SEND_TEMP	; send to DS 1620
		CLR 	RST		; stop transfer

		SETB 	RST
		MOV 	A, 	#02H	;write TL
		ACALL 	SEND
		MOV 	A, 	#32	;32 *0.5 = 16 deg.c
		ACALL 	SEND_TEMP
		CLR 	RST		; stop transfer

CONV:		SETB 	RST		; initiate transfer
		MOV 	A, 	#0EEH	; start temperature sensing
		ACALL 	SEND		; send
		CLR 	RST		; stop transfer

SENS:		SETB	RST
		MOV 	A, 	#0AAH	; read temperature
		ACALL	SEND
		ACALL 	READ
		JB 	THI, 	OFF	; if T >= 24 degrees, off
		JB 	TLO, 	ON	; if T <= 16 degrees, on
CONTINUE:	CLR	RST
		SJMP 	SENS		; loop

OFF:		CLR 	FURN		; turn furnance off
		SJMP 	CONTINUE		; keep sensing

ON:		SETB 	FURN		; turn furnance on
		SJMP 	CONTINUE		; keep sensing
;********************************************************
; This subroutine sends a byte of command or data to the
; DS1620
;********************************************************

SEND:		MOV 	R0, 	#08H	; use R0 as counter

NEXT:		CLR 	CLK		; start clock cycle
		RRC 	A		; rotate A into C, LSB first
		MOV 	DQ, 	C	; send out bit to DQ
		SETB 	CLK		; complete the clock cycle
		DJNZ 	R0, 	NEXT	; process next bit
		RET

READ:		MOV 	R1, 	#09H

NEXT1:		CLR 	CLK
		MOV 	C, 	DQ
		RRC 	A
		SETB 	CLK
		DJNZ 	R1, 	NEXT1
		MOV 	30H, 	A
		CLR 	CLK
		MOV 	C, 	DQ
		RRC 	A
		SETB 	CLK
		MOV	31H, 	A
		RET

SEND_TEMP:	MOV	R2, 	#09H

NEXT2:		CLR	CLK
		RRC	A
		MOV	DQ, 	C
		SETB	CLK
		DJNZ	R2, 	NEXT2
		RET
		END