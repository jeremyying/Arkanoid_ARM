.data
.global PowerUpBlock
PowerUpBlock:
  .int 0 //x coord
  .int 0 //y coord
  .int 2 //PowerUp Type
         //1 - Extend PowerUp
         //2 - Sticky PowerUp
  .int 0 //On/Off for displaying
         //1 - On
         //0 - Off

.text
//draws powerUP at PowerUpBlock coords
DrawPowerUp:
  push {r4-r6, lr}
  ldr r4, =PowerUpBlock
  ldr r5, [r4, #8] //PowerUp Type
  ldr r6, [r4, #12] //On/Off
  cmp r6, #1
  bne endDraw //Skip if Display toggle is off

  cmp r5, #1 //check PowerUp type
  ldreq r1, =XPower
  ldrne r1, =SPower

  ldr     r0, =drawArgs
  str     r1, [r0]

  ldr     r1, [r4] 		 //x coord
  str     r1, [r0, #4] //store x in DrawArgs

  ldr     r1, [r4, #4] //y coord
  str     r1, [r0, #8] //store y in DrawArgs

  mov     r1, #48 		//image width
  str     r1, [r0, #12]
  mov     r1, #48 		//image height
  str     r1, [r0, #16]
  bl      drawImage
endDraw:
  pop {r4-r6, pc}

//Updates a spawned PowerUp
.global updatePowerup
updatePowerup:
  push {r4-r6, r10, lr}
  ldr r0, =PowerUpBlock   //load powerup from memory
  ldr r1, =paddleStats
  ldr r2, [r0, #4] //PowerUp Y Coord
  ldr r3, [r0, #12] //PowerUp Type

  cmp r3, #0 //see if powerup is on
  beq updatePowerupReturn

  push {r0-r3}
  bl DrawPowerUp //draws PowerUp
  pop {r0-r3}

  cmp r2, #920 //check if y is bellow paddle
  addlt r2, #5 //Set y of PowerUp to new Position
  strlt r2, [r0, #4] //store new y

  movge r3, #0 //turn off display flag
  strge r3, [r0, #12]
  bgt updatePowerupReturn

  ldr r10, [r1, #8]
  cmp r10, #1 //check if paddle extended

  ldr r4, [r1] //load the x of the paddle
  ldr r5, [r0] //load the x of the powerup
  mov r6, r4 //copy paddle x

  //set PowerUp Registration boundary
  sub r4, #47 //x Lower Bound
  addne r6, #127 //x High Bound (not extended)
  add r6, #191 //x High Bound (extended)

  cmp r5, r4
  blt updatePowerupReturn //ret if powerup x < Left Paddle x

  cmp r5, r6
  bgt updatePowerupReturn //ret if powerup x > Right Paddle x

  ldr r4, [r0, #8] //load PowerUp type
  cmp r4, #1
  beq ExtendPowerUp
  bne StickyPowerUp

  ExtendPowerUp:
    mov r4, #1
    str r4, [r1, #8] //extend paddle on
    mov r4, #2
    str r4, [r0, #8] //change Powerup to Sticky

  StickyPowerUp:
    ldr r4, =stickyPack
    mov r5, #1
    str r5, [r4] //set Sticky On
    mov r5, #5
    str r5, [r4, #4] //set 5 moves for sticky

updatePowerupReturn:
  pop {r4-r6, r10, pc}

//spawn powerUP
.global checkPowerUp
checkPowerUp:
  push {r9-r10, lr}

  ldr r10, =destroyed
  ldr r10, [r10] //load destroyed int

  cmp r10, #20 //check if 20 blocks are destroyed
  beq SetPowerUpFlag

  cmp r10, #40 //check if 40 blocks are destroyed
  beq SetPowerUpFlag

  cmp r10, #60 //check if 60 blocks are desotryed
  beq SetPowerUpFlag

  b checkPowerUpReturn

  SetPowerUpFlag:
    ldr r10, =PowerUpBlock
    mov r9, #1 //set display to 1
    str r9, [r10, #12]

  checkPowerUpReturn:
    pop {r9-r10, pc}
