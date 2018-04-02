

.global moveBall
moveBall:
    push    {r4-r7, lr}


    ldr     r0, =attached
    ldr     r4, [r0]

    cmp     r4, #1
    beq     padBall         //branch to move ball on paddle speed

    bl      drawBFTile

    bl      padCollision
    cmp     r0, #1
    beq     endMoveBall

    ldr     r0, =ballStats
    ldr     r4, [r0]		//ball x coordinate
    ldr     r5, [r0, #4]	//ball y coordinate
    ldr     r6, [r0, #8]	//ball x speed
    ldr     r7, [r0, #12]	//ball y speed
    add     r4, r6
    add     r5, r7

    mov     r1, #336
    cmp     r4, r1
    movle   r4, r1
    negle   r6, r6
    strle   r6, [r0, #8]
    mov     r1, #1464
    cmp     r4, r1
    movge   r4, r1
    negge   r6, r6
    strge   r6, [r0, #8]

    mov     r1, #88
    cmp     r5, r1
    movle   r5, r1
    negle   r7, r7
    strle   r7, [r0, #12]

    mov     r1, #960
    cmp     r5, r1
    bge     loseLife

    str     r4, [r0]
    str     r5, [r0, #4]

    b       drawBall

loseLife:
    ldr     r0, =lives
    ldr     r1, [r0]
    sub     r1, #1
    str     r1, [r0]
    mov     r1, #1
    ldr     r0, =attached
    str     r1, [r0]
    ldr     r0, =paddleStats
    ldr     r4, [r0]
    ldr     r2, [r0, #4]
    add     r4, r2
    ldr     r2, [r0, #8]
    cmp     r2, #1
    moveq   r2, #84
    movne   r2, #52
    add     r4, r2
    ldr     r0, =ballStats
    str     r4, [r0]
    mov     r5, #896
    str     r5, [r0, #4]

    b       drawBall

padBall:
    ldr     r0, =paddleStats
    ldr     r1, [r0, #4]		    //load paddle x coordinate
    ldr     r0, =ballStats
    ldr     r4, [r0]                //set ball speed to paddle speed
    add     r4, r1
    str     r4, [r0]
    mov     r1, #0
    str     r1, [r0, #8]
    str     r1, [r0, #12]
    mov     r5, #896

drawBall:
    ldr     r0, =drawArgs
    ldr     r1, =ball
    str     r1, [r0]
    str     r4, [r0, #4]
    str     r5, [r0, #8]
    mov     r1, #24
    str     r1, [r0, #12]
    str     r1, [r0, #16]
    bl      drawImage

endMoveBall:
    pop     {r4-r7, pc}


.global padCollision
padCollision:
    push    {r4-r8, lr}

    ldr     r0, =ballStats
    ldr     r4, [r0]		//ball x coordinate
    ldr     r5, [r0, #4]	//ball y coordinate
    ldr     r6, [r0, #8]	//ball x speed
    ldr     r7, [r0, #12]	//ball y speed

    add     r4, r6		//r4 = updated ball x coordinate
    add     r5, r7		//r5 = update ball y coordinate

    ldr     r0, =paddleStats
    ldr     r6, [r0]		//paddle x coordinate
    ldr     r7, [r0, #4]	//paddle x speed
    ldr     r8, [r0, #8]	//r8 = extended paddle flag

    add     r6, r7
    sub     r6, #24		//r6 = adjusted paddle x coordinate

    cmp     r8, #1
    moveq   r7, #216            //r7 = paddle extended width + ball width
    movne   r7, #152            //r7 = paddle normal width + ball width

    cmp	    r4, r6		//check ball x coordinate
    movlt   r0, #0
    blt     endPadCo
    subge   r4, r6		//r4 = ball remaining pixels
    cmp     r4, r7
    movgt   r0, #0
    bgt     endPadCo		//if passed this point, ball is
				            //within paddle x range
    mov     r1, #896		//check y coordinate
    cmp     r5, r1
    movlt   r0, #0
    blt     endPadCo
    mov     r1, #952
    cmp     r5, r1
    movge   r0, #0
    bge     endPadCo
    mov     r1, #908
    cmp     r5, r1
    blt     topPadCo

sidePadCo:
    ldr     r0, =ballStats
    ldr     r8, [r0, #8]	//ball x speed
    neg     r8, r8		// flip ball x speed
    str     r8, [r0, #8]

    cmp     r4, #24		//check if ball on left side of paddle
    strlt   r6, [r0]            //update ball x coordinate
    addge   r6, r7		//assume ball is on right side of paddle
    strge   r6, [r0]

    ldr     r0, =drawArgs
    ldr     r1, =ball
    str     r1, [r0]
    str     r6, [r0, #4]
    str     r5, [r0, #8]
    mov     r1, #24
    str     r1, [r0, #12]
    str     r1, [r0, #16]
    bl      drawImage
    mov     r0, #1
    b       endPadCo

topPadCo:
    ldr     r0, =ballStats
    add     r6, r4
    str     r6, [r0]
    mov     r5, #896
    str     r5, [r0, #4]

    ldr     r0, =stickyPack
    ldr     r1, [r0]
    ldr     r2, [r0, #4]
    cmp     r2, #0
    beq     continuePadCo
    cmp     r1, #1              //if sticky Pad is on
    subeq   r2, #1
    streq   r2, [r0, #4]
    ldreq   r0, =attached
    streq   r1, [r0]
    ldreq   r0, =ballStats
    moveq   r1, #0
    streq   r1, [r0, #8]
    streq   r1, [r0, #12]
    beq     padCoDrawBall

continuePadCo:
    ldr     r0, =paddleStats
    ldr     r1, [r0, #8]
    cmp     r1, #1
    moveq   r2, #60             //if extended paddle on, use 48 to calc place of ball on paddle
    movne   r2, #44

    ldr     r0, =ballStats
    sub     r7, r2
    cmp     r4, r7		//check if ball is on right end of paddle
    movge   r4, #3
    strge   r4, [r0, #8]
    movge   r4, #-3
    strge   r4, [r0, #12]
    bge     padCoDrawBall

    sub     r7, r2
    cmp     r4, r7		//check if ball is on mid right end of paddle
    movge   r4, #2
    strge   r4, [r0, #8]
    movge   r4, #-4
    strge   r4, [r0, #12]
    bge     padCoDrawBall

    sub     r7, r2
    cmp     r4, r7		//check if ball is on mid left end of paddle
    movge   r4, #-2
    strge   r4, [r0, #8]
    movge   r4, #-4
    strge   r4, [r0, #12]
    bge     padCoDrawBall

    mov     r4, #-3		//ball is on left end of paddle
    str     r4, [r0, #8]
    str     r4, [r0, #12]

padCoDrawBall:
    ldr     r0, =drawArgs
    ldr     r1, =ball
    str     r1, [r0]
    str     r6, [r0, #4]
    str     r5, [r0, #8]
    mov     r1, #24
    str     r1, [r0, #12]
    str     r1, [r0, #16]
    bl      drawImage
    mov     r0, #1

endPadCo:
    pop     {r4-r8, pc}


.global checkCollisions
checkCollisions:
    push    {r4-r9, lr}

    bl      calcXYIndex
    mov     r4, r0              //x remaining pixels
    mov     r5, r1              //y remaining pixels
    mov     r7, r2
    mov     r8, r3

    mov     r0, r7
    mov     r1, r8
    bl      calcOffset

    ldrb    r3, [r0, #8]        //r3 = hardness of tile
    cmp     r3, #0
    beq     checkInside
    subgt   r3, #1
    strgtb  r3, [r0, #8]
    cmp	    r3, #0
    ldreq   r0, =destroyed
    ldreq   r1, [r0]
    addeq   r1, #1
    streq   r1, [r0]
    b       firstFlip

checkInside:
    cmp     r4, #40
    movge   r9, #1
    bge     checkRight
    cmp     r5, #8
    blt     endCheckCo
    mov     r9, #0              //flag for ball into right tile
    b       checkBottom

firstFlip:
    ldr     r0, =ballStats
    ldr     r1, [r0, #8]
    ldr     r2, [r0, #12]
    neg     r1, r1
    neg     r2, r2
    cmp     r4, #61
    strge   r1, [r0, #8]
    strlt   r2, [r0, #12]
    ldr	    r0, =score
    ldr     r1, [r0]
    add     r1, #1
    str     r1, [r0]
    b       endCheckCo

checkRight:
    add     r7, #1
    cmp     r7, #17
    bgt     checkBottom
    mov     r0, r7
    mov     r1, r8
    bl      calcOffset

    ldrb    r3, [r0, #8]            //r3 = hardness of tile
    cmp     r3, #0
    beq     checkBottom
    subgt   r3, #1
    strgtb  r3, [r0, #8]
    cmp	    r3, #0
    ldreq   r0, =destroyed
    ldreq   r1, [r0]
    addeq   r1, #1
    streq   r1, [r0]

secFlip:
    ldr     r0, =ballStats
    ldr     r1, [r0, #8]
    neg     r1, r1
    str     r1, [r0, #8]
    ldr	    r0, =score
    ldr     r1, [r0]
    add     r1, #1
    str     r1, [r0]
    b       endCheckCo

checkBottom:
    cmp     r9, #1
    subeq   r7, #1
    add     r8, #1
    cmp     r8, #27
    bgt     endCheckCo

    mov     r0, r7
    mov     r1, r8
    bl      calcOffset

    ldrb    r3, [r0, #8]            //r3 = hardness of tile
    cmp     r3, #0
    beq     checkLast
    subgt   r3, #1
    strgtb  r3, [r0, #8]
    cmp	    r3, #0
    ldreq   r0, =destroyed
    ldreq   r1, [r0]
    addeq   r1, #1
    streq   r1, [r0]

thirdFlip:
    ldr     r0, =ballStats
    ldr     r1, [r0, #12]
    neg     r1, r1
    str     r1, [r0, #12]
    ldr	    r0, =score
    ldr     r1, [r0]
    add     r1, #1
    str     r1, [r0]
    b       endCheckCo

checkLast:
    cmp     r9, #0
    beq     endCheckCo
    add     r7, #1

    mov     r0, r7
    mov     r1, r8
    bl      calcOffset

    ldrb    r3, [r0, #8]            //r3 = hardness of tile
    cmp     r3, #0
    beq     endCheckCo
    subgt   r3, #1
    strgtb  r3, [r0, #8]
    cmp	    r3, #0
    ldreq   r0, =destroyed
    ldreq   r1, [r0]
    addeq   r1, #1
    streq   r1, [r0]

lastFlip:
    ldr     r0, =ballStats
    ldr     r1, [r0, #8]
    ldr     r2, [r0, #12]
    neg     r1, r1
    neg     r2, r2
    cmp     r9, #1
    strne   r1, [r0, #8]
    streq   r2, [r0, #12]
    ldr	    r0, =score
    ldr     r1, [r0]
    add     r1, #1
    str     r1, [r0]

endCheckCo:
    pop     {r4-r9, pc}

.global drawBFTile              //r0 = drawArgs ptr, r1 = x, r2 = y, r3 = tile ptr
drawBFTile:
    push    {r4-r8, lr}

    bl      calcXYIndex
    mov     r4, r0
    mov     r5, r1

	mov     r0, r2				//middle tile to cover
	mov     r1, r3
	bl      calcOffset
	bl      drawBGTile

	mov     r0, r7				//left tile to cover
	sub     r0, #1
	cmp		r0, #0
	blt     backRightTile
	mov     r1, r8
	bl      calcOffset
	bl      drawBGTile

backRightTile:
	mov     r0, r7				//right tile to cover
	add     r0, #1
	cmp     r0, #17
	bgt     topLeftTile
	mov     r1, r8
	bl      calcOffset
	bl      drawBGTile

topLeftTile:
	mov     r0, r7				//top left tile
	sub     r0, #1
	cmp     r0, #0
	blt     topMiddleTile
	mov     r1, r8
	sub     r1, #1
	cmp     r1, #0
	blt     topMiddleTile
	bl      calcOffset
	bl      drawBGTile

topMiddleTile:
	mov     r0, r7       		//top middle tile
	mov     r1, r8
	sub     r1, #1
	cmp     r1, #0
	blt     topRightTile
	bl      calcOffset
	bl      drawBGTile

topRightTile:
	mov     r0, r7				//top right tile
	add     r0, #1
	cmp     r0, #17
	bgt     bottLeftTile
	mov     r1, r8
	sub     r1, #1
	cmp     r1, #0
	blt     bottLeftTile
	bl      calcOffset
	bl      drawBGTile

bottLeftTile:
	mov     r0, r7
	sub     r0, #1
	cmp     r0, #0
	blt     bottMiddleTile
	mov     r1, r8
	add     r1, #1
	cmp     r1, #27
	bgt     bottMiddleTile
	bl      calcOffset
	bl      drawBGTile

bottMiddleTile:
	mov     r0, r7
	mov     r1, r8
	add     r1, #1
	cmp     r1, #27
	bgt     bottRightTile
	bl      calcOffset
	bl      drawBGTile

bottRightTile:
	mov     r0, r7
	add     r0, #1
	cmp     r0, #17
	bgt     endBFTile
	mov     r1, r8
	add     r1, #1
	cmp     r1, #27
	bgt     endBFTile
	bl      calcOffset
	bl      drawBGTile


endBFTile:
    pop     {r4-r8, pc}

.global calcXYIndex
calcXYIndex:
    push    {r4-r8, lr}

    ldr     r0, =ballStats
    ldr     r4, [r0]            //x coordinate
    ldr     r5, [r0, #4]        //y coordinate
    mov     r6, #336
    sub     r4, r6              //x - left boundary, r4 becomes remaining pixels along x
    mov     r6, #88
    sub     r5, r6              //y - top boundary, r5 becomes remaining pixels along y
    mov     r7, #0              //r7 = x index
    mov     r8, #0              //r8 = y index

    calcXLoop:
    cmp     r4, #63
    subhi   r4, #64
    addhi   r7, #1
    bhi     calcXLoop
    calcYLoop:
    cmp     r5, #31
    subhi   r5, #32
    addhi   r8, #1
    bhi     calcYLoop

    mov     r0, r4
    mov     r1, r5
    mov     r2, r7
    mov     r3, r8

    pop     {r4-r8, pc}




.global drawBGTile              //r1 = x coordinate, r2 = y coordinate
drawBGTile:
    push    {lr}
    ldr     r0, =drawArgs
    ldr     r3, =fTile
    str     r3, [r0]
    str     r1, [r0, #4]
    str     r2, [r0, #8]
    mov     r1, #64
    str     r1, [r0, #12]
    mov     r1, #32
    str     r1, [r0, #16]
    bl      drawImage
    pop     {pc}

.global calcOffset          //takes r0 = x index, r1 = y index
calcOffset:
    mov     r2, #18
    mul     r3, r1, r2
    add     r3, r0
    add     r3, r3, lsl #3

    ldr     r0, =myArray
    add     r0, r3
    ldr     r1, [r0]
    ldr     r2, [r0, #4]

    mov     pc, lr          //returns r0 = myArray+offset, r1 = x coordinte, r2 = y coordinate


.global movePaddle
movePaddle:
    push    {r4-r8, lr}

    //check boundaries


    ldr     r0, =paddleStats    //load paddle stats
    ldr     r4, [r0]            //load x coordinate
    ldr     r5, [r0, #4]        //load speed
    ldr     r6, [r0, #8]        //load if extended
    cmp     r5, #0
    beq     drawPaddly

    bl      checkPaddleBound
    mov     r7, r0
    mov     r8, r1
    bl      drawBackFloor

    cmp     r7, #1
    beq     drawPaddleLeft
    cmp     r8, #1
    beq     drawPaddleRight

 drawPaddly:
    //bl      drawBackFloor
    add     r4, r5
    ldr     r0, =paddleStats
    str	    r4, [r0]
    mov     r7, #0
    str     r7, [r0, #4]
    cmp     r6, #1
    ldreq   r1, =exPaddle
    ldrne   r1, =paddle

    ldr     r0, =drawArgs
    str     r1, [r0]
    str     r4, [r0, #4]
    mov     r1, #920
    str     r1, [r0, #8]
    movne   r1, #128
    moveq   r1, #192
    str     r1, [r0, #12]
    mov     r1, #32
    str     r1, [r0, #16]
    bl      drawImage
    b       endMovePad

drawPaddleLeft:

    cmp     r6, #1
    ldreq   r1, =exPaddle
    ldrne   r1, =paddle
    ldr     r0, =drawArgs
    str     r1, [r0]
    mov     r1, #336
    str     r1, [r0, #4]
    mov     r1, #920
    str     r1, [r0, #8]
    movne   r1, #128
    moveq   r1, #192
    str     r1, [r0, #12]
    mov     r1, #32
    str     r1, [r0, #16]
    bl      drawImage
    b       endMovePad

drawPaddleRight:

    cmp     r6, #1
    ldreq   r1, =exPaddle
    ldrne   r1, =paddle
    moveq   r2, #1296
    movne   r2, #1360
    ldr     r0, =drawArgs
    str     r1, [r0]
    str     r2, [r0, #4]
    mov     r1, #920
    str     r1, [r0, #8]
    movne   r1, #128
    moveq   r1, #192
    str     r1, [r0, #12]
    mov     r1, #32
    str     r1, [r0, #16]
    bl      drawImage

endMovePad:
    pop     {r4-r8, pc}


.global checkPaddleBound
checkPaddleBound:
    push    {r4-r6, lr}

    ldr     r2, =paddleStats
    ldr     r3, [r2]            //load x coordinate
    ldr     r4, [r2, #4]        //load the speed of the paddle
    ldr     r5, [r2, #8]        //load if extened
    add     r3, r4          	//update the ball position so we can tell if there is a colision

    mov     r0, #0
    mov     r1, #0

    mov     r6, #336
    cmp     r3, r6
    movle   r0, #1		//r0 = left collision boolean
    strle   r6, [r2]
    movle   r6, #0
    strle   r6, [r2, #4]
    ble     endCheckPadBound


    cmp     r5, #1
    moveq   r6, #1328
    movne   r6, #1360
    cmp     r3, r6
    movge   r1, #1		//r1 = right collision boolean
    strge   r6, [r2]
    movge   r6, #0
    strge   r6, [r2, #4]

endCheckPadBound:

    pop     {r4-r6, pc}


//.global drawPaddleBack
drawBackFloor:
    push    {r4-r7, lr}

    ldr     r2, =paddleStats    //load paddle stats
    ldr     r4, [r2]            //load x coordinate
    ldr     r5, [r2, #4]
    ldr     r6, [r2, #8]        //load if extended

    cmp     r0, #1
    beq     drawAtLeft
    cmp     r1, #1
    beq     drawAtRight

    add     r4, r5
    mov     r1, #336
    sub     r4, r1              //x - left boundary, r4 becomes remaining pixels along x
    mov     r7, #0              //r7 = x index

calcLoop:
    cmp     r4, #63
    subhi   r4, #64
    addhi   r7, #1
    bhi     calcLoop

    mov     r1, #64
    mul	    r4, r7, r1
    mov     r1, #272
    add     r4, r1
    mov     r1, #336
    cmp     r4, r1
    movlt   r4, r1

    cmp     r6, #1
    moveq   r7, #6
    movne   r7, #7
    mov     r5, #0
    b       drawBack

drawAtLeft:
    cmp     r6, #1
    moveq   r4, #528
    movne   r4, #464
    mov     r7, #1
    mov     r5, #0
    b       drawBack

drawAtRight:
    cmp     r6, #1
    moveq   r4, #1232
    movne   r4, #1296
    mov     r7, #1
    mov     r5, #0

drawBack:

    ldr     r0, =drawArgs
    ldr     r1, =fTile
    str     r1, [r0]
    str     r4, [r0, #4]		//x coordinate
    mov     r1, #920                    //y coordinate
    str     r1, [r0, #8]
    mov     r1, #64                	//image width
    str     r1, [r0, #12]
    mov     r1, #32                 	//image height
    str     r1, [r0, #16]
    bl      drawImage
    add     r4, #64
    add     r5, #1
    mov     r1, #1424
    cmp     r4, r1
    movgt   r5, r7
    cmp     r5, r7
    blt     drawBack

    pop     {r4-r7, pc}
