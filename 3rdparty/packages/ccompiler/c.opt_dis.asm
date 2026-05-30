                    nam       c.opt
                    ttl       program module

                    use       defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $04

                    mod       eom,name,tylg,atrv,_start,size

u0000               rmb       5127
size                equ       .

name                equ       *
                    fcs       /c.opt/
                    fcb       edition

copybytes           lda       ,y+
L0015               sta       ,u+
L0017               leax      -$01,x
L0019               bne       copybytes
L001B               rts

_start              pshs      y
L001E               pshs      u
L0020               clra
L0021               clrb
L0022               sta       ,u+
L0024               decb
                    bne       L0022
                    ldx       ,s
                    leau      ,x
L002B               leax      $0887,x
L002F               pshs      x
L0031               leay      L27DC,pcr
L0035               ldx       ,y++
L0037               beq       L003D
L0039               bsr       copybytes
L003B               ldu       $02,s
L003D               leau      >$0023,u
L0041               ldx       ,y++
L0043               beq       L0048
L0045               bsr       copybytes
L0047               clra
L0048               cmpu      ,s
L004B               beq       L0051
L004D               sta       ,u+
L004F               bra       L0048

L0051               ldu       $02,s
L0053               ldd       ,y++
                    beq       L005E
L0057               leax      >$0000,pcr
L005B               lbsr      L0161
L005E               ldd       ,y++
L0060               beq       L0067
L0062               leax      ,u
L0064               lbsr      L0161
L0067               leas      $04,s
L0069               puls      x
                    stx       $0555,u
L006F               sty       $0515,u
L0074               ldd       #$0001
L0077               std       $0551,u
                    leay      $0517,u
                    leax      ,s
                    lda       ,x+
L0083               ldb       $0552,u
                    cmpb      #$1d
                    beq       L00DF
L008B               cmpa      #$0d
                    beq       L00DF
L008F               cmpa      #$20
                    beq       L0097
                    cmpa      #$2C
                    bne       L009B
L0097               lda       ,x+
L0099               bra       L008B

L009B               cmpa      #$22
                    beq       L00A3
                    cmpa      #$27
                    bne       L00C1
L00A3               stx       ,y++
                    inc       $0552,u
                    pshs      a
L00AB               lda       ,x+
                    cmpa      #$0d
L00AF               beq       L00B5
                    cmpa      ,s
L00B3               bne       L00AB
L00B5               puls      b
L00B7               clr       -$01,x
                    cmpa      #$0d
L00BB               beq       L00DF
                    lda       ,x+
L00BF               bra       L0083

L00C1               leax      -$01,x
L00C3               stx       ,y++
                    leax      $01,x
L00C7               inc       $0552,u
L00CB               cmpa      #$0d
                    beq       L00DB
                    cmpa      #$20
                    beq       L00DB
                    cmpa      #$2C
L00D5               beq       L00DB
                    lda       ,x+
                    bra       L00CB

L00DB               clr       -$01,x
                    bra       L0083

L00DF               leax      $0515,u
                    pshs      x
                    ldd       $0551,u
L00E9               pshs      d
                    leay      ,u
L00ED               bsr       stkinit
                    lbsr      main
                    clr       ,-s
L00F4               clr       ,-s
                    lbsr      exit
stkinit             leax      $0887,y
                    stx       $055f,y
                    sts       $0553,y
                    sts       $0561,y
                    ldd       #$FF82
                    leax      d,s
                    cmpx      $0561,y
                    bcc       L0120
                    cmpx      $055f,y
                    bcs       L013A
                    stx       $0561,y
L0120               rts

L0121               bpl       $014D
                    bpl       L014F
                    bra       L017A
                    lsrb
                    fcb       $41
                    coma
                    fcb       $4B
                    bra       $017C
                    rorb
                    fcb       $45,$52
                    rora
                    inca
                    clra
                    asrb
                    bra       L0160
                    bpl       $0162
                    bpl       L0147
L013A               leax      L0121,pcr
                    ldb       #$CF
                    pshs      b
                    lda       #$02
                    ldy       #$0064
L0147               os9       I$WritLn
                    clr       ,-s
                    lbsr      L27D6
L014F               ldd       $0553,y
                    subd      $0561,y
                    rts
                    ldd       $0561,y
                    subd      $055f,y
L0160               rts

L0161               pshs      x
                    leax      d,y
                    leax      d,x
                    pshs      x
L0169               ldd       ,y++
                    leax      d,u
                    ldd       ,x
                    addd      $02,s
                    std       ,x
                    cmpy      ,s
                    bne       L0169
L0178               leas      $04,s
L017A               rts

main                pshs      u
                    leas      -$08,s
                    leax      $0445,y
                    stx       $0565,y
                    leax      $0452,y
                    stx       $0567,y
                    clra
                    clrb
                    std       ,s
L0193               std       $02,s
                    lbra      L0243

L0198               ldd       [$0e,s]
                    std       $04,s
                    tfr       d,x
                    ldb       ,x
                    cmpb      #$2d
                    lbne      L0225
                    ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    ldb       ,x
                    sex
                    tfr       d,x
                    lbra      L0216

L01B5               ldd       #$0001
L01B8               std       $0007
                    lbra      L0243

L01BD               clra
                    clrb
                    std       >$0025,y
                    ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    ldb       ,x
                    cmpb      #$3d
                    beq       L01F1
                    ldd       $04,s
                    addd      #$FFFF
                    std       $04,s
                    bra       L01F1

L01D8               ldd       >$0025,y
                    pshs      d
                    ldd       #$000A
                    lbsr      L247E
                    pshs      d
                    ldd       $08,s
                    addd      #$FFD0
                    addd      ,s++
                    std       >$0025,y
L01F1               ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    ldb       ,x
                    sex
                    std       $06,s
L01FC               bne       L01D8
                    bra       L0243

L0200               ldd       $04,s
                    addd      #$FFFF
                    std       $04,s
                    pshs      d
                    leax      L069F,pcr
                    pshs      x
                    lbsr      L1814
                    leas      $04,s
                    bra       L0243

L0216               stx       -$02,s
                    lbeq      L01B5
                    cmpx      #$0069
                    lbeq      L01BD
                    bra       L0200

L0225               ldd       $02,s
                    bne       L022E
                    ldd       $04,s
                    lbra      L0193

L022E               ldd       ,s
                    bne       L0238
                    ldd       $04,s
                    std       ,s
                    bra       L0243

L0238               leax      L06B4,pcr
                    pshs      x
                    lbsr      L1814
                    leas      $02,s
L0243               ldd       $0e,s
                    addd      #$0002
                    std       $0e,s
                    ldd       $0C,s
                    addd      #$FFFF
                    std       $0C,s
                    lbne      L0198
                    ldd       $02,s
                    beq       L0283
                    leax      $0445,y
                    pshs      x
                    leax      L06C3,pcr
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    lbsr      L19F9
L026C               leas      $06,s
                    std       $0565,y
                    bne       L0283
                    ldd       $02,s
                    pshs      d
                    leax      L06C5,pcr
                    pshs      x
                    lbsr      L1814
                    leas      $04,s
L0283               ldd       ,s
                    beq       L02AB
                    leax      L06D3,pcr
                    pshs      x
                    ldd       $02,s
                    pshs      d
                    lbsr      L19DA
                    leas      $04,s
                    std       $0567,y
                    bne       L02AB
                    ldd       ,s
                    pshs      d
                    leax      L06D5,pcr
                    pshs      x
                    lbsr      L1814
                    leas      $04,s
L02AB               ldd       $0567,y
                    std       $0569,y
                    lbsr      L091F
                    lbsr      L0A7C
                    lbsr      L10E2
                    lbsr      L03C0
                    ldd       $0007
                    lbeq      L037E
                    leas      -$04,s
                    leax      L06E3,pcr
                    pshs      x
                    leax      $045f,y
                    pshs      x
                    lbsr      fprintf
                    leas      $04,s
                    ldd       $0009
                    pshs      d
                    leax      L06F0,pcr
                    pshs      x
L02E2               leax      $045f,y
                    pshs      x
                    lbsr      fprintf
                    leas      $06,s
                    ldd       L0019
                    pshs      d
                    ldd       L001B
                    pshs      d
                    lbsr      L03A0
                    leas      $04,s
L02FA               pshs      d
                    ldd       L001B
                    pshs      d
                    ldd       L0019
                    pshs      d
                    leax      L070A,pcr
                    pshs      x
                    leax      $045f,y
                    pshs      x
                    lbsr      fprintf
                    leas      $0a,s
                    ldd       $0009
                    pshs      d
                    ldd       L0021
                    pshs      d
                    lbsr      L03A0
                    leas      $04,s
                    pshs      d
                    ldd       L0021
                    pshs      d
                    leax      L072D,pcr
                    pshs      x
                    leax      $045f,y
                    pshs      x
                    lbsr      fprintf
                    leas      $08,s
                    ldd       L001B
                    aslb
                    rola
                    std       ,s
                    pshs      d
                    ldd       L0021
                    pshs      d
                    bsr       L0382
                    leas      $02,s
                    addd      ,s++
                    std       ,s
                    ldd       $0009
                    pshs      d
                    bsr       L0382
                    leas      $02,s
                    std       $02,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    bsr       L03A0
                    leas      $04,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    leax      L0752,pcr
                    pshs      x
                    leax      $045f,y
                    pshs      x
                    lbsr      fprintf
                    leas      $0a,s
                    leas      $04,s
L037E               leas      $08,s
                    puls      pc,u
L0382               pshs      u
                    ldd       $04,s
                    addd      $04,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    ldd       #$0003
                    lbsr      L247E
                    pshs      d
                    ldd       #$0005
                    lbsr      L24EA
                    addd      ,s++
                    puls      pc,u
L03A0               pshs      u
                    ldd       $06,s
                    beq       L03BC
                    ldd       $04,s
                    pshs      d
                    ldd       $08,s
                    addd      #$0032
                    pshs      d
                    ldd       #$0064
                    lbsr      L24D1
                    lbsr      L24D1
                    bra       L03BE

L03BC               clra
                    clrb
L03BE               puls      pc,u
L03C0               pshs      u
                    leas      $FF1C,s
                    clra
                    clrb
                    std       $0C,s
                    clra
                    clrb
                    std       $000F
                    std       $000D
                    clra
                    clrb
                    std       $000B
                    lbra      L0625

L03D7               leau      $0080,s
                    bra       L03DF

L03DD               leau      $01,u
L03DF               ldb       ,u
                    cmpb      #$0d
                    bne       L03DD
                    clra
                    clrb
                    stb       ,u
                    ldd       $000B
                    addd      #$0001
                    std       $000B
                    leax      $0080,s
                    stx       $06,s
                    ldb       [$06,s]
                    lbeq      L0625
                    ldb       [$06,s]
                    cmpb      #$2a
                    lbeq      L0625
                    leax      ,s
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    leax      $78,s
                    pshs      x
                    ldd       #$0001
                    pshs      d
                    lbsr      L07AD
                    leas      $08,s
                    std       $06,s
                    pshs      d
                    leax      $6b,s
                    pshs      x
                    ldd       #$0002
                    pshs      d
                    lbsr      L07AD
                    leas      $06,s
                    bra       L0437

L0432               ldd       $06,s
                    addd      #$0001
L0437               std       $06,s
                    ldb       [$06,s]
                    cmpb      #$20
                    beq       L0432
                    ldb       [$06,s]
                    cmpb      #$09
                    lbeq      L0432
                    ldb       $69,s
                    sex
                    tfr       d,x
                    lbra      L0542

L0452               leax      L0775,pcr
                    pshs      x
                    leax      $6b,s
                    pshs      x
                    lbsr      L244D
                    leas      $04,s
                    std       -$02,s
                    lbne      L056C
                    lbsr      L0671
                    ldd       #$0001
L046E               std       $000F
                    lbra      L0625

L0473               leax      L077D,pcr
                    pshs      x
                    leax      $6b,s
                    pshs      x
                    lbsr      L244D
                    leas      $04,s
                    std       -$02,s
                    lbeq      L053B
                    lbra      L056C

L048C               leax      L0782,pcr
                    pshs      x
                    leax      $6b,s
                    pshs      x
                    lbsr      L244D
                    leas      $04,s
                    std       -$02,s
                    lbne      L056C
                    bra       L04A8

L04A4               leas      $FF1C,x
L04A8               leax      $0080,s
                    pshs      x
                    leax      L0786,pcr
                    pshs      x
                    ldd       $0567,y
L04B8               pshs      d
                    lbsr      fprintf
                    leas      $06,s
                    lbra      L0625

L04C2               leax      L078A,pcr
                    pshs      x
                    leax      $6b,s
                    pshs      x
                    lbsr      L244D
                    leas      $04,s
                    std       -$02,s
                    lbne      L056C
                    lbsr      L0671
                    lbra      L053B

L04DE               leax      L0790,pcr
                    pshs      x
                    leax      $6b,s
                    pshs      x
                    lbsr      L244D
                    leas      $04,s
                    std       -$02,s
                    beq       L053B
                    lbra      L056C

L04F5               leax      L0794,pcr
L04F9               pshs      x
                    leax      $6b,s
                    pshs      x
                    lbsr      L244D
                    leas      $04,s
                    std       -$02,s
                    lbne      L056C
                    ldb       [$06,s]
                    cmpb      #$64
                    bne       L051F
                    ldx       $06,s
                    ldb       $01,x
                    cmpb      #$70
                    bne       L051F
                    ldd       #$0002
                    bra       L0522

L051F               ldd       #$0001
L0522               std       $02,s
                    ldd       $000D
                    cmpd      $02,s
                    bne       L0534
                    ldd       $000F
                    beq       L0534
                    clra
                    clrb
                    lbra      L046E

L0534               lbsr      L0671
                    ldd       $02,s
                    std       $000D
L053B               leax      $00E4,s
                    lbra      L04A4

L0542               cmpx      #$0065
                    lbeq      L0452
                    cmpx      #$0069
                    lbeq      L0473
                    cmpx      #$006E
                    lbeq      L048C
                    cmpx      #$0070
                    lbeq      L04C2
                    cmpx      #$0074
                    lbeq      L04DE
                    cmpx      #$0076
                    lbeq      L04F5
L056C               lbsr      L0671
                    ldd       $000D
                    beq       L0586
                    leax      $0080,s
                    pshs      x
                    leax      L079A,pcr
                    pshs      x
                    ldd       $0569,y
                    lbra      L04B8

L0586               ldb       $74,s
                    beq       L05CB
                    leax      $74,s
                    pshs      x
                    lbsr      L0988
                    leas      $02,s
                    std       $0a,s
                    bne       L05A5
                    leax      $74,s
                    pshs      x
                    lbsr      L0946
                    leas      $02,s
                    std       $0a,s
L05A5               ldd       ,s
                    beq       L05B1
                    ldx       $0a,s
                    ldd       $0a,x
                    orb       #$01
                    std       $0a,x
