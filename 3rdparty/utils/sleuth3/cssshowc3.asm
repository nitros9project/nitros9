***************************************
**
showaa              ldx       faddr,u             show object program
                    stx       saddr,u
                    leax      $01,x
                    bne       showab
                    rts
showab              lbsr      stopin              clear aux input
                    clr       saddr+1,u
                    lda       #$04
                    sta       inst1+scrnwd,u
                    sta       flisw,u
showac              lbsr      csctty              set tty parameters
showad              lbsr      wlftty              change function code
                    lbsr      xcrlf               print heading
                    leax      oarea-1,u           init pointers
                    stx       iaddr,u
                    leax      harea-1,u
                    stx       gaddr,u
                    leax      clrscn,pcr
                    lbsr      outcur              clear screen
                    ldb       #scrwid             format screen
                    cmpb      #$08
                    blt       showa2
                    leax      shotab,pcr
                    lbsr      xpdat
                    cmpb      #$08
                    beq       showa1
                    lbsr      xpdat
showa1              leax      shota1,pcr
                    lbsr      xpdat
                    cmpb      #$08
                    beq       showa2
                    lbsr      xpdat
showa2              leax      shota2,pcr
                    stx       eaddr,u
showae              ldx       eaddr,u             get next byte
                    lda       ,x
                    bne       showaf
                    lbsr      wtftty              change function code
                    lbra      showba              null=end
showaf              leax      $01,x
                    stx       eaddr,u
                    cmpa      #$2f
                    beq       showaj              /=line
                    cmpa      #$3c
                    bne       showag              <=start
                    leax      faddr,u
                    bra       showah
showag              cmpa      #$3e
                    bne       showai              >=end
                    leax      taddr,u
showah              lbsr      xot4h               xxxx
                    bra       showae
showai              lbsr      xoute
                    bra       showae
showaj              leax      shota2+1,pcr        print data line
                    cmpx      eaddr,u
                    bne       showja
                    ldb       #scrwid
                    cmpb      #$04
                    beq       showjj
showja              lbsr      xcrlf
showjj              leax      saddr,u
                    lbsr      xot4s
                    leax      inst1,u
                    stx       raddr,u
                    ldb       #scrwid             loop scrwid times
showak              pshs      b                   print hex
                    lbsr      getin
                    ldx       gaddr,u
                    leax      $01,x
                    sta       ,x
                    stx       gaddr,u
                    leax      instr,u
                    lbsr      xot2h
                    lda       insty,u
                    ora       #$40
                    suba      #$20
                    cmpa      #$32                chk for rmb
                    bne       showal
                    lda       #$22                change to "
showal              lbsr      xoute
                    lda       instr,u
                    anda      #$7f
                    ldx       raddr,u
                    cmpa      #$1f
                    bls       showam
                    cmpa      #maxprn
                    bls       showao
showam              lda       #$2e                .
showao              sta       ,x+
                    stx       raddr,u
                    puls      b
                    decb
                    bne       showak
                    lbsr      xouts
                    leax      inst1,u
                    lbsr      xpdat               print alpha
                    lbsr      xouts
                    lbra      showae
showba              lbsr      xinee               get command
                    cmpa      #$5f
                    bls       showby
                    anda      #$5f                fix case
showby              cmpa      #$51
                    bne       showbc              q=quit
showbz              clr       flisw,u             clear switch
                    lbra      inrtty              reset paras and exit
showbc              cmpa      #$50
                    bne       showbd              p=prev
                    ldd       saddr,u
                    subd      #(scrbyt*2)
                    bra       showbq
showbd              cmpa      #$53
                    bne       showbg              s=screen
                    ldd       saddr,u
                    subd      #scrbyt
                    std       saddr,u
                    leax      toblok,u            force output
                    lbsr      fob
                    lbsr      fulscr              full screen edit
                    lbra      showac
showbg              cmpa      #$2f
                    bhi       showbj              space=next
showbi              ldd       saddr,u             chk for end
                    cmpd      taddr,u
                    bhi       showbz
                    lbra      showad              back for more
showbj              cmpa      #$3a
                    blo       showbl              num
                    cmpa      #$41
                    blo       showbi              :-@
                    cmpa      #$47
                    blo       showbl              alpha
