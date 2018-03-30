
@ Code section
.section .text

/*gameMap consists of the core gameplay loop that takes user input and manipulates the ball
 or paddle accordingly. It returns an int in r0 that acts as a flag:
      0 - Main Menu
      1 - Restart game
      2 - Resume gameplay */
.global gameMap
gameMap:
    push    {r4-r10, lr}

    bl      init_Array //Create Bricks

    bl      initMap //draw Images
    bl      initPaddle
    bl      initBall

    APressed .req r10
    mov APressed, #0



//Main game loop
//Exit Main if Win, Lose, PauseMenu
  ldr r8, =destroyed
  ldr r9, =lives
play:
  ldr r6, [r8]
  cmp r6, #72 //check if all blocks destroyed
  beq WinGame

  ldr r7, [r9]
  cmp r7, #0 //check if lives are 0
  beq LoseGame

  bl      Read_SNES

  bl moveBall

  mov     r2, #0xffff     //no buttons pressed
  cmp     r1, r2
  beq     play

  ldrb r2, [r0, #3]
  cmp r2, #0 //check if START is pressed
  beq PauseMenuTrigger

  ldrb r2, [r0]
  cmp r2, #0 //check if B is pressed
  beq DetachBall

  ldrb r2, [r0,#8]
  cmp r2, #0 //check if A is pressed
  moveq APressed, #1 //A accelerates Paddle Speed

  ldrb r2, [r0, #6]
  cmp r2, #0 //check if LEFT is pressed
  beq LPaddelMove

  ldrb r2, [r0, #7]
  cmp r2, #0 //check if RIGHT is pressed
  beq RPaddleMove

  b play

DetachBall:
  ldr r4, =attached
  ldr r3, [r4]
  cmp r3, #0
  beq play

  mov r3, #0
  str r3, [r4] //set Attach to 0
  bl moveBall

//INSERT BULLSHIT

  b play


LPaddelMove:
  ldr r0, =paddleStats
  cmp APressed, #1
  moveq r1, #-2 //A is pressed, speed paddle up
  movne r1, #-1 //negative paddle speed
  str r1, [r0] //store paddlespeed in paddleStats
  b play

RPaddleMove:
  ldr r0, =paddleStats
  cmp APressed, #1
  moveq r1, #2 //A is pressed, speed paddle up
  movne r1, #1 //negative paddle speed
  str r1, [r0] //store paddlespeed in paddleStats
  b play

WinGame:
  //print win screen, go back to main menu
  mov r0, #0 //set 0 to go back to main


  pop     {r4-r10, pc} //ret

LoseGame:
  //print lose screen, go back to main menu
  mov r0, #0 //set 0 to go back to main


  pop     {r4-r10, pc} //ret

PauseMenuTrigger:
  bl PauseMenuButtonCheck
  /*PauseMenuButtonCheck returns an int in r0 based on user selections made inside the pause menu:
        1 - Restart game
        2 - Quit game
        3 - Resume game */

    //need to return argument in r0 for restarting game or quitting to go to main menu
  cmp r0, #1 //set ret to Restart Game
  beq ReturnPauseMenuTrigger

  cmp r0, #2
  moveq r0, #0 //set ret to Main Menu
  beq ReturnPauseMenuTrigger

  cmp r0, #3
  moveq r0, #2 //set ret to Resume Game
  beq ReturnPauseMenuTrigger
ReturnPauseMenuTrigger:


  pop     {r4-r10, pc}


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
