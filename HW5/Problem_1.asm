;*****************************************************************
; LCD interface
;
; This program continousl display on the LCD
; the ASCII characters are sotred in internal RAM
; locations 30H-70H
;*****************************************************************
		RS	EQU	P3.0		; RS = 0 command, RS = 1 data
		RW	EQU	P3.1		; RW = 1 read, RW = 0 write
		E	EQU	P3.2		; E = 1-to-0 enable LCD
		DBUS	EQU	P1		; D7 LCD busy status
		PTR	EQU	R0		; memory data pointer
		COUNT	EQU	R1

		ORG	0000H
		CALL	INIT			; initialize LCD
		CALL	NEW			; refresh LCD
		MOV 	COUNT, 	#32		; initialize char count
NEXT:		ACALL	GET_KEY			; read char from keypad
		JNC	NEXT			; C=0->no key pressed->read again
		ACALL	OUTCHR
		ACALL	DISP			; display on LCD
		DEC	COUNT			; count - 1
		MOV	A,	COUNT
		CJNE	A,#16,TEST1		; end of 1st line?
		ACALL	SEC_LINE			; yes, go to 2nd line
		SJMP	NEXT			; and go back to NEXT
TEST1:		CJNE	A,#0,NEXT	; end of 2nd line?
		MOV	COUNT,	#32	; yes, reinitialize char count
		ACALL	NEW		; and refresh LCD
		SJMP	NEXT		; go back to NEXT
;***************************************************************
; Initialize the LCD
;***************************************************************
INIT:		MOV	A, 	#38H		; 2lines, 5x7 dot matrix, command
		ACALL	WAIT			; wait for LCD to be free
		CLR	RS			; output a command
		ACALL	OUT			; send it out
		MOV	A, 	#0EH		; LCD on, cursor on, command
		ACALL	WAIT			; wait for LCD to be free
		CLR	RS			; output a command
		ACALL	OUT			; send it out
		RET
;***************************************************************
; DISP
; This function will display data on LCD
;***************************************************************
DISP:		ACALL	WAIT			; wait for LCD to be free
		SETB	RS			; output data mode
		ACALL	OUT			; send it out
		RET
;****************************************************************
; OUT
; This funtion will output command or data to LCD
;***************************************************************
OUT:		MOV	DBUS, 	A		; A will store the command / data
		CLR	RW			; write mode
		SETB	E			; send!
		CLR	E			; send finish
		RET
;***************************************************************
; NEW
; This function will refresh the LCD when all displayed
;***************************************************************
NEW:		MOV	A, 	#01H		; clear LCD, command
		ACALL	WAIT			; wait for LCD to be free
		CLR	RS			; output command mode
		ACALL	OUT			; send it out
		MOV	A, 	#80H		; cursor off, line1, pos1, command
		ACALL	WAIT			; and refresh LCD
		CLR	RS			; output command mode
		ACALL 	OUT			; sed it out
;****************************************************************
; WAIT
; Wait for LCD to be free
;****************************************************************
WAIT:		CLR	RS		; command
		SETB	RW		; read
		SETB	DBUS.7		; DB7 = input mode
		SETB	E		; get data from led
		CLR	E		; close LCD read
		JB	DBUS.7,	WAIT
		RET
;********************************************************************
; SEC_LINE
; start cusor at 2nd line
;********************************************************************
SEC_LINE:
		MOV	A,	#0C0H	; force cusor begining at 2nd line
		ACALL	WAIT		; wait for LCD to be free
 		CLR	RS		; output a command
		ACALL	OUT		; send it out
		RET
;*************************************************************************
; IN_HEX - input hex code from keypad with debouncing
; for key press and key release (50 repeat
; operations for each)
;*************************************************************************
;IN_HEX:		MOV	R3, 	#50	; debounce count
;BACK:		CALL	GET_KEY		; key pressed? C = 1 yes, C = 0 No
;		JNC	IN_HEX		; no, check again
;		DJNZ	R3, 	BACK	; yes, repeat 50 times for debouncing
;		PUSH	ACC		; save hex code
;
;BACK2:		MOV	R3, 	#50	; wait for key up
;BACK3:		CALL	GET_KEY		; key still pressed?
;		JC	BACK2		; yes: keep checking
;		DJNZ	R3, 	BACK3	; no, key released, repeat 50 times debouncing
;		POP	ACC		; recover hex code and
;		RET			; return


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
; These are the output of the ASCII code
HEX0:		MOV	A, 	#30H
		RET
HEX1:		MOV	A, 	#31H
		RET
HEX2:		MOV 	A, 	#32H
		RET
HEX3:		MOV	A, 	#33H
		RET
HEX4:		MOV	A, 	#34H
		RET
HEX5:		MOV	A, 	#35H
		RET
HEX6:		MOV	A, 	#36H
		RET
HEX7:		MOV	A, 	#37H
		RET
HEX8:		MOV	A, 	#38H
		RET
HEX9:		MOV	A, 	#39H
		RET
HEXA:		MOV	A, 	#41H
		RET
HEXB:		MOV	A, 	#42H
		RET
HEXC:		MOV	A, 	#43H
		RET
HEXD:		MOV	A, 	#44H
		RET
HEXE:		MOV	A, 	#45H
		RET
HEXF:		MOV	A, 	#46H
		RET
		end