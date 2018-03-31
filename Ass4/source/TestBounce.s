.global ballStats
ballStats:
    .int    0       //x coordinate
    .int    0       //y coordinate
    .int    0       //x speed
    .int    0       //y speed

.global DrawBounds
DrawBounds:
  push {r4-r10, lr}

  //blacks out the screen
  BlackScreen:
    mov     r4, #0 //initial x
    mov     r5, #24 //initial y
    mov     r6, #1824 //max x
    mov     r7, #984 //max y

  blackLoop:
    mov     r0, r4
    mov     r1, r5
    mov     r2, #0xFF000000
    bl      DrawPixel
    add     r4, #1
    teq     r4, r6
    moveq   r4, #0
    addeq   r5, #1
    cmp     r5, r7
    blt     blackLoop

  DrawLeftBound:
    mov     r4, #331 //initial x
    mov     r5, #88 //initial y
    mov     r6, #336 //max x
    mov     r7, #984 //max y

  DrawLeftBoundLoop:
    mov     r0, r4 //x
    mov     r1, r5 //y
    ldr     r2, =#0xFFFFFFFF //white
    bl      DrawPixel
    add     r4, #1 //increment x
    teq     r4, r6 //compare x to max x
    moveq   r4, #331 //if(x = max x), reset x
    addeq   r5, #1 //increment y
    cmp     r5, r7
    blt     DrawLeftBoundLoop //loop if y is less than max

  DrawRightBound:
    mov     r4, #1488 //initial x
    mov     r5, #88 //initial y
    mov     r6, #1493 //max x
    mov     r7, #984 //max y

  DrawRightBoundLoop:
    mov     r0, r4 //x
    mov     r1, r5 //y
    ldr     r2, =#0xFFFFFFFF //white
    bl      DrawPixel
    add     r4, #1 //increment x
    teq     r4, r6 //compare x to max x
    moveq   r4, #1488 //if(x = max x), reset x
    addeq   r5, #1 //increment y
    cmp     r5, r7
    blt     DrawRightBoundLoop //loop if y is less than max

  DrawTopBound:
    mov     r4, #336 //initial x
    mov     r5, #83 //initial y
    mov     r6, #1488 //max x
    mov     r7, #88 //max y

  DrawTopBoundLoop:
    mov     r0, r4 //x
    mov     r1, r5 //y
    ldr     r2, =#0xFFFFFFFF //white
    bl      DrawPixel
    add     r4, #1 //increment x
    teq     r4, r6 //compare x to max x
    moveq   r4, #336 //if(x = max x), reset x
    addeq   r5, #1 //increment y
    cmp     r5, r7
    blt     DrawTopBoundLoop //loop if y is less than max

  DrawBottomBound:
    mov     r4, #336 //initial x
    mov     r5, #920 //initial y
    mov     r6, #1488 //max x
    mov     r7, #925 //max y

  DrawBottomBoundLoop:
    mov     r0, r4 //x
    mov     r1, r5 //y
    ldr     r2, =#0xFFFFFFFF //white
    bl      DrawPixel
    add     r4, #1 //increment x
    teq     r4, r6 //compare x to max x
    moveq   r4, #336 //if(x = max x), reset x
    addeq   r5, #1 //increment y
    cmp     r5, r7
    blt     DrawBottomBoundLoop //loop if y is less than max

  pop {r4-r10, pc}//ret

.global initBall
initBall:
  push {r4-r10, lr}

  ldr     r8, =drawArgs
  ldr     r1, =ball             //image ascii text address
  ldr     r10, =ballStats

  str     r1, [r8]
  mov     r1, #900                   //x coordinate
  str     r1, [r8, #4]

  str     r1, [r10]
  mov     r1, #896                    //y coordinate
  str     r1, [r8, #8]

  str     r1, [r10, #4]
  mov     r1, #24                //image width
  str     r1, [r8, #12]
  mov     r1, #24                 //image height
  str     r1, [r8, #16]
  bl      drawImage

  pop {r4-r10, pc}

/*
.global initSpeed
initSpeed:
  push {r4-r10, lr}

  ldr r10, =ballStats
  mov r0, #2 //x ball speed
  str r0, [r10, #8]
  mov r1, #-3 //y ball speed
  str r1, [r10, #12]

  pop {r4-r10, pc}

.global moveBall
moveBall:
  push {r4-r10, lr}

  ldr r10, =ballStats
  ldr r6, [r10] //x
  ldr r7, [r10, #4] //y
  ldr r8, [r10, #8] //x speed
  ldr r9, [r10, #12] //y speed
  add r6, r8 //x + x speed
  str r6, [r10]
  add r7, r9 //y + y speed
  str r7, [r10, #4]

  ldr     r0, =drawArgs
  ldr     r1, =ball             //image ascii text address
  str r1, [r0]
  mov     r1, r6                    //x coordinate
  str     r1, [r0, #4]
  mov     r1, r7                    //y coordinate
  str     r1, [r0, #8]
  mov     r1, #24                //image width
  str     r1, [r0, #12]
  mov     r1, #24                 //image height
  str     r1, [r0, #16]
  bl      drawImage

  pop {r4-r10, pc}

.global Reflection
Reflection:
  push {r4-r10, lr}

  ldr r10, =ballStats
  ldr r6, [r10] //x
  ldr r7, [r10, #4] //y
  ldr r8, [r10, #8] //x speed
  ldr r9, [r10, #12] //y speed
  ldr r5, =#1464

  cmp r6, #336 //check Left Wall Collision
  ble LBound
  cmp r6, r5 //check Right Wall Collision
  bge RBound
  cmp r7, #88 //check Top Collision
  ble TBound
  cmp r7, #896 //check Bottom Collision
  bge BBound
  b ReflectionDone

  LBound:
   b XReflect
  RBound:
   b XReflect
  TBound:
   b YReflect
  BBound:
   b YReflect

  XReflect:
    ldr r8, [r10, #8] //x speed
    mov r0, #-1
    mul r8, r0 //invert x speed
    str r8, [r10, #8]
    b ReflectionDone

  YReflect:
    ldr r9, [r10, #12] //y speed
    mov r0, #-1
    mul r9, r0 //invert y speed
    str r9, [r10, #12]
    b ReflectionDone

  ReflectionDone:
  pop {r4-r10, pc}

*/
.global TestBounce
TestBounce:
  push {r4-r10, lr}

  bl DrawBounds
  bl initBall
  /*bl initSpeed

  TestBounceLoop:

    bl moveBall
    bl Reflection

    b TestBounceLoop*/

  push {r4-r10, lr}
