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
	li $t1, 0x00ff00	# $t1 stores the lime colour code
	li $t2, 0x00ff00	# $t2 stores the green colour code
	li $t3, 0x0000ff	# $t3 stores the blue colour code
	li $t4, 0xffffff        # $t4 stores the white colour code
	li $t5, 4096		# total size of board and the last unit of the display
	add $t5, $t5, $t0
	li $t6, 4096
makeBoardWhite:
	#sw $t4, ($t5)	 # paint each unit white
	subi $t5, $t5, 4
	subi $t6, $t6, 4
	sw $t4, ($t5)
	beqz $t6, CentralProcessing
	j makeBoardWhite
	#sw $t4, 4($t0)	 # paint the second unit on the first row green. Why $t0+4?
	#sw $t4, 128($t0) # paint the first unit on the second row blue. Why +128? 256/8 = 32, 32*4 = 128
makeCharacter:
	
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