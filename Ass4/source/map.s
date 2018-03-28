
@ Code section
.section .text

.global gameMap
gameMap:
    push    {lr}

    bl      init_Array

    bl      initMap

play:
    bl      action

    //need to return argument in r0 for restarting game or quitting to go to main menu

    pop     {pc}

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

