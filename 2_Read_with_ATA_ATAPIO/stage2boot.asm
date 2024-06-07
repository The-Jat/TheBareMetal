[BITS 16]
[ORG 0x8000]

start:
    mov ax, 0x07C0  ; Set up the segment registers
    mov ds, ax
    mov es, ax

    mov si, msg     ; Load the address of the message string
    call print_str  ; Call the function to print the string

    jmp $           ; Infinite loop

print_char:
    ; Print character in AL
    mov ah, 0x0E    ; BIOS teletype function
    mov bh, 0x00    ; Page number (0 for mode 3)
    mov bl, 0x07    ; Text attribute (0x07 is white on black)
    int 0x10        ; Call BIOS interrupt

    ret

print_str:
    ; Print null-terminated string at DS:SI
    .next_char:
        lodsb       ; Load next byte of string into AL
        test al, al ; Check for null terminator
        jz .done    ; If null terminator, we're done
        call print_char
        jmp .next_char
    .done:
        ret

msg db 'Hello, Second Stage Bootloader!', 0

times 512-($-$$) db 0   ; Pad the rest of the sector with zeros
