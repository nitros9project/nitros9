                    ifne      B09RUNB
MODrl
L1B7D
                    else
MODFNR
                    endc
                    leau      -12,y
                    pshs      y
MODF10              ldd       ,y++
                    std       ,u++
                    cmpu      ,s
                    bne       MODF10
                    leas      2,s
                    leay      -12,u
                    ifne      B09RUNB
                    lbsr      RLDIV
                    bsr       INTrl1
                    lbsr      RLMUL
                    lbra      L147E
                    else
                    lbsr      L422D
                    bsr       INTFNR
                    lbsr      L40CC
                    lbra      L3FAB
                    endc

                    ifne      B09RUNB
INTrl
INTrl1
                    else
INTFNR
                    endc
                    lda       1,y
                    bgt       INTF20
                    clra
                    clrb
                    std       1,y
                    std       3,y
                    stb       5,y
INTF10              rts

INTF20              cmpa      #$1F
                    bcc       INTF10
                    leau      6,y
                    ldb       -1,u
                    andb      #$01
                    pshs      u,b
                    leau      1,y
INTF30              leau      1,u
                    suba      #$08
                    bcc       INTF30
                    beq       INTF50
                    ldb       #$FF
INTF40              lslb
                    inca
                    bne       INTF40
                    andb      ,u
                    stb       ,u+
                    bra       INTF70

INTF50              leau      1,u
INTF60              sta       ,u+
INTF70              cmpu      1,s
                    bne       INTF60
                    puls      u,b
                    orb       5,y
                    stb       5,y
                    rts

                    ifne      B09RUNB
SQint
                    else
SQFNCI
                    endc
                    leay      -6,y
                    ldd       7,y
                    std       1,y
                    ifne      B09RUNB
                    lbra      INTMUL
                    else
                    lbra      INMUL
                    endc

                    ifne      B09RUNB
SQrl
                    else
L470E
                    endc
                    leay      -6,y
                    ldd       10,y
                    std       4,y
                    ldd       8,y
                    std       2,y
                    ldd       6,y
                    std       ,y
                    ifne      B09RUNB
                    lbra      RLMUL
                    else
                    lbra      L40CC
                    endc

                    ifne      B09RUNB
VAL
                    else
L471F
                    endc
                    ldd       <u0080
                    ldu       <u0082
                    pshs      u,d
                    ldd       1,y
                    std       <u0080
                    std       <u0082
                    std       <u0048
                    leay      6,y
                    ldb       #9
                    ifne      B09RUNB
                    lbsr      L1105
                    else
                    lbsr      L011F
                    endc
                    puls      u,d
                    std       <u0080
                    stu       <u0082
                    ifne      B09RUNB
                    lbcs      L4FC7
                    else
                    lbcs      L4FC7
                    endc
                    rts

                    ifne      B09RUNB
ADDR
                    else
ADRFNC
                    endc
                    ifne      B09RUNB
                    lbsr      L1224
                    else
                    lbsr      EVAL20
                    endc
                    leay      -6,y
                    stu       1,y
                    ifne      B09RUNB
L1C19
                    else
ADRF10
                    endc
                    lda       #1
                    sta       ,y
                    leax      1,x
                    rts

                    ifne      B09RUNB
L1C20
                    else
L474D
                    endc
                    fcb       1,2,5,1

                    ifne      B09RUNB
SIZE
                    else
L4751
                    endc
                    ifne      B09RUNB
                    lbsr      L1224
                    else
                    lbsr      EVAL20
                    endc
                    leay      -6,y
                    cmpa      #4
                    bcc       SIZE10
                    ifne      B09RUNB
                    leau      >L1C20,pcr
                    else
                    leau      <L474D,pc
                    endc
                    ldb       a,u
                    clra
                    bra       SIZE20
SIZE10              ldd       <u003E
SIZE20              std       1,y
                    ifne      B09RUNB
                    bra       L1C19
                    else
                    bra       ADRF10
                    endc

                    ifne      B09RUNB
equTRUE
                    else
L4769
                    endc
                    ldd       #$00FF
                    bra       BOOL10

                    ifne      B09RUNB
equFALSE
                    else
L476E
                    endc
                    ldd       #$0000
BOOL10              leay      -6,y
                    std       1,y
                    lda       #3
                    sta       ,y
                    rts

                    ifne      B09RUNB
LNOTI
                    else
NOTFNC
                    endc
                    com       1,y
                    com       2,y
                    rts

                    ifne      B09RUNB
LANDI
                    else
ANDFNC
                    endc
                    ldd       1,y
                    anda      7,y
                    andb      8,y
                    bra       LOGIC10

                    ifne      B09RUNB
LXORI
                    else
ORFNC
                    endc
                    ldd       1,y
                    eora      7,y
                    eorb      8,y
                    bra       LOGIC10

                    ifne      B09RUNB
LORI
                    else
L478F
                    endc
                    ldd       1,y
                    ora       7,y
                    orb       8,y
LOGIC10             std       7,y
                    leay      6,y
                    rts
