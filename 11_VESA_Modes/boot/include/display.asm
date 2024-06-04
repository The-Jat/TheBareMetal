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
	mov dx, FRAMEBUFFER_ADDRESS ; Set segment to video memory
	mov es, dx	; es now points to video memory
	
	mov dx, GRAPHICS_MODE_13_SCREEN_WIDTH	; set dx to screen width

	mul dx		; ax = y * 320

	add ax, bx	; ax = y * 320 + bx

	mov di, ax	; move offset to di

	mov al, cl	; set al to the color for the pixel
	stosb		; store al to ES:DI and increment di

ret


; Function: draw_char
; Inputs: AL = character, BX = X position, CX = Y position

    
; Function: draw_A
; Inputs: BX = X position, CX = Y position
draw_A:
    pusha                    ; Save all general-purpose registers
mov al, 'A'
sub al, 32	; ASCII_value - 32 (First printable character)
shl al, 3	; multiply by 8 using left shift (each character is 8 bytes long)

; pointing SI to the bitmap of character in the font_table by adding offset
	mov si, font_table           ; SI point to the starting address of font_table
	add si, ax	; Add the offset, SI now points to the character's bitmap in the font_table

	mov ax, cx	; set Y position to ax
	mov dx, GRAPHICS_MODE_13_SCREEN_WIDTH              ; Screen width in mode 13h (320 pixels)

	mul dx                   ; AX = Y * 320
	add ax, bx               ; AX += X position
	mov di, ax               ; DI = Screen position (Y * 320 + X)

	mov cx, 0xA000
	mov es, cx;0xA000           ; Segment address of video memory

	mov cx, 8		; 8 rows per character
next_row:
	lodsb                    ; Load next byte from font_A to AL
	mov ah, al               ; Copy to AH
	mov al, 0                ; Clear AL
	mov dx, 8                ; 8 bits per row
next_pixel:
	shl ah, 1                ; Shift AH right
	jnc skip_pixel           ; If carry (bit 0) is 0, skip
	mov byte [es:di], 0x0F   ; Set pixel color to white (0x0F)
skip_pixel:
	inc di		; Move to next pixel on screen
	dec dx		; Move to next bit
	jnz next_pixel           ; Repeat for 8 bits (pixels)

	add di, GRAPHICS_MODE_13_SCREEN_WIDTH - 8          ; Move to the start of the next row
	loop next_row            ; Repeat for 8 rows

	popa                     ; Restore all general-purpose registers
ret


	GRAPHICS_MODE_13_SCREEN_WIDTH	equ 320		; Screen width for the graphics mode 13
	FRAMEBUFFER_ADDRESS		equ 0xA000	; Memory address for the mode 13

;; This function prints the specfied number of character from the buffer,
;; si, pointer to buffer
;; cx, number of characters to print
print_passed_char:
	pusha
	.print_passed_char_loop:
	lodsb			; moves character from si to al and increment si.
	mov ah, 0x0E		; BIOS print function
	int 0x10		; BIOS VIDEO interrupt
	loop .print_passed_char_loop
	popa
ret
; Function to print VBE controller information
print_vbe_info:
pusha
    ; Print VBE signature
    mov si, vbeInfoBuffer
    mov cx, 4
    .loopy
    lodsb
    mov ah, 0x0E
    int 0x10
    loop .loopy
    jmp $
    ;mov di, print_buffer
    ;mov cx, 4
    ;rep movsb            ; Copy VBE signature to print buffer
    ;mov byte [edi], 0   ; Null-terminate the string
    ;call print_string_16   ; Print the string in the buffer

    ; Print VBE version
 ;   mov ax, word [esi + 4]  ; VBE version is a word (2 bytes)
 ;   call print_hex_word     ; Print VBE version in hexadecimal
 ;   call print_newline
    
    ; Print OEM string
    ;mov esi, dword [esi + 8] ;  OEM string pointer
    ;mov edi, print_buffer
    ;call print_oem_string	; Print OEM string
    ;call print_newline		; Print newline character
    
    ; Print Capabilities
   ; mov eax, dword [esi + 12]	; Capabilities pointer
   ; call print_capabilities	; Print capabilities
    ;call print_newline		; Print newline character
    
    ; Print video modes
    ;mov eax, dword [esi + 16]	; Video modes pointer
    ;call print_video_modes	; Print video modes
    ;call print_newline		; Print newline character
    
    

    ; Print other fields similarly
    ; For example, capabilities, total memory, OEM vendor name, etc.
popa
    ret


vbeInfoBuffer: resb 512	; Buffer to store VBE controller information.
print_buffer: resb 32	; Buffer for printing VBE information
vbe_info_block:		; 'Sector' 2
	.vbe_signature: db 'VBE2'
	.vbe_version: dw 0          ; Should be 0300h? BCD value
	.oem_string_pointer: dd 0 
	.capabilities: dd 0
	.video_mode_pointer: dd 0
	.total_memory: dw 0
	.oem_software_rev: dw 0
	.oem_vendor_name_pointer: dd 0
	.oem_product_name_pointer: dd 0
	.oem_product_revision_pointer: dd 0
	.reserved: times 222 db 0
	.oem_data: times 256 db 0


