; utils/disk_load.asm

[bits 16]

disk_load:
    push dx
    mov ah, 0x02                ; BIOS read sectors function
    mov al, dh                  ; Number of sectors to read from dh
    mov ch, 0x00                ; Cylinder number
    mov dh, 0x00                ; Head number
    mov cl, 0x02                ; Sector number (second sector, since boot sector is first)

    int 0x13                    ; BIOS interrupt call

    jc disk_error               ; Jump to error handling if carry flag is set

    pop dx                      ; Restore original dx
    cmp al, dh                  ; Check if the correct number of sectors was read
    jne disk_error              ; Jump to error if not
    
    mov bx, MSG_DISK_READ_SUCCESS
    call print_string
    ret                         ; Return if successful

disk_error:
    mov bx, MSG_DISK_ERROR      ; Load error message address
    call print_string           ; Print error message
    jmp $                       ; Infinite loop

MSG_DISK_ERROR: db 'disk ERROR!', 0x0D, 0x0A,0
MSG_DISK_READ_SUCCESS: db 'disk read SUCCESS', 0x0D, 0x0A, 0
