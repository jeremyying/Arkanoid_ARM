//PauseMenuPrint draws the pause menu and arrow
PauseMenuPrint:
  push {lr}
  ldr r0, =drawArgs
  ldr r1, =PauseMenuImage
  str r1, [r0]
  mov r1, #656 //x coord of PauseMenu
  str r1, [r0, #4]
  mov r1, #344 //y coord of PauseMenu
  str r1, [r0, #8]
  mov r1, #512 //image width
  str r1, [r0, #12]
  mov r1, #384 //image height
  str r1, [r0, #16]
  bl drawImage

PauseArrowPrint:
  ldr r0, =drawArgs
  ldr r1, =arrow
  str r1, [r0]
  mov r1, #784 //x coord of PauseArrow
  str r1, [r0, #4]
  mov r1, #504 //y coord of PauseArrow
  str r1, [r0, #8]
  mov r1, #36 //image width
  str r1, [r0, #12]
  mov r1, #45 //image height
  str r1, [r0, #16]
  bl drawImage
  pop {pc}

/*PauseMenuButtonCheck returns an int in r0 based on user selections made inside the pause menu:
      1 - Restart game
      2 - Quit game
      3 - Resume game */
.global PauseMenuButtonCheck
PauseMenuButtonCheck:
  push {r4-r10, lr}

  bl PauseMenuPrint //prints PauseMenu and arrow

  ArrowPosition .req r10
  mov ArrowPosition, #1

PauseMenuLoop:
  bl Read_SNES
  mov r2, #0xffff //no buttons are pressed
  cmp r1, r2
  beq PauseMenuLoop

  ldrb r2, [r0, #3] //check if START is pressed
  cmp r2, #0
  moveq ArrowPosition, #3 //Exit Pause Menu flag
  beq  DrawFloorBack

  ldrb r2, [r0, #4] //check if UP is pressed
  cmp r2, #0
  beq PauseMenuArrowUP

  ldrb r2, [r0, #5] //check if DOWN is pressed
  cmp r2, #0
  beq PauseMenuArrowDOWN

  ldrb r2, [r0, #8] //check if A is pressed
  cmp r2, #0
  beq DrawFloorBack //A is pressed when Arrow is on Restart

  b PauseMenuLoop //check for button presses

PauseMenuArrowUP:
  mov ArrowPosition, #1 //Arrow Position at Restart
  mov r4, #784 // x coord at Restart
  mov r5, #504 // y coord at Restart
  b PauseMenuRemoveArrow

PauseMenuArrowDOWN:
  mov ArrowPosition, #2 //Arrow Position at Quit
  mov r4, #784 // x coord at Quit
  mov r5, #590 // y coord at Quit
  b PauseMenuRemoveArrow

PauseMenuRemoveArrow:
  mov r0, #784 //x coord to blackout
  mov r1, #504 //y coord to blackout
  mov r2, #0xFF000000 //colour black
  mov r6, #819 //max x
  mov r7, #594 //max y
  //mov r6, #35 //width
  //mov r7, #90 //height
PauseMenuRemoveArrowLoop:
  bl DrawPixel
  add r0, #1 //increment x
  teq r0, r6
  moveq r0, #784 //reset to original x
  addeq r1, #1 //increment y
  cmp r1, r7
  blt PauseMenuRemoveArrowLoop



PauseMenuDrawArrow:
  ldr r0, =drawArgs
  ldr r1, =arrow
  str r1, [r0]
  mov r1, r4 //x coord of PauseArrow
  str r1, [r0, #4]
  mov r1, r5 //y coord of PauseArrow
  str r1, [r0, #8]
  mov r1, #36 //image width
  str r1, [r0, #12]
  mov r1, #45 //image height
  str r1, [r0, #16]
  bl drawImage
  b PauseMenuLoop

PauseMenuDrawFloor:
  mov r4, #656 //starting x coord
  mov r5, #344 //starting y coord
  //mov r6, #0 //block counter
  mov r6, #1168 //max x
  mov r7, #728 //maximum y coord
  //mov r8, #96 //tiles to make

PauseMenuDrawFloorLoop:
  ldr r0, =drawArgs
  ldr r1, =fTile //floor tile address
  str r1, [r0]
  mov r1, r4 //x coord of PauseArrow
  str r1, [r0, #4]
  mov r1, r5 //y coord of PauseArrow
  str r1, [r0, #8]
  mov r1, #64 //image width
  str r1, [r0, #12]
  mov r1, #32 //image height
  str r1, [r0, #16]
  bl drawImage
  add r4, #64 //increment x by a block width
  teq r4, r6 //check if x coord of block has surpassed maximum
  moveq r4, #656 //reset x coord to starting x coord
  addeq r5, #32 //increment y by block height
  cmp r5, r7
  bne PauseMenuDrawFloorLoop

PauseMenuReturn:
  mov r0, ArrowPosition //return int 1 (Restart), 2 (Quit), or 3 (Resume)
  .unreq ArrowPosition
  pop {r4-r10, pc} //return
