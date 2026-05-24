                    ifne      B09RUNB
SQRT
L1AC8
SQRR05
                    else
SQRR05
                    endc
                    ldb       5,y
                    asrb
                    ifne      B09RUNB
                    lbcs      err67
                    else
                    lbcs      L4FC7
                    endc
                    ldb       #$1F
                    stb       <u006E
                    ldd       1,y
                    ifne      B09RUNB
                    beq       L1AC3
                    else
                    beq       RETBYT99
                    endc
                    inca
                    asra
                    sta       1,y
                    ldd       2,y
                    bcs       SQRT10
                    lsra
                    rorb
                    std       -4,y
                    ldd       4,y
                    rora
                    rorb
                    bra       SQRT20

SQRT10              std       -4,y
                    ldd       4,y
SQRT20              std       -2,y
                    clra
                    clrb
                    std       2,y
                    std       4,y
                    std       -6,y
                    std       -8,y
                    bra       SQRT40

SQRT30              orcc      #Carry
                    rol       5,y
                    rol       4,y
                    rol       3,y
                    rol       2,y
                    dec       <u006E
                    beq       SQRT60
                    bsr       SQRT70
SQRT40              ldb       -4,y
                    subb      #$40
                    stb       -4,y
                    ldd       -6,y
                    sbcb      5,y
                    sbca      4,y
                    std       -6,y
                    ldd       -8,y
                    sbcb      3,y
                    sbca      2,y
                    std       -8,y
                    bpl       SQRT30
SQRT50              andcc     #^Carry
                    rol       5,y
                    rol       4,y
                    rol       3,y
                    rol       2,y
                    dec       <u006E
                    beq       SQRT60
                    bsr       SQRT70
                    ldb       -4,y
                    addb      #$C0
                    stb       -4,y
                    ldd       -6,y
                    adcb      5,y
                    adca      4,y
                    std       -6,y
                    ldd       -8,y
                    adcb      3,y
                    adca      2,y
                    std       -8,y
                    bmi       SQRT50
                    bra       SQRT30

SQRT60              ldd       2,y
                    bra       SQRT65

SQRT62              dec       1,y
                    ifne      B09RUNB
                    lbvs      L15B0
                    else
                    lbvs      L40DD
                    endc
SQRT65              lsl       5,y
                    rol       4,y
                    rolb
                    rola
                    bpl       SQRT62
                    std       2,y
                    rts

SQRT70              bsr       SQRT72
SQRT72              lsl       -1,y
                    rol       -2,y
                    rol       -3,y
                    rol       -4,y
                    rol       -5,y
                    rol       -6,y
                    rol       -7,y
                    rol       -8,y
                    rts
