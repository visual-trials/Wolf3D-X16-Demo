
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

; $2C-34 available

HALF_WALL_HEIGHT_INCREMENT= $35 ; 36
; $37 is free
COLUMN_HALF_WALL_HEIGHT   = $38 ; 39
; $3A is free
ANGLE_INDEX               = $3B ; 3C
ANGLE_INDEX_NEGATED       = $3D ; 3E

PALETTE_COLOR_OFFSET      = $3F       ; TODO: Only used during palette loading

NORMAL_DISTANCE_TO_WALL   = $40 ; 41  ; the normal distance of the player to the wall (length of the line 90 degress out of the wall to the player)
FROM_ANGLE                = $42 ; 43  ; the angle index of the left side of the wall we want to draw (angle relative to the normal line out of the wall to the player)
TO_ANGLE                  = $44 ; 45  ; the angle index of the right side of the wall we want to draw (angle relative to the normal line out of the wall to the player)
SCREEN_START_ANGLE        = $46 ; 47  ; the angle index of the very first column on the screen, its left side (angle relative to the normal line out of the wall to the player)
FROM_HALF_WALL_HEIGHT     = $48       ; the height of the left side of the wall 
TO_HALF_WALL_HEIGHT       = $49       ; the height of the right side of the wall
WALL_HEIGHT_INCREASES     = $4A       ; equal to 1 if wall height goes from small to large, equal to 0 if it goes from large to small 
START_SCREEN_X            = $4B ; 4C  ; the x-position of the wall starting on screen

TEXTURE_COLUMN_OFFSET     = $4D
TEXTURE_INDEX_OFFSET      = $4E

; $4f available

PLAYER_POS_X              = $50 ; 51  ; x-position of the player (8.8 bits)
PLAYER_POS_Y              = $52 ; 53  ; y-position of the player (8.8 bits)
VIEWPOINT_X               = $54 ; 55  ; x-position of the player (8.8 bits)
VIEWPOINT_Y               = $56 ; 57  ; y-position of the player (8.8 bits)
LOOKING_DIR_ANGLE         = $58 ; 59  ; looking direction of the player (0-1823)
LOOKING_DIR_QUANDRANT     = $5A       ; Two bits: 00 = q0 (ne), 01 = q1 (se), 11 = q2 (sw), 10 = q3 (nw) -> this way you can easely check if something is in a different quadrant horizontally or vertically
LOOKING_DIR_SINE          = $5B ; 5C
LOOKING_DIR_COSINE        = $5D ; 5E

CURRENT_WALL_INDEX        = $5F
WALL_START_X              = $60       ; x-coordinate of start of wall
WALL_START_Y              = $61       ; y-coordinate of start of wall)
WALL_END_X                = $62       ; x-coordinate of end of wall)
WALL_END_Y                = $63       ; y-coordinate of end of wall)
WALL_FACING_DIR           = $64       ; facing direction of the wall: 0 = north, 1 = east, 2 = south, 3 = west
WALL_POSITION_IN_TILE     = $65       ; 128 for a door, 0 is normal wall
WALL_INFO_TEXTURE_INDEXES = $66 ; 67  ; address of the place containing the texture indexes of a wall)

QUADRANT_CORRECTION       = $68
FLIP_TAN_ANGLE            = $69
DELTA_X                   = $6A ; 6B
DELTA_Y                   = $6C ; 6D
FROM_SCREEN_ANGLE         = $6E ; 6F
TO_SCREEN_ANGLE           = $70 ; 71

NR_OF_OCCLUDERS           = $72       ; the number of occluders in the linked list (to know which index to use when creating a new occluder)
CURRENT_OCCLUDER_INDEX    = $73
PREVIOUS_OCCLUDER_INDEX   = $74

FROM_SCREEN_ANGLE_PART    = $75 ; 76
TO_SCREEN_ANGLE_PART      = $77 ; 78

