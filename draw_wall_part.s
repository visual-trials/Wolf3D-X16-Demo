    ; ==================================================================================================================================
    ;
    ;                                                          PREPARE WALL PART
    ;
    ; ==================================================================================================================================

prep_and_draw_wall_part:



    ; ========== Recalculate FROM_RAY and TO_RAY INFO ===========
    
    ; Note that the FROM_ANGLE is an angle that is relative to the normal line of the wall
    ; This means that it has to be between 270 and 90 degrees. In order to get the tangent(FROM_ANGLE) we
    ; have to negate FROM_ANGLE if it is 'negative'. Note that we do *not* need to negate the result of tangent
    ; since we also determine the quadrant in which the from way lies (and the cosine/sine use that)s
    
    ; Also: the tangent is the ratio of: distance-*over*-the-wall / normal-distance-*to*-the-wall
    ; We want to know the distance-*over*-the-wall. But this can be either FROM_DELTA_X or FROM_DELTA_Y
    ; In order for us to know this one we have to overwrite we look at the direction of the wall: 
    ;   is it horizontal? then we have to recalculate the FROM_DELTA_X
    ;   is it vertical? then we have to recalculate the FROM_DELTA_X
    ; To check whether a wall is horizontal, we simply check the lowest bit of WALL_FACING_DIR.
    
    
    
    lda FROM_ANGLE_NEEDS_RECALC
    bne recalculate_from_ray_info
    
    ; There is no need to recalculate the from_ray_info so jump over it
    jmp from_ray_info_updated
    
    
recalculate_from_ray_info:
    ; -- Re-calculate FROM_DELTA_X **OR** FROM_DELTA_Y using tangent(FROM_ANGLE) --
    
    ; Check if FROM_ANGLE is 'negative' (between 270 degrees and 360)
    lda FROM_ANGLE+1
    ; FIXME: hack!
    cmp #4
    bcc from_ray_is_already_between_0_and_90_degrees
    
    sec
    lda #<(1824)
    sbc FROM_ANGLE
    sta ANGLE_INDEX
    lda #>(1824)
    sbc FROM_ANGLE+1
    sta ANGLE_INDEX+1
    
    bra from_ray_is_now_between_0_and_90_degrees

from_ray_is_already_between_0_and_90_degrees:
    lda FROM_ANGLE
    sta ANGLE_INDEX
    lda FROM_ANGLE+1
    sta ANGLE_INDEX+1

from_ray_is_now_between_0_and_90_degrees:

    ; SPEED: no need to do this lda
    lda ANGLE_INDEX+1
    bne is_high_positive_from_ray_index
is_low_positive_from_ray_index:
    ldy ANGLE_INDEX
    lda TANGENT_LOW,y             ; When the angle index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND
    lda TANGENT_HIGH,y             ; When the angle index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND+1
    bra got_tangent_from_ray
is_high_positive_from_ray_index:
    ldy ANGLE_INDEX
    lda TANGENT_LOW+256,y         ; When the angle index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND
    lda TANGENT_HIGH+256,y         ; When the angle index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND+1
got_tangent_from_ray:

    jsr MULT_WITH_NORMAL_DISTANCE
    
    lda WALL_FACING_DIR
    lsr
    bcc from_ray_on_horizontal_wall ; no carry (facing south or norht), so we its a horizontal wall

from_ray_on_vertical_wall:

    lda PRODUCT+1
    sta FROM_DELTA_Y
    lda PRODUCT+2
    sta FROM_DELTA_Y+1
    
    bra done_from_delta_calc
    
from_ray_on_horizontal_wall:
    
    lda PRODUCT+1
    sta FROM_DELTA_X
    lda PRODUCT+2
    sta FROM_DELTA_X+1
    
done_from_delta_calc:
    

    ; -- Re-calculate FROM_QUADRANT using FROM_ANGLE --

    ; FIXME: we first need to get the *absolute* angle for FROM_ANGLE
    ;        right now we do this by "unnormalizing" it and checking the WALL_FACING_DIR
    ;        but there is probably a better way to do this (earlier).

    lda WALL_FACING_DIR
    cmp #3  ; west
    beq from_ray_calc_wall_facing_west
    cmp #2  ; south
    beq from_ray_calc_wall_facing_south
    cmp #1  ; east
    beq from_ray_calc_wall_facing_east
    cmp #0  ; north
    beq from_ray_calc_wall_facing_north

