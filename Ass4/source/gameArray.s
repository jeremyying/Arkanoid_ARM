
@ Code section
.section .text

.global init_Array
init_Array:
    push    {r4-r7}

    ldr     r0, =myArray
    mov     r1, #336        //x coordinate of tile
    mov     r2, #88         //y coordinate
    mov     r3, #0          //hardness
    mov     r4, #0          //number of elements stored
    mov     r5, #1488       //x right boundary

topFloor:
    str     r1, [r0], #4
    str     r2, [r0], #4
    strb    r3, [r0], #1
    add     r1, #64
    teq     r1, r5
    moveq   r1, #336
    addeq   r2, #32
    add     r4, #1
    cmp     r4, #72
    blt     topFloor

    mov     r3, #3
    mov     r4, #0
blueBr:
    str     r1, [r0], #4
    str     r2, [r0], #4
    strb    r3, [r0], #1
    add     r1, #64
    teq     r1, r5
    moveq   r1, #336
    addeq   r2, #32
    add     r4, #1
    cmp     r4, #18
    blt     blueBr

    mov     r3, #2
    mov     r4, #0
orangBr:
    str     r1, [r0], #4
    str     r2, [r0], #4
    strb    r3, [r0], #1
    add     r1, #64
    teq     r1, r5
    moveq   r1, #336
    addeq   r2, #32
    add     r4, #1
    cmp     r4, #18
    blt     orangBr

    mov     r3, #1
    mov     r4, #0
greenBr:
    str     r1, [r0], #4
    str     r2, [r0], #4
    strb    r3, [r0], #1
    add     r1, #64
    teq     r1, r5
    moveq   r1, #336
    addeq   r2, #32
    add     r4, #1
    cmp     r4, #36
    blt     greenBr

    mov     r3, #0
    mov     r4, #0
    mov     r6, #360
bottFloor:
    str     r1, [r0], #4
    str     r2, [r0], #4
    strb    r3, [r0], #1
    add     r1, #64
    teq     r1, r5
    moveq   r1, #336
    addeq   r2, #32
    add     r4, #1
    cmp     r4, r6
    blt     bottFloor

    pop     {r4-r7}
    mov     pc, lr

.global drawGame
drawGame:
    push    {r4-r9, lr}
    
    mov     r1, #4
    mov     r2, #18
    mul     r3, r1, r2
    add     r3, r3, lsl #3

    ldr     r4, =myArray
    add     r4, r3
    mov     r5, #0
    mov     r6, #72

printLoop:
    ldr     r7, [r4], #4
    ldr     r8, [r4], #4
    ldrb    r9, [r4], #1
    ldr     r0, =drawArgs
    cmp     r9, #0
    ldreq   r1, =fTile
    cmp     r9, #1
    ldreq   r1, =gBrick
    cmp     r9, #2
    ldreq   r1, =oBrick
    cmp     r9, #3
    ldreq   r1, =bBrick
    str     r1, [r0]
    str     r7, [r0, #4]
    str     r8, [r0, #8]
    mov     r1, #64
    str     r1, [r0, #12]
    mov     r1, #32
    str     r1, [r0, #16]
    bl      drawImage
    add     r5, #1
    cmp     r5, r6
    blt     printLoop
    

    pop     {r4-r9, pc}



@ Data section
.section .data

.global myArray
myArray:
.skip       504*9




