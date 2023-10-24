
***************************************
**
disas               ldx       faddr,u             disassemble program code
                    leax      $01,x
                    bne       disro
                    lbsr      newrng              get range
disro               lda       #$24                $
                    sta       ulabel,u
                    sta       xlabel,u
                    sta       zlabel,u
                    sta       zulabe,u
                    lda       comand,u            chk view
                    cmpa      #$56                v
                    beq       disvx
                    lda       #$75                u
                    sta       ulabel,u
                    lda       #$7a                z
                    sta       zlabel,u
                    sta       zulabe,u
                    sta       xlabel,u
                    lda       pmode,u             chk for 6809
                    bpl       disxz
                    tst       os9flx,u            chk for OS/9
                    beq       disxz
                    lda       #$78                x
                    sta       xlabel,u
disxz               ldx       xaddr,u             chk xfer addr
                    leax      $01,x
                    bne       disxf
                    lbsr      sxfer               get xfer addr
disxf               lbsr      dikni               get output file name
disvx               lda       #$04                fix nam and opt
                    sta       names+5,u
                    sta       optes+5,u
                    lbsr      xcrlf               get options
                    clr       crtfl,u
                    clr       prnfl,u
                    leax      lenter,pcr          enter p(printer), etc.
                    lbsr      xpdat
                    lbsr      xinee
                    anda      #$5f
                    cmpa      #$42                b
                    beq       disqb
                    cmpa      #$50                p
                    beq       disqp
                    cmpa      #$54                t
                    beq       disqt
                    tst       disof,u             chk disk output
                    beq       disqt               t by default
                    bra       disor
disqb               inc       crtfl,u             both t and p
disqp               inc       prnfl,u             p
                    lbsr      xcrlf
                    leax      prtnm,pcr           get printer file name
                    lbsr      xpdat
                    leax      prfile,u
                    lbsr      inbufr
                    cmpa      #$0d
                    bne       disor
                    clr       prnfl,u             no file name
                    clr       prfile,u
                    bra       disor
disqt               inc       crtfl,u             t
disor               lbsr      xcrlf               get nam and opt
                    tst       disof,u             chk disk output
                    bne       disxn
                    lda       comand,u            chk view
                    cmpa      #$56                v
                    beq       disp0
                    tst       prnfl,u             chk printer
                    beq       disp0
disxn               leax      lnames,u
                    lbsr      xpdat
                    leax      names+5,u
                    lbsr      rdline
                    lbsr      xcrlf
disxo               leax      loptes,u
                    lbsr      xpdat
                    leax      optes+5,u
                    lbsr      rdline
                    lbsr      xcrlf
disp0               ldx       taddr,u             set addrs
                    stx       eaddr,u
                    ldx       typee,u
                    stx       addre,u
                    sts       stkadr,u
                    lbsr      dmptae              print parms
                    tst       disof,u             chk output file
                    beq       dis0b
                    leax      otfile,u            open output otfile
                    ldd       #(WRITE.*256)+(READ.+WRITE.+PREAD.) access and attributes
                    os9       I$Create
                    bcc       dis0a
                    lda       #$02                error
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
                    clr       otfile,u
                    clr       disof,u
                    clr       prfile,u
                    clr       prtfl,u
                    rts                           could not open
dis0a               clrb                          file desc
                    exg       a,b
                    std       otblok+iobfd,u      file desc
                    ldd       #buflen             buffer length
                    std       otblok+iobbl,u
                    std       otblok+iobcc,u
                    ldd       otblok+iobba,u      buffer addr
                    std       otblok+iobca,u
dis0b               tst       prnfl,u             chk printer file
                    beq       disp1
                    leax      prfile,u            open output prfile
                    ldd       #(WRITE.*256)+(READ.+WRITE.+PREAD.) access and attributes
                    os9       I$Create
                    bcc       dis0d
                    lda       #$02                error
                    leax      errprz,pcr
                    ldy       #errprl
                    os9       I$WritLn
                    tst       disof,u             chk output file
                    beq       dis0c
                    lda       otblok+iobfd+1,u
                    clr       otblok+iobfd,u
                    clr       otblok+iobfd+1,u
                    os9       I$Close
                    clr       otfile,u
                    clr       disof,u
