
    
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
    
    
    ; TEMP IDEA: in order to calculate the invtan(delta-y/delta-x) we could *FOR *NOW* simply do the "delta-y/delta-x" and *search* in the tangens-table if we find the two numbers it falls in-between. The index of those numbers is our invtan()!
    
    
    lda #0
    sta FROM_RAY_INDEX
    lda #0
    sta FROM_RAY_INDEX+1
    
    ; FIXME: to ray index is now hardcoded to 304 (=256+48)
;    lda #(304-256)
    lda #228   ; 45 degrees
    sta TO_RAY_INDEX
;    lda #1
    lda #0
    sta TO_RAY_INDEX+1
    
    ; Given the direction the player is facing we can also determine what would be the screen start ray index (left most angle in the viewing area of the player, relative to the normal line)
    ; If we know what parts of the screen columns/rays have been drawn already, we can now cut-off left and right parts of the wall.
    
    ; FIXME: screen start ray index is now hardcoded to 0
    lda #0
    sta SCREEN_START_RAY
    lda #0
    sta SCREEN_START_RAY+1
    
    ; If we have done that, we can now determine the distance from the player-plane and the left and right parts of the wall-part:
    ;   normal_distance_to_point = delta_x * cos(player_angle) + delta_y * sin(player_angle)
    ; Given these two distances, we can also determine the left and right wall heights.
    
    ; FIXME: from wall height is now hardcoded to 128
    lda #128
    sta FROM_WALL_HEIGHT
    lda #0
    sta FROM_WALL_HEIGHT+1
    
    lda #128-45 ; (45 pixels drop at 45 degrees drop when 30 degrees normal angle)
    sta TO_WALL_HEIGHT
    lda #0
    sta TO_WALL_HEIGHT+1
    
    ; We also have to determine whether the wall decreases (in height) from left to right, or the other way around and maybe do a different draw-wall-call accordingly
    
    lda #0
    sta WALL_HEIGHT_INCREASES
    
    
    jsr draw_wall_fast
    

    ; - 90 degrees = 1824-456 = 1368 = $558
    lda #$58
    sta SCREEN_START_RAY
    lda #$5
    sta SCREEN_START_RAY+1

    ; 1824-228 = 1596 = $63C
    lda #$3C   ; -45 degrees
    sta FROM_RAY_INDEX
    lda #$6
    sta FROM_RAY_INDEX+1

    ; - 30 degrees = 1824 - 152 = 1672 = $688
    lda #$88
    sta TO_RAY_INDEX
    lda #$6
    sta TO_RAY_INDEX+1


    lda #128-45 ; (45 pixels drop at 45 degrees drop when 30 degrees normal angle)
    sta FROM_WALL_HEIGHT
    lda #0
    sta FROM_WALL_HEIGHT+1

    ; FIXME: this value (180) is GUESSED!
    lda #180
    sta TO_WALL_HEIGHT
    lda #0
    sta TO_WALL_HEIGHT+1

    lda #1
    sta WALL_HEIGHT_INCREASES

    jsr draw_wall_fast




    rts


draw_wall_fast:

    ; NORMAL_DISTANCE_TO_WALL      ; the normal distance of the player to the wall (length of the line 90 degress out of the wall to the player)
    ; FROM_RAY_INDEX               ; the ray index of the left side of the wall we want to draw (angle relative to the normal line out of the wall to the player)
    ; TO_RAY_INDEX                 ; the ray index of the right side of the wall we want to draw (angle relative to the normal line out of the wall to the player)
    
    ; SCREEN_START_RAY             ; the ray index of the very first column on the screen, its left side (angle relative to the normal line out of the wall to the player)
    
    ; FROM_WALL_HEIGHT             ; the height of the left side of the wall 
    ; TO_WALL_HEIGHT               ; the height of the right side of the wall
    ; WALL_HEIGHT_INCREASES        ; equal to 1 if wall height goes from small to large, equal to 0 if it goes from large to small 
    
    ; START_SCREEN_X (calculated)  ; the x-position of the wall starting on screen
    
    ; TODO: TEXTURE_INDEX_PER_WALL_SEGMENT?
    
    ; We first determine how much the wall height will decrease per drawn column

    ; We do the divide: WALL_HEIGHT_INCREMENT = ((TO_WALL_HEIGHT-FROM_WALL_HEIGHT) * 256 * 256) / ((TO_RAY_INDEX-FROM_RAY_INDEX) * 256);
    ; Note that the difference in wall height should be stored in DIVIDEND (to be used by the divider)
    ; Note: we will have a negative number when the wall height is decrementing
    
    ; We are asuming there is no fraction in the wall height
    lda #0
    sta DIVIDEND+1
    lda #0
    sta DIVIDEND

    lda WALL_HEIGHT_INCREASES
    beq wall_height_decreases
    
wall_height_increases:

    sec
	lda TO_WALL_HEIGHT
	sbc FROM_WALL_HEIGHT
	sta DIVIDEND+2
