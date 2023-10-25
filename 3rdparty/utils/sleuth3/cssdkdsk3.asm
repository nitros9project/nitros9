
***************************************
**
diskd               lbsr      xcrlf               input file name
                    leax      disim,pcr
                    lbsr      xpdat
                    leax      locstk,u
                    lbsr      inbufr              get file name
                    cmpa      #$2a                chk for *
                    bne       dikkd
                    tst       os9flx,u            chk for OS/9
                    beq       dikkd
                    tst       disif,u             chk input flag
                    beq       dikkd
                    ldy       nxtmod+1,u          set up seek
                    sty       curmod+1,u
                    ldb       nxtmod,u
                    stb       curmod,u
                    clra
                    tfr       d,x
                    lda       inblok+iobfd+1,u    file desc
                    pshs      u
                    tfr       y,u
                    os9       I$Seek              seek
                    puls      u                   reset stack
                    lbcc      dikib               get next module
                    lda       #$02                error
                    leax      errirz,pcr
                    ldy       #errirl
                    os9       I$WritLn
                    lbra      dikfc               error exit
dikkd               pshs      a
                    clr       defalt,u
                    ldd       #$ffff              reset indices
                    std       curmod,u
                    std       nxtmod,u
                    std       inlrec,u
                    sta       curmod+2,u
                    sta       nxtmod+2,u
                    sta       inlrec+2,u
                    lbsr      maprt
                    puls      a
                    cmpa      #$0d                chk first char in buffer
                    lbeq      dikii               no file name entered
                    tst       disif,u             chk input flag
                    beq       dikia               already open?
                    clr       disif,u             clr input flag
                    lda       inblok+iobfd+1,u
                    os9       I$Close
dikia               leax      locstk,u            copy file name
                    leay      infile,u
dikco               lda       ,x+
                    sta       ,y+
                    bne       dikco
                    leax      infile,u            open input infile
                    lda       #READ.              was #(read.+exec.)=error
                    clrb
                    os9       I$Open
                    bcc       dikok
                    pshs      d,cc
                    os9       F$PErr
                    pshs      x
                    ldx       #$00FF
                    os9       F$Sleep
                    puls      x
                    puls      d,cc                restore it too
dikok               exg       a,b
                    bcc       dikib
                    clr       infile,u            error
                    lda       #$02
                    leax      errirz,pcr
                    ldy       #errirl
                    os9       I$WritLn
                    ldd       #$0000
                    std       inblok+iobfd,u
                    rts
dikib               std       inblok+iobfd,u      file desc
                    ldd       #buflen             buffer length
                    std       inblok+iobbl,u
                    ldd       #$0000
                    std       inblok+iobcc,u
                    ldd       inblok+iobba,u      buffer addr
                    std       inblok+iobca,u
                    ldd       curmod,u            reset log rec ctr
                    std       inlrec,u
                    lda       curmod+2,u
                    sta       inlrec+2,u
dikre               lbsr      mapdk               open, map it
                    bcc       dikti               chk error
dikfc               lbsr      fmsclo              close it and exit
dikie               lbra      stopin              turn off aux input
dikti               lda       #$4b                default type=k
                    sta       defalt,u
                    inc       disif,u
                    ldx       typee,u             set map addr
                    stx       typem,u
dikii               rts
**
dikni               lbsr      xcrlf               output file name
                    clr       disof,u
                    leax      disom,pcr
                    lbsr      xpdat
                    leax      otfile,u
                    lbsr      inbufr              get file name into line buffer
                    cmpa      #$0d                get first char in buffer
                    beq       dikno               no file name was entered
                    ldd       #$0000
                    sta       -$01,y              change cr to null
                    std       otblok+iobfd,u      file desc
                    inc       disof,u
dikno               rts
