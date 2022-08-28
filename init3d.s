; FIXME: use a different background color, or none!
BACKGROUND_COLOR_3D_VIEW = 2
CEILING_COLOR            = 19
FLOOR_COLOR              = 22

; FIXME: this assumes TEXTURE_DATA = $13000 which might change!
BS1 = $00+$30 ; blue stone 1
BS2 = $10+$30 ; blue stone 2
CLD = $20+$30 ; closed door

; FIXME: this is temporary data to get some wall information into the engine

; Starting room of Wolf3D (sort of)

;    3_
; 12_| |_45
;   |   |
;  0|   |6
;   |   |
;   |___|
;     7

wall_0_info:
    .byte 0, 0 ; start x, y
    .byte 0, 4 ; end x, y
    .byte 1    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    .byte BS1, BS2, BS1, BS1
    
wall_1_info:
    .byte 0, 4 ; start x, y
    .byte 1, 4 ; end x, y
    .byte 2    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    .byte BS1

wall_2_info:
    .byte 1, 4 ; start x, y
    .byte 1, 5 ; end x, y
    .byte 1    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    .byte BS1
    
wall_3_info:
    .byte 1, 5 ; start x, y
    .byte 2, 5 ; end x, y
    .byte 2    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    .byte CLD
    
wall_4_info:
    .byte 2, 5 ; start x, y
    .byte 2, 4 ; end x, y
    .byte 3    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    .byte BS1
    
wall_5_info:
    .byte 2, 4 ; start x, y
    .byte 3, 4 ; end x, y
    .byte 2    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    .byte BS1
    
wall_6_info:
    .byte 3, 4 ; start x, y
    .byte 3, 0 ; end x, y
    .byte 3    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    .byte BS1, BS1, BS2, BS2
    
wall_7_info:
    .byte 3, 0 ; start x, y
    .byte 0, 0 ; end x, y
    .byte 0    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    .byte BS1, BS2, BS1
    

; Square room
    .if 0    
    
wall_0_info:
    .byte 0, 4 ; start x, y
    .byte 4, 4 ; end x, y
    .byte 2    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west

wall_1_info:
    .byte 4, 4 ; start x, y
    .byte 4, 0 ; end x, y
    .byte 3    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west

wall_2_info:
    .byte 4, 0 ; start x, y
    .byte 0, 0 ; end x, y
    .byte 0    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west

wall_3_info:
    .byte 0, 0 ; start x, y
    .byte 0, 4 ; end x, y
    .byte 1    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    
    .endif

setup_player:

    ; TODO: this is now hardcoded, but this should to taken from a map

    ; x-position of the viewpoint (8.8 bits)
    lda #128
    sta PLAYER_POS_X 
    lda #1
    sta PLAYER_POS_X+1
    
    ; y-position of the viewpoint (8.8 bits)
    lda #0
    sta PLAYER_POS_Y
    lda #1
    sta PLAYER_POS_Y+1
    
    ; looking direction of the player/view (0-1823)
    lda #0
    ;lda #<(1824/4-100)
    sta LOOKING_DIR
    lda #0
    ;lda #>(1824/4-100)
    sta LOOKING_DIR+1
    
    rts
    
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
    lda #<(wall_0_info+5)
    sta WALL_INFO_TEXTURE_LOW,y
    lda #>(wall_0_info+5)
    sta WALL_INFO_TEXTURE_HIGH,y

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
    lda #<(wall_1_info+5)
    sta WALL_INFO_TEXTURE_LOW,y
    lda #>(wall_1_info+5)
    sta WALL_INFO_TEXTURE_HIGH,y
    
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
    lda #<(wall_2_info+5)
    sta WALL_INFO_TEXTURE_LOW,y
    lda #>(wall_2_info+5)
    sta WALL_INFO_TEXTURE_HIGH,y
    
    ldy #3

    lda wall_3_info
    sta WALL_INFO_START_X, y
    lda wall_3_info+1
    sta WALL_INFO_START_Y, y
    lda wall_3_info+2
    sta WALL_INFO_END_X, y
    lda wall_3_info+3
    sta WALL_INFO_END_Y, y
    lda wall_3_info+4
    sta WALL_INFO_FACING_DIR, y
    lda #<(wall_3_info+5)
    sta WALL_INFO_TEXTURE_LOW,y
    lda #>(wall_3_info+5)
    sta WALL_INFO_TEXTURE_HIGH,y
    
    ldy #4

    lda wall_4_info
    sta WALL_INFO_START_X, y
    lda wall_4_info+1
    sta WALL_INFO_START_Y, y
    lda wall_4_info+2
    sta WALL_INFO_END_X, y
    lda wall_4_info+3
    sta WALL_INFO_END_Y, y
    lda wall_4_info+4
    sta WALL_INFO_FACING_DIR, y
    lda #<(wall_4_info+5)
    sta WALL_INFO_TEXTURE_LOW,y
    lda #>(wall_4_info+5)
    sta WALL_INFO_TEXTURE_HIGH,y
    
    ldy #5

    lda wall_5_info
    sta WALL_INFO_START_X, y
    lda wall_5_info+1
    sta WALL_INFO_START_Y, y
    lda wall_5_info+2
    sta WALL_INFO_END_X, y
    lda wall_5_info+3
    sta WALL_INFO_END_Y, y
    lda wall_5_info+4
    sta WALL_INFO_FACING_DIR, y
    lda #<(wall_5_info+5)
    sta WALL_INFO_TEXTURE_LOW,y
    lda #>(wall_5_info+5)
    sta WALL_INFO_TEXTURE_HIGH,y
    
    ldy #6

    lda wall_6_info
    sta WALL_INFO_START_X, y
    lda wall_6_info+1
    sta WALL_INFO_START_Y, y
    lda wall_6_info+2
    sta WALL_INFO_END_X, y
    lda wall_6_info+3
    sta WALL_INFO_END_Y, y
    lda wall_6_info+4
    sta WALL_INFO_FACING_DIR, y
    lda #<(wall_6_info+5)
    sta WALL_INFO_TEXTURE_LOW,y
    lda #>(wall_6_info+5)
    sta WALL_INFO_TEXTURE_HIGH,y
    
    ldy #7

    lda wall_7_info
    sta WALL_INFO_START_X, y
    lda wall_7_info+1
    sta WALL_INFO_START_Y, y
    lda wall_7_info+2
    sta WALL_INFO_END_X, y
    lda wall_7_info+3
    sta WALL_INFO_END_Y, y
    lda wall_7_info+4
    sta WALL_INFO_FACING_DIR, y
    lda #<(wall_7_info+5)
    sta WALL_INFO_TEXTURE_LOW,y
    lda #>(wall_7_info+5)
    sta WALL_INFO_TEXTURE_HIGH,y
    
    rts


