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
  cmp r6, #0
  beq endDraw //Skip if Display toggle is off


/*BlackoutPowerUp:
  bl      calcXYIndex
  mov     r4, r0
  mov     r5, r1
  mov r7, r2
  mov r8, r3

  mov     r0, r2				//middle tile to cover
  mov     r1, r3
  bl      calcOffset
  bl      drawBGTile

  mov     r0, r7				//left tile to cover
  sub     r0, #1
  //cmp		  r0, #0
  //blt     backRightTile
  mov     r1, r8
  bl      calcOffset
  bl      drawBGTile*/

  ldr r7, [r4] //PowerUp X
  ldr r8, [r4, #4] //PowerUp Y
  sub r7, #8 //align 48x48 powerup with 64x32 tiles

  mov r1, r7
  mov r2, r8
  bl drawBGTile




  ldr r4, =PowerUpBlock
  ldr r5, [r4, #8]
  cmp r5, #1 //check PowerUp type
  ldreq r1, =XPower
  cmp r5, #2
  ldreq r1, =SPower

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
  push {r4-r10, lr}
  ldr r0, =PowerUpBlock   //load powerup from memory
  ldr r1, =paddleStats
  ldr r2, [r0, #4] //PowerUp Y Coord
  ldr r3, [r0, #12] //PowerUp On/off

  cmp r3, #0 //see if powerup is on
  beq updatePowerupReturn //ret if not on

  push {r0-r3}
  bl DrawPowerUp //draws PowerUp
  pop {r0-r3}

  cmp r2, #920 //check if y is bellow paddle
  addlt r2, #5 //Set y of PowerUp to new Position
  strlt r2, [r0, #4] //store new y

  //movge r3, #0 //turn off display flag
  //strge r3, [r0, #12]
  bgt updatePowerupReturn

  ldr r4, [r1] //load the x of the paddle
  ldr r5, [r0] //load the x of the powerup
  mov r6, r4 //copy paddle x

  //set PowerUp Registration boundary
  sub r4, #47 //x Lower Bound

  ldr r10, [r1, #8]
  cmp r10, #1 //check if paddle extended
  addne r6, #127 //x High Bound (not extended)
  addeq r6, #191 //x High Bound (extended)

  cmp r5, r4
  blt updatePowerupReturn //ret if powerup x < Left Paddle x

  cmp r5, r6
  bgt updatePowerupReturn //ret if powerup x > Right Paddle x

  ldr r4, [r0, #8] //load PowerUp type
  cmp r4, #1
  beq ExtendPowerUp
  bne StickyPowerUp

  ExtendPowerUp:
    /*ldr r6, [r0, #12]
    cmp r6, #0
    moveq r4, #2
    streq r4, [r0, #8] //change Powerup to Sticky*/

    mov r4, #1
    str r4, [r1, #8] //extend paddle on

    b updatePowerupReturn

  StickyPowerUp:
    /*mov r4, #1
    str r4, [r0, #8] //change Powerup to extend paddle*/

    ldr r4, =stickyPack
    mov r5, #1
    str r5, [r4] //set Sticky On
    mov r5, #5
    str r5, [r4, #4] //set 5 moves for sticky

    b updatePowerupReturn

updatePowerupReturn:
  ldr r0, =PowerUpBlock
  ldr r1, [r0, #4] //PowerUpBlock Y coord
  ldr r2, [r0, #8] //PowerUp Type
  ldr r3, [r0, #12] //PowerUp Display
  mov r10, r3 //copy display value
  cmp r1, #920
  movgt r3, #0 //display PowerUp off if out of bounds

  cmp r3, r10
  beq SkipPowerUpChange

  cmp r2, #1
  moveq r2, #2 //set PowerUp type to 2 if 1
  movgt r2, #1 //set PowerUp type to 1 if 2
  str r2, [r0, #8] //store powerup type

SkipPowerUpChange:
  pop {r4-r10, pc}

//spawn powerUP
.global checkPowerUp
checkPowerUp:
  push {r9-r10, lr}

  ldr r10, =destroyed
  ldr r10, [r10] //load destroyed int

  //TEST
  //TEST
  cmp r10, #1 //check if 20 blocks are destroyed
  beq SetPowerUpFlag

  cmp r10, #5 //check if 40 blocks are destroyed
  beq SetPowerUpFlag

  cmp r10, #10 //check if 60 blocks are destroyed
  beq SetPowerUpFlag
  //TEST
  //TEST

  /*cmp r10, #20 //check if 20 blocks are destroyed
  beq SetPowerUpFlag

  cmp r10, #40 //check if 40 blocks are destroyed
  beq SetPowerUpFlag

  cmp r10, #60 //check if 60 blocks are destroyed
  beq SetPowerUpFlag*/

  b checkPowerUpReturn

  SetPowerUpFlag:
    ldr r10, =PowerUpBlock
    mov r9, #1 //set display to on
    str r9, [r10, #12]

  checkPowerUpReturn:
    pop {r9-r10, pc}
