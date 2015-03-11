@@ -0,0 +1,526 @@
.CSEG 
.ORG 0X01

;------------------------------------------------------------
; Various key parameter constants
;------------------------------------------------------------
.EQU UP       = 0x1D     ; 'w' 
.EQU LEFT     = 0x1C     ; 'a'
.EQU RIGHT    = 0x23     ; 'd'
.EQU DOWN     = 0x1B     ; 's'
;------------------------------------------------------------

;------------------------------------------------------------
; Various screen parameter constants for 40x30 screen
;------------------------------------------------------------
.EQU LO_X    = 0x00
.EQU HI_X    = 0x27
.EQU LO_Y    = 0x00
.EQU HI_Y    = 0x1D
;------------------------------------------------------------

;------------------------------------------------------------
; Various screen I/O constants
;------------------------------------------------------------
.EQU LEDS                = 0x40     ; LED array
.EQU SSEG                = 0x81     ; 7-segment decoder 
.EQU SWITCHES            = 0x20     ; switches 

.EQU PS2_CONTROL         = 0x46     ; ps2 control register 
.EQU PS2_KEY_CODE        = 0x44     ; ps2 data register
.EQU PS2_STATUS          = 0x45     ; ps2 status register

;.EQU VGA_HADD            = 0x90     ; high address register
;.EQU VGA_LADD            = 0x91     ; low address register
;.EQU VGA_COLOR           = 0x92     ; color value register
;------------------------------------------------------------

;------------------------------------------------------------------
; Various drawing constants
;------------------------------------------------------------------
;.EQU BG_COLOR    = 0xE0            ; Background:  red
.EQU RED          = 0xE0            ; color data: red
.EQU BLUE         = 0x03            ; color data: blue 
.EQU GREEN        = 0x1C            ; color data: green 
;------------------------------------------------------------------

;------------------------------------------------------------------
; Various Constant Definitions
;------------------------------------------------------------------
.EQU KEY_UP     = 0xF0        ; key release data
.EQU int_flag   = 0x01        ; interrupt hello from keyboard
;------------------------------------------------------------------

;------------------------------------------------------------------
;- Register Usage Key
;------------------------------------------------------------------
;- r1 --- temp register
;- r2 --- holds keyboard input
;- r3 --- temp register for scratch ram
;- r4 --- stack pointer
;- r5 --- next location value
;- r6 --- holds drawing color
;- r7 --- main Y location value
;- r8 --- main X location value
;- r9 --- ending X/Y Coordinate
;- r10 --- 2nd temp register for scratch ram
;- r11 --- 3rd temp register for scratch ram
;- r15 --- for interrupt flag 
;- r21 --- saves current switch settings
;- r27 --- "first" y coordinate of the vertical wall
;- r28 --- "last" y coordinate of the vertical wall
;- r29 --- Single X/Y
;- r30 --- Start X/Y
;- r31 --- End X/Y
;------------------------------------------------------------------

;---------------------------------------------------------------------
;- Subrountine: draw_dot
;- 
;- This subroutine draws a dot on the display the given coordinates: 
;- 
;- (X,Y) = (r8,r7)  with a color stored in r6  
;- 
;- Tweaked registers: r4,r5
;---------------------------------------------------------------------
;draw_dot2: 

;           OUT   r8,VGA_LADD   ; write bot 8 address bits to register
;           OUT   r7,VGA_HADD   ; write top 3 address bits to register
;           OUT   r6,VGA_COLOR  ; write data to frame buffer
;           RET

; --------------------------------------------------------------------

;---------------------------------------------------------------------
;-Constant declarations
;---------------------------------------------------------------------
.EQU VGA_YADD  = 0x90
.EQU VGA_XADD  = 0x91
.EQU VGA_COLOR = 0x92
;.EQU BG_COLOR  = 0x03             ; Background:  blue

;---------------------------------------------------------------------
;- register definitions 
;---------------------------------------------------------------------
;- r6 is used for color
;- r7 is used for working Y coordinate
;- r8 is used for working X coordinate


;---------------------------------------------------------------------
main:    

		 CALL 	vert 					;pushes all vertical lines into stack
drawv:	 	 MOV 	r4, 0xFF				;starts r4 as stack pointer at 0xFF
		 LD 	r7, (r4)				;loads start x coordinate into r7
		 SUB 	r4, 0x01 				;decrements stack pointer by 0x01
		 LD 	r8, (r4)				;loads start y coordinate into r8
		 SUB 	r4, 0x01 				;decrements stack pointer by 0x01
		 LD	r9, (r4)				;loads end y coordinate into r9
		 SUB 	r4, 0x01 				;decrements stack pointer by 0x01
		 MOV 	r6, GREEN
		 CALL 	draw_vertical_line			;draws the vertical line
		 CMP	r4, 0xD2				;compares stack pointer to end of vertical lines(255-45=210)
		 BRNE	drawv					

		 CALL 	horiz					;pushes all horizontal lines into stack, above vert lines
