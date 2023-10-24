                    nam       Raaka-Tu
                    ttl       program module

* Disassembled 2004/07/13 07:31:17 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       os9.d
                    endc

THEOS9WAY           equ       1

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00

                    ifeq      THEOS9WAY
OS9Offset           equ       $00
SubOffset           equ       $600-$2C
                    else
OS9Offset           equ       $C000
SubOffset           equ       OS9Offset
                    endc


                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       1
u0001               rmb       1
u0002               rmb       1
u0003               rmb       1
u0004               rmb       1
u0005               rmb       1
u0006               rmb       1
u0007               rmb       1
u0008               rmb       1
u0009               rmb       1
u000A               rmb       1
u000B               rmb       1
u000C               rmb       1
u000D               rmb       1
u000E               rmb       1
u000F               rmb       1
u0010               rmb       1
u0011               rmb       1
u0012               rmb       1
u0013               rmb       1
u0014               rmb       1
u0015               rmb       1
u0016               rmb       1
u0017               rmb       1
u0018               rmb       1
u0019               rmb       1
u001A               rmb       1
u001B               rmb       1
u001C               rmb       1
u001D               rmb       1
u001E               rmb       1
u001F               rmb       1
u0020               rmb       1
u0021               rmb       1
u0022               rmb       1
u0023               rmb       1
u0024               rmb       1
u0025               rmb       1
u0026               rmb       1
u0027               rmb       1
u0028               rmb       1
u0029               rmb       1
u002A               rmb       1
u002B               rmb       1
u002C               rmb       1
u002D               rmb       1
u002E               rmb       1
u002F               rmb       1
u0030               rmb       2
u0032               rmb       1
u0033               rmb       1
u0034               rmb       1
u0035               rmb       1
u0036               rmb       1
u0037               rmb       1
u0038               rmb       1
u0039               rmb       1
u003A               rmb       1
u003B               rmb       1
u003C               rmb       2
u003E               rmb       1
u003F               rmb       1
u0040               rmb       1
u0041               rmb       1
u0042               rmb       1
u0043               rmb       1
u0044               rmb       1
u0045               rmb       1
u0046               rmb       1
u0047               rmb       2
u0049               rmb       2
u004B               rmb       1
u004C               rmb       1
u004D               rmb       1
u004E               rmb       1
u004F               rmb       1
u0050               rmb       1
u0051               rmb       1
u0052               rmb       1
u0053               rmb       1
u0054               rmb       1
u0055               rmb       1
u0056               rmb       1
u0057               rmb       1
u0058               rmb       1
u0059               rmb       1
u005A               rmb       1
u005B               rmb       1
u005C               rmb       3
u005F               rmb       1
u0060               rmb       1
u0061               rmb       1
u0062               rmb       1
u0063               rmb       1
u0064               rmb       2
u0066               rmb       1
u0067               rmb       1
u0068               rmb       1
u0069               rmb       1
u006A               rmb       1
u006B               rmb       1
u006C               rmb       2
u006E               rmb       1
u006F               rmb       1
u0070               rmb       1
u0071               rmb       1
u0072               rmb       1
u0073               rmb       3
u0076               rmb       1
u0077               rmb       1
u0078               rmb       1
u0079               rmb       1
u007A               rmb       1
u007B               rmb       3
u007E               rmb       2
u0080               rmb       1
u0081               rmb       1
u0082               rmb       1
u0083               rmb       1
u0084               rmb       1
u0085               rmb       1
u0086               rmb       1
u0087               rmb       1
u0088               rmb       1
u0089               rmb       1
u008A               rmb       1
u008B               rmb       1
u008C               rmb       1
u008D               rmb       2
u008F               rmb       1
u0090               rmb       1
                    rmb       $8000-.
size                equ       .

name                equ       *
                    fcs       /Raaka-Tu/
                    fcb       $04

start               equ       *
                    ifeq      THEOS9WAY
                    ldx       #$600
                    leay      realstart,pcr
                    ldd       #realsize
copyloop            ldu       ,y++
                    stu       ,x++
                    subd      #$0002
                    bgt       copyloop

                    jmp       >$0600
                    endc

realstart
                    ifeq      THEOS9WAY
* Clear screen at $400
                    clra
                    ldx       #$0400
                    ldu       #$6060
L0607               stu       ,x++
                    deca
                    bne       L0607
                    endc
* Set up stack at #$03FF
L060C               lds       #$03FF
                    lda       #$1D
                    sta       >$01D2
                    ldx       #$05E0
                    stx       <u0088
                    ldb       #$96
                    stb       >$01D5
                    ifne      THEOS9WAY
                    leax      L1523,pc
                    else
                    ldx       #$1523
                    endc
                    lbsr      L0A1F
                    stx       >$01D6
                    lbsr      X2
                    lda       #$0D
                    lbsr      X3
L0630               lds       #$03FF
                    lbsr      L0ACC
L0637               clr       >$01B7
                    clr       >$01BA
                    clr       >$01BB
                    clr       >$01B2
                    clr       >$01B3
                    clr       >$01B9
                    clr       >$01B8
                    clr       >$01B4
                    clr       >$01B5
                    clr       >$01BF
                    clr       >$01C3
                    clr       >$01C9
                    ldb       #$1D
                    stb       >$01D2
                    lbsr      X4
                    stx       >$01D3
                    lbsr      L0A42
                    ldb       ,x
                    stb       >$01D5

                    ifne      THEOS9WAY
                    leax      L1523,pc
                    else
                    ldx       #$1523
                    endc

                    lbsr      L0A1F
                    stx       >$01D6
                    ldx       #$01E3
                    stx       >$01D8
                    clr       ,x
                    ldx       #$05E0
L0682               lbsr      L0B42
                    beq       L0692
L0687               lda       ,x+
                    cmpa      #$60
                    beq       L0682
                    cmpx      #$0600
                    bne       L0687
L0692               cmpx      #$0600
                    bne       L0682
                    clr       [>$01D8]
                    ldx       #$01E3
                    lda       ,x
                    lbeq      L0736
                    cmpa      #$02
                    bne       L06B7
                    leax      $01,x
                    lda       ,x
                    leax      -$01,x
                    cmpa      #$06
                    bcc       L06B7
                    sta       >$01B8
                    leax      $03,x
L06B7               lda       ,x+
                    beq       L0736
                    ldb       ,x
                    ldu       ,x++
                    pshs      x
                    deca
                    bne       L06E5

                    ifne      THEOS9WAY
                    leax      L1333-1,pc
                    else
                    ldx       #$1332
                    endc

                    lbsr      L0A1F
                    bcc       L06DF
                    lbsr      L0A42
L06CF               lbsr      X5
                    tfr       b,a
                    bcc       L06DF
                    ldb       ,x+
                    lda       ,x+
                    cmpb      >$01B3
                    bne       L06CF
L06DF               stb       >$01B3

                    ifne      THEOS9WAY
                    lbra      L0731
                    else
                    jmp       >$0731
                    endc

L06E5               deca
                    bne       L071E
                    tst       >$01B5
                    beq       L070D
                    ldx       #$01C9
L06F0               stb       ,x+
                    lda       >$01B7
                    sta       ,x+
                    lda       >$01BA
                    sta       ,x
                    bne       L0702
                    tfr       u,d
                    stb       ,x
L0702               clr       >$01B7
                    clr       >$01B5
                    clr       >$01BA
                    bra       L0731
L070D               ldx       >$01C3
                    stx       >$01C9
                    ldx       >$01C5
                    stx       >$01CB
                    ldx       #$01C3
                    bra       L06F0
L071E               deca
                    bne       L072B
                    stb       >$01B7
                    tfr       u,d
                    stb       >$01BA
                    bra       L0731
L072B               stb       >$01B4
                    stb       >$01B5
L0731               puls      x

                    ifne      THEOS9WAY
                    lbra      L06B7
                    else
                    jmp       >$06B7
                    endc

L0736               tst       >$01B3
                    lbeq      L0995
                    ldx       #$01C9
                    lbsr      X6
                    sta       >$01C9
                    stx       >$01CC
                    ldx       #$01C3
                    lbsr      X6
                    sta       >$01C3
                    stx       >$01C6
                    clr       >$01B5
                    ldx       >$01C6
                    lda       >$01C3
                    beq       L0767
                    lbsr      L0A42
                    leax      $02,x
                    lda       ,x
L0767               sta       >$01C8
                    ldx       >$01CC
                    lda       >$01C9
                    beq       L0779
                    lbsr      L0A42
                    leax      $02,x
                    lda       ,x
L0779               sta       >$01CE

                    ifne      THEOS9WAY
                    leax      L135B,pc
                    else
                    ldx       #$135B
                    endc

L077F               lda       ,x
                    lbeq      L0951
                    lda       >$01B3
                    cmpa      ,x+
                    bne       L07E7
                    lda       ,x
                    sta       >$01B6
                    lda       >$01B4
                    beq       L079A
                    cmpa      ,x
                    bne       L07E7
L079A               leax      $01,x
                    lda       ,x
                    beq       L07B4
                    lda       >$01C3
                    bne       L07BB
                    lda       >$01BB
                    sta       >$01BD
                    ldy       #$01C3
                    lbsr      X7
                    bra       L07BB
L07B4               lda       >$01C3
                    lbne      L0951
L07BB               leax      $01,x
                    lda       ,x
                    beq       L07DA
                    lda       >$01C9
                    bne       L07E1
                    lda       >$01BC
                    sta       >$01BD
                    lda       #$01
                    sta       >$01B5
                    ldy       #$01C9
                    lbsr      X7
                    bra       L07E1
L07DA               lda       >$01C9
                    lbne      L0951
L07E1               leax      $01,x
                    lda       ,x
                    bra       L07F0
L07E7               leax      $01,x
                    leax      $01,x
                    leax      $02,x

                    ifne      THEOS9WAY
                    lbra      L077F
                    else
                    jmp       >$077F
                    endc

L07F0               sta       >$01D1
                    ldx       #$05FF
                    stx       <u0088
                    lda       #$0D
                    lbsr      X3
                    lda       >$01C3
                    bne       L080E
                    ldx       >$01CC
                    stx       >$01C6
                    lda       >$01C9
                    sta       >$01C3
L080E
                    ifne      THEOS9WAY
                    leax      L323C,pc
                    else
                    ldx       #$323C
                    endc

                    lbsr      L0A42
                    lbsr      X8
                    lbsr      X9
                    lda       #$0D
                    lbsr      X3

                    ifne      THEOS9WAY
                    lbra      L0630
                    else
                    jmp       >$0630
                    endc

X6                  clr       >$01BF
                    ldb       ,x+
                    stb       >$01B2
                    bne       L082E
                    clra
                    rts
L082E               lda       ,x+
                    sta       >$01B7
                    lda       ,x
                    sta       >$01CF

                    ifne      THEOS9WAY
                    leax      L20FF,pc
                    else
                    ldx       #$20FF
                    endc

                    lbsr      L0A1F
                    bcc       L089A
L0840               pshs      y
                    pshs      x
                    lda       >$01E1
                    sta       >$01E2
                    lbsr      L08AA
                    bne       L08A6
                    lda       >$01B7
                    beq       L0873
                    puls      x
                    pshs      x
                    lbsr      L0A42
                    leax      $03,x
                    ldb       #$01
                    lbsr      L0A27
                    bcc       L0873
                    lbsr      L0A42
L0867
                    lbsr      X5
                    bcc       L08A6
                    lda       >$01B7
                    cmpa      ,x+
                    bne       L0867
L0873               puls      x
                    lda       >$01BF
                    lbne      L098C
                    lda       >$01E2
                    sta       >$01BF
                    stx       >$01C0
L0885
                    lbsr      L0A42
                    tfr       y,x
                    puls      y
                    ldb       >$01B2
                    lda       >$01E2
                    sta       >$01E1
                    lbsr      L0A27
                    bcs       L0840
L089A               ldx       >$01C0
                    lda       >$01BF
                    bne       L08A5

                    ifne      THEOS9WAY
                    lbra      L0948
                    else
                    jmp       >$0948
                    endc

L08A5               rts
L08A6               puls      x
                    bra       L0885
L08AA
                    lbsr      L0A42
                    lda       >$01D5
                    cmpa      ,x
                    beq       L08A5
                    lda       ,x
                    beq       L08BF
                    cmpa      #$FF
                    beq       L08A5
                    bita      #$80
                    bne       L08BF
                    ldb       ,x
                    cmpb      >$01D2
                    beq       L08A5

                    ifne      THEOS9WAY
                    leax      L20FF,pc
                    else
                    ldx       #$20FF
                    endc

                    lbsr      X4
                    bra       L08AA
L08BF               ora       #$01
                    rts
X7                  pshs      x
                    clr       >$01B2
                    clr       >$01E1
                    pshs      y
                    lda       ,x
                    sta       >$01AB

                    ifne      THEOS9WAY
                    leax      L20FF,pc
                    else
                    ldx       #$20FF
                    endc

                    lbsr      L0A42
L08E7               lbsr      X5
                    bcc       L092C
                    inc       >$01E1
                    pshs      y
                    pshs      x
                    lbsr      L08AA
                    puls      x
                    bne       L0927
                    ldb       ,x
                    stx       >$01D8
                    lbsr      L0A42
                    leax      $02,x
                    lda       ,x
                    anda      >$01AB
                    cmpa      >$01AB
                    bne       L0921
                    lda       >$01B2
                    bne       L095A
                    stb       >$01B2
                    lda       ,x
                    sta       >$01B7
                    ldx       >$01D8
                    stx       >$01AD
L0921               exg       x,y
                    puls      y
                    bra       L08E7
L0927
                    lbsr      L0A42
                    bra       L0921
L092C               lda       >$01B2
                    beq       L095A
                    puls      y
                    ldx       >$01AD
                    lda       >$01E1
                    sta       ,y
                    leay      $03,y
                    stx       ,y++
                    lda       >$01B7
                    sta       ,y
                    puls      x
                    clra
                    rts
L0948
                    ifne      THEOS9WAY
                    leay      L1343,pc
                    else
                    ldy       #$1343
                    endc

                    lda       >$01CF
                    bra       L099B
L0951
                    ifne      THEOS9WAY
                    leay      L1352,pc
                    else
                    ldy       #$1352
                    endc
                    lda       >$01BC
                    bra       L099B
L095A               lda       >$01B5
                    beq       L0983
                    lda       >$01B4
                    bne       L0983

                    ifne      THEOS9WAY
                    leax      L3ECF,pc
                    else
                    ldx       #$3ECF
                    endc

L0967               ldb       ,x
                    beq       L0983
                    pshs      x
                    ldb       ,x+
                    abx
                    lda       >$01B6
                    cmpa      ,x+
                    beq       L097B
                    puls      b,a
                    bra       L0967
L097B               puls      y
                    lda       >$01BD

                    ifne      THEOS9WAY
                    lbsr      L09E1
                    else
                    jsr       >$09E1
                    endc

L0983
                    ifne      THEOS9WAY
                    leay      L1343,pc
                    else
                    ldy       #$1343
                    endc

                    lda       >$01BD
                    bra       L099B
L098C
                    ifne      THEOS9WAY
                    leay      L134A,pc
                    else
                    ldy       #$134A
                    endc

                    lda       >$01CF
                    bra       L099B
L0995
                    ifne      THEOS9WAY
                    leay      L133C,pc
                    else
                    ldy       #$133C
                    endc

                    lda       #$E0
L099B               lds       #$03FF
                    ldx       #$05E0

                    ifne      THEOS9WAY
                    lbsr      L09E1
                    else
                    jsr       >$09E1
                    endc

L09A5               lda       ,y
                    sta       >$01AB
                    pshs      x
L09AC               lda       #$60
                    sta       ,x+
                    dec       >$01AB
                    bne       L09AC

                    ifne      THEOS9WAY
                    lbsr      L09D6
                    else
                    jsr       >$09D6
                    endc

                    puls      x
                    decb
                    bne       L09D1
                    lda       ,y
                    inca
                    sta       >$01AB
L09C3
                    ifne      THEOS9WAY
                    lbsr      L0ADB
                    else
                    jsr       >$0ADB
                    endc

                    dec       >$01AB
                    bne       L09C3

                    ifne      THEOS9WAY
                    lbsr      L0A63
                    else
                    jsr       >$0A63
                    endc

                    ifne      THEOS9WAY
                    lbra      L0637
                    else
                    jmp       >$0637
                    endc

L09D1
                    ifne      THEOS9WAY
                    lbsr      L0A00
                    else
                    jsr       >$0A00
                    endc

                    bra       L09A5
L09D6               lda       #$32
L09D8               dec       >$01AB
                    bne       L09D8
                    deca
                    bne       L09D8
                    rts
L09E1               sta       >$01AB
                    ldd       #$05E0
                    ldb       >$01AB
                    tfr       d,x
                    lda       ,y
                    inca
                    sta       >$01AB
                    pshs      y
L09F4
                    ifne      THEOS9WAY
                    lbsr      L0B06
                    else
                    jsr       >$0B06
                    endc

                    dec       >$01AB
                    bne       L09F4
                    puls      y
                    ldb       #$08
L0A00               lda       ,y
                    sta       >$01AB
                    pshs      y,x,b
                    leay      $01,y
L0A09               lda       ,y+
                    sta       ,x+
                    dec       >$01AB
                    bne       L0A09
                    leax      $01,x
                    tfr       x,d
                    stb       >$01BD

                    ifne      THEOS9WAY
                    lbsr      L09D6
                    else
                    jsr       >$09D6
                    endc

                    puls      y,x,b
                    rts

L0A1F               leax      $01,x

                    ifne      THEOS9WAY
                    lbsr      L0A44
                    else
                    jsr       >$0A44
                    endc

                    clr       >$01E1
L0A27               lbsr      X5
                    bcs       L0A2D
                    rts
L0A2D               inc       >$01E1
                    cmpb      ,x
                    beq       L0A3F
                    pshs      y
                    lbsr      L0A42
                    tfr       y,x
                    puls      y
                    bra       L0A27
L0A3F               orcc      #$01
                    rts
L0A42               leax      $01,x
L0A44               clra
                    pshs      b
                    ldb       ,x+
                    bitb      #$80
                    beq       L0465
                    andb      #$7F
                    tfr       b,a
                    ldb       ,x+
L0465               leay      d,x
                    puls      b
                    rts
X5                  sty       >$01A9
                    cmpx      >$01A9
                    rts
L0A60               ldx       #$05E0

L0A63
                    ifne      THEOS9WAY
                    lbsr      L0B23
                    else
                    jsr       >$0B23
                    endc
L0A66

                    ifne      THEOS9WAY
                    lbsr      L0B2B
                    else
                    jsr       >$0B2B
                    endc

                    cmpa      #$15
                    beq       L0A8D
                    cmpa      #$5D
                    beq       L0AA0
                    cmpa      #$09
                    beq       L0AB3
                    cmpa      #$0D
                    beq       L0AC8
                    cmpa      #$0C
                    beq       L0ACC
                    cmpa      #$08
                    beq       L0ABC
                    cmpx      #$05FF
                    beq       L0A66

                    ifne      THEOS9WAY
                    lbsr      L0B06
                    else
                    jsr       >$0B06
                    endc

                    sta       ,x+
                    bra       L0A66
L0A8D               cmpx      #$05E0
                    beq       L0A66
                    leax      -$01,x
                    lda       ,x+
                    sta       ,x
                    leax      -$01,x
                    lda       #$CF
                    sta       ,x
                    bra       L0A66
L0AA0               cmpx      #$05FF
                    beq       L0A66
                    leax      $01,x
                    lda       ,x
                    leax      -$01,x
                    sta       ,x+
                    lda       #$CF
                    sta       ,x
                    bra       L0A66
L0AB3

                    ifne      THEOS9WAY
                    lbsr      L0ADB
                    else
                    jsr       >$0ADB
                    endc

                    lda       #$CF
                    sta       ,x
                    bra       L0A66
L0ABC               cmpx      #$05E0
                    beq       L0A66
                    leax      -$01,x

                    ifne      THEOS9WAY
                    lbsr      L0ADB
                    else
                    jsr       >$0ADB
                    endc

                    bra       L0A66
L0AC8

                    ifne      THEOS9WAY
                    lbsr      L0ADB
                    else
                    jsr       >$0ADB
                    endc

L0ACB               rts
L0ACC               ldx       #$05E0
                    ldb       #$20
                    lda       #$60
L0AD3               sta       ,x+
                    decb
                    bne       L0AD3

                    ifne      THEOS9WAY
                    lbra      L0A60
                    else
                    jmp       >$0A60
                    endc

L0ADB               tfr       x,u
                    leay      $01,x
                    lda       #$60
                    sta       ,x
                    cmpy      #$0600
                    beq       L0ACB
                    cmpy      #$0601
                    beq       L0ACB
                    cmpy      #$0602
                    beq       L0ACB
L0AF5               lda       ,y+
                    sta       ,x+
                    cmpy      #$0600
                    bne       L0AF5
                    lda       #$60
                    sta       ,x
                    tfr       u,x
                    rts
L0B06               cmpx      #$0600
                    beq       L0B22
                    stx       >$01A7
                    ldx       #$0600
                    ldy       #$05FF
L0B15               ldb       ,-y
                    stb       ,-x
                    cmpx      >$01A7
                    bne       L0B15
                    ldb       #$60
                    stb       ,x
L0B22               rts

L0B23
                    ifne      THEOS9WAY
                    lbsr      L0B06
                    else
                    jsr       >$0B06
                    endc

                    lda       #$CF
                    sta       ,x
                    rts

* Read one character from keyboard, returning it in A
L0B2B
                    ifne      THEOS9WAY
                    lbsr      L12A8
                    else
                    jsr       >$12A8
                    endc

*         jsr   [>$A000]
                    lbsr      os9read
                    nop
                    tsta
                    beq       L0B2B
                    cmpa      #$41                A or greater?
                    bcc       L0B3F               branch if A greater than or equal
                    cmpa      #$20                space?
                    bcs       L0B3F               branch if A less than
                    adda      #$40
L0B3F               rts

L0B40               leax      $01,x
L0B42               tfr       x,d
                    stb       >$01CF
                    cmpx      #$0600              start of screen?
                    beq       L0B3F
                    lda       ,x
                    cmpa      #$60
                    bcc       L0B40

                    ifne      THEOS9WAY
                    leay      L3C29,pcr
                    lbsr      L0B8B
                    else
                    ldy       #$3C29
                    jsr       >$0B8B
                    endc

                    beq       L0B42
                    ldb       #$01
L0B5D               leay      $01,y

                    ifne      THEOS9WAY
                    lbsr      L0B8B
                    else
                    jsr       >$0B8B
                    endc

                    beq       L0B6C
                    incb
                    cmpb      #$05
                    bne       L0B5D
                    ora       #$01
                    rts
L0B6C               exg       x,y
                    ldx       >$01D8
                    stb       ,x+
                    sta       ,x+
                    lda       >$01CF
                    sta       ,x+
                    stx       >$01D8
                    exg       x,y
                    cmpb      #$01
                    bne       L0B89
                    lda       >$01BC
                    sta       >$01BB
L0B89               clra
                    rts

L0B8B               lda       ,y
                    bne       L0B92
                    ora       #$01
                    rts
L0B92               sta       >$01AB
                    sta       >$01D0
                    pshs      x
                    leay      $01,y
L05AE               lda       ,x
                    cmpa      #$60
                    beq       L0BF5
                    cmpx      #$0600
                    beq       L0BF5
                    cmpa      #$60
                    bcs       L0BAF
                    leax      $01,x
                    bra       L05AE
L0BAF               cmpa      ,y
                    bne       L0BF5
                    leax      $01,x
                    leay      $01,y
                    dec       >$01AB
                    bne       L05AE
                    lda       >$01D0
                    cmpa      #$06
                    beq       L0BC9
                    lda       ,x
                    cmpa      #$60
                    bcs       L0BFE
L0BC9               lda       ,y
                    puls      y
                    sta       >$01AB
L0BD0               lda       ,x
                    cmpa      #$60
                    beq       L0BE2
                    stx       >$01A7
                    cmpx      #$0600
                    beq       L0BE8
                    leax      $01,x
                    bra       L0BD0
L0BE2               stx       >$01A7
                    inc       >$01A8
