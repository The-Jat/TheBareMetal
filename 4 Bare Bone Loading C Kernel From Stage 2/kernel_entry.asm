[bits 32]
section .text
[extern kmain]
global _start

_start:
	cld
	call kmain

jmp $
