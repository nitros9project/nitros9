
***************************************
**
iafcc               stb       maxln,u             fcc,fcb,rmb
                    tst       phase,u             chk phase and
                    beq       iafcx               exit if 1
                    leax      inst1,u
                    stx       gaddr,u
iafc0               ldb       instx,u
                    cmpb      #$43                fcc
                    bne       iafc5
                    anda      #$7f                mask off parity bit
                    cmpa      #$1f                control chars
                    bls       iafc2
                    cmpa      #maxprn             max printable
                    bhi       iafc2
                    cmpa      #$22                "
                    bne       iafc8
iafc2               ldb       instx,u
                    leax      inst1,u
                    cmpx      gaddr,u
                    bne       iafc3
                    cmpb      #$43                c
                    bne       iafcx
                    ldb       #$48                fcc->fcb
                    stb       instx,u
iafcx               lbra      next2               get next and return
iafc3               ldx       gaddr,u
                    cmpb      #$43
                    bne       iafc4
                    ldd       #$2204              fcc/fcs "..."
                    std       ,x
iafc4               rts                           return for fcc
iafc5               cmpb      #$52                r
                    bne       iafc8
                    ldd       saddr,u
                    pshs      d
iafc6               lbsr      getin               get next byte
                    ldb       insty,u
                    cmpb      #$52                r
                    bne       iafc7
                    ldy       daddr,u             chk labeled
                    lbsr      adalx
                    bcs       iafc7
                    lbsr      ckend               chk end of program
                    bls       iafc6
iafc7               ldd       saddr,u             end of rmb range
                    subd      ,s++
                    std       rmblth,u            set rmb length
                    rts
iafc8               leax      inst1,u
                    cmpx      gaddr,u
                    beq       iafc9
                    ldy       daddr,u
                    lbsr      adalx               chk label
                    bcs       iafc2
iafc9               ldx       gaddr,u
                    sta       ,x+
                    stx       gaddr,u
                    cmpa      instr,u             check for fcs
                    beq       iafca
                    lda       fccxx+3,u           c->s
                    ora       #$10
                    sta       fccxx+3,u           fcs
                    lbsr      getin
                    lbra      iafc2
iafca               lbsr      getin
                    ldb       fllth,u
                    cmpb      maxln,u
                    lbeq      iafc2
                    ldb       instx,u
                    cmpb      insty,u
                    lbne      iafc2
                    lbra      iafc0
**
adald               ldd       raddr,u             add a data label
adale               pshs      a                   flag as data
                    lda       zulabe,u            prefix u/z
                    sta       lauorz,u
                    puls      a
                    bra       adalv
adalw               ldd       raddr,u             add a data label
adalu               pshs      a                   flag as data
                    lda       ulabel,u            prefix u
                    sta       lauorz,u
                    puls      a
                    bra       adalv
adalb               ldd       raddr,u             add a prog label
adal0               pshs      a                   flag as label
                    lda       zlabel,u            prefix z
                    sta       lauorz,u
                    puls      a
adalv               pshs      d,y
                    tfr       d,y
                    bsr       adall               chk labels
                    bcs       adatx               branch if there
                    lda       lauorz,u
                    ldx       addre,u
                    cmpx      alimit,u            chk for overflow
                    lbhs      tablab
                    sty       ,x++                add to list
                    sta       ,x+
                    stx       addre,u
                    leax      -$03,x              bubble sort
adal1               cmpx      typee,u             back up
                    bls       adatx
                    leax      -$03,x
adal2               ldy       ,x                  compare
                    lda       $02,x
                    cmpy      $03,x
                    bls       adatx
                    pshs      a,y
                    ldy       $03,x               swap
                    lda       $05,x
                    sty       ,x
                    sta       $02,x
                    puls      a,y
                    sty       $03,x
                    sta       $05,x
                    bra       adal1
adatx               puls      d,y,pc
**
adalx               pshs      a                   chk prog labels
                    lda       zlabel,u            prefix z
                    sta       lauorz,u
                    puls      a
                    bra       adall
adaly               pshs      a                   chk data labels
                    lda       ulabel,u            prefix u
                    sta       lauorz,u
                    puls      a
adall               ldx       typee,u             chk labels
                    pshs      d
                    lda       lauorz,u
