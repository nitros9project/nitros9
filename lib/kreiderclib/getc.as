* Disassembly by Os9disasm of getc.r

                    section   code

getc                pshs      u
                    ldu       4,s
                    beq       L005f
                    lda       6,u
                    anda      #1
                    bne       L005f
                    ldx       ,u
                    cmpx      4,u
                    bcc       L0064
L0012               ldb       ,x+
L0014               stx       ,u
                    clra
                    puls      u,pc
ungetc              pshs      u
                    ldu       6,s
                    beq       L005f
                    ldb       7,u
                    andb      #1
                    beq       L005f
                    ldd       4,s
                    cmpd      #-1
                    beq       L005f
                    ldx       ,u
                    cmpx      2,u
                    beq       L005f
                    stb       ,-x
                    bra       L0014
getw                pshs      u
                    ldu       4,s
                    pshs      u,pc
                    bsr       getc
                    std       2,s
                    cmpd      #-1
                    beq       L0051
                    bsr       getc
                    cmpd      #-1
                    beq       L0051
                    lda       3,s
L0051               leas      4,s
                    puls      u,pc
L0055               ldb       #$10
                    bra       L005b
L0059               ldb       #$20
L005b               orb       7,u
                    stb       7,u
L005f               ldd       #-1
                    puls      u,pc
L0064               ldd       6,u
                    anda      #$80
                    andb      #$31
                    cmpb      #1
                    bne       L005f
                    cmpa      #$80
                    beq       L0079
                    pshs      u
                    lbsr      _setbase
                    leas      2,s
L0079               leax      _iob,y
                    pshs      x
                    cmpu      ,s++
                    bne       L0095
                    ldb       7,u
                    andb      #$40
                    beq       L0095
                    leax      _iob+13,y
                    pshs      x
                    lbsr      fflush
                    leas      2,s
L0095               ldb       7,u
                    andb      #8
                    beq       L00b0
                    ldd       11,u
                    pshs      d
                    ldx       2,u
                    ldd       8,u
                    pshs      d,x
                    ldb       7,u
                    andb      #$40
                    beq       L00bd
                    lbsr      readln
                    bra       L00c0
L00b0               ldd       #1
                    pshs      d
                    leax      10,u
                    stx       2,u
                    ldd       8,u
                    pshs      d,x
L00bd               lbsr      read
L00c0               leas      6,s
                    std       -2,s
                    beq       L0055
                    bmi       L0059
                    ldx       2,u
                    leax      d,x
                    stx       4,u
                    ldx       2,u
                    lbra      L0012

                    endsect

