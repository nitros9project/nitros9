
***************************************
**
dmptab              lbsr      xcrlf               dump tables
                    ldx       typem,u
dmptac              cmpx      typee,u
                    bhs       dmptae
dmptad              stx       caddr,u             print a line
                    lbsr      xcrlf
                    ldx       caddr,u
                    lda       ,x
                    cmpa      #$5a                chk 'Z
                    beq       dmpta2
                    ora       #$20
                    lbsr      xoute               type
                    lbsr      xouts               space
                    leax      $01,x
                    lbsr      xot4s               start
                    lbsr      xot4s               end
                    leax      $01,x
dmpta1              leax      $02,x
                    bra       dmptac
dmpta2              ldd       $01,x               chk start/end
                    cmpd      $03,x
                    bne       dmpta4
                    lda       #$6d                make m
                    lbsr      xoute               type
                    lbsr      xouts               space
                    leax      $03,x
dmpta3              lbsr      xot4s               end
                    lbsr      xot2s               value
                    bra       dmpta1
dmpta4              lda       #$74                make 't
                    lbsr      xoute               type
                    lbsr      xouts               space
                    leax      $01,x
                    lbsr      xot4s               start
                    bra       dmpta3
dmptae              lbsr      xcrlf               print parms
                    ldx       faddr,u
                    leax      $01,x
                    beq       dmptag
                    leax      loss9,pcr           OS/9 or Flex
                    tst       os9flx,u
                    bne       dmpte1
                    leax      lflex,pcr
dmpte1              lbsr      xpdat
                    leax      lstar,pcr           x-->" start="
                    lbsr      xpdat
                    leax      faddr,u
                    lbsr      xot4h
                    leax      lendr,pcr           x-->" end="
                    lbsr      xpdat
                    leax      taddr,u
                    lbsr      xot4h
dmptaf              ldx       xaddr,u
                    leax      $01,x
                    beq       dmptag
                    leax      lxfer,pcr           x-->" xfer="
                    lbsr      xpdat
                    leax      xaddr,u
                    lbsr      xot4h
dmptag              lbsr      xcrlf
                    ldx       oaddr,u
                    beq       dmptah
                    tst       os9flx,u            chk for OS/9
                    bne       dmptah
                    leax      offil,pcr           offset
                    lbsr      xpdat
                    lbsr      xouts
                    leax      oaddr,u
                    lbsr      xot4h
                    lbsr      xcrlf
dmptah              leax      equil,pcr           equ flag
                    lbsr      xpdat
                    leax      lon,pcr
                    tst       equfl,u
                    bne       dmptai
                    leax      loff,pcr
dmptai              lbsr      xpdat
                    lbsr      xcrlf
                    leax      cpuil,pcr           cpu mode
                    lbsr      xpdat
                    lbsr      xouts
                    lda       #$36
                    lbsr      xoute
                    ldb       pmode,u
                    bpl       dmptaj
                    ldb       #$09
dmptaj              addb      #$30
                    lda       #$38
                    cmpb      #$32                chk 2
                    bne       dmptak
                    lda       #$35
dmptak              lbsr      xoute
                    lda       #$30
                    lbsr      xoute
                    tfr       b,a
                    lbsr      xoute
                    lbsr      xcrlf
                    leax      posil,pcr           position flag
                    lbsr      xpdat
                    leax      lon,pcr
                    tst       posfl,u
                    bne       dmptal
                    leax      loff,pcr
dmptal              lbsr      xpdat
                    lbsr      xcrlf
                    leax      croil,pcr           cross-assembler flag
                    lbsr      xpdat
                    leax      lon,pcr
                    tst       crofl,u
                    bne       dmptan
                    leax      loff,pcr
dmptan              lbsr      xpdat
                    lbsr      xcrlf
                    tst       disif,u             chk for input file
                    beq       dmptaw
                    leax      disim,pcr
                    lbsr      xpdat
                    leax      infile,u
dmptav              lda       ,x+                 print file info
                    cmpa      #$20
                    blo       dmptaw
                    lbsr      xoute
                    bra       dmptav
dmptaw              rts                           exit
