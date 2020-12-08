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
# - Milestone 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# - M41: Score counter that increases each time the doodle moves from one ledge to another
# - M42: Dynamic increase in speed each time a user's score goes up. game gets faster/harder.
# - M51: fancier graphics including start/gameover/restart screen, giraffe doodle, and ledges with legs. 
# - M52: dynamic on screen notifications. good at 5 points, great at 10 points, poggers at 15 points. 
# - M53: moving platform and fragile platform that cannot be landed on.
#
# Link to video demonstration for final submission:
# - https://youtu.be/CQrIrP9wFME
#
# Any additional information that the TA needs to know:
#####################################################################

.data
	displayAddress:	.word	0x10008000
	charStartAddress: .word 0
	charBottomAddress: .word 0 # store the address of bottom address doodle should jump till
	ledge1StartAddress: .word 0
	ledge2StartAddress: .word 0
	ledge3StartAddress: .word 0
	ledge4StartAddress: .word 0
	ledge5StartAddress: .word 0
	score: .word 0
	currentLedge: .word 0
	sleep: .word 100
	
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
	add $s6, $s0, $s6 # never changed
	add $s7, $s0, $s7 # never changed
	j makeStartScreen

# wait for user to enter s to start the game
waitForS:
	lw $t6, 0xffff0000 # load value for if keystroke into t6 
	beq $t6, 1, checkS # if there is a keystroke, branch to check s
	j waitForS #if no keystroke, keep waiting
checkS:
	lw $t7, 0xffff0004 # load the keystorke value
	beq $t7, 0x73, startGame # if keystroke was s, then start the game
	j waitForS # if keystroke wasn't s, keep waiting
	
#start the game by intializing values and drawing necessarys objects	
startGame:
	li $t7, 0
	sw $t7, score #ensure score is 0 when we start/restart a game
	sw $t7, currentLedge #ensure current ledge is reset to 0 on restart
	
	li $t7, 100 
	sw $t7, sleep #ensure sleep is set back on restart
	
	add $t7, $s0, 4036 #128 more than 3908 because 128 will be subtracted in jumpUp
	sw $t7, charStartAddress # store the value of t7 into charStartAddress
	
	li $t7, 4096
	add $t7, $t7, $s0
	sw $t7, charBottomAddress
	lw $s5, charBottomAddress #store the default bottom address
	
	jal makeBoard
	jal initializeLedges
	jal makeLedges
	jal jumpUp

#make the board by colouring the screen blue
makeBoard:
	li $t7, 4096		# total size of board 
	add $t7, $t7, $s0	# set to base address + 4096 offset
	li $t6, 4096		# to keep track of how many pixels we've coloured
	
	j colourBoard # loop over all the pixels and colour them
	
colourBoard:
	subi $t7, $t7, 4
	subi $t6, $t6, 4
	sw $s4, ($t7) # paint each unit
	
	beqz $t6, doneColouringBoard
	j colourBoard
doneColouringBoard:
	jr $ra #return to where makeBoard was called
	
