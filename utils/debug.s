

DEBUG_INDENT = 15
DEBUG_TOP_MARGIN = 2

debug_player_message:
    .asciiz "   == Player =="
debug_wall_message:
    .asciiz "    == Wall =="
debug_wall_part_message:
    .asciiz "  == Wall part =="
debug_viewpoint_message:
    .asciiz "Viewpoint: "
debug_looking_dir_angle_message:
    .asciiz "Looking dir: "
debug_wall_index_message: 
    .asciiz "Wall index:  "
debug_wall_start_message: 
    .asciiz "Wall start:  "
debug_wall_end_message: 
    .asciiz "Wall end:    "
debug_screen_start_angle_message:
    .asciiz "Screen start angle: "
debug_normal_distance_message:
    .asciiz "Normal distance: "
debug_from_delta_x_message:
    .asciiz "From delta x: "
debug_from_delta_y_message:    
    .asciiz "From delta y: "
debug_to_delta_x_message:
    .asciiz "To delta x: "
debug_to_delta_y_message:    
    .asciiz "To delta y: "
debug_from_angle_message:
    .asciiz "From angle: "
debug_to_angle_message:
    .asciiz "To angle: "
debug_from_screen_angle_message:
    .asciiz "From screen angle: "
debug_to_screen_angle_message:
    .asciiz "To screen angle: "
debug_from_distance_message:
    .asciiz "From distance: "
debug_to_distance_message:
    .asciiz "To distance: "
debug_from_half_height_message:
    .asciiz "From half height: "
debug_to_half_height_message:
    .asciiz "To half height: "


clear_and_setup_debug_screen:

    lda #COLOR_NORMAL
    sta TEXT_COLOR
    
    lda #DEBUG_TOP_MARGIN
    sta CURSOR_Y
    
    jsr clear_tilemap_screen

    rts

debug_print_player_info_on_screen:

    ; ======== Player/viewpoint info ========
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_player_message
    sta TEXT_TO_PRINT
    lda #>debug_player_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    inc CURSOR_Y
    
    ; ---- Viewpoint ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_viewpoint_message
    sta TEXT_TO_PRINT
    lda #>debug_viewpoint_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    lda VIEWPOINT_X
    sta WORD_TO_PRINT
    lda VIEWPOINT_X+1
    sta WORD_TO_PRINT+1
    
    jsr print_fixed_point_word_as_decimal_fraction

    lda #':'
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    inc CURSOR_X
    
    lda VIEWPOINT_Y
    sta WORD_TO_PRINT
    lda VIEWPOINT_Y+1
    sta WORD_TO_PRINT+1
    
    jsr print_fixed_point_word_as_decimal_fraction
    
    inc CURSOR_Y
    
    ; ---- Looking dir angle ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_looking_dir_angle_message
    sta TEXT_TO_PRINT
    lda #>debug_looking_dir_angle_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero

    lda LOOKING_DIR_ANGLE
    sta WORD_TO_PRINT
    lda LOOKING_DIR_ANGLE+1
    sta WORD_TO_PRINT+1
    
    jsr print_word_as_decimal
    
    inc CURSOR_Y
    inc CURSOR_Y
    
    rts
    
debug_print_wall_info_on_screen:
    
    ; ======== Wall info ========
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_wall_message
    sta TEXT_TO_PRINT
    lda #>debug_wall_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    inc CURSOR_Y
    
    ; ---- Wall index ----
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_wall_index_message
    sta TEXT_TO_PRINT
    lda #>debug_wall_index_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    ldx CURRENT_WALL_NR
    lda ORDERED_WALL_INDEXES, x
    sta BYTE_TO_PRINT

    jsr print_byte_as_decimal
    
    inc CURSOR_Y
    
    ; ---- Wall start ----

    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_wall_start_message
    sta TEXT_TO_PRINT
    lda #>debug_wall_start_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    lda WALL_START_X
    sta BYTE_TO_PRINT
    
    jsr print_byte_as_decimal
    
    lda #':'
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    inc CURSOR_X
    
    lda WALL_START_Y
    sta BYTE_TO_PRINT
    
    jsr print_byte_as_decimal
    
    inc CURSOR_Y
    
    ; ---- Wall end ----

    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_wall_end_message
    sta TEXT_TO_PRINT
    lda #>debug_wall_end_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    lda WALL_END_X
    sta BYTE_TO_PRINT
    
    jsr print_byte_as_decimal
    
    lda #':'
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    inc CURSOR_X
    
    lda WALL_END_Y
    sta BYTE_TO_PRINT
    
    jsr print_byte_as_decimal
    
    inc CURSOR_Y
    
    ; ---- Screen start angle ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_screen_start_angle_message
    sta TEXT_TO_PRINT
    lda #>debug_screen_start_angle_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero

    lda SCREEN_START_ANGLE
    sta WORD_TO_PRINT
    lda SCREEN_START_ANGLE+1
    sta WORD_TO_PRINT+1
    
    jsr print_word_as_decimal
    
    inc CURSOR_Y
    
    ; ---- Screen normal distance ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_normal_distance_message
    sta TEXT_TO_PRINT
    lda #>debug_normal_distance_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    lda NORMAL_DISTANCE_TO_WALL
    sta WORD_TO_PRINT
    lda NORMAL_DISTANCE_TO_WALL+1
    sta WORD_TO_PRINT+1
    
    jsr print_fixed_point_word_as_decimal_fraction
    
    inc CURSOR_Y
    
    ; ---- From delta X ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_from_delta_x_message
    sta TEXT_TO_PRINT
    lda #>debug_from_delta_x_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    lda FROM_DELTA_X
    sta WORD_TO_PRINT
    lda FROM_DELTA_X+1
    sta WORD_TO_PRINT+1
    
    jsr print_fixed_point_word_as_decimal_fraction
    
    inc CURSOR_Y
    
    ; ---- From delta Y ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_from_delta_y_message
    sta TEXT_TO_PRINT
    lda #>debug_from_delta_y_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    lda FROM_DELTA_Y
    sta WORD_TO_PRINT
    lda FROM_DELTA_Y+1
    sta WORD_TO_PRINT+1
    
    jsr print_fixed_point_word_as_decimal_fraction
    
    inc CURSOR_Y
    
    ; ---- To delta X ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_to_delta_x_message
    sta TEXT_TO_PRINT
    lda #>debug_to_delta_x_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    lda TO_DELTA_X
    sta WORD_TO_PRINT
    lda TO_DELTA_X+1
    sta WORD_TO_PRINT+1
    
    jsr print_fixed_point_word_as_decimal_fraction
    
    inc CURSOR_Y
    
    ; ---- To delta Y ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_to_delta_y_message
    sta TEXT_TO_PRINT
    lda #>debug_to_delta_y_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    lda TO_DELTA_Y
    sta WORD_TO_PRINT
    lda TO_DELTA_Y+1
    sta WORD_TO_PRINT+1
    
    jsr print_fixed_point_word_as_decimal_fraction
    
    inc CURSOR_Y
    
    ; ---- From screen angle ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_from_screen_angle_message
    sta TEXT_TO_PRINT
    lda #>debug_from_screen_angle_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero

    lda FROM_SCREEN_ANGLE
    sta WORD_TO_PRINT
    lda FROM_SCREEN_ANGLE+1
    sta WORD_TO_PRINT+1
    
    jsr print_word_as_decimal
    
    inc CURSOR_Y
    
    ; ---- To screen angle ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_to_screen_angle_message
    sta TEXT_TO_PRINT
    lda #>debug_to_screen_angle_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero

    lda TO_SCREEN_ANGLE
    sta WORD_TO_PRINT
    lda TO_SCREEN_ANGLE+1
    sta WORD_TO_PRINT+1
    
    jsr print_word_as_decimal
    
    inc CURSOR_Y
    inc CURSOR_Y
    
    ; FIXME: do we also want to print the from/to angle for the *wall* (not just the wall part)?
    
    rts
    
    
