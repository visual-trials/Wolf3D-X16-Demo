
    
draw_3d_view_fast:


    ; Given a wall, we determine whether its to the top, left, right or bottom of the player (so horizontal/vertical and on which side). Also check if its facing the right way? Or is that a given at this point?
    ; After that we can determine the length of normal line from the wall (x or y coord) to the player
    ; We can also determine from which and to which ray index the wall extends (relative to the normal line)
    
    ; FIXME: distance to wall is now hardcoded to 2.0
    lda #0
    sta NORMAL_DISTANCE_TO_WALL
    lda #2
    sta NORMAL_DISTANCE_TO_WALL+1
    
    ; FIXME: from ray index is now hardcoded to 0
    lda #0
    sta FROM_RAY_INDEX
    lda #0
    sta FROM_RAY_INDEX+1
    
    ; FIXME: from ray index is now hardcoded to 304 (=256+48)
    lda #48
    sta TO_RAY_INDEX
    lda #1
    sta TO_RAY_INDEX+1
    
    ; Given the direction the player is facing we can also determine what would be the screen start ray index (left most angle in the viewing area of the player, relative to the normal line)
    ; If we know what parts of the screen columns/rays have been drawn already, we can now cut-off left and right parts of the wall.
    
    ; FIXME: screen start ray index is now hardcoded to 0
    lda #0
    sta SCREEN_START_RAY
    lda #0
    sta SCREEN_START_RAY+1
    
    ; If we have done that, we can now determine the distance from the player-plane and the left and right parts of the wall-part (using cosine)
    ; Given these two distances, we can also determine the left and right wall heights.
    
    ; FIXME: from wall height is now hardcoded to 128
    lda #128
    sta FROM_WALL_HEIGHT
    lda #0
    sta FROM_WALL_HEIGHT+1
    
    ; FIXME: to wall height is now hardcoded to 64
    lda #64
    sta TO_WALL_HEIGHT
    lda #0
    sta TO_WALL_HEIGHT+1
    
    ; We still have to determine whether the wall decreases (in height) from left to right, or the other way around and maybe do a different draw-wall-call accordingly
    
    jsr draw_wall_fast


    rts


draw_wall_fast:

    ; NORMAL_DISTANCE_TO_WALL      ; the normal distance of the player to the wall (length of the line 90 degress out of the wall to the player)
    ; FROM_RAY_INDEX               ; the ray index of the left side of the wall we want to draw (angle relative to the normal line out of the wall to the player)
    ; TO_RAY_INDEX                 ; the ray index of the right side of the wall we want to draw (angle relative to the normal line out of the wall to the player)
    
    ; SCREEN_START_RAY             ; the ray index of the very first column on the screen, its left side (angle relative to the normal line out of the wall to the player)
    
    ; FROM_WALL_HEIGHT             ; the height of the left side of the wall 
    ; TO_WALL_HEIGHT               ; the height of the right side of the wall
    
    ; START_SCREEN_X (calculated)  ; the x-position of the wall starting on screen
    
    ; TODO: TEXTURE_INDEX_PER_WALL_SEGMENT?
    
    ; We first determine how much the wall height will decrease per drawn column

; FIXME: should we use a negative number when decrementing the wall height instead?
    ; We do the divide: WALL_HEIGHT_DECREMENT = ((FROM_WALL_HEIGHT-TO_WALL_HEIGHT) * 256 * 256) / ((TO_RAY_INDEX-FROM_RAY_INDEX) * 256);
    ; Note that the difference in wall height should be stored in DIVIDEND (to be used by the divider)
    
    ; We are asuming there is no fraction in the wall height
    lda #0
    sta DIVIDEND+1
    lda #0
    sta DIVIDEND

    sec
	lda FROM_WALL_HEIGHT
	sbc TO_WALL_HEIGHT
	sta DIVIDEND+2
