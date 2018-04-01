
@ Code section
.section .text

.global mainMenu
mainMenu:
    push    {r4-r8, lr}

menu:
    bl      displayMenu
    mov     r4, #0

waitLoop:
    bl      Read_SNES
    mov     r2, #0xffff     //no buttons pressed
    cmp     r1, r2
    beq     waitLoop

    ldrb    r2, [r0, #8]    //check A button, index button #-1
    cmp     r2, #0
    beq     pickOption
    ldrb    r2, [r0, #4]    //check UP button
    cmp     r2, #0
    moveq   r4, #0
    beq     drawArrow      //display arrow on start
    ldrb    r2, [r0, #5]    //check DOWN button
    cmp     r2, #0
    moveq   r4, #1
    beq     drawArrow       //display arrow on quit
    b       waitLoop

pickOption:
    cmp     r4, #1
    beq     endMenu

startGame:
    bl      gameMap         //start game
    cmp     r0, #1
    beq     startGame       //restart game, from pause menu
    cmp     r0, #2
    beq       menu

drawArrow:
    mov     r5, #744        //x coordinate to blackout
    mov     r6, #678        //y coordinate to blackout
    mov     r7, #780         //max x
    mov     r8, #783        //max y

blackout:
    mov     r0, r5
    mov     r1, r6
    mov     r2, #0xFF000000
    bl      DrawPixel
    add     r5, #1
    teq     r5, r7
    moveq   r5, #744
    addeq   r6, #1
    cmp     r6, r8
    blt     blackout

    cmp     r4, #1
    moveq   r5, #744		//x coordinate of arrow on quit
    moveq   r6, #738        	//y coordinate of arrow on quit
    movne   r5, #744        	//x coordinate of arrow on start
    movne   r6, #678        	//y coordinate of arrow on start

    ldr     r0, =drawArgs
    ldr     r1, =arrow
    str     r1, [r0]
    mov     r1, r5           	//x coordinate of arrow
    str     r1, [r0, #4]
    mov     r1, r6           	//y coordinate of arrow
    str     r1, [r0, #8]
    mov     r1, #36           	//width of arrow image
    str     r1, [r0, #12]
    mov     r1, #45           	//height of arrow image
    str     r1, [r0, #16]
    bl      drawImage
    b       waitLoop

endMenu:
    mov     r4, #0
    mov     r5, #24
    mov     r6, #1824
    mov     r7, #984

endMenuLoop:
    mov     r0, r4
    mov     r1, r5
    mov     r2, #0xFF000000
    bl      DrawPixel
    add     r4, #1
    teq     r4, r6
    moveq   r4, #0
    addeq   r5, #1
    cmp     r5, r7
    blt     endMenuLoop


    pop     {r4-r8, pc}

.global displayMenu
displayMenu:
    push    {r4-r7, lr}

    mov     r4, #0
    mov     r5, #24
    mov     r6, #1824
    mov     r7, #984

blackLoop:
    mov     r0, r4
    mov     r1, r5
    mov     r2, #0xFF000000
    bl      DrawPixel
    add     r4, #1
    teq     r4, r6
    moveq   r4, #0
    addeq   r5, #1
    cmp     r5, r7
    blt     blackLoop


    ldr     r0, =drawArgs
    ldr     r1, =mMenu          //image ascii text address, name of game
    str     r1, [r0]
    mov     r1, #546          	//x coordinate
    str     r1, [r0, #4]
    mov     r1, #350            //y coordinate
    str     r1, [r0, #8]
    mov     r1, #732            //image width
    str     r1, [r0, #12]
    mov     r1, #120            //image height
    str     r1, [r0, #16]
    bl      drawImage

NamesPrint:
    ldr     r0, =drawArgs
    ldr     r1, =creator
    str     r1, [r0]
    mov     r1, #340 		//x coord
    str     r1, [r0, #4]
    mov     r1, #70 		//y coord
    str     r1, [r0, #8]
    mov     r1, #292 		//image width
    str     r1, [r0, #12]
    mov     r1, #98 		//image height
    str     r1, [r0, #16]
    bl      drawImage

MainMenuSelectionPrint:
    ldr     r0, =drawArgs
    ldr     r1, =menuOpts
    str     r1, [r0]
    mov     r1, #795 		//x coord
    str     r1, [r0, #4]
    mov     r1, #678 		//y coord
    str     r1, [r0, #8]
    mov     r1, #235 		//image width
    str     r1, [r0, #12]
    mov     r1, #120 		//image height
    str     r1, [r0, #16]
    bl      drawImage

MainMenuArrowPrint:
    ldr     r0, =drawArgs
    ldr     r1, =arrow
    str     r1, [r0]
    mov     r1, #744 		//x coord (759 base)
    str     r1, [r0, #4]
    mov     r1, #678 		//y coord
    str     r1, [r0, #8]
    mov     r1, #36 		//image width
    str     r1, [r0, #12]
    mov     r1, #45 		//image height
    str     r1, [r0, #16]
    bl      drawImage

    pop     {r4-r7, pc}


//PauseMenuPrint draws the pause menu and arrow
    PauseMenuPrint:
      push {lr}
      ldr r0, =drawArgs
      ldr r1, =PauseMenuImage
      str r1, [r0]
      mov r1, #656 //x coord of PauseMenu
      str r1, [r0, #4]
      mov r1, #344 //y coord of PauseMenu
      str r1, [r0, #8]
      mov r1, #512 //image width
      str r1, [r0, #12]
      mov r1, #384 //image height
      str r1, [r0, #16]
      bl drawImage

    PauseArrowPrint:
      ldr r0, =drawArgs
      ldr r1, =arrow
      str r1, [r0]
      mov r1, #784 //x coord of PauseArrow
      str r1, [r0, #4]
      mov r1, #515 //y coord of PauseArrow
      str r1, [r0, #8]
      mov r1, #36 //image width
      str r1, [r0, #12]
      mov r1, #45 //image height
      str r1, [r0, #16]
      bl drawImage
      pop {pc}

    /*PauseMenuButtonCheck returns an int in r0 based on user selections made inside the pause menu:
          1 - Restart game
          2 - Quit game
          3 - Resume game */
    .global PauseMenuButtonCheck
    PauseMenuButtonCheck:
      push {r4-r10, lr}

      bl PauseMenuPrint //prints PauseMenu and arrow

      ArrowPosition .req r10
      mov ArrowPosition, #1

    PauseMenuLoop:
      bl Read_SNES
      mov r2, #0xffff //no buttons are pressed
      cmp r1, r2


      beq PauseMenuLoop

      ldrb r2, [r0, #3] //check if START is pressed
      cmp r2, #0
      moveq ArrowPosition, #3 //Exit Pause Menu flag
      beq  PauseMenuDrawFloor

      ldrb r2, [r0, #4] //check if UP is pressed
      cmp r2, #0
      beq PauseMenuArrowUP

      ldrb r2, [r0, #5] //check if DOWN is pressed
      cmp r2, #0
      beq PauseMenuArrowDOWN

      ldrb r2, [r0, #8] //check if A is pressed
      cmp r2, #0
      beq PauseMenuDrawFloor //A is pressed when Arrow is on Restart

      b PauseMenuLoop //check for button presses

    PauseMenuArrowUP:
      mov ArrowPosition, #1 //Arrow Position at Restart
      mov r4, #784 // x coord at Restart
      mov r5, #515 // y coord at Restart
      b PauseMenuRemoveArrow

    PauseMenuArrowDOWN:
      mov ArrowPosition, #2 //Arrow Position at Quit
      mov r4, #784 // x coord at Quit
      mov r5, #590 // y coord at Quit
      b PauseMenuRemoveArrow

    PauseMenuRemoveArrow:
      mov     r6, #784 //x value
      mov     r7, #515 //yvalue
      mov     r8, #820 //max x
      mov     r9, #635 //max y

    PauseMenuRemoveArrowLoop:
      mov     r0, r6
      mov     r1, r7
      mov     r2, #0xFF000000
      bl      DrawPixel
      add     r6, #1
      teq     r6, r8
      moveq   r6, #784
      addeq   r7, #1
      cmp     r7, r9
      blt     PauseMenuRemoveArrowLoop


    PauseMenuDrawArrow:
      ldr r0, =drawArgs
      ldr r1, =arrow
      str r1, [r0]
      mov r1, r4 //x coord of PauseArrow
      str r1, [r0, #4]
      mov r1, r5 //y coord of PauseArrow
      str r1, [r0, #8]
      mov r1, #36 //image width
      str r1, [r0, #12]
      mov r1, #45 //image height
      str r1, [r0, #16]
      bl drawImage
      b PauseMenuLoop

    PauseMenuDrawFloor:
      mov r4, #656 //starting x coord
      mov r5, #344 //starting y coord
      mov r6, #1168 //max x
      mov r7, #728 //maximum y coord

    PauseMenuDrawFloorLoop:
      ldr r0, =drawArgs
      ldr r1, =fTile //floor tile address
      str r1, [r0]
      mov r1, r4 //x coord of PauseArrow
      str r1, [r0, #4]
      mov r1, r5 //y coord of PauseArrow
      str r1, [r0, #8]
      mov r1, #64 //image width
      str r1, [r0, #12]
      mov r1, #32 //image height
      str r1, [r0, #16]
      bl drawImage
      add r4, #64 //increment x by a block width
      teq r4, r6 //check if x coord of block has surpassed maximum
      moveq r4, #656 //reset x coord to starting x coord
      addeq r5, #32 //increment y by block height
      cmp r5, r7
      bne PauseMenuDrawFloorLoop

    PauseMenuReturn:
      mov r0, ArrowPosition //return int 1 (Restart), 2 (Quit), or 3 (Resume)
      .unreq ArrowPosition
      pop {r4-r10, pc} //return




