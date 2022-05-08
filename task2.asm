# Computer Architecture - Task 2
# ISA: MIPS32

.data
number1: .byte 0x05 0x69 0x2f
number2: .byte 0x68 0x90 0x15 0x23 0x46 0xff
result: .space 10

zeroes1: .byte 0xf0
zeroes2: .byte 0x0f
zeroes3: .space 1

nines1: .byte 0xff 0xff 0xff 0xff 0xff 0xff 0xff
nines2: .byte 0x00 0x00 0x83 0x63 0x19 0x24 0x2f
nines3: .byte 0x00 0x0f 0xff 0xff 0xff 0xff 0xff 0xff

space1: .byte 0x6f
space2: .byte 0x8f
space3: .space 2

.text
main:
	la 	$a0,	number1
	la	$a1,	number2
	la	$a2,	result
	jal	bcdAdd # test1: 5 692 + 6 890 152 346 = 6 890 158 038
	jal	bcdPrint
	
	la 	$a0,	zeroes1
	la	$a1,	zeroes2
	la	$a2,	zeroes3
	jal	bcdAdd # test2: 0 + 0 = 0
	jal	bcdPrint
	
	# test3: add 836319242 100 times
	li	$s0,	50
	main_loop:
		la	$a0,	nines1
		la	$a1,	nines2
		la	$a2,	nines3
		jal	bcdAdd
		jal	bcdPrint
		la	$a0,	nines3
		la	$a1,	nines2
		la	$a2,	nines1
		jal	bcdAdd
		jal	bcdPrint
		subiu	$s0,	$s0,	1
		bgtz	$s0,	main_loop
		
	la 	$a0,	space1
	la	$a1,	space2
	la	$a2,	space3
	jal	bcdAdd # test4: 6 + 8 = 14 (result longer than either of the operands)
	jal	bcdPrint
	
	li	$v0,	10
	syscall
	