; FIXME: the wall height difference can be > 256!! (so this wont fit, unless we use only 256 possible wall heights?)
	; lda FROM_WALL_HEIGHT+1
	; sbc TO_WALL_HEIGHT
	; FIXME: sta DIVIDEND+3 ??
    
    ; The DIVISOR should contain the width of the wall on screen, so the difference between FROM_RAY_INDEX and TO_RAY_INDEX. We substract the two.
    ; If FROM_RAY_INDEX > TO_RAY_INDEX (possible if FROM_RAY_INDEX starts before index 0, for example 1792) we need to make sure this calculation still works
    ; so after subsctracting FROM_RAY_INDEX from TO_RAY_INDEX we add 4*456=1824 ($720) to the result. We can check if this is needed if the result was negative.
    ; Note that the number below is * 256, because we get more precision with the divide_24bits that way.
    
    ; SPEED: Not sure if we need to reset this each time, probably not! (is not overwritten during divide_24bits)
    lda #0
    sta DIVISOR
    
    sec
	lda TO_RAY_INDEX
	sbc FROM_RAY_INDEX
	sta DIVISOR+1
	lda TO_RAY_INDEX+1
	sbc FROM_RAY_INDEX+1
	sta DIVISOR+2
    bpl wall_width_determined
    
    ; We have a negative result, so we add 1824 (= $720) to the result
    clc
	lda DIVISOR+1
	adc #$20
	sta DIVISOR+1
	lda DIVISOR+2
	adc #$7
	sta DIVISOR+2   
wall_width_determined:

    jsr divide_24bits
    
    ; FIXME: is this mapping of +2, +1 correct? Should we shift something here?
    lda DIVIDEND+2
    sta WALL_HEIGHT_DECREMENT+2
    lda DIVIDEND+1
    sta WALL_HEIGHT_DECREMENT+1
    lda DIVIDEND
    sta WALL_HEIGHT_DECREMENT
    
    ; We store the from wall height into the column wall height (FROM_WALL_HEIGHT * 256)
    lda FROM_WALL_HEIGHT+1
    sta COLUMN_WALL_HEIGHT+2
    lda FROM_WALL_HEIGHT
    sta COLUMN_WALL_HEIGHT+1
    lda #0
    sta COLUMN_WALL_HEIGHT
    
    ; Left part of the screen (256-8 = 248 columns)

    ; Using FROM_RAY_INDEX as the start RAY_INDEX
    lda FROM_RAY_INDEX
    sta RAY_INDEX
    lda FROM_RAY_INDEX+1
    sta RAY_INDEX+1
    
    ; SPEED: its probably better to let the SCREEN_START_RAY also include the 8 pixels at the beginning: so it would be 8 if we started at the beginning). Maybe?

    ; START_SCREEN_X = (FROM_RAY_INDEX - SCREEN_START_RAY) + 8 ; the x-position of the wall starting on screen
    sec
	lda FROM_RAY_INDEX
	sbc SCREEN_START_RAY
	sta START_SCREEN_X
	lda FROM_RAY_INDEX+1
	sbc SCREEN_START_RAY+1
	sta START_SCREEN_X+1
    
    clc
	lda START_SCREEN_X
	adc #8
	sta START_SCREEN_X
	lda START_SCREEN_X+1
	adc #0
	sta START_SCREEN_X+1

    ; If the high byte of START_SCREEN_X is not 0, we start on the right part of the screen
    bne draw_right_part_of_screen

    ; x = START_SCREEN_X (low byte)

    ldx START_SCREEN_X
    
draw_next_column_left:
    lda #%00000000           ; DCSEL=0, ADDRSEL=0
    sta VERA_CTRL
    lda #%11100000           ; Setting bit 16 of vram address to the highest bit (=0), setting auto-increment value to 320 bytes (=14=%1110)
    sta VERA_ADDR_BANK
    lda #$05                ; 5 * 256 = 1280 = 4 * 320 (3d view starts at 4 pixels from the top)
    sta VERA_ADDR_HIGH
    stx VERA_ADDR_LOW       ; We use x as the column number, so we set it as as the start byte of a column
    
    lda #%00000001           ; DCSEL=0, ADDRSEL=1
    sta VERA_CTRL
    lda #%01110001           ; Setting bit 16 of vram address to the highest bit (=1), setting auto-increment value to 64 bytes (=7=%0111)
    sta VERA_ADDR_BANK
    ; FIXME: we should not use only ONE texture! -> use (high) result of tangens to determine which cell of the wall you are in!
    lda #>TEXTURE_DATA
    sta VERA_ADDR_HIGH
    
    ; FIXME: also get TANGENS_HIGH!
