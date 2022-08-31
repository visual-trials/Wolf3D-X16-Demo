
    ; ==================================================================================================================================
    ;
    ;                                                              DRAW WALL
    ;
    ; ==================================================================================================================================
    
    
draw_wall:
    
    ; Steps:
    
    ; Given a wall, we determine whether its to the north, east, west or south of the player (so horizontal/vertical and on which side). 
    ; After that we can determine the length of normal line from the wall (x or y coord) to the player
    
    ; Given the direction the player is facing we can also determine what would be the screen start angle index (left most angle in the viewing area of the player, relative to the normal line)
    ; If we know what parts of the screen columns/rays have been drawn already, we can now cut-off left and right parts of the wall.
    
    ; SCREEN_START_ANGLE = (LOOKING_DIR_ANGLE - 30 degrees) - (WALL_FACING_DIR-2) * 90 degrees
    ; SCREEN_START_ANGLE = (LOOKING_DIR_ANGLE - 152) - (WALL_FACING_DIR-2) * 456
    
    ; We can now also determine from which and to which angle index the wall extends (relative to the normal line)
    
    ; BETTER IDEA: 1) check if dx < 0 and if dy < 0 (to see what quadrant youre in).  Note: maybe this is not needed if you know which way the wall is facing.
    ;              2) then normalize x and y to be positive
    ;              3) and check if dx < dy
    ;                  3a) if dy <= dx, then do: angle = invtan(dy/dx)
    ;                  3b) if dx < dy, then do: angle = 45 + (90 - invtan(dx/dy))
    ;                 -> this way the invtan only has to cover a number between 0.0 and 1.0 to result in 0-45 degrees (= 0-228 angle indexes)
    
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

    ; First we determine the length of the wall
    
    sec
    lda WALL_START_X
    sbc WALL_END_X
    sta WALL_LENGTH
    
    ; Then we calculate the screen start ray

    sec
    lda LOOKING_DIR_ANGLE
    sbc #<(152+456*2)
    sta SCREEN_START_ANGLE
    lda LOOKING_DIR_ANGLE+1
    sbc #>(152+456*2)
    sta SCREEN_START_ANGLE+1
    
    bpl wall_facing_north_screen_start_ray_calculated  ; if this is still positive we dont need to add 360 degrees (1824)
    
    clc
    lda SCREEN_START_ANGLE
    adc #<(1824)
    sta SCREEN_START_ANGLE
    lda SCREEN_START_ANGLE+1
    adc #>(1824)
    sta SCREEN_START_ANGLE+1

wall_facing_north_screen_start_ray_calculated:
    
    ; ============ START OF NORTH FACING WALL ===========
    
    ; First determine the normal distance to the wall, in the y-direction (delta Y)
    sec
    lda VIEWPOINT_Y
    sbc WALL_POSITION_IN_TILE   ; = 128 if wall is a door, 0 if wall is not a door
    sta NORMAL_DISTANCE_TO_WALL
    sta DELTA_Y
    lda VIEWPOINT_Y+1
    sbc WALL_START_Y            ; it doesnt matter if we use WALL_START_Y or WALL_END_Y here
    sta NORMAL_DISTANCE_TO_WALL+1
    sta DELTA_Y+1
    
    ; Since the NORMAL_DISTANCE_TO_WALL has now been determined, we can prepare the multiplier that uses it
    jsr setup_multiply_with_normal_distance_16bit

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
    
    ; SPEED: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_X
    sta FROM_DELTA_X
    lda DELTA_X+1
    sta FROM_DELTA_X+1
    
    ; SPEED: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_Y
    sta FROM_DELTA_Y
    lda DELTA_Y+1
    sta FROM_DELTA_Y+1
    
    lda ANGLE_INDEX
    sta FROM_ANGLE
    lda ANGLE_INDEX+1
    sta FROM_ANGLE+1

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
    
    ; SPEED: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_X
    sta TO_DELTA_X
    lda DELTA_X+1
    sta TO_DELTA_X+1
    
    ; SPEED: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_Y
    sta TO_DELTA_Y
    lda DELTA_Y+1
    sta TO_DELTA_Y+1

    lda ANGLE_INDEX
    sta TO_ANGLE
    lda ANGLE_INDEX+1
    sta TO_ANGLE+1
    
    jmp split_wall_into_wall_parts

    

