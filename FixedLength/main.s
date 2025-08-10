	.file	"main.cc"
	.text
	.section	.rodata._ZNSt6vectorIP8TreeNodeSaIS1_EE7reserveEm.str1.1,"aMS",@progbits,1
.LC0:
	.string	"vector::reserve"
	.section	.text._ZNSt6vectorIP8TreeNodeSaIS1_EE7reserveEm,"axG",@progbits,_ZNSt6vectorIP8TreeNodeSaIS1_EE7reserveEm,comdat
	.align 2
	.p2align 4,,15
	.weak	_ZNSt6vectorIP8TreeNodeSaIS1_EE7reserveEm
	.type	_ZNSt6vectorIP8TreeNodeSaIS1_EE7reserveEm, @function
_ZNSt6vectorIP8TreeNodeSaIS1_EE7reserveEm:
.LFB2463:
	.cfi_startproc
	movabsq	$2305843009213693951, %rax
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$24, %rsp
	.cfi_def_cfa_offset 80
	cmpq	%rax, %rsi
	ja	.L13
	movq	(%rdi), %rbp
	movq	16(%rdi), %rax
	movq	%rdi, %rbx
	subq	%rbp, %rax
	sarq	$3, %rax
	cmpq	%rsi, %rax
	jb	.L14
	addq	$24, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L14:
	.cfi_restore_state
	movq	8(%rdi), %r15
	leaq	0(,%rsi,8), %r14
	movq	%r15, %r13
	subq	%rbp, %r13
	testq	%rsi, %rsi
	je	.L7
	movq	%r14, %rdi
	call	_Znwm
	movq	(%rbx), %rcx
	movq	%rax, %r12
.L4:
	cmpq	%r15, %rbp
	je	.L5
	movq	%r13, %rdx
	movq	%rbp, %rsi
	movq	%r12, %rdi
	movq	%rcx, 8(%rsp)
	call	memmove
	movq	8(%rsp), %rcx
.L5:
	testq	%rcx, %rcx
	je	.L6
	movq	%rcx, %rdi
	call	_ZdlPv
.L6:
	movq	%r12, (%rbx)
	addq	%r12, %r13
	addq	%r14, %r12
	movq	%r13, 8(%rbx)
	movq	%r12, 16(%rbx)
	addq	$24, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L7:
	.cfi_restore_state
	movq	%rbp, %rcx
	xorl	%r12d, %r12d
	jmp	.L4
.L13:
	movl	$.LC0, %edi
	call	_ZSt20__throw_length_errorPKc
	.cfi_endproc
.LFE2463:
	.size	_ZNSt6vectorIP8TreeNodeSaIS1_EE7reserveEm, .-_ZNSt6vectorIP8TreeNodeSaIS1_EE7reserveEm
	.section	.text._ZNSt6vectorIP8TreeNodeSaIS1_EE17_M_realloc_insertIJS1_EEEvN9__gnu_cxx17__normal_iteratorIPS1_S3_EEDpOT_,"axG",@progbits,_ZNSt6vectorIP8TreeNodeSaIS1_EE17_M_realloc_insertIJS1_EEEvN9__gnu_cxx17__normal_iteratorIPS1_S3_EEDpOT_,comdat
	.align 2
	.p2align 4,,15
	.weak	_ZNSt6vectorIP8TreeNodeSaIS1_EE17_M_realloc_insertIJS1_EEEvN9__gnu_cxx17__normal_iteratorIPS1_S3_EEDpOT_
	.type	_ZNSt6vectorIP8TreeNodeSaIS1_EE17_M_realloc_insertIJS1_EEEvN9__gnu_cxx17__normal_iteratorIPS1_S3_EEDpOT_, @function
_ZNSt6vectorIP8TreeNodeSaIS1_EE17_M_realloc_insertIJS1_EEEvN9__gnu_cxx17__normal_iteratorIPS1_S3_EEDpOT_:
.LFB2623:
	.cfi_startproc
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	movq	%rdx, %r15
	movq	%rsi, %rdx
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	movq	%rsi, %r12
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	movq	%rdi, %rbx
	subq	$40, %rsp
	.cfi_def_cfa_offset 96
	movq	8(%rdi), %rcx
	movq	(%rdi), %rbp
	movq	%rcx, %rax
	subq	%rbp, %rdx
	subq	%rbp, %rax
	sarq	$3, %rax
	je	.L24
	leaq	(%rax,%rax), %rdi
	movq	$-8, %r14
	cmpq	%rdi, %rax
	jbe	.L30
.L17:
	movq	%r14, %rdi
	movq	%rdx, 16(%rsp)
	movq	%rcx, 8(%rsp)
	call	_Znwm
	movq	16(%rsp), %rdx
	movq	8(%rsp), %rcx
	movq	%rax, %r13
	addq	%rax, %r14
