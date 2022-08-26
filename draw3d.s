
update_viewpoint:

    ; FIXME: <BUG> Right now when we look right (at the 1.5,2 position) we see that the textures dont line up.
    
    ; FIXME: <BUG> When from/to delta_x/y are re-calculated you now get "1.02" and "3.0F" issues: this is because the delta_x/y are calculated from an (impresice) angle and multiplied! This probably gives some "rounding" errors...
    
    ; FIXME: <BUG> Right in the corners you can sometimes see a single column of the wrong texture.

    ; FIXME: We should add PLAYER_POS_X/Y and calcluate VIEWPOINT_X/Y from the player position and the LOOKING_DIR (every frame)
    ;        The viewpoint position is around 0.34 tiles "behind" the player position.

    ; x-position of the viewpoint (8.8 bits)
    lda PLAYER_POS_X
    sta VIEWPOINT_X 
    lda PLAYER_POS_X+1
    sta VIEWPOINT_X+1
    
    ; y-position of the viewpoint (8.8 bits)
    lda PLAYER_POS_Y
    sta VIEWPOINT_Y
    lda PLAYER_POS_Y+1
    sta VIEWPOINT_Y+1

    ; When calculating the distance to the wall (from the viewing-plane) we need the sine and cosine of the player direction
    ; But since we have the *absolute* values of DELTA_X and DELTA_Y, we also need the positive values of sine and cosine.
    ; Therefore we normalize the viewing angle first to the positive quadrants of both sine and cosine (which lies between 0 and 90 degrees)
    
    ; Apart from that we also have to mark the quarter the looking dir is in, so the calculation can negate the cosine/sine result
    ; when the ray for which the distance has to be calculated does not lie in the same quadrant.

    ; Two bits for LOOKING_DIR_QUANDRANT: 00 = q0 (ne), 01 = q1 (se), 11 = q2 (sw), 10 = q3 (nw) 
    ; This way you can easely check if something is in a different quadrant horizontally or vertically
    
    ; NOTE: I am (ab)using RAY_INDEX here for temporary storage of the normalized LOOKING_DIR
    
    lda LOOKING_DIR+1
    cmp #>(456*1)
    bcc looking_dir_in_q0
    bne looking_dir_in_not_in_q0
    lda LOOKING_DIR
    cmp #<(456*1)
    bcc looking_dir_in_q0
    
looking_dir_in_not_in_q0:
    lda LOOKING_DIR+1
    cmp #>(456*2)
    bcc looking_dir_in_q1
    bne looking_dir_in_not_in_q1
    lda LOOKING_DIR
    cmp #<(456*2)
    bcc looking_dir_in_q1
    
looking_dir_in_not_in_q1:
    lda LOOKING_DIR+1
    cmp #>(456*3)
    bcc looking_dir_in_q2
    bne looking_dir_in_q3
    lda LOOKING_DIR
    cmp #<(456*3)
    bcc looking_dir_in_q2
    
looking_dir_in_q3:
    ; FIXME, CHECK: we do -1 here, is this indeed the correct way?
    ; Normalize angle (360-1 degrees - q3angle = q0angle)
    sec
    lda #<(456*4-1)
    sbc LOOKING_DIR
    sta RAY_INDEX
    lda #>(456*4-1)
    sbc LOOKING_DIR+1
    sta RAY_INDEX+1

    ; Mark as q3
    lda #%00000010
    sta LOOKING_DIR_QUANDRANT
    
    bra looking_dir_info_updated
    
looking_dir_in_q2:
    ; Normalize angle (q2angle - 180 degrees = q0angle)
    sec
    lda LOOKING_DIR
    sbc #<(456*2)
    sta RAY_INDEX
    lda LOOKING_DIR+1
    sbc #>(456*2)
    sta RAY_INDEX+1
    
    ; Mark as q2
    lda #%00000011
    sta LOOKING_DIR_QUANDRANT
    
    bra looking_dir_info_updated
    
looking_dir_in_q1:
    ; FIXME, CHECK: we do -1 here, is this indeed the correct way?
    ; Normalize angle (180-1 degrees - q1angle = q0angle)
    sec
    lda #<(456*2-1)
    sbc LOOKING_DIR
    sta RAY_INDEX
    lda #>(456*2-1)
    sbc LOOKING_DIR+1
    sta RAY_INDEX+1
    
    ; Mark as q1
    lda #%00000001
    sta LOOKING_DIR_QUANDRANT
    
    bra looking_dir_info_updated
    
looking_dir_in_q0:

    lda LOOKING_DIR
    sta RAY_INDEX
    lda LOOKING_DIR+1
    sta RAY_INDEX+1
    
    ; Mark as q0
    lda #%00000000
    sta LOOKING_DIR_QUANDRANT


looking_dir_info_updated:

    ; Sine for looking dir
    
    lda RAY_INDEX+1
    bne is_high_index_sine
is_low_index_sine:
    ldy RAY_INDEX
    lda SINE_LOW,y
    sta LOOKING_DIR_SINE
    lda SINE_HIGH,y
    sta LOOKING_DIR_SINE+1
    bra got_looking_dir_sine
is_high_index_sine:
    ldy RAY_INDEX
    lda SINE_LOW+256,y         ; When the ray index >= 256, we retrieve from 256 positions further
    sta LOOKING_DIR_SINE
    lda SINE_HIGH+256,y        ; When the ray index >= 256, we retrieve from 256 positions further
    sta LOOKING_DIR_SINE+1
got_looking_dir_sine:

    ; Cosine for looking dir
    
    lda RAY_INDEX+1
    bne is_high_index_cosine
is_low_index_cosine:
    ldy RAY_INDEX
    lda COSINE_LOW,y
    sta LOOKING_DIR_COSINE
    lda COSINE_HIGH,y
    sta LOOKING_DIR_COSINE+1
    bra got_looking_dir_cosine
is_high_index_cosine:
    ldy RAY_INDEX
    lda COSINE_LOW+256,y         ; When the ray index >= 256, we retrieve from 256 positions further
    sta LOOKING_DIR_COSINE
    lda COSINE_HIGH+256,y        ; When the ray index >= 256, we retrieve from 256 positions further
    sta LOOKING_DIR_COSINE+1
got_looking_dir_cosine:

    rts
    
    
    
draw_3d_view:

    ; TODO: get a set of ordered walls (near to far) from some kind of BSP tree...
        ; Also check if walls are facing the right way? Or is that a given at this point?

    jsr draw_walls
    
    ; TODO: draw more than just the walls...

    rts


draw_walls:

    lda #0
;    lda #2
    sta CURRENT_WALL_INDEX

draw_next_wall:
    ldy CURRENT_WALL_INDEX
    
    lda WALL_INFO_START_X, y   ; x-coordinate of start of wall
    sta WALL_START_X
    
    lda WALL_INFO_START_Y, y   ; y-coordinate of start of wall
    sta WALL_START_Y
    
    lda WALL_INFO_END_X, y   ; x-coordinate of end of wall
    sta WALL_END_X
    
    lda WALL_INFO_END_Y, y   ; y-coordinate of end of wall
    sta WALL_END_Y
    
    lda WALL_INFO_FACING_DIR, y   ; facing direction of the wall: 0 = north, 1 = east, 2 = south, 3 = west
    sta WALL_FACING_DIR
    
    lda WALL_INFO_TEXTURE_LOW,y
    sta WALL_INFO_TEXTURE_INDEXES
    
    lda WALL_INFO_TEXTURE_HIGH,y
    sta WALL_INFO_TEXTURE_INDEXES+1
    
    jsr draw_wall
    
    inc CURRENT_WALL_INDEX
    lda CURRENT_WALL_INDEX
; FIXME: now limited to 1 wall
    cmp #8
;    cmp #3
    bne draw_next_wall
    
    rts
    

    
draw_wall:
    
    ; Steps:
    
    ; Given a wall, we determine whether its to the north, east, west or south of the player (so horizontal/vertical and on which side). 
    ; After that we can determine the length of normal line from the wall (x or y coord) to the player
    
    ; Given the direction the player is facing we can also determine what would be the screen start ray index (left most angle in the viewing area of the player, relative to the normal line)
    ; If we know what parts of the screen columns/rays have been drawn already, we can now cut-off left and right parts of the wall.
    
    ; SCREEN_START_RAY = (LOOKING_DIR - 30 degrees) - (WALL_FACING_DIR-2) * 90 degrees
    ; SCREEN_START_RAY = (LOOKING_DIR - 152) - (WALL_FACING_DIR-2) * 456
    
    ; We can now also determine from which and to which ray index the wall extends (relative to the normal line)
    
    ; BETTER IDEA: 1) check if dx < 0 and if dy < 0 (to see what quadrant youre in).  Note: maybe this is not needed if you know which way the wall is facing.
    ;              2) then normalize x and y to be positive
    ;              3) and check if dx < dy
    ;                  3a) if dy <= dx, then do: angle = invtan(dy/dx)
    ;                  3b) if dx < dy, then do: angle = 45 + (90 - invtan(dx/dy))
    ;                 -> this way the invtan only has to cover a number between 0.0 and 1.0 to result in 0-45 degrees (= 0-228 ray indexes)
    
    ; We use the QUADRANT_CORRECTION to store how many 90-degrees (quadrants) we have to be added at the end (in order to get a *normalized* result, so relative to the normal line)
    ; We use FLIP_TAN_ANGLE to store if the result of the tan() routine should be "flip": 90 degrees - tan()

    ; Assumptions:
    ;   0,0 starts at the most south-west position
    ;   angles run clock-wise (viewed from the top of the map) and starts due north (index = 0)
    ;   normally we do invtan(dx/dy) to get the angle. If we "flip" it, this means we do 90 degrees - invtan(dy/dx)
    ;   we use 0-1823 indexes instead of 0-360 degrees
    
    ; TODO: if the wall is facing the player from its back, we dont have to consider drawing it at all, so that could be an easy out.
    
    lda WALL_FACING_DIR
    cmp #3  ; west
    beq wall_facing_west_jmp
    cmp #2  ; south
    beq wall_facing_south_jmp
    cmp #1  ; east
    beq wall_facing_east_jmp
    cmp #0  ; north
    beq wall_facing_north_jmp

