
@ Code section
.section .text

.global movePaddle
movePaddle:
    push    {r4-r8, lr}

    //get current position (x,y top left corner) and speed from global variable paddleStats
    //if current position is at a boundary just return
    //calculate which floor tiles it is covering, this part is tricky...
    //I think subtract 336 from x, then divide by 64, ignore remainder (use a loop subtracting
    //64 and add 1 to a count), then multiply by 64 and add 336, that way you get the
    //coordinate of the left tile that the paddleis covering
    //replace current position with floor tiles, probably three tiles, 64x32 tiles
    //since paddle is two tiles width and it might be in between, 128x32
    //draw paddle in new position according to speed, add speed to x 
    //updeate paddle stats
    //check if ball is attached, if so, call moveBall
    //look at other files for imageDraw examples
    //left x coordinate boundary is 336, right boundary is 1360 (top left corner)
    //y coordinate is always 920

    pop     {r4-r8, pc}







