
    
draw_3d_view_fast:


    ; Given a wall, we determine whether its to the top, left, right or bottom of the player (so horizontal/vertical and on which side). Also check if its facing the right way? Or is that a given at this point?
    ; After that we can determine the length of normal line from the wall (x or y coord) to the player
    ; We can also determine from which and to which ray index the wall extends (relative to the normal line)
    
    ; Given the direction the player is facing we can also determine what would be the screen start ray index (left most angle in the viewing area of the player, relative to the normal line)
    ; If we know what parts of the screen columns/rays have been drawn already, we can now cut-off left and right parts of the wall.
    
    ; If we have done that, we can now determine the distance from the player-plane and the left and right parts of the wall-part (using cosine)
    ; Given these two distances, we can also determine the left and right wall heights.
    
    ; We still have to determine whether the wall decreases (in height) from left to right, or the other way around and maybe do a different draw-wall-call accordingly
    
    jsr draw_wall_fast


    rts


draw_wall_fast:

    ; NORMAL_DISTANCE_TO_WALL  ; the normal distance of the player to the wall (length of the line 90 degress out of the wall to the player)
    ; FROM_RAY_INDEX           ; the ray index of the left side of the wall we want to draw (angle relative to the normal line out of the wall to the player)
    ; TO_RAY_INDEX             ; the ray index of the right side of the wall we want to draw (angle relative to the normal line out of the wall to the player)
    
    ; SCREEN_START_RAY   ; the ray index of the very first column on the screen, its left side (angle relative to the normal line out of the wall to the player)
    
    ; FROM_WALL_HEIGHT   ; the height of the left side of the wall 
    ; TO_WALL_HEIGHT     ; the height of the right side of the wall
    
    ; TODO: TEXTURE_INDEX_PER_WALL_SEGMENT?
    
    ; We first determine how much the wall height will decrease per drawn column
    
    ; FIXME: we now have hardcoded how wide the wall is going to be (in nr of rays: 304)
    ; We do the divide: WALL_HEIGHT_DECREMENT = 64 * 256 / 304;
    lda #64
    sta DIVIDEND+2
    lda #0
    sta DIVIDEND+1
    lda #0
    sta DIVIDEND
    
    lda #1            ; 1 * 256
    sta DIVISOR+2
    lda #(304-256)    ;   + 48
    sta DIVISOR+1
    lda #0
    sta DIVISOR
    
    jsr divide_24bits
    
    ; FIXME: is this mapping of +2, +1 correct? Should we shift something here?
    lda DIVIDEND+2
    sta WALL_HEIGHT_DECREMENT+2
    lda DIVIDEND+1
    sta WALL_HEIGHT_DECREMENT+1
    lda DIVIDEND
    sta WALL_HEIGHT_DECREMENT
    
    ; FIXME: hardcoded starting wall height: 128.0
    lda #0
    sta COLUMN_WALL_HEIGHT+2
    lda #128
    sta COLUMN_WALL_HEIGHT+1
    lda #0
    sta COLUMN_WALL_HEIGHT
    
    ; Left part of the screen (256-8 = 248 columns)

    ; FIXME: starting ray_index now hardcoded to 0
    lda #0
    sta RAY_INDEX
    lda #0
    sta RAY_INDEX+1
    
    ; FIXME: we now always start at the left side of the screen, but when we draw a wall it could begin somewhere in the middle of the screen!
    ldx #8   ; screen column index
    
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
    
    ; FIXME: also get TANGENS_HIGH!
    lda RAY_INDEX+1
    bne is_high_ray_index_left
is_low_ray_index_left:
    ldy RAY_INDEX
    lda TANGENS_LOW,y             ; When the ray index >= 256, we retrieve from 256 positions further
    bra got_tangens_left
is_high_ray_index_left:
    ldy RAY_INDEX
    lda TANGENS_LOW+256,y         ; When the ray index >= 256, we retrieve from 256 positions further
got_tangens_left:
    
    ; FIXME: We do a * 2.0 (normal distance from wall), then a divide by 4 (256 positions in a cell, so to go to 64 we need to divide by 4). So effectively divide by 2 here
    lsr
    and #$3F                ; we effectively do a 'mod 64'
    sta VERA_ADDR_LOW       ; We use x mod 64 as the texture-column number, so we set it as as the start byte of a column

    ; FIXME: we now use only one byte of the wall height, but we also need to check the high byte (unless we only use 256 *EVEN* wall heights)
    lda COLUMN_WALL_HEIGHT+1
    ; FIXME: ONLY USE *EVEN* WALL HEIGHTS??
    and #$FE ; make even
    sta RAM_BANK
    ; FIXME: remove this nop!
    nop

    jsr DRAW_COLUMN_CODE

    ; FIXME: currently we have a fixed decrement of the wall height. Is this (always) correct?
    sec
	lda COLUMN_WALL_HEIGHT
	sbc WALL_HEIGHT_DECREMENT
	sta COLUMN_WALL_HEIGHT
	lda COLUMN_WALL_HEIGHT+1
	sbc WALL_HEIGHT_DECREMENT+1
	sta COLUMN_WALL_HEIGHT+1
	lda COLUMN_WALL_HEIGHT+2
	sbc WALL_HEIGHT_DECREMENT+2
	sta COLUMN_WALL_HEIGHT+2
    
    inc RAY_INDEX
    bne ray_index_updated_left
    inc RAY_INDEX+1
ray_index_updated_left:
    
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
    
    ; FIXME: also get TANGENS_HIGH!
    lda RAY_INDEX+1
    bne is_high_ray_index_right   
is_low_ray_index_right:
    ldy RAY_INDEX
    lda TANGENS_LOW,y             ; When the ray index >= 256, we retrieve from 256 positions further
    bra got_tangens_right
is_high_ray_index_right:
    ldy RAY_INDEX
    lda TANGENS_LOW+256,y         ; When the ray index >= 256, we retrieve from 256 positions further
got_tangens_right:
    ; FIXME: We do a * 2.0 (normal distance from wall), then a divide by 4 (256 positions in a cell, so to go to 64 we need to divide by 4). So effectively divide by 2 here
    lsr
    and #$3F                ; we effectively do a 'mod 64'
    sta VERA_ADDR_LOW       ; We use x mod 64 as the texture-column number, so we set it as as the start byte of a column

    ; FIXME: we now use only one byte of the wall height, but we also need to check the high byte (unless we only use 256 *EVEN* wall heights)
    lda COLUMN_WALL_HEIGHT+1
    ; FIXME: ONLY USE *EVEN* WALL HEIGHTS??
    and #$FE ; make even
    sta RAM_BANK
    ; FIXME: remove this nop!
    nop
    
    jsr DRAW_COLUMN_CODE
    
    ; FIXME: currently we have a fixed decrement of the wall height. Is this (always) correct?
    sec
	lda COLUMN_WALL_HEIGHT
	sbc WALL_HEIGHT_DECREMENT
	sta COLUMN_WALL_HEIGHT
	lda COLUMN_WALL_HEIGHT+1
	sbc WALL_HEIGHT_DECREMENT+1
	sta COLUMN_WALL_HEIGHT+1
	lda COLUMN_WALL_HEIGHT+2
	sbc WALL_HEIGHT_DECREMENT+2
	sta COLUMN_WALL_HEIGHT+2
    
    inc RAY_INDEX
    bne ray_index_updated_right
    inc RAY_INDEX+1
ray_index_updated_right:

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