wall_facing_west_jmp:
    jmp wall_facing_west
wall_facing_south_jmp:
    jmp wall_facing_south
wall_facing_east_jmp:
    jmp wall_facing_east
wall_facing_north_jmp:
    jmp wall_facing_north
    
    ; FIXME: DOORS are not on .0 but 0.5 instead!!
    ; FIXME: Opening or closing doors do not start/stop on .0 but on some intermediate value instead!!
    
    
; #############################################################################################################
; #                                                                                                           #
; #                                            WALL FACING NORTH                                              #
; #                                                                                                           #
; #############################################################################################################

wall_facing_north:

    sec
    lda LOOKING_DIR
    sbc #<(152+456*2)
    sta SCREEN_START_RAY
    lda LOOKING_DIR+1
    sbc #>(152+456*2)
    sta SCREEN_START_RAY+1
    
    bpl wall_facing_north_screen_start_ray_calculated  ; if this is still positive we dont need to add 360 degrees (1824)
    
    clc
    lda SCREEN_START_RAY
    adc #<(1824)
    sta SCREEN_START_RAY
    lda SCREEN_START_RAY+1
    adc #>(1824)
    sta SCREEN_START_RAY+1

wall_facing_north_screen_start_ray_calculated:
    
    ; ============ START OF NORTH FACING WALL ===========

    ; First determine the normal distance to the wall, in the y-direction (delta Y)
    sec
    lda VIEWPOINT_Y
    sbc #0                      ; Walls are always on .0
    sta NORMAL_DISTANCE_TO_WALL
    sta DELTA_Y
    lda VIEWPOINT_Y+1
    sbc WALL_START_Y            ; it doesnt matter if we use WALL_START_Y or WALL_END_Y here
    sta NORMAL_DISTANCE_TO_WALL+1
    sta DELTA_Y+1
    
    ; Determine the distance in the x-direction (delta X) for the START of the wall
    sec
    lda #0                      ; Walls always start on .0
    sbc VIEWPOINT_X
    sta DELTA_X
    lda WALL_START_X
    sbc VIEWPOINT_X+1
    sta DELTA_X+1

    ; Check if DELTA_X is negative: if so, this means it starts to the west of the player, if not, it starts to the east
    bpl wall_facing_north_starting_east
    
wall_facing_north_starting_west:

    ; We need to correct the angle +0 quadrants to be normalized
    lda #0
    sta QUADRANT_CORRECTION
    
    ; By default we do not need to flip the tan() result in this quadrant
    lda #0
    sta FLIP_TAN_ANGLE
    
    lda #%00000011      ; we are quadrant q2 (code %00000011)
    sta FROM_QUADRANT
    
    ; negating DELTA_X
    sec
    lda #0
    sbc DELTA_X
    sta DELTA_X
    sta TEXTURE_COLUMN_OFFSET   ; In order to determine where a texture starts, this offset has to be subtracted
    lda #0
    sbc DELTA_X+1
    sta DELTA_X+1
    sta TEXTURE_INDEX_OFFSET    ; In order to determine which texture needs to be drawn, this offset has to be subtracted
    
    bra wall_facing_north_calc_angle_for_start_of_wall
    
wall_facing_north_starting_east:
    
    ; We need to correct the angle +3 quadrants to be normalized
    lda #3
    sta QUADRANT_CORRECTION
    
    ; By default we need to flip the tan() result in this quadrant
    lda #1
    sta FLIP_TAN_ANGLE
    
    lda #%00000001      ; we are quadrant q1 (code %00000001)
    sta FROM_QUADRANT
    
    ; negating DELTA_X (but only for TEXTURE_COLUMN_OFFSET and TEXTURE_INDEX_OFFSET)
    sec
    lda #0
    sbc DELTA_X
    sta TEXTURE_COLUMN_OFFSET   ; In order to determine where a texture starts, this offset has to be subtracted
    lda #0
    sbc DELTA_X+1
    sta TEXTURE_INDEX_OFFSET    ; In order to determine which texture needs to be drawn, this offset has to be subtracted
    
    bra wall_facing_north_calc_angle_for_start_of_wall
    
wall_facing_north_calc_angle_for_start_of_wall:
    jsr calc_angle_for_point
    
    ; FIXME: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_X
    sta FROM_DELTA_X
    lda DELTA_X+1
    sta FROM_DELTA_X+1
    
    ; FIXME: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_Y
    sta FROM_DELTA_Y
    lda DELTA_Y+1
    sta FROM_DELTA_Y+1
    
    lda RAY_INDEX
    sta FROM_RAY_INDEX
    lda RAY_INDEX+1
    sta FROM_RAY_INDEX+1

    ; ============ END OF NORTH FACING WALL ===========
    
    ; We already determined the distance in y-direction above 
    
    ;  ... So nothing todo here for DELTA_Y...

    ; Determine the distance in the x-direction (delta X) for the END of the wall
    sec
    lda #0                      ; Walls always end on .0
    sbc VIEWPOINT_X
    sta DELTA_X
    lda WALL_END_X
    sbc VIEWPOINT_X+1
    sta DELTA_X+1
    
    ; Check if DELTA_X is negative: if so, this means it end to the west of the player, if not, it end to the east
    bpl wall_facing_north_ending_east
    
wall_facing_north_ending_west:

    ; We need to correct the angle +0 quadrants to be normalized
    lda #0
    sta QUADRANT_CORRECTION
    
    ; By default we DONT need to flip the tan() result in this quadrant
    lda #0
    sta FLIP_TAN_ANGLE

    lda #%00000011      ; we are quadrant q2 (code %00000011)
    sta TO_QUADRANT

    ; negating DELTA_X
    sec
    lda #0
    sbc DELTA_X
    sta DELTA_X
    lda #0
    sbc DELTA_X+1
    sta DELTA_X+1
    
    bra wall_facing_north_calc_angle_for_end_of_wall
    
wall_facing_north_ending_east:
    
    ; We need to correct the angle +3 quadrants to be normalized
    lda #3
    sta QUADRANT_CORRECTION
    
    ; By default we need to flip the tan() result in this quadrant
    lda #1
    sta FLIP_TAN_ANGLE
    
    lda #%00000001      ; we are quadrant q1 (code %00000001)
    sta TO_QUADRANT

    ; bra wall_facing_north_calc_angle_for_end_of_wall
    
wall_facing_north_calc_angle_for_end_of_wall:
    jsr calc_angle_for_point
    
    ; FIXME: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_X
    sta TO_DELTA_X
    lda DELTA_X+1
    sta TO_DELTA_X+1
    
    ; FIXME: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_Y
    sta TO_DELTA_Y
    lda DELTA_Y+1
    sta TO_DELTA_Y+1

    lda RAY_INDEX
    sta TO_RAY_INDEX
    lda RAY_INDEX+1
    sta TO_RAY_INDEX+1
    
    jmp calculated_normal_distance_to_wall

    

; #############################################################################################################
; #                                                                                                           #
; #                                            WALL FACING WEST                                               #
; #                                                                                                           #
; #############################################################################################################

wall_facing_west:

    sec
    lda LOOKING_DIR
    sbc #<(152+456*1)
    sta SCREEN_START_RAY
    lda LOOKING_DIR+1
    sbc #>(152+456*1)
    sta SCREEN_START_RAY+1
    
    bpl wall_facing_west_screen_start_ray_calculated  ; if this is still positive we dont need to add 360 degrees (1824)
    
    clc
    lda SCREEN_START_RAY
    adc #<(1824)
    sta SCREEN_START_RAY
    lda SCREEN_START_RAY+1
    adc #>(1824)
    sta SCREEN_START_RAY+1

