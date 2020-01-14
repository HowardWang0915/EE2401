		MOV	SCON, 	#12H	; mode 0, SM2 = 0, REN = 1
; ***********************************************************************************
; Using 16 extra input ports, we have to use 74165 to convert the parallel data to serial
; and then store it in 22H and 23H
;**************************************************************************************
		SETB	P1.0		; parallel load from 74165
		CLR	P1.1		; disable parallel load from 74675
; start transmit to 20H
INPUTDATA:	JNB	RI, 	$	; RX ready?
		CLR 	RI
		CLR	P1.0		; shift output to 8051
		MOV	22H, 	SBUF	; move the input data to 20H
; start transmit to 21H
		JNB	RI, 	$	;  TX ready?
		CLR	RI
		MOV	23H, 	SBUF	; move the input data to 21H
;*****************************************************************************************
; Using 16 extra output ports, we have to use 74675 to convert the serial data from the 
; 8051 to 16 output parallel form.
;***************************************************************************************** 
OUTPUTDATA:	CLR	P1.1		; disable parallel load from 74675
; send out 20H
		JNB	TI, 	$
		CLR	TI
		MOV	SBUF, 	20H	; send output data
; send out 21H
		JNB	TI, 	$	; TX ready?
		CLR 	TI
		MOV	SBUF, 	21H	; send output data
		SETB	P1.1		; Enable parallel load to 74675 to send out data
		LJMP	INPUTDATA