adalp               cmpx      addre,u
                    bhs       adanf
                    leax      $03,x
                    cmpy      -$03,x
                    bne       adaix
                    cmpa      -$01,x
                    bne       adalp
adafo               orcc      #$01                successful, c=1
                    leax      -$03,x              back up
                    puls      d,pc
adaix               bhi       adalp
adanf               andcc     #$fe                unsuccessful, c=0
                    puls      d,pc
**
ckequ               lda       instx,u             chk org's
                    cmpa      #$4b
                    beq       cktno
                    tst       dorgs,u
                    beq       cktno
                    clr       dorgs,u
ckeqw               tst       os9flx,u            chk for OS/9
                    bne       cktno
                    leax      caddr,u             xxxx
                    lbsr      xot4h
                    leax      orges,pcr           org $
                    lbsr      xpdat
                    leax      caddr,u             xxxx
                    lbsr      xot4h
                    lbsr      xcrlf
cktno               ldx       daddr,u             chk equ's
                    clr       baddr,u
                    dec       fllth,u
                    lda       fllth,u
                    ldb       instx,u
                    cmpb      #$43                c
                    beq       ckeqa
                    cmpb      #$48                h
                    beq       ckeqa
                    cmpb      #$52                r
                    bne       ckeso
ckeqa               ldx       caddr,u
                    clra
ckesx               stx       gaddr,u
                    sta       worka,u
                    ldy       gaddr,u
                    lbsr      adalx
                    bcc       ckenf
                    tst       worka,u             chk offset
                    beq       ckexo
                    leax      gaddr,u             xxxx
                    lbsr      xot4h
                    lda       #$02
                    lbsr      xoute
                    lda       zlabel,u            z
                    lbsr      xoute
                    leax      gaddr,u             xxxx
                    lbsr      xot4h
                    leax      bequb,pcr           equ
                    lbsr      xpdat
                    lbsr      xpdat               *+
                    lda       worka,u             x
                    adda      #$30
                    lbsr      xoute
                    lbsr      xcrlf
ckenf               lda       worka,u
                    beq       ckext
                    ldx       gaddr,u
                    deca
ckeso               leax      -$01,x
                    bra       ckesx
ckexo               ldb       instx,u             chk ign
                    cmpb      #$4b
                    bne       ckexe
                    leax      gaddr,u
                    lda       zlabel,u            prefix z
                    lbra      gnpea               xxxx zxxxx equ $xxxx
ckexe               tst       equfl,u             check equ flag
                    beq       ckexs
                    leax      caddr,u             xxxx
                    lbsr      xot4h
                    lda       #$02
                    lbsr      xoute
                    lda       zlabel,u            z
                    lbsr      xoute
                    leax      caddr,u             xxxx
                    lbsr      xot4h
                    leax      bequb,pcr           equ
                    lbsr      xpdat
                    lda       #$2a                *
                    lbsr      xoute
                    lbsr      xcrlf
                    bra       ckext
ckexs               inc       baddr,u
ckext               lda       instx,u             chk ign
                    cmpa      #$4b                k
                    beq       ckexz
                    leax      caddr,u             xxxx
                    lbsr      xot4h
                    lda       instx,u             chk rmb
                    cmpa      #$52                r
                    beq       ckexy
                    lda       #$01                hex object
                    lbsr      xoute
                    lda       fllth,u
                    inca
                    beq       ckexy
                    cmpa      #$06
                    blo       ckexu
                    lda       #$05
ckexu               sta       worka,u
                    leax      inst1,u
ckexv               lbsr      xot2h
                    dec       worka,u
                    bne       ckexv
ckexy               lda       #$02                label tab
                    lbsr      xoute
                    tst       baddr,u
                    beq       ckexz
                    lda       zlabel,u            z
                    lbsr      xoute
                    leax      caddr,u             xxxx
                    lbsr      xot4h
ckexz               rts
**
headr               lbsr      xcrlf               start program file
                    ldx       crtfl,u
                    stx       confl,u
                    lda       disof,u
                    sta       dskfl,u
                    lda       names+5,u           chk nam
                    cmpa      #$04
                    beq       headc
                    leax      names,u             nam
                    lbsr      xpdat
                    lbsr      xcrlf
headc               lda       optes+5,u           chk opt
                    cmpa      #$04
                    beq       headg
                    leax      optes,u             opt
                    lbsr      xpdat
                    lbsr      xcrlf
