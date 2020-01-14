		ORG	00H		; initial starting address
TOGGLE0:	JNB	P3.3,	TOGGLE0
TOGGLE1:	JB	P3.3,	TOGGLE1
TOGGLE2:	JNB	P3.3, 	TOGGLE2
		MOV	P1, 	#00H	; clear port 1
		MOV	P3,	#0FFH	; clear port 3 for select
		MOV	R0, 	#09H	; initial each counting bits
		MOV	R1, 	#09H
		MOV	R2, 	#09H
		MOV	R3, 	#09H
		MOV	DPTR, 	#LOOKUP	; load to the lookup table
DISPLAY:	MOV	A, 	R3
		MOVC	A, 	@A+DPTR	; Lookup the display table
		MOV	P1, 	A	; output display to p1
		CLR	P3.4		; activates display of R3
		LCALL	DELAY		; the time for scanning
; first digit finished, prepare for second digit
		SETB	P3.4		;deactivate display of R3
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
		MOV	P3,	#0FFH	; deactive all select
		SJMP	COUNTING	; counting part

; delay for 1 ms for scanning
DELAY:		MOV	R4, 	#01H	; 2
DEL1:		MOV	R5, 	#01H	; 250, 0FAH
DEL2:		DJNZ	R5, 	DEL2	;
		DJNZ	R4, 	DEL1	; 250 * 4 = 1000
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
; count check if the lower bit is zero
COUNTING:	CJNE	R0,#00H,	DEC1
		CJNE	R1,#00H,	DEC10
		CJNE	R2,#00H,	DEC100
		CJNE	R3,#00H,	DEC1000
		SJMP	end
DEC1:		DEC	R0
		AJMP	DISPLAY
DEC10:		DEC	R1
		MOV	R0, 	#09H
		AJMP	DISPLAY
DEC100:		DEC	R2
		MOV	R1, 	#09H
		MOV	R0, 	#09H
		AJMP	DISPLAY
DEC1000:	DEC	R3
		MOV	R2, 	#09H
		MOV	R1, 	#09H
		MOV	R0, 	#09H
		AJMP	DISPLAY
end:		end