; FIXME: we are now using ROM banks to contain textures. We need to copy those textures to vram, but have to run that copy-code in RAM. This is all deprecated once we use the SD card!
    
copy_vram_copiers_to_ram:

    ; Copying copy_texture_to_vram -> COPY_TEXTURE_TO_VRAM
    
    ldy #0
copy_texture_to_vram_byte:
    lda copy_texture_to_vram, y
    sta COPY_TEXTURE_TO_VRAM, y
    iny 
    cpy #(end_of_copy_texture_to_vram-copy_texture_to_vram)
    bne copy_texture_to_vram_byte

    ; Copying copy_palette_to_vram -> COPY_PALLETE_TO_VRAM
    
    ldy #0
copy_pallete_to_vram_byte:
    lda copy_palette_to_vram, y
    sta COPY_PALLETE_TO_VRAM, y
    iny 
    cpy #(end_of_copy_palette_to_vram-copy_palette_to_vram)
    bne copy_pallete_to_vram_byte

    rts

    
; FIXME: this is UGLY!
copy_texture_to_vram:

    ; Switching ROM BANK
    ; FIXME: HARDCODED!
    lda #$01
    sta ROM_BANK
; FIXME: remove nop!
    nop

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
    adc PALETTE_COLOR_OFFSET
    sta VERA_DATA0
    iny
    bne next_byte_to_copy_to_vram
    
    inc LOAD_ADDRESS+1
    inx
    cpx #16              ; 16 * 256 = 4096 bytes
    bne next_block_to_copy_to_vram


    ; Switching back to ROM bank 0
    lda #$00
    sta ROM_BANK
; FIXME: remove nop!
    nop
   
    rts
end_of_copy_texture_to_vram:




