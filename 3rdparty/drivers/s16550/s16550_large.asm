********************************************************************
* s16550_large - 16550 serial driver
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
* 28     Patched by Bob Brose to fix IRQ poll table     BOB ??/??/??
*        duplication bug

                    nam       s16550
                    ttl       os9 device driver

* Disassembled 02/04/02 22:41:55 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       1
u0001               rmb       2
u0003               rmb       1
u0004               rmb       1
u0005               rmb       1
u0006               rmb       2
u0008               rmb       1
u0009               rmb       1
u000A               rmb       1
u000B               rmb       1
u000C               rmb       1
u000D               rmb       1
u000E               rmb       1
u000F               rmb       1
u0010               rmb       4
u0014               rmb       2
u0016               rmb       3
u0019               rmb       2
u001B               rmb       2
u001D               rmb       1
u001E               rmb       1
u001F               rmb       1
u0020               rmb       1
u0021               rmb       1
u0022               rmb       1
u0023               rmb       2
u0025               rmb       2
u0027               rmb       1
u0028               rmb       1
u0029               rmb       1
u002A               rmb       2
u002C               rmb       2
u002E               rmb       2
u0030               rmb       2
u0032               rmb       2
u0034               rmb       1
u0035               rmb       1
u0036               rmb       2
OutNxt              rmb       2
u003A               rmb       1
u003B               rmb       1
u003C               rmb       2
u003E               rmb       2
u0040               rmb       1
u0041               rmb       2
u0043               rmb       1
u0044               rmb       52
u0078               rmb       8
u0080               rmb       128
U0100               rmb       0
size                equ       .

                    fcb       $03

name                fcs       /s16550/
                    fcb       28

L0015               fcb       $03

start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

* Init
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Init                clrb
                    pshs      dp,b,cc
                    lbsr      GetDP
                    ldd       <u0001
                    addd      #$0002
                    pshs      y                   save Y
                    leax      >IRQPkt,pcr
                    leay      >IRQRtn,pcr
                    os9       F$IRQ               install interrupt service routine
                    puls      y                   restore Y
                    bcc       L004A               branch if ok
                    puls      a,cc
                    orcc      #Carry              set error flag
                    puls      pc,dp               exit with error
L004A               lda       <M$Opt,y            get option count byte
                    cmpa      #$1C                size of standard SCF?
                    bls       L005F               branch if lower/same
                    lda       <$2E,y              else grab driver specific byte
                    anda      #$10
                    sta       <u001F
                    lda       <$2E,y
                    anda      #$0F                mask out %00001111
                    bne       L0061               if not zero, A holds number of 256 byte pages to allocate
L005F               lda       #$01                else allocate 1 256 byte page
L0061               clrb
                    pshs      u
                    os9       F$SRqMem            allocate memory
                    tfr       u,x                 transfer buffer start to X
                    puls      u
                    bcc       L0087
* Code here is in case of alloc error -- cleanup and return with error
                    stb       $01,s
                    ldx       #$0000
                    ldd       <u0001
                    addd      #$0002
                    pshs      y
                    leay      >IRQRtn,pcr
                    os9       F$IRQ
                    puls      y
                    puls      dp,b,cc
                    orcc      #Carry
                    rts

* D = size of allocated buffer in bytes
L0087               stx       <u0032              store buffer start in several pointers
                    stx       <u002C
                    stx       <u002E
                    std       <u0036
                    leax      d,x                 point at end of buffer
                    stx       <u0030              store
                    tfr       a,b                 transfer size hi byte to B
                    clra                          clear hi byte
                    orb       #$02                OR original hi byte with 2
                    andb      #$0E                clear bit 0 (b = %0000XXX0)
                    lslb
                    lslb
                    lslb
                    lslb
                    tstb
                    bpl       L00A3
                    ldb       #$80