L05B1               ldd       $0a,s
                    bra       L05B9

L05B5               ldx       $08,s
                    ldd       $08,x
L05B9               std       $08,s
                    ldx       $08,s
                    ldd       $08,x
                    bne       L05B5
                    ldd       $0C,s
                    ldx       $08,s
                    std       $08,x
                    ldd       $0a,s
                    std       $0C,s
L05CB               ldb       $69,s
                    beq       L0625
                    ldd       $06,s
                    pshs      d
                    leax      $10,s
                    pshs      x
                    ldd       #$0003
                    pshs      d
                    lbsr      L07AD
                    leas      $06,s
                    leax      $0C,s
                    pshs      x
                    leax      $10,s
                    pshs      x
                    leax      $6d,s
                    pshs      x
                    leax      >$0015,y
                    pshs      x
                    lbsr      L0A92
                    leas      $08,s
                    std       -$02,s
                    beq       L0612
                    ldd       L0017
                    pshs      d
                    lbsr      L110E
                    leas      $02,s
                    ldd       L0017
                    pshs      d
                    lbsr      L13F5
                    leas      $02,s
L0612               ldd       $0009
                    addd      #$0001
                    std       $0009
                    ldd       copybytes
                    cmpd      >$0025,y
                    blt       L0625
                    lbsr      L0D20
L0625               ldd       $0565,y
                    pshs      d
                    ldd       #$0064
                    pshs      d
                    leax      $0084,s
                    pshs      x
                    lbsr      L1A65
                    leas      $06,s
                    std       -$02,s
                    lbne      L03D7
                    ldd       $0C,s
                    beq       L0660
                    leax      $0C,s
                    pshs      x
                    leax      L07A2,pcr
                    pshs      x
                    leax      L079E,pcr
                    pshs      x
                    leax      >$0015,y
                    pshs      x
                    lbsr      L0A92
                    leas      $08,s
L0660               bsr       L0671
                    bra       L0667

L0664               lbsr      L0D20
L0667               ldd       copybytes
                    bne       L0664
                    leas      $00E4,s
                    puls      pc,u
L0671               pshs      u
                    ldd       $000F
                    beq       L069D
                    ldd       $000D
                    beq       L0684
                    clra
                    clrb
                    std       $000D
                    bra       L0688

L0681               lbsr      L0D20
L0684               ldd       copybytes
                    bne       L0681
L0688               leax      L07A3,pcr
                    pshs      x
                    ldd       $0567,y
                    pshs      d
                    lbsr      fprintf
                    leas      $04,s
                    clra
                    clrb
                    std       $000F
L069D               puls      pc,u
L069F               fcc       /unknown option '%s'/
                    fcb       $0D,$00
L06B4               fcc       /too many files/
                    fcb       $00
L06C3               fcb       $72
                    fcb       $00
L06C5               fcc       /can't open %s/
                    fcb       $00
L06D3               fcb       $77
                    fcb       $00
L06D5               fcc       /can't open %s/
                    fcb       $00
L06E3               fcc       /statistics:/
                    fcb       $0D,$00
L06F0               rol       L0074
                    fcc       /otal instructions : %d/
                    fcb       $0D,$00
L070A               rol       $006C
                    fcc       /ong branches :  %5d, %5d, %3d%%/
                    fcb       $0D,$00
L072D               rol       $0072
                    fcc       /emoved       :         %5d, %3d%%/
                    fcb       $0D,$00
L0752               rol       L0074
                    fcc       /otal bytes   :  %5d, %5d, %3d%%/
                    fcb       $0D,$00
L0775               fcc       /endsect/
                    fcb       $00
L077D               fcc       /info/
                    fcb       $00
L0782               fcb       $6E,$61,$6D
                    fcb       $00
L0786               fcb       $25,$73
                    fcb       $0D,$00
L078A               fcc       /psect/
                    fcb       $00
L0790               fcb       $74,$74,$6C
                    fcb       $00
L0794               fcc       /vsect/
                    fcb       $00
L079A               fcb       $25,$73
                    fcb       $0D,$00
L079E               fcb       $6E,$6F,$70
                    fcb       $00
L07A2               fcb       $00
L07A3               fcc       / endsect/
                    fcb       $0D,$00
L07AD               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldx       $06,s
                    lbra      L08DE

L07B8               ldd       #$000B
                    std       ,s
                    ldb       [$0a,s]
                    cmpb      #$20
                    lbeq      L08F5
                    ldb       [$0a,s]
                    cmpb      #$09
                    lbeq      L08F5
L07CF               ldx       $0a,s
                    leax      $01,x
                    stx       $0a,s
                    ldb       -$01,x
                    stb       ,u+
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    beq       L07FC
                    ldb       [$0a,s]
                    sex
                    leax      $03B8,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$0f
                    bne       L07CF
                    bra       L07FC

L07F5               ldd       $0a,s
                    addd      #$0001
                    std       $0a,s
L07FC               ldb       [$0a,s]
                    sex
                    leax      $03B8,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$0f
                    bne       L07F5
                    ldb       [$0a,s]
                    cmpb      #$3a
                    bne       L0819
                    ldd       #$0001
                    bra       L081B

L0819               clra
                    clrb
L081B               std       [$0C,s]
                    lbeq      L08F5
                    ldd       $0a,s
                    addd      #$0001
                    std       $0a,s
                    lbra      L08F5

L082C               ldd       #$000A
                    std       ,s
                    bra       L083A

L0833               ldd       $0a,s
                    addd      #$0001
                    std       $0a,s
L083A               ldb       [$0a,s]
                    cmpb      #$20
                    beq       L0833
                    ldb       [$0a,s]
                    cmpb      #$09
                    lbeq      L0833
                    bra       L0856

L084C               ldx       $0a,s
                    leax      $01,x
                    stx       $0a,s
                    ldb       -$01,x
                    stb       ,u+
L0856               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    beq       L087C
                    ldb       [$0a,s]
                    sex
                    leax      $03B8,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$0f
                    bne       L084C
                    bra       L087C

L0875               ldd       $0a,s
                    addd      #$0001
                    std       $0a,s
L087C               ldb       [$0a,s]
                    sex
                    leax      $03B8,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$0f
                    bne       L0875
                    lbra      L08F5

L0890               ldd       #$005A
                    std       ,s
                    bra       L089E

L0897               ldd       $0a,s
                    addd      #$0001
                    std       $0a,s
L089E               ldb       [$0a,s]
                    cmpb      #$20
                    beq       L0897
                    ldb       [$0a,s]
                    cmpb      #$09
                    lbeq      L0897
                    bra       L08BA

L08B0               ldx       $0a,s
                    leax      $01,x
                    stx       $0a,s
                    ldb       -$01,x
                    stb       ,u+
L08BA               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    beq       L08F5
                    ldb       [$0a,s]
                    bne       L08B0
                    bra       L08F5

L08CD               ldd       $06,s
                    pshs      d
                    leax      >L08FF,pcr
                    pshs      x
                    lbsr      L1814
                    leas      $04,s
                    bra       L08F5

L08DE               cmpx      #$0001
                    lbeq      L07B8
                    cmpx      #$0002
                    lbeq      L082C
                    cmpx      #$0003
                    lbeq      L0890
                    bra       L08CD

L08F5               clra
                    clrb
                    stb       ,u
                    ldd       $0a,s
                    leas      $02,s
                    puls      pc,u
L08FF               fcc       /parse called with bad type : %d/
                    fcb       $00
L091F               pshs      u,d
                    leax      $056b,y
                    stx       ,s
                    ldu       #$0000
                    bra       L093D

L092C               ldd       ,s
                    ldx       ,s
                    std       $02,x
                    std       [,s]
                    ldd       ,s
                    addd      #$0004
                    std       ,s
                    leau      $01,u
L093D               cmpu      #$0080
                    blt       L092C
                    lbra      L09EA

L0946               pshs      u,d
                    lbsr      L09EE
                    std       ,s
                    ldd       $06,s
                    pshs      d
                    lbsr      L09CC
                    leas      $02,s
                    aslb
                    rola
                    aslb
                    rola
                    leax      $056b,y
                    leax      d,x
                    leau      ,x
                    ldd       $06,s
                    pshs      d
                    ldd       $02,s
                    addd      #$000C
                    pshs      d
                    lbsr      L2408
                    leas      $04,s
                    stu       [,s]
                    ldd       $02,u
                    ldx       ,s
                    std       $02,x
                    ldd       ,s
                    std       [$02,u]
                    ldd       ,s
                    std       $02,u
                    ldd       ,s
                    lbra      L09EA

L0988               pshs      u,x,d
                    ldd       $08,s
                    pshs      d
                    bsr       L09CC
                    leas      $02,s
                    aslb
                    rola
                    aslb
                    rola
                    leax      $056b,y
                    leax      d,x
                    stx       ,s
                    ldd       [,s]
                    bra       L09BD

L09A2               ldd       $02,s
                    addd      #$000C
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    lbsr      L244D
                    leas      $04,s
                    std       -$02,s
                    bne       L09BA
                    ldd       $02,s
                    bra       L09C8

L09BA               ldd       [$02,s]
L09BD               std       $02,s
                    ldd       $02,s
                    cmpd      ,s
                    bne       L09A2
                    clra
                    clrb
L09C8               leas      $04,s
                    puls      pc,u
L09CC               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    clra
                    clrb
                    bra       L09DF

L09D6               ldd       ,s
                    pshs      d
                    ldb       ,u+
                    sex
                    addd      ,s++
L09DF               std       ,s
                    ldb       ,u
                    bne       L09D6
                    ldd       ,s
                    clra
                    andb      #$7f
L09EA               leas      $02,s
                    puls      pc,u
L09EE               pshs      u
                    ldu       $0011
                    beq       L0A04
                    ldd       ,u
                    std       $0011
                    clra
                    clrb
                    std       $0a,u
                    std       $08,u
                    std       $06,u
                    std       $04,u
                    bra       L0A10

L0A04               ldd       #$0018
                    pshs      d
                    lbsr      L17F3
                    leas      $02,s
                    tfr       d,u
L0A10               tfr       u,d
                    puls      pc,u
L0A14               pshs      u
                    ldu       $04,s
                    ldd       $04,u
                    bne       L0A31
                    ldd       $06,u
                    bne       L0A31
                    ldd       ,u
                    std       [$02,u]
                    ldd       $02,u
                    ldx       ,u
L0A29               std       $02,x
                    ldd       $0011
                    std       ,u
                    stu       $0011
L0A31               puls      pc,u
L0A33               pshs      u
                    ldd       >$0023,y
                    addd      #$0001
                    std       >$0023,y
                    pshs      d
                    leax      >L0A53,pcr
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    lbsr      L1ADA
                    leas      $06,s
                    puls      pc,u
L0A53               clrb
                    bcc       $0A7B
                    lsr       0,x
L0A58               pshs      u
                    ldu       $06,s
                    bra       L0A73

L0A5E               ldd       ,u
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L244D
                    leas      $04,s
                    std       -$02,s
                    lbeq      L0CCF
                    leau      $02,u
L0A73               cmpu      $08,s
                    bcs       L0A5E
                    clra
                    clrb
                    puls      pc,u
L0A7C               pshs      u
                    leax      >$0015,y
                    stx       L0017
                    tfr       x,d
                    std       L0015
                    clra
                    clrb
                    std       $001D
                    std       $001F
                    std       copybytes
                    puls      pc,u
L0A92               pshs      u
                    leas      -$0a,s
                    lbsr      L0C90
                    tfr       d,u
                    ldd       $14,s
                    beq       L0AA5
                    ldd       [$14,s]
                    bra       L0AA7

L0AA5               clra
                    clrb
L0AA7               std       $04,u
                    beq       L0AC3
                    ldd       [$14,s]
                    bra       L0AB8

L0AB0               ldx       $08,s
                    stu       $04,x
                    ldx       $08,s
                    ldd       $08,x
L0AB8               std       $08,s
                    ldd       $08,s
                    bne       L0AB0
                    clra
                    clrb
                    std       [$14,s]
L0AC3               ldd       $10,s
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    addd      ,s++
                    pshs      d
                    lbsr      L2408
                    leas      $04,s
                    ldd       $12,s
                    std       $04,s
                    tfr       d,x
                    ldb       ,x
                    beq       L0AEB
L0AE1               ldx       $04,s
                    leax      $01,x
                    stx       $04,s
                    ldb       ,x
                    bne       L0AE1
L0AEB               ldd       $04,s
                    subd      $12,s
                    std       ,s
                    ldd       $0e,s
                    std       ,u
                    ldx       $0e,s
                    ldd       $02,x
                    std       $02,u
                    ldx       $0e,s
                    stu       [$02,x]
                    ldx       $0e,s
                    stu       $02,x
                    ldd       copybytes
                    addd      #$0001
                    std       copybytes
                    leax      $08,u
                    stx       $06,s
                    ldb       ,x
                    sex
                    tfr       d,x
                    lbra      L0C53

L0B18               ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       ,x
                    cmpb      #$62
                    lbne      L0C6B
L0B26               leax      >$004b,y
                    pshs      x
                    leax      >$0027,y
                    pshs      x
                    ldd       $0a,s
                    addd      #$0001
                    pshs      d
                    lbsr      L0A58
                    leas      $06,s
                    std       $02,s
                    lbeq      L0C6B
                    ldd       $06,u
                    pshs      d
                    leax      >$0027,y
                    pshs      x
                    ldd       $06,s
                    subd      ,s++
                    pshs      d
                    ldd       #$0002
                    lbsr      L24EA
                    orb       #$60
                    ora       ,s+
                    orb       ,s+
                    std       $06,u
                    ldd       [$02,s]
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    addd      ,s++
                    pshs      d
                    lbsr      L2408
                    leas      $04,s
                    leax      ,s
                    pshs      x
                    ldd       $14,s
                    pshs      d
                    ldd       $16,s
                    pshs      d
                    ldd       #$0001
                    pshs      d
                    lbsr      L07AD
                    leas      $08,s
                    ldd       $12,s
                    pshs      d
                    lbsr      L0988
                    leas      $02,s
                    std       $08,s
                    leax      >$0027,y
                    cmpx      $02,s
                    bne       L0BE8
                    ldd       $08,s
                    beq       L0BB8
                    ldx       $08,s
                    ldd       $04,x
                    beq       L0BB8
                    ldx       $08,s
                    ldd       $04,x
                    pshs      d
                    pshs      u
                    lbsr      L0CEA
                    leas      $04,s
L0BB8               ldd       $04,u
                    bne       L0BE2
                    leax      >$0015,y
                    cmpx      $02,u
                    beq       L0BE2
                    ldx       $02,u
                    ldd       $06,x
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L0BE2
                    pshs      u
                    lbsr      L0F2A
                    leas      $02,s
                    ldd       L0021
                    addd      #$0001
                    std       L0021
                    clra
                    clrb
                    lbra      L0C8C