; FIXME: the wall height difference can be > 256!! (so this wont fit, unless we use only 256 possible wall heights?)
	; lda TO_WALL_HEIGHT+1
	; sbc FROM_WALL_HEIGHT+1
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
    bpl wall_width_determined_increasing_height
    
    ; We have a negative result, so we add 1824 (= $720) to the result
    clc
	lda DIVISOR+1
	adc #$20
	sta DIVISOR+1
	lda DIVISOR+2
	adc #$7
	sta DIVISOR+2   
wall_width_determined_increasing_height:

    jsr divide_24bits
    
    ; FIXME: is this mapping of +2, +1 correct? Should we shift something here?
    lda DIVIDEND+2
    sta WALL_HEIGHT_INCREMENT+2
    lda DIVIDEND+1
    sta WALL_HEIGHT_INCREMENT+1
    lda DIVIDEND
    sta WALL_HEIGHT_INCREMENT

    jmp wall_height_increment_determined
    
wall_height_decreases:
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
    bpl wall_width_determined_decreasing_height
    
    ; We have a negative result, so we add 1824 (= $720) to the result
    clc
	lda DIVISOR+1
	adc #$20
	sta DIVISOR+1
	lda DIVISOR+2
	adc #$7
	sta DIVISOR+2   
wall_width_determined_decreasing_height:

    jsr divide_24bits
    
    ; FIXME: is this mapping of +2, +1 correct? Should we shift something here?
    lda DIVIDEND+2
    sta WALL_HEIGHT_INCREMENT+2
    lda DIVIDEND+1
    sta WALL_HEIGHT_INCREMENT+1
    lda DIVIDEND
    sta WALL_HEIGHT_INCREMENT
    
    ; We negate the WALL_HEIGHT_INCREMENT
    sec
    lda #0
    sbc WALL_HEIGHT_INCREMENT
    sta WALL_HEIGHT_INCREMENT
    lda #0
    sbc WALL_HEIGHT_INCREMENT+1
    sta WALL_HEIGHT_INCREMENT+1
    lda #0
    sbc WALL_HEIGHT_INCREMENT+2
    sta WALL_HEIGHT_INCREMENT+1
    

wall_height_increment_determined:
    
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

    ; If the *high* byte of START_SCREEN_X is 0, we draw the left part of the screen (first), otherwise we start on the right part of the screen
    beq draw_left_part_of_screen
    
    jmp draw_right_part_of_screen

draw_left_part_of_screen:
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
    lda RAY_INDEX+1
    cmp #$2                       ; RAY_INDEX >= 512 ? (NOTE: we do not expect there to be angles between 90 degrees and 270 degrees. So check for ~100 degrees is good enough to see if we are in the 270-360 range = "negative")
    bcs is_negative_left
    
    lda RAY_INDEX+1
    bne is_high_positive_ray_index_left
is_low_positive_ray_index_left:
    ldy RAY_INDEX
    lda TANGENS_LOW,y             ; When the ray index >= 256, we retrieve from 256 positions further
    bra got_tangens_left
is_high_positive_ray_index_left:
    ldy RAY_INDEX
    lda TANGENS_LOW+256,y         ; When the ray index >= 256, we retrieve from 256 positions further
    bra got_tangens_left

is_negative_left:
    ; SPEED: we do this EACH time, this can be sped up!!

    ; We substract RAY_INDEX from 1824 (=$720)so we effectively negate it to allow is to use the (positive) tangens
    sec 
	lda #$20
	sbc RAY_INDEX
	sta RAY_INDEX_NEGATED
	lda #$7
	sbc RAY_INDEX+1
	sta RAY_INDEX_NEGATED+1
    
    bne is_high_negative_ray_index_left
is_low_negative_ray_index_left:
    ldy RAY_INDEX_NEGATED
    lda TANGENS_LOW,y             ; When the negated ray index >= 256, we retrieve from 256 positions further
    bra got_negative_tangens_left
is_high_negative_ray_index_left:
    ldy RAY_INDEX_NEGATED
    lda TANGENS_LOW+256,y         ; When the negated ray index >= 256, we retrieve from 256 positions further

got_negative_tangens_left:
    ; We negate the tangens result
    ; SPEED: can this be done faster?
    sec
    sta TMP1
    lda #0
    sbc TMP1
    
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

    clc
	lda COLUMN_WALL_HEIGHT
	adc WALL_HEIGHT_INCREMENT
	sta COLUMN_WALL_HEIGHT
	lda COLUMN_WALL_HEIGHT+1
	adc WALL_HEIGHT_INCREMENT+1
	sta COLUMN_WALL_HEIGHT+1
	lda COLUMN_WALL_HEIGHT+2
	adc WALL_HEIGHT_INCREMENT+2
	sta COLUMN_WALL_HEIGHT+2

    ; Incrmenting RAY_INDEX
    inc RAY_INDEX
    bne ray_index_is_incremented_left
    inc RAY_INDEX+1
    
