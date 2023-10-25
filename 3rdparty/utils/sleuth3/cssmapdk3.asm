
***************************************
**
mapdk               lbsr      maprt               map flex or OS/9 binary file
                    lbsr      xcrlf
mapnx               leax      inblok,u            look for leadin code
                    lbsr      gnc
                    lbcs      maper
                    lbvs      mapef
                    cmpa      #$02                chk $02
                    lbeq      mapmt
                    cmpa      #$16                chk $16
                    lbeq      mapmt
                    cmpa      #M$ID12/256         chk $87
                    bne       mapnx
map87               leax      inbuff,u            look at buffer
                    ldb       M$ID+1,x            chk second byte of header
                    cmpd      #M$ID12             chk $87cd
                    lbne      mapmt
                    ldy       M$Size,x            chk module length
                    lbeq      mapmt
                    cmpy      M$Name,x            chk name offset > length
                    lblo      mapmt
                    cmpy      M$Exec,x
                    lbls      mapmt               chk xfer > length
                    exg       d,y
                    addd      M$Mem,x
                    exg       d,y
                    lbcs      mapmt               chk prog + data > 64k
                    ldb       M$Type,x
                    andb      #LangMask           was lanmsk chk language
                    cmpb      #Objct
                    lbne      mapmt
                    ldb       ,x+                 chk header parity
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    eorb      ,x+
                    comb
                    lbne      mapmt
mapun               dec       os9flx,u            OS9 binary file
                    leay      objhdr,u            get OS9 header
                    ldb       #objlth
maphh               sta       ,y+
                    leax      inblok,u            get a char
                    lbsr      gnc
                    lbcs      maper
                    lbvs      mapef
                    decb
                    bne       maphh
                    ldx       obxfer,u            xfer address
                    stx       xaddr,u
                    ldx       typee,u             put module into table
                    lda       #$4d                m
                    sta       ,x
                    ldd       #$0000              module start addr
                    std       $01,x
                    std       faddr,u
                    std       oaddr,u             zero offset addr
                    ldd       obsize,u            module end addr
                    subd      #$0004
                    std       taddr,u
                    std       $03,x               end addr
                    ldd       curmod+1,u          curr module start
                    addd      #$0001
                    std       $06,x
                    lda       curmod,u
                    adca      #$00
                    sta       $05,x
                    pshs      x
                    leax      ltext,pcr           module
                    lbsr      xpdat
                    leax      lstar,pcr           start=
                    lbsr      xpdat
                    puls      x
                    leax      $01,x
                    lbsr      xot4h               xxxx
                    pshs      x
                    leax      lendr,pcr           end=
                    lbsr      xpdat
                    puls      x
                    lbsr      xot4h               xxxx
                    leax      $03,x
                    stx       typee,u
                    lbsr      xcrlf
                    leax      ldata,pcr           storage
                    lbsr      xpdat
                    leax      lstar,pcr           start=
                    lbsr      xpdat
                    ldx       #$0000
                    pshs      x
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    leax      lendr,pcr           end=
                    lbsr      xpdat
                    ldx       obstor,u
                    beq       mapst
                    leax      -$01,x
mapst               stx       ,s
                    tfr       s,x
                    lbsr      xot4h               xxxx
                    puls      x
                    lbsr      xcrlf
                    leax      toblok,u
                    lbsr      fob
                    ldy       obsize,u            length
                    leay      -(objlth+1),y
mapue               leax      inblok,u            scan extent contents
                    lbsr      gnc
                    lbcs      maper
                    lbvs      mapim               eof means short extent
                    leay      -$01,y
                    bne       mapue
                    ldd       inlrec+1,u          disk address of next module
                    std       nxtmod+1,u
                    lda       inlrec,u
                    sta       nxtmod,u
                    lbra      mapef
maprd               leax      inblok,u            look for $02 or $16 - flex
                    lbsr      gnc
                    lbcs      maper
                    lbvs      mapef
                    cmpa      #$02                chk $02
                    beq       mapmt
                    cmpa      #$16                chk $16
                    bne       maprd