from_ray_calc_wall_facing_east:
    ; The wall is facing north so we are turned 270. We need to subtract 90 degrees
    sec
    lda FROM_ANGLE
    sbc #<(1*456)
    sta ANGLE_INDEX
    lda FROM_ANGLE+1
    sbc #>(1*456)
    sta ANGLE_INDEX+1
    bra unnormalized_from_ray

from_ray_calc_wall_facing_north:
    ; The wall is facing north so we are turned 180. We need to subtract 180 degrees
    sec
    lda FROM_ANGLE
    sbc #<(2*456)
    sta ANGLE_INDEX
    lda FROM_ANGLE+1
    sbc #>(2*456)
    sta ANGLE_INDEX+1
    bra unnormalized_from_ray
    
from_ray_calc_wall_facing_west:
    ; The wall is facing west so we are turned 90. We need to subtract 270 degrees
    sec
    lda FROM_ANGLE
    sbc #<(3*456)
    sta ANGLE_INDEX
    lda FROM_ANGLE+1
    sbc #>(3*456)
    sta ANGLE_INDEX+1
    bra unnormalized_from_ray
    
from_ray_calc_wall_facing_south:
    ; The wall is facing south so we are turned 0. No need to subtract anything.
    lda FROM_ANGLE
    sta ANGLE_INDEX
    lda FROM_ANGLE+1
    sta ANGLE_INDEX+1

unnormalized_from_ray:

    ; Checking if ANGLE_INDEX is below 0, if so add 1824
    bpl unnormalized_from_ray_is_positive
    
    clc 
    lda ANGLE_INDEX
    adc #<(4*456)
    sta ANGLE_INDEX
    lda ANGLE_INDEX+1
    adc #>(4*456)
    sta ANGLE_INDEX+1

unnormalized_from_ray_is_positive:
    
    lda ANGLE_INDEX+1
    cmp #>(456*1)
    bcc from_ray_in_q0
    bne from_ray_in_not_in_q0
    lda ANGLE_INDEX
    cmp #<(456*1)
    bcc from_ray_in_q0
    
from_ray_in_not_in_q0:
    lda ANGLE_INDEX+1
    cmp #>(456*2)
    bcc from_ray_in_q1
    bne from_ray_in_not_in_q1
    lda ANGLE_INDEX
    cmp #<(456*2)
    bcc from_ray_in_q1
    
from_ray_in_not_in_q1:
    lda ANGLE_INDEX+1
    cmp #>(456*3)
    bcc from_ray_in_q2
    bne from_ray_in_q3
    lda ANGLE_INDEX
    cmp #<(456*3)
    bcc from_ray_in_q2
    
from_ray_in_q3:
    ; Normalize angle (360 degrees - q3angle = q0angle)
    sec
    lda #<(456*4)
    sbc ANGLE_INDEX
    sta ANGLE_INDEX
    lda #>(456*4)
    sbc ANGLE_INDEX+1
    sta ANGLE_INDEX+1

    ; Mark as q3
    lda #%00000010
    sta FROM_QUADRANT
    
    bra from_ray_info_updated
    
from_ray_in_q2:
    ; Normalize angle (q2angle - 180 degrees = q0angle)
    sec
    lda ANGLE_INDEX
    sbc #<(456*2)
    sta ANGLE_INDEX
    lda ANGLE_INDEX+1
    sbc #>(456*2)
    sta ANGLE_INDEX+1
    
    ; Mark as q2
    lda #%00000011
    sta FROM_QUADRANT
    
    bra from_ray_info_updated
    
from_ray_in_q1:
    ; Normalize angle (180 degrees - q1angle = q0angle)
    sec
    lda #<(456*2)
    sbc ANGLE_INDEX
    sta ANGLE_INDEX
    lda #>(456*2)
    sbc ANGLE_INDEX+1
    sta ANGLE_INDEX+1
    
    ; Mark as q1
    lda #%00000001
    sta FROM_QUADRANT
    
    bra from_ray_info_updated
    
from_ray_in_q0:

    lda ANGLE_INDEX
    sta ANGLE_INDEX
    lda ANGLE_INDEX+1
    sta ANGLE_INDEX+1
    
    ; Mark as q0
    lda #%00000000
    sta FROM_QUADRANT

