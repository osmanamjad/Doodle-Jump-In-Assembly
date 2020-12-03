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
	charBottomAddress: .word 0 # store the address of bottom address doodle should jump till
	ledge1StartAddress: .word 4016
	ledge2StartAddress: .word 0
	ledge3StartAddress: .word 0
	
.text
	lw $s0, displayAddress	# $s0 stores the base address for display
	li $s1, 0xffd700	# $s1 stores the golden colour code
	li $s2, 0xbdb76b	# $s2 stores the dark green colour code
	li $s3, 0x000000	# $s3 stores the black colour code
	li $s4, 0xb0e0e6       # $s4 stores the aqua colour code
	lw $s5, charBottomAddress # $s5 stores the default bottom address 
main:
	add $t7, $s0, 4036 #128 more than 3908 because 128 will be subtracted in jumpUpSetup
	sw $t7, charStartAddress # store the value of t7 into charStartAddress
	
	li $t7, 4096
	add $t7, $t7, $s0
	sw $t7, charBottomAddress
	lw $s5, charBottomAddress #store the default bottom address
	
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
	lw $t7, charStartAddress
	
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
	lw $t4, charStartAddress
	addi $t4, $t4, -128 # subtract 256 to ensure its a valid address
	sw $t4, charStartAddress
	j jumpUp
jumpUp:
	blt, $t4, $s0, jumpDownSetup # branch if t4 goes below the minimum valid address
	
	jal makeBoardSetup
	jal makeBoardBlue
	jal makeLedges
	
	jal makeCharacter
	
	addi $t4, $t4, -128
	sw $t4, charStartAddress

	lw $t6, 0xffff0000 # load value for keystroke into t7 
	beq $t6, 1, checkInput1 # if there is a keystroke, branch to check j or k
NoInput1:	
	li $v0, 32
	li $a0, 50
	syscall
	
	j jumpUp

checkInput1:
	jal checkJK
	
	li $v0, 32
	li $a0, 50
	syscall
	
	j jumpUp

jumpDownSetup:
	lw $t2, charBottomAddress # minimum point the doodle should jump down to
	
	lw $t4, charStartAddress # load the start address of the doodle
	addi $t4, $t4, 128 #add 256 since the exit condition of jump up made charStartAddress invalid address
	sw $t4, charStartAddress

	j jumpDown
jumpDown:
	bgt, $t4, $t2, jumpUpSetup 
	
	jal makeBoardSetup
	jal makeBoardBlue
	jal makeLedges
	
	jal makeCharacter
	jal checkLanding
	lw $t2, charBottomAddress # load charBottom address into t2 in case it changed
	
	addi $t4, $t4, 128
	sw $t4, charStartAddress
	
	lw $t6, 0xffff0000 # load value for keystroke into t7 
	beq $t6, 1, checkInput2 # if there is a keystroke, branch to check j or k
NoInput2:	
	li $v0, 32
	li $a0, 50
	syscall
	
	j jumpDown

checkInput2:
	jal checkJK
	
	li $v0, 32
	li $a0, 50
	syscall

	j jumpDown
	
makeLedgesSetup:
	lw $t7, ledge1StartAddress # load 4036 into t7
	add $t7, $s0, $t7 #add display address + 4036 
	sw $t7, ledge1StartAddress 
	
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 700 # set max value of random int to 700
	syscall
	
	sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 1000 #add 1000 so the ledge isnt too high on the screen
	add $t7, $s0, $a0 #add display address + random int to get new start 
	sw $t7, ledge2StartAddress
	
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 700 # set max value of random int to 700
	syscall
	
	sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 1000 #add 1000 so the ledge isnt too high on the screen
	add $t7, $s0, $a0 #add display address + random int to get new start 
	sw $t7, ledge3StartAddress
	
