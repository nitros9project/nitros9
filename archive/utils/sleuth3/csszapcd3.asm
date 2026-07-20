
***************************************
**
fillup              lda       #$5a                fill program code
                    ldy       typee,u             save table pointer
                    pshs      y
                    lbsr      gtype               get range
                    puls      y
                    sty       typee,u
                    pshs      x
                    leax      lvalue,pcr          value=
                    lbsr      xpdat
                    lbsr      xbyte
                    sta       [eaddr,u]           store it
                    lbsr      xinee
                    puls      x                   restore pointer
                    stx       typee,u
                    lbhs      tabovf
                    rts
**
writem              ldx       faddr,u             write new program code file
                    leax      $01,x
                    bne       writxf
                    lbsr      newrng              get range
writxf              ldx       xaddr,u             chk xfer addr
                    leax      $01,x
                    bne       writfx
                    lbsr      sxfer               get xfer addr
writfx              lbsr      dikni               get output file name
                    tst       disof,u
                    bne       writgf
                    rts                           return if no file name
writgf              clr       flabl,u             reset flag
                    lbsr      xcrlf
writop              leax      otfile,u            open output otfile
                    ldd       #(WRITE.*256)+(READ.+WRITE.+EXEC.+PEXEC.) access and attributes
                    os9       I$Create
                    lbcs      writer              error
                    clrb
                    exg       a,b
                    std       otblok+iobfd,u      file desc
                    ldd       #buflen             buffer length
                    std       otblok+iobbl,u
                    std       otblok+iobcc,u
                    ldd       otblok+iobba,u      buffer addr
                    std       otblok+iobca,u
                    ldx       faddr,u             set addrs
                    stx       saddr,u
                    tst       disif,u             chk for input file
                    bne       writft
                    ldd       obsize,u            chk for OS/9
                    bne       wrios9              OS/9
writft              tst       os9flx,u            chk for OS/9 format
                    lbeq      writst              flex
wrios9              ldb       #objlth             save header
                    leay      locstk,u
                    leax      objhdr,u
wriuhd              lda       ,x+
                    sta       ,y+
                    decb
                    bne       wriuhd
                    ldd       #$ffff              init crc accum
                    std       crcacc,u
                    sta       crcacc+2,u
                    clrb
                    leay      objhdr,u
wriusa              lda       b,y                 output header
                    leax      otblok,u
                    lbsr      crcalc              crc
                    lbsr      pnc
                    lbcs      writur
                    incb
                    cmpb      #objlth
                    blo       wriusa
                    leax      ltext,pcr           module
                    lbsr      xpdat
                    leax      lstar,pcr           start=
                    lbsr      xpdat
                    ldd       #$0000
                    pshs      d
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    leax      lendr,pcr           end=
                    lbsr      xpdat
                    ldd       obsize,u
                    subd      #$0004
                    std       savew,u
                    leax      savew,u
                    lbsr      xot4h               xxxx
                    lbsr      xcrlf
                    leax      toblok,u
                    lbsr      fob
                    ldd       obstor,u            chk storage length
                    beq       wriusc
                    leax      ldata,pcr           storage
                    lbsr      xpdat
                    leax      lstar,pcr           start=
                    lbsr      xpdat
                    ldd       #$0000
                    std       ,s
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    leax      lendr,pcr           end=
                    lbsr      xpdat
                    ldd       obstor,u
                    subd      #$0001
                    std       ,s
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    lbsr      xcrlf
                    leax      toblok,u
                    lbsr      fob
wriusc              puls      d
                    ldx       #objlth             first program address
                    stx       saddr,u
wriusr              lbsr      getin               get a byte
                    leax      otblok,u
                    lbsr      crcalc              crc
                    lbsr      pnc                 put contiguous bytes
                    lbcs      writur
                    ldx       daddr,u
                    cmpx      savew,u
                    bne       wriusr
                    leax      otblok,u
                    lda       crcacc,u            output crc
                    coma
                    lbsr      pnc
                    lbcs      writur
                    lda       crcacc+1,u          output crc
                    coma
                    lbsr      pnc
                    lbcs      writur
                    lda       crcacc+2,u          output crc
                    coma
                    lbsr      pnc
                    lbcs      writur
                    leax      lxfer+1,pcr         xfer=
                    lbsr      xpdat
                    leax      obxfer,u
                    lbsr      xot4h               xxxx
                    lbsr      xcrlf
                    leax      toblok,u
                    lbsr      fob
                    lbsr      writrh              restore header
                    lbra      writcl
