; Zero-page vars
ZP_BOARD    = $10    ; 9 bytes for 6x6 board
ZP_ALPHA    = $20    ; Best score for maximizer
ZP_BETA     = $22    ; Best score for minimizer
ZP_DEPTH    = $24    ; Current search depth
ZP_BESTMOVE = $25    ; Best move found

; Constants
MAX_DEPTH   = 2      ; Search 2 plies
BOARD_SIZE  = 9      ; Bytes for board

; Main AI move routine
ai_turn:
    lda #$FF         ; Init alpha (-infinity)
    sta ZP_ALPHA
    lda #$00         ; Init beta (+infinity)
    sta ZP_BETA
    lda #MAX_DEPTH
    sta ZP_DEPTH
    jsr minimax
    lda ZP_BESTMOVE  ; Apply best move
    jsr make_move
    rts

; Minimax with alpha-beta
minimax:
    lda ZP_DEPTH
    beq evaluate     ; Base case: score board
    dec ZP_DEPTH
    jsr generate_moves  ; Fills move list at $1000
    ldx #$00         ; Move index
next_move:
    lda $1000,x      ; Get move
    beq end_search   ; No more moves
    jsr apply_move   ; Test move
    jsr minimax      ; Recurse
    jsr undo_move    ; Restore state
    ; Update alpha/beta (maximizing player here)
    cmp ZP_ALPHA
    bcc skip_alpha
    sta ZP_ALPHA
    sta ZP_BESTMOVE  ; Save move at depth 0
skip_alpha:
    cmp ZP_BETA
    bcs prune        ; Branch if score >= beta
    inx
    jmp next_move
prune:
    inc ZP_DEPTH
    rts
end_search:
    lda ZP_ALPHA     ; Return best score
    inc ZP_DEPTH
    rts

evaluate:
    ldy #$00         ; Score accumulator
    ldx #$00
eval_loop:
    lda ZP_BOARD,x   ; Get byte (4 squares)
    jsr score_byte   ; Custom routine to unpack and score
    inx
    cpx #BOARD_SIZE
    bne eval_loop
    tya              ; Return score in A
    rts
