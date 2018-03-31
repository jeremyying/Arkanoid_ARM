/*  Cristhian Sotelo-Plaza
    30004060

    SNES controller driver
 */


.section    .text

.global init_SNES
init_SNES:
    push    {lr}

    bl        getGpioPtr        //Get GPIO base address and save it
    ldr        r1, =gpioBaseAddress
    str        r0, [r1]

    mov     r0, #9
    mov     r1, #1
    bl      Init_GPIO   //Set GPIO 9, LATCH, to output
    mov     r0, #10
    mov     r1, #0
    bl      Init_GPIO   //Set GPIO 10, DATA, to input
    mov     r0, #11
    mov     r1, #1
    bl      Init_GPIO   //Set GPIO 11, CLOCK, to output

    pop     {pc}

.global Read_SNES
Read_SNES:
    push    {r4-r7, lr}
    i_r     .req r4
    ldr     r5, =buttons
    mov     r6, #1
    mov     r7, #0      //register representation of buttons

    mov     r0, #1
    bl      Write_Clock
    mov     r0, #1
    bl      Write_Latch
    mov     r0, #12
    bl      delayMicroseconds
    mov     r0, #0
    bl      Write_Latch
    mov     i_r, #0

pulseLoop:
    mov     r0, #6
    bl      delayMicroseconds
    mov     r0, #0
    bl      Write_Clock
    mov     r0, #6
    bl      delayMicroseconds
    bl      Read_Data
    strb    r0, [r5, i_r]       //store individual button in array
    teq     r0, #1
    orreq   r7, r6
    lsl     r6, #1
    mov     r0, #1
    bl      Write_Clock
    add     i_r, #1
    cmp     i_r, #16
    blt     pulseLoop

    .unreq  i_r
    ldr     r0, =buttons
    mov     r1, r7

    push {r0}
    ldr     r0, =#86000
    bl      delayMicroseconds
    pop {r0}

    pop     {r4-r7, pc}


.global Init_GPIO
Init_GPIO:
    push    {r4, lr}
    ldr     r3, =gpioBaseAddress
    ldr     r4, [r3]

initLoop:
    cmp     r0, #9          //get GPIO register by dividing by 10
    subhi   r0, #10
    addhi   r4, #4       //gBase becomes GPIO register address
    bhi     initLoop

    add     r0, r0, lsl #1  //multiply remainder by 3
    lsl     r1, r0          //function code moved to pin# bits

    mov     r2, #7
    lsl     r2, r0          //move 111 to pin# bits

    ldr     r0, [r4]     //get current GPIO register
    bic     r0, r2          //clear pin# bits
    orr     r0, r1          //set function to pin#
    str     r0, [r4]     //update GPIO register
    pop     {r4, pc}

Write_Latch:
    ldr     r3, =gpioBaseAddress
    ldr     r2, [r3]
    mov     r1, #1
    lsl     r1, #9
    teq     r0, #0
    streq   r1, [r2, #40]
    strne   r1, [r2, #28]
    mov     pc, lr

Write_Clock:
    ldr     r3, =gpioBaseAddress
    ldr     r2, [r3]
    mov     r1, #1
    lsl     r1, #11
    teq     r0, #0
    streq   r1, [r2, #40]
    strne   r1, [r2, #28]
    mov     pc, lr

Read_Data:
    push    {r4, lr}
    ldr     r3, =gpioBaseAddress
    ldr     r4, [r3]
    ldr     r1, [r4, #52]
    mov     r2, #1
    lsl     r2, #10
    and     r1, r2
    teq     r1, #0
    moveq   r0, #0
    movne   r0, #1
    pop     {r4, pc}


@ Data section
.section .data

.global buttons
buttons:
.skip   16*1

.align 2
.global gpioBaseAddress
gpioBaseAddress:
.int    0