FROM_QUADRANT             = $79       ; Two bits: 00 = q0 (ne), 01 = q1 (se), 11 = q2 (sw), 10 = q3 (nw) 
TO_QUADRANT               = $7A       ; Two bits: 00 = q0 (ne), 01 = q1 (se), 11 = q2 (sw), 10 = q3 (nw) 
DISTANCE_DUE_TO_DELTA_X   = $7B ; 7C  ; The distance along the looking direction due to DELTA_X 
DISTANCE_DUE_TO_DELTA_Y   = $7D ; 7E  ; The distance along the looking direction due to DELTA_Y 
; FIXME: not only do we need to have variable for knowing when to negate from and to points, but also after walls have been cut-off, these points also need their distance be calculated. So we need a different solution.
NEGATE_COSINE_RESULT_FROM = $7F       ; This indicates whether we have to negate the result from cosine (FROM)
NEGATE_SINE_RESULT_FROM   = $80       ; This indicates whether we have to negate the result from sine (FROM)
NEGATE_COSINE_RESULT_TO   = $81       ; This indicates whether we have to negate the result from cosine (TO)
NEGATE_SINE_RESULT_TO     = $82       ; This indicates whether we have to negate the result from sine (TO)
; FIXME: we want to get rid of these, but for now this is helpful
FROM_DELTA_X              = $83 ; 84
FROM_DELTA_Y              = $85 ; 86
TO_DELTA_X                = $87 ; 88
TO_DELTA_Y                = $89 ; 8A
FROM_DISTANCE             = $8B ; 8C
TO_DISTANCE               = $8D ; 8E

FROM_ANGLE_NEEDS_RECALC   = $8F
TO_ANGLE_NEEDS_RECALC     = $90

WALL_LENGTH               = $91

; Used only by (slow) 16bit multiplier (multply_16bits)
MULTIPLIER                = $EF ; F0
MULTIPLICAND              = $F1 ; F2
PRODUCT                   = $F3 ; F4 ; F5 ; F6

; Used by the 16bit and 24 dividers
DIVIDEND                  = $F7 ; F8 ; F9  ; the thing you want to divide (e.g. 100 /) . This will also the result after the division
DIVISOR                   = $FA ; FB ; FC  ; the thing you divide by (e.g. / 10)
REMAINDER                 = $FD ; FE ; FF

; === VRAM addresses ===