; #############################################################################################################
; #                                                                                                           #
; #                                            WALL FACING WEST                                               #
; #                                                                                                           #
; #############################################################################################################

wall_facing_west:

    ; First we determine the length of the wall
    
    sec
    lda WALL_END_Y
    sbc WALL_START_Y
    sta WALL_LENGTH
    
    ; Then we calculate the screen start ray

    sec
    lda LOOKING_DIR_ANGLE
    sbc #<(152+456*1)
    sta SCREEN_START_ANGLE
    lda LOOKING_DIR_ANGLE+1
    sbc #>(152+456*1)
    sta SCREEN_START_ANGLE+1
    
    bpl wall_facing_west_screen_start_ray_calculated  ; if this is still positive we dont need to add 360 degrees (1824)
    
    clc
    lda SCREEN_START_ANGLE
    adc #<(1824)
    sta SCREEN_START_ANGLE
    lda SCREEN_START_ANGLE+1
    adc #>(1824)
    sta SCREEN_START_ANGLE+1

wall_facing_west_screen_start_ray_calculated:
    
    ; ============ START OF WEST FACING WALL ===========

    ; First determine the normal distance to the wall, in the x-direction (delta X)

    sec
    lda WALL_POSITION_IN_TILE   ; = 128 if wall is a door, 0 if wall is not a door
    sbc VIEWPOINT_X
    sta NORMAL_DISTANCE_TO_WALL
    sta DELTA_X
    lda WALL_START_X            ; it doesnt matter if we use WALL_START_X or WALL_END_X here
    sbc VIEWPOINT_X+1
    sta NORMAL_DISTANCE_TO_WALL+1
    sta DELTA_X+1
    
    ; Since the NORMAL_DISTANCE_TO_WALL has now been determined, we can prepare the multiplier that uses it
    jsr setup_multiply_with_normal_distance_16bit

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
    
    ; SPEED: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_X
    sta FROM_DELTA_X
    lda DELTA_X+1
    sta FROM_DELTA_X+1
    
    ; SPEED: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_Y
    sta FROM_DELTA_Y
    lda DELTA_Y+1
    sta FROM_DELTA_Y+1
    
    lda ANGLE_INDEX
    sta FROM_ANGLE
    lda ANGLE_INDEX+1
    sta FROM_ANGLE+1

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
    
    ; SPEED: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_X
    sta TO_DELTA_X
    lda DELTA_X+1
    sta TO_DELTA_X+1
    
    ; SPEED: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_Y
    sta TO_DELTA_Y
    lda DELTA_Y+1
    sta TO_DELTA_Y+1

    lda ANGLE_INDEX
    sta TO_ANGLE
    lda ANGLE_INDEX+1
    sta TO_ANGLE+1
    
    jmp split_wall_into_wall_parts



; #############################################################################################################
; #                                                                                                           #
; #                                            WALL FACING SOUTH                                              #
; #                                                                                                           #
; #############################################################################################################

wall_facing_south:

    ; First we determine the length of the wall
    
    sec
    lda WALL_END_X
    sbc WALL_START_X
    sta WALL_LENGTH
    
    ; Then we calculate the screen start ray

    sec
    lda LOOKING_DIR_ANGLE
    sbc #<(152+456*0)
    sta SCREEN_START_ANGLE
    lda LOOKING_DIR_ANGLE+1
    sbc #>(152+456*0)
    sta SCREEN_START_ANGLE+1
    
    bpl wall_facing_south_screen_start_ray_calculated  ; if this is still positive we dont need to add 360 degrees (1824)
    
    clc
    lda SCREEN_START_ANGLE
    adc #<(1824)
    sta SCREEN_START_ANGLE
    lda SCREEN_START_ANGLE+1
    adc #>(1824)
    sta SCREEN_START_ANGLE+1

