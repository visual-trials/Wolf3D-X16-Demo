
TURN_STEP = 5

update_player_based_on_keyboard_input:
    
    ldx #SCANCODE_RIGHT_ARROW
    lda KEYBOARD_STATE, x
    bne right_arrow_is_down
    
    ldx #SCANCODE_LEFT_ARROW
    lda KEYBOARD_STATE, x
    bne left_arrow_is_down
    
    ; FIXME: implement more!
    
    bra done_updating_player
    
right_arrow_is_down:
    jsr turn_player_right
    ; FIXME: we probably want to check for more pressed keys at once!!
    bra done_updating_player
    
left_arrow_is_down:
    jsr turn_player_left
    ; FIXME: we probably want to check for more pressed keys at once!!
    bra done_updating_player
    
done_updating_player:
    
    
    rts
    
    
turn_player_right:
    clc
    lda LOOKING_DIR_ANGLE
    adc #<(TURN_STEP)
    sta LOOKING_DIR_ANGLE
    lda LOOKING_DIR_ANGLE+1
    adc #>(TURN_STEP)
    sta LOOKING_DIR_ANGLE+1
    
    lda LOOKING_DIR_ANGLE+1
    cmp #$7                ; $720 = 1824
    bcc done_turning_player_right
    
    lda LOOKING_DIR_ANGLE
    cmp #$20
    bcc done_turning_player_right
    
    ; If we exceeded 1824 we need to subtract 1824
    sec
    lda LOOKING_DIR_ANGLE
    sbc #<(1824)
    sta LOOKING_DIR_ANGLE
    lda LOOKING_DIR_ANGLE+1
    sbc #>(1824)
    sta LOOKING_DIR_ANGLE+1
    
done_turning_player_right:

    rts

turn_player_left:
    sec
    lda LOOKING_DIR_ANGLE
    sbc #<(TURN_STEP)
    sta LOOKING_DIR_ANGLE
    lda LOOKING_DIR_ANGLE+1
    sbc #>(TURN_STEP)
    sta LOOKING_DIR_ANGLE+1

    ; If we go below 0 to add 1824
    lda LOOKING_DIR_ANGLE+1
    bpl done_turning_player_left
    
    clc
    lda LOOKING_DIR_ANGLE
    adc #<(1824)
    sta LOOKING_DIR_ANGLE
    lda LOOKING_DIR_ANGLE+1
    adc #>(1824)
    sta LOOKING_DIR_ANGLE+1
    
done_turning_player_left:

    rts

    