from_ray_info_updated:


    ; ============ TO RAY ==========
    
    lda TO_ANGLE_NEEDS_RECALC
    bne recalculate_to_ray_info
    
    ; There is no need to recalculate the to_ray_info so jump over it
    jmp to_ray_info_updated
    
recalculate_to_ray_info:
    ; -- Re-calculate TO_DELTA_X **OR** TO_DELTA_Y using tangent(TO_ANGLE) --
    
    ; Check if TO_ANGLE is 'negative' (between 270 degrees and 360)
    lda TO_ANGLE+1
    ; FIXME: hack!
    cmp #4
    bcc to_ray_is_already_between_0_and_90_degrees
    
    sec
    lda #<(1824)
    sbc TO_ANGLE
    sta ANGLE_INDEX
    lda #>(1824)
    sbc TO_ANGLE+1
    sta ANGLE_INDEX+1
    
    bra to_ray_is_now_between_0_and_90_degrees

to_ray_is_already_between_0_and_90_degrees:
    lda TO_ANGLE
    sta ANGLE_INDEX
    lda TO_ANGLE+1
    sta ANGLE_INDEX+1

to_ray_is_now_between_0_and_90_degrees:

    ; SPEED: no need to do this lda
    lda ANGLE_INDEX+1
    bne is_high_positive_to_ray_index
is_low_positive_to_ray_index:
    ldy ANGLE_INDEX
    lda TANGENT_LOW,y             ; When the angle index >= 256, we retrieve to 256 positions further
    sta MULTIPLICAND
    lda TANGENT_HIGH,y             ; When the angle index >= 256, we retrieve to 256 positions further
    sta MULTIPLICAND+1
    bra got_tangent_to_ray
is_high_positive_to_ray_index:
    ldy ANGLE_INDEX
    lda TANGENT_LOW+256,y         ; When the angle index >= 256, we retrieve to 256 positions further
    sta MULTIPLICAND
    lda TANGENT_HIGH+256,y         ; When the angle index >= 256, we retrieve to 256 positions further
    sta MULTIPLICAND+1
got_tangent_to_ray:

    jsr MULT_WITH_NORMAL_DISTANCE
    
    lda WALL_FACING_DIR
    lsr
    bcc to_ray_on_horizontal_wall ; no carry (facing south or norht), so we its a horizontal wall

to_ray_on_vertical_wall:

    lda PRODUCT+1
    sta TO_DELTA_Y
    lda PRODUCT+2
    sta TO_DELTA_Y+1
    
    bra done_to_delta_calc
    
to_ray_on_horizontal_wall:
    
    lda PRODUCT+1
    sta TO_DELTA_X
    lda PRODUCT+2
    sta TO_DELTA_X+1
    
done_to_delta_calc:
    

    ; -- Re-calculate TO_QUADRANT using TO_ANGLE --

    ; FIXME: we first need to get the *absolute* angle for TO_ANGLE
    ;        right now we do this by "unnormalizing" it and checking the WALL_FACING_DIR
    ;        but there is probably a better way to do this (earlier).

    lda WALL_FACING_DIR
    cmp #3  ; west
    beq to_ray_calc_wall_facing_west
    cmp #2  ; south
    beq to_ray_calc_wall_facing_south
    cmp #1  ; east
    beq to_ray_calc_wall_facing_east
    cmp #0  ; north
    beq to_ray_calc_wall_facing_north

to_ray_calc_wall_facing_east:
    ; The wall is facing north so we are turned 270. We need to subtract 90 degrees
    sec
    lda TO_ANGLE
    sbc #<(1*456)
    sta ANGLE_INDEX
    lda TO_ANGLE+1
    sbc #>(1*456)
    sta ANGLE_INDEX+1
    bra unnormalized_to_ray

to_ray_calc_wall_facing_north:
    ; The wall is facing north so we are turned 180. We need to subtract 180 degrees
    sec
    lda TO_ANGLE
    sbc #<(2*456)
    sta ANGLE_INDEX
    lda TO_ANGLE+1
    sbc #>(2*456)
    sta ANGLE_INDEX+1
    bra unnormalized_to_ray
    