.L18:
	movq	(%r15), %rax
	movq	%rcx, %r8
	leaq	8(%r13,%rdx), %r9
	subq	%r12, %r8
	movq	%rax, 0(%r13,%rdx)
	leaq	(%r9,%r8), %r15
	cmpq	%rbp, %r12
	je	.L19
	movq	%rbp, %rsi
	movq	%r13, %rdi
	movq	%r9, 24(%rsp)
	movq	%r8, 16(%rsp)
	movq	%rcx, 8(%rsp)
	call	memmove
	movq	8(%rsp), %rcx
	movq	16(%rsp), %r8
	movq	24(%rsp), %r9
	cmpq	%rcx, %r12
	je	.L23
.L20:
	movq	%r8, %rdx
	movq	%r12, %rsi
	movq	%r9, %rdi
	call	memcpy
.L22:
	testq	%rbp, %rbp
	jne	.L23
.L21:
	movq	%r13, (%rbx)
	movq	%r15, 8(%rbx)
	movq	%r14, 16(%rbx)
	addq	$40, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L23:
	.cfi_restore_state
	movq	%rbp, %rdi
	call	_ZdlPv
	jmp	.L21
	.p2align 4,,10
	.p2align 3
.L30:
	movabsq	$2305843009213693951, %rax
	cmpq	%rax, %rdi
	ja	.L17
	xorl	%r14d, %r14d
	xorl	%r13d, %r13d
	testq	%rdi, %rdi
	je	.L18
	jmp	.L16
	.p2align 4,,10
	.p2align 3
.L19:
	cmpq	%rcx, %r12
	jne	.L20
	jmp	.L22
	.p2align 4,,10
	.p2align 3
.L24:
	movl	$1, %edi
.L16:
	leaq	0(,%rdi,8), %r14
	jmp	.L17
	.cfi_endproc
.LFE2623:
	.size	_ZNSt6vectorIP8TreeNodeSaIS1_EE17_M_realloc_insertIJS1_EEEvN9__gnu_cxx17__normal_iteratorIPS1_S3_EEDpOT_, .-_ZNSt6vectorIP8TreeNodeSaIS1_EE17_M_realloc_insertIJS1_EEEvN9__gnu_cxx17__normal_iteratorIPS1_S3_EEDpOT_
	.section	.text._ZNSt6vectorIP8TreeNodeSaIS1_EE12emplace_backIJS1_EEEvDpOT_,"axG",@progbits,_ZNSt6vectorIP8TreeNodeSaIS1_EE12emplace_backIJS1_EEEvDpOT_,comdat
	.align 2
	.p2align 4,,15
	.weak	_ZNSt6vectorIP8TreeNodeSaIS1_EE12emplace_backIJS1_EEEvDpOT_
	.type	_ZNSt6vectorIP8TreeNodeSaIS1_EE12emplace_backIJS1_EEEvDpOT_, @function
_ZNSt6vectorIP8TreeNodeSaIS1_EE12emplace_backIJS1_EEEvDpOT_:
.LFB2573:
	.cfi_startproc
	movq	8(%rdi), %rax
	cmpq	16(%rdi), %rax
	je	.L32
	movq	(%rsi), %rdx
	addq	$8, %rax
	movq	%rdx, -8(%rax)
	movq	%rax, 8(%rdi)
	ret
	.p2align 4,,10
	.p2align 3
.L32:
	movq	%rsi, %rdx
	movq	%rax, %rsi
	jmp	_ZNSt6vectorIP8TreeNodeSaIS1_EE17_M_realloc_insertIJS1_EEEvN9__gnu_cxx17__normal_iteratorIPS1_S3_EEDpOT_
	.cfi_endproc
.LFE2573:
	.size	_ZNSt6vectorIP8TreeNodeSaIS1_EE12emplace_backIJS1_EEEvDpOT_, .-_ZNSt6vectorIP8TreeNodeSaIS1_EE12emplace_backIJS1_EEEvDpOT_
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	"new cost time:"
.LC2:
	.string	" us\n"
.LC3:
	.string	"object pool cost time:"
	.section	.text.unlikely,"ax",@progbits
.LCOLDB4:
	.text
.LHOTB4:
	.p2align 4,,15
	.globl	_Z14TestObjectPoolv
	.type	_Z14TestObjectPoolv, @function
