                    ifne      B09RUNB
L1C6D
                    else
L479A
                    endc
                    fcb       $ff,$de,$5b,$d8,$aa

                    ifne      B09RUNB
LOG10
                    else
L479F
                    endc
                    ifne      B09RUNB
                    bsr       LOG
                    leau      >L1C6D,pcr
                    lbsr      RCPVAR
                    lbra      RLMUL
                    else
                    bsr       L47AB
                    leau      <L479A,pc
                    lbsr      L3F93
                    lbra      L40CC
                    endc

                    ifne      B09RUNB
LOG
                    else
L47AB
                    endc
                    pshs      x
                    ldb       5,y
                    asrb
                    ifne      B09RUNB
                    lbcs      err67
                    else
                    lbcs      L4FC7
                    endc
                    ldd       1,y
                    ifne      B09RUNB
                    lbeq      err67
                    else
                    lbeq      L4FC7
                    endc
                    pshs      a
                    ldb       #1
                    stb       1,y
                    leay      <-$1A,y
                    leax      <$1B,y
                    leau      ,y
                    ifne      B09RUNB
                    lbsr      L209F
                    lbsr      L219A
                    else
                    lbsr      CMOVE
                    lbsr      CDENOR
                    endc
                    clra
                    clrb
                    std       <$14,y
                    std       <$16,y
                    sta       <$18,y
                    ifne      B09RUNB
                    leax      >L2152,pcr
                    else
                    leax      >L4C7F,pc
                    endc
                    stx       <$19,y
                    lbsr      LOGEXP10
                    leax      <$14,y
                    leau      <$1B,y
                    ifne      B09RUNB
                    lbsr      L209F
                    lbsr      L21B4
                    else
                    lbsr      CMOVE
                    lbsr      CNORM
                    endc
                    leay      <$1A,y
                    ldb       #2
                    stb       ,y
                    ldb       5,y
                    orb       #$01
                    stb       5,y
                    puls      b
                    bsr       CBLN2
                    puls      x
                    ifne      B09RUNB
                    lbra      RLADD
                    else
                    lbra      L3FB1
                    endc

                    ifne      B09RUNB
L1CD8
                    else
L4805
                    endc
                    fcb       $00,$b1,$72,$17,$f8

CBLN2               sex
                    bpl       CBLN10
                    negb
CBLN10              anda      #$01
                    pshs      d
                    ifne      B09RUNB
                    leau      >L1CD8,pcr
                    lbsr      RCPVAR
                    else
                    leau      <L4805,pc
                    lbsr      L3F93
                    endc
                    ldb       5,y
                    lda       1,s
                    cmpa      #1
                    beq       CBLN40
                    mul
                    stb       5,y
                    ldb       4,y
                    sta       4,y
                    lda       1,s
                    mul
                    addb      4,y
                    adca      #$00
                    stb       4,y
                    ldb       3,y
                    sta       3,y
                    lda       1,s
                    mul
                    addb      3,y
                    adca      #$00
                    stb       3,y
                    ldb       2,y
                    sta       2,y
                    lda       1,s
                    mul
                    addb      2,y
                    adca      #$00
                    beq       CBLN30
CBLN20              inc       1,y
                    lsra
                    rorb
                    ror       3,y
                    ror       4,y
                    ror       5,y
                    tsta
                    bne       CBLN20
CBLN30              stb       2,y
                    ldb       5,y
CBLN40              andb      #$FE
                    orb       ,s
                    stb       5,y
                    puls      pc,d

                    ifne      B09RUNB
EXP
L1D37
                    else
EXPFNC
                    endc
                    pshs      x
                    ldb       1,y
                    beq       EXPF21
                    cmpb      #$07
                    ble       EXPF10
                    ldb       5,y
                    rorb
                    rorb
                    eorb      #$80
                    lbra      FPOVRF

EXPF10              cmpb      #$E4
                    ifne      B09RUNB
                    lble      L1815
                    else
                    lble      REXP10
                    endc
                    tstb
                    bpl       EXPF25
EXPF21              clr       ,-s
                    ldb       5,y
                    andb      #$01
                    beq       EXPF50
                    bra       EXPF45

EXPF25              lda       #$71
                    mul
                    adda      1,y
                    ldb       5,y
                    andb      #$01
                    pshs      b,a
                    eorb      5,y
                    stb       5,y
                    ldb       ,s
EXPF30              lbsr      CBLN2
                    ifne      B09RUNB
                    lbsr      L147E
                    else
                    lbsr      L3FAB
                    endc
                    ldb       1,y
                    ble       EXPF40
                    addb      ,s
                    stb       ,s
                    ldb       1,y
                    bra       EXPF30

EXPF40              puls      d
                    pshs      a
                    tstb
                    beq       EXPF50
                    nega
                    sta       ,s
                    orb       5,y
                    stb       5,y
EXPF45
                    ifne      B09RUNB
                    leau      >L1CD8,pcr
                    lbsr      RCPVAR
                    lbsr      RLADD
                    else
                    leau      >L4805,pc
                    lbsr      L3F93
                    lbsr      L3FB1
                    endc
                    dec       ,s
                    ldb       5,y
                    andb      #$01
                    bne       EXPF45
EXPF50              leay      <-$1A,y
                    leax      <$1B,y
                    leau      <$14,y
                    ifne      B09RUNB
                    lbsr      L209F
                    lbsr      L219A
                    else
                    lbsr      CMOVE
                    lbsr      CDENOR
                    endc
                    ldd       #$1000
                    std       ,y
                    clra
                    std       2,y
                    sta       4,y
                    ifne      B09RUNB
                    leax      >L2134,pcr
                    else
                    leax      >FPDV45,pc
                    endc
                    stx       <$19,y
                    bsr       LOGEXP10
                    leax      ,y
                    leau      <$1B,y
                    ifne      B09RUNB
                    lbsr      L209F
                    lbsr      L21B4
                    else
                    lbsr      CMOVE
                    lbsr      CNORM
                    endc
                    leay      <$1A,y
                    puls      b
                    addb      1,y
                    bvs       FPOVRF
                    lda       #2
                    std       ,y
                    puls      pc,x

LOGEXP10            lda       #1
                    sta       <u009A
                    ifne      B09RUNB
                    leax      >L2242,pcr
                    else
                    leax      >L4D6F,pc
                    endc
                    stx       <u0095
                    leax      >$005F,x
                    stx       <u0097
                    ifne      B09RUNB
                    lbra      L206A
                    else
                    lbra      CORDIC
                    endc

FPOVRF              leay      -6,y
                    ifne      B09RUNB
                    lbpl      L15B0
                    ldb       #E$FltOvf
                    lbra      L1102
                    else
                    lbpl      L40DD
                    ldb       #$32
                    jsr       <u0024
                    fcb       $06
                    endc