to_ray_calc_wall_facing_west:
    ; The wall is facing west so we are turned 90. We need to subtract 270 degrees
    sec
    lda TO_ANGLE
    sbc #<(3*456)
    sta ANGLE_INDEX
    lda TO_ANGLE+1
    sbc #>(3*456)
    sta ANGLE_INDEX+1
    bra unnormalized_to_ray
    
to_ray_calc_wall_facing_south:
    ; The wall is facing south so we are turned 0. No need to subtract anything.
    lda TO_ANGLE
    sta ANGLE_INDEX
    lda TO_ANGLE+1
    sta ANGLE_INDEX+1

unnormalized_to_ray:

    ; Checking if ANGLE_INDEX is below 0, if so add 1824
    bpl unnormalized_to_ray_is_positive
    
    clc 
    lda ANGLE_INDEX
    adc #<(4*456)
    sta ANGLE_INDEX
    lda ANGLE_INDEX+1
    adc #>(4*456)
    sta ANGLE_INDEX+1

unnormalized_to_ray_is_positive:
    
    lda ANGLE_INDEX+1
    cmp #>(456*1)
    bcc to_ray_in_q0
    bne to_ray_in_not_in_q0
    lda ANGLE_INDEX
    cmp #<(456*1)
    bcc to_ray_in_q0
    
to_ray_in_not_in_q0:
    lda ANGLE_INDEX+1
    cmp #>(456*2)
    bcc to_ray_in_q1
    bne to_ray_in_not_in_q1
    lda ANGLE_INDEX
    cmp #<(456*2)
    bcc to_ray_in_q1
    
to_ray_in_not_in_q1:
    lda ANGLE_INDEX+1
    cmp #>(456*3)
    bcc to_ray_in_q2
    bne to_ray_in_q3
    lda ANGLE_INDEX
    cmp #<(456*3)
    bcc to_ray_in_q2
    
to_ray_in_q3:
    ; Normalize angle (360 degrees - q3angle = q0angle)
    sec
    lda #<(456*4)
    sbc ANGLE_INDEX
    sta ANGLE_INDEX
    lda #>(456*4)
    sbc ANGLE_INDEX+1
    sta ANGLE_INDEX+1

    ; Mark as q3
    lda #%00000010
    sta TO_QUADRANT
    
    bra to_ray_info_updated
    
to_ray_in_q2:
    ; Normalize angle (q2angle - 180 degrees = q0angle)
    sec
    lda ANGLE_INDEX
    sbc #<(456*2)
    sta ANGLE_INDEX
    lda ANGLE_INDEX+1
    sbc #>(456*2)
    sta ANGLE_INDEX+1
    
    ; Mark as q2
    lda #%00000011
    sta TO_QUADRANT
    
    bra to_ray_info_updated
    
to_ray_in_q1:
    ; Normalize angle (180 degrees - q1angle = q0angle)
    sec
    lda #<(456*2)
    sbc ANGLE_INDEX
    sta ANGLE_INDEX
    lda #>(456*2)
    sbc ANGLE_INDEX+1
    sta ANGLE_INDEX+1
    
    ; Mark as q1
    lda #%00000001
    sta TO_QUADRANT
    
    bra to_ray_info_updated
    
to_ray_in_q0:

    ; SPEED: this doesnt do anything!
    lda ANGLE_INDEX
    sta ANGLE_INDEX
    lda ANGLE_INDEX+1
    sta ANGLE_INDEX+1
    
    ; Mark as q0
    lda #%00000000
    sta TO_QUADRANT

to_ray_info_updated:




    .if 0
