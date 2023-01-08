
update_viewpoint:

    ; FIXME: <BUG> when the door is opening, there is a line visible on the left side. This is NOT correct!
    
    ; FIXME: We should add PLAYER_POS_X/Y and calcluate VIEWPOINT_X/Y from the player position and the LOOKING_DIR_ANGLE (every frame)
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
    
    ; NOTE: I am (ab)using ANGLE_INDEX here for temporary storage of the normalized LOOKING_DIR_ANGLE
    
    lda LOOKING_DIR_ANGLE+1
    cmp #>(456*1)
    bcc looking_dir_in_q0
    bne looking_dir_in_not_in_q0
    lda LOOKING_DIR_ANGLE
    cmp #<(456*1)
    bcc looking_dir_in_q0
    
looking_dir_in_not_in_q0:
    lda LOOKING_DIR_ANGLE+1
    cmp #>(456*2)
    bcc looking_dir_in_q1
    bne looking_dir_in_not_in_q1
    lda LOOKING_DIR_ANGLE
    cmp #<(456*2)
    bcc looking_dir_in_q1
    
looking_dir_in_not_in_q1:
    lda LOOKING_DIR_ANGLE+1
    cmp #>(456*3)
    bcc looking_dir_in_q2
    bne looking_dir_in_q3
    lda LOOKING_DIR_ANGLE
    cmp #<(456*3)
    bcc looking_dir_in_q2
    
looking_dir_in_q3:
    ; FIXME, CHECK: we do -1 here, is this indeed the correct way?
    ; Normalize angle (360-1 degrees - q3angle = q0angle)
    sec
    lda #<(456*4-1)
    sbc LOOKING_DIR_ANGLE
    sta ANGLE_INDEX
    lda #>(456*4-1)
    sbc LOOKING_DIR_ANGLE+1
    sta ANGLE_INDEX+1

    ; Mark as q3
    lda #%00000010
    sta LOOKING_DIR_QUANDRANT
    
    bra looking_dir_info_updated
    
looking_dir_in_q2:
    ; Normalize angle (q2angle - 180 degrees = q0angle)
    sec
    lda LOOKING_DIR_ANGLE
    sbc #<(456*2)
    sta ANGLE_INDEX
    lda LOOKING_DIR_ANGLE+1
    sbc #>(456*2)
    sta ANGLE_INDEX+1
    
    ; Mark as q2
    lda #%00000011
    sta LOOKING_DIR_QUANDRANT
    
    bra looking_dir_info_updated
    
looking_dir_in_q1:
    ; FIXME, CHECK: we do -1 here, is this indeed the correct way?
    ; Normalize angle (180-1 degrees - q1angle = q0angle)
    sec
    lda #<(456*2-1)
    sbc LOOKING_DIR_ANGLE
    sta ANGLE_INDEX
    lda #>(456*2-1)
    sbc LOOKING_DIR_ANGLE+1
    sta ANGLE_INDEX+1
    
    ; Mark as q1
    lda #%00000001
    sta LOOKING_DIR_QUANDRANT
    
    bra looking_dir_info_updated
    
looking_dir_in_q0:

    lda LOOKING_DIR_ANGLE
    sta ANGLE_INDEX
    lda LOOKING_DIR_ANGLE+1
    sta ANGLE_INDEX+1
    
    ; Mark as q0
    lda #%00000000
    sta LOOKING_DIR_QUANDRANT


looking_dir_info_updated:

    ; Sine for looking dir
    
    lda ANGLE_INDEX+1
    bne is_high_index_sine
is_low_index_sine:
    ldy ANGLE_INDEX
    lda SINE_LOW,y
    sta LOOKING_DIR_SINE
    lda SINE_HIGH,y
    sta LOOKING_DIR_SINE+1
    bra got_looking_dir_sine
is_high_index_sine:
    ldy ANGLE_INDEX
    lda SINE_LOW+256,y         ; When the angle index >= 256, we retrieve from 256 positions further
    sta LOOKING_DIR_SINE
    lda SINE_HIGH+256,y        ; When the angle index >= 256, we retrieve from 256 positions further
    sta LOOKING_DIR_SINE+1
got_looking_dir_sine:

    ; Since we know the LOOKING_DIR_SINE, we can prepare the multiplier that uses it
    jsr setup_multiply_with_looking_dir_sine_16bit
    
    ; Cosine for looking dir
    
    lda ANGLE_INDEX+1
    bne is_high_index_cosine
is_low_index_cosine:
    ldy ANGLE_INDEX
    lda COSINE_LOW,y
    sta LOOKING_DIR_COSINE
    lda COSINE_HIGH,y
    sta LOOKING_DIR_COSINE+1
    bra got_looking_dir_cosine
