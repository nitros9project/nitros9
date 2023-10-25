
***************************************
**
auxino              lbsr      xcrlf               get aux file info
                    leax      altnm,pcr
                    lbsr      xpdat
                    leax      disim,pcr
                    lbsr      xpdat
                    leax      axfile,u
                    lbsr      inbufr              get file name to line buffer
                    cmpa      #$0d
                    bne       strtin              process input aux file
                    lbsr      xcrlf
                    leax      altnm,pcr
                    lbsr      xpdat
                    leax      disom,pcr
                    lbsr      xpdat
                    leax      otfile,u
                    lbsr      inbufr              get file name to line buffer
                    cmpa      #$0d
                    lbne      statoa              process output aux file
                    rts
**
strtin              bsr       stopin              start aux input file
                    lda       #READ.              open input axfile
                    clrb
                    leax      axfile,u
                    os9       I$Open
                    bcs       strtie
                    exg       a,b
                    std       axblok+iobfd,u      file desc
                    ldd       #bufaux             buffer length
                    std       axblok+iobbl,u
                    ldd       #$0000
                    std       axblok+iobcc,u
                    leax      axbuff,u
                    stx       axblok+iobba,u
                    stx       axblok+iobca,u
                    lda       #READ.              mode
                    sta       axblok+iobfc,u
                    inc       getfl,u             set aux flag
                    bra       strtix
strtie              lda       #$02                error
                    leax      errarz,pcr
                    ldy       #errarl
                    os9       I$WritLn
                    clr       axfile,u
                    ldd       #$0000
                    std       axblok+iobfd,u      file desc
strtix              rts
**
stopin              pshs      x                   stop aux input
                    tst       getfl,u
                    beq       stopix
                    clr       getfl,u             reset aux flag
                    clr       axfile,u            close file
                    lda       axblok+iobfd+1,u    file desc
                    os9       I$Close
                    bcc       stopie
                    lda       #$02                error
                    leax      errarz,pcr
                    ldy       #errarl
                    os9       I$WritLn
stopie              ldd       #$0000
                    std       axblok+iobfd,u
stopix              puls      x,pc
**
statoa              leax      otfile,u            open output otfile
                    ldd       #(WRITE.*256)+(READ.+WRITE.+PREAD.) access and attributes
                    os9       I$Create
                    bcc       statof
                    cmpb      #218                files exists?
                    bne       stater
                    ldd       #(WRITE.*256)+(UPDAT.+PREAD.) about the same attr's
                    os9       I$Open
                    bcc       statof
* lda #$02 error
* leax errarz,pcr
* ldy #errarl
* os9 I$WritLn
stater              os9       F$PErr
                    clr       otfile,u
                    rts
statof              clrb                          file desc
                    exg       a,b
                    std       otblok+iobfd,u
                    ldd       #buflen             buffer length
                    std       otblok+iobbl,u
                    std       otblok+iobcc,u
                    ldd       otblok+iobba,u      buffer addr
                    std       otblok+iobca,u
                    clr       confl,u             don't output to console
                    inc       dskfl,u             output to disk
statra              lda       #$73                #'s=partial reset
                    lbsr      xoute
                    lbsr      xouts
                    lbsr      xcrlf
                    lda       #$6f                #'o offset
                    lbsr      xoute
                    lbsr      xouts
                    tst       os9flx,u            chk for OS/9
                    beq       stata1
                    lda       #$30                #'0
                    lbsr      xoute
                    lbsr      xoute
                    lbsr      xoute
                    lbsr      xoute
                    bra       stata2
stata1              leax      oaddr,u
                    lbsr      xot4h
stata2              tst       disif,u             chk for input file
                    beq       statrb
                    lbsr      xcrlf
                    lda       #$73                an s
                    lbsr      xoute
                    lbsr      xouts
                    leax      infile,u
                    lbsr      dmptav
statrb              ldx       typem,u
statrc              cmpx      typee,u
                    bhs       statre
statrd              stx       caddr,u             output a line
                    lbsr      xcrlf
                    ldx       caddr,u
                    lda       ,x
                    cmpa      #'Z                 was #$5a chk 'Z
                    beq       statr2
                    ora       #$20
                    lbsr      xoute               type
                    lbsr      xouts               space
                    leax      $01,x
                    lbsr      xot4s               start
                    lbsr      xot4s               end
                    leax      $01,x
statr1              leax      $02,x
                    bra       statrc
statr2              ldd       $01,x               chk start/end
                    cmpd      $03,x
                    bne       statr4
                    lda       #$6d                make 'm
                    lbsr      xoute               type
                    lbsr      xouts               space
                    leax      $03,x
statr3              lbsr      xot4s               end
                    lbsr      xot2s               value
                    bra       statr1
statr4              lda       #$74                make 't
                    lbsr      xoute               type
                    lbsr      xouts               space
                    leax      $01,x
                    lbsr      xot4s               start
                    bra       statr3
statre              lbsr      xcrlf               print parms
                    ldx       faddr,u
                    leax      $01,x
                    beq       statrf
                    tst       os9flx,u            chk for OS/9
                    beq       state1
                    tst       infile,u            chk for file
                    bne       statrf
state1              lda       #$6e                make 'n
                    lbsr      xoute
                    lbsr      xouts
                    tst       os9flx,u
                    beq       state2
                    leax      oaddr,u             OS/9
                    lbsr      xot4s
                    ldd       taddr,u
                    addd      oaddr,u
                    pshs      d
                    tfr       s,x
                    lbsr      xot4s
                    puls      d
                    bra       state9
state2              leax      faddr,u             flex
                    lbsr      xot4s
                    lbsr      xot4s
                    leax      xaddr,u
                    lbsr      xot4h
state9              lbsr      xcrlf
statrf              tst       equfl,u
                    beq       statrh
                    lda       #$65                #'e
                    lbsr      xoute
                    lbsr      xcrlf
statrh              tst       posfl,u
                    beq       statri
                    lda       #$70                #'p
                    lbsr      xoute
                    lbsr      xcrlf
statri              lda       #$7a                #'z
                    lbsr      xoute
                    lbsr      xouts
                    lda       pmode,u
                    bpl       statrj
                    lda       #$09
statrj              adda      #$30                #'0
                    lbsr      xoute
                    lbsr      xcrlf
statrk              tst       crofl,u
                    bne       statcl
                    lda       #$62                b
                    lbsr      xoute
                    lbsr      xcrlf
statcl              inc       confl,u             output to console
                    clr       dskfl,u             don't output to disk
                    leax      otblok,u            force output
                    lbsr      fob
                    bcc       static
                    lda       #$02                error
                    leax      errarz,pcr
                    ldy       #errarl
                    os9       I$WritLn
static              lda       otblok+iobfd+1,u    file desc
                    os9       I$Close
                    bcc       statie
                    lda       #$02                error
                    leax      errarz,pcr
                    ldy       #errarl
                    os9       I$WritLn
statie              ldd       #$0000
                    std       otblok+iobfd,u
statrx              rtsk+iobfd,u ,u
