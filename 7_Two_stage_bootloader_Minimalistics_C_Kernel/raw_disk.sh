#!/bin/bash
rm -f build/disk.img
# dd if=build/boot/mbr.bin of=build/disk.img bs=512 count=1 conv=notrunc
# dd if=build/boot/loader.bin of=build/disk.img bs=512 count=5 seek=1 conv=notrunc
# dd if=build/kernel/kernel.bin of=build/disk.img bs=512 count=100 seek=6 conv=notrunc

# this addresses a bug in the qemu that fails to read data out of the disk.img
# if that terminates prematurely. In a real computer, this wouldn't be likely to
# happen as (assming that the usb stick used has a bigger capacity then the file copied),
# BIOS would read garbage from whatever happens to be on the subsequent blocks.
# truncate --io-blocks -s $(expr 512 \* 106) build/disk.img

dd if=stage1boot.bin of=build/disk.img bs=512 count=1 conv=notrunc
dd if=loader.bin of=build/disk.img bs=512 count=5 seek=1 conv=notrunc
dd if=kernel.bin of=build/disk.img bs=512 count=100 seek=6 conv=notrunc
truncate --io-blocks -s $(expr 512 \* 106) build/disk.img
