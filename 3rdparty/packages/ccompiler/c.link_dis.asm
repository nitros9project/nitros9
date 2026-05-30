                    nam       c.link
                    ttl       program module

                    use       defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $04

                    mod       eom,name,tylg,atrv,_start,size

u0000               rmb       5646
size                equ       .

name                equ       *
                    fcs       /c.link/
                    fcb       edition

copybytes           lda       ,y+
L0016               sta       ,u+
L0018               leax      -$01,x
L001A               bne       copybytes
L001C               rts

_start              pshs      y
                    pshs      u
                    clra
L0022               clrb
L0023               sta       ,u+
                    decb
L0026               bne       L0023
L0028               ldx       ,s
L002A               leau      ,x
L002C               leax      $068e,x
L0030               pshs      x
L0032               leay      L3577,pcr
L0036               ldx       ,y++
L0038               beq       L003E
L003A               bsr       copybytes
L003C               ldu       $02,s
L003E               leau      >$0060,u
L0042               ldx       ,y++
L0044               beq       L0049
L0046               bsr       copybytes
L0048               clra
L0049               cmpu      ,s
L004C               beq       L0052
L004E               sta       ,u+
L0050               bra       L0049

L0052               ldu       $02,s
L0054               ldd       ,y++
                    beq       L005F
L0058               leax      >$0000,pcr
L005C               lbsr      L0162
L005F               ldd       ,y++
L0061               beq       L0068
L0063               leax      ,u
L0065               lbsr      L0162
L0068               leas      $04,s
                    puls      x
L006C               stx       $021a,u
                    sty       $01DA,u
L0075               ldd       #$0001
L0078               std       $0216,u
                    leay      $01DC,u
L0080               leax      ,s
                    lda       ,x+
L0084               ldb       $0217,u
                    cmpb      #$1d
                    beq       L00E0
L008C               cmpa      #$0d
                    beq       L00E0
                    cmpa      #$20
                    beq       L0098
                    cmpa      #$2C
                    bne       L009C
L0098               lda       ,x+
                    bra       L008C

L009C               cmpa      #$22
                    beq       L00A4
                    cmpa      #$27
                    bne       L00C2
L00A4               stx       ,y++
                    inc       $0217,u
                    pshs      a
L00AC               lda       ,x+
                    cmpa      #$0d
                    beq       L00B6
                    cmpa      ,s
                    bne       L00AC
L00B6               puls      b
                    clr       -$01,x
                    cmpa      #$0d
                    beq       L00E0
                    lda       ,x+
                    bra       L0084

L00C2               leax      -$01,x
                    stx       ,y++
                    leax      $01,x
L00C8               inc       $0217,u
L00CC               cmpa      #$0d
                    beq       L00DC
                    cmpa      #$20
                    beq       L00DC
                    cmpa      #$2C
                    beq       L00DC
                    lda       ,x+
                    bra       L00CC

L00DC               clr       -$01,x
                    bra       L0084

L00E0               leax      $01DA,u
                    pshs      x
                    ldd       $0216,u
                    pshs      d
                    leay      ,u
                    bsr       L00FA
                    lbsr      L017C
                    clr       ,-s
                    clr       ,-s
                    lbsr      L356B
L00FA               leax      $068e,y
                    stx       $0224,y
L0102               sts       $0218,y
                    sts       $0226,y
                    ldd       #$FF82
L010F               leax      d,s
                    cmpx      $0226,y
                    bcc       L0121
                    cmpx      $0224,y
                    bcs       L013B
                    stx       $0226,y
L0121               rts

L0122               bpl       $014E
                    bpl       L0150
                    bra       L017B
                    lsrb
                    fcb       $41
                    coma
                    fcb       $4B
                    bra       $017D
                    rorb
                    fcb       $45,$52
                    rora
                    inca
                    clra
                    asrb
                    bra       L0161
                    bpl       $0163
                    bpl       L0148
L013B               leax      L0122,pcr
                    ldb       #$CF
                    pshs      b
                    lda       #$02
                    ldy       #$0064
L0148               os9       I$WritLn
                    clr       ,-s
                    lbsr      L3571
L0150               ldd       $0218,y
                    subd      $0226,y
                    rts
                    ldd       $0226,y
                    subd      $0224,y
L0161               rts

L0162               pshs      x
                    leax      d,y
                    leax      d,x
                    pshs      x
L016A               ldd       ,y++
                    leax      d,u
                    ldd       ,x
                    addd      $02,s
                    std       ,x
                    cmpy      ,s
                    bne       L016A
                    leas      $04,s
L017B               rts

L017C               pshs      u
                    ldd       #$FFB0
                    lbsr      L010F
                    leas      -$06,s
                    leax      L1DFF,pcr
                    pshs      x
                    lbsr      L353B
                    leas      $02,s
                    lbra      L033C

L0194               ldx       $0C,s
                    leax      $02,x
                    stx       $0C,s
                    ldu       ,x
                    ldb       ,u
                    cmpb      #$2d
                    lbne      L0312
                    lbra      L0304

L01A7               ldb       ,u
                    sex
                    tfr       d,x
                    lbra      L02BE

L01AF               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    bne       L01BF
                    leau      $01,u
                    tfr       u,d
                    std       $0273,y
L01BF               ldd       $0271,y
                    lbne      L02A0
                    pshs      u
                    lbsr      L0D9D
                    leas      $02,s
                    std       $0271,y
                    lbra      L02A0

L01D5               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    bne       L0205
                    ldd       $000C
                    cmpd      #$0005
                    bge       L0205
                    ldd       $000C
                    addd      #$0001
                    std       $000C
                    subd      #$0001
                    aslb
                    rola
                    leax      $0266,y
                    leax      d,x
                    pshs      x
                    pshs      u
                    ldd       #$0001
                    addd      ,s++
L0200               std       [,s++]
                    lbra      L02A0

L0205               pshs      u
                    leax      L0DDD,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $04,s
                    lbra      L02A0

L0215               ldd       #$0001
                    std       $000E
                    lbra      L0304

L021D               ldd       #$0001
                    std       $0010
                    lbra      L0304

L0225               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    lbne      L02A0
                    leax      $01,u
                    stx       $0271,y
                    lbra      L02A0

L0238               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    lbne      L02A0
                    pshs      u
                    ldd       #$0001
                    addd      ,s++
                    pshs      d
                    lbsr      L302C
                    leas      $02,s
                    stb       $0270,y
                    bra       L02A0

L0256               leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    bne       L027A
                    pshs      u
                    ldd       #$0001
                    addd      ,s++
                    pshs      d
                    lbsr      L1B05
                    leas      $02,s
                    std       ,s
                    cmpd      #$0100
                    bcs       L02A0
                    ldd       ,s
                    std       L0032
                    bra       L02A0

L027A               pshs      u
                    leax      L0E17,pcr
                    pshs      x
                    leax      L0DFD,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $06,s
L028D               ldd       #$0001
                    std       copybytes
                    leau      $01,u
                    ldb       ,u
                    cmpb      #$3d
                    bne       L02A0
                    leax      $01,u
                    stx       $0275,y
L02A0               leax      $06,s
                    lbra      L030E

L02A5               ldd       #$0001
                    std       L0016
                    bra       L0304

L02AC               ldb       ,u
                    sex
                    pshs      d
                    leax      L0E24,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $04,s
                    bra       L0304

L02BE               cmpx      #$006F
                    lbeq      L01AF
                    cmpx      #$006C
                    lbeq      L01D5
                    cmpx      #$006D
                    lbeq      L0215
                    cmpx      #$0073
                    lbeq      L021D
                    cmpx      #$006E
                    lbeq      L0225
                    cmpx      #$0045
                    lbeq      L0238
                    cmpx      #$0065
                    lbeq      L0238
                    cmpx      #$004D
                    lbeq      L0256
                    cmpx      #$0062
                    lbeq      L028D
                    cmpx      #$0074
                    beq       L02A5
                    bra       L02AC

L0304               leau      $01,u
                    ldb       ,u
                    lbne      L01A7
                    bra       L033C

L030E               leas      -$06,x
                    bra       L033C

L0312               ldd       $000A
                    cmpd      #$001E
                    bne       L0325
                    leax      L0E37,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $02,s
L0325               ldd       $000A
                    addd      #$0001
                    std       $000A
                    subd      #$0001
                    aslb
                    rola
                    leax      $022a,y
                    leax      d,x
                    ldd       [$0C,s]
                    std       ,x
L033C               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    lbgt      L0194
                    lbsr      L044A
                    lbsr      L1D80
                    std       -$02,s
                    beq       L035C
                    leax      L0E4D,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $02,s
L035C               ldd       $0271,y
                    pshs      d
                    lbsr      $2EC4
                    leas      $02,s
                    std       L001A
                    lbsr      L0927
                    lbsr      L0A66
                    ldd       copybytes
                    beq       L03A8
                    ldd       L0026
                    bne       L037B
                    ldd       L002A
                    beq       L0386
L037B               leax      L0E63,pcr
                    pshs      x
                    lbsr      L0CE5
                    leas      $02,s
L0386               ldd       L0022
                    beq       L0395
                    leax      L0E78,pcr
                    pshs      x
                    lbsr      L0CE5
                    leas      $02,s
L0395               ldd       L0016
                    bne       L03A8
                    ldd       $001E
                    beq       L03A8
                    leax      L0E8B,pcr
                    pshs      x
                    lbsr      L0CE5
                    leas      $02,s
L03A8               ldd       L0022
                    addd      L002A
                    cmpd      #$0100
                    bls       L03C3
                    ldd       L0022
                    addd      L002A
                    pshs      d
                    leax      L0E9A,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $04,s
L03C3               ldd       L0044
                    beq       L03D2
                    leax      L0EBD,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $02,s
L03D2               ldd       $0273,y
                    bne       L03E3
                    leax      L0EC8,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $02,s
L03E3               ldd       copybytes
                    lbeq      L0443
                    ldd       $0275,y
                    bne       L03FA
                    leax      L0ED7,pcr
                    pshs      x
                    lbsr      L0CE5
                    bra       L043C

L03FA               leas      -$02,s
                    ldd       $0275,y
                    pshs      d
                    ldd       $0275,y
                    pshs      d
                    lbsr      L19F7
                    std       ,s
                    lbsr      L1A1C
                    leas      $04,s
                    std       ,s
                    beq       L042B
                    ldx       ,s
                    ldd       $0a,x
                    clra
                    andb      #$07
                    cmpd      #$0004
                    bne       L042B
                    ldx       ,s
                    ldd       $0C,x
                    std       L0030
                    bra       L043C

L042B               ldd       $0275,y
                    pshs      d
                    leax      L0EEB,pcr
                    pshs      x
                    lbsr      L0CE5
                    leas      $04,s
L043C               leas      $02,s
                    ldd       #$2181
                    std       L0018
L0443               lbsr      L1015
                    leas      $06,s
                    puls      pc,u
L044A               pshs      u
                    ldd       #$FF96
                    lbsr      L010F
                    leas      -$1e,s
                    ldd       $000A
                    lbeq      L065A
                    clra
                    clrb
                    lbra      L0594

L0460               ldd       ,s
                    aslb
                    rola
                    leax      $022a,y
                    leax      d,x
                    ldd       ,x
                    std       L0042
                    ldd       L0038
                    pshs      d
                    leax      L0F06,pcr
                    pshs      x
                    ldd       L0042
                    pshs      d
                    lbsr      L22B8
                    leas      $06,s
                    std       L0038
                    bne       L0488
                    lbsr      L0D2D
L0488               ldd       $0003
                    ldx       L0038
                    std       $0b,x
                    ldd       L0038
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$001C
                    pshs      d
                    leax      $08,s
                    pshs      x
                    lbsr      L232D
                    leas      $08,s
                    std       -$02,s
                    bne       L04AC
                    lbsr      L0D84
L04AC               leax      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L04BC
                    fcb       $62
                    fcb       $CD
                    fcb       $23
                    fcb       $87
L04BC               puls      x
                    lbsr      L30E7
                    beq       L04C8
                    lbsr      L0D40
                    bra       L0510

L04C8               ldb       $08,s
                    beq       L04D1
                    lbsr      L0D52
                    bra       L0510

L04D1               ldd       copybytes
                    beq       L04DE
                    ldd       $06,s
                    beq       L0510
                    lbsr      L0D1B
                    bra       L0510

L04DE               ldd       ,s
                    beq       L04EB
                    ldd       $06,s
                    beq       L0510
                    lbsr      L0D64
                    bra       L0510

L04EB               ldd       $06,s
                    bne       L0500
                    ldd       L0042
                    pshs      d
                    leax      L0F08,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $04,s
                    bra       L0504

L0500               ldd       $06,s
                    std       L0018
L0504               ldb       $0270,y
                    bne       L0510
                    ldb       $0e,s
                    stb       $0270,y
L0510               clra
                    clrb
                    pshs      d
                    leax      $04,s
                    pshs      x
                    lbsr      L065F
                    leas      $04,s
                    ldd       ,s
                    lbne      L058F
                    leas      -$02,s
                    ldd       L003E
                    std       ,s
                    ldd       #$0104
                    pshs      d
                    ldd       >$0070,y
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L0B8B
                    leas      $06,s
                    ldd       #$0104
                    pshs      d
                    ldd       >$0078,y
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L0B8B
                    leas      $06,s
                    ldd       #$0101
                    pshs      d
                    ldd       >$0072,y
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L0B8B
                    leas      $06,s
                    ldd       #$0100
                    pshs      d
                    ldd       >$0074,y
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L0B8B
                    leas      $06,s
                    ldd       #$0102
                    pshs      d
                    ldd       >$0076,y
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L0B8B
                    leas      $06,s
                    leas      $02,s
L058F               ldd       ,s
                    addd      #$0001
L0594               std       ,s
                    ldd       ,s
                    cmpd      $000A
                    lblt      L0460
                    clra
                    clrb
                    lbra      L064A

L05A4               ldd       ,s
                    aslb
                    rola
                    leax      $0266,y
                    leax      d,x
                    ldd       ,x
                    std       L0042
                    ldd       L0038
                    pshs      d
                    lbsr      L2B73
                    leas      $02,s
                    leax      L0F22,pcr
                    pshs      x
                    ldd       L0042
                    pshs      d
                    lbsr      L2299
                    leas      $04,s
                    std       L0038
                    lbne      L0628
                    lbsr      L0D2D
                    bra       L0628

L05D5               leax      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L05E5
                    fcb       $62
                    fcb       $CD
                    fcb       $23
                    fcb       $87
L05E5               puls      x
                    lbsr      L30E7
                    beq       L05F1
                    lbsr      L0D40
                    bra       L0619

L05F1               ldb       $08,s
                    beq       L05FA
                    lbsr      L0D52
                    bra       L0619

L05FA               ldd       $06,s
                    beq       L060C
                    ldd       copybytes
                    beq       L0607
                    lbsr      L0D1B
                    bra       L0619