drawh:	  	 LD 	r7, (r4)				;loads start y coordinate into r7
		 SUB 	r4, 0x01 				;decrements stack pointer by 0x01
		 LD	r8, (r4)				;loads start x coordinate into r8
		 SUB 	r4, 0x01 				;decrements stack pointer by 0x01
		 LD 	r9, (r4) 				;loads end x coordinate into r9
		 SUB 	r4, 0x01 				;decrements stack pointer by 0x01
		 MOV 	r6, GREEN
		 CALL 	draw_horizontal_line 			;draws the horizontal line
		 CMP 	r4, 0xAE				;compares stack pointer to end of horizontal lines(210-36=174)
		 BRNE	drawh 					

;--------------------------------------------------------------------

;---------------------------------------------------------------------
;-  Subroutine: draw_vertical_line
;-
;-  Draws a horizontal line from (r8,r7) to (r8,r9) using color in r6. 
;-   This subroutine works by consecutive calls to drawdot, meaning
;-   that a vertical line is nothing more than a bunch of dots. 
;-
;-  Parameters:
;-   r8  = x-coordinate
;-   r7  = starting y-coordinate
;-   r9  = ending y-coordinate
;-   r6  = color used for line
;- 
;- Tweaked registers: r7,r9
;--------------------------------------------------------------------
draw_vertical_line:
         ;enter your code here
         ADD     r9, 0x01
draw_vert1:
         CALL    draw_dot
         ADD     r7, 0x01
         CMP     r7, r9
         BRNE    draw_vert1
         RET
;--------------------------------------------------------------------

draw_horizontal_line:
		 ADD 	r9, 0x01
draw_horiz1:
		 CALL	draw_dot
		 ADD	r8,0x01
		 CMP	r8,r9
		 BRNE	draw_horiz1
		 RET

;---------------------------------------------------------------------
    
;---------------------------------------------------------------------
;- Subrountine: draw_dot
;- 
;- This subroutine draws a dot on the display at the given coordinates: 
;- 
;- (X,Y) = (r8,r7)  with a color stored in r6  
;---------------------------------------------------------------------
draw_dot: 
           OUT   r8,VGA_XADD   ; write x address bits
           OUT   r7,VGA_YADD   ; write y address bits
           OUT   r6,VGA_COLOR  ; write data to frame buffer
           RET
; --------------------------------------------------------------------

; --------------------------------------------------------------------
horiz: 		MOV r29, 0x00	;y position
		MOV r30, 0x00	;starting x position
		MOV r31, 0x0E	;ending x position
		PUSH r29	;puts y position to stack
		PUSH r30	;puts starting x position to stack
		PUSH r31	;puts ending x position to stack
		
		PUSH r29	;line 1
		MOV r30, 0x13	;start 19
		MOV r31, 0x27	;end 39
		PUSH r30
		PUSH r31
		
		MOV r29, 0X04	;line 4
		MOV r30, 0x09	;start 9
		MOV r31, 0x0E	;end 14
		PUSH r29
		PUSH r30
		PUSH r31
		
		PUSH r29		;line 4
		MOV r30, 0x13	;start 14
		MOV	r31, 0x1D	;end 29 
		PUSH r30
		PUSH r31
		
		MOV r29, 0X09	;line 9
		MOV r30, 0x04	;start 4
		MOV	r31, 0x18	;end 24
		PUSH r29
		PUSH r30
		PUSH r31
		
		MOV r29, 0X0E	;line 14
		MOV r30, 0x0E	;start 14
		MOV	r31, 0x13	;end 19
		PUSH r29
		PUSH r30
		PUSH r31
		
		PUSH r29		;line 14
		MOV r30, 0x18	;start 24
		MOV	r31, 0x22	;end 34
		PUSH r30
		PUSH r31
		
		MOV r29, 0X13	;line 19
		MOV r30, 0x04	;start 4
		MOV	r31, 0x09	;end 9
		PUSH r29
		PUSH r30
		PUSH r31
		
		PUSH r29		;line 19
		MOV r30, 0x1D	;start 29
		MOV	r31, 0x27	;end 39
		PUSH r30
		PUSH r31

		MOV r29, 0X18	;line 24
		MOV r30, 0x04	;start 4
		MOV	r31, 0x13	;end 19
		PUSH r29
		PUSH r30
		PUSH r31

		MOV r29, 0X1D	;line 29
		MOV r30, 0x00	;start 0
		MOV	r31, 0x13	;end 19
		PUSH r29
		PUSH r30
		PUSH r31
		
		PUSH r29		;line 29
		MOV r30, 0x18	;start 24
		MOV	r31, 0x27	;end 39
		PUSH r30
		PUSH r31
	
		RET