L0BE8               lda       >$01A8
                    sta       >$01BC
                    lda       >$01AB
                    clr       >$01A7
                    rts
L0BF5               leay      $01,y
                    dec       >$01AB
                    bne       L0BF5
L0BFE               puls      x
                    leay      $01,y

                    ifne      THEOS9WAY
                    lbra      L0B8B
                    else
                    jmp       >$0B8B
                    endc

X8                  lda       ,x+
                    tfr       a,b
                    bita      #$80
                    beq       L0C1E
                    pshs      y,x

                    ifne      THEOS9WAY
                    leax      L37FA,pc
                    else
                    ldx       #$37FA
                    endc

                    lbsr      L0A1F
                    bcc       L0C1B
                    lbsr      L0A42
                    lbsr      X8
L0C1B               puls      y,x
                    rts
L0C1E               tfr       b,a

L0C20
                    ifne      THEOS9WAY
                    leay      L12E5,pc
                    else
                    ldy       #$12E5
                    endc

                    lsla                          multiply A by 2 (for 16 bit address index)
                    jmp       [a,y]               pass control

L0C27
                    ifne      THEOS9WAY
                    lbsr      L0A44
                    else
                    jsr       >$0A44
                    endc

L0C2A               lbsr      X5
                    bcc       L0C3B
                    pshs      y
                    lbsr      X8
                    puls      y
                    beq       L0C2A
                    exg       x,y
                    rts
L0C3B               exg       x,y
                    clra
                    rts
L0C3F
                    ifne      THEOS9WAY
                    lbsr      L0A44
                    else
                    jsr       >$0A44
                    endc

L0C42               lbsr      X5
                    bcc       L0C53
                    pshs      y
                    lbsr      X8
                    puls      y
                    bne       L0C42
                    exg       x,y
                    rts
L0C53               exg       x,y
                    ora       #$01
                    rts
L0C58
                    ifne      THEOS9WAY
                    lbsr      L0A44
                    else
                    jsr       >$0A44
                    endc

                    ldb       ,x+
L0C5D               lbsr      X5
                    bcc       L0C53
                    pshs      y
                    pshs      b
                    tfr       b,a

                    ifne      THEOS9WAY
                    lbsr      L0C20
                    else
                    jsr       >$0C20
                    endc

                    puls      b
                    beq       L0C78

                    ifne      THEOS9WAY
                    lbsr      L0A44
                    else
                    jsr       >$0A44
                    endc

                    exg       x,y
                    puls      y
                    bra       L0C5D
L0C78

                    ifne      THEOS9WAY
                    lbsr      L0A44
                    else
                    jsr       >$0A44
                    endc

                    lbsr      X8
                    puls      x
                    rts

L0C81
                    ifne      THEOS9WAY
                    lbsr      L0C8D
                    else
                    jsr       >$0C8D
                    endc

                    pshs      x
                    lbsr      X2
                    puls      x
                    clra
                    rts
L0C8D               lda       ,x+
                    pshs      x
                    sta       >$01D5
                    tfr       a,b

                    ifne      THEOS9WAY
                    leax      L1523,pc
                    else
                    ldx       #$1523
                    endc

                    lbsr      L0A1F
                    stx       >$01D6
                    ldx       >$01D3
                    lbsr      L0A42
                    lda       >$01D5
                    sta       ,x
                    puls      x
                    clra
                    rts
L0CAE
                    ldu       >$01C6
                    stu       >$01C0
                    lda       >$01C3
                    sta       >$01BF
                    clra
                    rts

L0CBC
                    ldu       >$01CC
                    stu       >$01C0
                    lda       >$01C9
                    sta       >$01BF
                    clra
                    rts
L0CCA
                    ldb       ,x+
                    pshs      x
                    stb       >$01BF
                    beq       L0CD9
                    lbsr      X4
                    stx       >$01C0
L0CD9               puls      x
                    clra
                    rts

L0CDD               ldu       >$01C6
                    pshs      u
                    ldu       >$01CC
                    pshs      u
                    lda       >$01C9
                    ldb       >$01C3
                    pshs      b,a
                    lda       >$01D1
                    pshs      a
                    lda       ,x+
                    sta       >$01D1
                    ldd       ,x++
                    stb       >$01AB
                    pshs      x
                    sta       >$01C3
                    tfr       a,b
                    beq       L0D0F
                    lbsr      X4
                    stx       >$01C6
L0D0F               ldb       >$01AB
                    stb       >$01C9
                    beq       L0x2D
                    lbsr      X4
                    stx       >$01CC
L0x2D
                    ifne      THEOS9WAY
                    leax      L323C,pc
                    else
                    ldx       #$323C
                    endc

                    lbsr      L0A42
                    lbsr      X8
                    tfr       cc,a
                    sta       >$01AB
                    puls      y
                    puls      a
                    sta       >$01D1
                    puls      b,a
                    stb       >$01C3
                    sta       >$01C9
                    puls      u
                    stu       >$01CC
                    puls      u
                    stu       >$01C6
                    exg       x,y
                    lda       >$01AB
                    tfr       a,cc
L0D49               rts
X2                  lda       >$01D2
                    cmpa      #$1D
                    bne       L0D49
                    ldx       >$01D6
                    lbsr      L0A42
                    leax      $01,x
                    ldb       #$03
                    lbsr      L0A27
                    bcc       L0D65
                    leax      $01,x

                    ifne      THEOS9WAY
                    lbsr      L114C
                    else
                    jsr       >$114C
                    endc

L0D65
                    ifne      THEOS9WAY
                    leax      L20FF,pc
                    else
                    ldx       #$20FF
                    endc
                    lbsr      L0A42
L077D               pshs      y
                    lbsr      L0A42
                    lda       >$01D5
                    cmpa      ,x
                    bne       L0D89
                    leax      $03,x
                    ldb       #$03
                    lbsr      L0A27
                    bcc       L0D89
                    leax      $01,x
                    pshs      y

                    ifne      THEOS9WAY
                    lbsr      L114C
                    else
                    jsr       >$114C
                    endc

                    puls      y
L0D89               exg       x,y
                    puls      y
                    lbsr      X5
                    bcs       L077D
                    rts
L0D93
                    ldb       ,x+
                    pshs      x
                    lbsr      X4
                    lbsr      L08AA
                    puls      x
                    rts
L0DA0
                    lda       >$01D2
                    cmpa      ,x+
                    rts

L0DA6               ldb       ,x+

                    ifne      THEOS9WAY
                    lbra      L0F5F
                    else
                    jmp       >$0F5F
                    endc

L0DAB               ldd       ,x++
                    pshs      x
                    sta       >$01AB
                    lbsr      X4
                    lbsr      L0A42
                    ldd       ,x++
                    cmpa      >$01AB
                    puls      x
                    rts
L0DC0
                    ora       #$01
                    rts

L0DC3               lda       >$01D2
                    cmpa      #$1D
                    bne       L0DD8
L0DCA               ldb       #$1D
                    pshs      x
                    lbsr      X4
                    lbsr      L08AA
                    puls      x
                    beq       L07F1
L0DD8

                    ifne      THEOS9WAY
                    lbsr      L0A44
                    else
                    jsr       >$0A44
                    endc

                    exg       x,y
                    bra       L0DE2
L07F1

                    ifne      THEOS9WAY
                    lbsr      L114C
                    else
                    jsr       >$114C
                    endc

L0DE2               clra
                    rts

L0DE4               lbsr      X2
                    clra
                    rts

L0DE9               pshs      x
L0DEB               lda       #$0D
                    lbsr      X3

                    ifne      THEOS9WAY
                    leax      L20FF,pc
                    else
                    ldx       #$20FF
                    endc

                    lbsr      L0A42
L07F8               lbsr      X5
                    bcc       L0E1F
                    pshs      y
                    lbsr      L0A42
                    ldb       ,x
                    cmpb      >$01D2
                    bne       L0E19
                    leax      $03,x
                    ldb       #$02
                    lbsr      L0A27
                    bcc       L0E19
                    leax      $01,x
                    pshs      y

                    ifne      THEOS9WAY
                    lbsr      L1143
                    else
                    jsr       >$1143
                    endc

                    puls      y
L0E19               exg       x,y
                    puls      y
                    bra       L07F8
L0E1F               clra
                    puls      x
                    rts
L0E23               ldu       >$01C6
                    lda       >$01C3
L0E29               stu       >$01D8
                    tsta
                    beq       L0E3F
                    ldb       ,x+
                    pshs      x
                    lbsr      X4
                    exg       x,y
                    puls      x
                    cmpy      >$01D8
                    rts
L0E3F               tstb
                    rts

L0E41               ldu       >$01CC
                    lda       >$01C9
                    bra       L0E29
L0E49
                    ldb       ,x+
                    cmpb      >$01D1
                    rts
L0E4F
                    pshs      x
                    ldx       >$01C0
                    lbsr      L0A42
                    lda       >$01D2
                    sta       ,x
                    clra
                    puls      x
                    rts

L0E60               pshs      x
                    ldx       >$01C0
                    lbsr      L0A42
                    lda       >$01D5
                    sta       ,x
                    puls      x
                    clra
                    rts

L0E71               pshs      x
                    ldx       >$01D6
                    lbsr      L0A42
                    leax      $01,x
                    ldb       #$04
                    lbsr      L0A27
                    bcc       L0E8A
                    lbsr      L0A42
                    lbsr      X8
                    beq       L0EC5
L0E8A               lda       >$01C9
                    beq       L0EA6
                    ldx       >$01CC
                    lbsr      L0A42
                    leax      $03,x
                    ldb       #$06
                    lbsr      L0A27
                    bcc       L0EA6
                    lbsr      L0A42
                    lbsr      X8
                    beq       L0EC5
L0EA6               lda       >$01C3
                    bne       L0EB0
L0EAB               puls      x
                    ora       #$01
                    rts
L0EB0               ldx       >$01C6
                    lbsr      L0A42
                    leax      $03,x
                    ldb       #$07
                    lbsr      L0A27
                    bcc       L0EAB
                    lbsr      L0A42
                    lbsr      X8
L0EC5               puls      x
                    rts

L0EC8
                    pshs      x
                    ldx       >$01C0
                    lda       >$01BF
                    bra       L0EDA
L0ED2
                    pshs      x
                    ldx       >$01C6
                    lda       >$01C3
L0EDA               beq       L0EC5
                    ldb       #$1D
                    pshs      x
                    lbsr      X4
                    lbsr      L08AA
                    puls      x
                    bne       L0EFB
                    lbsr      L0A42
                    leax      $03,x
                    ldb       #$02
                    lbsr      L0A27
                    bcc       L0EFB
                    leax      $01,x

                    ifne      THEOS9WAY
                    lbsr      L114C
                    else
                    jsr       >$114C
                    endc

L0EFB               puls      x
                    clra
                    rts

L0EFF
                    pshs      x
                    ldx       >$01CC
                    lda       >$01C9
                    bra       L0EDA

L0F09
                    pshs      x
                    ldx       >$01C0
                    lda       >$01BF
                    beq       L0F21
                    lbsr      L0A42
                    leax      $02,x
                    lda       ,x
                    puls      x
                    anda      ,x
                    eora      ,x+
                    rts
L0F21               puls      x
                    leax      $01,x
                    ora       #$01
                    rts
L0F28
                    lbsr      X8
                    bne       L0F30
                    ora       #$01
                    rts
L0F30               clra
                    rts
L0F32
                    ldb       ,x+
                    pshs      x
                    lbsr      X4
                    lbsr      L0A42
                    puls      y
                    lda       ,y+
                    sta       ,x
                    exg       x,y
                    clra
L0F45               rts
L0F46               pshs      x
                    ldx       >$01C0
L0F4B
                    lbsr      L0A42
                    ldb       ,x
                    puls      x
                    lbeq      L08BF
                    cmpb      >$01D2
                    beq       L0F45
                    bitb      #$80
                    bne       L0F45
L0F5F               pshs      x
                    lbsr      X4
                    bra       L0F4B
X9

                    ifne      THEOS9WAY
                    leax      L20FF,pc
                    else
                    ldx       #$20FF
                    endc

                    clr       >$01D0
                    lbsr      L0A42
L0F6F               lbsr      X5
                    bcc       L0F45
                    inc       >$01D0
                    pshs      y
                    lbsr      L0A42
                    lda       ,x
                    sta       >$01AB
                    pshs      y
                    lda       ,x
                    beq       L0FC9
                    leax      $03,x
                    ldb       #$08
                    lbsr      L0A27
                    bcc       L0FC9
                    lbsr      L0A42
                    pshs      x

                    ifne      THEOS9WAY
                    lbsr      L12A8
                    else
                    jsr       >$12A8
                    endc

                    ldb       >$01D0
                    stb       >$01D2
                    lbsr      X4
                    stx       >$01D3
                    ldb       >$01AB
L0FA7               tstb
                    bmi       L0FB8
                    lbsr      X4
                    lbsr      L0A42
                    ldb       ,x
                    bne       L0FA7
                    puls      x
                    bra       L0FC9
L0FB8               stb       >$01D5

                    ifne      THEOS9WAY
                    leax      L1523,pc
                    else
                    ldx       #$1523
                    endc

                    lbsr      L0A1F
                    stx       >$01D6
                    puls      x
                    lbsr      X8
L0FC9               puls      x
                    puls      y
                    bra       L0F6F

L0FCF
                    ifne      THEOS9WAY
                    pshs      x
                    leax      L1338,pc
                    lda       ,x
                    puls      x
*         lda   >L1338+OS9Offset
                    else
                    lda       >$1338
                    endc

                    cmpa      ,x+
                    bcs       L0FDB
                    beq       L0FDB
                    ora       #$01
                    rts
L0FDB               clra
                    rts
L0FDD
                    lda       ,x+
                    sta       >$01AB
                    pshs      x
                    ldx       >$01C0
                    lbsr      L0A42
                    leax      $03,x
                    pshs      x
                    pshs      y
                    ldb       #$09
                    lbsr      L0A27
                    bcc       L1020
                    lbsr      L0A42
                    leax      $01,x
                    lda       ,x
                    suba      >$01AB
                    bcc       L1004
                    clra
L1004               sta       ,x
                    puls      y
                    puls      x
                    tsta
                    beq       L1011
L100D               puls      x
                    clra
                    rts
L1011               ldb       #$0A
                    lbsr      L0A27
                    bcc       L100D
                    lbsr      L0A42
                    lbsr      X8
                    bra       L100D
L1020               puls      y
                    puls      x
                    bra       L100D
L1026
                    ldb       ,x+
                    lda       ,x+
                    sta       >$01AB
                    pshs      x
                    lbsr      X4
                    lbsr      L0A42
                    tfr       x,u
                    ldb       >$01AB
                    lbsr      X4
                    lbsr      L0A42
                    lda       ,x
                    ldb       ,u
                    sta       ,u
                    stb       ,x
                    puls      x
                    clra
                    rts

L104C               lda       ,x+
                    pshs      x
                    sta       >$01AB
                    ldx       >$01C0
                    lbsr      L0A42
                    leax      $03,x
                    ldb       #$09
                    lbsr      L0A27
                    bcc       L1070
                    lbsr      L0A42
                    leax      $01,x
                    lda       ,x
                    cmpa      >$01AB
                    bcs       L0A87
                    beq       L0A87
L1070               puls      x
                    ora       #$01
                    rts
L0A87               puls      x
                    clra
                    rts
L1079
                    lda       ,x+
                    sta       >$01AB
                    pshs      x
                    ldx       >$01C0
                    lbsr      L0A42
                    leax      $03,x
                    ldb       #$09
                    lbsr      L0A27
                    bcc       L0A87
                    lbsr      L0A42
                    ldd       ,x
                    addb      >$01AB
                    sta       >$01AB
                    cmpb      >$01AB
                    bcs       L10A2
                    ldb       >$01AB
L10A2               leax      $01,x
                    stb       ,x
                    bra       L0A87
L10A8
                    lda       #$0D
                    lbsr      X3
                    lda       #$0D
                    lbsr      X3

                    ifne      THEOS9WAY
                    lbra      L060C
                    else
                    jmp       >$060C
                    endc

L10B5               bra       L10B5
L10B7               lda       ,y+
                    beq       L10C4
                    pshs      y
                    lbsr      X3
                    puls      y
                    bra       L10B7
L10C4               rts
L10C5               pshs      x
                    clr       >$01AF
                    clr       >$01B0
                    lda       >$01D5
                    cmpa      #$96
                    bne       L10D7
                    inc       >$01B0
L10D7
                    ifne      THEOS9WAY
                    leax      L20FF,pc
                    else
                    ldx       #$20FF
                    endc

                    lbsr      L0A42
L10DD               lbsr      X5
                    bcc       L110F
                    pshs      y
                    lbsr      L0A42
                    ldb       ,x+
                    cmpb      #$96
                    beq       L10F1
                    cmpb      #$1D
                    bne       L1109
L10F1               lda       >$01AF
                    adda      ,x
                    daa
                    sta       >$01AF
                    cmpb      #$96
                    beq       L1103
                    tst       >$01B0
                    beq       L1109
L1103               adda      ,x
                    daa
                    sta       >$01AF
L1109               tfr       y,x
                    puls      y
                    bra       L10DD
L110F               lda       >$01AF
                    asra
                    asra
                    asra
                    asra
                    adda      #$30
                    lbsr      X3
                    lda       >$01AF
                    anda      #$0F
                    adda      #$30
                    lbsr      X3
                    lda       #$2E
                    lbsr      X3
                    lda       #$20
                    lbsr      X3
                    puls      x
                    clra
                    rts
X4
                    ifne      THEOS9WAY
                    leax      L20FF,pc
                    else
                    ldx       #$20FF
                    endc

                    lbsr      L0A42
L1139               decb
                    beq       L10C4
                    lbsr      L0A42
                    exg       x,y
                    bra       L1139

L1143
                    ifne      THEOS9WAY
                    lbsr      L114C
                    else
                    jsr       >$114C
                    endc

                    lda       #$0D
                    lbsr      X3
                    rts
L114C               clra
                    ldb       ,x
                    bitb      #$80
                    beq       L1157
                    lda       ,x+
                    anda      #$7F
L1157               ldb       ,x+
                    std       >$01AB
L115C               ldd       >$01AB
                    cmpd      #$0002
                    bcs       L1173

                    ifne      THEOS9WAY
                    lbsr      L11EC
                    else
                    jsr       >$11EC
                    endc

                    ldd       >$01AB
                    subd      #$0002
                    std       >$01AB
                    bra       L115C
L1173               tstb
                    beq       L117E
                    lda       ,x+
                    lbsr      X3
                    decb
                    bra       L1173
L117E               lda       #$20
                    lbsr      X3
                    rts
X3                  pshs      b,a
                    lda       >$01BE
                    cmpa      #$20
                    bne       L11A7
                    puls      b,a
                    cmpa      #$20
                    beq       L11EA
                    cmpa      #$2E
                    beq       L11BF
                    cmpa      #$3F
                    beq       L11BF
                    cmpa      #$21
                    bne       L11A9
L11BF               ldu       <u0088
                    leau      -u0001,u
                    stu       <u0088
                    bra       L11A9
L11A7               puls      b,a
L11A9               sta       >$01BE
*         jsr   [>$A002]
                    lbsr      os9write
                    nop
                    lda       <u0089
                    cmpa      #$FE
                    bcs       L11EA
                    ldu       <u0088
                    leau      <-u0021,u
                    lda       #$0D
*         jsr   [>$A002]
                    lbsr      os9write
                    nop
L11C1               lda       ,u
                    cmpa      #$60
                    beq       L11CB
                    leau      -u0001,u
                    bra       L11C1
L11CB               leau      u0001,u
                    lda       ,u
                    cmpa      #$60
                    beq       L11EA
                    pshs      b
                    ldb       #$60
                    stb       ,u
                    puls      b
                    cmpa      #$60
                    bcs       L11E1
                    suba      #$40
L11E1               sta       >$01BE
*         jsr   [>$A002]
                    lbsr      os9write
                    nop
                    bra       L11CB
L11EA               rts
                    rts
L11EC
                    ifne      THEOS9WAY
                    leay      L12A4,pc
                    else
                    ldy       #$12A4
                    endc

                    ldb       #$03

                    ifne      THEOS9WAY
                    pshs      x
                    leax      L12A1,pc
                    stb       ,x
                    puls      x
*         stb   >L12A1+OS9Offset
                    else
                    stb       >$12A1
                    endc

                    lda       ,x+
                    sta       >$01DE
                    lda       ,x+
                    sta       >$01DD
                    leay      $03,y
L1203               ldu       #$0028

                    ifne      THEOS9WAY
                    pshs      x
                    leax      L12A2,pc
                    stu       ,x
                    puls      x
*         stu   >L12A2+OS9Offset
                    else
                    stu       >$12A2
                    endc

                    lda       #$11
                    sta       >$01DA
                    clr       >$01DB
                    clr       >$01DC
L1212               rol       >$01DE
                    rol       >$01DD
                    dec       >$01DA
                    beq       L1256
                    lda       #$00
                    adca      #$00
                    lsl       >$01DC
                    rol       >$01DB
                    adda      >$01DC

                    ifne      THEOS9WAY
                    pshs      x
                    leax      L12A3,pc
                    suba      ,x
                    puls      x
*         suba  >L12A3+OS9Offset
                    else
                    suba      >$12A3
                    endc

                    sta       >$01E0
                    lda       >$01DB

                    ifne      THEOS9WAY
                    pshs      x
                    leax      L12A2,pc
                    sbca      ,x
                    puls      x
*         sbca  >L12A2+OS9Offset
                    else
                    sbca      >$12A2
                    endc

                    sta       >$01DF
                    bcc       L1246
                    ldd       >$01DF

                    ifne      THEOS9WAY
                    pshs      x
                    leax      L12A2,pc
                    addd      ,x
                    puls      x
*         addd  >L12A2+OS9Offset
                    else
                    addd      >$12A2
                    endc

                    std       >$01DB
                    bra       L124C
L1246               ldd       >$01DF
                    std       >$01DB
L124C               bcs       L1252
                    orcc      #$01
                    bra       L1212
L1252               andcc     #$FE
                    bra       L1212
L1256               ldd       >$01DB

                    ifne      THEOS9WAY
                    addd      #L1279+OS9Offset
                    else
                    addd      #$1279
                    endc
                    tfr       d,u
                    lda       ,u
                    sta       ,-y

                    ifne      THEOS9WAY
                    pshs      x
                    leax      L12A1,pc
                    dec       ,x
                    puls      x
*         dec   >L12A1+OS9Offset
                    lbne      L1203
                    else
                    dec       >$12A1
                    bne       L1203
                    endc


                    ifne      THEOS9WAY
                    leay      L12A4,pc
                    else
                    ldy       #$12A4
                    endc

                    ldb       #$03
L126D               lda       ,y+
                    lbsr      X3
                    decb
                    bne       L126D
                    ldd       >$01AB
                    rts

L1279               fcb       $3F,$21,$32,$20,$22,$27 9?!2 "'<
                    fcc       "<>/03ABCDEFGHIJKLMNOPQRSTUVWXYZ-,."
L12A1               fcb       $00
L12A2               fcb       $00
L12A3               fcb       $00
L12A4               fcb       $00,$00,$00,$00     ........

L12A8               pshs      x,b

                    ifne      THEOS9WAY
                    leax      L1338,pc
                    else
                    ldx       #$1338
                    endc

                    ldb       #$17
                    lda       ,x
L12B1               leax      $01,x
                    orcc      #$01
                    anda      #$06
                    beq       L12C0
                    cmpa      #$06
                    orcc      #$01
                    beq       L12C0
                    clra
L12C0               lda       ,x
                    bcs       L12C7
                    lsra
                    bra       L12CA
L12C7               lsra
                    ora       #$80
L12CA               sta       ,x
                    leax      -$01,x
                    lda       ,x
                    bcs       L12D5
                    lsra
                    bra       L12D8
L12D5               lsra
                    ora       #$80
L12D8               anda      #$FE
                    sta       ,x
                    decb
                    bne       L12B1

                    ifne      THEOS9WAY
                    pshs      x
                    leax      L1339,pc
                    lda       ,x
                    puls      x
