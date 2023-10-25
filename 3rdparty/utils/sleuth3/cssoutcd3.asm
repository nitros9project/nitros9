***************************************
**
outpt               lda       instx,u             output instr
                    cmpa      #$4b                chk ign
                    bne       outor
                    sta       dorgs,u             set org flag
                    rts
outor               lda       instx,u             chk type
                    bmi       outfc
                    cmpa      #$48                h
                    bne       outnh
outfc               leax      fcbxx,u             gen fcb stmt
                    lbsr      xpdat
                    leax      inst1,u
                    ldb       fllth,u
outhw               beq       outhx
                    lbsr      xot2h               xx
                    lda       #$2c                ,
                    lbsr      xoute
                    lda       #$24                $
                    lbsr      xoute
                    decb
                    bra       outhw
outhx               lbsr      xot2h               xx
                    tst       instx,u
                    bpl       outhy
                    lbra      outi7
outhy               lbra      xcrlf
outnh               cmpa      #$41
                    bne       outnb
                    leax      fdbxx,u             gen fdb stmt
                    lbsr      xpdat
                    lda       zlabel,u            prefix z
                    tst       pmode,u             chk for 6809
                    bpl       outzx
                    tst       os9flx,u            chk for OS/9
                    beq       outzx
                    lda       xlabel,u            prefix x
outzx               lbsr      xoute               z/x
                    leax      raddr,u
                    lbsr      xot4h               xxxx
                    bra       outhy
outnb               cmpa      #$43                c
                    bne       outna
                    leax      fccxx,u             gen fcc stmt
                    lbsr      xpdat
                    lda       fccxx+3,u           fcs->fcc
                    anda      #$ef
                    sta       fccxx+3,u
                    bra       outhy
outna               cmpa      #$52                r
                    bne       outnr
                    leax      rmbes,pcr           gen rmb stmt
                    lbsr      xpdat
                    leax      rmblth,u            xxxx
                    lbsr      xot4h
                    bra       outhy
outnr               lda       #$03                gen instruction
                    lbsr      xoute
                    tst       posfl,u             chk pos-ind switch
                    beq       outad
                    tst       flabl,u             chk labelled
                    beq       outad
                    lda       pmode,u             chk cpu mode
                    cmpa      #$05
                    beq       outad
                    cmpa      #$02
                    beq       outad
                    ldd       raddr,u             chk addr for within range
                    cmpd      eaddr,u
outab               bhi       outad
                    cmpd      faddr,u
outac               bls       outag
outad               lbra      outgi               not pos-ind
outag               lda       flmod,u             addr mode
                    cmpa      #$02
                    blt       outad
                    cmpa      #$04
                    bgt       outad
                    beq       outaj
outai               inc       flpos,u             set pos-ind flag
                    bra       outad
outaj               ldb       inam4,u             chk suffix
                    cmpb      #$73                for s,u,x,y
                    blt       outad
                    lda       inam1,u             chk name
                    cmpa      #$63                for 'c'
                    beq       outam
                    cmpa      #$6c                for 'l'
                    bne       outad
                    ldx       #$6561              ld? #addr -> lea? addr,pcr
                    stx       inam2,u             (cc affected)
                    bra       outai
outam               cmpb      #$73                chk for suffix 's'
                    beq       outas
                    leax      lposr,pcr           suffix u,x,y
                    bra       outat
outas               leax      lposs,pcr           suffix s
outat               lda       ,x                  gen pos-ind code for imm
                    beq       outaz               null=quit
                    stx       baddr,u             save place
                    cmpa      #$2a                *=reg
                    beq       outau
                    cmpa      #$21                !=zxxxx
                    beq       outav
                    cmpa      #$25                %=crlf
                    beq       outaw
                    cmpa      #$5b                [=$03
                    bne       outan
                    lda       #$03
                    bra       outax
outan               cmpa      #$5d                ]=$05
                    bne       outax
                    lda       #$05
outax               lbsr      xoute               output
outay               ldx       baddr,u             remember place
                    leax      $01,x
                    bra       outat
outau               tfr       b,a                 reg name
                    bra       outax
outav               lda       zulabe,u            z/u
                    lbsr      xoute
                    leax      raddr,u             xxxx
                    lbsr      xot4h
                    bra       outay
outaw               lbsr      xcrlf               crlf
                    bra       outay
outaz               lbra      outi6               exit
outgi               leax      insxx,u             instr name
                    lbsr      xpdat
                    lda       #$05                tab
                    lbsr      xoute
                    tst       svcflg,u            check for OS/9 call
                    bpl       ousw3
                    leax      svcend,pcr          check for table overflow
                    cmpx      flinx,u
                    bhi       ousb3
