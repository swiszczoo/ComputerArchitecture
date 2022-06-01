# Computer Architecture - Task 4
# ISA: MIPS32

.data
str1: .space 32
str2: .space 32
str3: .space 32
str4: .space 32

menu: .asciiz "What do you want to do?\n1. Load string\n2. Print string\n3. strlen\n4. strcmp\n5. strcat\n6. strfind\n7. Exit\n> "
load1: .asciiz "Which string to load? "
load2: .asciiz "Enter string: "
print1: .asciiz "Which string to print? "
strlen1: .asciiz "Length of string 1: "
strcmp1: .asciiz "Result of strcmp: "
strfind1: .asciiz "Position of first occurence of string2 inside string1: "

.text
main:
	li	$v0,	4
	la	$a0,	menu
	syscall
	
	li	$v0,	5
	syscall
	move	$s0,	$v0
	
	main_1:	bne	$s0,	1,	main_2
		jal	menu_load
		b	main
	main_2:	bne	$s0,	2,	main_3
		jal	menu_print
		b	main
	main_3:	bne	$s0,	3,	main_4
		jal	menu_strlen
		b	main
	main_4:	bne	$s0,	4,	main_5
		jal	menu_strcmp
		b	main
	main_5:	bne	$s0,	5,	main_6
		jal	menu_strcat
		b	main
	main_6:	bne	$s0,	6,	main_7
		jal	menu_strfind
		b	main
	main_7:	bne	$s0,	7,	main
		jal	menu_exit
		b	main
		
fix_string:
	addi	$t0,	$a0,	-1
	fix_string_loop:
		addi	$t0,	$t0,	1
		lbu	$t1,	($t0)
		bnez	$t1, 	fix_string_1
			jr	$ra	# exit fix_string
		fix_string_1:
		bne	$t1,	'\n',	fix_string_loop
			sb	$zero,	($t0)
			jr	$ra
	
menu_load:
	li	$v0,	4
	la	$a0,	load1
	syscall
	
	li	$v0,	5
	syscall
	move	$s1,	$v0
	
	bgt	$s1,	4,	menu_load
	blt	$s1,	1,	menu_load
	
	li	$v0,	4
	la	$a0,	load2
	syscall
	
	li	$v0,	8
	la	$a0,	str1
	sll	$t0,	$s1,	5
	addi	$t0,	$t0,	-32
	add	$a0,	$a0,	$t0
	li	$a1,	32
	syscall
	
	move	$s7,	$ra
	jal	fix_string
	move	$ra,	$s7

	jr	$ra
	
menu_print:
	li	$v0,	4
	la	$a0,	print1
	syscall
	
	li	$v0,	5
	syscall
	move	$s1,	$v0
	
	bgt	$s1,	4,	menu_print
	blt	$s1,	1,	menu_print
	
	li	$v0,	4
	la	$a0,	str1
	sll	$t0,	$s1,	5
	addi	$t0,	$t0,	-32
	add	$a0,	$a0,	$t0
	syscall
	
	li	$v0,	11
	li	$a0,	'\n'
	syscall
	
	jr	$ra
	
menu_strlen:
	li	$v0,	4
	la	$a0,	strlen1
	syscall

	la	$a0,	str1
	move	$s7,	$ra
	jal	strlen
	move	$ra,	$s7
	
	move	$a0,	$v0
	li	$v0,	1
	syscall
	
	li	$v0,	11
	li	$a0,	'\n'
	syscall

	jr	$ra
	
menu_strcmp:
	li	$v0,	4
	la	$a0,	strcmp1
	syscall

	la	$a0,	str1
	la	$a1,	str2
	move	$s7,	$ra
	jal	strcmp
	move	$ra,	$s7
	
	move	$a0,	$v0
	li	$v0,	1
	syscall
	
	li	$v0,	11
	li	$a0,	'\n'
	syscall

	jr	$ra
	
menu_strcat:
	la	$a0,	str1
	la	$a1,	str2
	la	$a2,	str3
	move	$s7,	$ra
	jal	strcat
	move	$ra,	$s7
	
	jr	$ra
	
menu_strfind:
	li	$v0,	4
	la	$a0,	strfind1
	syscall

	la	$a0,	str1
	la	$a1,	str2
	move	$s7,	$ra
	jal	strfind
	move	$ra,	$s7
	
	move	$a0,	$v0
	li	$v0,	1
	syscall
	
	li	$v0,	11
	li	$a0,	'\n'
	syscall

	jr	$ra
	
menu_exit:
	li	$v0,	10
	syscall




# ===============
# IMPLEMENTATIONS
# ===============

# a0 - pointer to string
# returns: v0 - length of the string
strlen:
	li	$v0,	0
	strlen_loop:
	lbu	$t0,	($a0)
	beqz	$t0, strlen_end
	addi	$v0,	$v0,	1
	addi	$a0,	$a0,	1
	b strlen_loop
	strlen_end:
	jr	$ra
	
# a0 - pointer to the first string
# a1 - pointer to the second string
# returns:
#   -1 - string1 is before string2 lexically
#    0 - string1 equals string2
#    1 - string1 is after string2 lexically
strcmp:
	lbu	$t0,	($a0)
	lbu	$t1,	($a1)
	
	bge	$t0,	$t1,	strcmp_not_smaller
		li	$v0,	-1
		jr	$ra
	strcmp_not_smaller:
	beq	$t0,	$t1,	strcmp_not_larger
		li	$v0,	1
		jr	$ra
	strcmp_not_larger:
		beqz	$t0,	strcmp_equal
		addi	$a0,	$a0,	1
		addi	$a1,	$a1,	1
		b	strcmp
		
		strcmp_equal:
			li	$v0,	0
			jr	$ra
			
# a0 - pointer to destination
# a1 - pointer to the first string
# a2 - pointer to the second string
strcat:
	lbu	$t0,	($a1)
	sb	$t0,	($a0)
	addi	$a0,	$a0,	1
	addi	$a1,	$a1,	1
	bnez	$t0,	strcat
	addi	$a0,	$a0,	-1
	strcat_loop:
	lbu	$t0,	($a2)
	sb	$t0,	($a0)
	addi	$a0,	$a0,	1
	addi	$a2,	$a2,	1
	bnez	$t0,	strcat_loop
	
# a0 - pointer to haystack string
# a1 - pointer to needle string
# returns: index of first occurence of a1 in a0, 
#          or -1 if there's no occurence
strfind:
	move	$t9,	$a0
strfind_in:
	li	$t3,	0		# $t3 - sequence of ok characters
	move	$t0,	$a1
	move	$t4,	$a0
	strfind_next_char:
	lbu	$t1,	($t4)
	lbu	$t2,	($t0)
	bnez	$t2,	strfind_further_char_a1
		sub	$v0,	$a0,	$t9	# result position is $a0 - $t9
		jr	$ra	
	
	strfind_further_char_a1:
	bnez	$t1,	strfind_further_char_a0
		li	$v0,	-1		# we've reached end of the string
		jr	$ra
	
	strfind_further_char_a0:
	beq	$t1,	$t2,	strfind_charok
		# if chars do not equal
		addi	$a0,	$a0,	1
		b	strfind_in
	strfind_charok:				# char is ok
		addi	$t0,	$t0,	1
		addi	$t3,	$t3,	1
		addi	$t4,	$t4,	1
		b	strfind_next_char


