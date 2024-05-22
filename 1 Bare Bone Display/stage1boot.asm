; stage1boot.asm

[org 0x7c00]          ; Set the origin to 0x7C00, where the BIOS loads the boot sector

mov [BOOT_DISK], dl   ; Save the boot disk number (passed by BIOS in DL) to BOOT_DISK

mov bx, MSG_REAL_MODE ; Load the address of the message into BX
call print_string     ; Call the print_string function to print the message

jmp $                 ; Infinite loop to halt execution

%include "utils16/print.asm" ; Include the print_string function from an external file

MSG_REAL_MODE:
    db 'Starting in real mode', 0  ; Null-terminated string

BOOT_DISK: db 0                    ; Variable to store the boot disk number

times (510-($-$$)) db 0            ; Pad the rest of the boot sector with zeros
db 0x55                            ; Boot sector signature (part 1)
db 0xaa                            ; Boot sector signature (part 2)
