

; FIXME: this is temporary data to get some wall information into the engine

wall_0_info:
    .byte 0, 3 ; start x, y
    .byte 3, 3 ; end x, y
    .byte 2    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    
wall_1_info:
    .byte 3, 3 ; start x, y
    .byte 3, 0 ; end x, y
    .byte 3    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west

wall_2_info:
    .byte 0, 0 ; start x, y
    .byte 0, 3 ; end x, y
    .byte 1    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    
setup_wall_info:

    ldy #0
    
    lda wall_0_info
    sta WALL_INFO_START_X, y
    lda wall_0_info+1
    sta WALL_INFO_START_Y, y
    lda wall_0_info+2
    sta WALL_INFO_END_X, y
    lda wall_0_info+3
    sta WALL_INFO_END_Y, y
    lda wall_0_info+4
    sta WALL_INFO_FACING_DIR, y

    ldy #1

    lda wall_1_info
    sta WALL_INFO_START_X, y
    lda wall_1_info+1
    sta WALL_INFO_START_Y, y
    lda wall_1_info+2
    sta WALL_INFO_END_X, y
    lda wall_1_info+3
    sta WALL_INFO_END_Y, y
    lda wall_1_info+4
    sta WALL_INFO_FACING_DIR, y
    
    ldy #2

    lda wall_2_info
    sta WALL_INFO_START_X, y
    lda wall_2_info+1
    sta WALL_INFO_START_Y, y
    lda wall_2_info+2
    sta WALL_INFO_END_X, y
    lda wall_2_info+3
    sta WALL_INFO_END_Y, y
    lda wall_2_info+4
    sta WALL_INFO_FACING_DIR, y
    
    rts

setup_player:

    ; TODO: this is now hardcoded, but this should to taken from a map

    ; x-position of the player (8.8 bits)
    lda #0
    sta PLAYER_POS_X 
    lda #1
;    lda #2
    sta PLAYER_POS_X+1
    
    ; y-position of the player (8.8 bits)
    lda #0
    sta PLAYER_POS_Y
    lda #1
    sta PLAYER_POS_Y+1
    
    ; looking direction of the player (0-1823)
    lda #152              ; 30 degrees from facing straight north
; FIXME
;    lda #228
;    lda #<(1824-228)
    sta PLAYER_LOOKING_DIR
    lda #0
;    lda #>(1824-228)
    sta PLAYER_LOOKING_DIR+1
    
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
    
    jsr draw_wall
    
    inc CURRENT_WALL_INDEX
    lda CURRENT_WALL_INDEX
; FIXME: now limited to 1 wall
    cmp #2
;    cmp #3
    bne draw_next_wall
    
    rts
    

    
draw_wall:
    
    ; Steps:
    
    ; Given a wall, we determine whether its to the north, east, west or south of the player (so horizontal/vertical and on which side). 
    ; After that we can determine the length of normal line from the wall (x or y coord) to the player
    
    ; Given the direction the player is facing we can also determine what would be the screen start ray index (left most angle in the viewing area of the player, relative to the normal line)
    ; If we know what parts of the screen columns/rays have been drawn already, we can now cut-off left and right parts of the wall.
    
    ; SCREEN_START_RAY = (PLAYER_LOOKING_DIR - 30 degrees) - (WALL_FACING_DIR-2) * 90 degrees
    ; SCREEN_START_RAY = (PLAYER_LOOKING_DIR - 152) - (WALL_FACING_DIR-2) * 456
    
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
    
wall_facing_north:
    sec
    lda PLAYER_POS_Y
    sbc #0                      ; Walls are always on .0
    sta NORMAL_DISTANCE_TO_WALL
    lda PLAYER_POS_Y+1
    sbc WALL_START_Y
    sta NORMAL_DISTANCE_TO_WALL+1
    jmp calculated_normal_distance_to_wall
    