# initialize the start addresses of all the ledges (only used when game is started)
# chooses random numbers and manipulates them to ensure ledges arent on two sides of the screen 
# (they shouldn't go thru the right side of the screen and come out of the left or vice versa)
initializeLedges:
	# initialize ledge1
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 25 # set max value of random int
	syscall
	addi $a0, $a0, 7 # add 7 so that 4*random int is at least 28 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 # multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 3584 # add so the ledge is near bottom of screen
	add $t7, $s0, $a0 # add display address + random int to get new start 
	sw $t7, ledge1StartAddress
	sw $t7, charBottomAddress
	addi $t7, $t7, -128 #use this value for charStartAddress when the game starts
	sw $t7, charStartAddress
	
	# initialize ledge2
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 25 # set max value of random int
	syscall
	addi $a0, $a0, 7 # add 7 so that 4*random int is at least 28 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 # multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 2048 # add so the ledge isnt too high on the screen
	add $t7, $s0, $a0 # add display address + random int to get new start 
	sw $t7, ledge2StartAddress
	
	# initialize ledge3
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 25 # set max value of random int
	syscall
	addi $a0, $a0, 7 # add 7 so that 4*random int is at least 28 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 # multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 512 # add so the ledge isnt too high on the screen
	add $t7, $s0, $a0 # add display address + random int to get new start 
	sw $t7, ledge3StartAddress
	
	# initialize ledge4
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 25 # set max value of random int
	syscall
	addi $a0, $a0, 7 # add 7 so that 4*random int is at least 28 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 # multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 1280 # add so the ledge isnt too high on the screen
	add $t7, $s0, $a0 # add display address + random int to get new start 
	sw $t7, ledge4StartAddress

	# initialize ledge5
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 25 # set max value of random int
	syscall
	addi $a0, $a0, 7 # add 7 so that 4*random int is at least 28 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 # multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 2816 # add so the ledge isnt too high on the screen
	add $t7, $s0, $a0 # add display address + random int to get new start 
	sw $t7, ledge5StartAddress
	
	jr $ra
	
# make all the ledges on the board based on their addresses 	
makeLedges:
	add $a0, $ra, $zero # store the initial return address  
	
	lw $t7, ledge1StartAddress #load the address in
	jal createNormalLedge

	lw $t7, ledge2StartAddress #load the address into t7
	jal createNormalLedge
	
	lw $t7, ledge3StartAddress #load the address into t7
	jal createNormalLedge
	
	# create a broken ledge 
	lw $t7, ledge4StartAddress #load the address into t7
	sw $s2, ($t7) 
	sw $s2, -8($t7) 
	sw $s2, -16($t7)
	sw $s2, -24($t7)
	sw $s3, 104($t7) #put black in for leg
	sw $s3, 128($t7) #put black in for leg
	
	lw $t7, ledge5StartAddress #load the address into t7
	jal createNormalLedge
	
	jr $a0 #since a0 stores the initial return address of the first call we want to return to
	
createNormalLedge:
	#make ledge
	sw $s2, ($t7) 
	sw $s2, -4($t7) 
	sw $s2, -8($t7) 
	sw $s2, -12($t7)
	sw $s2, -16($t7)
	sw $s2, -20($t7)
	sw $s2, -24($t7) 
	
	#make legs of ledge
	sw $s3, 104($t7)  
	sw $s3, 128($t7)
	
	jr $ra

# make doodle jump up, update its address, and scroll the screen
jumpUp:
	lw $t4, charStartAddress
	addi $t4, $t4, -128 # subtract to ensure its a valid address (since the exit condtion of jumping down makes it invalid address)
	sw $t4, charStartAddress
	addi $t3, $t4, -2000 #represents the amount of jump to allow the doodle to do
	j jumpingUp
	
jumpingUp:
	blt, $t4, $t3, jumpDown # branch if t4 goes past max jumping capacity
	
	jal makeBoard
	jal makeLedges
	jal makeCharacter
	jal displayScore
	jal scroll
	
afterScroll:
	addi $t4, $t4, -128 # move the character up one row
	sw $t4, charStartAddress
	
	lw $t6, ledge5StartAddress
	addi $t6, $t6, 4 # make the moving ledge move right
	sw $t6, ledge5StartAddress

	lw $t6, 0xffff0000 # load value for keystroke
	beq $t6, 1, checkInput1 # if there is a keystroke, branch to check j or k

afterCheckInput1:	
	li $v0, 32
	lw $a0, sleep
	syscall
	j jumpingUp
	
checkInput1:
	jal checkJK # check if keystroke was j or k
	j afterCheckInput1
	
# make doodle jump down, update its address, and check its landing
jumpDown:
	lw $t3, charBottomAddress # minimum point the doodle should jump down to
	lw $t4, charStartAddress # load the start address of the doodle
	addi $t4, $t4, 128 #add 256 since the exit condition of jump up made charStartAddress invalid address
	sw $t4, charStartAddress
	j jumpingDown
	
