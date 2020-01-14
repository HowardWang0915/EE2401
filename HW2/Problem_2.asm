start:		JB	P1.1,	bxxxxx1	; start from looking at P1.1
		JNB	P1.3,	bxxx0x0
		JNB	P1.5,	p0equa0
		JNB	P1.4, 	p0equa0
		SJMP	p0equa1
		
bxxxxx1:	JNB	P1.6,	b0xxxx1
		JNB	P1.3, 	p0equa0
		JNB	P1.5,	p0equa1
		JNB	P1.4, 	p0equa1
		SJMP	p0equa0
		
bxxx0x0:	JNB	P1.6, 	b0xx0x0
		JNB	P1.2, 	p0equa1
		SJMP	p0equa0
		
b0xx0x0:	JNB	P1.4, 	p0equa0
		SJMP	p0equa1
		
b0xxxx1:	JNB	P1.4, 	b0x0xx1
		JNB	P1.2, 	b0x0x01
		JNB	P1.3, 	p0equa0
		JNB	P1.5, 	p0equa0
		SJMP	p0equa1
		
b0x0xx1:	JNB	P1.2,	p0equa1
		JNB	p1.3, 	p0equa1
		SJMP	p0equa0
		
b0x0x01:	JNB 	P1.3, 	p0equa0
		JNB	P1.5, 	p0equa0
		SJMP	p0equa1

p0equa1:	SETB	P1.0		; assigns 1 to P1.0 and return back to start
		SJMP	start
		
p0equa0:	CLR	P1.0		; assigns 0 to P1.0 and return back to start
		SJMP	start
		end
