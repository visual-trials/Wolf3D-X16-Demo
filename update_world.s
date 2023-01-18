
TURN_STEP = 20
MOVE_STEP = 80

update_viewpoint:

    ; FIXME: We should add PLAYER_POS_X/Y and calcluate VIEWPOINT_X/Y from the player position and the LOOKING_DIR_ANGLE (every frame)
    ;        The viewpoint position is around 0.34 tiles "behind" the player position.

    ; x-position of the viewpoint (8.8 bits)
    lda PLAYER_POS_X
    sta VIEWPOINT_X 
    lda PLAYER_POS_X+1
    sta VIEWPOINT_X+1
    
    ; y-position of the viewpoint (8.8 bits)
    lda PLAYER_POS_Y
    sta VIEWPOINT_Y
    lda PLAYER_POS_Y+1
    sta VIEWPOINT_Y+1

    ; When calculating the distance to the wall (from the viewing-plane) we need the sine and cosine of the player direction
    ; But since we have the *absolute* values of DELTA_X and DELTA_Y, we also need the positive values of sine and cosine.
    ; Therefore we normalize the viewing angle first to the positive quadrants of both sine and cosine (which lies between 0 and 90 degrees)
    
    ; Apart from that we also have to mark the quarter the looking dir is in, so the calculation can negate the cosine/sine result
    ; when the ray for which the distance has to be calculated does not lie in the same quadrant.

    ; Two bits for LOOKING_DIR_QUANDRANT: 00 = q0 (ne), 01 = q1 (se), 11 = q2 (sw), 10 = q3 (nw) 
    ; This way you can easely check if something is in a different quadrant horizontally or vertically
    
    ; NOTE: I am (ab)using ANGLE_INDEX here for temporary storage of the normalized LOOKING_DIR_ANGLE
    
    lda LOOKING_DIR_ANGLE+1
    cmp #>(456*1)
    bcc looking_dir_in_q0
    bne looking_dir_in_not_in_q0
    lda LOOKING_DIR_ANGLE
    cmp #<(456*1)
    bcc looking_dir_in_q0
    
looking_dir_in_not_in_q0:
    lda LOOKING_DIR_ANGLE+1
    cmp #>(456*2)
    bcc looking_dir_in_q1
    bne looking_dir_in_not_in_q1
    lda LOOKING_DIR_ANGLE
    cmp #<(456*2)
    bcc looking_dir_in_q1
    
looking_dir_in_not_in_q1:
    lda LOOKING_DIR_ANGLE+1
    cmp #>(456*3)
    bcc looking_dir_in_q2
    bne looking_dir_in_q3
    lda LOOKING_DIR_ANGLE
    cmp #<(456*3)
    bcc looking_dir_in_q2
    
looking_dir_in_q3:
    ; FIXME, CHECK: we do -1 here, is this indeed the correct way?
    ; Normalize angle (360-1 degrees - q3angle = q0angle)
    sec
    lda #<(456*4-1)
    sbc LOOKING_DIR_ANGLE
    sta ANGLE_INDEX
    lda #>(456*4-1)
    sbc LOOKING_DIR_ANGLE+1
    sta ANGLE_INDEX+1

    ; Mark as q3
    lda #%00000010
    sta LOOKING_DIR_QUANDRANT
    
    bra looking_dir_info_updated
    
looking_dir_in_q2:
    ; Normalize angle (q2angle - 180 degrees = q0angle)
    sec
    lda LOOKING_DIR_ANGLE
    sbc #<(456*2)
    sta ANGLE_INDEX
    lda LOOKING_DIR_ANGLE+1
    sbc #>(456*2)
    sta ANGLE_INDEX+1
    
    ; Mark as q2
    lda #%00000011
    sta LOOKING_DIR_QUANDRANT
    
    bra looking_dir_info_updated
    
looking_dir_in_q1:
    ; FIXME, CHECK: we do -1 here, is this indeed the correct way?
    ; Normalize angle (180-1 degrees - q1angle = q0angle)
    sec
    lda #<(456*2-1)
    sbc LOOKING_DIR_ANGLE
    sta ANGLE_INDEX
    lda #>(456*2-1)
    sbc LOOKING_DIR_ANGLE+1
    sta ANGLE_INDEX+1
    
    ; Mark as q1
    lda #%00000001
    sta LOOKING_DIR_QUANDRANT
    
    bra looking_dir_info_updated
    
