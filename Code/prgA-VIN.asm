org   08100h
VGAAddr           equ 0B800h
FileAddr          equ 02000h
FileField         equ 00a00h
FileNameFiled     equ 00020h
Start:
      mov   ax, cs
      mov   ds, ax
      mov   es, ax
      mov   ax, VGAAddr
      mov   gs, ax
      mov   ax, word[FileAddr]
      mov   word[totalfile], ax
NewStart:
      mov   word[selectfile], 1
Mainmenu:
      call  Cleanscreen
      ;print mainmenu
	mov	bp, MainMessage
	mov	ax, MainMessageLength
      mov   byte[style], 03h
	call  Print
      ;set cursor shape
      mov   ax, 0100h
      mov   cx, 2607h
      int   10h
      mov   ax, word[totalfile]
      mov   word[FIcount], 0
      mov   byte[x], 7
      mov   byte[y], 1
      ;print file
Loop1:
      inc   word[FIcount]
      mov   bx, word[FIcount]
      cmp   bx, ax
      ja    Loop1End
      mov   ax, FileField
      mul   bx
      add   ax, FileAddr
      mov   word[bpaddr], ax
      mov   byte[style], 07h
      mov   ax, word[FIcount]
      mov   bx, word[selectfile]
      cmp   ax, bx
      jnz   Loop1NotSel
      call  Printselect
Loop1NotSel:
      mov   ax, word[bpaddr]
      mov   bp, ax
      mov   ax, word[bp]
      add   bp, 2
      call  Print
      call  Printnewline
      mov   ax, word[totalfile]
      jmp   Loop1
      ;print new file
Loop1End:
      mov   byte[style], 07h
      mov   ax, word[totalfile]
      mov   bx, word[selectfile]
      cmp   bx, ax
      jle   Loop1EndNotSel
      call  Printselect
Loop1EndNotSel:
	mov	bp, CreateMessage
	mov	ax, CreateMessageLength 
	call  Print

Input:
      mov   ah, 0
      int   16h
      mov   byte[char], al
      cmp   byte[char], 1bh
      jz    Return
      cmp   byte[char], 57h
      jz    ListUp
      cmp   byte[char], 77h
      jz    ListUp
      cmp   byte[char], 53h
      jz    ListDown
      cmp   byte[char], 73h
      jz    ListDown
      cmp   byte[char], 0dh
      jz    ConfirmFile
      jmp   Mainmenu

Readfile:
      call  Cleanscreen
      mov   byte[style], 07h
      mov   word[x], 24
      mov   word[y], 62
	mov	bp, LineEndMessage
	mov	ax, LineEndMessageLength 
	call  Print
      mov   word[x], 24
      mov   word[y], 0
	mov	bp, Quto
	mov	ax, QutoLength 
	call  Print
      mov   bx, word[selectfile]
      mov   ax, FileField
      mul   bx
      add   ax, FileAddr
      mov   bp, ax
      mov   ax, word[bp]
      add   bp, 2
      call  Print
	mov	bp, Quto
	mov	ax, QutoLength 
	call  Print
      mov   byte[style], 07h
      mov   word[x], 0
      mov   word[y], 0
      mov   bx, word[selectfile]
      mov   ax, FileField
      mul   bx
      add   ax, FileAddr
      add   ax, FileNameFiled
      mov   word[bpaddr], ax
      mov   bp, ax
      mov   ax, word[bp]
      add   bp, 2
      call  Print
      mov   ah, 0
      int   16h
      mov   byte[char], al
      cmp   byte[char], 1bh
      jz    NewStart
      mov   byte[style], 0Fh
      mov   word[x], 24
      mov   word[y], 0
	mov	bp, LineStartMessage
	mov	ax, LineStartMessageLength 
	call  Print
      mov   byte[style], 07h
      mov   word[x], 0
      mov   word[y], 0
      mov   bx, word[selectfile]
      mov   ax, FileField
      mul   bx
      add   ax, FileAddr
      add   ax, FileNameFiled
      mov   word[bpaddr], ax
      mov   bp, ax
      mov   ax, word[bp]
      add   bp, 2
      call  Print
      mov   ax, word[bpaddr]
      mov   bp, ax
      mov   ax, word[bp]
      mov   cx, 780h
      call  FileInput
      jmp   NewStart

Return:
      jmp   0h:07c00h

ListUp:
      mov   ax, word[selectfile]
      cmp   ax, 1
      jz    Mainmenu
      dec   word[selectfile]
      jmp   Mainmenu