dis0c               clr       prfile,u
                    clr       prnfl,u
                    rts                           could not open
dis0d               clrb                          file desc
                    exg       a,b
                    std       prblok+iobfd,u      file desc
                    ldd       #buflen             buffer length
                    std       prblok+iobbl,u
                    std       prblok+iobcc,u
                    ldd       prblok+iobba,u      buffer addr
                    std       prblok+iobca,u
disp1               clr       phase,u             phase 1
                    clr       svcflg,u
                    lbsr      lastty              restore pause option
                    lda       comand,u            chk view
                    cmpa      #$56                v
                    beq       disp2
                    lbsr      reset
                    ldd       faddr,u             label program entry addr
                    lbsr      adal0
                    tst       os9flx,u            chk for OS/9
                    beq       dis1a
                    ldd       #$0000              label program start addr
                    lbsr      adal0
                    ldd       obstor,u            chk for storage
                    beq       dis1a
                    ldd       #$0000              label storage start addr
                    lbsr      adalu
dis1a               bsr       ckend               chk end
                    bhi       dis1b
                    bsr       decod               decode instruction
                    tst       flabl,u             chk label
                    beq       dis1a
                    lbsr      adald               add a label
                    bra       dis1a
dis1b               ldd       xaddr,u             chk xfer addr
                    cmpd      #$ffff
                    beq       disp2
                    lbsr      adal0               enter into label table
disp2               inc       phase,u             phase 2
                    lbsr      reset
                    lbsr      headr               output nam/opt/data/mod
dis2a               bsr       ckend               chk end
                    bhi       disp3
                    bsr       decod               decode instruction
                    lbsr      ckequ               chk equ's
                    lbsr      outpt               print instruction
                    bra       dis2a
disp3               lbra      ender               put out end
**
ckend               ldd       daddr,u             chk for higher than end
                    cmpd      eaddr,u
                    bhi       ckenz
                    ldd       faddr,u             chk for less than start
                    cmpd      daddr,u
ckenz               rts
**
decod               leax      insbeg,u            decode instruction
                    lda       instr,u             remember instr
                    ldb       insty,u             remember type
                    ldy       #(insend-insbeg)
decoe               clr       ,x+                 clear variables
                    leay      -$01,y
                    bne       decoe
                    sta       instr,u             restore instr
                    sta       inst1,u
                    sta       flopc,u
                    stb       insty,u             restore type
                    stb       instx,u
                    leax      inst1,u
                    stx       iaddr,u
                    ldx       saddr,u
                    leax      -$01,x
                    stx       caddr,u             current instruction addr
                    cmpb      #$43                chk fcc
                    bne       pnfcc
                    ldb       #$20                32 byte limit
                    lbra      iafcc
pnfcc               cmpb      #$48                chk fcb
                    bne       pnfcb
                    ldb       #$08                8 byte limit
                    lbra      iafcc
pnfcb               cmpb      #$4b                chk ign
                    lbeq      next2
                    cmpb      #$52                chk rmb
                    lbeq      iafcc
pnins               inc       flisw,u             start saving bytes
                    cmpb      #$41                chk fdb
                    bne       pnfdb
                    lbsr      getin
                    lbra      inpie
pnfdb               tfr       a,b                 compute addr of opcode
                    clra
                    aslb
                    rola
                    addd      aintab,u
                    std       raddr,u
                    tfr       d,x
                    lda       zlabel,u            init label prefix z
                    sta       zulabe,u
insp9               lda       ,x                  get table entry
                    beq       yecc9               chk for invalid optr
                    cmpa      #$ff                chk for page 2/3
                    beq       inspg
                    tfr       a,b
                    lsra
                    anda      #$7e
                    sta       worka,u             optabx pointer
                    andb      #$03
                    tst       pmode,u             chk cpu mode
                    bpl       insx9
                    lda       inst1,u             chk for page 2/3
                    anda      #$fe
                    cmpa      #$10
                    bne       insx9
                    incb
insx9               stb       fllts,u             length
                    lda       $01,x
                    tfr       a,b
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       flsuf,u             suffix
                    tfr       b,a
                    anda      modmsk,u
                    sta       flmod,u             mode
                    tst       pmode,u             chk cpu mode
                    bne       insnv
                    andb      #$08                chk 6801 instruction
                    bne       yecc9
                    bra       insnv
