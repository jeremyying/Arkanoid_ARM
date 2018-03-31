
@ Code section
.section .text

/*gameMap returns an int in r0:

      1 - Restart game
      2 - Main Menu */
.global gameMap
gameMap:
    push    {r4-r10, lr}

    bl      init_Array
    bl      initMap
    bl      initPaddle
    bl      initBall

    APressed .req r10
    sticky  .req r9

    mov     APressed, #0
    mov     sticky, #0


play:

    mov     r0, #16650
    bl      delayMicroseconds

    ldr     r0, =destroyed
    ldr     r1, [r0]
    cmp     r1, #72 		//check if all blocks destroyed
    beq     WinGame

    ldr     r0, =lives
    ldr     r1, [r0]
    cmp     r1, #0 		//check if lives are 0
    beq     LoseGame

    bl      Read_SNES
    mov     r2, #0xffff     	//no buttons pressed
    ldr     r0, =buttons
    ldr     r3, =paddleStats
    mov     r4, #0
    cmp     r1, r2
    streq   r4, [r0, #4]
    beq     continue

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
    moveq   r1, #-2 		//A is pressed, speed paddle up
    movne   r1, #-1 		//negative paddle speed
    str     r1, [r0, #4] 		//store paddlespeed in paddleStats
    b       continue

RPaddleMove:

    ldr     r0, =paddleStats
    cmp     APressed, #1
    moveq   r1, #2 		//A is pressed, speed paddle up
    movne   r1, #1 		//negative paddle speed
    str     r1, [r0, #4] 		//store paddlespeed in paddleStats
    b       continue

PauseMenuTrigger:
    bl      PauseMenuButtonCheck
    /*PauseMenuButtonCheck returns an int in r0 based on user selections made inside the pause menu:
          1 - Restart game
          2 - Quit game
          3 - Resume game */

    cmp	    r0, #1 //ret Restart game flag
    beq     endPlay
    cmp     r0, #2 //ret Main Menu flag
    beq     endPlay
    cmp r0, #3 //Resume Game
    beq continue //? I assume this continues the game?


continue:
    //bl      moveBall
    bl      movePaddle
    ldr     r0, =stickyPack
    cmp     sticky, #1
    streq   sticky, [r0]
    moveq   sticky, #0
    b       play

WinGame:
    mov     r0, #2
    // need to print win message
    b       endPlay

LoseGame:
    mov     r0, #2
    // need to print lose message
    b       endPlay

endPlay:
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
