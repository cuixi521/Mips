#GameStart of Catching (catcher need to catch the target with same colour)
#Xi Cui  xxc161130
.data
#set size of screen to get $gp (bitmap: unit pixel 16*16, window Screen display 512*512)
ScreenWidth: .word 32			
ScreenHeight:.word 32	

#store the initial position of catcher	
upperX:   .word 30	        
upperY:   .word 30	
underX:   .word 30
underY:   .word 31

#store score and message for dialog
score:  .word 0
msg: .asciiz "Your score: "
#store colors
upperColour:		.word 0x00F4D03F  		
underColour:             .word 0x00CCFF99
background:		.word 0x00A9E2F3

.text
#Screen initialize : $s0 store the upper position of catcher; $s1 store the under position of catcher 
#Game control: "a": move left; "s": move down; "d": move right; "w": move up
#              "e": end the game; "j": change colour upside-down
Main:
			lw $s6, upperColour	# Store uppercolour in s6
			lw $s7, background	# Store background colour in s7
			
			lw $a0, upperX 		# Get catcher upper possition
			lw $a1, upperY			
			jal PositionAddress	# Calculate possition Address on screen
			nop
			
			move $s0, $v0		# Store upper possition in s0
			
			lw $a0, underX 		# Get catcher under possition
			lw $a1, underY			
			jal PositionAddress	# Calculate possition Address on screen
			nop
			
			move $s1, $v0		# Store under possition in s1
			
			move $a0, $s7		# Fill screen background colour
			jal FillScreen
			nop
# Draw the catcher			
			move $a0, $s6		#colour stored in $a0	
			move $a1, $s0		#position stored in $a1
			jal Painting		#call painting funcion
			nop
				                 	
			li $a0, 0x00CCFF99
			move $a1, $s1		
			jal Painting		
			nop
#Waitting keyboard input to start game 			
MainWait:
			jal Sleep		# Wait
			nop
			lw $t0, 0xFFFF0000	# Retrieve transmitter
			blez $t0, MainWait	# Check if a key was pressed
			nop
GameStart:
#Create the target at random position from top
Target:	
#$s2 stroe the right hand of the target; $s3 store the left hand of the target	
			li $v0, 42		# use syscall 42 to get a random integer
			li $a0, 1
			li $a1, 31           
			syscall
			nop		
		
			sll $a0, $a0, 2		# converto the position on screen
			add $s2, $a0, $gp	# get left position
			addi $s3, $s2, 4		# get riht position
			nop
#Draw Target:				
			li $a0, 0x00CCFF99	#colour stored in $a0	
			move $a1, $s2		#position stored in $a1
              	  	jal Painting		#call painting funcion
              	  	nop
                
                		li $a0, 0x00F4D03F	#colour stored in $a0
			move $a1, $s3
                		jal Painting
                		nop
                		
#Set Target falling down:                
	        		li $t9, 0
Fall:           
			bgt $t9, 31, GameOver	#check if the target fall to the lower bound of screen
               		nop
               		
			jal Sleep		#is actually the falling speed
	       		move $a0, $s2         	#right hand move down
                		li $a1, 1		#move 1 bit
                		jal MoveDown
                		nop
                 
                		move $s4, $v0		#$s4 store the new position of right hand
               
                		move $a0, $s3		#left hand move down
                		li $a1, 1
                		jal MoveDown
                		nop
                
                		move $s5, $v0		#$s5 store the new position of left hand
#Check catching correct target: gain point or loose the game?              
                		lw $t4, ($s4)		#get the colour of new right position
                		lw $t2, ($s2)        	#get the colour of old right position
                		beq $t2, $t4, riPoint	#check if target has been caught and get score
                	
                		lw $t5,($s5)  		#get the colour of new left position	
                		lw $t3, ($s3)	   	#get the colour of old left position                		         
	        		beq $t3, $t5, lePoint  	#check if target has been caught and get score
	        		  
	        		bne $t4, $t5, GameOver	#gameover if did not catch the right target
