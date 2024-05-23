[org 0x0600]
[bits 16]

start:
    cli                        ; Clear interrupts
    cld                        ; Clear direction flag

    ; Set up GDT
    lgdt [gdt_descriptor]

    ; Set PE (Protection Enable) bit in CR0 to enter protected mode
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; Far jump to clear the prefetch queue and enter protected mode
    jmp CODE_SEG:init_pm

[bits 32]

init_pm:
    ; Initialize data segments
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Initialize stack pointer
    mov ebp, 0x90000
    mov esp, ebp

    ; Print a message in protected mode (you need a function for this)
   
    mov ebx, MSG_PROT_MODE
    call print_string_pm
    
    ; Here we simply loop to halt the CPU
    jmp $

; GDT setup
gdt_begin:

gdt_null:
    dd 0x00                   ; Null descriptor (mandatory)
    dd 0x00

gdt_code:
    dw 0xffff                 ; Segment limit (low 16 bits)
    dw 0x0000                 ; Base address (low 16 bits)
    db 0x0                    ; Base address (next 8 bits)
    db 10011010b              ; Access byte
                              ;  1 0 0 1 1 0 1 0
                              ;  P DPL S Type (Code Segment, Executable, Readable)
                              ;  P = 1 (Segment Present)
                              ;  DPL = 00 (Privilege Level 0)
                              ;  S = 1 (Descriptor Type - Code/Data Segment)
                              ;  Type = 1010 (Code Segment, Executable, Readable)
    db 11001111b              ; Flags and limit (high 4 bits)
                              ;  G = 1 (4 KB Granularity)
                              ;  D = 1 (32-bit Protected Mode)
                              ;  0 (Always 0)
                              ;  A = 1 (Accessed)
                              ;  Limit (high 4 bits) = 1111
    db 0x0                    ; Base address (high 8 bits)

gdt_data:
    dw 0xffff                 ; Segment limit (low 16 bits)
    dw 0x0000                 ; Base address (low 16 bits)
    db 0x0                    ; Base address (next 8 bits)
    db 10010010b              ; Access byte
                              ;  1 0 0 1 0 0 1 0
                              ;  P DPL S Type (Data Segment, Writable)
                              ;  P = 1 (Segment Present)
                              ;  DPL = 00 (Privilege Level 0)
                              ;  S = 1 (Descriptor Type - Code/Data Segment)
                              ;  Type = 0010 (Data Segment, Writable)
    db 11001111b              ; Flags and limit (high 4 bits)
                              ;  G = 1 (4 KB Granularity)
                              ;  D = 1 (32-bit Protected Mode)
                              ;  0 (Always 0)
                              ;  A = 1 (Accessed)
                              ;  Limit (high 4 bits) = 1111
    db 0x0                    ; Base address (high 8 bits)

gdt_end:

; GDT descriptor
gdt_descriptor:
    dw gdt_end - gdt_begin - 1 ; Limit (size of GDT - 1)
    dd gdt_begin               ; Base address of the GDT

; Segment offsets within the GDT
CODE_SEG equ gdt_code - gdt_begin
DATA_SEG equ gdt_data - gdt_begin

%include "utils32/print.asm"

MSG_PROT_MODE:
    db 'Switched to prot mode', 0