L0BE2               ldd       $06,u
                    ora       #$01
                    std       $06,u
L0BE8               ldd       L0019
                    addd      #$0001
                    std       L0019
                    ldd       $08,s
                    bne       L0BFF
                    ldd       $12,s
                    pshs      d
                    lbsr      L0946
                    leas      $02,s
                    std       $08,s
L0BFF               ldd       $06,u
                    ora       #$02
                    std       $06,u
                    ldd       $08,s
                    std       $13,u
                    pshs      d
                    pshs      u
                    lbsr      L0CD3
                    leas      $04,s
                    bra       L0C6B

L0C15               leax      L1088,pcr
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    lbsr      L244D
                    leas      $04,s
                    std       -$02,s
                    bne       L0C6B
                    leax      L108D,pcr
                    pshs      x
                    ldd       $14,s
                    addd      $02,s
                    addd      #$FFFD
                    bra       L0C40

L0C38               leax      L1091,pcr
                    pshs      x
                    ldd       $08,s
L0C40               pshs      d
                    lbsr      L244D
                    leas      $04,s
                    std       -$02,s
                    bne       L0C6B
                    ldd       $06,u
                    ora       #$01
                    std       $06,u
                    bra       L0C6B

L0C53               cmpx      #$006C
                    lbeq      L0B18
                    cmpx      #$0062
                    lbeq      L0B26
                    cmpx      #$0070
                    beq       L0C15
                    cmpx      #$0072
                    beq       L0C38
L0C6B               ldd       $06,u
                    clra
                    andb      #$20
                    bne       L0C8A
                    ldd       $12,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    lbsr      L0FED
                    leas      $02,s
                    std       $13,u
                    pshs      d
                    lbsr      L2408
                    leas      $04,s
L0C8A               tfr       u,d
L0C8C               leas      $0a,s
                    puls      pc,u
L0C90               pshs      u
                    ldu       $001D
                    bne       L0CC4
                    ldd       $001F
                    addd      #$0001
                    std       $001F
                    pshs      d
                    ldd       >$0025,y
                    addd      #$0003
                    cmpd      ,s++
                    bge       L0CB6
                    leax      L1095,pcr
                    pshs      x
                    lbsr      L1814
                    leas      $02,s
L0CB6               ldd       #$0015
                    pshs      d
                    lbsr      L17F3
                    leas      $02,s
                    tfr       d,u
                    bra       L0CCF

L0CC4               ldd       ,u
                    std       $001D
                    clra
                    clrb
                    std       $13,u
                    std       $06,u
L0CCF               tfr       u,d
                    puls      pc,u
L0CD3               pshs      u
                    lbsr      L0FC3
                    tfr       d,u
                    ldd       $04,s
                    std       $02,u
                    ldx       $06,s
                    ldd       $06,x
                    std       ,u
                    ldx       $06,s
                    stu       $06,x
                    puls      pc,u
L0CEA               pshs      u,d
                    ldd       $06,s
                    cmpd      $08,s
                    lbeq      L0F83
                    ldx       $06,s
                    ldu       $04,x
                    lbeq      L0F83
L0CFD               stu       ,s
                    ldd       $08,s
                    std       $04,u
                    ldu       $08,u
                    bne       L0CFD
                    ldx       $08,s
                    ldd       $04,x
                    ldx       ,s
                    std       $08,x
                    ldx       $06,s
                    ldd       $04,x
                    ldx       $08,s
                    std       $04,x
                    clra
                    clrb
                    ldx       $06,s
                    std       $04,x
                    lbra      L0F83

L0D20               pshs      u,d
                    ldu       L0015
                    pshs      u
                    leax      >$0015,y
                    cmpx      ,s++
                    bne       L0D39
                    leax      L10AD,pcr
                    pshs      x
                    lbsr      L1814
                    leas      $02,s
L0D39               ldd       $06,u
                    clra
                    andb      #$60
                    cmpd      #$0060
                    bne       L0D50
                    ldd       #$0004
                    pshs      d
                    pshs      u
                    lbsr      L0E5C
                    leas      $04,s
L0D50               ldd       $04,u
                    std       ,s
                    beq       L0DAB
                    ldd       #$0005
                    pshs      d
                    pshs      u
                    lbsr      L0E5C
                    bra       L0DA9

L0D62               ldd       ,s
                    addd      #$000C
                    pshs      d
                    leax      L10CC,pcr
                    pshs      x
                    ldd       $0567,y
                    pshs      d
                    lbsr      fprintf
                    leas      $06,s
                    ldx       ,s
                    ldd       $0a,x
                    clra
                    andb      #$01
                    beq       L0D93
                    ldd       $0567,y
                    pshs      d
                    ldd       #$003A
                    pshs      d
                    lbsr      $1FB2
                    leas      $04,s
L0D93               ldx       ,s
                    ldd       $08,x
                    std       ,s
                    beq       L0DAB
                    ldd       $0567,y
                    pshs      d
                    ldd       #$000D
                    pshs      d
                    lbsr      $1FB2
L0DA9               leas      $04,s
L0DAB               ldd       ,s
                    bne       L0D62
                    ldd       $0567,y
                    pshs      d
                    ldd       #$0020
                    pshs      d
                    lbsr      $1FB2
                    leas      $04,s
                    ldd       $06,u
                    clra
                    andb      #$20
                    beq       L0E0D
                    ldd       $06,u
                    anda      #$02
                    clrb
                    std       -$02,s
                    beq       L0DD7
                    ldd       $13,u
                    addd      #$000C
                    bra       L0DDA

L0DD7               ldd       $13,u
L0DDA               pshs      d
                    pshs      u
                    ldd       #$0008
                    addd      ,s++
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L0DF2
                    leax      L10D8,pcr
                    bra       L0DF6

L0DF2               leax      L10DA,pcr
L0DF6               tfr       x,d
                    pshs      d
                    leax      L10CF,pcr
                    pshs      x
                    ldd       $0567,y
                    pshs      d
                    lbsr      fprintf
                    leas      $0a,s
                    bra       L0E42

L0E0D               pshs      u
                    ldd       #$0008
                    addd      ,s++
                    pshs      d
                    leax      L10DB,pcr
                    pshs      x
                    ldd       $0567,y
                    pshs      d
                    lbsr      fprintf
                    leas      $06,s
                    ldb       [$13,u]
                    beq       L0E42
                    ldd       $13,u
                    pshs      d
                    leax      L10DE,pcr
                    pshs      x
                    ldd       $0567,y
                    pshs      d
                    lbsr      fprintf
                    leas      $06,s
L0E42               ldd       $0567,y
                    pshs      d
                    ldd       #$000D
                    pshs      d
                    lbsr      $1FB2
                    leas      $04,s
                    pshs      u
                    lbsr      L0F2A
                    leas      $02,s
                    lbra      L0F83

L0E5C               pshs      u,y,x,d
                    ldu       $0a,s
                    ldd       $0C,s
                    cmpd      #$0004
                    lbne      L0EC9
                    ldd       $06,u
                    anda      #$02
                    clrb
                    std       -$02,s
                    beq       L0E78
                    ldd       $13,u
                    bra       L0E82

L0E78               ldd       $13,u
                    pshs      d
                    lbsr      L0988
                    leas      $02,s
L0E82               std       $02,s
                    lbeq      L0F26
                    ldx       $02,s
                    ldd       $04,x
                    std       $04,s
                    lbeq      L0F26
                    ldd       #$0024
                    bra       L0EB2

L0E97               cmpu      $04,s
                    bne       L0EAD
                    ldd       $06,u
                    orb       #$80
                    std       $06,u
                    ldx       $0a,s
                    ldd       $06,x
                    andb      #$BF
                    std       $06,x
                    lbra      L0F04

L0EAD               ldd       ,s
                    addd      #$FFFF
L0EB2               std       ,s
                    ldd       ,s
                    lbeq      L0F26
                    ldu       ,u
                    pshs      u
                    leax      >$0015,y
                    cmpx      ,s++
                    bne       L0E97
                    lbra      L0F26

L0EC9               ldd       #$0024
                    bra       L0F12

L0ECE               ldd       $06,u
                    clra
                    andb      #$60
                    cmpd      #$0060
                    bne       L0F0D
                    ldd       $06,u
                    anda      #$02
                    clrb
                    std       -$02,s
                    beq       L0EE7
                    ldd       $13,u
                    bra       L0EF1

L0EE7               ldd       $13,u
                    pshs      d
                    lbsr      L0988
                    leas      $02,s
L0EF1               std       $02,s
                    beq       L0F0D
                    ldd       $0a,s
                    ldx       $02,s
                    cmpd      $04,x
                    bne       L0F0D
                    ldd       $06,u
                    andb      #$BF
                    std       $06,u
L0F04               ldd       L001B
                    addd      #$0001
                    std       L001B
                    bra       L0F26

L0F0D               ldd       ,s
                    addd      #$FFFF
L0F12               std       ,s
                    ldd       ,s
                    beq       L0F26
                    ldu       ,u
                    pshs      u
                    leax      >$0015,y
                    cmpx      ,s++
                    lbne      L0ECE
L0F26               leas      $06,s
                    puls      pc,u
L0F2A               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    clra
                    andb      #$20
                    beq       L0F44
                    ldd       $13,u
                    pshs      d
                    pshs      u
                    bsr       L0F87
                    leas      $04,s
                    bra       L0F4E

L0F44               ldd       $13,u
                    pshs      d
                    lbsr      L1024
                    leas      $02,s
L0F4E               ldd       $04,u
                    bra       L0F65

L0F52               clra
                    clrb
                    ldx       ,s
                    std       $04,x
                    ldd       ,s
                    pshs      d
                    lbsr      L0A14
                    leas      $02,s
                    ldx       ,s
                    ldd       $08,x
L0F65               std       ,s
                    ldd       ,s
                    bne       L0F52
                    ldd       ,u
                    std       [$02,u]
                    ldd       $02,u
                    ldx       ,u
                    std       $02,x
                    ldd       $001D
                    std       ,u
                    stu       $001D
                    ldd       copybytes
                    addd      #$FFFF
                    std       copybytes
L0F83               leas      $02,s
                    puls      pc,u
L0F87               pshs      u,x,d
                    ldd       $0a,s
                    beq       L0FBF
                    ldd       $0a,s
                    addd      #$0006
                    bra       L0FB7

L0F94               ldx       $02,s
                    ldd       $02,x
                    cmpd      $08,s
                    bne       L0FB5
                    ldd       [$02,s]
                    std       [,s]
                    ldd       $0a,s
                    pshs      d
                    lbsr      L0A14
                    leas      $02,s
                    ldd       $02,s
                    pshs      d
                    bsr       L0FE1
                    leas      $02,s
                    bra       L0FBF

L0FB5               ldd       $02,s
L0FB7               std       ,s
                    ldd       [,s]
                    std       $02,s
                    bne       L0F94
L0FBF               leas      $04,s
                    puls      pc,u
L0FC3               pshs      u
                    ldu       $0001
                    beq       L0FCF
                    ldd       ,u
                    std       $0001
                    bra       L0FDB

L0FCF               ldd       #$0004
                    pshs      d
                    lbsr      L17F3
                    leas      $02,s
                    tfr       d,u
L0FDB               clra
                    clrb
                    std       $02,u
                    bra       L101E

L0FE1               pshs      u
                    ldu       $04,s
                    ldd       $0001
                    std       ,u
                    stu       $0001
                    puls      pc,u
L0FED               pshs      u
                    ldd       $04,s
                    cmpd      #$0010
                    bge       L1006
                    ldu       $0003
                    beq       L1001
                    ldd       ,u
                    std       $0003
                    bra       L101C

L1001               ldd       #$0010
                    bra       L1013

L1006               ldu       $0005
                    beq       L1010
                    ldd       ,u
                    std       $0005
                    bra       L101C

L1010               ldd       #$005B
L1013               pshs      d
                    lbsr      L17F3
                    leas      $02,s
                    tfr       d,u
L101C               clra
                    clrb
L101E               std       ,u
                    tfr       u,d
                    puls      pc,u
L1024               pshs      u
                    ldu       $04,s
                    beq       L1050
                    bra       L102E

L102C               leau      $01,u
L102E               ldb       ,u
                    bne       L102C
                    tfr       u,d
                    subd      $04,s
                    cmpd      #$0010
                    bge       L1047
                    ldd       $0003
                    std       [$04,s]
                    ldd       $04,s
                    std       $0003
                    bra       L1050

L1047               ldd       $0005
                    std       [$04,s]
                    ldd       $04,s
                    std       $0005
L1050               puls      pc,u
                    fcb       $72,$61
                    fcb       $00
                    fcb       $73,$72
                    fcb       $00
                    fcb       $65,$71
                    fcb       $00
                    fcb       $6E,$65
                    fcb       $00
                    fcb       $6C,$74
                    fcb       $00
                    fcb       $67,$65
                    fcb       $00
                    fcb       $6C,$65
                    fcb       $00
                    fcb       $67,$74
                    fcb       $00
                    fcb       $6C,$6F
                    fcb       $00
                    fcb       $68,$73
                    fcb       $00
                    fcb       $6C,$73
                    fcb       $00
L1073               fcb       $68,$69
                    fcb       $00
                    fcb       $70,$6C
                    fcb       $00
L1079               fcb       $6D,$69
                    fcb       $00
                    fcb       $63,$63
                    fcb       $00
L107F               fcb       $63,$73
                    fcb       $00
                    fcb       $76,$63
                    fcb       $00
                    fcb       $76,$73
                    fcb       $00
L1088               fcc       /puls/
                    fcb       $00
L108D               fcb       $2C,$70,$63
                    fcb       $00
L1091               fcb       $72,$74,$73
                    fcb       $00
L1095               fcc       /run out of instructions/
                    fcb       $00
L10AD               fcc       /removing too many instructions/
                    fcb       $00
L10CC               fcb       $25,$73
                    fcb       $00
L10CF               fcc       /%sb%s %s/
                    fcb       $00
L10D8               fcb       $6C
                    fcb       $00
L10DA               fcb       $00
L10DB               fcb       $25,$73
                    fcb       $00
L10DE               fcb       $20,$25,$73
                    fcb       $00
L10E2               pshs      u,d
                    leau      $0146,y
                    bra       L1106

L10EA               ldd       $02,u
                    pshs      d
                    lbsr      L09CC
                    leas      $02,s
                    aslb
                    rola
                    leax      $076b,y
                    leax      d,x
                    stx       ,s
                    ldd       [,s]
                    std       $0e,u
                    stu       [,s]
                    leau      $10,u
L1106               ldd       ,u
                    bne       L10EA
                    leas      $02,s
                    puls      pc,u
L110E               pshs      u
                    ldu       $04,s
                    leas      -$0C,s
                    ldu       $02,u
                    bra       L111A