inspg               ldb       $01,x               page 2/3
                    andb      #$08
                    stb       flmod,u
                    lbsr      getin               next instruction
                    sta       flopc,u
                    leax      intpg9,pcr          point to page 2/3 table
                    ldy       #(intpx9-intpg9)
inpal               cmpa      $02,x               look up in page 2/3 table
                    bne       inpar
                    ldb       $01,x               chk page 2/3
                    andb      #$08
                    cmpb      flmod,u             check for proper page
                    bne       inpar
                    bra       insp9               found match
inpar               leax      $03,x
                    leay      -$03,y
                    bne       inpal
yecc9               lbra      yecch               invalid optr
insnv               lbsr      insnm               get instruction name
                    tst       pmode,u             chk for 6809
                    bpl       inpww
                    ldd       inam3,u             chk for swi2
                    cmpd      #$6932              i2
                    bne       inpww
                    tst       os9flx,u            chk for OS/9
                    beq       inpww
                    ldb       #$ff
                    stb       svcflg,u            set svc flag
                    inc       fllts,u             get call number
inpww               ldb       fllts,u             get fixed portion of instruction
                    decb
                    cmpb      fllth,u
                    beq       inpwx
                    lbsr      getin
                    bra       inpww
inpwx               ldx       iaddr,u             point to last instruction byte
                    ldb       ,x
                    stb       flinx,u
                    tst       svcflg,u            check for OS/9 call
                    lbmi      inswi3              handle it
                    lda       flmod,u             chk addr mode
inpn0               cmpa      #$01                chk inh
                    bne       inpn1
                    tst       flspc,u             chk special flag
                    beq       inpwz
                    lda       flopc,u             retrieve op code
                    cmpa      #$20
                    bpl       inpwz               not tfr or exg
                    tfr       b,a
                    anda      #$88                chk reg numbers
                    beq       inpi1
                    cmpa      #$88
                    beq       inpi1
inpyc               lbra      yecch               bad codes
inpi1               tfr       b,a                 chk dest reg
                    anda      #$0f
                    cmpa      #$06
                    bmi       inpi2
                    cmpa      #$08
                    bmi       inpyc
                    cmpa      #$0c
                    bpl       inpyc
inpi2               tfr       b,a                 chk source regs
                    anda      #$f0
                    cmpa      #$60
                    bmi       inpwz
                    cmpa      #$80
                    bmi       inpyc
                    cmpa      #$c0
                    bpl       inpyc
inpwz               lbra      next2               ok, exit
inpn1               cmpa      #$02                chk dir
                    bne       inpn2
                    tst       os9flx,u            chk for OS/9
                    beq       inp1x
                    tst       pmode,u             chk for 6809
                    bpl       inp1x
                    lda       xlabel,u            change to x
                    sta       zulabe,u
inp1x               lbra      dirct
inpn2               cmpa      #$03                chk ext
                    bne       inpn3
inpie               leax      -$01,x              point to addr
                    lda       pmode,u             chk cpu mode
                    cmpa      #$02
                    bne       inpif
                    ldd       ,x                  rev ext addr for 6502
                    exg       a,b
                    bra       inpih
inpif               bpl       inpig               chk for 6809
                    lda       os9flx,u            chk for OS/9
                    beq       inpig
                    lda       xlabel,u            change to x
                    sta       zulabe,u
inpig               ldd       ,x                  get ext addr
inpih               lbra      nextd
inpn3               cmpa      #$04                chk imm
                    bne       inpn4
                    lda       pmode,u             chk cpu mode
                    cmpa      #$05
                    beq       inpq4
                    lda       inam4,u             chk suffix
                    cmpa      #$64                for 'd'
                    blt       inpq4
                    bne       inpie
                    dec       flabl,u
                    bra       inpie
inpq4               tfr       b,a
                    clrb
                    dec       flabl,u
                    lbra      nextd
inpn4               cmpa      #$05                chk inx
                    beq       inpx1
                    lbra      inpn5
inpx1               lda       pmode,u             chk cpu mode
                    bmi       inpx5
                    cmpa      #$05                chk 6805
                    bne       inpxy
                    lbra      dirct               force direct