load_textures_into_vram:

    ; FIXME: this is deprecated once we run from the SD and run inside the kernal!
    jsr copy_vram_copiers_to_ram

    ; TODO: we can choose a much low palette color offset!
    lda #64   ; we start at this palette color offset
    sta PALETTE_COLOR_OFFSET

    
    ; Texture pixels
    lda #<($C000+2+blue_stone_1_texture)
    sta LOAD_ADDRESS
    lda #>($C000+2+blue_stone_1_texture)
    sta LOAD_ADDRESS+1
    
    lda #<TEXTURE_DATA
    sta VRAM_ADDRESS
    lda #>TEXTURE_DATA
    sta VRAM_ADDRESS+1
    
    jsr COPY_TEXTURE_TO_VRAM
    
    ; Texture palette
    lda #<($C000+2+blue_stone_1_texture+4096)  ; palette starts at 4096 (first byte contains nr of colors)
    sta LOAD_ADDRESS
    lda #>($C000+2+blue_stone_1_texture+4096)  ; palette starts at 4096 (first byte contains nr of colors)
    sta LOAD_ADDRESS+1
    
    jsr COPY_PALLETE_TO_VRAM
    
    ; Texture pixels
    lda #<($C000+2+blue_stone_2_texture)
    sta LOAD_ADDRESS
    lda #>($C000+2+blue_stone_2_texture)
    sta LOAD_ADDRESS+1
    
    lda #<(TEXTURE_DATA+4096)
    sta VRAM_ADDRESS
    lda #>(TEXTURE_DATA+4096)
    sta VRAM_ADDRESS+1
    
    jsr COPY_TEXTURE_TO_VRAM
    
    ; Texture palette
    lda #<($C000+2+blue_stone_2_texture+4096)  ; palette starts at 4096 (first byte contains nr of colors)
    sta LOAD_ADDRESS
    lda #>($C000+2+blue_stone_2_texture+4096)  ; palette starts at 4096 (first byte contains nr of colors)
    sta LOAD_ADDRESS+1
    
    jsr COPY_PALLETE_TO_VRAM

    ; Texture pixels
    lda #<($C000+2+closed_door_texture)
    sta LOAD_ADDRESS
    lda #>($C000+2+closed_door_texture)
    sta LOAD_ADDRESS+1
    
    lda #<(TEXTURE_DATA+4096*2)
    sta VRAM_ADDRESS
    lda #>(TEXTURE_DATA+4096*2)
    sta VRAM_ADDRESS+1
    
    jsr COPY_TEXTURE_TO_VRAM
    
    ; Texture palette
    lda #<($C000+2+closed_door_texture+4096)  ; palette starts at 4096 (first byte contains nr of colors)
    sta LOAD_ADDRESS
    lda #>($C000+2+closed_door_texture+4096)  ; palette starts at 4096 (first byte contains nr of colors)
    sta LOAD_ADDRESS+1
    
    jsr COPY_PALLETE_TO_VRAM
    
    rts
    


; FIXME: this is UGLY!
copy_palette_to_vram:

    ; Switching ROM BANK
    ; FIXME: HARDCODED!
    lda #$01
    sta ROM_BANK
; FIXME: remove nop!
    nop

    ldy #0

    lda (LOAD_ADDRESS), y            ; this is the byte containing the number of palette bytes
    sta NR_OF_PALETTE_BYTES
    
    inc LOAD_ADDRESS            ; our new base address should be one higher, since the first byte contained the nr of colors
    bne palette_load_address_ok
    inc LOAD_ADDRESS+1
palette_load_address_ok:

    ; TODO: this assumes ADDRSEL is 0!
    
    lda #%00010001           ; Setting bit 16 of vram address to the highest bit (=1), setting auto-increment value to 1
    sta VERA_ADDR_BANK
    lda #>(VERA_PALETTE)
    sta VERA_ADDR_HIGH
    lda #<(VERA_PALETTE)
    sta VERA_ADDR_LOW

    ; FIXME: this is dumb, but we move the VERA address towards the correct palette entry by ITERATING to it...
    ;        this also doesnt work if PALETTE_COLOR_OFFSET = 0 (but we assume it never is)
    ldx #0
go_to_next_palette_entry:
    lda VERA_DATA0  ; this increments the VERA address
    lda VERA_DATA0  ; this increments the VERA address
    inx
    cpx PALETTE_COLOR_OFFSET
    bne go_to_next_palette_entry
    
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

    inc PALETTE_COLOR_OFFSET

    cpy NR_OF_PALETTE_BYTES
    bne next_palette_color_to_copy


    ; Switching back to ROM bank 0
    lda #$00
    sta ROM_BANK
; FIXME: remove nop!
    nop
   
    rts
end_of_copy_palette_to_vram:
    
    
generate_draw_column_code:
    
    ; Below assumes a "virtual screen" of 512 pixels high, with the actual screen (which is 152 pixels high) starting at pixel 512/2 - 152/2 = 180 pixels from the top of this "virtual screen"
    
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
        
        
    
    lda #0
    sta CURRENT_WALL_HEIGHT+1
    lda #8                      ; TODO: we currenly start at wall height of 8. What is the minimal wall height?
    sta CURRENT_WALL_HEIGHT

