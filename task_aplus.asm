# ========================================================================
# This was a task to get a 5.5 (A+) grade from the entire assembly course.
# You need to implement your own fixed size heap allocator and 
# provide implementations for malloc and free functions.
# ========================================================================

# Proposed heap chunk header format:
# offset |  length  | meaning
# =====================================================================================================================================
#   0x00 |  4 bytes | address of the previous chunk (0 if this is the first chunk)
#   0x04 |  4 bytes | address of the next chunk (0 if this is the last chunk)
#   0x08 |  4 bytes | length of user data in this chunk (31 LO bits), the highest order bit is set if this chunk is currently allocated
#   0x0c |  n bytes | user data...
# =====================================================================================================================================

# Header size is 12 = 0x0c


.eqv HEAP_SIZE 2048

.data
heap: 	.space 	HEAP_SIZE
crlf: 	.asciiz	"\n\n"
text1: 	.asciiz 	"What do you want to do?\n1. Allocate memory\n2. Free memory\n3. Exit\n> "
alloc1: 	.asciiz 	"Enter block size (in bytes): "
alloc2: 	.asciiz 	"Pointer returned: "
alloc3: 	.asciiz 	"malloc returned NULL!\n\n"
free1: 	.asciiz 	"Enter pointer to free: "

.kdata
error_text:	.asciiz 	"An exception occured, exiting program...\n"

.ktext 0x80000180	# Exception handler
	li	$v0,	4
	la	$a0,	error_text
	syscall
	
	li	$v0,	10
	li	$a0,	0
	syscall
	
	eret

.text
.globl __start
__start:
	jal	init_heap
main:
	li	$v0,	4
	la	$a0,	text1
	syscall					# display menu
	
	li	$v0,	5
	syscall
	move	$s0,	$v0
	
	bne	$v0,	3,	main_no_exit	# handle exit
		li 	$v0,	10
		syscall
	main_no_exit:
	bne	$v0,	1,	main_no_malloc	# handle malloc
		jal	input_malloc
	main_no_malloc:
	bne	$v0,	2,	main_no_free	# handle free
		jal	input_free
	main_no_free:
	b main
	
input_malloc:
	li	$v0,	4
	la	$a0,	alloc1
	syscall				# display input text
	
	li	$v0,	5
	syscall				# ask for block size
	
	move	$a0,	$v0
	move	$s7,	$ra
	jal	malloc			# call malloc
	move	$s0,	$v0		# move returned pointer to $s0
	move	$ra,	$s7
	
	bnez	$v0,	input_malloc_ok
		# in case malloc failed
		li	$v0,	4
		la	$a0,	alloc3
		syscall
		
		jr	$ra
	
	input_malloc_ok:
		# in case malloc succeeded
		li	$v0,	4
		la	$a0,	alloc2
		syscall				# display pointer text
		
		la	$s1,	heap
		sub	$s0,	$s0,	$s1	# let pointer be the offset from heap start
		
		move	$a0,	$s0
		li	$v0,	1
		syscall				# display pointer value
		
		li	$v0,	4
		la	$a0,	crlf
		syscall				# make 2 newlines
	
		jr	$ra

input_free:
	li	$v0,	4
	la	$a0,	free1
	syscall				# display input text
	
	li	$v0,	5
	syscall				# ask for pointer to free
	
	la	$s1,	heap		# load heap start address
	add	$a0,	$v0,	$s1	# set $a0 to real pointer
	
	move	$s7,	$ra
	jal	free			# call free
	move	$ra,	$s7
	
	jr	$ra


# ==============
# IMPLEMENTATION
# ==============

# performs initialization of the heap structure
init_heap:
	la	$t0,	heap	# load heap start address
	sw	$zero,	0($t0)	# it is the first chunk
	sw	$zero,	4($t0)	# it is the last chunk
	li	$t1,	HEAP_SIZE
	addi	$t1,	$t1,	-12
	sw	$t1,	8($t0)	# its length is HEAP_SIZE - 12 bytes for header
	jr	$ra