; #############################################################################################################
; #                                                                                                           #
; #                                            WALL FACING WEST                                               #
; #                                                                                                           #
; #############################################################################################################

wall_facing_west:

    sec
    lda PLAYER_LOOKING_DIR
    sbc #<(152+456*1)
    sta SCREEN_START_RAY
    lda PLAYER_LOOKING_DIR+1
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
    sbc PLAYER_POS_X
    sta NORMAL_DISTANCE_TO_WALL
    sta DELTA_X
    lda WALL_START_X            ; it doesnt matter if we use WALL_START_X or WALL_END_X here
    sbc PLAYER_POS_X+1
    sta NORMAL_DISTANCE_TO_WALL+1
    sta DELTA_X+1
    
    ; Determine the distance in the y-direction (delta Y) for the START of the wall
    sec
    lda #0                      ; Walls always start on .0
    sbc PLAYER_POS_Y
    sta DELTA_Y
    lda WALL_START_Y
    sbc PLAYER_POS_Y+1
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

    ; negating DELTA_Y
    sec
    lda #0
    sbc DELTA_Y
    sta DELTA_Y
    lda #0
    sbc DELTA_Y+1
    sta DELTA_Y+1
    
    bra wall_facing_west_calc_angle_for_start_of_wall
    
wall_facing_west_starting_north:
    
    ; We need to correct the angle +3 quadrants to be normalized
    lda #3
    sta QUADRANT_CORRECTION
    
    ; By default we do not need to flip the tan() result in this quadrant
    lda #0
    sta FLIP_TAN_ANGLE
    
    bra wall_facing_west_calc_angle_for_start_of_wall
    
wall_facing_west_calc_angle_for_start_of_wall:
    jsr calc_angle_for_point
    
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
    sbc PLAYER_POS_Y
    sta DELTA_Y
    lda WALL_END_Y
    sbc PLAYER_POS_Y+1
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
    
    ; bra wall_facing_west_calc_angle_for_end_of_wall
    
wall_facing_west_calc_angle_for_end_of_wall:
    jsr calc_angle_for_point
    
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
    lda PLAYER_LOOKING_DIR
    sbc #<(152+456*0)
    sta SCREEN_START_RAY
    lda PLAYER_LOOKING_DIR+1
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
    sbc PLAYER_POS_Y
    sta NORMAL_DISTANCE_TO_WALL
    sta DELTA_Y
    lda WALL_START_Y            ; it doesnt matter if we use WALL_START_Y or WALL_END_Y here
    sbc PLAYER_POS_Y+1
    sta NORMAL_DISTANCE_TO_WALL+1
    sta DELTA_Y+1
    
    ; Determine the distance in the x-direction (delta X) for the START of the wall
    sec
    lda #0                      ; Walls always start on .0
    sbc PLAYER_POS_X
    sta DELTA_X
    lda WALL_START_X
    sbc PLAYER_POS_X+1
    sta DELTA_X+1
    
    ; Check if DELTA_X is negative: if so, this means it starts to the west of the player, if not, it starts to the east
    bpl wall_facing_south_starting_east
    
wall_facing_south_starting_west:

    ; We need to correct the angle +3 quadrants to be normalized
    lda #3
    sta QUADRANT_CORRECTION
    
    ; By default we need to flip the tan() result in this quadrant
    lda #1
    sta FLIP_TAN_ANGLE

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
    
    bra wall_facing_south_calc_angle_for_start_of_wall
    
wall_facing_south_calc_angle_for_start_of_wall:
    jsr calc_angle_for_point
    
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
    sbc PLAYER_POS_X
    sta DELTA_X
    lda WALL_END_X
    sbc PLAYER_POS_X+1
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
    
    ; bra wall_facing_south_calc_angle_for_end_of_wall
    
