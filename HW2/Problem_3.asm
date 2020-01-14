start:		JB 	P3.4, 	bxxx1
		JB	P3.5, 	bxx10
		JB 	P3.6, 	bx100
		JB 	P3.7, 	HEX8		; this indicates the input is 8, and so on…
		SJMP	HEX0
bxxx1:		JB	P3.5, 	bxx11
		JB	P3.6, 	bx101
		JB	P3.7, 	HEX9
		SJMP	HEX1
bxx10:		JB	P3.6, 	bx110
		JB	P3.7, 	HEXA
		SJMP	HEX2
bxx11:		JB	P3.6, 	bx111
		JB	P3.7, 	HEXB
		SJMP	HEX3
bx100:		JB	P3.7,	HEXC
		SJMP	HEX4
bx101:		JB	P3.7, 	HEXD
		SJMP	HEX5
bx110:		JB	P3.7, 	HEXE
		SJMP	HEX6
bx111:		JB	P3.7, 	HEXF
		SJMP	HEX7
; Lookups
; These are the output to the seven segments
HEX0:		MOV	P1, 	#0C0H
		SJMP	start
HEX1:		MOV	P1, 	#0F9H
		SJMP	start
HEX2:		MOV 	P1, 	#0A4H
		SJMP	start
HEX3:		MOV	P1, 	#0B0H
		SJMP	start
HEX4:		MOV	P1, 	#99H
		SJMP	start
HEX5:		MOV	P1, 	#92H
		SJMP	start
HEX6:		MOV	P1, 	#82H
		SJMP	start
HEX7:		MOV	P1, 	#0F8H
		SJMP	start
HEX8:		MOV	P1, 	#80H
		SJMP	start
HEX9:		MOV	P1, 	#90H
		SJMP	start
HEXA:		MOV	P1, 	#88H
		SJMP	start
HEXB:		MOV	P1, 	#83H
		SJMP	start
HEXC:		MOV	P1, 	#0C6H
		SJMP	start
HEXD:		MOV	P1, 	#0A1H
		AJMP	start
HEXE:		MOV	P1, 	#86H
		AJMP	start
HEXF:		MOV	P1, 	#08EH
		AJMP	start
		end
