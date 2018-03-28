
@ Code section
.section .text

.global main
init_Array:
    push    {r4-r7}

    ldr     r0, =myArray
    mov     r1, #336        //x coordinate of tile
    mov     r2, #88         //y coordinate
    mov     r3, #0          //hardness
    mov     r4, #0
    mov     r5, #1488

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

@ Data section
.section .data

.global myArray
myArray:
.skip       504*9





