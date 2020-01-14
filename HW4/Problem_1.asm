;**********************************************************************************
; KEYPAD INTERFACE EXAMPLE
;
; This program reads hexadecimal characters from a
; keypad attached to Port 1 and echoes keys pressed
; to the console.
;**********************************************************************************

HTOA		EQU	003CH		; MON51 subroutines
OUTCHR		EQU	01DEH		;

		ORG	0000H		; put main in reset ISR
MAIN:		CALL	IN_HEX		; get hex code from key pad
		CALL	OUTCHR		; echo to VDT console
		SJMP	MAIN		; repeat

;*************************************************************************
; IN_HEX - input hex code from keypad with debouncing
; for key press and key release (50 repeat
; operations for each)
;*************************************************************************
IN_HEX:		MOV	R3, 	#2	; debounce count
BACK:		CALL	GET_KEY		; key pressed? C = 1 yes, C = 0 No
		JNC	IN_HEX		; no, check again
		DJNZ	R3, 	BACK	; yes, repeat 50 times for debouncing
		PUSH	ACC		; save hex code

BACK2:		MOV	R3, 	#2	; wait for key up
BACK3:		CALL	GET_KEY		; key still pressed?
		JC	BACK2		; yes: keep checking
		DJNZ	R3, 	BACK3	; no, key released, repeat 50 times debouncing
		POP	ACC		; recover hex code and
		RET			; return


;*******************************************************************
; GET_KEY - get keypad status
; - return with C = 0 if no key pressed
; - return with C = 1 and hex code in ACC if
; a key is pressed
;********************************************************************
GET_KEY:		MOV	A, 	#0FEH	; start with column 0 "1111 1110"
		MOV	R6, 	#4	; use R6 as column counter

TEST:		MOV	P0, 	A	; activate column line
		MOV	R7, 	A	; save column info in ACC
		MOV	A, 	P0	; read back Port 0
		ANL	A, 	#0F0H	; isolate row lines (column turn into 0)
		CJNE	A, #0F0H, KEY_HIT	; row line active?
		MOV	A, 	R7	; no: move to next
		RL	A
		DJNZ	R6, 	TEST	; keep checking until all columns check

		CLR	C		; no key pressed
		SJMP	EXIT		; return with C = 0
; if found a key dowm
KEY_HIT:		MOV	R7, 	A	; save scan code in R7
		MOV	A, 	#4	; prepare to convert to hex code
		CLR	C		; column weighting
		SUBB	A, 	R6	; 4 - R6 = column number 0-3
		MOV	R6, 	A	; save in R6
		MOV	A, 	R7	; restore scan code
		SWAP	A		; put in low nibble
		MOV	R5, 	#4	; use R5 as counter
AGAIN:		RRC	A		; rotate for row num until 0
		JNC	DONE		; done when C = 0
		INC	R6		; add 4 to keycode to goto next
		INC	R6		; row until active low found
		INC	R6
		INC	R6
		DJNZ	R5, 	AGAIN
DONE:		SETB	C		; C = 1 (key passed)
		MOV	A, 	R6	; hex code in A
EXIT:		RET
;***********************************************************************
; SSD
; This function will convert the lcd pad signal to seven segmen display
;*********************************************************************
OUTCHR:
; First get the DIP input
start:		JB 	A.0, 	bxxx1
		JB	A.1, 	bxx10
		JB 	A.2, 	bx100
		JB 	A.3, 	HEX7		; this indicates the input is 8, and so on…
		SJMP	HEX1
bxxx1:		JB	A.1, 	bxx11
		JB	A.2, 	bx101
		JB	A.3, 	HEX8
		SJMP	HEX2
bxx10:		JB	A.2, 	bx110
		JB	A.3, 	HEX9
		SJMP	HEX3
bxx11:		JB	A.2, 	bx111
		JB	A.3, 	HEXC
		SJMP	HEXA
bx100:		JB	A.3,	HEXE
		SJMP	HEX4
bx101:		JB	A.3, 	HEX0
		SJMP	HEX5
bx110:		JB	A.3, 	HEXF
		SJMP	HEX6
bx111:		JB	A.3, 	HEXD
		SJMP	HEXB
; Lookups
; These are the output to the seven segments
HEX0:		MOV	P1, 	#0C0H
		RET
HEX1:		MOV	P1, 	#0F9H
		RET
HEX2:		MOV 	P1, 	#0A4H
		RET
HEX3:		MOV	P1, 	#0B0H
		RET
HEX4:		MOV	P1, 	#99H
		RET
HEX5:		MOV	P1, 	#92H
		RET
HEX6:		MOV	P1, 	#82H
		RET
HEX7:		MOV	P1, 	#0F8H
		RET
HEX8:		MOV	P1, 	#80H
		RET
HEX9:		MOV	P1, 	#90H
		RET
HEXA:		MOV	P1, 	#88H
		RET
HEXB:		MOV	P1, 	#83H
		RET
HEXC:		MOV	P1, 	#0C6H
		RET
HEXD:		MOV	P1, 	#0A1H
		RET
HEXE:		MOV	P1, 	#86H
		RET
HEXF:		MOV	P1, 	#08EH
		RET
		end

