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
	ledge1StartAddress: .word 0
	ledge2StartAddress: .word 0
	ledge3StartAddress: .word 0
	
.text
	lw $s0, displayAddress	# $s0 stores the base address for display
	li $s1, 0xffd700	# $s1 stores the golden colour code
	li $s2, 0xbdb76b	# $s2 stores the dark green colour code
	li $s3, 0x000000	# $s3 stores the black colour code
	li $s4, 0xb0e0e6       # $s4 stores the aqua colour code
	lw $s5, charBottomAddress # $s5 stores the default bottom address 
	li $s6, 3968 # $s6 stores the maximum display address of the character (1 row  above last row)
	li $s7, 4096 # $s7 stores maximum display address for board.
main:
	j makeStartScreen
	add $s6, $s0, $s6 # never changed
	add $s7, $s0, $s7 # never changed
	
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
waitForS:
	lw $t6, 0xffff0000 # load value for if keystroke into t6 
	beq $t6, 1, checkS # if there is a keystroke, branch to check s
	j waitForS
checkS:
	lw $t7, 0xffff0004 
	beq $t7, 0x73, startGame # if keystroke was s, then start the game
	j waitForS # if keystroke wasn't s, keep waiting
startGame:
	jal jumpUpSetup

makeBoardSetup:
	li $t7, 4096		# total size of board 
	add $t7, $t7, $s0	# set t5 to base address + 4096 offset
	li $t6, 4096		# to keep track of how many pixels we've coloured
	
	jr $ra
	
makeBoardBlue:
	subi $t7, $t7, 4
	subi $t6, $t6, 4
	sw $s4, ($t7) # paint each unit
	
	beqz $t6, returnUp
	j makeBoardBlue
returnUp:
	jr $ra
	
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

jumpUpSetup:
	lw $t4, charStartAddress
	addi $t4, $t4, -128 # subtract to ensure its a valid address
	addi $t3, $t4, -2000 #represents the amount of jump in bytes
	sw $t4, charStartAddress
	j jumpUp
jumpUp:
	blt, $t4, $t3, jumpDownSetup # branch if t4 goes below max jumping capacity
	
	jal makeBoardSetup
	jal makeBoardBlue
	jal makeLedges
	jal makeCharacter
	jal scroll
afterScroll:
	addi $t4, $t4, -128
	sw $t4, charStartAddress

	lw $t6, 0xffff0000 # load value for keystroke
	beq $t6, 1, checkInput1 # if there is a keystroke, branch to check j or k
NoInput1:	
	li $v0, 32
	li $a0, 40
	syscall
	
	j jumpUp

checkInput1:
	jal checkJK
	
	li $v0, 32
	li $a0, 40
	syscall
	
	j jumpUp

jumpDownSetup:
	lw $t3, charBottomAddress # minimum point the doodle should jump down to
	
	lw $t4, charStartAddress # load the start address of the doodle
	addi $t4, $t4, 128 #add 256 since the exit condition of jump up made charStartAddress invalid address
	sw $t4, charStartAddress

	j jumpDown
jumpDown:
	bgt, $t4, $t3, jumpUpSetup 
	
	jal makeBoardSetup
	jal makeBoardBlue
	jal makeLedges
	
	jal makeCharacter
	jal checkLanding
afterCheckLanding:
	lw $t3, charBottomAddress # load charBottom address into t3 in case it changed
	
	lw $t4, charStartAddress # load back into t4 in case it changed
	addi $t4, $t4, 128
	sw $t4, charStartAddress
	
	lw $t6, 0xffff0000 # load value for keystroke into t7 
	beq $t6, 1, checkInput2 # if there is a keystroke, branch to check j or k
NoInput2:	
	li $v0, 32
	li $a0, 100
	syscall
	
	j jumpDown

checkInput2:
	jal checkJK
	
	li $v0, 32
	li $a0, 100
	syscall

	j jumpDown
	
ledge1Setup:
	lw $t0, ledge1StartAddress
	bgt $t0, $s7, makeLedge1 #if its start address is more than max display address, remake it
	jr $ra
makeLedge1:	
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 26 # set max value of random int
	syscall
	addi $a0, $a0, 6 #add 6 so that 4*random int is at least 24 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 2560 #add soo the ledge is near bottom of screen
	add $t7, $s0, $a0 #add display address + random int to get new start 
	sw $t7, ledge1StartAddress
	
	jr $ra
	
ledge2Setup:
	lw $t0, ledge2StartAddress
	bgt $t0, $s7, makeLedge2 #if its start address is more than max display address, remake it
	
	jr $ra
makeLedge2:	
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 26 # set max value of random int
	syscall
	addi $a0, $a0, 6 #add 6 so that 4*random int is at least 24 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 1792 #add so the ledge isnt too high on the screen
	add $t7, $s0, $a0 #add display address + random int to get new start 
	sw $t7, ledge2StartAddress
	
	jr $ra
	
ledge3Setup:
	lw $t0, ledge3StartAddress
	bgt $t0, $s7, makeLedge3 #if its start address is more than max display address, remake it
	jr $ra
makeLedge3:	
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 26 # set max value of random int to 700
	syscall
	addi $a0, $a0, 6 #add 6 so that 4*random int is at least 24 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 1152 #add so the ledge isnt too high on the screen
	add $t7, $s0, $a0 #add display address + random int to get new start 
	sw $t7, ledge3StartAddress
	
	jr $ra
		