jumpingDown:
	bgt, $t4, $t3, jumpUp # branch once doodle is at its minimum point
	
	jal makeBoard
	jal makeLedges
	jal makeCharacter
	jal displayScore
	jal checkLanding
	
afterCheckLanding:
	lw $t3, charBottomAddress # load charBottom address into t3 in case it changed
	
	lw $t4, charStartAddress # load back into t4 in case it changed
	addi $t4, $t4, 128
	sw $t4, charStartAddress
	
	lw $t6, ledge5StartAddress
	addi $t6, $t6, -4 #make the ledge move left
	sw $t6, ledge5StartAddress
	
	lw $t6, 0xffff0000 # load value for keystroke into t7 
	beq $t6, 1, checkInput2 # if there is a keystroke, branch to check j or k

afterCheckInput2:	
	li $v0, 32
	lw $a0, sleep
	syscall
	j jumpingDown
	
checkInput2:
	jal checkJK
	j afterCheckInput2

# checks if input is j or k (called from both jump up and jump down		
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
	
#draw the character (cute giraffe)
makeCharacter: 
	lw $t7, charStartAddress
	
	# make black legs
	sw $s3, ($t7) 
	sw $s3, -8($t7) 
	sw $s3, -16($t7) 
	
	# make yellow and black body
	sw $s1, -128($t7) 
	sw $s3, -132($t7) 
	sw $s1, -136($t7) 
	sw $s3, -140($t7) 
	sw $s1, -144($t7) 
	sw $s3, -256($t7) 
	sw $s1, -260($t7) 
	sw $s3, -264($t7) 
	sw $s1, -268($t7) 
	sw $s3, -272($t7)
	
	# make neck
	sw $s3, -396($t7) #put golden in pixel in row 3
	sw $s1, -400($t7) #put golden in pixel in row 3
	
	# make head
	sw $s1, -524($t7) #put golden in pixel in row 3
	sw $s3, -528($t7) #put golden in pixel in row 3
	sw $s1, -532($t7) #put golden in pixel in row 3
	
	jr $ra

# display the score by dividing by 10 and showing the remainder		
displayScore:
	lw $t7, score
	li $t6, 10
	li $t5, 112 # initial offset
divide:
	div $t7, $t6
	mflo $t7 #put quotient in
	mfhi $t0 #put remainder in	
	
	add $a0, $s0, $t5 #load offset in
	add $a1, $zero, $s1 #load colour in
	
	beq, $t0, 0, make0
	beq, $t0, 1, make1
	beq, $t0, 2, make2
	beq, $t0, 3, make3
	beq, $t0, 4, make4
	beq, $t0, 5, make5
	beq, $t0, 6, make6
	beq, $t0, 7, make7
	beq, $t0, 8, make8
	beq, $t0, 9, make9
	
afterPrintNumber:
	beqz, $t7, backToJump
	
	addi $t5, $t5, -16 #decrement offset so next number can be printed
	
	j divide

backToJump:
	jr $ra
	
