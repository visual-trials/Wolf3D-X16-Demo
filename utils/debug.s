

DEBUG_INDENT = 15
DEBUG_TOP_MARGIN = 2

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
debug_from_angle_message:
    .asciiz "From angle: "
debug_to_angle_message:
    .asciiz "To angle: "


debug_print_wall_info_on_screen:

; FIXME: we should propably clear the tilemap here


    lda #COLOR_NORMAL
    sta TEXT_COLOR
    
    lda #DEBUG_TOP_MARGIN
    sta CURSOR_Y
    
    ; FIXME: add player position!
    
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

    jsr setup_cursor
    
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
    
    ; ---- Wall index ----
    lda #DEBUG_INDENT
    sta CURSOR_X
    
    lda #<debug_wall_index_message
    sta TEXT_TO_PRINT
    lda #>debug_wall_index_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    ldx CURRENT_WALL_NR
    lda ordered_list_of_wall_indexes, x
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
    
    jsr setup_cursor
    
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
    
    jsr setup_cursor
    
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
    
    rts