makeLedgesSetup:
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 25 # set max value of random int
	syscall
	addi $a0, $a0, 7 #add 7 so that 4*random int is at least 28 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 3584 #add so the ledge is near bottom of screen
	add $t7, $s0, $a0 #add display address + random int to get new start 
	sw $t7, ledge1StartAddress
	sw $t7, charBottomAddress
	addi $t7, $t7, -128 #use this value for charStartAddress
	sw $t7, charStartAddress
	
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 25 # set max value of random int
	syscall
	addi $a0, $a0, 7 #add 7 so that 4*random int is at least 28 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 2560 #add so the ledge isnt too high on the screen
	add $t7, $s0, $a0 #add display address + random int to get new start 
	sw $t7, ledge2StartAddress
	
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 25 # set max value of random int
	syscall
	addi $a0, $a0, 7 #add 7 so that 4*random int is at least 28 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 1792 #add so the ledge isnt too high on the screen
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
	lw $t7, 0xffff0004 #load keystroke value into t7
	beq $t7, 0x6a, respondToJ #check if it is j
	beq $t7, 0x6b, respondToK #check if it is k
afterRespond:
	jr $ra #go back to jumping
	
respondToJ:
	addi $t4, $t4, -4 #move left 1 pixel
	sw $t4, charStartAddress #save the new address for char
	
	j afterRespond
	
respondToK:
	addi $t4, $t4, 4 #move right one pixel
	sw $t4, charStartAddress #save the new address for char
	
	j afterRespond
	
checkLanding: # load each of the ledges addresses, and check if the doodle has landed on any part of them
	lw $t0, ledge1StartAddress
	lw $t1, ledge2StartAddress
	lw $t2, ledge3StartAddress
	lw $t3, charStartAddress
	
	addi $t7, $t3, 152
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	
	addi $t7, $t3, 128
	bgt $t7, $s7, waitForR #if charStartAddress+128 is more than max address then we lose
	
	sw $s5, charBottomAddress #if we don't land on a ledge, then make bottom back to default
	j afterCheckLanding #return to jumpDown

ledgeNewBase:
	addi $t3, $t3, 128 #add 128 because it will be subtracted in jump up setup
	sw $t3, charStartAddress
	sw $t3, charBottomAddress # since we've landed, make current charStartAddress the new bottom
	jal jumpUpSetup

scroll:
	lw $t7, charBottomAddress	
	addi $t7, $t7, 128
	bge $t7, $s6, doneScrolling #s6 is the max address in first row. $t3 cant go below first row
	sw $t7, charBottomAddress
	
	lw $t0, ledge1StartAddress
	addi $t0, $t0, 128
	sw $t0, ledge1StartAddress
	
	lw $t1, ledge2StartAddress
	addi $t1, $t1, 128
	sw $t1, ledge2StartAddress

	lw $t2, ledge3StartAddress
	addi $t2, $t2, 128
	sw $t2, ledge3StartAddress
	
	addi $t3, $t3, 128 #adjust the max jump height since we scroll down

doneScrolling:
	jal ledge1Setup
	jal ledge2Setup
	jal ledge3Setup

	j afterScroll

waitForR:
	lw $t6, 0xffff0000 # load value for if keystroke into t6 
	beq $t6, 1, checkR # if there is a keystroke, branch to check r
	j waitForR
checkR:
	lw $t7, 0xffff0004 
	beq $t7, 0x72, restartGame # if keystroke was r, then restart the game
	j waitForR # if keystroke wasn't r, keep waiting
restartGame:	
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
	
	jal startGame
	
makeStartScreen:
	add $a0, $zero, $s0
	addi $a0, $a0, 24 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeP
	
	add $a0, $zero, $s0
	addi $a0, $a0, 40 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeR
	
	add $a0, $zero, $s0
	addi $a0, $a0, 56 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeE
	
	add $a0, $zero, $s0
	addi $a0, $a0, 72 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeS
	
	add $a0, $zero, $s0
	addi $a0, $a0, 88 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeS
	
	j exit
	#jal makeE
	#jal makeS
	#jal makeS
	
	#jal makeS
	
	#jal makeT
	#jal makeO
	
	#jal makeS
	#jal makeT
	#jal makeA
	#jal makeR
	#jal makeT
makeP:	
	# make top of P	
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make vertical part of P
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 384($a0) #put colour in pixel
	sw $a1, 512($a0) #put colour in pixel
	
	# make smaller vertical part of P
	sw $a1, 136($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	
	# make middle part of P
	sw $a1, 260($a0) #put colour in pixel
	
	jr $ra # return to make word call
	
makeR:	
	# make top of R
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make vertical part of R
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 384($a0) #put colour in pixel
	sw $a1, 512($a0) #put colour in pixel
	
	# make smaller vertical part of R
	sw $a1, 136($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	# make slant part of R
	sw $a1, 260($a0) #put colour in pixel
	sw $a1, 388($a0) #put colour in pixel
	
	jr $ra # return to make word call
	
makeE:	
	# make top of E
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make vertical part of E
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 384($a0) #put colour in pixel
	sw $a1, 512($a0) #put colour in pixel
	
	# make middle part of E
	sw $a1, 260($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	
	# make bottom part of E
	sw $a1, 516($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	jr $ra # return to make word call
	
makeS:	
	# make top of S
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make left vertical part of S
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	
	# make middle part of S
	sw $a1, 260($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	
	# make right vertical part of S
	sw $a1, 392($a0) #put colour in pixel
	
	# make bottom part of S
	sw $a1, 512($a0) #put colour in pixel
	sw $a1, 516($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	jr $ra # return to make word call
	

CentralProcessing:
	#Check for keyboard input
	#Update the location of the Doodler accordingly
	#Check for collision events (between the Doodler and the screen)
	#Update the location of all platforms and other objects
	#Redraw the screen
	#Sleep.
	#Go back to Step #1
exit:
	li $v0, 10 # terminate the program gracefully
	syscall
