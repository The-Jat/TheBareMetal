[org 0x0600]

[bits 16]

start:
    cli                     ; Clear interrupts
    cld                     ; Clear direction flag
    xor ax, ax              ; Zero out the AX register
    mov ds, ax              ; Set DS (Data Segment) to 0
    mov es, ax              ; Set ES (Extra Segment) to 0

    ; Print a message
    mov si, msg
print_char:
    lodsb                   ; Load the next byte from SI into AL
    cmp al, 0               ; Compare AL with 0 (null terminator)
    je .done                ; If zero, jump to .done
    mov ah, 0x0e            ; BIOS teletype function
    int 0x10                ; Call BIOS interrupt
    jmp print_char          ; Repeat for the next character
.done:
    hlt                     ; Halt the CPU

msg db 'Kernel loaded successfully!', 0