_Z14TestObjectPoolv:
.LFB2182:
	.cfi_startproc
	.cfi_personality 0x3,__gxx_personality_v0
	.cfi_lsda 0x3,.LLSDA2182
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$104, %rsp
	.cfi_def_cfa_offset 160
	call	_ZNSt6chrono3_V212system_clock3nowEv
	movl	$100000, %esi
	leaq	32(%rsp), %rdi
	movq	$0, 32(%rsp)
	movq	%rax, (%rsp)
	movq	$0, 40(%rsp)
	movq	$0, 48(%rsp)
.LEHB0:
	call	_ZNSt6vectorIP8TreeNodeSaIS1_EE7reserveEm
	movl	$3, %ebp
.L39:
	movl	$100000, %ebx
	.p2align 4,,10
	.p2align 3
.L36:
	movl	$24, %edi
	call	_Znwm
	movl	$0, (%rax)
	leaq	64(%rsp), %rsi
	leaq	32(%rsp), %rdi
	movq	$0, 8(%rax)
	movq	$0, 16(%rax)
	movq	%rax, 64(%rsp)
	call	_ZNSt6vectorIP8TreeNodeSaIS1_EE12emplace_backIJS1_EEEvDpOT_
.LEHE0:
	subl	$1, %ebx
	jne	.L36
	xorl	%ebx, %ebx
	.p2align 4,,10
	.p2align 3
.L37:
	movq	32(%rsp), %rax
	movl	$24, %esi
	movq	(%rax,%rbx), %rdi
	addq	$8, %rbx
	call	_ZdlPvm
	cmpq	$800000, %rbx
	jne	.L37
	movq	32(%rsp), %rax
	cmpq	40(%rsp), %rax
	je	.L38
	movq	%rax, 40(%rsp)
.L38:
	subq	$1, %rbp
	jne	.L39
	call	_ZNSt6chrono3_V212system_clock3nowEv
	movq	%rax, %r15
	call	_ZNSt6chrono3_V212system_clock3nowEv
	movl	$100000, %esi
	leaq	64(%rsp), %rdi
	movq	$0, 64(%rsp)
	movq	%rax, 8(%rsp)
	movq	$0, 72(%rsp)
	movq	$0, 80(%rsp)
.LEHB1:
	call	_ZNSt6vectorIP8TreeNodeSaIS1_EE7reserveEm
	xorl	%r12d, %r12d
	movl	$3, %r14d
	xorl	%ebx, %ebx
	xorl	%r13d, %r13d
.L48:
	movl	$100000, %ebp
	jmp	.L44
	.p2align 4,,10
	.p2align 3
.L81:
	movq	%rbx, %rax
	movq	(%rbx), %rbx
.L41:
	movl	$0, (%rax)
	leaq	24(%rsp), %rsi
	leaq	64(%rsp), %rdi
	movq	$0, 8(%rax)
	movq	$0, 16(%rax)
	movq	%rax, 24(%rsp)
	call	_ZNSt6vectorIP8TreeNodeSaIS1_EE12emplace_backIJS1_EEEvDpOT_
	subl	$1, %ebp
	je	.L80
.L44:
	testq	%rbx, %rbx
	jne	.L81
	cmpq	$23, %r12
	jbe	.L82
	subq	$24, %r12
	movq	%r13, %rax
.L43:
	leaq	24(%rax), %r13
	jmp	.L41
	.p2align 4,,10
	.p2align 3
.L82:
	movl	$131072, %edi
	call	malloc
	testq	%rax, %rax
	je	.L83
	movl	$131048, %r12d
	jmp	.L43
.L80:
	movq	64(%rsp), %rcx
	xorl	%eax, %eax
	.p2align 4,,10
	.p2align 3
.L46:
	movq	(%rcx,%rax), %rdx
	testq	%rdx, %rdx
	je	.L45
	movq	%rbx, (%rdx)
	movq	64(%rsp), %rcx
	movq	%rdx, %rbx
.L45:
	addq	$8, %rax
	cmpq	$800000, %rax
	jne	.L46
	cmpq	%rcx, 72(%rsp)
	je	.L47
	movq	%rcx, 72(%rsp)
.L47:
	subq	$1, %r14
	jne	.L48
	call	_ZNSt6chrono3_V212system_clock3nowEv
	movl	$14, %edx
	movl	$.LC1, %esi
	movl	$_ZSt4cout, %edi
	movq	%rax, %rbx
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	subq	(%rsp), %r15
	movl	$_ZSt4cout, %edi
	movabsq	$2361183241434822607, %rdx
	movq	%r15, %rax
	sarq	$63, %r15
	imulq	%rdx
	sarq	$7, %rdx
	subq	%r15, %rdx
	movq	%rdx, %rsi
	call	_ZNSo9_M_insertIlEERSoT_
	movl	$4, %edx
	movl	$.LC2, %esi
	movq	%rax, %rdi
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	movl	$22, %edx
	movl	$.LC3, %esi
	movl	$_ZSt4cout, %edi
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	subq	8(%rsp), %rbx
	movl	$_ZSt4cout, %edi
	movabsq	$2361183241434822607, %rdx
	movq	%rbx, %rax
	sarq	$63, %rbx
	imulq	%rdx
	sarq	$7, %rdx
	subq	%rbx, %rdx
	movq	%rdx, %rsi
	call	_ZNSo9_M_insertIlEERSoT_
	movl	$4, %edx
	movl	$.LC2, %esi
	movq	%rax, %rdi
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l
	movq	64(%rsp), %rdi
	testq	%rdi, %rdi
	je	.L49
	call	_ZdlPv
