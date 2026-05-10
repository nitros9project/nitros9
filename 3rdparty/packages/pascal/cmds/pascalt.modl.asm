********************************************************************
* progname - program module
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*  -     Original Pascal 2.0 distribution version
*
* $Log$
* Revision 1.1  2002/04/05 08:23:28  roug
* Checked in Pascal 2.0
*
*

                    nam       PascalT.MODL
                    ttl       subroutine module

* Disassembled 02/04/05 10:06:04 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       /dd/defs/os9defs
                    endc
tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $02
                    mod       eom,name,tylg,atrv,start,size
u0000               rmb       0
size                equ       .
name                equ       *
                    fcs       /PascalT.MODL/
                    fcb       $02
start               equ       *
                    lbra      L0068
                    lbra      L0079
                    lbra      L0089
                    lbra      L00D9
                    lbra      L0119
                    lbra      L01A3
                    lbra      L01E2
                    lbra      L0221
                    lbra      L0260
                    lbra      L029F
                    lbra      L02DE
                    lbra      L0324
                    lbra      L03B0
                    lbra      L03F9
                    lbra      L044A
                    lbra      L04CA
                    lbra      L0539
                    lbra      L058B
                    lbra      L05E0
                    lbra      L062B
                    lbra      L0699
                    lbra      L06DD
                    lbra      L074A
                    lbra      L07B7
                    lbra      L0824
                    lbra      L0891
L0068               leax      >-$082B,y
                    ldd       $04,s
                    ldb       d,x
                    sex
                    std       $06,s
                    ldx       ,s
                    leas      $06,s
                    jmp       ,x
L0079               leax      >-$082B,y
                    ldd       $04,s
                    ldd       d,x
                    std       $06,s
                    ldx       ,s
                    leas      $06,s
                    jmp       ,x
L0089               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    leas      -$02,s
                    ldd       <u000A
                    pshs      b,a
                    clra
                    clrb
                    std       -$02,u
L009D               ldx       $07,u
                    ldd       -$02,u
                    ldb       d,x
                    subb      #$20
                    beq       L00B0
                    ldd       -$02,u
                    addd      #$0001
                    std       -$02,u
                    bra       L009D
L00B0               ldd       -$02,u
                    beq       L00C9
                    ldx       $07,u
                    ldd       -$02,u
                    pshs      x,b,a
                    ldd       #$000A
                    pshs      b,a
                    leax      >-$069A,y
                    pshs      x
                    ldx       <u0004
                    jsr       -$03,x
L00C9               puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $04,s
                    jmp       ,x
L00D9               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
L00E7               ldd       -$06,y
                    beq       L00F7
                    ldx       $05,u
                    pshs      x
                    ldb       #$04
                    ldx       <u001A
                    jsr       ,x
                    bra       L00E7
L00F7               puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $02,s
                    jmp       ,x
L0107               bra       L0129
                    bra       L012B
                    bra       L012D
                    bra       L012F
                    bra       L0131
                    bra       L0133
                    bra       L0135
                    bra       L0137
                    bra       L0139
L0119               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    ldd       -$06,y
L0129               subd      #$0020
                    bne       L0138
                    ldx       $05,u
                    pshs      x
                    ldb       #$04
                    ldx       <u001A
                    jsr       ,x
L0138               leax      >-$0109,y
                    ldd       -$04,y
                    lslb
                    rola
                    ldd       d,x
                    std       -$04,y
                    leax      >-$0389,y
                    ldd       -$04,y
                    lslb
                    rola
                    lslb
                    rola
                    pshs      b,a
                    lslb
                    rola
                    lslb
                    rola
                    addd      ,s++
                    leax      d,x
                    pshs      x
                    leax      <-$4A,y
                    pshs      x
                    lbsr      L08D4
                    neg       <u0014
                    ldd       -$06,y
                    addd      #$0001
                    std       -$06,y
                    leax      <-$4A,y
                    pshs      x
                    leax      <L0107,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0012
                    ldd       #$0000
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$03
                    ldx       <u001A
                    jsr       ,x
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $02,s
                    jmp       ,x
