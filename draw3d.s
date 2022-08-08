
BACKGROUND_COLOR_3D_VIEW = 2
CEILING_COLOR            = 19
FLOOR_COLOR              = 22

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
    clc
    adc #128                  ; FIXME: we now add 128 to the color value, since we have our custom palette there, but this only works if we have ONE texture!
    sta VERA_DATA0
    iny
    bne next_byte_to_copy_to_vram
    
    inc LOAD_ADDRESS+1
    inx
    cpx #16              ; 16 * 256 = 4096 bytes
    bne next_block_to_copy_to_vram
   
    rts

; FIXME: this only works for ONE texture palette!
copy_palette_to_vram:
    ldy #0

    ; TODO: this assumes ADDRSEL is 0!
    
    lda #%00010001           ; Setting bit 16 of vram address to the highest bit (=1), setting auto-increment value to 1
    sta VERA_ADDR_BANK
    lda #>(VERA_PALETTE+128*2)   ; FIXME: we now add 128 to the palette index, since we place our custom palette there, but this only works if we have ONE texture!
    sta VERA_ADDR_HIGH
    lda #<(VERA_PALETTE+128*2)   ; FIXME: we now add 128 to the palette index, since we place our custom palette there, but this only works if we have ONE texture!
    sta VERA_ADDR_LOW
    
next_palette_color_to_copy:

    lda (LOAD_ADDRESS), y     ; blue
    iny

    lsr
    lsr
    lsr
    lsr
    
    sta TMP1
    
    lda (LOAD_ADDRESS), y     ; green
    iny
    
    and #$F0
    ora TMP1

    sta VERA_DATA0

    lda (LOAD_ADDRESS), y     ; red
    iny

    lsr
    lsr
    lsr
    lsr
    
    sta VERA_DATA0

    cpy NR_OF_PALETTE_BYTES
    bne next_palette_color_to_copy

    rts

    
; FIXME: this is just a placeholder for now, we are drawing a texture 128 pixels high
draw_3d_view_fast:

    ; Left part of the screen (256-8 = 248 columns)

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

    ; FIXME: determine which code has to be called (switch to the correct ram bank)
;    jsr DRAW_COLUMN_CODE_128
    jsr DRAW_COLUMN_CODE
    
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
    
    ; FIXME: determine which code has to be called (switch to the correct ram bank)
;    jsr DRAW_COLUMN_CODE_128
    jsr DRAW_COLUMN_CODE
    
    inx
    cpx #56
    bne draw_next_column_right
    
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


generate_draw_column_code:
    
    ; Below assumes a "virtual screen" of 512 pixels high, with the actual screen starting at pixel 512/2 - 152/2 = 180 pixels from the top of the "virtual screen"
    
    ; We iterate through 512 possible wall heights
    
        ; We calcultate our texture_increment: 64 / wall_height (16 bits)
        ; We set our texture_cursor to 0 (16 bit)
        ; We set our previous_texture_cursor to 255 (as a marker to indicate we havent loaded from the texture at all)
    
        ; Lets say: wall_height = 128
        ; We determine your start position on the "virtual screen": virtual_screen_cursor = 512/2 - wall_height/2 = 192
        ; Since 192 > 180 the wall starts in the actual screen. 
        
            ; We need some ceiling pixels to move to that place first. So we iterate to add those.
            ; Set virtual_screen_cursor to the top of the actual screen (= 180)
            ; We also need to remember how many floor pixels need to be added later on.
        
        ; Lets say: wall_height = 152
        ; We determine your start position on the "virtual screen": virtual_screen_cursor = 512/2 - wall_height/2 = 180
        ; Since 180 == 180 the wall starts right at the top of the actual screen. No ceiling needed.
        
        ; Lets say: wall_height = 300
        ; We determine your start position on the "virtual screen": virtual_screen_cursor = 512/2 - wall_height/2 = 106
        ; Since 106 < 180 the wall starts above the actual screen. As long as that is the case we will not write pixels to the screen.
        
        
        ; We iterate our "virtual cursor" from virtual_start_position to 512-virtual_start_position:
        
            ; We determine our texture_cursor (only top 8 bits): has it changed? If so, we need to add a "lda VERA_DATA1" command. We update previous_texture_cursor in that case.
            
            ; If we are still outside the screen we dont write a pixel. Otherwise we add a "sta VERA_DATA0" command.
            
            ; We increment our texture_cursor with texture_increment (16 bits add)
            
            ; We increment our virtual_cursor with 1
            ; If we reach the end of the actual screen (> 332) or we reached the end of our texture, we stop
            
        ; We add floor pixels if needed.
        
        
    ; NOTE: it is probably a good idea to first iterate over the wall heights 0-255 and then over the wall heights 256-511. Since we can then use a byte for CURRENT_WALL_HEIGHT
    
    ; FIXME: we should iterate over all possible wall heights
