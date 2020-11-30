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
	lw $s0, displayAddress	# $s0 stores the base address for display
	li $s1, 0xffd700	# $s1 stores the golden colour code
	li $s2, 0x00ff00	# $s2 stores the green colour code
	li $s3, 0x000000	# $s3 stores the black colour code
	li $s4, 0xb0e0e6       # $s4 stores the aqua colour code
	
main:
	jal makeBoardSetup

	jal makeBoardBlue
	
	jal makeLedges
	
	jal jumpUpSetup

makeBoardSetup:
	li $t5, 4096		# total size of board 
	add $t5, $t5, $s0	# set t5 to base address + 4096 offset
	li $t6, 4096		# to keep track of how many pixels we've coloured
	
	jr $ra
	
makeBoardBlue:
	subi $t5, $t5, 4
	subi $t6, $t6, 4
	sw $s4, ($t5) # paint each unit
	
	beqz $t6, returnUp
	j makeBoardBlue
	
makeCharacter: 
	lw $t3, 0($sp) # load value at top of stack
	addi $sp, $sp, 4 # decrease size of stack
	
	add $t7, $t3, $s0 #store the address we want the character to start from
	
	sw $s1, ($t7) #put golden in pixel in row 1
	sw $s1, -4($t7) #put golden in pixel in row 1
	sw $s1, -8($t7) #put golden in pixel in row 1
	sw $s1, -12($t7) #put golden in pixel in row 1
	sw $s1, -16($t7) #put golden in pixel in row 1
	sw $s1, -128($t7) #put golden in pixel in row 2
	sw $s1, -132($t7) #put golden in pixel in row 2
	sw $s3, -136($t7) #put black in pixel in row 2
	sw $s1, -140($t7) #put golden in pixel in row 2
	sw $s1, -144($t7) #put golden in pixel in row 2
	sw $s1, -260($t7) #put golden in pixel in row 3
	sw $s1, -264($t7) #put golden in pixel in row 3
	sw $s1, -268($t7) #put golden in pixel in row 3
	
	jr $ra

returnUp:
	jr $ra

jumpUpSetup:
	li $t4 4036
	j jumpUp
jumpUp:
	bltz, $t4, jumpDownSetup 
	
	jal makeBoardSetup
	jal makeBoardBlue
	jal makeLedges
	
	addi $sp, $sp, -4 # put space on stack for start value
	sw $t4, 0($sp) # load the value into the allocated space
	jal makeCharacter
	
	addi $t4, $t4, -256
	
	li $v0, 32
	li $a0, 100
	syscall
	
	j jumpUp

jumpDownSetup:
	li $t4 4036
	li $t3 68
	j jumpDown
jumpDown:
	bgt, $t3, $t4, jumpUpSetup 
	
	jal makeBoardSetup
	jal makeBoardBlue
	jal makeLedges
	
	addi $sp, $sp, -4 # put space on stack for start value
	sw $t3, 0($sp) # load the value into the allocated space
	jal makeCharacter
	
	addi $t3, $t3, 256
	
	li $v0, 32
	li $a0, 100
	syscall
	
	j jumpDown
	
makeLedges:
	li $v0, 42
	li $a0, 0
	li $a1, 1000
	syscall
	
	sll $a0, $a0, 2
	add $t7, $s0, $a0
	
	sw $s2, ($t7) #put green in pixel in row 1
	sw $s2, 4($t7) #put green in pixel in row 1
	sw $s2, 8($t7) #put green in pixel in row 1
	sw $s2, 12($t7) #put green in pixel in row 1
	
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