wall_facing_south_screen_start_ray_calculated:
    
    ; ============ START OF SOUTH FACING WALL ===========

    
    ; First determine the normal distance to the wall, in the y-direction (delta Y)
    sec
    lda WALL_POSITION_IN_TILE   ; = 128 if wall is a door, 0 if wall is not a door
    sbc VIEWPOINT_Y
    sta NORMAL_DISTANCE_TO_WALL
    sta DELTA_Y
    lda WALL_START_Y            ; it doesnt matter if we use WALL_START_Y or WALL_END_Y here
    sbc VIEWPOINT_Y+1
    sta NORMAL_DISTANCE_TO_WALL+1
    sta DELTA_Y+1
    
    ; Since the NORMAL_DISTANCE_TO_WALL has now been determined, we can prepare the multiplier that uses it
    jsr setup_multiply_with_normal_distance_16bit

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
    
    ; SPEED: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_X
    sta FROM_DELTA_X
    lda DELTA_X+1
    sta FROM_DELTA_X+1
    
    ; SPEED: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_Y
    sta FROM_DELTA_Y
    lda DELTA_Y+1
    sta FROM_DELTA_Y+1
    
    lda ANGLE_INDEX
    sta FROM_ANGLE
    lda ANGLE_INDEX+1
    sta FROM_ANGLE+1

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
    
    ; SPEED: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_X
    sta TO_DELTA_X
    lda DELTA_X+1
    sta TO_DELTA_X+1
    
    ; SPEED: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_Y
    sta TO_DELTA_Y
    lda DELTA_Y+1
    sta TO_DELTA_Y+1

    lda ANGLE_INDEX
    sta TO_ANGLE
    lda ANGLE_INDEX+1
    sta TO_ANGLE+1
    
    jmp split_wall_into_wall_parts
    
    

; #############################################################################################################
; #                                                                                                           #
; #                                            WALL FACING EAST                                               #
; #                                                                                                           #
; #############################################################################################################

wall_facing_east:

    ; First we determine the length of the wall
    
    sec
    lda WALL_START_Y
    sbc WALL_END_Y
    sta WALL_LENGTH
    
    ; Then we calculate the screen start ray

    sec
    lda LOOKING_DIR_ANGLE
    sbc #<(152+456*3)
    sta SCREEN_START_ANGLE
    lda LOOKING_DIR_ANGLE+1
    sbc #>(152+456*3)
    sta SCREEN_START_ANGLE+1
    
    bpl wall_facing_east_screen_start_ray_calculated  ; if this is still positive we dont need to add 360 degrees (1824)
    
    clc
    lda SCREEN_START_ANGLE
    adc #<(1824)
    sta SCREEN_START_ANGLE
    lda SCREEN_START_ANGLE+1
    adc #>(1824)
    sta SCREEN_START_ANGLE+1

wall_facing_east_screen_start_ray_calculated:
    
    ; ============ START OF EAST FACING WALL ===========

    ; First determine the normal distance to the wall, in the x-direction (delta X)
    
    sec
    lda VIEWPOINT_X
    sbc WALL_POSITION_IN_TILE   ; = 128 if wall is a door, 0 if wall is not a door
    sta NORMAL_DISTANCE_TO_WALL
    sta DELTA_X
    lda VIEWPOINT_X+1
    sbc WALL_START_X            ; it doesnt matter if we use WALL_START_X or WALL_END_X here
    sta NORMAL_DISTANCE_TO_WALL+1
    sta DELTA_X+1
    
    ; Since the NORMAL_DISTANCE_TO_WALL has now been determined, we can prepare the multiplier that uses it
    jsr setup_multiply_with_normal_distance_16bit

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
    
    ; SPEED: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_X
    sta FROM_DELTA_X
    lda DELTA_X+1
    sta FROM_DELTA_X+1
    
    ; SPEED: right now we are copying the results to FROM_ variables. We want to get rid of this
    lda DELTA_Y
    sta FROM_DELTA_Y
    lda DELTA_Y+1
    sta FROM_DELTA_Y+1
    
    lda ANGLE_INDEX
    sta FROM_ANGLE
    lda ANGLE_INDEX+1
    sta FROM_ANGLE+1

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
    
    ; SPEED: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_X
    sta TO_DELTA_X
    lda DELTA_X+1
    sta TO_DELTA_X+1
    
    ; SPEED: right now we are copying the results to TO_ variables. We want to get rid of this
    lda DELTA_Y
    sta TO_DELTA_Y
    lda DELTA_Y+1
    sta TO_DELTA_Y+1

    lda ANGLE_INDEX
    sta TO_ANGLE
    lda ANGLE_INDEX+1
    sta TO_ANGLE+1
    
    ; SPEED: this jmp is not needed here
    jmp split_wall_into_wall_parts


    
