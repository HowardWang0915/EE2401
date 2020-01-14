		MOV	P1, 	#00H	; clear port 1 for display
		MOV	P3,	#0FFH	; clear port 3 for select
MAIN:		MOV	A, 	31H
		ANL	A, 	#0FH	; strip the high nibble
		MOV	R0, 	A	; put the 31H low nibble into R0
		MOV	A, 	31H	; this time for the higher nibble
		ANL	A, 	#0F0H	; strip the lower nibble
		SWAP	A
		MOV	R1, 	A	; put the 30H high nibble into R1
		MOV	A, 	30H
		ANL	A, 	#0FH	; strip the high nibble
		MOV	R2, 	A	; put the 30H low nibble into R2
		MOV	A, 	30H	; this time for the higher nibble
		ANL	A, 	#0F0H	; strip the lower nibble
		SWAP	A
		MOV	R3, 	A	; put the 32H high nibble into R3

		MOV	DPTR, 	#LOOKUP	; load to the lookup table
DISPLAY:		MOV	A, 	R3
		MOVC	A, 	@A+DPTR	; Lookup the display table
		MOV	P1, 	A	; output display to p1
		CLR	P3.4		; activates display of R3
		LCALL	DELAY		; the time for scanning
; first digit finished, prepare for second digit
		SETB	P3.4				;deactivate display of R3
		MOV	A, 	R2
		MOVC	A, 	@A+DPTR	; Lookup the display table
		MOV	P1, 	A	; output display to p1
		CLR	P3.5		; activates display of R2
		LCALL	DELAY		; the time for scanning
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
		MOV	P3,	#0FFH	; deactivate all select
		AJMP	MAIN
; delay for 8 us for scanning
DELAY:		MOV	R4, 	#02H		; 2
DEL1:		MOV	R5, 	#02H		; 2
DEL2:		DJNZ	R5, 	DEL2		; 2
		DJNZ	R4, 	DEL1	; 2 * 2 * 2 = 8
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
		DB	088H
		DB	083H
		DB	0C6H
		DB	0A1H
		DB	086H
		DB	08EH
		end
