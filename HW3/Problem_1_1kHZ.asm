		; 1kHZ	, 500us per half clock cycle
		MOV	TMOD, 	#01H	; T0 16-bit mode
	LOOP:	MOV	TH0, 	#0FEH	; 2us
		MOV	TL0, 	#018H	; 2us
		SETB	TR0		; 1us
	WAIT:	JNB	TF0, 	$	; 2us, count 448, 12us execution
		CLR 	TR0		; 1us
		CLR	TF0		; 1us
		CPL	P1.0		; 1us
		SJMP	LOOP		; 2us
					; total 500us