ousa3               lda       #$24                $ invalid
                    leax      inst3,u             second byte
                    lbsr      xot2h               xx
                    bra       ousd3
ousb3               ldx       flinx,u             point to name table
                    lda       ,x
                    cmpa      #$20                check validity
                    beq       ousa3
                    ldb       #(4+(2*2))
ousc3               lda       ,x+
                    cmpa      #$20
                    bls       ousd3
                    lbsr      xoute
                    decb
                    bne       ousc3
ousd3               lda       svcflg,u            reset flag
                    anda      #$0f
                    sta       svcflg,u
                    lbra      outi6               exit
ousw3               lda       flmod,u             addr mode
                    ldb       flinx,u             instr variant byte
                    cmpa      #$01                chk inh
                    lbne      outb1
outa1               tst       flspc,u             chk special
                    beq       outj1
                    lda       flopc,u             instr
                    cmpa      #$20                chk exg/tfr
                    bpl       outf1
                    pshs      b
                    andb      #$f0                source reg
                    lsrb
                    lsrb
                    lsrb
                    clra
                    pshs      u
                    leau      tfrexc,pcr
                    pshs      u
                    addd      ,s++
                    puls      u
                    tfr       d,x
                    ldx       ,x
                    stx       inam1,u
                    puls      b
                    andb      #$0f                dest reg
                    aslb
                    clra
                    pshs      u
                    leau      tfrexc,pcr
                    pshs      u
                    addd      ,s++
                    puls      u
                    tfr       d,x
                    ldx       ,x
                    stx       inam4,u
                    lda       #$2c                ,
                    sta       inam3,u
                    leax      inam1,u             output source,dest
                    lbsr      xpdat
                    bra       outh1
outj1               lda       pmode,u             chk cpu mode
                    cmpa      #$02
                    bne       outh1               exit if not 6502
                    lda       inst1,u             chk instr
                    anda      #$9f
                    cmpa      #$0a
                    bne       outh1               for $0a,$2a,$4a,$6a
                    lda       #$61                accum instr
                    lbsr      xoute
outh1               lbra      outi6               exit
outf1               cmpa      #$3c                chk cwai
                    bne       outk1
                    clr       inam4,u             fake 8-bit imm
                    stb       raddr,u
                    lbra      outd4
outk1               lda       inam4,u             psh/pul
                    eora      #$06                exg s and u
                    leax      pshpul,u
                    sta       $02,x               fix table
outl1               aslb                          carry=sign bit
                    bcc       outm1
                    stx       raddr,u
                    ldx       ,x
                    stx       inam4,u             reg name
                    leax      inam4,u
                    lbsr      xpdat               output name
                    ldx       raddr,u
                    tstb
                    beq       outx1
                    lda       #$2c                ,
                    lbsr      xoute
outm1               leax      $02,x               chk for more
                    tstb
                    bne       outl1
outx1               lbra      outi6               exit
outb1               cmpa      #$02                chk dir
                    bne       outb2
outa2               tst       flpos,u             chk pos-ind flag
                    bne       outd2
                    lda       #$3c                force dir with <
outc2               ldb       pmode,u             chk cpu mode
                    orb       crofl,u             and x-asmb flag
                    bpl       outd2
                    lbsr      xoute               force mode
outd2               lda       zulabe,u            z/u
                    lbsr      xoute
                    leax      raddr,u             xxxx
                    lbsr      xot4h
                    tst       flpos,u             chk pos-ind flag
                    beq       outx2
                    leax      lcpcr,pcr           ,pcr
                    lbsr      xpdat
                    bra       outz2
outx2               lda       pmode,u             chk cpu mode
                    cmpa      #$02
                    bne       outz2
outw2               ldb       flmod,u             chk mode
                    cmpb      #$08
                    bne       outy2
                    lda       #$29                )
                    lbsr      xoute
outy2               tst       inam5,u             chk x/y
                    beq       outz2
                    lda       #$2c                ,
                    lbsr      xoute
                    lda       inam5,u             x/y
                    lbsr      xoute
                    cmpb      #$07
                    bne       outz2
                    lda       #$29                )
                    lbsr      xoute
outz2               lbra      outi6               exit
outb2               cmpa      #$03                chk ext
                    bne       outb3
                    tst       posfl,u             chk pos-ind switch
                    bne       outd3
                    lda       #$3e                force ext with >
outc3               bra       outc2
outd3               bra       outd2
outb3               cmpa      #$04                chk imm
                    bne       outb4
