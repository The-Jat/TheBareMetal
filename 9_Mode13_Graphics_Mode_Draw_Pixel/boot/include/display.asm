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
;	ax = y coordinate
;	bx = x coordinate
;	cl = color
draw_pixel:
	mov dx, 0xA000 ; Set segment to video memory
	mov es, dx	; es now points to video memory
	
	mov dx, GRAPHICS_MODE_13_SCREEN_WIDTH	; set dx to screen width

	mul dx		; ax = y * 320

	add ax, bx	; ax = y * 320 + bx

	mov di, ax	; move offset to di

	mov al, cl	; set al to the color for the pixel
	stosb		; store al to ES:DI and increment di

ret

section .data
	GRAPHICS_MODE_13_SCREEN_WIDTH	equ 320		; Screen width for the graphics mode 13
	FRAMEBUFFER_ADDRESS		equ 0xA000	; Memory address for the mode 13




%endif ; __BARE_METAL_DISPLAY_INC__
