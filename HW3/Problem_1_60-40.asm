		; 4kHZ	, the up cycle, for 150us
		MOV	TMOD, 	#01H	; T0 16-bit mode
	LOOP1:	MOV	TH0, 	#0FFH	; 2us
		MOV	TL0, 	#076H	; 2us
		SETB	TR0		; 1us
	WAIT1:	JNB	TF0, 	$	; 2us, count 138, 12us execution
		CLR 	TR0		; 1us
		CLR	TF0		; 1us
		CPL	P1.0		; 1us
		SJMP	LOOP2		; 2us
					; total 5000us
		; 4kHZ	, the down cycle for 100us
	LOOP2:	MOV	TH0, 	#0FFH	; 2us
		MOV	TL0, 	#0A8H	; 2us
		SETB	TR0		; 1us
	WAIT2:	JNB	TF0, 	$	; 2us, count 88, 12us execution
		CLR 	TR0		; 1us
		CLR	TF0		; 1us
		CPL	P1.0		; 1us
		SJMP	LOOP1		; 2us
					; total 5000us