L00A3               pshs      b,a
                    ldd       <u0036
                    subd      ,s++
                    std       <u002A
                    leax      <u0044,u
                    stx       <u003E
                    stx       <OutNxt
                    stx       <u003A
                    leax      >u0100,u
                    stx       <u003C
                    ldd       #$00BC
                    std       <u0041
                    clr       <u0034
                    clr       <u0035
                    clr       <u0040
                    ldd       <$26,y
                    std       <u001D
                    lbsr      L0318
                    ldx       <u0001
                    lda       $05,x
                    lda       ,x
                    lda       $05,x
                    lda       $06,x
                    anda      #$B0
                    sta       <u0020
                    clrb
                    bita      #$10
                    bne       L00E2
                    orb       #$02
L00E2               bita      #$20
                    bne       L00E8
                    orb       #$01
L00E8               stb       <u0028
                    orcc      #IntMasks
                    lda       >L0015,pcr
                    bmi       L00F5
                    sta       >$FF7F
L00F5               lda       >$FF23
                    anda      #$FC
                    sta       >$FF23
                    lda       >$FF22
                    lda       >$0092
                    ora       #$01
                    sta       >$0092
                    sta       >$FF92
                    puls      pc,dp,b,cc

Write               clrb
                    pshs      dp,b,cc
                    lbsr      GetDP
                    ldx       <OutNxt             get address of next pos to save write char
                    sta       ,x+                 store char (A) at ,X and increment
                    cmpx      <u003C              less than end of buffer?
                    bcs       L011D
                    ldx       <u003E
L011D               orcc      #IntMasks           mask interrupts
                    cmpx      <u003A              reached end of buffer?
                    bne       L0138               nope, still more room
                    pshs      x
                    lbsr      L05AD
                    puls      x
                    ldu       >D.Proc
                    ldb       <P$Signal,u         get pending signal, if any
                    beq       L0136               branch if none
                    cmpb      #S$Intrpt           interrupt?
                    bls       L013E               branch if lower or same
L0136               bra       L011D
L0138               stx       <OutNxt             update next output position
                    inc       <u0040              increment output buffer size
                    bsr       L0140
L013E               puls      pc,dp,b,cc
L0140               lda       #$0F
                    bra       L0146
                    lda       #$0D
L0146               ldx       <V.Port
                    sta       $01,x
                    rts

Read                clrb
                    pshs      dp,b,cc
                    lbsr      GetDP
                    orcc      #IntMasks
                    ldd       <u0034
                    beq       L0169
                    cmpd      #$0010
                    lbne      L018F
                    andcc     #^IntMasks
                    bsr       L01BD
L0163               orcc      #IntMasks
                    ldd       <u0034
                    bne       L018F
L0169               lbsr      L05AD
                    ldx       >$0050
                    ldb       <$19,x
                    beq       L0178
                    cmpb      #$03
                    bls       L018A
L0178               ldb       $0C,x
                    andb      #$02
                    bne       L018A
                    ldb       <u000E
                    bne       L01A6
                    ldb       <u0005
                    beq       L0163
                    orcc      #IntMasks
                    bra       L0169
L018A               puls      dp,a,cc
                    orcc      #Carry
                    rts
L018F               subd      #$0001
                    std       <u0034
                    ldx       <u002E
                    lda       ,x+
                    cmpx      <u0030
                    bne       L019E
                    ldx       <u0032
L019E               stx       <u002E
                    andcc     #^IntMasks
                    ldb       <u000E
                    beq       L01BB
L01A6               stb       <$3A,y
                    clr       <u000E
                    puls      dp,a,cc
                    bitb      #$20
                    beq       L01B6
                    ldb       #$F4
                    orcc      #Carry
                    rts
L01B6               ldb       #$DC
                    orcc      #Carry
                    rts
L01BB               puls      pc,dp,b,cc
L01BD               pshs      cc
                    ldx       <u0001
                    ldb       <u0028
                    bitb      #$70
                    beq       L01D9
                    bitb      #$20
                    beq       L01DB
                    orcc      #IntMasks
                    ldb       <u0028
                    andb      #$DF
                    stb       <u0028
                    lda       $04,x
                    ora       #$02
                    sta       $04,x