wall_facing_west_screen_start_ray_calculated:
    
    ; ============ START OF WEST FACING WALL ===========

    ; First determine the normal distance to the wall, in the x-direction (delta X)
    
    sec
    lda #0                      ; Walls are always on .0
    sbc VIEWPOINT_X
    sta NORMAL_DISTANCE_TO_WALL
    sta DELTA_X
    lda WALL_START_X            ; it doesnt matter if we use WALL_START_X or WALL_END_X here
    sbc VIEWPOINT_X+1
    sta NORMAL_DISTANCE_TO_WALL+1
    sta DELTA_X+1
    
    ; Determine the distance in the y-direction (delta Y) for the START of the wall
    sec
    lda #0                      ; Walls always start on .0
    sbc VIEWPOINT_Y
    sta DELTA_Y
    lda WALL_START_Y
    sbc VIEWPOINT_Y+1
    sta DELTA_Y+1
    
    ; Check if DELTA_Y is negative: if so, this means it starts to the south of the player, if not, it starts to the north
    bpl wall_facing_west_starting_north
    
wall_facing_west_starting_south:

    ; We need to correct the angle +0 quadrants to be normalized
    lda #0
    sta QUADRANT_CORRECTION
    
    ; By default we do need to flip the tan() result in this quadrant
    lda #1
    sta FLIP_TAN_ANGLE

    lda #%00000001      ; we are quadrant q1 (code %00000001)
    sta FROM_QUADRANT
    
    ; negating DELTA_Y
    sec
    lda #0
    sbc DELTA_Y
    sta DELTA_Y
    sta TEXTURE_COLUMN_OFFSET   ; In order to determine where a texture starts, this offset has to be subtracted
    lda #0
    sbc DELTA_Y+1
    sta DELTA_Y+1
    sta TEXTURE_INDEX_OFFSET    ; In order to determine which texture needs to be drawn, this offset has to be subtracted
    
    bra wall_facing_west_calc_angle_for_start_of_wall
    
wall_facing_west_starting_north:
    
    ; We need to correct the angle +3 quadrants to be normalized
    lda #3
    sta QUADRANT_CORRECTION
    
    ; By default we do not need to flip the tan() result in this quadrant
    lda #0
    sta FLIP_TAN_ANGLE
    
    lda #%00000000      ; we are quadrant q0 (code %00000000)
    sta FROM_QUADRANT
    
    ; negating DELTA_Y (but only for TEXTURE_COLUMN_OFFSET and TEXTURE_INDEX_OFFSET)
    sec
    lda #0
    sbc DELTA_Y
    sta TEXTURE_COLUMN_OFFSET   ; In order to determine where a texture starts, this offset has to be subtracted
    lda #0
    sbc DELTA_Y+1
    sta TEXTURE_INDEX_OFFSET    ; In order to determine which texture needs to be drawn, this offset has to be subtracted
    
    bra wall_facing_west_calc_angle_for_start_of_wall
    
wall_facing_west_calc_angle_for_start_of_wall:
    jsr calc_angle_for_point
    
    ; FIXME: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_X
    sta FROM_DELTA_X
    lda DELTA_X+1
    sta FROM_DELTA_X+1
    
    ; FIXME: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_Y
    sta FROM_DELTA_Y
    lda DELTA_Y+1
    sta FROM_DELTA_Y+1
    
    lda RAY_INDEX
    sta FROM_RAY_INDEX
    lda RAY_INDEX+1
    sta FROM_RAY_INDEX+1

    ; ============ END OF WEST FACING WALL ===========
    
    ; We already determined the distance in x-direction above 
    
    ;  ... So nothing todo here for DELTA_X...

    ; Determine the distance in the y-direction (delta Y) for the END of the wall
    sec
    lda #0                      ; Walls always end on .0
    sbc VIEWPOINT_Y
    sta DELTA_Y
    lda WALL_END_Y
    sbc VIEWPOINT_Y+1
    sta DELTA_Y+1
    
    ; Check if DELTA_Y is negative: if so, this means it end to the south of the player, if not, it starts to the north
    bpl wall_facing_west_ending_north
    
wall_facing_west_ending_south:

    ; We need to correct the angle +0 quadrants to be normalized
    lda #0
    sta QUADRANT_CORRECTION
    
    ; By default we do need to flip the tan() result in this quadrant
    lda #1
    sta FLIP_TAN_ANGLE

    lda #%00000001      ; we are quadrant q1 (code %00000001)
    sta TO_QUADRANT
    
    ; negating DELTA_Y
    sec
    lda #0
    sbc DELTA_Y
    sta DELTA_Y
    lda #0
    sbc DELTA_Y+1
    sta DELTA_Y+1
    
    bra wall_facing_west_calc_angle_for_end_of_wall
    
wall_facing_west_ending_north:
    
    ; We need to correct the angle +3 quadrants to be normalized
    lda #3
    sta QUADRANT_CORRECTION
    
    ; By default we dont need to flip the tan() result in this quadrant
    lda #0
    sta FLIP_TAN_ANGLE
    
    lda #%00000000      ; we are quadrant q0 (code %00000000)
    sta TO_QUADRANT
    
    ; bra wall_facing_west_calc_angle_for_end_of_wall
    
wall_facing_west_calc_angle_for_end_of_wall:
    jsr calc_angle_for_point
    
    ; FIXME: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_X
    sta TO_DELTA_X
    lda DELTA_X+1
    sta TO_DELTA_X+1
    
    ; FIXME: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_Y
    sta TO_DELTA_Y
    lda DELTA_Y+1
    sta TO_DELTA_Y+1

    lda RAY_INDEX
    sta TO_RAY_INDEX
    lda RAY_INDEX+1
    sta TO_RAY_INDEX+1
    
    jmp calculated_normal_distance_to_wall



; #############################################################################################################
; #                                                                                                           #
; #                                            WALL FACING SOUTH                                              #
; #                                                                                                           #
; #############################################################################################################

wall_facing_south:

    sec
    lda LOOKING_DIR
    sbc #<(152+456*0)
    sta SCREEN_START_RAY
    lda LOOKING_DIR+1
    sbc #>(152+456*0)
    sta SCREEN_START_RAY+1
    
    bpl wall_facing_south_screen_start_ray_calculated  ; if this is still positive we dont need to add 360 degrees (1824)
    
    clc
    lda SCREEN_START_RAY
    adc #<(1824)
    sta SCREEN_START_RAY
    lda SCREEN_START_RAY+1
    adc #>(1824)
    sta SCREEN_START_RAY+1

wall_facing_south_screen_start_ray_calculated:
    
    ; ============ START OF SOUTH FACING WALL ===========

    ; First determine the normal distance to the wall, in the y-direction (delta Y)
    sec
    lda #0                      ; Walls are always on .0
    sbc VIEWPOINT_Y
    sta NORMAL_DISTANCE_TO_WALL
    sta DELTA_Y
    lda WALL_START_Y            ; it doesnt matter if we use WALL_START_Y or WALL_END_Y here
    sbc VIEWPOINT_Y+1
    sta NORMAL_DISTANCE_TO_WALL+1
    sta DELTA_Y+1
    
    ; Determine the distance in the x-direction (delta X) for the START of the wall
    sec
    lda #0                      ; Walls always start on .0
    sbc VIEWPOINT_X
    sta DELTA_X
    sta TEXTURE_COLUMN_OFFSET   ; In order to determine where a texture starts, this offset has to be subtracted
    lda WALL_START_X
    sbc VIEWPOINT_X+1
    sta DELTA_X+1
    sta TEXTURE_INDEX_OFFSET    ; In order to determine which texture needs to be drawn, this offset has to be subtracted

    ; Check if DELTA_X is negative: if so, this means it starts to the west of the player, if not, it starts to the east
    bpl wall_facing_south_starting_east
    
wall_facing_south_starting_west:

    ; We need to correct the angle +3 quadrants to be normalized
    lda #3
    sta QUADRANT_CORRECTION
    
    ; By default we need to flip the tan() result in this quadrant
    lda #1
    sta FLIP_TAN_ANGLE

    lda #%00000010      ; we are quadrant q3 (code %00000010)
    sta FROM_QUADRANT
    
    ; negating DELTA_X
    sec
    lda #0
    sbc DELTA_X
    sta DELTA_X
    lda #0
    sbc DELTA_X+1
    sta DELTA_X+1
    
    bra wall_facing_south_calc_angle_for_start_of_wall
    
wall_facing_south_starting_east:
    
    ; We DONT need to correct the angle any quadrants to be normalized
    lda #0
    sta QUADRANT_CORRECTION
    
    ; By default we DONT need to flip the tan() result in this quadrant
    lda #0
    sta FLIP_TAN_ANGLE
    
    lda #%00000000      ; we are quadrant q0 (code %00000000)
    sta FROM_QUADRANT
    
    bra wall_facing_south_calc_angle_for_start_of_wall
    
