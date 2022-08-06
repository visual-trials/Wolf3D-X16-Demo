
BACKGROUND_COLOR_3D_VIEW = $01

clear_3d_view_fast:

    ; Left part of the screen (256-8 = 248 columns)

    ldy #BACKGROUND_COLOR_3D_VIEW
    
    ldx #8
    
clear_next_column_left:
    lda #%11100000           ; Setting bit 16 of vram address to the highest bit (=0), setting auto-increment value to 320px (=14=%1110)
    sta VERA_ADDR_BANK
    lda #$05                ; 5 * 256 = 1280 = 4 * 320 (3d view starts at 4 pixels from the top)
    sta VERA_ADDR_HIGH
    stx VERA_ADDR_LOW       ; We use x as the column number, so we set it as as the start byte of a column
    
    jsr clear_152_column_fast
    
    inx
    bne clear_next_column_left
    
    ; Right part of the screen (56 columns)

    ldx #0

clear_next_column_right:
    lda #%11100000           ; Setting bit 16 of vram address to the highest bit (=0), setting auto-increment value to 320px (=14=%1110)
    sta VERA_ADDR_BANK
    lda #$06                ; The right side part of the screen has a start byte starting at address 256 and up
    sta VERA_ADDR_HIGH
    stx VERA_ADDR_LOW       ; We use x as the column number, so we set it as as the start byte of a column
    
    jsr clear_152_column_fast
    
    inx
    cpx #56
    bne clear_next_column_right
    
    rts
    
clear_152_column_fast:
    ; 0-15
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    
    ; 16-31
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0

    ; 32-47
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0

    ; 48-63
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0

    ; 64-79
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0

    ; 80-95
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0

    ; 96-111
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0

    ; 112-127
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0

    ; 128-143
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0

    ; 144-151
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    sty VERA_DATA0
    
    rts