showbk              bra       showbi              rest
showbl              lbsr      xnhe9               addr
                    asla
                    asla
                    asla
                    asla
                    tfr       a,b
                    lbsr      xnhex
                    pshs      b
                    adda      ,s+
showbq              cmpa      faddr,u             chk addr
                    bcs       showbi
                    cmpa      taddr,u
                    bhi       showbi
                    sta       saddr,u             change addr
                    lbra      showad              back for more
**
* output cursor control string (1-3 chars)
outcur              pshs      b,x                 save b
                    ldb       #$03                set counter
outcr1              lda       ,x+                 get char
                    lbsr      xoutet              output char
                    decb                          dec the count
                    bne       outcr1              loop til done
                    leax      clrscn,pcr          chk clr screen
                    cmpx      $01,s
                    bne       outcr2
                    lda       ,x                  chk for adm-3
                    cmpa      #$1a
                    bne       outcr2
                    lda       #$80                delay
                    lbsr      xoutet
                    lbsr      xoutet
                    lbsr      xoutet
                    lbsr      xoutet
outcr2              leax      toblok,u            force output
                    lbsr      fob
                    puls      b,x,pc              restore and return
**
* find start of cursor control string
cmpcur              pshs      b                   save b-reg
                    leax      clrscn+leadin,pcr   point into table
cmp1                cmpa      ,x                  correct entry?
                    beq       cmp2                yes
                    leax      $03,x               no, bump to next entry
                    bra       cmp1                and try again
cmp2                ldb       #leadin
                    beq       cmp4
cmp3                leax      -$01,x              backup to 1st byte
                    decb
                    bne       cmp3
cmp4                puls      b,pc                restore and return
**
fulscr              lbsr      scstty              full screen edit
fulsc1              clr       horptr,u            reset parameters
                    clr       vrtptr,u
                    leax      harea,u             init screen
                    stx       adrptr,u
                    leax      homeup,pcr
                    bsr       outcur
                    leax      rtcur,pcr
                    bsr       outcur
                    bsr       outcur
                    bsr       outcur
                    bsr       outcur
                    bsr       outcur
                    ldb       #scrwid
                    cmpb      #$04
                    beq       fulsrc
                    leax      dncur,pcr
                    bsr       outcur
fulsrc              leax      curson,pcr          turn on cursor if off
                    lbsr      outcur
fulbel              lda       beeps,pcr           bell
fulout              lbsr      xoutet
fulgnx              clrb                          use b as flag register
fulg1               lbsr      inchrt              get a character
                    sta       cchar,u             save it
                    cmpa      #lead1              is it leadin char #1
                    bne       fulg2               no, see if it's 2nd or 3rd char in sequence
                    incb                          count as first char
                    bra       fulg1               and go get another
fulg2               tstb                          is this the 1st char?
                    beq       fulg4               yes, then it's not an escape sequence
                    cmpa      #lead2              no, then is it 2nd leadin char
                    bne       fulctl              no, then it must bea 2-char control sequence
                    incb                          count as 2nd char
                    bra       fulg1               and go geta 3rd char
fulg4               cmpa      #$80                is it an 8-bit control character?
                    bls       fulg5               no, check for 7-bit control char
                    bra       fulctl              go process
fulg5               cmpa      #$1f                is it a 7-bit control char
                    bls       fulctl              yes, go process
                    lbra      fulnct              no, then process as alpha
fulctl              cmpa      homeup+leadin,pcr   check home
                    beq       fulsc1
fulnhm              cmpa      clrscn+leadin,pcr   check clear
                    beq       fulsc1
fulncl              ldb       vrtptr,u
                    cmpa      upcur+leadin,pcr    check up-cursor
                    bne       fulnup
                    tstb
                    beq       fulbel
                    dec       vrtptr,u
                    ldd       adrptr,u
                    subd      #scrwid
                    std       adrptr,u
                    leax      upcur,pcr           point to cursor string
                    bra       fulecc
fulnup              cmpa      dncur+leadin,pcr    check down-cursor
                    bne       fulndn
                    cmpb      #$0e
                    bhi       fulbeb
                    inc       vrtptr,u
                    ldd       adrptr,u
                    addd      #scrwid
                    std       adrptr,u
                    leax      dncur,pcr           point to string
fulecc              lbsr      outcur
                    bra       fulgnx