L0607               lbsr      L0D64
                    bra       L0619

L060C               ldd       #$0001
                    pshs      d
                    leax      $04,s
                    pshs      x
                    bsr       L065F
                    leas      $04,s
L0619               leax      >$0060,y
                    cmpx      >$0060,y
                    bne       L0628
                    leax      $1e,s
                    bra       L0657

L0628               ldd       L0038
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$001C
                    pshs      d
                    leax      $08,s
                    pshs      x
                    lbsr      L232D
                    leas      $08,s
                    std       -$02,s
                    lbne      L05D5
                    ldd       ,s
                    addd      #$0001
L064A               std       ,s
                    ldd       ,s
                    cmpd      $000C
                    lblt      L05A4
                    bra       L065A

L0657               leas      -$1e,x
L065A               leas      $1e,s
                    puls      pc,u
L065F               pshs      u
                    ldd       #$FF8B
                    lbsr      L010F
                    leas      -$29,s
                    ldd       L003C
                    bne       L067D
                    ldd       #$0031
                    pshs      d
                    lbsr      L1C1F
                    leas      $02,s
                    std       $27,s
                    bra       L068A

L067D               ldd       L003C
                    std       $27,s
                    ldx       $27,s
                    ldd       $11,x
                    std       L003C
L068A               clra
                    clrb
                    ldx       $27,s
                    std       $2d,x
                    clra
                    clrb
                    ldx       $27,s
                    std       $27,x
                    ldd       $27,s
                    std       $1b,s
                    ldd       #$0010
                    bra       L06B8

L06A5               ldd       $23,s
                    ldx       $1b,s
                    leax      $01,x
                    stx       $1b,s
                    stb       -$01,x
                    ldd       $21,s
                    addd      #$FFFF
L06B8               std       $21,s
                    ldd       $21,s
                    ble       L06CE
                    ldd       L0038
                    pshs      d
                    lbsr      L2C96
                    leas      $02,s
                    std       $23,s
                    bne       L06A5
L06CE               ldx       L0038
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L06DA
                    lbsr      L0D84
L06DA               clra
                    clrb
                    stb       [$1b,s]
                    ldd       L0042
                    ldx       $27,s
                    std       $2f,x
                    ldd       #$0010
                    pshs      d
                    ldd       $2f,s
                    addd      #$000C
                    pshs      d
                    ldd       $2b,s
                    addd      #$0015
                    pshs      d
                    lbsr      L309F
                    leas      $06,s
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF8
                    leas      $02,s
                    std       $1f,s
                    bra       L074F

L070F               lbsr      L0BCC
                    std       $25,s
                    ldx       $27,s
                    ldd       $2d,x
                    ldx       $25,s
                    std       $0e,x
                    ldd       $25,s
                    ldx       $27,s
                    std       $2d,x
                    ldd       $25,s
                    pshs      d
                    lbsr      L1DE0
                    leas      $02,s
                    ldd       L0038
                    pshs      d
                    lbsr      L2C96
                    leas      $02,s
                    ldx       $25,s
                    std       $0a,x
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF8
                    leas      $02,s
                    ldx       $25,s
                    std       $0C,x
L074F               ldd       $1f,s
                    addd      #$FFFF
                    std       $1f,s
                    subd      #$FFFF
                    bne       L070F
                    ldd       $2f,s
                    lbeq      L07DC
                    ldx       $27,s
                    ldd       $2d,x
                    bra       L0784

L076C               ldd       #$0001
                    pshs      d
                    ldd       $27,s
                    pshs      d
                    lbsr      L1B82
                    leas      $04,s
                    std       -$02,s
                    bne       L078C
                    ldx       $25,s
                    ldd       $0e,x
L0784               std       $25,s
                    ldd       $25,s
                    bne       L076C
L078C               ldd       $25,s
                    bne       L07DC
                    leas      -$02,s
                    ldx       $29,s
                    ldd       $2d,x
                    pshs      d
                    lbsr      L0CC7
                    leas      $02,s
                    std       ,s
                    ldd       $0001
                    ldx       ,s
                    std       $0e,x
                    ldx       $29,s
                    ldd       $0e,x
                    std       $0001
                    ldd       $29,s
                    pshs      d
                    lbsr      L0BF0
                    leas      $02,s
                    lbsr      L0C3B
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF8
                    std       ,s
                    lbsr      L0C0E
                    leas      $02,s
                    ldd       L003C
                    ldx       $29,s
                    std       $11,x
                    ldd       $29,s
                    std       L003C
                    leas      $2b,s
                    puls      pc,u
L07DC               ldx       $27,s
                    ldd       $2d,x
                    bra       L0817

L07E4               ldd       $25,s
                    pshs      d
                    lbsr      L1A56
                    std       ,s++
                    beq       L0812
                    ldd       $27,s
                    pshs      d
                    ldd       $27,s
                    pshs      d
                    leax      L0F24,pcr
                    pshs      x
                    leax      $00A3,y
                    pshs      x
                    lbsr      L23CF
                    leas      $08,s
                    ldd       L0044
                    addd      #$0001
                    std       L0044
L0812               ldx       $25,s
                    ldd       $0e,x
L0817               std       $25,s
                    ldd       $25,s
                    bne       L07E4
                    ldd       $0040
                    bne       L082C
                    ldd       $27,s
                    std       $0040
                    std       L003E
                    bra       L0836

L082C               ldd       $27,s
                    ldx       $0040
                    std       $11,x
                    std       $0040
L0836               ldx       $27,s
                    leax      $29,x
                    pshs      x
                    ldd       L0038
                    pshs      d
                    lbsr      L2A1A
                    leas      $02,s
                    lbsr      L314B
                    ldd       $27,s
                    pshs      d
                    lbsr      L0BF0
                    leas      $02,s
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF8
                    leas      $02,s
                    std       $1f,s
                    lbra      L08D1

L0863               leax      $01,s
                    pshs      x
                    lbsr      L1DE0
                    leas      $02,s
                    leax      $01,s
                    pshs      x
                    leax      $03,s
                    pshs      x
                    lbsr      L19F7
                    std       ,s
                    lbsr      L1A1C
                    leas      $04,s
                    std       $25,s
                    beq       L088E
                    ldx       $25,s
                    ldd       $0a,x
                    ora       #$01
                    std       $0a,x
                    bra       L08B4

L088E               leas      -$02,s
                    leax      $03,s
                    pshs      x
                    lbsr      L1BD8
                    leas      $02,s
                    std       ,s
                    leax      $03,s
                    pshs      x
                    ldd       $02,s
                    addd      #$0004
                    pshs      d
                    lbsr      L2ED5
                    leas      $04,s
                    ldd       $29,s
                    ldx       ,s
                    std       $0e,x
                    leas      $02,s
L08B4               ldx       $27,s
                    ldd       $27,x
                    leax      $27,x
                    pshs      x,d
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF8
                    std       ,s
                    lbsr      L0C79
                    leas      $02,s
                    addd      ,s++
                    std       [,s++]
L08D1               ldd       $1f,s
                    addd      #$FFFF
                    std       $1f,s
                    subd      #$FFFF
                    lbne      L0863
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF8
                    leas      $02,s
                    std       $1f,s
                    ldx       L0038
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L0914
                    lbsr      L0D84
                    bra       L0914

L08FB               ldx       $27,s
                    ldd       $27,x
                    leax      $27,x
                    pshs      x,d
                    ldd       #$0001
                    pshs      d
                    lbsr      L0C79
                    leas      $02,s
                    addd      ,s++
                    std       [,s++]
L0914               ldd       $1f,s
                    addd      #$FFFF
                    std       $1f,s
                    subd      #$FFFF
                    bne       L08FB
                    leas      $29,s
                    puls      pc,u
L0927               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    leas      -$02,s
                    clra
                    clrb
                    std       $0034
                    ldd       L003E
                    lbra      L09DC

L093A               ldx       ,s
                    ldu       $2d,x
                    lbra      L09D1

L0942               ldd       $0a,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L09CF
                    ldx       ,s
                    ldd       $13,x
                    ora       #$01
                    std       $13,x
                    ldd       $001E
                    pshs      d
                    ldx       $02,s
                    ldd       $17,x
                    addd      ,s++
                    std       $001E
                    ldd       L0022
                    pshs      d
                    ldx       $02,s
                    ldd       $19,x
                    addd      ,s++
                    std       L0022
                    ldd       L0026
                    pshs      d
                    ldx       $02,s
                    ldd       $1b,x
                    addd      ,s++
                    std       L0026
                    ldd       L002A
                    pshs      d
                    ldx       $02,s
                    ldd       $1d,x
                    addd      ,s++
                    std       L002A
                    ldd       L0032
                    pshs      d
                    ldx       $02,s
                    ldd       $21,x
                    addd      ,s++
                    std       L0032
                    ldd       $002E
                    pshs      d
                    ldx       $02,s
                    ldd       $1f,x
                    addd      ,s++
                    std       $002E
                    ldd       L0036
                    pshs      d
                    ldx       $02,s
                    ldd       $27,x
                    addd      ,s++
                    std       L0036
                    ldx       ,s
                    ldd       $1f,x
                    ldx       ,s
                    addd      $1b,x
                    cmpd      $0034
                    bls       L09D7
                    ldx       ,s
                    ldd       $1f,x
                    ldx       ,s
                    addd      $1b,x
                    std       $0034
                    bra       L09D7

L09CF               ldu       $0e,u
L09D1               stu       -$02,s
                    lbne      L0942
L09D7               ldx       ,s
                    ldd       $11,x
L09DC               std       ,s
                    ldd       ,s
                    lbne      L093A
                    ldd       >$0070,y
                    pshs      d
                    ldd       >$0070,y
                    pshs      d
                    lbsr      L19F7
                    std       ,s
                    lbsr      L1A1C
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L0A04
                    ldd       $002E
                    std       $0C,u
L0A04               ldd       >$0072,y
                    pshs      d
                    ldd       >$0072,y
                    pshs      d
                    lbsr      L19F7
                    std       ,s
                    lbsr      L1A1C
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L0A24
                    ldd       L0026
                    std       $0C,u
L0A24               ldd       >$0074,y
                    pshs      d
                    ldd       >$0074,y
                    pshs      d
                    lbsr      L19F7
                    std       ,s
                    lbsr      L1A1C
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L0A44
                    ldd       $001E
                    std       $0C,u
L0A44               ldd       >$0076,y
                    pshs      d
                    ldd       >$0076,y
                    pshs      d
                    lbsr      L19F7
                    std       ,s
                    lbsr      L1A1C
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L0A64
                    ldd       L0022
                    std       $0C,u
L0A64               puls      pc,u,x
L0A66               pshs      u
                    ldd       #$FFB1
                    lbsr      L010F
                    leas      -$05,s
                    lbsr      L0B64
                    ldd       L003E
                    lbra      L0B37

L0A78               ldx       $03,s
                    ldd       $13,x
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L0B32
                    ldx       $03,s
                    ldu       $2d,x
                    lbra      L0AEB

L0A8E               ldd       $0a,u
                    clra
                    andb      #$07
                    tfr       d,x
                    bra       L0ACF

L0A97               ldd       $0C,u
                    addd      L001C
                    bra       L0AB3

L0A9D               ldd       $0C,u
                    addd      $0024
                    bra       L0AB3

L0AA3               ldd       $0C,u
                    addd      $0020
                    bra       L0AB3

L0AA9               ldd       $0C,u
                    addd      L0028
                    bra       L0AB3

L0AAF               ldd       $0C,u
                    addd      L002C
L0AB3               std       $0C,u
                    bra       L0AE9

L0AB7               ldx       $03,s
                    ldd       $2f,x
                    pshs      d
                    ldd       $05,s
                    pshs      d
                    leax      L0F48,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $06,s
                    bra       L0AE9

L0ACF               stx       -$02,s
                    beq       L0A97
                    cmpx      #$0001
                    beq       L0A9D
                    cmpx      #$0002
                    beq       L0AA3
                    cmpx      #$0003
                    beq       L0AA9
                    cmpx      #$0004
                    beq       L0AAF
                    bra       L0AB7

L0AE9               ldu       $0e,u
L0AEB               stu       -$02,s
                    lbne      L0A8E
                    ldd       L001C
                    pshs      d
                    ldx       $05,s
                    ldd       $17,x
                    addd      ,s++
                    std       L001C
                    ldd       $0024
                    pshs      d
                    ldx       $05,s
                    ldd       $1b,x
                    addd      ,s++
                    std       $0024
                    ldd       $0020
                    pshs      d
                    ldx       $05,s
                    ldd       $19,x
                    addd      ,s++
                    std       $0020
                    ldd       L0028
                    pshs      d
                    ldx       $05,s
                    ldd       $1d,x
                    addd      ,s++
                    std       L0028
                    ldd       L002C
                    pshs      d
                    ldx       $05,s
                    ldd       $1f,x
                    addd      ,s++
                    std       L002C
L0B32               ldx       $03,s
                    ldd       $11,x
L0B37               std       $03,s
                    ldd       $03,s
                    lbne      L0A78
                    ldd       >$0078,y
                    pshs      d
                    ldd       >$0078,y
                    pshs      d
                    lbsr      L19F7
                    std       ,s
                    lbsr      L1A1C
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    beq       L0B5F
                    clra
                    clrb
                    std       $0C,u
L0B5F               bsr       L0B64
                    lbra      L0CC3

L0B64               pshs      u
                    ldd       #$FFC0
                    lbsr      L010F
                    clra
                    clrb
                    std       L0028
                    ldd       L0028
                    addd      L002A
                    std       $0020
                    ldd       $0020
                    addd      L0022
                    std       $0024
                    ldd       $0024
                    addd      L0026
                    std       L001C
                    ldd       L001A
                    addd      #$000E
                    std       L002C
                    puls      pc,u
L0B8B               pshs      u
                    ldd       #$FFB4
                    lbsr      L010F
                    leas      -$02,s
                    bsr       L0BCC
                    std       ,s
                    ldx       $06,s
                    ldd       $2d,x
                    ldx       ,s
                    std       $0e,x
                    ldd       ,s
                    ldx       $06,s
                    std       $2d,x
                    ldd       #$0009
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $04,s
                    pshs      d
                    lbsr      L2F4B
                    leas      $06,s
                    ldd       $0a,s
                    ldx       ,s
                    std       $0a,x
                    ldd       ,s
                    pshs      d
                    lbsr      L1A56
                    leas      $02,s
                    puls      pc,u,x
L0BCC               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    ldd       $0001
                    bne       L0BE6
                    ldd       #$0012
                    pshs      d
                    lbsr      L1C1F
                    leas      $02,s
                    tfr       d,u
                    bra       L0BEC

L0BE6               ldu       $0001
                    ldd       $0e,u
                    std       $0001
L0BEC               tfr       u,d
                    puls      pc,u
