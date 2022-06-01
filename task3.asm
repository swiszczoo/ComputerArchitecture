# Computer Architecture - Task 3
# ISA: MIPS32

.eqv STACK_SIZE 1024

.data
global_array: 	.word 	1,2,3,4,5,6,7,8,9,10
sys_stack_addr: 	.word 	0
stack:		.space	STACK_SIZE

.text
.globl __start
__start:
	sw	$sp, 	sys_stack_addr
	la	$sp, 	stack + STACK_SIZE
	
main:
	# void main()
	# {
	#   int s;
	#   s = sum( global_array, 10 );
	#   print( s );
	#   return;
	# }

	# local variables offsets:
	#   s - 0x00
	subi	$sp,	$sp,	4	# allocate local variables (4 bytes)
	
	# s = sum( global_array, 10 );
	subi	$sp,	$sp,	8
	la	$t0,	global_array
	sw	$t0,	0x04($sp)	# save 1st arg of sum
	li	$t0,	10
	sw	$t0,	0x00($sp)	# save 2nd arg of sum
	jal	sum
	lw	$t0,	0x00($sp)	# load return value
	sw	$t0,	0x0c($sp)	# store return value in $t0
	addi	$sp,	$sp,	12	# remove 2 arguments + 1 return value
	
	# print ( s );
	subi	$sp,	$sp,	4
	lw	$t0,	0x04($sp)	# load s
	sw	$t0,	0x00($sp)	# save first argument of print
	jal	print
	addi	$sp,	$sp,	4	# remove argument from stack
	
	addi	$sp,	$sp,	4	# deallocate local variables (4 bytes)
	
__finalize:
	lw	$sp,	sys_stack_addr
	
	li	$v0,	10
	syscall
	
sum:
	# int sum ( int *array, int array_size )
	#   // notacja int *array oznacza przekazanie do funkcji
	#   // adresu poczatku tablicy array
	# {
	#   int i;
	#   int s;
	#
	#   s = 0;
	#   i = array_size - 1;
	#   while ( i > 0 ) {
	#     i = i - 1;
	#     s = s + array[i];
	#   }
	#   return s;
	# }
	
	# local variables offsets:
	#   s - 0x00
	#   i - 0x04
	
	subi	$sp,	$sp,	8	# allocate return value + $ra
	sw	$ra,	0x00($sp)	# put $ra on stack
	
	subi	$sp,	$sp,	8	# allocate local variables on stack (8 bytes)
	
	# stack:
	# 0x00 | 0x04 | 0x08 | 0x0c | 0x10 | 0x14
	#   s  |  i   |  ra  |  rv  | arg2 | arg1
	
	# s = 0;
	sw	$zero,	0x00($sp)
	
	# i = array_size - 1;
	lw	$t0,	0x10($sp)	# load array_size
	addi	$t0,	$t0,	-1	# decrease by 1
	sw	$t0,	0x04($sp)	# store in i
	
	# while ( i >= 0 ) ...
	sum_while:
	lw	$t0,	0x04($sp)
	bltz 	$t0,	sum_while_end
	
	# s = s + array[i];
	lw	$t0,	0x00($sp)	# load s
	lw	$t1,	0x04($sp)	# load i
	lw	$t2,	0x14($sp)	# load array
	sll	$t1,	$t1,	2	# change $t1 into offset
	add	$t2,	$t2,	$t1	# calc address of word
	lw	$t1,	($t2)		# load array[i]
	add	$t0,	$t0,	$t1	
	sw	$t0,	0x00($sp)	# store s
	
	# i = i - 1;
	lw	$t0,	0x04($sp)
	addi	$t0,	$t0, 	-1
	sw	$t0,	0x04($sp)
	
	# }
	b	sum_while
	
	sum_while_end:
	
	# return s;
	lw	$t0,	0x00($sp)	# load s
	sw	$t0,	0x0c($sp)	# store in return value
	
	addi	$sp,	$sp,	8	# deallocate local variables (8 bytes)
	lw	$ra,	0($sp)		# restore $ra
	addi	$sp,	$sp,	4	# remove $ra from stack
	jr	$ra
	
print:
	subi	$sp,	$sp,	4	# allocate $ra
	sw	$ra,	0x00($sp)	# put $ra on stack
	
	# stack:
	# 0x00 | 0x04
	#  ra  | arg1
	
	lw	$a0,	0x04($sp)
	li	$v0,	1
	syscall
	
	lw	$ra,	0x00($sp)		# restore $ra
	addi	$sp,	$sp,	4	# remove $ra from stack
	jr	$ra
	