; --------------------------------------------------------------------
vert:	MOV r29, 0x00	;line 0 (x)
		MOV r30, 0x00	;start 0
		MOV r31, 0x1D	;end 29
		PUSH r29
		PUSH r30
		PUSH r31

		MOV r29, 0x00	;line 4
		MOV r30, 0x04	;start 4
		MOV r31, 0x09	;end 9
		PUSH r29
		PUSH r30
		PUSH r31

		PUSH r29		;line 4
		MOV r30, 0x0E	;start 14
		MOV	r31, 0x13	;end 19
		PUSH r30
		PUSH r31

		MOV r29, 0x09	;line 9
		MOV r30, 0x00	;start 0
		MOV r31, 0x04	;end 4
		PUSH r29
		PUSH r30
		PUSH r31

		PUSH r29		;line 9
		MOV r30, 0x09	;start 9
		MOV	r31, 0x0E	;end 14
		PUSH r30
		PUSH r31
	
		PUSH r29		;line 9
		MOV r30, 0x13	;start 19
		MOV	r31, 0x18	;end 24
		PUSH r30
		PUSH r31

		MOV r29, 0x0E	;line 14
		MOV r30, 0x0E	;start 14
		MOV r31, 0x13	;end 19
		PUSH r29
		PUSH r30
		PUSH r31

		MOV r29, 0x13	;line 19
		MOV r30, 0x04	;start 4
		MOV r31, 0x09	;end 9
		PUSH r29
		PUSH r30
		PUSH r31

		PUSH r29		;line 19
		MOV r30, 0x0E	;start 14
		MOV	r31, 0x1D	;end 29
		PUSH r30
		PUSH r31
	
		MOV r29, 0x13	;line 24
		MOV r30, 0x09	;start 9
		MOV r31, 0x1D	;end 29
		PUSH r29
		PUSH r30
		PUSH r31

		MOV r29, 0x13	;line 29
		MOV r30, 0x04	;start 4
		MOV r31, 0x09	;end 9
		PUSH r29
		PUSH r30
		PUSH r31

		PUSH r29		;line 29
		MOV r30, 0x13	;start 19
		MOV	r31, 0x18	;end 24
		PUSH r30
		PUSH r31

		MOV r29, 0x13	;line 34
		MOV r30, 0x04	;start 4
		MOV r31, 0x0E	;end 14
		PUSH r29
		PUSH r30
		PUSH r31

		PUSH r29		;line 34
		MOV r30, 0x18	;start 24
		MOV	r31, 0x1D	;end 29
		PUSH r30
		PUSH r31
		
		MOV r29, 0x00	;line 39
		MOV r30, 0x00	;start 0
		MOV r31, 0x1D	;end 29
		PUSH r29
		PUSH r30
		PUSH r31

		RET

;------------------------------------------------------------
;- These subroutines add and/or subtract '1' from the given 
;- X or Y value, depending on the direction the blit was 
;- told to go. The trick here is to not go off the screen
;- so the blit is moved only if there is room to move the 
;- blit without going off the screen.  
;- 
;- Tweaked Registers: possibly r7; possibly r8
;------------------------------------------------------------
sub_x:   CMP   r8,LO_X      ; see if you can move left
         BREQ  done1	    ; branch if it hits the end
	     MOV   r1, r8       ; store value of r8
		 SUB   r8, 0x01     ; make r8 be the next coordinate
	     MOV   r5, r8       ; place coordinate into register to check
		 MOV   r8, r1       ; restore previous coordinate
	     CALL  wall_check_x ; checks to see if there is a wall
done1:   RET

sub_y:   CMP   r7,LO_Y    ; see if you can move down
         BREQ  done2
		 MOV   r1, r7
		 SUB   r7, 0x01
		 MOV   r5, r7
		 MOV   r7, r1
		 CALL wall_check_y ; checks for horizontal wall
done2:   RET
 
add_x:   CMP   r8,HI_X    ; see if you can move right
         BREQ  done3
		 MOV   r1, r8       ; store value of r8
		 SUB   r8, 0x01     ; make r8 be the next coordinate
	     MOV   r5, r8       ; place coordinate into register to check
		 MOV   r8, r1       ; restore previous coordinate
	     CALL  wall_check_x ; checks to see if there is a wall
