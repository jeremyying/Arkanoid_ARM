
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

			mov     r5, #665        //x coordinate to blackout
			mov     r6, #25        //y coordinate to blackout
			mov     r7, #720         //max x
			mov     r8, #55        //max y

	blackoutUpdateScore:
			mov     r0, r5
			mov     r1, r6
			mov     r2, #0xFF000000
			bl      DrawPixel
			add     r5, #1
			teq     r5, r7
			moveq   r5, #665
			addeq   r6, #1
			cmp     r6, r8
			blt     blackoutUpdateScore


			mov     r5, #1225        //x coordinate to blackout
			mov     r6, #25        //y coordinate to blackout
			mov     r7, #1260         //max x
			mov     r8, #55        //max y

	blackoutUpdateLives:
			mov     r0, r5
			mov     r1, r6
			mov     r2, #0xFF000000
			bl      DrawPixel
			add     r5, #1
			teq     r5, r7
			moveq   r5, #1225
			addeq   r6, #1
			cmp     r6, r8
			blt     blackoutUpdateLives

		ldr r0, =lives
		      ldr r4, [r0]
		ldr r0, =score
		      ldr r6, [r0]
		mov r5, #0xFFFFFFFF

		//print the score

		mov 	r0, r6			//character
		mov 	r3, r5	//color
		mov 	r1, #25	//y
		mov 	r2, #665		//x
		bl printNum

		mov 	r0, r4			//character
		mov 	r3, r5		//color
		mov 	r1, #25	//y
		mov 	r2, #1225		//x

		bl printNum


		pop     {r4-r10, pc}

.global LivesUpdate
LivesUpdate:
	push {lr}
	ldr r0, =ballStats
	ldr r1, [r0, #4]
	cmp r1, #920
	blt LivesUpdateReturn

	ldr r0, =lives
	ldr r1, [r0]
	sub r1, #1 //lose 1 life
	str r1, [r0] //save new life count

LivesUpdateReturn:
	pop {pc}