checkLanding: # load each of the ledges addresses, and check if the doodle has landed on any part of them
	lw $t0, ledge1StartAddress
	lw $t1, ledge2StartAddress
	lw $t2, ledge3StartAddress
	lw $t3, charStartAddress
	lw $t5, ledge4StartAddress
	lw $t6, ledge5StartAddress
	
	addi $t7, $t3, 152
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	beq $t7, $t6, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	beq $t7, $t6, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	beq $t7, $t6, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	beq $t7, $t6, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	beq $t7, $t6, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	beq $t7, $t6, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	beq $t7, $t6, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	beq $t7, $t6, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	beq $t7, $t6, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	beq $t7, $t6, ledgeNewBase
	
	addi $t7, $t7, -4
	beq $t7, $t0, ledgeNewBase
	beq $t7, $t1, ledgeNewBase
	beq $t7, $t2, ledgeNewBase
	beq $t7, $t6, ledgeNewBase
	
	#AFTER checking all the valid platforms, check if we landed on a broken platform
	#this is to ensure that if broken ledge coincides with valid ledge, then we should land on valid edge 
	addi $t7, $t3, 152
	beq $t7, $t5, brokenLedge
	addi $t7, $t7, -4
	beq $t7, $t5, brokenLedge
	addi $t7, $t7, -4
	beq $t7, $t5, brokenLedge
	addi $t7, $t7, -4
	beq $t7, $t5, brokenLedge
	addi $t7, $t7, -4
	beq $t7, $t5, brokenLedge
	addi $t7, $t7, -4
	beq $t7, $t5, brokenLedge
	addi $t7, $t7, -4
	beq $t7, $t5, brokenLedge
	addi $t7, $t7, -4
	beq $t7, $t5, brokenLedge
	addi $t7, $t7, -4
	beq $t7, $t5, brokenLedge
	addi $t7, $t7, -4
	beq $t7, $t5, brokenLedge
	addi $t7, $t7, -4
	beq $t7, $t5, brokenLedge
	
	addi $t7, $t3, 128
	bgt $t7, $s7, gameOver #if charStartAddress+128 is more than max address then we lose

noLanding:	
	sw $s5, charBottomAddress #if we don't land on a ledge, then make bottom back to default
	j afterCheckLanding #return to jumpingDown

# if land on broken ledge, then remove the ledge by making its address invalid
brokenLedge:
	lw $t7, ledge4StartAddress
	addi $t7, $t7, 4096 #add amount to make it invalid address (bc we wanna remove it_
	sw $t7, ledge4StartAddress
	j noLanding

# if we land on a ledge, check which one
ledgeNewBase:
	beq $t7, $t0, ledge1Current
	beq $t7, $t1, ledge2Current
	beq $t7, $t2, ledge3Current
	beq $t7, $t6, ledge5Current

afterChangeCurrentLedge:
	addi $t3, $t3, 128 #add 128 because it will be subtracted in jump up setup
	sw $t3, charStartAddress
	sw $t3, charBottomAddress # since we've landed, make current charStartAddress the new bottom
	jal jumpUp
	
# set this to be the current ledge we've landed on and update score and sleep if its different from te previous ledge	
ledge1Current:
	li $t7, 1
	lw $t6, currentLedge # load previous current ledge
	sw $t7, currentLedge # update current ledge
	bne $t6, 1, updateScoreAndSleep #if the landed ledge is different from current ledge, update score
	j afterChangeCurrentLedge

ledge2Current:
	li $t7, 2
	lw $t6, currentLedge # load previous current ledge
	sw $t7, currentLedge # update current ledge
	bne $t6, 2, updateScoreAndSleep #if the landed ledge is different from current ledge, update score
	j afterChangeCurrentLedge

ledge3Current:
	li $t7, 3
	lw $t6, currentLedge # load previous current ledge
	sw $t7, currentLedge # update current ledge
	bne $t6, 3, updateScoreAndSleep #if the landed ledge is different from current ledge, update score
	j afterChangeCurrentLedge
	
ledge5Current:
	li $t7, 5
	lw $t6, currentLedge # load previous current ledge
	sw $t7, currentLedge # update current ledge
	bne $t6, 5, updateScoreAndSleep #if the landed ledge is different from current ledge, update score
	j afterChangeCurrentLedge

# update the score and sleep variables 		
updateScoreAndSleep:
	lw $t7, score
	addi $t7, $t7, 1 #update score since we landed on a ledge
	sw $t7, score
	
	j checkScoreAndPrint
afterCheckScore:	
	lw $t7, sleep
	addi $t7, $t7, -2 #update score since we landed on a ledge
	blt $t7, 30, afterChangeCurrentLedge #if sleep is already at 30, dont let it go more down
	sw $t7, sleep
	j afterChangeCurrentLedge
	
# print a message at certain scores (5, 10, 15)	
checkScoreAndPrint:
	lw $t7, score
	beq $t7, 5, printGood
	beq $t7, 10, printGreat
	beq $t7, 15, printPoggers
	j afterCheckScore	