done3:   RET

add_y:   CMP   r7,HI_Y    ; see if you can move up
         BREQ  done4
		 MOV   r1, r7
		 SUB   r7, 0x01
		 MOV   r5, r7
		 MOV   r7, r1
		 CALL wall_check_y ; checks for horizontal wall
done4:   RET
;---------------------------------------------------------

Keyboard: CMP   r15, int_flag        ; check key-up flag 
          BRNE  continue
          MOV   r15, 0x00            ; clean key-up flag
          BRN   reset_ps2_register       

continue: IN    r2, PS2_KEY_CODE     ; get keycode data
          OUT	r2, SSEG

move_up:  CMP   r2, UP               ; decode keypress value
          BRNE  move_down 		  
          CALL  sub_y                ; verify move is possible
		  BRN   keyboard

move_down:
          CMP   r2, DOWN
          BRNE  move_left 		  
          CALL  add_y                ; verify move
		  BRN   keyboard

move_left:
          CMP   r2, LEFT
          BRNE  move_right 		  
          CALL  sub_x                ; verify move
		  BRN   keyboard

move_right:
          CMP   r2, RIGHT
          BRNE  key_up_check		  		  
          CALL  add_x                ; verify move
		  BRN   keyboard

key_up_check:
		  CMP	r2, KEY_UP
		  BRNE	reset_ps2_register


move_x:	  MOV   r8,r5
		  CALL  draw_dot
		  BRN   reset_ps2_register
		  RET

move_y:	  MOV   r7,r5
		  CALL  draw_dot
		  BRN   reset_ps2_register
		  RET

reset_ps2_register:
		  MOV	r3,0x01
		  OUT	r3,PS2_CONTROL
		  MOV	r3,0x00
		  OUT 	r3,PS2_CONTROL
		  EXOR	r16,0x20
		  OUT	r16,LEDS
		  RETIE


;------------------------------------------------------------

;------------------------------------------------------------
;- These subroutines runs through the scratch ram and checks to 
;- see if the unit runs into a wall.
;------------------------------------------------------------

wall_check_x:	MOV r4,0xFD			; move address 0xFD to r4
				CALL hor_checkx		; check for a vertical wall to the left/right

wall_check_y:	MOV r4,r27			; move the address of the "first" y value of the horizontal walls into r4
				CALL vert_checky	; check for a horizontal wall to the top/bottom

hor_checkx:	LD r29,(r4)			; put the x coordinate of the wall into r5
			ADD r4, 0x01			; increment the stack
			LD r30,(r4)			; put the beginning y coordinate into r6
			ADD r4,0x01			; increment the stack
			LD r31,(r4)
			ADD r31,0x01		; increment r7 so that the whole wall can be checked
			SUB r4,0x05			; change r4 so that it is the address of the next x coordinate
			CMP r4,r27			; compare if the stack pointer is at the end of the hor walls
			BREQ move_x			; if true, move the dot
			CMP r5,r29			; compare the if the new coordinate can hit the wall
			BREQ hor_checky		; if true, check if it hits the wall
			BRN hor_checkx		; loop

hor_checky:	CMP r30,r8			; check if wall's x and dot's x are the same
			BREQ keyboard		; if the same, cannot move
			ADD r30,0x01		; increment wall's y coordinate
			CMP r30,r31			; check if at the ending y coordinate
			BREQ hor_checkx		; if true, check the next x coordinate
			BRN hor_checky		; loop

vert_checky:LD r29,(r4)			; put the y coordinate of wall into r6
			ADD r4,0x01			; increment stack
			LD r30,(r4)			; put the beginning x coordinate into r5
			ADD r4,0x01			; increment stack
			LD r31,(r4)			; put the ending x coordinate into r7
			ADD r31,0x01		; increment r7 so that the whole wall can be checked
			SUB r4,0x05			; change r4 so that it is the address of the next x coordinate
			CMP r4,r28			; compare if stack pointer is at the end of the ver walls
			BREQ move_y			; if true, move
			CMP r5,r29			; compare if the new coordinate can hit the wall
			BREQ vert_checkx	; if true, check if it hits the wall
			BRN vert_checky		; loop

vert_checkx:CMP r30,r7			; check if wall's y and dot's y are the same
			BREQ keyboard		; if the same, cannot move
			ADD r30,0x01		; increment the wall's x coordinate
			CMP r30,r31			; check if at the ending x coordinate
			BREQ vert_checky	; if true, check the next y coordinate
			BRN vert_checkx		;loop
