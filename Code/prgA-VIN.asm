org   8100h
VGAAddr     equ 0B800h
FileAddr    equ 09000h
Start:
      mov   ax, cs
      mov   ds, ax
      mov   es, ax
      mov   ax, VGAAddr
      mov   gs, ax
      mov   ax, word[FileAddr]
      mov   word[totalfile], ax
      mov   word[selectfile], 0
Mainmenu:
      call  Cleanscreen
      ;print mainmenu
	mov	bp, MainMessage		
	mov	ax, MainMessageLength 
	call  Print
      ;set cursor shape
      mov   ax, 0100h
      mov   cx, 2607h
      int   10h
      mov   ax, word[totalfile]
      mov   word[count], ax
      mov   byte[x], 7
      mov   byte[y], 1
      ;print file
      ;print new file
      cmp   word[selectfile], 0
      call  Printselect
	mov	bp, CreateMessage		
	mov	ax, CreateMessageLength 
	call  Print

Input:
      mov   ah, 0
      int   16h
      cmp   al, 1bh
      jz    Return

      jmp   Input

Return:
      jmp   0h:07c00h

Printnewline:
	mov	bp, Newline		
	mov	ax, NewlineLength 
	call  Print
      ret

Printselect:
	mov	bp, Select		
	mov	ax, SelectLength 
	call  Print
      ret

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

Datafield:
      count dw 0
      selectfile dw 0
      totalfile dw 0
      x     dw 0
      y     dw 0
MainMessage:
      db '" ==================================================', 0ah
      db '"                VIN - VIN Is Non-vim', 0ah
      db '" XJB Directory Listing                  (XJB v000)', 0ah
      db '"   [RAM]/', 0ah
      db '"   Sorted by    none', 0ah
      db '"   Quick Help:  ESC:exit', 0ah
      db '" ==================================================', 0ah
MainMessageLength  equ ($-MainMessage)
Newline:
      db 0ah
NewlineLength  equ ($-Newline)
CreateMessage:
      db 'Create New File', 0ah
CreateMessageLength  equ ($-CreateMessage)
Select:
      db '[*] '
SelectLength  equ ($-Select)
      times 1024-($-$$) db 0