L0BF0               pshs      u
                    ldd       #$FFB4
                    lbsr      L010F
                    ldd       #$0001
                    pshs      d
                    ldx       $06,s
                    ldd       $1f,x
                    ldx       $06,s
                    addd      $1d,x
                    ldx       $06,s
                    addd      $1b,x
                    bra       L0C25

L0C0E               pshs      u
                    ldd       #$FFB4
                    lbsr      L010F
                    ldd       #$0001
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    ldd       #$0003
                    lbsr      L317F
L0C25               lbsr      L3140
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L0038
                    pshs      d
                    lbsr      $28C3
                    leas      $08,s
                    puls      pc,u
L0C3B               pshs      u
                    ldd       #$FFAE
                    lbsr      L010F
                    leas      -$0C,s
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF8
                    leas      $02,s
                    std       ,s
                    bra       L0C69

L0C52               leax      $02,s
                    pshs      x
                    lbsr      L1DE0
                    leas      $02,s
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF8
                    std       ,s
                    lbsr      L0C0E
                    leas      $02,s
L0C69               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bne       L0C52
                    leas      $0C,s
                    puls      pc,u
L0C79               pshs      u
                    ldd       #$FFAF
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$05,s
                    clra
                    clrb
                    bra       L0CB7

L0C89               ldd       L0038
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0003
                    pshs      d
                    leax      $06,s
                    pshs      x
                    lbsr      L232D
                    leas      $08,s
                    std       -$02,s
                    bne       L0CA7
                    lbsr      L0D84
L0CA7               ldb       ,s
                    clra
                    andb      #$30
                    cmpd      #$0020
                    beq       L0CB9
                    ldd       $03,s
                    addd      #$0001
L0CB7               std       $03,s
L0CB9               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    bne       L0C89
                    ldd       $03,s
L0CC3               leas      $05,s
                    puls      pc,u
L0CC7               pshs      u
                    ldd       #$FFBE
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$02,s
                    stu       ,s
                    stu       ,s
                    bra       L0CDD

L0CD9               stu       ,s
                    ldu       $0e,u
L0CDD               stu       -$02,s
                    bne       L0CD9
                    ldd       ,s
                    puls      pc,u,x
L0CE5               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      $00A3,y
                    pshs      x
                    lbsr      L23CF
                    leas      $06,s
                    leax      $00A3,y
                    pshs      x
                    ldd       #$000D
                    pshs      d
                    lbsr      L2A83
                    leas      $04,s
                    leax      L0F64,pcr
                    pshs      x
                    lbsr      L1AB5
                    puls      pc,u,x
L0D1B               pshs      u
                    ldd       #$FFBA
                    lbsr      L010F
                    leax      L0F75,pcr
                    pshs      x
                    bsr       L0CE5
                    puls      pc,u,x
L0D2D               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    ldd       L0042
                    pshs      d
                    leax      L0F89,pcr
                    lbra      L0D94

L0D40               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    ldd       L0042
                    pshs      d
                    leax      L0F99,pcr
                    bra       L0D94

L0D52               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    ldd       L0042
                    pshs      d
                    leax      L0FBA,pcr
                    bra       L0D94

L0D64               pshs      u
                    ldd       #$FFB6
                    lbsr      L010F
                    ldd       L0042
                    pshs      d
                    ldx       L003E
                    ldd       $2f,x
                    pshs      d
                    leax      L0FD8,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $06,s
                    puls      pc,u
L0D84               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    ldd       L0042
                    pshs      d
                    leax      L0FF9,pcr
L0D94               pshs      x
                    lbsr      L1AB5
                    leas      $04,s
                    puls      pc,u
L0D9D               pshs      u
                    ldd       #$FFBE
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$02,s
                    stu       ,s
                    bra       L0DB9

L0DAD               ldb       ,u
                    cmpb      #$2f
                    bne       L0DB7
                    leax      $01,u
                    stx       ,s
L0DB7               leau      $01,u
L0DB9               ldb       ,u
                    bne       L0DAD
                    ldd       ,s
                    puls      pc,u,x
                    fcc       /etext/
                    fcb       $00
                    fcc       /edata/
                    fcb       $00
                    fcb       $65,$6E,$64
                    fcb       $00
                    fcc       /dpsiz/
                    fcb       $00
                    fcc       /btext/
                    fcb       $00
L0DDD               fcc       /error specifying library: -l%s/
                    fcb       $0D,$00
L0DFD               fcc       /error specifying %s -M%s/
                    fcb       $0D,$00
L0E17               fcc       /memory size:/
                    fcb       $00
L0E24               fcc       /unknown option -%c/
                    fcb       $00
L0E37               fcc       /too many source files/
                    fcb       $00
L0E4D               fcc       /unresolved references/
                    fcb       $00
L0E63               fcc       /no init data allowed/
                    fcb       $00
L0E78               fcc       /no dp data allowed/
                    fcb       $00
L0E8B               fcc       /no static data/
                    fcb       $00
L0E9A               fcc       /direct page allocation is %u bytes/
                    fcb       $00
L0EBD               fcc       /name clash/
                    fcb       $00
L0EC8               fcc       /no output file/
                    fcb       $00
L0ED7               fcc       /no entry point name/
                    fcb       $00
L0EEB               fcc       /entry point '%s' not found/
                    fcb       $00
L0F06               fcb       $72
                    fcb       $00
L0F08               fcc       /'%s' contains no mainline/
                    fcb       $00
L0F22               fcb       $72
                    fcb       $00
L0F24               fcc       /symbol already defined: %-8s in %s/
                    fcb       $0D,$00
L0F48               fcc       /unknown entry type in %s:%s/
                    fcb       $00
L0F64               fcc       /BASIC09 conflict/
                    fcb       $00
L0F75               fcc       /no mainline allowed/
                    fcb       $00
L0F89               fcc       /can't open '%s'/
                    fcb       $00
L0F99               fcc       /'%s' is not a relocatable module/
                    fcb       $00
L0FBA               fcc       /'%s' contains assembly errors/
                    fcb       $00
L0FD8               fcc       /mainline found in both %s and %s/
                    fcb       $00
L0FF9               fcc       /error reading input file %s/
                    fcb       $00
L1015               pshs      u
                    ldd       #$FFA5
                    lbsr      L010F
                    leas      -$0f,s
                    ldd       $0034
                    std       L0046
                    pshs      d
                    lbsr      L1C1F
                    leas      $02,s
                    std       L0048
                    clra
                    clrb
                    std       L0046
                    ldd       #$87CD
                    std       $02,s
                    ldd       L001A
                    addd      L0036
                    aslb
                    rola
                    addd      #$000D
                    addd      $002E
                    addd      L0026
                    addd      L002A
                    addd      #$000D
                    std       $04,s
                    ldd       #$000D
                    std       $06,s
                    ldd       L0018
                    pshs      d
                    ldd       #$0008
                    lbsr      L329D
                    stb       $08,s
                    ldd       L0018
                    clra
                    stb       $09,s
                    ldd       #$0008
                    pshs      d
                    leax      $04,s
                    pshs      x
                    lbsr      L18C7
                    leas      $04,s
                    stb       $0a,s
                    ldd       copybytes
                    beq       L1077
                    ldd       L0030
                    bra       L107E

L1077               ldx       L003E
                    ldd       $23,x
                    addd      L002C
L107E               std       $0b,s
                    ldd       L002A
                    addd      L0022
                    addd      L0026
                    addd      $001E
                    addd      L0032
                    std       $0d,s
                    leax      L193E,pcr
                    pshs      x
                    ldd       $0273,y
                    pshs      d
                    lbsr      L2299
                    leas      $04,s
                    std       L003A
                    bne       L10B0
                    bra       L10A5

L10A3               leas      -$0f,x
L10A5               leax      L1942,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $02,s
L10B0               ldd       #$0200
                    ldx       L003A
                    std       $0b,x
                    ldd       $04,s
                    pshs      d
                    ldx       L003A
                    ldd       $08,x
                    pshs      d
                    lbsr      L192B
                    leas      $04,s
                    std       -$02,s
                    beq       L10CE
                    leax      $0f,s
                    bra       L10A3

L10CE               leax      >$0005,y
                    pshs      x
                    ldd       #$000D
                    pshs      d
                    leax      $06,s
                    pshs      x
                    lbsr      L3491
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$000D
                    pshs      d
                    leax      $08,s
                    pshs      x
                    lbsr      L2373
                    leas      $08,s
                    lbsr      L1907
                    ldd       $0271,y
                    std       ,s
L1102               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L1102
                    ldd       ,s
                    subd      #$0002
                    std       ,s
                    ldb       [,s]
                    sex
                    orb       #$80
                    stb       [,s]
                    leax      >$0005,y
                    pshs      x
                    ldd       L001A
                    pshs      d
                    ldd       $0271,y
                    pshs      d
                    lbsr      L3491
                    leas      $06,s
                    ldd       $0271,y
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      L23CF
                    leas      $04,s
                    lbsr      L1907
                    leax      >$0005,y
                    pshs      x
                    ldd       #$0001
                    pshs      d
                    leax      $0270,y
                    pshs      x
                    lbsr      L3491
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldb       $0270,y
                    sex
                    pshs      d
                    lbsr      L2A83
                    leas      $04,s
                    ldb       [,s]
                    clra
                    andb      #$7f
                    stb       [,s]
                    ldd       L0036
                    pshs      d
                    lbsr      L1F89
                    leas      $02,s
                    leax      $0377,y
                    pshs      x
                    ldd       L003A
                    pshs      d
                    lbsr      L2A1A
                    leas      $02,s
                    lbsr      L314B
                    leax      $037f,y
                    pshs      x
                    leax      $0377,y
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $002E
                    lbsr      L3140
                    lbsr      L30BD
                    lbsr      L314B
                    leax      $037b,y
                    pshs      x
                    leax      $037f,y
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L11BE
                    fcb       $00,$00,$00,$02
L11BE               puls      x
                    lbsr      L30BD
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L002A
                    lbsr      L3140
                    lbsr      L30BD
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L11E1
                    fcb       $00,$00,$00,$02
L11E1               puls      x
                    lbsr      L30BD
                    lbsr      L314B
                    leax      $0383,y
                    pshs      x
                    leax      $037b,y
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L0026
                    lbsr      L3140
                    lbsr      L30BD
                    lbsr      L314B
                    ldd       L003E
                    bra       L1221

L120A               ldx       L0050
                    ldd       $13,x
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L121C
                    lbsr      L145D
                    lbsr      L1907
L121C               ldx       L0050
                    ldd       $11,x
L1221               std       L0050
                    ldd       L0050
                    bne       L120A
                    clra
                    clrb
                    pshs      d
                    leax      $037f,y
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      $28C3
                    leas      $08,s
                    leax      >$0005,y
                    pshs      x
                    ldd       #$0002
                    pshs      d
                    leax      >$002a,y
                    pshs      x
                    lbsr      L3491
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldd       L002A
                    pshs      d
                    lbsr      L2B28
                    leas      $04,s
                    leax      >$0005,y
                    pshs      x
                    ldd       L002A
                    pshs      d
                    leax      $0277,y
                    pshs      x
                    lbsr      L3491
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldd       L002A
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    leax      $0277,y
                    pshs      x
                    lbsr      L2373
                    leas      $08,s
                    lbsr      L1907
                    leax      >$0005,y
                    pshs      x
                    ldd       #$0002
                    pshs      d
                    leax      >$0026,y
                    pshs      x
                    lbsr      L3491
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldd       L0026
                    pshs      d
                    lbsr      L2B28
                    leas      $04,s
                    ldd       L0026
                    beq       L12C3
                    ldd       L0026
                    pshs      d
                    lbsr      L13DB
                    leas      $02,s
L12C3               clra
                    clrb
                    pshs      d
                    leax      $0383,y
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      $28C3
                    leas      $08,s
                    leax      >$0005,y
                    pshs      x
                    ldd       #$0002
                    pshs      d
                    leax      >$004e,y
                    pshs      x
                    lbsr      L3491
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldd       L004E
                    pshs      d
                    lbsr      L2B28
                    leas      $04,s
                    ldd       L0052
                    pshs      d
                    lbsr      L2091
                    leas      $02,s
                    leax      >$0005,y
                    pshs      x
                    ldd       #$0002
                    pshs      d
                    leax      >$004C,y
                    pshs      x
                    lbsr      L3491
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldd       L004C
                    pshs      d
                    lbsr      L2B28
                    leas      $04,s
                    ldd       L0054
                    pshs      d
                    lbsr      L2091
                    leas      $02,s
                    leax      >$0005,y
                    pshs      x
                    ldd       L001A
                    addd      #$0001
                    pshs      d
                    ldd       $0271,y
                    pshs      d
                    lbsr      L3491
                    leas      $06,s
                    ldd       $0271,y
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      L23CF
                    leas      $04,s
                    ldd       L003A
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      L2A83
                    leas      $04,s
                    ldu       #$0000
                    bra       L1388

L136D               tfr       u,d
                    leax      >$0005,y
                    leax      d,x
                    pshs      x
                    tfr       u,d
                    leax      >$0005,y
                    leax      d,x
                    ldb       ,x
                    sex
                    coma
                    comb
                    stb       [,s++]
                    leau      $01,u
L1388               cmpu      #$0003
                    blt       L136D
                    ldd       L003A
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0003
                    pshs      d
                    leax      >$0005,y
                    pshs      x
                    lbsr      L2373
                    leas      $08,s
                    lbsr      L1907
                    ldd       L003A
                    pshs      d
                    lbsr      L2B73
                    leas      $02,s
                    ldd       $000E
                    beq       L13BA
                    lbsr      L1CAB
L13BA               ldd       copybytes
                    beq       L13D7
                    ldd       L0016
                    beq       L13D7
                    ldd       $001E
                    pshs      d
                    leax      L195B,pcr
                    pshs      x
                    leax      $00A3,y
                    pshs      x
                    lbsr      L23CF
                    leas      $06,s
L13D7               leas      $0f,s
                    puls      pc,u
L13DB               pshs      u
                    ldd       #$FF32
                    lbsr      L010F
                    leas      $FF7E,s
                    clra
                    clrb
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      L2A1A
                    leas      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      $28C3
                    leas      $08,s
                    bra       L1436

L1407               lbsr      L1907
                    ldd       ,s
                    cmpd      $0086,s
                    ble       L1419
                    ldd       $0086,s
                    std       ,s
L1419               leax      >$0005,y
                    pshs      x
                    ldd       $02,s
                    pshs      d
                    leax      $06,s
                    pshs      x
                    lbsr      L3491
                    leas      $06,s
                    ldd       $0086,s
                    subd      ,s
                    std       $0086,s
L1436               ldd       $0086,s
                    ble       L1457
                    ldd       L003A
                    pshs      d
                    ldd       #$0080
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    leax      $08,s
                    pshs      x
                    lbsr      L232D
                    leas      $08,s
                    std       ,s
                    bne       L1407
L1457               leas      $0082,s
                    puls      pc,u
