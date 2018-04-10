org   08100h
VGAAddr           equ 0B800h
QueueStartAddr    equ 9000h
QueueEndAddr      equ 9fffh
delay             equ 50000
Start:
      mov   ax, cs
      mov   ds, ax
      mov   es, ax
      mov   ax, VGAAddr
      mov   gs, ax
      ;mov   es, ax
      call  Cleanscreen
      ;initial queue
      mov   ax, QueueStartAddr
      mov   bp, ax
      mov   word[queuetail], ax
      mov   word[queuehead], ax
      mov   byte[space], 20h
      mov   byte[bp], 0
      inc   bp
      inc   word[queuehead]
      inc   word[queuetail]
      mov   byte[bp], 0
      mov   ax, QueueEndAddr
      mov   bp, ax
      mov   byte[bp], 0
      mov   ax, word[hx]
      mov   bx, word[hy]
      mov   word[x], ax
      mov   word[y], bx
      mov   byte[style], 0FFh
      call  Print
      ;decide LRNG seed
LRNGSeed:
      mov   cx, 1
Loop1:
      mov   ah, 01h
      int   16h
      jnz   Loop1End
      inc   cx
      cmp   cx, 0
      jle   LRNGSeed
      jmp   Loop1
Loop1End:
      mov   word[lcdx], cx
      mov   ah, 00h
      int   16h
      cmp   al, 1bh
      jz    Return
      call  NewPoint
      mov   ax, word[ddelay]
      mov   word[dcount], ax
Loop2:
      mov   ah, 01h
      int   16h
      jz    Loop2Break
      call  ChangeHead
Loop2Break:
      dec   word[count]
      jnz   Loop2
      mov   word[count], delay
      dec   word[dcount]
      jnz   Loop2
      mov   ax, word[ddelay]
      mov   word[dcount], ax
      call  TailMove
      call  HeadMove
      cmp   byte[style], 0Fh
      jnz   Break1
      call  TailReMove
      call  NewPoint
Break1:
      jmp   Loop2

NewPoint:
      call  LRNG
      mov   bx, 25
      call  LRNGmodBx
      mov   word[x], dx
      call  LRNG
      mov   bx, 80
      call  LRNGmodBx
      mov   word[y], dx
      mov   byte[style], 0EEh
      call  Print
      cmp   byte[style], 0Eh
      jz    NewPoint
      ret

TailMove:
      mov   ax, word[tx]
      mov   bx, word[ty]
      mov   cx, word[queuetail]
      mov   bp, cx
      mov   cl, byte[bp]
      cmp   cl, 0
      jz    TailSkipMove
      mov   word[x], ax
      mov   word[y], bx
      mov   byte[style], 07h
      call  Print
TailSkipMove:
      mov   cx, word[queuetail]
      mov   bp, cx
      mov   cl, byte[bp]
      call  Move
      mov   word[tx], ax
      mov   word[ty], bx
      cmp   word[queuetail], QueueEndAddr
      jl    TailInc
      mov   word[queuetail], QueueStartAddr
TailInc:
      inc   word[queuetail]
      ret

HeadMove:
      mov   cx, word[hd]
      mov   word[hdr], cx
      mov   ax, word[hx]
      mov   bx, word[hy]
      mov   cx, word[hdr]
      call  Move
      mov   word[hx], ax
      mov   word[hy], bx
      mov   word[x], ax
      mov   word[y], bx
      mov   byte[style], 0FFh
      call  Print
      cmp   word[queuehead], QueueEndAddr
      jl    HeadInc
      mov   word[queuehead], QueueStartAddr
HeadInc:
      inc   word[queuehead]
      mov   cx, word[queuehead]
      mov   bp, cx
      mov   cx, word[hdr]
      mov   byte[bp], cl
      ret

Move:
      mov   word[x], ax
      mov   word[y], bx
      mov   byte[char], cl
      cmp   byte[char], 1
      jz    MoveUp
      cmp   byte[char], 2
      jz    MoveRight
      cmp   byte[char], 3
      jz    MoveDown
      cmp   byte[char], 4
      jz    MoveLeft
      ret

ReMove:
      mov   word[x], ax
      mov   word[y], bx
      mov   byte[char], cl
      cmp   byte[char], 1
      jz    MoveDown
      cmp   byte[char], 2
      jz    MoveLeft
      cmp   byte[char], 3
      jz    MoveUp
      cmp   byte[char], 4
      jz    MoveRight
      ret

TailReMove:
      dec   word[queuetail]
      cmp   word[queuetail], QueueStartAddr
      ja    TailRemoveOn
      mov   word[queuetail], QueueEndAddr
TailRemoveOn:
      mov   ax, word[tx]
      mov   bx, word[ty]
      mov   cx, word[queuetail]
      mov   bp, cx
      mov   cl, byte[bp]
      call  ReMove
      mov   word[tx], ax
      mov   word[ty], bx
      mov   word[x], ax
      mov   word[y], bx
      mov   byte[style], 0FFh
      call  Print
      ret