mode_info_block:	; 'Sector' 3
    ;; Mandatory info for all VBE revisions
	.mode_attributes: dw 0
	.window_a_attributes: db 0
	.window_b_attributes: db 0
	.window_granularity: dw 0
	.window_size: dw 0
	.window_a_segment: dw 0
	.window_b_segment: dw 0
	.window_function_pointer: dd 0
	.bytes_per_scanline: dw 0

    ;; Mandatory info for VBE 1.2 and above
	.x_resolution: dw 0
	.y_resolution: dw 0
	.x_charsize: db 0
	.y_charsize: db 0
	.number_of_planes: db 0
	.bits_per_pixel: db 0
	.number_of_banks: db 0
	.memory_model: db 0
	.bank_size: db 0
	.number_of_image_pages: db 0
	.reserved1: db 1

    ;; Direct color fields (required for direct/6 and YUV/7 memory models)
	.red_mask_size: db 0
	.red_field_position: db 0
	.green_mask_size: db 0
	.green_field_position: db 0
	.blue_mask_size: db 0
	.blue_field_position: db 0
	.reserved_mask_size: db 0
	.reserved_field_position: db 0
	.direct_color_mode_info: db 0

    ;; Mandatory info for VBE 2.0 and above
	.physical_base_pointer: dd 0     ; Physical address for flat memory frame buffer
	.reserved2: dd 0
	.reserved3: dw 0

    ;; Mandatory info for VBE 3.0 and above
	.linear_bytes_per_scan_line: dw 0
    .bank_number_of_image_pages: db 0
    .linear_number_of_image_pages: db 0
    .linear_red_mask_size: db 0
    .linear_red_field_position: db 0
    .linear_green_mask_size: db 0
    .linear_green_field_position: db 0
    .linear_blue_mask_size: db 0
    .linear_blue_field_position: db 0
    .linear_reserved_mask_size: db 0
    .linear_reserved_field_position: db 0
    .max_pixel_clock: dd 0

    .reserved4: times 190 db 0      ; Remainder of mode info block

;; VBE Variables
width: dw 1920
height: dw 1080
bpp: db 32
offset: dw 0
t_segment: dw 0	; "segment" is keyword in fasm
mode: dw 0

;print_supported_modes:
;    mov esi, modeInfoBuffer       ; Set source index to mode information buffer
;    mov edi, print_buffer         ; Set destination index to print buffer
;    mov cx, word [esi]            ; Number of supported modes
;    mov byte [edi], 'S'           ; Print 'Supported Modes:' header
;    mov byte [edi + 1], ' '
;    mov byte [edi + 2], ' '
;    add edi, 3                    ; Move destination index
;    call print_string_16             ; Print header
;    call print_newline            ; Print newline

;.loop_modes:
;    add esi, 2                    ; Move to next mode number
;    mov ax, [esi]                 ; Get video mode number
;    call print_hex_word           ; Print mode number in hexadecimal
;    call print_newline            ; Print newline
;    loop .loop_modes              ; Repeat for all supported modes

;    ret

print_newline:
    mov ah, 0x0E            ; BIOS function to print character
    mov al, 0x0A            ; Newline character
    mov bh, 0x00            ; Page number
    mov bl, 0x07            ; Attribute (white on black)
    int 0x10                ; Call BIOS interrupt to print character
    mov al, 0x0D            ; Carriage return character
    int 0x10                ; Call BIOS interrupt to print character
    ret

; Function to print OEM string
print_oem_string:
    mov edi, print_buffer   ; Destination buffer
    xor ecx, ecx            ; Clear ECX register
    mov cl, 32              ; Maximum characters to print
    cld                     ; Set direction flag to forward
    repne scasb             ; Scan for null terminator
    jecxz .done             ; If not found, exit
    mov ecx, 32             ; Reset ECX to maximum characters to print
    mov esi, edi            ; Set source index to destination
    sub esi, ecx            ; Calculate source pointer
    mov edi, print_buffer   ; Reset destination pointer
    mov ecx, 32             ; Reset ECX to maximum characters to print
    rep movsb               ; Copy string to buffer
.done:
    call print_string       ; Print the string
    ret


; Function to print a string
print_string_16:
    mov ah, 0x0E           ; BIOS function to print character
    ;mov bx, 0x0007         ; Display page (0), attribute (white on black)
.loop16:
    lodsb                  ; Load character from string into AL
    test al, al            ; Check for null terminator
    jz .done               ; If null terminator, exit loop
    int 0x10               ; Otherwise, print the character
    jmp .loop16              ; Continue printing characters
.done:
    ret

hexString: db '0x0000'
hex_to_ascii: db '0123456789ABCDEF'
;; print_hex: Suboutine to print a hex string
    print_hex:
        mov cx, 4	; offset in string, counter (4 hex characters)
        .hex_loop:
            mov ax, dx	              ; Hex word passed in DX
            and al, 0Fh               ; Use nibble in AL
            mov bx, hex_to_ascii
            xlatb                     ; AL = [DS:BX + AL]

            mov bx, cx                ; Need bx to index data
            mov [hexString+bx+1], al  ; Store hex char in string
            ror dx, 4                 ; Get next nibble
        loop .hex_loop 

        mov si, hexString             ; Print out hex string
        mov ah, 0Eh
        mov cx, 6                     ; Length of string
        .loop:
            lodsb
            int 10h
        loop .loop
        ret

; Function to print a hexadecimal word (2 bytes)
print_hex_word:
    ; Convert each nibble of the word to a hexadecimal character and print it
    mov cx, 4               ; Loop counter for each nibble
.next_nibble:
    rol ax, 4               ; Rotate left to get next nibble in AL
    mov dl, al              ; Move nibble to DL for printing
    and dl, 0x0F            ; Mask upper bits to isolate nibble
    add dl, '0'             ; Convert nibble to ASCII character
    cmp dl, '9'             ; Check if character is in range '0' to '9'
    jbe .print_digit        ; If yes, print digit
    add dl, 7               ; If not, adjust for characters 'A' to 'F'
.print_digit:
    mov ah, 0x0E            ; BIOS function to print character
    mov bx, 0x0007          ; Display page (0), attribute (white on black)
    int 0x10                ; Call BIOS interrupt to print character
    loop .next_nibble       ; Continue with next nibble
    ret


