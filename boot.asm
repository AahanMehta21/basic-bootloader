; code resides at 0x7C00 so segment is 0x7C0
  mov ax, 0x7C0
  mov ds, ax

; storage segment is 512 bytes after from 0x7C00 for 512 bytes to 0x7E00 so stack segment is 0x7E0
  mov ax, 0x7E0
  mov ss, ax

; setting stack pointer to 0x2000 so stack top is at 0x9E00 and stack size is 8Kb
  mov sp, 0x2000


; clearing the screen and setting up color and stuff
; calls video interrupt. see https://www.ctyme.com/intr/rb-0097.htm
clearscreen:
  push bp
  mov bp, sp
  pusha

  mov ah, 0x07
  mov al, 0x00 ; lets interrupt know to clear entire window
  mov bh, 0x07 ; bios color interrupt lower 7 bits is text color (light gray) and upper 7 is background (black)
  mov cx, 0x00 ; top left of screen is (0,0)
  mov dh, 0x18 ; 24 rows of characters
  mov dl, 0x4f ; 79 columns of characters
  int 0x10     ; calls the video interrupt

  popa
  mov sp, bp
  pop bp
  ret

setcursor:
  push bp
  mov bp, sp
  pusha

; see https://www.ctyme.com/intr/rb-0097.htm for more information about the cursor interrupt
  mov dx, [bp+4]  ; bp+4 accesses argument passed to function, which is ent to dx which lets the interrupt know cursor position
  mov ah, 0x02    ; lets interrupt know to set cursor position
  mov bh, 0x00    ; cursor is at current page (page 0)
  int 0x10        ; calls video interrupt

  popa
  mov sp, bp
  pop bp
  ret

; string message to print upon booting
bootmessage: "Never gonna give you up, never gonna let you down.", 0

print:
  push bp
  mov bp, sp
  pusha

; https://www.ctyme.com/intr/rb-0106.htm <- info on interrupt
  mov si, [bp+4]    ; pointer to data
  mov bh, 0x00      ; 

  popa
  mov sp, bp
  pop bp
  ret