; FIXME: allow RAY_INDEX to be > 456 (up until 1824) and allow negative/flipped results?
    lda RAY_INDEX+1
    bne is_high_ray_index_left
is_low_ray_index_left:
    ldy RAY_INDEX
    lda TANGENS_LOW,y             ; When the ray index >= 256, we retrieve from 256 positions further
    bra got_tangens_left
is_high_ray_index_left:
    ldy RAY_INDEX
    lda TANGENS_LOW+256,y         ; When the ray index >= 256, we retrieve from 256 positions further
got_tangens_left:
    
    ; FIXME: We do a * 2.0 (normal distance from wall), then a divide by 4 (256 positions in a cell, so to go to 64 we need to divide by 4). So effectively divide by 2 here
; FIXME: multiply with NORMAL_DISTANCE_TO_WALL instead! (and 'cache' the distance in the multiplier)
    lsr
    and #$3F                ; we effectively do a 'mod 64'
    sta VERA_ADDR_LOW       ; We use x mod 64 as the texture-column number, so we set it as as the start byte of a column

    ; FIXME: we now use only one byte of the wall height, but we also need to check the high byte (unless we only use 256 *EVEN* wall heights)
    lda COLUMN_WALL_HEIGHT+1
    ; FIXME: ONLY USE *EVEN* WALL HEIGHTS??
    and #$FE ; make even
    sta RAM_BANK
    ; FIXME: remove this nop!
    nop

    jsr DRAW_COLUMN_CODE

    sec
	lda COLUMN_WALL_HEIGHT
	sbc WALL_HEIGHT_DECREMENT
	sta COLUMN_WALL_HEIGHT
	lda COLUMN_WALL_HEIGHT+1
	sbc WALL_HEIGHT_DECREMENT+1
	sta COLUMN_WALL_HEIGHT+1
	lda COLUMN_WALL_HEIGHT+2
	sbc WALL_HEIGHT_DECREMENT+2
	sta COLUMN_WALL_HEIGHT+2
    
; FIXME: Only if RAY_INDEX = 1824 we should reset it to 0!
; FIXME: also stop drawing is RAY_INDEX = TO_RAY_INDEX!
    inc RAY_INDEX
    bne ray_index_updated_left
    inc RAY_INDEX+1
ray_index_updated_left:
    
    inx
    bne draw_next_column_left
    
    ; Since we just drew the left part of the screen, x is now 0, which is correct for drawing the right part of the screen. So we skip the x-initialization (which is done if we *started* on the right part of the screen)
    bra draw_next_column_right

    ; Right part of the screen (56 columns)
draw_right_part_of_screen:

    ; x = FROM_RAY_INDEX (low byte) Note: this is only done when *starting* on the right part of the screen!
    ldx START_SCREEN_X

draw_next_column_right:
    lda #%00000000           ; DCSEL=0, ADDRSEL=0
    sta VERA_CTRL
    lda #%11100000           ; Setting bit 16 of vram address to the highest bit (=0), setting auto-increment value to 320px (=14=%1110)
    sta VERA_ADDR_BANK
    lda #$06                ; The right side part of the screen has a start byte starting at address 256 and up
    sta VERA_ADDR_HIGH
    stx VERA_ADDR_LOW       ; We use x as the column number, so we set it as as the start byte of a column
    
    lda #%00000001           ; DCSEL=0, ADDRSEL=1
    sta VERA_CTRL
    lda #%01110001           ; Setting bit 16 of vram address to the highest bit (=1), setting auto-increment value to 64 bytes (=7=%0111)
    sta VERA_ADDR_BANK
    ; FIXME: we should not use only ONE texture! -> use (high) result of tangens to determine which cell of the wall you are in!
    lda #>TEXTURE_DATA
    sta VERA_ADDR_HIGH
    
    ; FIXME: also get TANGENS_HIGH!
