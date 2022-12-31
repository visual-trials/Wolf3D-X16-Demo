
; Print margins
TOP_MARGIN      = 20
LEFT_MARGIN     = 2
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
    
; Input: WORD_TO_PRINT (as 8.8 bit fixed point number)
print_fixed_point_word_as_decimal_fraction:

    ; First we print the whole number part of the 8.8 bit fixed point number
    lda WORD_TO_PRINT+1
    jsr print_byte_as_decimal
    
    ; We then print the period
    jsr setup_cursor
    lda #'.'
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    inc CURSOR_X
    
    ; Lastly we print the high-nibble of the fraction part of the fixed point number as a decimal fraction
    lda WORD_TO_PRINT
    lsr
    lsr
    lsr
    lsr
    tax
    ; FIXME: rename this table
    lda sub_ms_nibble_as_decimal, x
    jsr print_byte_as_decimal

    rts
    
; Input: WORD_TO_PRINT
print_word_as_decimal:

    jsr setup_cursor
    
    jsr mod10_word
    clc
    adc #'0'
    sta DECIMAL_STRING+4
    
    lda DIVIDEND
    sta WORD_TO_PRINT
    lda DIVIDEND+1
    sta WORD_TO_PRINT+1
    jsr mod10_word
    clc
    adc #'0'
    sta DECIMAL_STRING+3
    
    lda DIVIDEND
    sta WORD_TO_PRINT
    lda DIVIDEND+1
    sta WORD_TO_PRINT+1
    jsr mod10_word
    clc
    adc #'0'
    sta DECIMAL_STRING+2
    
    lda DIVIDEND
    sta WORD_TO_PRINT
    lda DIVIDEND+1
    sta WORD_TO_PRINT+1
    jsr mod10_word
    clc
    adc #'0'
    sta DECIMAL_STRING+1
    
    lda DIVIDEND
    sta WORD_TO_PRINT
    lda DIVIDEND+1
    sta WORD_TO_PRINT+1
    jsr mod10_word
    clc
    adc #'0'
    sta DECIMAL_STRING+0
    
    ldy #0 ; we havent reached a non-zero yet
    ldx #0 ; we start at digit index 0
print_next_digit_word:

    cpx #4
    beq do_print_digit_word  ; always print the last digit (even if its a zero)
    
    cpy #1
    beq do_print_digit_word  ; if we have seen an non-zero digit, we wont skip digits anymore

    lda DECIMAL_STRING, x
    cmp #'0'
    beq skip_printing_digit_word  ; we skip a zero-digit
    
    ldy #1   ; we remember we saw a non-zero digit

do_print_digit_word:
    lda DECIMAL_STRING, x
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    inc CURSOR_X
skip_printing_digit_word:
    
    inx
    cpx #5
    bne print_next_digit_word


    ; TODO: we are clearing the screen at the end of the decimal, but this might not always be needed! (if we do tens of thousands for example)
    ; Note: not incrementing the cursor here
    lda #' '
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    lda #' '
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    lda #' '
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    lda #' '
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    
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
    
    ; TODO: we are clearing the screen at the end of the decimal, but this might not always be needed! (if we do hundreds for example)
    ; Note: not incrementing the cursor here
    lda #' '
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    lda #' '
    sta VERA_DATA0
    lda TEXT_COLOR
    sta VERA_DATA0
    
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
    tax      ; x = a / 10
    
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

    
; Input
;   WORD_TO_PRINT : 16-bit word to do modulus once
; Result
;   a : WORD_TO_PRINT % 10
;   WORD_TO_PRINT : WORD_TO_PRINT / 10
    
mod10_word:
    
    ; We do division and by multiplication 10, so we store the DIVISOR and MULTIPLIER first
    lda #10
    sta DIVISOR
    sta MULTIPLIER
    lda #0
    sta DIVISOR+1
    sta MULTIPLIER+1
    
    ; First we divide the (16 bit) word by 10
    lda WORD_TO_PRINT
    sta DIVIDEND
    lda WORD_TO_PRINT+1
    sta DIVIDEND+1
    
    jsr divide_16bits   ; Note: the result is stored in DIVIDEND
    
    ; We multiply the result by 10
    
    lda DIVIDEND
    sta MULTIPLICAND
    lda DIVIDEND+1
    sta MULTIPLICAND+1
    
    jsr multply_16bits  ; Note: the result is stored in PRODUCT
    
    ; We subtract the original 16-bit word with the one divided and multiplied by 10 and put it in a   -->  a - ((a / 10) * 10) = a % 10
    
    sec
	lda WORD_TO_PRINT
	sbc PRODUCT
    
    ; Note: we are ignoring the high byte of the words, since we know this is not relevant here (since the result is always < 10)

    rts
    
    