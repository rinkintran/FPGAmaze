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
.EQU PS2_ERROR_MASK      = 0x01     ;*NEW
.EQU PS2_DATA_READY_MASK = 0x02     ;*NEW

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

.EQU ICOUNT = 0x03
.EQU FB_HADD = 0x90
.EQU FB_LADD = 0x91
.EQU FB_COLOR = 0x92
;------------------------------------------------------------------

;------------------------------------------------------------------
;- Register Usage Key
;------------------------------------------------------------------
;- r1 --- temp register
;- r2 --- holds keyboard input
;- r3 --- temp register for scratch ram (Possibly Delete)
;- r4 --- stack pointer
;- r5 --- next location value
;- r6 --- holds drawing color
;- r7 --- main Y location value
;- r8 --- main X location value
;- r9 --- ending X/Y Coordinate
;- r12 --- status *NEW
;- r13 --- interrupt count *NEW
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

         CALL   vert                    ;pushes all vertical lines into stack
         MOV    r4, 0x00                ;starts r4 as stack pointer at 0xFF
drawv:   LD     r8, (r4)                ;loads start x coordinate into r8
         ADD    r4, 0x01                ;increments stack pointer by 0x01
         LD     r7, (r4)                ;loads start y coordinate into r7
         ADD    r4, 0x01                ;increments stack pointer by 0x01
         LD     r9, (r4)                ;loads end y coordinate into r9
         ADD    r4, 0x01                ;increments stack pointer by 0x01
         MOV    r6, GREEN
         CALL   draw_vertical_line      ;draws the vertical line
         CMP    r4, 0x2D                ;compares stack pointer to end of vertical lines(255-45=210)
         BRNE   drawv                   

		 MOV	r27, r4
         CALL   horiz                   ;pushes all horizontal lines into stack, above vert lines
drawh:   LD     r7, (r4)                ;loads start y coordinate into r7
         ADD    r4, 0x01                ;increments stack pointer by 0x01
         LD     r8, (r4)                ;loads start x coordinate into r8
		 ADD    r4, 0x01                ;increments stack pointer by 0x01
         LD     r9, (r4)                ;loads end x coordinate into r9
         ADD    r4, 0x01                ;increments stack pointer by 0x01
         MOV    r6, GREEN
         CALL   draw_horizontal_line    ;draws the horizontal line
         CMP    r4, 0x51                ;compares stack pointer to end of horizontal lines(210-36=174)
         BRNE   drawh        
		 MOV	r28, r4

		 SEI
		 MOV	r0, 0x00
		 MOV	r7, 0x01				; puts dot at the maze's start
		 MOV	r8, 0x01
		 MOV	r6, BLUE
		 MOV	r19, 0x00
		 CALL	draw_dot

foreground:
		 CMP	r0, 0x00
		 BRN	foreground



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
         ADD    r9, 0x01
draw_horiz1:
         CALL   draw_dot
         ADD    r8,0x01
         CMP    r8,r9
         BRNE   draw_horiz1
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

