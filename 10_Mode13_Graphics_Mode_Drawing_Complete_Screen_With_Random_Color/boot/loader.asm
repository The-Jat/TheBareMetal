[BITS 16]
[ORG 0x7E00]
; Produce a map file containing all symbols and sections.
[map all loader.map]

;===============================================================================
; loader
;
; Second-stage boot loader entry point
;
; Due to the limited size of the first-stage boot loader, its only mission in
; life is to load the Second-stage boot leader. The second-stage boot loader is
; responsible for essentially preparing the system to enter into the protected
; mode.
;
; Input registers:
;
;   DL      Boot drive number
;
; Memory layout before this code starts running:
;
;   00000000 - 000003ff        1,024 bytes     Real mode IVT
;   00000400 - 000004ff          256 bytes     BIOS data area
;   00000500 - 00007bff       30,464 bytes     Free
;   00007c00 - 00007dff          512 bytes     First-stage boot loader (MBR)
;   00007e00 - 0009fbff      622,080 bytes     Free -> We are here now
;   0009fc00 - 0009ffff        1,024 bytes     Extended BIOS data area (EBDA)
;   000a0000 - 000bffff      131,072 bytes     BIOS video memory
;   000c0000 - 000fffff      262,144 bytes     ROM
;===============================================================================

; jump to start procedure
jmp start

; Include functions/constants that are useful in real mode
%include "include/const.asm"
%include "include/mem.asm"
%include "include/gdt.asm"
%include "include/realmode.asm"
%include "include/second_stage_loader.asm"
%include "include/display.asm" ; switch mode and displaying graphics


start:

  ; Proper initialisation of stack during BIOS bootloader
  ;   https://stackoverflow.com/a/33975465/832748
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov bx, Loader.Mem.Stack.Top

  ; Turn off interrupts for SS:SP update to avoid a problem with buggy 8088 CPUs
  cli
  ; SS = 0x0000
  mov ss, ax
  ; SP = 0x7c00
  ; Set the stack starting just below where the bootloader is at 0x0:0x7c00.
  mov sp, bx
  ; Turn interrupts back on
  sti

boot:
  ; Save DriveId for later
  mov [BIOS.Drive.Id], dl

  ; Print booting message
  mov si, Realmode.SecondStage.Booting.Msg
  call display_string

  ; Attempt to enable the A20 line if necessary.
  call enable_A20

  ; Check whether we are running on a 64-bit processor
  call cpu_supports_64_bit_mode
  

	call switch_to_graphics_mode13

	mov ax, 10	; x-coordinate
	mov bx, 10	; y-coordinate
	mov cl, 0x7	; color (8 bit)

	call draw_pixel
	

	
;jmp $
  ; Prepare to enter protected mode
  call enter_protected_mode

  ; enter a endless loop. This instruction should never be reached
  jmp endless_loop


[BITS 32]

; Include Constants/Variables/routines useful in protected mode
%include "include/protectedmode.asm"
%include "include/display32.asm"

string_to_print db 'The JAT', 0   ; String to print, null-terminated

protected_mode_boot:

; Accoring to Intel 64 manual
; Section: 9.9.1 Switching to Protected Mode
;
;   9. After entering protected mode, the segment registers continue to hold the
;      contents they had in real-address mode. The JMP or CALL instruction in
;     step 4 resets the CS register. Perform one of the following operations to
;     update the contents of the remaining segment registers.
;
;     — Reload segment registers DS, SS, ES, FS, and GS.
;       If the ES, FS, and/or GS registers are not going to be used,
;       load them with a null selector.

  ; 0x10 = 16 which points to the GDT Data Segment (and the right DPL too)
  mov ax, 0x10
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov esp, 0x90000;Loader.Mem.Stack.Top


  ; 10. Execute the LIDT instruction to load the IDTR register with the address
  ;   and limit of the protected-mode IDT.
  lidt [IDT32.Table.Pointer]

  ; 11. Execute the STI instruction to enable maskable hardware interrupts and
  ;   perform the necessary hardware operation to enable NMI interrupts.
;  sti

	mov al, 13	; color to fill the screen
	call clear_screen

	; Fill the screen with the random color pixel
	call fill_screen_with_random_colors

jmp $

;	ax = y coordinate
;	bx = x coordinate
;	cl = color

	mov eax, '~'	; character to print
	mov ebx, 10	; x
	mov ecx, 15	; y
	mov edx, 4	; color
	call draw_Char

; Call print_string with the string to print, x position, y position, and color
	mov esi, string_to_print  ; ESI points to the string
	mov ebx, 100               ; X position
	mov ecx, 100               ; Y position
	mov edx, 13			; Color = light magenta
	call print_string

; infinite loop
;jmp $

  ; fix video text printing
  call pm_retrive_video_cursor_settings

  ; display status message
 ; mov eax, ProtectedMode.SecondStage.Booting.Msg
 ; call pm_display_string

  ; copy kernel to the right location
  call pm_move_kernel
  ; Setup paging
  call pm_setup_page_tables

  ; Enter Long monde (finally!)
  call pm_enter_long_mode

  ; enter a endless loop. This instruction should never be reached
  jmp pm_endless_loop


[BITS 64]

; Include Constants/Variables/routines useful in protected mode
%include "include/longmode.asm"

;-------------------------------------------------------------------------
; Launch the 64-bit kernel
;-------------------------------------------------------------------------
long_mode_boot:
    ; It is very important that you don't enable the interrupts (unless you have set up a 64-bit IDT of course).

    ; 0x10 = 16 which points to the GDT Data Segment (and the right DPL too)
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov rsp, Loader.Mem.Stack.Top

    ; display status message
;    mov rax, LongMode.SecondStage.Booting.Msg
;    call lm_display_string

    ; jump to memory address in which the kernel should be (fingers crossed)
    jmp Kernel.New.Start.Address
jmp $
    ; enter a endless loop. This instruction should never be reached
    jmp lm_endless_loop

    ;TODOS:
    ; -> lm_display_string -> Try to make use of 64 bit registers where possible
    ; -> lm_set_cursor -> Try to make use of 64 bit registers where possible
    ; -> pm_setup_page_tables -> You still have a few questions about the 4kb pages format bits (LeftShift remember?)
    ; -> ProtectedMode.asm -> Please refactor this a bit...this looks like a mess
    ; -> Display string -> refactor this function to allow the OS tag name to be stored just once.. no biggie, but relevant


; On physical devices this isn't required because the BIOS will
; pull the x number of blocks regardless of their content, however,
; if you are using QEMU and a raw image, it will strugle to Read
; the BIOS Disk Access Packet (DAP ) because the file finishes
; way earlier than the number of blocks requested.
times (Loader.File.NumberOfBlocks * 512) - ($ - $$) db 0
