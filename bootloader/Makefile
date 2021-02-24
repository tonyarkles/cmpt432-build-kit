
include ../Make.definitions

all: booter.boot

booter.boot: booter.o
	ld -melf_i386 -N -e start -Ttext $(BOOT_SEG) -o booter.out booter.o
	objcopy -S -O binary booter.out booter.boot

floppyimg: booter.boot main.bin
	rm -f floppyimg
	dd if=booter.boot of=floppyimg bs=512 count=1
	dd if=main.bin of=floppyimg bs=512 seek=1 conv=sync

clean:
	rm -f floppyimg *.boot *.bin *.out *.o booter.out booter.boot
