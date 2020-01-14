		MOV	P1, 	#00H		; clear port 1 for display
		MOV	P3,	#0FFH		; clear port 3 for select
		MOV	DPTR, 	#LOOKUP		; load to the lookup table

MAIN:		MOV	A, 	31H
		MOV	B, 	#0AH	; 10, to divide
		DIV	AB		; for minute display
		MOV	R0, 	B	; put the 31H low nibble into R0
		MOV	R1, 	A	; put the 30H high nibble into R1
		MOV	A, 	30H
		MOV	B, 	#0AH	; 10, to divide
		DIV	AB
		MOV	R2, 	B	; put the 30H low nibble into R2
		MOV	R3, 	A	; put the 32H high nibble into R3

DISPLAY:		MOV	A, 	R3
		MOVC	A, 	@A+DPTR		; Lookup the display table
		MOV	P1, 	A		; output display to p1
		CLR	P3.4			; activates display of R3
		LCALL	DELAY			; the time for scanning
; first digit finished, prepare for second digit
		SETB	P3.4			;deactivate display of R3
		MOV	A, 	R2
		MOVC	A, 	@A+DPTR		; Lookup the display table
		MOV	P1, 	A		; output display to p1
		CLR	P3.5			; activates display of R2
		LCALL	DELAY			; the time for scanning
; second digit finished, prepare for third digit
		SETB	P3.5
		MOV	A, 	R1
		MOVC	A, 	@A+DPTR
		MOV	P1, 	A
		CLR	P3.6
		LCALL	DELAY
; third digit finished, prepare for the last digit
		SETB	P3.6
		MOV 	A, 	R0
		MOVC	A, 	@A+DPTR
		MOV	P1, 	A
		CLR	P3.7
		LCALL	DELAY
; all finished prepare to return
		MOV	P3,	#0FFH		; deactivate all select
		SJMP	COUNTING			; jump to counting part
; delay for 8 us for scanning
DELAY:		MOV	R4, 	#01H		; 1
DEL1:		MOV	R5, 	#01H		; 1
DEL2:		DJNZ	R5, 	DEL2		; 2
		DJNZ	R4, 	DEL1		; 1 * 1 * 2 = 2
		RET
; lookup table
LOOKUP:
		DB 	0C0H		; 0
		DB	0F9H		; 1
		DB	0A4H		; 2
		DB	0B0H		; 3
		DB	099H		; 4
		DB	092H		; 5
		DB	082H		; 6
		DB	0F8H		; 7
		DB	080H		; 8
		DB	090H		; 9
; count check if satiisfy carry conditions (60 second 60 minutes 24 hour)
COUNTING:	MOV	A, 	32H
		CJNE	A,#59D,	ADD1SEC	; add 1 second
		MOV	A, 	31H
		CJNE	A,#59D,	ADD1MIN	; add 1 minute
		MOV	A, 	30H
		CJNE	A,#23D,	ADD1HOU	; add 1 hour
		SJMP 	RES			; 24 hours passed, reset
ADD1SEC:		INC	32H
		AJMP	MAIN
ADD1MIN:		INC	31H
		MOV	32H, 	#00H
		AJMP	MAIN
ADD1HOU:		INC	30H
		MOV	31H, 	#00H
		MOV	32H, 	#00H
		AJMP	MAIN
RES:		MOV	30H, 	#00H
		MOV	31H, 	#00H
		MOV	32H, 	#00H
		AJMP	MAIN
		end