wall_facing_south_calc_angle_for_end_of_wall:
    jsr calc_angle_for_point
    
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
    lda PLAYER_LOOKING_DIR
    sbc #<(152+456*3)
    sta SCREEN_START_RAY
    lda PLAYER_LOOKING_DIR+1
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
    lda PLAYER_POS_X
    sbc #0                      ; Walls are always on .0
    sta NORMAL_DISTANCE_TO_WALL
    sta DELTA_X
    lda PLAYER_POS_X+1
    sbc WALL_START_X            ; it doesnt matter if we use WALL_START_X or WALL_END_X here
    sta NORMAL_DISTANCE_TO_WALL+1
    sta DELTA_X+1
    
    ; Determine the distance in the y-direction (delta Y) for the START of the wall
    sec
    lda #0                      ; Walls always start on .0
    sbc PLAYER_POS_Y
    sta DELTA_Y
    lda WALL_START_Y
    sbc PLAYER_POS_Y+1
    sta DELTA_Y+1
    
    ; Check if DELTA_Y is negative: if so, this means it starts to the south of the player, if not, it starts to the north
    bpl wall_facing_east_starting_north
    
wall_facing_east_starting_south:

    ; We need to correct the angle +2 quadrants to be normalized
    lda #3
    sta QUADRANT_CORRECTION
    
    ; By default we dont need to flip the tan() result in this quadrant
    lda #0
    sta FLIP_TAN_ANGLE

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
    
    bra wall_facing_east_calc_angle_for_start_of_wall
    
wall_facing_east_calc_angle_for_start_of_wall:
    jsr calc_angle_for_point
    
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
    sbc PLAYER_POS_Y
    sta DELTA_Y
    lda WALL_END_Y
    sbc PLAYER_POS_Y+1
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
    
    ; bra wall_facing_east_calc_angle_for_end_of_wall
    
wall_facing_east_calc_angle_for_end_of_wall:
    jsr calc_angle_for_point
    
    lda RAY_INDEX
    sta TO_RAY_INDEX
    lda RAY_INDEX+1
    sta TO_RAY_INDEX+1
    
    jmp calculated_normal_distance_to_wall


    
calculated_normal_distance_to_wall:

;    stp
;    lda SCREEN_START_RAY
;    lda SCREEN_START_RAY+1
;    lda FROM_RAY_INDEX
;    lda FROM_RAY_INDEX+1
;    lda TO_RAY_INDEX
;    lda TO_RAY_INDEX+1


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
    
; FIXME: HACK!!
    cmp #5
    bcc from_ray_is_not_left_of_screen   
;    bpl from_ray_is_not_left_of_screen
    
from_ray_is_left_of_screen:
    ; Cut off left part of wall to the beginning of the screen
    
    lda SCREEN_START_RAY
    sta FROM_RAY_INDEX
    lda SCREEN_START_RAY+1
    sta FROM_RAY_INDEX+1
    
    ; FIXME: only do this IF the wall is not COMPLETELY left of the screen!
    
from_ray_is_not_left_of_screen:


    ; Check if end of wall is between the left and right of the screen
    ; To do this, we first need to know the ray number on the screen (TO_RAY_INDEX - SCREEN_START_RAY)
    sec
    lda TO_RAY_INDEX
    sbc SCREEN_START_RAY
    sta TESTING_RAY_INDEX
    lda TO_RAY_INDEX+1
    sbc SCREEN_START_RAY+1
    sta TESTING_RAY_INDEX+1
    
    ; Check if to ray > 60 degrees
    cmp #>(304)
    bcc to_ray_is_not_right_of_screen
    lda TESTING_RAY_INDEX
    cmp #<(304)
    bcc to_ray_is_not_right_of_screen
    
    ; Set to-ray to screen start ray + 60 degrees (right column of the screen)
    clc
    lda SCREEN_START_RAY
    adc #<(304)
    sta TO_RAY_INDEX
    lda SCREEN_START_RAY+1
    adc #>(304)
    sta TO_RAY_INDEX+1
    
    ; FIXME: only do this IF the wall is not COMPLETELY right of the screen!
    
