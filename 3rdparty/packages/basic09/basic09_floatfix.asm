FLOAT               clra
                    clrb
                    std       4,y
                    ldd       1,y
                    bne       FLOAT1
                    stb       3,y
                    lda       #2
                    sta       ,y
                    rts

FLOAT1              ldu       #$0210
                    tsta
                    ifne      B09RUNB
                    bpl       FLOT2
                    else
                    bpl       L451F
                    endc
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
                    inc       5,y
FLOT2               tsta
L451F               bne       L4526
                    ldu       #$0208
                    exg       a,b
L4526               tsta
                    bmi       FLOAT5
L4529               leau      -1,u
                    lslb
                    rola
                    bpl       L4529
FLOAT5              std       2,y
                    stu       ,y
                    rts

                    ifne      B09RUNB
float2              leay      6,y
                    else
FLTNEX              leay      6,y
                    endc
                    bsr       FLOAT
                    leay      -6,y
                    rts

FIX                 ldb       1,y
                    bgt       FIX1
                    bmi       FIXZER
                    lda       2,y
                    bpl       FIXZER
                    ldd       #$0001
                    bra       FIX4A

FIXZER              clra
                    clrb
                    bra       FIX5

FIX1                subb      #$10
                    bhi       FIXERR
                    bne       FIX2
                    ldd       2,y
                    ror       5,y
                    bcc       FIX5
                    cmpd      #$8000
                    bne       FIXERR
                    tst       4,y
                    bpl       FIX5
                    bra       FIXERR

FIX2                cmpb      #$F8
                    bhi       FIX3
                    pshs      b
                    ldd       2,y
                    std       3,y
                    clr       2,y
                    puls      b
                    addb      #$08
                    beq       FIX4
FIX3                lsr       2,y
                    ror       3,y
                    ror       4,y
                    incb
                    bne       FIX3
FIX4                ldd       2,y
                    tst       4,y
                    bpl       FIX4A
                    addd      #$0001
                    bvc       FIX4A
FIXERR              ldb       #$34
                    ifne      B09RUNB
                    lbra      L1102
                    else
                    jsr       <u0024
                    fcb       $06
                    endc

FIX4A               ror       5,y
                    bcc       FIX5
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
FIX5                std       1,y
                    lda       #1
                    sta       ,y
                    rts

                    ifne      B09RUNB
fixN1               leay      6,y
                    else
FIXNEX              leay      6,y
                    endc
                    bsr       FIX
                    leay      -6,y
                    rts

                    ifne      B09RUNB
fixN2               leay      $C,y
                    else
L45A7               leay      $C,y
                    endc
                    bsr       FIX
                    leay      -$C,y
                    rts
