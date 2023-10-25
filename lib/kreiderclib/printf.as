* Disassembly by Os9disasm of printf.r

                    section   bss

* Uninitialized data (class B)
B0000               rmb       2
B0002               rmb       10
* Initialized Data (class G)
G0000               fcb       $27
                    fcb       $10
                    fcb       $03
                    fcb       $e8
                    fcb       $00
                    fcb       $64
                    fcb       $00
                    fcb       $0a

                    endsect

                    section   code

printf              pshs      u
                    leau      6,s
                    leax      _iob+13,y
                    ldd       4,s
                    bra       L0014
fprintf             pshs      u
                    leau      8,s
                    ldx       4,s
                    ldd       6,s
L0014               stx       B0000,y
                    leax      L024a,pcr
                    bra       L002e
sprintf             pshs      u
                    ldd       4,s
                    std       B0000,y
                    leau      8,s
                    ldd       6,s
                    leax      L0256,pcr
L002e               pshs      d,u
                    pshs      x
                    bsr       L003b
                    leas      6,s
                    puls      u,pc
L0038               leas      8,s
                    rts
L003b               ldu       4,s
                    leas      -8,s
                    bra       L004a
L0041               ldx       14,s
                    ldd       ,x++
                    stx       14,s
L0047               jsr       [10,s]
L004a               ldb       ,u+
                    beq       L0038
                    cmpb      #$25
                    bne       L0047
                    clrb
                    lda       #$7d
                    std       ,s
                    stb       7,s
                    stb       2,s
                    ldb       ,u+
                    cmpb      #$2d
                    bne       L0065
                    stb       7,s
                    ldb       ,u+
L0065               cmpb      #$30
                    beq       L006b
                    ldb       #$20
L006b               stb       6,s
                    ldb       -1,u
                    lbsr      L021f
                    std       3,s
                    ldb       ,u+
                    cmpb      #$2e
                    bne       L0085
                    stb       2,s
                    ldb       ,u+
                    lbsr      L021f
                    std       ,s
                    ldb       ,u+
L0085               cmpb      #$63
                    beq       L0041
                    pshs      u
                    cmpb      #$66
                    beq       L00c5
                    cmpb      #$65
                    beq       L00c5
                    cmpb      #$67
                    beq       L00c5
                    cmpb      #$45
                    beq       L00c5
                    cmpb      #$47
                    beq       L00c5
                    cmpb      #$6c
                    beq       L00e6
                    cmpb      #$73
                    beq       L0108
                    cmpb      #$64
                    beq       L0124
                    cmpb      #$6f
                    lbeq      L01ca
                    cmpb      #$78
                    lbeq      L0182
                    cmpb      #$58
                    lbeq      L0182
                    cmpb      #$75
                    beq       L0137
                    puls      u
                    bra       L0047
L00c5               ldd       5,s
                    pshs      d
                    leax      18,s
                    ldd       4,s
                    tst       6,s
                    bne       L00d5
                    ldd       #6
L00d5               pshs      d,x
                    ldd       #$7d00
                    std       8,s
                    ldb       -1,u
                    clra
                    pshs      d
                    lbsr      pffloat
                    bra       L0101
L00e6               pshs      u
                    ldx       18,s
                    ldd       2,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    leax      4,x
                    stx       22,s
                    ldb       ,u+
                    stu       6,s
                    pshs      d
                    lbsr      pflong
L0101               leas      8,s
                    tfr       d,u
                    lbra      L01b4
L0108               bsr       L0179
                    tfr       d,u
                    pshs      u
                    lbsr      strlen
                    leas      2,s
                    tst       4,s
                    beq       L011e
                    cmpd      2,s
                    bhi       L011e
                    std       2,s
L011e               lbsr      L01e9
                    lbra      L01b6
L0124               bsr       L0175
                    pshs      d,x,y,u
                    tsta
                    bpl       L013b
                    nega
                    negb
                    sbca      #0
                    std       ,s
                    ldb       #$2d
                    stb       ,u+
                    bra       L013b
L0137               bsr       L0175
                    pshs      d,x,y,u
L013b               ldd       #5
                    std       2,s
                    sta       4,s
                    leax      G0000,y
                    puls      d
                    bra       L0167
L014a               inc       ,s
L014c               subd      ,x
                    bcc       L014a
                    addd      ,x++
                    pshs      b
                    ldb       1,s
                    tst       3,s
                    bne       L015f
                    tstb
                    beq       L0163
                    inc       3,s
L015f               addb      #$30
                    stb       ,u+
L0163               clr       1,s
                    puls      b
L0167               dec       1,s
                    bne       L014c
                    addb      #$30
                    stb       ,u+
                    clr       ,u
                    leas      4,s
                    bra       L01b2
L0175               leau      B0002,y
L0179               ldx       18,s
                    ldd       ,x++
                    stx       18,s
                    rts
L0182               andb      #$20
                    stb       7,s
                    bsr       L0175
                    pshs      d,u
L018a               andb      #$0f
                    pshs      b
                    lda       #$30
                    cmpb      #9
                    ble       L0198
                    lda       #$37
                    adda      12,s
L0198               adda      ,s+
                    sta       ,u+
                    ldd       ,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       ,s
                    bne       L018a
L01aa               clr       ,u
                    ldx       2,s
                    bsr       frevers
                    leas      2,s
L01b2               puls      u
L01b4               bsr       L01e2
L01b6               puls      u
                    lbra      L004a
L01bb               ldb       ,x
                    lda       ,-u
                    sta       ,x+
                    stb       ,u
frevers             pshs      u
                    cmpx      ,s++
                    bcs       L01bb
                    rts
L01ca               bsr       L0175
                    pshs      d,u
L01ce               andb      #7
                    addb      #$30
                    stb       ,u+
                    ldd       ,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       ,s
                    bne       L01ce
                    bra       L01aa
L01e2               pshs      u
                    lbsr      strlen
                    leas      2,s
L01e9               nega
                    negb
                    sbca      #0
                    addd      7,s
                    std       7,s
                    tst       11,s
                    bne       L0200
                    bsr       L0215
                    bra       L0200
L01f9               ldb       ,u+
                    beq       L0209
                    jsr       [14,s]
L0200               ldd       4,s
                    subd      #1
                    std       4,s
                    bpl       L01f9
L0209               tst       11,s
                    beq       L020f
                    bsr       L0215
L020f               rts
L0210               ldb       12,s
                    jsr       [16,s]
L0215               ldd       9,s
                    subd      #1
                    std       9,s
                    bpl       L0210
                    rts
L021f               clr       ,-s
                    clr       ,-s
                    leau      -1,u
                    leax      _chcodes,y
                    bra       L0242
L022b               ldd       ,s
                    lslb
                    rola
                    std       ,s
                    lslb
                    rola
                    lslb
                    rola
                    addd      ,s
                    addb      ,u+
                    adca      #0
                    subd      #$0030
                    std       ,s
                    ldb       ,u
L0242               lda       b,x
                    anda      #8
                    bne       L022b
                    puls      d,pc
L024a               ldx       B0000,y
                    pshs      d,x
                    lbsr      putc
                    leas      4,s
                    rts
L0256               ldx       B0000,y
                    stb       ,x+
                    stx       B0000,y
                    clr       ,x
                    rts

                    endsect