# $a0 - memory block size (in bytes)
# returns: $v0 - pointer to the newly allocated memory block
malloc:
	# align $a0 to the mutliple of 4
	li	$t0,	4
	div	$a0,	$t0
	mfhi	$t0
	beqz	$t0,	malloc_no_align		# skip if $a0 mod 4 is 0
		sub	$a0,	$a0,	$t0
		addi	$a0,	$a0,	4	# set $a0 to the next multiple of 4
	malloc_no_align:
	
	# now try to find the smallest unallocated chunk
	# that is bigger than $a0
	la	$t0,	heap	# set current chunk address to heap start
	lui	$t1,	0x8000	# set current minimal length to 2^31
	li	$t2,	0	# set current best address to NULL
	lui	$t3,	0x8000	# set bitmask for checking if the chunk is allocated
	malloc_minimum_loop:
		lw	$t4,	8($t0)		# load length of current chunk
		and	$t5,	$t4,	$t3	# check if it is allocated
		bnez	$t5,	malloc_minimum_loop_skip		# skip it if it isn't free
		blt	$t4,	$a0, malloc_minimum_loop_skip	# skip if it's too short
		bgeu	$t4,	$t1, malloc_minimum_loop_skip	# skip if it isn't the new minimum
			move	$t1,	$t4
			move	$t2,	$t0
		malloc_minimum_loop_skip:	# go to next chunk
		lw	$t0,	4($t0)
		bnez	$t0,	malloc_minimum_loop
		
	# if we didn't find any suitable chunk, exit malloc returning NULL
	bnez	$t2,	malloc_found
	li	$v0,	0	# return NULL
	jr	$ra
	
	# we found the best smallest possible chunk
	# now if it's length is greater than or equal to $a0 by at least 16 bytes (header + word),
	# split it by inserting a new chunk header at the adequate position
	malloc_found:	# $t2 contains address of our selected chunk, $t1 - its length
	addi	$t0,	$a0,	16
	bge	$t1,	$t0,	malloc_split # split chunk if $t1 > $a0 + 16
		# do not split, even if the chunk is larger than $a0
		lw	$t0,	8($t2)
		or	$t0,	$t0,	$t3	# set bit 31 of length to indicate that chunk is allocated
		sw	$t0,	8($t2)
		addi	$v0,	$t2,	12	# user data address is $t2 + 12 bytes (for header)
		jr	$ra
	malloc_split:
		# split chunk -  place next header chunk at address $t2 + 12 + $a0 and update both headers
		add	$t4,	$t2,	$a0
		addi	$t4,	$t4,	12	# store next chunk address in $t4
		
		or	$t0,	$a0,	$t3
		sw	$t0,	8($t2)		# update length of current chunk
		
		lw	$t0,	4($t2)		
		sw	$t0,	4($t4)		# copy next chunk address to the newly created chunk
		
		sw	$t2,	0($t4)		# set prev chunk address to $t2
		sw	$t4,	4($t2)		# set next chunk address to $t4
		
		# update also prev address of the chunk right after the split chunk
		lw	$t0,	4($t4)
		beqz	$t0,	malloc_split_last_chunk	# do not update anything if we split the last chunk
			sw	$t4,	0($t0)	# update prev address of the next chunk
		malloc_split_last_chunk:
		
		# calculate length of the new chunk ($t0 = $t1 - $a0 - 12 bytes for new header)
		# it will always be unallocated
		sub	$t0,	$t1,	$a0	
		addi	$t0,	$t0,	-12
		sw	$t0,	8($t4)
		
		# return $t2 + 12 bytes
		addi	$v0,	$t2,	12	# user data address is $t2 + 12 bytes (for header)
		jr	$ra
		
# a0 - pointer to free
free:
	addi	$t1,	$a0,	-12		# store current chunk header in $t1
	lw	$t0,	8($t1)			
	andi	$t0,	$t0, 0x7fffffff		# clear allocation flag from current chunk header
	sw	$t0,	8($t1)
	
	# try to join left and right chunks
	lw	$t0,	4($t1)			# load next chunk address
	beqz	$t0,	free_no_join_right	# skip if we're at the last chunk
	lw	$t2,	8($t0)
	andi	$t2,	0x80000000		# check if the next chunk is allocated
	bnez	$t2,	free_no_join_right	# if it is, don't join
	
	# perform join with right chunk
	move	$t3,	$ra
	move	$a1,	$t1			# set $a1 to current chunk
	move	$a2,	$t0			# set $a2 to next chunk
	jal	free_merge_left
	move	$ra,	$t3
	
	free_no_join_right:
	lw	$t0,	0($t1)			# load prev chunk address
	beqz	$t0,	free_no_join_left	# skip if we're at the first chunk
	lw	$t2,	8($t0)
	andi	$t2,	0x80000000		# check if the previous chunk is allocated
	bnez	$t2,	free_no_join_left	# if it is, don't join
	
	# perform join with left chunk
	move	$t3,	$ra
	move	$a1,	$t0			# set $a1 to previous chunk
	move	$a2,	$t1			# set $a2 to current chunk
	jal	free_merge_left
	move	$ra,	$t3
	
	free_no_join_left:
	jr	$ra
	
# a1 - first chunk
# a2 - second chunk
# don't touch registers $t0-$t3
free_merge_left:
	lw	$t4,	4($a2)				# load chunk after the second chunk
	sw	$t4,	4($a1)				# save address as a chunk after first chunk
	beqz	$t4,	free_merge_left_no_update	# if it doesn't exist, do not update its prev addr
		sw	$a1,	0($t4)
	free_merge_left_no_update:
	
	# update length of the first chunk
	lw	$t4,	8($a1)				# load length of the first chunk
	lw	$t5,	8($a2)				# load length of the second chunk
	add	$t4,	$t4,	$t5
	addi	$t4,	$t4,	12			# sum both lengths and treat second chunk header as empty space
	sw	$t4,	8($a1)				# store as a new length of the first chunk
	
	jr	$ra
	