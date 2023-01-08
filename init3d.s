; FIXME: use a different background color, or none!
BACKGROUND_COLOR_3D_VIEW = 0
CEILING_COLOR            = 19
FLOOR_COLOR              = 22

; FIXME: this assumes TEXTURE_DATA = $13000 which might change!
BS1 = $00+$30 ; blue stone 1
BS2 = $10+$30 ; blue stone 2
CLD = $20+$30 ; closed door


NR_OF_WALLS = TMP2


; FIXME: this is temporary data to get some wall information into the engine

    .if 1

    ; Note: STARTING_PLAYER_POS_... is set inside wall_map.s
    
STARTING_LOOKING_DIR_ANGLE = 1368

    .include wall_map.s
    .endif
    
    .if 0
; Starting room of Wolf3D (sort of)

;     2           ; Note: this door is rendered *before* the walls beside it! (it is also position at y = 4, not y = 5)
; 13_|_|_45
;   |   |
;  0|   |6
;   |   |
;   |___|
;     7

STARTING_PLAYER_POS_X_HIGH = 1
STARTING_PLAYER_POS_X_LOW = 128

STARTING_PLAYER_POS_Y_HIGH = 1
STARTING_PLAYER_POS_Y_LOW = 0

STARTING_LOOKING_DIR_ANGLE = 100   ; 0 - 1823

; FIXME: we want this to be loaded on-the-fly!!
ordered_list_of_wall_indexes:
    .byte 0, 1, 2, 3, 4, 5, 6, 7

wall_info:
    .byte 8    ; number of walls

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
; FIXME: HACK! Door far away
;    .byte 1, 8 ; start x, y
;    .byte 2, 8 ; end x, y
; FIXME: door on north facing wall
;    .byte 2, 0 ; start x, y
;    .byte 1, 0 ; end x, y
;    .byte (0 | 4)   ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west  (bit 2 = 1 means this is a door)
; Normal door:
    .byte 1, 4 ; start x, y
    .byte 2, 4 ; end x, y
    .byte (2 | 4)   ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west  (bit 2 = 1 means this is a door)
    .byte CLD
    
wall_3_info:
    .byte 1, 4 ; start x, y
    .byte 1, 5 ; end x, y
    .byte 1    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    .byte BS1
    
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
    
; FIXME: HACK! moving back wall to front!
wall_7_info:
    .byte 0, 8 ; start x, y
    .byte 7, 8 ; end x, y
    .byte 2    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    .byte BS1, BS1, BS1, BS1, BS1, BS1, BS1, BS1
    
;wall_7_info:
;    .byte 3, 0 ; start x, y
;    .byte 0, 0 ; end x, y
;    .byte 0    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
;    .byte BS1, BS2, BS1
    .endif

; Square room
    .if 0
    
STARTING_PLAYER_POS_X_HIGH = 1
STARTING_PLAYER_POS_X_LOW = 128

STARTING_PLAYER_POS_Y_HIGH = 1
STARTING_PLAYER_POS_Y_LOW = 128

STARTING_LOOKING_DIR_ANGLE = 100   ; 0 - 1823
    
; FIXME: we want this to be loaded on-the-fly!!
ordered_list_of_wall_indexes:
    .byte 0, 1, 2, 3
    
wall_info:
    .byte 4    ; number of walls
    
wall_0_info:
    .byte 0, 4 ; start x, y
    .byte 4, 4 ; end x, y
    .byte 2    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    .byte BS2, BS2, BS2, BS2

wall_1_info:
    .byte 4, 4 ; start x, y
    .byte 4, 0 ; end x, y
    .byte 3    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    .byte BS1, BS2, BS2, BS2

wall_2_info:
    .byte 4, 0 ; start x, y
    .byte 0, 0 ; end x, y
    .byte 0    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    .byte BS1, BS1, BS1, BS2

wall_3_info:
    .byte 0, 0 ; start x, y
    .byte 0, 4 ; end x, y
    .byte 1    ; facing dir: 0 = north, 1 = east, 2 = south, 3 = west
    .byte BS1, BS1, BS1, BS1
    
    .endif

