
include ../Make.definitions

# The linker needs kernel/head.o to be the first file linked in,
# no exceptions.  Here's a little hack to get in all the .o files
# but keep kernel/head.o as the first one.
ALL_OBJS=kernel/head.o `find -name '*.o' | grep -v kernel/head.o`

all: _kernel 
	ld -melf_i386 -N -e head -Ttext $(KERNEL_START) -o main.out $(ALL_OBJS) 
	objcopy -S -O binary main.out main.bin

_kernel:
	cd kernel && ${MAKE}

clean:
	cd kernel && ${MAKE} clean


