
@ Code section
.section .text


.global printNum
printNum:
	push    {r4-r10, lr}
	mov 	r4, r0			@load value to print
	mov 	r5, r4
	mov 	r6, r1			@load x point
	mov	r7, r2			@load y point
	mov	r8, r3			@load color
	mov	r9, #100
	mov 	r10, #0
	printLoop:	
		mov r10, #0
		//check for a 100 digit
		calcHundLoop:
			cmp r5, #100
			blt doneHundLoop
			sub r5, #100
			add r10, r10, #1
			b calcHundLoop
		doneHundLoop:
			cmp r10, #0
			beq	checkTen
			add 	r0, r10, #48	
			mov 	r3, r8	//color
			mov 	r1, r7		//y
			mov 	r2, r6		//x
			bl 	drawText
			mul 	r5, r10, r9
			sub	r4, r4, r5
			mov 	r5, r4
			add	r7, r7, #16
			
			mov r10, #0
		
		checkTen:
			cmp 	r5, #10
			blt	checkZero
			sub 	r5, #10
			add 	r10, r10, #1
			b 	checkTen

		checkZero:
		
		add 	r0, r10, #48	
		mov 	r3, r8	//color
		mov 	r1, r7		//y
		mov 	r2, r6		//x
		bl 	drawText
		mov	r9, #10
		
		sub	r4, r4, r5
		add	r7, r7, #16
		
	donePrint:
		add 	r0, r5, #48	
		mov 	r3, r8	//color
		mov 	r1, r7		//y
		mov 	r2, r6		//x
		bl 	drawText		
	


	
    		pop     {r4-r10, pc}


.global updateStats
updateStats:
	push    {r4-r10, lr}
	
	//ldr r4, =stats
	mov r5, #0xFFFFFFFF
	
	//print the score

	mov 	r0, #999			//character
	mov 	r3, r5	//color
	mov 	r1, #25	//y
	mov 	r2, #665		//x
	bl printNum

	mov 	r0, #1			//character
	mov 	r3, r5		//color
	mov 	r1, #25	//y
	mov 	r2, #1225		//x
	
	bl printNum
	

	return:
    		pop     {r4-r10, pc}