L1118               leas      -$0C,x
L111A               leax      >$0015,y
                    pshs      x
                    cmpu      ,s++
                    lbeq      L12F1
                    ldd       ,u
                    std       $0a,s
                    pshs      d
                    leax      >$0015,y
                    cmpx      ,s++
                    lbeq      L12F1
                    ldx       $0a,s
                    ldd       $04,x
                    lbeq      L11C3
                    ldd       $06,u
                    clra
                    andb      #$20
                    lbeq      L12F1
                    ldd       $06,u
                    clra
                    andb      #$3f
                    cmpd      #$0021
                    lbeq      L12F1
                    ldx       $13,u
                    ldd       $04,x
                    cmpd      $0a,s
                    bne       L1181
                    ldd       $0a,s
                    pshs      d
                    pshs      u
                    lbsr      L0CEA
                    leas      $04,s
                    pshs      u
                    lbsr      L0F2A
                    leas      $02,s
                    ldx       $0a,s
                    ldu       $02,x
                    ldd       L0021
                    addd      #$0001
                    std       L0021
                    leax      $0C,s
                    lbra      L1118

L1181               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L12F1
                    ldd       $04,u
                    lbne      L12F1
                    ldu       $02,u
                    pshs      u
                    leax      >$0015,y
                    cmpx      ,s++
                    lbeq      L12F1
                    ldd       $06,u
                    clra
                    andb      #$3f
                    cmpd      #$0021
                    lble      L12F1
                    ldx       $13,u
                    ldd       $04,x
                    cmpd      $0a,s
                    lbne      L12F1
                    pshs      u
                    lbsr      L12F5
                    leas      $02,s
                    lbra      L12F1

L11C3               pshs      u
                    ldd       #$0008
                    addd      ,s++
                    pshs      d
                    lbsr      L09CC
                    leas      $02,s
                    aslb
                    rola
                    leax      $076b,y
                    leax      d,x
                    ldd       ,x
                    std       $08,s
                    clra
                    clrb
                    std       $04,s
                    lbra      L125A

L11E4               ldx       $08,s
                    ldd       $02,x
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    addd      ,s++
                    pshs      d
                    lbsr      L135C
                    leas      $04,s
                    std       -$02,s
                    lbeq      L1254
                    ldx       $08,s
                    ldd       $04,x
                    pshs      d
                    ldd       $13,u
                    pshs      d
                    lbsr      L135C
                    leas      $04,s
                    std       -$02,s
                    beq       L1254
                    ldx       $08,s
                    ldd       $06,x
                    pshs      d
                    ldd       $0C,s
                    addd      #$0008
                    pshs      d
                    lbsr      L135C
                    leas      $04,s
                    std       -$02,s
                    beq       L1254
                    ldx       $08,s
                    ldd       $08,x
                    cmpd      #$0001
                    bne       L1237
                    ldd       $13,u
                    bra       L123B

L1237               ldx       $08,s
                    ldd       $08,x
L123B               pshs      d
                    ldx       $0C,s
                    ldd       $13,x
                    pshs      d
                    lbsr      L135C
                    leas      $04,s
                    std       -$02,s
                    beq       L1254
                    ldd       #$0001
                    std       $04,s
                    bra       L1260

L1254               ldx       $08,s
                    ldd       $0e,x
                    std       $08,s
L125A               ldd       $08,s
                    lbne      L11E4
L1260               ldd       $04,s
                    lbeq      L12F1
                    ldx       $08,s
                    ldx       $0a,x
                    bra       L1289

L126C               ldd       $0a,s
                    addd      #$0008
                    bra       L1277

L1273               ldx       $08,s
                    ldd       $0a,x
L1277               pshs      d
                    pshs      u
                    ldd       #$0008
                    addd      ,s++
                    pshs      d
                    lbsr      L2408
                    leas      $04,s
                    bra       L1295

L1289               cmpx      #$0001
                    beq       L1295
                    cmpx      #$0002
                    beq       L126C
                    bra       L1273

L1295               ldx       $08,s
                    ldx       $0C,x
                    bra       L12BB

L129B               clra
                    clrb
                    stb       [$13,u]
                    bra       L12CB

L12A2               ldx       $0a,s
                    ldd       $13,x
                    bra       L12AD

L12A9               ldx       $08,s
                    ldd       $0C,x
L12AD               pshs      d
                    ldd       $13,u
                    pshs      d
                    lbsr      L2408
                    leas      $04,s
                    bra       L12CB

L12BB               stx       -$02,s
                    beq       L129B
                    cmpx      #$0001
                    beq       L12CB
                    cmpx      #$0002
                    beq       L12A2
                    bra       L12A9

L12CB               ldd       $0a,s
                    pshs      d
                    lbsr      L0F2A
                    leas      $02,s
                    ldd       L0021
                    addd      #$0001
                    std       L0021
                    ldx       [$08,s]
                    bra       L12E4

L12E0               ldu       $02,u
                    bra       L12EE

L12E4               cmpx      #$0001
                    beq       L12E0
                    cmpx      #$0002
                    beq       L12F1
L12EE               lbra      L111A

L12F1               leas      $0C,s
                    puls      pc,u
L12F5               pshs      u
                    ldu       $04,s
                    ldd       $06,u
                    clra
                    andb      #$3f
                    eorb      #$01
                    pshs      d
                    ldx       ,u
                    ldd       $06,x
                    anda      #$FE
                    andb      #$C0
                    ora       ,s+
                    orb       ,s+
                    std       $06,u
                    clra
                    andb      #$1f
                    aslb
                    rola
                    leax      >$0027,y
                    leax      d,x
                    ldd       ,x
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    addd      ,s++
                    pshs      d
                    lbsr      L2408
                    leas      $04,s
                    ldd       $13,u
                    pshs      d
                    pshs      u
                    lbsr      L0F87
                    leas      $04,s
                    ldx       ,u
                    ldd       $13,x
                    std       $13,u
                    pshs      d
                    pshs      u
                    lbsr      L0CD3
                    leas      $04,s
                    ldd       ,u
                    pshs      d
                    lbsr      L0F2A
                    leas      $02,s
                    ldd       L0021
                    addd      #$0001
                    std       L0021
                    puls      pc,u
L135C               pshs      u
                    ldu       $04,s
                    ldd       $06,s
                    lbne      L13E1
                    ldd       #$0001
                    puls      pc,u
                    lbra      L13E1

L136E               ldb       [$06,s]
                    cmpb      #$3C
                    lbne      L13CE
                    ldb       ,u
                    sex
                    leax      $03B8,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    lbeq      L13F1
                    leas      -$02,s
                    clra
                    clrb
                    std       ,s
L138F               ldd       ,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L247E
                    pshs      d
                    ldb       ,u+
                    sex
                    addd      ,s++
                    addd      #$FFD0
                    std       ,s
                    ldb       ,u
                    sex
                    leax      $03B8,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    bne       L138F
                    ldd       ,s
                    cmpd      #$00FF
                    bls       L13C3
                    clra
                    clrb
                    leas      $02,s
                    puls      pc,u
L13C3               leas      $02,s
                    ldd       $06,s
                    addd      #$0001
                    std       $06,s
                    bra       L13E1

L13CE               ldb       ,u+
                    sex
                    pshs      d
                    ldx       $08,s
                    leax      $01,x
                    stx       $08,s
                    ldb       -$01,x
                    sex
                    cmpd      ,s++
                    bne       L13F1
L13E1               ldb       [$06,s]
                    lbne      L136E
                    ldb       ,u
                    bne       L13F1
                    ldd       #$0001
                    bra       L13F3

L13F1               clra
                    clrb
L13F3               puls      pc,u
L13F5               pshs      u
                    ldu       $04,s
                    leas      -$0a,s
                    leax      >$0015,y
                    cmpx      $02,u
                    lbeq      L15DA
                    clra
                    clrb
                    std       ,s
                    ldd       $04,u
                    bra       L1454

L140D               ldx       $06,s
                    ldd       $06,x
                    bra       L144A

L1413               ldx       $04,s
                    ldd       $02,x
                    std       $08,s
                    ldx       $08,s
                    ldd       $04,x
                    beq       L1447
                    ldx       $08,s
                    ldd       $06,x
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L1447
                    ldx       $08,s
                    ldd       $06,x
                    clra
                    andb      #$80
                    bne       L1447
                    lbsr      L0FC3
                    std       $02,s
                    ldd       ,s
                    std       [$02,s]
                    ldd       $02,s
                    std       ,s
                    ldd       $08,s
                    ldx       ,s
                    std       $02,x
L1447               ldd       [$04,s]
L144A               std       $04,s
                    ldd       $04,s
                    bne       L1413
                    ldx       $06,s
                    ldd       $08,x
L1454               std       $06,s
                    ldd       $06,s
                    lbne      L140D
                    lbra      L14D1

L145F               pshs      u
                    ldx       $02,s
                    ldd       $02,x
L1465               std       $0a,s
                    pshs      d
                    lbsr      L0CEA
                    leas      $04,s
                    ldx       $08,s
                    ldd       $02,x
                    std       $08,s
                    pshs      d
                    leax      >$0015,y
                    cmpx      ,s++
                    beq       L14C0
                    ldx       $08,s
                    ldd       $06,x
                    clra
                    andb      #$20
                    beq       L14C0
                    ldx       $08,s
                    ldd       $06,x
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L149C
                    ldd       [$08,s]
                    pshs      d
                    lbsr      L0F2A
                    bra       L14BE

L149C               ldx       $08,s
                    ldd       $06,x
                    clra
                    andb      #$3f
                    cmpd      #$0021
                    ble       L14C0
                    ldx       $08,s
                    ldx       $13,x
                    ldd       $04,x
                    ldx       $08,s
                    cmpd      [,x]
                    bne       L14C0
                    ldd       $08,s
                    pshs      d
                    lbsr      L12F5
L14BE               leas      $02,s
L14C0               ldd       [,s]
                    std       $02,s
                    ldd       ,s
                    pshs      d
                    lbsr      L0FE1
                    leas      $02,s
                    ldd       $02,s
                    std       ,s
L14D1               ldd       ,s
                    lbne      L145F
                    ldx       $02,u
                    ldd       $06,x
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L152A
                    ldd       $04,u
                    bra       L1519

L14E6               ldx       $06,s
                    ldd       $06,x
                    bra       L150F

L14EC               ldx       $04,s
                    ldd       $02,x
                    std       $08,s
                    tfr       d,x
                    ldd       $06,x
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L150C
                    ldd       $08,s
                    pshs      d
                    ldx       $08,s
                    ldd       $08,x
                    pshs      d
                    lbsr      L1762
                    leas      $04,s
L150C               ldd       [$04,s]
L150F               std       $04,s
                    ldd       $04,s
                    bne       L14EC
                    ldx       $06,s
                    ldd       $08,x
L1519               std       $06,s
                    ldd       $06,s
                    bne       L14E6
                    pshs      u
                    ldd       $04,u
                    pshs      d
                    lbsr      L1762
                    leas      $04,s
L152A               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L15DA
                    ldd       $06,u
                    clra
                    andb      #$20
                    beq       L1571
                    ldx       $13,u
                    ldd       $04,x
                    std       $08,s
                    beq       L1562
                    ldx       $08,s
                    ldd       $02,x
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    lbsr      L15DE
                    leas      $04,s
                    std       -$02,s
                    lbne      L15DA
                    pshs      u
                    ldx       $0a,s
                    ldd       $04,x
                    bra       L1567

L1562               pshs      u
                    ldd       $13,u
L1567               pshs      d
                    lbsr      L1762
                    leas      $04,s
                    lbra      L15DA

L1571               ldd       $02,u
                    lbra      L15CE

L1576               ldx       $08,s
                    ldd       $06,x
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L15CA
                    ldx       $08,s
                    ldd       $06,x
                    clra
                    andb      #$A0
                    bne       L15CA
                    ldd       $08,s
                    addd      #$0008
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    addd      ,s++
                    pshs      d
                    lbsr      L244D
                    leas      $04,s
                    std       -$02,s
                    bne       L15CA
                    ldx       $08,s
                    ldd       $13,x
                    pshs      d
                    ldd       $13,u
                    pshs      d
                    lbsr      L244D
                    leas      $04,s
                    std       -$02,s
                    bne       L15CA
                    ldd       $02,u
                    pshs      d
                    ldx       $0a,s
                    ldd       $02,x
                    pshs      d
                    bsr       L15DE
                    leas      $04,s
                    std       -$02,s
                    bne       L15DA
L15CA               ldx       $08,s
                    ldd       $02,x
L15CE               std       $08,s
                    leax      >$0015,y
                    cmpx      $08,s
                    lbne      L1576
L15DA               leas      $0a,s
                    puls      pc,u
L15DE               pshs      u
                    ldu       $04,s
                    leas      -$14,s
                    clra
                    clrb
                    std       ,s
                    stu       $06,s
                    pshs      u
                    ldd       $1C,s
                    std       $06,s
                    cmpd      ,s++
                    bne       L160D
                    lbra      L175B
                    bra       L160D

L15FC               ldu       $02,u
                    ldx       $1a,s
                    ldd       $02,x
                    std       $1a,s
                    ldd       ,s
                    addd      #$0001
                    std       ,s
L160D               leax      >$0015,y
                    pshs      x
                    cmpu      ,s++
                    lbeq      L16BA
                    leax      >$0015,y
                    cmpx      $1a,s
                    lbeq      L16BA
                    cmpu      $04,s
                    lbeq      L16BA
                    ldd       $1a,s
                    cmpd      $06,s
                    lbeq      L16BA
                    ldd       $06,u
                    clra
                    andb      #$3f
                    pshs      d
                    ldx       $1C,s
                    ldd       $06,x
                    clra
                    andb      #$3f
                    cmpd      ,s++
                    lbne      L16BA
                    ldd       $06,u
                    clra
                    andb      #$80
                    lbne      L16BA
                    ldd       $06,u
                    clra
                    andb      #$20
                    beq       L1684
                    ldx       $13,u
                    ldd       $04,x
                    beq       L1678
                    ldx       $13,u
                    ldd       $04,x
                    ldx       $1a,s
                    ldx       $13,x
                    cmpd      $04,x
                    bne       L16B4
L1673               ldd       #$0001
                    bra       L16B6

L1678               ldd       $13,u
                    ldx       $1a,s
                    cmpd      $13,x
                    bra       L16B2

L1684               ldd       $1a,s
                    addd      #$0008
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    addd      ,s++
                    pshs      d
                    lbsr      L244D
                    leas      $04,s
                    std       -$02,s
                    bne       L16B4
                    ldx       $1a,s
                    ldd       $13,x
                    pshs      d
                    ldd       $13,u
                    pshs      d
                    lbsr      L244D
                    leas      $04,s
                    std       -$02,s
L16B2               beq       L1673
L16B4               clra
                    clrb