;    lda #128
    lda #96
;    lda #64
    sta CURRENT_WALL_HEIGHT
    
    ; FIXME: actually do the divide: 64 / wall_height
;    lda #$80
    lda #170
;    lda #$0
    sta TEXTURE_INCREMENT
;    lda #0
    lda #0
;    lda #1
    sta TEXTURE_INCREMENT+1
    
    lda #0
    sta TEXTURE_CURSOR
    lda #0
    sta TEXTURE_CURSOR+1
    
    lda #255
    sta PREVIOUS_TEXTURE_CURSOR
    
generate_draw_code_for_next_wall_height:

    ; FIXME: there should be many variants of this code: one for each possible height of a column!

    lda #<DRAW_COLUMN_CODE
    sta CODE_ADDRESS
    lda #>DRAW_COLUMN_CODE
    sta CODE_ADDRESS+1
    
    ldy #0                 ; generated code byte counter
    
    ; We determine your start position on the "virtual screen": virtual_screen_cursor = 512/2 - wall_height/2
    
    ; TODO: if wall height is an odd number, should we put the extra pixel at the top or at the bottom?
    lda CURRENT_WALL_HEIGHT
    lsr                        ; wall_height/2
    sta TOP_HALF_WALL_HEIGHT
    bcc bottom_wall_height_is_determined ; if there is no carry, the wall height was an even number, so the bottom half is the same as the top
    inc                                  ; if there is a carry, the wall height was an add number, so add one to the bottom half
bottom_wall_height_is_determined:
    sta BOTTOM_HALF_WALL_HEIGHT

    lda #0                     ; 512/2 = 0
    sec
    sbc TOP_HALF_WALL_HEIGHT   ; 512/2 - top_half_wall_height
    
    sta VIRTUAL_SCREEN_CURSOR
    cmp #180
    bcc no_more_ceiling_needed  ; if VIRTUAL_SCREEN_CURSOR < 180, then we start outside the real screen (so no need to add ceiling pixels)
    beq no_more_ceiling_needed  ; if VIRTUAL_SCREEN_CURSOR = 180, then we start at the top of the real screen (so no need to add ceiling pixels)

    ; -- lda #CEILING_COLOR
    lda #$A9               ; lda #...
    jsr add_code_byte
    
    lda #CEILING_COLOR     ; #CEILING_COLOR
    jsr add_code_byte

    ; We need to know how many ceiling pixel we need to add
    lda VIRTUAL_SCREEN_CURSOR
    sec
    sbc #180
    tax
    
add_next_ceiling_code:

    ; -- sta VERA_DATA0 ($9F23)
    lda #$8D               ; sta ....
    jsr add_code_byte

    lda #$23               ; $23
    jsr add_code_byte
    
    lda #$9F               ; $9F
    jsr add_code_byte

    dex
    bne add_next_ceiling_code

no_more_ceiling_needed:

next_virtual_pixel_top:

    lda TEXTURE_CURSOR+1
    cmp PREVIOUS_TEXTURE_CURSOR
    beq correct_texture_pixel_loaded_top
    
    ; We need to add a load of the texture
    
    ; -- lda VERA_DATA1 ($9F24)
    lda #$AD               ; lda ....
    jsr add_code_byte
    
    lda #$24               ; VERA_DATA1
    jsr add_code_byte
    
    lda #$9F         
    jsr add_code_byte
    
    lda TEXTURE_CURSOR+1
    sta PREVIOUS_TEXTURE_CURSOR

