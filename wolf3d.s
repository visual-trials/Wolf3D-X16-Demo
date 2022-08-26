
; ===========================
; ===== Wolf3D X16 Demo =====
; ===========================


; IMPORTANT NOTE: right now this demo runs as a ROM and not as an PRG.


; == Zero page addresses

; Bank switching
RAM_BANK                  = $00
ROM_BANK                  = $01

; Temp vars
TMP1                      = $02
TMP2                      = $03
TMP3                      = $04
TMP4                      = $05

; Printing
TEXT_TO_PRINT             = $06 ; 07
TEXT_COLOR                = $08
CURSOR_X                  = $09
CURSOR_Y                  = $0A
INDENTATION               = $0B
BYTE_TO_PRINT             = $0C
DECIMAL_STRING            = $0D ; 0E ; 0F

TIMING_COUNTER            = $10 ; 11
TIME_ELAPSED_MS           = $12
TIME_ELAPSED_SUB_MS       = $13 ; one nibble of sub-milliseconds

LOAD_ADDRESS              = $14 ; 15
VRAM_ADDRESS              = $16 ; 17 ; only two bytes, because bit 16 is assumed to be 1
CODE_ADDRESS              = $18 ; 18 ; TODO: this can probably share the address of LOAD_ADDRESS
NR_OF_PALETTE_BYTES       = $1A

; Used for draw column code generation (can be re-used after code has been generated)
TEXTURE_INCREMENT         = $20 ; 21 ; 22
TEXTURE_CURSOR            = $23 ; 24 ; 25
PREVIOUS_TEXTURE_CURSOR   = $26
CURRENT_WALL_HEIGHT       = $27 ; 28
VIRTUAL_SCREEN_CURSOR     = $29
TOP_HALF_WALL_HEIGHT      = $2A
BOTTOM_HALF_WALL_HEIGHT   = $2B

DIVIDEND                  = $2C ; 2D ; 2E  ; the thing you want to divide (e.g. 100 /) . This will also the result after the division
DIVISOR                   = $2F ; 30 ; 31  ; the thing you divide by (e.g. / 10)
REMAINDER                 = $32 ; 33 ; 34

WALL_HEIGHT_INCREMENT     = $35 ; 35 ; 37
COLUMN_WALL_HEIGHT        = $38 ; 39 ; 3A
RAY_INDEX                 = $3B ; 3C
RAY_INDEX_NEGATED         = $3D ; 3E

PALETTE_COLOR_OFFSET      = $3F       ; TODO: Only used during palette loading

NORMAL_DISTANCE_TO_WALL   = $40 ; 41  ; the normal distance of the player to the wall (length of the line 90 degress out of the wall to the player)
FROM_RAY_INDEX            = $42 ; 43  ; the ray index of the left side of the wall we want to draw (angle relative to the normal line out of the wall to the player)
TO_RAY_INDEX              = $44 ; 45  ; the ray index of the right side of the wall we want to draw (angle relative to the normal line out of the wall to the player)
SCREEN_START_RAY          = $46 ; 47  ; the ray index of the very first column on the screen, its left side (angle relative to the normal line out of the wall to the player)
FROM_WALL_HEIGHT          = $48 ; 49  ; the height of the left side of the wall 
TO_WALL_HEIGHT            = $4A ; 4B  ; the height of the right side of the wall
WALL_HEIGHT_INCREASES     = $4C       ; equal to 1 if wall height goes from small to large, equal to 0 if it goes from large to small 
START_SCREEN_X            = $4D ; 4E  ; the x-position of the wall starting on screen

; FIXME: *use* PLAYER_POS_X/Y
PLAYER_POS_X              = $51 ; 52  ; x-position of the player (8.8 bits)
PLAYER_POS_Y              = $53 ; 54  ; y-position of the player (8.8 bits)
VIEWPOINT_X               = $55 ; 56  ; x-position of the player (8.8 bits)
VIEWPOINT_Y               = $57 ; 58  ; y-position of the player (8.8 bits)
LOOKING_DIR               = $59 ; 5A  ; looking direction of the player (0-1823)
LOOKING_DIR_QUANDRANT     = $5B       ; Two bits: 00 = q0 (ne), 01 = q1 (se), 11 = q2 (sw), 10 = q3 (nw) -> this way you can easely check if something is in a different quadrant horizontally or vertically
LOOKING_DIR_SINE          = $5C ; 5D
LOOKING_DIR_COSINE        = $5E ; 5F

