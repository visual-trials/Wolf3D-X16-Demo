
; FIXME: use a different background color, or none!
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
    
    
; FIXME: should we only store code for *EVEN* wall heights?
; FIXME: should we only store code for *EVEN* wall heights?
; FIXME: should we only store code for *EVEN* wall heights?
    
    ; FIXME: we should iterate over all possible wall heights
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
    
    ; FIXME: we currently allow only 256 wall height and store them inefficiently
    lda CURRENT_WALL_HEIGHT
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
    
    ; TODO: if wall height is an odd number, should we put the extra pixel at the top or at the bottom?
    lda CURRENT_WALL_HEIGHT+1
    lsr 
    lda CURRENT_WALL_HEIGHT
    ror                        ; wall_height/2
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

    lda TEXTURE_CURSOR+2
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

    lda TEXTURE_CURSOR+2
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
    
    ; FIXME; enable iterating over wall heights (not just 256)
    inc CURRENT_WALL_HEIGHT
    lda CURRENT_WALL_HEIGHT
    bne generate_draw_code_for_next_wall_height_jmp
        
    rts
    
generate_draw_code_for_next_wall_height_jmp:
    jmp generate_draw_code_for_next_wall_height
    
    


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


; This is a list of 8.8 bit values (so 16 bits each, 8 bits for fraction, 8 bits for whole number)
; Since there are 456 angle-indexes per 90 degrees, this list contains 456 values.
tangens:
    ; FIXME: DOUBLE CHECK THIS, ESPECIALLY THE NUMBERS AT THE END!
    ; FIXME: store these as two list of high byte and low byte instead from the beginning! (aligned to a page)
    .word 0, 1, 2, 3, 4, 4, 5, 6, 7, 8, 9, 10, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 19, 20, 21, 22, 23, 24, 25, 26, 27, 27, 28, 29, 30, 31, 32, 33, 34, 35, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 130, 131, 132, 133, 134, 135, 136, 137, 139, 140, 141, 142, 143, 144, 145, 147, 148, 149, 150, 151, 153, 154, 155, 156, 157, 159, 160, 161, 162, 164, 165, 166, 167, 169, 170, 171, 172, 174, 175, 176, 178, 179, 180, 181, 183, 184, 185, 187, 188, 190, 191, 192, 194, 195, 196, 198, 199, 201, 202, 204, 205, 206, 208, 209, 211, 212, 214, 215, 217, 218, 220, 221, 223, 225, 226, 228, 229, 231, 232, 234, 236, 237, 239, 241, 242, 244, 246, 247, 249, 251, 252, 254, 256, 258, 260, 261, 263, 265, 267, 269, 271, 272, 274, 276, 278, 280, 282, 284, 286, 288, 290, 292, 294, 296, 298, 300, 302, 304, 307, 309, 311, 313, 315, 317, 320, 322, 324, 327, 329, 331, 334, 336, 338, 341, 343, 346, 348, 351, 353, 356, 359, 361, 364, 367, 369, 372, 375, 377, 380, 383, 386, 389, 392, 395, 398, 401, 404, 407, 410, 413, 416, 420, 423, 426, 430, 433, 436, 440, 443, 447, 451, 454, 458, 462, 465, 469, 473, 477, 481, 485, 489, 493, 497, 502, 506, 510, 515, 519, 524, 528, 533, 538, 542, 547, 552, 557, 562, 568, 573, 578, 584, 589, 595, 600, 606, 612, 618, 624, 630, 637, 643, 649, 656, 663, 670, 677, 684, 691, 698, 706, 714, 721, 729, 737, 746, 754, 763, 772, 781, 790, 799, 809, 818, 828, 839, 849, 860, 871, 882, 894, 905, 917, 930, 942, 955, 969, 982, 996, 1011, 1026, 1041, 1057, 1073, 1089, 1107, 1124, 1142, 1161, 1180, 1200, 1221, 1242, 1264, 1287, 1311, 1335, 1360, 1387, 1414, 1442, 1472, 1502, 1534, 1567, 1602, 1638, 1676, 1716, 1757, 1801, 1846, 1894, 1945, 1998, 2054, 2113, 2176, 2242, 2313, 2388, 2468, 2554, 2646, 2745, 2851, 2965, 3089, 3224, 3372, 3533, 3710, 3906, 4123, 4367, 4640, 4950, 5304, 5713, 6190, 6753, 7429, 8255, 9287, 10615, 12384, 14862, 18578, 24771, 32767/2, 32767/2, 32767/2

init_tangens:

    lda #<tangens
    sta LOAD_ADDRESS
    lda #>tangens
    sta LOAD_ADDRESS+1
    
    ldx #0
next_tangens_value_first_part:
    ldy #0
    lda (LOAD_ADDRESS),y
    sta TANGENS_LOW, x
    
    ldy #1
    lda (LOAD_ADDRESS),y
    sta TANGENS_HIGH, x
    
    inx
    beq done_tangens_first_part
    
    inc LOAD_ADDRESS
    bne incemented_load_address_once_first
    inc LOAD_ADDRESS+1
incemented_load_address_once_first:
    inc LOAD_ADDRESS
    bne incemented_load_address_twice_first
    inc LOAD_ADDRESS+1
incemented_load_address_twice_first:
    bra next_tangens_value_first_part
    
done_tangens_first_part:
    
    lda #<(tangens+512)
    sta LOAD_ADDRESS
    lda #>(tangens+512)
    sta LOAD_ADDRESS+1
    
    ldx #0
next_tangens_value_last_part:
    ldy #0
    lda (LOAD_ADDRESS),y
    sta TANGENS_LOW+256, x
    
    ldy #1
    lda (LOAD_ADDRESS),y
    sta TANGENS_HIGH+256, x
    
    inx
    cpx #(456-256)
    beq done_tangens_last_part
    
    inc LOAD_ADDRESS
    bne incemented_load_address_once_last
    inc LOAD_ADDRESS+1
incemented_load_address_once_last:
    inc LOAD_ADDRESS
    bne incemented_load_address_twice_last
    inc LOAD_ADDRESS+1
incemented_load_address_twice_last:
    bra next_tangens_value_last_part
    
done_tangens_last_part:

    rts
    
; https://codebase64.org/doku.php?id=base:24bit_division_24-bit_result

divide_24bits:
    phx
    phy

	lda #0	        ; preset REMAINDER to 0
	sta REMAINDER
	sta REMAINDER+1
	sta REMAINDER+2
	ldx #24	        ; repeat for each bit: ...

divloop:
	asl DIVIDEND	; DIVIDEND lb & hb*2, msb -> Carry
	rol DIVIDEND+1	
	rol DIVIDEND+2
	rol REMAINDER	; REMAINDER lb & hb * 2 + msb from carry
	rol REMAINDER+1
	rol REMAINDER+2
	lda REMAINDER
	sec
	sbc DIVISOR	    ; substract DIVISOR to see if it fits in
	tay	            ; lb result -> Y, for we may need it later
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

    