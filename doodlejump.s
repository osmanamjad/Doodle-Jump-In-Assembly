#####################################################################
#
# CSCB58 Fall 2020 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Muhammad Osman Amjad, 1005308016
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). 
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.data
	displayAddress:	.word	0x10008000
	charStartAddress: .word 0
	ledge1StartAddress: .word 4016
	ledge2StartAddress: .word 0
	ledge3StartAddress: .word 0
	
.text
	lw $s0, displayAddress	# $s0 stores the base address for display
	li $s1, 0xffd700	# $s1 stores the golden colour code
	li $s2, 0xbdb76b	# $s2 stores the dark green colour code
	li $s3, 0x000000	# $s3 stores the black colour code
	li $s4, 0xb0e0e6       # $s4 stores the aqua colour code
	
main:
	jal makeBoardSetup

	jal makeBoardBlue
	
	jal makeLedgesSetup
	
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
	
	add $t7, $t3, $s0 # store the address we want the character to start from into t7
	sw $t7, charStartAddress # store the value of t7 
	
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
	li $t4 3908
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

	lw $t7, 0xffff0000 # load value for keystroke into t7 
	beq $t7, 1, checkJK # if there is a keystroke, branch to check j or k

afterCheckInput:	
	li $v0, 32
	li $a0, 100
	syscall
	
	j jumpUp

jumpDownSetup:
	li $t4 3908
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
	
makeLedgesSetup:
	#li $v0, 42 # prepare syscall to produce random int
	#li $a0, 0 
	#li $a1, 1000 # set max value of random int to 1000
	#syscall
	
	#sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	lw $t7, ledge1StartAddress # load 4036 into t7
	add $t7, $s0, $t7 #add display address + 4036 
	sw $t7, ledge1StartAddress 
	
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 1000 # set max value of random int to 1000
	syscall
	
	sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	add $t7, $s0, $a0 #add display address + random int to get new start 
	sw $t7, ledge2StartAddress
	
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 1000 # set max value of random int to 1000
	syscall
	
	sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	add $t7, $s0, $a0 #add display address + random int to get new start 
	sw $t7, ledge3StartAddress
	
makeLedges:
	lw $t7, ledge1StartAddress #load the address into t7
	
	sw $s2, ($t7) #put green in pixel in row 1
	sw $s2, 4($t7) #put green in pixel in row 1
	sw $s2, 8($t7) #put green in pixel in row 1
	sw $s2, 12($t7) #put green in pixel in row 1
	sw $s2, 16($t7) #put green in pixel in row 1
	sw $s2, 20($t7) #put green in pixel in row 1
	sw $s2, 24($t7) #put green in pixel in row 1
	
	
	lw $t7, ledge2StartAddress #load the address into t7
	
	sw $s2, ($t7) #put green in pixel in row 1
	sw $s2, 4($t7) #put green in pixel in row 1
	sw $s2, 8($t7) #put green in pixel in row 1
	sw $s2, 12($t7) #put green in pixel in row 1
	sw $s2, 16($t7) #put green in pixel in row 1
	sw $s2, 20($t7) #put green in pixel in row 1
	sw $s2, 24($t7) #put green in pixel in row 1
	
	
	lw $t7, ledge3StartAddress #load the address into t7
	
	sw $s2, ($t7) #put green in pixel in row 1
	sw $s2, 4($t7) #put green in pixel in row 1
	sw $s2, 8($t7) #put green in pixel in row 1
	sw $s2, 12($t7) #put green in pixel in row 1
	sw $s2, 16($t7) #put green in pixel in row 1
	sw $s2, 20($t7) #put green in pixel in row 1
	sw $s2, 24($t7) #put green in pixel in row 1
	
	jr $ra
	
checkJK:
	lw $t7, 0xffff0004 
	beq $t7, 0x6a, respondToJ 
	beq $t7, 0x6b, respondToK
afterRespond:
	j afterCheckInput
	
respondToJ:
	addi $t4, $t4, -4
	j afterRespond
	
respondToK:
	addi $t4, $t4, 4
	j afterRespond
		
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
