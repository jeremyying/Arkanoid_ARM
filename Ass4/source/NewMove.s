
@ Code section
.section .text

.global movePaddle
movePaddle:
    push    {r4-r8, lr}

    //check boundaries
    

    ldr     r0, =paddleStats    //load paddle stats
    ldr     r4, [r3]            //load x coordinate
    ldr     r5, [r3, #4]        //load speed
    ldr     r6, [r3, #8]        //load if extended
    cmp     r5, #0
    beq     endMovePad

    bl      checkPaddleBound
  
    cmp     r0, #1
    beq     drawPaddleLeft
    cmp     r1, #1
    beq     drawPaddleRight

    bl      drawBackFloor

    
    add     r4, r5
    //ldr     r0, =check
    //mov     r1, r6
    //bl      printf

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
    bl      drawBackFloor
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
    bl      drawBackFloor
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
    push    {r4-r7, lr}

    ldr     r3, =paddleStats
    ldr     r4, [r3]            //load x coordinate
    ldr     r7, [r3, #4]        //load the speed of the paddle
    add     r4, r4, r7          //update the ball position so we can tell if there is a colision
    ldr     r5, [r3, #8]        //load if extened

    mov     r0, #0
    mov     r1, #0

    mov     r6, #336
    cmp     r4, r6
    movle   r0, #1		//r0 = left collision boolean
    ble     endCheckPadBound
    

    cmp     r5, #1
    moveq   r6, #1328
    movne   r6, #1360
    cmp     r4, r6
    movge   r1, #1		//r1 = right collision boolean

endCheckPadBound:

    pop     {r4-r7, pc}


//.global drawPaddleBack
drawBackFloor:
    push    {r4-r9, lr}

    mov     r8, r0
    mov     r9, r1

    ldr     r3, =paddleStats    //load paddle stats
    ldr     r4, [r3]            //load x coordinate
    ldr     r5, [r3, #8]        //load if extended

    mov     r6, #336
    sub     r4, r6              //x - left boundary, r4 becomes remaining pixels along x
    mov     r7, #0              //r7 = x index
    
calcLoop:
    cmp     r4, #63
    subhi   r4, #64
    addhi   r7, #1
    bhi     calcLoop

    mov     r6, #64
    mul	    r4, r7, r6
    mov     r6, #336
    add     r4, r6

    cmp	    r0, #1
    beq     drawAtLeft
    cmp     r1, #1
    beq     drawAtRight

    cmp     r5, #1
    moveq   r6, #4
    movne   r6, #3
    mov     r5, #0
    b       drawBack

drawAtLeft:
    mov     r4, #336
    mov     r6, #3
    mov     r5, #0	
    b       drawBack

drawAtRight:
    cmp     r5, #1
    moveq   r4, #1296
    moveq   r6, #3
    movne   r4, #1360
    movne   r6, #2
    mov     r5, #0

drawBack:

    ldr     r0, =drawArgs
    ldr     r1, =fTile
    str     r1, [r0]
    mov     r1, r4                  //x coordinate
    str     r1, [r0, #4]
    mov     r1, #920                    //y coordinate
    str     r1, [r0, #8]
    mov     r1, #64                //image width
    str     r1, [r0, #12]
    mov     r1, #32                 //image height
    str     r1, [r0, #16]
    bl      drawImage
    add     r4, #64
    add     r5, #1
    cmp     r5, r6
    blt     drawBack   

    pop     {r4-r9, pc}


.global moveBall
moveBall:
    push    {r4, lr}

    ldr     r0, =attached
    ldr     r1, [r0]
    cmp     r1, #1
    beq     padBall         //branch to move ball on paddle speed

    ldr     r0, =ballStats
    ldr     r4, [r0, #4]
    mov     r1, #344
    cmp     r4, r1          //if ball below brick area
    bge     drawBFloor
    mov     r1, #184
    cmp     r4, r1
    bge     nextCo
    bl      drawBFTile
    bl      checkBound
    b       drawBall

brickCo:
    bl      checkCollisions
    b       drawBall

drawBFloor:
    bl      drawBFTile
    bl      padCollision    //else check collision with paddle
    cmp     r0, #1
    beq     drawBall
    bl      checkBound
    cmp     r0, #1
    beq     loseLife
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
    ldr     r1, [r0]
    ldr     r2, [r0, #8]
    cmp     r2, #1
    moveq   r2, #84
    movne   r2, #52
    add     r1, r2
    ldr     r0, =ballStats
    str     r1, [r0]
    mov     r1, #896
    str     r1, [r0, #4]

padBall:
    ldr     r0, =paddleStats
    ldr     r1, [r0, #4]
    ldr     r0, =ballStats
    str     r1, [r0, #8]        //set ball speed to paddle speed
    mov     r1, #0
    str     r1, [r0, #12]

drawBall:
    ldr     r0, =ballStats
    ldr     r2, [r0]
    ldr     r3, [r0, #4]
    ldr     r4, [r0, #8]
    add     r2, r4
    ldr     r4, [r0, #12]
    add     r3, r4
    str     r2, [r0]
    str     r3, [r0, #4]
    ldr     r0, =drawArgs
    ldr     r1, =ball
    str     r1, [r0]
    str     r2, [r0, #4]
    str     r3, [r0, #8]
    mov     r4, #24
    str     r4, [r0, #12]
    str     r4, [r0, #16]
    bl      drawImage

    pop     {r4, pc}


//returns r0 = side collision, r1 = top collision, r2 = bottom out of bounds
//r3 = collision with paddle
.global checkBound
checkBound:
    push    {r4, r5}

    ldr     r2, =ballStats
    ldr     r3, [r2]            //load x coordinate
    ldr     r4, [r2, #4]        //load y coordinate

    mov     r5, #336
    mov     r1, #0              //side boundary collision boolean
    cmp     r3, r5
    movle   r1, #1
    mov     r5, #1424
    cmp     r3, r5
    movge   r1, #1
    ldr     r5, [r2, #8]
    neg     r5, r5
    cmp     r1, #1
    streq   r5, [r2, #8]

    mov     r5, #88
    mov     r1, #0              //top boundary collision
    cmp     r4, r5
    movle   r1, #1
    ldr     r5, [r2, #12]
    neg     r5, r5
    cmp     r1, #1
    streq   r5, [r2, #12]

    mov     r0, #0              //r2 = bottom boundary
    mov     r5, #960
    cmp     r4, r5
    movge   r0, #1

    pop     {r4, r5}
    mov     pc, lr

.global padCollision
padCollision:
    push    {r4-r7}

    ldr     r0, =ballStats
    ldr     r1, [r0]            //r1 = ball x coordinate
    ldr     r2, [r0, #4]        //r2 = ball y coordinate


    ldr     r0, =paddleStats
    ldr     r3, [r0]            //r3 = paddle x coordinate
    sub     r3, #24
    ldr     r4, [r0, #4]        //r4 = paddle speed
    ldr     r5, [r0, #8]        //r5 = extended paddle on
    cmp     r5, #1
    moveq   r6, #216            //r6 = paddle extended width + ball width
    movne   r6, #152            //r6 = paddle normal width + ball width

    ldr     r0, =stickyPack
    ldr     r7, [r0]
    cmp     r7, #0              //if sticky Pad is off
    beq     nextCo
    mov     r7, #896
    cmp     r2, r7              //check y coordinate
    subge   r2, r7
    cmp     r2, #12
    bgt     nextCo
    cmp     r1, r3              //check x coordinate
    subge   r1, r3
    cmp     r1, r6
    bgt     nextCo
    ldr     r7, [r0, #4]        //stickyPack is on
    cmp     r7, #1
    subgt   r7, #1
    strgt   r7, [r0, #4]        //update stickyPack
    moveq   r7, #0
    streq   r7, [r0]
    ldr     r0, =ballStats
    mov     r7, #0
    str     r4, [r0, #8]        //update ball speed to paddle speed
    str     r7, [r0, #12]
    mov     r1, #1
    ldr     r0, =attached
    str     r1, [r0]
    mov     r0, #1              //speed changed
    b       endPadCo            //return

nextCo:
    ldr     r0, =ballStats
    ldr     r1, [r0]            //r1 = ball x coordinate
    ldr     r2, [r0, #4]        //r2 = ball y coordinate
    mov     r7, #896
    cmp     r2, r7              //check y coordinate
    subge   r2, r7
    cmp     r2, #48
    movge   r0, #0
    bge     endPadCo
    cmp     r5, #1
    moveq   r7, #48             //if extended paddle on, use 48 to calc place of ball on paddle
    movne   r7, #32
    cmp     r1, r3              //check x coordinate
    subgt   r1, r3
    cmp     r1, r6
    movgt   r0, #0
    bgt     endPadCo
    cmp     r2, #12             //if ball halfway through paddle, assume it's on the side
    strle   r4, [r0, #8]        //use paddle speed to update ball speed
    movle   r0, #1
    ble     endPadCo
    sub     r6, r7              //subtract a quarter from paddle width
    cmp     r1, r6              //check if ball is on right end of paddle
    movgt   r1, #1
    strgt   r1, [r0, #8]        //ball speed updated to 45 deg right up
    strgt   r1, [r0, #12]
    movgt   r0, #1
    bgt     endPadCo
    sub     r6, r7
    cmp     r1, r6              //check if ball is on right mid of paddle
    movgt   r1, #1
    movgt   r2, #2
    strgt   r1, [r0, #4]        //ball speed updated 60 deg right up
    strgt   r2, [r0, #12]
    movgt   r0, #1
    bgt     endPadCo
    sub     r6, r7
    cmp     r1, r6              //check if ball is on left mid of paddle
    movgt   r1, #-1
    movgt   r2, #2
    strgt   r1, [r0, #4]        //ball speed updated to 60 deg left up
    strgt   r2, [r0, #12]
    movgt   r0, #1
    movgt   r1, #1
    bgt     endPadCo
    mov     r1, #-1
    mov     r2, #1
    str     r1, [r0, #8]        //ball speed updated to 45 deg left up
    str     r1, [r0, #12]
    mov     r0, #1

endPadCo:
    pop     {r4-r7}
    mov     pc, lr


.global checkCollisions
checkCollisions:
    push    {r4-r9, lr}

    ldr     r0, =ballStats
    ldr     r4, [r0]            //x coordinate
    ldr     r5, [r0, #4]        //y coordinate
    mov     r6, #336
    sub     r4, r6              //x - left boundary, r4 becomes remaining pixels along x
    mov     r6, #88
    sub     r5, r6              //y - top boundary, r5 becomes remaining pixels along y
    mov     r7, #0              //r7 = x index
    mov     r8, #0              //r8 = y index

XLoop:
    cmp     r4, #63
    subhi   r4, #64
    addhi   r7, #1
    bhi     XLoop
YLoop:
    cmp     r5, #31
    subhi   r5, #32
    addhi   r8, #1
    bhi     YLoop

    mov     r2, #18
    mul     r1, r8, r2
    add     r1, r7
    add     r1, r1, lsl #3      // r1 = ((y * width) + x) * 9
    mov     r6, r1              //r6 = offset
    ldr     r0, =myArray
    add     r0, r6
    ldr     r1, [r0], #4        //r1 = x coordinate of tile
    ldr     r2, [r0], #4        //r2 = y coordinate of tile
    ldrb    r3, [r0]            //r3 = hardness of tile
    add     r6, #9
    cmp     r3, #0
    ldreq   r3, =fTile          //if hardness 0, then it's a floor tile
    beq     drawFirsT
    cmp     r3, #1
    subge   r3, #1
    strge   r3, [r0]
    ldreq   r3, =fTile
    beq     firstFlip
    cmp     r8, #4
    ldreq   r3, =bBrick         //row 4 has blue bricks
    cmp     r8, #5
    ldreq   r3, =oBrick         //row 5 orange bricks
    ldr     r3, =gBrick         //brick is not blue or orange, then it's green
    b       firstFlip

drawFirsT:
    ldr     r0, =drawArgs
    bl      drawBGTile
    cmp     r4, #40
    bge     checkRight
    cmp     r5, #8
    blt     endCheckCo
    mov     r9, #0              //flag for ball into right tile
    b       checkBottom

firstFlip:
    ldr     r0, =drawArgs
    bl      drawBGTile
    ldr     r0, =ballStats
    ldr     r1, [r0, #8]
    ldr     r2, [r0, #12]
    neg     r1, r1
    neg     r2, r2
    cmp     r4, #62
    strge   r1, [r0, #8]
    strlt   r2, [r0, #12]
    b       endCheckCo

checkRight:
    mov     r9, #1
    ldr     r0, =myArray
    add     r0, r6
    ldr     r1, [r0], #4        //r1 = x coordinate of tile
    ldr     r2, [r0], #4        //r2 = y coordinate of tile
    ldrb    r3, [r0]            //r3 = hardness of tile
    add     r6, #9
    cmp     r3, #0
    ldreq   r3, =fTile          //if hardness 0, then it's a floor tile
    beq     drawRight
    cmp     r3, #1
    subge   r3, #1
    strge   r3, [r0]
    ldreq   r3, =fTile
    beq     secFlip
    cmp     r8, #4
    ldreq   r3, =bBrick         //row 4 has blue bricks
    cmp     r8, #5
    ldreq   r3, =oBrick         //row 5 orange bricks
    ldr     r3, =gBrick         //brick is not blue or orange, then it's green
    b       secFlip

drawRight:
    ldr     r0, =drawArgs
    bl      drawBGTile
    cmp     r5, #8
    blt     endCheckCo
    b       checkBottom

secFlip:
    ldr     r0, =drawArgs
    bl      drawBGTile
    ldr     r0, =ballStats
    ldr     r1, [r0, #8]
    neg     r1, r1
    str     r1, [r0, #8]
    b       endCheckCo

checkBottom:
    cmp     r9, #1
    moveq   r1, #16
    movne   r1, #17
    mov     r2, #9
    mul     r3, r1, r2
    add     r6, r3
    ldr     r0, =myArray
    add     r0, r6
    ldr     r1, [r0], #4        //r1 = x coordinate of tile
    ldr     r2, [r0], #4        //r2 = y coordinate of tile
    ldrb    r3, [r0]            //r3 = hardness of tile
    add     r6, #9
    cmp     r3, #0
    ldreq   r3, =fTile          //if hardness 0, then it's a floor tile
    beq     drawLBottom
    cmp     r3, #1
    subge   r3, #1
    strge   r3, [r0]
    ldreq   r3, =fTile
    beq     thirdFlip
    cmp     r8, #4
    ldreq   r3, =bBrick         //row 4 has blue bricks
    cmp     r8, #5
    ldreq   r3, =oBrick         //row 5 orange bricks
    ldr     r3, =gBrick         //brick is not blue or orange, then it's green
    b       thirdFlip

drawLBottom:
    ldr     r0, =drawArgs
    bl      drawBGTile
    cmp     r9, #1
    beq     checkLast
    b       endCheckCo

thirdFlip:
    ldr     r0, =drawArgs
    bl      drawBGTile
    ldr     r0, =ballStats
    ldr     r1, [r0, #12]
    neg     r1, r1
    str     r1, [r0, #12]
    b       endCheckCo

checkLast:
    ldr     r0, =myArray
    add     r0, r6
    ldr     r1, [r0], #4        //r1 = x coordinate of tile
    ldr     r2, [r0], #4        //r2 = y coordinate of tile
    ldrb    r3, [r0]            //r3 = hardness of tile
    cmp     r3, #0
    ldreq   r3, =fTile          //if hardness 0, then it's a floor tile
    beq     drawLast
    cmp     r3, #1
    subge   r3, #1
    strge   r3, [r0]
    ldreq   r3, =fTile
    beq     lastFlip
    cmp     r8, #4
    ldreq   r3, =bBrick         //row 4 has blue bricks
    cmp     r8, #5
    ldreq   r3, =oBrick         //row 5 orange bricks
    ldr     r3, =gBrick         //brick is not blue or orange, then it's green
    b       lastFlip

drawLast:
    ldr     r0, =drawArgs
    bl      drawBGTile
    b       endCheckCo

lastFlip:
    ldr     r0, =drawArgs
    bl      drawBGTile
    ldr     r0, =ballStats
    ldr     r1, [r0, #8]
    ldr     r2, [r0, #12]
    neg     r1, r1
    neg     r2, r2
    cmp     r9, #1
    strne   r1, [r0, #8]
    streq   r2, [r0, #12]

endCheckCo:
    pop     {r4-r9, pc}

.global drawBFTile              //r0 = drawArgs ptr, r1 = x, r2 = y, r3 = tile ptr
drawBFTile:
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

    mov     r6, #64
    mul     r4, r7, r6
    mov     r6, #336
    add     r4, r6
    mov     r6, #32
    mul     r5, r8, r6
    mov     r6, #88
    add     r5, r6
    mov     r6, #0

printFLoop:
    ldr     r0, =drawArgs
    ldr     r1, =fTile
    str     r1, [r0]
    str     r4, [r0, #4]
    str     r5, [r0, #8]
    mov     r1, #64
    str     r1, [r0, #12]
    mov     r1, #32
    str     r1, [r0, #16]
    bl      drawImage
    add     r4, #64
    add     r6, #1
    cmp     r6, #2
    subeq   r4, #128
    addeq   r5, #32
    cmp     r6, #4
    blt     printFLoop

    pop     {r4-r8, pc}

.global drawBGTile              //r0 = drawArgs ptr, r1 = x, r2 = y, r3 = tile ptr
drawBGTile:
    push    {lr}
    str     r3, [r0]
    str     r1, [r0, #4]
    str     r2, [r0, #8]
    mov     r1, #64
    str     r1, [r0, #12]
    mov     r1, #32
    str     r1, [r0, #16]
    bl      drawImage
    pop     {pc}



