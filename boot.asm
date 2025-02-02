bits 16 ; tells assembler to work in 16 bit real-mode

; code resides at 0x7C00 so segment is 0x7C0
  mov ax, 0x7C0
  mov ds, ax

; storage segment is 512 bytes after from 0x7C00 for 512 bytes to 0x7E00 so stack segment is 0x7E0
  mov ax, 0x7E0
  mov ss, ax

; setting stack pointer to 0x2000 so stack top is at 0x9E00 and stack size is 8Kb
  mov sp, 0x2000

call clearscreen

push 0x0000 ; argument for movecursor
call setcursor
add sp, 2 ; clean up stack

push bootmessage ; argument for print
call print
add sp, 2 ; clean up stack

cli   ; disables further interrupts
hlt   ; halt processor from executing program further
  

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

; string message to print upon booting db means save it byte by byte
bootmessage: db  "Never gonna give you up, never gonna let you down.",0

print:
  push bp
  mov bp, sp
  pusha

; https://www.ctyme.com/intr/rb-0106.htm <- info on interrupt
  mov si, [bp+4]  ; pointer to data
  mov bh, 0x00    ; page number set to 0 (current page)
  mov bl, 0x00    ; set foreground color to black
  mov ah, 0x0E    ; lets interrupt know to print message in console

.char:
    mov al, [si]  ; dereference pointer to string to get current character
    add si, 1     ; move to next character
    or al, 0      ; check if current character is the null terminator
    je .return    ; end loop when string is looped through
    int 0x10      ; call interrupt to print current character stored in al
    jmp .char     ; loop
.return:
  popa
  mov sp, bp
  pop bp
  ret

times 510-($-$$) db 0  ; fills up remaining spaces with 0 to fit within 512 bytes assigned to bootloader
dw 0xAA55 ; bootloader signature 
