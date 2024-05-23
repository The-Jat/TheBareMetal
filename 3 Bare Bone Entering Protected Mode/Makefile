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


kernel.bin: kernel.asm

	nasm $< -f bin -o $@

os-image.bin: stage1boot.bin kernel.bin
	cat stage1boot.bin kernel.bin > os-image.bin

# Rule to run the OS image using QEMU
run: os-image.bin
	qemu-system-x86_64 -drive format=raw,file=os-image.bin

# Clean up generated files
clean:
	rm -rf *.bin *.o
