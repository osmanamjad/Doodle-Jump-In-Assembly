# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
	displayAddress:	.word	0x10008000
.text
	lw $t0, displayAddress	# $t0 stores the base address for display
	li $t1, 0xffd700	# $t1 stores the golden colour code
	li $t2, 0x00ff00	# $t2 stores the green colour code
	li $t3, 0x000000	# $t3 stores the black colour code
	li $t4, 0xb0e0e6       # $t4 stores the aqua colour code
	
	li $t5, 4096		# total size of board and the last unit of the display
	add $t5, $t5, $t0	# set t5 to base address + 4096 offset
	li $t6, 4096

makeBoardBlue:
	subi $t5, $t5, 4
	subi $t6, $t6, 4
	sw $t4, ($t5) # paint each unit
	
	beqz $t6, next1
	j makeBoardBlue

next1:
	li $t5 4028
jump:
	beqz, $t5, CentralProcessing #infinite loop
	
	addi $sp, $sp, -4 # put space on stack for start value
	sw $t5, 0($sp) # load the value into the allocated space
	jal makeCharacter
	
	addi $t5, $t5, -256
	
	li $v0, 32
	li $a0, 100
	syscall
	
	#jal makeBoardBlue
	
	j jump
	
	
	
makeCharacter: 
	lw $t6, 0($sp) # load value at top of stack
	addi $sp, $sp, 4 # decrease size of stack
	
	add $t7, $t6, $t0
	
	sw $t1, ($t7) #put golden in pixel in row 1
	sw $t1, -4($t7) #put golden in pixel in row 1
	sw $t1, -8($t7) #put golden in pixel in row 1
	sw $t1, -12($t7) #put golden in pixel in row 1
	sw $t1, -16($t7) #put golden in pixel in row 1
	sw $t1, -128($t7) #put golden in pixel in row 2
	sw $t1, -132($t7) #put golden in pixel in row 2
	sw $t3, -136($t7) #put black in pixel in row 2
	sw $t1, -140($t7) #put golden in pixel in row 2
	sw $t1, -144($t7) #put golden in pixel in row 2
	sw $t1, -260($t7) #put golden in pixel in row 3
	sw $t1, -264($t7) #put golden in pixel in row 3
	sw $t1, -268($t7) #put golden in pixel in row 3
	
	jr $ra
	
	
	

	
	
	
	
	
CentralProcessing:
	#Check for keyboard input
	#Update the location of the Doodler accordingly
	#Check for collision events (between the Doodler and the screen)
	#Update the location of all platforms and other objects
	#Redraw the screen
	#Sleep.
	#Go back to Step #1

Exit:
	li $v0, 10 # terminate the program gracefully
	syscall