*         lda   >L1339+OS9Offset
                    else
                    lda       >$1339
                    endc

                    puls      x,b
                    rts

L12E5               fdb       L0C81+SubOffset
                    fdb       L0D93+SubOffset
                    fdb       L0DA6+SubOffset
                    fdb       L0DAB+SubOffset
                    fdb       L0DC3+SubOffset
                    fdb       L0FCF+SubOffset
                    fdb       L0DE9+SubOffset
                    fdb       L0DE4+SubOffset
                    fdb       L0E23+SubOffset
                    fdb       L0E41+SubOffset
                    fdb       L0E49+SubOffset
                    fdb       L0C58+SubOffset
                    fdb       L0DC0+SubOffset
                    fdb       L0C27+SubOffset
                    fdb       L0C3F+SubOffset
                    fdb       L0E4F+SubOffset
                    fdb       L0E60+SubOffset
                    fdb       L0ED2+SubOffset
                    fdb       L0EFF+SubOffset
                    fdb       L0E71+SubOffset
                    fdb       L0F28+SubOffset
                    fdb       L0F09+SubOffset
                    fdb       L0EC8+SubOffset
                    fdb       L0F32+SubOffset
                    fdb       L0F46+SubOffset
                    fdb       L0C8D+SubOffset
                    fdb       L0CAE+SubOffset
                    fdb       L0CBC+SubOffset
                    fdb       L0CCA+SubOffset
                    fdb       L0FDD+SubOffset
                    fdb       L1026+SubOffset
                    fdb       L0DCA+SubOffset
                    fdb       L0DA0+SubOffset
                    fdb       L0CDD+SubOffset
                    fdb       L104C+SubOffset
                    fdb       L1079+SubOffset
                    fdb       L10B5+SubOffset
                    fdb       L10A8+SubOffset
                    fdb       L10C5+SubOffset
