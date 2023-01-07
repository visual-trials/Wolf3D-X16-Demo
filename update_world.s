
TURN_STEP = 5
MOVE_STEP = 5

update_player_based_on_keyboard_input:
    
    ; FIXME: should we process turning *before* moving? And move based on the new viewing direction or the old one?
    
    ldx #SCANCODE_RIGHT_ARROW
    lda KEYBOARD_STATE, x
    bne right_arrow_is_down
    
    ldx #SCANCODE_LEFT_ARROW
    lda KEYBOARD_STATE, x
    bne left_arrow_is_down
    
    ldx #SCANCODE_UP_ARROW
    lda KEYBOARD_STATE, x
    bne up_arrow_is_down
    
    ldx #SCANCODE_DOWN_ARROW
    lda KEYBOARD_STATE, x
    bne down_arrow_is_down
    
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

up_arrow_is_down:
    jsr move_player_forward
    ; FIXME: we probably want to check for more pressed keys at once!!
    bra done_updating_player
    
down_arrow_is_down:
    jsr move_player_backward
    ; FIXME: we probably want to check for more pressed keys at once!!
    bra done_updating_player

    
done_updating_player:
    
    
; FIXME: remove this!
; FIXME: remove this!
; FIXME: remove this!
    
    jsr clear_and_setup_debug_screen
    jsr debug_print_player_info_on_screen
    
    
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

    
move_player_forward:
    lda #0
    sta TMP3
    bra move_player_along_viewing_dir
move_player_backward:
    lda #1
    sta TMP3
    bra move_player_along_viewing_dir
    
move_player_along_viewing_dir:

    ; We have to multiply the sine and cosine of the viewing angle with a constant (speed) value
    
    ; FIXME: we should make sure the sine and cosine viewing angle pre-processing (now in routine 'update_viewpoint') is done *before* this usage
    ; FIXME: we should make sure the sine and cosine viewing angle pre-processing (now in routine 'update_viewpoint') is done *before* this usage
    ; FIXME: we should make sure the sine and cosine viewing angle pre-processing (now in routine 'update_viewpoint') is done *before* this usage
    
    
    ; -- MOVE_DISTANCE_IN_X --

    lda #<(MOVE_STEP)
    sta MULTIPLICAND
    lda #>(MOVE_STEP)
    sta MULTIPLICAND+1

    jsr MULT_WITH_LOOK_DIR_SINE
    
    lda PRODUCT+1
    sta MOVE_DISTANCE_IN_X
    lda PRODUCT+2
    sta MOVE_DISTANCE_IN_X+1

    ; -- MOVE_DISTANCE_IN_Y --
    
    lda #<(MOVE_STEP)
    sta MULTIPLICAND
    lda #>(MOVE_STEP)
    sta MULTIPLICAND+1

    jsr MULT_WITH_LOOK_DIR_COSINE
    
    lda PRODUCT+1
    sta MOVE_DISTANCE_IN_Y
    lda PRODUCT+2
    sta MOVE_DISTANCE_IN_Y+1
    

    ; Now we need to know whether to negate either of these DISTANCES

    ldx TMP3
    bne negate_movement_in_y

    lda LOOKING_DIR_QUANDRANT
    and #%00000001  ; check vertical
    beq movement_needs_positive_cosine
    bra movement_needs_negative_cosine
    
negate_movement_in_y:
    
    lda LOOKING_DIR_QUANDRANT
    and #%00000001  ; check vertical
    beq movement_needs_negative_cosine
    bra movement_needs_positive_cosine
    
movement_needs_negative_cosine:
    ; We negate the MOVE_DISTANCE_IN_Y
    sec
    lda #0
    sbc MOVE_DISTANCE_IN_Y
    sta MOVE_DISTANCE_IN_Y
    lda #0
    sbc MOVE_DISTANCE_IN_Y+1
    sta MOVE_DISTANCE_IN_Y+1
    
movement_needs_positive_cosine:
    ; Nothing to do with the MOVE_DISTANCE_IN_Y

    ldx TMP3
    bne negate_movement_in_x
    
    lda LOOKING_DIR_QUANDRANT
    and #%00000010  ; check horizontal
    beq movement_needs_positive_sine
    bra movement_needs_negative_sine
    
negate_movement_in_x:

    lda LOOKING_DIR_QUANDRANT
    and #%00000010  ; check horizontal
    beq movement_needs_negative_sine
    bra movement_needs_positive_sine
    
movement_needs_negative_sine:
    ; We negate the MOVE_DISTANCE_IN_X
    sec
    lda #0
    sbc MOVE_DISTANCE_IN_X
    sta MOVE_DISTANCE_IN_X
    lda #0
    sbc MOVE_DISTANCE_IN_X+1
    sta MOVE_DISTANCE_IN_X+1

movement_needs_positive_sine:
    ; Nothing to do with the MOVE_DISTANCE_IN_X

    
    clc
    lda PLAYER_POS_X
    adc MOVE_DISTANCE_IN_X
    sta PLAYER_POS_X
    lda PLAYER_POS_X+1
    adc MOVE_DISTANCE_IN_X+1
    sta PLAYER_POS_X+1
    

    clc
    lda PLAYER_POS_Y
    adc MOVE_DISTANCE_IN_Y
    sta PLAYER_POS_Y
    lda PLAYER_POS_Y+1
    adc MOVE_DISTANCE_IN_Y+1
    sta PLAYER_POS_Y+1

    rts
    