printGood:
	addi $a0, $s0, 800 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeG
	
	addi $a0, $s0, 816 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeO
	
	addi $a0, $s0, 832 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeO
	
	addi $a0, $s0, 848 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeD
	
	#sleep for a moment so they see the notification
	li $v0, 32
	li $a0, 300
	syscall
	
	j afterCheckScore
	
printGreat:
	addi $a0, $s0, 792 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeG
	
	addi $a0, $s0, 808 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeR
	
	addi $a0, $s0, 824 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeE
	
	addi $a0, $s0, 840 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeA
	
	addi $a0, $s0, 856 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeT
	
	#sleep for a moment so they see the notification
	li $v0, 32
	li $a0, 300
	syscall
	
	j afterCheckScore
	
printPoggers:	
	addi $a0, $s0, 784 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeP
	
	addi $a0, $s0, 800 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeO
	
	addi $a0, $s0, 816 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeG
	
	addi $a0, $s0, 832 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeG
	
	addi $a0, $s0, 848 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeE
	
	addi $a0, $s0, 864 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeR
	
	addi $a0, $s0, 880 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeS
	
	#sleep for a moment so they see the notification
	li $v0, 32
	li $a0, 300
	syscall
	j afterCheckScore

# move each object down by one row so the screen "scrolls"		
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
	
	lw $t7, ledge4StartAddress
	addi $t7, $t7, 128
	sw $t7, ledge4StartAddress
	
	lw $t7, ledge5StartAddress
	addi $t7, $t7, 128
	sw $t7, ledge5StartAddress
	
	addi $t3, $t3, 128 #adjust the max jump height since we scroll down

doneScrolling:
	jal resetLedge1
	jal resetLedge2
	jal resetLedge3
	jal resetLedge4
	jal resetLedge5

	j afterScroll

# resets ledge address if necessary		
resetLedge1:
	lw $t0, ledge1StartAddress
	bgt $t0, $s6, setLedge1Address #if its start address is more than max display address, remake it
	jr $ra
setLedge1Address:	
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
	
# resets ledge address if necessary			
resetLedge2:
	lw $t0, ledge2StartAddress
	bgt $t0, $s6, setLedge2Address #if its start address is more than max display address, remake it
	
	jr $ra
setLedge2Address:	
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 26 # set max value of random int
	syscall
	addi $a0, $a0, 6 #add 6 so that 4*random int is at least 24 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 2048 #add so the ledge isnt too high on the screen
	add $t7, $s0, $a0 #add display address + random int to get new start 
	sw $t7, ledge2StartAddress
	
	jr $ra

# resets ledge address if necessary			
resetLedge3:
	lw $t0, ledge3StartAddress
	bgt $t0, $s6, setLedge3Address #if its start address is more than max display address, remake it
	jr $ra
setLedge3Address:	
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 26 # set max value of random int to 700
	syscall
	addi $a0, $a0, 6 #add 6 so that 4*random int is at least 24 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 1536 #add so the ledge isnt too high on the screen
	add $t7, $s0, $a0 #add display address + random int to get new start 
	sw $t7, ledge3StartAddress
	
	jr $ra
	
# resets ledge address if necessary			
resetLedge4:
	lw $t0, ledge4StartAddress
	bgt $t0, $s6, setLedge4Address #if its start address is more than max display address, remake it
	jr $ra
setLedge4Address:	
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 26 # set max value of random int to 700
	syscall
	addi $a0, $a0, 6 #add 6 so that 4*random int is at least 24 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 512 #add so the ledge isnt too high on the screen
	add $t7, $s0, $a0 #add display address + random int to get new start 
	sw $t7, ledge4StartAddress
	
	jr $ra

# resets ledge address if necessary		
resetLedge5:
	lw $t0, ledge5StartAddress
	bgt $t0, $s6, setLedge5Address #if its start address is more than max display address, remake it
	
	jr $ra