fulbeb              bra       fulbel              bell
fulndn              ldb       horptr,u
                    cmpa      lfcur+leadin,pcr    check left-cursor
                    bne       fulnlf
fullf1              tstb
                    beq       fulbeb
                    decb
                    pshs      b
                    stb       horptr,u
                    cmpb      #scrhex
                    bne       fullf3
                    ldd       adrptr,u
                    addd      #scrwid
fullf2              std       adrptr,u
fullf3              puls      b
                    cmpb      #scrhex
                    bhi       fulinx
                    bitb      #$01
                    bne       fulecb
                    lbsr      cmpcur              get start of cursor string to x
                    bra       fulecc
fulecb              lda       cchar,u
                    lbsr      cmpcur              find table entry
                    lbsr      outcur
                    cmpb      #scrhex
                    bne       fulinx
                    lbsr      outcur
fulinx              ldx       adrptr,u
                    lda       cchar,u
                    cmpa      rtcur+leadin,pcr
                    bne       fuldex
                    leax      $01,x
                    bra       fulxix
fuldex              leax      -$01,x
fulxix              stx       adrptr,u
                    lbsr      cmpcur              get start of cursor string to x
fulech              bra       fulecc
fulnlf              cmpa      rtcur+leadin,pcr    check right-cursor
                    bne       fulnrt
fulrt1              cmpb      #scrale
                    bhi       fulbeb
                    pshs      b
                    incb
                    stb       horptr,u
                    cmpb      #scrals
                    bne       fullf3
                    ldd       adrptr,u
                    subd      #scrwid
                    bra       fullf2
fulnrt              cmpa      #$0d
                    beq       fulcre              chk cr
fulbec              lbra      fulbel              bell
fulcre              ldx       saddr,u             chk for changes
                    stx       eaddr,u
                    ldx       #scrbyt
                    stx       savew,u
                    leax      harea,u
                    stx       daddr,u
                    leax      oarea-1,u
                    stx       iaddr,u
fulnxc              ldx       daddr,u
                    lda       ,x+
                    stx       daddr,u
                    ldx       iaddr,u
                    leax      $01,x
                    stx       iaddr,u
                    cmpa      ,x
                    beq       fulnxn
                    ldx       typee,u
                    ldb       #$5a                z
                    stb       ,x+
                    ldy       eaddr,u
                    sty       ,x++                xxxx
                    sty       ,x++                xxxx
                    sta       ,x+                 cc
                    ldd       #$0000
                    std       ,x++
                    stx       typee,u
fulnxn              inc       eaddr+1,u           next byte
                    ldx       savew,u
                    leax      -$01,x
                    stx       savew,u
                    bne       fulnxc
                    leax      toblok,u            force output
                    lbra      fob                 and exit
fulbed              lbra      fulbel              bell
fulnct              ldx       adrptr,u            non-controls
                    anda      #$7f                remove parity
                    ldb       horptr,u
                    cmpb      #scrhex
                    bhi       fulalp
                    cmpa      #$5f
                    bls       fullow
                    anda      #$5f                change case
fullow              suba      #$30                chk hex
                    blo       fulbed
                    cmpa      #$09
                    bls       fulhex
                    cmpa      #$11
                    blo       fulbed
                    cmpa      #$16
                    bgt       fulbed
                    suba      #$07
fulhex              andb      #$01
                    beq       fulhev
                    ldb       ,x
                    andb      #$f0
                    bra       fulhez
fulhev              ldb       ,x
                    andb      #$0f
                    asla
                    asla
                    asla
                    asla
fulhez              pshs      b
                    adda      ,s+
fulalp              sta       ,x                  store char
                    lda       cchar,u
                    lbsr      xoutet              echo it
                    leax      lfcur,pcr           cursor left
                    lbsr      outcur
                    lda       rtcur+leadin,pcr    correct cursor
                    sta       cchar,u
                    ldb       horptr,u
                    lbra      fulrt1
**
inchrt              pshs      x                   input routine
                    leax      toblok,u            force output
                    lbsr      fob
                    leax      tiblok,u            get a char
                    lbsr      gnc
                    bcc       inchr1
                    lda       #$0d                cr if error
inchr1              equ       *
**** delete next line if terminal requires 8 bit ascii
                    anda      #$7f                masks parity
                    puls      x,pc                masks parity
