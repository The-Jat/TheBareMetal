;=============================================================================
; @file display.asm
;
; Constants that are used during compilation to make the assembly code readable
;=============================================================================

%ifndef __BARE_METAL_DISPLAY32_INC__
%define __BARE_METAL_DISPLAY32_INC__

	FRAMEBUFFER_ADDRESS_MODE_13		equ 0xA0000	; Memory address for the mode 13
	MODE_13_SCREEN_WIDTH			equ 320

print_string:
    pusha                    ; Save all general-purpose registers

.next_char:
    lodsb                    ; Load the next byte (character) from string into AL
    test al, al              ; Check if AL is zero (end of string)
    jz .done                 ; If zero, we're done


    ; Draw the character at the current position
    mov eax, eax              ; Character to print
    push ebx                 ; Save X position
    push ecx                 ; Save Y position
    call draw_Char
    pop ecx                  ; Restore Y position
    pop ebx                  ; Restore X position

    ; Advance to the next character position
    add ebx, 8               ; Move to the next character position (8 pixels to the right)
    jmp .next_char           ; Repeat for the next character

.done:
    popa                     ; Restore all general-purpose registers
    ret


;; Draw the pixel at a particular position
; ebx = x position
; eax = y position
; ecx = color
draw_pixel32:
	pusha
	mov edx, MODE_13_SCREEN_WIDTH
	mul edx
	add eax, ebx

	mov ebx, FRAMEBUFFER_ADDRESS_MODE_13
	add eax, ebx
	mov byte [eax], cl
	popa
ret

; Draw the character on the screen
; eax = charaacter to print
; ebx = x position
; ecx = y position
draw_Char:
    pusha                    ; Save all general-purpose registers
    
	sub esp, 4	; make way for local variable
	mov dword [ebp], edx	; push the color in local variable
	; Finding the offset of character in font table
	sub eax, 32	; ASCII_value - 32 (First Printable character)
	shl eax, 3	; Multiply by 8 using left shift (each character is 8 bytes long)

; pointing SI to the bitmap of character in the font_table by adding offset
	mov esi, font_table           ; SI point to the starting address of font_table
	add esi, eax	; Add the offset, SI now points to the character's bitmap in the font_table

	mov eax, ecx	; set Y position to ax
	mov edx, MODE_13_SCREEN_WIDTH              ; Screen width in mode 13h (320 pixels)

	mul edx                   ; AX = Y * 320
	add eax, ebx               ; AX += X position
	mov edi, eax               ; DI = Screen position (Y * 320 + X)

	add edi, FRAMEBUFFER_ADDRESS_MODE_13

	mov cx, 8		; 8 rows per character
next_row32:
	lodsb                    ; Load next byte from font_A to AL
	mov ah, al               ; Copy to AH
	mov al, 0                ; Clear AL
	mov edx, 8                ; 8 bits per row
next_pixel32:
	shl ah, 1                ; Shift AH right
	jnc skip_pixel32           ; If carry (bit 0) is 0, skip
	mov byte al, [ebp]	; read color from local variable.
	mov byte [edi], al;0x0F   ; Set pixel color to passed color
skip_pixel32:
	inc edi		; Move to next pixel on screen
	dec edx		; Move to next bit
	jnz next_pixel32           ; Repeat for 8 bits (pixels)

	add edi, MODE_13_SCREEN_WIDTH - 8          ; Move to the start of the next row
	loop next_row32            ; Repeat for 8 rows
	add esp, 4	; free the local variable
	popa                     ; Restore all general-purpose registers
ret




%endif ; __BARE_METAL_DISPLAY_INC__