split_wall_into_wall_parts:


    ; ==================================================================================================================================
    ;
    ;                                                   SPLIT WALL INTO WALL PARTS
    ;
    ; ==================================================================================================================================


    ; FIXME: we now do NOT cut off part of the wall! We still need to cut the wall into smaller pieces, what have not been drawn to the screen yet!
    ; FIXME: we now do NOT cut off part of the wall! We still need to cut the wall into smaller pieces, what have not been drawn to the screen yet!

    ; For now we ONLY cut off walls if they do not fit into the screen
        
    lda #0
    sta FROM_RAY_NEEDS_RECALC
    sta TO_RAY_NEEDS_RECALC
    
    ; Check if start of wall is between the left and right of the screen
    ; To do this, we first need to know the ray number on the screen (FROM_ANGLE - SCREEN_START_ANGLE)
    
    sec
    lda FROM_ANGLE
    sbc SCREEN_START_ANGLE
    sta TESTING_ANGLE
    lda FROM_ANGLE+1
    sbc SCREEN_START_ANGLE+1
    sta TESTING_ANGLE+1
    
    bpl from_testing_ray_is_positive
    
    ; If this becomes below 0 (meaning highest bit is 1) we have to add 1824 again.
    clc
    lda TESTING_ANGLE
    adc #<(1824)
    sta TESTING_ANGLE
    lda TESTING_ANGLE+1
    adc #>(1824)
    sta TESTING_ANGLE+1
    
from_testing_ray_is_positive:
    ; We check if its within 0 and 304 rays (first check left, then right)
    ; FIXME: hack
    cmp #5
    bcc from_ray_is_not_left_of_screen   
    
from_ray_is_left_of_screen:
    ; SPEED: only do this IF the wall is not COMPLETELY left of the screen! -> so check if the end of the wall is ALSO to the left of the screen!D
    
    ; Cut off left part of wall to the beginning of the screen
    
    lda SCREEN_START_ANGLE
    sta FROM_ANGLE
    lda SCREEN_START_ANGLE+1
    sta FROM_ANGLE+1
    
    lda #1
    sta FROM_RAY_NEEDS_RECALC
    
    bra from_ray_is_within_the_screen
    
from_ray_is_not_left_of_screen:

    ; We also need to check if the from ray is to the *right* of the screen: check if its > 304
    lda TESTING_ANGLE+1
    cmp #>(304)
    bcc from_ray_is_within_the_screen
    bne from_ray_is_right_of_screen
    lda TESTING_ANGLE
    cmp #<(304)
    bcc from_ray_is_within_the_screen

from_ray_is_right_of_screen:
    ; FIXME: we should in fact check if there is another wall part possible?
    rts ; we are not drawing this wall, since its outside of the screen
    
    
from_ray_is_within_the_screen:
    ; Check if end of wall is between the left and right of the screen
    ; To do this, we first need to know the ray number on the screen (TO_ANGLE - SCREEN_START_ANGLE)
    sec
    lda TO_ANGLE
    sbc SCREEN_START_ANGLE
    sta TESTING_ANGLE
    lda TO_ANGLE+1
    sbc SCREEN_START_ANGLE+1
    sta TESTING_ANGLE+1
    
    ; FIXME: because TO_ANGLE now represents the ray+1 until we want to draw, we are here subscracting 1 for the TESTING_ANGLE!
    ;        We might consider TO_ANGLE containing the ray (not +1) until we want to draw

    ; SPEED: incremting TESTING_ANGLE with 1 (this can probably be done quicker!)
    sec
    lda TESTING_ANGLE
    sbc #<(1)
    sta TESTING_ANGLE
    lda TESTING_ANGLE+1
    sbc #>(1)
    sta TESTING_ANGLE+1
    
    bpl to_testing_ray_is_positive
    
    ; If this becomes below 0 (meaning highest bit is 1) we have to add 1824 again.
    clc
    lda TESTING_ANGLE
    adc #<(1824)
    sta TESTING_ANGLE
    lda TESTING_ANGLE+1
    adc #>(1824)
    sta TESTING_ANGLE+1
    