correct_texture_pixel_loaded_top:

    lda VIRTUAL_SCREEN_CURSOR
    cmp #180
    bcc done_reading_and_writing_for_virtual_pixel_top  ; if VIRTUAL_SCREEN_CURSOR < 180, then we are (still) outside the real screen. We should not write to the screen (omit the "sta VERA_DATA0")
    
    ; -- sta VERA_DATA0 ($9F23)
    lda #$8D               ; sta ....
    jsr add_code_byte

    lda #$23               ; $23
    jsr add_code_byte
    
    lda #$9F               ; $9F
    jsr add_code_byte
    
done_reading_and_writing_for_virtual_pixel_top:

    ; Increment the texture cursor
    clc
	lda TEXTURE_CURSOR
	adc TEXTURE_INCREMENT
	sta TEXTURE_CURSOR
	lda TEXTURE_CURSOR+1
	adc TEXTURE_INCREMENT+1
	sta TEXTURE_CURSOR+1
    
    ; Increment the virtual cursor
    inc VIRTUAL_SCREEN_CURSOR
    
    lda VIRTUAL_SCREEN_CURSOR
    bne next_virtual_pixel_top       ; Repeat until we reach 256 for our virtual pixel.


    ; == Now we do the same for the BOTTOM part of the virtual screen ==

next_virtual_pixel_bottom:

    lda TEXTURE_CURSOR+1
    cmp PREVIOUS_TEXTURE_CURSOR
    beq correct_texture_pixel_loaded_bottom
    
    ; We need to add a load of the texture
    
    ; -- lda VERA_DATA1 ($9F24)
    lda #$AD               ; lda ....
    jsr add_code_byte
    
    lda #$24               ; VERA_DATA1
    jsr add_code_byte
    
    lda #$9F         
    jsr add_code_byte
    
    lda TEXTURE_CURSOR+1
    sta PREVIOUS_TEXTURE_CURSOR

correct_texture_pixel_loaded_bottom:

;    lda VIRTUAL_SCREEN_CURSOR
;    cmp #180
;    bcc done_reading_and_writing_for_virtual_pixel_bottom  ; if VIRTUAL_SCREEN_CURSOR < 180, then we are (still) outside the real screen. We should not write to the screen (omit the "sta VERA_DATA0")
    
    ; -- sta VERA_DATA0 ($9F23)
    lda #$8D               ; sta ....
    jsr add_code_byte

    lda #$23               ; $23
    jsr add_code_byte
    
    lda #$9F               ; $9F
    jsr add_code_byte
    
done_reading_and_writing_for_virtual_pixel_bottom:

    ; Increment the texture cursor
    clc
	lda TEXTURE_CURSOR
	adc TEXTURE_INCREMENT
	sta TEXTURE_CURSOR
	lda TEXTURE_CURSOR+1
	adc TEXTURE_INCREMENT+1
	sta TEXTURE_CURSOR+1
    
    ; Increment the virtual cursor
    
    inc VIRTUAL_SCREEN_CURSOR
    
    lda VIRTUAL_SCREEN_CURSOR
    cmp #(332-256)                      ; We reached the end of the real screen, so we are done
    beq done_drawing_bottom
    cmp BOTTOM_HALF_WALL_HEIGHT         ; We reached the end of our wall height, so we should fill the remaining part with floor pixels
    beq fill_bottom_with_floor_pixels
    
    bra next_virtual_pixel_bottom
    
fill_bottom_with_floor_pixels:
    
    ; -- lda #FLOOR_COLOR
    lda #$A9               ; lda #...
    jsr add_code_byte
    
    lda #FLOOR_COLOR       ; #FLOOR_COLOR
    jsr add_code_byte
    
add_next_floor_code:    
    
    ; -- sta VERA_DATA0 ($9F23)
    lda #$8D               ; sta ....
    jsr add_code_byte

    lda #$23               ; $23
    jsr add_code_byte
    
    lda #$9F               ; $9F
    jsr add_code_byte
    
    ; Increment the virtual cursor
    inc VIRTUAL_SCREEN_CURSOR

    lda VIRTUAL_SCREEN_CURSOR
    cmp #(332-256)                      ; We reached the end of the real screen, so we are done
    bne add_next_floor_code
    
