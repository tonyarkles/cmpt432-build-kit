/*
   Entry point for the 32-bit kernel.

   Based on example from http://osdever.net/tutorials/basickernel.php
*/
#include <segments.h>

.extern k_main
.global start
.text
.code32

start:
	# Need to get our segments in order
	movl $0x00000010, %eax	# Load up the KERNEL_DATA_SEG
	mov %ax, %ds
	mov %ax, %es
	mov %ax, %fs
	mov %ax, %gs
	# Plus we need a stack somewhere
	mov $0x001FFFFF, %esp
	mov %ax, %ss

	# Go to the C function for our main kernel (beats asm)
	call k_main

	# Only reach here when the kernel ends
	cli
	jmp .	# Use infinite loop instead of hlt because QEMU's console seems
			# to lock up when using hlt.
