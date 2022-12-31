; Keyboard scan code retreival and intepretation

; Also see 'receive_scancode' inside kernal/drivers/x16/ps2kbd.s for proper handling of keyboard scancodes (in the kernal)

SMC_I2C_ADDR  = $42
KEYBOARD_SCANCODE_REGISTER = $07


init_scancode_buffer:
    lda #0
    sta NR_OF_KBD_SCANCODE_BYTES
    rts

retrieve_keyboard_scan_codes:

    ldx #SMC_I2C_ADDR
    
scancode_next:
    ldy #KEYBOARD_SCANCODE_REGISTER
    jsr i2c_read_byte
    
    bcs scancode_read_error
    beq scancode_zero

    ldy NR_OF_KBD_SCANCODE_BYTES
    sta KEYBOARD_SCANCODE_BUFFER, y

    ; increment nr of bytes in buffer
    iny
    tya
    and #%00011111                ; making sure buffer of 32 bytes is never exceeded
    sta NR_OF_KBD_SCANCODE_BYTES

    bra scancode_next
    
scancode_read_error:   
    ; TODO: ignoring read errors for now
scancode_zero:
    rts
    
; This is a *very simple* interpretation of scancodes into a *single* "key press"
; It returns a single byte containing the (truncated) scancode that would normally be received for a key down event for ps/2
get_interpreted_key_press:

    ; by default we assume nothing was pressed (=0)
    lda #0
    sta TMP1
    
    ldy #0
next_scancode_byte:
    cpy NR_OF_KBD_SCANCODE_BYTES
    beq done_reading_keycode_bytes
    
    lda KEYBOARD_SCANCODE_BUFFER, y

    ; FIXNE: right now, if a escape code is present, we completely ignore the scan code bytes in the buffer
    cmp #$E0 ; escape code prefix
    beq done_reading_keycode_bytes
    
    ; FIXNE: right now, if a escape code is present, we completely ignore the scan code bytes in the buffer
    cmp #$E1 ; escape code prefix
    beq done_reading_keycode_bytes
    
    ; FIXNE: right now, if a key up code is present, we completely ignore the scan code bytes in the buffer
    cmp #$F0 ; key up prefix
    beq done_reading_keycode_bytes
    
    ; If other than escaped or key up, we put the scancode in the output (TMP1)
    sta TMP1
    bra done_reading_keycode_bytes
    
    ; FIXME: this code is never reached at the moment
do_next_scancode_byte:
    iny
    bra next_scancode_byte
    
done_reading_keycode_bytes:

    ; Resetting the buffer afterwards
    lda #0
    sta NR_OF_KBD_SCANCODE_BYTES

    lda TMP1
    
    rts
    
wait_until_key_press:

    jsr retrieve_keyboard_scan_codes
    jsr get_interpreted_key_press
    beq wait_until_key_press

    rts
    