/* head.S - 16-bit code for initializing the environment and jumping into
   protected mode. */

.equ NULL_SEG,          0x00
.equ KERNEL_CODE_SEG,   0x08
.equ KERNEL_DATA_SEG,   0x10
.equ USER_CODE_SEG,     0x18
.equ USER_DATA_SEG,     0x20
.equ TSS_SEG,           0x28

.globl head
.globl gdt_ptr
.globl gdt_start
.globl tss_ptr
.globl e820_raw
.globl e820_counter

.extern start
.code16

head:
    # Data and Stack should be in the same segment as our Code
    mov %cs, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    # Get a safe starting value for the stack
    mov $0xF000, %sp

    # Load the first string into SI
    lea txt_starting, %si
    call println16

    # Copy the e820 map out (so that we know what memory we can use)
    call copy_e820

    lea txt_bouncing, %si
    call println16

    # Disable interrupts
    cli
    # Load the GDT
	lgdt gdt_ptr

    # Switch to protected mode
    mov %cr0, %eax
    or $0x01, %al
    mov %eax, %cr0
    # Now we need to do a long jump to clear the prefetch queue
    ljmp $KERNEL_CODE_SEG, $start

println16:
    /* Prints a line one character at a time using INT 10h, Service 0Eh
    Usage: DS:SI should point to the beginning of the string. */
    # Save registers
    pushf
    push %ax
    # Pick service 0Eh
_println16_loop:
    # Load the next byte
    lodsb
    # If we hit a null, stop
    or %al, %al
    jz _println16_finish
    # Write it and continue
    mov $0x0e, %ah
    int $0x10
    jmp _println16_loop
_println16_finish:
    # Reload registers
    pop %ax
    popf
    ret

    # this is implemented (good god) from the ACPI 2.0 spec
    # www.acpi.info
    # we're not distinguishing here which is good memory and bad memory,
    # that'll happen in the cartographer
copy_e820:
    pusha
    movl $0x0000e820, %eax
    movl $0x00000000, %ebx
    movl $0x00000020, %ecx
    movl $0x534d4150, %edx   # the string 'SMAP'
    
    lea  e820_raw, %di

e820_loop:
    int $0x15
    
    jc e820_done  # carry flag means we had an error
    
    cmpl $0x534d4150, %eax   # compare against smap
    jne e820_done
   

    incw (e820_counter)
	
	orl %ebx, %ebx 	 # zero continuation means we're done
	jz e820_done

    # move the pointer to the next entry in the e820 map
    movw %di, %ax
    addw $20, %ax
    movw %ax, %di

    lea txt_e820_read, %si
    call println16

    movl $0x0000e820, %eax
    # don't touch ebx, it contains the "continuation pointer"
    movl $0x00000020, %ecx
    movl $0x534d4150, %edx
    
    jmp e820_loop

e820_done:
    popa
    ret
    
.code32
gdt_ptr:
    .word gdt_end - gdt_start - 1 
gdt_start_ptr:
    .long gdt_start
gdt_start:
    # Null descriptor
    .word 0x0000, 0x0000, 0x0000, 0x0000
    # Kernel code segment
    .word 0xFFFF        # Limit 15:00
    .word 0x0000        # Base  15:00
    .byte 0x00          # Base  23:16
    .byte 0x9B          # Present, DPL=0, ERA Code Seg
    .byte 0xCF          # Large, 32-bit, Limit 19:16
    .byte 0x00          # Base  31:24
    # Kernel data segment
    .word 0xFFFF        # Limit 15:00
    .word 0x0000        # Base  15:00
    .byte 0x00          # Base  23:16
    .byte 0x93          # Present, DPL=0, WA Code Seg
    .byte 0xCF          # Large, 32-bit, Limit 19:16
    .byte 0x00          # Base  31:24
    # User code segment
    .word 0xFFFF        # Limit 15:00
    .word 0x0000        # Base  15:00
    .byte 0x00          # Base  23:16
    .byte 0xFB          # Present, DPL=3, ERA Code Seg
    .byte 0xCF          # Large, 32-bit, Limit 19:16
    .byte 0x00          # Base  31:24
    # User data segment
    .word 0xFFFF        # Limit 15:00
    .word 0x0000        # Base  15:00
    .byte 0x00          # Base  23:16
    .byte 0xF3          # Present, DPL=3, WA Code Seg
    .byte 0xCF          # Large, 32-bit, Limit 19:16
    .byte 0x00          # Base  31:24
    # TSS
tss_ptr:
    .word 0xFFFF        # Limit 15:00
    .word 0x0000        # Base  15:00
    .byte 0x00          # Base  23:16
    .byte 0x89          # Present, DPL=0, 32-bit TSS
    .byte 0x8F          # Big TSS, Limit 19:16
    .byte 0x00          # Base  31:24
gdt_end:

vid_mem_ptr: .long 0x000b8000
txt_starting: .asciz "Kernel in 16-bit mode\r\n"
txt_bouncing: .asciz "Enabling 32-bit mode\r\n"
txt_e820_read: .asciz "Reading e820 entry\r\n"

e820_counter: .word 0x0000
e820_raw: .fill 640, 1, 0  # allocate 640 bytes (not hex) for the e820 map