generate_draw_code_for_next_wall_height:

    ldy #0                 ; generated code byte counter
    
    lda #<DRAW_COLUMN_CODE
    sta CODE_ADDRESS
    lda #>DRAW_COLUMN_CODE
    sta CODE_ADDRESS+1
    
    ; We allow a wall height of up to 512, but store only the even ones
    ; We store only the even wall heights, so we store at index: wall height / 2
    lda CURRENT_WALL_HEIGHT+1
    lsr
    lda CURRENT_WALL_HEIGHT
    ror                        
    sta RAM_BANK
    ; FIXME: remove this nop!
    nop
    
    ; We do the divide: texture_increment = 64.0 / wall_height
    lda #64
    sta DIVIDEND+2
    lda #0
    sta DIVIDEND+1
    lda #0
    sta DIVIDEND
    
    lda #0
    sta DIVISOR+2
    lda CURRENT_WALL_HEIGHT+1
    sta DIVISOR+1
    lda CURRENT_WALL_HEIGHT
    sta DIVISOR
    
    jsr divide_24bits
    
    lda DIVIDEND+2
    sta TEXTURE_INCREMENT+2
    lda DIVIDEND+1
    sta TEXTURE_INCREMENT+1
    lda DIVIDEND
    sta TEXTURE_INCREMENT
    
    ; We reset the current and previous texture cursor
    lda #0
    sta TEXTURE_CURSOR
    lda #0
    sta TEXTURE_CURSOR+1
    lda #0
    sta TEXTURE_CURSOR+2
    lda #255
    sta PREVIOUS_TEXTURE_CURSOR
    
    ; We determine your start position on the "virtual screen": virtual_screen_cursor = 512/2 - wall_height/2
    
    lda CURRENT_WALL_HEIGHT+1
    lsr 
    lda CURRENT_WALL_HEIGHT
    ror                        ; wall_height/2
    sta TOP_HALF_WALL_HEIGHT
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

    sec
    lda TEXTURE_CURSOR+2
    sbc PREVIOUS_TEXTURE_CURSOR           ; we calcultate the nr of texels we are 'off'
    beq correct_texture_pixel_loaded_top  ; if we are equal we dont have to load a new texel

    ; We need to add one or several loads of the texture
    phx
    tax
    
load_next_texture_top:
    ; -- lda VERA_DATA1 ($9F24)
    lda #$AD               ; lda ....
    jsr add_code_byte
    
    lda #$24               ; VERA_DATA1
    jsr add_code_byte
    
    lda #$9F         
    jsr add_code_byte
    
    dex
    bne load_next_texture_top

    plx

    lda TEXTURE_CURSOR+2
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
    lda TEXTURE_CURSOR+2
    adc TEXTURE_INCREMENT+2
    sta TEXTURE_CURSOR+2
    
    ; Increment the virtual cursor
    inc VIRTUAL_SCREEN_CURSOR
    
    lda VIRTUAL_SCREEN_CURSOR
    bne next_virtual_pixel_top       ; Repeat until we reach 256 for our virtual pixel.

    ; == Now we do the same for the BOTTOM part of the virtual screen ==

next_virtual_pixel_bottom:

    sec
    lda TEXTURE_CURSOR+2
    sbc PREVIOUS_TEXTURE_CURSOR              ; we calcultate the nr of texels we are 'off'
    beq correct_texture_pixel_loaded_bottom  ; if we are equal we dont have to load a new texel
    
    ; We need to add one or several loads of the texture
    phx
    tax
    
load_next_texture_bottom:
    ; -- lda VERA_DATA1 ($9F24)
    lda #$AD               ; lda ....
    jsr add_code_byte
    
    lda #$24               ; VERA_DATA1
    jsr add_code_byte
    
    lda #$9F         
    jsr add_code_byte
    
    dex
    bne load_next_texture_bottom
    
    plx

    lda TEXTURE_CURSOR+2
    sta PREVIOUS_TEXTURE_CURSOR
    
correct_texture_pixel_loaded_bottom:

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
    lda TEXTURE_CURSOR+2
    adc TEXTURE_INCREMENT+2
    sta TEXTURE_CURSOR+2
    
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
    
    inc CURRENT_WALL_HEIGHT
    inc CURRENT_WALL_HEIGHT
    bne keep_generating_draw_code
    ; We reach 256, so we have to increment the high byte
    inc CURRENT_WALL_HEIGHT+1
    lda CURRENT_WALL_HEIGHT+1
    cmp #2
    beq stop_generating_draw_code ; if we reached wall height 512 we stop

keep_generating_draw_code:
    jmp generate_draw_code_for_next_wall_height
    
stop_generating_draw_code:
    
        
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

    
; === TODO: put this in a more common place (e.g. math.s): ===


; See: https://github.com/commanderx16/x16-demo/blob/master/cc65-sprite/demo.c

; Python script to generate the table:
; import math
; # cycle=320
; cycle=1824
; ampl=256
; [int(math.sin(float(i)/cycle*2.0*math.pi)*ampl+0.5) for i in range(cycle)]
; [int(math.cos(float(i)/cycle*2.0*math.pi)*ampl+0.5) for i in range(cycle)]

; [int(math.tan(float(i)/cycle*2.0*math.pi)*ampl+0.5) for i in range(cycle)]

; The math.atan() method returns the arc tangent of a number (x) as a numeric value between -PI/2 and PI/2 radians.
; example: math.atan(55/256)/(math.pi*2.0)*1824
; FIXME: shouldnt there be a +0.5 here somewhere?
; [int(math.atan(j/ampl)/(math.pi*2.0)*cycle) for j in range(ampl)]

; Also see: https://csdb.dk/forums/?roomid=11&topicid=26608&firstpost=2


