********************************************************************
* CC3Disk - Disto No Halt Super Controller II disk driver
*
* This driver their 'sleep' driver. It is a no halt (multitasking)
* disk driver, but it does not use interrupts. Thus it is safe to use
* this driver with other hardware uses interrupts.
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*  02    Fist disassembled                              tjl 02/08/27

                    nam       CC3Disk
                    ttl       os9 device driver

* Disassembled 02/08/27 11:42:59 by Disasm v1.6 (C) 1988 by RML

* Disto's Super Controller II supports two locations for its
* registers: $FF74 and $FF58

nh_base             equ       $FF74
nh_stat             equ       nh_base
nh_data             equ       nh_base+2

                    ifp1
                    use       defsfile
                    endc
tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $02
                    mod       eom,name,tylg,atrv,start,size
u0000               rmb       1
u0001               rmb       1
u0002               rmb       1
u0003               rmb       1
u0004               rmb       1
u0005               rmb       2
u0007               rmb       1
u0008               rmb       2
u000A               rmb       4
u000E               rmb       1
u000F               rmb       1
u0010               rmb       2
u0012               rmb       1
u0013               rmb       31
u0032               rmb       24
u004A               rmb       6
u0050               rmb       47
u007F               rmb       11
u008A               rmb       28
u00A6               rmb       1
u00A7               rmb       10
u00B1               rmb       13
size                equ       .
                    fcb       $FF
name                equ       *
                    fcs       /CC3Disk/
                    fcb       $A2                 "
start               equ       *
                    lbra      L003C
                    lbra      L0084
                    lbra      L010E
                    lbra      L0081
                    lbra      L030F
                    leay      >u00B1,u
                    ldx       #$0000
                    os9       F$VIRQ
                    os9       F$IRQ
                    clrb
                    stb       >$FF40
                    stb       <u0032
                    rts
L0039               fcb       $00
                    fcb       $01
                    fcb       $09
L003C               clr       >nh_data
                    clr       <u0032
                    ldx       #$FF48
                    lda       #$D0
                    sta       ,x
                    lbsr      L02D9
                    lda       ,x
                    lda       #$FF
                    sta       >u00A7,u
                    ldb       #$04
                    leax      u000F,u
L0057               sta       ,x
                    sta       <$15,x
                    leax      <$26,x
                    decb
                    bne       L0057
                    leax      >L01C0,pcr
                    stx       <D.NMI
                    pshs      u
                    leau      >u00A7,u
                    leay      u000E,u
                    tfr       y,d
                    leay      >L0428,pcr
                    leax      >L0039,pcr
                    os9       F$IRQ
                    puls      u
                    bcs       L0082
L0081               clrb
L0082               rts
L0083               rts
L0084               lbsr      L01E7
                    clr       u0003,u
                    ldd       <u0010,u
                    bne       L00D8
                    bsr       L00D8
                    bcs       L0083
                    lda       <$23,y
                    bita      #$40
                    lbne      L043B
                    ldx       $08,y
                    pshs      y,x
                    ldy       <$1E,y
                    ldb       #$14
L00A5               lda       b,x
                    sta       b,y
                    decb
                    bpl       L00A5
                    lda       <$10,y
                    ldy       $02,s
                    ldb       <$24,y
                    bita      #$02
                    beq       L00BD
                    bitb      #$01
                    beq       L00D3
L00BD               bita      #$04
                    beq       L00C5
                    bitb      #$02
                    beq       L00D3
L00C5               bita      #$01
                    beq       L00D0
                    lda       <$27,y
                    suba      #$02
                    bcs       L00D3
L00D0               clrb
                    puls      pc,y,x
L00D3               comb
                    ldb       #$F9
                    puls      pc,y,x
L00D8               lbsr      L0257
                    bcs       L0083
                    ldb       #$80
                    lda       #$07
                    lbsr      L016C
                    bcc       L00F6
                    ldb       >$FF48
                    clr       >nh_data
                    lda       u0001,u
                    ora       #$08
                    sta       >$FF40
                    lbra      L01E3
L00F6               ldx       $08,y
                    ldb       #$80
                    tst       u0003,u
                    bne       L010B
                    pshs      b
L0100               ldd       >nh_stat
                    std       ,x++
                    dec       ,s
                    bne       L0100
                    puls      b
L010B               andcc     #$FE
                    rts
L010E               lbsr      L01E7
L0111               bsr       L0120
                    bcs       L011F
                    tst       <$28,y
                    bne       L011E
                    bsr       L0144
                    bcs       L0111
L011E               clrb
L011F               rts
L0120               lbsr      L0257
                    bcs       L011F
                    ldx       $08,y
                    lda       #$04
                    sta       >nh_data
                    ldb       #$80
                    pshs      b
L0130               ldd       ,x++
                    std       >nh_stat
                    dec       ,s
                    bne       L0130
                    puls      b
                    ldb       #$A0
                    lda       #$06
                    bsr       L016C
                    lbra      L01C4