L01D9               puls      pc,cc
L01DB               bitb      #$10
                    beq       L01EF
                    orcc      #IntMasks
                    ldb       <u0028
                    andb      #$EF
                    stb       <u0028
                    lda       $04,x
                    ora       #$01
                    sta       $04,x
                    bra       L01D9
L01EF               bitb      #$40
                    beq       L01D9
                    ldb       <u000F
                    orcc      #IntMasks
                    stb       <u0043
                    lbsr      L0140
                    ldb       <u0028
                    andb      #$BF
                    stb       <u0028
                    bra       L01D9

GetStat             clrb
                    pshs      dp,b,cc
                    lbsr      GetDP
                    cmpa      #$01
                    bne       L0226
                    ldd       <u0034
                    beq       L021E
                    tsta
                    beq       L0217
                    ldb       #$FF
L0217               ldx       $06,y
                    stb       $02,x
                    lbra      L0316
L021E               puls      b,cc
                    orcc      #Carry
                    ldb       #$F6
                    puls      pc,dp
L0226               cmpa      #$28
                    bne       L024E
                    ldd       <u001D
                    tst       <u001F
                    beq       L0236
                    bitb      #$04
                    bne       L0236
                    andb      #$F7
L0236               ldx       $06,y
                    std       $08,x
                    clrb
                    lda       <u0020
                    bita      #$80
                    bne       L0243
                    orb       #$10
L0243               bita      #$20
                    bne       L0249
                    orb       #$40
L0249               stb       $02,x
                    lbra      L0316
L024E               cmpa      #$06
                    bne       L0256
                    clrb
                    lbra      L0316
L0256               cmpa      #$C1
                    bne       L026F
                    ldx       $06,y
                    ldd       #$00BC
                    std       $06,x
                    clra
                    ldb       <u0040
                    std       $08,x
                    ldb       <u0028
                    andb      #$07
                    stb       $02,x
                    lbra      L0316
L026F               cmpa      #$D0
                    bne       L02DD
                    ldb       <u000E
                    lbne      L01A6
                    orcc      #IntMasks
                    ldd       <u0030
                    subd      <u002E
                    cmpd      <u0034
                    bcs       L0288
                    ldd       <u0034
                    beq       L021E
L0288               andcc     #^IntMasks
                    ldu       $06,y
                    cmpd      u0008,u
                    bls       L0293
                    ldd       u0008,u
L0293               std       u0008,u
                    beq       L02DB
                    pshs      b,a
                    pshs      u,y,x
                    std       $02,s
                    ldd       <u002E
                    std       ,s
                    ldd       u0006,u
                    std       $04,s
                    ldx       >$0050
                    ldb       $06,x
                    lda       >$00D0
                    puls      u,y,x
                    orcc      #IntMasks
                    os9       F$Move
                    ldd       <u0034
                    subd      ,s
                    std       <u0034
                    andcc     #^IntMasks
                    cmpd      #$0010
                    bhi       L02CD
                    addd      ,s
                    cmpd      #$0010
                    bls       L02CD
                    lbsr      L01BD
L02CD               puls      b,a
                    ldx       <u002E
                    leax      d,x
                    cmpx      <u0030
                    bne       L02D9
                    ldx       <u0032
L02D9               stx       <u002E
L02DB               bra       L0316
L02DD               cmpa      #$D2
                    bne       L02F5
                    ldd       #$0B04
                    ldy       $06,y
                    std       $01,y
                    ldd       #$0077
                    std       $06,y
                    ldd       #$0001
                    std       $08,y
                    bra       L0316
L02F5               cmpa      #$26
                    bne       L030E
                    ldx       $06,y
                    ldy       $03,y
                    ldy       $04,y
                    clra
                    ldb       <$2C,y
                    std       $06,x
                    ldb       <$2D,y
                    std       $08,x
                    bra       L0316
L030E               puls      b,cc
                    orcc      #Carry
                    ldb       #$D0
                    puls      pc,dp