; FIXME: we only need ONE byte per entry for sine and cosine! (the last few are 256, but that can be handled a different way)

; This is a list of 8.8 bit values (so 16 bits each, 8 bits for fraction, 8 bits for whole number)
; Since there are 456 angle-indexes per 90 degrees, this list contains 456 values (actually a bit more, but I am lazy and havent removed the last/extra ones).
sine:
    .word 0, 1, 2, 3, 4, 4, 5, 6, 7, 8, 9, 10, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 19, 20, 21, 22, 23, 24, 25, 26, 26, 27, 28, 29, 30, 31, 32, 33, 33, 34, 35, 36, 37, 38, 39, 40, 40, 41, 42, 43, 44, 45, 46, 46, 47, 48, 49, 50, 51, 52, 53, 53, 54, 55, 56, 57, 58, 59, 59, 60, 61, 62, 63, 64, 65, 65, 66, 67, 68, 69, 70, 71, 71, 72, 73, 74, 75, 76, 76, 77, 78, 79, 80, 81, 81, 82, 83, 84, 85, 86, 86, 87, 88, 89, 90, 91, 91, 92, 93, 94, 95, 96, 96, 97, 98, 99, 100, 100, 101, 102, 103, 104, 104, 105, 106, 107, 108, 108, 109, 110, 111, 112, 112, 113, 114, 115, 116, 116, 117, 118, 119, 120, 120, 121, 122, 123, 123, 124, 125, 126, 126, 127, 128, 129, 130, 130, 131, 132, 133, 133, 134, 135, 136, 136, 137, 138, 139, 139, 140, 141, 141, 142, 143, 144, 144, 145, 146, 147, 147, 148, 149, 149, 150, 151, 152, 152, 153, 154, 154, 155, 156, 157, 157, 158, 159, 159, 160, 161, 161, 162, 163, 163, 164, 165, 165, 166, 167, 167, 168, 169, 169, 170, 171, 171, 172, 173, 173, 174, 175, 175, 176, 177, 177, 178, 179, 179, 180, 180, 181, 182, 182, 183, 183, 184, 185, 185, 186, 187, 187, 188, 188, 189, 190, 190, 191, 191, 192, 192, 193, 194, 194, 195, 195, 196, 196, 197, 198, 198, 199, 199, 200, 200, 201, 201, 202, 203, 203, 204, 204, 205, 205, 206, 206, 207, 207, 208, 208, 209, 209, 210, 210, 211, 211, 212, 212, 213, 213, 214, 214, 215, 215, 216, 216, 217, 217, 218, 218, 219, 219, 219, 220, 220, 221, 221, 222, 222, 223, 223, 223, 224, 224, 225, 225, 226, 226, 226, 227, 227, 228, 228, 228, 229, 229, 230, 230, 230, 231, 231, 232, 232, 232, 233, 233, 233, 234, 234, 234, 235, 235, 235, 236, 236, 237, 237, 237, 238, 238, 238, 238, 239, 239, 239, 240, 240, 240, 241, 241, 241, 242, 242, 242, 242, 243, 243, 243, 244, 244, 244, 244, 245, 245, 245, 245, 246, 246, 246, 246, 247, 247, 247, 247, 248, 248, 248, 248, 248, 249, 249, 249, 249, 249, 250, 250, 250, 250, 250, 251, 251, 251, 251, 251, 251, 252, 252, 252, 252, 252, 252, 253, 253, 253, 253, 253, 253, 253, 253, 254, 254, 254, 254, 254, 254, 254, 254, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 255