wall_facing_south_calc_angle_for_start_of_wall:
    jsr calc_angle_for_point
    
    ; FIXME: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_X
    sta FROM_DELTA_X
    lda DELTA_X+1
    sta FROM_DELTA_X+1
    
    ; FIXME: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_Y
    sta FROM_DELTA_Y
    lda DELTA_Y+1
    sta FROM_DELTA_Y+1
    
    lda RAY_INDEX
    sta FROM_RAY_INDEX
    lda RAY_INDEX+1
    sta FROM_RAY_INDEX+1

    ; ============ END OF SOUTH FACING WALL ===========
    
    ; We already determined the distance in y-direction above 
    
    ;  ... So nothing todo here for DELTA_Y...

    ; Determine the distance in the x-direction (delta X) for the END of the wall
    sec
    lda #0                      ; Walls always end on .0
    sbc VIEWPOINT_X
    sta DELTA_X
    lda WALL_END_X
    sbc VIEWPOINT_X+1
    sta DELTA_X+1
    
    ; Check if DELTA_X is negative: if so, this means it end to the west of the player, if not, it end to the east
    bpl wall_facing_south_ending_east
    
wall_facing_south_ending_west:

    ; We need to correct the angle +3 quadrants to be normalized
    lda #3
    sta QUADRANT_CORRECTION
    
    ; By default we need to flip the tan() result in this quadrant
    lda #1
    sta FLIP_TAN_ANGLE

    lda #%00000010      ; we are quadrant q3 (code %00000010)
    sta TO_QUADRANT
    
    ; negating DELTA_X
    sec
    lda #0
    sbc DELTA_X
    sta DELTA_X
    lda #0
    sbc DELTA_X+1
    sta DELTA_X+1
    
    bra wall_facing_south_calc_angle_for_end_of_wall
    
wall_facing_south_ending_east:
    
    ; We DONT need to correct the angle any quadrants to be normalized
    lda #0
    sta QUADRANT_CORRECTION
    
    ; By default we DONT need to flip the tan() result in this quadrant
    lda #0
    sta FLIP_TAN_ANGLE
    
    lda #%00000000      ; we are quadrant q0 (code %00000000)
    sta TO_QUADRANT
    
    ; bra wall_facing_south_calc_angle_for_end_of_wall
    
wall_facing_south_calc_angle_for_end_of_wall:
    jsr calc_angle_for_point
    
    ; FIXME: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_X
    sta TO_DELTA_X
    lda DELTA_X+1
    sta TO_DELTA_X+1
    
    ; FIXME: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_Y
    sta TO_DELTA_Y
    lda DELTA_Y+1
    sta TO_DELTA_Y+1

    lda RAY_INDEX
    sta TO_RAY_INDEX
    lda RAY_INDEX+1
    sta TO_RAY_INDEX+1
    
    jmp calculated_normal_distance_to_wall
    
    

; #############################################################################################################
; #                                                                                                           #
; #                                            WALL FACING EAST                                               #
; #                                                                                                           #
; #############################################################################################################

wall_facing_east:

    sec
    lda LOOKING_DIR
    sbc #<(152+456*3)
    sta SCREEN_START_RAY
    lda LOOKING_DIR+1
    sbc #>(152+456*3)
    sta SCREEN_START_RAY+1
    
    bpl wall_facing_east_screen_start_ray_calculated  ; if this is still positive we dont need to add 360 degrees (1824)
    
    clc
    lda SCREEN_START_RAY
    adc #<(1824)
    sta SCREEN_START_RAY
    lda SCREEN_START_RAY+1
    adc #>(1824)
    sta SCREEN_START_RAY+1

wall_facing_east_screen_start_ray_calculated:
    
    ; ============ START OF EAST FACING WALL ===========

    ; First determine the normal distance to the wall, in the x-direction (delta X)
    
    sec
    lda VIEWPOINT_X
    sbc #0                      ; Walls are always on .0
    sta NORMAL_DISTANCE_TO_WALL
    sta DELTA_X
    lda VIEWPOINT_X+1
    sbc WALL_START_X            ; it doesnt matter if we use WALL_START_X or WALL_END_X here
    sta NORMAL_DISTANCE_TO_WALL+1
    sta DELTA_X+1
    
    ; Determine the distance in the y-direction (delta Y) for the START of the wall
    sec
    lda #0                      ; Walls always start on .0
    sbc VIEWPOINT_Y
    sta DELTA_Y
    sta TEXTURE_COLUMN_OFFSET   ; In order to determine where a texture starts, this offset has to be subtracted
    lda WALL_START_Y
    sbc VIEWPOINT_Y+1
    sta DELTA_Y+1
    sta TEXTURE_INDEX_OFFSET    ; In order to determine which texture needs to be drawn, this offset has to be subtracted

    ; Check if DELTA_Y is negative: if so, this means it starts to the south of the player, if not, it starts to the north
    bpl wall_facing_east_starting_north
    
wall_facing_east_starting_south:

    ; We need to correct the angle +2 quadrants to be normalized
    lda #3
    sta QUADRANT_CORRECTION
    
    ; By default we dont need to flip the tan() result in this quadrant
    lda #0
    sta FLIP_TAN_ANGLE

    lda #%00000011      ; we are quadrant q2 (code %00000011)
    sta FROM_QUADRANT
    
    ; negating DELTA_Y
    sec
    lda #0
    sbc DELTA_Y
    sta DELTA_Y
    lda #0
    sbc DELTA_Y+1
    sta DELTA_Y+1
    
    bra wall_facing_east_calc_angle_for_start_of_wall
    
wall_facing_east_starting_north:
    
    ; We need to correct the angle +3 quadrants to be normalized
    lda #0
    sta QUADRANT_CORRECTION
    
    ; By default we do need to flip the tan() result in this quadrant
    lda #1
    sta FLIP_TAN_ANGLE
    
    lda #%00000010      ; we are quadrant q3 (code %00000010)
    sta FROM_QUADRANT
    
    bra wall_facing_east_calc_angle_for_start_of_wall
    
wall_facing_east_calc_angle_for_start_of_wall:
    jsr calc_angle_for_point
    
    ; FIXME: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_X
    sta FROM_DELTA_X
    lda DELTA_X+1
    sta FROM_DELTA_X+1
    
    ; FIXME: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_Y
    sta FROM_DELTA_Y
    lda DELTA_Y+1
    sta FROM_DELTA_Y+1
    
    lda RAY_INDEX
    sta FROM_RAY_INDEX
    lda RAY_INDEX+1
    sta FROM_RAY_INDEX+1

    ; ============ END OF EAST FACING WALL ===========
    
    ; We already determined the distance in x-direction above 
    
    ;  ... So nothing todo here for DELTA_X...

    ; Determine the distance in the y-direction (delta Y) for the END of the wall
    sec
    lda #0                      ; Walls always end on .0
    sbc VIEWPOINT_Y
    sta DELTA_Y
    lda WALL_END_Y
    sbc VIEWPOINT_Y+1
    sta DELTA_Y+1
    
    ; Check if DELTA_Y is negative: if so, this means it end to the south of the player, if not, it starts to the north
    bpl wall_facing_east_ending_north
    
wall_facing_east_ending_south:

    ; We need to correct the angle +2 quadrants to be normalized
    lda #3
    sta QUADRANT_CORRECTION
    
    ; By default we do need to flip the tan() result in this quadrant
    lda #0
    sta FLIP_TAN_ANGLE

    lda #%00000011      ; we are quadrant q2 (code %00000011)
    sta TO_QUADRANT
    
    ; negating DELTA_Y
    sec
    lda #0
    sbc DELTA_Y
    sta DELTA_Y
    lda #0
    sbc DELTA_Y+1
    sta DELTA_Y+1
    
    bra wall_facing_east_calc_angle_for_end_of_wall
    
wall_facing_east_ending_north:
    
    ; We need to correct the angle +2 quadrants to be normalized
    lda #0
    sta QUADRANT_CORRECTION
    
    ; By default we dont need to flip the tan() result in this quadrant
    lda #1
    sta FLIP_TAN_ANGLE
    
    lda #%00000010      ; we are quadrant q3 (code %00000010)
    sta TO_QUADRANT
    
    ; bra wall_facing_east_calc_angle_for_end_of_wall
    
wall_facing_east_calc_angle_for_end_of_wall:
    jsr calc_angle_for_point
    
    ; FIXME: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_X
    sta TO_DELTA_X
    lda DELTA_X+1
    sta TO_DELTA_X+1
    
    ; FIXME: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_Y
    sta TO_DELTA_Y
    lda DELTA_Y+1
    sta TO_DELTA_Y+1

    lda RAY_INDEX
    sta TO_RAY_INDEX
    lda RAY_INDEX+1
    sta TO_RAY_INDEX+1
    
    jmp calculated_normal_distance_to_wall


    
calculated_normal_distance_to_wall:

; FIXME: we now do NOT cut off part of the wall! We still need to cut the wall into smaller pieces, what have not been drawn to the screen yet!
; FIXME: we now do NOT cut off part of the wall! We still need to cut the wall into smaller pieces, what have not been drawn to the screen yet!

    ; For now we ONLY cut off walls if they do not fit into the screen
    
    ; Check if start of wall is between the left and right of the screen
    ; To do this, we first need to know the ray number on the screen (FROM_RAY_INDEX - SCREEN_START_RAY)
    
    sec
    lda FROM_RAY_INDEX
    sbc SCREEN_START_RAY
    sta TESTING_RAY_INDEX
    lda FROM_RAY_INDEX+1
    sbc SCREEN_START_RAY+1
    sta TESTING_RAY_INDEX+1
    
    bpl from_testing_ray_is_positive
    
    ; If this becomes below 0 (meaning highest bit is 1) we have to add 1824 again.
    clc
    lda TESTING_RAY_INDEX
    adc #<(1824)
    sta TESTING_RAY_INDEX
    lda TESTING_RAY_INDEX+1
    adc #>(1824)
    sta TESTING_RAY_INDEX+1
    