setLedge5Address:	
	li $v0, 42 # prepare syscall to produce random int
	li $a0, 0 
	li $a1, 26 # set max value of random int
	syscall
	addi $a0, $a0, 6 #add 6 so that 4*random int is at least 24 (number of pixels in a ledge is 28)
	sll $a0, $a0, 2 #multiply the random int by 4 to ensure its a multiple of 4 to use with displayAddress
	addi $a0, $a0, 1024 #add so the ledge isnt too high on the screen
	add $t7, $s0, $a0 #add display address + random int to get new start 
	sw $t7, ledge5StartAddress
	
	jr $ra

gameOver:
	j makeGameOverScreen
waitForR:
	lw $t6, 0xffff0000 # load value for if keystroke into t6 
	beq $t6, 1, checkR # if there is a keystroke, branch to check r
	j waitForR
checkR:
	lw $t7, 0xffff0004 
	beq $t7, 0x72, restartGame # if keystroke was r, then restart the game
	j waitForR # if keystroke wasn't r, keep waiting
restartGame:	
	j startGame
	
makeGameOverScreen:
	jal makeBoard
	
	addi $a0, $s0, 32 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeG
	
	addi $a0, $s0, 48 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeA
	
	addi $a0, $s0, 64 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeM
	
	addi $a0, $s0, 80 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeE
	
	addi $a0, $s0, 800 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeO
	
	addi $a0, $s0, 816 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeV
	
	addi $a0, $s0, 832 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeE
	
	addi $a0, $s0, 848 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeR
	
	addi $a0, $s0, 1688 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeP
	
	addi $a0, $s0, 1704 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeR
	
	addi $a0, $s0, 1720 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeE
	
	addi $a0, $s0, 1736 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeS
	
	addi $a0, $s0, 1752 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeS
	
	add $a0, $zero, $s0
	addi $a0, $a0, 2472 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeR
	
	addi $a0, $s0, 2496 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeT
	
	addi $a0, $s0, 2512 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeO
	
	addi $a0, $s0, 3212 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeR
	
	addi $a0, $s0, 3228 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeE
	
	addi $a0, $s0, 3244 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeS
	
	addi $a0, $s0, 3260 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeT
	
	addi $a0, $s0, 3276 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeA
	
	addi $a0, $s0, 3292 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeR
	
	addi $a0, $s0, 3308 #put offset into a0
	add $a1, $zero, $s1 #put desired colour into a1 
	jal makeT
	
	j waitForR
	
makeStartScreen:
	addi $a0, $s0, 24 #put offset into a0
	add $a1, $zero, $s4 #put desired colour into a1 
	jal makeP
	
	addi $a0, $s0, 40 #put offset into a0
	add $a1, $zero, $s4 #put desired colour into a1 
	jal makeR
	
	addi $a0, $s0, 56 #put offset into a0
	add $a1, $zero, $s4 #put desired colour into a1 
	jal makeE
	
	addi $a0, $s0, 72 #put offset into a0
	add $a1, $zero, $s4 #put desired colour into a1 
	jal makeS
	
	addi $a0, $s0, 88 #put offset into a0
	add $a1, $zero, $s4 #put desired colour into a1 
	jal makeS
	
	addi $a0, $s0, 824 #put offset into a0
	add $a1, $zero, $s4 #put desired colour into a1 
	jal makeS
	
	addi $a0, $s0, 1584 #put offset into a0
	add $a1, $zero, $s4 #put desired colour into a1 
	jal makeT
	
	addi $a0, $s0, 1600 #put offset into a0
	add $a1, $zero, $s4 #put desired colour into a1 
	jal makeO
	
	addi $a0, $s0, 2328 #put offset into a0
	add $a1, $zero, $s4 #put desired colour into a1 
	jal makeS
	
	addi $a0, $s0, 2344 #put offset into a0
	add $a1, $zero, $s4 #put desired colour into a1 
	jal makeT
	
	addi $a0, $s0, 2360 #put offset into a0
	add $a1, $zero, $s4 #put desired colour into a1 
	jal makeA
	
	addi $a0, $s0, 2376 #put offset into a0
	add $a1, $zero, $s4 #put desired colour into a1 
	jal makeR
	
	addi $a0, $s0, 2392 #put offset into a0
	add $a1, $zero, $s4 #put desired colour into a1 
	jal makeT
	
	j waitForS

