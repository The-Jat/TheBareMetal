# $@ = target file
# $< = first dependency
# $^ = all dependencies

all: run

kernel.bin: kernel_entry.o kernel.o
	ld -m elf_i386 -o $@ -T linker.ld $^ --oformat binary

kernel_entry.o: kernel_entry.asm
	nasm $< -f elf32 -o $@

kernel.o: kernel/kernel.c
	gcc -m32 -ffreestanding -fno-pie -c $< -o $@

debug/kernel.dis: kernel.bin
	ndisasm -b 32 $< > $@

stage1boot.bin: stage1boot.asm
	nasm $< -f bin -o $@

os-image.bin: stage1boot.bin kernel.bin
	cat $^ > $@

run: os-image.bin
	qemu-system-x86_64 -drive format=raw,file=$< -d guest_errors -d int -no-reboot -no-shutdown
	# qemu-system-x86_64 -fda $<

clean:
	rm -rf *.bin *.o debug/*.dis
