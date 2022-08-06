
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
    
    jsr print_testing
    

    
loop:
    ; TODO: wait for (keyboard) input
    jmp loop

    
; FIXME: put this somewhere else!    
print_testing:    
    
    lda #COLOR_NORMAL
    sta TEXT_COLOR
    
    lda #<testing_message
    sta TEXT_TO_PRINT
    lda #>testing_message
    sta TEXT_TO_PRINT + 1
    
    jsr print_text_zero
    
    rts

    
    ; === Included files ===
    
    .include utils/x16.s
    .include utils/utils.s
    .include utils/setup_vera_for_bitmap_and_tilemap.s
  
  
testing_message: 
    .asciiz "Testing blit performance..."
  
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