ray_index_is_incremented_left:

    ; If RAY_INDEX = 1824 (=$720) we reset it to 0 (we "loop" around)
    lda RAY_INDEX
    cmp #$20
    bne ray_index_is_updated_left
    lda RAY_INDEX+1
    cmp #$7
    bne ray_index_is_updated_left
    
    ; Resetting RAY_INDEX to 0
    lda #0
    sta RAY_INDEX
    sta RAY_INDEX+1
    
ray_index_is_updated_left:

    ; We should stop drawing the wall if we reached the end of the wall, meaning RAY_INDEX == TO_RAY_INDEX (after incrementing it)
    lda RAY_INDEX
    cmp TO_RAY_INDEX
    bne continue_drawing_left   ; not equal, so keep on going drawing the wall
    lda RAY_INDEX+1
    cmp TO_RAY_INDEX+1
    bne continue_drawing_left   ; not equal, so keep on going drawing the wall

    ; both bytes are equal, we should stop drawing
    jmp done_drawing_wall
    
continue_drawing_left:
    inx
    beq draw_next_column_right ; Since we just drew the left part of the screen, x is now 0, which is correct for drawing the right part of the screen. So we skip the x-initialization (which is done if we *started* on the right part of the screen)
    
    ; We iterate to the next column (left side of the screen)
    jmp draw_next_column_left


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
    lda RAY_INDEX+1
    cmp #$2                       ; RAY_INDEX >= 512 ? (NOTE: we do not expect there to be angles between 90 degrees and 270 degrees. So check for ~100 degrees is good enough to see if we are in the 270-360 range = "negative")
    bcs is_negative_right
    
    lda RAY_INDEX+1
    bne is_high_positive_ray_index_right
is_low_positive_ray_index_right:
    ldy RAY_INDEX
    lda TANGENS_LOW,y             ; When the ray index >= 256, we retrieve from 256 positions further
    bra got_tangens_right
is_high_positive_ray_index_right:
    ldy RAY_INDEX
    lda TANGENS_LOW+256,y         ; When the ray index >= 256, we retrieve from 256 positions further
    
    bra got_tangens_right

is_negative_right:
    ; SPEED: we do this EACH time, this can be sped up!!

    ; We substract RAY_INDEX from 1824 (=$720)so we effectively negate it to allow is to use the (positive) tangens
    sec 
	lda #$20
	sbc RAY_INDEX
	sta RAY_INDEX_NEGATED
	lda #$7
	sbc RAY_INDEX+1
	sta RAY_INDEX_NEGATED+1
    
    bne is_high_negative_ray_index_right
is_low_negative_ray_index_right:
    ldy RAY_INDEX_NEGATED
    lda TANGENS_LOW,y             ; When the negated ray index >= 256, we retrieve from 256 positions further
    bra got_negative_tangens_right
is_high_negative_ray_index_right:
    ldy RAY_INDEX_NEGATED
    lda TANGENS_LOW+256,y         ; When the negated ray index >= 256, we retrieve from 256 positions further

got_negative_tangens_right:
    ; We negate the tangens result
    ; SPEED: can this be done faster?
    sec
    sta TMP1
    lda #0
    sbc TMP1
    
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
    
    clc
	lda COLUMN_WALL_HEIGHT
	adc WALL_HEIGHT_INCREMENT
	sta COLUMN_WALL_HEIGHT
	lda COLUMN_WALL_HEIGHT+1
	adc WALL_HEIGHT_INCREMENT+1
	sta COLUMN_WALL_HEIGHT+1
	lda COLUMN_WALL_HEIGHT+2
	adc WALL_HEIGHT_INCREMENT+2
	sta COLUMN_WALL_HEIGHT+2
    
    ; Incrmenting RAY_INDEX
    inc RAY_INDEX
    bne ray_index_is_incremented_right
    inc RAY_INDEX+1
    
ray_index_is_incremented_right:

    ; If RAY_INDEX = 1824 (=$720) we reset it to 0 (we "loop" around)
    lda RAY_INDEX
    cmp #$20
    bne ray_index_is_updated_right
    lda RAY_INDEX+1
    cmp #$7
    bne ray_index_is_updated_right
    
    ; Resetting RAY_INDEX to 0
    lda #0
    sta RAY_INDEX
    sta RAY_INDEX+1
    
ray_index_is_updated_right:

    ; We should stop drawing the wall if we reached the end of the wall, meaning RAY_INDEX == TO_RAY_INDEX (after incrementing it)
    lda RAY_INDEX
    cmp TO_RAY_INDEX
    bne continue_drawing_right   ; not equal, so keep on going drawing the wall
    lda RAY_INDEX+1
    cmp TO_RAY_INDEX+1
    beq done_drawing_wall       ; both bytes are equal, we should stop drawing
    
continue_drawing_right:
    inx
    cpx #56
    beq done_drawing_wall
    
    ; We iterate to the next column (right side of the screen)
    jmp draw_next_column_right
    
done_drawing_wall:
    
    ; NOTE: be *careful* here: this code is DUPLICATED above!
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
