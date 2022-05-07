# Computer Architecture - Task 1
# ISA: MIPS32

.data
in_i: .word -1234
out_f: .space 4

# t0 - [input] i
# t1 - current exponent
# t2 - mantissa mask
# t3 - 0x00800000 value
# t4 - last lost bit
# t7 - [output] IEEE-754 float
.text
main:
li	$t4,	0		# reset $t4
li 	$t7, 	0 		# reset $t7
lw 	$t0, 	in_i
bnez 	$t0, 	nzero
sw 	$zero, 	out_f 		# if the number is zero, store 0x00000000 in out_f
j 	end
nzero: 		# number is != 0
bgtz 	$t0, 	positive
lui 	$t7, 	0x8000 		# store 1 in the sign bit of the float
neg 	$t0, 	$t0 		# negate $t0
positive: 	# number is > 0
li 	$t1, 	150 		# exponent is 150 for 2^24, 24th bit of mantissa is always 1
li 	$t3, 	0x00800000 	# store mantissa mask in $t3
loop:
andi 	$t2, 	$t0, 	0xff800000
beq 	$t2, 	$t3, 	loopend	# $t0 is ok, loop ends
beqz 	$t2, 	smaller		# $t0 is greater than it should be
andi	$t4,	$t0,	1	# store last lost bit (to support rounding up)
srl 	$t0, 	$t0, 	1
addiu 	$t1, 	$t1, 	1
j 	loop
smaller: 			# $t0 is smaller than it should be
sll 	$t0, 	$t0, 	1
subiu 	$t1, 	$t1, 	1
j 	loop
loopend:
sll 	$t1, 	$t1, 	23 		# shift exponent 23 bits left
or 	$t7, 	$t7, 	$t1 		# put exponent in resulting float
andi 	$t0, 	$t0, 	0x007fffff 	# cut last 23 bits of mantissa
or 	$t7, 	$t7, 	$t0 		# put mantissa in resulting float
addu	$t7,	$t7,	$t4		# add 1 to round up if necessary
sw 	$t7, 	out_f 			# put float in out_f

# test if the float is valid
end:
lw $a0, out_f
mtc1 $a0, $f12
li $v0, 2
syscall
