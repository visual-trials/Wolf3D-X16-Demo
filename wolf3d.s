
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

WALL_HEIGHT_DECREMENT     = $35 ; 35 ; 37
COLUMN_WALL_HEIGHT        = $38 ; 39 ; 3A
RAY_INDEX                 = $3B ; 3C

; === VRAM addresses ===

TEXTURE_DATA             = $13000
TILE_MAP                 = $1B000   ; TODO: constant is not used
TILE_DATA                = $1F000   ; TODO: constant is not used
ELAPSED_TIME_SPRITE_VRAM = $1F800   ; We put this sprite data in $1F800 (right after the tile data (petscii characters)

; === RAM addresses ===

TANGENS_LOW              = $7A00    ; 456 bytes (fraction)
TANGENS_HIGH             = $7C00    ; 456 bytes (whole number)
CLEAR_COLUMN_CODE        = $7E00    ; 152 * 3 bytes + 1 byte = 457 bytes
DRAW_COLUMN_CODE         = $A000    ; 152 * 3 bytes + 64 * 3 bytes + 1 byte = 649 bytes for each wall height (512 wall heights_


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
    
    

    ; Texture pixels
    lda #$00
    sta LOAD_ADDRESS
    lda #$E6
    sta LOAD_ADDRESS+1
    
    lda #<TEXTURE_DATA
    sta VRAM_ADDRESS
    lda #>TEXTURE_DATA
    sta VRAM_ADDRESS+1
    
    jsr copy_texture_to_vram
    
    ; Texture palette
    lda #$01             ; palette starts at 4096 + 1 bytes from texture data
    sta LOAD_ADDRESS
    lda #$F6             ; palette starts at 4096 + 1 bytes from texture data
    sta LOAD_ADDRESS+1
    
    lda $F600            ; this is the byte containing the number of palette bytes
    sta NR_OF_PALETTE_BYTES
    
    jsr copy_palette_to_vram
    
    
    ; Drawing 3D View
    
    jsr init_tangens
    jsr generate_clear_column_code
    jsr generate_draw_column_code
    
    jsr clear_3d_view_fast
    jsr draw_3d_view_fast
    
    ; jmp vsync_measurement
    
loop2:
    jsr start_timer
    jsr draw_3d_view_fast
    ;jsr clear_3d_view_fast
    ;jsr clear_bitmap_screen
    ;jsr copy_petscii_charset
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
    .org $E5FE
    .binary "assets/BLUESTONE1_OLD.BIN"
  
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