from_testing_ray_is_positive:
    ; FIXME: We should check if its within 0 and 304 rays (first check left, then right)
    ; FIXME: hack
    cmp #5
    bcc from_ray_is_not_left_of_screen   
    
from_ray_is_left_of_screen:
    ; FIXME: only do this IF the wall is not COMPLETELY left of the screen! -> so check if the end of the wall is ALSO to the left of the screen!
    
    ; Cut off left part of wall to the beginning of the screen
    
    lda SCREEN_START_RAY
    sta FROM_RAY_INDEX
    lda SCREEN_START_RAY+1
    sta FROM_RAY_INDEX+1
    
    bra from_ray_is_within_the_screen
    
from_ray_is_not_left_of_screen:

    ; We also need to check if the from ray is to the *right* of the screen: check if its > 304
    lda TESTING_RAY_INDEX+1
    cmp #>(304)
    bcc from_ray_is_within_the_screen
    bne from_ray_is_right_of_screen
    lda TESTING_RAY_INDEX
    cmp #<(304)
    bcc from_ray_is_within_the_screen

from_ray_is_right_of_screen:
    ; FIXME: we should in fact check if there is another wall part possible?
    rts ; we are not drawing this wall, since its outside of the screen
    
    
from_ray_is_within_the_screen:
    ; Check if end of wall is between the left and right of the screen
    ; To do this, we first need to know the ray number on the screen (TO_RAY_INDEX - SCREEN_START_RAY)
    sec
    lda TO_RAY_INDEX
    sbc SCREEN_START_RAY
    sta TESTING_RAY_INDEX
    lda TO_RAY_INDEX+1
    sbc SCREEN_START_RAY+1
    sta TESTING_RAY_INDEX+1
    
    ; FIXME: because TO_RAY_INDEX now represents the ray+1 until we want to draw, we are here subscracting 1 for the TESTING_RAY_INDEX!
    ;        We might consider TO_RAY_INDEX containing the ray (not +1) until we want to draw

    ; SPEED: incremting TESTING_RAY_INDEX with 1 (this can probably be done quicker!)
    sec
    lda TESTING_RAY_INDEX
    sbc #<(1)
    sta TESTING_RAY_INDEX
    lda TESTING_RAY_INDEX+1
    sbc #>(1)
    sta TESTING_RAY_INDEX+1
    
    bpl to_testing_ray_is_positive
    
    ; If this becomes below 0 (meaning highest bit is 1) we have to add 1824 again.
    clc
    lda TESTING_RAY_INDEX
    adc #<(1824)
    sta TESTING_RAY_INDEX
    lda TESTING_RAY_INDEX+1
    adc #>(1824)
    sta TESTING_RAY_INDEX+1
    
to_testing_ray_is_positive:

    ; We check if the to-ray is not to the left of the screen
    ; FIXME: hack
    cmp #5
    bcc to_ray_is_not_left_of_screen
    
    ; If the to-ray is left of the screen, we should not draw the wall
    ; FIXME: we should in fact check if there is another wall part possible?
    rts 

to_ray_is_not_left_of_screen:

; FIXME: is this still correct? Since TESTING_RAY_INDEX was decremented by 1? Or is it NOW correct?

    ; Check if to ray > 60 degrees
    cmp #>(304)
    bcc to_ray_is_not_right_of_screen
    bne to_ray_is_on_right_of_screen
    lda TESTING_RAY_INDEX
    cmp #<(304)
    bcc to_ray_is_not_right_of_screen
    
to_ray_is_on_right_of_screen:
    ; Set to-ray to screen start ray + 60 degrees (right column of the screen)
    clc
    lda SCREEN_START_RAY
    adc #<(304)
    sta TO_RAY_INDEX
    lda SCREEN_START_RAY+1
    adc #>(304)
    sta TO_RAY_INDEX+1
    
    ; FIXME: checking if > $720, isnt there a nicer way?
    
    lda TO_RAY_INDEX+1
    cmp #>(1824)
    bcc to_ray_is_within_bounds
    bne to_ray_is_outside_bounds
    lda TO_RAY_INDEX
    cmp #<(1824)
    bcc to_ray_is_within_bounds

to_ray_is_outside_bounds:
    ; TO_RAY_INDEX is more than $720, so we have to subtract $720
    sec
    lda TO_RAY_INDEX
    sbc #<(1824)
    sta TO_RAY_INDEX
    lda TO_RAY_INDEX+1
    sbc #>(1824)
    sta TO_RAY_INDEX+1
    
to_ray_is_within_bounds:
    
    
    ; FIXME: only do this IF the wall is not COMPLETELY right of the screen!
    
to_ray_is_not_right_of_screen:


    ; ========== Recalculate FROM_RAY and TO_RAY INFO ===========
    
    ; Note that the FROM_RAY_INDEX is an angle that is relative to the normal line of the wall
    ; This means that it has to be between 270 and 90 degrees. In order to get the tangent(FROM_RAY_INDEX) we
    ; have to negate FROM_RAY_INDEX if it is 'negative'. Note that we do *not* need to negate the result of tangent
    ; since we also determine the quadrant in which the from way lies (and the cosine/sine use that)s
    
    ; Also: the tangent is the ratio of: distance-*over*-the-wall / normal-distance-*to*-the-wall
    ; We want to know the distance-*over*-the-wall. But this can be either FROM_DELTA_X or FROM_DELTA_Y
    ; In order for us to know this one we have to overwrite we look at the direction of the wall: 
    ;   is it horizontal? then we have to recalculate the FROM_DELTA_X
    ;   is it vertical? then we have to recalculate the FROM_DELTA_X
    ; To check whether a wall is horizontal, we simply check the lowest bit of WALL_FACING_DIR.
    
    
    ; -- Re-calculate FROM_DELTA_X **OR** FROM_DELTA_Y using tangent(FROM_RAY_INDEX) --
    
    ; Check if FROM_RAY_INDEX is 'negative' (between 270 degrees and 360)
    lda FROM_RAY_INDEX+1
    ; FIXME: hack!
    cmp #4
    bcc from_ray_is_already_between_0_and_90_degrees
    
    sec
    lda #<(1824)
    sbc FROM_RAY_INDEX
    sta RAY_INDEX
    lda #>(1824)
    sbc FROM_RAY_INDEX+1
    sta RAY_INDEX+1
    
    bra from_ray_is_now_between_0_and_90_degrees

from_ray_is_already_between_0_and_90_degrees:
    lda FROM_RAY_INDEX
    sta RAY_INDEX
    lda FROM_RAY_INDEX+1
    sta RAY_INDEX+1

from_ray_is_now_between_0_and_90_degrees:

    ; SPEED: no need to do this lda
    lda RAY_INDEX+1
    bne is_high_positive_from_ray_index
is_low_positive_from_ray_index:
    ldy RAY_INDEX
    lda TANGENT_LOW,y             ; When the ray index >= 256, we retrieve from 256 positions further
    sta MULTIPLIER
    lda TANGENT_HIGH,y             ; When the ray index >= 256, we retrieve from 256 positions further
    sta MULTIPLIER+1
    bra got_tangent_from_ray
is_high_positive_from_ray_index:
    ldy RAY_INDEX
    lda TANGENT_LOW+256,y         ; When the ray index >= 256, we retrieve from 256 positions further
    sta MULTIPLIER
    lda TANGENT_HIGH+256,y         ; When the ray index >= 256, we retrieve from 256 positions further
    sta MULTIPLIER+1
got_tangent_from_ray:

    lda NORMAL_DISTANCE_TO_WALL
    sta MULTIPLICAND
    lda NORMAL_DISTANCE_TO_WALL+1
    sta MULTIPLICAND+1

    jsr multply_16bits
    
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
    

    ; -- Re-calculate FROM_QUADRANT using FROM_RAY_INDEX --

    ; FIXME: we first need to get the *absolute* angle for FROM_RAY_INDEX
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
    lda FROM_RAY_INDEX
    sbc #<(1*456)
    sta RAY_INDEX
    lda FROM_RAY_INDEX+1
    sbc #>(1*456)
    sta RAY_INDEX+1
    bra unnormalized_from_ray

from_ray_calc_wall_facing_north:
    ; The wall is facing north so we are turned 180. We need to subtract 180 degrees
    sec
    lda FROM_RAY_INDEX
    sbc #<(2*456)
    sta RAY_INDEX
    lda FROM_RAY_INDEX+1
    sbc #>(2*456)
    sta RAY_INDEX+1
    bra unnormalized_from_ray
    
from_ray_calc_wall_facing_west:
    ; The wall is facing west so we are turned 90. We need to subtract 270 degrees
    sec
    lda FROM_RAY_INDEX
    sbc #<(3*456)
    sta RAY_INDEX
    lda FROM_RAY_INDEX+1
    sbc #>(3*456)
    sta RAY_INDEX+1
    bra unnormalized_from_ray
    
