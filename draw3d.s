
BACKGROUND_COLOR_3D_VIEW = $02
CEILING_COLOR            = $03
FLOOR_COLOR              = $04

copy_texture_to_vram:

    ; We copy 4kb to (high) vram
    
    ; TODO: this assumes ADDRSEL is 0!
    
    lda #%00010001           ; Setting bit 16 of vram address to the highest bit (=1), setting auto-increment value to 1
    sta VERA_ADDR_BANK
    lda VRAM_ADDRESS+1
    sta VERA_ADDR_HIGH
    lda VRAM_ADDRESS
    sta VERA_ADDR_LOW
    
    ldx #0
next_block_to_copy_to_vram:
    ldy #0
next_byte_to_copy_to_vram:
    lda (LOAD_ADDRESS), y
    sta VERA_DATA0
    iny
    bne next_byte_to_copy_to_vram
    
    inc LOAD_ADDRESS+1
    inx
    cpx #16              ; 16 * 256 = 4096 bytes
    bne next_block_to_copy_to_vram
   
    rts

    
; FIXME: this is just a placeholder for now, we are drawing a texture 128 pixels high
draw_3d_view_fast:

    ; Left part of the screen (256-8 = 248 columns)

;    ldy #BACKGROUND_COLOR_3D_VIEW
    
    ldx #8
    
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
    ; FIXME: we should not use only ONE texture!
    lda #>TEXTURE_DATA
    sta VERA_ADDR_HIGH
    txa
    lsr
    and #$3F                ; we effectively do a 'mod 64'
    sta VERA_ADDR_LOW       ; We use x mod 64 as the texture-column number, so we set it as as the start byte of a column
    
    jsr draw_152_column_fast
    
    inx
    bne draw_next_column_left
    
    ; Right part of the screen (56 columns)

    ldx #0

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
    ; FIXME: we should not use only ONE texture!
    lda #>TEXTURE_DATA
    sta VERA_ADDR_HIGH
    txa
    lsr
    and #$3F                ; we effectively do a 'mod 64'
    sta VERA_ADDR_LOW       ; We use x mod 64 as the texture-column number, so we set it as as the start byte of a column
    
    jsr draw_152_column_fast
    
    inx
    cpx #56
    bne draw_next_column_right
    
    ; We set back to ADDRSEL=0
    lda #%00000000           ; DCSEL=0, ADDRSEL=0
    sta VERA_CTRL
    
    rts



clear_3d_view_fast:

    ; Left part of the screen (256-8 = 248 columns)

    ldy #BACKGROUND_COLOR_3D_VIEW
    
    ldx #8
    
clear_next_column_left:
    lda #%11100000           ; Setting bit 16 of vram address to the highest bit (=0), setting auto-increment value to 320 bytes (=14=%1110)
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
    lda #%11100000           ; Setting bit 16 of vram address to the highest bit (=0), setting auto-increment value to 320 bytes (=14=%1110)
    sta VERA_ADDR_BANK
    lda #$06                ; The right side part of the screen has a start byte starting at address 256 and up
    sta VERA_ADDR_HIGH
    stx VERA_ADDR_LOW       ; We use x as the column number, so we set it as as the start byte of a column
    
    jsr clear_152_column_fast
    
    inx
    cpx #56
    bne clear_next_column_right
    
    rts

; FIXME: generate this code on startup!    
; NOTE: this example will draw a texture-column at a height of 128 pixels (so twice the size of the texture)
draw_152_column_fast:
    ; 0-11
    ldy #CEILING_COLOR
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
    
    ; 12-15
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    
    ; 16-31
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0

    ; 32-47
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0

    ; 48-63
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0

    ; 64-79
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0

    ; 80-95
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0

    ; 96-111
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0

    ; 112-127
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0

    ; 128-139
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    ldy VERA_DATA1
    sty VERA_DATA0
    sty VERA_DATA0
    
    ; 140-151
    ldy #FLOOR_COLOR
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
    
    rts
    
; FIXME: generate this code on startup!    
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