		MOV	SCON,	#52H	; mode 2, SM2 = 0, REN = 1
		ANL	PCON, 	#72H	; SMOD = 0
		MOV	R0, 	#20H	; initialize pointer

INPUT:		CJNE	R0,#26H, NEXT1	; input done, continue to output
		SJMP	OUTPUT
NEXT1:		; sending address bit to input slaves
		SETB	TB8		; send adrres bit mode
		JNB	TI, 	$	; TX empty?
		CLR	TI		; start transmission
		MOV	SBUF, 	R0	; move the current slave id into sbuf
		; recieving data from the input slaves
		JNB	RI, 	$	; RX empty?
		CLR	RI		; start recieving
		MOV	@R0, 	SBUF	; store it to the register where R0 is pointing to
		INC	R0		; point to next register
		LJMP	INPUT		; repeat until all input port recieved

OUTPUT:		CJNE	R0, #2CH,	NEXT2	; output done, continue to input
		SJMP	INPUT
		; sending address bit to select output slaves.
NEXT2:		SETB	TB8		; send address bit mode
		JNB	TI, 	$	; TX empty?
		CLR	TI		; start transmission
		MOV	SBUF, 	R0	; send the current slave id into sbuf
		; sending data to correspnding output slave
		CLR	TB8		; send data mode
		JNB	TI,	$	; TX ready?
		CLR	TI		; start transmission
		MOV	SBUF,	@R0	; send the output datas to output slave
		INC	R0		; point to next position
		LJMP	OUTPUT		; repeat until all output datas are outputed
		end