debug_print_wall_part_info_on_screen:

    ; ======== Wall part info ========

    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_wall_part_message
    sta TEXT_TO_PRINT
    lda #>debug_wall_part_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    inc CURSOR_Y
    
    ; ---- From angle ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_from_angle_message
    sta TEXT_TO_PRINT
    lda #>debug_from_angle_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero

    lda FROM_ANGLE
    sta WORD_TO_PRINT
    lda FROM_ANGLE+1
    sta WORD_TO_PRINT+1
    
    jsr print_word_as_decimal
    
    inc CURSOR_Y
    
    ; ---- To angle ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_to_angle_message
    sta TEXT_TO_PRINT
    lda #>debug_to_angle_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero

    lda TO_ANGLE
    sta WORD_TO_PRINT
    lda TO_ANGLE+1
    sta WORD_TO_PRINT+1
    
    jsr print_word_as_decimal
    
    inc CURSOR_Y
    
    ; ---- From screen angle ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_from_screen_angle_message
    sta TEXT_TO_PRINT
    lda #>debug_from_screen_angle_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero

    lda FROM_SCREEN_ANGLE_PART
    sta WORD_TO_PRINT
    lda FROM_SCREEN_ANGLE_PART+1
    sta WORD_TO_PRINT+1
    
    jsr print_word_as_decimal
    
    inc CURSOR_Y
    
    ; ---- To screen angle ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_to_screen_angle_message
    sta TEXT_TO_PRINT
    lda #>debug_to_screen_angle_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero

    lda TO_SCREEN_ANGLE_PART
    sta WORD_TO_PRINT
    lda TO_SCREEN_ANGLE_PART+1
    sta WORD_TO_PRINT+1
    
    jsr print_word_as_decimal
    
    inc CURSOR_Y
    
    ; ---- From distance ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_from_distance_message
    sta TEXT_TO_PRINT
    lda #>debug_from_distance_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    lda FROM_DISTANCE
    sta WORD_TO_PRINT
    lda FROM_DISTANCE+1
    sta WORD_TO_PRINT+1
    
    jsr print_fixed_point_word_as_decimal_fraction
    
    inc CURSOR_Y
    
    ; ---- To distance ----
    
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_to_distance_message
    sta TEXT_TO_PRINT
    lda #>debug_to_distance_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    lda TO_DISTANCE
    sta WORD_TO_PRINT
    lda TO_DISTANCE+1
    sta WORD_TO_PRINT+1
    
    jsr print_fixed_point_word_as_decimal_fraction
    
    inc CURSOR_Y
    
    ; ---- From half height ----

    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_from_half_height_message
    sta TEXT_TO_PRINT
    lda #>debug_from_half_height_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    lda FROM_HALF_WALL_HEIGHT
    sta BYTE_TO_PRINT
    
    jsr print_byte_as_decimal
    
    inc CURSOR_Y
    
    ; ---- To half height ----

    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_to_half_height_message
    sta TEXT_TO_PRINT
    lda #>debug_to_half_height_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    lda TO_HALF_WALL_HEIGHT
    sta BYTE_TO_PRINT
    
    jsr print_byte_as_decimal
    
    inc CURSOR_Y
    
    
    rts