    cpu	8048
	org 400h
	include "g7000.h"

	; BIOS routines in g7000.h
	jmp     selectgame				    ; reset
	jmp     irq						    ; interrupt
	jmp     timer					    ; timer
	jmp     vsyncirq				    ; VSYNC-interrupt
	jmp     main					    ; start main program
	jmp     soundirq				    ; sound-interrupt

; Internal RAM variables
iram_score_start        equ     020h    ; First 8 bits of score
iram_score_end          equ     021h    ; Second 8 bits of score
animation_flag			equ     022h    ; animation_flag



; Page 1 - Initialization routines (except grid) and main loop
    align   256


; Timer not used
timer:
    ret


; Handles program flow
main:
    call    gfxoff                      ; turn off graphics while editing vdc
    call    init_grid                   ; create maze
    call    init_sprites                ; create sprites
    call    game_loop                   ; main game loop


; Initializes sprite VDCs and copies onto screen
init_sprites:
    
    ; Sprite 0 Control $00-$03
    ; Sprite 1 Control $04-$07
    ; Sprite 2 Control $08-$0B
    ; Sprite 3 Control $0C-$0F

    ; KC Sprite
    mov     r0,#vdc_spr0_shape         
    mov     r1,#kc_neutral & 0ffh    
    mov     r7,#8
    call    copy_sprite
    mov     r0,#000h                    ; y position set
    movx    a,@r0
    mov     a,#130
    movx    @r0,a
    mov     r0,#001h                    ; x position set
    movx    a,@r0 
    mov     a,#75
    movx    @r0,a
    mov     r0,#002h                    ; color
    movx    a,@r0
    mov     a,#col_spr_cyan
    movx    @r0,a 

    ; Ghost Sprite 1
    mov     r0,#vdc_spr1_shape         
    mov     r1,#ghost_left_1 & 0ffh    
    mov     r7,#8
    call    copy_sprite
    mov     r0,#004h                    ; y position set
    movx    a,@r0
    mov     a,#100
    movx    @r0,a
    mov     r0,#005h                    ; x position set
    movx    a,@r0 
    mov     a,#70
    movx    @r0,a
    mov     r0,#006h                    ; color
    movx    a,@r0
    mov     a,#col_spr_red
    movx    @r0,a 

    ; Ghost Sprite 2
    mov     r0,#vdc_spr2_shape         
    mov     r1,#ghost_right_2 & 0ffh    
    mov     r7,#8
    call    copy_sprite
    mov     r0,#008h                    ; y position set
    movx    a,@r0
    mov     a,#100
    movx    @r0,a
    mov     r0,#009h                    ; x position set
    movx    a,@r0 
    mov     a,#80
    movx    @r0,a
    mov     r0,#00Ah                    ; color
    movx    a,@r0
    mov     a,#col_spr_blue
    movx    @r0,a 

    ; Miru Sprite
    mov     r0,#vdc_spr3_shape         
    mov     r1,#miru_left_1 & 0ffh    
    mov     r7,#8
    call    copy_sprite
    mov     r0,#00Ch                    ; y position set
    movx    a,@r0
    mov     a,#70
    movx    @r0,a
    mov     r0,#00Dh                    ; x position set
    movx    a,@r0 
    mov     a,#75
    movx    @r0,a
    mov     r0,#00Eh                    ; color
    movx    a,@r0
    mov     a,#col_spr_green
    movx    @r0,a 

    ret


; Page 2
    align 256
; Loop that runs for every game frame
game_loop:
    
    ; Activate collision check for kc sprite on next frame
    mov     r0,#vdc_collision
    mov     a,#vdc_coll_spr0
    movx    @r0,a 

    ; Advance one frame
    call    gfxon
    call    waitvsync            
    call    gfxoff

    ; Check collision and move sprite back if collided
    call    kc_grid_col_check
    ; Read joystick and move
    call    move_player

    jmp game_loop


