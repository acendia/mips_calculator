.data  
write:		.asciiz "write the operator: "  
first_number: 	.asciiz "Enter first number: "
second_number: 	.asciiz "Enter second number: "
dec_bin_hex: 	.asciiz "Would you liked the result be in dec(1), hex(2) or bin(3)?\n"
repeat: 	.asciiz "\nWould you like to continue?(y/n): "
repeat_yes:	.asciiz "y\n"
saved_val: 	.asciiz "M\n"
addition: 	.asciiz "+\n"
subtraction: 	.asciiz "-\n"
multiplication: .asciiz "*\n"
division: 	.asciiz "/\n"
power: 		.asciiz "**\n"
string: 	.space 20  
string2: 	.space 10
first_input: 	.space 5
second_input: 	.space 5


.text
.globl main

main:  

REPEATER:
# prompt the user.
li $v0,4          
la $a0,write  
syscall

# read the input
li $v0,8
la $a0,string
addi $a1,$zero,20
syscall

# prompt the user.
la $a0, first_number
jal print_string

# read first int
jal read_integer
move $s2, $v0

# prompt the user.
la $a0, second_number
jal print_string

# read second int
jal read_integer
move $s3, $v0

la $a0, string			# set input of user

#### ADDITION ####
la $a1, addition		# set addition string
jal strcmp      		# check if it's addition  
beq $v0,$zero matching_add 	# if user input is + then do addition and print.
j exit_add
matching_add:  			
	add $v0, $s3, $s2
	jal exit_operation
exit_add: 

#### SUBTRACTION ####   
la $a1, subtraction		# set subtraction string
jal strcmp      		# check if it's subtraction  
beq $v0,$zero, matching_sub	# if user input is - then do subtraction and print.
j exit_sub
matching_sub:  			
	sub $v0, $s2, $s3
	jal exit_operation
exit_sub:  

#### MULTIPLICATION ####
la $a1, multiplication		# set multiplication string
jal strcmp      		# check if it's multiplication  
beq $v0,$zero, matching_mul 	# if user input is * then do multiplication and print.
j exit_mul
matching_mul:  			
	mul $v0, $s2, $s3
	jal exit_operation
exit_mul: 

#### DIVISION #### 
la $a1, division		# set division string
jal strcmp      		# check if it's division  
beq $v0,$zero, matching_div 	# if user input is / then do division and print.
j exit_div
matching_div:  			
	div $v0, $s2, $s3
	jal exit_operation
exit_div: 

#### POWER ####
la $a1, power			# set power string
jal strcmp      		# check if it's power  
beq $v0,$zero, matching_pow 	# if user input is ** then do power and print.
j exit_pow
matching_pow:  			
	li $v0, 1
	li $t0, 0
	bge $t0, $s3, exit_pow
for: 
	mul $v0, $v0, $s2
	addi $t0, $t0, 1
	blt $t0, $s3, for	
exit_pow: 

exit_operation:

move $a3, $v0
# prompt the user.
li $v0,4          
la $a0, dec_bin_hex  
syscall

# read first int
jal read_integer
move $s2, $v0

beq $s2, 1, CHOICE1
beq $s2, 2, CHOICE2
beq $s2, 3, CHOICE3
j EXIT_PROG

CHOICE1:
	move $a0, $a3
	jal print_integer
	j EXIT_CHOICES
CHOICE2:	
	jal print_hex
CHOICE3:
	move $a0, $a3
	jal turn_to_bin

EXIT_CHOICES:


# save result to stack pointer
move $v1, $v0

# prompt the user.    
la $a0, repeat  
jal print_string

# read the input
li $v0,8
la $a0,string2
addi $a1,$zero,10
syscall

# if user input is equal to y then repeat else end.
la $a0, string2			# set input of user
la $a1, repeat_yes		# set "y" string
jal strcmp    
beq $v0, $zero, REPEATER

# exit prog
EXIT_PROG:
li $v0,10  
syscall  

#### FUNCTIONS ####
# compare the 2 strings. (return 0 if equal, else return 1)
strcmp:
	add $t1, $zero, $a0
	add $t2, $zero, $a1
loop:
	lb $t3, 0($t1)
	lb $t4, 0($t2)
	addi $t1, $t1, 1
	addi $t2, $t2, 1
	beqz $t3, end_of_loop
	beqz $t4, end_of_loop
	blt $t3, $t4, not_equal
	bgt $t3, $t4, not_equal
	beq $t3, $t4, loop
not_equal: 
	li $v0, 1
	jr $ra
equal:
	li $v0, 0
	jr $ra
end_of_loop:
	beq $t3, $t4, equal
	beqz $t3, not_equal
	beqz $t4, not_equal

# print hex of integer
print_hex:
	# counter of the bit pos
	li $t0, 28 
	hex_loop:
		srlv $a1, $a3, $t0	# shift right starting from the 4MSB to the 4LSB
		and $t1, $a1, 0xF	# do AND to get the 4 lsb bites from the $a1 binary
		addi $t0, $t0, -4	# change pos of the binary going to the LSB, every time by offset of 4

		bgt $t1, 9, ALPHAS	# if number if greater than 9 then print the represented hex char.
	
		addi $t1, $t1, 48	
		jal print_char
	
		slt $t3, $t0, $zero	# if counter is less than 0 then exit the process
		beq $t3, $0, hex_loop	
		j EXIT_CHOICES		# exit program when finished
	
	ALPHAS:
		addi $t1, $t1, 55
		jal print_char
		slt $t3, $t0, $zero	# if counter is less than 0 then exit the process
		beq $t3, $0, hex_loop		
		j EXIT_CHOICES
	

# turn dec to binary
turn_to_bin:
	add $t0, $zero, $a0	# set $a0 to $t0
	add $t1, $zero, $zero	# set t1 to zero
	addi $t3, $zero, 1	
	sll $t3, $t3, 31 	
	addi $t4, $zero, 32	# loop counter

bin_loop:
	and $t1, $t0, $t3 		# and the input with the mask
	beq $t1, $zero, print_binary 	# Branch to print if its 0
	addi $t1, $zero, 1 		# Put a 1 in $t1
	j print_binary

print_binary: 
	li $v0, 1
	move $a0, $t1
	syscall

	addi $t4, $t4, -1	# sub with 1 the counter till we reach the 0.
	srl $t3, $t3, 1		# shift right the only ace binary every time.
	bne $t4, $zero, bin_loop

	li $v0, 11	# print new line char
	li $a0, 10 	# new line on asccii table is 10
	syscall
	jr $ra		


# print the character
print_char:
	move $a0, $t1
	li $v0, 11
	syscall
	jr $ra

# prompt the user.
print_string:
	li $v0, 4
	syscall	
	jr $ra
	
# read integer
read_integer:
	li $v0, 5
	syscall 
	jr $ra

# print integer
print_integer:
	li $v0, 1
	syscall 
	jr $ra