to_testing_ray_is_positive:

    ; We check if the to-ray is not to the left of the screen
    ; FIXME: hack
    cmp #5
    bcc to_ray_is_not_left_of_screen
    
    ; If the to-ray is left of the screen, we should not draw the wall
    ; FIXME: we should in fact check if there is another wall part possible?
    rts 

to_ray_is_not_left_of_screen:

; FIXME: is this still correct? Since TESTING_ANGLE was decremented by 1? Or is it NOW correct?

    ; Check if to ray > 60 degrees
    cmp #>(304)
    bcc to_ray_is_not_right_of_screen
    bne to_ray_is_on_right_of_screen
    lda TESTING_ANGLE
    cmp #<(304)
    bcc to_ray_is_not_right_of_screen
    
to_ray_is_on_right_of_screen:

    lda #1
    sta TO_RAY_NEEDS_RECALC
    
    ; Set to-ray to screen start ray + 60 degrees (right column of the screen)
    clc
    lda SCREEN_START_ANGLE
    adc #<(304)
    sta TO_ANGLE
    lda SCREEN_START_ANGLE+1
    adc #>(304)
    sta TO_ANGLE+1
    
    ; FIXME: checking if > $720, isnt there a nicer way?
    
    lda TO_ANGLE+1
    cmp #>(1824)
    bcc to_ray_is_within_bounds
    bne to_ray_is_outside_bounds
    lda TO_ANGLE
    cmp #<(1824)
    bcc to_ray_is_within_bounds

to_ray_is_outside_bounds:
    ; TO_ANGLE is more than $720, so we have to subtract $720
    sec
    lda TO_ANGLE
    sbc #<(1824)
    sta TO_ANGLE
    lda TO_ANGLE+1
    sbc #>(1824)
    sta TO_ANGLE+1
    
to_ray_is_within_bounds:
    
    
to_ray_is_not_right_of_screen:



    jsr prep_and_draw_wall_part
    
    
    rts
    
    


    ; ==================================================================================================================================
    ;
    ;                                                           CALC ANGLE FOR POINT
    ;
    ; ==================================================================================================================================
    
    
calc_angle_for_point:

    ; ---------------------------------------------------------------------------------------
    ; From here on, we calculate the angle based on the absolute values of DELTA_X and DELTA_Y
    ; We can -later on- normalize the result using QUADRANT_CORRECTION and FLIP_TAN_ANGLE
    ; The result is stored in ANGLE_INDEX
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
    sta ANGLE_INDEX
    lda #0              ; The angle from invtangent is always < 256 (so the high byte is 0)
    sta ANGLE_INDEX+1
    
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
    
    sta ANGLE_INDEX
    lda #0              ; The angle from invtangent is always < 256 (so the high byte is 0)
    sta ANGLE_INDEX+1
    
    ; We check if the invtangent result should be flipped
    
    ldy FLIP_TAN_ANGLE
    beq tan_angle_result_is_correct
    
    sec
    lda #<(456)
    sbc ANGLE_INDEX
    sta ANGLE_INDEX
    lda #>(456)
    sbc ANGLE_INDEX+1   ; TODO: this is always 0, right? So we can save a clock cycle here...
    sta ANGLE_INDEX+1
    
tan_angle_result_is_correct:

    ; We assume here the (flipped) result of invtangent is in a range of 0 to 90 degrees (0-456)
    
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
    lda ANGLE_INDEX
    adc #<(456*3)
    sta ANGLE_INDEX
    lda ANGLE_INDEX+1
    adc #>(456*3)
    sta ANGLE_INDEX+1
    bra done_adding_quadrants_to_angle
    
add_2_quadrants_to_angle:
    clc
    lda ANGLE_INDEX
    adc #<(456*2)
    sta ANGLE_INDEX
    lda ANGLE_INDEX+1
    adc #>(456*2)
    sta ANGLE_INDEX+1
    bra done_adding_quadrants_to_angle

add_1_quadrant_to_angle:
    clc
    lda ANGLE_INDEX
    adc #<(456*1)
    sta ANGLE_INDEX
    lda ANGLE_INDEX+1
    adc #>(456*1)
    sta ANGLE_INDEX+1
    bra done_adding_quadrants_to_angle
    
add_0_quadrants_to_angle:

done_adding_quadrants_to_angle:

    rts