#Print the new position of target(ie. let the target falling down)	                            
	Print:            
          		move $a0, $s7		#colour stored in $a0
			move $a1, $s2
                		jal Painting
                		nop 
                             
                		move $a0, $s7		#colour stored in $a0
			move $a1, $s3
                		jal Painting
                		nop 
                          
          		li $a0, 0x00CCFF99	#colour stored in $a0
			move $a1, $s4
                		jal Painting
                                     
                		li $a0, 0x00F4D03F	#colour stored in $a0
			move $a1, $s5
                		jal Painting
                		nop
                                                                         
                		move $s2, $s4		#update target right position
                		move $s3, $s5		#update target left position
                		nop
                		
               		addi $t9, $t9, 1 	#count the falling steps
                		b Direction 		#make sure the target keep falling after getting direction      	
                		j Fall
                
        riPoint:
        #play sound when gain a point
        			li $a0, 60		#pitch
			li $a1,300		#time
			li $a2,32 		#instumanets
			li $a3,100		#volume
			li $v0,33		#syscall to beep with pause
			syscall 
	
			li $a0, 72		#pitch
			li $a1,300
			li $a2,32 
			li $a3,100
			li $v0,33		#syscall to beep with pause
			syscall 
		
	        		move $a0, $s7
			move $a1, $s2
                		jal Painting
                		nop 
	#let the target keep falling                          
                		move $a0, $s7		#print the old position to background color
			move $a1, $s3
                		jal Painting
                		nop 
                
                		move $a0, $t4		#colour stored in $a0
			move $a1, $s4
                		jal Painting
                                     
                		move $a0, $s7
			move $a1, $s5
                		jal Painting
                		nop
          #add score     
                		lw $t8, score
                		addi $t8, $t8, 1
                		sw $t8, score                
                		nop
                
                		j Target      		#get a new target 
	
	lePoint:
			li $a0, 61		#pitch
			li $a1,400		#time
			li $a2,32 		#instumanets
			li $a3,100		#volume
			li $v0,33		#syscall to beep with pause
			syscall 
	
	        		move $a0, $s7
			move $a1, $s2
                		jal Painting
               		nop 
                             
                		move $a0, $s7
			move $a1, $s3
                		jal Painting
                		nop 
                
                		move $a0, $s7
			move $a1, $s4
                		jal Painting
                                     
                		move $a0, $t5
			move $a1, $s5
                		jal Painting
                		nop
                
                		lw $t8, score
                		addi $t8, $t8, 1
                		sw $t8, score
                		nop
                
                		j Target      		#get a new target 
				
Direction: 	
			jal GetDir		#get direction from keyboard
                         beq $v0, $zero, Fall    	#if no input from keyboard let target keep falling
			nop
			move $t6, $v0		#store direction from keyboard
			
			move $a0, $s0		#Load possition
			li $a1, 2		#Set distance to move
			nop
			                                  
	MainRight:
			bne $t6, 0x01000000, MainUp
			nop
			jal MoveRight					
			nop
			j DirDone
			nop
	MainUp:
			bne $t6, 0x02000000, MainLeft
			nop
			jal MoveUp			
			nop
			j DirDone
			nop
	MainLeft:
			bne $t6, 0x03000000, MainDown
			nop
			jal MoveLeft			
			nop
			j DirDone
			nop
	MainDown:
			bne $t6, 0x04000000, MainChange
			nop
			jal MoveDown		
			nop
			j DirDone
			nop
			
	MainChange:             
			bne $t6, 0x05000000, MainNone
			nop
			j Change			
			nop
	MainNone:
			b MainRight
			nop
	DirDone:
			move $a0, $s7		# fill old position with backgraound colour
			move $a1, $s0		
			jal Painting
			nop
			
			add $s1, $s0, 128
			
			move $a0, $s7
			move $a1, $s1
			jal Painting
			nop		          
			
			move $s0, $v0     	#update new position of catcher
			add $s1, $s0, 128
			
			move $a0, $s6		#draw new position of catcher
			move $a1, $s0		
			jal Painting
			
			li $a0, 0x00CCFF99
			move $a1, $s1
			jal Painting
			nop
			           				
			j Fall	
			
	Change:	
	#exchange the colour upside-down		
			lw $a2,($s1)		#load the color of under part
			lw $a0, ($s0)         	#paint the under part with upper colour
			move $a1, $s1
			jal Painting
			nop
			
			move $a0, $a2		#paint the upper part with under colour
			move $a1, $s0
			jal Painting	
			nop
			
			j Fall			#target keep falling																																
GameOver:
	#Play ending music
			jal Music	
	PrintScore:
			li $v0 56          	#output a dialog with score message
			la $a0 msg
			lw $a1 score
			syscall	
	
	End:		li $v0, 10		#Syscall terminate
			syscall
#############################[ Fuctions ]###############################
Sleep:
		ori $v0, $zero, 32		# Syscall sleep
		ori $a0, $zero, 120		# For this many miliseconds
		syscall
		jr $ra				# Return
		nop
#------------------------------------------------------------------------			
Painting:
		sw $a0, ($a1)			# Set colour
		jr $ra				# Return
#--------------------------------------------------------------------------------					
PositionAddress:
		move $v0, $a0			# Move x to v0
		lw $a0, ScreenWidth		# Load the screen width into a0
		mulu  $a0, $a0, $a1		# Multiply y by the screen width
		
		addu $v0, $v0, $a0		# Add the result to the x coordinate and store in v0
		sll $v0, $v0, 2			# Multiply v0 by 4 (bytes) using a logical shift
		addu $v0, $v0, $gp		# Add gp to v0 to give stage memory address
		
		jr $ra				# Return
		nop