inpx5               tfr       b,a                 addr mode
                    anda      #$0f
                    sta       flamf,u
                    tfr       b,a                 indir addr
                    anda      #$10
                    sta       flind,u
                    tfr       b,a                 reg
                    anda      #$60
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       flreg,u             reg*2
                    cmpa      #$04                chk for u
                    bne       inpxu
                    tst       os9flx,u            chk for OS/9
                    beq       inpxu
                    ldb       flamf,u             chk addr mode
                    cmpb      #$0c
                    beq       inpxu
                    cmpb      #$0d
                    beq       inpxu
                    ldb       ulabel,u            set label prefix u
                    stb       zulabe,u
inpxu               ldb       ,x                  chk postfix first bit
                    bmi       inpx2
                    tst       os9flx,u            chk for OS/9
                    beq       inpxy
                    andb      #$f0
                    cmpb      #$40                chk for +n,u
                    bne       inpxy
                    ldb       flamf,u             get offset
                    clra
                    lbra      nextd               label it
inpx2               lda       flind,u
                    andb      #$0f                chk amf
                    cmpb      #$07
                    bne       inpx7
inpxg               lbra      yecch               bad amf
inpx7               cmpb      #$0a
                    beq       inpxg
                    cmpb      #$0e
                    beq       inpxg
                    cmpb      #$01
                    beq       inpxy
                    cmpb      #$03
                    bne       inpx3
                    tsta                          chk indir
                    bne       inpxg
inpxy               lbra      next2               ok, exit
inpx3               cmpb      #$0f
                    bne       inpxf
                    tsta                          chk indir
                    beq       inpxg
                    tst       flreg,u             chk register
                    bne       inpxg
inpxf               cmpb      #$08                chk for more bytes
                    bmi       inpxy
                    beq       inpx8
                    cmpb      #$0b
                    beq       inpxy
                    cmpb      #$0c
                    beq       inpx8
                    pshs      b
                    lbsr      getin               need two
                    puls      b
inpx8               pshs      b
                    lbsr      getin               need one or two
                    puls      b
                    cmpb      #$0f
                    lbeq      inpie               ext addr
inpxe               cmpb      #$0c
                    bne       inpxc
                    tfr       a,b                 pc+-8bits
                    lbra      reltv
inpxc               cmpb      #$0d
                    bne       inpxd
                    tfr       a,b                 pc+-16bits
                    lda       ,-x
                    lbra      relad
inpxd               cmpb      #$09
                    bne       inpx9
                    tfr       a,b                 r+-16bits
                    lda       ,-x
                    tst       os9flx,u            chk for OS/9
                    beq       inpxz
                    tst       pmode,u             chk for 6809
                    bpl       inpxz
                    pshs      a
                    lda       flreg,u             chk for u-reg
                    cmpa      #$04
                    puls      a
                    lbeq      nextd               label it
inpxz               dec       flabl,u             don't label it
                    lbra      nextd
inpx9               cmpb      #$08
                    bne       inpxh
                    tfr       a,b                 r+-8bits
                    tst       os9flx,u            chk for OS/9
                    beq       inpxz
                    tst       pmode,u             chk for 6809
                    bpl       inpxz
                    tstb                          chk for positive
                    bmi       inpxz
                    pshs      a
                    lda       flreg,u             chk for u-reg
                    cmpa      #$04
                    puls      a
                    bne       inpxz
                    clra
                    lbra      nextd               label it
inpxh               bra       yecch               bad
inpn5               cmpa      #$06                chk rel
                    beq       relat
                    ldb       pmode,u             chk cpu mode
                    cmpb      #$02
                    bmi       yecch
                    bne       inpn7
                    lda       inst1,u             check for lbra (ind)
                    cmpa      #$6c
                    bne       inpyd               6502 ixi,ini
                    lbra      inpie
inpn7               cmpb      #$05
                    bne       yecch
                    cmpa      #$07                chk ix0
                    beq       next2
                    cmpa      #$08                chk ix2
                    bne       inpn8
                    lbra      inpie
inpn8               cmpa      #$09                chk btb
                    bne       inpn9
                    ldb       inst3,u             comp rel addr
                    sex
