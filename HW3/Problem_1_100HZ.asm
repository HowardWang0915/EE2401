		; 100HZ	, 5000us per half clock cycle
		MOV	TMOD, 	#01H	; T0 16-bit mode
	LOOP:	MOV	TH0, 	#0ECH	; 2us
		MOV	TL0, 	#084H	; 2us
		SETB	TR0		; 1us
	WAIT:	JNB	TF0, 	$	; 2us, count 4898, 12us execution
		CLR 	TR0		; 1us
		CLR	TF0		; 1us
		CPL	P1.0		; 1us
		SJMP	LOOP		; 2us
					; total 5000us