TEXTURE_DATA             = $13000
TILE_MAP                 = $1B000   ; TODO: constant is not used
TILE_DATA                = $1F000   ; TODO: constant is not used
ELAPSED_TIME_SPRITE_VRAM = $1F800   ; We put this sprite data in $1F800 (right after the tile data (petscii characters)

; === RAM addresses ===

WALL_INFO_START_X        = $6000    ; 256 bytes (x-coordinate of start of wall)
WALL_INFO_START_Y        = $6100    ; 256 bytes (y-coordinate of start of wall)
WALL_INFO_END_X          = $6200    ; 256 bytes (x-coordinate of end of wall)
WALL_INFO_END_Y          = $6300    ; 256 bytes (y-coordinate of end of wall)
WALL_INFO_FACING_DIR     = $6400    ; 256 bytes (facing direction of the wall: 0 = north, 1 = east, 2 = south, 3 = west (bit 2 = 1 means this is a door)
WALL_INFO_TEXTURE_LOW    = $6500    ; 256 bytes (low byte of the addres containing the texture indexes)
WALL_INFO_TEXTURE_HIGH   = $6600    ; 256 bytes (low byte of the addres containing the texture indexes)

COPY_TEXTURE_TO_VRAM     = $6700    ; routine that must be run in RAM, because it switches the ROM bank
COPY_PALLETE_TO_VRAM     = $6800    ; routine that must be run in RAM, because it switches the ROM bank
GENERATE_MULT_TABLES     = $6900    ; routine that must be run in RAM: generate_multiplication_tables
MULT_WITH_NORMAL_DISTANCE= $6A00    ; routine that must be run in RAM: multply_with_normal_distance_16bits
MULT_WITH_LOOK_DIR_SINE  = $6B00    ; routine that must be run in RAM: multply_with_looking_dir_sine_16bits
MULT_WITH_LOOK_DIR_COSINE= $6C00    ; routine that must be run in RAM: multply_with_looking_dir_cosine_16bits

TANGENT_LOW              = $7200    ; 456 bytes (fraction)
TANGENT_HIGH             = $7400    ; 456 bytes (whole number)
SINE_LOW                 = $7600    ; 456 bytes (fraction)
SINE_HIGH                = $7800    ; 456 bytes (whole number)   ; FIXME: do we really need this (values goes to 256)
COSINE_LOW               = $7A00    ; 456 bytes (fraction)
COSINE_HIGH              = $7C00    ; 456 bytes (whole number)   ; FIXME: do we really need this (values goes to 256)

CLEAR_COLUMN_CODE        = $7E00    ; 152 * 3 bytes + 1 byte = 457 bytes

SQUARE1_LOW              = $8000    ; 512 bytes
SQUARE1_HIGH             = $8200    ; 512 bytes
SQUARE2_LOW              = $8400    ; 512 bytes
SQUARE2_HIGH             = $8600    ; 512 bytes

; FIXME: make this 48 bytes!
OCCLUDER_FROM_ANGLE_LOW  = $8800    ; 32 bytes
OCCLUDER_FROM_ANGLE_HIGH = $8820    ; 32 bytes
OCCLUDER_TO_ANGLE_LOW    = $8840    ; 32 bytes
OCCLUDER_TO_ANGLE_HIGH   = $8860    ; 32 bytes
OCCLUDER_NEXT            = $8880    ; 32 bytes


DRAW_COLUMN_CODE         = $A000    ; 152 * 3 bytes + 64 * 3 bytes + 1 byte = 649 bytes for each wall height (512 wall heights)


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
    
    jsr copy_multipliers_to_ram   ; this must be run *before* GENERATE_MULT_TABLES!
    jsr GENERATE_MULT_TABLES
    
    jsr generate_clear_column_code
    jsr generate_draw_column_code
    
    jsr setup_player
    jsr setup_wall_info
    
    jsr clear_3d_view_fast
    
    bra do_not_turn_around
    
keep_turning_around:  
    lda #0
    sta LOOKING_DIR_ANGLE
    sta LOOKING_DIR_ANGLE+1
    
turn_around:
    jsr update_viewpoint
    jsr draw_3d_view
    inc LOOKING_DIR_ANGLE
    ;nop                      ; WEIRD FIXME!! if i have two nops here, its DOESNT work anymore on real HW! -> it it SOMETIMES draws a few columns!! (or 3 walls) -> if you try enough times, it starts to work?!!?
    ;nop                      ; ALSO: if i remove loading one of the textures, it also work! 
    ; lda LOOKING_DIR_ANGLE        ; WEIRD FIXME!! if I remove this the HW works, but if I leave the lda in place, it crashes? (stays red)
    bne turn_around

    inc LOOKING_DIR_ANGLE+1
    lda LOOKING_DIR_ANGLE+1
    cmp #$7                ; $720 = 1824
    bcc turn_around
    
turn_around2:    
    jsr update_viewpoint
    jsr draw_3d_view
    inc LOOKING_DIR_ANGLE
    lda LOOKING_DIR_ANGLE
    cmp #$20
    bne turn_around2
    
    bra keep_turning_around

stop_turning:
    jmp stop_turning

do_not_turn_around:



    ; bra do_not_move_forward
    
keep_moving_forward:
    lda #0
    sta PLAYER_POS_Y
    lda #1
    sta PLAYER_POS_Y+1
    
move_forward:
    jsr update_viewpoint
    jsr draw_3d_view
    inc PLAYER_POS_Y
    inc PLAYER_POS_Y
    inc PLAYER_POS_Y
    inc PLAYER_POS_Y
    bne move_forward

    inc PLAYER_POS_Y+1
    lda PLAYER_POS_Y+1
    cmp #$4
    bcc move_forward
    
    bra keep_moving_forward

stop_moving:
    jmp stop_moving

do_not_move_forward:



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
    .include math.s
    .include init3d.s
    .include draw_wall_part.s
    .include draw_wall.s
    .include draw3d.s
  
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

    ; === Texture files ===
    
    ; FIXME: these texture file use an old type of file (with 2 extra bytes in front and with specific palette bytes). 

    ; ROM Bank 1
    .align 14        ; This is to make sure the data wont covert two ROM banks
blue_stone_1_texture:
    .binary "assets/BLUESTONE1_OLD.BIN"
    
blue_stone_2_texture:
    .binary "assets/BLUESTONE2_OLD.BIN"
    
closed_door_texture:
    .binary "assets/CLOSEDDOOR_OLD.BIN"
    