outa4               tst       flpos,u             chk pos-ind flag
                    bne       outd3
outd4               lda       #$23                #
                    lbsr      xoute
                    ldb       inam4,u             chk suffix
                    cmpb      #$73                for 's'
                    bge       outd3
                    lda       #$24                $
                    lbsr      xoute
                    leax      raddr,u
                    lbsr      xot2h               xx
                    cmpb      #$64                chk for 'd'
                    bne       outf4
                    lbsr      xot2h               xx
outf4               lbra      outi6               exit
outb4               cmpa      #$05                chk inx
                    lbne      outb5
outa5               tst       pmode,u             chk cpu mode
                    bpl       outc5
                    tstb
                    lbmi      outd5               chk inx type
                    andb      #$1f                r+-5bits
                    bitb      #$10                chk neg
                    bne       outg5
                    tst       os9flx,u            chk for OS/9
                    beq       outc5
                    tst       pmode,u             chk for 6809
                    bpl       outc5
                    lda       flreg,u             chk for u-reg
                    cmpa      #$04
                    bne       outc5
                    lda       #$3c                <
                    lbra      oux3v
outg5               lda       #$2d                -
                    lbsr      xoute
                    orb       #$f0
                    negb
                    andb      #$0f
                    bne       outc5               chk $10
                    ldb       #$10
outc5               stb       raddr,u
                    clr       flind,u
                    lda       pmode,u             chk cpu mode
                    cmpa      #$05
                    bne       oupt0
                    tst       crofl,u             chk x-asmb flag
                    beq       outf5
                    lda       #$3c                <
                    lbsr      xoute
outf5               lda       zulabe,u            z/u
                    lbsr      xoute
                    lda       #$30                0
                    lbsr      xoute
                    bra       oupta
oupt0               lda       #$24                $
oupta               lbsr      xoute
                    leax      raddr,u             xx
                    lbsr      xot2h
oupt1               lda       #$2c                ,
                    lbsr      xoute
                    tst       flmin,u             chk auto-decr
                    beq       oupt3
oupt2               lda       #$2d                -
                    lbsr      xoute
                    dec       flmin,u
                    bne       oupt2
oupt3               ldb       flreg,u             reg name
                    clra
                    pshs      u
                    leau      tfrexc,pcr
                    pshs      u
                    addd      ,s++
                    puls      u
                    tfr       d,x
                    ldx       $02,x
                    stx       inam4,u
oupt4               leax      inam4,u
                    lbsr      xpdat               output reg name
                    tst       flpls,u             chk auto-incr
                    beq       oupt6
oupt5               lda       #$2b                +
                    lbsr      xoute
                    dec       flpls,u
                    bne       oupt5
oupt6               tst       flind,u             chk indir
                    beq       oupt9
                    lda       #$5d                ]
                    lbsr      xoute
oupt9               lbra      outi6               exit
outd5               tst       flind,u             chk indir
                    beq       oute5
                    lda       #$5b                [
                    lbsr      xoute
oute5               andb      #$0f                addr mode field
                    bne       oux0z               ,r+
oux0a               inc       flpls,u
                    bra       oupt1
oux0z               cmpb      #$01
                    bne       oux1z               ,r++
oux1a               inc       flpls,u
                    bra       oux0a
oux1z               cmpb      #$02
                    bne       oux2z               ,-r
oux2a               inc       flmin,u
                    bra       oupt1
oux2z               cmpb      #$03
                    bne       oux3z               ,--r
oux3a               inc       flmin,u
                    bra       oux2a
oux3z               cmpb      #$04
                    bne       oux4z               ,r
                    ldx       #$0000
                    stx       raddr,u
                    lda       #$3c                <
oux3u               tst       os9flx,u            chk for OS/9
                    beq       oux3y
                    tst       pmode,u             chk for 6809
                    bpl       oux3y
                    ldb       flreg,u             chk for u-reg
                    cmpb      #$04
                    bne       oux3y