L0144               lda       u0004,u
                    pshs      a
                    clr       u0004,u
                    lda       #$FF
                    sta       u0003,u
                    lbsr      L00D8
                    bcs       L0167
                    pshs      b
L0155               ldd       >nh_stat
                    cmpd      ,x++
                    bne       L0163
                    dec       ,s
                    bne       L0155
                    bra       L0165
L0163               orcc      #$01
L0165               puls      b
L0167               puls      a
                    sta       u0004,u
                    rts
L016C               std       u0008,u
L016E               ldd       u0008,u
                    bsr       L018D
                    bcs       L0179
                    lbsr      L01C4
                    bcc       L018C
L0179               lda       >$FF48
                    bita      #$40
                    bne       L018B
                    lsr       u0004,u
                    beq       L018B
                    bcc       L016E
                    lbsr      L02E5
                    bra       L016E
L018B               coma
L018C               rts
L018D               stb       >$FF48
                    sta       >nh_data
                    ldb       #$28
                    orb       u0001,u
                    stb       >$FF40
                    ldb       #$04
                    lda       #$FF
                    pshs      x,a
L01A0               ldx       #$0001
                    lbsr      L03C3
                    dec       ,s
                    beq       L01B5
                    tst       >nh_data
                    bmi       L01A0
                    stb       >nh_data
                    clrb
                    puls      pc,x,a
L01B5               stb       >nh_data
                    lda       #$D0
                    sta       >$FF48
                    comb
                    puls      pc,x,a
L01C0               leas      $0C,s
                    puls      y,cc
L01C4               ldb       >$FF48
                    clr       >nh_data
                    andb      #$F8
                    beq       L01DC
                    pshs      x
                    leax      <L01DD,pcr
L01D3               leax      $01,x
                    rolb
                    bcc       L01D3
                    ldb       ,x
                    puls      pc,x
L01DC               clrb
L01DD               rts
                    fcb       $F6
                    fcb       $F2
                    fcb       $F5
                    fcb       $F7
                    fcb       $F3
L01E3               comb
                    ldb       #$F4
                    rts
L01E7               leau      >u00A7,u
                    clr       u0007,u
                    lda       #$91
                    sta       u0004,u
                    tstb
                    bne       L0203
                    tfr       x,d
                    std       <u0010,u
                    beq       L0225
                    ldx       <$1E,y
                    cmpd      $01,x
                    bcs       L0209
L0203               comb
                    ldb       #$F1
                    leas      $02,s
                    rts
L0209               clr       ,-s
                    bra       L020F
L020D               inc       ,s
L020F               subd      <$11,x
                    bcc       L020D
                    addd      <$11,x
                    lda       <$10,x
                    lsra
                    bcc       L0223
                    lsr       ,s
                    bcc       L0223
                    inc       u0007,u
L0223               puls      a
L0225               std       u0005,u
                    clrb
                    rts
L0229               clr       u0002,u
                    lda       <$21,y
                    cmpa      #$04
                    bcs       L0236
                    comb
                    ldb       #$F0
                    rts
L0236               pshs      x,b,a
                    cmpa      ,u
                    beq       L023E
                    com       u0002,u
L023E               sta       ,u
                    leax      <L024C,pcr
                    ldb       a,x
                    stb       u0001,u
                    lbsr      L03DD
                    puls      pc,x,b,a
L024C               fcb       $01,$02,$04,$40
L0250               pshs      a
                    ldb       <$15,x
                    bra       L028E
L0257               lbsr      L0229
                    bcs       L02B1
                    ldd       u0005,u
                    pshs      a
                    lda       u0007,u
                    beq       L026A
                    lda       u0001,u
                    ora       #$40
                    sta       u0001,u
L026A               lda       <$23,y
                    bita      #$02
                    bne       L0272
                    incb
L0272               stb       >$FF4A
                    ldx       <$1E,y
                    ldb       <$15,x
                    lda       <$10,x
                    lsra
                    eora      <$24,y
                    anda      #$02
                    pshs      a
                    lda       $01,s
                    tst       ,s+
                    beq       L028E
                    lsla
                    lslb
L028E               stb       >$FF49
                    tst       u0002,u
                    bne       L029C
                    ldb       ,s
                    cmpb      <$15,x
                    beq       L02A8
L029C               sta       >$FF4B
                    ldb       <$22,y
                    andb      #$03
                    eorb      #$1B
                    bsr       L02B2
L02A8               puls      a
                    sta       <$15,x
                    sta       >$FF49
                    clrb
L02B1               rts
L02B2               bsr       L02D7
L02B4               ldb       >$FF48
                    bitb      #$01
                    beq       L02D9
                    ldd       #$00F0
                    std       u000A,u
                    pshs      x
                    ldx       #$0001
                    lbsr      L03C3
                    puls      x
                    bra       L02B4
L02CC               lda       #$08
                    ora       u0001,u
                    sta       >$FF40
                    stb       >$FF48
                    rts