; FIXME: allow RAY_INDEX to be > 456 (up until 1824) and allow negative/flipped results?
    lda RAY_INDEX+1
    bne is_high_ray_index_right   
is_low_ray_index_right:
    ldy RAY_INDEX
    lda TANGENS_LOW,y             ; When the ray index >= 256, we retrieve from 256 positions further
    bra got_tangens_right
is_high_ray_index_right:
    ldy RAY_INDEX
    lda TANGENS_LOW+256,y         ; When the ray index >= 256, we retrieve from 256 positions further
got_tangens_right:
    ; FIXME: We do a * 2.0 (normal distance from wall), then a divide by 4 (256 positions in a cell, so to go to 64 we need to divide by 4). So effectively divide by 2 here
    ; FIXME: multiply with NORMAL_DISTANCE_TO_WALL instead! (and 'cache' the distance in the multiplier)
    lsr
    and #$3F                ; we effectively do a 'mod 64'
    sta VERA_ADDR_LOW       ; We use x mod 64 as the texture-column number, so we set it as as the start byte of a column

    ; FIXME: we now use only one byte of the wall height, but we also need to check the high byte (unless we only use 256 *EVEN* wall heights)
    lda COLUMN_WALL_HEIGHT+1
    ; FIXME: ONLY USE *EVEN* WALL HEIGHTS??
    and #$FE ; make even
    sta RAM_BANK
    ; FIXME: remove this nop!
    nop
    
    jsr DRAW_COLUMN_CODE
    
    sec
	lda COLUMN_WALL_HEIGHT
	sbc WALL_HEIGHT_DECREMENT
	sta COLUMN_WALL_HEIGHT
	lda COLUMN_WALL_HEIGHT+1
	sbc WALL_HEIGHT_DECREMENT+1
	sta COLUMN_WALL_HEIGHT+1
	lda COLUMN_WALL_HEIGHT+2
	sbc WALL_HEIGHT_DECREMENT+2
	sta COLUMN_WALL_HEIGHT+2
    
; FIXME: Only if RAY_INDEX = 1824 we should reset it to 0!
; FIXME: also stop drawing is RAY_INDEX = TO_RAY_INDEX!
    inc RAY_INDEX
    bne ray_index_updated_right
    inc RAY_INDEX+1
ray_index_updated_right:

    inx
    cpx #56
    bne draw_next_column_right
    
    
    ; We set back to ADDRSEL=0
    lda #%00000000           ; DCSEL=0, ADDRSEL=0
    sta VERA_CTRL
    
    rts


    
    
clear_3d_view_fast:

    ; Left part of the screen (256-8 = 248 columns)

    ldx #8
    
clear_next_column_left:
    lda #%11100000           ; Setting bit 16 of vram address to the highest bit (=0), setting auto-increment value to 320 bytes (=14=%1110)
    sta VERA_ADDR_BANK
    lda #$05                ; 5 * 256 = 1280 = 4 * 320 (3d view starts at 4 pixels from the top)
    sta VERA_ADDR_HIGH
    stx VERA_ADDR_LOW       ; We use x as the column number, so we set it as as the start byte of a column
    
    lda #BACKGROUND_COLOR_3D_VIEW
    jsr CLEAR_COLUMN_CODE
    
    inx
    bne clear_next_column_left
    
    ; Right part of the screen (56 columns)

    ldx #0

clear_next_column_right:
    lda #%11100000           ; Setting bit 16 of vram address to the highest bit (=0), setting auto-increment value to 320 bytes (=14=%1110)
    sta VERA_ADDR_BANK
    lda #$06                ; The right side part of the screen has a start byte starting at address 256 and up
    sta VERA_ADDR_HIGH
    stx VERA_ADDR_LOW       ; We use x as the column number, so we set it as as the start byte of a column
    
    lda #BACKGROUND_COLOR_3D_VIEW
    jsr CLEAR_COLUMN_CODE
    
    inx
    cpx #56
    bne clear_next_column_right
    
    rts