to_ray_is_not_right_of_screen:
    
    
    
    ; If we have done that, we can now determine the distance from the player-plane and the left and right parts of the wall-part:
    ;   normal_distance_to_point = delta_x * cos(player_angle) + delta_y * sin(player_angle)
    ; Given these two distances, we can also determine the left and right wall heights.
    
; FIXME!
    lda CURRENT_WALL_INDEX
    cmp #1
    beq HACK_wall_height_wall_1
    cmp #2
    beq HACK_wall_height_wall_2
    
HACK_wall_height_wall_0:
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
    
    jsr draw_wall_part
    
    rts


; FIXME: get rid of this if the above is dynamic
    .if 0
    
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


; FIXME: get rid of this if the above is dynamic
    .endif


HACK_wall_height_wall_1:    


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

    jsr draw_wall_part

    rts


HACK_wall_height_wall_2:    


    lda #200
    sta FROM_WALL_HEIGHT
    lda #0
    sta FROM_WALL_HEIGHT+1

    ; FIXME: this value (180) is GUESSED!
    lda #128-45 ; (45 pixels drop at 45 degrees drop when 30 degrees normal angle)
    sta TO_WALL_HEIGHT
    lda #0
    sta TO_WALL_HEIGHT+1

    lda #0
    sta WALL_HEIGHT_INCREASES

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
    
    ; We take the fraction-part, since that is the input/index of the invtangens table
    ldy DIVIDEND
    
    bra do_tan_lookup
    
dx_equal_to_dy:

    ; Since x and y are the same, we are at 45 degrees (228)
    lda #228
    sta RAY_INDEX
    lda #0              ; The angle from invtangens is always < 256 (so the high byte is 0)
    sta RAY_INDEX+1
    
    ; No need to look this up in the invtangens table
    
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
    
    ; We take the fraction-part, since that is the input/index of the invtangens table
    ldy DIVIDEND
    
do_tan_lookup:
    
    lda invtangens, y
    
    sta RAY_INDEX
    lda #0              ; The angle from invtangens is always < 256 (so the high byte is 0)
    sta RAY_INDEX+1
    
    ; We check if the invtangens result should be flipped
    
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

    ; We assume here the (flipped) result of invtangens is in a
    
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
    
    ; SPEED: use a FAST mutlipler and 'cache' the NORMAL_DISTANCE_TO_WALL! ( https://codebase64.org/doku.php?id=base:seriously_fast_multiplication )
    ;        note that this needs to run in RAM in order for the 'cache' to work.

    ; We do a * NORMAL_DISTANCE_TO_WALL, then a divide by 4 (256 positions in a cell, so to go to 64 we need to divide by 4). 
    sta MULTIPLICAND
    stz MULTIPLICAND+1   ; FIXME: we should get the TANGENS_HIGH instead!!
    
    ; SPEED: copying this 16-bit value is slow
    lda NORMAL_DISTANCE_TO_WALL
    sta MULTIPLIER
    lda NORMAL_DISTANCE_TO_WALL+1
    sta MULTIPLIER+1

    jsr multply_16bits
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
    ; SPEED: use a FAST mutlipler and 'cache' the NORMAL_DISTANCE_TO_WALL! ( https://codebase64.org/doku.php?id=base:seriously_fast_multiplication )
    ;        note that this needs to run in RAM in order for the 'cache' to work.

    ; We do a * NORMAL_DISTANCE_TO_WALL, then a divide by 4 (256 positions in a cell, so to go to 64 we need to divide by 4). 
    sta MULTIPLICAND
    stz MULTIPLICAND+1   ; FIXME: we should get the TANGENS_HIGH instead!!
    
    ; SPEED: copying this 16-bit value is slow
    lda NORMAL_DISTANCE_TO_WALL
    sta MULTIPLIER
    lda NORMAL_DISTANCE_TO_WALL+1
    sta MULTIPLIER+1

    jsr multply_16bits
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
