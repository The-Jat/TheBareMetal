[org 0x7c00]

start:
	KERNEL_OFFSET equ 0x1000
	
	; Bootloader starts here
	mov [BOOT_DISK], dl         ; Save the boot drive number

	mov bp, 0x8000 		; stack init
	mov sp, bp

	; Print a message
	mov bx, MSG_REAL_MODE
	call print_string
    
	call load_kernel

	jmp KERNEL_OFFSET	; jmp to the kernel

	jmp $


%include "utils16/print.asm"
%include "utils16/disk_load.asm"

[bits 16]
load_kernel:
    mov bx, MSG_KERNEL_LOAD
    call print_string

    mov bx, KERNEL_OFFSET	; Set BX to the kernel offset
    mov dh, 4 			; sectors count (number of sector to read.)
    mov dl, [BOOT_DISK]		; Load boot disk number
    call disk_load		; Call the disk loading function
    ret				; Return from the function

MSG_REAL_MODE:
    db 'Starting in real mode', 0x0D, 0x0A, 0
MSG_PROT_MODE:
    db 'Switched to prot mode', 0
MSG_KERNEL_LOAD:
    db 'Loading kernel from drive', 0x0D, 0x0A, 0

BOOT_DISK: db 0

times 510-($-$$) db 0    ; Pad the rest of the sector with zeros
dw 0xAA55                ; Boot sector signature
