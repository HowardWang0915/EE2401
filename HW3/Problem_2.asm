;****************************************************************
MONITOR	CODE 	00BCH 	; MON51 (V12) entry point
COUNT 	EQU 	0EC78H 	; 0.05 seconds per timeout
REPEAT 	EQU 	5 	; 5 x 0.05 = 0.25 seconds/note
;****************************************************************
; Note: X3 not installed on SBC-51, therefore
; interrupts directed to the following jump table
; beginning at 0000H
;***************************************************************

		ORG 	0000H 	; RAM entry points for...
		LJMP 	MAIN 	; main program
		ORG	0003H
		LJMP 	EXT0ISR 	; External 0 interrupt
		ORG	000BH
		LJMP 	T0ISR 	; Timer 0 interrupt
		ORG	0013H
		LJMP  	EXT1ISR 	;External 1 interrupt
		ORG	001BH
		LJMP 	T1ISR 	;Timer 1 interrupt
		ORG	0023H
		LJMP 	SPISR 	;Serial Port interrupt
		ORG	002BH
		LJMP 	T2ISR 	;Timer 2 interrupt


;****************************************************************
; MAIN PROGRAM BEGINS
;****************************************************************
MAIN: 		MOV 	TMOD,	#11H 	;both timers 16-bit mode
		MOV 	R7,	#0 	;use R7 as note counter
		MOV 	R6,	#REPEAT 	;use R6 as timeout counter
		MOV 	IE,	#8AH 	;Timer 0 & 1 interrupts on
		SETB 	TF1 		;force Timer 1 interrupt
		SETB 	TF0 		;force Timer 0 interrupt
		SJMP 	$ 		;ZzZzZzZz time for a nap

;****************************************************************
; TIMER 0 INTERRUPT SERVICE ROUTINE (EVERY 0.05 SEC.)
;****************************************************************
T0ISR: 		CLR 	TR0 		;stop timer
		MOV 	TH0,	#HIGH (COUNT) ;reload
		MOV 	TL0,	#LOW (COUNT)
		DJNZ 	R6,	EXIT 	;if not 5th int, exit
		MOV 	R6,	#REPEAT 	;if 5th, reset
		INC 	R7 		;increment note
		CJNE 	R7,#LENGTH,EXIT 	;beyond last note?
		MOV 	R7,	#0 	;yes: reset, A=440 Hz
EXIT: 		SETB 	TR0 		;no: start timer, go
		RETI 			;back to ZzZzZzZ

;****************************************************************
; TIMER 1 INTERRUPT SERVICE ROUTINE (PITCH OF NOTES)
;
; Note: The output frequencies are slightly off due
; to the length of this ISR. Timer reload values
; need adjusting.
;****************************************************************
T1ISR: 		CPL 	P1.7	 	;music maestro!
		CLR 	TR1 		;stop timer
		MOV 	A,	R7 	;get note counter
		RL 	A 		;multiply (2 bytes/note)
		CALL 	GETBYTE 		;get high-byte of count
		MOV 	TH1,	A 	;put in timer high register
		MOV 	A,	R7 	;get note counter again
		RL 	A 		;align on word boundary
		INC 	A 		;past high-byte (whew!)
		CALL 	GETBYTE 		;get low-byte of count
		MOV 	TL1,	A 	;put in timer low register
		SETB 	TR1 		;start timer
		RETI 			;time for a rest
;****************************************************************
; GET A BYTE FROM LOOK-UP OF NOTES IN A MAJOR SCALE
;****************************************************************
GETBYTE: 	INC 	A 		;table look-up subroutine
		MOVC 	A,	@A+PC
		RET
TABLE: 		DW 	0F887H 		;C
		DW 	0F95AH 		;D
		DW 	0FA14H 		;E
		DW 	0FA69H 		;F
		DW 	0FB05H		;G
		DW 	0FB90H		;A
		DW 	0FC0CH 		;B
LENGTH 		EQU 	7 		;LENGTH = # of notes

;****************************************************************
; UNUSED INTERRUPTS - BACK TO MONITOR PROG (ERROR)
;****************************************************************
EXT0ISR:
EXT1ISR:
SPISR:
T2ISR: 		CLR 	EA 		; shut off interrupts and
		LJMP 	MONITOR 		; return to MON51
		END