headg               clr       column,u
                    tst       os9flx,u            chk for OS/9
                    lbeq      headt
                    lda       comand,u            chk view
                    cmpa      #$56                v
                    lbeq      headt
                    leax      sysdef,pcr          system definitions
                    lbsr      xpdat
                    lda       obatre,u            version
                    lbsr      xothr
                    lbsr      xcrlf
                    ldd       obname,u            module name offset
                    lbsr      adal0
                    leax      lmodul,pcr          mod endmod,namemd,
                    lbsr      xpdat
                    lda       obtyla,u            type and language
                    anda      #$f0
                    lsra
                    leax      ltypes,pcr          type
                    leax      a,x
                    lbsr      xpdat
                    leax      llangs,pcr          +objct,
                    lbsr      xpdat
                    lda       obatre,u            attributes and version
                    bpl       headq
                    leax      lreent,pcr          reent+
                    lbsr      xpdat
headq               leax      lversi,pcr          version,xferad,endmem
                    lbsr      xpdat
                    lbsr      xcrlf
                    ldd       #$0000              xxxx
                    pshs      d
                    tfr       s,x
                    lbsr      xot4h
                    leax      orges,pcr           org $0000 for storage
                    lbsr      xpdat
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    puls      d
                    lbsr      xcrlf
                    lbsr      gendat              generate data rmb's and equ's
headh               leax      lemmod,pcr          module header
                    lbsr      xpdat               endmem
                    lbsr      xpdat               equ .
                    lbsr      xcrlf
                    lda       names+5,u           chk nam
                    cmpa      #$04
                    beq       headn
                    leax      names,u             nam
                    lbsr      xpdat
                    lbsr      xcrlf
headn               ldx       #$ffff              gen absolute equ's
                    stx       caddr,u
                    ldx       #$0000
                    stx       raddr,u
                    lda       xlabel,u            prefiz x
                    sta       zulabe,u
                    lbsr      gnequ
                    ldx       #$000c              gen equ's in header
                    stx       caddr,u
                    ldx       #$0000
                    stx       raddr,u
                    lda       zlabel,u            prefiz z
                    sta       zulabe,u
                    lbsr      gnequ
                    lda       ulabel,u            prefiz u
                    sta       zulabe,u
headt               ldd       curmod,u            reset curr locn
                    std       inlrec,u            zap curr locn
                    lda       curmod+2,u
                    sta       inlrec+2,u
                    ldx       faddr,u             gen out-of-range equ's
                    beq       headx
                    leax      -$01,x
                    stx       caddr,u
                    ldx       #$0000
                    stx       raddr,u
                    lda       zlabel,u            prefiz z
                    sta       zulabe,u
                    lbsr      gnequ
headx               inc       dorgs,u
                    rts
**
gendat              equ       *                   generate data rmb's and equ's
                    lda       ulabel,u            prefix u
                    sta       zulabe,u
                    ldx       obstor,u
                    lbeq      gendeq
                    leax      -$01,x
                    stx       caddr,u
                    ldx       #$0000
                    stx       raddr,u
                    stx       zaddr,u
                    ldx       typee,u             gen data rmb's
genrm1              stx       gaddr,u
                    cmpx      addre,u
                    beq       genrm5
                    bhi       gendeq
                    ldy       $00,x
                    cmpy      raddr,u
                    beq       genrm6
genrm2              blo       genrm4
                    cmpy      caddr,u
genrm3              bls       genrm6
genrm4              leax      $03,x
                    bra       genrm1
genrm5              ldy       obstor,u            force last rmb
                    bra       genrm7
genrm6              lda       zulabe,u            prefix u/z
                    cmpa      $02,x
                    bne       genrm8
genrm7              stx       gaddr,u
                    tfr       y,d
                    subd      zaddr,u             compute rmb offset
                    bls       genrm8              chk for non-positive
                    pshs      d
                    leax      zaddr,u             xxxx
                    lbsr      xot4h
                    lda       #$02
                    lbsr      xoute
                    lda       zulabe,u            prefix u
                    lbsr      xoute
                    leax      zaddr,u             xxxx
                    lbsr      xot4h
                    leax      rmbes,pcr           rmb $
                    lbsr      xpdat
                    tfr       s,x
                    lbsr      xot4h
                    lbsr      xcrlf
                    puls      d
                    sty       zaddr,u             remember current address