.L49:
	movq	32(%rsp), %rdi
	testq	%rdi, %rdi
	je	.L35
	call	_ZdlPv
.L35:
	addq	$104, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
.L83:
	.cfi_restore_state
	movl	$8, %edi
	call	__cxa_allocate_exception
	movl	$_ZNSt9bad_allocD1Ev, %edx
	movl	$_ZTISt9bad_alloc, %esi
	movq	$_ZTVSt9bad_alloc+16, (%rax)
	movq	%rax, %rdi
	call	__cxa_throw
.LEHE1:
.L57:
	movq	%rax, %rbx
	jmp	.L51
.L56:
	movq	%rax, %rbx
	jmp	.L53
	.globl	__gxx_personality_v0
	.section	.gcc_except_table,"a",@progbits
.LLSDA2182:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE2182-.LLSDACSB2182
.LLSDACSB2182:
	.uleb128 .LEHB0-.LFB2182
	.uleb128 .LEHE0-.LEHB0
	.uleb128 .L56-.LFB2182
	.uleb128 0
	.uleb128 .LEHB1-.LFB2182
	.uleb128 .LEHE1-.LEHB1
	.uleb128 .L57-.LFB2182
	.uleb128 0
.LLSDACSE2182:
	.text
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x3,__gxx_personality_v0
	.cfi_lsda 0x3,.LLSDAC2182
	.type	_Z14TestObjectPoolv.cold.31, @function
_Z14TestObjectPoolv.cold.31:
.LFSB2182:
.L51:
	.cfi_def_cfa_offset 160
	.cfi_offset 3, -56
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	movq	64(%rsp), %rdi
	testq	%rdi, %rdi
	je	.L53
	call	_ZdlPv
.L53:
	movq	32(%rsp), %rdi
	testq	%rdi, %rdi
	je	.L54
	call	_ZdlPv
.L54:
	movq	%rbx, %rdi
.LEHB2:
	call	_Unwind_Resume
.LEHE2:
	.cfi_endproc
.LFE2182:
	.section	.gcc_except_table
.LLSDAC2182:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSEC2182-.LLSDACSBC2182
.LLSDACSBC2182:
	.uleb128 .LEHB2-.LCOLDB4
	.uleb128 .LEHE2-.LEHB2
	.uleb128 0
	.uleb128 0
.LLSDACSEC2182:
	.section	.text.unlikely
	.text
	.size	_Z14TestObjectPoolv, .-_Z14TestObjectPoolv
	.section	.text.unlikely
	.size	_Z14TestObjectPoolv.cold.31, .-_Z14TestObjectPoolv.cold.31
.LCOLDE4:
	.text
.LHOTE4:
	.section	.text.startup,"ax",@progbits
	.p2align 4,,15
	.globl	main
	.type	main, @function
main:
.LFB2194:
	.cfi_startproc
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	call	_Z14TestObjectPoolv
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE2194:
	.size	main, .-main
	.p2align 4,,15
	.type	_GLOBAL__sub_I__Z14TestObjectPoolv, @function
_GLOBAL__sub_I__Z14TestObjectPoolv:
.LFB2717:
	.cfi_startproc
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movl	$_ZStL8__ioinit, %edi
	call	_ZNSt8ios_base4InitC1Ev
	movl	$__dso_handle, %edx
	movl	$_ZStL8__ioinit, %esi
	movl	$_ZNSt8ios_base4InitD1Ev, %edi
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	jmp	__cxa_atexit
	.cfi_endproc
.LFE2717:
	.size	_GLOBAL__sub_I__Z14TestObjectPoolv, .-_GLOBAL__sub_I__Z14TestObjectPoolv
	.section	.init_array,"aw"
	.align 8
	.quad	_GLOBAL__sub_I__Z14TestObjectPoolv
	.local	_ZStL8__ioinit
	.comm	_ZStL8__ioinit,1,1
	.hidden	__dso_handle
	.ident	"GCC: (GNU) 8.3.1 20190311 (Red Hat 8.3.1-3)"
	.section	.note.GNU-stack,"",@progbits