L019A               negb
                    comb
                    lsla
                    comb
                    bra       L01C0
                    bra       L01C2
                    lsra
L01A3               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    leax      <-$4A,y
                    pshs      x
                    leax      <L019A,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0009
L01C0               ldx       $05,u
L01C2               pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $02,s
                    jmp       ,x
L01D9               negb
                    fcb       $55                 U
                    inca
                    comb
                    bra       L01FF
                    bra       L0201
                    lsra
L01E2               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    leax      <-$4A,y
                    pshs      x
                    leax      <L01D9,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0009
L01FF               ldx       $05,u
L0201               pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $02,s
                    jmp       ,x
L0218               negb
                    comb
                    lsla
                    comb
                    bra       L023E
                    bra       L0240
                    fcb       $42                 B
L0221               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    leax      <-$4A,y
                    pshs      x
                    leax      <L0218,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0009
L023E               ldx       $05,u
L0240               pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $02,s
                    jmp       ,x
L0257               negb
                    comb
                    lsla
                    comb
                    bra       L027D
                    bra       L027F
                    lslb
L0260               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    leax      <-$4A,y
                    pshs      x
                    leax      <L0257,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0009
L027D               ldx       $05,u
L027F               pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $02,s
                    jmp       ,x
L0296               negb
                    fcb       $55                 U
                    inca
                    comb
                    bra       L02BC
                    bra       L02BE
                    fcb       $42                 B
L029F               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    leax      <-$4A,y
                    pshs      x
                    leax      <L0296,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0009
L02BC               ldx       $05,u
L02BE               pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $02,s
                    jmp       ,x
L02D5               negb
                    fcb       $55                 U
                    inca
                    comb
                    bra       L02FB
                    bra       L02FD
                    lslb
L02DE               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    leax      <-$4A,y
                    pshs      x
                    leax      <L02D5,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0009
L02FB               ldx       $05,u
L02FD               pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $02,s
                    jmp       ,x
L0314               bra       L0362
                    lsra
                    lslb
                    bra       L034F
                    bge       L0371
L031C               bra       L036A
                    lsra
                    lslb
                    bra       L0357
                    bge       L037C
L0324               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    leas      -$04,s
                    ldd       <u000A
                    pshs      b,a
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L00D9
                    leax      <L0314,pcr
                    ldd       #$0008
                    pshs      x,b,a
                    pshs      b,a
                    leax      >-$069A,y
                    pshs      x
                    ldx       <u0004
L034F               jsr       -$03,x
                    leax      >-$069A,y
                    pshs      x
L0357               clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
                    ldd       #$0002
                    std       -$02,u
L0362               ldd       $07,u
                    std       -$04,u
                    ldd       -$02,u
                    subd      -$04,u
L036A               bgt       L039B
L036C               leax      <L031C,pcr
                    ldd       #$0008
                    pshs      x,b,a
                    pshs      b,a
                    leax      >-$069A,y
                    pshs      x
L037C               ldx       <u0004
                    jsr       -$03,x
                    leax      >-$069A,y
                    pshs      x
                    clr       $0D,x
                    ldx       <u0004
                    jsr       -$09,x
                    ldd       -$02,u
                    subd      -$04,u
                    bge       L039B
                    ldd       -$02,u
                    addd      #$0001
                    std       -$02,u
                    bra       L036C
L039B               puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $04,s
                    jmp       ,x
L03AB               inca
                    lsra
                    lsra
                    bra       L03D3
L03B0               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    leax      <-$4A,y
                    pshs      x
                    leax      <L03AB,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0005
                    ldd       $07,u
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
L03E1               lbsr      L01A3
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $04,s
                    jmp       ,x
L03F4               inca
                    lsra
                    fcb       $42                 B
                    bra       L041C
L03F9               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    leax      <-$4A,y
                    pshs      x
                    leax      <L03F4,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0005
                    ldd       $07,u
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
L0424               ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0221
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $04,s
                    jmp       ,x