L145D               pshs      u
                    ldd       #$FFA3
                    lbsr      L010F
                    leas      -$07,s
                    ldd       $004A
                    ldx       L0050
                    cmpd      $2f,x
                    beq       L149F
                    ldd       L0038
                    pshs      d
                    leax      L1981,pcr
                    pshs      x
                    ldx       L0050
                    ldd       $2f,x
                    std       $004A
                    pshs      d
                    lbsr      L22B8
                    leas      $06,s
                    std       L0038
                    bne       L149F
                    ldx       L0050
                    ldd       $2f,x
                    pshs      d
                    leax      L1983,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $04,s
L149F               clra
                    clrb
                    pshs      d
                    ldx       L0050
                    leax      $29,x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L0038
                    pshs      d
                    lbsr      $28C3
                    leas      $08,s
                    ldd       L0038
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldx       L0050
                    ldd       $1f,x
                    ldx       L0050
                    addd      $1d,x
                    ldx       L0050
                    addd      $1b,x
                    pshs      d
                    ldd       L0048
                    pshs      d
                    lbsr      L232D
                    leas      $08,s
                    std       -$02,s
                    bne       L14EC
                    ldx       L0050
                    ldd       $2f,x
                    pshs      d
                    lbsr      L18F5
                    leas      $02,s
L14EC               ldd       L0038
                    pshs      d
                    lbsr      L2CF8
                    leas      $02,s
                    std       ,s
                    ldx       L0038
                    ldd       $06,x
                    clra
                    andb      #$20
                    lbeq      L15A5
                    ldx       L0050
                    ldd       $2f,x
                    pshs      d
                    lbsr      L18F5
                    leas      $02,s
                    lbra      L15A5

L1511               leas      -$0a,s
                    leax      ,s
                    pshs      x
                    lbsr      L1DE0
                    leas      $02,s
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF8
                    leas      $02,s
                    tfr       d,u
                    ldx       L0038
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L153C
                    ldx       L0050
                    ldd       $2f,x
                    pshs      d
                    lbsr      L18F5
                    leas      $02,s
L153C               leax      ,s
                    pshs      x
                    leax      $02,s
                    pshs      x
                    lbsr      L19F7
                    std       ,s
                    lbsr      L1A1C
                    leas      $04,s
                    std       $0f,s
                    bne       L159B
                    leax      ,s
                    pshs      x
                    leax      L199E,pcr
                    pshs      x
                    lbsr      L1AB5
                    bra       L1599

L1561               ldd       L0038
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0003
                    pshs      d
                    leax      $12,s
                    pshs      x
                    lbsr      L232D
                    leas      $08,s
                    ldx       L0038
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L158E
                    ldx       L0050
                    ldd       $2f,x
                    pshs      d
                    lbsr      L18F5
                    leas      $02,s
L158E               ldd       $0f,s
                    pshs      d
                    leax      $0e,s
                    pshs      x
                    lbsr      L17A0
L1599               leas      $04,s
L159B               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    bne       L1561
                    leas      $0a,s
L15A5               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    lbne      L1511
                    ldd       L0038
                    pshs      d
                    lbsr      L2CF8
                    leas      $02,s
                    std       ,s
                    ldx       L0038
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L160E
                    ldx       L0050
                    ldd       $2f,x
                    pshs      d
                    lbsr      L18F5
                    leas      $02,s
                    bra       L160E

L15D5               ldd       L0038
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       #$0003
                    pshs      d
                    leax      $08,s
                    pshs      x
                    lbsr      L232D
                    leas      $08,s
                    ldx       L0038
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L1601
                    ldx       L0050
                    ldd       $2f,x
                    pshs      d
                    lbsr      L18F5
                    leas      $02,s
L1601               clra
                    clrb
                    pshs      d
                    leax      $04,s
                    pshs      x
                    lbsr      L17A0
                    leas      $04,s
L160E               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bne       L15D5
                    leax      >$0005,y
                    pshs      x
                    ldx       L0050
                    ldd       $1f,x
                    pshs      d
                    ldd       L0048
                    pshs      d
                    lbsr      L3491
                    leas      $06,s
                    ldd       $005A
                    bne       L164D
                    clra
                    clrb
                    pshs      d
                    leax      $0377,y
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      $28C3
                    leas      $08,s
L164D               ldd       L003A
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldx       L0050
                    ldd       $1f,x
                    pshs      d
                    ldd       L0048
                    pshs      d
                    lbsr      L2373
                    leas      $08,s
                    leax      $0377,y
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldx       L0050
                    ldd       $1f,x
                    lbsr      L3140
                    lbsr      L30BD
                    lbsr      L314B
                    ldd       #$0001
                    std       $005A
                    lbsr      L1907
                    clra
                    clrb
                    std       ,s
                    ldd       L0048
                    ldx       L0050
                    addd      $1f,x
                    tfr       d,u
                    bra       L16AE

L1699               ldb       ,u+
                    ldx       >$007a,y
                    leax      $01,x
                    stx       >$007a,y
                    stb       -$01,x
                    ldd       ,s
                    addd      #$0001
                    std       ,s
L16AE               ldd       ,s
                    ldx       L0050
                    cmpd      $1d,x
                    bcs       L1699
                    ldx       L0050
                    ldd       $1b,x
                    lbeq      L1720
                    clra
                    clrb
                    pshs      d
                    leax      $037b,y
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       L003A
                    pshs      d
                    lbsr      $28C3
                    leas      $08,s
                    ldd       L003A
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldx       L0050
                    ldd       $1b,x
                    pshs      d
                    ldd       L0048
                    ldx       L0050
                    addd      $1f,x
                    ldx       L0050
                    addd      $1d,x
                    pshs      d
                    lbsr      L2373
                    leas      $08,s
                    leax      $037b,y
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldx       L0050
                    ldd       $1b,x
                    lbsr      L3140
                    lbsr      L30BD
                    lbsr      L314B
                    lbsr      L1907
                    clra
                    clrb
                    std       $005A
L1720               ldd       L001C
                    pshs      d
                    ldx       L0050
                    ldd       $17,x
                    addd      ,s++
                    std       L001C
                    ldd       $0020
                    pshs      d
                    ldx       L0050
                    ldd       $19,x
                    addd      ,s++
                    std       $0020
                    ldd       $0024
                    pshs      d
                    ldx       L0050
                    ldd       $1b,x
                    addd      ,s++
                    std       $0024
                    ldd       L0028
                    pshs      d
                    ldx       L0050
                    ldd       $1d,x
                    addd      ,s++
                    std       L0028
                    ldd       L002C
                    pshs      d
                    ldx       L0050
                    ldd       $1f,x
                    addd      ,s++
                    std       L002C
                    ldd       L001C
                    ldx       L0050
                    subd      $17,x
                    ldx       L0050
                    std       $17,x
                    ldd       $0020
                    ldx       L0050
                    subd      $19,x
                    ldx       L0050
                    std       $19,x
                    ldd       $0024
                    ldx       L0050
                    subd      $1b,x
                    ldx       L0050
                    std       $1b,x
                    ldd       L0028
                    ldx       L0050
                    subd      $1d,x
                    ldx       L0050
                    std       $1d,x
                    ldd       L002C
                    ldx       L0050
                    subd      $1f,x
                    ldx       L0050
                    std       $1f,x
                    lbra      L18C3

L17A0               pshs      u
                    ldd       #$FFB1
                    lbsr      L010F
                    leas      -$07,s
                    ldx       $0b,s
                    ldd       $01,x
                    addd      L0048
                    std       $05,s
                    ldb       [$0b,s]
                    stb       $02,s
                    ldd       $0d,s
                    beq       L17D8
                    ldx       $0d,s
                    ldd       $0C,x
                    std       $03,s
                    ldx       $0d,s
                    ldd       $0a,x
                    stb       $01,s
                    ldb       $02,s
                    clra
                    andb      #$80
                    lbeq      L1820
                    ldd       $03,s
                    subd      L002C
                    std       $03,s
                    bra       L1820

L17D8               ldb       $02,s
                    stb       $01,s
                    clra
                    andb      #$07
                    tfr       d,x
                    bra       L1806

L17E3               ldd       L001C
                    bra       L17F5

L17E7               ldd       $0024
                    bra       L17F5

L17EB               ldd       $0020
                    bra       L17F5

L17EF               ldd       L0028
                    bra       L17F5

L17F3               ldd       L002C
L17F5               std       $03,s
                    bra       L1820

L17F9               leax      L19BC,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $02,s
                    bra       L1820

L1806               stx       -$02,s
                    beq       L17E3
                    cmpx      #$0001
                    beq       L17E7
                    cmpx      #$0002
                    beq       L17EB
                    cmpx      #$0003
                    beq       L17EF
                    cmpx      #$0004
                    beq       L17F3
                    bra       L17F9

L1820               ldb       $02,s
                    clra
                    andb      #$40
                    beq       L182F
                    ldd       $03,s
                    nega
                    negb
                    sbca      #$00
                    std       $03,s
L182F               ldb       $02,s
                    clra
                    andb      #$30
                    stb       ,s
                    cmpb      #$20
                    beq       L185B
                    ldd       $05,s
                    pshs      d
                    ldx       L0050
                    ldd       $1f,x
                    addd      ,s++
                    std       $05,s
                    ldb       ,s
                    clra
                    andb      #$10
                    bne       L185B
                    ldd       $05,s
                    pshs      d
                    ldx       L0050
                    ldd       $1d,x
                    addd      ,s++
                    std       $05,s
L185B               ldb       $02,s
                    clra
                    andb      #$08
                    beq       L186D
                    ldb       [$05,s]
                    sex
                    addd      $03,s
                    stb       [$05,s]
                    bra       L1875

L186D               ldd       [$05,s]
                    addd      $03,s
                    std       [$05,s]
L1875               ldb       ,s
                    cmpb      #$20
                    beq       L18C3
                    ldb       ,s
                    clra
                    andb      #$10
                    beq       L1886
                    ldd       L0028
                    bra       L1888

L1886               ldd       $0024
L1888               ldx       $0b,s
                    addd      $01,x
                    tfr       d,u
                    ldb       $01,s
                    clra
                    andb      #$07
                    cmpd      #$0004
                    bne       L18AF
                    pshs      u
                    leax      >$0052,y
                    pshs      x
                    lbsr      L200D
                    leas      $04,s
                    ldd       L004E
                    addd      #$0001
                    std       L004E
                    bra       L18C3

L18AF               pshs      u
                    leax      >$0054,y
                    pshs      x
                    lbsr      L200D
                    leas      $04,s
                    ldd       L004C
                    addd      #$0001
                    std       L004C
L18C3               leas      $07,s
                    puls      pc,u
L18C7               pshs      u
                    ldd       #$FFBC
                    lbsr      L010F
                    ldu       $04,s
                    leas      -$02,s
                    ldd       #$FFFF
                    bra       L18E3

L18D8               ldd       ,s
                    pshs      d
                    ldb       ,u+
                    sex
                    eora      ,s+
                    eorb      ,s+
L18E3               std       ,s
                    ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L18D8
                    ldd       ,s
                    puls      pc,u,x
L18F5               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    ldd       $04,s
                    pshs      d
                    leax      L19CB,pcr
                    bra       L1922

L1907               pshs      u
                    ldd       #$FFB8
                    lbsr      L010F
                    ldx       L003A
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L1929
                    ldd       $0273,y
                    pshs      d
                    leax      L19E1,pcr
L1922               pshs      x
                    lbsr      L1AB5
                    leas      $04,s
L1929               puls      pc,u
L192B               pshs      u,x,d
                    lda       $09,s
                    ldb       #$02
                    ldx       #$0000
                    ldu       $0a,s
                    os9       I$SetStt
                    puls      u,x,d
                    lbra      L3566
L193E               fcb       $77,$78,$2B
                    fcb       $00
L1942               fcc       /can't create output file/
                    fcb       $00
L195B               fcc       /BASIC09 static data size is %d bytes/
                    fcb       $0D,$00
L1981               fcb       $72
                    fcb       $00
L1983               fcc       /can't reopen input file %s/
                    fcb       $00
L199E               fcc       /symbol %s not found in codgen/
                    fcb       $00
L19BC               fcc       /ref type error/
                    fcb       $00
L19CB               fcc       /error reading file %s/
                    fcb       $00
L19E1               fcc       /error writing file %s/
                    fcb       $00
L19F7               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    clra
                    clrb
                    bra       L1A0A

L1A01               ldd       ,s
                    pshs      d
                    ldb       ,u+
                    sex
                    addd      ,s++
L1A0A               std       ,s
                    ldb       ,u
                    bne       L1A01
                    ldd       ,s
                    pshs      d
                    ldd       #$0173
                    lbsr      L31D2
                    puls      pc,u,x
L1A1C               pshs      u
                    ldd       $04,s
                    aslb
                    rola
                    leax      $0387,y
                    leax      d,x
                    ldu       ,x
                    bra       L1A4E

L1A2C               ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    cmpd      ,s++
                    bne       L1A4B
                    pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L2F1A
                    leas      $04,s
                    std       -$02,s
                    lbeq      L1C1B
L1A4B               ldu       $10,u
L1A4E               stu       -$02,s
                    bne       L1A2C
                    clra
                    clrb
                    puls      pc,u
L1A56               pshs      u,d
                    ldd       $06,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L19F7
                    leas      $02,s
                    std       $02,s
                    pshs      d
                    lbsr      L1A1C
                    leas      $04,s
                    std       -$02,s
                    bne       L1AAE
                    ldd       ,s
                    aslb
                    rola
                    leax      $0387,y
                    leax      d,x
                    ldd       ,x
                    ldx       $06,s
                    std       $10,x
                    ldd       ,s
                    aslb
                    rola
                    leax      $0387,y
                    leax      d,x
                    ldd       $06,s
                    std       ,x
                    clra
                    clrb
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L1B82
                    leas      $04,s
                    std       -$02,s
                    beq       L1AAA
                    ldx       $06,s
                    ldd       $0a,x
                    ora       #$01
                    std       $0a,x
L1AAA               clra
                    clrb
                    bra       L1AB1

L1AAE               ldd       #$0001
L1AB1               puls      pc,u,x
                    puls      pc,u,x
L1AB5               pshs      u,d
                    ldd       $0228,y
                    std       ,s
                    leax      L1E2C,pcr
                    pshs      x
                    leax      $00A3,y
                    pshs      x
                    lbsr      L23CF
                    leas      $04,s
                    ldd       $0C,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    leax      $00A3,y
                    pshs      x
                    lbsr      L23CF
                    leas      $0a,s
                    leax      L1E3B,pcr
                    pshs      x
                    leax      $00A3,y
                    pshs      x
                    lbsr      L23CF
                    leas      $04,s
                    ldd       ,s
                    pshs      d
                    lbsr      L356B
                    leas      $02,s
                    puls      pc,u,x
L1B05               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    bra       L1B22

L1B0F               ldd       ,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L317F
                    pshs      d
                    ldd       $04,s
                    addd      #$FFD0
                    addd      ,s++
