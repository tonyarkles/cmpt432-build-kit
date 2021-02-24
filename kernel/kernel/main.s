	.file	"main.c"
	.text
.globl printk_bootstrap
	.type	printk_bootstrap, @function
printk_bootstrap:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	movq	%rsp, %rbp
	.cfi_offset 6, -16
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)
	movl	$0, -12(%rbp)
	movq	$753664, -8(%rbp)
	movl	-12(%rbp), %eax
	cltq
	addq	-24(%rbp), %rax
	movzbl	(%rax), %eax
	testb	%al, %al
	je	.L4
	movl	-12(%rbp), %eax
	cltq
	addq	-24(%rbp), %rax
	movzbl	(%rax), %edx
	movq	-8(%rbp), %rax
	movb	%dl, (%rax)
	movq	-8(%rbp), %rax
	addq	$1, %rax
	movb	$31, (%rax)
.L3:
	jmp	.L3
.L4:
	leave
	ret
	.cfi_endproc
.LFE0:
	.size	printk_bootstrap, .-printk_bootstrap
	.section	.rodata
.LC0:
	.string	"Hello from k_main"
	.text
.globl k_main
	.type	k_main, @function
k_main:
.LFB1:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	movq	%rsp, %rbp
	.cfi_offset 6, -16
	.cfi_def_cfa_register 6
	movl	$.LC0, %edi
	call	printk_bootstrap
.L6:
	jmp	.L6
	.cfi_endproc
.LFE1:
	.size	k_main, .-k_main
	.ident	"GCC: (GNU) 4.4.3"
	.section	.note.GNU-stack,"",@progbits