L043D               rola
                    fcb       $4E                 N
                    coma
                    bra       L048B
                    bra       L0487
                    comb
L0445               fcb       $41                 A
                    lsra
                    lsra
                    fcb       $42                 B
                    bls       L03E1
                    bra       L0424
                    bra       L0483
                    aim       #$34,<u0040
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    ldd       $07,u
                    subd      #$0001
                    bne       L047E
                    leax      <-$4A,y
                    pshs      x
                    leax      <L043D,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0008
                    clra
                    clrb
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    bra       L04AD
L047E               ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L029F
L0487               leax      <-$4A,y
                    pshs      x
                    leax      <L0445,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0005
                    ldd       $07,u
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
L04A4               ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0221
L04AD               puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $04,s
                    jmp       ,x
L04BD               lsra
                    fcb       $45                 E
                    coma
                    bra       L050B
                    bra       L0507
                    comb
L04C5               comb
                    fcb       $55                 U
                    fcb       $42                 B
                    fcb       $42                 B
                    bls       L0461
                    bra       L04A4
                    bra       L0503
                    aim       #$34,<u0040
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    ldd       $07,u
                    subd      #$0001
                    bne       L04FE
                    leax      <-$4A,y
                    pshs      x
                    leax      <L04BD,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0008
                    clra
                    clrb
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    bra       L0524
L04FE               leax      <-$4A,y
                    pshs      x
L0503               leax      <L04C5,pcr
                    pshs      x
                    lbsr      L08D4
L050B               neg       <u0005
                    ldd       $07,u
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0221
L0524               puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $04,s
                    jmp       ,x
L0534               fcb       $41                 A
                    lsra
                    lsra
                    lsra
                    bls       L04D0
                    bra       L0513
                    bra       L0572
                    aim       #$34,<u0040
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L01E2
                    leax      <-$4A,y
                    pshs      x
                    leax      <L0534,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0005
                    ldd       $07,u
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L01A3
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $04,s
                    jmp       ,x
L0586               comb
                    fcb       $55                 U
                    fcb       $42                 B
                    lsra
                    bls       L0522
                    bra       L0565
                    bra       L05C4
                    aim       #$34,<u0040
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L01E2
                    leax      <-$4A,y
                    pshs      x
                    leax      <L0586,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0005
                    ldd       $07,u
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L01A3
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $04,s
                    jmp       ,x
L05D8               inca
                    fcb       $45                 E
                    fcb       $41                 A
                    lslb
                    rola
                    bra       L0622
                    rolb
L05E0               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    leax      <-$4A,y
                    pshs      x
                    leax      <L05D8,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0008
                    ldd       $07,u
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0260
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $04,s
L0622               jmp       ,x
L0624               inca
                    fcb       $45                 E
                    fcb       $41                 A
                    lslb
                    rola
                    bra       L066E
L062B               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    leas      -$01,s
                    ldd       <u000A
                    pshs      b,a
                    ldd       $09,u
                    beq       L0652
                    ldd       $09,u
                    pshs      b,a
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0324
                    ldb       #$58
                    stb       -$01,u
                    bra       L0656
L0652               ldb       #$55
                    stb       -$01,u
L0656               leax      <-$4A,y
                    pshs      x
                    leax      <L0624,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0007
                    ldb       -$01,u
                    stb       <-$43,y
                    ldd       $07,u
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0260
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $06,s
                    jmp       ,x
L0691               inca
                    fcb       $45                 E
                    fcb       $41                 A
                    comb
                    rola
                    bra       L06DB
                    comb
L0699               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    leax      <-$4A,y
                    pshs      x
                    leax      <L0691,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0008
                    clra
                    clrb
                    subd      $07,u
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $04,s
                    jmp       ,x
L06D6               comb
                    lsrb
                    fcb       $42                 B
                    bra       L0724
L06DB               bra       L0720
L06DD               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    leas      -$01,s
                    ldd       <u000A
                    pshs      b,a
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L029F
                    ldd       $09,u
                    beq       L070D
                    ldd       $09,u
                    pshs      b,a
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0324
                    ldb       #$58
                    stb       -$01,u
                    bra       L0711