from_ray_calc_wall_facing_south:
    ; The wall is facing south so we are turned 0. No need to subtract anything.
    lda FROM_RAY_INDEX
    sta RAY_INDEX
    lda FROM_RAY_INDEX+1
    sta RAY_INDEX+1

unnormalized_from_ray:

    ; Checking if RAY_INDEX is below 0, if so add 1824
    bpl unnormalized_from_ray_is_positive
    
    clc 
    lda RAY_INDEX
    adc #<(4*456)
    sta RAY_INDEX
    lda RAY_INDEX+1
    adc #>(4*456)
    sta RAY_INDEX+1

unnormalized_from_ray_is_positive:
    
    lda RAY_INDEX+1
    cmp #>(456*1)
    bcc from_ray_in_q0
    bne from_ray_in_not_in_q0
    lda RAY_INDEX
    cmp #<(456*1)
    bcc from_ray_in_q0
    
from_ray_in_not_in_q0:
    lda RAY_INDEX+1
    cmp #>(456*2)
    bcc from_ray_in_q1
    bne from_ray_in_not_in_q1
    lda RAY_INDEX
    cmp #<(456*2)
    bcc from_ray_in_q1
    
from_ray_in_not_in_q1:
    lda RAY_INDEX+1
    cmp #>(456*3)
    bcc from_ray_in_q2
    bne from_ray_in_q3
    lda RAY_INDEX
    cmp #<(456*3)
    bcc from_ray_in_q2
    
from_ray_in_q3:
    ; Normalize angle (360 degrees - q3angle = q0angle)
    sec
    lda #<(456*4)
    sbc RAY_INDEX
    sta RAY_INDEX
    lda #>(456*4)
    sbc RAY_INDEX+1
    sta RAY_INDEX+1

    ; Mark as q3
    lda #%00000010
    sta FROM_QUADRANT
    
    bra from_ray_info_updated
    
from_ray_in_q2:
    ; Normalize angle (q2angle - 180 degrees = q0angle)
    sec
    lda RAY_INDEX
    sbc #<(456*2)
    sta RAY_INDEX
    lda RAY_INDEX+1
    sbc #>(456*2)
    sta RAY_INDEX+1
    
    ; Mark as q2
    lda #%00000011
    sta FROM_QUADRANT
    
    bra from_ray_info_updated
    
from_ray_in_q1:
    ; Normalize angle (180 degrees - q1angle = q0angle)
    sec
    lda #<(456*2)
    sbc RAY_INDEX
    sta RAY_INDEX
    lda #>(456*2)
    sbc RAY_INDEX+1
    sta RAY_INDEX+1
    
    ; Mark as q1
    lda #%00000001
    sta FROM_QUADRANT
    
    bra from_ray_info_updated
    
from_ray_in_q0:

    lda RAY_INDEX
    sta RAY_INDEX
    lda RAY_INDEX+1
    sta RAY_INDEX+1
    
    ; Mark as q0
    lda #%00000000
    sta FROM_QUADRANT

from_ray_info_updated:


    ; ============ TO RAY ==========
    
    ; -- Re-calculate TO_DELTA_X **OR** TO_DELTA_Y using tangent(TO_RAY_INDEX) --
    
    ; Check if TO_RAY_INDEX is 'negative' (between 270 degrees and 360)
    lda TO_RAY_INDEX+1
    ; FIXME: hack!
    cmp #4
    bcc to_ray_is_already_between_0_and_90_degrees
    
    sec
    lda #<(1824)
    sbc TO_RAY_INDEX
    sta RAY_INDEX
    lda #>(1824)
    sbc TO_RAY_INDEX+1
    sta RAY_INDEX+1
    
    bra to_ray_is_now_between_0_and_90_degrees

to_ray_is_already_between_0_and_90_degrees:
    lda TO_RAY_INDEX
    sta RAY_INDEX
    lda TO_RAY_INDEX+1
    sta RAY_INDEX+1

to_ray_is_now_between_0_and_90_degrees:

    ; SPEED: no need to do this lda
    lda RAY_INDEX+1
    bne is_high_positive_to_ray_index
is_low_positive_to_ray_index:
    ldy RAY_INDEX
    lda TANGENT_LOW,y             ; When the ray index >= 256, we retrieve to 256 positions further
    sta MULTIPLIER
    lda TANGENT_HIGH,y             ; When the ray index >= 256, we retrieve to 256 positions further
    sta MULTIPLIER+1
    bra got_tangent_to_ray
is_high_positive_to_ray_index:
    ldy RAY_INDEX
    lda TANGENT_LOW+256,y         ; When the ray index >= 256, we retrieve to 256 positions further
    sta MULTIPLIER
    lda TANGENT_HIGH+256,y         ; When the ray index >= 256, we retrieve to 256 positions further
    sta MULTIPLIER+1
got_tangent_to_ray:

    lda NORMAL_DISTANCE_TO_WALL
    sta MULTIPLICAND
    lda NORMAL_DISTANCE_TO_WALL+1
    sta MULTIPLICAND+1

    jsr multply_16bits
    
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
    

    ; -- Re-calculate TO_QUADRANT using TO_RAY_INDEX --

    ; FIXME: we first need to get the *absolute* angle for TO_RAY_INDEX
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
    lda TO_RAY_INDEX
    sbc #<(1*456)
    sta RAY_INDEX
    lda TO_RAY_INDEX+1
    sbc #>(1*456)
    sta RAY_INDEX+1
    bra unnormalized_to_ray

to_ray_calc_wall_facing_north:
    ; The wall is facing north so we are turned 180. We need to subtract 180 degrees
    sec
    lda TO_RAY_INDEX
    sbc #<(2*456)
    sta RAY_INDEX
    lda TO_RAY_INDEX+1
    sbc #>(2*456)
    sta RAY_INDEX+1
    bra unnormalized_to_ray
    
to_ray_calc_wall_facing_west:
    ; The wall is facing west so we are turned 90. We need to subtract 270 degrees
    sec
    lda TO_RAY_INDEX
    sbc #<(3*456)
    sta RAY_INDEX
    lda TO_RAY_INDEX+1
    sbc #>(3*456)
    sta RAY_INDEX+1
    bra unnormalized_to_ray
    
to_ray_calc_wall_facing_south:
    ; The wall is facing south so we are turned 0. No need to subtract anything.
    lda TO_RAY_INDEX
    sta RAY_INDEX
    lda TO_RAY_INDEX+1
    sta RAY_INDEX+1

unnormalized_to_ray:

    ; Checking if RAY_INDEX is below 0, if so add 1824
    bpl unnormalized_to_ray_is_positive
    
    clc 
    lda RAY_INDEX
    adc #<(4*456)
    sta RAY_INDEX
    lda RAY_INDEX+1
    adc #>(4*456)
    sta RAY_INDEX+1

unnormalized_to_ray_is_positive:
    
    lda RAY_INDEX+1
    cmp #>(456*1)
    bcc to_ray_in_q0
    bne to_ray_in_not_in_q0
    lda RAY_INDEX
    cmp #<(456*1)
    bcc to_ray_in_q0
    
to_ray_in_not_in_q0:
    lda RAY_INDEX+1
    cmp #>(456*2)
    bcc to_ray_in_q1
    bne to_ray_in_not_in_q1
    lda RAY_INDEX
    cmp #<(456*2)
    bcc to_ray_in_q1
    
to_ray_in_not_in_q1:
    lda RAY_INDEX+1
    cmp #>(456*3)
    bcc to_ray_in_q2
    bne to_ray_in_q3
    lda RAY_INDEX
    cmp #<(456*3)
    bcc to_ray_in_q2
    
to_ray_in_q3:
    ; Normalize angle (360 degrees - q3angle = q0angle)
    sec
    lda #<(456*4)
    sbc RAY_INDEX
    sta RAY_INDEX
    lda #>(456*4)
    sbc RAY_INDEX+1
    sta RAY_INDEX+1

    ; Mark as q3
    lda #%00000010
    sta TO_QUADRANT
    
    bra to_ray_info_updated
    
to_ray_in_q2:
    ; Normalize angle (q2angle - 180 degrees = q0angle)
    sec
    lda RAY_INDEX
    sbc #<(456*2)
    sta RAY_INDEX
    lda RAY_INDEX+1
    sbc #>(456*2)
    sta RAY_INDEX+1
    
    ; Mark as q2
    lda #%00000011
    sta TO_QUADRANT
    
    bra to_ray_info_updated
    
to_ray_in_q1:
    ; Normalize angle (180 degrees - q1angle = q0angle)
    sec
    lda #<(456*2)
    sbc RAY_INDEX
    sta RAY_INDEX
    lda #>(456*2)
    sbc RAY_INDEX+1
    sta RAY_INDEX+1
    
    ; Mark as q1
    lda #%00000001
    sta TO_QUADRANT
    
    bra to_ray_info_updated
    
