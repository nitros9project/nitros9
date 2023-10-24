* Disassembly by Os9disasm of fopen.r

                    section   code

L0000               pshs      d
                    stu       -2,s
                    bne       L0022
                    leau      _iob,y
                    lda       #$10
L000c               ldb       7,u
                    andb      #3
                    beq       L0022
                    leau      13,u
                    deca
                    bne       L000c
                    ldd       #$00c8
                    std       errno,y
                    clra
                    clrb
                    puls      x,pc
L0022               puls      d
                    std       8,u
                    ldd       1,x
                    tsta
                    beq       L0037
                    cmpa      #$2b
                    beq       L0033
                    cmpb      #$2b
                    bne       L0037
L0033               ldb       #3
                    bra       L0047
L0037               ldb       ,x
                    cmpb      #$72
                    beq       L0041
                    cmpb      #$64
                    bne       L0045
L0041               ldb       #1
                    bra       L0047
L0045               ldb       #2
L0047               orb       7,u
                    stb       7,u
                    ldd       2,u
                    addd      11,u
                    std       ,u
                    std       4,u
                    tfr       u,d
                    rts
L0056               clra
                    clrb
                    pshs      d,u
                    ldd       1,x
                    tsta
                    beq       L007a
                    cmpa      #$78
                    bne       L0071
                    cmpb      #$2b
                    bne       L006c
                    ldd       #7
                    bra       L0078
L006c               ldd       #4
                    bra       L0078
L0071               cmpa      #$2b
                    bne       L00c7
                    ldd       #3
L0078               std       ,s
L007a               ldb       ,x
                    cmpb      #$72
                    bne       L0086
                    ldd       ,s
                    orb       #1
                    bra       L00d7
L0086               cmpb      #$61
                    bne       L00b2
                    ldd       ,s
                    orb       #2
                    pshs      d
                    pshs      u
                    lbsr      open
                    leas      4,s
                    std       2,s
                    cmpd      #-1
                    beq       L00b6
                    ldu       #2
                    ldx       #0
                    pshs      x,u
                    pshs      d,x
                    lbsr      lseek
                    puls      d
                    leas      6,s
                    bra       L00e0
L00b2               cmpb      #$77
                    bne       L00c3
L00b6               ldd       ,s
                    orb       #2
                    pshs      d
                    pshs      u
                    lbsr      creat
                    bra       L00de
L00c3               cmpb      #$64
                    beq       L00d3
L00c7               ldd       #$00cb
                    std       errno,y
                    ldd       #-1
                    bra       L00e0
L00d3               ldd       ,s
                    orb       #$81
L00d7               pshs      d
                    pshs      u
                    lbsr      open
L00de               leas      4,s
L00e0               leas      4,s
                    rts
fdopen              pshs      u
                    ldu       #0
                    ldx       6,s
                    ldd       4,s
                    bra       L011c
fopen               pshs      u
                    ldx       6,s
                    ldu       4,s
                    lbsr      L0056
                    ldu       #0
                    std       -2,s
                    bpl       L011a
L00fe               clra
                    clrb
                    puls      u,pc
freopen             pshs      u
                    ldd       8,s
                    pshs      d
                    lbsr      fclose
                    leas      2,s
                    ldx       6,s
                    ldu       4,s
                    lbsr      L0056
                    std       -2,s
                    bmi       L00fe
                    ldu       8,s
L011a               ldx       6,s
L011c               lbsr      L0000
                    puls      u,pc

                    endsect