L16B6               lbne      L15FC
L16BA               ldu       ,u
                    ldd       ,s
                    lbeq      L175B
                    ldd       [$1a,s]
                    std       $1a,s
                    std       $04,s
                    ldd       $04,u
                    std       $02,s
                    bne       L171D
                    ldx       $1a,s
                    ldd       $04,x
                    std       $02,s
                    bne       L171D
                    leax      $08,s
                    pshs      x
                    lbsr      L0A33
                    std       ,s
                    lbsr      L0946
                    leas      $02,s
                    std       $02,s
                    ldd       $1a,s
                    ldx       $02,s
                    std       $04,x
                    ldd       $02,s
                    ldx       $1a,s
                    std       $04,x
                    bra       L171D

L16F9               ldd       $1a,s
                    pshs      d
                    pshs      u
                    lbsr      L0CEA
                    leas      $04,s
                    ldu       ,u
                    ldd       $02,u
                    pshs      d
                    lbsr      L0F2A
                    leas      $02,s
                    ldd       L0021
                    addd      #$0001
                    std       L0021
                    ldd       [$1a,s]
                    std       $1a,s
L171D               ldd       ,s
                    addd      #$FFFF
                    std       ,s
                    subd      #$FFFF
                    bge       L16F9
                    clra
                    clrb
                    pshs      d
                    ldd       $04,s
                    addd      #$000C
                    pshs      d
                    leax      L17EE,pcr
                    pshs      x
                    pshs      u
                    lbsr      L0A92
                    leas      $08,s
                    pshs      u
                    lbsr      L110E
                    leas      $02,s
                    ldd       $04,s
                    pshs      d
                    ldx       $06,s
                    ldd       $04,x
                    pshs      d
                    bsr       L1762
                    leas      $04,s
                    ldd       #$0001
                    bra       L175D

L175B               clra
                    clrb
L175D               leas      $14,s
                    puls      pc,u
L1762               pshs      u,d
                    bra       L17A1

L1766               ldx       $06,s
                    ldd       $06,x
                    bra       L1795

L176C               ldx       ,s
                    ldu       $02,x
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    beq       L1793
                    ldd       $06,u
                    clra
                    andb      #$80
                    bne       L1793
                    ldx       $08,s
                    ldd       $02,x
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    lbsr      L15DE
                    leas      $04,s
                    std       -$02,s
                    bne       L179B
L1793               ldd       [,s]
L1795               std       ,s
                    ldd       ,s
                    bne       L176C
L179B               ldx       $06,s
                    ldd       $08,x
                    std       $06,s
L17A1               ldd       $06,s
                    bne       L1766
                    leas      $02,s
                    puls      pc,u
                    fcb       $2C,$78,$2B
                    fcb       $00
                    fcb       $2C,$79,$2B
                    fcb       $00
                    fcb       $2C,$75,$2B
                    fcb       $00
                    fcb       $2C,$2D,$78
                    fcb       $00
                    fcb       $2C,$2D,$79
                    fcb       $00
                    fcb       $2C,$2D,$75
                    fcb       $00
                    fcc       /,x++/
                    fcb       $00
                    fcc       /,y++/
                    fcb       $00
                    fcc       /,u++/
                    fcb       $00
                    fcc       /,--x/
                    fcb       $00
                    fcc       /,--y/
                    fcb       $00
                    fcc       /,--u/
                    fcb       $00
                    fcc       /,s++/
                    fcb       $00
                    fcc       /-4,s/
                    fcb       $00
                    fcc       /-6,s/
                    fcb       $00
L17EE               fcc       /lbra/
                    fcb       $00
L17F3               pshs      u,d
                    ldd       $06,s
                    pshs      d
                    lbsr      L273E
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L1810
                    leax      >L185E,pcr
                    pshs      x
                    bsr       L1814
                    leas      $02,s
L1810               ldd       ,s
                    bra       L185A

L1814               pshs      u
                    leax      >L186E,pcr
                    pshs      x
                    leax      $045f,y
                    pshs      x
                    lbsr      fprintf
                    leas      $04,s
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    ldd       $0a,s
                    pshs      d
                    leax      $045f,y
                    pshs      x
                    lbsr      fprintf
                    leas      $0a,s
                    leax      $045f,y
                    pshs      x
                    ldd       #$000D
                    pshs      d
                    lbsr      $1FB2
                    leas      $04,s
                    ldd       #$0001
                    pshs      d
                    lbsr      exit
L185A               leas      $02,s
                    puls      pc,u
L185E               fcc       /memory overflow/
                    fcb       $00
L186E               fcc       /C optimiser error: /
                    fcb       $00
L1882               pshs      u
                    leau      $0445,y
L1888               ldd       $06,u
                    clra
                    andb      #$03
                    lbeq      L18F9
                    leau      $0d,u
                    pshs      u
                    leax      $0515,y
                    cmpx      ,s++
                    bhi       L1888
                    ldd       #$00C8
                    std       $0563,y
                    lbra      L18FD
                    puls      pc,u
L18A9               pshs      u
                    ldu       $08,s
                    bne       L18B3
                    bsr       L1882
                    tfr       d,u
L18B3               stu       -$02,s
                    beq       L18FD
                    ldd       $04,s
                    std       $08,u
                    ldx       $06,s
                    ldb       $01,x
                    cmpb      #$2b
                    beq       L18CB
                    ldx       $06,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L18D1
L18CB               ldd       $06,u
                    orb       #$03
                    bra       L18EF

L18D1               ldd       $06,u
                    pshs      d
                    ldb       [$08,s]
                    cmpb      #$72
                    beq       L18E3
                    ldb       [$08,s]
                    cmpb      #$64
                    bne       L18E8
L18E3               ldd       #$0001
                    bra       L18EB

L18E8               ldd       #$0002
L18EB               ora       ,s+
                    orb       ,s+
L18EF               std       $06,u
                    ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
L18F9               tfr       u,d
                    puls      pc,u
L18FD               clra
                    clrb
                    puls      pc,u
L1901               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    clra
                    clrb
                    std       ,s
                    ldx       $0a,s
                    ldb       $01,x
                    sex
                    tfr       d,x
                    bra       L1932

L1914               ldx       $0a,s
                    ldb       $02,x
                    cmpb      #$2b
                    bne       L1921
                    ldd       #$0007
                    bra       L1929

L1921               ldd       #$0004
                    bra       L1929

L1926               ldd       #$0003
L1929               std       ,s
                    bra       L1942

L192D               leax      $04,s
                    lbra      L199C

L1932               stx       -$02,s
                    beq       L1942
                    cmpx      #$0078
                    beq       L1914
                    cmpx      #$002B
                    beq       L1926
                    bra       L192D

L1942               ldb       [$0a,s]
                    sex
                    tfr       d,x
                    lbra      L19A9

L194B               ldd       ,s
                    orb       #$01
                    bra       L198F

L1951               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      L2601
                    leas      $04,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L197E
                    ldd       #$0002
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbsr      L26D7
                    leas      $08,s
                    bra       L19C3

L197E               ldd       ,s
                    orb       #$02
                    pshs      d
                    pshs      u
                    lbsr      L2622
                    bra       L1996

L198B               ldd       ,s
                    orb       #$81
L198F               pshs      d
                    pshs      u
                    lbsr      L2601
L1996               leas      $04,s
                    std       $02,s
                    bra       L19C3

L199C               leas      -$04,x
L199E               ldd       #$00CB
                    std       $0563,y
                    clra
                    clrb
                    bra       L19C5

L19A9               cmpx      #$0072
                    lbeq      L194B
                    cmpx      #$0061
                    lbeq      L1951
                    cmpx      #$0077
                    beq       L197E
                    cmpx      #$0064
                    beq       L198B
                    bra       L199E

L19C3               ldd       $02,s
L19C5               leas      $04,s
                    puls      pc,u
                    pshs      u
                    clra
                    clrb
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    lbra      L1A25

L19DA               pshs      u
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L1901
                    leas      $04,s
                    tfr       d,u
                    cmpu      #$FFFF
                    bne       L19F5
                    clra
                    clrb
                    bra       L1A2A

L19F5               clra
                    clrb
                    bra       L1A1D

L19F9               pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L20A2
                    leas      $02,s
                    ldd       $06,s
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      L1901
                    leas      $04,s
                    tfr       d,u
                    stu       -$02,s
                    bge       L1A1B
                    clra
                    clrb
                    bra       L1A2A

L1A1B               ldd       $08,s
L1A1D               pshs      d
                    ldd       $08,s
                    pshs      d
                    pshs      u
L1A25               lbsr      L18A9
                    leas      $06,s
L1A2A               puls      pc,u
                    pshs      u,d
                    ldu       $06,s
L1A30               leax      $0445,y
                    pshs      x
                    lbsr      L21C9
                    leas      $02,s
                    std       ,s
                    cmpd      #$000D
                    beq       L1A51
                    ldd       ,s
                    cmpd      #$FFFF
                    beq       L1A51
                    ldd       ,s
                    stb       ,u+
                    bra       L1A30

L1A51               ldd       ,s
                    cmpd      #$FFFF
                    bne       L1A5D
                    clra
                    clrb
                    puls      pc,u,x
L1A5D               clra
                    clrb
                    stb       ,u
                    ldd       $06,s
                    puls      pc,u,x
L1A65               pshs      u
                    ldu       $06,s
                    leas      -$04,s
                    ldd       $08,s
                    std       ,s
L1A6F               tfr       u,d
                    leau      -$01,u
                    std       -$02,s
                    ble       L1A96
                    ldd       $0C,s
                    pshs      d
                    lbsr      L21C9
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L1A96
                    ldd       $02,s
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    cmpb      #$0d
                    bne       L1A6F
L1A96               clra
                    clrb
                    stb       [,s]
                    ldd       $02,s
                    cmpd      #$FFFF
                    bne       L1AA6
                    clra
                    clrb
                    bra       L1AA8

L1AA6               ldd       $08,s
L1AA8               leas      $04,s
                    puls      pc,u
                    pshs      u
                    leax      $0452,y
                    stx       $086b,y
                    leax      $06,s
                    pshs      x
                    ldd       $06,s
                    bra       L1ACC

fprintf             pshs      u
                    ldd       $04,s
                    std       $086b,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
L1ACC               pshs      d
                    leax      L1F86,pcr
                    pshs      x
                    bsr       doprnt
                    leas      $06,s
                    puls      pc,u
L1ADA               pshs      u
                    ldd       $04,s
                    std       $086b,y
                    leax      $08,s
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    leax      L1F99,pcr
                    pshs      x
                    bsr       doprnt
                    leas      $06,s
                    clra
                    clrb
                    stb       [$086b,y]
                    ldd       $04,s
                    puls      pc,u
doprnt              pshs      u
                    ldu       $06,s
                    leas      -$0b,s
L1B04               ldb       ,u+
                    stb       $08,s
                    cmpb      #$25
                    beq       L1B1E
                    ldb       $08,s
                    lbeq      L1D45
                    ldb       $08,s
                    sex
                    pshs      d
                    jsr       [$11,s]
                    leas      $02,s
                    bra       L1B04

L1B1E               ldb       ,u+
                    stb       $08,s
                    clra
                    clrb
                    std       $02,s
                    std       $06,s
                    ldb       $08,s
                    cmpb      #$2d
                    bne       L1B3B
                    ldd       #$0001
                    std       $0881,y
                    ldb       ,u+
                    stb       $08,s
                    bra       L1B41

L1B3B               clra
                    clrb
                    std       $0881,y
L1B41               ldb       $08,s
                    cmpb      #$30
                    bne       L1B4C
                    ldd       #$0030
                    bra       L1B4F

L1B4C               ldd       #$0020
L1B4F               std       $0883,y
L1B53               ldb       $08,s
                    sex
                    leax      $03B8,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    beq       L1B7F
                    ldd       $06,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L247E
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $06,s
                    ldb       ,u+
                    stb       $08,s
                    bra       L1B53

L1B7F               ldb       $08,s
                    cmpb      #$2e
                    bne       L1BB6
                    ldd       #$0001
                    std       $04,s
L1B8A               ldb       ,u+
                    stb       $08,s
                    ldb       $08,s
                    sex
                    leax      $03B8,y
                    leax      d,x
                    ldb       ,x
                    clra
                    andb      #$08
                    beq       L1BBA
                    ldd       $02,s
                    pshs      d
                    ldd       #$000A
                    lbsr      L247E
                    pshs      d
                    ldb       $0a,s
                    sex
                    addd      #$FFD0
                    addd      ,s++
                    std       $02,s
                    bra       L1B8A

L1BB6               clra
                    clrb
                    std       $04,s
L1BBA               ldb       $08,s
                    sex
                    tfr       d,x
                    lbra      L1CE8

L1BC2               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L1D49
                    bra       L1BEA

L1BD7               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    pshs      d
                    lbsr      L1E0C
L1BEA               std       ,s
                    lbra      L1CCE

L1BEF               ldd       $06,s
                    pshs      d
                    ldb       $0a,s
                    sex
                    leax      $03B8,y
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
                    lbsr      L1E52
                    lbra      L1CCA

L1C15               ldd       $06,s
                    pshs      d
                    ldx       $15,s
                    leax      $02,x
                    stx       $15,s
                    ldd       -$02,x
                    pshs      d
                    leax      $086d,y
                    pshs      x
                    lbsr      L1D91
                    lbra      L1CCA

L1C31               ldd       $04,s
                    bne       L1C3A
                    ldd       #$0006
                    std       $02,s
L1C3A               ldd       $06,s
                    pshs      d
                    leax      $15,s
                    pshs      x
                    ldd       $06,s
                    pshs      d
                    ldb       $0e,s
                    sex
                    pshs      d
                    lbsr      $23EC
                    leas      $06,s
                    lbra      L1CCC

L1C54               ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    lbra      L1CDE

L1C61               ldx       $13,s
                    leax      $02,x
                    stx       $13,s
                    ldd       -$02,x
                    std       $09,s
                    ldd       $04,s
                    beq       L1CA9
                    ldd       $09,s
                    std       $04,s
L1C75               ldd       $02,s
                    addd      #$FFFF
                    std       $02,s
                    subd      #$FFFF
                    beq       L1C8F
                    ldb       [$09,s]
                    beq       L1C8F
                    ldd       $09,s
                    addd      #$0001
                    std       $09,s
                    bra       L1C75

L1C8F               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    subd      $06,s
                    pshs      d
                    ldd       $08,s
                    pshs      d
                    ldd       $15,s
                    pshs      d
                    lbsr      L1EBD
                    leas      $08,s
                    bra       L1CD8

L1CA9               ldd       $06,s
                    pshs      d
                    ldd       $0b,s
                    bra       L1CCC

L1CB1               ldb       ,u+
                    stb       $08,s
                    bra       L1CB9
                    leas      -$0b,x
L1CB9               ldd       $06,s
                    pshs      d
                    leax      $15,s
                    pshs      x
                    ldb       $0C,s
                    sex
                    pshs      d
                    lbsr      L23AE
