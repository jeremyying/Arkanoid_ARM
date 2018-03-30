
@ Code section
.section .text

.global movePaddle
movePaddle:
    push    {r4-r8, lr}

    //get current position (x,y top left corner) and speed from global variable paddleStats
    //if current position is at a boundary just return
    //calculate which floor tiles it is covering, this part is tricky...
    //I think subtract 336 from x, then divide by 64, ignore remainder (use a loop subtracting
    //64 and add 1 to a count), then multiply by 64 and add 336, that way you get the
    //coordinate of the left tile that the paddleis covering
    //replace current position with floor tiles, probably three tiles, 64x32 tiles
    //since paddle is two tiles width and it might be in between, 128x32
    //draw paddle in new position according to speed, add speed to x
    //updeate paddle stats
    //check if ball is attached, if so, call moveBall
    //look at other files for imageDraw examples
    //left x coordinate boundary is 336, right boundary is 1360 (top left corner)
    //y coordinate is always 920

    //check boundaries
    bl checkPaddleBound

    ldr     r3, =paddleStats // load padel stats
    ldr     r4, [r3]            //load x coordinate
    ldr     r5, [r3, #8]        //load if extened

    // if no bounds are violated then draw the paddle
    cmp   r0, #0
    beq drawPaddel
    b return
    cmp r1, #0
    beq drawPaddel
    b return

    //if we hid a boundy since none of the above went go to draw boundry
    b drawAtBoundy

    //now we can return
    b return



drawAtBoundy:
  bl drawPaddelAtBoundry

drawPaddle:
    bl drawPaddle

return:
    pop     {r4-r8, pc}

.global checkPaddelBound
checkPaddleBound:
    push    {r4-r6}

    ldr     r3, =paddleStats
    ldr     r4, [r3]            //load x coordinate
    ldr     r7, [r3, #4]        //load the speed of the paddel
    add     r4, r4, r7          //update the ball position so we can tell if there is a colision
    ldr     r5, [r3, #8]        //load if extened

    mov     r6, #336
    mov     r0, #0             //r0 = left colison boolean
    cmp     r4, r6
    movle   r0, #1

    cmp r5, #1
    moveq r6, #1328
    movne r6, #1360
    mov     r1, #0              //r1 = right colision boolean
    cmp     r4, r6
    movle   r1, #1

    pop     {r4-r6}
    mov     pc, lr

.global drawPaddel
drawPaddel:
    ldr     r3, =paddleStats
    ldr     r4, [r3]            //load x coordinate
    ldr     r7, [r3, #4]        //load the speed of the paddel
    add     r5, r4, r7          //update the ball position so we can tell if there is a colision

    //see which tile the paddle is in
    mov     r8, #0
calcXLoop:
    cmp     r5, #63 //
    subhi   r5, #64
    addhi   r8, #1
    bhi     calcXLoop

    cmp     r9, #0
    movne   r9, #3
    moveq   r9, #2

    mov r3, #0 // reset r3
    sub r3, r4, r4
    sub r3, r3, r5



DrawBackgroundLoop:
    cmp r9, #0
    beq DrawPaddleOverBackground
    // first draw over the background
    ldr r0, =drawArgs
    ldr r1, =fTile
    str r1, [r0]

    add r9, r9, #1
    add r3, r3, #64

    str r3, [r0, #4] // x value
    str #920, [r0, #8] // y value

    str #64, [r0, #12] // length
    str #32, [r0, #16] // width


    bl drawImage
    sub r9, r9, #1
    b DrawBackgroundLoop



DrawPaddleOverBackground:
    ldr     r3, =paddleStats
    ldr     r2 ,[r3, #4] //x pos
    ldr     r4, [r3, #8] //x speed
    add     r2, r2, r4 // update position
    ldr     r1, [r3, #12]            //load extended

    cmp     r1, #0  // see if it is extened
    ldrne   r0, =xPaddle
    ldreq   r0, =paddle

    ldr     r3, =drawArgs
    str     r0, [r3]
    str     r4, [r3, #4]
    str     #920, [r3, #8]
    cmp     r1, #0
    streq   #128, [r3, #12] //if not extened
    strne   #192, [r3, #12] // if extened
    str     #32, [r3, #16]

    bl drawImage





    pop     {r4-r6}
    mov     pc, lr


.global drawPaddelAtBoundry
drawPaddelAtBoundry:
    // load in the paddel variables
    ldr     r3, =paddleStats
    ldr     r4, [r3]            //load x coordinate
    ldr     r7, [r3, #4]        //load the speed of the paddel
    ldr     r5, [r3, #8]        //load if extened
    //see if there is a boundy colision or the right
    cmp     r0, #1
    bne     left






    right: //draw on the right side
    cmp r5, #0
    moveq r6, #1360
    movne r6, #1296
    b doneLeftRightAjustment
    left: //draw on the left side
    mov r6, #336






doneLeftRightAjustment:
    str r6, [r3]
    str #0, [r3, #4]

    bl drawPaddel
    pop     {r4-r6}
    mov     pc, lr



.global moveBall
moveBall:
    push    {r4, lr}

    ldr     r0, =attached
    ldr     r1, [r0]
    cmp     r1, #1
    beq     padBall         //branch to move ball on paddle speed

    ldr     r0, =ballStats
    ldr     r4, [r0, #4]
    mov     r1, #896
    cmp     r4, r1          //if ball above y = 896, jump to check boundaries
    blt     boundaries
    bl      padCollision    //else check collision with paddle
    cmp     r0, #1
    beq     drawBall
    cmp     r1, #1
    beq     drawBall

boundaries:
    bl      checkBound
    cmp     r0, #1
    beq     drawBall
    cmp     r1, #1
    beq     drawBall
    cmp     r2, #1
    beq     loseLife

    mov     r1, #952
    cmp     r4, r1
    bge     drawBall
    mov     r1, #216
    bge     drawBall

    bl      brickCollision
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
    bl      drawBackG
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
    push    {r4-r6}

    ldr     r3, =ballStats
    ldr     r4, [r3]            //load x coordinate
    ldr     r5, [r3, #4]        //load y coordinate

    mov     r6, #336
    mov     r0, #0              //r0 = side boundary collision boolean
    cmp     r4, r6
    movle   r0, #1
    mov     r6, #1424
    cmp     r4, r6
    movge   r0, #1
    ldr     r6, [r3, #8]
    neg     r6, r6
    cmp     r0, #1
    streq   r6, [r3, #8]

    mov     r6, #88
    mov     r1, #0              //r1 = top boundary collision
    cmp     r5, r6
    movle   r1, #1
    ldr     r6, [r3, #12]
    neg     r6, r6
    cmp     r1, #1
    streq   r6, [r3, #12]

    mov     r2, #0              //r2 = bottom boundary
    mov     r6, #960
    cmp     r5, r6
    movge   r2, #1

    pop     {r4-r6}
    mov     pc, lr

.global padCollision
padCollision:
    push    {r4-r7}

    ldr     r0, =ballStats
    ldr     r1, [r0]            //ball x coordinate
    ldr     r2, [r0, #4]        //ball y coordinate


    ldr     r0, =paddleStats
    ldr     r3, [r0]            //paddle x coordinate
    sub     r3, #24
    ldr     r4, [r0, #4]        //paddle speed
    ldr     r5, [r0, #8]
    cmp     r5, #1
    moveq   r6, #216            //paddle extended width + ball width
    movne   r6, #152            //paddle normal width + ball width

    ldr     r0, =stickyPack
    ldr     r7, [r0]
    cmp     r7, #0              //if sticky Pad is off
    beq     nextCo
    mov     r7, #896
    cmp     r2, r7              //check y coordinate
    subge   r2, r7
    cmp     r2, #24
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
    ldr     r1, [r0]
    ldr     r2, [r0, #4]
    mov     r7, #896
    cmp     r2, r7              //check y coordinate
    subge   r2, r7
    cmp     r2, #24
    movgt   r0, #0
    movgt   r1, #0
    bgt     endPadCo
    cmp     r5, #1
    moveq   r7, #48             //if extended paddle on, use 48 to calc place of ball on paddle
    movne   r7, #32
    cmp     r1, r3              //check x coordinate
    subgt   r1, r3
    cmp     r1, r6
    movgt   r0, #0
    movgt   r1, #0
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
    mov     r1, #1

endPadCo:
    pop     {r4-r7}
    mov     pc, lr

.global brickCollision
brickCollision:
    push    {r4-r9, lr}

    ldr     r0, =ballStats
    ldr     r4, [r0]            //x coordinate
    ldr     r5, [r0, #4]        //y coordinate
    mov     r6, #336
    sub     r4, r6              //x - left boundary, r4 becomes remaining pixels along x
    mov     r6, #88
    sub     r5, r6              //y - top boundary, r5 becomes remaining pixels along y
    mov     r7, #0              //r7 = y index
    mov     r8, #0              //r8 = x index
YLoop:
    cmp     r5, #31
    subhi   r5, #32
    addhi   r7, #1
    bhi     YLoop
XLoop:
    cmp     r4, #63
    subhi   r4, #64
    addhi   r8, #1
    bhi     XLoop

    mov     r2, #18
    mul     r1, r7, r2
    add     r1, r8
    add     r1, r1, lsl #3      // r1 = ((y * width) + x) * 9
    mov     r6, r1              //r6 = offset
    ldr     r0, =myArray
    ldr     r1, [r0, r6]        //r1 = x coordinate of tile
    add     r6, #4
    ldr     r2, [r0, r6]        //r2 = y coordinate of tile
    add     r6, #4
    ldrb    r3, [r0, r6]        //r3 = hardness of tile
    add     r6, #1












    pop     {r4-r9}
    mov     pc, lr

.global drawBackG
drawBackG:
    push    {r4-r9, lr}

    ldr     r0, =ballStats
    ldr     r4, [r0]            //x coordinate
    ldr     r5, [r0, #4]        //y coordinate
    mov     r6, #336
    sub     r4, r6              //x - left boundary, r4 becomes remaining pixels along x
    mov     r6, #88
    sub     r5, r6              //y - top boundary, r5 becomes remaining pixels along y
    mov     r7, #0              //r7 = y index
    mov     r8, #0              //r8 = x index
calcYLoop:
    cmp     r5, #31
    subhi   r5, #32
    addhi   r7, #1
    bhi     calcYLoop
calcXLoop:
    cmp     r4, #63
    subhi   r4, #64
    addhi   r8, #1
    bhi     calcXLoop

    mov     r2, #18
    mul     r1, r7, r2
    add     r1, r8
    add     r1, r1, lsl #3      // r1 = ((y * width) + x) * 9
    mov     r6, r1              //r6 = offset
    ldr     r0, =myArray
    ldr     r1, [r0, r6]        //r1 = x coordinate of tile
    add     r6, #4
    ldr     r2, [r0, r6]        //r2 = y coordinate of tile
    add     r6, #4
    ldrb    r3, [r0, r6]        //r3 = hardness of tile
    add     r6, #1
    cmp     r3, #0
    ldreq   r3, =fTile          //if hardness 0, then it's a floor tile
    beq     drawFirsT
    cmp     r7, #4
    ldreq   r3, =bBrick         //row 4 has blue bricks
    cmp     r7, #5
    ldreq   r3, =oBrick         //row 5 orange bricks
    ldr     r3, =gBrick         //bricks are not blue or orange, then it's green
drawFirsT:
    ldr     r0, =drawArgs
    bl      drawBGTile

checkSec:
    cmp     r4, #40
    movle   r9, #0              //flag for ball covering tile to the right
    movgt   r9, #1
    ble     checkThird
    ldr     r0, =myArray
    ldr     r1, [r0, r6]
    add     r6, #4
    ldr     r2, [r0, r6]
    add     r6, #4
    ldrb    r3, [r0, r6]
    add     r6, #1
    cmp     r3, #0
    ldreq   r3, =fTile          //if hardness 0, then it's a floor tile
    beq     drawSecT
    cmp     r7, #4
    ldreq   r3, =bBrick         //row 4 has blue bricks
    cmp     r7, #5
    ldreq   r3, =oBrick         //row 5 orange bricks
    ldr     r3, =gBrick         //bricks are not blue or orange, then it's green
drawSecT:
    ldr     r0, =drawArgs
    bl	    drawBGTile

checkThird:
    mov     r1, #16
    mov     r2, #9
    mul     r3, r1, r2
    add     r6, r3
    cmp     r5, #8
    movle   r9, #0
    ble     checkFourth
    ldr     r0, =myArray
    ldr     r1, [r0, r6]
    add     r6, #4
    ldr     r2, [r0, r6]
    add     r6, #4
    ldrb    r3, [r0, r6]
    add     r6, #1
    cmp     r3, #0
    ldreq   r3, =fTile          //if hardness 0, then it's a floor tile
    beq     drawThird
    cmp     r7, #4
    ldreq   r3, =bBrick         //row 4 has blue bricks
    cmp     r7, #5
    ldreq   r3, =oBrick         //row 5 orange bricks
    ldr     r3, =gBrick         //bricks are not blue or orange, then it's green
drawThird:
    ldr     r0, =drawArgs
    bl      drawBGTile

checkFourth:
    cmp     r9, #0
    beq     endDrawBG
    ldr     r0, =myArray
    ldr     r1, [r0, r6]
    add     r6, #4
    ldr     r2, [r0, r6]
    add     r6, #4
    ldrb    r3, [r0, r6]
    add     r6, #1
    cmp     r3, #0
    ldreq   r3, =fTile          //if hardness 0, then it's a floor tile
    beq     drawFourth
    cmp     r7, #4
    ldreq   r3, =bBrick         //row 4 has blue bricks
    cmp     r7, #5
    ldreq   r3, =oBrick         //row 5 orange bricks
    ldr     r3, =gBrick         //bricks are not blue or orange, then it's green
drawFourth:
    ldr     r0, =drawArgs
    bl      drawBGTile

endDrawBG:
    pop     {r4-r10, pc}

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