makeLedges:
	lw $t7, ledge1StartAddress #load the address into t7
	
	sw $s2, ($t7) #put green in pixel in row 1
	sw $s2, -4($t7) #put green in pixel in row 1
	sw $s2, -8($t7) #put green in pixel in row 1
	sw $s2, -12($t7) #put green in pixel in row 1
	sw $s2, -16($t7) #put green in pixel in row 1
	sw $s2, -20($t7) #put green in pixel in row 1
	sw $s2, -24($t7) #put green in pixel in row 1
	
	
	lw $t7, ledge2StartAddress #load the address into t7
	
	sw $s2, ($t7) #put green in pixel in row 1
	sw $s2, -4($t7) #put green in pixel in row 1
	sw $s2, -8($t7) #put green in pixel in row 1
	sw $s2, -12($t7) #put green in pixel in row 1
	sw $s2, -16($t7) #put green in pixel in row 1
	sw $s2, -20($t7) #put green in pixel in row 1
	sw $s2, -24($t7) #put green in pixel in row 1
	
	
	lw $t7, ledge3StartAddress #load the address into t7
	
	sw $s2, ($t7) #put green in pixel in row 1
	sw $s2, -4($t7) #put green in pixel in row 1
	sw $s2, -8($t7) #put green in pixel in row 1
	sw $s2, -12($t7) #put green in pixel in row 1
	sw $s2, -16($t7) #put green in pixel in row 1
	sw $s2, -20($t7) #put green in pixel in row 1
	sw $s2, -24($t7) #put green in pixel in row 1
	
	jr $ra
	
checkJK:
	lw $t7, 0xffff0004 
	beq $t7, 0x6a, respondToJ 
	beq $t7, 0x6b, respondToK
afterRespond:
	jr $ra
	
respondToJ:
	addi $t4, $t4, -4
	sw $t4, charStartAddress
	
	j afterRespond
	
respondToK:
	addi $t4, $t4, 4
	sw $t4, charStartAddress
	
	j afterRespond
	
checkLanding:
	lw $t3, charStartAddress
	lw $t5, ledge1StartAddress
	lw $t6, ledge2StartAddress
	lw $t7, ledge3StartAddress
	
	addi $t0, $t3, 152
	beq $t0, $t7, ledge3NewBase
	beq $t0, $t6, ledge2NewBase
	beq $t0, $t5, ledge1NewBase
	
	addi $t0, $t0, -4
	beq $t0, $t7, ledge3NewBase
	beq $t0, $t6, ledge2NewBase
	beq $t0, $t5, ledge1NewBase
	
	addi $t0, $t0, -4
	beq $t0, $t7, ledge3NewBase
	beq $t0, $t6, ledge2NewBase
	beq $t0, $t5, ledge1NewBase
	
	addi $t0, $t0, -4
	beq $t0, $t7, ledge3NewBase
	beq $t0, $t6, ledge2NewBase
	beq $t0, $t5, ledge1NewBase
	
	addi $t0, $t0, -4
	beq $t0, $t7, ledge3NewBase
	beq $t0, $t6, ledge2NewBase
	beq $t0, $t5, ledge1NewBase	
	
	addi $t0, $t0, -4
	beq $t0, $t7, ledge3NewBase
	beq $t0, $t6, ledge2NewBase
	beq $t0, $t5, ledge1NewBase
	
	addi $t0, $t0, -4
	beq $t0, $t7, ledge3NewBase
	beq $t0, $t6, ledge2NewBase
	beq $t0, $t5, ledge1NewBase
	
	addi $t0, $t0, -4
	beq $t0, $t7, ledge3NewBase
	beq $t0, $t6, ledge2NewBase
	beq $t0, $t5, ledge1NewBase
	
	addi $t0, $t0, -4
	beq $t0, $t7, ledge3NewBase
	beq $t0, $t6, ledge2NewBase
	beq $t0, $t5, ledge1NewBase
	
	addi $t0, $t0, -4
	beq $t0, $t7, ledge3NewBase
	beq $t0, $t6, ledge2NewBase
	beq $t0, $t5, ledge1NewBase
	
	addi $t0, $t0, -4
	beq $t0, $t7, ledge3NewBase
	beq $t0, $t6, ledge2NewBase
	beq $t0, $t5, ledge1NewBase
	
	sw $s5, charBottomAddress #if we don't land on a ledge, then make bottom back to default
	jr $ra #return to jumpDown

ledge3NewBase:
	sw $t3, charBottomAddress # since we've landed, make current charStartAddress the new bottom
	jr $ra #return to jumpDown
	
ledge2NewBase:
	sw $t3, charBottomAddress #since we've landed, make current charStartAddress the new bottom
	jr $ra #return to jumpDown

ledge1NewBase:
	sw $t3, charBottomAddress #since we've landed, make current charStartAddress the new bottom
	jr $ra #return to jumpDown
		
		
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
