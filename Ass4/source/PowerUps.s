.data
.global PowerUpBlock
PowerUpBlock:
  .int 0 //x coord
  .int 0 //y coord
  .int 2 //PowerUp Type
         //1 - Extend PowerUp
         //2 - Sticky PowerUp
  .int 0 //On/Off for displaying

.text
//draws powerUP at PowerUpBlock coords
.global DrawPowerUp
DrawPowerUp:
  push {r4-r5, lr}
  ldr r4, =PowerUpBlock
  ldr r6, [r4, #12]
  ldr r5, [r4, #8]
  cmp r6, #1
  bne endDraw
  cmp r5, #1 //check PowerUp type
  ldreq r1, =XPower
  ldrne r1, =SPower

  ldr     r0, =drawArgs
  str     r1, [r0]

  ldr     r1, [r4] 		//x coord
  str     r1, [r0, #4]

  ldr     r1, [r4, #4] 		//y coord
  str     r1, [r0, #8]

  mov     r1, #48 		//image width
  str     r1, [r0, #12]
  mov     r1, #48 		//image height
  str     r1, [r0, #16]
  bl      drawImage
endDraw:
  pop {r4-r5, pc}

//UpdateSpawned PowerUp
.global updatePowerup
updatePowerup:
  push {lr}
  ldr r0, =PowerUpBlock   //load powerup from memory
  ldr r1, =paddleStats
  ldr  r2, [r0, #4]
  ldr  r3, [r0, #12]

  cmp r3, #0 //see if powerup is on
  beq return

  cmp r2, #920 //see if it is bellow the paddle
  movgt r3, #0
  strgt r3, [r0, #12]
  bgt return

  ldr r4, [r1] //load the x of the paddle
  ldr r5, [r0] //load the x of the powerup
  mov r6, r5
  sub r5, #47
  ldr r4, [r1, #8] //if extended or not
  cmp r4, #0
  addeq r6, #128
  addne r6, #192

  cmp r4, r5
  blt return

  cmp r4, r6
  bgt return

  cmp r2, #872
  blt increaseSpeed
  //if we are here set the powerup to true
  mov r2, #0
  str r2, [r0, #12] //turn the powerup off
  ldr r2, [r0, #8] //get the last type of powerup
  cmp r2, #1
  ldreq r0, =paddleStats
  moveq r2, #1
  streq r2, [r0, #8]
  ldrne r0, =stickyPack
  movne r2, #1
  strne r2,[r0]
  movne r2, #4
  strne r2, [r0, #4]

  b return // return since we dont need to update the posistion

increaseSpeed:
  add r2, #7 // drop speed
  str r2, [r0, #4]
  bl      DrawPowerUp


return:
  pop {pc}

//spawn powerUP
.global checkPowerUp
checkPowerUp:
  push {r8, r9, lr}
  mov r8, r0 // r8 is the block x
  mov r9, r1 // r9 is the block y
  /*ldr r0, =destroyed
  ldr r0, [r0]
  mov r1, r0
  mov r2, #4
  modMathLoop:
    cmp r1, #4
    blt doneCheck
    sub r1, #4
    b modMathLoop

  doneCheck:
    cmp r1, #0
    bne returnCheck
  */
  ldr r0, =PowerUpBlock

  mov r1, #1
  str r1, [r0, #12]

  ldr r1, [r0, #8]
  cmp r1, #1
  movne r1, #1
  moveq r1, #2
  str r1, [r0, #8]
  add r9, #32 // offset the blocks
  add r8, #8
  str r8, [r0]
  str r9, [r0, #4]

  returnCheck:
    pop {r8, r9, pc}