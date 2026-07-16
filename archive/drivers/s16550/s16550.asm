                    nam       s16550
                    ttl       os9 device driver

                    *         Disassembled        96/09/20 17:17:26 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       /dd/defs/os9defs
                    endc
                    00e1      tylg                set   Drivr+Objct
                    0081      atrv                set   ReEnt+rev
                    0001      rev                 set   $01
                    0000      87CD0799            mod   eom,name,tylg,atrv,start,size

D                   0000      u0000               rmb   1     V.PAGE
D                   0001      u0001               rmb   2     V.PORT
D                   0003      u0003               rmb   1     V.LPRC
D                   0004      u0004               rmb   1     V.BUSY
D                   0005      u0005               rmb   1     V.WAKE
D                   0006      u0006               rmb   1     V.TYPE
                    u0007     rmb                 1     V.LINE
D                   0008      u0008               rmb   1     V.PAUS
D                   0009      u0009               rmb   2     V.DEV2
D                   000b      u000B               rmb   1     V.INTR
D                   000c      u000C               rmb   1     V.QUIT
D                   000d      u000D               rmb   1     V.PCHR
D                   000e      u000E               rmb   1     V.ERR
D                   000f      u000F               rmb   1     V.XON
D                   0010      u0010               rmb   4     V.XOFF
                    u0011     rmb                 1     V.KANJI
                    u0012     rmb                 2     V.KBUF
D                   0014      u0014               rmb   2     V.MODADR
D                   0016      u0016               rmb   2     V.PDLHD
                    u0018     rmb                 5     V.RSV
D                   001d      u001D               rmb   1
D                   001e      u001E               rmb   1
D                   001f      u001F               rmb   1
D                   0020      u0020               rmb   1
D                   0021      u0021               rmb   1
D                   0022      u0022               rmb   1
D                   0023      u0023               rmb   2
D                   0025      u0025               rmb   2
D                   0027      u0027               rmb   1     * signal code (for send)
D                   0028      u0028               rmb   1
D                   0029      u0029               rmb   1
D                   002a      u002A               rmb   2
D                   002c      u002C               rmb   2
D                   002e      u002E               rmb   2
D                   0030      u0030               rmb   2
D                   0032      u0032               rmb   2     V.BUFADDR
D                   0034      u0034               rmb   1
D                   0035      u0035               rmb   1
D                   0036      u0036               rmb   2     V.BUFSIZ
D                   0038      u0038               rmb   2     xmit buff addr?
D                   003a      u003A               rmb   1
D                   003b      u003B               rmb   1
D                   003c      u003C               rmb   2
D                   003e      u003E               rmb   2
D                   0040      u0040               rmb   1
D                   0041      u0041               rmb   2
D                   0043      u0043               rmb   1
D                   0044      u0044               rmb   52
D                   0078      u0078               rmb   8
D                   0080      u0080               rmb   128   * ???baud table???

D                   0100      size                equ   .
                    000d      03                  fcb   $03
                    000e      name                equ   *
                    000e      73313635            fcs   /s16550/
                    0014      10                  fcb   $10
                    0015      03                  L0015    fcb   $03

                    0016      start               equ   *
                    0016      16005A              lbra  Iniz       |SCF jump table
                    0019      160160              lbra  Read       |
                    001c      160114              lbra  Write      |
                    001f      1601EC              lbra  GetSta     |
                    0022      160324              lbra  SetSta     |
*                                      Term       |

                    0025      5F                  clrb
                    0026      340D                pshs  dp,b,cc
                    0028      1704FB              lbsr  UtoDP

                    002b      1A50                orcc  #$50
                    002d      4F                  clra
                    002e      DD34                std   <u0034
                    0030      9E32                ldx   <u0032
                    0032      9F2C                stx   <u002C
                    0034      9F2E                stx   <u002E
                    0036      3416                pshs  x,b,a
                    0038      E664                ldb   $04,s
                    003a      1F9A                tfr   b,cc
                    003c      BE0050              ldx   >$0050
                    003f      A684                lda   ,x
                    0041      9704                sta   <V.BUSY
                    0043      9703                sta   <V.LPRC
                    0045      0D40                L0045    tst   <u0040
                    0047      2608                bne   L0051

                    0049      9E01                ldx   <V.PORT
                    004b      E605                ldb   $05,x
                    004d      C420                andb  #$20
                    004f      260D                bne   exit       *exit routine

                    0051      1704BA              L0051    lbsr  L050E
                    0054      EC62                ldd   $02,s
                    0056      DD2C                std   <u002C
                    0058      ECE4                ldd   ,s
                    005a      DD34                std   <u0034
                    005c      20E7                bra   L0045

                    005e      3264                exit     leas  $04,s      * EXIT-----------------------
                    0060      6F01                clr   $01,x
                    0062      6F04                clr   $04,x
                    0064      DC36                ldd   <V.BUFSIZ   |num bytes to return
                    0066      DE32                ldu   <V.BUFADDR  |st addr ram to return
                    0068      103F29              os9   F$SRtMem    |return system memory
                    006b      8E0000              ldx   #$0000      |
                    006e      103F2A              os9   F$IRQ       |remove from poll
                    0071      358D                puls  pc,dp,b,cc