horiz:  MOV r29, 0x00   ;y position
        MOV r30, 0x00   ;starting x position
        MOV r31, 0x0E   ;ending x position
        ST  r29, (r28)  ;puts y position to stack from the top
        ADD r28, 0x01   ;increments stack pointer by 1
        ST  r30, (r28)  ;puts starting x position to stack
        ADD r28, 0x01   ;increments stack pointer by 1
        ST  r31, (r28)  ;puts ending x position to stack
        ADD r28, 0x01   ;increments stack pointer by 1

        ST  r29, (r28)  ;line 1
        ADD r28, 0x01   ;
        MOV r30, 0x13   ;start 19
        MOV r31, 0x27   ;end 39
        ST  r30, (r28)
        ADD r28, 0x01
        ST  r31, (r28)
        ADD r28, 0x01
        
        MOV r29, 0X04   ;line 4
        MOV r30, 0x09   ;start 9
        MOV r31, 0x0E   ;end 14
        ST  r29, (r28)
        ADD r28, 0x01
        ST  r30, (r28)
        ADD r28, 0x01
        ST  r31, (r28)
        ADD r28, 0x01
        
        ST  r29, (r28)  ;line 4
        ADD r28, 0x01
        MOV r30, 0x13   ;start 14
        MOV r31, 0x1D   ;end 29 
        ST  r30, (r28)
        ADD r28, 0x01
        ST  r31, (r28)
        ADD r28, 0x01
        
        MOV r29, 0X09   ;line 9
        MOV r30, 0x04   ;start 4
        MOV r31, 0x18   ;end 24
        ST  r29, (r28)
        ADD r28, 0x01
        ST  r30, (r28)
        ADD r28, 0x01
        ST  r31, (r28)
        ADD r28, 0x01
        
        MOV r29, 0X0E   ;line 14
        MOV r30, 0x0E   ;start 14
        MOV r31, 0x13   ;end 19
        ST  r29, (r28)
        ADD r28, 0x01
        ST  r30, (r28)
        ADD r28, 0x01
        ST  r31, (r28)
        ADD r28, 0x01
        
		ST  r29, (r28)        ;line 14
        ADD r28, 0x01
        MOV r30, 0x18   ;start 24
        MOV r31, 0x22   ;end 34
        ST  r30, (r28)
        ADD r28, 0x01
        ST  r31, (r28)
        ADD r28, 0x01
        
        MOV r29, 0X13   ;line 19
        MOV r30, 0x04   ;start 4
        MOV r31, 0x09   ;end 9
        ST  r29, (r28)
        ADD r28, 0x01
        ST  r30, (r28)
        ADD r28, 0x01
        ST  r31, (r28)
        ADD r28, 0x01
        
        ST  r29, (r28)  ;line 19
        ADD r28, 0x01
        MOV r30, 0x1D   ;start 29
        MOV r31, 0x27   ;end 39
        ST  r30, (r28)
        ADD r28, 0x01
        ST  r31, (r28)
        ADD r28, 0x01

        MOV r29, 0X18   ;line 24
        MOV r30, 0x04   ;start 4
        MOV r31, 0x13   ;end 19
        ST  r29, (r28)
        ADD r28, 0x01
        ST  r30, (r28)
        ADD r28, 0x01
        ST  r31, (r28)
        ADD r28, 0x01

        MOV r29, 0X1D   ;line 29
        MOV r30, 0x00   ;start 0
        MOV r31, 0x13   ;end 19
        ST  r29, (r28)
        ADD r28, 0x01
        ST  r30, (r28)
        ADD r28, 0x01
        ST  r31, (r28)
        ADD r28, 0x01
        
        ST  r29, (r28)  ;line 29
        ADD r28, 0x01
        MOV r30, 0x18   ;start 24
        MOV r31, 0x27   ;end 39
        ST  r30, (r28)
        ADD r28, 0x01
        ST  r31, (r28)
        ADD r28, 0x01
        
    
        RET
