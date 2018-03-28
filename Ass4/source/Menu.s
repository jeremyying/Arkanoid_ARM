
@ Code section
.section .text

.global mainMenu
mainMenu:
    push    {r4-r8, lr}

menu:
    bl displayMenu
    mov     r4, #0

waitLoop:
    bl      Read_SNES
    mov     r2, #0xffff     //no buttons pressed
    cmp     r1, r2

    beq     waitLoop




ldrb    r2, [r0, #8]    //check A button, index button #-1
    cmp     r2, #0
    beq     pickOption //A is pressed
    ldrb    r2, [r0, #4]    //check UP button
    cmp     r2, #0
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
    b       menu

drawArrow:
    mov     r5, #744   //759 is base        //x coordinate to blackout
    mov     r6, #678   //temp        //y coordinate to blackout
    mov     r7, #36   //temp        //width
    mov     r8, #120  //temp        //height

blackout:
    mov     r0, r5
    mov     r1, r6
    mov     r2, #0xFF000000
    bl      DrawPixel
    add     r5, #1
    teq     r5, r7
    moveq   r5, #0
    addeq   r6, #1
    cmp     r6, r8
    blt     blackout

    cmp     r4, #1
    moveq   r5, #744   //temp        //x coordinate of arrow on quit
    moveq   r6, #738   //temp        //y coordinate of arrow on quit

    movne   r5, #744   //temp        //x coordinate of arrow on start
    movne   r6, #678   //temp        //y coordinate of arrow on start

    ldr r0, =drawArgs
    ldr r1, =arrow
    str r1, [r0]
    mov r1, r5 //x coord of arrow
    str r1, [r0, #4]
    mov r1, r6 //y coord of arrow
    str r1, [r0, #8]
    mov r1, #36 //image width of arrow
    str r1, [r0, #12]
    mov r1, #45 //image height of arrow
    str r1, [r0, #16]
    bl drawImage
    b       waitLoop

endMenu:
    pop     {r4-r8, pc}


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
    ldr     r1, =mMenu             //image ascii text address, name of game
    str     r1, [r0]
    mov     r1, #546                   //x coordinate
    str     r1, [r0, #4]
    mov     r1, #350                    //y coordinate
    str     r1, [r0, #8]
    mov     r1, #732                //image width
    str     r1, [r0, #12]
    mov     r1, #120                 //image height
    str     r1, [r0, #16]
    bl      drawImage

//draws the names onto the menu
NamesPrint:
    ldr r0, =drawArgs
    ldr r1, =creator
    str r1, [r0]
    mov r1, #240 //x coord
    str r1, [r0, #4]
    mov r1, #34 //y coord
    str r1, [r0, #8]
    mov r1, #292 //image width
    str r1, [r0, #12]
    mov r1, #98 //image height
    str r1, [r0, #16]
    bl drawImage

MainMenuSelectionPrint:
    ldr r0, =drawArgs
    ldr r1, =menuOpts
    str r1, [r0]
    mov r1, #795 //x coord
    str r1, [r0, #4]
    mov r1, #678 //y coord
    str r1, [r0, #8]
    mov r1, #235 //image width
    str r1, [r0, #12]
    mov r1, #120 //image height
    str r1, [r0, #16]
    bl drawImage

/*
MainMenuArrowPrint:
    ldr r0, =drawArgs
    ldr r1, =arrow
    str r1, [r0]
    mov r1, #759 //x coord
    str r1, [r0, #4]
    mov r1, #678 //y coord
    str r1, [r0, #8]
    mov r1, #36 //image width
    str r1, [r0, #12]
    mov r1, #45 //image height
    str r1, [r0, #16]
    bl drawImage*/


    //display creator names, and menu options, still to complete
    //follow same process as the display of game name
    //position options in the middle under game name
    //position creator names on top left corner
    //put missing coordinates on drawArrow, the blackout loop is to erase previous
    //arrow position, blackout the height of the options image.
    //image labels: menuOpts (235x120), arrow (36x45), creator (292x98)

    pop     {r4-r7, pc}