CURRENT_WALL_INDEX        = $60
WALL_START_X              = $61       ; x-coordinate of start of wall
WALL_START_Y              = $62       ; y-coordinate of start of wall)
WALL_END_X                = $63       ; x-coordinate of end of wall)
WALL_END_Y                = $64       ; y-coordinate of end of wall)
WALL_FACING_DIR           = $65       ; facing direction of the wall: 0 = north, 1 = east, 2 = south, 3 = west

QUADRANT_CORRECTION       = $68
FLIP_TAN_ANGLE            = $69
DELTA_X                   = $6A ; 6B
DELTA_Y                   = $6C ; 6D
TESTING_RAY_INDEX         = $6E ; 6F

; Used only by (slow) 16bit multiplier (multply_16bits)
MULTIPLIER                = $70 ; 71
MULTIPLICAND              = $72 ; 73
PRODUCT                   = $74 ; 75 ; 76 ; 77

FROM_QUADRANT             = $78       ; Two bits: 00 = q0 (ne), 01 = q1 (se), 11 = q2 (sw), 10 = q3 (nw) 
TO_QUADRANT               = $79       ; Two bits: 00 = q0 (ne), 01 = q1 (se), 11 = q2 (sw), 10 = q3 (nw) 
DISTANCE_DUE_TO_DELTA_X   = $7A ; 7B  ; The distance along the looking direction due to DELTA_X 
DISTANCE_DUE_TO_DELTA_Y   = $7C ; 7D  ; The distance along the looking direction due to DELTA_Y 
; FIXME: not only do we need to have variable for knowing when to negate from and to points, but also after walls have been cut-off, these points also need their distance be calculated. So we need a different solution.
NEGATE_COSINE_RESULT_FROM = $7E       ; This indicates whether we have to negate the result from cosine (FROM)
NEGATE_SINE_RESULT_FROM   = $7F       ; This indicates whether we have to negate the result from sine (FROM)
NEGATE_COSINE_RESULT_TO   = $80       ; This indicates whether we have to negate the result from cosine (TO)
NEGATE_SINE_RESULT_TO     = $81       ; This indicates whether we have to negate the result from sine (TO)
; FIXME: we want to get rid of these, but for now this is helpful
FROM_DELTA_X              = $82 ; 83
FROM_DELTA_Y              = $84 ; 85
TO_DELTA_X                = $86 ; 87
TO_DELTA_Y                = $88 ; 89
FROM_DISTANCE             = $8A ; 8B
TO_DISTANCE               = $8C ; 8D

; === VRAM addresses ===

