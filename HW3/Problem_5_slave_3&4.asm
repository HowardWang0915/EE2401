; This program is for output slaves. It will recieve the slave id from the master and if id matched. If id matched, it will recieve the data from the mastrer and act as a output port of the master.
		MOV	SCON, 	#70H	; mode 2, SM2 = 1 for RB8, REN = 1
		ANL	PCON, 	#7FH	; SMOD = 0
		; recieve slave id from master
OUTPUT:		JNB	RI, 	$	; RX ready?
		CLR	RI		; start recieving
		MOV	A, 	SBUF	; get id
		CJNE	A, #26H, MEM27	; jump if not correct id
		; if right slave, start to recieve the output datas from the master
		CLR	SM2		; recieve data mode
		JNB	RI, 	$	; RX ready?
		CLR	RI		; start reciving
		MOV	P0, 	SBUF	; put recived output into output port
		SETB	SM2		; output recieved, prepare to listen to the next addres
		LJMP	OUTPUT

MEM27:		CJNE	A, #27H, MEM28	; jump if not correct id
		; if right slave, start to recieve the output datas from the master
		CLR	SM2		; recieve data mode
		JNB	RI, 	$	; RX ready?
		CLR	RI		; start reciving
		MOV	P1, 	SBUF	; put recived output into output port
		SETB	SM2		; output recieved, prepare to listen to the next addres
		LJMP	OUTPUT

MEM28:		CJNE	A, #28H, OUTPUT	; all id not match, listen to the master again
		; if right slave, start to recieve the output datas from the master
		CLR	SM2		; recieve data mode
		JNB	RI, 	$	; RX ready?
		CLR	RI		; start reciving
		MOV	P1, 	SBUF	; put recived output into output port
		SETB	SM2		; output recieved, prepare to listen to the next addres
		LJMP	OUTPUT