; FIXME
;    stp
    lda SCREEN_START_ANGLE
    lda SCREEN_START_ANGLE+1
    
    nop
    
    lda FROM_ANGLE
    lda FROM_ANGLE+1
    
    nop
    
    lda TO_ANGLE
    lda TO_ANGLE+1

    nop
    nop

    lda LOOKING_DIR_QUANDRANT
    lda FROM_QUADRANT
    lda TO_QUADRANT
    
    nop
    
    lda FROM_DELTA_X
    lda FROM_DELTA_X+1
    
    nop
    
    lda FROM_DELTA_Y
    lda FROM_DELTA_Y+1
    
    nop
    
    lda TO_DELTA_X
    lda TO_DELTA_X+1
    
    nop

    lda TO_DELTA_Y
    lda TO_DELTA_Y+1
    
    lda LOOKING_DIR_COSINE
    lda LOOKING_DIR_COSINE+1
    
    lda LOOKING_DIR_SINE
    lda LOOKING_DIR_SINE+1
    
    .endif
    
    ; If we have done that, we can now determine the distance from the player-plane and the left and right parts of the wall-part:
    ;   normal_distance_to_point = delta_x * cos(player_angle) + delta_y * sin(player_angle)
    ; Given these two distances, we can also determine the left and right wall heights.

    ; ================ FROM DISTANCE ===============

    ; First we calculate the *positive* distance along the looking direction due to DELTA_X and DELTA_Y accordingly

    ; -- FROM: DISTANCE_DUE_TO_DELTA_X --

    lda FROM_DELTA_X
    sta MULTIPLICAND
    lda FROM_DELTA_X+1
    sta MULTIPLICAND+1

    jsr MULT_WITH_LOOK_DIR_SINE
    
    lda PRODUCT+1
    sta DISTANCE_DUE_TO_DELTA_X
    lda PRODUCT+2
    sta DISTANCE_DUE_TO_DELTA_X+1

    ; -- FROM: DISTANCE_DUE_TO_DELTA_Y --
    
    lda FROM_DELTA_Y
    sta MULTIPLICAND
    lda FROM_DELTA_Y+1
    sta MULTIPLICAND+1

    jsr MULT_WITH_LOOK_DIR_COSINE
    
    lda PRODUCT+1
    sta DISTANCE_DUE_TO_DELTA_Y
    lda PRODUCT+2
    sta DISTANCE_DUE_TO_DELTA_Y+1

    ; Now we need to know whether to negate either of these DISTANCES

    lda LOOKING_DIR_QUANDRANT
    eor FROM_QUADRANT             ; we XOR the bits with the FROM_QUADRANT. If bit 0 or 1 become a 1, this means there is a difference horizontally or vertically and we have to negate sine/cosine accordingly
    sta TMP1

from_check_vertical_difference:    
    and #%00000001  ; check vertical
    beq from_is_the_same_vertically
from_is_not_the_same_vertically:
    ; We negate the DISTANCE_DUE_TO_DELTA_Y
    sec
    lda #0
    sbc DISTANCE_DUE_TO_DELTA_Y
    sta DISTANCE_DUE_TO_DELTA_Y
    lda #0
    sbc DISTANCE_DUE_TO_DELTA_Y+1
    sta DISTANCE_DUE_TO_DELTA_Y+1

from_is_the_same_vertically:
    ; Nothing to do with the DISTANCE_DUE_TO_DELTA_Y


from_check_horizontal_difference:
    lda TMP1
    
    and #%00000010  ; check horizontal
    beq from_is_the_same_horizontally
from_is_not_the_same_horizontally:
    ; We negate the DISTANCE_DUE_TO_DELTA_X
    sec
    lda #0
    sbc DISTANCE_DUE_TO_DELTA_X
    sta DISTANCE_DUE_TO_DELTA_X
    lda #0
    sbc DISTANCE_DUE_TO_DELTA_X+1
    sta DISTANCE_DUE_TO_DELTA_X+1

