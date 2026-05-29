                    ifne      B09RUNB
ABSrl
                    else
ABSFNR
                    endc
                    ifne      H6309
                    ifeq      B09RUNB
                    aim       #$fe,5,y
                    else
                    lda       5,y
                    anda      #$FE
                    sta       5,y
                    rts
                    endc
                    else
                    lda       5,y
                    anda      #$FE
                    sta       5,y
                    rts
                    endc

                    ifne      B09RUNB
ABSint
                    else
L45B5
                    endc
                    ldd       1,y
                    bpl       ABSINT2
                    ifne      H6309
                    ifeq      B09RUNB
                    negd
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
                    std       1,y
ABSINT2             rts

                    ifne      B09RUNB
PEEK
                    else
PEKFNC
                    endc
                    clra
                    ldb       [<1,y]
                    std       1,y
                    rts

                    ifne      B09RUNB
SGNrl
                    else
SGNFNR
                    endc
                    lda       2,y
                    beq       SGNZER
                    lda       5,y
                    anda      #$01
                    bne       SGNMIN
SGNPLS              ldb       #$01
                    bra       RETINT

                    ifne      B09RUNB
SGNint
                    else
SGNFNI
                    endc
                    ldd       1,y
                    bmi       SGNMIN
                    bne       SGNPLS
SGNZER              clrb
                    bra       RETINT

SGNMIN              ldb       #$FF
RETINT              sex
                    bra       RETINT1

                    ifne      B09RUNB
ERR
                    else
L45E3
                    endc
                    ldb       <u0036
                    clr       <u0036
                    ifne      B09RUNB
L1ABA
                    else
L45E7
                    endc
                    clra
                    leay      -6,y
RETINT1             std       1,y
                    lda       #1
                    sta       ,y
                    ifne      B09RUNB
L1AC3
                    else
RETBYT99
                    endc
                    rts

                    ifne      B09RUNB
POS
                    else
POSFNC
                    endc
                    ldb       <u007D
                    ifne      B09RUNB
                    bra       L1ABA
                    else
                    bra       L45E7
                    endc