; Calls movement routines for player
move_player:

    ; Get joystick 0 movement
    mov     r1,#000h                    ; select joystick 0
    call    getjoystick
    mov     a,r1 
    cpl     a 
    mov     r1,a                        ; save joystick bits

    ; Store initial X and Y values
    mov     r0,#000h                    ; y position 
    movx    a,@r0
    mov     r2,a
    mov     r0,#001h                    ; x position  
    movx    a,@r0
    mov     r3,a  

    ; Joystick bits in BIOS 0 = Up, 1 = Right, 2 = Down, 3 = Left, 4 = Fire
    ; "stored movement" AND with BIOS value to determine which bit set
    mov     a,r1
    anl     a,#001h
    jnz     move_up

    mov     a,r1 
    anl     a,#002h             
    jnz     move_right

    mov     a,r1
    anl     a,#004h
    jnz     move_down

    mov     a,r1
    anl     a,#008h
    jnz     move_left

    call    neutral_animate

    ret


; Move player sprite up
move_up:

    ; Move sprite
    mov     r1,#000h
    movx    a,@r1
    add     a,#0ffh
    movx    @r1,a

    

    ; For alternating animation frames
    ; If i'm being completely honest i dont know why this works
    ; Like it literally doesnt matter if i set the flag anywhere or not
    anl     a,#animation_flag
    jnz     up_animate
    jmp     closed_animate


; Move player sprite down
move_down:

    ; Move sprite
    mov     r1,#000h
    movx    a,@r1 
    add     a,#001h 
    movx    @r1,a

    ; For alternating animation frames
    anl     a,#animation_flag
    jnz     down_animate
    jmp     closed_animate

; Move player sprite left
move_left:

    ; Move sprite
    mov     r1,#001h
    movx    a,@r1 
    add     a,#0ffh 
    movx    @r1,a

    ; For alternating animation frames
    anl     a,#animation_flag
    jnz     left_animate
    jmp     closed_animate



; Move player sprite right
move_right:

    ; Move sprite
    mov     r1,#001h
    movx    a,@r1 
    add     a,#001h 
    movx    @r1,a

    ; For alternating animation frames
    anl     a,#animation_flag
    jnz     right_animate
    jmp     closed_animate


; Checks if kc is colliding with grid
; If collision, move back to pre-movement position
kc_grid_col_check: 

    ; Check for collision of player with grid
    ; Bit 5 is horizontal, bit 4 is vertical
    mov     r0,#iram_collision
    mov     a,@r0
    anl     a,#00110000b
    jnz     kc_col_grid

    ret

; Moves kc back if collide with grid     
kc_col_grid:

    mov     r0,#000h
    mov     a,r2 
    movx    @r0,a  
    mov     r0,#001h
    mov     a,r3    
    movx    @r0,a

    jmp     game_loop    


left_animate:
    mov     r0,#vdc_spr0_shape         
    mov     r1,#kc_left & 0ffh    
    mov     r7,#8
    call    copy_sprite
    jmp     game_loop


right_animate:
    mov     r0,#vdc_spr0_shape         
    mov     r1,#kc_right & 0ffh    
    mov     r7,#8
    call    copy_sprite
    jmp     game_loop


down_animate:
    mov     r0,#vdc_spr0_shape         
    mov     r1,#kc_down & 0ffh    
    mov     r7,#8
    call    copy_sprite
    jmp     game_loop

up_animate:
    mov     r0,#vdc_spr0_shape         
    mov     r1,#kc_up & 0ffh    
    mov     r7,#8
    call    copy_sprite
    jmp     game_loop

closed_animate:
    mov     r0,#vdc_spr0_shape         
    mov     r1,#kc_closed & 0ffh    
    mov     r7,#8
    call    copy_sprite
    jmp     game_loop


neutral_animate:
    mov     r0,#vdc_spr0_shape         
    mov     r1,#kc_neutral & 0ffh    
    mov     r7,#8
    call    copy_sprite


; ***NEW PAGE***
; Need sprites and copy sprite that accesses them on same page
    align   256

