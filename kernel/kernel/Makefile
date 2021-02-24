
include ../../Make.definitions

MAIN_OBJS = head.o kernel_start.o main.o 

ASFLAGS=-I ../include -m32
CFLAGS+=-I ../include -fno-stack-protector -m32

all: main.bin

main.bin: $(MAIN_OBJS)

clean:
	rm -f floppyimg *.boot *.bin *.out *.o