L0316               puls      pc,dp,b,cc
L0318               pshs      u
                    tfr       b,a
                    leau      >L07E3,pcr
                    ldx       <u0001
                    andb      #$0F
                    lslb
                    lslb
                    leau      b,u
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    eora      #$03
                    anda      #$03
                    pshs      a,cc
                    lda       <u001D
                    lsra
                    lsra
                    anda      #$38
                    ora       $01,s
                    sta       $01,s
                    ora       #$80
                    orcc      #IntMasks
                    sta       $03,x
                    ldd       ,u++
                    exg       a,b
                    std       ,x
                    lda       $01,s
                    sta       $03,x
                    ldd       ,u
                    sta       <u0021
                    ora       #$06
                    sta       $02,x
                    stb       <u0029
                    puls      pc,u,a,cc

SetStat             clrb
                    pshs      dp,b,cc
                    lbsr      GetDP
                    cmpa      #$D1
                    lbne      L03F5
                    ldu       $06,y
                    ldx       u0006,u
                    ldd       u0008,u
                    pshs      x,b,a
                    beq       L03D3
L036F               ldd       <u003A
                    cmpd      <u003E
                    bne       L037D
                    ldd       <u003C
                    subd      #$0001
                    bra       L0387
L037D               subd      #$0001
                    cmpd      <OutNxt
                    bcc       L0387
                    ldd       <u003C
L0387               subd      <OutNxt
                    beq       L03D8
                    cmpd      ,s
                    bls       L0392
                    ldd       ,s
L0392               pshs      b,a
                    ldx       >$0050
                    lda       $06,x
                    ldb       >$00D0
                    ldu       <OutNxt
                    ldx       $04,s
                    ldy       ,s
                    orcc      #IntMasks
                    os9       F$Move
                    ldd       ,s
                    ldu       <OutNxt
                    leau      d,u
                    cmpu      <u003C
                    bcs       L03B5
                    ldu       <u003E
L03B5               stu       <OutNxt
                    clra
                    ldb       <u0040
                    addd      ,s
                    stb       <u0040
                    andcc     #^IntMasks
                    ldd       ,s
                    ldx       $04,s
                    leax      d,x
                    stx       $04,s
                    ldd       $02,s
                    subd      ,s++
                    std       ,s
                    bne       L036F
                    lbsr      L0140
L03D3               leas      $04,s
                    lbra      L0543
L03D8               orcc      #IntMasks
                    lbsr      L0140
                    lbsr      L05AD
                    ldx       >$0050
                    ldb       <$19,x
                    beq       L03EC
                    cmpb      #$03
                    bls       L03D3
L03EC               ldb       $0C,x
                    andb      #$02
                    bne       L03D3
                    lbra      L036F
L03F5               cmpa      #$28
                    bne       L0426
                    ldy       $06,y
                    ldd       $08,y
                    tst       <u001F
                    beq       L0408
                    bitb      #$04
                    bne       L0408
                    orb       #$08
L0408               std       <u001D
                    lbsr      L0318
                    clr       <u0022
                    tst       <u000C
                    bne       L0423
                    tst       <u000B
                    bne       L0423
                    tst       <u000D
                    bne       L0423
                    ldb       <u001D
                    bitb      #$04
                    bne       L0423
                    inc       <u0022
L0423               lbra      L0543
L0426               cmpa      #$2B
                    bne       L0441
                    ldx       <u0001
                    lda       $04,x
                    pshs      x,a
                    anda      #$FE
                    sta       $04,x
                    ldx       #$001E
                    os9       F$Sleep
                    puls      x,a
                    sta       $04,x
                    lbra      L0543
L0441               cmpa      #$1D
                    bne       L0491
                    orcc      #IntMasks
                    ldx       <u0001
                    lda       <u0028
                    ora       #$08
                    sta       <u0028
                    lda       #$0D
                    sta       $01,x
                    clr       <u0040
                    ldd       <u003E
                    std       <u003A
                    std       <OutNxt
                    lda       <u0021
                    ora       #$04
                    sta       $02,x
                    clra
                    sta       ,x