setup_player:

    ; TODO: this is now hardcoded, but this should to taken from a map

    ; x-position of the viewpoint (8.8 bits)
    lda #STARTING_PLAYER_POS_X_LOW
    sta PLAYER_POS_X 
    lda #STARTING_PLAYER_POS_X_HIGH
    sta PLAYER_POS_X+1
    
    ; y-position of the viewpoint (8.8 bits)
    lda #STARTING_PLAYER_POS_Y_LOW
    sta PLAYER_POS_Y
    lda #STARTING_PLAYER_POS_Y_HIGH
    sta PLAYER_POS_Y+1
    
    ; looking direction of the player/view (0-1823)
    lda #<(STARTING_LOOKING_DIR_ANGLE)
    sta LOOKING_DIR_ANGLE
    lda #>(STARTING_LOOKING_DIR_ANGLE)
    sta LOOKING_DIR_ANGLE+1
    
    jsr update_viewpoint
    
    rts
    
load_wall_info:

    lda #<wall_info
    sta LOAD_ADDRESS
    lda #>wall_info
    sta LOAD_ADDRESS+1

    ldy #0
    lda (LOAD_ADDRESS),y
    sta NR_OF_WALLS
    
    inc LOAD_ADDRESS
    bne load_wall_address_incremented
    inc LOAD_ADDRESS+1
load_wall_address_incremented:


    ldx #0          ; wall index
next_wall_to_load:

    lda (LOAD_ADDRESS),y
    sta WALL_INFO_START_X, x
    iny

    lda (LOAD_ADDRESS),y
    sta WALL_INFO_START_Y, x
    iny
    
    lda (LOAD_ADDRESS),y
    sta WALL_INFO_END_X, x
    iny
    
    lda (LOAD_ADDRESS),y
    sta WALL_INFO_END_Y, x
    iny
    
    lda (LOAD_ADDRESS),y
    sta WALL_INFO_FACING_DIR, x
    iny
    
    jsr determine_length_of_wall_using_facing_dir
    
    ; Set texture index table address for this wall
    clc
    lda LOAD_ADDRESS
    adc #<(5)
    sta WALL_INFO_TEXTURE_LOW,x
    lda LOAD_ADDRESS+1
    adc #>(5)             ; = 0
    sta WALL_INFO_TEXTURE_HIGH,x

    ; Increment the LOAD_ADDRESS to be just after the textture address, which is the start address of the next wall
    clc
    lda WALL_INFO_TEXTURE_LOW,x
    adc WALL_LENGTH
    sta LOAD_ADDRESS
    lda WALL_INFO_TEXTURE_HIGH,x
    adc #0
    sta LOAD_ADDRESS+1
    
    ; Reset y 
    ldy #0
    
    inx
    cpx NR_OF_WALLS
    bne next_wall_to_load

    rts

determine_length_of_wall_using_facing_dir:

    ; We remove the doorness of the wall (this doesnt matter for the wall length)
    and #%11111011
    
    ; lda WALL_INFO_FACING_DIR, x
    cmp #3  ; west
    beq length_wall_facing_west
    cmp #2  ; south
    beq length_wall_facing_south
    cmp #1  ; east
    beq length_wall_facing_east
    ;cmp #0  ; north
    ;beq length_wall_facing_north

length_wall_facing_north:
    sec
    lda WALL_INFO_START_X, x
    sbc WALL_INFO_END_X, x
    sta WALL_LENGTH
    bra done_length_of_wall_using_facing_dir
length_wall_facing_east:
    sec
    lda WALL_INFO_END_Y, x
    sbc WALL_INFO_START_Y, x
    sta WALL_LENGTH
    bra done_length_of_wall_using_facing_dir
length_wall_facing_south:
    sec
    lda WALL_INFO_END_X, x
    sbc WALL_INFO_START_X, x
    sta WALL_LENGTH
    bra done_length_of_wall_using_facing_dir
length_wall_facing_west:
    sec
    lda WALL_INFO_START_Y, x
    sbc WALL_INFO_END_Y, x
    sta WALL_LENGTH
    ; bra done_length_of_wall_using_facing_dir
    
done_length_of_wall_using_facing_dir:
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