is_high_index_cosine:
    ldy ANGLE_INDEX
    lda COSINE_LOW+256,y         ; When the angle index >= 256, we retrieve from 256 positions further
    sta LOOKING_DIR_COSINE
    lda COSINE_HIGH+256,y        ; When the angle index >= 256, we retrieve from 256 positions further
    sta LOOKING_DIR_COSINE+1
got_looking_dir_cosine:

    ; Since we know the LOOKING_DIR_COSINE, we can prepare the multiplier that uses it
    jsr setup_multiply_with_looking_dir_cosine_16bit

    rts
    
    
    
draw_3d_view:

    ; TODO: get a set of ordered walls (near to far) from some kind of BSP tree...
        ; Also check if walls are facing the right way? Or is that a given at this point?

    jsr draw_walls
    
    ; TODO: draw more than just the walls...

    rts


draw_walls:

    ; FIXME: make this a prepare_for_wall_draw routines?

    ldy #0
    sty NR_OF_OCCLUDERS
    
    ; The initial occluder begins at 304 and ends at 0 (basicly evertything that is not on screen)
    lda #(<304)
    sta OCCLUDER_FROM_ANGLE_LOW, y
    lda #(>304)
    sta OCCLUDER_FROM_ANGLE_HIGH, y
    
    lda #0
    sta OCCLUDER_TO_ANGLE_LOW, y
    sta OCCLUDER_TO_ANGLE_HIGH, y
    ; Initially there is no other occluder, so the next one is itself (index = 0)
    sta OCCLUDER_NEXT, y
    
    ; We now have 1 occluder
    inc NR_OF_OCCLUDERS


    ; Iterating over a ordered list of all wall indexes

    lda ordered_list_of_wall_indexes   ; the first byte contains the number of ordered walls
    sta NR_OF_ORDERED_WALLS
    
    lda #0
    sta CURRENT_WALL_NR

draw_next_wall:
    ldx CURRENT_WALL_NR
    lda ordered_list_of_wall_indexes+1, x   ; +1 because the first byte contains the number of ordered walls
    tay
    
    ; FIXME: we should use 16 bits for WALL_START_X/Y and WALL_END_X/Y due to the fact that doors can be in the middle of a square! (determining the normal_distance/delta_x/y is quite inconvenient right now)
    
    lda WALL_INFO_START_X, y   ; x-coordinate of start of wall
    sta WALL_START_X
    
    lda WALL_INFO_START_Y, y   ; y-coordinate of start of wall
    sta WALL_START_Y
    
    lda WALL_INFO_END_X, y   ; x-coordinate of end of wall
    sta WALL_END_X
    
    lda WALL_INFO_END_Y, y   ; y-coordinate of end of wall
    sta WALL_END_Y
    
    lda WALL_INFO_FACING_DIR, y   ; facing direction of the wall: 0 = north, 1 = east, 2 = south, 3 = west  (bit 2 = 1 means this is a door)
    and #%00000100                ; checking for bit 2
    beq wall_is_not_a_door
    
    ; The wall is a door
    lda WALL_INFO_FACING_DIR, y
    and #%11111011                ; unsetting bit 2
    sta WALL_FACING_DIR
    
    ; FIXME: set DOOR_OPENED value properly!
    lda TMP_DOOR_OPENED_STATUS
    sta DOOR_OPENED
    lda TMP_DOOR_OPENED_STATUS+1
    sta DOOR_OPENED+1

    lda #128
    sta WALL_POSITION_IN_TILE
    bra wall_doorness_determined
    
wall_is_not_a_door:
    lda WALL_INFO_FACING_DIR, y
    sta WALL_FACING_DIR
    lda #0
    sta WALL_POSITION_IN_TILE
    
    ; FIXME: set DOOR_OPENED value properly!
    lda #0
    sta DOOR_OPENED
    lda #0               ; a normal wall is always 'fully closed'
    sta DOOR_OPENED+1
    
wall_doorness_determined:
    
    lda WALL_INFO_TEXTURE_LOW,y
    sta WALL_INFO_TEXTURE_INDEXES
    
    lda WALL_INFO_TEXTURE_HIGH,y
    sta WALL_INFO_TEXTURE_INDEXES+1
    
    jsr draw_wall
    
    .if DEBUG_WALL_INFO
    jsr clear_and_setup_debug_screen
    jsr debug_print_player_info_on_screen
    jsr debug_print_wall_info_on_screen
    jsr wait_until_spacebar_press
    .endif
    
; FIXME: the NR_OF_WALLS has to be dependend on the viewpoint! So as well as the ordered list of walls, we also need to 'reload' the nr of ordered walls!
    
    inc CURRENT_WALL_NR
    lda CURRENT_WALL_NR
    cmp NR_OF_ORDERED_WALLS
    bne draw_next_wall
    
    rts
    
