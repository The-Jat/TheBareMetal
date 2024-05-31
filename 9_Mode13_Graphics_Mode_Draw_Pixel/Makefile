# $@ = target file
# $< = first dependency
# $^ = all dependencies

# Notes:
# 	- gnu99 is used instead of c99 so we can use the GCC inline assembly extensions
CCFLAGS     := -std=c99 -Qn -g \
		   				-m64 -mno-red-zone -mno-mmx -masm=intel \
		   				-ffreestanding -fno-asynchronous-unwind-tables \
		   				-Wall -Wextra -Wpedantic -mcmodel=small

LDFLAGS     := -nostdlib  -z max-page-size=0x1000

# Define phony targets to avoid conflicts with files of the same name
.PHONY: all run clean

# Default target to build everything and run the OS image
all: run

# Rule to assemble the stage1boot.asm file into a binary file stage1boot.bin
stage1boot.bin: boot/stage1boot.asm
	nasm -i boot $< -f bin -o $@

loader.bin: boot/loader.asm
	nasm -i boot $< -f bin -o $@

start.o: kernel/start.asm
	nasm -i boot $< -f elf64 -o $@

vga.o: kernel/vga.c
	gcc  $(CCFLAGS) -c $< -o $@

kernel.o: kernel/kernel.c
	gcc  $(CCFLAGS) -c $< -o $@

kernel.obj: kernel.o start.o vga.o
	ld  $(LDFLAGS) -o $@ -T linker.ld $^ #--oformat binary

kernel.bin: kernel.obj
	objcopy -O binary kernel.obj kernel.bin

os-image.bin: stage1boot.bin loader.bin kernel.bin
	# bash raw_disk.sh
	cat stage1boot.bin loader.bin kernel.bin > os-image.bin
	# dd if=stage1boot.bin of=build/disk.img bs=512 count=1 conv=notrunc
	# dd if=loader.bin of=build/disk.img bs=512 count=5 seek=1 conv=notrunc
	# dd if=kernel.bin of=build/disk.img bs=512 count=100 seek=6 conv=notrunc
	# truncate --io-blocks -s $(expr 512 \* 106) build/disk.img
	# stage1boot.bin loader.bin
	# cat stage1boot.bin loader.bin > os-image.bin
	# dd if=/dev/zero of=floppy.img bs=512 count=2880
	# dd if=stage1boot.bin of=floppy.img bs=512 count=1 conv=notrunc
	# dd if=kernel.bin of=floppy.img bs=512 seek=1 count=1 conv=notrunc
	# dd if=kernel.bin of=floppy.img bs=512 seek=2 conv=notrunc

# Rule to run the OS image using QEMU
run: os-image.bin
	qemu-system-x86_64 -drive format=raw,file=os-image.bin
	# qemu-system-x86_64 -fda os-image.bin
	#qemu-system-x86_64 -drive format=raw,file=build/disk.img

# Clean up generated files
clean:
	rm -rf *.bin *.o *.obj *.img build/*.img build/*