; This is a list of 8 bit values (8 bits for a fraction, no bits for the whole number, since that is assumed to be 0)
; Since there are 456 angle-indexes per 90 degrees, this list contains 456 values (actually a bit more, but I am lazy and havent removed the last/extra ones).
cosine:
    .word 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 256, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 254, 254, 254, 254, 254, 254, 254, 254, 253, 253, 253, 253, 253, 253, 253, 253, 252, 252, 252, 252, 252, 252, 251, 251, 251, 251, 251, 251, 250, 250, 250, 250, 250, 249, 249, 249, 249, 249, 248, 248, 248, 248, 248, 247, 247, 247, 247, 246, 246, 246, 246, 245, 245, 245, 245, 244, 244, 244, 244, 243, 243, 243, 242, 242, 242, 242, 241, 241, 241, 240, 240, 240, 239, 239, 239, 238, 238, 238, 238, 237, 237, 237, 236, 236, 235, 235, 235, 234, 234, 234, 233, 233, 233, 232, 232, 232, 231, 231, 230, 230, 230, 229, 229, 228, 228, 228, 227, 227, 226, 226, 226, 225, 225, 224, 224, 223, 223, 223, 222, 222, 221, 221, 220, 220, 219, 219, 219, 218, 218, 217, 217, 216, 216, 215, 215, 214, 214, 213, 213, 212, 212, 211, 211, 210, 210, 209, 209, 208, 208, 207, 207, 206, 206, 205, 205, 204, 204, 203, 203, 202, 201, 201, 200, 200, 199, 199, 198, 198, 197, 196, 196, 195, 195, 194, 194, 193, 192, 192, 191, 191, 190, 190, 189, 188, 188, 187, 187, 186, 185, 185, 184, 183, 183, 182, 182, 181, 180, 180, 179, 179, 178, 177, 177, 176, 175, 175, 174, 173, 173, 172, 171, 171, 170, 169, 169, 168, 167, 167, 166, 165, 165, 164, 163, 163, 162, 161, 161, 160, 159, 159, 158, 157, 157, 156, 155, 154, 154, 153, 152, 152, 151, 150, 149, 149, 148, 147, 147, 146, 145, 144, 144, 143, 142, 141, 141, 140, 139, 139, 138, 137, 136, 136, 135, 134, 133, 133, 132, 131, 130, 130, 129, 128, 127, 126, 126, 125, 124, 123, 123, 122, 121, 120, 120, 119, 118, 117, 116, 116, 115, 114, 113, 112, 112, 111, 110, 109, 108, 108, 107, 106, 105, 104, 104, 103, 102, 101, 100, 100, 99, 98, 97, 96, 96, 95, 94, 93, 92, 91, 91, 90, 89, 88, 87, 86, 86, 85, 84, 83, 82, 81, 81, 80, 79, 78, 77, 76, 76, 75, 74, 73, 72, 71, 71, 70, 69, 68, 67, 66, 65, 65, 64, 63, 62, 61, 60, 59, 59, 58, 57, 56, 55, 54, 53, 53, 52, 51, 50, 49, 48, 47, 46, 46, 45, 44, 43, 42, 41, 40, 40, 39, 38, 37, 36, 35, 34, 33, 33, 32, 31, 30, 29, 28, 27, 26, 26, 25, 24, 23, 22, 21, 20, 19, 19, 18, 17, 16, 15, 14, 13, 12, 11, 11, 10, 9, 8, 7, 6, 5, 4, 4, 3, 2, 1, 0, 0

; This is a list of 8.8 bit values (so 16 bits each, 8 bits for fraction, 8 bits for whole number)
; Since there are 456 angle-indexes per 90 degrees, this list contains 456 values.
tangent:
    ; FIXME: DOUBLE CHECK THIS, ESPECIALLY THE NUMBERS AT THE END!
    ; FIXME: store these as two list of high byte and low byte instead from the beginning! (aligned to a page)
    .word 0, 1, 2, 3, 4, 4, 5, 6, 7, 8,  9, 10, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 19, 20, 21, 22, 23, 24, 25, 26, 27, 27, 28, 29, 30, 31, 32, 33, 34, 35, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91,  92,  93,  94,  95,  96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 130, 131, 132, 133, 134, 135, 136, 137, 139, 140, 141, 142, 143, 144, 145, 147, 148, 149, 150, 151, 153, 154, 155, 156, 157, 159, 160, 161, 162, 164, 165, 166, 167, 169, 170, 171, 172, 174, 175, 176, 178, 179, 180, 181, 183, 184, 185, 187, 188, 190, 191, 192, 194, 195, 196, 198, 199, 201, 202, 204, 205, 206, 208, 209, 211, 212, 214, 215, 217, 218, 220, 221, 223, 225, 226, 228, 229, 231, 232, 234, 236, 237, 239, 241, 242, 244, 246, 247, 249, 251, 252, 254, 256, 258, 260, 261, 263, 265, 267, 269, 271, 272, 274, 276, 278, 280, 282, 284, 286, 288, 290, 292, 294, 296, 298, 300, 302, 304, 307, 309, 311, 313, 315, 317, 320, 322, 324, 327, 329, 331, 334, 336, 338, 341, 343, 346, 348, 351, 353, 356, 359, 361, 364, 367, 369, 372, 375, 377, 380, 383, 386, 389, 392, 395, 398, 401, 404, 407, 410, 413, 416, 420, 423, 426, 430, 433, 436, 440, 443, 447, 451, 454, 458, 462, 465, 469, 473, 477, 481, 485, 489, 493, 497, 502, 506, 510, 515, 519, 524, 528, 533, 538, 542, 547, 552, 557, 562, 568, 573, 578, 584, 589, 595, 600, 606, 612, 618, 624, 630, 637, 643, 649, 656, 663, 670, 677, 684, 691, 698, 706, 714, 721, 729, 737, 746, 754, 763, 772, 781, 790, 799, 809, 818, 828, 839, 849, 860, 871, 882, 894, 905, 917, 930, 942, 955, 969, 982, 996, 1011, 1026, 1041, 1057, 1073, 1089, 1107, 1124, 1142, 1161, 1180, 1200, 1221, 1242, 1264, 1287, 1311, 1335, 1360, 1387, 1414, 1442, 1472, 1502, 1534, 1567, 1602, 1638, 1676, 1716, 1757, 1801, 1846, 1894, 1945, 1998, 2054, 2113, 2176, 2242, 2313, 2388, 2468, 2554, 2646, 2745, 2851, 2965, 3089, 3224, 3372, 3533, 3710, 3906, 4123, 4367, 4640, 4950, 5304, 5713, 6190, 6753, 7429, 8255, 9287, 10615, 12384, 14862, 18578, 24771, 32767/2, 32767/2, 32767/2
    ; idx 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228