L1333               fcb       $00,$12,$23,$44,$1D (.E..#D.
L1338               fcb       $27
L1339               fcb       $4D,$2D
                    fcb       $13
L133C               fcb       $06
                    fcc       /?VERB?/
L1343               fcb       $06
                    fcc       /?WHAT?/
L134A               fcb       $07
                    fcc       /?WHICH?/
L1352               fcb       $08
                    fcc       /?PHRASE?/
L135B               fcb       $05,$00,$00,$00,$01 SE?.....
                    fcb       $06,$00,$00,$00,$02,$07,$00,$00 ........
                    fcb       $00,$03,$08,$00,$00,$00,$04,$09 ........
                    fcb       $00,$20,$00,$05,$34,$07,$00,$80 . ..4...
                    fcb       $05,$34,$07,$80,$00,$05,$0A,$00 .4......
                    fcb       $20,$00,$06,$0A,$05,$80,$80,$0F .......
                    fcb       $0A,$06,$00,$88,$16,$0B,$00,$00 ........
                    fcb       $00,$07,$01,$00,$04,$00,$08,$04 ........
                    fcb       $02,$10,$40,$09,$0C,$00,$00,$00 ..@.....
                    fcb       $0A,$0C,$03,$00,$80,$0B,$0C,$04 ........
                    fcb       $00,$80,$0C,$0C,$05,$00,$80,$10 ........
                    fcb       $03,$03,$40,$10,$0D,$03,$05,$80 ..@.....
                    fcb       $80,$39,$03,$08,$00,$20,$06,$03 .9... ..
                    fcb       $01,$80,$10,$0E,$0D,$01,$80,$10 ........
                    fcb       $0E,$0E,$00,$80,$00,$0B,$0E,$05 ........
                    fcb       $00,$80,$0B,$0F,$00,$80,$00,$11 ........
                    fcb       $0F,$02,$80,$80,$3A,$10,$00,$80 ....:...
                    fcb       $00,$12,$10,$08,$00,$80,$12,$10 ........
                    fcb       $06,$00,$80,$05,$10,$06,$80,$00 ........
                    fcb       $05,$10,$07,$00,$80,$2D,$10,$07 .....-..
                    fcb       $80,$00,$2D,$11,$02,$88,$88,$14 ..-.....
                    fcb       $12,$00,$80,$00,$15,$13,$06,$00 ........
                    fcb       $88,$16,$14,$00,$88,$00,$16,$15 ........
                    fcb       $00,$80,$00,$17,$15,$07,$00,$80 ........
                    fcb       $17,$15,$08,$00,$80,$17,$15,$09 ........
                    fcb       $00,$80,$17,$15,$0C,$00,$80,$17 ........
                    fcb       $15,$05,$00,$00,$36,$15,$05,$00 ....6...
                    fcb       $80,$36,$15,$06,$00,$00,$37,$15 .6....7.
                    fcb       $06,$00,$80,$37,$15,$04,$00,$80 ...7....
                    fcb       $38,$16,$00,$80,$00,$18,$18,$00 8.......
                    fcb       $00,$00,$1A,$05,$01,$00,$00,$01 ........
                    fcb       $06,$01,$00,$00,$02,$07,$01,$00 ........
                    fcb       $00,$03,$08,$01,$00,$00,$04,$0A ........
                    fcb       $08,$00,$20,$06,$0A,$08,$20,$00 .. ... .
                    fcb       $06,$0A,$0A,$20,$80,$06,$0A,$04 ... ....
                    fcb       $20,$80,$06,$0A,$0C,$20,$80,$06 .... ..
                    fcb       $0C,$07,$00,$00,$0A,$0C,$08,$00 ........
                    fcb       $00,$0A,$0C,$09,$80,$00,$0B,$0C ........
                    fcb       $09,$00,$80,$0B,$0C,$0B,$00,$00 ........
                    fcb       $0A,$0C,$0A,$00,$00,$0A,$0C,$0B ........
                    fcb       $00,$80,$1B,$0C,$0A,$00,$80,$1C ........
                    fcb       $32,$00,$00,$00,$21,$2B,$00,$00 2...!+..
                    fcb       $00,$22,$2D,$00,$00,$00,$23,$2C ."-...#,
                    fcb       $00,$00,$00,$25,$2C,$00,$20,$00 ...%,. .
                    fcb       $06,$21,$00,$00,$00,$25,$21,$01 .!...%!.
                    fcb       $00,$80,$3D,$21,$05,$00,$80,$36 ..=!...6
                    fcb       $21,$06,$00,$80,$37,$21,$04,$00 !...7!..
                    fcb       $80,$38,$21,$07,$00,$80,$17,$21 .8!....!
                    fcb       $08,$00,$80,$17,$21,$0B,$00,$80 ....!...
                    fcb       $26,$23,$00,$80,$00,$27,$23,$08 &#...'#.
                    fcb       $00,$80,$27,$23,$05,$00,$80,$27 ..'#...'
                    fcb       $24,$02,$10,$80,$28,$24,$01,$80 $...($..
                    fcb       $10,$29,$28,$00,$00,$00,$2C,$1C .)(...,.
                    fcb       $00,$80,$00,$2D,$1F,$00,$00,$00 ...-....
                    fcb       $2F,$1F,$0B,$00,$00,$2F,$09,$07 /..../..
                    fcb       $00,$00,$2F,$20,$09,$00,$80,$34 ../ ...4
                    fcb       $20,$05,$00,$80,$36,$20,$06,$00 ...6 ..
                    fcb       $80,$37,$00

L1523               fcb       $00,$8B,$D9,$81,$5E .7...Y.^
                    fcb       $00,$03,$52,$C7,$DE,$94,$14,$4B ..RG^..K
                    fcb       $5E,$83,$96,$5F,$17,$46,$48,$39 ^.._.FH9
                    fcb       $17,$DB,$9F,$56,$D1,$09,$71,$D0 .[.VQ.qP
                    fcb       $B0,$7F,$7B,$F3,$17,$0D,$8D,$90 0{s....
                    fcb       $14,$08,$58,$81,$8D,$1B,$B5,$5F ..X...5_
                    fcb       $BE,$5B,$B1,$4B,$7B,$55,$45,$8E >[1K{UE.
                    fcb       $91,$11,$8A,$F0,$A4,$91,$7A,$89 ...p$.z.
                    fcb       $17,$82,$17,$47,$5E,$66,$49,$90 ...G^fI.
                    fcb       $14,$03,$58,$3B,$16,$B7,$B1,$A9 ..X;.71)
                    fcb       $15,$DB,$8B,$83,$7A,$5F,$BE,$D7 .[..z_>W
                    fcb       $14,$43,$7A,$CF,$98,$04,$07,$0B .CzO....
                    fcb       $05,$0A,$03,$02,$00,$82,$82,$80 ........
                    fcb       $C4,$00,$03,$80,$AB,$C7,$DE,$94 D...+G^.
                    fcb       $14,$4B,$5E,$83,$96,$3B,$16,$B7 .K^..;.7
                    fcb       $B1,$2F,$17,$FB,$55,$C7,$98,$54 1/..UG.T
                    fcb       $8B,$39,$17,$FF,$9F,$C0,$16,$82 .9...@..
                    fcb       $17,$48,$5E,$81,$8D,$91,$AF,$96 .H^.../.
                    fcb       $64,$DB,$72,$95,$5F,$15,$BC,$FF d[r._.<.
                    fcb       $78,$B8,$16,$82,$17,$54,$5E,$3F x8...T^?
                    fcb       $A0,$D5,$15,$90,$14,$D0,$15,$F3 U...P.s
                    fcb       $BF,$16,$53,$51,$5E,$07,$B2,$BB ?.SQ^.2;
                    fcb       $9A,$14,$8A,$6B,$C4,$0C,$BA,$7D ...kD.:}
                    fcb       $62,$90,$73,$C4,$6A,$91,$62,$30 b.sDj.b0
                    fcb       $60,$82,$17,$50,$5E,$BE,$A0,$03 `..P^> .
                    fcb       $71,$33,$98,$47,$B9,$53,$BE,$0E q3.G9S>.
                    fcb       $D0,$2F,$8E,$D0,$15,$82,$17,$47 P/.P...G
                    fcb       $5E,$66,$49,$F3,$17,$F3,$8C,$4B ^fIs.s.K
                    fcb       $7B,$4A,$45,$77,$C4,$D3,$14,$0F {JEwDS..
                    fcb       $B4,$19,$58,$36,$A0,$83,$61,$81 4.X6 .a.
                    fcb       $5B,$1B,$B5,$6B,$BF,$5F,$BE,$61 [.5k?_>a
                    fcb       $17,$82,$C6,$03,$EE,$5F,$17,$46 ..F.n_.F
                    fcb       $48,$A9,$15,$DB,$8B,$E3,$8B,$0B H).[.c..
                    fcb       $5C,$6B,$BF,$46,$45,$35,$49,$DB \k?FE5I[
                    fcb       $16,$D3,$B9,$9B,$6C,$1B,$D0,$2E .S9.l.P.
                    fcb       $04,$13,$0B,$11,$0A,$04,$02,$00 ........
                    fcb       $81,$02,$02,$00,$83,$03,$06,$0D ........
                    fcb       $04,$20,$1D,$8B,$81,$83,$3A,$00 . ....:.
                    fcb       $03,$2A,$C7,$DE,$94,$14,$4B,$5E .*G^..K^
                    fcb       $83,$96,$FB,$14,$4B,$B2,$55,$A4 ....K2U$
                    fcb       $09,$B7,$59,$5E,$3B,$4A,$23,$D1 .7Y^;J#Q
                    fcb       $13,$54,$C9,$B8,$F5,$A4,$B2,$17 .TI8u$2.
                    fcb       $90,$14,$16,$58,$D6,$9C,$DB,$72 ...XV.[r
                    fcb       $47,$B9,$77,$BE,$04,$0B,$0B,$09 G9w>....
                    fcb       $0A,$01,$02,$00,$82,$02,$02,$00 ........
                    fcb       $84,$84,$67,$00,$03,$53,$C7,$DE ..g..SG^
                    fcb       $94,$14,$43,$5E,$16,$BC,$DB,$72 ..C^.<[r
                    fcb       $82,$BF,$B8,$16,$7B,$14,$55,$A4 .?8.{.U$
                    fcb       $09,$B7,$59,$5E,$85,$73,$15,$71 .7Y^.s.q
                    fcb       $82,$8D,$4B,$62,$89,$5B,$83,$96 ..Kb.[..
                    fcb       $33,$98,$6B,$BF,$5F,$BE,$99,$16 3.k?_>..
                    fcb       $C2,$B3,$56,$F4,$F4,$72,$4B,$5E B3VttrK^
                    fcb       $C3,$B5,$E1,$14,$73,$B3,$84,$5B C5a.s3.[
                    fcb       $89,$17,$82,$17,$47,$5E,$66,$49 ....G^fI
                    fcb       $90,$14,$03,$58,$06,$9A,$F4,$72 ...X..tr
                    fcb       $89,$17,$82,$17,$59,$5E,$66,$62 ....Y^fb
                    fcb       $2E,$04,$0F,$0B,$0D,$0A,$01,$02 ........
                    fcb       $00,$83,$04,$02,$00,$A1,$03,$02 .....!..
                    fcb       $00,$85,$85,$44,$00,$03,$26,$63 ...D..&c
                    fcb       $BE,$CB,$B5,$C3,$B5,$73,$17,$1B >K5C5s..
                    fcb       $B8,$E6,$A4,$39,$17,$DB,$9F,$56 8f$9.[.V
                    fcb       $D1,$07,$71,$96,$D7,$C7,$B5,$66 Q.q.WG5f
                    fcb       $49,$15,$EE,$36,$A1,$73,$76,$8E I.n6!sv.
                    fcb       $48,$F7,$17,$17,$BA,$04,$19,$0B Hw..:...
                    fcb       $17,$0A,$04,$02,$00,$84,$02,$02 ........
                    fcb       $00,$86,$03,$0C,$0D,$0A,$00,$88 ........
                    fcb       $14,$0D,$05,$20,$1D,$01,$07,$82 ... ....
                    fcb       $86,$3F,$00,$03,$2F,$C7,$DE,$94 .?../G^.
                    fcb       $14,$4B,$5E,$83,$96,$39,$17,$DB .K^..9.[
                    fcb       $9F,$56,$D1,$09,$71,$DB,$B0,$66 .VQ.q[0f
                    fcb       $17,$0F,$A0,$F3,$17,$0D,$8D,$52 .. s...R
                    fcb       $F4,$65,$49,$77,$47,$CE,$B5,$86 teIwGN5.
                    fcb       $5F,$99,$16,$C2,$B3,$90,$14,$07 _..B3...
                    fcb       $58,$66,$49,$2E,$04,$0B,$0B,$09 XfI.....
                    fcb       $0A,$01,$02,$00,$85,$03,$02,$00 ........
                    fcb       $87,$87,$44,$00,$03,$2F,$63,$BE ..D../c>
                    fcb       $CB,$B5,$C3,$B5,$39,$17,$8E,$C5 K5C59..E
                    fcb       $39,$17,$DB,$9F,$56,$D1,$0A,$71 9.[.VQ.q
                    fcb       $7A,$79,$F3,$17,$0D,$8D,$56,$F4 zys...Vt
                    fcb       $DB,$72,$16,$A0,$51,$DB,$F0,$A4 [r. Q[p$
                    fcb       $91,$7A,$D5,$15,$89,$17,$82,$17 .zU.....
                    fcb       $59,$5E,$66,$62,$2E,$04,$10,$0B Y^fb....
                    fcb       $0E,$0A,$05,$07,$0D,$05,$08,$08 ........
                    fcb       $19,$8C,$0C,$04,$02,$00,$86,$88 ........
                    fcb       $79,$00,$03,$57,$C7,$DE,$94,$14 y..WG^..
                    fcb       $4B,$5E,$83,$96,$8C,$17,$90,$78 K^.....x
                    fcb       $2E,$6F,$23,$49,$01,$B3,$59,$90 .o#I.3Y.
                    fcb       $82,$7B,$C2,$16,$93,$61,$C5,$98 .{B..aE.
                    fcb       $D0,$15,$82,$17,$47,$5E,$66,$49 P...G^fI
                    fcb       $90,$14,$19,$58,$66,$62,$E1,$14 ...Xfba.
                    fcb       $CF,$B2,$AF,$B3,$82,$17,$2F,$62 O2/3../b
                    fcb       $D5,$15,$7B,$14,$FB,$B9,$67,$C0 U.{..9g@
                    fcb       $D0,$15,$82,$17,$55,$5E,$36,$A1 P...U^6!
                    fcb       $05,$71,$B8,$A0,$23,$62,$56,$D1 .q8 #bVQ
                    fcb       $04,$71,$6B,$A1,$8E,$48,$94,$14 .qk!.H..
                    fcb       $09,$B3,$2E,$04,$1D,$0B,$1B,$0A .3......
                    fcb       $04,$0B,$0E,$09,$0D,$05,$20,$1D ...... .
                    fcb       $01,$07,$82,$00,$85,$03,$0B,$0E ........
                    fcb       $09,$0D,$05,$20,$1D,$01,$06,$82 ... ....
                    fcb       $00,$89,$89,$5D,$00,$03,$3F,$C7 ...]..?G
                    fcb       $DE,$94,$14,$43,$5E,$16,$BC,$DB ^..C^.<[
                    fcb       $72,$47,$B9,$53,$BE,$8E,$61,$B8 rG9S>.a8
                    fcb       $16,$82,$17,$49,$5E,$63,$B1,$05 ...I^c1.
                    fcb       $BC,$9E,$61,$CE,$B0,$9B,$15,$11 <.aN0...
                    fcb       $8D,$5F,$4A,$3A,$15,$8D,$7B,$3A ._J:..{:
                    fcb       $15,$66,$7B,$D0,$15,$82,$17,$47 .f{P...G
                    fcb       $5E,$66,$49,$90,$14,$19,$58,$66 ^fI...Xf
                    fcb       $62,$F3,$17,$0D,$8D,$2E,$04,$19 bs......
                    fcb       $0B,$17,$0A,$04,$0C,$0D,$0A,$00 ........
                    fcb       $88,$14,$0D,$05,$20,$1D,$01,$06 .... ...
                    fcb       $82,$01,$02,$00,$90,$03,$02,$00 ........
                    fcb       $8A,$8A,$3A,$00,$03,$26,$63,$BE ..:..&c>
                    fcb       $CB,$B5,$C3,$B5,$73,$17,$1B,$B8 K5C5s..8
                    fcb       $E6,$A4,$39,$17,$DB,$9F,$56,$D1 f$9.[.VQ
                    fcb       $07,$71,$96,$D7,$C7,$B5,$66,$49 .q.WG5fI
                    fcb       $15,$EE,$36,$A1,$73,$76,$8E,$48 .n6!sv.H
                    fcb       $F7,$17,$17,$BA,$04,$0F,$0B,$0D w..:....
                    fcb       $0A,$04,$02,$00,$89,$02,$02,$00 ........
                    fcb       $8B,$03,$02,$00,$8D,$8B,$3F,$00 ......?.
                    fcb       $03,$2F,$C7,$DE,$94,$14,$4B,$5E ./G^..K^
                    fcb       $83,$96,$39,$17,$DB,$9F,$56,$D1 ..9.[.VQ
                    fcb       $09,$71,$7B,$B1,$66,$17,$0F,$A0 .q{1f..
                    fcb       $F3,$17,$0D,$8D,$52,$F4,$65,$49 s...RteI
                    fcb       $77,$47,$CE,$B5,$86,$5F,$99,$16 wGN5._..
                    fcb       $C2,$B3,$90,$14,$07,$58,$66,$49 B3...XfI
                    fcb       $2E,$04,$0B,$0B,$09,$0A,$01,$02 ........
                    fcb       $00,$8A,$03,$02,$00,$8C,$8C,$44 .......D
                    fcb       $00,$03,$2F,$63,$BE,$CB,$B5,$C3 ../c>K5C
                    fcb       $B5,$39,$17,$8E,$C5,$39,$17,$DB 59..E9.[
                    fcb       $9F,$56,$D1,$0A,$71,$7A,$79,$F3 .VQ.qzys
                    fcb       $17,$0D,$8D,$56,$F4,$DB,$72,$16 ...Vt[r.
                    fcb       $A0,$51,$DB,$F0,$A4,$91,$7A,$D5 Q[p$.zU
                    fcb       $15,$89,$17,$82,$17,$59,$5E,$66 .....Y^f
                    fcb       $62,$2E,$04,$10,$0B,$0E,$0A,$05 b.......
                    fcb       $07,$0D,$05,$08,$08,$19,$87,$0C ........
                    fcb       $04,$02,$00,$8B,$8D,$4D,$00,$03 .....M..
                    fcb       $3D,$C7,$DE,$94,$14,$4B,$5E,$83 =G^..K^.
                    fcb       $96,$DF,$16,$96,$BE,$45,$5E,$4F ._..>E^O
L1370               fcb       $72,$74,$4D,$56,$F4,$F4,$72,$4B rtMVttrK
L1378               fcb       $5E,$C3,$B5,$3B,$16,$B7,$B1,$94 ^C5;.71.
L1380               fcb       $AF,$3F,$A0,$89,$17,$82,$17,$50 /? ....P
L1388               fcb       $5E,$BE,$A0,$03,$71,$33,$98,$52 ^> .q3.R
L1390               fcb       $45,$65,$49,$77,$47,$89,$17,$82 EeIwG...
L1398               fcb       $17,$59,$5E,$66,$62,$2E,$04,$0B .Y^fb...
L13A0               fcb       $0B,$09,$0A,$04,$02,$00,$8A,$01 ........
L13A8               fcb       $02,$00,$8E,$8E,$80,$A2,$00,$03 ....."..
L13B0               fcb       $3B,$C7,$DE,$94,$14,$4B,$5E,$83 ;G^..K^.
L13B8               fcb       $96,$3B,$16,$B7,$B1,$39,$17,$DB .;.719.[
L13C0               fcb       $9F,$23,$D1,$13,$54,$E7,$B8,$0D .#Q.Tg8.
L13C8               fcb       $8D,$B8,$16,$FF,$14,$1B,$53,$91 .8....S.
L13D0               fcb       $7A,$56,$15,$5A,$62,$56,$F4,$F4 zV.ZbVtt
L13D8               fcb       $72,$43,$5E,$5B,$B1,$23,$63,$0B rC^[1#c.
L13E0               fcb       $C0,$04,$9A,$53,$BE,$8E,$48,$61 @..S>.Ha
L13E8               fcb       $17,$82,$C6,$2E,$04,$62,$0B,$60 ..F..b.`
L13F0               fcb       $0A,$02,$02,$00,$8D,$01,$59,$0E ......Y.
L13F8               fcb       $57,$0D,$1D,$01,$1E,$20,$1D,$04 W.... ..
L1400               fcb       $17,$5F,$BE,$73,$15,$C1,$B1,$3F ._>s.A1?
L1408               fcb       $DE,$B6,$14,$5D,$9E,$D6,$B5,$DB ^6.].V5[
L1410               fcb       $72,$1B,$D0,$99,$16,$C2,$B3,$2E r.P..B3.
L1418               fcb       $0D,$34,$20,$1D,$01,$0A,$17,$0A .4 .....
L1420               fcb       $00,$17,$1E,$8E,$04,$28,$5F,$BE .....(_>
L1428               fcb       $73,$15,$C1,$B1,$3F,$DE,$E1,$14 s.A1?^a.
L1430               fcb       $35,$92,$89,$17,$43,$16,$5B,$66 5...C.[f
L1438               fcb       $8E,$48,$FF,$15,$ED,$93,$09,$15 .H..m...
L1440               fcb       $03,$D2,$6B,$BF,$89,$4E,$8B,$54 .Rk?.N.T
L1448               fcb       $C7,$DE,$99,$AF,$39,$4A,$00,$8F G^./9J..
L1450               fcb       $8F,$3A,$00,$03,$2E,$63,$BE,$CB .:...c>K
L1458               fcb       $B5,$C3,$B5,$7B,$17,$F3,$8C,$01 5C5{.s..
L1460               fcb       $B3,$45,$90,$40,$49,$F3,$5F,$C3 3E.@Is_C
L1468               fcb       $9E,$09,$BA,$5B,$98,$56,$D1,$03 ..:[.VQ.
L1470               fcb       $71,$5B,$17,$BE,$98,$47,$5E,$96 q[.>.G^.
L1478               fcb       $D7,$89,$17,$82,$17,$55,$5E,$36 W....U^6
L1480               fcb       $A1,$9B,$76,$04,$07,$0B,$05,$0A !.v.....
L1488               fcb       $02,$02,$00,$8E,$90,$80,$A2,$00 ......".
L1490               fcb       $03,$56,$C7,$DE,$94,$14,$43,$5E .VG^..C^
L1498               fcb       $16,$BC,$DB,$72,$04,$9A,$53,$BE .<[r..S>
L14A0               fcb       $8E,$61,$B8,$16,$82,$17,$49,$5E .a8...I^
L14A8               fcb       $63,$B1,$05,$BC,$9E,$61,$CE,$B0 c1.<.aN0
L14B0               fcb       $9B,$15,$11,$8D,$5F,$4A,$3A,$15 ...._J:.
L14B8               fcb       $8D,$7B,$3A,$15,$66,$7B,$D0,$15 .{:.f{P.
L14C0               fcb       $82,$17,$47,$5E,$66,$49,$90,$14 ..G^fI..
L14C8               fcb       $19,$58,$66,$62,$F3,$17,$0D,$8D .Xfbs...
L14D0               fcb       $56,$F4,$F4,$72,$4B,$5E,$C3,$B5 VttrK^C5
L14D8               fcb       $09,$15,$A3,$A0,$03,$A0,$5F,$BE ..# . _>
L14E0               fcb       $99,$16,$C2,$B3,$F3,$17,$17,$8D ..B3s...
L14E8               fcb       $04,$47,$0B,$45,$0A,$02,$02,$00 .G.E....
L14F0               fcb       $89,$03,$02,$00,$A0,$01,$36,$0E .... .6.
L14F8               fcb       $34,$0D,$14,$01,$1B,$04,$10,$5F 4......_
L1500               fcb       $BE,$09,$15,$A3,$A0,$89,$4E,$A5 >..# .N%
L1508               fcb       $54,$DB,$16,$D3,$B9,$BF,$6C,$0D T[.S9?l.
L1510               fcb       $1C,$00,$91,$17,$1B,$91,$04,$12 ........
L1518               fcb       $5F,$BE,$09,$15,$A3,$A0,$C9,$54 _>..# IT
L1520               fcb       $B5,$B7,$AF,$14,$90,$73,$1B,$58 57/..s.X
L1528               fcb       $3F,$A1,$17,$1C,$00,$04,$02,$00 ?!......
L1530               fcb       $92,$91,$80,$8F,$00,$03,$22,$C7 ......"G
L1538               fcb       $DE,$94,$14,$4B,$5E,$83,$96,$CB ^..K^..K
L1540               fcb       $17,$4E,$C5,$FB,$17,$53,$BE,$4E .NE..S>N
L1548               fcb       $45,$31,$49,$46,$5E,$44,$A0,$89 E1IF^D .
L1550               fcb       $17,$82,$17,$55,$5E,$36,$A1,$9B ...U^6!.
L1558               fcb       $76,$04,$68,$0B,$66,$0A,$02,$2F v.h.f../
L1560               fcb       $0E,$2D,$0D,$10,$01,$1B,$04,$0C .-......
L1568               fcb       $5F,$BE,$09,$15,$A3,$A0,$4B,$7B _>..# K{
L1570               fcb       $2F,$B8,$9B,$C1,$0D,$19,$00,$90 /8.A....
L1578               fcb       $17,$1B,$90,$04,$0F,$5F,$BE,$09 ....._>.
L1580               fcb       $15,$A3,$A0,$C9,$54,$B5,$B7,$89 .# IT57.
L1588               fcb       $14,$D0,$47,$2E,$17,$1C,$00,$11 .PG.....
L1590               fcb       $32,$0E,$30,$0D,$10,$08,$1C,$04 2.0.....
L1598               fcb       $0C,$8D,$7B,$8E,$14,$63,$B1,$FB ..{..c1.
L15A0               fcb       $5C,$5F,$A0,$1B,$9C,$0D,$1C,$08 \_ .....
L15A8               fcb       $1B,$17,$1C,$91,$17,$1B,$00,$04 ........
L15B0               fcb       $12,$64,$B7,$B7,$C6,$B0,$C6,$D6 .d77F0FV
L15B8               fcb       $6A,$DB,$72,$81,$5B,$91,$AF,$F0 j[r.[./p
L15C0               fcb       $A4,$5B,$BB,$92,$4B,$00,$03,$3B $[;.K..;
L15C8               fcb       $C7,$DE,$94,$14,$43,$5E,$16,$BC G^..C^.<
L15D0               fcb       $DB,$72,$9E,$61,$D0,$B0,$9B,$53 [r.aP0.S
L15D8               fcb       $6B,$BF,$4E,$45,$11,$A0,$FB,$14 k?NE. ..
L15E0               fcb       $4B,$B2,$70,$C0,$6E,$98,$FA,$17 K2p@n.z.
L15E8               fcb       $DA,$78,$3F,$16,$0D,$47,$F7,$17 Zx?..Gw.
L15F0               fcb       $17,$BA,$82,$17,$2F,$62,$D5,$15 .:../bU.
L15F8               fcb       $7B,$14,$55,$A4,$09,$B7,$47,$5E {.U$.7G^
L1600               fcb       $66,$49,$2E,$04,$0B,$0B,$09,$0A fI......
L1608               fcb       $03,$02,$00,$90,$04,$02,$00,$93 ........
L1610               fcb       $93,$22,$00,$03,$12,$C7,$DE,$94 ."...G^.
L1618               fcb       $14,$4B,$5E,$96,$96,$DB,$72,$54 .K^..[rT
L1620               fcb       $59,$D6,$83,$98,$C5,$57,$61,$04 YV..EWa.
L1628               fcb       $0B,$0B,$09,$0A,$03,$02,$00,$92 ........
L1630               fcb       $04,$02,$00,$94,$94,$58,$00,$03 .....X..
L1638               fcb       $3B,$C7,$DE,$94,$14,$43,$5E,$16 ;G^..C^.
L1640               fcb       $BC,$DB,$72,$9E,$61,$D0,$B0,$9B <[r.aP0.
L1648               fcb       $53,$6B,$BF,$4E,$45,$11,$A0,$FB Sk?NE. .
L1650               fcb       $14,$4B,$B2,$70,$C0,$6E,$98,$FA .K2p@n.z
L1658               fcb       $17,$DA,$78,$3F,$16,$0D,$47,$23 .Zx?..G#
L1660               fcb       $15,$17,$BA,$82,$17,$2F,$62,$D5 ..:../bU
L1668               fcb       $15,$7B,$14,$55,$A4,$09,$B7,$59 .{.U$.7Y
L1670               fcb       $5E,$66,$62,$2E,$04,$18,$0B,$16 ^fb.....
L1678               fcb       $0A,$03,$02,$00,$93,$04,$0F,$0E ........
L1680               fcb       $0D,$0D,$09,$20,$1D,$03,$00,$16 ... ....
L1688               fcb       $17,$15,$95,$0C,$00,$95,$95,$32 .......2
L1690               fcb       $00,$03,$20,$C7,$DE,$94,$14,$4B .. G^..K
L1698               fcb       $5E,$83,$96,$3B,$16,$B7,$B1,$39 ^..;.719
L16A0               fcb       $17,$DB,$9F,$56,$D1,$03,$71,$5B .[.VQ.q[
L16A8               fcb       $17,$BE,$98,$47,$5E,$96,$D7,$23 .>.G^.W#
L16B0               fcb       $15,$17,$BA,$04,$0D,$0B,$0B,$0A ..:.....
L16B8               fcb       $36,$01,$8F,$17,$01,$8F,$03,$02 6.......
L16C0               fcb       $00,$94,$96,$30,$00,$03,$18,$C7 ...0...G
L16C8               fcb       $DE,$94,$14,$4B,$5E,$83,$96,$FF ^..K^...
L16D0               fcb       $14,$97,$9A,$FB,$14,$4B,$B2,$4F .....K2O
L16D8               fcb       $59,$0C,$A3,$91,$C5,$FF,$8B,$04 Y.#.E...
L16E0               fcb       $13,$0B,$11,$0A,$01,$02,$00,$A3 .......#
L16E8               fcb       $02,$02,$00,$A4,$04,$02,$00,$97 ...$....
L16F0               fcb       $03,$02,$00,$A4,$97,$30,$00,$03 ...$.0..
L16F8               fcb       $18,$C7,$DE,$94,$14,$4B,$5E,$83 .G^..K^.
L1700               fcb       $96,$FB,$14,$4B,$B2,$F0,$59,$9B ...K2pY.
L1708               fcb       $B7,$4F,$59,$0C,$A3,$91,$C5,$FF 7OY.#.E.
L1710               fcb       $8B,$04,$13,$0B,$11,$0A,$01,$02 ........
L1718               fcb       $00,$A2,$02,$02,$00,$96,$03,$02 ."......
L1720               fcb       $00,$A3,$04,$02,$00,$98,$98,$40 .#.....@
L1728               fcb       $00,$03,$28,$6C,$BE,$29,$A1,$16 ..(l>)!.
L1730               fcb       $71,$DB,$72,$F0,$81,$BF,$6D,$51 q[rp.?mQ
L1738               fcb       $18,$55,$C2,$1B,$60,$5F,$BE,$23 .UB.`_>#
L1740               fcb       $15,$F3,$B9,$0E,$D0,$11,$8A,$83 .s9.P...
L1748               fcb       $64,$84,$15,$96,$5F,$7F,$17,$E6 d..._.f
L1750               fcb       $93,$DB,$63,$04,$13,$0B,$11,$0A .[c.....
L1758               fcb       $01,$02,$00,$9B,$02,$02,$00,$99 ........
L1760               fcb       $03,$02,$00,$97,$04,$02,$00,$9E ........
L1768               fcb       $99,$44,$00,$03,$2C,$83,$7A,$45 .D..,.zE
L1770               fcb       $45,$E3,$8B,$10,$B2,$C4,$6A,$59 Ec..2DjY
L1778               fcb       $60,$5B,$B1,$C7,$DE,$66,$17,$8E `[1G^f..
L1780               fcb       $48,$D6,$B5,$DB,$72,$47,$B9,$53 HV5[rG9S
L1788               fcb       $BE,$0E,$D0,$11,$8A,$83,$64,$84 >.P...d.
L1790               fcb       $15,$96,$5F,$7F,$17,$E6,$93,$DB .._.f.[
L1798               fcb       $63,$04,$13,$0B,$11,$0A,$01,$02 c.......
L17A0               fcb       $00,$9F,$02,$02,$00,$96,$03,$02 ........
L17A8               fcb       $00,$98,$04,$02,$00,$9A,$9A,$59 .......Y
L17B0               fcb       $00,$03,$41,$6C,$BE,$29,$A1,$16 ..Al>)!.
L17B8               fcb       $71,$DB,$72,$F0,$59,$9B,$B7,$8E q[rpY.7.
L17C0               fcb       $C5,$31,$62,$09,$B3,$76,$BE,$51 E1b.3v>Q
L17C8               fcb       $18,$45,$C2,$83,$48,$A7,$B7,$82 .EB.H'7.
L17D0               fcb       $17,$49,$5E,$63,$B1,$04,$BC,$00 .I^c1.<.
L17D8               fcb       $B3,$5B,$E3,$16,$6C,$4B,$62,$03 3[c.lKb.
L17E0               fcb       $A0,$5F,$BE,$F7,$17,$F3,$B9,$0E _>w.s9.
L17E8               fcb       $D0,$11,$8A,$96,$64,$DB,$72,$EF P...d[ro
L17F0               fcb       $BD,$FF,$A5,$2E,$04,$13,$0B,$11 =.%.....
L17F8               fcb       $0A,$01,$02,$00,$9B,$02,$02,$00 ........
L1800               fcb       $99,$03,$02,$00,$9C,$04,$02,$00 ........
L1808               fcb       $A4,$9B,$4D,$00,$03,$35,$6C,$BE $.M..5l>
L1810               fcb       $29,$A1,$03,$71,$73,$15,$0B,$A3 )!.qs..#
L1818               fcb       $96,$96,$DB,$72,$F0,$81,$BF,$6D ..[rp.?m
L1820               fcb       $51,$18,$45,$C2,$83,$48,$A7,$B7 Q.EB.H'7
L1828               fcb       $82,$17,$50,$5E,$BE,$A0,$19,$71 ..P^> .q
L1830               fcb       $46,$48,$B8,$16,$7B,$14,$89,$91 FH8.{...
L1838               fcb       $08,$99,$D7,$78,$B3,$9A,$EF,$BD ..Wx3.o=
L1840               fcb       $FF,$A5,$2E,$04,$13,$0B,$11,$0A .%......
L1848               fcb       $01,$02,$00,$A2,$02,$02,$00,$9D ..."....
L1850               fcb       $04,$02,$00,$9A,$03,$02,$00,$98 ........
L1858               fcb       $9C,$3A,$00,$03,$26,$C7,$DE,$94 .:..&G^.
L1860               fcb       $14,$55,$5E,$50,$BD,$90,$5A,$C4 .U^P=.ZD
L1868               fcb       $6A,$59,$60,$5B,$B1,$5F,$BE,$F7 jY`[1_>w
L1870               fcb       $17,$F3,$B9,$9E,$61,$D0,$B0,$9B .s9.aP0.
L1878               fcb       $53,$C3,$9E,$5F,$BE,$7F,$17,$E6 SC._>.f
L1880               fcb       $93,$DB,$63,$04,$0F,$0B,$0D,$0A .[c.....
L1888               fcb       $01,$02,$00,$9D,$02,$02,$00,$9F ........
L1890               fcb       $04,$02,$00,$9A,$9D,$80,$B3,$00 ......3.
L1898               fcb       $03,$12,$C7,$DE,$94,$14,$43,$5E ..G^..C^
L18A0               fcb       $16,$BC,$DB,$72,$04,$9A,$53,$BE .<[r..S>
L18A8               fcb       $0E,$D0,$9B,$8F,$04,$80,$9B,$0B .P......
L18B0               fcb       $80,$98,$0A,$01,$02,$00,$9B,$03 ........
L18B8               fcb       $02,$00,$9E,$17,$80,$88,$0D,$80 ........
L18C0               fcb       $85,$08,$21,$0E,$80,$80,$0D,$54 ..!....T
L18C8               fcb       $05,$7F,$04,$2A,$C7,$DE,$DE,$14 ..*G^^.
L18D0               fcb       $64,$7A,$89,$17,$82,$17,$54,$5E dz....T^
L18D8               fcb       $38,$A0,$3B,$F4,$4B,$49,$C7,$DE 8 ;tKIG^
L18E0               fcb       $66,$17,$D3,$61,$03,$A0,$5F,$BE f.Sa. _>
L18E8               fcb       $39,$17,$E6,$9E,$D6,$15,$E1,$14 9.f.V.a.
L18F0               fcb       $FB,$8C,$17,$A7,$5B,$BB,$17,$36 ...'[;.6
L18F8               fcb       $00,$17,$29,$FF,$17,$2A,$FF,$17 ..)..*..
L1900               fcb       $2B,$FF,$17,$2C,$FF,$17,$2D,$FF +..,..-.
L1908               fcb       $17,$2E,$FF,$17,$31,$FF,$17,$34 ....1..4
L1910               fcb       $FF,$17,$35,$FF,$17,$3A,$FF,$17 ..5..:..
L1918               fcb       $3C,$00,$00,$81,$04,$28,$4B,$49 <....(KI
L1920               fcb       $C7,$DE,$DE,$14,$64,$7A,$16,$EE G^^.dz.n
L1928               fcb       $DB,$72,$10,$CB,$49,$5E,$CF,$7B [r.KI^O{
L1930               fcb       $D9,$B5,$3B,$4A,$8E,$48,$51,$18 Y5;J.HQ.
L1938               fcb       $48,$C2,$46,$48,$89,$17,$82,$17 HBFH....
L1940               fcb       $49,$5E,$07,$B3,$57,$98,$04,$02 I^.3W...
L1948               fcb       $00,$9C,$9E,$25,$00,$03,$11,$C7 ...%...G
L1950               fcb       $DE,$94,$14,$43,$5E,$16,$BC,$DB ^..C^.<[
L1958               fcb       $72,$95,$5F,$19,$BC,$46,$48,$2E r._.<FH.
L1960               fcb       $04,$0F,$0B,$0D,$0A,$01,$02,$00 ........
L1968               fcb       $9D,$02,$02,$00,$9F,$03,$02,$00 ........
L1970               fcb       $98,$9F,$26,$00,$03,$12,$C7,$DE ..&...G^
L1978               fcb       $94,$14,$43,$5E,$16,$BC,$DB,$72 ..C^.<[r
L1980               fcb       $47,$B9,$53,$BE,$0E,$D0,$9B,$8F G9S>.P..
L1988               fcb       $04,$0F,$0B,$0D,$0A,$04,$02,$00 ........
L1990               fcb       $9C,$03,$02,$00,$9E,$02,$02,$00 ........
L1998               fcb       $99,$A0,$20,$00,$03,$14,$C7,$DE .  ...G^
L19A0               fcb       $94,$14,$4B,$5E,$83,$96,$CF,$17 ..K^..O.
L19A8               fcb       $7B,$B4,$E3,$B8,$F3,$8C,$01,$B3 {4c8s..3
L19B0               fcb       $DB,$95,$04,$07,$0B,$05,$0A,$04 [.......
L19B8               fcb       $02,$00,$90,$A1,$2C,$00,$03,$20 ...!,..
L19C0               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96 G^..K^..
L19C8               fcb       $5F,$17,$46,$48,$39,$17,$DB,$9F _.FH9.[.
L19D0               fcb       $56,$D1,$03,$71,$5B,$17,$BE,$98 VQ.q[.>.
L19D8               fcb       $47,$5E,$96,$D7,$23,$15,$17,$BA G^.W#..:
L19E0               fcb       $04,$07,$0B,$05,$0A,$03,$02,$00 ........
L19E8               fcb       $84,$A2,$30,$00,$03,$18,$C7,$DE ."0...G^
L19F0               fcb       $94,$14,$4B,$5E,$83,$96,$FB,$14 ..K^....
L19F8               fcb       $4B,$B2,$4F,$59,$06,$A3,$9D,$61 K2OY.#.a
L1A00               fcb       $4C,$5E,$91,$C5,$FF,$8B,$04,$13 L^.E....
L1A08               fcb       $0B,$11,$0A,$03,$02,$00,$A4,$01 ......$.
L1A10               fcb       $02,$00,$96,$02,$02,$00,$A3,$04 ......#.
L1A18               fcb       $02,$00,$97,$A3,$30,$00,$03,$18 ...#0...
L1A20               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96 G^..K^..
L1A28               fcb       $FF,$14,$97,$9A,$FB,$14,$D3,$93 ......S.
L1A30               fcb       $54,$59,$CC,$83,$91,$C5,$FF,$8B TYL..E..
L1A38               fcb       $04,$13,$0B,$11,$0A,$03,$02,$00 ........
L1A40               fcb       $A4,$01,$02,$00,$A2,$02,$02,$00 $..."...
L1A48               fcb       $96,$04,$02,$00,$97,$A4,$30,$00 .....$0.
L1A50               fcb       $03,$18,$C7,$DE,$94,$14,$4B,$5E ..G^..K^
L1A58               fcb       $83,$96,$FB,$14,$D3,$93,$54,$59 ....S.TY
L1A60               fcb       $C6,$83,$9D,$61,$4C,$5E,$91,$C5 F..aL^.E
L1A68               fcb       $FF,$8B,$04,$13,$0B,$11,$0A,$03 ........
L1A70               fcb       $02,$00,$A3,$01,$02,$00,$A2,$02 ..#...".
L1A78               fcb       $02,$00,$96,$04,$02,$00,$A3,$A5 ......#%
L1A80               fcb       $2C,$00,$03,$20,$C7,$DE,$94,$14 ,.. G^..
L1A88               fcb       $4B,$5E,$96,$96,$DB,$72,$A5,$B7 K^..[r%7
L1A90               fcb       $76,$B1,$DB,$16,$D3,$B9,$9B,$6C v1[.S9.l
L1A98               fcb       $23,$D1,$13,$54,$E3,$8B,$0B,$5C #Q.Tc..\
L1AA0               fcb       $95,$5F,$9B,$C1,$04,$07,$0B,$05 ._.A....
L1AA8               fcb       $0A,$03,$02,$00,$A6,$A6,$50,$00 ....&&P.
L1AB0               fcb       $03,$2C,$C7,$DE,$94,$14,$43,$5E .,G^..C^
L1AB8               fcb       $16,$BC,$DB,$72,$8E,$61,$B8,$16 .<[r.a8.
L1AC0               fcb       $82,$17,$52,$5E,$65,$49,$77,$47 ..R^eIwG
L1AC8               fcb       $56,$F4,$F4,$72,$4B,$5E,$C3,$B5 VttrK^C5
L1AD0               fcb       $A9,$15,$DB,$8B,$83,$7A,$5F,$BE ).[..z_>
L1AD8               fcb       $D7,$14,$43,$7A,$CF,$98,$04,$1F W.CzO...
L1AE0               fcb       $0B,$1D,$0A,$04,$02,$00,$A5,$17 ......%.
L1AE8               fcb       $05,$0D,$03,$08,$2C,$91,$36,$05 ....,.6.
L1AF0               fcb       $0D,$03,$08,$2C,$91,$37,$05,$0D ...,.7..
L1AF8               fcb       $03,$08,$2C,$91,$33,$01,$91

L20FF               fcb       $00                 ..,.3...
                    fcb       $91,$3A,$01,$03,$00,$00,$00,$03 .:......
                    fcb       $03,$00,$00,$00,$06,$48,$82,$00 .....H..
                    fcb       $80,$02,$02,$E9,$B3,$07,$3F,$0B ...i3.?.
                    fcb       $3D,$0A,$0C,$01,$8C,$36,$01,$8A =....6..
                    fcb       $33,$01,$8A,$34,$01,$8A,$35,$01 3..4..5.
                    fcb       $8B,$2D,$01,$8C,$26,$28,$04,$26 .-..&(.&
                    fcb       $C7,$DE,$D3,$14,$E6,$96,$16,$EE G^S.f..n
L1B38               fcb       $DB,$72,$E9,$B3,$66,$17,$76,$B1 [ri3f.v1
L1B40               fcb       $1F,$54,$C3,$B5,$F3,$8C,$5F,$BE .TC5s._>
L1B48               fcb       $F3,$17,$43,$DB,$B9,$55,$CB,$B9 s.C[9UK9
L1B50               fcb       $5F,$BE,$39,$17,$FF,$9F,$09,$5E _>9....^
L1B58               fcb       $82,$00,$84,$02,$03,$81,$5B,$52 ......[R
L1B60               fcb       $07,$54,$0E,$52,$0D,$22,$0A,$08 .T.R."..
L1B68               fcb       $04,$1E,$5F,$BE,$D3,$14,$13,$B4 .._>S..4
L1B70               fcb       $C5,$98,$C0,$16,$82,$17,$46,$5E E.@...F^
L1B78               fcb       $44,$A0,$53,$17,$B3,$E0,$49,$1B D S.3`I.
L1B80               fcb       $99,$16,$07,$BC,$BF,$9A,$1C,$B5 ...<?..5
L1B88               fcb       $0D,$2C,$14,$0A,$0B,$04,$27,$C7 .,....'G
L1B90               fcb       $DE,$C6,$22,$9B,$15,$5B,$CA,$6B ^F"..[Jk
L1B98               fcb       $BF,$2B,$6E,$6B,$BF,$5F,$BE,$23 ?+nk?_>#
L1BA0               fcb       $15,$F3,$B9,$46,$B8,$51,$5E,$96 .s9F8Q^.
L1BA8               fcb       $64,$DB,$72,$01,$B3,$56,$90,$C6 d[r.3V.F
L1BB0               fcb       $9C,$D6,$9C,$56,$72,$2E,$0C,$2A .V.Vr..*
L1BB8               fcb       $84,$00,$A0,$03,$0D,$5F,$BE,$5B .. .._>[
L1BC0               fcb       $B1,$4B,$7B,$01,$68,$0A,$58,$2F 1K{.h.X/
L1BC8               fcb       $62,$2E,$07,$11,$0D,$0F,$0A,$15 b.......
L1BD0               fcb       $04,$04,$F4,$4F,$AB,$A2,$17,$05 ..tO+"..
L1BD8               fcb       $00,$1C,$1D,$23,$0F,$02,$03,$01 ...#....
L1BE0               fcb       $68,$44,$0D,$2A,$88,$00,$80,$02 hD.*....
L1BE8               fcb       $04,$FB,$B9,$67,$C0,$07,$05,$0D ..9g@...
L1BF0               fcb       $03,$0A,$12,$8D,$03,$18,$5F,$BE ......_>
L1BF8               fcb       $66,$17,$8F,$49,$4B,$5E,$C8,$B5 f..IK^H5
L1C00               fcb       $DB,$46,$AB,$98,$5F,$BE,$23,$15 [F+._>#.
L1C08               fcb       $F3,$B9,$81,$5B,$1B,$B5,$0D,$2A s9.[.5.*
L1C10               fcb       $00,$00,$80,$02,$04,$FB,$B9,$67 ......9g
L1C18               fcb       $C0,$07,$05,$0D,$03,$0A,$12,$8D @.......
L1C20               fcb       $03,$18,$5F,$BE,$66,$17,$8F,$49 .._>f..I
L1C28               fcb       $4B,$5E,$C8,$B5,$DB,$46,$AB,$98 K^H5[F+.
L1C30               fcb       $5F,$BE,$F7,$17,$F3,$B9,$81,$5B _>w.s9.[
L1C38               fcb       $1B,$B5,$12,$44,$8C,$05,$A4,$03 .5.D..$.
L1C40               fcb       $14,$54,$45,$91,$7A,$B8,$16,$53 .TE.z8.S
L1C48               fcb       $15,$75,$98,$09,$BC,$BE,$9F,$D5 .u..<>.U
L1C50               fcb       $15,$9F,$15,$7F,$B1,$02,$06,$3E ...1..>
L1C58               fcb       $6E,$14,$58,$91,$7A,$07,$21,$0D n.X.z.!.
L1C60               fcb       $1F,$0A,$08,$04,$1B,$5F,$BE,$D0 ....._>P
L1C68               fcb       $15,$64,$B7,$EE,$7A,$C0,$7A,$2F .d7nz@z/
L1C70               fcb       $17,$0D,$47,$FC,$ED,$10,$B2,$D1 ..G.m.2Q
L1C78               fcb       $6A,$8F,$64,$03,$A1,$27,$A0,$22 j.d.!' "
L1C80               fcb       $0E,$42,$A1,$00,$E4,$03,$19,$5F .B!.d.._
L1C88               fcb       $BE,$5B,$B1,$4B,$7B,$4E,$45,$31 >[1K{NE1
L1C90               fcb       $49,$55,$5E,$44,$D2,$0E,$58,$4B IU^DR.XK
L1C98               fcb       $4A,$AB,$98,$63,$98,$03,$B1,$2E J+.c..1.
L1CA0               fcb       $07,$18,$0D,$16,$0A,$08,$04,$12 ........
L1CA8               fcb       $2C,$1D,$5F,$A0,$D3,$B3,$B8,$16 ,._ S38.
L1CB0               fcb       $43,$16,$57,$63,$28,$54,$BD,$5F C.Wc(T=_
L1CB8               fcb       $23,$BC,$02,$08,$54,$8B,$9B,$6C #<..T..l
L1CC0               fcb       $81,$BA,$33,$B1,$0F,$6B,$8E,$00 .:31.k..
L1CC8               fcb       $80,$03,$34,$5F,$BE,$5B,$B1,$4B ..4_>[1K
L1CD0               fcb       $7B,$4A,$45,$FF,$78,$35,$A1,$66 {JE.x5!f
L1CD8               fcb       $17,$0F,$A0,$73,$15,$C1,$B1,$3F .. s.A1?
L1CE0               fcb       $DE,$DF,$16,$1A,$B1,$F3,$5F,$03 ^_..1s_.
L1CE8               fcb       $A0,$4E,$45,$01,$60,$43,$5E,$08 NE.`C^.
L1CF0               fcb       $4F,$56,$5E,$DB,$72,$04,$9A,$53 OV^[r..S
L1CF8               fcb       $BE,$55,$A4,$09,$B7,$DB,$63,$07 >U$.7[c.
L1D00               fcb       $24,$0D,$22,$0A,$0B,$04,$1E,$5F $."...._
L1D08               fcb       $BE,$5B,$B1,$EA,$48,$94,$5F,$D6 >[1jH._V
L1D10               fcb       $B5,$C4,$9C,$46,$5E,$07,$B2,$04 5D.F^.2.
L1D18               fcb       $58,$81,$8D,$11,$58,$8A,$96,$4B X...X..K
L1D20               fcb       $7B,$BB,$54,$C9,$D2,$02,$0A,$09 {;TIR...
L1D28               fcb       $BA,$5B,$98,$14,$6C,$4B,$6E,$DB :[..lKn[
L1D30               fcb       $8B,$22,$58,$95,$00,$80,$03,$32 ."X....2
L1D38               fcb       $68,$4D,$AF,$A0,$51,$18,$55,$C2 hM/ Q.UB
L1D40               fcb       $50,$BD,$0B,$5C,$83,$48,$4E,$48 P=.\.HNH
L1D48               fcb       $46,$49,$66,$17,$D0,$47,$F3,$5F FIf.PGs_
L1D50               fcb       $56,$D1,$16,$71,$DB,$72,$89,$4E VQ.q[r.N
L1D58               fcb       $73,$9E,$C3,$9E,$47,$55,$C6,$9A s.C.GUF.
L1D60               fcb       $65,$62,$53,$17,$B3,$55,$05,$67 ebS.3U.g
L1D68               fcb       $6F,$62,$07,$10,$0B,$0E,$0A,$12 ob......
L1D70               fcb       $01,$8E,$0C,$01,$8E,$38,$05,$0D .....8..
L1D78               fcb       $03,$00,$A5,$90,$02,$0D,$89,$4E ..%....N
L1D80               fcb       $73,$9E,$FB,$B9,$8F,$7A,$03,$58 s..9.z.X
L1D88               fcb       $3B,$8E,$52,$23,$2F,$95,$05,$A0 ;.R#/..
L1D90               fcb       $03,$20,$49,$45,$BE,$9F,$83,$61 . IE>..a
L1D98               fcb       $09,$79,$15,$8A,$50,$BD,$0B,$5C .y..P=.\
L1DA0               fcb       $83,$7A,$5F,$BE,$D7,$14,$BF,$9A .z_>W.?.
L1DA8               fcb       $91,$AF,$96,$64,$DB,$72,$01,$B3 ./.d[r.3
L1DB0               fcb       $DB,$95,$02,$08,$3E,$6E,$F0,$59 [...>npY
L1DB8               fcb       $C6,$15,$B3,$9F,$27,$80,$9A,$9C F.3.'...
L1DC0               fcb       $00,$80,$03,$34,$AF,$6E,$73,$49 ...4/nsI
L1DC8               fcb       $79,$4F,$AF,$9B,$73,$15,$F5,$BD yO/.s.u=
L1DD0               fcb       $30,$15,$AB,$6E,$66,$CA,$FB,$17 0.+nfJ..
L1DD8               fcb       $53,$BE,$63,$7A,$B5,$6C,$B8,$16 S>cz5l8.
L1DE0               fcb       $57,$17,$1F,$B3,$CD,$9A,$66,$17 W..3M.f.
L1DE8               fcb       $8E,$48,$5B,$17,$F0,$8B,$13,$BF .H[.p..?
L1DF0               fcb       $AF,$14,$04,$68,$5B,$5E,$3F,$A1 /..h[^?!
L1DF8               fcb       $07,$55,$0B,$53,$0A,$11,$20,$04 .U.S.. .
L1E00               fcb       $1E,$5F,$BE,$73,$15,$F5,$BD,$94 ._>s.u=.
L1E08               fcb       $14,$4E,$5E,$5D,$9E,$16,$60,$51 .N^]..`Q
L1E10               fcb       $18,$45,$C2,$83,$48,$06,$9A,$C2 .EB.H..B
L1E18               fcb       $16,$83,$61,$5F,$BE,$DB,$95,$36 ..a_>[.6
L1E20               fcb       $10,$04,$0E,$5F,$BE,$73,$15,$F5 ..._>s.u
L1E28               fcb       $BD,$94,$14,$45,$5E,$85,$8D,$17 =..E^...
L1E30               fcb       $60,$17,$19,$04,$17,$5F,$BE,$73 `...._>s
L1E38               fcb       $15,$F5,$BD,$94,$14,$56,$5E,$2B .u=..V^+
L1E40               fcb       $A0,$F1,$B8,$02,$A1,$89,$17,$DE q8.!..^
L1E48               fcb       $14,$64,$7A,$2E,$34,$01,$89,$02 .dz.4...
L1E50               fcb       $08,$79,$4F,$AF,$9B,$73,$15,$F5 .yO/.s.u
L1E58               fcb       $BD,$16,$59,$91,$00,$A0,$02,$04 =.Y.. ..
L1E60               fcb       $F8,$8B,$23,$62,$03,$16,$44,$45 x.#b..DE
L1E68               fcb       $EF,$60,$AE,$D0,$F3,$5F,$F8,$8B o`.Ps_x.
L1E70               fcb       $23,$62,$4B,$7B,$03,$A0,$0F,$A0 #bK{. .
L1E78               fcb       $F3,$17,$17,$8D,$07,$36,$0D,$34 s....6.4
L1E80               fcb       $0A,$12,$04,$2F,$56,$45,$D2,$B0 .../VER0
L1E88               fcb       $09,$15,$A3,$A0,$5F,$A0,$8B,$9A ..# _ ..
L1E90               fcb       $B9,$46,$5B,$CA,$C7,$DE,$3B,$F4 9F[JG^;t
L1E98               fcb       $3E,$6E,$06,$58,$66,$C6,$53,$15 >n.XfFS.
L1EA0               fcb       $0D,$8D,$82,$17,$54,$5E,$3F,$A0 ....T^?
L1EA8               fcb       $90,$14,$06,$58,$09,$B3,$8B,$9A ...X.3..
L1EB0               fcb       $C7,$DE,$2E,$81,$16,$42,$00,$05 G^...B..
L1EB8               fcb       $A0,$03,$12,$44,$45,$EF,$60,$AE ..DEo`.
L1EC0               fcb       $D0,$F3,$5F,$F8,$8B,$23,$62,$4B Ps_x.#bK
L1EC8               fcb       $7B,$F4,$72,$DB,$63,$02,$0A,$6C {tr[c..l
L1ED0               fcb       $4D,$F7,$62,$E6,$8B,$3F,$16,$74 Mwbf.?.t
L1ED8               fcb       $CA,$07,$1D,$0D,$1B,$0A,$12,$04 J.......
L1EE0               fcb       $17,$5F,$BE,$3F,$16,$74,$CA,$D3 ._>?.tJS
L1EE8               fcb       $14,$90,$96,$CE,$9C,$11,$A0,$23 ...N.. #
L1EF0               fcb       $62,$5B,$4D,$6E,$A7,$E6,$8B,$2E b[Mn'f..
L1EF8               fcb       $18,$80,$C5,$91,$00,$84,$07,$80 ..E.....
L1F00               fcb       $98,$0D,$80,$95,$0A,$08,$04,$80 ........
L1F08               fcb       $90,$9E,$C5,$BE,$9F,$33,$17,$1F ..E>.3..
L1F10               fcb       $54,$CE,$B5,$1B,$79,$56,$D1,$90 TN5.yVQ.
L1F18               fcb       $73,$2F,$17,$DA,$46,$0A,$EE,$2F s/.ZF.n/
L1F20               fcb       $62,$D6,$E7,$C3,$9C,$7B,$9B,$19 bVgC.{..
L1F28               fcb       $87,$50,$D1,$33,$70,$98,$8C,$91 .PQ3p...
L1F30               fcb       $7A,$E4,$14,$96,$5F,$2F,$C6,$44 zd.._/FD
L1F38               fcb       $F4,$59,$5E,$43,$49,$82,$17,$29 tY^CI..)
L1F40               fcb       $A1,$73,$76,$EB,$99,$96,$91,$F4 !svk...t
L1F48               fcb       $BD,$FA,$17,$73,$49,$73,$BE,$E4 =z.sIs>d
L1F50               fcb       $14,$26,$60,$16,$EE,$56,$72,$82 .&`.nVr.
L1F58               fcb       $17,$1B,$A1,$54,$72,$75,$98,$C3 ..!Tru.C
L1F60               fcb       $B5,$33,$98,$8F,$8C,$73,$7B,$73 53...s{s
L1F68               fcb       $BE,$E9,$16,$B4,$D0,$EE,$68,$84 >i.4Pnh.
L1F70               fcb       $15,$26,$60,$3B,$F4,$6E,$A7,$16 .&`;tn'.
L1F78               fcb       $8A,$DB,$72,$F8,$8B,$23,$62,$6B .[rx.#bk
L1F80               fcb       $BF,$0B,$6C,$96,$96,$FB,$75,$A3 ?.l...u#
L1F88               fcb       $D0,$42,$8E,$04,$EE,$52,$5E,$72 PB..nR^r
L1F90               fcb       $B1,$2F,$49,$16,$58,$DF,$9C,$DB 1/I.X_.[
L1F98               fcb       $F9,$03,$1F,$5F,$BE,$5B,$B1,$4B y.._>[1K
L1FA0               fcb       $7B,$52,$45,$53,$8B,$1B,$C4,$03 {RES..D.
L1FA8               fcb       $A0,$5F,$BE,$F3,$17,$F3,$8C,$B9 _>s.s.9
L1FB0               fcb       $46,$5B,$CA,$5F,$BE,$3F,$16,$74 F[J_>?.t
L1FB8               fcb       $CA,$2E,$02,$04,$FB,$A5,$A7,$AD J....%'-
L1FC0               fcb       $19,$6F,$92,$00,$A8,$03,$10,$45 .o..(..E
L1FC8               fcb       $45,$8E,$48,$DB,$8B,$4B,$7B,$83 E.H[.K{.
L1FD0               fcb       $7A,$5F,$BE,$39,$17,$FF,$9F,$02 z_>9....
L1FD8               fcb       $04,$10,$53,$FF,$5A,$07,$52,$0B ..S.Z.R.
L1FE0               fcb       $50,$0A,$14,$34,$0E,$32,$0D,$2F P..4.2./
L1FE8               fcb       $09,$14,$1E,$11,$12,$04,$28,$5F ......(_
L1FF0               fcb       $BE,$D3,$14,$46,$98,$4B,$5E,$D0 >S.F.K^P
L1FF8               fcb       $B5,$6B,$A1,$F4,$4F,$10,$99,$33 5k!tO..3
L2000               fcb       $70,$55,$45,$A7,$D0,$15,$BC,$B0 pUE'P.<0
L2008               fcb       $53,$12,$BC,$37,$62,$96,$5F,$4B S.<7b._K
L2010               fcb       $62,$5F,$BE,$39,$17,$FF,$9F,$88 b_>9....
L2018               fcb       $15,$17,$0D,$15,$04,$12,$55,$BD ......U=
L2020               fcb       $F5,$BD,$F3,$17,$1E,$DA,$D6,$15 u=s..ZV.
L2028               fcb       $D2,$B5,$55,$9F,$19,$A0,$49,$C6 R5U.. IF
L2030               fcb       $81,$19,$80,$C6,$00,$00,$A8,$03 ...F..(.
L2038               fcb       $12,$45,$45,$8E,$48,$DB,$8B,$4B .EE.H[.K
L2040               fcb       $7B,$F4,$4F,$10,$99,$C6,$6A,$6E {tO..Fjn
L2048               fcb       $7A,$DB,$E0,$02,$0A,$F4,$4F,$10 z[`..tO.
L2050               fcb       $99,$C5,$6A,$8E,$48,$DB,$8B,$07 .Ej.H[..
L2058               fcb       $59,$0E,$57,$0D,$1C,$0E,$04,$0A Y.W.....
L2060               fcb       $13,$0A,$14,$04,$14,$5F,$BE,$D3 ....._>S
L2068               fcb       $14,$46,$98,$4B,$5E,$C3,$B5,$EF .F.K^C5o
L2070               fcb       $8D,$13,$47,$BF,$14,$D3,$B2,$CF ..G?.S2O
L2078               fcb       $98,$0D,$19,$0A,$16,$1E,$11,$12 ........
L2080               fcb       $04,$12,$5F,$BE,$D3,$14,$46,$98 .._>S.F.
L2088               fcb       $4B,$5E,$C7,$B5,$43,$D9,$C7,$98 K^G5CYG.
L2090               fcb       $5A,$7B,$17,$60,$0D,$1C,$0A,$15 Z{.`....
L2098               fcb       $04,$18,$C7,$DE,$2F,$17,$46,$48 ..G^/.FH
L20A0               fcb       $55,$DB,$87,$74,$B3,$8B,$76,$A7 U[.t3.v'
L20A8               fcb       $D6,$15,$C7,$16,$08,$BC,$3D,$7B V.G..<={
L20B0               fcb       $9B,$C1,$08,$46,$0D,$44,$1F,$24 .A.F.D.$
L20B8               fcb       $5F,$BE,$43,$16,$2E,$6D,$5C,$15 _>C..m\.
L20C0               fcb       $DB,$9F,$5F,$BE,$D3,$14,$46,$98 [._>S.F.
L20C8               fcb       $55,$5E,$2F,$60,$D6,$B5,$C4,$9C U^/`V5D.
L20D0               fcb       $49,$5E,$09,$B3,$91,$7A,$03,$15 I^.3.z..
L20D8               fcb       $67,$93,$1B,$B5,$0B,$1C,$01,$1D g..5....
L20E0               fcb       $07,$0D,$05,$1C,$1D,$1D,$14,$0C ........
L20E8               fcb       $1E,$07,$0D,$05,$1C,$1E,$1D,$32 .......2
L20F0               fcb       $0C,$15,$07,$0D,$05,$1C,$15,$1D ........
L20F8               fcb       $0F,$0C,$18,$80,$84,$92,$00,$84 ........
L2100               fcb       $07,$5B,$0D,$59,$0A,$08,$04,$55 .[.Y...U
L2108               fcb       $9E,$7A,$D6,$9C,$DB,$72,$70,$C0 .zV.[rp@
L2110               fcb       $6E,$98,$30,$15,$F4,$BD,$D6,$B5 n.0.t=V5
L2118               fcb       $DB,$72,$A7,$B7,$B4,$85,$04,$EE [r'74..n
L2120               fcb       $D8,$B0,$53,$61,$90,$14,$19,$58 X0Sa...X
L2128               fcb       $57,$7B,$FB,$8E,$DB,$72,$37,$6E W{..[r7n
L2130               fcb       $5B,$BB,$04,$68,$9F,$15,$FB,$17 [;.h....
L2138               fcb       $F3,$8C,$65,$B1,$00,$9F,$6F,$7C s.e1..o|
L2140               fcb       $82,$17,$54,$5E,$92,$5F,$46,$62 ..T^._Fb
L2148               fcb       $95,$14,$82,$17,$4E,$5E,$7A,$79 ....N^zy
L2150               fcb       $04,$BC,$59,$60,$5B,$B1,$8F,$73 .<Y`[1.s
L2158               fcb       $7E,$15,$85,$A1,$2E,$03,$1C,$5F ~..!..._
L2160               fcb       $BE,$5B,$B1,$2F,$49,$E4,$14,$EE >[1/Id.n
L2168               fcb       $DE,$CB,$78,$F0,$B3,$4B,$62,$B9 ^Kxp3Kb9
L2170               fcb       $46,$5B,$CA,$5F,$BE,$8F,$17,$CF F[J_>..O
L2178               fcb       $99,$9B,$8F,$02,$04,$F0,$B3,$4B .....p3K
L2180               fcb       $62,$1B,$80,$B5,$A0,$00,$AC,$03 b..5 .,.
L2188               fcb       $14,$5F,$BE,$5B,$B1,$4B,$7B,$44 ._>[1K{D
L2190               fcb       $45,$38,$C6,$91,$7A,$3B,$16,$D3 E8F.z;.S
L2198               fcb       $93,$F4,$72,$DB,$63,$07,$80,$8F .tr[c...
L21A0               fcb       $0E,$80,$8C,$0D,$1B,$0E,$04,$0A ........
L21A8               fcb       $13,$0A,$14,$04,$13,$5F,$BE,$3B ....._>;
L21B0               fcb       $16,$D3,$93,$4B,$7B,$4C,$48,$86 .S.K{LH.
L21B8               fcb       $5F,$44,$DB,$38,$C6,$91,$7A,$2E _D[8F.z.
L21C0               fcb       $0B,$6D,$0A,$16,$12,$0D,$10,$1E .m......
L21C8               fcb       $28,$14,$04,$0B,$5F,$BE,$3B,$16 (..._>;.
L21D0               fcb       $D3,$93,$4B,$7B,$36,$A1,$2E,$18 S.K{6!..
L21D8               fcb       $2D,$0D,$2B,$04,$26,$5F,$BE,$3B -.+.&_>;
L21E0               fcb       $16,$D3,$93,$37,$6E,$D1,$B5,$97 .S.7nQ5.
L21E8               fcb       $C6,$51,$18,$4F,$C2,$66,$C6,$9B FQ.OBfF.
L21F0               fcb       $15,$5B,$CA,$E4,$B3,$66,$4D,$D6 .[Jd3fMV
L21F8               fcb       $15,$82,$17,$59,$5E,$00,$B3,$D9 ...Y^.3Y
L2200               fcb       $6A,$39,$4A,$1E,$28,$14,$08,$27 j9J.(..'
L2208               fcb       $04,$25,$5F,$BE,$3B,$16,$D3,$93 .%_>;.S.
L2210               fcb       $4B,$7B,$48,$55,$2F,$62,$19,$58 K{HU/b.X
L2218               fcb       $82,$7B,$7B,$17,$D3,$B2,$13,$B8 .{{.S2.8
L2220               fcb       $8E,$48,$51,$18,$45,$C2,$85,$48 .HQ.EB.H
L2228               fcb       $14,$BC,$86,$5F,$D6,$15,$2E,$02 .<._V...
L2230               fcb       $08,$F4,$4F,$10,$99,$CE,$6A,$72 .tO..Njr
L2238               fcb       $48,$24,$81,$C0,$00,$00,$90,$03 H$.@....
L2240               fcb       $1C,$4E,$45,$31,$49,$55,$5E,$3A .NE1IU^:
L2248               fcb       $62,$9E,$61,$43,$16,$4B,$62,$3B b.aC.Kb;
L2250               fcb       $55,$E6,$8B,$C0,$16,$82,$17,$48 Uf.@...H
L2258               fcb       $5E,$81,$8D,$1B,$B5,$09,$02,$3C ^...5..<
L2260               fcb       $3C,$07,$80,$B3,$0B,$80,$B0,$0A <..3..0.
L2268               fcb       $09,$80,$9A,$0D,$80,$97,$1A,$09 ........
L2270               fcb       $09,$0B,$80,$91,$05,$99,$2B,$0D ......+.
L2278               fcb       $29,$04,$03,$C7,$DE,$52,$12,$04 )..G^R..
L2280               fcb       $1F,$50,$B8,$CB,$87,$6B,$BF,$5F .P8K.k?_
L2288               fcb       $BE,$A3,$15,$33,$8E,$83,$7A,$5F >#.3..z_
L2290               fcb       $BE,$57,$17,$1F,$B3,$B5,$9A,$D5 >W..35.U
L2298               fcb       $B5,$0E,$53,$44,$DB,$93,$9E,$21 5.SD[..!
L22A0               fcb       $1D,$11,$CC,$2E,$0D,$2C,$04,$03 ..L..,..
L22A8               fcb       $C7,$DE,$52,$12,$04,$24,$6C,$BE G^R..$l>
L22B0               fcb       $85,$A1,$7B,$14,$29,$B8,$B4,$D0 .!{.)84P
L22B8               fcb       $B8,$16,$62,$17,$35,$49,$C3,$B5 8.b.5IC5
L22C0               fcb       $CB,$B5,$09,$BC,$50,$8B,$B5,$53 K5.<P.5S
L22C8               fcb       $B8,$16,$96,$64,$DB,$72,$0E,$D0 8..d[r.P
L22D0               fcb       $AB,$89,$FF,$31,$0D,$2F,$04,$2B +..1./.+
L22D8               fcb       $5F,$BE,$57,$17,$1F,$B3,$B5,$9A _>W..35.
L22E0               fcb       $CA,$B5,$86,$5F,$D5,$15,$57,$17 J5._U.W.
L22E8               fcb       $74,$CA,$F3,$5F,$79,$68,$4A,$90 tJs_yhJ.
L22F0               fcb       $4B,$7B,$F6,$4E,$EB,$DA,$4F,$45 K{vNkZOE
L22F8               fcb       $80,$47,$53,$79,$B0,$53,$04,$BC .GSy0S.<
L2300               fcb       $89,$8D,$21,$1D,$FF,$15,$10,$04 ..!.....
L2308               fcb       $0E,$76,$4D,$F4,$BD,$1B,$16,$F3 .vMt=..s
L2310               fcb       $8C,$73,$7B,$14,$67,$F1,$B9,$08 .s{.gq9.
L2318               fcb       $80,$C4,$0D,$80,$C1,$0E,$3E,$0D .D..A.>.
L2320               fcb       $32,$14,$01,$1D,$0B,$19,$0A,$04 2.......
L2328               fcb       $04,$21,$04,$00,$00,$03,$04,$21 .!.....!
L2330               fcb       $03,$00,$00,$01,$04,$21,$01,$00 .....!..
L2338               fcb       $00,$02,$04,$21,$02,$00,$00,$1F ...!....
L2340               fcb       $12,$5F,$BE,$57,$17,$1F,$B3,$B3 ._>W..33
L2348               fcb       $9A,$74,$A7,$27,$BA,$DB,$B5,$1B .t'':[5.
L2350               fcb       $A1,$8E,$48,$1F,$08,$5F,$BE,$57 !.H.._>W
L2358               fcb       $17,$1F,$B3,$B3,$9A,$0D,$7F,$01 ..33...
L2360               fcb       $1D,$1C,$1D,$0B,$79,$05,$33,$23 ....y.3#
L2368               fcb       $0D,$21,$1F,$1D,$0C,$BA,$17,$7A .!...:.z
L2370               fcb       $33,$BB,$7B,$A6,$40,$B9,$E1,$14 3;{&@9a.
L2378               fcb       $3D,$C6,$4B,$62,$6C,$BE,$29,$A1 =FKbl>)!
L2380               fcb       $1B,$71,$34,$A1,$CF,$17,$9D,$7A .q4!O..z
L2388               fcb       $21,$1D,$14,$99,$16,$1F,$14,$0C !.......
L2390               fcb       $BA,$17,$7A,$33,$BB,$C7,$DE,$09 :.z3;G^.
L2398               fcb       $15,$37,$5A,$A3,$15,$CE,$B5,$91 .7Z#.N5.
L23A0               fcb       $C5,$EB,$5D,$CC,$21,$0D,$1F,$1F Ek]L!...
L23A8               fcb       $1B,$3B,$55,$0B,$8E,$D2,$B0,$06 .;U..R0.
L23B0               fcb       $79,$43,$DB,$07,$B3,$33,$98,$C7 yC[.33.G
L23B8               fcb       $DE,$90,$14,$05,$58,$1D,$A0,$F3 ^...X. s
L23C0               fcb       $BF,$0D,$56,$21,$1D,$14,$FF,$16 ?.V!....
L23C8               fcb       $1F,$14,$16,$6C,$F4,$72,$CB,$B5 ...ltrK5
L23D0               fcb       $17,$C0,$03,$8C,$04,$68,$90,$14 .@...h..
L23D8               fcb       $96,$14,$45,$BD,$5B,$89,$0A,$15 ..E=[...
L23E0               fcb       $0D,$13,$1F,$0E,$5F,$BE,$57,$17 ...._>W.
L23E8               fcb       $1F,$B3,$B3,$9A,$4B,$7B,$E3,$59 .33.K{cY
L23F0               fcb       $9B,$5D,$1E,$15,$16,$02,$05,$B4 .].....4
L23F8               fcb       $B7,$F0,$A4,$54,$24,$40,$00,$00 7p$T$@..
L2400               fcb       $80,$03,$1A,$4E,$45,$31,$49,$46 ...NE1IF
L2408               fcb       $5E,$86,$5F,$57,$17,$1F,$B3,$B3 ^._W..33
L2410               fcb       $9A,$87,$8C,$D1,$B5,$96,$96,$DB ...Q5..[
L2418               fcb       $72,$89,$67,$C7,$A0,$07,$15,$0D r.gG ...
L2420               fcb       $13,$0A,$15,$04,$0F,$A8,$77,$4E .....(wN
L2428               fcb       $5E,$E6,$A0,$7B,$16,$92,$14,$F6 ^f {...v
L2430               fcb       $A4,$7F,$7B,$21,$02,$08,$E3,$59 ${!..cY
L2438               fcb       $15,$58,$3A,$62,$9E,$61,$1F,$09 .X:b.a..
L2440               fcb       $FF,$00,$80,$02,$04,$50,$72,$0B .....Pr.
L2448               fcb       $5C,$20,$34,$9C,$05,$A4,$03,$14 \ 4..$..
L2450               fcb       $5F,$BE,$5B,$B1,$4B,$7B,$45,$45 _>[1K{EE
L2458               fcb       $50,$9F,$C0,$16,$82,$17,$49,$5E P.@...I^
L2460               fcb       $07,$B3,$57,$98,$07,$14,$0D,$12 .3W.....
L2468               fcb       $0A,$08,$04,$0E,$2C,$1D,$D5,$47 ....,.UG
L2470               fcb       $F3,$5F,$5B,$4D,$C3,$B0,$1D,$85 s_[MC0..
L2478               fcb       $5C,$C0,$02,$03,$3B,$55,$4E,$21 \@..;UN!
L2480               fcb       $7F,$88,$00,$80,$03,$1D,$5F,$BE ....._>
L2488               fcb       $5B,$B1,$4B,$7B,$56,$45,$A3,$7A [1K{VE#z
L2490               fcb       $5E,$17,$F3,$A0,$36,$56,$D0,$15 ^.s 6VP.
L2498               fcb       $82,$17,$50,$5E,$BE,$A0,$19,$71 ..P^> .q
L24A0               fcb       $46,$48,$2E,$02,$06,$90,$BE,$55 FH....>U
L24A8               fcb       $DB,$86,$8D,$06,$53,$0D,$51,$0A [...S.Q.
L24B0               fcb       $0F,$0E,$4D,$0D,$24,$14,$08,$18 ..M.$...
L24B8               fcb       $04,$02,$5F,$BE,$11,$04,$1A,$4B .._>...K
L24C0               fcb       $7B,$81,$BF,$B3,$14,$D6,$6A,$C8 {.?3.VjH
L24C8               fcb       $9C,$73,$7B,$83,$7A,$25,$BA,$03 .s{.z%:.
L24D0               fcb       $71,$83,$17,$7B,$9B,$C9,$B8,$9B q..{.I8.
L24D8               fcb       $C1,$0D,$25,$17,$06,$00,$17,$07 A.%.....
L24E0               fcb       $88,$17,$18,$00,$04,$1A,$5F,$BE ......_>
L24E8               fcb       $66,$17,$8F,$49,$56,$5E,$38,$C6 f..IV^8F
L24F0               fcb       $D6,$B5,$C8,$9C,$D7,$46,$82,$17 V5H.WF..
L24F8               fcb       $59,$5E,$66,$62,$09,$15,$C7,$A0 Y^fb..G
L2500               fcb       $18,$53,$88,$00,$84,$03,$1C,$5F .S....._
L2508               fcb       $BE,$5B,$B1,$4B,$7B,$4F,$45,$65 >[1K{OEe
L2510               fcb       $62,$77,$47,$D3,$14,$0F,$B4,$17 bwGS..4.
L2518               fcb       $58,$3F,$98,$96,$AF,$DB,$72,$C9 X?../[rI
L2520               fcb       $B8,$9B,$C1,$02,$0A,$14,$53,$66 8.A...Sf
L2528               fcb       $CA,$67,$16,$D3,$B9,$9B,$6C,$07 Jg.S9.l.
L2530               fcb       $24,$0D,$22,$0A,$08,$04,$1E,$5F $."...._
L2538               fcb       $BE,$67,$16,$D3,$B9,$9B,$6C,$1B >g.S9.l.
L2540               fcb       $B7,$33,$BB,$93,$1D,$5B,$66,$55 73;..[fU
L2548               fcb       $A4,$09,$B7,$48,$5E,$A3,$A0,$52 $.7H^# R
L2550               fcb       $45,$05,$B2,$DC,$63,$09,$3B,$90 E.2\c.;.
L2558               fcb       $00,$80,$03,$0D,$5F,$BE,$09,$15 ...._>..
L2560               fcb       $A3,$A0,$4B,$7B,$C9,$54,$A6,$B7 # K{IT&7
L2568               fcb       $2E,$02,$03,$81,$5B,$52,$07,$22 ....[R."
L2570               fcb       $0D,$20,$0A,$11,$17,$1B,$00,$17 . ......
L2578               fcb       $1C,$90,$04,$16,$7C,$B3,$6F,$B3 ....|3o3
L2580               fcb       $27,$60,$2D,$60,$8B,$18,$5F,$BE '`-`.._>
L2588               fcb       $09,$15,$A3,$A0,$4B,$7B,$5F,$A0 ..# K{_
L2590               fcb       $1B,$9C,$09,$30,$00,$00,$80,$03 ...0....
L2598               fcb       $12,$5F,$BE,$09,$15,$A3,$A0,$4B ._>..# K
L25A0               fcb       $7B,$FB,$B9,$43,$98,$AB,$98,$5F {.9C.+._
L25A8               fcb       $A0,$1B,$9C,$02,$03,$81,$5B,$52 .....[R
L25B0               fcb       $07,$12,$0D,$10,$0A,$11,$04,$0C ........
L25B8               fcb       $8D,$7B,$8E,$14,$63,$B1,$FB,$5C .{..c1.\
L25C0               fcb       $5F,$A0,$1B,$9C,$FF,$80,$87,$96 _ ......
L25C8               fcb       $00,$80,$0A,$76,$0E,$74,$0B,$07 ...v.t..
L25D0               fcb       $20,$1D,$01,$81,$23,$01,$81,$0D ...#...
L25D8               fcb       $69,$1F,$66,$C7,$DE,$DB,$16,$CB i.fG^[.K
L25E0               fcb       $B9,$36,$A1,$59,$F4,$F0,$72,$51 96!YtprQ
L25E8               fcb       $18,$43,$C2,$0D,$D0,$A6,$61,$51 .CB.P&aQ
L25F0               fcb       $18,$48,$C2,$8E,$7A,$51,$18,$3D .HB.zQ.=
L25F8               fcb       $C6,$40,$61,$DA,$14,$D0,$47,$F3 F@aZ.PGs
L2600               fcb       $5F,$6B,$BF,$44,$45,$81,$8D,$15 _k?DE...
L2608               fcb       $58,$4B,$BD,$66,$98,$8E,$14,$54 XK=f...T
L2610               fcb       $BD,$43,$F4,$EC,$16,$35,$79,$0B =Ctl.5y.
L2618               fcb       $BC,$CD,$B5,$67,$98,$90,$8C,$D1 <M5g...Q
L2620               fcb       $6A,$74,$CA,$51,$18,$59,$C2,$82 jtJQ.YB.
L2628               fcb       $7B,$7B,$14,$13,$87,$7F,$66,$D6 {{...fV
L2630               fcb       $15,$49,$16,$A5,$9F,$43,$16,$9B .I.%.C..
L2638               fcb       $85,$63,$BE,$CB,$B5,$CB,$B5,$9B .c>K5K5.
L2640               fcb       $C1,$81,$08,$06,$0D,$04,$1C,$1D A.......
L2648               fcb       $23,$05,$09,$02,$46,$46,$0F,$81 #...FF..
L2650               fcb       $B4,$00,$00,$90,$03,$25,$5F,$BE 4....%_>
L2658               fcb       $5B,$B1,$4B,$7B,$4A,$45,$FF,$78 [1K{JE.x
L2660               fcb       $35,$A1,$73,$15,$C1,$B1,$3F,$DE 5!s.A1?^
L2668               fcb       $B6,$14,$5D,$9E,$91,$7A,$82,$17 6.]..z..
L2670               fcb       $50,$5E,$BE,$A0,$12,$71,$65,$49 P^> .qeI
L2678               fcb       $77,$47,$2E,$02,$06,$14,$6C,$4B wG....lK
L2680               fcb       $6E,$DB,$8B,$09,$02,$FF,$FF,$07 n[......
L2688               fcb       $22,$0D,$20,$0A,$15,$04,$1C,$DD ". ....]
L2690               fcb       $72,$F3,$8C,$96,$5F,$51,$18,$4E rs.._Q.N
L2698               fcb       $C2,$11,$A0,$AF,$14,$04,$68,$5B B. /..h[
L26A0               fcb       $5E,$1D,$A1,$F3,$8C,$96,$5F,$A3 ^.!s.._#
L26A8               fcb       $15,$EB,$8F,$08,$81,$29,$0D,$81 .k...)..
L26B0               fcb       $26,$01,$1D,$1C,$1D,$14,$01,$12 &.......
L26B8               fcb       $0B,$81,$1C,$05,$19,$2E,$0D,$2C .......,
L26C0               fcb       $1F,$28,$5F,$BE,$73,$15,$C1,$B1 .(_>s.A1
L26C8               fcb       $3F,$DE,$81,$15,$75,$B1,$51,$18 ?^..u1Q.
L26D0               fcb       $59,$C2,$82,$7B,$A3,$15,$CA,$B5 YB.{#.J5
L26D8               fcb       $B8,$A0,$90,$14,$14,$58,$ED,$7A 8 ...Xmz
L26E0               fcb       $51,$18,$23,$C6,$36,$6F,$D1,$B5 Q.#F6oQ5
L26E8               fcb       $71,$C6,$1D,$FF,$3F,$21,$0D,$1F qF..?!..
L26F0               fcb       $1F,$1B,$5F,$BE,$73,$15,$C1,$B1 .._>s.A1
L26F8               fcb       $3F,$DE,$DE,$14,$05,$4A,$51,$18 ?^^..JQ.
L2700               fcb       $43,$C2,$B9,$55,$CB,$B9,$5F,$BE CB9UK9_>
L2708               fcb       $DA,$14,$66,$62,$21,$1D,$32,$64 Z.fb!.2d
L2710               fcb       $2E,$0D,$2C,$1F,$28,$C7,$DE,$4F ..,.(G^O
L2718               fcb       $15,$33,$61,$5F,$BE,$80,$15,$5A .3a_>..Z
L2720               fcb       $49,$91,$7A,$B8,$16,$82,$17,$49 I.z8...I
L2728               fcb       $5E,$31,$49,$CE,$A1,$A5,$5E,$7F ^1IN!%^
L2730               fcb       $17,$82,$62,$D0,$15,$51,$18,$23 ..bP.Q.#
L2738               fcb       $C6,$46,$B8,$EB,$5D,$1D,$32,$A3 FF8k].2#
L2740               fcb       $3C,$0D,$3A,$1F,$36,$5F,$BE,$DE <.:.6_>^
L2748               fcb       $14,$05,$4A,$B8,$16,$82,$17,$49 ..J8...I
L2750               fcb       $5E,$31,$49,$CE,$A1,$54,$5E,$D3 ^1IN!T^S
L2758               fcb       $7A,$6C,$BE,$29,$A1,$1B,$71,$34 zl>)!.q4
L2760               fcb       $A1,$94,$14,$4B,$90,$83,$96,$83 !..K....
L2768               fcb       $96,$3F,$C0,$EE,$93,$89,$17,$2F .?@n.../
L2770               fcb       $17,$DA,$46,$51,$18,$23,$C6,$F6 .ZFQ.#Fv
L2778               fcb       $4E,$EB,$DA,$1D,$19,$E1,$3E,$0D NkZ..a>.
L2780               fcb       $3C,$1F,$38,$5F,$BE,$73,$15,$C1 <.8_>s.A
L2788               fcb       $B1,$3F,$DE,$4F,$16,$B7,$98,$C3 1?^O.7.C
L2790               fcb       $B5,$1B,$BC,$34,$A1,$4B,$15,$9B 5.<4!K..
L2798               fcb       $53,$F6,$4F,$51,$18,$52,$C2,$46 SvOQ.RBF
L27A0               fcb       $C5,$AB,$14,$AF,$54,$4A,$13,$44 E+./TJ.D
L27A8               fcb       $5E,$7F,$7B,$DB,$B5,$34,$A1,$5A ^{[54!Z
L27B0               fcb       $17,$2E,$A1,$F4,$59,$D0,$15,$FF ..!tYP..
L27B8               fcb       $B9,$F1,$46,$1D,$19,$FF,$18,$0D 9qF.....
L27C0               fcb       $16,$1F,$14,$C7,$DE,$09,$15,$37 ...G^..7
L27C8               fcb       $5A,$82,$17,$49,$5E,$31,$49,$CE Z..I^1IN
L27D0               fcb       $A1,$A5,$5E,$A9,$15,$E7,$B2,$0A !%^).g2.
L27D8               fcb       $2C,$0D,$2A,$1F,$22,$5F,$BE,$73 ,.*."_>s
L27E0               fcb       $15,$C1,$B1,$3F,$DE,$7B,$17,$B5 .A1?^{.5
L27E8               fcb       $85,$7B,$14,$10,$67,$33,$48,$6F .{..g3Ho
L27F0               fcb       $4F,$82,$49,$90,$14,$16,$58,$F0 O.I...Xp
L27F8               fcb       $72,$3A,$15,$94,$A5,$6F,$62,$17 r:..%ob.
L2800               fcb       $1E,$00,$17,$1F,$8E,$0F,$53,$00 ......S.
L2808               fcb       $00,$80,$03,$24,$5F,$BE,$5B,$B1 ...$_>[1
L2810               fcb       $4B,$7B,$5F,$BE,$FF,$14,$F3,$46 K{_>..sF
L2818               fcb       $14,$53,$15,$53,$D1,$B5,$83,$64 .S.SQ5.d
L2820               fcb       $97,$96,$D3,$6D,$73,$15,$C1,$B1 ..Sms.A1
L2828               fcb       $3F,$DE,$8F,$16,$2C,$49,$DB,$E0 ?^..,I[`
L2830               fcb       $07,$1D,$0D,$1B,$0A,$15,$04,$17 ........
L2838               fcb       $7A,$C4,$CB,$06,$82,$17,$95,$7A zDK....z
L2840               fcb       $BD,$15,$49,$90,$50,$9F,$D6,$6A =.I.P.Vj
L2848               fcb       $C4,$9C,$55,$5E,$DD,$78,$21,$02 D.U^]x!.
L2850               fcb       $09,$E3,$59,$09,$58,$31,$49,$CE .cY.X1IN
L2858               fcb       $A1,$45,$25,$32,$FF,$00,$80,$07 !E%2....
L2860               fcb       $28,$0B,$26,$0A,$17,$20,$04,$1E (.&.. ..
L2868               fcb       $C7,$DE,$D3,$14,$90,$96,$F3,$A0 G^S...s
L2870               fcb       $C3,$54,$A3,$91,$5F,$BE,$F3,$17 CT#._>s.
L2878               fcb       $16,$8D,$D6,$15,$D5,$15,$89,$17 ..V.U...
L2880               fcb       $D5,$9C,$C1,$93,$77,$BE,$34,$01 U.A.w>4.
L2888               fcb       $89,$02,$03,$0E,$D0,$4C,$26,$29 ....PL&)
L2890               fcb       $9D,$00,$80,$03,$1E,$4E,$45,$31 .....NE1
L2898               fcb       $49,$50,$5E,$91,$62,$B5,$A0,$B8 IP^.b5 8
L28A0               fcb       $16,$D3,$17,$75,$98,$DE,$14,$91 .S.u.^..
L28A8               fcb       $7A,$D6,$B5,$D6,$9C,$DB,$72,$0E zV5V.[r.
L28B0               fcb       $D0,$9B,$8F,$02,$04,$10,$CB,$4B P.....KK
L28B8               fcb       $62,$1E,$28,$8F,$05,$A0,$03,$16 b.(.. ..
L28C0               fcb       $5F,$BE,$5B,$B1,$4B,$7B,$49,$45 _>[1K{IE
L28C8               fcb       $BE,$9F,$83,$61,$29,$54,$26,$A7 >..a)T&'
L28D0               fcb       $DD,$78,$9F,$15,$7F,$B1,$02,$0B ]x..1..
L28D8               fcb       $3E,$6E,$F0,$59,$DA,$14,$6D,$A0 >npYZ.m
L28E0               fcb       $85,$BE,$4B,$28,$80,$CA,$9C,$00 .>K(.J..
L28E8               fcb       $90,$03,$27,$B8,$B7,$2B,$62,$09 ..'87+b.
L28F0               fcb       $8A,$94,$C3,$0B,$5C,$14,$53,$8B ..C.\.S.
L28F8               fcb       $B4,$AB,$98,$F6,$8B,$4E,$72,$E4 4+.v.Nrd
L2900               fcb       $14,$E5,$A0,$09,$4F,$D6,$B5,$38 .e .OV58
L2908               fcb       $C6,$89,$17,$4B,$15,$9B,$53,$C7 F..K..SG
L2910               fcb       $DE,$2E,$08,$80,$95,$0E,$80,$92 ^.......
L2918               fcb       $0D,$2F,$14,$01,$1D,$0B,$29,$03 ./....).
L2920               fcb       $9C,$23,$07,$0D,$05,$00,$9D,$01 .#......
L2928               fcb       $1D,$86,$9F,$23,$07,$0D,$05,$00 ...#....
L2930               fcb       $9C,$01,$1D,$86,$9E,$23,$07,$0D .....#..
L2938               fcb       $05,$00,$9F,$01,$1D,$86,$9D,$23 .......#
L2940               fcb       $07,$0D,$05,$00,$9E,$01,$1D,$86 ........
L2948               fcb       $0C,$0D,$5F,$01,$1D,$1C,$1D,$1F .._.....
L2950               fcb       $58,$A6,$1D,$51,$A0,$D0,$15,$06 X&.Q P..
                    fcb       $67,$33,$61,$79,$5B,$06,$07,$82 g3ay[...
                    fcb       $17,$49,$5E,$94,$C3,$0B,$5C,$F8 .I^.C.\x
                    fcb       $8B,$33,$61,$5F,$BE,$23,$7B,$B9 .3a_>#{9
                    fcb       $55,$D4,$B9,$85,$A1,$90,$14,$0E UT9.!...
                    fcb       $58,$45,$A0,$56,$5E,$EB,$72,$84 XE V^kr.
                    fcb       $AF,$CE,$9F,$6B,$B5,$C7,$DE,$84 /N.k5G^.
                    fcb       $AF,$93,$9E,$4B,$15,$0D,$8D,$89 /..K....
                    fcb       $17,$82,$17,$49,$5E,$07,$B3,$33 ...I^.33
                    fcb       $98,$06,$B2,$FF,$5A,$19,$58,$82 ..2.Z.X.
                    fcb       $7B,$82,$17,$55,$5E,$48,$72,$09 {..U^Hr.
                    fcb       $C0,$81,$02,$04,$23,$6F,$4D,$B1 @...#oM1
                    fcb       $29,$4C,$1D,$00,$00,$08,$47,$0B )L....G.
                    fcb       $45,$03,$9C,$23,$0E,$0E,$0C,$0D E..#....
                    fcb       $04,$03,$9A,$1D,$85,$0D,$04,$03 ........
                    fcb       $99,$1D,$87,$9F,$23,$0E,$0E,$0C ....#...
                    fcb       $0D,$04,$03,$99,$1D,$85,$0D,$04 ........
                    fcb       $03,$98,$1D,$87,$9E,$23,$0E,$0E .....#..
                    fcb       $0C,$0D,$04,$03,$98,$1D,$85,$0D ........
                    fcb       $04,$03,$9B,$1D,$87,$9D,$23,$0E ......#.
                    fcb       $0E,$0C,$0D,$04,$03,$9B,$1D,$85 ........
                    fcb       $0D,$04,$03,$9A,$1D,$87,$13,$30 .......0
                    fcb       $9C,$00,$A0,$02,$08,$EF,$A6,$51 .. ..o&Q
                    fcb       $54,$4B,$C6,$AF,$6C,$08,$21,$0D TKF/l.!.
                    fcb       $1F,$03,$9C,$25,$0B,$1A,$05,$33 ...%...3
                    fcb       $03,$17,$25,$89,$66,$03,$17,$25 ..%.f..%
                    fcb       $94,$99,$03,$17,$25,$86,$CC,$03 ....%.L.
                    fcb       $17,$25,$8E,$FF,$03,$17,$25,$83 .%....%.
                    fcb       $13,$23,$00,$05,$A0,$02,$08,$EF .#.. ..o
                    fcb       $A6,$51,$54,$4B,$C6,$AF,$6C,$03 &QTKF/l.
                    fcb       $14,$5F,$BE,$5B,$B1,$4B,$7B,$52 ._>[1K{R
                    fcb       $45,$65,$B1,$C7,$7A,$C9,$B5,$5B Ee1GzI5[
                    fcb       $61,$F4,$72,$DB,$63,$2A,$32,$FF atr[c*2.
                    fcb       $00,$00,$02,$03,$01,$B3,$4D,$07 .....3M.
                    fcb       $28,$0D,$26,$0A,$0B,$01,$25,$04 (.&...%.
                    fcb       $20,$C7,$DE,$03,$15,$61,$B7,$74 G^..a7t
                    fcb       $CA,$7B,$14,$EF,$A6,$51,$54,$4B J{.o&QTK
                    fcb       $C6,$AF,$6C,$A3,$15,$BF,$59,$8B F/l#.?Y.
                    fcb       $96,$83,$96,$E4,$14,$D3,$62,$BF ...d.Sb?
                    fcb       $53,$1B,$62,$00,$00,$AC,$02,$03 S.b..,..
                    fcb       $4F,$8B,$50,$03,$0E,$5F,$BE,$5B O.P.._>[
                    fcb       $B1,$4B,$7B,$4E,$45,$72,$48,$9F 1K{NErH.
                    fcb       $15,$7F,$B1,$07,$48,$0B,$46,$0A .1.H.F.
                    fcb       $14,$1C,$0E,$1A,$0D,$17,$09,$12 ........
                    fcb       $1E,$28,$14,$04,$10,$5F,$BE,$3B .(..._>;
                    fcb       $16,$D3,$93,$4B,$7B,$09,$9A,$BF .S.K{..?
                    fcb       $14,$D3,$B2,$CF,$98,$88,$18,$19 .S2O....
                    fcb       $04,$17,$29,$D1,$09,$15,$51,$18 ..)Q..Q.
                    fcb       $56,$C2,$90,$73,$DB,$83,$1B,$A1 VB.s[..!
                    fcb       $2F,$49,$03,$EE,$46,$8B,$90,$5A /I.nF..Z
                    fcb       $3F,$08,$0A,$04,$08,$49,$1B,$99 ?....I..
                    fcb       $16,$14,$BC,$A4,$C3,$2B,$09,$00 ..<$C+..
                    fcb       $00,$80,$02,$04,$89,$67,$A3,$A0 .....g#
                    fcb       $2C,$0B,$00,$00,$80,$07,$01,$93 ,.......
                    fcb       $02,$03,$23,$63,$54,$2D,$0D,$00 ..#cT-..
                    fcb       $00,$80,$07,$01,$93,$02,$05,$55 .......U
                    fcb       $A4,$09,$B7,$45,$2E,$0B,$00,$00 $.7E....
                    fcb       $80,$07,$01,$93,$02,$03,$7E,$74 ......~t
                    fcb       $45,$2F,$0E,$00,$00,$80,$07,$01 E/......
                    fcb       $93,$02,$06,$44,$55,$06,$B2,$A3 ...DU.2#
                    fcb       $A0,$30,$09,$00,$00,$80,$02,$04 0......
                    fcb       $44,$55,$74,$98,$31,$07,$88,$00 DUt.1...
                    fcb       $80,$02,$02,$09,$4F,$32,$09,$88 ....O2..
                    fcb       $00,$80,$02,$04,$3C,$49,$6B,$A1 ....<Ik!
                    fcb       $33,$0D,$00,$00,$80,$07,$01,$93 3.......
                    fcb       $02,$05,$4E,$72,$B3,$8E,$59,$34 ..Nr3.Y4
                    fcb       $0A,$8D,$00,$80,$02,$05,$1B,$54 .......T
                    fcb       $AF,$91,$52,$35,$09,$91,$00,$80 /.R5....
                    fcb       $02,$04,$D7,$C9,$33,$8E,$36,$0E ..WI3.6.
                    fcb       $00,$00,$80,$07,$01,$93,$02,$06 ........
                    fcb       $9E,$61,$D0,$B0,$9B,$53,$37,$0C .aP0.S7.
                    fcb       $00,$00,$80,$07,$01,$93,$02,$04 ........
                    fcb       $70,$C0,$6E,$98,$38,$0C,$FF,$00 p@n.8...
                    fcb       $80,$07,$01,$93,$02,$04,$F0,$81 ......p.
                    fcb       $BF,$6D,$39,$0C,$FF,$00,$80,$07 ?m9.....
                    fcb       $01,$93,$02,$04,$EF,$BD,$FF,$A5 ....o=.%
                    fcb       $24,$0B,$9C,$00,$80,$02,$06,$B4 $......4
                    fcb       $B7,$F0,$A4,$0B,$C0,$3A,$31,$82 7p$.@:1.
                    fcb       $00,$80,$07,$28,$0B,$26,$0A,$36 ...(.&.6
                    fcb       $01,$8A,$33,$01,$8A,$34,$01,$8A ..3..4..
                    fcb       $26,$17,$04,$15,$5F,$BE,$5B,$B1 &..._>[1
                    fcb       $4B,$7B,$EB,$99,$1B,$D0,$94,$14 K{k..P..
                    fcb       $30,$A1,$16,$58,$DB,$72,$96,$A5 0!.X[r.%
                    fcb       $2E,$17,$01,$8A,$02,$02,$96,$A5 .......%
                    fcb       $3B,$0A,$00,$00,$80,$02,$05,$AB ;......+
                    fcb       $53,$90,$8C,$47,$22,$39,$A5,$00 S..G"9%.
                    fcb       $80,$02,$04,$4E,$48,$23,$62,$07 ...NH#b.
                    fcb       $2E,$0D,$2C,$0A,$12,$04,$28,$C7 ..,...(G
                    fcb       $DE,$D3,$14,$90,$96,$F3,$A0,$C8 ^S...s H
                    fcb       $93,$56,$5E,$DB,$72,$4E,$48,$23 .V^[rNH#
                    fcb       $62,$79,$68,$44,$90,$8F,$61,$82 byhD..a.
                    fcb       $49,$D6,$15,$0B,$EE,$0B,$BC,$D6 IV..n.<V
                    fcb       $B5,$2B,$A0,$E3,$72,$9F,$CD,$3C 5+ cr.M<
                    fcb       $03,$1D,$00,$80

L323C               fcb       $00,$85,$BB,$0E     ......;.


                    fcb       $85,$B8,$0D,$2C,$0E,$08,$0A,$01 .8.,....
                    fcb       $0A,$02,$0A,$03,$0A,$04,$0E,$20 .......
                    fcb       $13,$0D,$1D,$04,$19,$5F,$BE,$5B ....._>[
                    fcb       $B1,$4B,$7B,$EB,$99,$1B,$D0,$89 1K{k..P.
                    fcb       $17,$81,$15,$82,$17,$73,$49,$94 .....sI.
                    fcb       $5A,$E6,$5F,$C0,$7A,$2E,$20,$1D Zf_@z. .
                    fcb       $0B,$85,$83,$0A,$05,$21,$0E,$1F .....!..
                    fcb       $0D,$19,$1A,$18,$04,$13,$C7,$DE ......G^
                    fcb       $94,$14,$43,$5E,$EF,$8D,$13,$47 ..C^o..G
                    fcb       $D3,$14,$83,$B3,$91,$7A,$82,$17 S..3.z..
                    fcb       $45,$16,$84,$13,$83,$14,$0C,$06 E.......
                    fcb       $0C,$0D,$0A,$1A,$10,$04,$06,$F9 .......y
                    fcb       $5B,$9F,$A6,$9B,$5D,$08,$17,$0E [.&.]...
                    fcb       $15,$13,$0D,$12,$04,$0E,$89,$74 .......t
                    fcb       $D3,$14,$9B,$96,$1B,$A1,$63,$B1 S....!c1
                    fcb       $16,$58,$DB,$72,$11,$84,$11,$16 .X[r....
                    fcb       $0E,$14,$13,$0D,$11,$04,$0D,$EB .......k
                    fcb       $99,$0F,$A0,$D3,$14,$91,$96,$F0 .. S...p
                    fcb       $A4,$82,$17,$45,$11,$84,$12,$21 $..E...!
                    fcb       $0E,$1F,$13,$0D,$1C,$04,$13,$33 .......3
                    fcb       $D1,$09,$15,$E6,$96,$51,$18,$4E Q..f.Q.N
                    fcb       $C2,$98,$5F,$56,$5E,$DB,$72,$81 B._V^[r.
                    fcb       $A6,$52,$11,$04,$04,$49,$48,$7F &R...IH
                    fcb       $98,$09,$81,$37,$0E,$81,$34,$14 ...7..4.
                    fcb       $1B,$14,$0E,$03,$09,$17,$83,$0E ........
                    fcb       $81,$29,$0D,$1F,$14,$15,$40,$14 .)....@.
                    fcb       $09,$17,$04,$0C,$C7,$DE,$D3,$14 ....G^S.
                    fcb       $E6,$96,$AF,$15,$B3,$B3,$5F,$BE f./.33_>
                    fcb       $11,$04,$06,$56,$D1,$16,$71,$DB ...VQ.q[
                    fcb       $72,$12,$84,$13,$0D,$1A,$1A,$14 r.......
                    fcb       $15,$10,$04,$12,$73,$7B,$77,$5B ....s{w[
                    fcb       $D0,$B5,$C9,$9C,$36,$A0,$89,$17 P5I.6 ..
                    fcb       $96,$14,$45,$BD,$C3,$83,$11,$84 ..E=C...
                    fcb       $0D,$80,$D7,$1A,$0B,$80,$D3,$09 ..W...S.
                    fcb       $09,$80,$99,$0B,$80,$96,$05,$52 .......R
                    fcb       $28,$0D,$26,$04,$17,$4F,$45,$7A (.&..OEz
                    fcb       $79,$FB,$C0,$6C,$BE,$66,$C6,$04 y.@l>fF.
                    fcb       $EE,$73,$C6,$73,$7B,$D5,$92,$B5 nsFs{U.5
                    fcb       $B7,$82,$17,$45,$16,$04,$0A,$7B 7..E...{
                    fcb       $50,$4D,$45,$49,$7A,$36,$92,$21 PMEIz6.!
                    fcb       $62,$A4,$2D,$0D,$2B,$04,$1C,$89 b$-.+...
                    fcb       $4E,$73,$9E,$F5,$B3,$F5,$72,$59 Ns.u3urY
                    fcb       $15,$C2,$B3,$95,$14,$51,$18,$4A .B3..Q.J
                    fcb       $C2,$CF,$49,$5E,$17,$5A,$49,$F3 BOI^.ZIs
                    fcb       $5F,$5F,$BE,$16,$04,$08,$83,$7A __>....z
                    fcb       $5F,$BE,$94,$14,$EB,$8F,$1D,$0A _>..k...
                    fcb       $FD,$20,$0D,$1E,$04,$1A,$C7,$DE . ....G^
                    fcb       $63,$16,$C9,$97,$43,$5E,$84,$15 c.I.C^..
                    fcb       $73,$4A,$AB,$98,$89,$4E,$D6,$CE sJ+..NVN
                    fcb       $D6,$9C,$DB,$72,$1F,$54,$F1,$B9 V.[r.Tq9
                    fcb       $1D,$14,$FF,$18,$0D,$16,$04,$12 ........
                    fcb       $4E,$45,$DD,$C3,$44,$DB,$89,$8D NE]CD[..
                    fcb       $89,$17,$82,$17,$4A,$5E,$94,$5F ....J^._
                    fcb       $AB,$BB,$1D,$FF,$17,$34,$0B,$32 +;...4.2
                    fcb       $05,$AF,$14,$04,$12,$59,$45,$3E ./...YE>
                    fcb       $7A,$EF,$16,$1A,$98,$90,$14,$1B zo......
                    fcb       $58,$1B,$A1,$D5,$92,$5B,$BB,$FF X.!U.[;.
                    fcb       $19,$0D,$17,$04,$13,$C7,$DE,$EF .....G^o
                    fcb       $16,$1A,$98,$F3,$5F,$8F,$73,$D0 ...s_.sP
                    fcb       $15,$82,$17,$4A,$5E,$86,$5F,$21 ...J^._!
                    fcb       $1D,$03,$0D,$0F,$04,$02,$5F,$BE ......_>
                    fcb       $11,$04,$08,$4B,$7B,$92,$C5,$37 ...K{.E7
                    fcb       $49,$17,$60,$0A,$01,$07,$15,$29 I.`....)
                    fcb       $0E,$27,$13,$0D,$24,$04,$0D,$80 .'..$...
                    fcb       $5B,$F3,$23,$5B,$4D,$4E,$B8,$F9 [s#[MN8y
                    fcb       $8E,$82,$17,$45,$11,$04,$12,$47 ...E...G
                    fcb       $D2,$C8,$8B,$F3,$23,$55,$BD,$DB RH.s#U=[
                    fcb       $BD,$41,$6E,$03,$58,$99,$9B,$5F =An.X.._
                    fcb       $4A,$17,$51,$0E,$4F,$13,$0D,$25 J.Q.O..%
                    fcb       $1A,$15,$10,$04,$0C,$46,$77,$05 .....Fw.
                    fcb       $A0,$16,$BC,$90,$73,$D6,$83,$DB .<.sV.[
                    fcb       $72,$11,$04,$11,$4E,$D1,$15,$8A r...NQ..
                    fcb       $50,$BD,$15,$58,$8E,$BE,$08,$8A P=.X.>..
                    fcb       $BE,$A0,$56,$72,$2E,$0D,$25,$04 > Vr..%.
                    fcb       $12,$CF,$62,$8B,$96,$9B,$64,$1B .Ob...d.
                    fcb       $A1,$47,$55,$B3,$8B,$C3,$54,$A3 !GU3.CT#
                    fcb       $91,$5F,$BE,$11,$04,$0E,$73,$7B ._>...s{
                    fcb       $47,$D2,$C8,$8B,$F3,$23,$EE,$72 GRH.s#nr
                    fcb       $1B,$A3,$3F,$A1,$16,$16,$0E,$14 .#?!....
                    fcb       $13,$0D,$11,$04,$02,$5F,$BE,$11 ....._>.
                    fcb       $04,$0A,$4B,$7B,$06,$9A,$BF,$14 ..K{..?.
                    fcb       $D3,$B2,$CF,$98,$18,$35,$0E,$33 S2O..5.3
                    fcb       $13,$0D,$18,$1A,$15,$10,$04,$11 ........
                    fcb       $5B,$BE,$65,$BC,$99,$16,$F3,$17 [>e<..s.
                    fcb       $56,$DB,$CA,$9C,$3E,$C6,$82,$17 V[J.>F..
                    fcb       $45,$16,$84,$0D,$16,$04,$02,$5F E......_
                    fcb       $BE,$11,$04,$0F,$81,$8D,$CB,$87 >.....K.
                    fcb       $A5,$94,$04,$71,$8E,$62,$23,$62 %..q.b#b
                    fcb       $09,$9A,$2E,$0B,$3A,$0E,$38,$13 ....:.8.
                    fcb       $0D,$19,$1A,$15,$04,$04,$12,$3F .......?
                    fcb       $B9,$82,$62,$91,$7A,$D5,$15,$04 9.b.zU..
                    fcb       $18,$8E,$7B,$83,$61,$03,$A0,$5F ..{.a. _
                    fcb       $BE,$16,$84,$0D,$1A,$04,$16,$5F >......_
                    fcb       $BE,$5D,$B1,$D0,$B5,$02,$A1,$91 >]1P5.!.
                    fcb       $7A,$62,$17,$DB,$5F,$33,$48,$B9 zb.[_3H9
                    fcb       $46,$73,$C6,$5F,$BE,$11,$84,$0C FsF_>...
                    fcb       $1A,$0E,$18,$13,$0D,$15,$04,$11 ........
                    fcb       $5F,$BE,$5D,$B1,$D0,$B5,$02,$A1 _>]1P5.!
                    fcb       $91,$7A,$B0,$17,$F4,$59,$82,$17 .z0.tY..
                    fcb       $45,$11,$84,$10,$18,$0E,$16,$13 E.......
                    fcb       $0D,$13,$04,$0F,$5F,$BE,$5D,$B1 ...._>]1
                    fcb       $D0,$B5,$02,$A1,$91,$7A,$D0,$15 P5.!.zP.
                    fcb       $82,$17,$45,$11,$84,$1B,$20,$0E ..E... .
                    fcb       $1E,$13,$0D,$03,$08,$00,$07,$0D ........
                    fcb       $16,$04,$12,$5F,$BE,$5B,$B1,$4B ..._>[1K
                    fcb       $7B,$06,$9A,$90,$73,$C3,$6A,$07 {...sCj.
                    fcb       $B3,$33,$98,$5F,$BE,$11,$84,$1C 33._>...
                    fcb       $34,$0E,$32,$13,$0D,$17,$08,$00 4.2.....
                    fcb       $04,$13,$5F,$BE,$5B,$B1,$4B,$7B .._>[1K{
                    fcb       $06,$9A,$90,$73,$C4,$6A,$A3,$60 ...sDj#`
                    fcb       $33,$98,$C7,$DE,$2E,$0D,$16,$04 3.G^....
                    fcb       $12,$5F,$BE,$5B,$B1,$4B,$7B,$06 ._>[1K{.
                    fcb       $9A,$90,$73,$C4,$6A,$A3,$60,$33 ..sDj#`3
                    fcb       $98,$5F,$BE,$11,$84,$21,$0A,$04 ._>..!..
                    fcb       $08,$B5,$6C,$8E,$C5,$EB,$72,$AB .5l.Ekr+
                    fcb       $BB,$22,$12,$04,$10,$5B,$E0,$27 ;"...[`'
                    fcb       $60,$31,$60,$41,$A0,$49,$A0,$89 `1`A I .
                    fcb       $D3,$89,$D3,$69,$CE,$23,$05,$0D S.SiN#..
                    fcb       $03,$92,$26,$24,$2C,$04,$0D,$02 ..&$,...
                    fcb       $92,$26,$3E,$01,$27,$3F,$01,$28 .&>.'?.(
                    fcb       $25,$0D,$04,$0B,$03,$C0,$7B,$14 %....@{.
                    fcb       $94,$5A,$E6,$5F,$C0,$7A,$2E,$26 .Zf_@z.&
                    fcb       $24,$0E,$22,$13,$0D,$17,$1A,$15 $.".....
                    fcb       $10,$04,$02,$5F,$BE,$11,$04,$0D ..._>...
                    fcb       $40,$D2,$F3,$23,$F6,$8B,$51,$18 @Rs#v.Q.
                    fcb       $52,$C2,$65,$49,$21,$04,$06,$09 RBeI!...
                    fcb       $9A,$FA,$17,$70,$49,$3D,$01,$94 .z.pI=..
                    fcb       $27,$0E,$0E,$0C,$13,$04,$09,$25 '......%
                    fcb       $A1,$AB,$70,$3B,$95,$77,$BF,$21 !+p;.w?!
                    fcb       $28,$0A,$0E,$08,$13,$0D,$04,$1A (.......
                    fcb       $15,$10,$96,$97,$29,$0A,$0E,$08 ....)...
                    fcb       $13,$0D,$04,$1B,$15,$10,$96,$97 ........
                    fcb       $2F,$07,$04,$05,$9B,$29,$57,$C6 /....)WF
                    fcb       $3E,$2D,$09,$0E,$07,$13,$0D,$02 >-......
                    fcb       $1A,$83,$14,$0C,$33,$04,$0E,$02 ....3...
                    fcb       $13,$98,$34,$04,$0E,$02,$13,$98 ..4.....
                    fcb       $36,$17,$0E,$15,$13,$0D,$12,$04 6.......
                    fcb       $0E,$C7,$DE,$D3,$14,$E6,$96,$77 .G^S.f.w
                    fcb       $15,$0B,$BC,$96,$96,$DB,$72,$11 ..<..[r.
                    fcb       $84,$37,$15,$0E,$13,$13,$0D,$10 .7......
                    fcb       $04,$0C,$C7,$DE,$94,$14,$85,$61 ..G^...a
                    fcb       $0B,$BC,$96,$96,$DB,$72,$11,$84 .<..[r..
                    fcb       $38,$20,$0E,$1E,$13,$0D,$1B,$04 8 ......
                    fcb       $17,$5F,$BE,$5B,$B1,$4B,$7B,$06 ._>[1K{.
                    fcb       $9A,$30,$15,$29,$A1,$14,$71,$3F .0.)!.q?
                    fcb       $A0,$B0,$17,$F4,$59,$82,$17,$45 0.tY..E
                    fcb       $11,$84,$39,$1D,$0E,$1B,$13,$0D ..9.....
                    fcb       $18,$04,$16,$C7,$DE,$FB,$17,$F3 ...G^..s
                    fcb       $8C,$58,$72,$56,$5E,$D2,$9C,$73 .XrV^R.s
                    fcb       $C6,$73,$7B,$83,$7A,$5F,$BE,$7F Fs{.z_>
                    fcb       $B1,$3A,$1E,$0E,$1C,$13,$0D,$19 1:......
                    fcb       $04,$0C,$C7,$DE,$D3,$14,$E6,$96 ..G^S.f.
                    fcb       $C2,$16,$83,$61,$5F,$BE,$11,$04 B..a_>..
                    fcb       $06,$56,$D1,$16,$71,$DB,$72,$12 .VQ.q[r.
                    fcb       $84,$0D,$34,$0E,$32,$0D,$2E,$1A ..4.2...
                    fcb       $83,$0E,$2A,$0D,$27,$0E,$07,$14 ..*.'...
                    fcb       $15,$10,$1B,$14,$15,$40,$04,$02 .....@..
                    fcb       $5F,$BE,$11,$04,$14,$07,$4F,$17 _>....O.
                    fcb       $98,$CA,$B5,$37,$49,$F5,$8B,$D3 .J57Iu.S
                    fcb       $B8,$B8,$16,$91,$64,$96,$64,$DB 88..d.d[
                    fcb       $72,$12,$84,$10,$13,$14,$0C,$0E r.......
                    fcb       $39,$0E,$37,$0D,$1B,$1B,$14,$15 9.7.....
                    fcb       $10,$04,$02,$5F,$BE,$12,$04,$10 ..._>...
                    fcb       $4B,$7B,$06,$9A,$85,$14,$B2,$53 K{....2S
                    fcb       $90,$BE,$C9,$6A,$5E,$79,$5B,$BB .>Ij^y[;
                    fcb       $13,$0D,$17,$04,$02,$5F,$BE,$12 ....._>.
                    fcb       $04,$10,$60,$7B,$F3,$23,$D5,$46 ..`{s#UF
                    fcb       $EE,$61,$91,$7A,$BC,$14,$AF,$78 na.z<./x
                    fcb       $5B,$BB,$0F,$19,$0E,$17,$13,$0D [;......
                    fcb       $14,$04,$02,$5F,$BE,$11,$04,$0B ..._>...
                    fcb       $40,$D2,$F3,$23,$16,$67,$D0,$15 @Rs#.gP.
                    fcb       $82,$17,$45,$12,$84,$14,$3B,$0D ..E...;.
                    fcb       $39,$1B,$83,$0E,$35,$0D,$18,$1A 9...5...
                    fcb       $15,$08,$0E,$04,$09,$12,$09,$14 ........
                    fcb       $0E,$0D,$13,$04,$0A,$73,$7B,$40 .....s{@
                    fcb       $D2,$F3,$23,$F4,$4F,$1B,$9C,$0D Rs#tO...
                    fcb       $19,$04,$0C,$C7,$DE,$D3,$14,$E6 ...G^S.f
                    fcb       $96,$BF,$14,$C3,$B2,$5F,$BE,$11 .?.C2_>.
                    fcb       $04,$06,$56,$D1,$16,$71,$DB,$72 ..VQ.q[r
                    fcb       $12,$84,$07,$1A,$0D,$18,$04,$15 ........
                    fcb       $C7,$DE,$94,$14,$45,$5E,$3C,$49 G^..E^<I
                    fcb       $D0,$DD,$D6,$6A,$DB,$72,$FE,$67 P]Vj[r.g
                    fcb       $89,$8D,$91,$7A,$3A,$06,$04,$02 ...z:...
                    fcb       $00,$00

L37FA               fcb       $00,$84,$2C,$81,$63,$0D ....,.c.
                    fcb       $61

                    fcb       $1F,$10,$C7,$DE,$AF,$23,$FF a..G^/#.

                    fcb       $14,$17,$47,$8C,$17,$43,$DB,$0B ..G..C[.
                    fcb       $6C,$1B,$9C,$95,$17,$01,$81,$17 l.......
                    fcb       $05,$84,$17,$06,$88,$17,$07,$00 ........
                    fcb       $17,$08,$8C,$17,$09,$A1,$17,$0A .....!..
                    fcb       $8E,$17,$0C,$95,$17,$0E,$91,$17 ........
                    fcb       $0F,$00,$17,$11,$92,$17,$12,$00 ........
                    fcb       $17,$14,$A0,$17,$15,$00,$17,$16 .. .....
                    fcb       $00,$17,$18,$9C,$17,$1E,$00,$17 ........
                    fcb       $1F,$00,$17,$22,$8F,$17,$25,$9C ..."..%.
                    fcb       $17,$26,$00,$17,$28,$00,$1C,$15 .&..(...
                    fcb       $23,$3C,$1C,$1D,$23,$46,$17,$1D #<..#F..
                    fcb       $96,$25,$82,$2C,$0D,$2A,$1F,$27 .%.,.*.'
                    fcb       $5F,$BE,$66,$17,$8F,$49,$54,$5E _>f..IT^
                    fcb       $3F,$61,$57,$49,$D6,$B5,$DB,$72 ?aWIV5[r
                    fcb       $3C,$49,$6B,$A1,$23,$D1,$13,$54 <Ik!#Q.T
                    fcb       $F0,$A4,$8C,$62,$7F,$49,$DB,$B5 p$.bI[5
                    fcb       $34,$A1,$9F,$15,$3E,$49,$2E,$81 4!..>I..
                    fcb       $83,$66,$0D,$64,$0E,$61,$0D,$08 .f.d.a..
                    fcb       $08,$0E,$17,$0E,$00,$1C,$0F,$0C ........
                    fcb       $0D,$08,$08,$25,$17,$25,$00,$1C ...%.%..
                    fcb       $26,$0C,$0D,$1D,$15,$10,$04,$0C &.......
                    fcb       $46,$77,$05,$A0,$16,$BC,$90,$73 Fw. .<.s
                    fcb       $D6,$83,$DB,$72,$16,$04,$0A,$4E V.[r...N
                    fcb       $D1,$05,$8A,$42,$A0,$2B,$62,$FF Q..B +b.
                    fcb       $BD,$0D,$21,$14,$15,$20,$04,$1A =.!.. ..
                    fcb       $C7,$DE,$94,$14,$53,$5E,$D6,$C4 G^..S^VD
                    fcb       $4B,$5E,$13,$98,$44,$A4,$DB,$8B K^..D$[.
                    fcb       $C3,$9E,$6F,$B1,$53,$A1,$AB,$98 C.o1S!+.
                    fcb       $5F,$BE,$16,$84,$18,$0D,$08,$0F _>......
                    fcb       $16,$04,$04,$4D,$BD,$A7,$61,$18 ...M='a.
                    fcb       $84,$04,$04,$02,$3B,$F4,$85,$29 ....;t.)
                    fcb       $1F,$27,$49,$45,$07,$B3,$11,$A3 .'IE.3.#
                    fcb       $89,$64,$94,$C3,$0B,$5C,$94,$91 .d.C.\..
                    fcb       $1F,$54,$C3,$B5,$07,$B3,$33,$98 .TC5.33.
                    fcb       $5F,$BE,$E1,$14,$CF,$B2,$96,$AF _>a.O2./
                    fcb       $DB,$9C,$34,$A1,$33,$17,$2E,$6D [.4!3..m
                    fcb       $2E,$87,$2A,$1F,$28,$49,$45,$07 ..*.(IE.
                    fcb       $B3,$11,$A3,$89,$64,$94,$C3,$0B 3.#.d.C.
                    fcb       $5C,$95,$5A,$EA,$48,$94,$5F,$C3 \.ZjH._C
                    fcb       $B5,$07,$B3,$33,$98,$5F,$BE,$E1 5.33._>a
                    fcb       $14,$CF,$B2,$96,$AF,$DB,$9C,$34 .O2./[.4
                    fcb       $A1,$3F,$16,$D7,$68,$86,$1E,$1F !?.Wh...
                    fcb       $1C,$49,$45,$07,$B3,$11,$A3,$89 .IE.3.#.
                    fcb       $64,$94,$C3,$0B,$5C,$3F,$55,$4B d.C.\?UK
                    fcb       $62,$39,$49,$8E,$C5,$82,$17,$45 b9I.E..E
                    fcb       $5E,$B8,$A0,$47,$62,$88,$13,$0D ^8 Gb...
                    fcb       $11,$04,$02,$5F,$BE,$12,$04,$0A ..._>...
                    fcb       $4B,$7B,$06,$9A,$BF,$14,$10,$B2 K{..?..2
                    fcb       $5B,$70,$92,$1C,$1F,$1A,$36,$A1 [p....6!
                    fcb       $B8,$16,$7B,$14,$85,$A6,$44,$B8 8.{..&D8
                    fcb       $DB,$8B,$08,$67,$1E,$C1,$51,$18 [..g.AQ.
                    fcb       $23,$C6,$61,$B7,$5B,$B1,$4B,$7B #Fa7[1K{
                    fcb       $89,$12,$1F,$10,$C7,$DE,$D3,$14 ....G^S.
                    fcb       $E6,$96,$FF,$15,$D3,$93,$5B,$BE f...S.[>
                    fcb       $08,$BC,$21,$49,$8A,$32,$0D,$30 .<!I.2.0
                    fcb       $1F,$2D,$C7,$DE,$3B,$16,$33,$98 .-G^;.3.
                    fcb       $03,$A0,$55,$45,$8D,$A5,$43,$5E . UE.%C^
                    fcb       $16,$BC,$DB,$72,$06,$4F,$7F,$BF .<[r.O?
                    fcb       $B8,$16,$82,$17,$52,$5E,$73,$7B 8...R^s{
                    fcb       $23,$D1,$13,$54,$5F,$BE,$3F,$17 #Q.T_>?.
                    fcb       $C5,$6A,$4F,$A1,$66,$B1,$2E,$81 EjO!f1..
                    fcb       $8B,$79,$0D,$77,$1F,$74,$C7,$DE .y.w.tG^
                    fcb       $2F,$17,$43,$48,$5B,$E3,$23,$D1 /.CH[c#Q
                    fcb       $DB,$8B,$C7,$DE,$AF,$23,$4B,$15 [.G^/#K.
                    fcb       $03,$8D,$AB,$98,$5B,$BE,$16,$BC ..+.[>.<
                    fcb       $DB,$72,$E9,$B3,$E1,$14,$74,$CA [ri3a.tJ
                    fcb       $F3,$5F,$52,$45,$97,$7B,$82,$17 s_RE.{..
                    fcb       $44,$5E,$0E,$A1,$DB,$9F,$C3,$9E D^.![.C.
                    fcb       $5F,$BE,$E3,$16,$0B,$BC,$C5,$B5 _>c..<E5
                    fcb       $4F,$A1,$66,$B1,$FB,$17,$53,$BE O!f1..S>
                    fcb       $63,$B9,$B5,$85,$84,$14,$36,$A1 c95...6!
                    fcb       $59,$15,$23,$C6,$67,$66,$16,$BC Y.#Fgf.<
                    fcb       $46,$48,$8B,$18,$C7,$DE,$09,$15 FH..G^..
                    fcb       $E6,$96,$9B,$15,$5B,$CA,$8F,$BE f...[J.>
                    fcb       $56,$5E,$CF,$9C,$95,$5F,$2F,$C6 V^O.._/F
                    fcb       $82,$17,$5B,$61,$1B,$63,$06,$56 ..[a.c.V
                    fcb       $DB,$E0,$81,$8C,$49,$1F,$47,$C7 [`..I.GG
                    fcb       $DE,$03,$15,$61,$B7,$74,$CA,$7B ^..a7tJ{
                    fcb       $14,$E7,$59,$06,$A3,$35,$49,$E3 .gY.#5Ic
                    fcb       $16,$19,$BC,$85,$73,$07,$71,$3F ..<.s.q?
                    fcb       $D9,$4D,$98,$5C,$15,$DB,$9F,$5F YM.\.[._
                    fcb       $BE,$99,$16,$C2,$B3,$89,$17,$82 >..B3...
                    fcb       $17,$55,$5E,$36,$A1,$19,$71,$46 .U^6!.qF
                    fcb       $48,$56,$F4,$DB,$72,$96,$A5,$D5 HVt[r.%U
                    fcb       $15,$89,$17,$C4,$9C,$F3,$B2,$16 ...D.s2.
                    fcb       $58,$CC,$9C,$72,$C5,$2E,$8D,$20 XL.rE..
                    fcb       $04,$1E,$5F,$BE,$66,$17,$8F,$49 .._>f..I
                    fcb       $4B,$5E,$CF,$B5,$DA,$C3,$89,$17 K^O5ZC..
                    fcb       $CA,$9C,$98,$5F,$48,$DB,$A3,$A0 J.._H[#
                    fcb       $C7,$DE,$89,$17,$71,$16,$7F,$CA G^..q.J
                    fcb       $8E,$3E,$04,$3C,$7A,$C4,$D9,$06 .>.<zDY.
                    fcb       $82,$7B,$84,$15,$96,$5F,$03,$15 .{..._..
                    fcb       $93,$66,$2E,$56,$FB,$C0,$C7,$DE .f.V.@G^
                    fcb       $63,$16,$C9,$97,$56,$5E,$CF,$9C c.I.V^O.
                    fcb       $4F,$A1,$82,$17,$43,$5E,$3B,$8E O!..C^;.
                    fcb       $83,$AF,$33,$98,$C7,$DE,$03,$15 ./3.G^..
                    fcb       $61,$B7,$74,$CA,$7B,$14,$A5,$B7 a7tJ{.%7
                    fcb       $76,$B1,$DB,$16,$D3,$B9,$BF,$6C v1[.S9?l
                    fcb       $8F,$07,$0D,$05,$08,$2B,$00,$A5 .....+.%
                    fcb       $90,$90,$22,$1F,$20,$5F,$BE,$8E ..". _>.
                    fcb       $14,$54,$BD,$71,$16,$75,$CA,$AB .T=q.uJ+
                    fcb       $14,$8B,$54,$6B,$BF,$A3,$B7,$16 ..Tk?#7.
                    fcb       $8A,$DB,$72,$7E,$74,$43,$5E,$08 .[r~tC^.
                    fcb       $4F,$5B,$5E,$3F,$A1,$91,$37,$0D O[^?!.7.
                    fcb       $35,$1F,$30,$4B,$49,$C7,$DE,$DE 5.0KIG^^
                    fcb       $14,$64,$7A,$C7,$16,$11,$BC,$96 .dzG..<.
                    fcb       $64,$DB,$72,$7E,$74,$B3,$63,$73 d[r~t3cs
                    fcb       $7B,$A7,$B7,$4B,$94,$6B,$BF,$89 {'7K.k?.
                    fcb       $91,$D3,$78,$13,$8D,$57,$17,$33 .Sx..W.3
                    fcb       $48,$D3,$C5,$6A,$4D,$8E,$7A,$51 HSEjM.zQ
                    fcb       $18,$DB,$C7,$00,$9F,$95,$93,$09 .[G.....
                    fcb       $0B,$07,$0A,$36,$01,$94,$37,$01 ...6..7.
                    fcb       $94,$94,$19,$1F,$17,$FF,$A5,$57 ......%W
                    fcb       $49,$B5,$17,$46,$5E,$2F,$7B,$03 I5.F^/{.
                    fcb       $56,$1D,$A0,$A6,$16,$3F,$BB,$11 V. &.?;.
                    fcb       $EE,$99,$AF,$2E,$95,$26,$0D,$24 n./..&.$
                    fcb       $17,$36,$FF,$17,$29,$00,$17,$2A .6..)..*
                    fcb       $00,$17,$2B,$00,$17,$2C,$00,$17 ..+..,..
                    fcb       $2D,$00,$17,$2E,$00,$17,$31,$00 -.....1.
                    fcb       $17,$34,$00,$17,$35,$00,$17,$3A .4..5..:
                    fcb       $00,$17,$3C,$1D,$96,$1A,$04,$18 ..<.....
                    fcb       $5B,$BE,$65,$BC,$7B,$14,$41,$6E [>e<{.An
                    fcb       $19,$58,$3B,$4A,$6B,$BF,$85,$8D .X;Jk?..
                    fcb       $5B,$5E,$34,$A1,$9B,$15,$31,$98 [^4!..1.
                    fcb       $97,$19,$04,$17,$43,$79,$C7,$DE ....CyG^
                    fcb       $D3,$14,$88,$96,$8E,$7A,$7B,$14 S....z{.
                    fcb       $C7,$93,$76,$BE,$BD,$15,$49,$90 G.v>=.I.
                    fcb       $67,$48,$21,$98,$24,$04,$22,$0F gH!.$.".
                    fcb       $A0,$5F,$17,$46,$48,$66,$17,$D3 _.FHf.S
                    fcb       $61,$04,$68,$63,$16,$5B,$99,$56 a.hc.[.V
                    fcb       $98,$C0,$16,$49,$5E,$90,$78,$0E .@.I^.x.
                    fcb       $BC,$92,$5F,$59,$15,$9B,$AF,$19 <._Y../.
                    fcb       $A1

L3C29
* VERBS (ACTION WORDS)
* Format:
* Byte 1: ??, Byte 2: word length
* Word follows...
                    fcb       $00,$04
                    fcc       /READ/
                    fcb       $01,$03
                    fcc       /GET/
                    fcb       $09,$05
                    fcc       /THROW/
                    fcb       $03,$06
                    fcc       /ATTACK/
                    fcb       $04,$04
                    fcc       /KILL/
                    fcb       $04,$03
                    fcc       /HIT/
                    fcb       $04,$05
                    fcc       /NORTH/
                    fcb       $05,$01
                    fcc       /N/
                    fcb       $05,$05
                    fcc       /SOUTH/
                    fcb       $06,$01
                    fcc       /S/
                    fcb       $06,$04
                    fcc       /EAST/
                    fcb       $07,$01
                    fcc       /E/
                    fcb       $07,$04
                    fcc       /WEST/
                    fcb       $08,$01
                    fcc       /W/
                    fcb       $08,$04
                    fcc       /TAKE/
                    fcb       $09,$04
                    fcc       /DROP/
                    fcb       $0A,$03
                    fcc       /PUT/
                    fcb       $0A,$06
                    fcc       /INVENT/
                    fcb       $0B,$04
                    fcc       /LOOK/
                    fcb       $0C,$04
                    fcc       /GIVE/
                    fcb       $0D,$05
                    fcc       /OFFER/
                    fcb       $0D,$06
                    fcc       /EXAMIN/
                    fcb       $0E,$06
                    fcc       /SEARCH/
                    fcb       $0E,$04
                    fcc       /OPEN/
                    fcb       $0F,$04
                    fcc       /PULL/
                    fcb       $10,$05
                    fcc       /LIGHT/
                    fcb       $11,$04
                    fcc       /BURN/
                    fcb       $11,$03
                    fcc       /EAT/
                    fcb       $12,$05
                    fcc       /TASTE/
                    fcb       $12,$04
                    fcc       /BLOW/
                    fcb       $13,$06
                    fcc       /EXTING/
                    fcb       $14,$05
                    fcc       /CLIMB/
                    fcb       $15,$03
                    fcc       /RUB/
                    fcb       $16,$04
                    fcc       /WIPE/
                    fcb       $16,$06
                    fcc       /POLISH/
                    fcb       $16,$04
                    fcc       /LIFT/
                    fcb       $1C,$04
                    fcc       /WAIT/
                    fcb       $1F,$04
                    fcc       /STAY/
                    fcb       $1F,$04
                    fcc       /JUMP/
                    fcb       $20,$02
                    fcc       /GO/
                    fcb       $21,$03
                    fcc       /RUN/
                    fcb       $21,$05
                    fcc       /ENTER/
                    fcb       $21,$04
                    fcc       /PUSH/
                    fcb       $10,$04
                    fcc       /MOVE/
                    fcb       $10,$04
                    fcc       /KICK/
                    fcb       $23,$04
                    fcc       /FEED/
                    fcb       $24,$05
                    fcc       /SCORE/
                    fcb       $28,$06
                    fcc       /SCREAM/
                    fcb       $2B,$04
                    fcc       /YELL/
                    fcb       $2B,$04
                    fcc       /QUIT/
                    fcb       $2D,$04
                    fcc       /STOP/
                    fcb       $2D,$05
                    fcc       /PLUGH/
                    fcb       $32,$05
                    fcc       /LEAVE/
                    fcb       $2C,$04
                    fcc       /PICK/
* OBJECTS
                    fcb       $34,$00,$06
                    fcc       /POTION/
                    fcb       $03,$03
                    fcc       /RUG/
                    fcb       $06,$04
                    fcc       /DOOR/
                    fcb       $09,$04
                    fcc       /FOOD/
                    fcb       $0C,$06
                    fcc       /STATUE/
                    fcb       $0D,$05
                    fcc       /SWORD/
                    fcb       $0E,$06
                    fcc       /GARGOY/
                    fcb       $0F,$04
                    fcc       /RING/
                    fcb       $12,$03
                    fcc       /GEM/
                    fcb       $13,$05
                    fcc       /LEVER/
                    fcb       $16,$06
                    fcc       /PLAQUE/
                    fcb       $18,$05
                    fcc       /RUNES/
                    fcb       $18,$04
                    fcc       /SIGN/
                    fcb       $18,$06
                    fcc       /MESSAG/
                    fcb       $18,$06
                    fcc       /CANDLE/
                    fcb       $19,$04
                    fcc       /LAMP/
                    fcb       $1B,$06
                    fcc       /CHOPST/
                    fcb       $1E,$04
                    fcc       /HAND/
                    fcb       $1F,$05
                    fcc       /HANDS/
                    fcb       $1F,$04
                    fcc       /COIN/
                    fcb       $20,$04
                    fcc       /SLOT/
                    fcb       $21,$05
                    fcc       /ALTAR/
                    fcb       $22,$04
                    fcc       /IDOL/
                    fcb       $23,$06
                    fcc       /SERPEN/
                    fcb       $24,$05
                    fcc       /SNAKE/
                    fcb       $24,$04
                    fcc       /WALL/
                    fcb       $25,$05
                    fcc       /WALLS/
                    fcb       $25,$04
                    fcc       /VINE/
                    fcb       $26,$05
                    fcc       /VINES/
                    fcb       $26,$04
                    fcc       /GATE/
                    fcb       $27,$05
                    fcc       /GATES/
                    fcb       $27,$05
                    fcc       /GUARD/
                    fcb       $28,$06
                    fcc       /GUARDS/
                    fcb       $28,$04
                    fcc       /ROOM/
                    fcb       $2A,$05
                    fcc       /FLOOR/
                    fcb       $2B,$04
                    fcc       /EXIT/
                    fcb       $2C,$06
                    fcc       /PASSAG/
                    fcb       $2D,$04
                    fcc       /HOLE/
                    fcb       $2E,$06
                    fcc       /CORRID/
                    fcb       $2F,$03
                    fcc       /BOW/
                    fcb       $31,$05
                    fcc       /ARROW/
                    fcb       $32,$06
                    fcc       /HALLWA/
                    fcb       $33,$06
                    fcc       /CHAMBE/
                    fcb       $34,$05
                    fcc       /VAULT/
                    fcb       $35,$06
                    fcc       /ENTRAN/
                    fcb       $36,$06
                    fcc       /TUNNEL/
                    fcb       $37,$06
                    fcc       /JUNGLE/
                    fcb       $38,$06
                    fcc       /TEMPLE/
                    fcb       $39,$03
                    fcc       /PIT/
                    fcb       $3A,$06
                    fcc       /CEILIN/
                    fcb       $3B,$00,$00
L3ECF               fcb       $02
                    fcc       /TO/
                    fcb       $01,$04
                    fcc       /WITH/
                    fcb       $02,$02
                    fcc       /AT/
                    fcb       $03,$05
                    fcc       /UNDER/
                    fcb       $04,$02
                    fcc       /IN/
                    fcb       $05,$04
                    fcc       /INTO/
                    fcb       $05,$03
                    fcc       /OUT/
                    fcb       $06,$02
                    fcc       /UP/
                    fcb       $07,$04
                    fcc       /DOWN/
                    fcb       $08,$04
                    fcc       /OVER/
                    fcb       $09,$06
                    fcc       /BEHIND/
                    fcb       $0A,$06
                    fcc       /AROUND/
                    fcb       $0B,$02
                    fcc       /ON/
                    fcb       $0C,$00
                    fcb       $03,$CE,$80,$01,$03,$00,$00,$40 .N.....@
                    fcb       $FF                 .

os9read             pshs      y,x,d
                    clra
                    leax      ,s
                    ldy       #$0001
                    os9       I$Read
ok                  puls      d,x,y,pc

os9write            pshs      y,x,d
                    cmpa      #$0D
                    beq       WriteCR
                    lda       #$01
                    leax      ,s
                    ldy       #$0001
                    os9       I$Write
                    bra       DoCHROUT
WriteCR
                    lda       #$01
                    leax      ,s
                    ldy       #$0001
                    os9       I$WritLn
DoCHROUT
                    puls      d,x,y
                    pshs      x,b,a
                    ldx       $88                 get cursor position
                    cmpa      #$08                backspace character?
                    bne       LA31D               branch if not...
                    cmpx      #$400               else is current screen pointer at top?
                    beq       LA35D               branch if so...
                    lda       #$60                else put SPACE to erase character and move X back
                    sta       ,-x
                    bra       LA344
LA31D               cmpa      #$0D
                    bne       LA32F
                    ldx       $88
LA323               lda       #$60
                    sta       ,x+
                    tfr       x,d
                    bitb      #$1F
                    bne       LA323
                    bra       LA344
LA32F               cmpa      #$20
                    bcs       LA35D
                    tsta
                    bmi       LA342
                    cmpa      #$40
                    bcs       LA340
                    cmpa      #$60
                    bcs       LA342
                    anda      #$DF
LA340               eora      #$40
LA342               sta       ,x+
LA344               stx       $88
                    cmpx      #$400+511
                    bls       LA35D
                    ldx       #$400

* SCROLL SCREEN
LA34E               ldd       32,x
                    std       ,x++
                    cmpx      #$400+$1E0
                    bcs       LA34E
                    ldb       #$60
LA92D               stx       $88
LA92F               stb       ,x+
                    cmpx      #$400+511
                    bls       LA92F
LA35D               puls      d,x,pc

os9exit             os9       F$Exit
realsize            equ       *-realstart

                    emod
eom                 equ       *
                    end