L0464               lda       $05,x
                    anda      #$40
                    bne       L0476
                    andcc     #^IntMasks
                    ldx       #$0001
                    os9       F$Sleep
                    ldx       <u0001
                    bra       L0464
L0476               lda       $03,x
                    ora       #$40
                    sta       $03,x
                    ldx       #$001E
                    os9       F$Sleep
                    ldx       <u0001
                    anda      #$BF
                    sta       $03,x
                    lda       <u0028
                    anda      #$F7
                    sta       <u0028
                    lbra      L0543
L0491               cmpa      #$C2
                    bne       L04A7
                    ldb       <u0028
                    andb      #$F8
                    stb       <u0028
                    tst       <u0040
                    lbeq      L0543
                    lbsr      L0140
                    lbra      L0543
L04A7               cmpa      #$1A
                    bne       L04C4
                    lda       $05,y
                    ldy       $06,y
                    ldb       $07,y
                    orcc      #IntMasks
                    ldx       <u0034
                    bne       L04BD
                    std       <u0025
                    lbra      L0543
L04BD               puls      cc
                    os9       F$Send
                    puls      pc,dp,b
L04C4               cmpa      #$1B
                    bne       L04D5
                    lda       $05,y
                    cmpa      <u0025
                    bne       L04D2
                    clra
                    clrb
                    std       <u0025
L04D2               lbra      L0543
L04D5               cmpa      #$9A
                    bne       L04E4
                    lda       $05,y
                    ldy       $06,y
                    ldb       $07,y
                    std       <u0023
                    bra       L0543
L04E4               cmpa      #$9B
                    bne       L04F6
                    orcc      #IntMasks
                    lda       $05,y
                    cmpa      <u0023
                    bne       L04F4
                    clra
                    clrb
                    std       <u0023
L04F4               bra       L0543
L04F6               cmpa      #$2A
                    lbne      L0511
                    orcc      #IntMasks
                    lda       $05,y
                    ldx       #$0000
                    cmpa      <u0025
                    bne       L0509
                    stx       <u0025
L0509               cmpa      <u0023
                    bne       L050F
                    stx       <u0023
L050F               bra       L0543
L0511               cmpa      #$C3
                    bne       L052B
                    orcc      #IntMasks
                    ldb       #$0D
                    stb       $01,x
                    ldd       <u003E
                    std       <OutNxt
                    std       <u003A
                    clr       <u0040
                    ldb       <u0021
                    orb       #$04
                    stb       $02,x
                    bra       L0543
L052B               cmpa      #$29
                    bne       L053B
                    ldx       <u0001
                    lda       #$03
                    sta       $04,x
                    ldb       #$0F
                    stb       $01,x
                    bra       L0543
L053B               puls      b,cc
                    orcc      #Carry
                    ldb       #$D0
                    puls      pc,dp
L0543               puls      pc,dp,b,cc

Term                clrb
                    pshs      dp,b,cc
                    lbsr      GetDP
                    orcc      #IntMasks
                    clra
                    clrb
                    std       <u0034
                    ldx       <u0032
                    stx       <u002C
                    stx       <u002E
                    pshs      x,b,a
                    ldb       $04,s
                    tfr       b,cc
                    ldx       >$0050
                    lda       ,x
                    sta       <u0004
                    sta       <u0003
L0566               orcc      #IntMasks
                    tst       <u0040
                    bne       L0576
                    ldx       <u0001
                    ldb       $05,x
                    eorb      #$20
                    andb      #$20
                    beq       L0585
L0576               orcc      #IntMasks
                    lbsr      L05AD
                    ldd       $02,s
                    std       <u002C
                    ldd       ,s
                    std       <u0034
                    bra       L0566
L0585               leas      $04,s
                    clr       $01,x
                    clr       $04,x
                    andcc     #^IntMasks
                    ldd       <u0036
                    pshs      u
                    ldu       <u0032
                    os9       F$SRtMem
                    puls      u
                    ldx       #$0000
                    ldd       <u0001
                    addd      #$0002
                    pshs      y
                    leay      >IRQRtn,pcr
                    os9       F$IRQ
                    puls      y
                    puls      pc,dp,b,cc
