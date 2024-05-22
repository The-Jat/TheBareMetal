; utils16/print.asm

[bits 16] 	; Specify 16-bit code

print_string:
    pusha                        ; Save all general-purpose registers
    mov ah, 0x0e                 ; Set AH to BIOS teletype output function
print_string_cycle:
    cmp [bx], BYTE 0             ; Compare the byte at address BX with 0 (null terminator)
    je print_string_end          ; If zero (null terminator), jump to the end
    mov al, [bx]                 ; Load the byte at address BX into AL
    int 0x10                     ; Call BIOS interrupt 0x10 to print the character in AL
    add bx, 1                    ; Increment BX to point to the next character
    jmp print_string_cycle       ; Repeat the loop
print_string_end:
    popa                         ; Restore all general-purpose registers
    ret                          ; Return from the function
