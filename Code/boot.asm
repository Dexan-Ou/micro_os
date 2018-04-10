org   7c00h		; BIOS将把引导扇区加载到0:7C00h处，并开始执行
OffSetPrg   equ 08100h
Start:
	mov	ax, cs	       ; 置其他段寄存器值与CS相同
	mov	ds, ax	       ; 数据段
      mov	es, ax		 ; 置ES=DS
	mov   ax, 0B800h         ; 文本窗口显存起始地址
	mov   gs, ax             ; GS = B800h
      ;mov   word[09000h], 0   ;initial VIN file space
Startword:
      mov   ax, 0100h
      mov   cx, 2607h
      int   10h
      call  Cleanscreen
	mov	bp, HelloMessage		
	mov	ax, HelloMessageLength 
	call  Print

Input:
      mov   ah, 0
      int   16h
      mov   byte[char], al
      ;check if press ESC
      cmp   byte[char], 1bh
      jz    Shutdown
      ;check if press A/a
      cmp   byte[char], 41h
      jz    LoadPrgA
      cmp   byte[char], 61h
      jz    LoadPrgA
      cmp   byte[char], 42h
      jz    LoadPrgB
      cmp   byte[char], 62h
      jz    LoadPrgB
      jmp   Input

LoadPrgA:
      call  Cleanscreen
      mov   bx, OffSetPrg
      mov   ax, 0203h
      xor   dx, dx
      mov   cx, 0002h
      int   13H
      jmp   OffSetPrg

LoadPrgB:
      call  Cleanscreen
      mov   bx, OffSetPrg
      mov   ax, 0202h
      xor   dx, dx
      mov   cx, 0005h
      int   13H
      jmp   OffSetPrg

Shutdown:
      ;check if APM exist
      mov   ax, 5300h
      xor   bx, bx
      int   15h
      jc    ErrorAPM
      ;connect APM Interface
      inc   byte[ErrorAPMCode]
      mov   ax, 5301h
      xor   bx, bx
      int   15h
      jc    ErrorAPM
      ;switch to APM 1.2
      inc   byte[ErrorAPMCode]
      mov   ax, 530eh
      xor   bx, bx
      mov   cx, 0102h
      int   15h
      jc    ErrorAPM
      ;enable APM
      inc   byte[ErrorAPMCode]
      mov   ax, 5308h
      mov   bx, 01h
      mov   cx, 01h
      int   15h
      jc    ErrorAPM
      ;shudown
      inc   byte[ErrorAPMCode]
      mov   ax, 5307h
      mov   bx, 01h
      mov   cx, 03h
      int   15h
      jc    ErrorAPM

ErrorAPM:
      call  Cleanscreen
      mov	bp, ErrorAPMMessage		
	mov	ax, ErrorAPMMessageLength 
	call  Print
      mov   ah, 0
      int   16h
      jmp   Input

Cleanscreen:
      mov   ax, 0600h
      mov   bh, 07h
      mov   dx, 184fh
      xor   cx, cx
      int   10h
      mov   word[x], 0
      mov   word[y], 0
      ret

Print:
      mov   word[count], ax
      inc   word[count]
PrintLoop:
      dec   word[count]
      jz    PrintEnd
      ;set the output word
      mov   ah, 07h           ;  0000：黑底、1111：亮白字（默认值为07h）
	mov   al, byte[bp]
      mov   cx, ax            ;save ax
      ;calculate position
      xor   ax, ax
      mov   ax, word[x]
	mov   bx, 80
	mul   bx
	add   ax, word[y]
	mov   bx, 2
	mul   bx

      mov   dx, bp            ;save bp
      cmp   byte[bp], 0ah     ;check if \n
      jz   PrintAfterL1
	mov   bp, ax            ;set position
      mov   ax, cx            ;rebuild output word
	mov   word[gs:bp], ax   ;output
      mov   bp, dx            ;rebuild bp
PrintAfterL1:
      ;calculate next position
      inc   word[y]
      cmp   byte[bp], 0ah
      jz    AxInc
PrintAfterL2:
      inc   bp
	jmp   PrintLoop
PrintEnd:
      ret
AxInc:
      inc   word[x]
      mov   word[y], 0
      jmp   PrintAfterL2

data:
      count dw 0
      char  db '0'
      x     dw 0
      y     dw 0
HelloMessage:
      db 'Micro OS (c) Alayse.', 0ah, 'Press [A], [B] or [C] to run programs.', 0ah, 'Press [ESC] to shutdown.'
HelloMessageLength  equ ($-HelloMessage)
ErrorAPMMessage:
      db 'Failed to shutdown OS. Error code:0'
      ErrorAPMCode db '0'
ErrorAPMMessageLength  equ ($-ErrorAPMMessage)
      times 510-($-$$) db 0
      db 0x55,0xaa