writst              ldx       typee,u             set up flex segment
                    lda       #$02
                    sta       ,x
                    ldd       saddr,u
                    std       $01,x
                    std       savew,u
                    stx       caddr,u
                    clr       worka,u
writgc              ldd       saddr,u             chk addrs
                    cmpd      taddr,u
writca              bhi       writeb              skip if end
                    lbsr      getin               get next byte
                    ldb       insty,u             get type
                    cmpb      #$4b                chk ign
                    beq       writeb
                    cmpb      #$52                chk rmb
                    beq       writeb
                    ldx       caddr,u             store it
                    sta       $04,x
                    leax      $01,x
                    stx       caddr,u
                    lda       worka,u
                    inca
                    sta       worka,u
                    cmpa      #$f8                check number of bytes
                    bne       writgc
writeb              lda       worka,u             write segment
                    beq       writlt
                    leax      lxtnt,pcr           extent start=
                    lbsr      xpdat
                    leax      savew,u
                    lbsr      xot4h               xxxx
                    ldx       saddr,u
                    leax      -$01,x
                    stx       savew,u
                    leax      lendr,pcr           end=
                    lbsr      xpdat
                    leax      savew,u
                    lbsr      xot4h               xxxx
                    lbsr      xcrlf
                    leax      toblok,u
                    lbsr      fob
                    ldx       typee,u
                    lda       worka,u
                    sta       $03,x               set count
                    adda      #$04
                    sta       worka,u
                    stx       caddr,u
writby              ldx       caddr,u             output segment
                    lda       ,x+
                    stx       caddr,u
                    leax      otblok,u            put a bute
                    lbsr      pnc
                    lbcs      writer
                    dec       worka,u
                    bne       writby
                    lda       #$01                set flag
                    sta       flabl,u
writlt              ldd       saddr,u             chk addrs
                    cmpd      taddr,u
writla              bhi       writxa              skip if end
                    lbra      writst
writxa              ldx       xaddr,u             output xfer addr
                    leax      $01,x
                    beq       writcl              skip if $ffff
                    tst       flabl,u
                    beq       writcl              skip if no code
                    leax      lxfer+1,pcr         xfer=
                    lbsr      xpdat
                    leax      xaddr,u             xxxx
                    lbsr      xot4h
                    lbsr      xcrlf
                    ldx       typee,u
                    lda       #$16
                    sta       ,x
                    ldd       xaddr,u
                    std       $01,x
                    lda       #$03
                    sta       worka,u
                    stx       caddr,u
writta              ldx       caddr,u
                    lda       ,x+
                    stx       caddr,u
                    leax      otblok,u            put a byte
                    lbsr      pnc
                    bcs       writer
                    dec       worka,u
                    bne       writta
                    bra       writcl
writrh              ldb       #objlth             restore header
                    leax      locstk,u
                    leay      objhdr,u
writri              lda       ,x+
                    sta       ,y+
                    decb
                    bne       writri
                    rts
writur              bsr       writrh              restore header
writer              lda       #$02                report error
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
writcl              leax      otblok,u            force output
                    lbsr      fob
                    bcc       writcx
                    lda       #$02                report error
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
writcx              lda       otblok+iobfd+1,u    close file
                    os9       I$Close
                    bcc       writex
                    lda       #$02                report error
                    leax      errorz,pcr
                    ldy       #errorl
                    os9       I$WritLn
writex              clr       disof,u             reset flag
                    clr       otfile,u
                    rts
**
crcalc              pshs      cc,d,dp,x,y,u       calc OS/9 crc
                    leax      $01,s
                    ldy       #$0001
                    leau      crcacc,u
                    os9       F$CRC
                    rti
**
findst              leax      inam0,u             find hex string
                    lbsr      gadrs
                    lbhi      badrg               bad range
findar              leax      lvalue,pcr          value=
                    lbsr      xpdat
                    clr       worka,u             get pattern
                    leax      inst1,u             point to match area
findhx              lbsr      xinee               get char
                    cmpa      #$5f
                    bls       findxh
                    anda      #$5f                change case