L05AD               ldd       >$0050
                    sta       <u0005
                    tfr       d,x
                    lda       $0C,x
                    ora       #$08
                    sta       $0C,x
                    andcc     #^IntMasks
                    ldx       #$0001
                    os9       F$Sleep
                    rts

* Transfer hi-byte of U to Direct Page
GetDP               pshs      u
                    puls      dp
                    leas      $01,s
                    rts

L05CA               fdb       $0160,$0115,$001b,$01bb,$0004,$0004,$002a

* IRQ Service Routine
IRQRtn              fcb       $5f
L05D8               pshs      dp,b,cc
                    bsr       GetDP
                    clr       <u0027
                    ldy       <u0001
                    ldb       $02,y
                    bitb      #$01
                    beq       L05F4
                    tfr       a,b
                    andb      #$0E
                    bne       L05F4
                    puls      cc
                    orcc      #Carry
                    puls      pc,dp
L05F4               leax      >L05CA,pcr
                    andb      #$0E
                    abx
                    tfr       pc,d
                    addd      ,x
                    tfr       d,pc
L0601               ldb       $02,y
                    bitb      #$01
                    beq       L05F4
                    lda       <u0005
                    beq       L0616
                    clrb
                    stb       <u0005
                    tfr       d,x
                    lda       $0C,x
                    anda      #$F7
                    sta       $0C,x
L0616               puls      pc,dp,b,cc
                    ldx       <u002C
                    lda       $05,y
                    bmi       L062B
                    ldb       <u0029
L0620               bsr       L0651
                    decb
                    bne       L0620
                    bra       L0629
                    ldx       <u002C
L0629               lda       $05,y
L062B               bita      #$1E
                    beq       L0634
                    lbsr      L07BF
                    bra       L0629
L0634               bita      #$01
                    beq       L063C
L0638               bsr       L0651
                    bra       L0629
L063C               tst       <u0027
                    bne       L064D
                    ldd       <u0025
                    beq       L064D
                    stb       <u0027
                    os9       F$Send
                    clra
                    clrb
                    std       <u0025
L064D               stx       <u002C
                    bra       L0601
L0651               lda       ,y
                    beq       L0679
                    tst       <u0022
                    bne       L0679
                    cmpa      <u000C
                    bne       L0662
                    lda       #$02
                    lbra      L06FD
L0662               cmpa      <u000B
                    bne       L066B
                    lda       #$03
                    lbra      L06FD
L066B               cmpa      <u000F
                    beq       L06E3
                    cmpa      <u0010
                    beq       L06F2
                    cmpa      <u000D
                    lbeq      L070A
L0679               pshs      b
                    sta       ,x+
                    cmpx      <u0030
                    bne       L0683
                    ldx       <u0032
L0683               cmpx      <u002E
                    bne       L0697
                    ldb       #$02
                    orb       <u000E
                    stb       <u000E
                    cmpx      <u0032
                    bne       L0693
                    ldx       <u0030
L0693               leax      -$01,x
                    bra       L06A5
L0697               stx       <u002C
                    ldd       <u0034
                    addd      #$0001
                    std       <u0034
                    cmpd      <u002A
                    beq       L06A7
L06A5               puls      pc,b
L06A7               ldb       <u0028
                    bitb      #$70
                    bne       L06A5
                    lda       <u001D
                    bita      #$02
                    beq       L06BF
                    orb       #$20
                    stb       <u0028
                    lda       $04,y
                    anda      #$FD
                    sta       $04,y
                    bra       L06A5
L06BF               bita      #$01
                    beq       L06CF
                    orb       #$10
                    stb       <u0028
                    lda       $04,y
                    anda      #$FE
                    sta       $04,y
                    bra       L06A5