make0:	
	# make top of 0
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make left vertical part of 0
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 384($a0) #put colour in pixel
	sw $a1, 512($a0) #put colour in pixel
	
	# make bottom part of 0
	sw $a1, 516($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	# make right vertical part of 0
	sw $a1, 136($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 392($a0) #put colour in pixel
	
	j afterPrintNumber #go back after printing
	
make1:	
	# make top of 1
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	
	# make vertical part of 1
	sw $a1, 132($a0) #put colour in pixel
	sw $a1, 260($a0) #put colour in pixel
	sw $a1, 388($a0) #put colour in pixel
	sw $a1, 516($a0) #put colour in pixel
	
	j afterPrintNumber #go back after printing

make2:	
	# make top of 2
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make right vertical part of 2
	sw $a1, 136($a0) #put colour in pixel
	
	# make middle part of 2
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 260($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	
	# make left vertical part of 2
	sw $a1, 384($a0) #put colour in pixel
	
	# make bottom part of 2
	sw $a1, 512($a0) #put colour in pixel
	sw $a1, 516($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	j afterPrintNumber #go back after printing
	
make3:	
	# make top of 3
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make vertical part of 3
	sw $a1, 136($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 392($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	# make middle part of 3
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 260($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	
	# make bottom part of 3
	sw $a1, 512($a0) #put colour in pixel
	sw $a1, 516($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	j afterPrintNumber #go back after printing
	
make4:	
	# make left vertical part of 4
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	
	# make middle part of 4
	sw $a1, 260($a0) #put colour in pixel
	
	# make right vertical part of 4
	sw $a1, 8($a0) #put colour in pixel
	sw $a1, 136($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 392($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	j afterPrintNumber #go back after printing
	
make5:	
	# make top of 5
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make left vertical part of 5
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	
	# make middle part of 5
	sw $a1, 260($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	
	# make right vertical part of 5
	sw $a1, 392($a0) #put colour in pixel
	
	# make bottom part of 5
	sw $a1, 512($a0) #put colour in pixel
	sw $a1, 516($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	j afterPrintNumber #go back after printing
	
make6:
	# make top of 6
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make vertical part of 6
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 384($a0) #put colour in pixel
	sw $a1, 512($a0) #put colour in pixel
	
	# make middle part of 6
	sw $a1, 260($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 392($a0) #put colour in pixel
	
	# make bottom part of 6
	sw $a1, 516($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	j afterPrintNumber #go back after printing
	
make7:	
	# make top of 7
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	sw $a1, 128($a0) #put colour in pixel
	
	# make vertical part of 7
	sw $a1, 136($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 392($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	j afterPrintNumber #go back after printing

make8:	
	# make top of 8
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make right vertical part of 8
	sw $a1, 136($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 392($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	# make left vertical part of 8
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 384($a0) #put colour in pixel
	sw $a1, 512($a0) #put colour in pixel
	
	# make middle part of 8
	sw $a1, 260($a0) #put colour in pixel
	
	# make bottom part of 8
	sw $a1, 516($a0) #put colour in pixel
	
	j afterPrintNumber #go back after printing
	
make9:	
	# make top of 9
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make right vertical part of 9
	sw $a1, 136($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 392($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	# make left vertical part of 9
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 512($a0) #put colour in pixel
	
	# make middle part of 9
	sw $a1, 260($a0) #put colour in pixel
	
	# make bottom part of 9
	sw $a1, 516($a0) #put colour in pixel
	
	j afterPrintNumber #go back after printing
	
makeA:	
	# make left vertical part of A
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 384($a0) #put colour in pixel
	sw $a1, 512($a0) #put colour in pixel
	
	# make middle parts of A
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 260($a0) #put colour in pixel
	
	# make right vertical part of A
	sw $a1, 8($a0) #put colour in pixel
	sw $a1, 136($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 392($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	jr $ra # return to make word call

makeD:	
	# make top of D
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	
	# make left vertical part of D
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 384($a0) #put colour in pixel
	sw $a1, 512($a0) #put colour in pixel
	
	# make bottom part of D
	sw $a1, 516($a0) #put colour in pixel

	
	# make right vertical part of D
	sw $a1, 136($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 392($a0) #put colour in pixel
	
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

makeG:	
	# make top of G
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make left vertical part of G
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 384($a0) #put colour in pixel
	sw $a1, 512($a0) #put colour in pixel
	
	# make bottom part of G
	sw $a1, 516($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	# make right vertical part of G
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 392($a0) #put colour in pixel
	
	jr $ra # return to make word call	

makeH:	
	# make left vertical part of H
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 384($a0) #put colour in pixel
	sw $a1, 512($a0) #put colour in pixel
	
	# make middle part of H
	sw $a1, 260($a0) #put colour in pixel
	
	# make right vertical part of H
	sw $a1, 8($a0) #put colour in pixel
	sw $a1, 136($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 392($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	jr $ra # return to make word call
	
makeM:	
	# make left vertical part of M
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 384($a0) #put colour in pixel
	sw $a1, 512($a0) #put colour in pixel
	
	# make middle part of M
	sw $a1, 132($a0) #put colour in pixel
	
	# make right vertical part of M
	sw $a1, 8($a0) #put colour in pixel
	sw $a1, 136($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 392($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	jr $ra # return to make word call
	
makeO:	
	# make top of O
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make left vertical part of O
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 384($a0) #put colour in pixel
	sw $a1, 512($a0) #put colour in pixel
	
	# make bottom part of O
	sw $a1, 516($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	# make right vertical part of O
	sw $a1, 136($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 392($a0) #put colour in pixel
	
	jr $ra # return to make word call
	
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
	
makeT:	
	# make top of T
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make vertical part of T
	sw $a1, 132($a0) #put colour in pixel
	sw $a1, 260($a0) #put colour in pixel
	sw $a1, 388($a0) #put colour in pixel
	sw $a1, 516($a0) #put colour in pixel
	
	jr $ra # return to make word call

makeV:	
	# make top of V
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make left vertical part of V
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 256($a0) #put colour in pixel
	sw $a1, 384($a0) #put colour in pixel
	
	# make bottom part of V
	sw $a1, 516($a0) #put colour in pixel
	
	# make right vertical part of V
	sw $a1, 136($a0) #put colour in pixel
	sw $a1, 264($a0) #put colour in pixel
	sw $a1, 392($a0) #put colour in pixel
	
	jr $ra # return to make word call
	
makeY:	
	# make top of Y
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	sw $a1, 128($a0) #put colour in pixel
	sw $a1, 136($a0) #put colour in pixel
	
	# make vertical part of Y
	sw $a1, 260($a0) #put colour in pixel
	sw $a1, 388($a0) #put colour in pixel
	sw $a1, 516($a0) #put colour in pixel
	
	jr $ra # return to make word call
	
makeZ:	
	# make top of Z
	sw $a1, 0($a0) #put colour in pixel
	sw $a1, 4($a0) #put colour in pixel
	sw $a1, 8($a0) #put colour in pixel
	
	# make right side of Z
	sw $a1, 136($a0) #put colour in pixel
	
	# make left side of Z
	sw $a1, 384($a0) #put colour in pixel
	
	# make middle part of Z
	sw $a1, 260($a0) #put colour in pixel
	
	# make bottom part of Z
	sw $a1, 512($a0) #put colour in pixel
	sw $a1, 516($a0) #put colour in pixel
	sw $a1, 520($a0) #put colour in pixel
	
	jr $ra # return to make word call
	
exit:
	li $v0, 10 # terminate the program gracefully
	syscall