L1CCA               leas      $04,s
L1CCC               pshs      d
L1CCE               ldd       $13,s
                    pshs      d
                    lbsr      L1F1F
                    leas      $06,s
L1CD8               lbra      L1B04

L1CDB               ldb       $08,s
                    sex
L1CDE               pshs      d
                    jsr       [$11,s]
                    leas      $02,s
                    lbra      L1B04

L1CE8               cmpx      #$0064
                    lbeq      L1BC2
                    cmpx      #$006F
                    lbeq      L1BD7
                    cmpx      #$0078
                    lbeq      L1BEF
                    cmpx      #$0058
                    lbeq      L1BEF
                    cmpx      #$0075
                    lbeq      L1C15
                    cmpx      #$0066
                    lbeq      L1C31
                    cmpx      #$0065
                    lbeq      L1C31
                    cmpx      #$0067
                    lbeq      L1C31
                    cmpx      #$0045
                    lbeq      L1C31
                    cmpx      #$0047
                    lbeq      L1C31
                    cmpx      #$0063
                    lbeq      L1C54
                    cmpx      #$0073
                    lbeq      L1C61
                    cmpx      #$006C
                    lbeq      L1CB1
                    bra       L1CDB

L1D45               leas      $0b,s
                    puls      pc,u
L1D49               pshs      u,d
                    leax      $086d,y
                    stx       ,s
                    ldd       $06,s
                    bge       L1D7D
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
                    bge       L1D72
                    leax      L1FAB,pcr
                    pshs      x
                    leax      $086d,y
                    pshs      x
                    lbsr      L2408
                    leas      $04,s
                    puls      pc,u,x
L1D72               ldd       #$002D
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
L1D7D               ldd       $06,s
                    pshs      d
                    ldd       $02,s
                    pshs      d
                    bsr       L1D91
                    leas      $04,s
                    leax      $086d,y
                    tfr       x,d
                    puls      pc,u,x
L1D91               pshs      u,y,x,d
                    ldu       $0a,s
                    clra
                    clrb
                    std       $02,s
                    clra
                    clrb
                    std       ,s
L1D9D               ldd       $0C,s
                    bge       L1DB2
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    ldd       $0C,s
                    subd      $0438,y
                    std       $0C,s
                    bra       L1D9D

L1DB2               leax      $0438,y
                    stx       $04,s
L1DB8               ldd       $04,s
                    cmpd      $0440,y
                    beq       L1DFB
L1DC1               ldd       $0C,s
                    subd      [$04,s]
                    std       $0C,s
                    blt       L1DD3
                    ldd       ,s
                    addd      #$0001
                    std       ,s
                    bra       L1DC1

L1DD3               ldd       $0C,s
                    addd      [$04,s]
                    std       $0C,s
                    ldd       ,s
                    beq       L1DE3
                    ldd       #$0001
                    std       $02,s
L1DE3               ldd       $02,s
                    beq       L1DEE
                    ldd       ,s
                    addd      #$0030
                    stb       ,u+
L1DEE               clra
                    clrb
                    std       ,s
                    ldd       $04,s
                    addd      #$0002
                    std       $04,s
                    bra       L1DB8

L1DFB               ldd       $0C,s
                    addd      #$0030
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       $0a,s
                    leas      $06,s
                    puls      pc,u
L1E0C               pshs      u,d
                    leax      $086d,y
                    stx       ,s
                    leau      $0877,y
L1E18               ldd       $06,s
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
                    bne       L1E18
L1E2E               leau      -$01,u
                    pshs      u
                    leax      $0877,y
                    cmpx      ,s++
                    bhi       L1E46
                    ldb       ,u
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bra       L1E2E

L1E46               clra
                    clrb
                    stb       [,s]
                    leax      $086d,y
                    tfr       x,d
                    puls      pc,u,x
L1E52               pshs      u,x,d
                    leax      $086d,y
                    stx       $02,s
                    leau      $0877,y
L1E5E               ldd       $08,s
                    clra
                    andb      #$0f
                    std       ,s
                    pshs      d
                    ldd       $02,s
                    cmpd      #$0009
                    ble       L1E80
                    ldd       $0C,s
                    beq       L1E78
                    ldd       #$0041
                    bra       L1E7B

L1E78               ldd       #$0061
L1E7B               addd      #$FFF6
                    bra       L1E83

L1E80               ldd       #$0030
L1E83               addd      ,s++
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
                    bne       L1E5E
L1E97               leau      -$01,u
                    pshs      u
                    leax      $0877,y
                    cmpx      ,s++
                    bhi       L1EAF
                    ldb       ,u
                    ldx       $02,s
                    leax      $01,x
                    stx       $02,s
                    stb       -$01,x
                    bra       L1E97

L1EAF               clra
                    clrb
                    stb       [$02,s]
                    leax      $086d,y
                    tfr       x,d
                    lbra      L1F95

L1EBD               pshs      u
                    ldu       $06,s
                    ldd       $0a,s
                    subd      $08,s
                    std       $0a,s
                    ldd       $0881,y
                    bne       L1EE6
L1ECD               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       L1EE6
                    ldd       $0883,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
                    bra       L1ECD

L1EE6               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    beq       L1EFE
                    ldb       ,u+
                    sex
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
                    bra       L1EE6

L1EFE               ldd       $0881,y
                    beq       L1F1D
L1F04               ldd       $0a,s
                    addd      #$FFFF
                    std       $0a,s
                    subd      #$FFFF
                    ble       L1F1D
                    ldd       $0883,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
                    bra       L1F04

L1F1D               puls      pc,u
L1F1F               pshs      u
                    ldu       $06,s
                    ldd       $08,s
                    pshs      d
                    pshs      u
                    lbsr      $23F7
                    leas      $02,s
                    nega
                    negb
                    sbca      #$00
                    addd      ,s++
                    std       $08,s
                    ldd       $0881,y
                    bne       L1F55
L1F3C               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    ble       L1F55
                    ldd       $0883,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
                    bra       L1F3C

L1F55               ldb       ,u
                    beq       L1F65
                    ldb       ,u+
                    sex
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
                    bra       L1F55

L1F65               ldd       $0881,y
                    beq       L1F84
L1F6B               ldd       $08,s
                    addd      #$FFFF
                    std       $08,s
                    subd      #$FFFF
                    ble       L1F84
                    ldd       $0883,y
                    pshs      d
                    jsr       [$06,s]
                    leas      $02,s
                    bra       L1F6B

L1F84               puls      pc,u
L1F86               pshs      u
                    ldd       $086b,y
                    pshs      d
                    ldd       $06,s
                    pshs      d
                    lbsr      $1FB2
L1F95               leas      $04,s
                    puls      pc,u
L1F99               pshs      u
                    ldd       $04,s
                    ldx       $086b,y
                    leax      $01,x
                    stx       $086b,y
                    stb       -$01,x
                    puls      pc,u
L1FAB               blt       L1FE0
                    leas      -$09,y
                    pshu      y,x,dp
                    neg       $0034
                    nega
                    ldu       $06,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$22
                    cmpd      #$8002
                    beq       L1FD6
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    lbne      L20EC
                    pshs      u
                    lbsr      L231E
                    leas      $02,s
L1FD6               ldd       $06,u
                    clra
                    andb      #$04
                    beq       L2012
                    ldd       #$0001
L1FE0               pshs      d
                    leax      $07,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L1FF7
                    leax      L26C7,pcr
                    bra       L1FFB

L1FF7               leax      L26AE,pcr
L1FFB               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    leas      $06,s
                    cmpd      #$FFFF
                    bne       L2053
                    ldd       $06,u
                    orb       #$20
                    std       $06,u
                    lbra      L20EC

L2012               ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L2022
                    pshs      u
                    lbsr      L2107
                    leas      $02,s
L2022               ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L2048
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2053
                    ldd       $04,s
                    cmpd      #$000D
                    bne       L2053
L2048               pshs      u
                    lbsr      L2107
                    std       ,s++
                    lbne      L20EC
L2053               ldd       $04,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    ldd       #$0008
                    lbsr      L2560
                    pshs      d
                    lbsr      $1FB2
                    leas      $04,s
                    ldd       $06,s
                    pshs      d
                    pshs      u
                    lbsr      $1FB2
                    lbra      L21C1

L207A               pshs      u,d
                    leau      $0445,y
                    clra
                    clrb
                    std       ,s
L2084               ldd       ,s
                    addd      #$0001
                    std       ,s
                    subd      #$0001
                    cmpd      #$0010
                    bge       L20A0
                    tfr       u,d
                    leau      $0d,u
                    pshs      d
                    bsr       L20A2
                    leas      $02,s
                    bra       L2084

L20A0               puls      pc,u,x
L20A2               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    cmpu      #$0000
                    beq       L20B2
                    ldd       $06,u
                    bne       L20B7
L20B2               ldd       #$FFFF
                    puls      pc,u,x
L20B7               ldd       $06,u
                    clra
                    andb      #$02
                    beq       L20C6
                    pshs      u
                    bsr       L20DB
                    leas      $02,s
                    bra       L20C8

L20C6               clra
                    clrb
L20C8               std       ,s
                    ldd       $08,u
                    pshs      d
                    lbsr      L2610
                    leas      $02,s
                    clra
                    clrb
                    std       $06,u
                    ldd       ,s
                    puls      pc,u,x
L20DB               pshs      u
                    ldu       $04,s
                    beq       L20EC
                    ldd       $06,u
                    clra
                    andb      #$22
                    cmpd      #$0002
                    beq       L20F1
L20EC               ldd       #$FFFF
                    puls      pc,u
L20F1               ldd       $06,u
                    anda      #$80
                    clrb
                    std       -$02,s
                    bne       L2101
                    pshs      u
                    lbsr      L231E
                    leas      $02,s
L2101               pshs      u
                    bsr       L2107
                    puls      pc,u,x
L2107               pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L2139
                    ldd       ,u
                    cmpd      $04,u
                    beq       L2139
                    clra
                    clrb
                    pshs      d
                    pshs      u
                    lbsr      L21C5
                    leas      $02,s
                    ldd       $02,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L26D7
                    leas      $08,s
L2139               ldd       ,u
                    subd      $02,u
                    std       $02,s
                    lbeq      L21B1
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    lbeq      L21B1
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2188
                    ldd       $02,u
L2157               std       ,u
                    ldd       $02,s
                    lbeq      L21B1
                    ldd       $02,s
                    pshs      d
                    ldd       ,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L26C7
                    leas      $06,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L217C
                    leax      $04,s
                    bra       L21A0

L217C               ldd       $02,s
                    subd      ,s
                    std       $02,s
                    ldd       ,u
                    addd      ,s
                    bra       L2157

L2188               ldd       $02,s
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    lbsr      L26AE
                    leas      $06,s
                    cmpd      $02,s
                    beq       L21B1
                    bra       L21A2

L21A0               leas      -$04,x
L21A2               ldd       $06,u
                    orb       #$20
                    std       $06,u
                    ldd       $04,u
                    std       ,u
                    ldd       #$FFFF
                    bra       L21C1

L21B1               ldd       $06,u
                    ora       #$01
                    std       $06,u
                    ldd       $02,u
                    std       ,u
                    addd      $0b,u
                    std       $04,u
                    clra
                    clrb
L21C1               leas      $04,s
                    puls      pc,u
L21C5               pshs      u
                    puls      pc,u
L21C9               pshs      u
                    ldu       $04,s
                    beq       L2215
                    ldd       $06,u
                    anda      #$01
                    clrb
                    std       -$02,s
                    bne       L2215
                    ldd       ,u
                    cmpd      $04,u
                    bcc       L21F0
                    ldd       ,u
                    addd      #$0001
                    std       ,u
                    subd      #$0001
                    tfr       d,x
                    ldb       ,x
                    clra
                    bra       L21F7

L21F0               pshs      u
                    lbsr      L2264
                    leas      $02,s
L21F7               puls      pc,u
                    pshs      u
                    ldu       $06,s
                    beq       L2215
                    ldd       $06,u
                    clra
                    andb      #$01
                    beq       L2215
                    ldd       $04,s
                    cmpd      #$FFFF
                    beq       L2215
                    ldd       ,u
                    cmpd      $02,u
                    bhi       L221A
L2215               ldd       #$FFFF
                    puls      pc,u
L221A               ldd       ,u
                    addd      #$FFFF
                    std       ,u
                    tfr       d,x
                    ldd       $04,s
                    stb       ,x
                    ldd       $04,s
                    puls      pc,u
                    pshs      u
                    ldu       $04,s
                    leas      -$04,s
                    pshs      u
                    lbsr      L21C9
                    leas      $02,s
                    std       $02,s
                    cmpd      #$FFFF
                    beq       L224F
                    pshs      u
                    lbsr      L21C9
                    leas      $02,s
                    std       ,s
                    cmpd      #$FFFF
                    bne       L2254
L224F               ldd       #$FFFF
                    bra       L2260

L2254               ldd       $02,s
                    pshs      d
                    ldd       #$0008
                    lbsr      L2577
                    addd      ,s
L2260               leas      $04,s
                    puls      pc,u
L2264               pshs      u
                    ldu       $04,s
                    leas      -$02,s
                    ldd       $06,u
                    anda      #$80
                    andb      #$31
                    cmpd      #$8001
                    beq       L228D
                    ldd       $06,u
                    clra
                    andb      #$31
                    cmpd      #$0001
                    beq       L2286
                    ldd       #$FFFF
                    puls      pc,u,x
L2286               pshs      u
                    lbsr      L231E
                    leas      $02,s
L228D               leax      $0445,y
                    pshs      x
                    cmpu      ,s++
                    bne       L22AA
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L22AA
                    leax      $0452,y
                    pshs      x
                    lbsr      L20DB
                    leas      $02,s
L22AA               ldd       $06,u
                    clra
                    andb      #$08
                    beq       L22D6
                    ldd       $0b,u
                    pshs      d
                    ldd       $02,u
                    pshs      d
                    ldd       $08,u
                    pshs      d
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L22CA
                    leax      L269E,pcr
                    bra       L22CE

L22CA               leax      L267D,pcr
L22CE               tfr       x,d
                    tfr       d,x
                    jsr       ,x
                    bra       L22E8

L22D6               ldd       #$0001
                    pshs      d
                    leax      $0a,u
                    stx       $02,u
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    lbsr      L267D
L22E8               leas      $06,s
                    std       ,s
                    ldd       ,s
                    bgt       L230B
                    ldd       $06,u
                    pshs      d
                    ldd       $02,s
                    beq       L22FD
                    ldd       #$0020
                    bra       L2300

L22FD               ldd       #$0010
L2300               ora       ,s+
                    orb       ,s+
                    std       $06,u
                    ldd       #$FFFF
                    puls      pc,u,x
L230B               ldd       $02,u
                    addd      #$0001
                    std       ,u
                    ldd       $02,u
                    addd      ,s
                    std       $04,u
                    ldb       [$02,u]
                    clra
                    puls      pc,u,x