mapmt               sta       worka,u             have $02 or $16
                    leax      inblok,u            get hi addr
                    lbsr      gnc
                    lbcs      maper
                    lbvs      mapef
                    sta       baddr,u             hold it
                    leax      inblok,u            get lo addr
                    lbsr      gnc
                    lbcs      maper
                    lbvs      mapef
                    tfr       a,b
                    lda       worka,u             chk for xfer addr
                    cmpa      #$02
                    beq       map02
map16               lda       baddr,u             xfer addr
                    std       xaddr,u
                    bra       maprd
map02               lda       baddr,u             offset addr
                    addd      oaddr,u
                    std       baddr,u
                    leax      inblok,u
                    lbsr      gnc                 get length
                    lbcs      maper
                    lbvs      mapef
                    sta       worka,u
                    leax      inblok,u            get a byte
                    lbsr      gnc
                    lbcs      maper
                    lbvs      mapef
                    ldx       typee,u             put into table
                    lda       #$4d                m
                    sta       ,x                  type
                    ldd       baddr,u             start=end addr in table
                    std       $01,x
                    std       $03,x
                    ldd       inlrec,u            curr locn
                    std       $05,x
                    std       caddr,u
                    lda       inlrec+2,u
                    sta       $07,x
                    ldd       baddr,u             update start addr
mapnb               cmpd      faddr,u
                    bhi       mapff
                    std       faddr,u
mapff               cmpd      taddr,u             update end addr
                    bls       mapgg
                    std       taddr,u
mapgg               dec       worka,u             count data bytes
                    beq       mapmm
                    leax      inblok,u            get a byte
                    lbsr      gnc
                    bcs       maper
                    lbvs      mapim               eof means short extent
                    ldd       baddr,u
                    addd      #$0001
                    std       baddr,u
                    ldx       typee,u             update end addr in table
                    std       $03,x
                    bra       mapnb
mapmm               leax      lxtnt,pcr           extent start=
                    lbsr      xpdat
                    ldx       typee,u
                    leax      $01,x
                    lbsr      xot4h               xxxx
                    pshs      x
                    leax      lendr,pcr           end=
                    lbsr      xpdat
                    puls      x
                    lbsr      xot4h               xxxx
                    leax      $03,x
                    stx       typee,u             complete table entry
                    lbsr      xcrlf
                    leax      toblok,u
                    lbsr      fob
                    ldx       typee,u             chk for table overflow
                    cmpx      alimit,u
                    lblo      maprd
                    lbsr      xcrlf
                    leax      tabov,pcr           table overflow
                    lbsr      xpdat
                    lbsr      xcrlf
                    bra       maprt
maper               lda       #$02                error
                    leax      errirz,pcr
                    ldy       #errirl
                    os9       I$WritLn
maprt               leax      endpr,u             reset table pointers
                    stx       types,u
                    stx       typee,u
                    stx       typem,u
                    ldb       #objos9             clear OS/9 header info
                    leax      objhdr,u
mapri               clr       ,x+
                    decb
                    bne       mapri
                    ldd       #$ffff
                    std       crcacc,u
                    sta       crcacc+2,u
                    std       maddr,u
                    std       xaddr,u
                    std       faddr,u
                    sta       crofl,u
                    addd      #$0001
                    std       taddr,u             reset end addr
                    sta       posfl,u             clear switches
                    sta       equfl,u
                    orcc      #$01                set error flag
mapex               rts
mapef               ldx       typee,u             eof - chk for valid map
                    cmpx      types,u
                    bne       mapok
mapim               leax      badfil,pcr          not a valid binary file
                    lbsr      xpdat
                    bra       maprt
mapok               leax      -$08,x              chk for rmb only
                    cmpx      types,u
                    bne       map0f
                    lda       ,x
                    cmpa      #$52                r
                    beq       mapim
map0f               ldx       faddr,u             check for $0000-$ffff
                    bne       mapko
                    ldx       taddr,u
                    leax      $01,x
                    bne       mapko
                    ldx       #$fff0              change upper bound
                    stx       taddr,u
mapko               lbsr      dmptae              valid map
                    andcc     #$fe                reset error flag
                    rts