; --------------------------------------------------------------------
vert:   MOV r28, 0x00   ;initialize r28 as stack pointer to 0x00
        MOV r29, 0x00   ;line 0 (x)
        MOV r30, 0x00   ;start 0
        MOV r31, 0x1D   ;end 29
        ST r29, (r28)   ;store in stack
        ADD r28, 0x01   ;increment
        ST r30, (r28)   ;store in stack
        ADD r28, 0x01   ;increment
        ST r31, (r28)   ;store in stack
        ADD r28, 0x01   ;increment

        MOV r29, 0x04   ;line 4
        MOV r30, 0x04   ;start 4
        MOV r31, 0x09   ;end 9
        ST r29, (r28)
        ADD r28, 0x01   ;increment
        ST r30, (r28)
        ADD r28, 0x01   ;increment
        ST r31, (r28)
        ADD r28, 0x01   ;increment

        ST r29, (r28)   ;line 4
        ADD r28, 0x01   ;increment
        MOV r30, 0x0E   ;start 14
        MOV r31, 0x13   ;end 19
        ST r30, (r28)   
        ADD r28, 0x01   ;increment
        ST r31, (r28)
        ADD r28, 0x01   ;increment

        MOV r29, 0x09   ;line 9
        MOV r30, 0x00   ;start 0
        MOV r31, 0x04   ;end 4
        ST r29, (r28)
        ADD r28, 0x01   ;increment
        ST r30, (r28)
        ADD r28, 0x01   ;increment
        ST r31, (r28)
        ADD r28, 0x01   ;increment

        ST r29, (r28)   ;line 9
        ADD r28, 0x01   ;increment
        MOV r30, 0x09   ;start 9
        MOV r31, 0x0E   ;end 14
        ST r30, (r28)
        ADD r28, 0x01   ;increment
        ST r31, (r28)
        ADD r28, 0x01   ;increment
    
        ST r29, (r28)   ;line 9
        ADD r28, 0x01   ;increment
        MOV r30, 0x13   ;start 19
        MOV r31, 0x18   ;end 24
        ST r30, (r28)
        ADD r28, 0x01   ;increment
        ST r31, (r28)
        ADD r28, 0x01   ;increment

        MOV r29, 0x0E   ;line 14
        MOV r30, 0x0E   ;start 14
        MOV r31, 0x13   ;end 19
        ST r29, (r28)
        ADD r28, 0x01   ;increment
        ST r30, (r28)
        ADD r28, 0x01   ;increment
        ST r31, (r28)
        ADD r28, 0x01   ;increment

        MOV r29, 0x13   ;line 19
        MOV r30, 0x04   ;start 4
        MOV r31, 0x09   ;end 9
        ST r29, (r28)
        ADD r28, 0x01   ;increment
        ST r30, (r28)
        ADD r28, 0x01   ;increment
        ST r31, (r28)
        ADD r28, 0x01   ;increment

        ST r29, (r28)   ;line 19
        ADD r28, 0x01   ;increment
        MOV r30, 0x0E   ;start 14
        MOV r31, 0x1D   ;end 29
        ST r30, (r28)
        ADD r28, 0x01   ;increment
        ST r31, (r28)
        ADD r28, 0x01   ;increment
    
        MOV r29, 0x18   ;line 24
        MOV r30, 0x09   ;start 9
        MOV r31, 0x1D   ;end 29
        ST r29, (r28)
        ADD r28, 0x01   ;increment
        ST r30, (r28)
        ADD r28, 0x01   ;increment
        ST r31, (r28)
        ADD r28, 0x01   ;increment

        MOV r29, 0x1D   ;line 29
        MOV r30, 0x04   ;start 4
        MOV r31, 0x09   ;end 9
        ST r29, (r28)
        ADD r28, 0x01   ;increment
        ST r30, (r28)
        ADD r28, 0x01   ;increment
        ST r31, (r28)
        ADD r28, 0x01   ;increment

        ST r29, (r28)        ;line 29
        ADD r28, 0x01   ;increment
        MOV r30, 0x13   ;start 19
        MOV r31, 0x18   ;end 24
        ST r30, (r28)
        ADD r28, 0x01   ;increment
        ST r31, (r28)
        ADD r28, 0x01   ;increment

        MOV r29, 0x22   ;line 34
        MOV r30, 0x04   ;start 4
        MOV r31, 0x0E   ;end 14
        ST r29, (r28)
        ADD r28, 0x01   ;increment
        ST r30, (r28)
        ADD r28, 0x01   ;increment
        ST r31, (r28)
        ADD r28, 0x01   ;increment

        ST r29, (r28)        ;line 34
        ADD r28, 0x01   ;increment
        MOV r30, 0x18   ;start 24
        MOV r31, 0x1D   ;end 29
        ST r30, (r28)
        ADD r28, 0x01   ;increment
        ST r31, (r28)
        ADD r28, 0x01   ;increment
        
        MOV r29, 0x27   ;line 39
        MOV r30, 0x00   ;start 0
        MOV r31, 0x1D   ;end 29
        ST r29, (r28)
        ADD r28, 0x01   ;increment
        ST r30, (r28)
        ADD r28, 0x01   ;increment
        ST r31, (r28)
        ADD r28, 0x01   ;increment

        RET

;------------------------------------------------------------

;------------------------------------------------------------
;- These subroutines add and/or subtract '1' from the given 
;- X or Y value, depending on the direction the blit was 
;- told to go. The trick here is to not go off the screen
;- so the blit is moved only if there is room to move the 
;- blit without going off the screen.  
;- 
;- Tweaked Registers: possibly r7; possibly r8
;------------------------------------------------------------
sub_x:   ;CMP   r8,LO_X      ; see if you can move left
         ;BREQ  done1        ; branch if it hits the end
         MOV   r1, r8       ; store value of r8
         SUB   r8, 0x01     ; make r8 be the next coordinate
         MOV   r5, r8       ; place coordinate into register to check
         MOV   r8, r1       ; restore previous coordinate
         ;CALL   move_x
		 CALL  wall_check_x ; checks to see if there is a wall
done1:   RET

sub_y:   ;CMP   r7,LO_Y    ; see if you can move down
         ;BREQ  done2
         MOV   r1, r7
         SUB   r7, 0x01
         MOV   r5, r7
         MOV   r7, r1
		 ;CALL move_y
         CALL wall_check_y ; checks for horizontal wall
done2:   RET
 
