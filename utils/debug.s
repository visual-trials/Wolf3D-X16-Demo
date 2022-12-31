

DEBUG_INDENT = 20
DEBUG_TOP_MARGIN = 2

debug_wall_index_message: 
    .asciiz "Wall index: "
debug_wall_start_message: 
    .asciiz "Wall start: "
debug_wall_end_message: 
    .asciiz "Wall end:   "


debug_print_wall_info_on_screen:

    lda #COLOR_NORMAL
    sta TEXT_COLOR
    
    ; ---- Wall index ----
    lda #DEBUG_INDENT
    sta CURSOR_X
    lda #DEBUG_TOP_MARGIN+0
    sta CURSOR_Y
    
    lda #<debug_wall_index_message
    sta TEXT_TO_PRINT
    lda #>debug_wall_index_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    ldx CURRENT_WALL_NR
    lda ordered_list_of_wall_indexes, x
    sta BYTE_TO_PRINT

    jsr print_byte_as_decimal
    
    ; ---- Wall start ----

    lda #DEBUG_INDENT
    sta CURSOR_X
    lda #DEBUG_TOP_MARGIN+1
    sta CURSOR_Y
    
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
    
    ; ---- Wall end ----

    lda #DEBUG_INDENT
    sta CURSOR_X
    lda #DEBUG_TOP_MARGIN+2
    sta CURSOR_Y
    
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
    
    
    rts