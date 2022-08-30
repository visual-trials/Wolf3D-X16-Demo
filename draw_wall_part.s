
draw_wall_part:

    ; NORMAL_DISTANCE_TO_WALL      ; the normal distance of the player to the wall (length of the line 90 degress out of the wall to the player)
    ; FROM_ANGLE                   ; the angle index of the left side of the wall we want to draw (angle relative to the normal line out of the wall to the player)
    ; TO_ANGLE                     ; the angle index of the right side of the wall we want to draw (angle relative to the normal line out of the wall to the player)
    
    ; SCREEN_START_ANGLE           ; the angle index of the very first column on the screen, its left side (angle relative to the normal line out of the wall to the player)
    
    ; FROM_HALF_WALL_HEIGHT        ; the half of the height of the left side of the wall 
    ; TO_HALF_WALL_HEIGHT               ; the half of the height of the right side of the wall
    ; WALL_HEIGHT_INCREASES        ; equal to 1 if wall height goes from small to large, equal to 0 if it goes from large to small 
    
    ; START_SCREEN_X (calculated)  ; the x-position of the wall starting on screen
    
    ; TODO: TEXTURE_INDEX_PER_WALL_SEGMENT?
    
    ; We first determine how much the wall height will decrease per drawn column

    ; We do the divide: HALF_WALL_HEIGHT_INCREMENT = ((TO_HALF_WALL_HEIGHT-FROM_HALF_WALL_HEIGHT) * 256) / TO_ANGLE-FROM_ANGLE;
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
	lda TO_HALF_WALL_HEIGHT
	sbc FROM_HALF_WALL_HEIGHT
	sta DIVIDEND+1
    
    ; The DIVISOR should contain the width of the wall on screen, so the difference between FROM_ANGLE and TO_ANGLE. We substract the two.
    ; If FROM_ANGLE > TO_ANGLE (possible if FROM_ANGLE starts before index 0, for example 1792) we need to make sure this calculation still works
    ; so after subsctracting FROM_ANGLE from TO_ANGLE we add 4*456=1824 ($720) to the result. We can check if this is needed if the result was negative.
    
    ; SPEED: Not sure if we need to reset this each time, probably not! (is not overwritten during divide_16bits)
    lda #0
    sta DIVISOR
    
    sec
	lda TO_ANGLE
	sbc FROM_ANGLE
	sta DIVISOR
	lda TO_ANGLE+1
	sbc FROM_ANGLE+1
	sta DIVISOR+1
    bpl wall_width_determined_increasing_height
    
    ; We have a negative result, so we add 1824 (= $720) to the result
    clc
	lda DIVISOR
	adc #$20
	sta DIVISOR
	lda DIVISOR+1
	adc #$7
	sta DIVISOR+1   
wall_width_determined_increasing_height:

    jsr divide_16bits
    
    lda DIVIDEND+1
    sta HALF_WALL_HEIGHT_INCREMENT+1
    lda DIVIDEND
    sta HALF_WALL_HEIGHT_INCREMENT

    jmp half_wall_height_increment_determined
    
wall_height_decreases:
    sec
	lda FROM_HALF_WALL_HEIGHT
	sbc TO_HALF_WALL_HEIGHT
	sta DIVIDEND+1
    
    ; The DIVISOR should contain the width of the wall on screen, so the difference between FROM_ANGLE and TO_ANGLE. We substract the two.
    ; If FROM_ANGLE > TO_ANGLE (possible if FROM_ANGLE starts before index 0, for example 1792) we need to make sure this calculation still works
    ; so after subsctracting FROM_ANGLE from TO_ANGLE we add 4*456=1824 ($720) to the result. We can check if this is needed if the result was negative.
    
    ; SPEED: Not sure if we need to reset this each time, probably not! (is not overwritten during divide_16bits)
    lda #0
    sta DIVISOR
    
    sec
	lda TO_ANGLE
	sbc FROM_ANGLE
	sta DIVISOR
	lda TO_ANGLE+1
	sbc FROM_ANGLE+1
	sta DIVISOR+1
    bpl wall_width_determined_decreasing_height
    
    ; We have a negative result, so we add 1824 (= $720) to the result
    clc
	lda DIVISOR
	adc #$20
	sta DIVISOR
	lda DIVISOR+1
	adc #$7
	sta DIVISOR+1   