*** crash into init from exit? ***

                    0073      5F                  Iniz     clrb
                    0074      340D                pshs  dp,b,cc
                    0076      1704AD              lbsr  UtoDP

                    0079      DC01                ldd   <u0001      |dev. base addr
                    007b      C30002              addd  #$0002      |status register=base+2
                    007e      3420                pshs  y           dev.desc. addr>stack
                    0080      308D06CF            leax  >Data,pcr   |addr packet
                    0084      318D04B3            leay  >IRQser,pcr |addr irq service routine
                    0088      103F2A              os9   F$IRQ       |add to poll
                    008b      3520                puls  y           dev.desc. addr
                    008d      2406                bcc   checkdesc

                    008f      3503                puls  a,cc
                    0091      1A01                orcc  #$01
                    0093      3588                puls  pc,dp
                    0095      A6A811              checkdesc lda   <$11,y     bytes in init table
                    0098      811C                cmpa  #$1C
                    009a      230E                bls   L00AA

                    009c      A6A82E              lda   <$2E,y
                    009f      8410                anda  #$10
                    00a1      971F                sta   <u001F
                    00a3      A6A82E              lda   <$2E,y
                    00a6      840F                anda  #$0F
                    00a8      2602                bne   L00AC

                    00aa      8601                L00AA    lda   #$01
                    00ac      5F                  L00AC    clrb
                    00ad      3440                pshs  u          save U
                    00af      103F28              os9   F$SRqMem    |Request System RAM
                    |(d=byte  cnt)
                    00b2      1F31                tfr   u,x         |start addr to x
                    00b4      3540                puls  u          restore U
                    00b6      240D                bcc   L00C5       |error?

                    00b8      E761                stb   $01,s
                    00ba      8E0000              ldx   #$0000      set remove
                    00bd      103F2A              os9   F$IRQ       Set IRQ (remove from poll)
                    00c0      350D                puls  dp,b,cc
                    00c2      1A01                orcc  #$01
                    00c4      39                  rts

                    00c5      9F32                L00C5    stx   <u0032
                    00c7      9F2C                stx   <u002C
                    00c9      9F2E                stx   <u002E
                    00cb      DD36                std   <u0036
                    00cd      308B                leax  d,x
                    00cf      9F30                stx   <u0030
                    00d1      1F89                tfr   a,b
                    00d3      4F                  clra
                    00d4      CB03                addb  #$03
                    00d6      C40C                andb  #$0C
                    00d8      58                  lslb
                    00d9      58                  lslb
                    00da      58                  lslb
                    00db      3406                pshs  b,a
                    00dd      DC36                ldd   <u0036
                    00df      A3E1                subd  ,s++
                    00e1      DD2A                std   <u002A
                    00e3      30C844              leax  <u0044,u
                    00e6      9F3E                stx   <u003E
                    00e8      9F38                stx   <u0038
                    00ea      9F3A                stx   <u003A
                    00ec      30C90100            leax  >u0100,u
                    00f0      9F3C                stx   <u003C
                    00f2      CC00BC              ldd   #$00BC
                    00f5      DD41                std   <u0041
                    00f7      0F34                clr   <u0034
                    00f9      0F35                clr   <u0035
                    00fb      0F40                clr   <u0040
                    00fd      ECA826              ldd   <$26,y
                    0100      DD1D                std   <u001D
                    0102      170203              lbsr  L0308

                    0105      9E01                ldx   <V.PORT
                    0107      C610                ldb   #$10
                    0109      A605                L0109    lda   $05,x
                    010b      A684                lda   ,x
                    010d      5A                  decb
                    010e      26F9                bne   L0109

                    0110      1A50                orcc  #$50
                    0112      A68DFEFF            lda   >L0015,pcr
                    0116      2B03                bmi   L011B

                    0118      B7FF7F              sta   >$FF7F     * set mpi slot
                    011b      B6FF23              L011B    lda   >$FF23     * CART IRQ flag
                    011e      84FC                anda  #$FC
                    0120      B7FF23              sta   >$FF23     * CART IRQ ctrl
                    0123      B6FF22              lda   >$FF22     * ???ram size???
                    0126      B60092              lda   >$0092
                    0129      8A01                ora   #$01
                    012b      B70092              sta   >$0092
                    012e      B7FF92              sta   >$FF92     * IRQENR irq enable
                    0131      358D                puls  pc,dp,b,cc
                    0133      5F                  Write    clrb
                    0134      340D                pshs  dp,b,cc
                    0136      1703ED              lbsr  UtoDP      u=dev mem area

                    0139      9E38                ldx   <u0038
                    013b      A780                sta   ,x+        character to write
                    013d      9C3C                cmpx  <u003C
                    013f      2502                bcs   L0143

                    0141      9E3E                ldx   <u003E
                    0143      9C3A                L0143    cmpx  <u003A
                    0145      260A                bne   L0151

                    0147      3410                pshs  x
                    0149      8D19                bsr   L0164

                    014b      3510                puls  x
                    014d      24F4                bcc   L0143
                    014f      2006                bra   L0157

                    0151      9F38                L0151    stx   <u0038
                    0153      0C40                inc   <u0040
                    0155      8D02                bsr   L0159

                    0157      358D                L0157    puls  pc,dp,b,cc
                    0159      860F                L0159    lda   #$0F
                    015b      2002                bra   L015F

                    015d      860D                lda   #$0D
                    015f      9E01                L015F    ldx   <V.PORT
                    0161      A701                sta   $01,x
                    0163      39                  rts

                    0164      1703A7              L0164    lbsr  L050E

                    0167      BE0050              ldx   >$0050
                    016a      E68819              ldb   <$19,x
                    016d      2704                beq   L0173

                    016f      C103                cmpb  #$03
                    0171      2306                bls   L0179

                    0173      E60C                L0173    ldb   $0C,x
                    0175      C402                andb  #$02
                    0177      2702                beq   L017B

                    0179      1A01                L0179    orcc  #$01
                    017b      39                  L017B    rts
                    017c      5F                  Read     clrb
                    017d      340D                pshs  dp,b,cc
                    017f      1703A4              lbsr  UtoDP      dev.mem. to dp

                    0182      D60E                ldb   <V.ERR
                    0184      262C                bne   ReadErr

                    0186      1A50                L0186    orcc  #$50       FIRQ,IRQ mask
                    0188      DC34                ldd   <u0034
                    018a      271B                beq   L01A7

                    018c      10830010            cmpd  #$0010
                    0190      2602                bne   L0194

                    0192      8D33                bsr   L01C7

                    0194      830001              L0194    subd  #$0001
                    0197      DD34                std   <u0034
                    0199      9E2E                ldx   <u002E
                    019b      A680                lda   ,x+
                    019d      9C30                cmpx  <u0030
                    019f      2602                bne   L01A3

                    01a1      9E32                ldx   <u0032
                    01a3      9F2E                L01A3    stx   <u002E
                    01a5      358D                puls  pc,dp,b,cc

                    01a7      8DBB                L01A7    bsr   L0164

                    01a9      2502                bcs   L01AD

                    01ab      20D9                bra   L0186

                    01ad      350B                L01AD    puls  dp,a,cc
                    01af      1A01                orcc  #$01
                    01b1      39                  rts

                    01b2      E7A83A              ReadErr  stb   <$3A,y     b=V.ERR
                    01b5      0F0E                clr   <V.ERR
                    01b7      350B                puls  dp,a,cc
                    01b9      C520                bitb  #$20       $20=bit 5
                    01bb      2705                beq   L01C2

                    01bd      C6F4                ldb   #$F4
                    01bf      1A01                orcc  #$01
                    01c1      39                  rts

                    01c2      C6DC                L01C2    ldb   #$DC
                    01c4      1A01                orcc  #$01
                    01c6      39                  rts

                    01c7      3407                L01C7    pshs  b,a,cc
                    01c9      9E01                ldx   <V.PORT
                    01cb      D628                ldb   <u0028
                    01cd      C570                bitb  #$70
                    01cf      2712                beq   L01E3

                    01d1      C520                bitb  #$20
                    01d3      2710                beq   L01E5

                    01d5      1A50                orcc  #$50
                    01d7      D628                ldb   <u0028
                    01d9      C4DF                andb  #$DF
                    01db      D728                stb   <u0028
                    01dd      A604                lda   $04,x
                    01df      8A0A                ora   #$0A
                    01e1      A704                sta   $04,x
                    01e3      3587                L01E3    puls  pc,b,a,cc
                    01e5      C510                L01E5    bitb  #$10
                    01e7      2710                beq   L01F9

                    01e9      1A50                orcc  #$50
                    01eb      D628                ldb   <u0028
                    01ed      C4EF                andb  #$EF
                    01ef      D728                stb   <u0028
                    01f1      A604                lda   $04,x
                    01f3      8A05                ora   #$05
                    01f5      A704                sta   $04,x
                    01f7      20EA                bra   L01E3

                    01f9      C540                L01F9    bitb  #$40
                    01fb      27E6                beq   L01E3

                    01fd      D60F                ldb   <V.XON
                    01ff      1A50                orcc  #$50
                    0201      D743                stb   <u0043
                    0203      17FF53              lbsr  L0159
                    0206      D628                ldb   <u0028
                    0208      C4BF                andb  #$BF
                    020a      D728                stb   <u0028
                    020c      20D5                bra   L01E3

                    020e      5F                  GetSta   clrb
                    020f      340D                pshs  dp,b,cc
                    0211      170312              lbsr  UtoDP
                    0214      8101                cmpa  #$01
                    0216      2618                bne   L0230

                    0218      DC34                ldd   <u0034
                    021a      270C                beq   L0228

                    021c      4D                  tsta
                    021d      2702                beq   L0221

                    021f      C6FF                ldb   #$FF
                    0221      AE26                L0221    ldx   $06,y
                    0223      E702                stb   $02,x
                    0225      1600DE              lbra  L0306

                    0228      3505                L0228    puls  b,cc
                    022a      1A01                orcc  #$01
                    022c      C6F6                ldb   #$F6
                    022e      3588                puls  pc,dp
                    0230      8128                L0230    cmpa  #$28
                    0232      2624                bne   L0258

                    0234      DC1D                ldd   <u001D
                    0236      0D1F                tst   <u001F
                    0238      2706                beq   L0240

                    023a      C504                bitb  #$04
                    023c      2602                bne   L0240

                    023e      C4F7                andb  #$F7
                    0240      AE26                L0240    ldx   $06,y
                    0242      ED06                std   $06,x
                    0244      5F                  clrb
                    0245      9620                lda   <u0020
                    0247      8580                bita  #$80
                    0249      2602                bne   L024D

                    024b      CA10                orb   #$10
                    024d      8520                L024D    bita  #$20
                    024f      2602                bne   L0253

                    0251      CA40                orb   #$40
                    0253      E702                L0253    stb   $02,x
                    0255      1600AE              lbra  L0306
                    0258      8106                L0258    cmpa  #$06
                    025a      2604                bne   L0260

                    025c      5F                  clrb
                    025d      1600A6              lbra  L0306
                    0260      81D0                L0260    cmpa  #$D0
                    0262      266A                bne   L02CE

                    0264      D60E                ldb   <V.ERR
                    0266      1026FF48            lbne  L01B2
                    026a      1A50                orcc  #$50
                    026c      DC30                ldd   <u0030
                    026e      932E                subd  <u002E
                    0270      109334              cmpd  <u0034
                    0273      2504                bcs   L0279

                    0275      DC34                ldd   <u0034
                    0277      27AF                beq   L0228

                    0279      1CAF                L0279    andcc #$AF
                    027b      EE26                ldu   $06,y
                    027d      10A346              cmpd  V.TYPE,u
                    0280      2302                bls   L0284

                    0282      EC46                ldd   V.TYPE,u
                    0284      ED46                L0284    std   V.TYPE,u
                    0286      2744                beq   L02CC

                    0288      3406                pshs  b,a
                    028a      3470                pshs  u,y,x
                    028c      ED62                std   $02,s
                    028e      DC2E                ldd   <u002E
                    0290      EDE4                std   ,s
                    0292      EC44                ldd   V.BUSY,u
                    0294      ED64                std   $04,s
                    0296      BE0050              ldx   >$0050
                    0299      E606                ldb   $06,x      * |dest task num
                    029b      B600D0              lda   >$00D0     * |source task num
                    029e      3570                puls  u,y,x      * |dest pt, bytes, srce pt
                    02a0      103F38              os9   F$Move     * |move data
                    02a3      1A50                orcc  #$50
                    02a5      DC34                ldd   <u0034
                    02a7      A3E4                subd  ,s
                    02a9      DD34                std   <u0034
                    02ab      1CAF                andcc #$AF
                    02ad      10830010            cmpd  #$0010
                    02b1      240B                bcc   L02BE

                    02b3      E3E4                addd  ,s
                    02b5      10830010            cmpd  #$0010
                    02b9      2503                bcs   L02BE

                    02bb      17FF09              lbsr  L01C7

                    02be      3506                L02BE    puls  b,a
                    02c0      9E2E                ldx   <u002E
                    02c2      308B                leax  d,x
                    02c4      9C30                cmpx  <u0030
                    02c6      2602                bne   L02CA

                    02c8      9E32                ldx   <u0032
                    02ca      9F2E                L02CA    stx   <u002E
                    02cc      2038                L02CC    bra   L0306

                    02ce      81D2                L02CE    cmpa  #$D2
                    02d0      2613                bne   L02E5

                    02d2      CC0B04              ldd   #$0B04
                    02d5      AE26                ldx   $06,y
                    02d7      ED01                std   $01,x
                    02d9      CC0707              ldd   #$0707
                    02dc      ED04                std   $04,x
                    02de      CC0001              ldd   #$0001
                    02e1      ED06                std   $06,x
                    02e3      2021                bra   L0306

                    02e5      8126                L02E5    cmpa  #$26
                    02e7      2615                bne   L02FE

                    02e9      AE26                ldx   $06,y
                    02eb      10AE23              ldy   $03,y
                    02ee      10AE24              ldy   $04,y
                    02f1      4F                  clra
                    02f2      E6A82C              ldb   <$2C,y
                    02f5      ED04                std   $04,x
                    02f7      E6A82D              ldb   <$2D,y
                    02fa      ED06                std   $06,x
                    02fc      2008                bra   L0306

                    02fe      3505                L02FE    puls  b,cc
                    0300      1A01                orcc  #$01
                    0302      C6D0                ldb   #$D0
                    0304      3588                puls  pc,dp
                    0306      358D                L0306    puls  pc,dp,b,cc
                    0308      3440                L0308    pshs  u
                    030a      1F98                tfr   b,a
                    030c      338D0446            leau  >L0756,pcr
                    0310      9E01                ldx   <V.PORT
                    0312      C40F                andb  #$0F
                    0314      58                  lslb
                    0315      58                  lslb
                    0316      33C5                leau  b,u
                    0318      44                  lsra
                    0319      44                  lsra
                    031a      44                  lsra
                    031b      44                  lsra
                    031c      44                  lsra
                    031d      8803                eora  #$03
                    031f      8403                anda  #$03
                    0321      3403                pshs  a,cc
                    0323      961D                lda   <u001D
                    0325      44                  lsra
                    0326      44                  lsra
                    0327      8438                anda  #$38
                    0329      AA61                ora   $01,s
                    032b      A761                sta   $01,s
                    032d      8A80                ora   #$80
                    032f      1A50                orcc  #$50
                    0331      A703                sta   $03,x
                    0333      ECC1                ldd   ,u++
                    0335      1E89                exg   a,b
                    0337      ED84                std   ,x
                    0339      A661                lda   $01,s
                    033b      A703                sta   $03,x
                    033d      ECC4                ldd   ,u
                    033f      9721                sta   <u0021
                    0341      8A06                ora   #$06
                    0343      A702                sta   $02,x
                    0345      D729                stb   <u0029
                    0347      35C3                puls  pc,u,a,cc
                    0349      5F                  SetSta   clrb
                    034a      340D                pshs  dp,b,cc
                    034c      1701D7              lbsr  UtoDP

                    034f      81D1                cmpa  #$D1
                    0351      267F                bne   L03D2

                    0353      EE26                ldu   $06,y
                    0355      AE44                ldx   V.BUSY,u
                    0357      EC46                ldd   V.TYPE,u
                    0359      3416                pshs  x,b,a
                    035b      2764                beq   L03C1

                    035d      DC3A                L035D    ldd   <u003A
                    035f      10933E              cmpd  <u003E
                    0362      2607                bne   L036B

                    0364      DC3C                ldd   <u003C
                    0366      830001              subd  #$0001
                    0369      200A                bra   L0375

                    036b      830001              L036B    subd  #$0001
                    036e      109338              cmpd  <u0038
                    0371      2402                bcc   L0375

                    0373      DC3C                ldd   <u003C
                    0375      9338                L0375    subd  <u0038
                    0377      274D                beq   L03C6

                    0379      10A3E4              cmpd  ,s
                    037c      2302                bls   L0380

                    037e      ECE4                ldd   ,s
                    0380      3406                L0380    pshs  b,a
                    0382      BE0050              ldx   >$0050
                    0385      A606                lda   $06,x
                    0387      F600D0              ldb   >$00D0
                    038a      DE38                ldu   <u0038
                    038c      AE64                ldx   $04,s
                    038e      10AEE4              ldy   ,s
                    0391      1A50                orcc  #$50
                    0393      103F38              os9   F$Move
                    0396      ECE4                ldd   ,s
                    0398      DE38                ldu   <u0038
                    039a      33CB                leau  d,u
                    039c      11933C              cmpu  <u003C
                    039f      2502                bcs   L03A3

                    03a1      DE3E                ldu   <u003E
                    03a3      DF38                L03A3    stu   <u0038
                    03a5      4F                  clra
                    03a6      D640                ldb   <u0040
                    03a8      E3E4                addd  ,s
                    03aa      D740                stb   <u0040
                    03ac      1CAF                andcc #$AF
                    03ae      ECE4                ldd   ,s
                    03b0      AE64                ldx   $04,s
                    03b2      308B                leax  d,x
                    03b4      AF64                stx   $04,s
                    03b6      EC62                ldd   $02,s
                    03b8      A3E1                subd  ,s++
                    03ba      EDE4                std   ,s
                    03bc      269F                bne   L035D

                    03be      17FD98              lbsr  L0159
                    03c1      3264                L03C1    leas  $04,s
                    03c3      160146              lbra  L050C
                    03c6      1A50                L03C6    orcc  #$50
                    03c8      17FD8E              lbsr  L0159
                    03cb      17FD96              lbsr  L0164
                    03ce      248D                bcc   L035D

                    03d0      20EF                bra   L03C1

                    03d2      8128                L03D2    cmpa  #$28
                    03d4      262C                bne   L0402

                    03d6      AE26                ldx   $06,y
                    03d8      EC06                ldd   $06,x
                    03da      0D1F                tst   <u001F
                    03dc      2706                beq   L03E4

                    03de      C504                bitb  #$04
                    03e0      2602                bne   L03E4

                    03e2      CA08                orb   #$08
                    03e4      DD1D                L03E4    std   <u001D
                    03e6      17FF1F              lbsr  L0308
                    03e9      0F22                clr   <u0022
                    03eb      0D0C                tst   <V.QUIT
                    03ed      2610                bne   L03FF

                    03ef      0D0B                tst   <V.INTR
                    03f1      260C                bne   L03FF

                    03f3      0D0D                tst   <V.PCHR
                    03f5      2608                bne   L03FF

                    03f7      D61D                ldb   <u001D
                    03f9      C504                bitb  #$04
                    03fb      2602                bne   L03FF

                    03fd      0C22                inc   <u0022
                    03ff      16010A              L03FF    lbra  L050C
                    0402      812B                L0402    cmpa  #$2B
                    0404      2617                bne   L041D

                    0406      9E01                ldx   <V.PORT
                    0408      A604                lda   $04,x
                    040a      3412                pshs  x,a
                    040c      84FA                anda  #$FA
                    040e      A704                sta   $04,x
                    0410      8E001E              ldx   #$001E
                    0413      103F0A              os9   F$Sleep
                    0416      3512                puls  x,a
                    0418      A704                sta   $04,x
                    041a      1600EF              lbra  L050C
                    041d      811D                L041D    cmpa  #$1D
                    041f      2640                bne   L0461

                    0421      1A50                orcc  #$50
                    0423      9E01                ldx   <V.PORT
                    0425      9628                lda   <u0028
                    0427      8A08                ora   #$08
                    0429      9728                sta   <u0028
                    042b      8D50                bsr   L047D

                    042d      4F                  clra
                    042e      A784                sta   ,x
                    0430      1A50                L0430    orcc  #$50
                    0432      A605                lda   $05,x
                    0434      8540                bita  #$40
                    0436      260C                bne   L0444

                    0438      1CAF                andcc #$AF
                    043a      8E0001              ldx   #$0001
                    043d      103F0A              os9   F$Sleep
                    0440      9E01                ldx   <V.PORT
                    0442      20EC                bra   L0430

                    0444      8A40                L0444    ora   #$40
                    0446      A703                sta   $03,x
                    0448      8E001E              ldx   #$001E
                    044b      103F0A              os9   F$Sleep
                    044e      9E01                ldx   <V.PORT
                    0450      1A50                orcc  #$50
                    0452      A603                lda   $03,x
                    0454      84BF                anda  #$BF
                    0456      A703                sta   $03,x
                    0458      9628                lda   <u0028
                    045a      84F7                anda  #$F7
                    045c      9728                sta   <u0028
                    045e      1600AB              lbra  L050C
                    0461      811A                L0461    cmpa  #$1A
                    0463      262B                bne   L0490

                    0465      A625                lda   $05,y
                    0467      AE26                ldx   $06,y
                    0469      E605                ldb   $05,x
                    046b      1A50                orcc  #$50
                    046d      9E34                ldx   <u0034
                    046f      2605                bne   L0476

                    0471      DD25                std   <u0025
                    0473      160096              lbra  L050C
                    0476      3501                L0476    puls  cc
                    0478      103F08              os9   F$Send
                    047b      358C                puls  pc,dp,b
                    047d      860D                L047D    lda   #$0D
                    047f      A701                sta   $01,x
                    0481      0F40                clr   <u0040
                    0483      DC3E                ldd   <u003E
                    0485      DD3A                std   <u003A
                    0487      DD38                std   <u0038
                    0489      9621                lda   <u0021
                    048b      8A04                ora   #$04
                    048d      A702                sta   $02,x
                    048f      39                  rts
                    0490      811B                L0490    cmpa  #$1B
                    0492      260C                bne   L04A0

                    0494      A625                lda   $05,y
                    0496      9125                cmpa  <u0025
                    0498      2604                bne   L049E

                    049a      4F                  clra
                    049b      5F                  clrb
                    049c      DD25                std   <u0025
                    049e      206C                L049E    bra   L050C

                    04a0      819A                L04A0    cmpa  #$9A
                    04a2      260A                bne   L04AE

                    04a4      A625                lda   $05,y
                    04a6      AE26                ldx   $06,y
                    04a8      E605                ldb   $05,x
                    04aa      DD23                std   <u0023
                    04ac      205E                bra   L050C

                    04ae      819B                L04AE    cmpa  #$9B
                    04b0      260E                bne   L04C0

                    04b2      1A50                orcc  #$50
                    04b4      A625                lda   $05,y
                    04b6      9123                cmpa  <u0023
                    04b8      2604                bne   L04BE

                    04ba      4F                  clra
                    04bb      5F                  clrb
                    04bc      DD23                std   <u0023
                    04be      204C                L04BE    bra   L050C

                    04c0      812A                L04C0    cmpa  #$2A
                    04c2      2615                bne   L04D9

                    04c4      1A50                orcc  #$50
                    04c6      A625                lda   $05,y
                    04c8      8E0000              ldx   #$0000
                    04cb      9125                cmpa  <u0025
                    04cd      2602                bne   L04D1

                    04cf      9F25                stx   <u0025
                    04d1      9123                L04D1    cmpa  <u0023
                    04d3      2602                bne   L04D7

                    04d5      9F23                stx   <u0023
                    04d7      2033                L04D7    bra   L050C

                    04d9      8129                L04D9    cmpa  #$29
                    04db      2627                bne   L0504

                    04dd      9E01                ldx   <V.PORT
                    04df      1A50                orcc  #$50
                    04e1      0D28                tst   <u0028
                    04e3      2619                bne   L04FE

                    04e5      A606                lda   $06,x
                    04e7      84B0                anda  #$B0
                    04e9      9720                sta   <u0020
                    04eb      5F                  clrb
                    04ec      8510                bita  #$10
                    04ee      2602                bne   L04F2

                    04f0      CA02                orb   #$02
                    04f2      8520                L04F2    bita  #$20
                    04f4      2602                bne   L04F8

                    04f6      CA01                orb   #$01
                    04f8      D728                L04F8    stb   <u0028
                    04fa      860F                lda   #$0F
                    04fc      A704                sta   $04,x
                    04fe      C60F                L04FE    ldb   #$0F
                    0500      E701                stb   $01,x
                    0502      2008                bra   L050C

                    0504      3505                L0504    puls  b,cc
                    0506      1A01                orcc  #$01
                    0508      C6D0                ldb   #$D0
                    050a      3588                puls  pc,dp
                    050c      358D                L050C    puls  pc,dp,b,cc
                    050e      1A50                L050E    orcc  #$50
                    0510      FC0050              ldd   >$0050
                    0513      9705                sta   <V.WAKE
                    0515      1F01                tfr   d,x
                    0517      A60C                lda   $0C,x
                    0519      8A08                ora   #$08
                    051b      A70C                sta   $0C,x
                    051d      8E0001              ldx   #$0001     * |remainer of slice
                    0520      103F0A              os9   F$Sleep    * |sleep
                    0523      1CAF                andcc #$AF       * |carry set on error
                    0525      39                  rts

                    0526      3440                UtoDP    pshs  u     U to DP, clean stack
                    0528      3508                puls  dp    |
                    052a      3261                leas  $01,s |
                    052c      39                  rts         |

                    052d      01                  L052D    fcb   $01
                    052e      6F01                clr   $01,x
                    0530      1C00                andcc #$00
                    0532      1D                  sex
                    0533      01                  fcb   $01
                    0534      C8FF                eorb  #$FF
                    0536      F3FFF3              addd  >$FFF3
                    0539      002C                neg   <u002C
                    053b      3408                IRQser   pshs  dp
                    053d      8DE7                bsr   UtoDP

                    053f      0F27                clr   <u0027
                    0541      109E01              ldy   <V.PORT
                    0544      E622                ldb   $02,y
                    0546      C501                bitb  #$01
                    0548      2710                beq   L055A

                    054a      0D40                tst   <u0040
                    054c      2708                beq   L0556

                    054e      E625                ldb   $05,y
                    0550      C520                bitb  #$20
                    0552      10260131            lbne  L0687
                    0556      1A01                L0556    orcc  #$01
                    0558      3588                puls  pc,dp
                    055a      308DFFCF            L055A    leax  >L052D,pcr
                    055e      C40E                andb  #$0E
                    0560      3A                  abx
                    0561      1F50                tfr   pc,d
                    0563      E384                addd  ,x
                    0565      1F05                tfr   d,pc
                    0567      E622                L0567    ldb   $02,y
                    0569      C501                bitb  #$01
                    056b      27ED                beq   L055A

                    056d      9605                lda   <V.WAKE
                    056f      270B                beq   L057C

                    0571      5F                  clrb
                    0572      D705                stb   <V.WAKE
                    0574      1F01                tfr   d,x
                    0576      A60C                lda   $0C,x
                    0578      84F7                anda  #$F7
                    057a      A70C                sta   $0C,x
                    057c      1CFE                L057C    andcc #$FE
                    057e      3588                puls  pc,dp
                    0580      9E2C                ldx   <u002C
                    0582      A625                lda   $05,y
                    0584      2B0D                bmi   L0593

                    0586      D629                ldb   <u0029
                    0588      8D2F                L0588    bsr   L05B9

                    058a      5A                  decb
                    058b      26FB                bne   L0588

                    058d      2002                bra   L0591

                    058f      9E2C                ldx   <u002C
                    0591      A625                L0591    lda   $05,y
                    0593      851E                L0593    bita  #$1E
                    0595      2705                beq   L059C

                    0597      170198              lbsr  L0732

                    059a      20F5                bra   L0591

                    059c      8501                L059C    bita  #$01
                    059e      2704                beq   L05A4

                    05a0      8D17                bsr   L05B9

                    05a2      20ED                bra   L0591

                    05a4      0D27                L05A4    tst   <u0027
                    05a6      260D                bne   L05B5

                    05a8      DC25                ldd   <u0025
                    05aa      2709                beq   L05B5

                    05ac      D727                stb   <u0027     * |signal code
                    05ae      103F08              os9   F$Send     * |send signal
                    05b1      4F                  clra
                    05b2      5F                  clrb
                    05b3      DD25                std   <u0025
                    05b5      9F2C                L05B5    stx   <u002C
                    05b7      20AE                bra   L0567

                    05b9      3404                L05B9    pshs  b
                    05bb      A6A4                lda   ,y
                    05bd      2736                beq   L05F5

                    05bf      0D22                tst   <u0022
                    05c1      2632                bne   L05F5

                    05c3      910C                cmpa  <V.QUIT
                    05c5      2604                bne   L05CB

                    05c7      C602                ldb   #$02
                    05c9      2006                bra   L05D1

                    05cb      910B                L05CB    cmpa  <V.INTR
                    05cd      2611                bne   L05E0

                    05cf      C603                ldb   #$03
                    05d1      3402                L05D1    pshs  a
                    05d3      0D27                tst   <u0027
                    05d5      2607                bne   L05DE

                    05d7      9603                lda   <V.LPRC    * | dest proc id
                    05d9      D727                stb   <u0027     * | signal code
                    05db      103F08              os9   F$Send     * | send signal
                    05de      3502                L05DE    puls  a
                    05e0      910F                L05E0    cmpa  <V.XON
                    05e2      2773                beq   L0657

                    05e4      9110                cmpa  <V.XOFF
                    05e6      10270081            lbeq  L066B

                    05ea      910D                cmpa  <V.PCHR
                    05ec      2607                bne   L05F5

                    05ee      DE09                ldu   <V.DEV2
                    05f0      2703                beq   L05F5

                    05f2      A7C808              sta   <V.PAUS,u
                    05f5      A780                L05F5    sta   ,x+
                    05f7      9C30                cmpx  <u0030
                    05f9      2602                bne   L05FD

                    05fb      9E32                ldx   <u0032
                    05fd      9C2E                L05FD    cmpx  <u002E
                    05ff      2610                bne   L0611

                    0601      C602                ldb   #$02
                    0603      DA0E                orb   <V.ERR
                    0605      D70E                stb   <V.ERR
                    0607      9C32                cmpx  <u0032
                    0609      2602                bne   L060D

                    060b      9E30                ldx   <u0030
                    060d      301F                L060D    leax  -$01,x
                    060f      200C                bra   L061D

                    0611      DC34                L0611    ldd   <u0034
                    0613      C30001              addd  #$0001
                    0616      DD34                std   <u0034
                    0618      10932A              cmpd  <u002A
                    061b      2702                beq   L061F

                    061d      3584                L061D    puls  pc,b
                    061f      D628                L061F    ldb   <u0028
                    0621      C570                bitb  #$70
                    0623      26F8                bne   L061D

                    0625      961D                lda   <u001D
                    0627      8502                bita  #$02
                    0629      270C                beq   L0637

                    062b      CA20                orb   #$20
                    062d      D728                stb   <u0028
                    062f      A624                lda   $04,y
                    0631      84F5                anda  #$F5
                    0633      A724                sta   $04,y
                    0635      20E6                bra   L061D

                    0637      8501                L0637    bita  #$01
                    0639      270C                beq   L0647

                    063b      CA10                orb   #$10
                    063d      D728                stb   <u0028
                    063f      A624                lda   $04,y
                    0641      84FA                anda  #$FA
                    0643      A724                sta   $04,y
                    0645      20D6                bra   L061D

                    0647      9610                L0647    lda   <V.XOFF
                    0649      27D2                beq   L061D

                    064b      CA40                orb   #$40
                    064d      D728                stb   <u0028
                    064f      9743                sta   <u0043
                    0651      C60F                ldb   #$0F
                    0653      E721                stb   $01,y
                    0655      20C6                bra   L061D

                    0657      D61D                L0657    ldb   <u001D
                    0659      C504                bitb  #$04
                    065b      1027FF96            lbeq  L05F5

                    065f      9628                lda   <u0028
                    0661      84FB                anda  #$FB
                    0663      9728                sta   <u0028
                    0665      860F                lda   #$0F
                    0667      A721                sta   $01,y
                    0669      20B2                bra   L061D

                    066b      D61D                L066B    ldb   <u001D
                    066d      C504                bitb  #$04
                    066f      1027FF82            lbeq  L05F5

                    0673      9628                lda   <u0028
                    0675      8A04                ora   #$04
                    0677      9728                sta   <u0028
                    0679      860D                lda   #$0D
                    067b      A721                sta   $01,y
                    067d      209E                bra   L061D

                    067f      A625                lda   $05,y
                    0681      8520                bita  #$20
                    0683      1027FEE0            lbeq  L0567

                    0687      9E3A                L0687    ldx   <u003A
                    0689      9643                lda   <u0043
                    068b      2F06                ble   L0693

                    068d      A7A4                sta   ,y
                    068f      8A80                ora   #$80
                    0691      9743                sta   <u0043
                    0693      0D40                L0693    tst   <u0040
                    0695      2734                beq   L06CB

                    0697      D628                ldb   <u0028
                    0699      C508                bitb  #$08
                    069b      262E                bne   L06CB

                    069d      C407                andb  #$07
                    069f      D41D                andb  <u001D
                    06a1      2628                bne   L06CB

                    06a3      D63B                ldb   <u003B
                    06a5      50                  negb
                    06a6      C10F                cmpb  #$0F
                    06a8      2302                bls   L06AC
                    06aa      C60F                ldb   #$0F

                    06ac      D140                L06AC    cmpb  <u0040
                    06ae      2302                bls   L06B2

                    06b0      D640                ldb   <u0040
                    06b2      3404                L06B2    pshs  b
                    06b4      A680                L06B4    lda   ,x+
                    06b6      A7A4                sta   ,y
                    06b8      5A                  decb
                    06b9      26F9                bne   L06B4

                    06bb      9C3C                cmpx  <u003C
                    06bd      2502                bcs   L06C1

                    06bf      9E3E                ldx   <u003E
                    06c1      9F3A                L06C1    stx   <u003A
                    06c3      D640                ldb   <u0040
                    06c5      E0E0                subb  ,s+
                    06c7      D740                stb   <u0040
                    06c9      2604                bne   L06CF

                    06cb      860D                L06CB    lda   #$0D
                    06cd      A721                sta   $01,y

                    06cf      16FE95              L06CF    lbra  L0567
                    06d2      A626                lda   $06,y
                    06d4      1F89                tfr   a,b
                    06d6      C4B0                andb  #$B0
                    06d8      D720                stb   <u0020
                    06da      D628                ldb   <u0028
                    06dc      C4FC                andb  #$FC
                    06de      8510                bita  #$10
                    06e0      2602                bne   L06E4

                    06e2      CA02                orb   #$02
                    06e4      8520                L06E4    bita  #$20
                    06e6      2602                bne   L06EA

                    06e8      CA01                orb   #$01
                    06ea      D728                L06EA    stb   <u0028
                    06ec      8508                bita  #$08
                    06ee      2734                beq   L0724

                    06f0      8580                bita  #$80
                    06f2      261E                bne   L0712

                    06f4      961D                lda   <u001D
                    06f6      8510                bita  #$10
                    06f8      270E                beq   L0708

                    06fa      9E16                ldx   <V.PDLHD
                    06fc      270A                beq   L0708

                    06fe      8601                lda   #$01
                    0700      A7883F              L0700    sta   <$3F,x
                    0703      AE883D              ldx   <$3D,x
                    0706      26F8                bne   L0700

                    0708      8620                L0708    lda   #$20
                    070a      9A0E                ora   <V.ERR
                    070c      970E                sta   <V.ERR
                    070e      C4FB                andb  #$FB
                    0710      D728                stb   <u0028
                    0712      0D27                L0712    tst   <u0027
                    0714      260E                bne   L0724

                    0716      DC23                ldd   <u0023
                    0718      5D                  tstb
                    0719      2709                beq   L0724

                    071b      103F08              os9   F$Send     * |send signal
                    071e      D727                stb   <u0027
                    0720      4F                  clra
                    0721      5F                  clrb
                    0722      DD23                std   <u0023
                    0724      860F                L0724    lda   #$0F
                    0726      A721                sta   $01,y
                    0728      16FE3C              lbra  L0567
                    072b      A625                lda   $05,y

                    072d      8D03                bsr   L0732

                    072f      16FE35              lbra  L0567

                    0732      3404                L0732    pshs  b
                    0734      5F                  clrb
                    0735      8502                bita  #$02
                    0737      2702                beq   L073B

                    0739      CA04                orb   #$04
                    073b      8504                L073B    bita  #$04
                    073d      2702                beq   L0741

                    073f      CA01                orb   #$01
                    0741      8508                L0741    bita  #$08
                    0743      2702                beq   L0747

                    0745      CA02                orb   #$02
                    0747      8510                L0747    bita  #$10
                    0749      2606                bne   L0751

                    074b      CA08                orb   #$08
                    074d      DA0E                orb   <V.ERR
                    074f      D70E                stb   <V.ERR
                    0751      3584                L0751    puls  pc,b