L070D               ldb       #$55
                    stb       -$01,u
L0711               leax      <-$4A,y
                    pshs      x
                    leax      <L06D6,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0007
L0720               ldb       -$01,u
                    stb       <-$43,y
                    ldd       $07,u
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $06,s
                    jmp       ,x
L0743               inca
                    lsra
                    fcb       $42                 B
                    bra       L0791
                    bra       L078D
L074A               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    leas      -$01,s
                    ldd       <u000A
                    pshs      b,a
                    ldd       $09,u
                    beq       L0771
                    ldd       $09,u
                    pshs      b,a
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0324
                    ldb       #$58
                    stb       -$01,u
                    bra       L0775
L0771               ldb       #$55
                    stb       -$01,u
L0775               leax      <-$4A,y
                    pshs      x
                    leax      <L0743,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0007
                    ldb       -$01,u
                    stb       <-$43,y
                    ldd       $07,u
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0221
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $06,s
                    jmp       ,x
L07B0               comb
                    lsrb
                    lsra
                    bra       L07FE
                    bra       L07FA
L07B7               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    leas      -$01,s
                    ldd       <u000A
                    pshs      b,a
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L01E2
                    ldd       $09,u
                    beq       L07E7
                    ldd       $09,u
                    pshs      b,a
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0324
                    ldb       #$58
                    stb       -$01,u
                    bra       L07EB
L07E7               ldb       #$55
                    stb       -$01,u
L07EB               leax      <-$4A,y
                    pshs      x
                    leax      <L07B0,pcr
                    pshs      x
                    lbsr      L08D4
                    neg       <u0007
L07FA               ldb       -$01,u
                    stb       <-$43,y
                    ldd       $07,u
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $06,s
                    jmp       ,x
L081D               inca
                    lsra
                    lsra
                    bra       L086B
                    bra       L0867
L0824               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    leas      -$01,s
                    ldd       <u000A
                    pshs      b,a
                    ldd       $09,u
                    beq       L084B
                    ldd       $09,u
                    pshs      b,a
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0324
                    ldb       #$58
                    stb       -$01,u
                    bra       L084F
L084B               ldb       #$55
                    stb       -$01,u
L084F               leax      <-$4A,y
                    pshs      x
                    leax      <L081D,pcr
                    pshs      x
                    bsr       L08D4
                    neg       <u0007
                    ldb       -$01,u
                    stb       <-$43,y
                    ldd       $07,u
                    std       <-$38,y
L0867               ldx       $05,u
                    pshs      x
L086B               ldb       #$FF
                    lbsr      L0119
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L01A3
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $06,s
                    jmp       ,x
L0889               inca
                    lsra
                    lsra
                    bra       L08D7
                    bra       L08D3
                    rolb
L0891               lda       <u0020
                    stb       <u0020
                    pshs      a
                    pshs      u
                    leau      ,s
                    ldd       <u000A
                    pshs      b,a
                    leax      <-$4A,y
                    pshs      x
                    leax      <L0889,pcr
                    pshs      x
                    bsr       L08D4
                    neg       <u0008
                    ldd       $07,u
                    std       <-$38,y
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L0119
                    ldx       $05,u
                    pshs      x
                    ldb       #$FF
                    lbsr      L01A3
                    puls      b,a
                    std       <u000A
                    leas      ,u
                    puls      u
                    puls      x,a
                    sta       <u0020
                    leas      $04,s
                    jmp       ,x
L08D4               ldd       [,s]
                    pshs      u,y
                    ldx       $06,s
                    ldu       $08,s
                    tfr       d,y
                    bitb      #$01
                    beq       L08EA
                    ldb       ,x+
                    stb       ,u+
                    leay      -$01,y
                    beq       L08F2
L08EA               ldd       ,x++
                    std       ,u++
                    leay      -$02,y
                    bne       L08EA
L08F2               puls      u,y
                    ldx       ,s
                    leas      $06,s
                    jmp       $02,x
                    emod
eom                 equ       *
