
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

    ; We enable VERA as soon as possible (and set it up), to give a sign of life (rom only)
    .include "utils/rom_only_setup_vera_for_tile_map.s"  

    ; Setup initial (rom only) screen and title
    .include "utils/rom_only_setup_screen.s"

    ; Test Zero Page and Stack RAM once
    .include "tests/rom_only_test_zp_and_stack_ram_once.s"
    

    ; Init cursor for printing to screen
    lda #(MARGIN+INDENT_SIZE)
    sta INDENTATION
    sta CURSOR_X
    lda #5          ; We already printed a title, a header and one line when testing Zero page and stack memory
    sta CURSOR_Y

    
loop:
    ; TODO: wait for (keyboard) input
    jmp loop

    
    ; === Included files ===
    
    .include utils/x16.s
    .include utils/utils.s
    .include utils/setup_vera_for_bitmap_and_tilemap.s
  
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