inpyr               addd      saddr,u
                    std       zaddr,u             save it
                    lda       comand,u            chk for view only
                    cmpa      #$56                v
                    beq       inpyd
                    tst       phase,u             chk phase
                    bne       inpyd
                    ldd       zaddr,u
                    lbsr      adal0               add label
inpyd               ldb       inst2,u             restore dir addr
                    bra       dirct
inpn9               cmpa      #$0a                chk bsc
                    beq       inpyd
**
yecch               com       instx,u             invalid opcode
yeccc               clr       fllth,u             back pointers up
                    ldx       caddr,u
                    stx       daddr,u
                    leax      $01,x
                    stx       saddr,u
                    bra       next2               make inv optr into fcb
**
dirct               clra                          dir
                    bra       nextd
relat               lda       inam0,u             chk long branch
                    cmpa      #$6c                l
                    bne       reltv
                    ldx       iaddr,u             long branch
                    lda       ,-x
                    bra       relad
reltv               sex                           compute rel addr
relad               addd      saddr,u
nextd               std       raddr,u
nextl               inc       flabl,u             labelled
**
next2               clr       flisw,u             reset instruction save switch
                    lbra      getin               get next instruction
**
insnm               ldd       aoptab,u            get instruction name
                    addb      worka,u
                    adca      #$00
                    tfr       d,x
                    lda       ,x
                    lsra
                    lsra
                    lsra
                    ora       #$60
                    sta       inam1,u
                    ldd       ,x
                    rolb
                    rolb
                    rolb
                    andb      #$03
                    asla
                    asla
                    anda      #$1f
                    ora       #$60
                    pshs      b
                    adda      ,s+
                    sta       inam2,u
                    clrb
                    lda       $01,x
                    lsra
                    rorb
                    stb       flspc,u             special flag
                    anda      #$1f
                    beq       insns
                    ora       #$60
                    sta       inam3,u
insns               ldb       flsuf,u             get suffix
                    aslb
                    clra
                    addd      asuftb,u
                    tfr       d,x
                    ldd       ,x
                    std       inam4,u
                    ldb       pmode,u             chk cpu mode
                    bpl       inpwk
                    cmpa      #$6c                chk 6809 l.branch
                    bne       inpkw
                    clr       inam4,u
                    sta       inam0,u             put l first
                    bra       inpkw
inpwk               cmpb      #$02                chk 6502
                    bne       inpkl
                    sta       inam5,u             fix 6502 suffix
                    suba      #$78                x
                    asla
                    sta       flreg,u
                    lda       #$04
                    sta       inam4,u
                    bra       inpkw
inpkl               cmpb      #$05                chk 6805
                    bne       inpkw
                    lda       inst1,u             fix 6805 instructions
                    cmpa      #$1f
                    bhi       inpkw
                    ldb       #$62                b
                    stb       inam0,u
                    cmpa      #$0f
                    bhi       inpkw
                    ldx       inam2,u
                    stx       inam3,u
                    lda       inam1,u
                    sta       inam2,u
                    lda       #$72                r
                    sta       inam1,u
inpkw               lda       #$04
                    sta       inamx,u
                    rts
**
inswi3              ldb       #(4+(2*2))          handle os9 call
                    mul                           get index into table
                    leax      svctab,pcr
                    leax      d,x
                    clr       flmod,u             remember count
                    stx       flinx,u             remember pointer to name
inswr3              ldd       #$6f73              change swi2 to os9
                    std       inam1,u
                    ldd       #$3904
                    std       inam3,u
                    tst       phase,u             chk phase
                    bne       inswx3
                    ldb       #$0f                fix svc flag
                    stb       svcflg,u
inswx3              lbra      next2               get next instruction
**
reset               ldx       faddr,u             reset addrs
                    tst       os9flx,u            chk for OS/9
                    beq       resos
                    leax      M$Mem+2,x           was m$stak+2,x skip module header
resos               stx       saddr,u
                    stx       daddr,u
                    clr       dorgs,u
                    clr       flisw,u
                    lbsr      xcrlf
                    lda       comand,u            chk view
                    cmpa      #$56                v
                    beq       resex
                    leax      phace,pcr           print phase
                    lbsr      xpdat
                    lda       phase,u
                    adda      #$31
                    lbsr      xoute
resex               leax      toblok,u            force text out
                    lbsr      fob
                    bra       getin