from_is_the_same_horizontally:
    ; Nothing to do with the DISTANCE_DUE_TO_DELTA_X


    ; --- Calculate the distance and then the wall height ---
    clc
    lda DISTANCE_DUE_TO_DELTA_Y
    adc DISTANCE_DUE_TO_DELTA_X
    sta FROM_DISTANCE
    lda DISTANCE_DUE_TO_DELTA_Y+1
    adc DISTANCE_DUE_TO_DELTA_X+1
    sta FROM_DISTANCE+1
    
    ; FIXME: For now we do: 132.5*256/distance (Note: 265/2=132.5)
    lda #128        ; 0.5
    sta DIVIDEND
    lda #<(132)
    sta DIVIDEND+1
    
    lda FROM_DISTANCE
    sta DIVISOR
    lda FROM_DISTANCE+1
    sta DIVISOR+1
    
    ; SPEED: we can speed this up using a lookup table: distance2halfheight!
    jsr divide_16bits
    
    lda DIVIDEND
    sta FROM_HALF_WALL_HEIGHT
    

    ; ================ TO DISTANCE ===============
    
    ; First we calculate the *positive* distance along the looking direction due to DELTA_X and DELTA_Y accordingly

    ; -- TO: DISTANCE_DUE_TO_DELTA_X --

    lda TO_DELTA_X
    sta MULTIPLICAND
    lda TO_DELTA_X+1
    sta MULTIPLICAND+1

    jsr MULT_WITH_LOOK_DIR_SINE
    
    lda PRODUCT+1
    sta DISTANCE_DUE_TO_DELTA_X
    lda PRODUCT+2
    sta DISTANCE_DUE_TO_DELTA_X+1

    ; -- TO: DISTANCE_DUE_TO_DELTA_Y --
    
    lda TO_DELTA_Y
    sta MULTIPLICAND
    lda TO_DELTA_Y+1
    sta MULTIPLICAND+1

    jsr MULT_WITH_LOOK_DIR_COSINE
    
    lda PRODUCT+1
    sta DISTANCE_DUE_TO_DELTA_Y
    lda PRODUCT+2
    sta DISTANCE_DUE_TO_DELTA_Y+1

    ; Now we need to know whether to negate either of these DISTANCES

    lda LOOKING_DIR_QUANDRANT
    eor TO_QUADRANT             ; we XOR the bits with the TO_QUADRANT. If bit 0 or 1 become a 1, this means there is a difference horizontally or vertically and we have to negate sine/cosine accordingly
    sta TMP1

to_check_vertical_difference:    
    and #%00000001  ; check vertical
    beq to_is_the_same_vertically
to_is_not_the_same_vertically:
    ; We negate the DISTANCE_DUE_TO_DELTA_Y
    sec
    lda #0
    sbc DISTANCE_DUE_TO_DELTA_Y
    sta DISTANCE_DUE_TO_DELTA_Y
    lda #0
    sbc DISTANCE_DUE_TO_DELTA_Y+1
    sta DISTANCE_DUE_TO_DELTA_Y+1

to_is_the_same_vertically:
    ; Nothing to do with the DISTANCE_DUE_TO_DELTA_Y


to_check_horizontal_difference:
    lda TMP1
    
    and #%00000010  ; check horizontal
    beq to_is_the_same_horizontally
to_is_not_the_same_horizontally:
    ; We negate the DISTANCE_DUE_TO_DELTA_X
    sec
    lda #0
    sbc DISTANCE_DUE_TO_DELTA_X
    sta DISTANCE_DUE_TO_DELTA_X
    lda #0
    sbc DISTANCE_DUE_TO_DELTA_X+1
    sta DISTANCE_DUE_TO_DELTA_X+1

to_is_the_same_horizontally:
    ; Nothing to do with the DISTANCE_DUE_TO_DELTA_X


    ; --- Calculate the distance and then the wall height ---
    clc
    lda DISTANCE_DUE_TO_DELTA_Y
    adc DISTANCE_DUE_TO_DELTA_X
    sta TO_DISTANCE
    lda DISTANCE_DUE_TO_DELTA_Y+1
    adc DISTANCE_DUE_TO_DELTA_X+1
    sta TO_DISTANCE+1

    ; FIXME: For now we do: 132.5*256/distance (Note: 265.0/2 = 132.5)
    lda #128         ; 0.5
    sta DIVIDEND
    lda #<(132)
    sta DIVIDEND+1
    
    lda TO_DISTANCE
    sta DIVISOR
    lda TO_DISTANCE+1
    sta DIVISOR+1
    
    ; SPEED: we can speed this up using a lookup table: distance2halfheight!
    jsr divide_16bits
    
    lda DIVIDEND
    sta TO_HALF_WALL_HEIGHT

    
    ; We also have to determine whether the wall decreases (in height) from left to right, or the other way around and maybe do a different draw-wall-call accordingly
    
    lda #0
    sta WALL_HEIGHT_INCREASES
    
    sec
    lda FROM_HALF_WALL_HEIGHT
    sbc TO_HALF_WALL_HEIGHT
    bcs wall_height_incr_decr_determined

    lda #1
    sta WALL_HEIGHT_INCREASES
    
wall_height_incr_decr_determined:

    jsr draw_wall_part
    
    rts




    ; ==================================================================================================================================
    ;
    ;                                                            DRAW WALL PART
    ;
    ; ==================================================================================================================================
    
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