L231E               pshs      u
                    ldu       $04,s
                    ldd       $06,u
                    clra
                    andb      #$C0
                    bne       L2356
                    leas      -$20,s
                    leax      ,s
                    pshs      x
                    ldd       $08,u
                    pshs      d
                    clra
                    clrb
                    pshs      d
                    lbsr      L2592
                    leas      $06,s
                    ldd       $06,u
                    pshs      d
                    ldb       $02,s
                    bne       L234A
                    ldd       #$0040
                    bra       L234D

L234A               ldd       #$0080
L234D               ora       ,s+
                    orb       ,s+
                    std       $06,u
                    leas      $20,s
L2356               ldd       $06,u
                    ora       #$80
                    std       $06,u
                    clra
                    andb      #$0C
                    beq       L2363
                    puls      pc,u
L2363               ldd       $0b,u
L2365               bne       L2378
                    ldd       $06,u
                    clra
                    andb      #$40
                    beq       L2373
                    ldd       #$0080
                    bra       L2376

L2373               ldd       #$0100
L2376               std       $0b,u
L2378               ldd       $02,u
                    bne       L238D
                    ldd       $0b,u
                    pshs      d
                    lbsr      L2795
                    leas      $02,s
                    std       $02,u
                    cmpd      #$FFFF
                    beq       L2395
L238D               ldd       $06,u
                    orb       #$08
                    std       $06,u
                    bra       L23A4

L2395               ldd       $06,u
                    orb       #$04
                    std       $06,u
                    leax      $0a,u
                    stx       $02,u
                    ldd       #$0001
                    std       $0b,u
L23A4               ldd       $02,u
                    addd      $0b,u
                    std       $04,u
                    std       ,u
                    puls      pc,u
L23AE               pshs      u
                    ldb       $05,s
                    sex
                    tfr       d,x
                    bra       L23D4

L23B7               ldd       [$06,s]
                    addd      #$0004
                    std       [$06,s]
                    leax      >L23EB,pcr
                    bra       L23D0

L23C6               ldb       $05,s
                    stb       $0443,y
                    leax      $0442,y
L23D0               tfr       x,d
                    puls      pc,u
L23D4               cmpx      #$0064
                    beq       L23B7
                    cmpx      #$006F
                    lbeq      L23B7
                    cmpx      #$0078
                    lbeq      L23B7
                    bra       L23C6
                    puls      pc,u
L23EB               neg       $0034
                    nega
                    leax      >L23F6,pcr
                    tfr       x,d
                    puls      pc,u
L23F6               neg       $0034
                    nega
                    ldu       $04,s
L23FB               ldb       ,u+
                    bne       L23FB
                    tfr       u,d
                    subd      $04,s
                    addd      #$FFFF
                    puls      pc,u
L2408               pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L2412               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L2412
                    ldd       $06,s
                    puls      pc,u,x
                    pshs      u
                    ldu       $06,s
                    leas      -$02,s
                    ldd       $06,s
                    std       ,s
L242C               ldx       ,s
                    leax      $01,x
                    stx       ,s
                    ldb       -$01,x
                    bne       L242C
                    ldd       ,s
                    addd      #$FFFF
                    std       ,s
L243D               ldb       ,u+
                    ldx       ,s
                    leax      $01,x
                    stx       ,s
                    stb       -$01,x
                    bne       L243D
                    ldd       $06,s
                    puls      pc,u,x
L244D               pshs      u
                    ldu       $04,s
L2451               ldb       ,u
                    sex
                    pshs      d
                    ldb       [$08,s]
                    sex
                    cmpd      ,s++
                    bne       L2471
                    ldx       $06,s
                    leax      $01,x
                    stx       $06,s
                    ldb       -$01,x
                    bne       L246D
                    clra
                    clrb
                    puls      pc,u
L246D               leau      $01,u
                    bra       L2451

L2471               ldb       [$06,s]
                    sex
                    pshs      d
                    ldb       ,u
                    sex
                    subd      ,s++
                    puls      pc,u
L247E               tsta
                    bne       L2493
                    tst       $02,s
                    bne       L2493
                    lda       $03,s
                    mul
                    ldx       ,s
                    stx       $02,s
                    ldx       #$0000
                    std       ,s
                    puls      pc,d
L2493               pshs      d
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
                    bcc       L24B0
                    inc       ,s
L24B0               lda       $04,s
                    ldb       $09,s
                    mul
                    addd      $01,s
                    std       $01,s
                    bcc       L24BD
                    inc       ,s
L24BD               lda       $04,s
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

L24D1               subd      #$0000
                    beq       L24E0
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    bra       L250E

L24E0               puls      d
                    std       ,s
                    ldd       #$002D
                    lbra      L2583

L24EA               subd      #$0000
                    beq       L24E0
                    pshs      d
                    leas      -$02,s
                    clr       ,s
                    clr       $01,s
                    tsta
                    bpl       L2502
                    nega
                    negb
                    sbca      #$00
                    inc       $01,s
                    std       $02,s
L2502               ldd       $06,s
                    bpl       L250E
                    nega
                    negb
                    sbca      #$00
                    com       $01,s
                    std       $06,s
L250E               lda       #$01
L2510               inca
                    asl       $03,s
                    rol       $02,s
                    bpl       L2510
                    sta       ,s
                    ldd       $06,s
                    clr       $06,s
                    clr       $07,s
L251F               subd      $02,s
                    bcc       L2529
                    addd      $02,s
                    andcc     #$FE
                    bra       L252B

L2529               orcc      #$01
L252B               rol       $07,s
                    rol       $06,s
                    lsr       $02,s
                    ror       $03,s
                    dec       ,s
                    bne       L251F
                    std       $02,s
                    tst       $01,s
                    beq       L2545
                    ldd       $06,s
                    nega
                    negb
                    sbca      #$00
                    std       $06,s
L2545               ldx       $04,s
                    ldd       $06,s
                    std       $04,s
                    stx       $06,s
                    ldx       $02,s
                    ldd       $04,s
                    leas      $06,s
                    rts
                    tstb
                    beq       L256A
L2557               asr       $02,s
                    ror       $03,s
                    decb
                    bne       L2557
                    bra       L256A

L2560               tstb
                    beq       L256A
L2563               lsr       $02,s
                    ror       $03,s
                    decb
                    bne       L2563
L256A               ldd       $02,s
                    pshs      d
                    ldd       $02,s
                    std       $04,s
                    ldd       ,s
                    leas      $04,s
                    rts

L2577               tstb
                    beq       L256A
L257A               asl       $03,s
                    rol       $02,s
                    decb
                    bne       L257A
                    bra       L256A

L2583               std       $0563,y
                    pshs      y,b
                    os9       F$ID
                    puls      y,b
                    os9       F$Send
                    rts

L2592               lda       $05,s
                    ldb       $03,s
                    beq       L25C5
                    cmpb      #$01
                    beq       L25C7
                    cmpb      #$06
                    beq       L25C7
                    cmpb      #$02
                    beq       L25AD
                    cmpb      #$05
                    beq       L25AD
                    ldb       #$D0
                    lbra      L27C2

L25AD               pshs      u
                    os9       I$GetStt
                    bcc       L25B9
                    puls      u
                    lbra      L27C2

L25B9               stx       [$08,s]
                    ldx       $08,s
                    stu       $02,x
                    puls      u
                    clra
                    clrb
                    rts

L25C5               ldx       $06,s
L25C7               os9       I$GetStt
                    lbra      L27CB
                    lda       $05,s
                    ldb       $03,s
                    beq       L25DC
                    cmpb      #$02
                    beq       L25E4
                    ldb       #$D0
                    lbra      L27C2

L25DC               ldx       $06,s
                    os9       I$SetStt
                    lbra      L27CB

L25E4               pshs      u
                    ldx       $08,s
                    ldu       $0a,s
                    os9       I$SetStt
                    puls      u
                    lbra      L27CB
                    ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    bcs       L25FE
                    os9       I$Close
L25FE               lbra      L27CB

L2601               ldx       $02,s
                    lda       $05,s
                    os9       I$Open
                    lbcs      L27C2
                    tfr       a,b
                    clra
                    rts

L2610               lda       $03,s
                    os9       I$Close
                    lbra      L27CB
                    ldx       $02,s
                    ldb       $05,s
                    os9       I$MakDir
                    lbra      L27CB

L2622               ldx       $02,s
                    lda       $05,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0b
                    os9       I$Create
                    bcs       L2635
L2631               tfr       a,b
                    clra
                    rts

L2635               cmpb      #$DA
                    lbne      L27C2
                    lda       $05,s
                    bita      #$80
                    lbne      L27C2
                    anda      #$07
                    ldx       $02,s
                    os9       I$Open
                    lbcs      L27C2
                    pshs      u,a
                    ldx       #$0000
                    leau      ,x
                    ldb       #$02
                    os9       I$SetStt
                    puls      u,a
                    bcc       L2631
                    pshs      b
                    os9       I$Close
                    puls      b
                    lbra      L27C2
                    ldx       $02,s
                    os9       I$Delete
                    lbra      L27CB
                    lda       $03,s
                    os9       I$Dup
                    lbcs      L27C2
                    tfr       a,b
                    clra
                    rts

L267D               pshs      y
                    ldx       $06,s
                    lda       $05,s
                    ldy       $08,s
                    pshs      y
                    os9       I$Read
L268B               bcc       L269A
                    cmpb      #$D3
                    bne       L2695
                    clra
                    clrb
                    puls      pc,y,x
L2695               puls      y,x
                    lbra      L27C2

L269A               tfr       y,d
                    puls      pc,y,x
L269E               pshs      y
                    lda       $05,s
                    ldx       $06,s
                    ldy       $08,s
                    pshs      y
                    os9       I$ReadLn
                    bra       L268B

L26AE               pshs      y
                    ldy       $08,s
                    beq       L26C3
                    lda       $05,s
                    ldx       $06,s
                    os9       I$Write
L26BC               bcc       L26C3
                    puls      y
                    lbra      L27C2

L26C3               tfr       y,d
                    puls      pc,y
L26C7               pshs      y
                    ldy       $08,s
                    beq       L26C3
                    lda       $05,s
                    ldx       $06,s
                    os9       I$WritLn
                    bra       L26BC

L26D7               pshs      u
                    ldd       $0a,s
                    bne       L26E5
                    ldu       #$0000
                    ldx       #$0000
                    bra       L2719

L26E5               cmpd      #$0001
                    beq       L2710
                    cmpd      #$0002
                    beq       L2705
                    ldb       #$F7
L26F3               clra
                    std       $0563,y
                    ldd       #$FFFF
                    leax      $0557,y
                    std       ,x
                    std       $02,x
                    puls      pc,u
L2705               lda       $05,s
                    ldb       #$02
                    os9       I$GetStt
                    bcs       L26F3
                    bra       L2719

L2710               lda       $05,s
                    ldb       #$05
                    os9       I$GetStt
                    bcs       L26F3
L2719               tfr       u,d
                    addd      $08,s
                    std       $0559,y
                    tfr       d,u
                    tfr       x,d
                    adcb      $07,s
                    adca      $06,s
                    bmi       L26F3
                    tfr       d,x
                    std       $0557,y
                    lda       $05,s
                    os9       I$Seek
                    bcs       L26F3
                    leax      $0557,y
                    puls      pc,u
L273E               ldd       $0555,y
                    pshs      d
                    ldd       $04,s
                    cmpd      $0885,y
                    bcs       L2772
                    addd      $0555,y
                    pshs      y
                    subd      ,s
                    os9       F$Mem
                    tfr       y,d
                    puls      y
                    bcc       L2764
                    ldd       #$FFFF
                    leas      $02,s
                    rts

L2764               std       $0555,y
                    addd      $0885,y
                    subd      ,s
                    std       $0885,y
L2772               leas      $02,s
                    ldd       $0885,y
                    pshs      d
                    subd      $04,s
                    std       $0885,y
                    ldd       $0555,y
                    subd      ,s++
                    pshs      d
                    clra
                    ldx       ,s
L278B               sta       ,x+
                    cmpx      $0555,y
                    bcs       L278B
                    puls      pc,d
L2795               ldd       $02,s
                    addd      $055f,y
                    bcs       L27BE
                    cmpd      $0561,y
                    bcc       L27BE
                    pshs      d
                    ldx       $055f,y
                    clra
L27AB               cmpx      ,s
                    bcc       L27B3
                    sta       ,x+
                    bra       L27AB

L27B3               ldd       $055f,y
                    puls      x
                    stx       $055f,y
                    rts

L27BE               ldd       #$FFFF
                    rts

L27C2               clra
                    std       $0563,y
                    ldd       #$FFFF
                    rts

L27CB               bcs       L27C2
                    clra
                    clrb
                    rts

exit                lbsr      L27DB
                    lbsr      L207A
L27D6               ldd       $02,s
                    os9       F$Exit
L27DB               rts

