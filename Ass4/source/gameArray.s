/*	Cristhian Sotelo-Plaza
	30004060
	
	Zheyu Jeremy Ying
	30002931
	
	Zachary	Metz
	30001506
	
	CPSC359 WINTER 2018
	Assignment 4

*/


@ Code section
.section .text

//initArray stores x,y coordinates and hardness of each tile

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
    str     r1, [r0], #4	//store current x coordinate
    str     r2, [r0], #4	//store current y coordinate
    strb    r3, [r0], #1	//store hardness
    add     r1, #64		//increase x coordinate by tile width
    teq     r1, r5		//check if x is at right boundary
    moveq   r1, #336		//reset x
    addeq   r2, #32		//increase y coordinate by tile height
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
    
    
    
//drawGame draws current state of tiles around the brick area    

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
    ldr     r7, [r4], #4	//get x coordinate
    ldr     r8, [r4], #4	//get y coordinate
    ldrb    r9, [r4], #1	//get hardness
    ldr     r0, =drawArgs	//load draw arguments
    cmp     r9, #0		//check hardness
    ldreq   r1, =fTile		//load floor tile image
    cmp     r9, #1
    ldreq   r1, =gBrick		//load green brick tile if hardness is 1
    cmp     r9, #2
    ldreq   r1, =oBrick		//load orange tile..
    cmp     r9, #3
    ldreq   r1, =bBrick
    str     r1, [r0]
    str     r7, [r0, #4]	//pass x
    str     r8, [r0, #8]	//pass y
    mov     r1, #64		//pass width of tile
    str     r1, [r0, #12]
    mov     r1, #32		//pass height of tile
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
