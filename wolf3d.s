
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
    
    jsr init_timer
    
    jmp vsync_measurement
    
loop2:
    jsr start_timer
    jsr clear_bitmap_screen
    ;jsr copy_petscii_charset
    jsr stop_timer
    
    ; FIXME: intead of printing, put a sprite at a corresponding x-pixel position on the screen. This sprit may be a 'dot' inside a 'tube'. Add vertical bars for showing 16ms/33ms etc.
    
    jsr print_time_elapsed
    jmp loop2
    
loop:
    ; TODO: wait for (keyboard) input
    jmp loop


    
; FIXME: where to put this?
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
    
    
    lda #%00000111 ; ACK any existing IRQs in VERA
    sta VERA_ISR
    
    lda TIMING_COUNTER
    lda TIMING_COUNTER+1
    
    jmp wait_for_vsync
    
    
    
    
; FIXME: put this somewhere else!    
print_time_elapsed:
    
    lda #COLOR_NORMAL
    sta TEXT_COLOR
    
    lda #<time_elapsed_message
    sta TEXT_TO_PRINT
    lda #>time_elapsed_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero

    lda TIME_ELAPSED_MS
    sta BYTE_TO_PRINT
    jsr print_byte_as_decimal
    
    lda #'.'
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    inc CURSOR_X
    
    lda TIME_ELAPSED_SUB_MS
    tax
    lda sub_ms_nibble_as_decimal, x
    sta BYTE_TO_PRINT
    jsr print_byte_as_decimal
    
    ; TODO: we should create a generic linefeed-routine
;    lda INDENTATION
;    sta CURSOR_X

    lda #<time_elapsed_ms_message
    sta TEXT_TO_PRINT
    lda #>time_elapsed_ms_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    jsr move_cursor_to_next_line
    
    ; FIXME: check if Y is equal to MAX lines!?!
    lda CURSOR_Y
    cmp #TILE_MAP_HEIGHT/2       ; FIXME: we should change the TILE_MAP_HEIGHT to 25/32?
    ; bne cursor_y_ok
    beq loop ; We currently stop it we reach the end

    ; FIXME: Resetting to line 0 for now, should we scroll instead?
;    lda #0
;    sta CURSOR_Y
    
cursor_y_ok:
    
    rts

    
    ; === Included files ===
    
    .include utils/x16.s
    .include utils/utils.s
    .include utils/setup_vera_for_bitmap_and_tilemap.s
  
  
time_elapsed_message: 
    .asciiz "Time elapsed... "
time_elapsed_ms_message: 
    .asciiz " ms  "
  
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
