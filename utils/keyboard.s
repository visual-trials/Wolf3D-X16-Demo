; Keyboard scan code retreival and intepretation

; Also see 'receive_scancode' inside kernal/drivers/x16/ps2kbd.s for proper handling of keyboard scancodes (in the kernal)

SMC_I2C_ADDR  = $42
KEYBOARD_SCANCODE_REGISTER = $07

; Scancodes for specific keys:
SCANCODE_SPACE_BAR        = $29
SCANCODE_UP_ARROW         = $75
SCANCODE_DOWN_ARROW       = $72
SCANCODE_LEFT_ARROW       = $6B
SCANCODE_RIGHT_ARROW      = $74


init_keyboard:
    jsr reset_scancode_buffer
    jsr clear_keyboard_state
    rts

reset_scancode_buffer:
    lda #0
    sta NR_OF_KBD_SCANCODE_BYTES
    rts
    
clear_keyboard_state:
    ldx #0
next_key_state:
    lda #0
    sta KEYBOARD_STATE, x
    inx
    bne next_key_state
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
    

update_keyboard_state:

    ; We look through the buffer byte by byte and see if we recognize a scancode (usually 2 or 3 bytes long)
    ; If we have a scancode, we update the corresponding key in the keyboard state array (whether a key is up or down atm)
    ; We go on doing that until we have looked through the entire buffer scancode buffer.
    
    ; FIXME: we *could* record whether a key as come down AND up in the same scancode buffer. We could record this in the KEYBOARD_STATE byte somehow.
    
    ; FIXME: technically we could be *reading* outside the 32 byte buffer (since y is not checked every byte), but we dont care at the moment

    ldy #0
read_next_scan_code:

    ; -- Loop through the buffer of scancodes to find the next scan code (usually 2-3 bytes) --
    
    cpy NR_OF_KBD_SCANCODE_BYTES
    bcs done_reading_keycode_bytes

    ; Read *first byte* of scan code
    lda KEYBOARD_SCANCODE_BUFFER, y
    iny
    
    cmp #$E0 ; escape code prefix
    beq e0_as_first_byte_scan_code
    
    ; FIXME: we ignore the entire buffer when we see an E1 scan code
    cmp #$E1 ; escape code prefix
    beq done_reading_keycode_bytes
    
    cmp #$F0 ; key up prefix
    beq f0_as_first_byte_scan_code
    
    ; --- Non escaped scan code (not starting with E0, E1 or F0) --
    
    ; This means we have a keydown event on a key.
    
    ; We skip the scancodes we should ignore (see HACK below)
    jsr check_if_between_and_including_69_and_75   ; NOTE: this jsr affects register x!!
    bne non_escaped_keydown_ignored
    
    ; We store the keydown event
    tax
    lda #1  ; 1 = key is down
    sta KEYBOARD_STATE, x
    
    ; Since we have a *one byte* scancode we can move on to the next scan code
    bra read_next_scan_code
    
non_escaped_keydown_ignored:

    ; Since we have a *one byte* scancode we can move on to the next scan code
    bra read_next_scan_code

    
e0_as_first_byte_scan_code:

    ; We have an escaped scan code (starting with e0)
    
    ; Read *second byte* of scan code
    lda KEYBOARD_SCANCODE_BUFFER, y
    iny
    
    cmp #$F0 ; key up prefix
    beq f0_as_second_byte_scan_code
    
    ; FIXME: we ignore the entire buffer when we see an E012.. scan code -> see HACK below
    cmp #$12 ; checking for E012E07C (Prt Scr)
    beq done_reading_keycode_bytes
    
    ; We skip the escaped scancodes we should ignore -> see HACK below
    ; This effectively also ignores E04A and E01F -> see HACK below
    jsr check_if_between_and_including_69_and_75   ; NOTE: this jsr affects register x!!
    beq two_bytes_escaped_keydown_ignored
    
    ; We have an escaped scan code between and including $69 and $75
    
    ; We store the keydown event
    tax
    lda #1  ; 1 = key is down
    sta KEYBOARD_STATE, x
    
    ; Since we have a *two byte* scancode we can move on to the next scan code
    bra read_next_scan_code
    
