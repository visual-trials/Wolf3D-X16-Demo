

    ; FIXME: <BUG> when the door is opening, there is a line visible on the left side. This is NOT correct!
    
    
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

    lda #0
    sta CURRENT_WALL_NR

draw_next_wall:
    ldx CURRENT_WALL_NR
    lda ORDERED_WALL_INDEXES, x
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
    