add_x:   ;CMP   r8,HI_X    ; see if you can move right
         ;BREQ  done3
         MOV   r1, r8       ; store value of r8
         ADD   r8, 0x01     ; make r8 be the next coordinate
         MOV   r5, r8       ; place coordinate into register to check
         MOV   r8, r1       ; restore previous coordinate
         ;CALL move_x
		 CALL  wall_check_x ; checks to see if there is a wall
done3:   RET

add_y:   ;CMP   r7,HI_Y    ; see if you can move up
         ;BREQ  done4
         MOV   r1, r7
         ADD   r7, 0x01
         MOV   r5, r7
         MOV   r7, r1
		 ;CALL move_y
         CALL wall_check_y ; checks for horizontal wall
done4:   RET
;---------------------------------------------------------
;-- The Following Code Below is the Old Etch a Sketch
;---------------------------------------------------------

Keyboard:     
		  IN   R2, PS2_KEY_CODE
		  OUT  R2, SSEG

		  MOV  r19, 0x00

move_up:  CMP   r2, UP               ; decode keypress value
          BRNE  move_down         
          CALL  sub_y                ; verify move is possible - this is correct
          BRN   reset_ps2_register

move_down:
          CMP   r2, DOWN
          BRNE  move_left         
          CALL  add_y                ; verify move - this is correct
          BRN   reset_ps2_register

move_left:
          CMP   r2, LEFT
          BRNE  move_right        
          CALL  sub_x                ; verify move
          BRN   reset_ps2_register

move_right:
          CMP   r2, RIGHT
          BRNE	reset_ps2_register
		  ;BRNE  key_up_check                  
          CALL  add_x                ; verify move
          BRN   reset_ps2_register

;key_up_check:
          ;CMP   r2, KEY_UP
          ;BRNE  reset_ps2_register


move_x:   MOV	r6,0x00
		  CALL	draw_dot
		  MOV   r8,r5
		  MOV	r6,BLUE
          CALL  draw_dot
          BRN   reset_ps2_register

move_y:   MOV	r6,0x00
		  CALL	draw_dot
		  MOV   r7,r5
		  MOV	r6,BLUE
          CALL  draw_dot
          BRN   reset_ps2_register

reset_ps2_register:
          MOV   r10,0x01
          OUT   r10,PS2_CONTROL
          MOV   r10,0x00
          OUT   r10,PS2_CONTROL
          RETIE


;------------------------------------------------------------

;------------------------------------------------------------
;- These subroutines runs through the scratch ram and checks to 
;- see if the unit runs into a wall.
;------------------------------------------------------------

wall_check_x:   MOV r4,0x00         ; move address 0xFD to r4
                BRN hor_checkx     ; check for a vertical wall to the left/right

wall_check_y:   MOV r4,r27          ; move the address of the "first" y value of the horizontal walls into r4
                BRN vert_checky    ; check for a horizontal wall to the top/bottom

hor_checkx: LD r29,(r4)         ; put the x coordinate of the wall into r5
            ADD r4, 0x01        ; increment the stack
            LD r30,(r4)         ; put the beginning y coordinate into r6
            ADD r4,0x01         ; increment the stack
            LD r31,(r4)			; put the ending y coordinate into r31
			ADD r4,0x01			; increment r4 so it is at the address of the next y coord
            ADD r31,0x01        ; increment r7 so that the whole wall can be checked
            CMP r4,r27          ; compare if the stack pointer is at the end of the hor walls
            BREQ move_x         ; if true, move the dot
            CMP r5,r29          ; compare the if the new coordinate can hit the wall
            BREQ hor_checky     ; if true, check if it hits the wall
            BRN hor_checkx      ; loop

hor_checky: CMP r30,r7          ; check if wall's y and dot's y are the same
            BREQ reset_ps2_register          ; if the same, cannot move
            ADD r30,0x01        ; increment wall's y coordinate
            CMP r30,r31         ; check if at the ending y coordinate
            BREQ hor_checkx     ; if true, check the next x coordinate
            BRN hor_checky      ; loop

vert_checky:LD r29,(r4)         ; put the y coordinate of wall into r6
            ADD r4,0x01         ; increment stack
            LD r30,(r4)         ; put the beginning x coordinate into r5
            ADD r4,0x01         ; increment stack
            LD r31,(r4)         ; put the ending x coordinate into r7
            ADD r31,0x01        ; increment r7 so that the whole wall can be checked
            ADD r4,0x01         ; increment r4 so that it is the address of the next x coord
            CMP r4,r28          ; compare if stack pointer is at the end of the ver walls
            BREQ move_y         ; if true, move
            CMP r5,r29          ; compare if the new coordinate can hit the wall
            BREQ vert_checkx    ; if true, check if it hits the wall
            BRN vert_checky     ; loop

