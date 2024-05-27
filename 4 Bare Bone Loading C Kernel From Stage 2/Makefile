# $@ = target file
# $< = first dependency
# $^ = all dependencies

# Define phony targets to avoid conflicts with files of the same name
.PHONY: all run clean

# Default target to build everything and run the OS image
all: run

# Rule to assemble the stage1boot.asm file into a binary file stage1boot.bin
stage1boot.bin: stage1boot.asm
	nasm $< -f bin -o $@

stage2boot.bin: stage2boot.asm
	nasm $< -f bin -o $@

kernel_entry.o: kernel_entry.asm
	nasm $< -f elf -o $@

kernel.o: kernel.c
	gcc -ffreestanding -m32 -fno-pie -c $< -o $@

kernel.bin: kernel_entry.o kernel.o
	ld -o $@ -T linker.ld -m elf_i386 $^

os-image.bin: stage1boot.bin stage2boot.bin kernel.bin
	# cat stage1boot.bin stage2boot.bin kernel.bin > os-image.bin
	dd if=/dev/zero of=floppy.img bs=512 count=2880
	dd if=stage1boot.bin of=floppy.img bs=512 count=1 conv=notrunc
	dd if=stage2boot.bin of=floppy.img bs=512 seek=1 count=1 conv=notrunc
	dd if=kernel.bin of=floppy.img bs=512 count=10 seek=2 conv=notrunc

# Rule to run the OS image using QEMU
run: os-image.bin
	# qemu-system-x86_64 -drive format=raw,file=os-image.bin
	# qemu-system-x86_64 -fda os-image.bin
	qemu-system-x86_64 -fda floppy.img

# Clean up generated files
clean:
	rm -rf *.bin *.o *.img