to_ray_in_q0:

    lda RAY_INDEX
    sta RAY_INDEX
    lda RAY_INDEX+1
    sta RAY_INDEX+1
    
    ; Mark as q0
    lda #%00000000
    sta TO_QUADRANT

to_ray_info_updated:





; FIXME
;    stp
    lda SCREEN_START_RAY
    lda SCREEN_START_RAY+1
    
    nop
    
    lda FROM_RAY_INDEX
    lda FROM_RAY_INDEX+1
    
    nop
    
    lda TO_RAY_INDEX
    lda TO_RAY_INDEX+1

    nop
    nop
; FIXME:
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
    
    ; If we have done that, we can now determine the distance from the player-plane and the left and right parts of the wall-part:
    ;   normal_distance_to_point = delta_x * cos(player_angle) + delta_y * sin(player_angle)
    ; Given these two distances, we can also determine the left and right wall heights.

    ; ================ FROM DISTANCE ===============

    ; First we calculate the *positive* distance along the looking direction due to DELTA_X and DELTA_Y accordingly

    ; -- FROM: DISTANCE_DUE_TO_DELTA_X --

    ; SPEED: copying this 16-bit value is slow
    lda LOOKING_DIR_SINE
    sta MULTIPLIER
    lda LOOKING_DIR_SINE+1
    sta MULTIPLIER+1

    lda FROM_DELTA_X
    sta MULTIPLICAND
    lda FROM_DELTA_X+1
    sta MULTIPLICAND+1

    ; SPEED: this multiplier is SLOW
    jsr multply_16bits
    
    lda PRODUCT+1
    sta DISTANCE_DUE_TO_DELTA_X
    lda PRODUCT+2
    sta DISTANCE_DUE_TO_DELTA_X+1

    ; -- FROM: DISTANCE_DUE_TO_DELTA_Y --
    
    ; SPEED: copying this 16-bit value is slow
    lda LOOKING_DIR_COSINE
    sta MULTIPLIER
    lda LOOKING_DIR_COSINE+1
    sta MULTIPLIER+1

    lda FROM_DELTA_Y
    sta MULTIPLICAND
    lda FROM_DELTA_Y+1
    sta MULTIPLICAND+1

    ; SPEED: this multiplier is SLOW
    jsr multply_16bits
    
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
    
    ; FIXME: For now we do: 265.0*256/distance
    lda #0
    sta DIVIDEND
    lda #<(265)
    sta DIVIDEND+1
    lda #>(265)
    sta DIVIDEND+2
    
    lda FROM_DISTANCE
    sta DIVISOR
    lda FROM_DISTANCE+1
    sta DIVISOR+1
    lda #0
    sta DIVISOR+2
    
    ; SPEED: we can speed this up using a lookup table: distance2height!
    jsr divide_24bits
    
    lda DIVIDEND
    sta FROM_WALL_HEIGHT
    lda DIVIDEND+1
    sta FROM_WALL_HEIGHT+1
    

    ; ================ TO DISTANCE ===============
    
    ; First we calculate the *positive* distance along the looking direction due to DELTA_X and DELTA_Y accordingly

    ; -- TO: DISTANCE_DUE_TO_DELTA_X --

    ; SPEED: copying this 16-bit value is slow
    lda LOOKING_DIR_SINE
    sta MULTIPLIER
    lda LOOKING_DIR_SINE+1
    sta MULTIPLIER+1

    lda TO_DELTA_X
    sta MULTIPLICAND
    lda TO_DELTA_X+1
    sta MULTIPLICAND+1

    ; SPEED: this multiplier is SLOW
    jsr multply_16bits
    
    lda PRODUCT+1
    sta DISTANCE_DUE_TO_DELTA_X
    lda PRODUCT+2
    sta DISTANCE_DUE_TO_DELTA_X+1

    ; -- TO: DISTANCE_DUE_TO_DELTA_Y --
    
    ; SPEED: copying this 16-bit value is slow
    lda LOOKING_DIR_COSINE
    sta MULTIPLIER
    lda LOOKING_DIR_COSINE+1
    sta MULTIPLIER+1

    lda TO_DELTA_Y
    sta MULTIPLICAND
    lda TO_DELTA_Y+1
    sta MULTIPLICAND+1

    ; SPEED: this multiplier is SLOW
    jsr multply_16bits
    
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

    ; FIXME: For now we do: 265.0*256/distance
    lda #0
    sta DIVIDEND
    lda #<(265)
    sta DIVIDEND+1
    lda #>(265)
    sta DIVIDEND+2
    
    lda TO_DISTANCE
    sta DIVISOR
    lda TO_DISTANCE+1
    sta DIVISOR+1
    lda #0
    sta DIVISOR+2
    
    ; SPEED: we can speed this up using a lookup table: distance2height!
    jsr divide_24bits
    
    lda DIVIDEND
    sta TO_WALL_HEIGHT
    lda DIVIDEND+1
    sta TO_WALL_HEIGHT+1

    
    ; We also have to determine whether the wall decreases (in height) from left to right, or the other way around and maybe do a different draw-wall-call accordingly
    
    lda #0
    sta WALL_HEIGHT_INCREASES
    
    ; FIXME: If wall heights are between 0 and 255 we dont have to compare 16 bit anymore
    sec
    lda FROM_WALL_HEIGHT
    sbc TO_WALL_HEIGHT
    lda FROM_WALL_HEIGHT+1
    sbc TO_WALL_HEIGHT+1
    bpl wall_height_incr_decr_determined

    lda #1
    sta WALL_HEIGHT_INCREASES
    
wall_height_incr_decr_determined:

    jsr draw_wall_part
    
    rts


    
calc_angle_for_point:

    ; ---------------------------------------------------------------------------------------
    ; From here on, we calculate the angle based on the absolute values of DELTA_X and DELTA_Y
    ; We can -later on- normalize the result using QUADRANT_CORRECTION and FLIP_TAN_ANGLE
    ; The result is stored in RAY_INDEX
    ; ---------------------------------------------------------------------------------------

    ; Check if dx < dy
    lda DELTA_X+1
    cmp DELTA_Y+1
    beq dx_high_equal_to_dy_high
    bcc dx_smaller_than_dy
    bra dy_smaller_than_dx
dx_high_equal_to_dy_high:
    lda DELTA_X
    cmp DELTA_Y
    beq dx_equal_to_dy
    bcc dx_smaller_than_dy

dy_smaller_than_dx:
    ; We invert FLIP_TAN_ANGLE because y <= x
    lda FLIP_TAN_ANGLE
    eor #1
    sta FLIP_TAN_ANGLE

    ; We do (DELTA_Y*256)/(DELTA_X)
    lda #0
    sta DIVIDEND
    lda DELTA_Y
    sta DIVIDEND+1
    lda DELTA_Y+1
    sta DIVIDEND+2
    
    lda DELTA_X
    sta DIVISOR
    lda DELTA_X+1
    sta DIVISOR+1
    lda #0
    sta DIVISOR+2
    
    ; SPEED: can we speed this up?
    jsr divide_24bits
    
    ; We take the fraction-part, since that is the input/index of the invtangent table
    ldy DIVIDEND
    
    bra do_tan_lookup
    
dx_equal_to_dy:

    ; Since x and y are the same, we are at 45 degrees (228)
    lda #228
    sta RAY_INDEX
    lda #0              ; The angle from invtangent is always < 256 (so the high byte is 0)
    sta RAY_INDEX+1
    
    ; No need to look this up in the invtangent table
    
    bra tan_angle_result_is_correct
    
dx_smaller_than_dy:

    ; We do (DELTA_X*256)/(DELTA_Y)
    
    lda #0
    sta DIVIDEND
    lda DELTA_X
    sta DIVIDEND+1
    lda DELTA_X+1
    sta DIVIDEND+2
    
    lda DELTA_Y
    sta DIVISOR
    lda DELTA_Y+1
    sta DIVISOR+1
    lda #0
    sta DIVISOR+2
    
    ; SPEED: can we speed this up?
    jsr divide_24bits
    
    ; We take the fraction-part, since that is the input/index of the invtangent table
    ldy DIVIDEND
    
do_tan_lookup:
    
    lda invtangent, y
    
    sta RAY_INDEX
    lda #0              ; The angle from invtangent is always < 256 (so the high byte is 0)
    sta RAY_INDEX+1
    
    ; We check if the invtangent result should be flipped
    
    ldy FLIP_TAN_ANGLE
    beq tan_angle_result_is_correct
    
    sec
    lda #<(456)
    sbc RAY_INDEX
    sta RAY_INDEX
    lda #>(456)
    sbc RAY_INDEX+1   ; TODO: this is always 0, right? So we can save a clock cycle here...
    sta RAY_INDEX+1
    
tan_angle_result_is_correct:

    ; We assume here the (flipped) result of invtangent is in a
    
    ldy QUADRANT_CORRECTION
    beq add_0_quadrants_to_angle
    cpy #1
    beq add_1_quadrant_to_angle
    cpy #2
    beq add_2_quadrants_to_angle
    ; cpy #3
    ; beq add_3_quadrants_to_angle
    