two_bytes_escaped_keydown_ignored:

    ; Since we have a *two byte* scancode we can move on to the next scan code
    bra read_next_scan_code
    
f0_as_first_byte_scan_code:

    ; This means we have a keyup event on a key (non-escaped).
    
    ; Read *second byte* of scan code
    lda KEYBOARD_SCANCODE_BUFFER, y
    iny
    
    ; We skip the scancodes we should ignore (see HACK below)
    jsr check_if_between_and_including_69_and_75   ; NOTE: this jsr affects register x!!
    bne non_escaped_keyup_ignored
    
    ; We store the keyup event
    tax
    lda #0  ; 0 = key is up
    sta KEYBOARD_STATE, x
    
    ; Since we have a *two byte* scancode we can move on to the next scan code
    bra read_next_scan_code
    
non_escaped_keyup_ignored:

    ; Since we have a *two byte* scancode we can move on to the next scan code
    bra read_next_scan_code
    
f0_as_second_byte_scan_code:

    ; This means we have a keyup event on a key (escaped with e0).

    ; Read *third byte* of scan code
    lda KEYBOARD_SCANCODE_BUFFER, y
    iny

    ; FIXME: we ignore the entire buffer when we see an E0F07C.. scan code -> see HACK below
    cmp #$7C ; checking for E0F07CE0F012 (key up Prt Scr)
    beq done_reading_keycode_bytes
    
    ; We skip the escaped scancodes we should ignore -> see HACK below
    ; This effectively also ignores E04A and E01F -> see HACK below
    jsr check_if_between_and_including_69_and_75   ; NOTE: this jsr affects register x!!
    beq three_bytes_escaped_keyup_ignored
    
    ; We have an escaped scan code between and including $69 and $75
    
    ; We store the keydown event
    tax
    lda #0  ; 0 = key is up
    sta KEYBOARD_STATE, x
    
    ; Since we have a *three byte* scancode we can move on to the next scan code
    bra read_next_scan_code
    
three_bytes_escaped_keyup_ignored:

    ; Since we have a *three byte* scancode we can move on to the next scan code
    bra read_next_scan_code
    
done_reading_keycode_bytes:

    ; We reset the scancode buffer afterwards
    jsr reset_scancode_buffer
    
    rts
    
    
wait_until_spacebar_press:
    ; We reset the keyboard state, since we do not expect it to be properly reset when using this procedure regurlarly
    ; NOTE: clearing the keyboard state should only be done during DEBUG, since it destroys all state of the keyboard!
    jsr clear_keyboard_state

keep_waiting_until_spacebar_press:
    jsr retrieve_keyboard_scan_codes
    jsr update_keyboard_state
    
    ldx #SCANCODE_SPACE_BAR
    lda KEYBOARD_STATE, x
    beq keep_waiting_until_spacebar_press
    
    rts
    
    
; HACK: Scancodes $69 through $75 (mostly in the numerical part of the keyboard) are ignored and are 
;       replaced by the (two byte) keycodes $E069 through $E075. 
;       Also: E012E07C (Prt Scr), E11477E1F014E077 (Pause/Break), E04A ("/" on numpad) and E01F (Windows left) are ignored (including their correpsonding ..F0.. codes)
;       This allows for almost all practical keys to be represented in single byte.

check_if_between_and_including_69_and_75:
    cmp #$69
    bcc is_not_between_and_including_69_and_75
    cmp #$75+1
    bcs is_not_between_and_including_69_and_75
is_between_and_including_69_and_75:
    ldx #1 ; this affects the Z-flag
    rts

is_not_between_and_including_69_and_75:
    ldx #0 ; this affects the Z-flag
    rts

; Also see: https://techdocs.altium.com/display/FPGA/PS2+Keyboard+Scan+Codes
;       or: https://webdocs.cs.ualberta.ca/~amaral/courses/329/labs/scancodes.html