L02D7               bsr       L02CC
L02D9               clr       <u0012,u
                    inc       <u0012,u
L02DF               rol       <u0012,u
                    bpl       L02DF
                    rts
L02E5               pshs      x,b
                    lbsr      L0229
                    bcs       L030D
                    ldx       <$1E,y
                    clr       <$15,x
                    lda       #$04
L02F4               ldb       <$22,y
                    andb      #$03
                    eorb      #$4B
                    pshs      a
                    bsr       L02B2
                    puls      a
                    deca
                    bne       L02F4
                    ldb       <$22,y
                    andb      #$03
                    eorb      #$0B
                    bsr       L02B2
L030D               puls      pc,x,b
L030F               leau      >u00A7,u
                    ldx       $06,y
                    ldb       $02,x
                    cmpb      #$04
                    beq       L0323
                    cmpb      #$03
                    beq       L02E5
                    comb
                    ldb       #$D0
                    rts
L0323               pshs      u,y
                    ldd       #$1A00
                    os9       F$SRqMem
                    lbcs      L0381
                    ldx       $02,s
                    stu       <$13,x
                    ldx       <u0050
                    lda       $06,x
                    ldb       <L00D0
                    ldy       ,s
                    ldx       $06,y
                    ldx       $04,x
                    ldy       #$1A00
                    os9       F$Move
                    bcs       L0372
                    puls      u,y
                    pshs      u,y
                    lbsr      L0229
                    bcs       L0372
                    ldx       $06,y
                    ldb       $07,x
                    bitb      #$01
                    beq       L0363
                    lda       u0001,u
                    ora       #$40
                    sta       u0001,u
                    sta       u0007,u
L0363               lda       $09,x
                    ldx       <$1E,y
                    lbsr      L0250
                    bcs       L0372
                    ldx       <u0013,u
                    bsr       L0383
L0372               ldu       $02,s
                    pshs      b,cc
                    ldu       <u0013,u
                    ldd       #$1A00
                    os9       F$SRtMem
                    puls      b,cc
L0381               puls      pc,u,y
L0383               pshs      y,cc
                    orcc      #$50
                    ldb       #$F0
                    stb       >$FF48
                    ldy       #$FFFF
                    ldb       #$28
                    orb       u0001,u
                    stb       >$FF40
                    orb       #$A8
                    lda       #$02
                    lbsr      L02D9
L039E               bita      >$FF48
                    bne       L03B9
                    leay      -$01,y
                    bne       L039E
                    lda       u0001,u
                    ora       #$08
                    sta       >$FF40
                    lda       #$D0
                    sta       >$FF48
                    puls      y,cc
                    comb
                    ldb       #$F5
                    rts
L03B9               lda       ,x+
                    sta       >$FF4B
                    stb       >$FF40
                    bra       L03B9
L03C3               pshs      b,a
                    ldd       <u0050
                    cmpd      <u004A
                    puls      b,a
                    beq       L03D2
                    os9       F$Sleep
                    rts
L03D2               ldx       #$A000
L03D5               nop
                    nop
                    nop
                    leax      -$01,x
                    bne       L03D5
                    rts
L03DD               pshs      y,x,b,a
                    ldd       #$00F0
                    std       u000A,u
                    lda       u0001,u
                    ora       #$08
                    sta       >$FF40
                    ldx       #$0028
                    lda       <u0032
                    bmi       L040A
                    beq       L0408
                    tst       u0002,u
                    beq       L040C
                    lda       <$23,y
                    bita      #$10
                    beq       L040C
                    bsr       L03C3
                    ldd       #$00F0
                    std       u000A,u
                    bra       L040C
L0408               bsr       L03C3
L040A               bsr       L040F
L040C               clrb
                    puls      pc,y,x,b,a
L040F               lda       #$01
                    sta       <u0032
                    ldx       #$0001
                    leay      u000A,u
                    clr       $04,y
                    ldd       #$00F0
                    os9       F$VIRQ
                    bcc       L0426
                    lda       #$80
                    sta       <u0032
L0426               clra
                    rts
L0428               pshs      a
                    lda       <u008A
                    beq       L0432
                    bsr       L040F
                    bra       L0439
L0432               sta       >$FF40
                    clr       u000E,u
                    clr       <u0032
L0439               puls      pc,a
L043B               ldx       <$1E,y
                    ldb       #$14
L0440               clr       b,x
                    decb
                    bpl       L0440
                    ldb       <$26,y
                    lda       <$27,y
                    mul
                    subd      #$0001
                    lda       <$2A,y
                    sta       $03,x
                    sta       <$12,x
                    mul
                    addd      <$2B,y
                    std       $01,x
                    lda       #$07
                    sta       $0D,x
                    lda       <$24,y
                    lsla
                    pshs      a
                    lda       <$27,y
                    deca
                    ora       ,s+
                    sta       <$10,x
                    clrb
                    rts
                    emod
eom                 equ       *