add_3_quadrants_to_angle:
    clc
    lda RAY_INDEX
    adc #<(456*3)
    sta RAY_INDEX
    lda RAY_INDEX+1
    adc #>(456*3)
    sta RAY_INDEX+1
    bra done_adding_quadrants_to_angle
    
add_2_quadrants_to_angle:
    clc
    lda RAY_INDEX
    adc #<(456*2)
    sta RAY_INDEX
    lda RAY_INDEX+1
    adc #>(456*2)
    sta RAY_INDEX+1
    bra done_adding_quadrants_to_angle

add_1_quadrant_to_angle:
    clc
    lda RAY_INDEX
    adc #<(456*1)
    sta RAY_INDEX
    lda RAY_INDEX+1
    adc #>(456*1)
    sta RAY_INDEX+1
    bra done_adding_quadrants_to_angle
    
add_0_quadrants_to_angle:

done_adding_quadrants_to_angle:

    rts

draw_wall_part:

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
    sta WALL_HEIGHT_INCREMENT+2
    

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
    
    lda RAY_INDEX+1
    cmp #$2                       ; RAY_INDEX >= 512 ? (NOTE: we do not expect there to be angles between 90 degrees and 270 degrees. So check for ~100 degrees is good enough to see if we are in the 270-360 range = "negative")
    bcs is_negative_left
    
    lda RAY_INDEX+1
    bne is_high_positive_ray_index_left
is_low_positive_ray_index_left:
    ldy RAY_INDEX
    lda TANGENT_HIGH,y
    sta MULTIPLICAND+1
    lda TANGENT_LOW,y
    sta MULTIPLICAND
    bra got_tangent_left
is_high_positive_ray_index_left:
    ldy RAY_INDEX
    lda TANGENT_HIGH+256,y        ; When the ray index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND+1
    lda TANGENT_LOW+256,y         ; When the ray index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND
    bra got_tangent_left

is_negative_left:
    ; SPEED: we do this EACH time, this can be sped up!!

    ; We substract RAY_INDEX from 1824 (=$720)so we effectively negate it to allow is to use the (positive) tangent
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
    lda TANGENT_HIGH,y
    sta MULTIPLICAND+1
    lda TANGENT_LOW,y
    sta MULTIPLICAND
    bra got_negative_tangent_left
is_high_negative_ray_index_left:
    ldy RAY_INDEX_NEGATED
    lda TANGENT_HIGH+256,y        ; When the negated ray index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND+1
    lda TANGENT_LOW+256,y         ; When the negated ray index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND

got_negative_tangent_left:

    ; FIXME: shouldnt we do this AFTER the multiplication?

; FIXME: HACK!
    lda #1  ; we need to negate the result
    sta TMP2
    
    ; We negate the tangent result
;    sec
;    lda #0
;    sbc MULTIPLICAND
;    sta MULTIPLICAND
;    lda #0
;    sbc MULTIPLICAND+1
;    sta MULTIPLICAND+1

got_tangent_left:
    
    ; SPEED: use a FAST mutlipler and 'cache' the NORMAL_DISTANCE_TO_WALL! ( https://codebase64.org/doku.php?id=base:seriously_fast_multiplication )
    ;        note that this needs to run in RAM in order for the 'cache' to work.

    ; We do a * NORMAL_DISTANCE_TO_WALL, then a divide by 4 (256 positions in a cell, so to go to 64 we need to divide by 4). 
    
;    stp
    
    ; SPEED: copying this 16-bit value is slow
    lda NORMAL_DISTANCE_TO_WALL
    sta MULTIPLIER
    lda NORMAL_DISTANCE_TO_WALL+1
    sta MULTIPLIER+1

    ; SPEED: this multiplier is SLOW
    jsr multply_16bits
    
    ; FIXME: shouldnt we do this AFTER the multiplication?
; FIXME: HACK!
    lda TMP2
    beq product_ok_left
    
    ; We negate the tangent result
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
    
    tay
    
    lda (WALL_INFO_TEXTURE_INDEXES),y
    
    .if 0
    ; FIXME: use the high byte of the multiplication result to determine which texture to use! (possibly substract something from it to normalize it to start-at-0-index of the wall-pieces)
    and #01
    bne odd_texture_left
even_texture_left:
    lda #>TEXTURE_DATA
    bra texture_index_known_left
odd_texture_left:
    lda #>(TEXTURE_DATA+4096)
texture_index_known_left:
    .endif

    sta VERA_ADDR_HIGH
    
    lda PRODUCT+1
    lsr
    lsr
    and #$3F                ; we effectively do a 'mod 64'
    sta VERA_ADDR_LOW       ; We use x mod 64 as the texture-column number, so we set it as as the start byte of a column


    ; FIXME: we now use only one byte of the wall height, but we also need to check the high byte (unless we only use 256 *EVEN* wall heights)
    lda COLUMN_WALL_HEIGHT+1
    ; FIXME: ONLY USE *EVEN* WALL HEIGHTS??
    and #$FE ; make even
    sta RAM_BANK
    ; SPEED: remove this nop!
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
    
; FIXME: HACK!
    lda #0  ; default = no need to negate the result
    sta TMP2
    
    lda RAY_INDEX+1
    cmp #$2                       ; RAY_INDEX >= 512 ? (NOTE: we do not expect there to be angles between 90 degrees and 270 degrees. So check for ~100 degrees is good enough to see if we are in the 270-360 range = "negative")
    bcs is_negative_right
    
    lda RAY_INDEX+1
    bne is_high_positive_ray_index_right
is_low_positive_ray_index_right:
    ldy RAY_INDEX
    lda TANGENT_HIGH,y
    sta MULTIPLICAND+1
    lda TANGENT_LOW,y
    sta MULTIPLICAND
    bra got_tangent_right
is_high_positive_ray_index_right:
    ldy RAY_INDEX
    lda TANGENT_HIGH+256,y        ; When the ray index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND+1
    lda TANGENT_LOW+256,y         ; When the ray index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND
    
    bra got_tangent_right

is_negative_right:
    ; SPEED: we do this EACH time, this can be sped up!!

    ; We substract RAY_INDEX from 1824 (=$720)so we effectively negate it to allow is to use the (positive) tangent
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
    lda TANGENT_HIGH,y
    sta MULTIPLICAND+1
    lda TANGENT_LOW,y
    sta MULTIPLICAND
    bra got_negative_tangent_right
is_high_negative_ray_index_right:
    ldy RAY_INDEX_NEGATED
    lda TANGENT_HIGH+256,y        ; When the negated ray index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND+1
    lda TANGENT_LOW+256,y         ; When the negated ray index >= 256, we retrieve from 256 positions further
    sta MULTIPLICAND

got_negative_tangent_right:

    ; FIXME: shouldnt we do this AFTER the multiplication?

; FIXME: HACK!
    lda #1  ; we need to negate the result
    sta TMP2
    
    ; We negate the tangent result
;    sec
;    lda #0
;    sbc MULTIPLICAND
;    sta MULTIPLICAND
;    lda #0
;    sbc MULTIPLICAND+1
;    sta MULTIPLICAND+1
    
got_tangent_right:
    ; SPEED: use a FAST mutlipler and 'cache' the NORMAL_DISTANCE_TO_WALL! ( https://codebase64.org/doku.php?id=base:seriously_fast_multiplication )
    ;        note that this needs to run in RAM in order for the 'cache' to work.

    ; We do a * NORMAL_DISTANCE_TO_WALL, then a divide by 4 (256 positions in a cell, so to go to 64 we need to divide by 4). 
    
    ; SPEED: copying this 16-bit value is slow
    lda NORMAL_DISTANCE_TO_WALL
    sta MULTIPLIER
    lda NORMAL_DISTANCE_TO_WALL+1
    sta MULTIPLIER+1

    ; SPEED: this multiplier is SLOW
    jsr multply_16bits
    
; FIXME: HACK!
    lda TMP2
    beq product_ok_right
    
    ; We negate the tangent result
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
    ; FIXME: this sta is not needed
    sta PRODUCT+2
    
    tay
    
    lda (WALL_INFO_TEXTURE_INDEXES),y
    
    .if 0
    ; FIXME: use the high byte of the multiplication result to determine which texture to use! (possibly substract something from it to normalize it to start-at-0-index of the wall-pieces)
    and #01
    bne odd_texture_right
even_texture_right:
    lda #>TEXTURE_DATA
    bra texture_index_known_right
odd_texture_right:
    lda #>(TEXTURE_DATA+4096)
texture_index_known_right:
    .endif

    sta VERA_ADDR_HIGH
    
    lda PRODUCT+1
    lsr
    lsr
    and #$3F                ; we effectively do a 'mod 64'
    sta VERA_ADDR_LOW       ; We use x mod 64 as the texture-column number, so we set it as as the start byte of a column
    
    ; FIXME: we now use only one byte of the wall height, but we also need to check the high byte (unless we only use 256 *EVEN* wall heights)
    lda COLUMN_WALL_HEIGHT+1
    ; FIXME: ONLY USE *EVEN* WALL HEIGHTS??
    and #$FE ; make even
    sta RAM_BANK
    ; SPEED: remove this nop!
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