font_table:
    ; Offset 0x00 (ASCII 32: Space ' ')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b00000000  ; Row 2: 0x00
    db 0b00000000  ; Row 3: 0x00
    db 0b00000000  ; Row 4: 0x00
    db 0b00000000  ; Row 5: 0x00
    db 0b00000000  ; Row 6: 0x00
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x08 (ASCII 33: Exclamation Mark '!')
    db 0b00011000  ; Row 0: 0x18
    db 0b00011000  ; Row 1: 0x18
    db 0b00011000  ; Row 2: 0x18
    db 0b00011000  ; Row 3: 0x18
    db 0b00011000  ; Row 4: 0x18
    db 0b00000000  ; Row 5: 0x00
    db 0b00011000  ; Row 6: 0x18
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x10 (ASCII 34: Double Quote '"')
    db 0b01100110  ; Row 0: 0x66
    db 0b01100110  ; Row 1: 0x66
    db 0b00100100  ; Row 2: 0x24
    db 0b00000000  ; Row 3: 0x00
    db 0b00000000  ; Row 4: 0x00
    db 0b00000000  ; Row 5: 0x00
    db 0b00000000  ; Row 6: 0x00
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x18 (ASCII 35: Hash '#')
    db 0b01100110  ; Row 0: 0x66
    db 0b01100110  ; Row 1: 0x66
    db 0b11111111  ; Row 2: 0xFF
    db 0b01100110  ; Row 3: 0x66
    db 0b11111111  ; Row 4: 0xFF
    db 0b01100110  ; Row 5: 0x66
    db 0b01100110  ; Row 6: 0x66
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x20 (ASCII 36: Dollar Sign '$')
    db 0b00011000  ; Row 0: 0x18
    db 0b00111111  ; Row 1: 0x3F
    db 0b01100000  ; Row 2: 0x60
    db 0b00111110  ; Row 3: 0x3E
    db 0b00000111  ; Row 4: 0x07
    db 0b01111110  ; Row 5: 0x7E
    db 0b00011000  ; Row 6: 0x18
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x28 (ASCII 37: Percent '%')
    db 0b11000001  ; Row 0: 0xC1
    db 0b11000110  ; Row 1: 0xC6
    db 0b00001100  ; Row 2: 0x0C
    db 0b00011000  ; Row 3: 0x18
    db 0b00110000  ; Row 4: 0x30
    db 0b01100011  ; Row 5: 0x63
    db 0b11000011  ; Row 6: 0xC3
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x30 (ASCII 38: Ampersand '&')
    db 0b00110000  ; Row 0: 0x30
    db 0b01101100  ; Row 1: 0x6C
    db 0b01100100  ; Row 2: 0x64
    db 0b00111000  ; Row 3: 0x38
    db 0b01101110  ; Row 4: 0x6E
    db 0b11001100  ; Row 5: 0xCC
    db 0b01110110  ; Row 6: 0x76
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x38 (ASCII 39: Single Quote ''')
    db 0b00011000  ; Row 0: 0x18
    db 0b00011000  ; Row 1: 0x18
    db 0b00110000  ; Row 2: 0x30
    db 0b00000000  ; Row 3: 0x00
    db 0b00000000  ; Row 4: 0x00
    db 0b00000000  ; Row 5: 0x00
    db 0b00000000  ; Row 6: 0x00
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x40 (ASCII 40: Left Parenthesis '(')
    db 0b00001100  ; Row 0: 0x0C
    db 0b00011000  ; Row 1: 0x18
    db 0b00110000  ; Row 2: 0x30
    db 0b00110000  ; Row 3: 0x30
    db 0b00110000  ; Row 4: 0x30
    db 0b00011000  ; Row 5: 0x18
    db 0b00001100  ; Row 6: 0x0C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x48 (ASCII 41: Right Parenthesis ')')
    db 0b00110000  ; Row 0: 0x30
    db 0b00011000  ; Row 1: 0x18
    db 0b00001100  ; Row 2: 0x0C
    db 0b00001100  ; Row 3: 0x0C
    db 0b00001100  ; Row 4: 0x0C
    db 0b00011000  ; Row 5: 0x18
    db 0b00110000  ; Row 6: 0x30
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x50 (ASCII 42: Asterisk '*')
    db 0b00011000  ; Row 0: 0x18
    db 0b01101100  ; Row 1: 0x6C
    db 0b00111100  ; Row 2: 0x3C
    db 0b11111111  ; Row 3: 0xFF
    db 0b00111100  ; Row 4: 0x3C
    db 0b01101100  ; Row 5: 0x6C
    db 0b00011000  ; Row 6: 0x18
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x58 (ASCII 43: Plus '+')
    db 0b00011000  ; Row 0: 0x18
    db 0b00011000  ; Row 1: 0x18
    db 0b00011000  ; Row 2: 0x18
    db 0b11111111  ; Row 3: 0xFF
    db 0b00011000  ; Row 4: 0x18
    db 0b00011000  ; Row 5: 0x18
    db 0b00011000  ; Row 6: 0x18
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x60 (ASCII 44: Comma ',')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b00000000  ; Row 2: 0x00
    db 0b00000000  ; Row 3: 0x00
    db 0b00000000  ; Row 4: 0x00
    db 0b00011000  ; Row 5: 0x18
    db 0b00011000  ; Row 6: 0x18
    db 0b00110000  ; Row 7: 0x30

    ; Offset 0x68 (ASCII 45: Hyphen '-')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b00000000  ; Row 2: 0x00
    db 0b11111111  ; Row 3: 0xFF
    db 0b00000000  ; Row 4: 0x00
    db 0b00000000  ; Row 5: 0x00
    db 0b00000000  ; Row 6: 0x00
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x70 (ASCII 46: Period '.')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b00000000  ; Row 2: 0x00
    db 0b00000000  ; Row 3: 0x00
    db 0b00000000  ; Row 4: 0x00
    db 0b00011000  ; Row 5: 0x18
    db 0b00011000  ; Row 6: 0x18
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x78 (ASCII 47: Slash '/')
    db 0b00000001  ; Row 0: 0x01
    db 0b00000010  ; Row 1: 0x02
    db 0b00000110  ; Row 2: 0x06
    db 0b00001100  ; Row 3: 0x0C
    db 0b00011000  ; Row 4: 0x18
    db 0b00110000  ; Row 5: 0x30
    db 0b01100000  ; Row 6: 0x60
    db 0b11000000  ; Row 7: 0xC0

    ; Offset 0x80 (ASCII 48: Zero '0')
    db 0b00111100  ; Row 0: 0x3C
    db 0b01100110  ; Row 1: 0x66
    db 0b01101110  ; Row 2: 0x6E
    db 0b01110110  ; Row 3: 0x76
    db 0b01100110  ; Row 4: 0x66
    db 0b01100110  ; Row 5: 0x66
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x88 (ASCII 49: One '1')
    db 0b00011000  ; Row 0: 0x18
    db 0b00111000  ; Row 1: 0x38
    db 0b01111000  ; Row 2: 0x78
    db 0b00011000  ; Row 3: 0x18
    db 0b00011000  ; Row 4: 0x18
    db 0b00011000  ; Row 5: 0x18
    db 0b01111110  ; Row 6: 0x7E
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x90 (ASCII 50: Two '2')
    db 0b00111100  ; Row 0: 0x3C
    db 0b01100110  ; Row 1: 0x66
    db 0b00000110  ; Row 2: 0x06
    db 0b00001100  ; Row 3: 0x0C
    db 0b00110000  ; Row 4: 0x30
    db 0b01100000  ; Row 5: 0x60
    db 0b01111110  ; Row 6: 0x7E
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x98 (ASCII 51: Three '3')
    db 0b00111100  ; Row 0: 0x3C
    db 0b01100110  ; Row 1: 0x66
    db 0b00000110  ; Row 2: 0x06
    db 0b00011100  ; Row 3: 0x1C
    db 0b00000110  ; Row 4: 0x06
    db 0b01100110  ; Row 5: 0x66
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0xA0 (ASCII 52: Four '4')
    db 0b00001100  ; Row 0: 0x0C
    db 0b00011100  ; Row 1: 0x1C
    db 0b00111100  ; Row 2: 0x3C
    db 0b01101100  ; Row 3: 0x6C
    db 0b11111110  ; Row 4: 0xFE
    db 0b00001100  ; Row 5: 0x0C
    db 0b00001100  ; Row 6: 0x0C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0xA8 (ASCII 53: Five '5')
    db 0b01111110  ; Row 0: 0x7E
    db 0b01100000  ; Row 1: 0x60
    db 0b01111100  ; Row 2: 0x7C
    db 0b00000110  ; Row 3: 0x06
    db 0b00000110  ; Row 4: 0x06
    db 0b01100110  ; Row 5: 0x66
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0xB0 (ASCII 54: Six '6')
    db 0b00111100  ; Row 0: 0x3C
    db 0b01100000  ; Row 1: 0x60
    db 0b01111100  ; Row 2: 0x7C
    db 0b01100110  ; Row 3: 0x66
    db 0b01100110  ; Row 4: 0x66
    db 0b01100110  ; Row 5: 0x66
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0xB8 (ASCII 55: Seven '7')
    db 0b01111110  ; Row 0: 0x7E
    db 0b01100110  ; Row 1: 0x66
    db 0b00000110  ; Row 2: 0x06
    db 0b00001100  ; Row 3: 0x0C
    db 0b00001100  ; Row 4: 0x0C
    db 0b00001100  ; Row 5: 0x0C
    db 0b00001100  ; Row 6: 0x0C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0xC0 (ASCII 56: Eight '8')
    db 0b00111100  ; Row 0: 0x3C
    db 0b01100110  ; Row 1: 0x66
    db 0b01100110  ; Row 2: 0x66
    db 0b00111100  ; Row 3: 0x3C
    db 0b01100110  ; Row 4: 0x66
    db 0b01100110  ; Row 5: 0x66
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0xC8 (ASCII 57: Nine '9')
    db 0b00111100  ; Row 0: 0x3C
    db 0b01100110  ; Row 1: 0x66
    db 0b01100110  ; Row 2: 0x66
    db 0b00111110  ; Row 3: 0x3E
    db 0b00000110  ; Row 4: 0x06
    db 0b01100110  ; Row 5: 0x66
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0xD0 (ASCII 58: Colon ':')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b00011000  ; Row 2: 0x18
    db 0b00011000  ; Row 3: 0x18
    db 0b00000000  ; Row 4: 0x00
    db 0b00011000  ; Row 5: 0x18
    db 0b00011000  ; Row 6: 0x18
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0xD8 (ASCII 59: Semicolon ';')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b00011000  ; Row 2: 0x18
    db 0b00011000  ; Row 3: 0x18
    db 0b00000000  ; Row 4: 0x00
    db 0b00011000  ; Row 5: 0x18
    db 0b00011000  ; Row 6: 0x18
    db 0b00110000  ; Row 7: 0x30

    ; Offset 0xE0 (ASCII 60: Less Than '<')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000110  ; Row 1: 0x06
    db 0b00011000  ; Row 2: 0x18
    db 0b01100000  ; Row 3: 0x60
    db 0b11000000  ; Row 4: 0xC0
    db 0b01100000  ; Row 5: 0x60
    db 0b00011000  ; Row 6: 0x18
    db 0b00000110  ; Row 7: 0x06

    ; Offset 0xE8 (ASCII 61: Equals '=')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b11111111  ; Row 2: 0xFF
    db 0b00000000  ; Row 3: 0x00
    db 0b11111111  ; Row 4: 0xFF
    db 0b00000000  ; Row 5: 0x00
    db 0b00000000  ; Row 6: 0x00
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0xF0 (ASCII 62: Greater Than '>')
    db 0b00000000  ; Row 0: 0x00
    db 0b01100000  ; Row 1: 0x60
    db 0b00011000  ; Row 2: 0x18
    db 0b00000110  ; Row 3: 0x06
    db 0b00000011  ; Row 4: 0x03
    db 0b00000110  ; Row 5: 0x06
    db 0b00011000  ; Row 6: 0x18
    db 0b01100000  ; Row 7: 0x60

    ; Offset 0xF8 (ASCII 63: Question Mark '?')
    db 0b00111100  ; Row 0: 0x3C
    db 0b01100110  ; Row 1: 0x66
    db 0b00000110  ; Row 2: 0x06
    db 0b00001100  ; Row 3: 0x0C
    db 0b00011000  ; Row 4: 0x18
    db 0b00000000  ; Row 5: 0x00
    db 0b00011000  ; Row 6: 0x18
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x100 (ASCII 64: At Sign '@')
    db 0b00111100  ; Row 0: 0x3C
    db 0b01000010  ; Row 1: 0x42
    db 0b01011010  ; Row 2: 0x5A
    db 0b01011110  ; Row 3: 0x5E
    db 0b01011110  ; Row 4: 0x5E
    db 0b01000000  ; Row 5: 0x40
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x108 (ASCII 65: Capital A 'A')
    db 0b00111100  ; Row 0: 0x3C
    db 0b01100110  ; Row 1: 0x66
    db 0b01100110  ; Row 2: 0x66
    db 0b01111110  ; Row 3: 0x7E
    db 0b01100110  ; Row 4: 0x66
    db 0b01100110  ; Row 5: 0x66
    db 0b01100110  ; Row 6: 0x66
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x110 (ASCII 66: Capital B 'B')
    db 0b01111100  ; Row 0: 0x7C
    db 0b01100110  ; Row 1: 0x66
    db 0b01100110  ; Row 2: 0x66
    db 0b01111100  ; Row 3: 0x7C
    db 0b01100110  ; Row 4: 0x66
    db 0b01100110  ; Row 5: 0x66
    db 0b01111100  ; Row 6: 0x7C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x118 (ASCII 67: Capital C 'C')
    db 0b00111100  ; Row 0: 0x3C
    db 0b01100110  ; Row 1: 0x66
    db 0b01100000  ; Row 2: 0x60
    db 0b01100000  ; Row 3: 0x60
    db 0b01100000  ; Row 4: 0x60
    db 0b01100110  ; Row 5: 0x66
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x120 (ASCII 68: Capital D 'D')
    db 0b01111100  ; Row 0: 0x7C
    db 0b01100110  ; Row 1: 0x66
    db 0b01100010  ; Row 2: 0x62
    db 0b01100010  ; Row 3: 0x62
    db 0b01100010  ; Row 4: 0x62
    db 0b01100110  ; Row 5: 0x66
    db 0b01111100  ; Row 6: 0x7C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x128 (ASCII 69: Capital E 'E')
    db 0b01111110  ; Row 0: 0x7E
    db 0b01100000  ; Row 1: 0x60
    db 0b01100000  ; Row 2: 0x60
    db 0b01111100  ; Row 3: 0x7C
    db 0b01100000  ; Row 4: 0x60
    db 0b01100000  ; Row 5: 0x60
    db 0b01111110  ; Row 6: 0x7E
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x130 (ASCII 70: Capital F 'F')
    db 0b01111110  ; Row 0: 0x7E
    db 0b01100000  ; Row 1: 0x60
    db 0b01100000  ; Row 2: 0x60
    db 0b01111100  ; Row 3: 0x7C
    db 0b01100000  ; Row 4: 0x60
    db 0b01100000  ; Row 5: 0x60
    db 0b01100000  ; Row 6: 0x60
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x138 (ASCII 71: Capital G 'G')
    db 0b00111100  ; Row 0: 0x3C
    db 0b01100110  ; Row 1: 0x66
    db 0b01100000  ; Row 2: 0x60
    db 0b01100000  ; Row 3: 0x60
    db 0b01101110  ; Row 4: 0x6E
    db 0b01100110  ; Row 5: 0x66
    db 0b00111110  ; Row 6: 0x3E
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x140 (ASCII 72: Capital H 'H')
    db 0b01100110  ; Row 0: 0x66
    db 0b01100110  ; Row 1: 0x66
    db 0b01100110  ; Row 2: 0x66
    db 0b01111110  ; Row 3: 0x7E
    db 0b01100110  ; Row 4: 0x66
    db 0b01100110  ; Row 5: 0x66
    db 0b01100110  ; Row 6: 0x66
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x148 (ASCII 73: Capital I 'I')
    db 0b00111100  ; Row 0: 0x3C
    db 0b00011000  ; Row 1: 0x18
    db 0b00011000  ; Row 2: 0x18
    db 0b00011000  ; Row 3: 0x18
    db 0b00011000  ; Row 4: 0x18
    db 0b00011000  ; Row 5: 0x18
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x150 (ASCII 74: Capital J 'J')
    db 0b00011110  ; Row 0: 0x1E
    db 0b00001100  ; Row 1: 0x0C
    db 0b00001100  ; Row 2: 0x0C
    db 0b00001100  ; Row 3: 0x0C
    db 0b01101100  ; Row 4: 0x6C
    db 0b01101100  ; Row 5: 0x6C
    db 0b00111000  ; Row 6: 0x38
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x158 (ASCII 75: Capital K 'K')
    db 0b01100110  ; Row 0: 0x66
    db 0b01101100  ; Row 1: 0x6C
    db 0b01111000  ; Row 2: 0x78
    db 0b01110000  ; Row 3: 0x70
    db 0b01111000  ; Row 4: 0x78
    db 0b01101100  ; Row 5: 0x6C
    db 0b01100110  ; Row 6: 0x66
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x160 (ASCII 76: Capital L 'L')
    db 0b01100000  ; Row 0: 0x60
    db 0b01100000  ; Row 1: 0x60
    db 0b01100000  ; Row 2: 0x60
    db 0b01100000  ; Row 3: 0x60
    db 0b01100000  ; Row 4: 0x60
    db 0b01100000  ; Row 5: 0x60
    db 0b01111110  ; Row 6: 0x7E
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x168 (ASCII 77: Capital M 'M')
    db 0b01100011  ; Row 0: 0x63
    db 0b01110111  ; Row 1: 0x77
    db 0b01111111  ; Row 2: 0x7F
    db 0b01101010  ; Row 3: 0x6A
    db 0b01100011  ; Row 4: 0x63
    db 0b01100011  ; Row 5: 0x63
    db 0b01100011  ; Row 6: 0x63
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x170 (ASCII 78: Capital N 'N')
    db 0b01100011  ; Row 0: 0x63
    db 0b01110011  ; Row 1: 0x73
    db 0b01111011  ; Row 2: 0x7B
    db 0b01111111  ; Row 3: 0x7F
    db 0b01101111  ; Row 4: 0x6F
    db 0b01100111  ; Row 5: 0x67
    db 0b01100011  ; Row 6: 0x63
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x178 (ASCII 79: Capital O 'O')
    db 0b00111100  ; Row 0: 0x3C
    db 0b01100110  ; Row 1: 0x66
    db 0b01100110  ; Row 2: 0x66
    db 0b01100110  ; Row 3: 0x66
    db 0b01100110  ; Row 4: 0x66
    db 0b01100110  ; Row 5: 0x66
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x180 (ASCII 80: Capital P 'P')
    db 0b01111100  ; Row 0: 0x7C
    db 0b01100110  ; Row 1: 0x66
    db 0b01100110  ; Row 2: 0x66
    db 0b01111100  ; Row 3: 0x7C
    db 0b01100000  ; Row 4: 0x60
    db 0b01100000  ; Row 5: 0x60
    db 0b01100000  ; Row 6: 0x60
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x1B8 (ASCII 81: Capital Q 'Q')
    db 0b00111100  ; Row 0: 0x3C
    db 0b01100110  ; Row 1: 0x66
    db 0b01100110  ; Row 2: 0x66
    db 0b01100110  ; Row 3: 0x66
    db 0b01100110  ; Row 4: 0x66
    db 0b01100110  ; Row 5: 0x66
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x190 (ASCII 82: Capital R 'R')
    db 0b01111100  ; Row 0: 0x7C
    db 0b01100110  ; Row 1: 0x66
    db 0b01100110  ; Row 2: 0x66
    db 0b01111100  ; Row 3: 0x7C
    db 0b01101100  ; Row 4: 0x6C
    db 0b01100110  ; Row 5: 0x66
    db 0b01100110  ; Row 6: 0x66
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x198 (ASCII 83: Capital S 'S')
    db 0b00111100  ; Row 0: 0x3C
    db 0b01100110  ; Row 1: 0x66
    db 0b01100000  ; Row 2: 0x60
    db 0b00111100  ; Row 3: 0x3C
    db 0b00000110  ; Row 4: 0x06
    db 0b01100110  ; Row 5: 0x66
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x1A0 (ASCII 84: Capital T 'T')
    db 0b01111110  ; Row 0: 0x7E
    db 0b01011010  ; Row 1: 0x5A
    db 0b00011000  ; Row 2: 0x18
    db 0b00011000  ; Row 3: 0x18
    db 0b00011000  ; Row 4: 0x18
    db 0b00011000  ; Row 5: 0x18
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x1A8 (ASCII 85: Capital U 'U')
    db 0b01100110  ; Row 0: 0x66
    db 0b01100110  ; Row 1: 0x66
    db 0b01100110  ; Row 2: 0x66
    db 0b01100110  ; Row 3: 0x66
    db 0b01100110  ; Row 4: 0x66
    db 0b01100110  ; Row 5: 0x66
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x1B0 (ASCII 86: Capital V 'V')
    db 0b01100110  ; Row 0: 0x66
    db 0b01100110  ; Row 1: 0x66
    db 0b01100110  ; Row 2: 0x66
    db 0b01100110  ; Row 3: 0x66
    db 0b00100100  ; Row 4: 0x24
    db 0b00100100  ; Row 5: 0x24
    db 0b00011000  ; Row 6: 0x18
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x1B8 (ASCII 87: Capital W 'W')
    db 0b01100011  ; Row 0: 0x63
    db 0b01100011  ; Row 1: 0x63
    db 0b01100011  ; Row 2: 0x63
    db 0b01101011  ; Row 3: 0x6B
    db 0b01101011  ; Row 4: 0x6B
    db 0b01111111  ; Row 5: 0x7F
    db 0b01100110  ; Row 6: 0x66
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x1C0 (ASCII 88: Capital X 'X')
    db 0b01100110  ; Row 0: 0x66
    db 0b01100110  ; Row 1: 0x66
    db 0b00111100  ; Row 2: 0x3C
    db 0b00011000  ; Row 3: 0x18
    db 0b00111100  ; Row 4: 0x3C
    db 0b01100110  ; Row 5: 0x66
    db 0b01100110  ; Row 6: 0x66
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x1C8 (ASCII 89: Capital Y 'Y')
    db 0b01100110  ; Row 0: 0x66
    db 0b01100110  ; Row 1: 0x66
    db 0b01100110  ; Row 2: 0x66
    db 0b00111100  ; Row 3: 0x3C
    db 0b00011000  ; Row 4: 0x18
    db 0b00011000  ; Row 5: 0x18
    db 0b00011000  ; Row 6: 0x18
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x1D0 (ASCII 90: Capital Z 'Z')
    db 0b01111110  ; Row 0: 0x7E
    db 0b00000110  ; Row 1: 0x06
    db 0b00001100  ; Row 2: 0x0C
    db 0b00011000  ; Row 3: 0x18
    db 0b00110000  ; Row 4: 0x30
    db 0b01100000  ; Row 5: 0x60
    db 0b01111110  ; Row 6: 0x7E
    db 0b00000000  ; Row 7: 0x00
    
    ; Offset 0x1D8 (ASCII 91: Left Square Bracket '[')
    db 0b00011110  ; Row 0: 0x1E
    db 0b00011000  ; Row 1: 0x18
    db 0b00011000  ; Row 2: 0x18
    db 0b00011000  ; Row 3: 0x18
    db 0b00011000  ; Row 4: 0x18
    db 0b00011000  ; Row 5: 0x18
    db 0b00011110  ; Row 6: 0x1E
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x1E0 (ASCII 92: Backslash '\')
    db 0b01100000  ; Row 0: 0x60
    db 0b01100000  ; Row 1: 0x60
    db 0b00110000  ; Row 2: 0x30
    db 0b00110000  ; Row 3: 0x30
    db 0b00011000  ; Row 4: 0x18
    db 0b00011000  ; Row 5: 0x18
    db 0b00001100  ; Row 6: 0x0C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x1E8 (ASCII 93: Right Square Bracket ']')
    db 0b00011110  ; Row 0: 0x1E
    db 0b00001100  ; Row 1: 0x0C
    db 0b00001100  ; Row 2: 0x0C
    db 0b00001100  ; Row 3: 0x0C
    db 0b00001100  ; Row 4: 0x0C
    db 0b00001100  ; Row 5: 0x0C
    db 0b00011110  ; Row 6: 0x1E
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x1F0 (ASCII 94: Caret '^')
    db 0b00001000  ; Row 0: 0x08
    db 0b00011100  ; Row 1: 0x1C
    db 0b00110110  ; Row 2: 0x36
    db 0b01100011  ; Row 3: 0x63
    db 0b01100011  ; Row 4: 0x63
    db 0b00000000  ; Row 5: 0x00
    db 0b00000000  ; Row 6: 0x00
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x1F8 (ASCII 95: Underscore '_')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b00000000  ; Row 2: 0x00
    db 0b00000000  ; Row 3: 0x00
    db 0b00000000  ; Row 4: 0x00
    db 0b00000000  ; Row 5: 0x00
    db 0b01111111  ; Row 6: 0x7F
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x200 (ASCII 96: Grave Accent '`')
    db 0b00011000  ; Row 0: 0x18
    db 0b00001100  ; Row 1: 0x0C
    db 0b00000110  ; Row 2: 0x06
    db 0b00000000  ; Row 3: 0x00
    db 0b00000000  ; Row 4: 0x00
    db 0b00000000  ; Row 5: 0x00
    db 0b00000000  ; Row 6: 0x00
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x208 (ASCII 97: Lowercase a 'a')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b00011100  ; Row 2: 0x1C
    db 0b00100010  ; Row 3: 0x22
    db 0b00111110  ; Row 4: 0x3E
    db 0b01000010  ; Row 5: 0x42
    db 0b00111110  ; Row 6: 0x3E
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x210 (ASCII 98: Lowercase b 'b')
    db 0b01100000  ; Row 0: 0x60
    db 0b01100000  ; Row 1: 0x60
    db 0b01111100  ; Row 2: 0x7C
    db 0b01100110  ; Row 3: 0x66
    db 0b01100110  ; Row 4: 0x66
    db 0b01111100  ; Row 5: 0x7C
    db 0b01100000  ; Row 6: 0x60
    db 0b01100000  ; Row 7: 0x60

    ; Offset 0x218 (ASCII 99: Lowercase c 'c')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b00011100  ; Row 2: 0x1C
    db 0b00100010  ; Row 3: 0x22
    db 0b00100000  ; Row 4: 0x20
    db 0b00111100  ; Row 5: 0x3C
    db 0b00000000  ; Row 6: 0x00
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x220 (ASCII 100: Lowercase d 'd')
    db 0b00000110  ; Row 0: 0x06
    db 0b00000110  ; Row 1: 0x06
    db 0b00011110  ; Row 2: 0x1E
    db 0b00110110  ; Row 3: 0x36
    db 0b00100110  ; Row 4: 0x26
    db 0b00011110  ; Row 5: 0x1E
    db 0b00000000  ; Row 6: 0x00
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x228 (ASCII 101: Lowercase e 'e')
    db 0b00000000  ; Row 0: 0x00
    db 0b00011100  ; Row 1: 0x1C
    db 0b00100010  ; Row 2: 0x22
    db 0b00111110  ; Row 3: 0x3E
    db 0b00111110  ; Row 4: 0x3E
    db 0b00100000  ; Row 5: 0x20
    db 0b00011110  ; Row 6: 0x1E
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x230 (ASCII 102: Lowercase f 'f')
    db 0b00011100  ; Row 0: 0x1C
    db 0b00100010  ; Row 1: 0x22
    db 0b00111110  ; Row 2: 0x3E
    db 0b00100010  ; Row 3: 0x22
    db 0b00100000  ; Row 4: 0x20
    db 0b00100000  ; Row 5: 0x20
    db 0b00000000  ; Row 6: 0x00
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x238 (ASCII 103: Lowercase g 'g')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b00011110  ; Row 2: 0x1E
    db 0b00100110  ; Row 3: 0x26
    db 0b00111110  ; Row 4: 0x3E
    db 0b00000110  ; Row 5: 0x06
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x240 (ASCII 104: Lowercase h 'h')
    db 0b01100000  ; Row 0: 0x60
    db 0b01100000  ; Row 1: 0x60
    db 0b01111100  ; Row 2: 0x7C
    db 0b01100110  ; Row 3: 0x66
    db 0b01100110  ; Row 4: 0x66
    db 0b01100110  ; Row 5: 0x66
    db 0b01100110  ; Row 6: 0x66
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x248 (ASCII 105: Lowercase i 'i')
    db 0b00011000  ; Row 0: 0x18
    db 0b00000000  ; Row 1: 0x00
    db 0b00011000  ; Row 2: 0x18
    db 0b00011000  ; Row 3: 0x18
    db 0b00011000  ; Row 4: 0x18
    db 0b00011000  ; Row 5: 0x18
    db 0b00011110  ; Row 6: 0x1E
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x250 (ASCII 106: Lowercase j 'j')
    db 0b00000110  ; Row 0: 0x06
    db 0b00000000  ; Row 1: 0x00
    db 0b00000110  ; Row 2: 0x06
    db 0b00000110  ; Row 3: 0x06
    db 0b00000110  ; Row 4: 0x06
    db 0b00000110  ; Row 5: 0x06
    db 0b00000110  ; Row 6: 0x06
    db 0b00111100  ; Row 7: 0x3C

    ; Offset 0x258 (ASCII 107: Lowercase k 'k')
    db 0b01100000  ; Row 0: 0x60
    db 0b01100000  ; Row 1: 0x60
    db 0b01100110  ; Row 2: 0x66
    db 0b01101100  ; Row 3: 0x6C
    db 0b01111000  ; Row 4: 0x78
    db 0b01101100  ; Row 5: 0x6C
    db 0b01100110  ; Row 6: 0x66
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x260 (ASCII 108: Lowercase l 'l')
    db 0b00011110  ; Row 0: 0x1E
    db 0b00000110  ; Row 1: 0x06
    db 0b00000110  ; Row 2: 0x06
    db 0b00000110  ; Row 3: 0x06
    db 0b00000110  ; Row 4: 0x06
    db 0b00000110  ; Row 5: 0x06
    db 0b00000110  ; Row 6: 0x06
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x268 (ASCII 109: Lowercase m 'm')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b01101010  ; Row 2: 0x6A
    db 0b01110101  ; Row 3: 0x75
    db 0b01110101  ; Row 4: 0x75
    db 0b01101010  ; Row 5: 0x6A
    db 0b01100010  ; Row 6: 0x62
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x270 (ASCII 110: Lowercase n 'n')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b01111100  ; Row 2: 0x7C
    db 0b01100110  ; Row 3: 0x66
    db 0b01100110  ; Row 4: 0x66
    db 0b01100110  ; Row 5: 0x66
    db 0b01100110  ; Row 6: 0x66
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x278 (ASCII 111: Lowercase o 'o')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b00011100  ; Row 2: 0x1C
    db 0b00100010  ; Row 3: 0x22
    db 0b00100010  ; Row 4: 0x22
    db 0b00011100  ; Row 5: 0x1C
    db 0b00000000  ; Row 6: 0x00
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x280 (ASCII 112: Lowercase p 'p')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b01111100  ; Row 2: 0x7C
    db 0b01100110  ; Row 3: 0x66
    db 0b01100110  ; Row 4: 0x66
    db 0b01111100  ; Row 5: 0x7C
    db 0b01100000  ; Row 6: 0x60
    db 0b01100000  ; Row 7: 0x60

    ; Offset 0x288 (ASCII 113: Lowercase q 'q')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b00011110  ; Row 2: 0x1E
    db 0b00110110  ; Row 3: 0x36
    db 0b00100110  ; Row 4: 0x26
    db 0b00011110  ; Row 5: 0x1E
    db 0b00000110  ; Row 6: 0x06
    db 0b00000110  ; Row 7: 0x06

    ; Offset 0x290 (ASCII 114: Lowercase r 'r')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b01111100  ; Row 2: 0x7C
    db 0b01100110  ; Row 3: 0x66
    db 0b01100000  ; Row 4: 0x60
    db 0b01100000  ; Row 5: 0x60
    db 0b01100000  ; Row 6: 0x60
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x298 (ASCII 115: Lowercase s 's')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b00011100  ; Row 2: 0x1C
    db 0b00100010  ; Row 3: 0x22
    db 0b00011100  ; Row 4: 0x1C
    db 0b00000110  ; Row 5: 0x06
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x2A0 (ASCII 116: Lowercase t 't')
    db 0b00000000  ; Row 0: 0x00
    db 0b00001000  ; Row 1: 0x08
    db 0b00011100  ; Row 2: 0x1C
    db 0b00001000  ; Row 3: 0x08
    db 0b00001000  ; Row 4: 0x08
    db 0b00001000  ; Row 5: 0x08
    db 0b00000110  ; Row 6: 0x06
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x2A8 (ASCII 117: Lowercase u 'u')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b01100110  ; Row 2: 0x66
    db 0b01100110  ; Row 3: 0x66
    db 0b01100110  ; Row 4: 0x66
    db 0b00111110  ; Row 5: 0x3E
    db 0b00000000  ; Row 6: 0x00
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x2B0 (ASCII 118: Lowercase v 'v')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b01100110  ; Row 2: 0x66
    db 0b01100110  ; Row 3: 0x66
    db 0b00111100  ; Row 4: 0x3C
    db 0b00111100  ; Row 5: 0x3C
    db 0b00011000  ; Row 6: 0x18
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x2B8 (ASCII 119: Lowercase w 'w')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b01100011  ; Row 2: 0x63
    db 0b01101011  ; Row 3: 0x6B
    db 0b01101011  ; Row 4: 0x6B
    db 0b00111110  ; Row 5: 0x3E
    db 0b00011000  ; Row 6: 0x18
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x2C0 (ASCII 120: Lowercase x 'x')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b01100110  ; Row 2: 0x66
    db 0b00111100  ; Row 3: 0x3C
    db 0b00011000  ; Row 4: 0x18
    db 0b00111100  ; Row 5: 0x3C
    db 0b01100110  ; Row 6: 0x66
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x2C8 (ASCII 121: Lowercase y 'y')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b01100110  ; Row 2: 0x66
    db 0b01100110  ; Row 3: 0x66
    db 0b00111110  ; Row 4: 0x3E
    db 0b00000110  ; Row 5: 0x06
    db 0b00111100  ; Row 6: 0x3C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x2D0 (ASCII 122: Lowercase z 'z')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b01111110  ; Row 2: 0x7E
    db 0b00000110  ; Row 3: 0x06
    db 0b00001100  ; Row 4: 0x0C
    db 0b00011000  ; Row 5: 0x18
    db 0b01111110  ; Row 6: 0x7E
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x2D8 (ASCII 123: Left Curly Brace '{')
    db 0b00011100  ; Row 0: 0x1C
    db 0b00011000  ; Row 1: 0x18
    db 0b00011000  ; Row 2: 0x18
    db 0b00110000  ; Row 3: 0x30
    db 0b00011000  ; Row 4: 0x18
    db 0b00011000  ; Row 5: 0x18
    db 0b00011100  ; Row 6: 0x1C
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x2E0 (ASCII 124: Vertical Bar '|')
    db 0b00011000  ; Row 0: 0x18
    db 0b00011000  ; Row 1: 0x18
    db 0b00011000  ; Row 2: 0x18
    db 0b00011000  ; Row 3: 0x18
    db 0b00011000  ; Row 4: 0x18
    db 0b00011000  ; Row 5: 0x18
    db 0b00011000  ; Row 6: 0x18
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x2E8 (ASCII 125: Right Curly Brace '}')
    db 0b01110000  ; Row 0: 0x70
    db 0b00011000  ; Row 1: 0x18
    db 0b00011000  ; Row 2: 0x18
    db 0b00001100  ; Row 3: 0x0C
    db 0b00011000  ; Row 4: 0x18
    db 0b00011000  ; Row 5: 0x18
    db 0b01110000  ; Row 6: 0x70
    db 0b00000000  ; Row 7: 0x00

    ; Offset 0x2F0 (ASCII 126: Tilde '~')
    db 0b00000000  ; Row 0: 0x00
    db 0b00000000  ; Row 1: 0x00
    db 0b00110010  ; Row 2: 0x32
    db 0b01001100  ; Row 3: 0x4C
    db 0b00000000  ; Row 4: 0x00
    db 0b00000000  ; Row 5: 0x00
    db 0b00000000  ; Row 6: 0x00
    db 0b00000000  ; Row 7: 0x00



%endif ; __BARE_METAL_DISPLAY_INC__