L1B22               std       ,s
                    ldb       ,u+
                    sex
                    std       $02,s
                    leax      $015a,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L1B0F
                    ldd       $02,s
                    cmpd      #$006B
                    beq       L1B46
                    ldd       $02,s
                    cmpd      #$004B
                    bne       L1B52
L1B46               ldd       ,s
                    pshs      d
                    ldd       #$0004
                    lbsr      L317F
                    std       ,s
L1B52               ldd       ,s
                    pshs      d
                    ldd       #$0008
                    lbsr      L32C0
                    leas      $04,s
                    puls      pc,u
L1B60               pshs      u
                    ldu       $04,s
                    ldd       ,u
                    std       [$02,u]
                    ldd       $02,u
                    ldx       ,u
                    std       $02,x
                    leax      >$0060,y
                    pshs      x
                    cmpu      ,s++
                    beq       L1B80
                    ldd       L005C
                    std       ,u
                    stu       L005C
L1B80               puls      pc,u
L1B82               pshs      u,d
                    clra
                    clrb
                    std       ,s
                    ldu       >$0060,y
                    bra       L1BC9

L1B8E               ldb       $04,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    bne       L1BC7
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       #$0004
                    addd      ,s++
                    pshs      d
                    lbsr      L2F1A
                    leas      $04,s
                    std       -$02,s
                    bne       L1BC7
                    ldd       $08,s
                    beq       L1BBA
                    tfr       u,d
                    puls      pc,u,x
L1BBA               ldd       ,u
                    std       ,s
                    pshs      u
                    lbsr      L1B60
                    leas      $02,s
                    ldu       ,s
L1BC7               ldu       ,u
L1BC9               leax      >$0060,y
                    pshs      x
                    cmpu      ,s++
                    bne       L1B8E
                    ldd       ,s
                    puls      pc,u,x
L1BD8               pshs      u
                    ldd       #$0001
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L1B82
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bne       L1C1B
                    ldd       L005C
                    beq       L1BFA
                    ldu       L005C
                    ldd       ,u
                    std       L005C
                    bra       L1C05

L1BFA               ldd       #$0010
                    pshs      d
                    bsr       L1C1F
                    leas      $02,s
                    tfr       d,u
L1C05               leax      >$0060,y
                    stx       $02,u
                    ldd       >$0060,y
                    std       ,u
                    ldx       >$0060,y
                    stu       $02,x
                    stu       >$0060,y
L1C1B               tfr       u,d
                    puls      pc,u
L1C1F               pshs      u,d
                    ldd       $06,s
                    pshs      d
                    lbsr      L34B7
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L1C58
                    ldd       L0046
                    beq       L1C4B
                    ldd       L0046
                    pshs      d
                    leax      L1E3D,pcr
                    pshs      x
                    leax      $00A3,y
                    pshs      x
                    lbsr      L23CF
                    leas      $06,s
L1C4B               leax      L1E58,pcr
                    pshs      x
                    lbsr      L1AB5
                    leas      $02,s
                    bra       L1C5C

L1C58               ldd       ,s
                    puls      pc,u,x
L1C5C               puls      pc,u,x
L1C5E               pshs      u
                    ldd       $04,s
                    clra
                    andb      #$07
                    tfr       d,x
                    bra       L1C8F

L1C69               leax      L1E66,pcr
                    bra       L1C8B

L1C6F               leax      L1E6B,pcr
                    bra       L1C8B

L1C75               leax      L1E70,pcr
                    bra       L1C8B

L1C7B               leax      L1E75,pcr
                    bra       L1C8B

L1C81               leax      L1E7A,pcr
                    bra       L1C8B

L1C87               leax      L1E7F,pcr
L1C8B               tfr       x,d
                    puls      pc,u
L1C8F               cmpx      #$0004
                    beq       L1C69
                    stx       -$02,s
                    beq       L1C6F
                    cmpx      #$0001
                    beq       L1C75
                    cmpx      #$0002
                    beq       L1C7B
                    cmpx      #$0003
                    beq       L1C81
                    bra       L1C87
                    puls      pc,u
L1CAB               pshs      u,d
                    ldd       $0273,y
                    pshs      d
                    ldd       $0271,y
                    pshs      d
                    leax      L1E83,pcr
                    pshs      x
                    lbsr      L23BD
                    leas      $06,s
                    leax      L1EA1,pcr
                    pshs      x
                    lbsr      L22EB
                    leas      $02,s
                    ldd       L003E
                    lbra      L1D4C

L1CD4               ldx       ,s
                    ldd       $13,x
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L1D47
                    ldx       ,s
                    ldd       $2f,x
                    pshs      d
                    ldx       $02,s
                    ldd       $19,x
                    pshs      d
                    ldx       $04,s
                    ldd       $1d,x
                    pshs      d
                    ldx       $06,s
                    ldd       $17,x
                    pshs      d
                    ldx       $08,s
                    ldd       $1b,x
                    pshs      d
                    ldx       $0a,s
                    ldd       $1f,x
                    pshs      d
                    ldd       $0C,s
                    pshs      d
                    leax      L1ED3,pcr
                    pshs      x
                    lbsr      L23BD
                    leas      $10,s
                    ldd       $0010
                    beq       L1D47
                    ldx       ,s
                    ldu       $2d,x
                    bra       L1D43

L1D27               ldd       $0C,u
                    pshs      d
                    ldd       $0a,u
                    pshs      d
                    lbsr      L1C5E
                    std       ,s
                    pshs      u
                    leax      L1EF8,pcr
                    pshs      x
                    lbsr      L23BD
                    leas      $08,s
                    ldu       $0e,u
L1D43               stu       -$02,s
                    bne       L1D27
L1D47               ldx       ,s
                    ldd       $11,x
L1D4C               std       ,s
                    ldd       ,s
                    lbne      L1CD4
                    leax      L1F0B,pcr
                    pshs      x
                    lbsr      L22EB
                    leas      $02,s
                    ldd       L0022
                    pshs      d
                    ldd       L002A
                    pshs      d
                    ldd       $001E
                    pshs      d
                    ldd       L0026
                    pshs      d
                    ldd       $002E
                    pshs      d
                    leax      L1F2E,pcr
                    pshs      x
                    lbsr      L23BD
                    leas      $0C,s
                    puls      pc,u,x
L1D80               pshs      u
                    leax      >$0060,y
                    cmpx      >$0060,y
                    beq       L1DDA
                    leax      L1F5A,pcr
                    pshs      x
                    leax      $00A3,y
                    pshs      x
                    lbsr      L23CF
                    leas      $04,s
                    ldu       >$0060,y
                    bra       L1DCA

L1DA3               ldx       $0e,u
                    ldd       $2f,x
                    pshs      d
                    ldd       $0e,u
                    pshs      d
                    pshs      u
                    ldd       #$0004
                    addd      ,s++
                    pshs      d
                    leax      L1F72,pcr
                    pshs      x
                    leax      $00A3,y
                    pshs      x
                    lbsr      L23CF
                    leas      $0a,s
                    ldu       ,u
L1DCA               leax      >$0060,y
                    pshs      x
                    cmpu      ,s++
                    bne       L1DA3
                    ldd       #$0001
                    puls      pc,u
L1DDA               clra
                    clrb
                    puls      pc,u
                    puls      pc,u
L1DE0               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    bra       L1DEC

L1DE8               ldd       ,s
                    stb       ,u+
L1DEC               ldd       L0038
                    pshs      d
                    lbsr      L2C96
                    leas      $02,s
                    std       ,s
                    bne       L1DE8
                    clra
                    clrb
                    stb       ,u
                    puls      pc,u,x
L1DFF               pshs      u,d
                    ldd       $0228,y
                    std       ,s
                    ldd       L003A
                    beq       L1E1F
                    ldd       L003A
                    pshs      d
                    lbsr      L2B73
                    leas      $02,s
                    ldd       $0273,y
                    pshs      d
                    lbsr      L33AF
                    leas      $02,s
L1E1F               ldd       $0228,y
                    pshs      d
                    lbsr      L356B
                    leas      $02,s
                    puls      pc,u,x
L1E2C               fcc       /linker fatal: /
                    fcb       $00
L1E3B               fcb       $0D,$00
L1E3D               fcc       /need %d bytes for linkbuf/
                    fcb       $0D,$00
L1E58               fcc       /out of memory/
                    fcb       $00
L1E66               fcc       /code/
                    fcb       $00
L1E6B               fcc       /udat/
                    fcb       $00
L1E70               fcc       /idat/
                    fcb       $00
L1E75               fcc       /udpd/
                    fcb       $00
L1E7A               fcc       /idpd/
                    fcb       $00
L1E7F               fcb       $3F,$3F,$3F
                    fcb       $00
L1E83               fcc       /Linkage map for %s  File - %s/
                    fcb       $00
L1EA1               fcb       $0D,$0D
                    fcc       /Section          Code IDat UDat IDpD UDpD File/
                    fcb       $0D,$00
L1ED3               fcc       /%-16s %04x %04x %04x %02x   %02x %s/
                    fcb       $0D,$00
L1EF8               fcc       /     %-9s %s %04x/
                    fcb       $0D,$00
L1F0B               fcc       /                 ---- ---- ---- --/
                    fcb       $00
L1F2E               fcc       /                 %04x %04x %04x %02x  %02x/
                    fcb       $0D,$00
L1F5A               fcc       /Unresolved references:/
                    fcb       $0D,$00
L1F72               fcc       / %-16s %-16s in %-16s/
                    fcb       $0D,$00
L1F89               pshs      u
                    ldu       >$005C,y
                    bra       L1F9A

L1F91               ldu       ,u
                    ldd       $04,s
                    subd      #$0007
                    std       $04,s
L1F9A               ldd       $04,s
                    ble       L1FA2
                    stu       -$02,s
                    bne       L1F91
L1FA2               ldd       $04,s
                    beq       L1FC9
                    bra       L1FC5

L1FA8               ldd       #$0010
                    pshs      d
                    lbsr      L1C1F
                    leas      $02,s
                    tfr       d,u
                    ldd       >$005C,y
                    std       ,u
                    stu       >$005C,y
                    ldd       $04,s
                    subd      #$0007
                    std       $04,s
L1FC5               ldd       $04,s
                    bgt       L1FA8
L1FC9               puls      pc,u
L1FCB               pshs      u
                    ldu       $04,s
                    bra       L1FD6

L1FD1               ldd       #$FFFF
                    std       ,u++
L1FD6               ldd       $06,s
                    addd      #$FFFF
                    std       $06,s
                    subd      #$FFFF
                    bgt       L1FD1
                    puls      pc,u
L1FE4               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    clra
                    clrb
                    std       ,s
                    bra       L2001

L1FF0               ldd       ,u
                    bge       L1FF8
                    tfr       u,d
                    puls      pc,u,x
L1FF8               ldd       ,s
                    addd      #$0001
                    std       ,s
                    leau      $02,u
L2001               ldd       ,s
                    cmpd      #$0007
                    blt       L1FF0
                    clra
                    clrb
                    puls      pc,u,x
L200D               pshs      u,d
                    ldd       [$06,s]
                    bne       L203B
                    ldd       >$005C,y
                    std       [$06,s]
                    ldx       $06,s
                    ldd       [,x]
                    std       >$005C,y
                    clra
                    clrb
                    ldx       $06,s
                    std       [,x]
                    ldd       #$0007
                    pshs      d
                    ldd       [$08,s]
                    addd      #$0002
                    pshs      d
                    lbsr      L1FCB
                    leas      $04,s
L203B               ldd       [$06,s]
                    addd      #$0002
                    pshs      d
                    lbsr      L1FE4
                    leas      $02,s
                    std       ,s
                    bne       L208B
                    ldd       >$005C,y
                    bne       L205D
                    leax      L2131,pcr
                    pshs      x
                    lbsr      L1AB5
                    bra       L2089

L205D               leas      -$02,s
                    ldd       >$005C,y
                    std       ,s
                    ldd       [,s]
                    std       >$005C,y
                    ldd       [$08,s]
                    std       [,s]
                    ldd       ,s
                    std       [$08,s]
                    ldd       #$0007
                    pshs      d
                    ldd       [$0a,s]
                    addd      #$0002
                    std       $04,s
                    pshs      d
                    lbsr      L1FCB
                    leas      $04,s
L2089               leas      $02,s
L208B               ldd       $08,s
                    std       [,s]
                    puls      pc,u,x
L2091               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    bra       L20CC

L2099               clra
                    clrb
                    std       $02,s
                    leax      $02,u
                    stx       ,s
                    bra       L20C2

L20A3               ldd       [,s]
                    cmpd      #$FFFF
                    beq       L20CA
                    ldx       ,s
                    leax      $02,x
                    stx       ,s
                    ldd       -$02,x
                    pshs      d
                    bsr       L20D6
                    leas      $02,s
                    bra       L20BB

L20BB               ldd       $02,s
                    addd      #$0001
                    std       $02,s
L20C2               ldd       $02,s
                    cmpd      #$0007
                    blt       L20A3
L20CA               ldu       ,u
L20CC               stu       -$02,s
                    bne       L2099
                    bsr       L20F3
                    leas      $04,s
                    puls      pc,u
L20D6               pshs      u
                    ldd       $04,s
                    ldx       $0008
                    leax      $02,x
                    stx       $0008
                    std       -$02,x
                    ldd       $005E
                    addd      #$0002
                    std       $005E
                    cmpd      #$0100
                    blt       L20F1
                    bsr       L20F3
L20F1               puls      pc,u
L20F3               pshs      u
                    leax      >$0005,y
                    pshs      x
                    ldd       $005E
                    pshs      d
                    leax      $0277,y
                    pshs      x
                    lbsr      L3491
                    leas      $06,s
                    ldd       L003A
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    ldd       $005E
                    pshs      d
                    leax      $0277,y
                    pshs      x
                    lbsr      L2373
                    leas      $08,s
                    lbsr      L1907
                    leax      $0277,y
                    stx       $0008
                    clra
                    clrb
                    std       $005E
                    puls      pc,u
L2131               fcc       /out of dref nodes/
                    fcb       $00
L2143               pshs      u
                    leau      $0089,y
L2149               ldd       $06,u
                    clra
                    andb      #$03
                    lbeq      L21BA
                    leau      $0d,u
                    pshs      u
                    leax      $0159,y
                    cmpx      ,s++
                    bhi       L2149
                    ldd       #$00C8
                    std       $0228,y
                    lbra      L21BE
                    puls      pc,u
L216A               pshs      u
                    ldu       $08,s
                    bne       L2174
                    bsr       L2143
                    tfr       d,u
L2174               stu       -$02,s
                    beq       L21BE
                    ldd       $04,s
                    std       $08,u
                    ldx       $06,s
                    ldb       $01,x
                    cmpb      #$2b
                    beq       L218C
                    ldx       $06,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L2192
L218C               ldd       $06,u
                    orb       #$03
                    bra       L21B0

