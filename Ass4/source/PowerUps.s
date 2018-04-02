/* Cristhian Sotelo-Plaza
   30004060
   Zheyu Jeremy Ying
   30002931
   Zachary Metz
   30001506

   CPSC359 WINTER 2018
   Assignment 4

*/
.data
.global PowerUpBlock
PowerUpBlock:
  .int 0 //x coord
  .int 0 //y coord
  .int 0 //PowerUp Type
         //1 - Extend PowerUp
         //2 - Sticky PowerUp
  .int 0 //On/Off for displaying
         //1 - On
         //0 - Off

.text

//Updates a spawned PowerUp
.global updatePowerup
updatePowerup:
	push 	{r4-r10, lr}

	ldr		r0, =PowerUpBlock
	ldr		r4, [r0]			//r4 = power up x coordinate
	ldr		r5, [r0, #4]		//r5 = power up y coordinate
	ldr   r6, [r0, #8]		//r6 = power up type

	ldr   r0, =paddleStats
	ldr		r7, [r0]			//r7 = paddle x coordinate
	ldr		r8, [r0, #8]		//r8 = paddle extended flag

	sub		r7, #47
	cmp		r4, r7
	blt   nextPower //check if powerup x < paddle x, exit if

	cmp		r8, #1
	moveq r1, #192
	movne r1, #128

	add		r7, #47
	add   r7, r1
	cmp   r4, r7
	bgt   nextPower //check if powerup x > paddle x, exit if

	cmp   r5, #872 //check if powerup y exceeded paddle within paddle x range
	ldrge r0, =PowerUpBlock
	movge r1, #0
	strge r1, [r0, #12]
	bge   activatePower

 nextPower:
	mov		r1, #935
	cmp		r5, r1
	ldrge r0, =PowerUpBlock
	movge r1, #0
	strge r1, [r0, #12] //set powerup display toggle off if powerup goes past paddle
	bge		powerOut

	bl		drawPowerUp
	b		  endPowerUp

activatePower:
	mov		r0, #1
	bl    clearPowerUp //draws over old powerup image
	cmp		r6, #1
	ldreq r0, =paddleStats
	moveq	r1, #1
	streq r1, [r0, #8] //extend paddle on/off?
	ldrne	r0, =stickyPack
	movne	r1, #1
	movne	r2, #4
	strne	r1, [r0] //store sticky pack on/off
	strne r2, [r0, #4] //store sticky pack moves left
	b		endPowerUp

powerOut:
	mov		r0, #0
	bl    clearPowerUp

endPowerUp:
  pop {r4-r10, pc}

//removes old powerup image and draws new powerup
.global drawPowerUp
drawPowerUp:
	push	{r4-r7, lr}

	ldr		r0, =PowerUpBlock
	ldr		r4, [r0] //powerup x
	ldr		r5, [r0, #4] //powerup y
	ldr		r6, [r0, #8] //powerup type

//blackout old drawn position of powerup
	sub		r4, #336
	sub		r5, #88
	mov		r0, #0
	mov		r1, #0

powerXLoop:
    cmp     r4, #63
    subhi   r4, #64
    addhi   r0, #1			//r0 = x index
    bhi     powerXLoop
powerYLoop:
    cmp     r5, #31
    subhi   r5, #32
    addhi   r1, #1			//r1 = y index
    bhi     powerYLoop

	bl      calcOffset
	bl      drawBGTile

//loads powerup block type
	ldr		r0, =PowerUpBlock
	ldr   r4, [r0] //opwerup x
	ldr   r5, [r0, #4] //powerup y
	add		r5, #2 //increment y every draw
	str		r5, [r0, #4]
	cmp		r6, #1 //load appropriate image for the powerup
	ldreq r7, =XPower
	ldrne r7, =SPower

//draw powerup
	ldr		r0, =drawArgs
	str   r7, [r0]
	str		r4, [r0, #4]
	str		r5, [r0, #8]
	mov		r1, #48
	str		r1, [r0, #12]
	str		r1, [r0, #16]
	bl 		drawImage

	pop		{r4-r7, pc}


.global clearPowerUp
clearPowerUp:
	push	{r4-r8, lr}

	mov		r8, r0

	ldr		r0, =PowerUpBlock
	ldr		r4, [r0]
	ldr		r5, [r0, #4]

	sub		r4, #336
	sub		r5, #88
	mov		r6, #0
	mov		r7, #0

clearXLoop:
    cmp     r4, #63
    subhi   r4, #64
    addhi   r6, #1			//r6 = x index
    bhi     clearXLoop
clearYLoop:
    cmp     r5, #31
    subhi   r5, #32
    addhi   r7, #1			//r7 = y index
    bhi     clearYLoop

	sub		r7, #1
	mov		r4, #0
	cmp		r8, #1
	moveq	r5, #3
	movne	r5, #4

clearLoop:
	mov		r0, r6
	mov		r1, r7
	bl    calcOffset
	bl    drawBGTile
	add		r7, #1
	add		r4, #1
	cmp		r4, r5
	blt		clearLoop

	pop		{r4-r8, pc}