L06CF               bita      #$08
                    beq       L06A5
                    orb       #$40
                    stb       <u0028
                    lda       <u0010
                    beq       L06A5
                    sta       <u0043
                    ldb       #$0F
                    stb       $01,y
                    bra       L06A5
L06E3               lda       <u0028
                    anda      #$FB
                    sta       <u0028
                    tst       <u0040
                    beq       L06F1
                    lda       #$0F
                    sta       $01,y
L06F1               rts
L06F2               lda       <u0028
                    ora       #$04
                    sta       <u0028
                    lda       #$0D
                    sta       $01,y
                    rts
L06FD               pshs      b
                    tfr       a,b
                    lda       <u0003
                    stb       <u0027
                    os9       F$Send
                    puls      pc,b
L070A               ldu       <u0009
                    beq       L0711
                    sta       <u0008,u
L0711               rts
                    ldx       <u003A
                    lda       <u0043
                    ble       L071E
                    sta       ,y
                    anda      #$80
                    sta       <u0043
L071E               tst       <u0040
                    beq       L0757
                    ldb       <u0028
                    bitb      #$08
                    bne       L0757
                    andb      #$07
                    andb      <u001D
                    bne       L0757
                    ldb       <u003B
                    negb
                    cmpb      #$0F
                    bls       L0737
                    ldb       #$0F
L0737               cmpb      <u0040
                    bls       L073D
                    ldb       <u0040
L073D               pshs      b
L073F               lda       ,x+
                    sta       ,y
                    decb
                    bne       L073F
                    cmpx      <u003C
                    bcs       L074C
                    ldx       <u003E
L074C               stx       <u003A
                    ldb       <u0040
                    subb      ,s+
                    stb       <u0040
L0754               lbra      L0601
L0757               lda       #$0D
                    sta       $01,y
                    bra       L0754
                    lda       $06,y
                    tfr       a,b
                    andb      #$B0
                    stb       <u0020
                    ldb       <u0028
                    andb      #$FC
                    bita      #$10
                    bne       L076F
                    orb       #$02
L076F               bita      #$20
                    bne       L0775
                    orb       #$01
L0775               bita      #$08
                    beq       L07AF
                    bita      #$80
                    bne       L0799
                    lda       <u001D
                    bita      #$10
                    beq       L0791
                    ldx       <u0016
                    beq       L0791
                    lda       #$01
L0789               sta       <$3F,x
                    ldx       <$3D,x
                    bne       L0789
L0791               lda       #$20
                    ora       <u000E
                    sta       <u000E
                    andb      #$FB
L0799               tst       <u0027
                    bne       L07AF
                    stb       <u0028
                    ldd       <u0023
                    tstb
                    beq       L07B1
                    os9       F$Send
                    stb       <u0027
                    clra
                    clrb
                    std       <u0023
                    bra       L07B1
L07AF               stb       <u0028
L07B1               lda       #$0F
                    sta       $01,y
                    lbra      L0601
                    lda       $05,y
                    bsr       L07BF
                    lbra      L0601
L07BF               pshs      b
                    clrb
                    bita      #$02
                    beq       L07C8
                    orb       #$04
L07C8               bita      #$04
                    beq       L07CE
                    orb       #$01
L07CE               bita      #$08
                    beq       L07D4
                    orb       #$02
L07D4               bita      #$10
                    bne       L07DE
                    orb       #$08
                    orb       <u000E
                    stb       <u000E
L07DE               puls      pc,b

* IRQ Flip/Mask/Priority Bytes
IRQPkt              fcb       $01,$01,$80

L07E3               fcb       $28
                    fdb       $e901,$010f,$0001,$0107,$8041,$0403
                    fdb       $c081,$0801,$e0c1,$0e00,$f0c1,$0e00,$78c1,$0e00
                    fdb       $3c81,$0800,$1e81,$0800,$1481,$0800,$0f81,$0800
                    fdb       $0a81,$0800,$0a81,$0800,$0a81,$0800,$0a81,$0800
                    fdb       $2581
                    fcb       $08

                    emod
eom                 equ       *
                    end