; This is a list of number between 0 and 228 representing an angle. There are 256 entries which indicate the result after a y/x division: 8-bit number (0.8 bits). So this covers 45 degrees.
; Also see: https://www.microchip.com/forums/m817546.aspx
invtangent:
    ; manually: .byte 0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 38, 39, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 64, 65, 
    .byte 0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 16, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30, 31, 32, 33, 34, 36, 37, 38, 39, 40, 41, 42, 43, 44, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 139, 140, 141, 142, 143, 144, 145, 146, 147, 147, 148, 149, 150, 151, 152, 153, 153, 154, 155, 156, 157, 158, 158, 159, 160, 161, 162, 162, 163, 164, 165, 166, 167, 167, 168, 169, 170, 170, 171, 172, 173, 174, 174, 175, 176, 177, 177, 178, 179, 180, 180, 181, 182, 183, 183, 184, 185, 186, 186, 187, 188, 188, 189, 190, 191, 191, 192, 193, 193, 194, 195, 196, 196, 197, 198, 198, 199, 200, 200, 201, 202, 202, 203, 204, 204, 205, 206, 206, 207, 208, 208, 209, 209, 210, 211, 211, 212, 213, 213, 214, 214, 215, 216, 216, 217, 218, 218, 219, 219, 220, 221, 221, 222, 222, 223, 223, 224, 225, 225, 226, 226, 227
    ; idx 0, 1, 2, 3, 4, 5, 6, 7, 8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91,  92,  93,  94,  95,  96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255
    
init_sine:

    lda #<sine
    sta LOAD_ADDRESS
    lda #>sine
    sta LOAD_ADDRESS+1
    
    ldx #0
next_sine_value_first_part:
    ldy #0
    lda (LOAD_ADDRESS),y
    sta SINE_LOW, x
    
    ldy #1
    lda (LOAD_ADDRESS),y
    sta SINE_HIGH, x
    
    inx
    beq done_sine_first_part
    
    inc LOAD_ADDRESS
    bne sine_incemented_load_address_once_first
    inc LOAD_ADDRESS+1
sine_incemented_load_address_once_first:
    inc LOAD_ADDRESS
    bne sine_incemented_load_address_twice_first
    inc LOAD_ADDRESS+1
sine_incemented_load_address_twice_first:
    bra next_sine_value_first_part
    
done_sine_first_part:
    
    lda #<(sine+512)
    sta LOAD_ADDRESS
    lda #>(sine+512)
    sta LOAD_ADDRESS+1
    
    ldx #0
next_sine_value_last_part:
    ldy #0
    lda (LOAD_ADDRESS),y
    sta SINE_LOW+256, x
    
    ldy #1
    lda (LOAD_ADDRESS),y
    sta SINE_HIGH+256, x
    
    inx
    cpx #(456-256)
    beq done_sine_last_part
    
    inc LOAD_ADDRESS
    bne sine_incemented_load_address_once_last
    inc LOAD_ADDRESS+1
sine_incemented_load_address_once_last:
    inc LOAD_ADDRESS
    bne sine_incemented_load_address_twice_last
    inc LOAD_ADDRESS+1
sine_incemented_load_address_twice_last:
    bra next_sine_value_last_part
    
done_sine_last_part:

    rts

init_cosine:

    lda #<cosine
    sta LOAD_ADDRESS
    lda #>cosine
    sta LOAD_ADDRESS+1
    
    ldx #0
next_cosine_value_first_part:
    ldy #0
    lda (LOAD_ADDRESS),y
    sta COSINE_LOW, x
    
    ldy #1
    lda (LOAD_ADDRESS),y
    sta COSINE_HIGH, x
    
    inx
    beq done_cosine_first_part
    
    inc LOAD_ADDRESS
    bne cosine_incemented_load_address_once_first
    inc LOAD_ADDRESS+1
cosine_incemented_load_address_once_first:
    inc LOAD_ADDRESS
    bne cosine_incemented_load_address_twice_first
    inc LOAD_ADDRESS+1
cosine_incemented_load_address_twice_first:
    bra next_cosine_value_first_part
    
done_cosine_first_part:
    
    lda #<(cosine+512)
    sta LOAD_ADDRESS
    lda #>(cosine+512)
    sta LOAD_ADDRESS+1
    
    ldx #0