wall_width_determined_decreasing_height:

    jsr divide_16bits
    
    ; FIXME: is this mapping of +2, +1 correct? Should we shift something here?
    lda DIVIDEND+1
    sta HALF_WALL_HEIGHT_INCREMENT+1
    lda DIVIDEND
    sta HALF_WALL_HEIGHT_INCREMENT
    
    ; We negate the HALF_WALL_HEIGHT_INCREMENT
    sec
    lda #0
    sbc HALF_WALL_HEIGHT_INCREMENT
    sta HALF_WALL_HEIGHT_INCREMENT
    lda #0
    sbc HALF_WALL_HEIGHT_INCREMENT+1
    sta HALF_WALL_HEIGHT_INCREMENT+1

half_wall_height_increment_determined:

    ; We store the from wall height into the column wall height (FROM_HALF_WALL_HEIGHT * 256)
    lda FROM_HALF_WALL_HEIGHT
    sta COLUMN_HALF_WALL_HEIGHT+1
    lda #0
    sta COLUMN_HALF_WALL_HEIGHT
    
    ; Left part of the screen (256-8 = 248 columns)

    ; Using FROM_ANGLE as the start ANGLE_INDEX
    lda FROM_ANGLE
    sta ANGLE_INDEX
    lda FROM_ANGLE+1
    sta ANGLE_INDEX+1
    
    ; SPEED: its probably better to let the SCREEN_START_ANGLE also include the 8 pixels at the beginning: so it would be 8 if we started at the beginning). Maybe?

    ; START_SCREEN_X = (FROM_ANGLE - SCREEN_START_ANGLE) + 8 ; the x-position of the wall starting on screen
    sec
	lda FROM_ANGLE
	sbc SCREEN_START_ANGLE
	sta START_SCREEN_X
	lda FROM_ANGLE+1
	sbc SCREEN_START_ANGLE+1
	sta START_SCREEN_X+1
    
    bpl start_screen_is_positive
    
    ; If this becomes negative (highest bit is 1) we need to add 1824 to it
    
    clc
    lda START_SCREEN_X
    adc #<(1824)
    sta START_SCREEN_X
    lda START_SCREEN_X+1
    adc #>(1824)
    sta START_SCREEN_X+1
    
start_screen_is_positive:
    
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
    
; FIXME: HACK!
    lda #0  ; default = no need to negate the result
    sta TMP2
    
    lda ANGLE_INDEX+1
    cmp #$2                       ; ANGLE_INDEX >= 512 ? (NOTE: we do not expect there to be angles between 90 degrees and 270 degrees. So check for ~100 degrees is good enough to see if we are in the 270-360 range = "negative")
    bcs is_negative_left
    
    lda ANGLE_INDEX+1
    bne is_high_positive_ray_index_left
is_low_positive_ray_index_left:
    ldy ANGLE_INDEX
    lda TANGENT_HIGH,y
    sta MULTIPLICAND+1
    lda TANGENT_LOW,y
    sta MULTIPLICAND
    bra got_tangent_left
is_high_positive_ray_index_left:
    ldy ANGLE_INDEX
    lda TANGENT_HIGH+256,y        ; When the angle index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND+1
    lda TANGENT_LOW+256,y         ; When the angle index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND
    bra got_tangent_left

is_negative_left:
    ; SPEED: we do this EACH time, this can be sped up!!

    ; We substract ANGLE_INDEX from 1824 (=$720)so we effectively negate it to allow is to use the (positive) tangent
    sec 
	lda #$20
	sbc ANGLE_INDEX
	sta ANGLE_INDEX_NEGATED
	lda #$7
	sbc ANGLE_INDEX+1
	sta ANGLE_INDEX_NEGATED+1
    
    bne is_high_negative_ray_index_left
