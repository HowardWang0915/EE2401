		; 50kHZ, 5us per half cycle
LOOP:		SETB	P1.0	; 1us
		NOP		; 1us
		NOP		; 1us
		NOP		; 1us
		NOP		; 1us, the first half cycle
		CLR	P1.0	; 1us
		NOP		; 1us
		NOP		; 1us
		SJMP	LOOP	; 2us