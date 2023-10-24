* Disassembly by Os9disasm of pflinit.r

* class D external label equates

D003b               equ       $003b

                    section   bss

* Uninitialized data (class B)
B0000               rmb       20
* Initialized Data (class G)
G0000               fcb       $3b
                    fcb       $9a
                    fcb       $ca
                    fcb       $00
                    fcb       $05
                    fcb       $f5
                    fcb       $e1
                    fcb       $00
                    fcb       $00
                    fcb       $98
                    fcb       $96
                    fcb       $80
                    fcb       $00
                    fcb       $0f
                    fcb       $42
                    fcb       $40
                    fcb       $00
                    fcb       $01
                    fcb       $86
                    fcb       $a0
                    fcb       $00
                    fcb       $00
                    fcb       $27
                    fcb       $10
                    fcb       $00
                    fcb       $00
                    fcb       $03
                    fcb       $e8
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $64
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $0a

                    endsect

                    section   code

pflinit             rts
pflong              pshs      u
                    leau      B0000,y
                    pshs      u
                    ldb       7,s
                    cmpb      #$64
                    beq       L0074
                    cmpb      #$6f
                    beq       L0023
                    cmpb      #$78
                    beq       L0049
                    cmpb      #$58
                    beq       L0049
                    lda       #$6c
                    std       ,u++
L001f               clr       ,u
                    puls      d,u,pc
L0023               leax      8,s
L0025               ldb       3,x
                    andb      #7
                    addb      #$30
                    stb       ,u+
                    ldb       #3
                    bsr       L0035
                    bne       L0025
                    bra       L006b
L0035               lsr       ,x
                    ror       1,x
                    ror       2,x
                    ror       3,x
                    decb
                    bne       L0035
                    lda       ,x
                    ora       1,x
                    ora       2,x
                    ora       3,x
                    rts
L0049               andb      #$20
                    pshs      b
                    leax      9,s
L004f               ldb       3,x
                    andb      #$0f
                    pshs      b
                    lda       #$30
                    cmpb      #9
                    ble       L005f
                    lda       #$37
                    adda      1,s
L005f               adda      ,s+
                    sta       ,u+
                    ldb       #4
                    bsr       L0035
                    bne       L004f
                    leas      1,s
L006b               ldx       ,s
                    clr       ,u
                    lbsr      frevers
                    puls      d,u,pc
L0074               ldb       8,s
                    bpl       L00a3
                    ldd       #0
                    subd      10,s
                    std       10,s
                    ldd       #0
                    sbcb      9,s
                    sbca      8,s
                    std       8,s
                    cmpd      #$8000
                    bne       L009f
                    ldd       2,x
                    bne       L009f
                    leax      >L00f1,pcr
L0096               lda       ,x+
                    sta       ,u+
                    bne       L0096
L009c               lbra      L001f
L009f               ldb       #$2d
                    stb       ,u+
L00a3               leax      G0000,y
                    clra
                    ldb       #$0a
                    pshs      a
                    pshs      d
                    bra       L00e3
L00b0               inc       ,s
L00b2               ldd       13,s
                    subd      2,x
                    std       13,s
                    ldd       11,s
                    sbcb      1,x
                    sbca      ,x
                    std       11,s
                    bcc       L00b0
                    ldd       13,s
                    addd      2,x
                    std       13,s
                    ldd       11,s
                    adcb      1,x
                    adca      ,x
                    std       11,s
                    ldb       ,s
                    tst       2,s
                    bne       L00db
                    tstb
                    beq       L00df
                    inc       2,s
L00db               addb      #$30
                    stb       ,u+
L00df               leax      4,x
                    clr       ,s
L00e3               dec       1,s
                    bne       L00b2
                    ldb       14,s
                    addb      #$30
                    stb       ,u+
                    leas      3,s
                    bra       L009c
L00f1               blt       L0125
                    leay      -12,y
                    pulu      b,x,y
                    fcb       $38
                    leau      -10,y
                    pshs      dp,x,y
                    fcb       $00

                    endsect