vert_checkx:CMP r30,r7          ; check if wall's x and dot's x are the same
            BREQ reset_ps2_register         ; if the same, cannot move
            ADD r30,0x01        ; increment the wall's x coordinate
            CMP r30,r31         ; check if at the ending x coordinate
            BREQ vert_checky    ; if true, check the next y coordinate
            BRN vert_checkx     ;loop



My_ISR:
	MOV R18, 0x00
	ADD R19, 0x01
	CMP R19, ICOUNT ; Each key press generates 3 interrupts, so only read the last one
    BREQ Keyboard

; --------------------------------------------------------------------
; interrupt vector
; --------------------------------------------------------------------
.CSEG
.ORG 0x3FF
BRN My_ISR

;------------------------------------------------------------
;- Red Etch a Sketch Code that was tested before *NEW
;------------------------------------------------------------
;init:
 ;  SEI
  ; MOV  R0, 0x00
   ;MOV  R1, 0x00
;   MOV  R7, 0x0F  ;the y origin (CHANGE TO THE STARTING POSITION *UNCHANGED*)
 ;  MOV  R8, 0x14  ;UNCHANGED X COORD ORIGIN
  ; MOV  R4, R7   ;y coordin
   ;MOV  R5, R8   ;x coordin
;   MOV  R6, 0xE0 ;Red color
 ;  MOV	R18, 0x00 ;For debug
  ; MOV  R19, 0x00
   ;CALL draw_dot   ;draw red square at origin

;CheckKeyboard:
  

 ;  OR R18, 0x01
  ; OUT R18, LEDS
   ;MOV R19, 0x00

;   IN   R2, PS2_KEY_CODE
 ;  OUT  R2, SSEG
  ; CMP  R2, UP
   ;BREQ move_up
;   CMP  R2, DOWN
 ;  BREQ move_down
  ; CMP  R2, RIGHT
   ;BREQ move_right
;   CMP  R2, LEFT
 ;  BREQ move_left
  ; CMP	R2, 0xF0
   ;BREQ no_move	
;   BRN  PROCESS_DATA_RETURN

;no_move:
 ;  OR R18, 0x10
  ; OUT R18, LEDS
   ;BRN PROCESS_DATA_RETURN

;move_up:
 ;  OR R18, 0x02
  ; OUT R18, LEDS
   
;   CALL sub_y

   ;SUB  R7, 0x01
   ;MOV  R4, R7   ;y coordin
   ;MOV  R5, R8   ;x coordin   
   ;CALL draw_dot
 ;  BRN  PROCESS_DATA_RETURN

;move_down:
 ;  OR R18, 0x04
  ; OUT R18, LEDS

   ;CALL add_y

   ;ADD  R7, 0x01
   ;MOV  R4, R7   ;y coordin
   ;MOV  R5, R8   ;x coordin
   ;CALL draw_dot
   ;BRN  PROCESS_DATA_RETURN


;move_left:
 ;  OR R18, 0x08
  ; OUT R18, LEDS

;   CALL sub_x

   ;SUB  R8, 0x01
   ;MOV  R4, R7   ;y coordin
   ;MOV  R5, R8   ;x coordin
   ;CALL draw_dot
;   BRN  PROCESS_DATA_RETURN

;move_right:
 ;  OR R18, 0x08
  ; OUT R18, LEDS

;   call add_x

   ;ADD  R8, 0x01
   ;MOV  R4, R7   ;y coordin
   ;MOV  R5, R8   ;x coordin
   ;CALL draw_dot
;   BRN  PROCESS_DATA_RETURN

; --------------------------------------------------------------------
; Interrupts service routine *NEW
; --------------------------------------------------------------------
;My_ISR:
;	MOV R18, 0x00
;	ADD R19, 0x01
;	CMP R19, ICOUNT ; Each key press generates 3 interrupts, so only read the last one
 ;   BREQ CheckKeyboard
       
	
;PROCESS_DATA_RETURN: 

;	MOV r10, 0x01           
;	OUT r10, PS2_CONTROL    ;set the PS2_DATA_READY flag (this may not be necessary)
;	MOV r10, 0x00           
;	OUT r10, PS2_CONTROL    ;clear the PS2_DATA_READY flag
;	RETIE

; --------------------------------------------------------------------
; interrupt vector *NEW
; --------------------------------------------------------------------
;.CSEG
;.ORG 0x3FF
;BRN My_ISR