is_low_negative_ray_index_left:
    ldy ANGLE_INDEX_NEGATED
    lda TANGENT_HIGH,y
    sta MULTIPLICAND+1
    lda TANGENT_LOW,y
    sta MULTIPLICAND
    bra got_negative_tangent_left
is_high_negative_ray_index_left:
    ldy ANGLE_INDEX_NEGATED
    lda TANGENT_HIGH+256,y        ; When the negated angle index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND+1
    lda TANGENT_LOW+256,y         ; When the negated angle index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND

got_negative_tangent_left:

; FIXME: HACK!
    lda #1  ; we need to negate the result AFTER the multiplication
    sta TMP2
    
got_tangent_left:
    
    ; SPEED: use a FAST mutlipler and 'cache' the NORMAL_DISTANCE_TO_WALL! ( https://codebase64.org/doku.php?id=base:seriously_fast_multiplication )
    ;        note that this needs to run in RAM in order for the 'cache' to work.

    ; We do a * NORMAL_DISTANCE_TO_WALL, then a divide by 4 (256 positions in a cell, so to go to 64 we need to divide by 4). 
    
; SPEED: this is putting x on the stack!
    jsr MULT_WITH_NORMAL_DISTANCE
    
; FIXME: HACK!
    lda TMP2
    beq product_ok_left
    
    ; We negate the tangent result AFTER the multiplication
    sec
    lda #0
    sbc PRODUCT
    sta PRODUCT
    lda #0
    sbc PRODUCT+1
    sta PRODUCT+1
    lda #0
    sbc PRODUCT+2
    sta PRODUCT+2
    ; No need to do PRODUCT+3
    
product_ok_left:

    ; We need to subtract the TEXTURE_COLUMN/INDEX_OFFSET
    sec
    lda PRODUCT+1
    sbc TEXTURE_COLUMN_OFFSET
    sta PRODUCT+1
    lda PRODUCT+2
    sbc TEXTURE_INDEX_OFFSET
    ; SPEED: this sta is not needed!
    sta PRODUCT+2
    
    ; FIXME: we check if the index into the wall (tiles) is within bounds. Instead of doing that, we should instead 
    ;        NOT do any tan+multiply calculation for the start and end ray.
    bmi texture_start_index_not_ok_left ; Check if the index is negative
    cmp WALL_LENGTH       ; Check if the index is beyond the length of the wall
    bcc texture_index_ok_left
    ; The index is too large. This means that it should be corrected to the length minus 1 (and the low byte to $FF)
    lda #$FF
    sta PRODUCT+1
    bra texture_index_ok_left
    lda WALL_LENGTH
    dec
    ; SPEED: this sta is not needed!
    sta PRODUCT+2
    
texture_start_index_not_ok_left:  
    ; The index is negative. This means that it should be corrected to 0 (also the low byte)
    lda #0
    sta PRODUCT+1
    ; SPEED: this sta is not needed!
    sta PRODUCT+2
    
texture_index_ok_left:
    tay
    
    lda (WALL_INFO_TEXTURE_INDEXES),y
    sta VERA_ADDR_HIGH
    
    lda PRODUCT+1
    lsr
    lsr
    and #$3F                ; we effectively do a 'mod 64'
    sta VERA_ADDR_LOW       ; We use x mod 64 as the texture-column number, so we set it as as the start byte of a column


    lda COLUMN_HALF_WALL_HEIGHT+1
    sta RAM_BANK
    ; SPEED: remove this nop!
    nop

    jsr DRAW_COLUMN_CODE

    clc
	lda COLUMN_HALF_WALL_HEIGHT
	adc HALF_WALL_HEIGHT_INCREMENT
	sta COLUMN_HALF_WALL_HEIGHT
	lda COLUMN_HALF_WALL_HEIGHT+1
	adc HALF_WALL_HEIGHT_INCREMENT+1
	sta COLUMN_HALF_WALL_HEIGHT+1

    ; Incrmenting ANGLE_INDEX
    inc ANGLE_INDEX
    bne ray_index_is_incremented_left
    inc ANGLE_INDEX+1
    
ray_index_is_incremented_left:

    ; If ANGLE_INDEX = 1824 (=$720) we reset it to 0 (we "loop" around)
    lda ANGLE_INDEX
    cmp #$20
    bne ray_index_is_updated_left
    lda ANGLE_INDEX+1
    cmp #$7
    bne ray_index_is_updated_left
    
    ; Resetting ANGLE_INDEX to 0
    lda #0
    sta ANGLE_INDEX
    sta ANGLE_INDEX+1
    
ray_index_is_updated_left:

    ; We should stop drawing the wall if we reached the end of the wall, meaning ANGLE_INDEX == TO_ANGLE (after incrementing it)
    lda ANGLE_INDEX
    cmp TO_ANGLE
    bne continue_drawing_left   ; not equal, so keep on going drawing the wall
    lda ANGLE_INDEX+1
    cmp TO_ANGLE+1
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

    ; x = FROM_ANGLE (low byte) Note: this is only done when *starting* on the right part of the screen!
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
    
; FIXME: HACK!
    lda #0  ; default = no need to negate the result
    sta TMP2
    
    lda ANGLE_INDEX+1
    cmp #$2                       ; ANGLE_INDEX >= 512 ? (NOTE: we do not expect there to be angles between 90 degrees and 270 degrees. So check for ~100 degrees is good enough to see if we are in the 270-360 range = "negative")
    bcs is_negative_right
    
    lda ANGLE_INDEX+1
    bne is_high_positive_ray_index_right
is_low_positive_ray_index_right:
    ldy ANGLE_INDEX
    lda TANGENT_HIGH,y
    sta MULTIPLICAND+1
    lda TANGENT_LOW,y
    sta MULTIPLICAND
    bra got_tangent_right
is_high_positive_ray_index_right:
    ldy ANGLE_INDEX
    lda TANGENT_HIGH+256,y        ; When the angle index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND+1
    lda TANGENT_LOW+256,y         ; When the angle index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND
    
    bra got_tangent_right

is_negative_right:
    ; SPEED: we do this EACH time, this can be sped up!!

    ; We substract ANGLE_INDEX from 1824 (=$720)so we effectively negate it to allow is to use the (positive) tangent
    sec 
	lda #$20
	sbc ANGLE_INDEX
	sta ANGLE_INDEX_NEGATED
	lda #$7
	sbc ANGLE_INDEX+1
	sta ANGLE_INDEX_NEGATED+1
    
    bne is_high_negative_ray_index_right
is_low_negative_ray_index_right:
    ldy ANGLE_INDEX_NEGATED
    lda TANGENT_HIGH,y
    sta MULTIPLICAND+1
    lda TANGENT_LOW,y
    sta MULTIPLICAND
    bra got_negative_tangent_right
is_high_negative_ray_index_right:
    ldy ANGLE_INDEX_NEGATED
    lda TANGENT_HIGH+256,y        ; When the negated angle index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND+1
    lda TANGENT_LOW+256,y         ; When the negated angle index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND

got_negative_tangent_right:

; FIXME: HACK!
    lda #1  ; we need to negate the result AFTER multiplication
    sta TMP2
    
got_tangent_right:
    ; SPEED: use a FAST mutlipler and 'cache' the NORMAL_DISTANCE_TO_WALL! ( https://codebase64.org/doku.php?id=base:seriously_fast_multiplication )
    ;        note that this needs to run in RAM in order for the 'cache' to work.

    ; We do a * NORMAL_DISTANCE_TO_WALL, then a divide by 4 (256 positions in a cell, so to go to 64 we need to divide by 4). 
    
; SPEED: this is putting x on the stack!
    jsr MULT_WITH_NORMAL_DISTANCE
    
; FIXME: HACK!
    lda TMP2
    beq product_ok_right
    
    ; We negate the tangent result AFTER the multiplication
    sec
    lda #0
    sbc PRODUCT
    sta PRODUCT
    lda #0
    sbc PRODUCT+1
    sta PRODUCT+1
    lda #0
    sbc PRODUCT+2
    sta PRODUCT+2
    ; No need to do PRODUCT+3
    
product_ok_right:

    ; We need to subtract the TEXTURE_COLUMN/INDEX_OFFSET
    sec
    lda PRODUCT+1
    sbc TEXTURE_COLUMN_OFFSET
    sta PRODUCT+1
    lda PRODUCT+2
    sbc TEXTURE_INDEX_OFFSET
    ; SPEED: this sta is not needed
    sta PRODUCT+2
    
    ; FIXME: we check if the index into the wall (tiles) is within bounds. Instead of doing that, we should instead 
    ;        NOT do any tan+multiply calculation for the start and end ray.
    bmi texture_start_index_not_ok_right ; Check if the index is negative
    cmp WALL_LENGTH       ; Check if the index is beyond the length of the wall
    bcc texture_index_ok_right
    ; The index is too large. This means that it should be corrected to the length minus 1 (and the low byte to $FF)
    lda #$FF
    sta PRODUCT+1
    bra texture_index_ok_right
    lda WALL_LENGTH
    dec
    ; SPEED: this sta is not needed!
    sta PRODUCT+2
    
texture_start_index_not_ok_right:  
    ; The index is negative. This means that it should be corrected to 0 (also the low byte)
    lda #0
    sta PRODUCT+1
    ; SPEED: this sta is not needed!
    sta PRODUCT+2
    
texture_index_ok_right:
    tay
    
    lda (WALL_INFO_TEXTURE_INDEXES),y
    sta VERA_ADDR_HIGH
    
    lda PRODUCT+1
    lsr
    lsr
    and #$3F                ; we effectively do a 'mod 64'
    sta VERA_ADDR_LOW       ; We use x mod 64 as the texture-column number, so we set it as as the start byte of a column
    
    lda COLUMN_HALF_WALL_HEIGHT+1
    sta RAM_BANK
    ; SPEED: remove this nop!
    nop
    
    jsr DRAW_COLUMN_CODE
    
    clc
	lda COLUMN_HALF_WALL_HEIGHT
	adc HALF_WALL_HEIGHT_INCREMENT
	sta COLUMN_HALF_WALL_HEIGHT
	lda COLUMN_HALF_WALL_HEIGHT+1
	adc HALF_WALL_HEIGHT_INCREMENT+1
	sta COLUMN_HALF_WALL_HEIGHT+1
    
    ; Incrmenting ANGLE_INDEX
    inc ANGLE_INDEX
    bne ray_index_is_incremented_right
    inc ANGLE_INDEX+1
    
ray_index_is_incremented_right:

    ; If ANGLE_INDEX = 1824 (=$720) we reset it to 0 (we "loop" around)
    lda ANGLE_INDEX
    cmp #$20
    bne ray_index_is_updated_right
    lda ANGLE_INDEX+1
    cmp #$7
    bne ray_index_is_updated_right
    
    ; Resetting ANGLE_INDEX to 0
    lda #0
    sta ANGLE_INDEX
    sta ANGLE_INDEX+1
    
ray_index_is_updated_right:

    ; We should stop drawing the wall if we reached the end of the wall, meaning ANGLE_INDEX == TO_ANGLE (after incrementing it)
    lda ANGLE_INDEX
    cmp TO_ANGLE
    bne continue_drawing_right   ; not equal, so keep on going drawing the wall
    lda ANGLE_INDEX+1
    cmp TO_ANGLE+1
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
