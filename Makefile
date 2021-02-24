
include Make.definitions

all: floppyimg
# all: main.bin booter.boot floppyimg

_bootloader:
	cd bootloader && ${MAKE}

_kernel:
	cd kernel && ${MAKE}

floppyimg: _bootloader _kernel
	rm -f floppyimg
	dd if=/dev/zero of=floppyimg bs=1k count=1440
	dd if=bootloader/booter.boot of=floppyimg bs=512 count=1 conv=notrunc
	dd if=kernel/main.bin of=floppyimg bs=512 seek=1 conv=notrunc

clean:
	-(cd kernel/; make clean)
	-(cd bootloader/; make clean)
	rm -f floppyimg *.boot *.bin *.out *.o