looking_dir_in_q0:

    lda LOOKING_DIR_ANGLE
    sta ANGLE_INDEX
    lda LOOKING_DIR_ANGLE+1
    sta ANGLE_INDEX+1
    
    ; Mark as q0
    lda #%00000000
    sta LOOKING_DIR_QUANDRANT


looking_dir_info_updated:

    ; Sine for looking dir
    
    lda ANGLE_INDEX+1
    bne is_high_index_sine
is_low_index_sine:
    ldy ANGLE_INDEX
    lda SINE_LOW,y
    sta LOOKING_DIR_SINE
    lda SINE_HIGH,y
    sta LOOKING_DIR_SINE+1
    bra got_looking_dir_sine
is_high_index_sine:
    ldy ANGLE_INDEX
    lda SINE_LOW+256,y         ; When the angle index >= 256, we retrieve from 256 positions further
    sta LOOKING_DIR_SINE
    lda SINE_HIGH+256,y        ; When the angle index >= 256, we retrieve from 256 positions further
    sta LOOKING_DIR_SINE+1
got_looking_dir_sine:

    ; Since we know the LOOKING_DIR_SINE, we can prepare the multiplier that uses it
    jsr setup_multiply_with_looking_dir_sine_16bit
    
    ; Cosine for looking dir
    
    lda ANGLE_INDEX+1
    bne is_high_index_cosine
is_low_index_cosine:
    ldy ANGLE_INDEX
    lda COSINE_LOW,y
    sta LOOKING_DIR_COSINE
    lda COSINE_HIGH,y
    sta LOOKING_DIR_COSINE+1
    bra got_looking_dir_cosine
is_high_index_cosine:
    ldy ANGLE_INDEX
    lda COSINE_LOW+256,y         ; When the angle index >= 256, we retrieve from 256 positions further
    sta LOOKING_DIR_COSINE
    lda COSINE_HIGH+256,y        ; When the angle index >= 256, we retrieve from 256 positions further
    sta LOOKING_DIR_COSINE+1
got_looking_dir_cosine:

    ; Since we know the LOOKING_DIR_COSINE, we can prepare the multiplier that uses it
    jsr setup_multiply_with_looking_dir_cosine_16bit

    rts
    
    
; ============================================================================================
;                            UPDATE PLAYER BASED ON INPUT
; ============================================================================================
    
    
update_player_based_on_keyboard_input:
    
    ; FIXME: should we process turning *before* moving? And move based on the new viewing direction or the old one?
    
    ldx #SCANCODE_RIGHT_ARROW
    lda KEYBOARD_STATE, x
    beq right_arrow_is_handled
    jsr turn_player_right
right_arrow_is_handled:

    ldx #SCANCODE_LEFT_ARROW
    lda KEYBOARD_STATE, x
    beq left_arrow_is_handled
    jsr turn_player_left
left_arrow_is_handled:
    
    ldx #SCANCODE_UP_ARROW
    lda KEYBOARD_STATE, x
    beq up_arrow_is_handled
    jsr move_player_forward
up_arrow_is_handled:
    
    ldx #SCANCODE_DOWN_ARROW
    lda KEYBOARD_STATE, x
    beq down_arrow_is_handled
    jsr move_player_backward
down_arrow_is_handled:
    
    ; TODO: implement more!
    
done_updating_player:

    ; SPEED: we should *ONLY* do this when something has changed!! (better: only call parts of this if parts of it has changed)
    jsr update_viewpoint
    
    ; FIXME: only if viewpoint position has *changed* (x,y) load appropiate ordered wall list!
    ; FIXME: only if viewpoint position has *changed* (x,y) load appropiate ordered wall list!
    ; FIXME: only if viewpoint position has *changed* (x,y) load appropiate ordered wall list!
    
    jsr LOAD_ORDERED_WALL_INDEXES
    
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
    
    .if DEBUG
    jsr clear_and_setup_debug_screen
    jsr debug_print_player_info_on_screen
    .endif
    
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
    