TEXTURE_DATA             = $13000
TILE_MAP                 = $1B000   ; TODO: constant is not used
TILE_DATA                = $1F000   ; TODO: constant is not used
ELAPSED_TIME_SPRITE_VRAM = $1F800   ; We put this sprite data in $1F800 (right after the tile data (petscii characters)

; === RAM addresses ===

TANGENT_LOW              = $7200    ; 456 bytes (fraction)
TANGENT_HIGH             = $7400    ; 456 bytes (whole number)
SINE_LOW                 = $7600    ; 456 bytes (fraction)
SINE_HIGH                = $7800    ; 456 bytes (whole number)   ; FIXME: do we really need this (values goes to 256)
COSINE_LOW               = $7A00    ; 456 bytes (fraction)
COSINE_HIGH              = $7C00    ; 456 bytes (whole number)   ; FIXME: do we really need this (values goes to 256)

CLEAR_COLUMN_CODE        = $7E00    ; 152 * 3 bytes + 1 byte = 457 bytes
DRAW_COLUMN_CODE         = $A000    ; 152 * 3 bytes + 64 * 3 bytes + 1 byte = 649 bytes for each wall height (512 wall heights)

WALL_INFO_START_X        = $6000    ; 256 bytes (x-coordinate of start of wall)
WALL_INFO_START_Y        = $6100    ; 256 bytes (y-coordinate of start of wall)
WALL_INFO_END_X          = $6200    ; 256 bytes (x-coordinate of end of wall)
WALL_INFO_END_Y          = $6300    ; 256 bytes (y-coordinate of end of wall)
WALL_INFO_FACING_DIR     = $6400    ; 256 bytes (facing direction of the wall: 0 = north, 1 = east, 2 = south, 3 = west

COPY_TEXTURE_TO_VRAM     = $6500    ; routine that must be run in RAM, because it switches the ROM bank
COPY_PALLETE_TO_VRAM     = $6600    ; routine that must be run in RAM, because it switches the ROM bank



    ; Info on Wolfenstein3D engine: https://fabiensanglard.net/gebbwolf3d.pdf
    ; Info on Doom (classic) renderer: https://fabiensanglard.net/doomIphone/doomClassicRenderer.php
    ; Some more helpful info on raycasting: https://lodev.org/cgtutor/raycasting.html  (note: we are not casting rays in this engine!)


    .org $C000

reset:
    ; Disable interrupts 
    sei
    
    ; Setup stack
    ldx #$ff
    txs
    
    jsr setup_vera_for_bitmap_and_tile_map
    jsr copy_petscii_charset
    jsr clear_tilemap_screen
    jsr init_cursor
    
    jsr clear_bitmap_screen
    jsr clear_sprite_data
    
    jsr init_timer
    ; jsr init_elapsed_time_sprite

    ; FIXME: this loading from ROM banks wont work for more than 16kb since we would have to switch the ROM bank for that!
    jsr load_textures_into_vram
    
    ; Drawing 3D View
    
    jsr init_tangent
    jsr init_sine
    jsr init_cosine
    
    jsr generate_clear_column_code
    jsr generate_draw_column_code
    
    jsr setup_player
    jsr setup_wall_info
    
    jsr clear_3d_view_fast
    
    bra do_not_turn_around
    
keep_turning_around:  
    lda #0
    sta LOOKING_DIR
    sta LOOKING_DIR+1
    
turn_around:
    jsr update_viewpoint
    jsr draw_3d_view
    inc LOOKING_DIR
    lda LOOKING_DIR
    bne turn_around

    inc LOOKING_DIR+1
    lda LOOKING_DIR+1
    cmp #$7                ; $720 = 1824
    bcc turn_around
    
turn_around2:    
    jsr update_viewpoint
    jsr draw_3d_view
    inc LOOKING_DIR
    lda LOOKING_DIR
    cmp #$20
    bne turn_around2
    
    bra keep_turning_around

stop_turning:
    jmp stop_turning

do_not_turn_around:

    ; jmp vsync_measurement
    
loop2:
    jsr start_timer
    
    jsr update_viewpoint
    jsr draw_3d_view
    
    jsr stop_timer
    
; FIXME:
    lda #9
    sta CURSOR_X
    lda #24
    sta CURSOR_Y
    
    
    jsr print_time_elapsed
    ; jsr position_elapsed_time_sprite
    ; TODO: maybe draw a horizontal bar instead?

tmp_loop:
    jmp tmp_loop
    
    jmp loop2
    
loop:
    ; TODO: wait for (keyboard) input
    jmp loop

    
vsync_measurement:    
    lda #%00000111 ; ACK any existing IRQs in VERA
    sta VERA_ISR
    
    lda #%00000001  ; enable only v-sync irq
    sta VERA_IEN
    
    jsr start_timer
    
wait_for_vsync:

    lda VERA_ISR
    and #%00000001
    beq wait_for_vsync
    
    jsr stop_timer
    jsr start_timer
    
    jsr print_time_elapsed
    ; jsr position_elapsed_time_sprite
    ; TODO: maybe draw a horizontal bar instead?
    
    
    lda #%00000111 ; ACK any existing IRQs in VERA
    sta VERA_ISR
    
    lda TIMING_COUNTER
    lda TIMING_COUNTER+1
    
    jmp wait_for_vsync
    
    ; no jsr needed here
    

    
    ; === Included files ===
    
    .include utils/x16.s
    .include utils/utils.s
    .include utils/timing.s
    .include utils/setup_vera_for_bitmap_and_tilemap.s
    .include init3d.s
    .include draw3d.s
  
    ; === Texture files ===
    
    ; FIXME: this uses an old file (with 2 extra bytes in front and with specific palette bytes). 
    ; Starting at E5FE because we want it to begin at E600, but we ignore the 2 extra bytes.
 ;   .org $E5FE
 ;   .binary "assets/BLUESTONE1_OLD.BIN"
  
    ; ======== PETSCII CHARSET =======

    .org $F700
    .include "utils/petscii.s"

    ; ======== NMI / IRQ =======
nmi:
    ; TODO: implement this
    ; FIXME: ugly hack!
    jmp reset
    rti
   
irq:
    rti


    .org $fffa
    .word nmi
    .word reset
    .word irq

    ; ROM Bank 1
    .align 14        ; This is to make sure the data wont covert two ROM banks
blue_stone_1_texture:
    .binary "assets/BLUESTONE1_OLD.BIN"
    
closed_door_texture:
    .binary "assets/CLOSEDDOOR_OLD.BIN"
    