done_drawing_bottom:
    
    
    ; -- rts --
    lda #$60
    jsr add_code_byte
    
    ; FIXME; enable iterating over wall heights
    ; lda CURRENT_WALL_HEIGHT
    ; bne generate_draw_code_for_next_wall_height
    
        
    rts
    
    
    
    
    
; FIXME: remove this!    
generate_draw_column_code_128:

    ; FIXME: there should be many variants of this code: one for each possible height of a column!

    lda #<DRAW_COLUMN_CODE_128
    sta CODE_ADDRESS
    lda #>DRAW_COLUMN_CODE_128
    sta CODE_ADDRESS+1
    
    ldy #0                 ; generated code byte counter
    
    
    ; -- lda #CEILING_COLOR
    lda #$A9               ; lda #...
    jsr add_code_byte
    
    lda #CEILING_COLOR     ; #CEILING_COLOR
    jsr add_code_byte

    ldx #0                 ; counts nr of ceiling instructions

next_ceiling_instruction_128:

    ; -- sta VERA_DATA0 ($9F23)
    lda #$8D               ; sta ....
    jsr add_code_byte

    lda #$23               ; $23
    jsr add_code_byte
    
    lda #$9F               ; $9F
    jsr add_code_byte
    
    inx
    cpx #12                ; 12 ceiling pixels written to VERA
    bne next_ceiling_instruction_128

    
    ldx #0                 ; counts nr of texture double-write instructions

next_instruction_set_128:

    ; -- lda VERA_DATA1 ($9F24)
    lda #$AD               ; lda ....
    jsr add_code_byte
    
    lda #$24               ; VERA_DATA1
    jsr add_code_byte
    
    lda #$9F         
    jsr add_code_byte
            
    ; -- sta VERA_DATA0 ($9F23)
    lda #$8D               ; sta ....
    jsr add_code_byte

    lda #$23               ; $23
    jsr add_code_byte
    
    lda #$9F               ; $9F
    jsr add_code_byte

    ; -- sta VERA_DATA0 ($9F23)
    lda #$8D               ; sta ....
    jsr add_code_byte

    lda #$23               ; $23
    jsr add_code_byte
    
    lda #$9F               ; $9F
    jsr add_code_byte
    
    inx
    cpx #64                ; 64 * 2 = 128 pixels written to VERA
    bne next_instruction_set_128
    
    
    ; -- lda #FLOOR_COLOR
    lda #$A9               ; lda #...
    jsr add_code_byte
    
    lda #FLOOR_COLOR       ; #FLOOR_COLOR
    jsr add_code_byte

    ldx #0                 ; counts nr of floor instructions

next_floor_instruction_128:

    ; -- sta VERA_DATA0 ($9F23)
    lda #$8D               ; sta ....
    jsr add_code_byte

    lda #$23               ; $23
    jsr add_code_byte
    
    lda #$9F               ; $9F
    jsr add_code_byte
    
    inx
    cpx #12                ; 12 floor pixels written to VERA
    bne next_floor_instruction_128

    ; -- rts --
    lda #$60
    jsr add_code_byte

    rts




generate_clear_column_code:

    lda #<CLEAR_COLUMN_CODE
    sta CODE_ADDRESS
    lda #>CLEAR_COLUMN_CODE
    sta CODE_ADDRESS+1
    
    ldy #0                 ; generated code byte counter
    
    ldx #0                 ; counts nr of clear instructions

next_clear_instruction:

    ; -- sta VERA_DATA0 ($9F23)
    lda #$8D               ; sta ....
    jsr add_code_byte

    lda #$23               ; $23
    jsr add_code_byte
    
    lda #$9F               ; $9F
    jsr add_code_byte
    
    inx
    cpx #152               ; 152 clear pixels written to VERA
    bne next_clear_instruction

    ; -- rts --
    lda #$60
    jsr add_code_byte

    rts

    
add_code_byte:
    sta (CODE_ADDRESS),y   ; store code byte at address (located at CODE_ADDRESS) + y
    iny                    ; increase y
    cpy #0                 ; if y == 0
    bne done_adding_code_byte
    inc CODE_ADDRESS+1     ; increment high-byte of CODE_ADDRESS
done_adding_code_byte:
    rts