findxh              cmpa      #$2f                check for hex
                    bls       findot
                    cmpa      #$39
                    bls       findin
                    cmpa      #$40
                    bls       findot
                    cmpa      #$46
                    bhi       findot
findin              lbsr      xnhe9
                    asla
                    asla
                    asla
                    asla
                    tfr       a,b
                    lbsr      xnhex
                    pshs      b
                    adda      ,s+
                    sta       ,x+                 save it
                    lda       worka,u
                    inca
                    sta       worka,u
                    cmpa      #$1f
                    bls       findhx
findot              tst       worka,u             got string
                    beq       findxt
findsr              ldx       inam0,u             set up search
                    stx       saddr,u
                    ldx       inam2,u             end addr
                    leax      $01,x
                    bne       findrs
                    leax      -$02,x              fix if $ffff
                    stx       inam2,u
findrs              lbsr      xcrlf
                    lda       #$0b                10 addrs per line
                    sta       flabl,u
                    ldx       typee,u             establish circular buffer
                    stx       baddr,u
                    inc       baddr,u
                    ldx       baddr,u
                    stx       caddr,u
findiz              clr       baddr+1,u           reset addrs
                    clr       caddr+1,u
                    lda       worka,u             load buffer
                    sta       inam5,u
findrd              ldd       saddr,u             chk end addr
                    cmpd      inam2,u
findre              bls       findra
findxt              bra       findex              found end
findra              lbsr      getin               get instr
                    ldb       insty,u             get type
                    cmpb      #$4b                chk ign
                    beq       findiz
                    cmpb      #$52                chk rmb
                    beq       findiz
                    sta       [caddr,u]           save instr
                    inc       caddr+1,u
                    dec       inam5,u
                    bgt       findrd
findoc              ldb       worka,u             set up compare
                    ldx       baddr,u
                    stx       raddr,u
                    leax      inst1,u
findcl              lda       [raddr,u]           compare data
                    cmpa      ,x+
                    bne       findne              skip if no match
                    inc       raddr+1,u
                    decb
                    bne       findcl
findma              dec       flabl,u             print address
                    bne       findnl
                    lbsr      xcrlf               new line
                    lda       #$0a                10 addrs per line
                    sta       flabl,u
findnl              ldb       worka,u             back up addr
                    negb
                    sex
                    ldx       saddr,u
                    leax      d,x
                    stx       inam4,u
                    leax      inam4,u             output addr
                    lbsr      xot4s
                    leax      toblok,u            force output
                    lbsr      fob
findne              inc       baddr+1,u           get next instr
                    clr       inam5,u
                    bra       findrd
findex              rts
**
examin              leax      lstar,pcr           examine/change program code
                    lbsr      xpdat               start=
                    lbsr      xbadr               xxxx
                    stx       saddr,u
examcr              lbsr      xcrlf
                    leax      saddr,u
                    lbsr      xot4s               print addr
                    lbsr      getin               get instr
                    leax      instr,u
                    lbsr      xot2s               print byte
examhx              lbsr      xinee               get char
                    cmpa      #$5f
                    bls       examxh
                    anda      #$5f                change case
examxh              cmpa      #$20                chk space
                    beq       examhx
                    cmpa      #$0d                chk cr
                    bne       examnc
                    rts                           return
examnc              cmpa      #$5e                up arrow
                    bne       examna
                    ldx       saddr,u             back up
                    leax      -$02,x
                    stx       saddr,u
examot              bra       examcr              go back for more
examna              cmpa      #$2f                check for hex
                    bls       examot
                    cmpa      #$39
                    bls       examto
                    cmpa      #$40
                    bls       examot
                    cmpa      #$46
                    bhi       examot
examto              lbsr      xnhe9
                    asla
                    asla
                    asla
                    asla
                    tfr       a,b
                    lbsr      xnhex
                    pshs      b
                    adda      ,s+
                    ldx       typee,u             store in table
                    cmpx      alimit,u            chk for overflow
                    lbhs      tabovf
                    ldb       #$5a                z
                    stb       ,x+
                    ldy       daddr,u             xxxx
                    sty       ,x++
                    sty       ,x++
                    sta       ,x+                 xx
                    ldd       #$0000
                    std       ,x++
                    stx       typee,u
                    bra       examcr              go back for more
