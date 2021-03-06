CR	EQU	0DH	; carriage return
NC	EQU	00H	; null character
		MOV	SCON, 	#70H	; mode1, SM2 = 1, REN = 1
		ANL	PCON,	#7FH	; SMOD = 0 for 9600 baud
		MOV	TMOD, 	#20H	; timer 1 mode 2 for baud rate
MAIN:		MOV	TL1, 	#0FDH	; 9.6Kbps
		MOV	TH1, 	#0FDH	; auto reload
		SETB	TR1		; start t1
		MOV	R0, 	#60H	; initialize pointer
		LCALL	INLINE		; recieve
		MOV	R0, 	#60	; initial pointer after recieve
		LCALL	OUTSTR
		SJMP	MAIN

INLINE:		LCALL	INCHR
		CJNE	R0, #87H,INRANGE ; check if out of range
		SJMP	NULL
INRANGE:		CJNE	A, #CR, KEEPGOIN
NULL:		MOV	A, 	#0	; assign null character
		MOVX	@R0, 	A	; to buffer
		RET

INCHR:		JNB	RI, 	$	; is the system ready?
		CLR	RI		; stop interrupt
		MOV	A, 	SBUF	; move the recieve data to acc
		MOV	C, 	P
		CPL	C
		CLR	A.7
		RET
KEEPGOIN:	MOVX	@R0, 	A	; a valid character, store in reg
		INC	R0		; point to the next address
		AJMP	INLINE		; input next word

OUTSTR:		MOVX	A, 	@R0
		INC	R0
		CJNE	A, #00H, KEEPGOUT ; check if null
		MOV	A, 	#CR	; if null, send CR
		LCALL	OUTCHR		; send
		RET
KEEPGOUT:	LCALL	OUTCHR		; send char
		AJMP	OUTSTR		; continue
OUTCHR:		MOV	C, 	P	; parity bit in C
		CPL	C		; change to odd parity
		MOV	A.7, 	C	; add to character
		JNB	TI,	$	; is system ready to transmit?
		CLR	TI		; disable interrupt
		MOV	SBUF, 	A	; output the datas
		CLR	A.7		; strip off parity bit
		RET
		end