oux3v               tst       crofl,u             chk x-asmb flag
                    beq       oux3x
                    tst       os9flx,u            chk for OS/9
                    beq       oux3x
                    tst       pmode,u             chk for 6809
                    bpl       oux3x
                    ldb       flreg,u             chk for u-reg
                    cmpb      #$04
                    beq       oux3x
                    tst       flind,u             chk for [ and </>
                    bne       oux3x
                    lbsr      xoute               < or >
oux3x               lda       zulabe,u            z/u
                    lbsr      xoute
                    leax      raddr,u
                    lbsr      xot4h               xxxx
oux3y               lbra      oupt1
oux4z               cmpb      #$05
                    bne       oux5z               b,r
oux5a               lda       #$62
oux5b               lbsr      xoute
                    lbra      oupt1
oux5z               cmpb      #$06
                    bne       oux6z               a,r
oux6a               lda       #$61
                    bra       oux5b
oux6z               cmpb      #$08
                    bne       oux8z               r+-8bits
oux8a               tst       raddr,u             chk neg
                    bpl       oux8c
                    lda       #$2d                -
                    lbsr      xoute
                    neg       raddr,u
oux8b               lbra      oupt0
oux8c               tst       os9flx,u            chk for OS/9
                    beq       oux8b
                    tst       pmode,u             chk for 6809
                    bpl       oux8b
                    lda       flreg,u             chk for u-reg
                    cmpa      #$04
                    bne       oux8b
                    lda       #$3c                <
                    bra       oux3v
oux8z               cmpb      #$09
                    bne       oux9z               r+-16bits
oux9c               tst       os9flx,u            chk for os/9
                    beq       oux9a
                    tst       pmode,u             chk for 6809
                    bpl       oux9a
                    lda       flreg,u             chk for u-reg
                    cmpa      #$04
                    bne       oux9a
                    lda       #$3e                >
                    lbra      oux3v
oux9a               lda       #$24                $
oux9b               lbsr      xoute
                    leax      raddr,u             xxxx
                    lbsr      xot4h
                    lbra      oupt1
oux9z               cmpb      #$0b
                    bne       ouxbz               d,r
ouxba               lda       #$64                d
                    bra       oux5b
ouxbz               cmpb      #$0c
                    bne       ouxcz               pcr+-8bits
                    lda       #$3c                <
ouxca               tst       crofl,u             chk x-asmb flag
                    beq       ouxcb
                    tst       posfl,u             chk pos-ind flag
                    bne       ouxcb
                    lbsr      xoute
ouxcb               lda       zulabe,u            z/u
                    lbsr      xoute
                    leax      raddr,u             xxxx
                    lbsr      xot4h
                    leax      lcpcr,pcr           ,pcr
                    lbsr      xpdat
                    lbra      oupt6
ouxcz               cmpb      #$0d
                    bne       ouxdz               pcr+-16bits
                    lda       #$3e                >
                    bra       ouxca
ouxdz               cmpb      #$0f
                    bne       ouxfz               ext ind
ouxfa               lda       zulabe,u            z/u
                    lbsr      xoute
                    leax      raddr,u             xxxx
                    lbsr      xot4h
                    lbra      oupt6
ouxfz               bra       outi6               exit
outb5               cmpa      #$06                chk rel
                    lbeq      outd2
outb6               ldb       pmode,u             chk cpu mode
                    cmpb      #$02
                    bne       outc6
                    lda       #$28                (
                    lbsr      xoute
                    lbra      outd2
outc6               cmpa      #$07                chk ix0
                    lbeq      oupt1
outb7               cmpa      #$08                chk ix2
                    bne       outb8
                    tst       crofl,u             chk x-asmb flag
                    beq       outf7
                    lda       #$3e                >
                    lbsr      xoute
outf7               lda       zulabe,u            z/u
                    lbra      oux9b
outb8               cmpa      #$0b                chk btb,bsc
                    bpl       outi6
                    tfr       a,b
                    lda       flopc,u             get bit number
                    anda      #$0f
                    lsra
                    adda      #$30                add ascii 0
                    lbsr      xoute
                    lda       #$2c                ,
                    lbsr      xoute
                    lda       zulabe,u            z/u
                    lbsr      xoute
                    lda       #$30                00
                    lbsr      xoute
                    lbsr      xoute
                    leax      inst2,u             xx
                    lbsr      xot2h
                    lda       flmod,u             chk mode
                    cmpa      #$0a
                    beq       outi6
                    lda       #$2c                ,
                    lbsr      xoute
                    lda       zulabe,u            z/u
                    lbsr      xoute
                    leax      zaddr,u             xxxx
                    lbsr      xot4h
outi6               lda       instx,u             chk print ascii
                    cmpa      #$4a
                    bne       outi9
outi7               lda       #$06                print characters
                    lbsr      xoute
                    leax      inst1,u
                    ldb       fllth,u
outi8               lda       ,x+                 print printables
                    anda      #$7f
                    cmpa      #$1f
                    bls       pral1
                    cmpa      #maxprn
                    bls       pral2
pral1               lda       #$2e                .
pral2               lbsr      xoute
                    decb
                    bpl       outi8
outi9               lbra      xcrlf
