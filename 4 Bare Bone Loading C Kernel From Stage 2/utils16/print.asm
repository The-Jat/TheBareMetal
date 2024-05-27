[bits 16]  ; Specify 16-bit code

print_string:
    pusha                        ; Save all general-purpose registers
    mov ah, 0x0e                 ; Set AH to BIOS teletype output function
print_string_cycle:
    cmp byte [bx], 0             ; Compare the byte at address BX with 0 (null terminator)
    je print_string_end          ; If zero (null terminator), jump to the end
    mov al, [bx]                 ; Load the byte at address BX into AL
    cmp al, 0x0A                 ; Compare AL with newline character (LF)
    je newline                   ; If newline, jump to newline handler
    int 0x10                     ; Call BIOS interrupt 0x10 to print the character in AL
    add bx, 1                    ; Increment BX to point to the next character
    jmp print_string_cycle       ; Repeat the loop

newline:
    mov al, 0x0D                 ; Carriage return
    int 0x10                     ; Call BIOS interrupt 0x10
    mov al, 0x0A                 ; Line feed
    int 0x10                     ; Call BIOS interrupt 0x10
    add bx, 1                    ; Increment BX to point to the next character
    jmp print_string_cycle       ; Continue printing

print_string_end:
    popa                         ; Restore all general-purpose registers
    ret                          ; Return from the function
