#define LOAD_SEGMENT 0x0900
#define SECTOR_COUNT 0x70  /* 0x70 * 512 bytes = 56k might be enough */

.code16
.text

.globl start
start:
    /* set up all the segment registers to our segment */
    movw    %cs, %ax
    movw    %ax, %ds

    /* set up a stack */
    movw    $0x7c00, %ax
    movw    %ax, %ss
    movw    $0xFFFF, %sp

    /* init the string index */
    leaw txt_phase1, %si
    call display_message

    /* before loading from disk, fill the entire segment with 0xCC
     * which is the breakpoint interrupt
     */
    movw    $LOAD_SEGMENT, %ax
    movw    %ax, %es
    movw    $0x0000, %di
filler_loop:
    movb    $0xCC, %al
    stosb   /* assume that the EFLAGS is set s.t. DI increments */
    movw    %di, %bx
    jz      done_filling
    jmp     filler_loop

done_filling:

    /* load image from disk */
    movw    $0x0000, %bx
    movw    $LOAD_SEGMENT, %ax
    movw    %ax, %es
    movw    $SECTOR_COUNT, sector_count
    call    load_stage_2

    /* tell the user what we're doing */
    leaw    txt_phase2, %si
    call    display_message

	/* Jump to newly loaded kernel (still 16-bit) */
    ljmp    $0x0000, $(LOAD_SEGMENT*0x10)



display_message:
    /* protect what we're about to mangle */
    pushw   %bx
    pushw   %ax

    /* init the loop counter */
    movw    $0x0000, %bx
display_loop:
    lodsb
    andb    %al, %al
    jz      display_message_done
    movb    $0xe, %ah
    int     $0x10
    jmp display_loop

display_message_done:
    popw    %ax
    popw    %bx
    ret


load_stage_2:
    /* copy the #defined number of sectors from the floppy, starting at
       the #defined sector, into the memory at ES:BX */
    pushw   %cx
    pushw   %dx

    /* reset the floppy first */
    movb    $0x00, %ah
    movb    $0x00, %dl
    int     $0x13

	/* read disk */
    movb    $0x02, %ah 
    movb    $0x01, %al  /* only read 1 sector at a time */
    /* starting point is track 0 head 0 sector 2 */
    movw    $0x0002, %cx /* tttttttt ttssssss -> 0002 = track 0 sector 2 */ 
    movb    $0x00, %dh /* head 0 */
    movb    $0x00, %dl /* floppy drive A */

sector_read_loop:
    pushw   %ax

    /* see if we have any sectors left, and decrement if we do */
    movw    sector_count, %ax
    cmp     $0, %ax
    je      stage2_done     
    dec     %ax
    movw    %ax, sector_count
    popw    %ax

    movw    $0x0201, %ax

    /* perform the read */ 
    int     $0x13

    /* carry flag gets set on error */
    jc      read_err
    
    /* advance the buffer pointer */
    addw    $512, %bx
    
    /* advance our position on disk: try sector first, then head,
     * then cylinder
     */
    inc     %cl     /* sector */
    cmp     $18, %cl
    jle     sector_read_loop
    
    movb    $0x01, %cl
    inc     %dh /* increment the head */
    cmp     $2, %dh
    jl      sector_read_loop

    movb    $0x00, %dh
    inc     %ch /* increment the cylinder */
    jmp     sector_read_loop

read_err:
    jmp     . /* temporary to see registers after read */
    leaw    txt_floppy_err, %si
    call    display_message
	jmp		.

stage2_done:
    popw    %ax /* put the stack back where it was */
    popw    %dx
    popw    %cx
    ret

sector_count: .byte
txt_phase1: .asciz "NarfOS Bootloader\r\n"
txt_floppy_err: .asciz "Error reading from floppy\r\n"
txt_phase2: .asciz "Starting kernel\r\n"
txt_sector_ok: .asciz "Sector read ok\r\n"
/* Boot signature */
.org 510
.byte 0x55
.byte 0xAA