ChangeHead:
      mov   ah, 00h
      int   16h
      mov   byte[char], al
      cmp   byte[char], 1bh
      jz    Return
      cmp   byte[char], 57h
      jz    TurnUp
      cmp   byte[char], 77h
      jz    TurnUp
      cmp   byte[char], 41h
      jz    TurnLeft
      cmp   byte[char], 61h
      jz    TurnLeft
      cmp   byte[char], 53h
      jz    TurnDown
      cmp   byte[char], 73h
      jz    TurnDown
      cmp   byte[char], 44h
      jz    TurnRight
      cmp   byte[char], 64h
      jz    TurnRight
      cmp   byte[char], 2bh
      jz    SpeedUp
      cmp   byte[char], 2dh
      jz    SpeedDown
      jmp   DefRet

TurnUp:
      cmp   word[hdr], 1
      jz    DefRet
      cmp   word[hdr], 3
      jz    DefRet
      mov   word[hd], 1
      jmp   DefRet
TurnRight:
      cmp   word[hdr], 2
      jz    DefRet
      cmp   word[hdr], 4
      jz    DefRet
      mov   word[hd], 2
      jmp   DefRet
TurnDown:
      cmp   word[hdr], 1
      jz    DefRet
      cmp   word[hdr], 3
      jz    DefRet
      mov   word[hd], 3
      jmp   DefRet
TurnLeft:
      cmp   word[hdr], 2
      jz    DefRet
      cmp   word[hdr], 4
      jz    DefRet
      mov   word[hd], 4
      jmp   DefRet

DefRet:
      ret

MoveUp:
      cmp   word[x], 0
      jnz   MoveUpBreak
      mov   word[x], 25
MoveUpBreak:
      dec   word[x]
      jmp   PositionBack
MoveLeft:
      cmp   word[y], 0
      jnz    MoveLeftBreak
      mov   word[y], 80
MoveLeftBreak:
      dec   word[y]
      jmp   PositionBack
MoveDown:
      inc   word[x]
      cmp   word[x], 24
      jle   PositionBack
      mov   word[x], 0
      jmp   PositionBack
MoveRight:
      inc   word[y]
      cmp   word[y], 79
      jle   PositionBack
      mov   word[y], 0
      jmp   PositionBack
PositionBack:
      mov   ax, word[x]
      mov   bx, word[y]
      jmp   DefRet

Return:
      jmp   0h:07c00h

SpeedUp:
      cmp   word[ddelay], 1
      jz    DefRet
      dec   word[ddelay]
      jmp   DefRet
SpeedDown:
      cmp   word[ddelay], 100
      jz    DefRet
      inc   word[ddelay]
      jmp   DefRet

Cleanscreen:
      mov   ax, 0600h
      mov   bh, 07h
      mov   dx, 184fh
      xor   cx, cx
      int   10h
      mov   word[x], 0
      mov   word[y], 0
      ret

LRNG:
      mov   ax, word[lcdx]
      mov   bx, word[lcda]
      mul   bx
      xor   dx, dx
      mov   word[lcdx], ax
      ret
LRNGmodBx:
      xor   dx, dx
      mov   ax, word[lcdx]
      div   bx
      ret

Print:
      pusha
      ;calculate position
      xor   ax, ax
      mov   ax, word[x]
	mov   bx, 80
	mul   bx
	add   ax, word[y]
	mov   bx, 2
	mul   bx
	mov   bp, ax            ;set position
      ;set the output word
      mov   ah, byte[style]
	mov   al, byte[space]
      mov   bx, word[gs:bp]
      cmp   bh, 07h
      jnz   LikeGG
PrintBreak:
	mov   word[gs:bp], ax   ;output
      popa
      ret

LikeGG:
      cmp   bh, 0FFh
      jnz   LikeGGBreak
      cmp   ah, 0FFh
      jnz   LikeGGBreak
      jmp   GG
LikeGGBreak:
      cmp   bh, 0EEh
      jnz   LikeGGBreak2
      mov   byte[style], 0Fh
      jmp   PrintBreak
LikeGGBreak2:
      mov   byte[style], 0Eh
      jmp   PrintBreak

GG:
      mov   ah, 00h
      int   16h
      cmp   al, 1bh
      jz    Return
      jmp   GG

Data:
      count       dw delay
      dcount      dw 0
      ddelay      dw 10
      char  db 0
      hx    dw 12
      hy    dw 39
      hd    dw 1
      hdr   dw 1

      tx    dw 12
      ty    dw 39

      x     dw 0
      y     dw 0
      style db 0

      space db ' '

      queuehead   dw 0
      queuetail   dw 0

      lcda  dw 0bc8fh
      lcdx  dw 0

      times 1024-($-$$) db 0