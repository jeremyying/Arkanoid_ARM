
@ Code section
.section .text

//------
//action: Main game Loop
.global action
action:
    push    {r4-r8, lr}

    bl      initPaddle
    bl      initBall

    pop     {r4-r8, pc}


initPaddle:
    push    {lr}

    ldr     r0, =drawArgs
    ldr     r2, =paddleStats
    ldr     r1, =paddle             //image ascii text address
    str     r1, [r0]
    mov     r1, #848                   //x coordinate
    str     r1, [r0, #4]
    str     r1, [r2]
    mov     r1, #920                    //y coordinate
    str     r1, [r0, #8]
    str     r1, [r2, #4]
    mov     r1, #128                //image width
    str     r1, [r0, #12]
    mov     r1, #32                 //image height
    str     r1, [r0, #16]
    bl      drawImage

    pop     {pc}

initBall:
    push    {lr}

    ldr     r0, =drawArgs
    ldr     r2, =ballStats
    ldr     r1, =ball             //image ascii text address
    str     r1, [r0]
    mov     r1, #900                   //x coordinate
    str     r1, [r0, #4]
    str     r1, [r2]
    mov     r1, #896                    //y coordinate
    str     r1, [r0, #8]
    str     r1, [r2, #4]
    mov     r1, #24                //image width
    str     r1, [r0, #12]
    mov     r1, #24                 //image height
    str     r1, [r0, #16]
    bl      drawImage

    pop     {pc}



@ Data section
.section .data

.global ballStats
ballStats:
    .int    0       //x coordinate
    .int    0       //y coordinate
    .int    0       //x speed
    .int    0       //y speed

.global paddleStats
paddleStats:
    .int    0       //x coordinate
    .int    0       //y coordinate
    .int    0       //x speed

.global attached
attached:
    .int    0       //flag for ball attached to paddle

.global win
win:
    int.    0

.global lose
lose:
    .int    0





