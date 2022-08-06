
; Print margins
MARGIN          = 0
INDENT_SIZE     = 2

; Colors
COLOR_NORMAL       = $01 ; Background color = 0 (no color), foreground color 1 (white)

move_cursor_to_next_line:
    pha

    lda INDENTATION
    sta CURSOR_X
    inc CURSOR_Y

    pla
    rts

setup_cursor:
    lda #%00010001           ; Setting bit 16 of vram address to the highest bit in the tilebase (=1), setting auto-increment value to 1
    sta VERA_ADDR_BANK
    lda #$B0
    clc
    adc CURSOR_Y             ; this assumes TILE_MAP_WIDTH = 128 (and each tile takes 2 bytes, so we add $100 for each Y)
    sta VERA_ADDR_HIGH
    lda CURSOR_X
    asl                      ; each tile takes to bytes, so we shift to the left once
    sta VERA_ADDR_LOW
    rts


; -- Prints a zero-terminated string
;
; TEXT_TO_PRINT : address containing the ASCII text to print
; TEXT_COLOR : two nibbles containing the background and foreground color of the text
; CURSOR_X : the x-position of the cursor to start printing
; CURSOR_Y : the y-position of the cursor to start printing (assuming TILE_MAP_WIDTH = 128)
;
print_text_zero:
    pha
    tya
    pha

    jsr setup_cursor

    ldy #0
print_next_char:
    lda (TEXT_TO_PRINT), y
    beq done_print_text
    cmp #97  ; 'a'
    bpl char_larger_than_or_equal_to_a
char_smaller_than_a:            
    cmp #65  ; 'A'
    bpl char_between_A_and_a
    ; This part is roughly the same between ASCII and PETSCII
    jmp char_conversion_done
char_between_A_and_a:           ; Uppercase letters
    sec
    sbc #64
    jmp char_conversion_done
char_larger_than_or_equal_to_a: ; Lowercase letters
    sec
    sbc #96
    clc
    adc #128
char_conversion_done:
    iny
    sta VERA_DATA0
    lda TEXT_COLOR                 ; Background color is high nibble, foreground color is low nibble
    sta VERA_DATA0           
    jmp print_next_char
  
done_print_text:

    clc
    tya
    adc CURSOR_X
    sta CURSOR_X

    pla
    tay
    pla

    rts
    

print_byte_as_decimal:

    sta BYTE_TO_PRINT
    jsr setup_cursor
    
    lda BYTE_TO_PRINT
    
    jsr mod10
    clc
    adc #'0'
    sta DECIMAL_STRING+2
    txa
    jsr mod10
    clc
    adc #'0'
    sta DECIMAL_STRING+1
    txa
    jsr mod10
    clc
    adc #'0'
    sta DECIMAL_STRING
    
    lda BYTE_TO_PRINT
    cmp #10
    bcc print_ones
    cmp #100
    bcc print_tens
    
print_hundreds:
    lda DECIMAL_STRING
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    inc CURSOR_X
print_tens:
    lda DECIMAL_STRING+1
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    inc CURSOR_X
print_ones:
    lda DECIMAL_STRING+2
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    inc CURSOR_X
    
    rts
    
    
