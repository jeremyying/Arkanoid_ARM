
@ Code section
.section .text

.global gameMap
gameMap:
    push    {r4-r10, lr}

    bl      init_Array
    bl      initMap
    bl      initPaddle
    bl      initBall
    bl      updateStats

    APressed .req r10
    sticky  .req r9

    mov     APressed, #0
    mov     sticky, #0

play:

    //mov     r0, #20000
    //bl      delayMicroseconds

    ldr     r0, =destroyed
    ldr     r1, [r0]
    cmp     r1, #72 		//check if all blocks destroyed
    beq     WinGame

    ldr     r0, =lives
    ldr     r1, [r0]
    cmp     r1, #0 		//check if lives are 0
    moveq   r1, #5
    streq   r1, [r0]
    beq     LoseGame

    bl      Read_SNES
    mov     r2, #0xffff     	//no buttons pressed

    ldr     r3, =paddleStats
    mov     r4, #0
    cmp     r1, r2
    streq   r4, [r0, #4]

    beq     continue

    ldr     r0, =attached
    mov     r4, #0
    str     r4, [r0]

    ldr     r0, =buttons

    ldrb    r2, [r0, #3]
    cmp     r2, #0 		//check if START is pressed
    beq     PauseMenuTrigger

    ldrb    r2, [r0]
    cmp     r2, #0 		//check if B is pressed
    beq     DetachBall

    ldrb    r2, [r0,#8]
    cmp     r2, #0 		//check if A is pressed
    moveq   APressed, #1 	//A accelerates Paddle Speed

    ldrb    r2, [r0, #6]
    cmp     r2, #0 		//check if LEFT is pressed
    beq     LPaddleMove

    ldrb    r2, [r0, #7]
    cmp     r2, #0 		//check if RIGHT is pressed
    beq     RPaddleMove

    b       continue

DetachBall:
    ldr     r0, =attached
    ldr     r1, [r0]
    cmp     r1, #0
    beq     continue
    mov     r1, #0
    str     r1, [r0]
    ldr     r0, =stickyPack
    ldr     r1, [r0]
    cmp     r1, #1
    moveq   sticky, r1
    moveq   r1, #0
    streq   r1, [r0]
    b       continue

LPaddleMove:

    ldr     r0, =paddleStats
    cmp     APressed, #1
    moveq   r1, #-18 		//A is pressed, speed paddle up
    movne   r1, #-9 		//negative paddle speed

    moveq   APressed, #0

    str     r1, [r0, #4] 		//store paddlespeed in paddleStats
    b       continue

RPaddleMove:

    ldr     r0, =paddleStats
    cmp     APressed, #1
    moveq   r1, #18 		//A is pressed, speed paddle up
    movne   r1, #9 		//negative paddle speed
    moveq   APressed, #0
    str     r1, [r0, #4] 		//store paddlespeed in paddleStats
    b       continue

PauseMenuTrigger:
    bl      PauseMenuButtonCheck

    cmp	    r0, #1
    beq     endPlay
    cmp     r0, #2
    beq     endPlay
    cmp     r0, #3
    beq     continue


continue:
	bl		checkCollisions
    bl      drawGame
    bl      moveBall
    bl      movePaddle

//    bl checkPowerUp //Spawn PowerUp
  //  bl updatePowerup //Updates Spawned PowerUp

    ldr     r0, =stickyPack
    cmp     sticky, #1
    streq   sticky, [r0]
    moveq   sticky, #0

    bl      updateStats

    b       play

WinGame:
    mov     r0, #2
    push {r0}
    // need to print win message

    ldr     r0, =drawArgs
    ldr     r1, =WinImage
    str     r1, [r0]
    mov     r1, #760 		//x coord
    str     r1, [r0, #4]
    mov     r1, #416 		//y coord
    str     r1, [r0, #8]
    mov     r1, #304 		//image width
    str     r1, [r0, #12]
    mov     r1, #152 		//image height
    str     r1, [r0, #16]
    bl      drawImage

    b       PressToReturn

LoseGame:

    mov     r0, #2
    push {r0}
    // need to print lose message

    ldr     r0, =drawArgs
    ldr     r1, =LoseImage
    str     r1, [r0]
    mov     r1, #760 		//x coord
    str     r1, [r0, #4]
    mov     r1, #416 		//y coord
    str     r1, [r0, #8]
    mov     r1, #304 		//image width
    str     r1, [r0, #12]
    mov     r1, #152 		//image height
    str     r1, [r0, #16]
    bl      drawImage

    b PressToReturn

PressToReturn:
  bl Read_SNES
  mov r2, #0xffff
  cmp r1, r2
  beq PressToReturn

  pop {r0}

  endPlay:
    ldr r9, =lives
    mov r10, #5
    str r10, [r9] //reset Lives to 5 after ending a game

    ldr r9, =score
    mov r10, #0
    str r10, [r9] //reset to Score to 0 after ending a game

    ldr r9, =destroyed
    str r10, [r9]

    ldr r9, =paddleStats
    str r10, [r9, #8]

    ldr r9, =stickyPack
    str r10, [r9]
    str r10, [r9, #4]

    ldr r9, =attached
    mov r10, #1
    str r10, [r9]

    .unreq  APressed
    pop     {r4-r10, pc}


.global initMap
initMap:
    push    {r4-r8, lr}

    ldr     r0, =drawArgs
    ldr     r1, =topBar             //image ascii text address
    str     r1, [r0]
    mov     r1, #528                   //x coordinate
    str     r1, [r0, #4]
    mov     r1, #24                    //y coordinate
    str     r1, [r0, #8]
    mov     r1, #768                //image width
    str     r1, [r0, #12]
    mov     r1, #32                 //image height
    str     r1, [r0, #16]
    bl      drawImage

    mov     r4, #304
    mov     r5, #1520

topWall:
    ldr     r0, =drawArgs
    ldr     r1, =wtTile     	    //image ascii text address
    str     r1, [r0]
    mov     r1, r4	   	        //x coordinate
    str     r1, [r0, #4]
    mov     r1, #56        	        //y coordinate
    str     r1, [r0, #8]
    mov     r1, #64         	    //image width
    str     r1, [r0, #12]
    mov     r1, #32         	    //image height
    str     r1, [r0, #16]
    bl      drawImage
    add     r4, #64
    cmp     r4, r5
    blt     topWall

    mov     r4, #88
    mov     r5, #984

leftWall:
    ldr     r0, =drawArgs
    ldr     r1, =wsTile             //image ascii text address
    str     r1, [r0]
    mov     r1, #304                   //x coordinate
    str     r1, [r0, #4]
    mov     r1, r4                    //y coordinate
    str     r1, [r0, #8]
    mov     r1, #32                 //image width
    str     r1, [r0, #12]
    mov     r1, #64                 //image height
    str     r1, [r0, #16]
    bl      drawImage
    add     r4, #64
    cmp     r4, r5
    blt     leftWall

    mov     r4, #88
    mov     r5, #984

rightWall:
    ldr     r0, =drawArgs
    ldr     r1, =wsTile             //image ascii text address
    str     r1, [r0]
    mov     r1, #1488                   //x coordinate
    str     r1, [r0, #4]
    mov     r1, r4                    //y coordinate
    str     r1, [r0, #8]
    mov     r1, #32                 //image width
    str     r1, [r0, #12]
    mov     r1, #64                 //image height
    str     r1, [r0, #16]
    bl      drawImage
    add     r4, #64
    cmp     r4, r5
    blt     rightWall

    mov     r4, #336
    mov     r5, #88
    mov     r6, #0
    mov     r7, #1488

topFloor:
    ldr     r0, =drawArgs
    ldr     r1, =fTile             //image ascii text address
    str     r1, [r0]
    mov     r1, r4                  //x coordinate
    str     r1, [r0, #4]
    mov     r1, r5                    //y coordinate
    str     r1, [r0, #8]
    mov     r1, #64                //image width
    str     r1, [r0, #12]
    mov     r1, #32                 //image height
    str     r1, [r0, #16]
    bl      drawImage
    add     r4, #64
    teq     r4, r7
    moveq   r4, #336
    addeq   r5, #32
    add     r6, #1
    cmp     r6, #72
    blt     topFloor

    mov     r4, #336
    mov     r5, #216
    mov     r6, #0
    mov     r7, #1488
    mov     r8, #432

bottomFloor:
    ldr     r0, =drawArgs
    ldr     r1, =fTile             //image ascii text address
    str     r1, [r0]
    mov     r1, r4                  //x coordinate
    str     r1, [r0, #4]
    mov     r1, r5                    //y coordinate
    str     r1, [r0, #8]
    mov     r1, #64                //image width
    str     r1, [r0, #12]
    mov     r1, #32                 //image height
    str     r1, [r0, #16]
    bl      drawImage
    add     r4, #64
    teq     r4, r7
    moveq   r4, #336
    addeq   r5, #32
    add     r6, #1
    cmp     r6, r8
    bne     bottomFloor

    mov     r4, #336
    mov     r5, #1488

bluBricks:
    ldr     r0, =drawArgs
    ldr     r1, =bBrick             //image ascii text address
    str     r1, [r0]
    mov     r1, r4                  //x coordinate
    str     r1, [r0, #4]
    mov     r1, #216                    //y coordinate
    str     r1, [r0, #8]
    mov     r1, #64                //image width
    str     r1, [r0, #12]
    mov     r1, #32                 //image height
    str     r1, [r0, #16]
    bl      drawImage
    add     r4, #64
    cmp     r4, r5
    blt     bluBricks

    mov     r4, #336
    mov     r5, #1488

orangBricks:
    ldr     r0, =drawArgs
    ldr     r1, =oBrick             //image ascii text address
    str     r1, [r0]
    mov     r1, r4                  //x coordinate
    str     r1, [r0, #4]
    mov     r1, #248                    //y coordinate
    str     r1, [r0, #8]
    mov     r1, #64                //image width
    str     r1, [r0, #12]
    mov     r1, #32                 //image height
    str     r1, [r0, #16]
    bl      drawImage
    add     r4, #64
    cmp     r4, r5
    blt     orangBricks

    mov     r4, #336
    mov     r5, #280
    mov     r6, #0
    mov     r7, #1488

greenBricks:
    ldr     r0, =drawArgs
    ldr     r1, =gBrick             //image ascii text address
    str     r1, [r0]
    mov     r1, r4                  //x coordinate
    str     r1, [r0, #4]
    mov     r1, r5                    //y coordinate
    str     r1, [r0, #8]
    mov     r1, #64                //image width
    str     r1, [r0, #12]
    mov     r1, #32                 //image height
    str     r1, [r0, #16]
    bl      drawImage
    add     r4, #64
    teq     r4, r7
    moveq   r4, #336
    addeq   r5, #32
    add     r6, #1
    cmp     r6, #36
    blt     greenBricks

    pop     {r4-r8, pc}
