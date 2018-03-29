.global PauseMenuPrint
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
  push {r4, r5, r10, lr}
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
  beq  PauseMenuReturn

  ldrb r2, [r0, #4] //check if UP is pressed
  cmp r2, #0
  beq PauseMenuArrowUP

  ldrb r2, [r0, #5] //check if DOWN is pressed
  cmp r2, #0
  beq PauseMenuArrowDOWN

  ldrb r2, [r0, #8] //check if A is pressed
  cmp r2, #0
  beq PauseMenuReturn //A is pressed when Arrow is on Restart

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
  mov r2, #35 //width
  mov r3, #90 //height

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

PauseMenuReturn:
  mov r0, ArrowPosition //return int 1 (Restart), 2 (Quit), or 3 (Resume)
  .unreq ArrowPosition
  pop {r4, r5, r10, pc} //return