; Initialize grid at start of game
; Note: bit 7 = bottom of grid
init_grid:

    ; Set color of maze 
    mov     r0,#vdc_color
    mov     a,#col_grd_yellow
    movx    @r0,a

    ; Create vertical lines on both edges
    mov     r0,#vdc_gridv0
    mov     a,#01111111b
    movx    @r0,a
    mov     r0,#vdc_gridv9
    mov     a,#01111111b
    movx    @r0,a


    ; Set horizontal lines
    mov     r0,#vdc_gridh0
    mov     a,#10000001b
    movx    @r0,a
    mov     r0,#vdc_gridh1
    mov     a,#10000001b
    movx    @r0,a
    mov     r0,#vdc_gridh2
    mov     a,#10000001b
    movx    @r0,a
    mov     r0,#vdc_gridh3
    mov     a,#10000001b
    movx    @r0,a
    mov     r0,#vdc_gridh4
    mov     a,#10000001b
    movx    @r0,a
    mov     r0,#vdc_gridh5
    mov     a,#10000001b
    movx    @r0,a
    mov     r0,#vdc_gridh6
    mov     a,#10000001b
    movx    @r0,a
    mov     r0,#vdc_gridh7
    mov     a,#10000001b
    movx    @r0,a
    mov     r0,#vdc_gridh8
    mov     a,#10000001b
    movx    @r0,a

    ; Set vertical lines
    mov     r0,#vdc_gridv1
    mov     a,#00000000b
    movx    @r0,a
    mov     r0,#vdc_gridv2
    mov     a,#00000000b
    movx    @r0,a
    mov     r0,#vdc_gridv3
    mov     a,#00000000b
    movx    @r0,a
    mov     r0,#vdc_gridv4
    mov     a,#00000000b
    movx    @r0,a
    mov     r0,#vdc_gridv5
    mov     a,#00000000b
    movx    @r0,a
    mov     r0,#vdc_gridv6
    mov     a,#00000000b
    movx    @r0,a
    mov     r0,#vdc_gridv7
    mov     a,#00000000b
    movx    @r0,a
    mov     r0,#vdc_gridv8
    mov     a,#00000000b
    movx    @r0,a

    ret

; Copies sprite data into VDC
copy_sprite:
    mov     a,r1 
    movp    a,@a
    movx    @r0,a 
    inc     r0
    inc     r1 
    djnz    r7,copy_sprite

    ret

; All sprites designed with assumption that will be flipped on Y-axis
ghost_right_1:
	db	10111101b
	db	01111110b
	db	10110111b
	db	10110111b
	db	11111111b
	db	01111110b
    db	11011011b
	db	10010001b

ghost_right_2:
	db	10111101b
	db	01111110b
	db	10110111b
	db	10110111b
	db	11111111b
	db	01111110b
    db	11011011b
	db	01001010b

ghost_left_1:
	db	10111101b
	db	01111110b
	db	11101101b
	db	11101101b
	db	11111111b
	db	01111110b
    db	11011011b
	db	10010001b

ghost_left_2:
	db	10111101b
	db	01111110b
	db	11101101b
	db	11101101b
	db	11111111b
	db	01111110b
    db	11011011b
	db	01001010b

miru_left_1:
	db	01011100b
    db  10111110b
    db  01110101b
    db  01110101b
    db  01111111b
    db  01111111b
    db  00111110b
    db  01111100b


kc_neutral:
 	db	10000001b
    db  01011010b
    db  00111100b
    db  01011010b 
    db  11111111b
    db  10111101b 
    db  01000010b
    db  00111100b

kc_right:
    db	01111101b
    db  00110110b
    db  00011110b
    db  00000111b 
    db  00001110b
    db  00111100b 
    db  01111000b
    db  00000000b

kc_left:
    db	10111110b
    db  01101100b
    db  01111000b
    db  11100000b 
    db  01110000b
    db  00111100b 
    db  00011110b
    db  00000000b

kc_closed:
    db	00011000b
    db  00111100b
    db  01111110b
    db  11111111b 
    db  01111110b
    db  00111100b 
    db  00011000b
    db  00000000b

kc_down:
    db  00000000b
    db	10010000b
    db  01111100b
    db  11111110b
    db  10110111b 
    db  11100111b
    db  11000011b 
    db  10000001b

kc_up:
    db	00000000b
    db  10000001b
    db  11000011b
    db  11100111b 
    db  10110111b
    db  11111110b 
    db  01111100b
    db  10010000b