#************************** Move *******************************************************************		
# a0: address to move; a1: move distance; return v0: new position address
MoveRight:
		move $v0, $a0			# Move address to v0
		sll $a0, $a1, 2			# Multiply distance by 4 using a logical shift
		add $v0, $v0, $a0		# Move Right
		jr $ra				# Return
		nop
#-----------------------------------------------------------------------------------------------
MoveUp:
		move $v0, $a0			# Move address to v0
		lw $a0, ScreenWidth		# Load the screen width into a0
		mulu $a0, $a0, $a1		# Multiply distance by screen width
		nop

		sll $a0, $a0, 2			# Multiply v0 by 4
		subu $v0, $v0, $a0		# Move Up
		jr $ra				# Return
		nop
#--------------------------------------------------------------------------------------------
MoveLeft:
		move $v0, $a0			# Move address to v0
		sll $a0, $a1, 2			# Multiply distance by 4
		subu $v0, $v0, $a0		# Move Left
		jr $ra				
		nop
#--------------------------------------------------------------------------------------------###
MoveDown:
		move $v0, $a0		        	# Move address to v0
		lw $a0, ScreenWidth		# Load the screen width into a0
		mulu $a0, $a0, $a1	        # Multiply distance by screen width
		nop

		sll $a0, $a0, 2			# Multiply v0 by 4 
		addu $v0, $v0, $a0		# Move down
		jr $ra				
		nop
#******************* Direction ****************************************************************
GetDir:
		move      $v0, $zero
        		li $t1, 0xFFFF0000              	# load the keboard 
	
		lw	$t0,	($t1)		# check whether keybroad used
		beq	$t0,	$zero,	Direction_done # if there is no enter return to the main function
		lw	$t0,	4($t1)
#check the diection:					
Direction_right:
		bne $t0, 100, Direction_up		
		nop
		li $v0, 0x01000000	
		j Direction_done
		nop
Direction_up:
		bne $t0, 119, Direction_left
		nop
		li $v0, 0x02000000	
		j Direction_done
		nop
Direction_left:
		bne $t0, 97, Direction_down
		nop
		li $v0, 0x03000000	
		j Direction_done
		nop
Direction_down:
		bne $t0, 115, Direction_change
		nop
		li $v0, 0x04000000	
		j Direction_done
		nop
		
Direction_change:	
		bne $t0, 106, Direction_none
		nop
		li $v0, 0x05000000	
		j Direction_done
		nop	
		
Direction_none:    
		bne, $t0, 102, GameOver		#"e" to end the game
						
Direction_done:
		jr $ra				
		nop
#******************** Fill ************************************************************
FillScreen:
		lw $a1, ScreenWidth		# Calculate max uppper bound
		lw $a2, ScreenHeight
		mulu $a2, $a1, $a2               # Multiply screen width
				
		nop
		sll $a2, $a2, 2			# Multiply by 4
		add $a2, $a2, $gp		# Add to screen position
		
		move $a1, $gp			
				
FillScreen_loop:	
		sw $a0, ($a1)			# Paint the color
		add $a1, $a1, 4			# move to next right position
		blt $a1, $a2, FillScreen_loop	# Paint one row for one loop 
		nop
		
		jr $ra				
		nop
#******************* Music **************************************************
Music:	
#Play ending music by using the syscall 33 beep
#a0: pitch; a1: duration in milliseconds; a2: instrument; a3: volume
        		li $a0, 69
		li $a1,400
		li $a2,32 
		li $a3,100
		li $v0,33
		syscall 
		
        		li $a0, 71
		li $a1,400
		li $a2,32 
		li $a3,100
		li $v0,33
		syscall 
		
         	li $a0, 72
		li $a1,300
		li $a2,32 
		li $a3,100
		li $v0,33
		syscall 
		
		li $a0, 72
		li $a1,400
		li $a2,32 
		li $a3,100
		li $v0,33
		syscall 
				
		li $a0, 71
		li $a1,300
		li $a2,32 
		li $a3,100
		li $v0,33
		syscall 
		
    		li $a0, 72
		li $a1,500
		li $a2,32 
		li $a3,100
		li $v0,33
		syscall 
		
        		li $a0, 76
		li $a1,600
		li $a2,32 
		li $a3,150
		li $v0,33
		syscall 
		
		li $a0, 71
		li $a1,600
		li $a2,32 
		li $a3,100
		li $v0,33
		syscall 
		
		jr $ra		
		nop
