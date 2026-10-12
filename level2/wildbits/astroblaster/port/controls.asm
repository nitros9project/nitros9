* SS.LiveKeys senses come from wildbits_vtio.d (LEFTBIT etc.), not local
* copies of hardware bits. X points at the ASTRO_KEY_BYTES input record.
* Return B = normalized controls. A/CC scratch; preserve X,Y,U.
TranslateControls pshs      x,y
                    leas      -TC_FrameBytes,s
                    clr       TC_Buttons,s
                    lda       ASTRO_KEY_SENSE,x
                    bita      #ALTBIT
                    bne       TranslateActionKeys ; Alt-arrows belong to Multi-Term
                    bita      #LEFTBIT
                    beq       TranslateRight
                    ldb       #CONTROL_LEFT
                    stb       TC_Buttons,s
TranslateRight    bita      #RIGHTBIT
                    beq       TranslateActionKeys
                    ldb       TC_Buttons,s
                    orb       #CONTROL_RIGHT
                    stb       TC_Buttons,s
TranslateActionKeys
                    bita      #SPACEBIT
                    beq       TranslateWarp
                    ldb       TC_Buttons,s
                    orb       #CONTROL_FIRE
                    stb       TC_Buttons,s
TranslateWarp     bita      #CTRLBIT
                    beq       TranslateHeldKeys
                    ldb       TC_Buttons,s
                    orb       #CONTROL_WARP
                    stb       TC_Buttons,s
TranslateHeldKeys leax      ASTRO_KEY_CODES,x
                    ldy       #ASTRO_LIVEKEY_BYTES
TranslateNextKey  lda       ,x+
                    ldb       #CONTROL_EXIT
                    cmpa      #KEY_ESCAPE
                    beq       TranslateSetKey
                    ldb       AD_Game+GS_Phase,u
                    cmpb      #PHASE_INITIALS
                    beq       TranslateKeyDone ; S/Q are letters during name entry
                    ldb       #CONTROL_START1
                    cmpa      #KEY_START1
                    beq       TranslateSetKey
                    ldb       #CONTROL_START2
                    cmpa      #KEY_START2
                    beq       TranslateSetKey
                    ldb       #CONTROL_FIRE
                    cmpa      #KEY_SHOOT_LOWER
                    beq       TranslateSetKey
                    cmpa      #KEY_SHOOT_UPPER
                    beq       TranslateSetKey
                    ldb       #CONTROL_CREDIT
                    cmpa      #KEY_CREDIT
                    beq       TranslateSetKey
                    ldb       #CONTROL_EXIT
                    cmpa      #KEY_QUIT_LOWER
                    beq       TranslateSetKey
                    cmpa      #KEY_QUIT_UPPER
                    bne       TranslateKeyDone
TranslateSetKey   orb       TC_Buttons,s
                    stb       TC_Buttons,s
TranslateKeyDone  leay      -1,y
                    bne       TranslateNextKey
                    ldb       TC_Buttons,s
                    leas      TC_FrameBytes,s
                    puls      x,y,pc

* Nonblocking credit/start equivalent of the original $0089/$013A paths.
* B = current controls, X = game workspace, U = platform state.
* Return A=0 (no start), 1 or 2 (credits deducted, start requested).
* X,Y,U preserved; B/CC scratch. Call from title/attract state only.
* Credit is rising-edge triggered: never spin waiting for a held key to
* release inside an interrupt as the arcade coin routine does.
UpdateStartControls
                    lda       AP_PreviousButtons,u
                    stb       AP_PreviousButtons,u
                    coma
                    pshs      b
                    anda      ,s+       stack offset 0: current button mask
                    pshs      a
                    bita      #CONTROL_CREDIT
                    beq       StartCheckButtons
                    lda       GS_CreditsBCD,x
                    adda      #1
                    daa                 decimal increment, same as service coin
                    sta       GS_CreditsBCD,x
StartCheckButtons puls      a
                    bita      #CONTROL_START1+CONTROL_FIRE
                    bne       RequestOnePlayer
                    bita      #CONTROL_START2
                    beq       StartNoRequest
                    lda       #2
                    bra       StartCheckCredits
RequestOnePlayer  lda       #1
StartCheckCredits leas      -SC_StartFrameBytes,s
                    sta       SC_StartPlayers,s
                    sta       SC_CreditsLeft,s
                    lda       GS_CreditsBCD,x
                    cmpa      SC_CreditsLeft,s ; BCD 0/1/2 compare numerically
                    blo       StartNotEnough
StartSubtractCredit
                    suba      #1
                    tfr       a,b
                    andb      #BCD_DIGIT_MASK
                    cmpb      #BCD_BORROW_DIGIT
                    bne       StartCreditAdjusted
                    suba      #BCD_BORROW_FIX ; 6809 DAA does not correct subtraction
StartCreditAdjusted
                    dec       SC_CreditsLeft,s
                    bne       StartSubtractCredit
                    sta       GS_CreditsBCD,x
                    clr       GS_C80D,x
                    clr       GS_C80F,x
                    lda       SC_StartPlayers,s
                    leas      SC_StartFrameBytes,s
                    rts
StartNotEnough    leas      SC_StartFrameBytes,s
StartNoRequest    clra
                    rts