L2192               ldd       $06,u
                    pshs      d
                    ldb       [$08,s]
                    cmpb      #$72
                    beq       L21A4
                    ldb       [$08,s]
                    cmpb      #$64
                    bne       L21A9
L21A4               ldd       #$0001
                    bra       L21AC

L21A9               ldd       #$0002
L21AC               ora       ,s+
                    orb       ,s+
L21B0               std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
L21BA               tfr       u,d
                    puls      pc,u
L21BE               clra
                    clrb
                    puls      pc,u
L21C2               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $0a,s
                    ldb       $01,x
                    sex
                    tfr       d,x
                    bra       L21F3

L21D5               ldx       $0a,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L21E2
                    ldd       #$0007
                    bra       L21EA

L21E2               ldd       #$0004
                    bra       L21EA

L21E7               ldd       #$0003
L21EA               std       ,s
                    bra       L2203

L21EE               leax      $04,s
                    lbra      L225B

L21F3               stx       -$02,s
                    beq       L2203
                    cmpx      #$0078
                    beq       L21D5
                    cmpx      #$002B
                    beq       L21E7
                    bra       L21EE

L2203               ldb       [$0a,s]
                    sex
                    tfr       d,x
                    lbra      L2268

L220C               ldd       ,s
                    orb       #$01
                    bra       L224E

L2212               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      L334A
                    leas      $04,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L223D
                    ldd       #$0002
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L341E
                    leas      $08,s
                    bra       L2282

L223D               ldd       ,s
                    orb       #$0b
                    pshs      d
                    pshs      u
                    lbsr      L336B
                    bra       L2255

L224A               ldd       ,s
                    orb       #$81
L224E               pshs      d
                    pshs      u
                    lbsr      L334A
L2255               leas      $04,s
                    std       $02,s
                    bra       L2282

L225B               leas      -$04,x
L225D               ldd       #$00CB
                    std       $0228,y
                    clra
                    clrb
                    bra       L2284

L2268               cmpx      #$0072
                    lbeq      L220C
                    cmpx      #$0061
                    lbeq      L2212
                    cmpx      #$0077
                    beq       L223D
                    cmpx      #$0064
                    beq       L224A
                    bra       L225D

L2282               ldd       $02,s
L2284               leas      $04,s
                    puls      pc,u
                    pshs      u
                    clra
                    clrb
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbra      L22E4

L2299               pshs      u
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L21C2
                    leas      $04,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L22B4
                    clra
                    clrb
                    bra       L22E9

L22B4               clra
                    clrb
                    bra       L22DC

L22B8               pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L2B73
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L21C2
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bge       L22DA
                    clra
                    clrb
                    bra       L22E9

L22DA               ldd       $08,s
L22DC               pshs      d
                    ldd       $08,s
                    pshs      d
                    pshs      u
L22E4               lbsr      L216A
                    leas      $06,s
L22E9               puls      pc,u
L22EB               pshs      u
                    leax      $0096,y
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    bsr       L230D
                    leas      $04,s
                    leax      $0096,y
                    pshs      x
                    ldd       #$000D
                    pshs      d
                    lbsr      L2A83
                    leas      $04,s
                    puls      pc,u
L230D               pshs      u
                    ldu       $04,s
                    leas      -$01,s
                    bra       L2323

L2315               ldd       $07,s
                    pshs      d
                    ldb       $02,s
                    sex
                    pshs      d
                    lbsr      L2A83
                    leas      $04,s
L2323               ldb       ,u+
                    stb       ,s
                    bne       L2315
                    leas      $01,s
                    puls      pc,u
L232D               pshs      u
                    ldu       $04,s
                    leas      -$06,s
                    clra
                    clrb
                    bra       L2364

L2337               ldd       $0C,s
                    std       $04,s
                    bra       L2353

L233D               ldd       $10,s
                    pshs      d
                    lbsr      L2C96
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    beq       L236D
                    ldd       ,s
                    stb       ,u+
L2353               ldd       $04,s
                    addd      #$FFFF
                    std       $04,s
                    subd      #$FFFF
                    bgt       L233D
                    ldd       $02,s
                    addd      #$0001
L2364               std       $02,s
                    ldd       $02,s
                    cmpd      $0e,s
                    blt       L2337
L236D               ldd       $02,s
                    leas      $06,s
                    puls      pc,u
L2373               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    bra       L23AE

L237D               clra
                    clrb
                    std       ,s
                    bra       L239A

L2383               ldd       $0e,s
                    pshs      d
                    ldb       ,u+
                    sex
                    pshs      d
                    lbsr      L2A83
                    leas      $04,s
                    ldx       $0e,s
                    ldd       $06,x
                    clra
                    andb      #$20
                    bne       L23B7
L239A               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      $0a,s
                    blt       L2383
                    ldd       $02,s
                    addd      #$0001
L23AE               std       $02,s
                    ldd       $02,s
                    cmpd      $0C,s
                    blt       L237D
L23B7               ldd       $02,s
                    leas      $04,s
                    puls      pc,u
L23BD               pshs      u
                    leax      $0096,y
                    stx       $066d,y
                    leax      $06,s
                    pshs      x
                    ldd       $06,s
                    bra       L23DD

L23CF               pshs      u
                    ldd       $04,s
                    std       $066d,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
L23DD               pshs      d
                    leax      L2897,pcr
                    pshs      x
                    bsr       L240F
                    leas      $06,s
                    puls      pc,u
                    pshs      u
                    ldd       $04,s
                    std       $066d,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    leax      L28AA,pcr
                    pshs      x
                    bsr       L240F
                    leas      $06,s
                    clra
                    clrb
                    stb       [$066d,y]
                    ldd       $04,s
                    puls      pc,u
L240F               pshs      u
                    ldu       $06,s
                    leas      -$0b,s
                    bra       L2427

L2417               ldb       $08,s
                    lbeq      L2658
                    ldb       $08,s
                    sex
                    pshs      d
                    jsr       [$11,s]
                    leas      $02,s
L2427               ldb       ,u+
                    stb       $08,s
                    cmpb      #$25
                    bne       L2417
                    ldb       ,u+
                    stb       $08,s
                    clra
                    clrb
                    std       $02,s
                    std       $06,s
                    ldb       $08,s
                    cmpb      #$2d
                    bne       L244C
                    ldd       #$0001
                    std       $0683,y
                    ldb       ,u+
                    stb       $08,s
                    bra       L2452

L244C               clra
                    clrb
                    std       $0683,y
L2452               ldb       $08,s
                    cmpb      #$30
                    bne       L245D
                    ldd       #$0030
                    bra       L2460

L245D               ldd       #$0020
L2460               std       $0685,y
                    bra       L2480

L2466               ldd       $06,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L317F
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    ldb       ,u+
                    stb       $08,s
L2480               ldb       $08,s
                    sex
                    leax      $015a,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L2466
                    ldb       $08,s
                    cmpb      #$2e
                    bne       L24C9
                    ldd       #$0001
                    std       $04,s
                    bra       L24B3

L249D               ldd       $02,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L317F
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $02,s
L24B3               ldb       ,u+
                    stb       $08,s
                    ldb       $08,s
                    sex
                    leax      $015a,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L249D
                    bra       L24CD

L24C9               clra
                    clrb
                    std       $04,s
L24CD               ldb       $08,s
                    sex
                    tfr       d,x
                    lbra      L25FB

L24D5               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L265C
                    bra       L24FD

L24EA               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L271D
L24FD               std       ,s
                    lbra      L25E1

L2502               ldd       $06,s
                    pshs      d
                    ldb       $0a,s
                    sex
                    leax      $015a,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$02
                    pshs      d
                    ldx       $17,s
                    leax      $02,x
                    stx       $17,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L2763
                    lbra      L25DD

L2528               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    pshs      d
                    leax      $066f,y
                    pshs      x
                    lbsr      L26A4
                    lbra      L25DD

L2544               ldd       $04,s
                    bne       L254D
                    ldd       #$0006
                    std       $02,s
L254D               ldd       $06,s
                    pshs      d
                    leax      $15,s
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    ldb       $0e,s
                    sex
                    pshs      d
                    lbsr      $2EB9
                    leas      $06,s
                    lbra      L25DF

L2567               ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    lbra      L25F1

L2574               ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    std       $09,s
                    ldd       $04,s
                    beq       L25BC
                    ldd       $09,s
                    std       $04,s
                    bra       L2596

L258A               ldb       [$09,s]
                    beq       L25A2
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
L2596               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    bne       L258A
L25A2               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    subd      $06,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $15,s
                    pshs      d
                    lbsr      L27CE
                    leas      $08,s
                    bra       L25EB

L25BC               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    bra       L25DF

L25C4               ldb       ,u+
                    stb       $08,s
                    bra       L25CC
                    leas      -$0b,x
L25CC               ldd       $06,s
                    pshs      d
                    leax      $15,s
                    pshs      x
                    ldb       $0C,s
                    sex
                    pshs      d
                    lbsr      L2E7B
L25DD               leas      $04,s
L25DF               pshs      d
L25E1               ldd       $13,s
                    pshs      d
                    lbsr      L2830
                    leas      $06,s
L25EB               lbra      L2427

L25EE               ldb       $08,s
                    sex
L25F1               pshs      d
                    jsr       [$11,s]
                    leas      $02,s
                    lbra      L2427

L25FB               cmpx      #$0064
                    lbeq      L24D5
                    cmpx      #$006F
                    lbeq      L24EA
                    cmpx      #$0078
                    lbeq      L2502
                    cmpx      #$0058
                    lbeq      L2502
                    cmpx      #$0075
                    lbeq      L2528
                    cmpx      #$0066
                    lbeq      L2544
                    cmpx      #$0065
                    lbeq      L2544
                    cmpx      #$0067
                    lbeq      L2544
                    cmpx      #$0045
                    lbeq      L2544
                    cmpx      #$0047
                    lbeq      L2544
                    cmpx      #$0063
                    lbeq      L2567
                    cmpx      #$0073
                    lbeq      L2574
                    cmpx      #$006C
                    lbeq      L25C4
                    bra       L25EE

L2658               leas      $0b,s
                    puls      pc,u
L265C               pshs      u,d
                    leax      $066f,y
                    stx       ,s
                    ldd       $06,s
                    bge       L2690
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
                    bge       L2685
                    leax      L28BC,pcr
                    pshs      x
                    leax      $066f,y
                    pshs      x
                    lbsr      L2ED5
                    leas      $04,s
                    puls      pc,u,x
L2685               ldd       #$002D
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L2690               ldd       $06,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    bsr       L26A4
                    leas      $04,s
                    leax      $066f,y
                    tfr       x,d
                    puls      pc,u,x
L26A4               pshs      u,y,x,d
                    ldu       $0a,s
                    clra
                    clrb
                    std       $02,s
                    clra
                    clrb
                    std       ,s
                    bra       L26C1

L26B2               ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       $0C,s
                    subd      >$007C,y
                    std       $0C,s
L26C1               ldd       $0C,s
                    blt       L26B2
                    leax      >$007C,y
                    stx       $04,s
                    bra       L2703

L26CD               ldd       ,s
                    addd      #$0001
                    std       ,s
L26D4               ldd       $0C,s
                    subd      [$04,s]
                    std       $0C,s
                    bge       L26CD
                    ldd       $0C,s
                    addd      [$04,s]
                    std       $0C,s
                    ldd       ,s
                    beq       L26ED
                    ldd       #$0001
                    std       $02,s
L26ED               ldd       $02,s
                    beq       L26F8
                    ldd       ,s
                    addd      #$0030
                    stb       ,u+
L26F8               clra
                    clrb
                    std       ,s
                    ldd       $04,s
                    addd      #$0002
                    std       $04,s
L2703               ldd       $04,s
                    cmpd      $0084,y
                    bne       L26D4
                    ldd       $0C,s
                    addd      #$0030
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       $0a,s
                    leas      $06,s
                    puls      pc,u
L271D               pshs      u,d
                    leax      $066f,y
                    stx       ,s
                    leau      $0679,y
L2729               ldd       $06,s
                    clra
                    andb      #$07
                    addd      #$0030
                    stb       ,u+
                    ldd       $06,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    std       $06,s
                    bne       L2729
                    bra       L274B

L2741               ldb       ,u
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L274B               leau      -$01,u
                    pshs      u
                    leax      $0679,y
                    cmpx      ,s++
                    bls       L2741
                    clra
                    clrb
                    stb       [,s]
                    leax      $066f,y
                    tfr       x,d
                    puls      pc,u,x
L2763               pshs      u,x,d
                    leax      $066f,y
                    stx       $02,s
                    leau      $0679,y
L276F               ldd       $08,s
                    clra
                    andb      #$0f
                    std       ,s
                    pshs      d
                    ldd       $02,s
                    cmpd      #$0009
                    ble       L2791
                    ldd       $0C,s
                    beq       L2789
                    ldd       #$0041
                    bra       L278C

L2789               ldd       #$0061
L278C               addd      #$FFF6
                    bra       L2794

L2791               ldd       #$0030
L2794               addd      ,s++
                    stb       ,u+
                    ldd       $08,s
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    anda      #$0f
                    std       $08,s
                    bne       L276F
                    bra       L27B4

L27AA               ldb       ,u
                    ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    stb       -$01,x
L27B4               leau      -$01,u
                    pshs      u
                    leax      $0679,y
                    cmpx      ,s++
                    bls       L27AA
                    clra
                    clrb
                    stb       [$02,s]
                    leax      $066f,y
                    tfr       x,d
                    lbra      L28A6

L27CE               pshs      u
                    ldu       $06,s
                    ldd       $0a,s
                    subd      $08,s
                    std       $0a,s
                    ldd       $0683,y
                    bne       L2803
                    bra       L27EB

L27E0               ldd       $0685,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L27EB               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       L27E0
                    bra       L2803

L27F9               ldb       ,u+
                    sex
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L2803               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bne       L27F9
                    ldd       $0683,y
                    beq       L282E
                    bra       L2822

L2817               ldd       $0685,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L2822               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       L2817
L282E               puls      pc,u
L2830               pshs      u
                    ldu       $06,s
                    ldd       $08,s
                    pshs      d
                    pshs      u
                    lbsr      $2EC4
                    leas      $02,s
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       $08,s
                    ldd       $0683,y
                    bne       L2872
                    bra       L285A

L284F               ldd       $0685,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L285A               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L284F
                    bra       L2872

L2868               ldb       ,u+
                    sex
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L2872               ldb       ,u
                    bne       L2868
                    ldd       $0683,y
                    beq       L2895
                    bra       L2889

L287E               ldd       $0685,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
L2889               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L287E
L2895               puls      pc,u
L2897               pshs      u
                    ldd       $066d,y
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L2A83
L28A6               leas      $04,s
                    puls      pc,u
L28AA               pshs      u
                    ldd       $04,s
                    ldx       $066d,y
                    leax      $01,x
                    stx       $066d,y
                    stb       -$01,x
                    puls      pc,u