* ------------------------------------------------------------------
* L27DC - cc1-style init image for the work block (see _start):
* rts stub + count/block table + relocation dirs + module-name string.
* ------------------------------------------------------------------
L27DC               fcb       $00,$07,$00,$00,$00,$00,$00,$00 init table / work-block image
                    fcb       $00,$04,$F2,$00,$00,$01
                    fcb       $2C
                    fcb       $10
                    fcb       $52
                    fcb       $10
                    fcb       $55
                    fcb       $10
                    fcb       $58
                    fcb       $10
                    fcb       $5B
                    fcb       $10
                    fcb       $5E
                    fcb       $10
                    fcb       $61
                    fcb       $10
                    fcb       $64
                    fcb       $10
                    fcb       $67
                    fcb       $10
                    fcb       $6A
                    fcb       $10
                    fcb       $6D
                    fcb       $10
                    fcb       $70
                    fcb       $10
                    fcb       $73
                    fcb       $10
                    fcb       $76
                    fcb       $10
                    fcb       $79
                    fcb       $10
                    fcb       $7C
                    fcb       $10,$7F,$10,$82,$10,$85
                    fcb       $64
                    fcb       $00
                    fcb       $78
                    fcb       $00
                    fcb       $79
                    fcb       $00
                    fcb       $75
                    fcb       $00
                    fcb       $64,$2C,$78
                    fcb       $00
                    fcb       $64,$2C,$79
                    fcb       $00
                    fcb       $64,$2C,$75
                    fcb       $00
                    fcc       /d,x,u/
                    fcb       $00
                    fcc       /d,x,y,u/
                    fcb       $00
                    fcc       /x,u,pc/
                    fcb       $00
                    fcb       $79,$2C,$64
                    fcb       $00
                    fcb       $79,$2C,$75
                    fcb       $00
                    fcb       $75,$2C,$64
                    fcb       $00
                    fcc       /u,pc/
                    fcb       $00
                    fcc       /clra/
                    fcb       $00
                    fcc       /cmpb/
                    fcb       $00
                    fcc       /cmpd/
                    fcb       $00
                    fcc       /cmpx/
                    fcb       $00
                    fcc       /cmpy/
                    fcb       $00
                    fcc       /cmpu/
                    fcb       $00
                    fcb       $6C,$64,$62
                    fcb       $00
                    fcb       $6C,$64,$64
                    fcb       $00
                    fcb       $6C,$64,$78
                    fcb       $00
                    fcb       $6C,$64,$79
                    fcb       $00
                    fcb       $6C,$64,$75
                    fcb       $00
                    fcb       $73,$74,$62
                    fcb       $00
                    fcb       $73,$74,$64
                    fcb       $00
                    fcb       $73,$74,$78
                    fcb       $00
                    fcb       $73,$74,$79
                    fcb       $00
                    fcb       $73,$74,$75
                    fcb       $00
                    fcc       /pshs/
                    fcb       $00
                    fcc       /puls/
                    fcb       $00
                    fcc       /leax/
                    fcb       $00
                    fcc       /leay/
                    fcb       $00
                    fcc       /leau/
                    fcb       $00
                    fcc       /leas/
                    fcb       $00
                    fcb       $73,$65,$78
                    fcb       $00
                    fcb       $74,$66,$72
                    fcb       $00
                    fcb       $23,$30
                    fcb       $00
                    fcb       $32,$2C,$78
                    fcb       $00
                    fcb       $31,$2C,$78
                    fcb       $00
                    fcb       $30,$2C,$78
                    fcb       $00
                    fcc       /-1,x/
                    fcb       $00
                    fcc       /-2,x/
                    fcb       $00
                    fcb       $32,$2C,$79
                    fcb       $00
                    fcb       $31,$2C,$79
                    fcb       $00
                    fcb       $30,$2C,$79
                    fcb       $00
                    fcc       /-1,y/
                    fcb       $00
                    fcc       /-2,y/
                    fcb       $00
                    fcb       $32,$2C,$75
                    fcb       $00
                    fcb       $31,$2C,$75
                    fcb       $00
                    fcb       $30,$2C,$75
                    fcb       $00
                    fcc       /-1,u/
                    fcb       $00
                    fcc       /-2,u/
                    fcb       $00
                    fcb       $32,$2C,$73
                    fcb       $00
                    fcb       $30,$2C,$73
                    fcb       $00
                    fcc       /-2,s/
                    fcb       $00
                    fcb       $23,$3C
                    fcb       $00,$00,$02,$00,$BB,$00,$00,$00
                    fcb       $A7,$00,$01,$00,$01,$00,$01,$00
                    fcb       $00,$00,$02,$00,$BF,$00,$00,$00
                    fcb       $AB,$00,$01,$00,$01,$00,$01,$00
                    fcb       $00,$00,$02,$00,$B7,$00,$00,$00
                    fcb       $A3,$00,$01,$00,$01,$00,$01,$00
                    fcb       $00,$00,$02,$00,$A7,$00,$00,$00
                    fcb       $BB,$00,$01,$00,$01,$00,$01,$00
                    fcb       $00,$00,$02,$00,$AB,$00,$00,$00
                    fcb       $BF,$00,$01,$00,$01,$00,$01,$00
                    fcb       $00,$00,$01,$00,$ED,$00
                    fcb       $74
                    fcb       $00,$CB,$00
                    fcb       $4B
                    fcb       $00,$02,$00
                    fcb       $4F
                    fcb       $00,$00,$00,$01,$00,$ED,$00
                    fcb       $7C
                    fcb       $00,$CB,$00
                    fcb       $4B
                    fcb       $00,$02,$00
                    fcb       $51
                    fcb       $00,$00,$00,$02,$00,$CB,$00
                    fcb       $4D
                    fcb       $00,$CB,$00
                    fcb       $4B
                    fcb       $00,$01,$00
                    fcb       $53
                    fcb       $00,$00,$00,$02,$00,$CB,$00
                    fcb       $51
                    fcb       $00,$CB,$00
                    fcb       $4B
                    fcb       $00,$01,$00
                    fcb       $5B
                    fcb       $00,$00,$00,$02,$00,$CB,$00
                    fcb       $4F
                    fcb       $00,$CB,$00
                    fcb       $4B
                    fcb       $00,$01,$00
                    fcb       $57
                    fcb       $00,$00,$00,$02,$00,$CB,$00
                    fcb       $51
                    fcb       $00,$CB,$00
                    fcb       $4F
                    fcb       $00,$01,$00
                    fcb       $78
                    fcb       $00,$00,$00,$02,$00,$A7,$00,$00
                    fcb       $00,$8F,$00,$F1,$00,$01,$00,$01
                    fcb       $00,$00,$00,$02,$00,$AB,$00,$00
                    fcb       $00,$94,$00,$F1,$00,$01,$00,$01
                    fcb       $00,$00,$00,$02,$00,$AF,$00,$00
                    fcb       $00,$99,$00,$F1,$00,$01,$00,$01
                    fcb       $00,$00,$00,$02,$00,$B3,$00,$00
                    fcb       $00,$9E,$00,$F1,$00,$01,$00,$01
                    fcb       $00,$00,$00,$02,$00,$C3,$00,$00
                    fcb       $00,$99,$00,$F1,$00,$01,$00,$01
                    fcb       $00,$00,$00,$02,$00,$C7,$00,$00
                    fcb       $00,$9E,$00,$F1,$00,$01,$00,$01
                    fcb       $00,$00,$00,$02,$00,$A3,$00,$00
                    fcb       $00,$B7,$00,$01,$00,$01,$00,$01
                    fcb       $00,$00,$00,$01,$00,$E9,$00,$00
                    fcb       $00,$85,$00,$00,$00,$02,$00,$00
                    fcb       $00,$00,$00,$02,$00,$D5,$00,$F8
                    fcb       $00,$00,$01,$00,$00,$02,$17,$A9
                    fcb       $00,$00,$00,$02,$00,$DA,$01,$0E
                    fcb       $00,$00,$01,$16,$00,$02,$17,$AD
                    fcb       $00,$00,$00,$02,$00,$DF,$01
                    fcb       $24
                    fcb       $00,$00,$01
                    fcb       $2C
                    fcb       $00,$02,$17,$B1,$00,$00,$00,$02
                    fcb       $00,$D5,$01,$00,$00,$00,$00,$FC
                    fcb       $00,$02,$17,$B5,$00,$00,$00,$02
                    fcb       $00,$DA,$01,$16,$00,$00,$01,$12
                    fcb       $00,$02,$17,$B9,$00,$00,$00,$02
                    fcb       $00,$DF,$01
                    fcb       $2C
                    fcb       $00,$00,$01
                    fcb       $28
                    fcb       $00,$02,$17,$BD,$00,$00,$00,$02
                    fcb       $00,$D5,$00,$F4,$00,$00,$01,$05
                    fcb       $00,$02,$17,$C1,$00,$00,$00,$02
                    fcb       $00,$DA,$01,$0A,$00,$00,$01,$1B
                    fcb       $00,$02,$17,$C6,$00,$00,$00,$02
                    fcb       $00,$DF,$01
                    fcb       $20
                    fcb       $00,$00,$01
                    fcb       $31
                    fcb       $00,$02,$17,$CB,$00,$00,$00,$02
                    fcb       $00,$D5,$01,$05,$00,$00,$00,$FC
                    fcb       $00,$02,$17,$D0,$00,$00,$00,$02
                    fcb       $00,$DA,$01,$1B,$00,$00,$01,$12
                    fcb       $00,$02,$17,$D5,$00,$00,$00,$02
                    fcb       $00,$DF,$01
                    fcb       $31
                    fcb       $00,$00,$01
                    fcb       $28
                    fcb       $00,$02,$17,$DA,$00,$00,$00,$02
                    fcb       $00,$E9,$00,$00,$00,$8F,$01
                    fcb       $43
                    fcb       $00,$8A,$00,$02,$00,$00,$00,$02
                    fcb       $00,$85,$00,$00,$00,$8F,$01
                    fcb       $43
                    fcb       $00,$8A,$00,$02,$00,$00,$00,$02
                    fcb       $00,$E4,$01
                    fcb       $36
                    fcb       $00,$BB,$01
                    fcb       $3E
                    fcb       $00,$02,$17,$DF,$00,$00,$00,$02
                    fcb       $00,$E4,$01
                    fcb       $36
                    fcb       $00,$CB,$00
                    fcb       $4B
                    fcb       $00,$BB,$01
                    fcb       $3A
                    fcb       $00,$00,$00,$02,$00,$CB,$00
                    fcb       $51
                    fcb       $00,$E4,$01
                    fcb       $3E
                    fcb       $00,$01,$00
                    fcb       $5B
                    fcb       $00,$00,$00,$02,$00,$CB,$00
                    fcb       $51
                    fcb       $00,$E4,$17,$E4,$00,$01,$00
                    fcb       $5F
                    fcb       $00,$00,$00,$02,$00,$CB,$00
                    fcb       $51
                    fcb       $00,$E4,$17,$E9,$00,$01,$00
                    fcb       $65
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $01,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$02,$00
                    fcc       /88((((((((/
                    fcb       $00,$00,$00,$00,$00,$00,$02
                    fcc       /""""""/
                    fcb       $02,$02,$02,$02,$02,$02,$02,$02
                    fcb       $02,$02,$02,$02,$02,$02,$02,$02
                    fcb       $02,$02,$02,$02,$00,$00,$00,$00
                    fcb       $02,$00,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$00,$00,$00,$00
                    fcb       $00
                    fcb       $27
                    fcb       $10,$03,$E8,$00
                    fcb       $64
                    fcb       $00,$0A,$04
                    fcb       $40,$6C,$78
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $01,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$02,$00,$01
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00
                    fcb       $42
                    fcb       $00,$02,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00,$00
                    fcb       $21
                    fcb       $02,$C2,$02,$B2,$02,$A2,$02,$92
                    fcb       $02,$82,$03
                    fcb       $32
                    fcb       $03
                    fcb       $22
                    fcb       $03,$12,$03,$02,$02,$F2,$02,$E2
                    fcb       $02,$D2,$00
                    fcb       $2D
                    fcb       $00
                    fcb       $2B
                    fcb       $00
                    fcb       $29
                    fcb       $00
                    fcb       $27
                    fcb       $03,$9E,$03,$8E,$03
                    fcb       $62
                    fcb       $00
                    fcb       $3B
                    fcb       $00
                    fcb       $39
                    fcb       $00
                    fcb       $37
                    fcb       $00
                    fcb       $35
                    fcb       $00
                    fcb       $33
                    fcb       $00
                    fcb       $31
                    fcb       $00
                    fcb       $2F
                    fcb       $00
                    fcb       $49
                    fcb       $00
                    fcb       $47
                    fcb       $00
                    fcb       $45
                    fcb       $00
                    fcb       $43
                    fcb       $00
                    fcb       $41
                    fcb       $00
                    fcb       $3F
                    fcb       $00
                    fcb       $3D
                    fcb       $00,$82,$01
                    fcb       $58
                    fcb       $01
                    fcb       $4C
                    fcb       $01
                    fcb       $48
                    fcb       $04
                    fcb       $40
                    fcb       $01,$8C,$01,$88,$01
                    fcb       $7C
                    fcb       $01
                    fcb       $78
                    fcb       $01
                    fcb       $6C
                    fcb       $01
                    fcb       $68
                    fcb       $01
                    fcb       $5C
                    fcb       $01,$AA,$01,$A8,$01,$A2,$01,$9E
                    fcb       $01,$9C,$01,$9A,$01,$98,$01,$BE
                    fcb       $01,$BC,$01,$BA,$01,$B8,$01,$B2
                    fcb       $01,$AE,$01,$AC,$01,$D8,$01,$D2
                    fcb       $01,$CE,$01,$CC,$01,$CA,$01,$C8
                    fcb       $01,$C2,$01,$EC,$01,$EA,$01,$E8
                    fcb       $01,$E2,$01,$DE,$01,$DC,$01,$DA
                    fcb       $02,$0C,$02,$08,$01,$FE,$01,$FC
                    fcb       $01,$F8,$01,$F2,$01,$EE,$02
                    fcb       $2E
                    fcb       $02
                    fcb       $2C
                    fcb       $02
                    fcb       $28
                    fcb       $02,$1E,$02,$1C,$02,$18,$02,$0E
                    fcb       $02
                    fcb       $58
                    fcb       $02
                    fcb       $4E
                    fcb       $02
                    fcb       $4C
                    fcb       $02
                    fcb       $48
                    fcb       $02
                    fcb       $3E
                    fcb       $02
                    fcb       $3C
                    fcb       $02
                    fcb       $38
                    fcb       $02,$88,$02
                    fcb       $7E
                    fcb       $02
                    fcb       $7A
                    fcb       $02
                    fcb       $78
                    fcb       $02
                    fcb       $6C
                    fcb       $02
                    fcb       $68
                    fcb       $02
                    fcb       $5C
                    fcb       $02,$AA,$02,$A8,$02,$9E,$02,$9A
                    fcb       $02,$98,$02,$8E,$02,$8A,$02,$CE
                    fcb       $02,$CA,$02,$C8,$02,$BE,$02,$BA
                    fcb       $02,$B8,$02,$AE,$02,$F8,$02,$EE
                    fcb       $02,$EA,$02,$E8,$02,$DE,$02,$DA
                    fcb       $02,$D8,$03,$1A,$03,$18,$03,$0E
                    fcb       $03,$0A,$03,$08,$02,$FE,$02,$FA
                    fcb       $03
                    fcb       $3E
                    fcb       $03
                    fcb       $3C
                    fcb       $03
                    fcb       $38
                    fcb       $03
                    fcb       $2E
                    fcb       $03
                    fcb       $2A
                    fcb       $03
                    fcb       $28
                    fcb       $03,$1E,$03
                    fcb       $5A
                    fcb       $03
                    fcb       $58
                    fcb       $03
                    fcb       $50
                    fcb       $03
                    fcb       $4E
                    fcb       $03
                    fcb       $4C
                    fcb       $03
                    fcb       $48
                    fcb       $03
                    fcb       $40
                    fcb       $03
                    fcb       $70
                    fcb       $03
                    fcb       $6E
                    fcb       $03
                    fcb       $6C
                    fcb       $03
                    fcb       $6A
                    fcb       $03
                    fcb       $68
                    fcb       $03
                    fcb       $5E
                    fcb       $03
                    fcb       $5C
                    fcb       $03,$88,$03,$82,$03
                    fcb       $7E
                    fcb       $03
                    fcb       $7C
                    fcb       $03
                    fcb       $7A
                    fcb       $03
                    fcb       $78
                    fcb       $03
                    fcb       $72
                    fcb       $03,$A2,$03,$9C,$03,$9A,$03,$98
                    fcb       $03,$92,$03,$8C,$03,$8A
                    fcc       /c.opt/
                    fcb       $00
                    emod
eom                 equ       *
                    end
