[BITS 16]
[ORG 0x7C00]

start:
    cli                 ; Clear interrupts
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00      ; Set up stack

    ; Setup segment registers
    mov ax, 0x07C0
    mov ds, ax
    mov es, ax


;; READ KERNEL INTO MEMORY SECOND
    mov bl, 0           ; Will be reading 10 sectors
    mov di, 8000h       ; Memory address to read sectors into (0000h:2000h)

    mov dx, 1F6h        ; Head & drive # port
    mov al, [drive_num] ; Drive # - hard disk 1
    and al, 0Fh         ; Head # (low nibble)
    or al, 0A0h         ; default high nibble to 'primary' drive (drive 1), 'secondary' drive (drive 2) would be hex B or 1011b
    out dx, al          ; Send head/drive #

    mov dx, 1F2h        ; Sector count port
    mov al, 0Ah         ; # of sectors to read
    out dx, al

    mov dx, 1F3h        ; Sector # port
    mov al, 2           ; Sector to start reading at (sectors are 0-based!!)
    out dx, al

    mov dx, 1F4h        ; Cylinder low port
    xor al, al          ; Cylinder low #
    out dx, al

    mov dx, 1F5h        ; Cylinder high port
    xor al, al          ; Cylinder high #
    out dx, al

    mov dx, 1F7h        ; Command port (writing port 1F7h)
    mov al, 20h         ; Read with retry
    out dx, al

;; Poll status port after reading 1 sector
kernel_loop:
    in al, dx           ; Status register (reading port 1F7h)
    test al, 8          ; Sector buffer requires servicing
    je kernel_loop     ; Keep trying until sector buffer is ready

    mov cx, 256         ; # of words to read for 1 sector
    mov dx, 1F0h        ; Data port, reading 
    rep insw            ; Read bytes from DX port # into DI, CX # of times
    
    ;; 400ns delay - Read alternate status register
    mov dx, 3F6h
    in al, dx
    in al, dx
    in al, dx
    in al, dx

    cmp bl, 0
    je jump_to_kernel

    dec bl
    mov dx, 1F7h
    jmp kernel_loop

jump_to_kernel:

jmp 0:0x8000

jmp $

drive_num: db 0

times 510-($-$$) db 0   ; Pad the rest of the sector with zeros
dw 0xAA55               ; Boot signature
