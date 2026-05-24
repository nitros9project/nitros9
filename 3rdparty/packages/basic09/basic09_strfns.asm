* String functions: LEN, ASC, CHR$, LEFT$, RIGHT$, MID$, TRIM$,
*                  SUBSTR, STR$, error, TAB, ENDS00
L4EAB               ldd       <u0048
                    ldu       1,y
                    subd      1,y
                    subd      #1
                    stu       <u0048
L4EB6               std       1,y
                    lda       #1
                    sta       ,y
                    rts

ASCFNC               ldd       1,y
                    std       <u0048
                    ldb       [<$01,y]
                    clra
                    bra       L4EB6

CHRFNC               ldd       1,y
                    tsta
                    lbne      L4FC7
                    ldu       <u0048
                    stu       1,y
                    stb       ,u+
                    lbsr      ENDS00
                    sty       <u0044
                    cmpu      <u0044
                    lbhs      L44C2
                    rts

L4EE2               ldd       1,y
                    ble       L4EF4
                    addd      7,y
                    tfr       d,u
                    cmpd      <u0048
                    bcc       L4EF1
                    bsr       L4F70
L4EF1               leay      6,y
                    rts

L4EF4               leay      6,y
                    ldu       1,y
                    bra       L4F70

RGTFNC               ldd       1,y
                    ble       L4EF4
                    pshs      x
                    ldd       <u0048
                    subd      1,y
                    subd      #1
                    cmpd      7,y
                    bls       RGTFN2
                    tfr       d,x
                    ldu       7,y
L4F10               lda       ,x+
                    sta       ,u+
                    cmpa      #$FF
                    bne       L4F10
                    stu       <u0048
RGTFN2               leay      6,y
                    puls      pc,x

MIDFNC               ldd       $01,y
                    ble       VARR05
                    ldd       $07,y
                    bgt       MIDFN2
VARR05               ldd       $01,y
                    leay      $06,y
                    std       $01,y
                    bra       L4EE2

MIDFN2               subd      #$0001
                    beq       VARR05
                    addd      $0D,y
                    cmpd      <u0048
                    bcs       MIDFN3
                    leay      $06,y
                    bra       L4EF4
MIDFN3               pshs      x
                    tfr       d,x
                    ldb       $02,y
                    ldu       $0D,y
L4F46               lda       ,x+
                    sta       ,u+
                    cmpa      #$FF
                    beq       MIDFN5
                    decb
                    bne       L4F46
                    dec       1,y
                    bpl       L4F46
                    lda       #$FF
                    sta       ,u+
MIDFN5               stu       <u0048
                    leay      $0C,y
                    puls      pc,x

TRMFNC               ldu       <u0048
                    leau      -1,u
TRMFN2               cmpu      $01,y
                    beq       L4F70
                    lda       ,-u
                    cmpa      #$20
                    beq       TRMFN2
                    leau      1,u
L4F70               lda       #$FF
                    sta       ,u+
                    stu       <u0048
                    rts

SUBFNC               pshs      y,x
                    ldd       <u0048
                    subd      1,y
                    addd      7,y
                    addd      #1
                    ldx       7,y
                    ldy       1,y
                    ifeq      INCLUDED&EDITOR
                    lbsr      L10FF
                    else
                    bsr       L3C29
                    endc
                    bcc       SUBF10
                    ifeq      INCLUDED&EDITOR
                    clra
                    clrb
                    else
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    endc
                    bra       SUBF20
                    ifeq      INCLUDED&EDITOR
                    else
L3C29               jsr       <u001B
                    fcb       $08
                    endc
SUBF10               tfr       y,d
                    ldx       2,s
                    subd      1,x
                    addd      #$0001
SUBF20               puls      y,x
                    std       7,y
                    lda       #1
                    sta       6,y
                    leay      6,y
                    rts

STRFNI               ldb       #$02
                    bra       STRF10

L4FA8               ldb       #$03
STRF10               lda       <u007D
                    ldu       <u0082
                    pshs      u,x,a
                    ifeq      INCLUDED&EDITOR
                    lbsr      L1105
                    else
                    lbsr      L011F
                    endc
                    bcs       L4FC7
                    ldx       <u0082
                    lda       #$FF
                    sta       ,x
                    ldx       $03,s
                    lbsr      STRLIT
                    puls      u,x,a
                    sta       <u007D
                    stu       <u0082
                    rts

L4FC7               ldb       #$43
                    ifeq      INCLUDED&EDITOR
                    lbra      L1102
                    else
                    jsr       <u0024
                    fcb       $06
                    endc

TABFNC               pshs      x
                    ldd       1,y
                    blt       L4FC7
                    sty       <u0044
                    ldu       <u0048
                    stu       $01,y
                    lda       #$20
TABF10               cmpb      <u007D
                    bls       ENDSTR
                    sta       ,u+
                    decb
                    cmpu      <u0044
                    blo       TABF10
                    lbra      L44C2

ENDS00               pshs      x
ENDSTR               lda       #$FF
                    sta       ,u+
                    stu       <u0048
                    lda       #$04
                    sta       ,y
                    puls      pc,x