next_cosine_value_last_part:
    ldy #0
    lda (LOAD_ADDRESS),y
    sta COSINE_LOW+256, x
    
    ldy #1
    lda (LOAD_ADDRESS),y
    sta COSINE_HIGH+256, x
    
    inx
    cpx #(456-256)
    beq done_cosine_last_part
    
    inc LOAD_ADDRESS
    bne cosine_incemented_load_address_once_last
    inc LOAD_ADDRESS+1
cosine_incemented_load_address_once_last:
    inc LOAD_ADDRESS
    bne cosine_incemented_load_address_twice_last
    inc LOAD_ADDRESS+1
cosine_incemented_load_address_twice_last:
    bra next_cosine_value_last_part
    
done_cosine_last_part:

    rts
    
    
init_tangent:

    lda #<tangent
    sta LOAD_ADDRESS
    lda #>tangent
    sta LOAD_ADDRESS+1
    
    ldx #0
next_tangent_value_first_part:
    ldy #0
    lda (LOAD_ADDRESS),y
    sta TANGENT_LOW, x
    
    ldy #1
    lda (LOAD_ADDRESS),y
    sta TANGENT_HIGH, x
    
    inx
    beq done_tangent_first_part
    
    inc LOAD_ADDRESS
    bne tangent_incemented_load_address_once_first
    inc LOAD_ADDRESS+1
tangent_incemented_load_address_once_first:
    inc LOAD_ADDRESS
    bne tangent_incemented_load_address_twice_first
    inc LOAD_ADDRESS+1
tangent_incemented_load_address_twice_first:
    bra next_tangent_value_first_part
    
done_tangent_first_part:
    
    lda #<(tangent+512)
    sta LOAD_ADDRESS
    lda #>(tangent+512)
    sta LOAD_ADDRESS+1
    
    ldx #0
next_tangent_value_last_part:
    ldy #0
    lda (LOAD_ADDRESS),y
    sta TANGENT_LOW+256, x
    
    ldy #1
    lda (LOAD_ADDRESS),y
    sta TANGENT_HIGH+256, x
    
    inx
    cpx #(456-256)
    beq done_tangent_last_part
    
    inc LOAD_ADDRESS
    bne tangent_incemented_load_address_once_last
    inc LOAD_ADDRESS+1
tangent_incemented_load_address_once_last:
    inc LOAD_ADDRESS
    bne tangent_incemented_load_address_twice_last
    inc LOAD_ADDRESS+1
tangent_incemented_load_address_twice_last:
    bra next_tangent_value_last_part
    
done_tangent_last_part:

    rts










    
; https://codebase64.org/doku.php?id=base:24bit_division_24-bit_result

divide_24bits:
    phx
    phy

    lda #0            ; preset REMAINDER to 0
    sta REMAINDER
    sta REMAINDER+1
    sta REMAINDER+2
    ldx #24            ; repeat for each bit: ...

divloop:
    asl DIVIDEND    ; DIVIDEND lb & hb*2, msb -> Carry
    rol DIVIDEND+1    
    rol DIVIDEND+2
    rol REMAINDER    ; REMAINDER lb & hb * 2 + msb from carry
    rol REMAINDER+1
    rol REMAINDER+2
    lda REMAINDER
    sec
    sbc DIVISOR        ; substract DIVISOR to see if it fits in
    tay                ; lb result -> Y, for we may need it later
    lda REMAINDER+1
    sbc DIVISOR+1
    sta TMP1
    lda REMAINDER+2
    sbc DIVISOR+2
    bcc divskip     ; if carry=0 then DIVISOR didnt fit in yet

    sta REMAINDER+2 ; else save substraction result as new REMAINDER,
    lda TMP1
    sta REMAINDER+1
    sty REMAINDER    
    inc DIVIDEND    ; and INCrement result cause DIVISOR fit in 1 times

divskip:
    dex
    bne divloop    
    
    ply
    plx
    rts


    
; https://codebase64.org/doku.php?id=base:16bit_multiplication_32-bit_product

multply_16bits:
    phx
    lda    #$00
    sta    PRODUCT+2    ; clear upper bits of PRODUCT
    sta    PRODUCT+3 
    ldx    #$10         ; set binary count to 16 
shift_r:
    lsr    MULTIPLIER+1 ; divide MULTIPLIER by 2 
    ror    MULTIPLIER
    bcc    rotate_r 
    lda    PRODUCT+2    ; get upper half of PRODUCT and add MULTIPLICAND
    clc
    adc    MULTIPLICAND
    sta    PRODUCT+2
    lda    PRODUCT+3 
    adc    MULTIPLICAND+1
rotate_r:
    ror                 ; rotate partial PRODUCT 
    sta    PRODUCT+3 
    ror    PRODUCT+2
    ror    PRODUCT+1 
    ror    PRODUCT 
    dex
    bne    shift_r 
    plx
    
    rts
    