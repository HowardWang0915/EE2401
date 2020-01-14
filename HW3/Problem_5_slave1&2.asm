; This program is for input slave. It will first recieve the id from the master and send the input 	  datas to the master
		; initialize
		MOV	SCON, 	#72H	; mode 2, SM2 = 1 for RB8, REN = 1
		ANL	PCON,	#7FH	; SMOD = 0
		; start to recieve slave id
INPUT:		JNB	RI, 	$	; RX empty?
		CLR	RI		; start recieving
		MOV	A, 	SBUF	; recieve slave ID
		CJNE	A, #20H, 	MEM21	; if not correct id, check next port
		; correct id, start to transmit to master
		JNB	TI, 	$	; TX ready?
		CLR	TI
		MOV	SBUF,	P0	; start to transmit data from p0
		LJMP	INPUT
MEM21:		CJNE	A, #21H, 	MEM22	; if not correct id, check next port
		JNB	TI, 	$	; correct id,TX ready?
		CLR	TI
		MOV	SBUF,	P1	; send data from p1
		LJMP	INPUT
MEM22:		CJNE	A, #22H, 	INPUT	; if all id don't match, recieve a new id
		JNB	TI,	$	; TX ready?
		CLR	TI		; start to tranmit
		MOV	SBUF, 	P2	; correct id, send p2 to master
		SJMP	INPUT		; recive a new ID