genrm8              ldx       gaddr,u             get next label
                    bra       genrm4
gendeq              ldx       obstor,u            gen out-of-range data equ's
                    stx       raddr,u
                    ldx       #$ffff
                    stx       caddr,u
                    lbsr      gnequ
                    rts
**
ender               ldx       daddr,u             end text file
                    beq       ende0               gen out-of-range equ's
                    stx       raddr,u
                    ldx       #$ffff
                    stx       caddr,u
                    lda       zlabel,u            prefix z
                    sta       zulabe,u
                    lbsr      gnequ
ende0               lda       comand,u            chk view
                    cmpa      #$56                v
                    beq       ende3
                    tst       os9flx,u            chk for OS/9
                    beq       ende1
                    leax      endos9,pcr          emod
                    lbsr      xpdat               endmod equ *
                    leax      lnamem,pcr          namemd equ
                    lbsr      xpdat
                    lda       zlabel,u            z
                    lbsr      xoute               z/$
                    leax      obname,u
                    lbsr      xot4h               xxxx
                    lbsr      xcrlf
                    leax      lxfera,pcr          xferad equ
                    lbsr      xpdat
                    lda       zlabel,u            z
                    lbsr      xoute               z/$
                    leax      obxfer,u            xfer offset
                    lbsr      xot4h               xxxx
                    lbsr      xcrlf
ende1               leax      endes,pcr           end
                    lbsr      xpdat
                    tst       os9flx,u            chk for OS/9
                    bne       ende2
                    ldx       xaddr,u             chk xfer addr
                    leax      $01,x
                    beq       ende2
                    lda       zlabel,u            z
                    lbsr      xoute
                    leax      xaddr,u             xxxx
                    lbsr      xot4h
ende2               lbsr      xcrlf
**
ende3               lda       #$01                reset flags and close files
                    sta       confl,u
                    clr       phase,u
                    tst       prtfl,u             chk for printer output
                    beq       endep
                    clr       prtfl,u             close printer file
                    clr       prfile,u
                    leax      prblok,u            force last block
                    lbsr      fob
                    bcc       endpe
                    lda       #$02                error
                    leax      errprz,pcr
                    ldy       #errprl
                    os9       I$WritLn
endpe               lda       prblok+iobfd+1,u    close it
                    clr       prblok+iobfd,u
                    clr       prblok+iobfd+1,u
                    os9       I$Close
                    bcc       endep
                    lda       #$02
                    leax      errprz,pcr
                    ldy       #errprl
                    os9       I$WritLn
endep               tst       dskfl,u             chk for disk output
                    beq       endex
                    clr       disof,u             close output file
                    clr       dskfl,u
                    clr       otfile,u
                    leax      otblok,u            force last block
                    lbsr      fob
                    bcc       endxe
                    lda       #$02                error
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
endxe               lda       otblok+iobfd+1,u    close it
                    clr       otblok+iobfd,u
                    clr       otblok+iobfd+1,u
                    os9       I$Close
                    bcc       endex
                    lda       #$02
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
endex               lbra      xcrlf
**
gnequ               ldx       typee,u             out-of-range equ's
gneq1               stx       gaddr,u
                    cmpx      addre,u
                    beq       gneqx
                    ldd       $00,x
                    cmpd      raddr,u
                    beq       gneq6
gneq2               blo       gneq4
                    cmpd      caddr,u
gneq3               bls       gneq6
gneq4               leax      $03,x
                    bra       gneq1
gneq6               stx       gaddr,u
                    lda       zulabe,u            prefix u/z
                    cmpa      $02,x
                    bne       gneq7
                    bsr       gnpea
gneq7               ldx       gaddr,u
                    bra       gneq4
gneqx               rts
**
gnpea               pshs      a                   gen xxxx zxxxx equ $xxxx
                    stx       baddr,u             xxxx
                    lbsr      xot4h
                    lda       #$02
                    lbsr      xoute
                    puls      a                   label prefix
                    lbsr      xoute
                    ldx       baddr,u             xxxx
                    lbsr      xot4h
                    leax      bequb,pcr           equ
                    lbsr      xpdat
                    lda       #$24                $
                    lbsr      xoute
                    ldx       baddr,u             xxxx
                    lbsr      xot4h
                    lbra      xcrlf
**