ListDown:
      mov   ax, word[totalfile]
      mov   bx, word[selectfile]
      cmp   bx, ax
      ja    Mainmenu
      inc   word[selectfile]
      jmp   Mainmenu

ConfirmFile:
      call  Cleanscreen
      mov   ax, word[totalfile]
      mov   bx, word[selectfile]
      cmp   bx, ax
      jle   Readfile
      mov   byte[style], 07h
	mov	bp, InputNameMessage
	mov	ax, InputNameMessageLength 
	call  Print
      inc   word[totalfile]
      mov   bx, word[selectfile]
      cmp   bx, 10
      ja    Mainmenu
      mov   ax, FileField
      mul   bx
      add   ax, FileAddr
      mov   bp, ax
      mov   word[bp], 0
      mov   cx, 10h
      xor   ax, ax
      call  FileInput
      jmp   Readfile

FileInput:
      mov   bx, bp
      mov   word[bpaddr], bx
      mov   word[FIcount], ax
      mov   word[maxcount], cx
FIInput:
      mov   ah, 0
      int   16h
      mov   byte[char], al
      cmp   byte[char], 1bh
      jz    FIReturn
      mov   cx, word[maxcount]
      mov   ax, word[FIcount]
      cmp   cx, ax
      jle   FIInput
      cmp   byte[char], 1fh
      jle   FIInput
      cmp   byte[char], 7eh
      ja    FIInput
      inc   word[FIcount]
      mov   bx, word[bpaddr]
      mov   ax, word[FIcount]
      mov   bp, bx
      mov   word[bp], ax
      inc   bp
      add   bp, ax
      mov   al, byte[char]
      mov   byte[bp], al
      mov   ax, 1
      call  Print
      jmp   FIInput

FIReturn:
      ret

Printnewline:
	mov	bp, Newline		
	mov	ax, NewlineLength 
	call  Print
      mov   word[y], 1
      ret

Printselect:
      mov   byte[style], 0Eh
	mov	bp, Select		
	mov	ax, SelectLength 
	call  Print
      mov   byte[style], 0Fh
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
      pusha
      mov   word[count], ax
      inc   word[count]
PrintLoop:
      dec   word[count]
      jz    PrintEnd
      ;set the output word
      mov   ah, byte[style]   ;  0000：黑底、1111：亮白字（默认值为07h）
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
      cmp   byte[bp], 0dh     ;check if \r
      jz   PrintAfterL1
	mov   bp, ax            ;set position
      mov   ax, cx            ;rebuild output word
	mov   word[gs:bp], ax   ;output
      mov   bp, dx            ;rebuild bp
PrintAfterL1:
      ;calculate next position
      inc   word[y]
      cmp   byte[bp], 0dh
      jz    AxInc
PrintAfterL2:
      inc   bp
	jmp   PrintLoop
PrintEnd:
      popa
      ret
AxInc:
      inc   word[x]
      mov   word[y], 0
      jmp   PrintAfterL2

Datafield:
      count dw 0
      FIcount     dw 0
      maxcount    dw 0
      bpaddr      dw 0
      selectfile  dw 0
      totalfile   dw 0
      x     dw 0
      y     dw 0
      style db 0
      char  db 0
LineStartMessage:
      db '-- INSERT --        '
LineStartMessageLength  equ ($-LineStartMessage)  
LineEndMessage:
      db '-1,-1         All'
LineEndMessageLength  equ ($-LineEndMessage)
MainMessage:
      db '" ==================================================', 0dh
      db '"                VIN - VIN Is Non-vim', 0dh
      db '" XJB Directory Listing                  (XJB v000)', 0dh
      db '"   [RAM]/', 0dh
      db '"   Sorted by    none', 0dh
      db '"   Quick Help: W:previous S:next Enter:confirm ESC:exit', 0dh
      db '" ==================================================', 0dh
MainMessageLength  equ ($-MainMessage)
Newline:
      db 0dh
NewlineLength  equ ($-Newline)
CreateMessage:
      db ' Create New File', 0dh
CreateMessageLength  equ ($-CreateMessage)
InputNameMessage:
      db 'Please Input File Name(press ESC to confirm):'
InputNameMessageLength  equ ($-InputNameMessage)
Select:
      db '[*] '
SelectLength  equ ($-Select)
Quto:
      db '"'
QutoLength  equ ($-Quto)
      times 1536-($-$$) db 0