# a0 - [in] address of the first term
# a1 - [in] address of the second term
# a2 - [out] address of addition result
bcdAdd:
	# Registers:
	# t0 - temporary register
	# t1 - current mask/AND result / temp2 register
	# t2 - current address of the first term
	# t3 - current address of the second term
	# t4 - length of the first term in digits
	# t5 - length of the second term in digits
	# t6 - calculated length of the result (+1 to store 0xf)
	# t7 - are we R/W-ing more significant half-byte? / carry flag
	#      (bit mask, 2^0 - first term, 2^1 - second term, 2^2 - result, 2^3 - carry flag)
	# t8 - count of processed digits
	# t9 - return address
	
	move	$t2,	$a0
	move	$t9,	$ra
	li	$t4,	0
	loopLength1:			# calculate length of the first term
		lbu	$t0,	($t2)		# load next byte to $t0
		xori	$t0,	$t0,	0xff	# flip all bits (to make 0xF equal 0x0)
		andi	$t1,	$t0,	0xf0
		beqz	$t1,	endLoopLength1
		addi	$t4,	$t4,	1	# 0xf is not there - increase $t4 by 1
		andi	$t1,	$t0,	0x0f
		beqz	$t1,	endLoopLength1
		addi	$t4,	$t4,	1	# 0xf is not there - increase $t4 by 1
		addiu	$t2,	$t2,	1	# go to next byte
		b	loopLength1
	endLoopLength1:
	move	$t3,	$a1
	li	$t5,	0
	loopLength2:			# calculate length of the second term
		lbu	$t0,	($t3)		# load next byte to $t0
		xori	$t0,	$t0,	0xff	# flip all bits (to make 0xF equal 0x0)
		andi	$t1,	$t0,	0xf0
		beqz	$t1,	endLoopLength2
		addi	$t5,	$t5,	1	# 0xf is not there - increase $t5 by 1
		andi	$t1,	$t0,	0x0f
		beqz	$t1,	endLoopLength2
		addi	$t5,	$t5,	1	# 0xf is not there - increase $t5 by 1
		addiu	$t3,	$t3,	1	# go to next byte
		b	loopLength2
	endLoopLength2:
	# firstly perform dry run addition and propagate carry flag to calculate the
	# length of the result
	andi	$t7,	$t5,	0x01 	# set first flag of $t7 + clear carry
	sll	$t7,	$t7,	1
	andi	$t0,	$t4,	0x01
	or	$t7,	$t7,	$t0	# set second flag of $t7
	
	subiu	$t0,	$t4,	1
	srl	$t0,	$t0,	1
	addu	$t2,	$a0,	$t0	# store address of the last digit in $t2
	subiu	$t0,	$t5,	1
	srl	$t0,	$t0,	1
	addu	$t3,	$a1,	$t0	# store address of the last digit in $t3
	li	$t6,	0		# set current result length to 0
	li	$t8,	0		# set processed digits count to 0
	
	loopLength3:
		jal 	_bcdAddStep
		addiu	$t8,	$t8,	1		# increase processed digits
		beqz	$t0,	loopLength3_digitZero
		addiu	$t6,	$t8,	1		# increase $t6 according to $t8 if the resulting digit is greater than 0
		loopLength3_digitZero:
		andi	$t0,	$t7,	0x01
		beqz	$t0,	loopLength3_addr1NoDec	# check if $t2 should be decreased
		subiu	$t2,	$t2,	1		# decrease $t2 by one byte
		loopLength3_addr1NoDec:
		andi	$t0,	$t7,	0x02
		beqz	$t0,	loopLength3_addr2NoDec	# check if $t3 should be decreased
		subiu	$t3,	$t3,	1		# decrease $t3 by one byte
		loopLength3_addr2NoDec:
		xori	$t7,	$t7,	0x03		# flip upper/lower half-byte flags
		# loop conditions:
		bge	$t2,	$a0,	loopLength3
		bge	$t3,	$a1,	loopLength3
		andi	$t0,	$t7,	0x08
		bnez	$t0,	loopLength3
	# should we represent 0 as 0x0f or 0xf0 in result?
	bgtz	$t6,	adding
	li	$t6,	2	# change 2 to 1 to represent 0 as 0xf0
	# now finally add two numbers
	# change t8 meaning - current result address
	adding:
	andi	$t7,	$t6,	0x01	# set result flag of $t7 + clear carry
	sll	$t7,	$t7,	2
	andi	$t0,	$t5,	0x01 	
	sll	$t0,	$t0,	1
	or	$t7,	$t7,	$t0	# set first flag of $t7
	andi	$t0,	$t4,	0x01
	or	$t7,	$t7,	$t0	# set second flag of $t7
	
	subiu	$t6,	$t6,	1
	srl	$t0,	$t6,	1
	addu	$t8,	$a2,	$t0	# store address of terminator of the result in $t8
	subiu	$t0,	$t4,	1
	srl	$t0,	$t0,	1
	addu	$t2,	$a0,	$t0	# store address of the last digit in $t2
	subiu	$t0,	$t5,	1
	srl	$t0,	$t0,	1
	addu	$t3,	$a1,	$t0	# store address of the last digit in $t3
	
	andi	$t0,	$t7,	0x04
	xori	$t7,	$t7,	0x04	# flip upper/lower flag for result
	beqz	$t0,	terminatorToLSB	# store terminator in upper half-byte
	li	$t0,	0xf0
	sb	$t0,	($t8)
	subiu	$t8,	$t8,	1	# decrease address in $t8
	b loopAdd
	terminatorToLSB:			# store terminator in lower half-byte
	li	$t0,	0x0f
	sb	$t0,	($t8)
	
	loopAdd:
		jal 	_bcdAddStep
		andi	$t1,	$t7,	0x04
		beqz	$t1,	loopAdd_resultLSB	# saving upper half-byte of the result
		lbu	$t1,	($t8)				# load current byte value
		andi	$t1,	0x0f				# clear upper half-byte
		sll	$t0,	$t0,	4
		or	$t1,	$t1,	$t0			# set bits of upper half-byte
		sb	$t1,	($t8)				# save result byte
		subiu	$t8,	$t8,	1			# decrease $t8 address by one byte
		b 	loopAdd_addresses
		loopAdd_resultLSB:			# saving lower half-byte of the result
		sb	$t0,	($t8)
		loopAdd_addresses:
		andi	$t0,	$t7,	0x01
		beqz	$t0,	loopAdd_addr1NoDec	# check if $t2 should be decreased
		subiu	$t2,	$t2,	1			# decrease $t2 by one byte
		loopAdd_addr1NoDec:
		andi	$t0,	$t7,	0x02
		beqz	$t0,	loopAdd_addr2NoDec	# check if $t3 should be decreased
		subiu	$t3,	$t3,	1			# decrease $t3 by one byte
		loopAdd_addr2NoDec:
		xori	$t7,	$t7,	0x07		# flip upper/lower/result half-byte flags
		subiu	$t6,	$t6,	1
		bgtz	$t6,	loopAdd	# there are more digits left to add
		
	jr 	$t9 		# return
	
	_bcdAddStep:		# internal subroutine to prevent duplicate code, t0 contains current digit, t9 - carry
		# first digit:
		li	$t0,	0
		blt	$t2,	$a0,	_bcdAddStep_addr1Underflow	# if $t2 is less than $a0, the first term has ended and we use 0
		andi	$t0,	$t7,	0x01		# put upper half-byte flag in $t0
		beqz	$t0,	_bcdAddStep_addr1LSB	# load upper half-byte:
		lbu	$t0,	($t2)				# load current byte to $t0
		srl	$t0,	$t0,	4			# get upper four bytes
		b	_bcdAddStep_addr1Underflow
		_bcdAddStep_addr1LSB:			# load lower half-byte:
		lbu	$t0,	($t2)				# load current byte to $t0
		andi	$t0,	$t0,	0x0f			# get lower four bytes
		_bcdAddStep_addr1Underflow:
		# second digit:
		li	$t1,	0
		blt	$t3,	$a1	_bcdAddStep_addr2Underflow	# if $t3 is less than $a1, the second term has ended and we use 0
		andi	$t1,	$t7,	0x02		# put upper half-byte flag in $t1
		beqz	$t1,	_bcdAddStep_addr2LSB	# load upper half-byte:
		lbu	$t1,	($t3)				# load current byte to $t1
		srl	$t1,	$t1,	4			# get upper four bytes
		b	_bcdAddStep_addr2Underflow
		_bcdAddStep_addr2LSB:			# load lower half-byte:
		lbu	$t1,	($t3)				# load current byte to $t1
		andi	$t1,	$t1,	0x0f			# get lower four bytes
		_bcdAddStep_addr2Underflow:
		# add two digits and carry
		addu	$t0,	$t0,	$t1
		andi	$t1,	$t7,	0x08 		# extract carry flag from $t7
		xor	$t7,	$t7,	$t1		# clear carry (x XOR x = 0)
		srl	$t1,	$t1,	3
		addu	$t0,	$t0,	$t1
		blt	$t0,	10,	_bcdAddStep_noCarry
		subiu	$t0,	$t0,	10		# apply BCD bias
		ori	$t7,	$t7,	0x08		# set carry
		_bcdAddStep_noCarry:
		jr	$ra

# a2 - address of the BCD-encoded decimal to print
bcdPrint:
	# Registers:
	# t0 - temporary register
	# t1 - upper half-byte
	# t2 - lower half-byte
	# t3 - AND mask
	li	$v0,	11		# service 11 - print character
	loopPrint:			# calculate length of the first term
		lbu	$t0,	($a2)		# load next byte to $t0
		srl	$t1,	$t0,	4	# store first digit
		andi	$t2,	$t0,	0x0f	# store second digit
		xori	$t0,	$t0,	0xff	# flip all bytes (to make 0xF equal 0x0)
		andi	$t3,	$t0,	0xf0
		beqz	$t3,	endLoopPrint
		addi	$a0,	$t1,	48	# 48 - ASCII for 0
		syscall
		andi	$t3,	$t0,	0x0f
		beqz	$t3,	endLoopPrint
		addi	$a0,	$t2,	48	# 48 - ASCII for 0
		syscall
		addiu	$a2,	$a2,	1	# go to next byte
		b	loopPrint
	endLoopPrint:
	li	$a0,	10
	syscall
	jr	$ra		# return