; modulus 10 a byte
; Input
;   a : byte to do modulus once
; Result
;   a : a % 10
;   x : a / 10
mod10:
    ; TODO: This is not a good way of doing a mod10, make it better someday
    sta TMP2

    ; Divide by 10 ( from: https://codebase64.org/doku.php?id=base:8bit_divide_by_constant_8bit_result )
    lsr
    sta  TMP1
    lsr
    adc  TMP1
    ror
    lsr
    lsr
    adc  TMP1
    ror
    adc  TMP1
    ror
    lsr
    lsr
    
    sta TMP1  ; number divided by 10 is in TMP1
    tax      ; a = a / 10
    
    ; We multiply the divided number by 10 again
    
    asl
    asl
    asl      ; * 8
    asl TMP1 ; * 2
    clc
    adc TMP1 ; a * 8 + a * 2 = a * 10
    sta TMP1
    
    lda TMP2
    sec
    sbc TMP1 ; a - ((a / 10) * 10) = a % 10
    
    rts

    
init_timer:
    ; We reset the FIFO and configure it
    lda #%10000000  ; FIFO Reset, 8-bit, Mono, no volume
    sta VERA_AUDIO_CTRL
    
    ; We set the PCM sample rate to 0 (no sampling)
    lda #$00
    sta VERA_AUDIO_RATE
    
    ; We fill the PCM buffer with 4KB (= 16 * 256 bytes) of data

    lda #$00  ; It really doesn't matter where we fill it with
    ldy #16
fill_pcm_audio_block_with_ff:
    ldx #0
fill_pcm_audio_byte_with_ff:
    sta VERA_AUDIO_DATA
    inx
    bne fill_pcm_audio_byte_with_ff
    dey
    bne fill_pcm_audio_block_with_ff
    
    ; NOTE: we are assuming the buffer is full now
    
    rts
    
start_timer:
    
    ; NOTE: The buffer is asumed to be full and playback not running. 
    
    ; We will now start "playback" by setting a sampling rate. 
    
    ; -- Start playback
    ; Formula: frequency = 48828.125/(128/VERA_AUDIO_RATE)
    ; lda #26   ;  9918.2 Hz (fairly close to 10000Hz) 
    ; lda #27   ; 10299.7 Hz (fairly close to 10000Hz) 
    lda #42   ; 16021.7 Hz (fairly close to 16000Hz) -> divide by 16 and you get the milliseconds
    sta VERA_AUDIO_RATE
    
    rts
    
    
stop_timer:
    ; -- Stop playback
    lda #$00
    sta VERA_AUDIO_RATE
    
    ; We fill the PCM buffer again, but now we keep checking if its full: that we know how many bytes it sampled/played
    lda #0
    sta TIMING_COUNTER
    sta TIMING_COUNTER+1
    
    lda #0 ; It really doesn't matter where we fill it with
fill_pcm_audio_byte:
    sta VERA_AUDIO_DATA
    inc TIMING_COUNTER
    bne no_increment_counter_pcm
    inc TIMING_COUNTER+1    
no_increment_counter_pcm:
    lda VERA_AUDIO_CTRL
    bpl fill_pcm_audio_byte ; If bit 7 is not set the audio FIFO buffer is not full. So we repeat
    
    lda TIMING_COUNTER
    and #$0F
    sta TIME_ELAPSED_SUB_MS
    
    lda TIMING_COUNTER
    lsr
    lsr
    lsr
    lsr
    sta TIME_ELAPSED_MS
    
    ; We assume we ran at 16000Hz, so we divide by 16 and the remaining byte is the number of milliseconds elapsed
    lda TIMING_COUNTER+1
    and #$0F
    asl
    asl
    asl
    asl
    ora TIME_ELAPSED_MS
    sta TIME_ELAPSED_MS
    
    rts

sub_ms_nibble_as_decimal:
    .byte 00 ; 0/16 = 0.0
    .byte 10 ; 1/16 = 0.0625  --> FIXME: this will show up as .6!! (we have no leading zeros) -> so made this 10 for now
    .byte 13 ; 2/16 = 0.125
    .byte 19 ; 3/16 = 0.1865

    .byte 25 ; 4/16 = 0.25
    .byte 31 ; 5/16 = 0.3125
    .byte 38 ; 6/16 = 0.375
    .byte 44 ; 7/16 = 0.4375

    .byte 50 ; 8/16 = 0.5
    .byte 56 ; 9/16 = 0.5625
    .byte 63 ; 10/16 = 0.625
    .byte 69 ; 11/16 = 0.6875

    .byte 75 ; 12/16 = 0.75
    .byte 81 ; 13/16 = 0.8125
    .byte 88 ; 14/16 = 0.875
    .byte 94 ; 15/16 = 0.9375