L28BC               blt       L28F1
                    leas      -$09,y
                    pshu      y,x,dp
                    neg       $0034
                    nega
                    ldu       $04,s
                    leas      -$06,s
                    cmpu      #$0000
                    beq       L28D6
                    ldd       $06,u
                    clra
                    andb      #$03
                    bne       L28DC
L28D6               ldd       #$FFFF
                    lbra      L29FF

L28DC               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L28EF
                    pshs      u
                    lbsr      L2DEB
                    leas      $02,s
                    lbra      L29C5

L28EF               ldd       $06,u
L28F1               anda      #$01
                    clrb
                    std       -$02,s
                    beq       L290E
                    pshs      u
                    lbsr      L2BAC
                    leas      $02,s
                    ldd       $06,u
                    anda      #$FE
                    std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    lbra      L29C3

L290E               ldd       ,u
                    cmpd      $04,u
                    lbcc      L29C5
                    leax      $02,s
                    pshs      x
                    leax      $0e,s
                    lbsr      L314B
                    ldx       $10,s
                    lbra      L2992

L2926               leax      $02,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    pshs      u
                    lbsr      L2A1A
                    leas      $02,s
                    lbsr      L30D2
                    lbsr      L314B
L293F               ldd       $0b,u
                    lbsr      L3132
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    leax      $06,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L295C
                    fcb       $00,$00,$00,$00
L295C               puls      x
                    lbsr      L30E7
                    bge       L296A
                    leax      $06,s
                    lbsr      L310B
                    bra       L296C

L296A               leax      $06,s
L296C               lbsr      L30E7
                    blt       L299F
                    ldd       $04,s
                    addd      ,u
                    std       ,s
                    cmpd      $02,u
                    bcs       L299F
                    ldd       ,s
                    cmpd      $04,u
                    bcc       L299F
                    ldd       ,s
                    std       ,u
                    ldd       $06,u
                    andb      #$EF
                    std       $06,u
                    lbra      L29FD
                    bra       L299F

L2992               stx       -$02,s
                    lbeq      L2926
                    cmpx      #$0001
                    lbeq      L293F
L299F               ldd       $10,s
                    cmpd      #$0001
                    bne       L29C1
                    leax      $0C,s
                    pshs      x
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $04,u
                    subd      ,u
                    lbsr      L3132
                    lbsr      L30D2
                    lbsr      L314B
L29C1               ldd       $04,u
L29C3               std       ,u
L29C5               ldd       $06,u
                    andb      #$EF
                    std       $06,u
                    ldd       $10,s
                    pshs      d
                    leax      $0e,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L341E
                    leas      $08,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    bsr       L29F1
                    fcb       $FF,$FF,$FF,$FF
L29F1               puls      x
                    lbsr      L30E7
                    bne       L29FD
                    ldd       #$FFFF
                    bra       L29FF

L29FD               clra
                    clrb
L29FF               leas      $06,s
                    puls      pc,u
                    pshs      u
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    lbsr      $28C3
                    leas      $08,s
                    puls      pc,u
L2A1A               pshs      u
                    ldu       $04,s
                    beq       L2A27
                    ldd       $06,u
                    clra
                    andb      #$03
                    bne       L2A3A
L2A27               bsr       L2A2D
                    fcb       $FF,$FF,$FF,$FF
L2A2D               puls      x
                    leau      $021C,y
                    pshs      u
                    lbsr      L314B
                    puls      pc,u
L2A3A               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L2A4A
                    pshs      u
                    lbsr      L2DEB
                    leas      $02,s
L2A4A               ldd       #$0001
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L341E
                    leas      $08,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L2A73
                    ldd       $02,u
                    bra       L2A75

L2A73               ldd       $04,u
L2A75               pshs      d
                    ldd       ,u
                    subd      ,s++
                    lbsr      L3132
                    lbsr      L30BD
                    puls      pc,u
L2A83               pshs      u
                    ldu       $06,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$22
                    cmpd      #$8002
                    beq       L2AA7
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    lbne      L2BBD
                    pshs      u
                    lbsr      L2DEB
                    leas      $02,s
L2AA7               ldd       $06,u
                    clra
                    andb      #$04
                    beq       L2AE3
                    ldd       #$0001
                    pshs      d
                    leax      $07,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2AC8
                    leax      L340E,pcr
                    bra       L2ACC

L2AC8               leax      L33F5,pcr
L2ACC               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    leas      $06,s
                    cmpd      #$FFFF
                    bne       L2B24
                    ldd       $06,u
                    orb       #$20
                    std       $06,u
                    lbra      L2BBD

L2AE3               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L2AF3
                    pshs      u
                    lbsr      L2BD8
                    leas      $02,s
L2AF3               ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L2B19
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2B24
                    ldd       $04,s
                    cmpd      #$000D
                    bne       L2B24
L2B19               pshs      u
                    lbsr      L2BD8
                    std       ,s++
                    lbne      L2BBD
L2B24               ldd       $04,s
                    puls      pc,u
L2B28               pshs      u
                    ldu       $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    lbsr      L32A9
                    pshs      d
                    lbsr      L2A83
                    leas      $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      L2A83
                    lbra      L2C92

L2B4B               pshs      u,d
                    leau      $0089,y
                    clra
                    clrb
                    std       ,s
                    bra       L2B61

L2B57               tfr       u,d
                    leau      $0d,u
                    pshs      d
                    bsr       L2B73
                    leas      $02,s
L2B61               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0010
                    blt       L2B57
                    puls      pc,u,x
L2B73               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    cmpu      #$0000
                    beq       L2B83
                    ldd       $06,u
                    bne       L2B88
L2B83               ldd       #$FFFF
                    puls      pc,u,x
L2B88               ldd       $06,u
                    clra
                    andb      #$02
                    beq       L2B97
                    pshs      u
                    bsr       L2BAC
                    leas      $02,s
                    bra       L2B99

L2B97               clra
                    clrb
L2B99               std       ,s
                    ldd       $08,u
                    pshs      d
                    lbsr      L3359
                    leas      $02,s
                    clra
                    clrb
                    std       $06,u
                    ldd       ,s
                    puls      pc,u,x
L2BAC               pshs      u
                    ldu       $04,s
                    beq       L2BBD
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    beq       L2BC2
L2BBD               ldd       #$FFFF
                    puls      pc,u
L2BC2               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L2BD2
                    pshs      u
                    lbsr      L2DEB
                    leas      $02,s
L2BD2               pshs      u
                    bsr       L2BD8
                    puls      pc,u,x
L2BD8               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L2C0A
                    ldd       ,u
                    cmpd      $04,u
                    beq       L2C0A
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      L2A1A
                    leas      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L341E
                    leas      $08,s
L2C0A               ldd       ,u
                    subd      $02,u
                    std       $02,s
                    lbeq      L2C82
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L2C82
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2C59
                    ldd       $02,u
                    bra       L2C51

L2C2A               ldd       $02,s
                    pshs      d
                    ldd       ,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L340E
                    leas      $06,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L2C47
                    leax      $04,s
                    bra       L2C71

L2C47               ldd       $02,s
                    subd      ,s
                    std       $02,s
                    ldd       ,u
                    addd      ,s
L2C51               std       ,u
                    ldd       $02,s
                    bne       L2C2A
                    bra       L2C82

L2C59               ldd       $02,s
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L33F5
                    leas      $06,s
                    cmpd      $02,s
                    beq       L2C82
                    bra       L2C73

L2C71               leas      -$04,x
L2C73               ldd       $06,u
                    orb       #$20
                    std       $06,u
                    ldd       $04,u
                    std       ,u
                    ldd       #$FFFF
                    bra       L2C92

L2C82               ldd       $06,u
                    ora       #$01
                    std       $06,u
                    ldd       $02,u
                    std       ,u
                    addd      $0b,u
                    std       $04,u
                    clra
                    clrb
L2C92               leas      $04,s
                    puls      pc,u
L2C96               pshs      u
                    ldu       $04,s
                    beq       L2CE2
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L2CE2
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L2CBD
                    ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldb       ,x
                    clra
                    bra       L2CC4

L2CBD               pshs      u
                    lbsr      L2D31
                    leas      $02,s
L2CC4               puls      pc,u
                    pshs      u
                    ldu       $06,s
                    beq       L2CE2
                    ldd       $06,u
                    clra
                    andb      #$01
                    beq       L2CE2
                    ldd       $04,s
                    cmpd      #$FFFF
                    beq       L2CE2
                    ldd       ,u
                    cmpd      $02,u
                    bhi       L2CE7
L2CE2               ldd       #$FFFF
                    puls      pc,u
L2CE7               ldd       ,u
                    addd      #$FFFF
                    std       ,u
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       $04,s
                    puls      pc,u
L2CF8               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    pshs      u
                    lbsr      L2C96
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L2D1C
                    pshs      u
                    lbsr      L2C96
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L2D21
L2D1C               ldd       #$FFFF
                    bra       L2D2D

L2D21               ldd       $02,s
                    pshs      d
                    ldd       #$0008
                    lbsr      L32C0
                    addd      ,s
L2D2D               leas      $04,s
                    puls      pc,u
L2D31               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$31
                    cmpd      #$8001
                    beq       L2D5A
                    ldd       $06,u
                    clra
                    andb      #$31
                    cmpd      #$0001
                    beq       L2D53
                    ldd       #$FFFF
                    puls      pc,u,x
L2D53               pshs      u
                    lbsr      L2DEB
                    leas      $02,s
L2D5A               leax      $0089,y
                    pshs      x
                    cmpu      ,s++
                    bne       L2D77
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2D77
                    leax      $0096,y
                    pshs      x
                    lbsr      L2BAC
                    leas      $02,s
L2D77               ldd       $06,u
                    clra
                    andb      #$08
                    beq       L2DA3
                    ldd       $0b,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2D97
                    leax      L33E5,pcr
                    bra       L2D9B

L2D97               leax      L33C4,pcr
L2D9B               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    bra       L2DB5

L2DA3               ldd       #$0001
                    pshs      d
                    leax      $0a,u
                    stx       $02,u
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    lbsr      L33C4
L2DB5               leas      $06,s
                    std       ,s
                    ldd       ,s
                    bgt       L2DD8
                    ldd       $06,u
                    pshs      d
                    ldd       $02,s
                    beq       L2DCA
                    ldd       #$0020
                    bra       L2DCD

L2DCA               ldd       #$0010
L2DCD               ora       ,s+
                    orb       ,s+
                    std       $06,u
                    ldd       #$FFFF
                    puls      pc,u,x
L2DD8               ldd       $02,u
                    addd      #$0001
                    std       ,u
                    ldd       $02,u
                    addd      ,s
                    std       $04,u
                    ldb       [$02,u]
                    clra
                    puls      pc,u,x
L2DEB               pshs      u
                    ldu       $04,s
                    ldd       $06,u
                    clra
                    andb      #$C0
                    bne       L2E23
                    leas      -$20,s
                    leax      ,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      L32DB
                    leas      $06,s
                    ldd       $06,u
                    pshs      d
                    ldb       $02,s
                    bne       L2E17
                    ldd       #$0040
                    bra       L2E1A

L2E17               ldd       #$0080
L2E1A               ora       ,s+
                    orb       ,s+
                    std       $06,u
                    leas      $20,s
L2E23               ldd       $06,u
                    ora       #$80
                    std       $06,u
                    clra
                    andb      #$0C
                    beq       L2E30
                    puls      pc,u
L2E30               ldd       $0b,u
                    bne       L2E45
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2E40
                    ldd       #$0080
                    bra       L2E43

L2E40               ldd       #$0100
L2E43               std       $0b,u
L2E45               ldd       $02,u
                    bne       L2E5A
                    ldd       $0b,u
                    pshs      d
                    lbsr      L350E
                    leas      $02,s
                    std       $02,u
                    cmpd      #$FFFF
                    beq       L2E62
L2E5A               ldd       $06,u
                    orb       #$08
                    std       $06,u
                    bra       L2E71

L2E62               ldd       $06,u
                    orb       #$04
                    std       $06,u
                    leax      $0a,u
                    stx       $02,u
                    ldd       #$0001
                    std       $0b,u
L2E71               ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
                    puls      pc,u
L2E7B               pshs      u
                    ldb       $05,s
                    sex
                    tfr       d,x
                    bra       L2EA1

L2E84               ldd       [$06,s]
                    addd      #$0004
                    std       [$06,s]
                    leax      >L2EB8,pcr
                    bra       L2E9D

L2E93               ldb       $05,s
                    stb       $0087,y
                    leax      $0086,y
L2E9D               tfr       x,d
                    puls      pc,u
L2EA1               cmpx      #$0064
                    beq       L2E84
                    cmpx      #$006F
                    lbeq      L2E84
                    cmpx      #$0078
                    lbeq      L2E84
                    bra       L2E93
                    puls      pc,u
L2EB8               neg       $0034
                    nega
                    leax      >L2EC3,pcr
                    tfr       x,d
                    puls      pc,u
L2EC3               neg       $0034
                    nega
                    ldu       $04,s
L2EC8               ldb       ,u+
                    bne       L2EC8
                    tfr       u,d
                    subd      $04,s
                    addd      #$FFFF
                    puls      pc,u
L2ED5               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L2EDF               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L2EDF
                    ldd       $06,s
                    puls      pc,u,x
                    pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L2EF9               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L2EF9
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L2F0A               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L2F0A
                    ldd       $06,s
                    puls      pc,u,x
L2F1A               pshs      u
                    ldu       $04,s
                    bra       L2F30

L2F20               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       L2F2E
                    clra
                    clrb
                    puls      pc,u
L2F2E               leau      $01,u
L2F30               ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       L2F20
                    ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
                    puls      pc,u
L2F4B               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L2F55               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       L2F79
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L2F55
                    bra       L2F79

L2F6F               clra
                    clrb
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L2F79               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    bgt       L2F6F
                    ldd       $06,s
                    puls      pc,u,x
                    pshs      u
                    ldu       $04,s
                    bra       L2F9F

L2F8F               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       L2F9D
                    clra
                    clrb
                    puls      pc,u
L2F9D               leau      $01,u
L2F9F               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    ble       L2FB9
                    ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    beq       L2F8F
L2FB9               ldd       $08,s
                    bge       L2FC1
                    clra
                    clrb
                    bra       L2FCC

L2FC1               ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
L2FCC               puls      pc,u
                    pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L2FD8               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L2FD8
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L2FE9               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       L3001
                    ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L2FE9
L3001               ldd       $0a,s
                    bge       L3009
                    clra
                    clrb
                    stb       [,s]
L3009               ldd       $06,s
                    puls      pc,u,x
                    pshs      u
                    ldu       $04,s
L3011               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    stb       ,u+
                    bgt       L3011
                    ldb       -$01,u
                    clra
                    andb      #$7f
                    stb       -$01,u
                    clra
                    clrb
                    stb       ,u
                    ldd       $04,s
                    puls      pc,u
L302C               pshs      u
                    ldu       $04,s
                    leas      -$05,s
                    clra
                    clrb
                    std       $01,s
