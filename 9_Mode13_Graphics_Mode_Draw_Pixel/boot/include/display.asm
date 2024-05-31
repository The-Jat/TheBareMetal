;=============================================================================
; @file display.asm
;
; Constants that are used during compilation to make the assembly code readable
;=============================================================================

%ifndef __BARE_METAL_DISPLAY_INC__
%define __BARE_METAL_DISPLAY_INC__

switch_to_graphics_mode13:
	mov ax, 0x13
	int 0x10
ret


; Function to draw a pixel at (x, y) with color index c
;	cx = x coordinate
;	dx = y coordinate
;	bl = color
draw_pixel:
    push ax        ; Save AX register
    push bx        ; Save BX register
    
    mov ax, 0xA0000 ; Set segment to video memory
    ;mov es, ax
    
    mov bx, dx      ; Calculate the offset
    mov ax, 320     ; Screen width
    mul bx
    add bx, cx
    mov dx, bx
    pop bx
    mov al, bl      ; Color index
    mov bx, dx
    mov [es:bx], al ; Plot pixel
    
   ; pop bx         ; Restore BX register
	pop ax         ; Restore AX register
ret





%endif ; __BARE_METAL_DISPLAY_INC__