*[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[

                    0753      01                  Data     fcb   $01
                    0754      01                  fcb   $01
                    0755      0A28                dec   <u0028
                    0757      E901                adcb  $01,x
                    0759      01                  fcb   $01
                    075a      0F00                clr   <V.PAGE
                    075c      01                  fcb   $01
                    075d      01                  fcb   $01
                    075e      0780                asr   <u0080
                    0760      41                  fcb   $41 A
                    0761      0403                lsr   <V.LPRC
                    0763      C081                subb  #$81

                    0765      0801                lsl   <V.PORT
                    0767      E0C1                subb  ,u++
                    0769      0E00                jmp   <V.PAGE
                    076b      F0C10E              subb  >$C10E
                    076e      0078                neg   <u0078
                    0770      C10E                cmpb  #$0E
                    0772      003C                neg   <u003C
                    0774      8108                cmpa  #$08
                    0776      001E                neg   <u001E
                    0778      8108                cmpa  #$08
                    077a      0014                neg   <V.MODADR
                    077c      8108                cmpa  #$08
                    077e      000F                neg   <V.XON
                    0780      8108                cmpa  #$08
                    0782      000A                neg   <u000A
                    0784      8108                cmpa  #$08
                    0786      000A                neg   <u000A
                    0788      8108                cmpa  #$08
                    078a      000A                neg   <u000A
                    078c      8108                cmpa  #$08
                    078e      000A                neg   <u000A
                    0790      8108                cmpa  #$08
                    0792      0025                neg   <u0025
                    0794      8108                cmpa  #$08
                    0796      85C9D1              emod
                    0799      eom                 equ   *