L3036               ldb       ,u+
                    stb       ,s
                    cmpb      #$20
                    beq       L3036
                    ldb       ,s
                    cmpb      #$09
                    lbeq      L3036
                    ldb       ,s
                    cmpb      #$2d
                    bne       L3051
                    ldd       #$0001
                    bra       L3053

L3051               clra
                    clrb
L3053               std       $03,s
                    ldb       ,s
                    cmpb      #$2d
                    beq       L3079
                    ldb       ,s
                    cmpb      #$2b
                    bne       L307D
                    bra       L3079

L3063               ldd       $01,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L317F
                    pshs      d
                    ldb       $02,s
                    sex
                    addd      ,s++
                    addd      #$FFD0
                    std       $01,s
L3079               ldb       ,u+
                    stb       ,s
L307D               ldb       ,s
                    sex
                    leax      $015a,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L3063
                    ldd       $03,s
                    beq       L3099
                    ldd       $01,s
                    nega
                    negb
                    sbca      #$00
                    bra       L309B

L3099               ldd       $01,s
L309B               leas      $05,s
                    puls      pc,u
L309F               pshs      u
                    ldu       $04,s
                    bra       L30AF

L30A5               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    stb       ,u+
L30AF               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    bgt       L30A5
                    puls      pc,u
L30BD               ldd       $04,s
                    addd      $02,x
                    std       $021e,y
                    ldd       $02,s
                    adcb      $01,x
                    adca      ,x
                    std       $021C,y
                    lbra      L3161

L30D2               ldd       $04,s
                    subd      $02,x
                    std       $021e,y
                    ldd       $02,s
                    sbcb      $01,x
                    sbca      ,x
                    std       $021C,y
                    lbra      L3161

L30E7               ldd       $02,s
                    cmpd      ,x
                    bne       L3100
                    ldd       $04,s
                    cmpd      $02,x
                    beq       L3100
                    bcs       L30FD
                    lda       #$01
                    andcc     #$FE
                    bra       L3100

L30FD               clra
                    cmpa      #$01
L3100               pshs      cc
                    ldd       $01,s
                    std       $05,s
                    puls      cc
                    leas      $04,s
                    rts

L310B               lbsr      L3170
                    ldd       #$0000
                    subd      $02,x
                    std       $02,x
                    ldd       #$0000
                    sbcb      $01,x
                    sbca      ,x
                    std       ,x
                    rts
                    ldd       ,x
                    coma
                    comb
                    std       $021C,y
                    ldd       $02,x
                    coma
                    comb
                    leax      $021C,y
                    std       $02,x
                    rts

L3132               leax      $021C,y
                    std       $02,x
                    tfr       a,b
                    sex
                    tfr       a,b
                    std       ,x
                    rts

L3140               leax      $021C,y
                    std       $02,x
                    clr       ,x
                    clr       $01,x
                    rts

L314B               pshs      y
                    ldy       $04,s
                    ldd       ,x
                    std       ,y
                    ldd       $02,x
                    std       $02,y
                    puls      x
                    exg       y,x
                    puls      d
                    std       ,s
                    rts

L3161               tfr       cc,a
                    puls      x
                    stx       $02,s
                    leas      $02,s
                    leax      $021C,y
                    tfr       a,cc
                    rts

L3170               ldd       ,x
                    std       $021C,y
                    ldd       $02,x
                    leax      $021C,y
                    std       $02,x
                    rts

L317F               tsta
                    bne       L3194
                    tst       $02,s
                    bne       L3194
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,d
L3194               pshs      d
                    ldd       #$0000
                    pshs      d
                    pshs      d
                    lda       $05,s
                    ldb       $09,s
                    mul
                    std       $02,s
                    lda       $05,s
                    ldb       $08,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L31B1
                    inc       ,s
L31B1               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L31BE
                    inc       ,s
L31BE               lda       $04,s
                    ldb       $08,s
                    mul
                    addd      ,s
                    std       ,s
                    ldx       $06,s
                    stx       $08,s
                    ldx       ,s
                    ldd       $02,s
                    leas      $08,s
                    rts

L31D2               clr       $0687,y
                    leax      >L321A,pcr
                    stx       $0688,y
                    bra       L31F4
                    leax      >L3233,pcr
                    stx       $0688,y
                    clr       $0687,y
                    tst       $02,s
                    bpl       L31F4
                    inc       $0687,y
L31F4               subd      #$0000
                    bne       L31FF
                    puls      x
                    ldd       ,s++
                    jmp       ,x

L31FF               ldx       $02,s
                    pshs      x
                    jsr       [$0688,y]
                    ldd       ,s
                    std       $02,s
                    tfr       x,d
                    tst       $0687,y
                    beq       L3217
                    nega
                    negb
                    sbca      #$00
L3217               std       ,s++
                    rts

L321A               subd      #$0000
                    beq       L3229
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    bra       L3257

L3229               puls      d
                    std       ,s
                    ldd       #$002D
                    lbra      L32CC

L3233               subd      #$0000
                    beq       L3229
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    tsta
                    bpl       L324B
                    nega
                    negb
                    sbca      #$00
                    inc       $01,s
                    std       $02,s
L324B               ldd       $06,s
                    bpl       L3257
                    nega
                    negb
                    sbca      #$00
                    com       $01,s
                    std       $06,s
L3257               lda       #$01
L3259               inca
                    asl       $03,s
                    rol       $02,s
                    bpl       L3259
                    sta       ,s
                    ldd       $06,s
                    clr       $06,s
                    clr       $07,s
L3268               subd      $02,s
                    bcc       L3272
                    addd      $02,s
                    andcc     #$FE
                    bra       L3274

L3272               orcc      #$01
L3274               rol       $07,s
                    rol       $06,s
                    lsr       $02,s
                    ror       $03,s
                    dec       ,s
                    bne       L3268
                    std       $02,s
                    tst       $01,s
                    beq       L328E
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
L328E               ldx       $04,s
                    ldd       $06,s
                    std       $04,s
                    stx       $06,s
                    ldx       $02,s
                    ldd       $04,s
                    leas      $06,s
                    rts

L329D               tstb
                    beq       L32B3
L32A0               asr       $02,s
                    ror       $03,s
                    decb
                    bne       L32A0
                    bra       L32B3

L32A9               tstb
                    beq       L32B3
L32AC               lsr       $02,s
                    ror       $03,s
                    decb
                    bne       L32AC
L32B3               ldd       $02,s
                    pshs      d
                    ldd       $02,s
                    std       $04,s
                    ldd       ,s
                    leas      $04,s
                    rts

L32C0               tstb
                    beq       L32B3
L32C3               asl       $03,s
                    rol       $02,s
                    decb
                    bne       L32C3
                    bra       L32B3

L32CC               std       $0228,y
                    pshs      y,b
                    os9       F$ID
                    puls      y,b
                    os9       F$Send
                    rts

L32DB               lda       $05,s
                    ldb       $03,s
                    beq       L330E
                    cmpb      #$01
                    beq       L3310
                    cmpb      #$06
                    beq       L3310
                    cmpb      #$02
                    beq       L32F6
                    cmpb      #$05
                    beq       L32F6
                    ldb       #$D0
                    lbra      L355D

L32F6               pshs      u
                    os9       I$GetStt
                    bcc       L3302
                    puls      u
                    lbra      L355D

L3302               stx       [$08,s]
                    ldx       $08,s
                    stu       $02,x
                    puls      u
                    clra
                    clrb
                    rts

L330E               ldx       $06,s
L3310               os9       I$GetStt
                    lbra      L3566
                    lda       $05,s
                    ldb       $03,s
                    beq       L3325
                    cmpb      #$02
                    beq       L332D
                    ldb       #$D0
                    lbra      L355D

L3325               ldx       $06,s
                    os9       I$SetStt
                    lbra      L3566

L332D               pshs      u
                    ldx       $08,s
                    ldu       $0a,s
                    os9       I$SetStt
                    puls      u
                    lbra      L3566
                    ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    bcs       L3347
                    os9       I$Close
L3347               lbra      L3566

L334A               ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    lbcs      L355D
                    tfr       a,b
                    clra
                    rts

L3359               lda       $03,s
                    os9       I$Close
                    lbra      L3566
                    ldx       $02,s
                    ldb       $05,s
                    os9       I$MakDir
                    lbra      L3566

L336B               ldx       $02,s
                    ldb       $05,s
                    tfr       b,a
                    anda      #$07
                    os9       I$Create
                    bcs       L337C
L3378               tfr       a,b
                    clra
                    rts

L337C               cmpb      #$DA
                    lbne      L355D
                    lda       $05,s
                    bita      #$80
                    lbne      L355D
                    anda      #$07
                    ldx       $02,s
                    os9       I$Open
                    lbcs      L355D
                    pshs      u,a
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      u,a
                    bcc       L3378
                    pshs      b
                    os9       I$Close
                    puls      b
                    lbra      L355D

L33AF               ldx       $02,s
                    os9       I$Delete
                    lbra      L3566
                    lda       $03,s
                    os9       I$Dup
                    lbcs      L355D
                    tfr       a,b
                    clra
                    rts

L33C4               pshs      y
                    ldx       $06,s
                    lda       $05,s
                    ldy       $08,s
                    pshs      y
                    os9       I$Read
L33D2               bcc       L33E1
                    cmpb      #$D3
                    bne       L33DC
                    clra
                    clrb
                    puls      pc,y,x
L33DC               puls      y,x
                    lbra      L355D

L33E1               tfr       y,d
                    puls      pc,y,x
L33E5               pshs      y
                    lda       $05,s
                    ldx       $06,s
                    ldy       $08,s
                    pshs      y
                    os9       I$ReadLn
                    bra       L33D2

L33F5               pshs      y
                    ldy       $08,s
                    beq       L340A
                    lda       $05,s
                    ldx       $06,s
                    os9       I$Write
L3403               bcc       L340A
                    puls      y
                    lbra      L355D

L340A               tfr       y,d
                    puls      pc,y
L340E               pshs      y
                    ldy       $08,s
                    beq       L340A
                    lda       $05,s
                    ldx       $06,s
                    os9       I$WritLn
                    bra       L3403

L341E               pshs      u
                    ldd       $0a,s
                    bne       L342C
                    ldu       #$0000
                    ldx       #$0000
                    bra       L3460

L342C               cmpd      #$0001
                    beq       L3457
                    cmpd      #$0002
                    beq       L344C
                    ldb       #$F7
L343A               clra
                    std       $0228,y
                    ldd       #$FFFF
                    leax      $021C,y
                    std       ,x
                    std       $02,x
                    puls      pc,u
L344C               lda       $05,s
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L343A
                    bra       L3460

L3457               lda       $05,s
                    ldb       #$05
                    os9       I$GetStt
                    bcs       L343A
L3460               tfr       u,d
                    addd      $08,s
                    std       $021e,y
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       L343A
                    tfr       d,x
                    std       $021C,y
                    lda       $05,s
                    os9       I$Seek
                    bcs       L343A
                    leax      $021C,y
                    puls      pc,u
                    rts
                    ldx       #$0000
                    clrb
                    os9       F$Sleep
                    lbra      L355D
                    rts

L3491               pshs      u,y
                    ldx       $06,s
                    ldy       $08,s
                    ldu       $0a,s
                    os9       F$CRC
                    puls      pc,u,y
                    lda       $03,s
                    ldb       $05,s
                    os9       F$Perr
                    lbcs      L355D
                    rts
                    ldx       $02,s
                    os9       F$Sleep
                    lbcs      L355D
                    tfr       x,d
                    rts

L34B7               ldd       $021a,y
                    pshs      d
                    ldd       $04,s
                    cmpd      $068a,y
                    bcs       L34EB
                    addd      $021a,y
                    pshs      y
                    subd      ,s
                    os9       F$Mem
                    tfr       y,d
                    puls      y
                    bcc       L34DD
                    ldd       #$FFFF
                    leas      $02,s
                    rts

L34DD               std       $021a,y
                    addd      $068a,y
                    subd      ,s
                    std       $068a,y
L34EB               leas      $02,s
                    ldd       $068a,y
                    pshs      d
                    subd      $04,s
                    std       $068a,y
                    ldd       $021a,y
                    subd      ,s++
                    pshs      d
                    clra
                    ldx       ,s
L3504               sta       ,x+
                    cmpx      $021a,y
                    bcs       L3504
                    puls      pc,d
L350E               ldd       $02,s
                    addd      $0224,y
                    bcs       L3537
                    cmpd      $0226,y
                    bcc       L3537
                    pshs      d
                    ldx       $0224,y
                    clra
L3524               cmpx      ,s
                    bcc       L352C
                    sta       ,x+
                    bra       L3524

L352C               ldd       $0224,y
                    puls      x
                    stx       $0224,y
                    rts

L3537               ldd       #$FFFF
                    rts

L353B               pshs      u
                    tfr       y,u
                    ldx       $04,s
                    stx       $068C,y
                    leax      >L3551,pcr
                    os9       F$Icpt
                    puls      u
                    lbra      L3566

L3551               tfr       u,y
                    clra
                    pshs      d
                    jsr       [$068C,y]
                    leas      $02,s
                    rti

L355D               clra
                    std       $0228,y
                    ldd       #$FFFF
                    rts

L3566               bcs       L355D
                    clra
                    clrb
                    rts

L356B               lbsr      L3576
                    lbsr      L2B4B
L3571               ldd       $02,s
                    os9       F$Exit
L3576               rts
* ------------------------------------------------------------------
* L3577 - cc1-style init image for the work block (see _start):
* rts stub + count/block table + relocation dirs + module-name string.
* ------------------------------------------------------------------
L3577               fcb       $00,$0A,$00,$00,$00,$04,$00,$FF,$FF,$FF,$02
                    fcb       $77
                    fcb       $01
                    fcb       $7A
                    fcb       $00
                    fcb       $60
                    fcb       $00
                    fcb       $60
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0D,$C1,$0D,$C7,$0D,$CD,$0D,$D1,$0D,$D7,$02
                    fcc       /w'/
                    fcb       $10,$03,$E8,$00
                    fcb       $64
                    fcb       $00,$0A,$00,$84
                    fcc       /lx/
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $42
                    fcb       $00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$11,$11,$01,$11,$11,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
                    fcc       /0               HHHHH/
                    fcc       /HHHHH       BBBBBB/
                    fcb       $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
                    fcc       /      DDDDDD/
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04
                    fcc       /    /
                    fcb       $01,$00,$05,$00
                    fcb       $78
                    fcb       $00
                    fcb       $76
                    fcb       $00
                    fcb       $74
                    fcb       $00
                    fcb       $72
                    fcb       $00
                    fcb       $70
                    fcb       $00,$05,$00
                    fcb       $62
                    fcb       $00
                    fcb       $60
                    fcb       $00
                    fcb       $7A
                    fcb       $00,$08,$00,$84
                    fcc       /c.link/
                    fcb       $00

                    emod
eom                 equ       *
                    end
