
***************************************
**
start               equ       *                   starting address
**
initz               leax      temps,u             clear work area
                    ldy       #(tempe-temps)
clear               clr       ,x+
                    leay      -$01,y
                    bne       clear
                    leax      predef,pcr          init data
                    leay      prermb,u
                    ldb       #prelen
cleard              lda       ,x+
                    sta       ,y+
                    decb
                    bne       cleard
**
clears              sts       mystk,u             beginning stack pointer
                    leax      -$0200,s            table address limit
                    stx       alimit,u
                    lbsr      fixesc              fix escape addr, pg 7
                    lbsr      initty              initialize tty paras, pg 7
                    lbsr      inifil              initialize file buffers, pg 8
                    lda       #$09                set 6809 mode
                    lbsr      setmoi              set cpu mode, pg 10
                    lbsr      maprt               fix addrs, pg 10
                    inc       confl,u             set crt flag
                    lbsr      xcrlf               print heading, pg 83
                    leax      clrscn,pcr
                    lbsr      outcur              clear the screen, pg24
                    leax      idlin,pcr
                    lbsr      xpdat               output logo, pg 83
                    lda       #$30+vn
                    lbsr      xoute               output version, pg 83
                    lbsr      helpyu              output rest of heading, pg 10
**
askin               lds       mystk,u             look at input
                    tst       ttyswt,u            check tty switch
                    beq       askin0
                    bsr       initty              initialize tty params, pg 7
askin0              lbsr      inrtty              reset tty paras
                    lbsr      xcrlf               ,pg 83
                    leax      beeps,pcr           beep bell
                    lbsr      xpdat               , pg 83
                    lda       #$3f                print a ?
                    lbsr      xoute               , pg 83
askin1              lbsr      xinee               read command, pg 81
                    cmpa      #$20                chk cntrl char
                    bgt       askin2              its printable
                    cmpa      #$0d                chk cr
                    bne       askin
                    tst       getfl,u             chk get flag
                    bne       askin1              ignore if so
                    bra       askin
askin2              leax      coman,pcr           command table
                    anda      #$5f                to upper case
                    sta       comand,u
                    pshs      a                   offset
                    clrb
                    cmpa      #'A                 A?
                    blo       rdjmp
                    cmpa      #'Z                 Z?
                    bhi       rdjmp
                    tfr       a,b
                    subb      #$40                sub ascii bias
                    aslb                          dbl it
rdjmp               ldd       b,x                 jump to routine
                    leax      d,x
                    puls      a                   get offset back
                    jsr       ,x
                    bra       askin               end of this routine
**
fixesc              equ       *                   fix escape action
                    leax      xcrlr,pcr           interrupt handler
                    os9       F$Icpt              catch interrupts
                    rts
**
initty              ldd       #$0000              set up tty paras
                    leax      scfolg,u            point to scf orig area
                    os9       I$GetStt            get tty info
                    ldd       #$0100              set up tty paras
                    leax      scfolp,u            point to scf orig area
                    os9       I$GetStt            get tty info
                    lda       scfolg+PD.PAU-PD.OPT,u
                    ldb       scfolp+PD.PAU-PD.OPT,u
                    sta       scfopg,u
                    stb       scfopp,u
                    clr       scfolg+PD.PAU-PD.OPT,u
                    clr       scfolp+PD.PAU-PD.OPT,u
                    clr       ttyswt,u            clear tty switch
                    bra       inrtty              set up tty paras
**
wtftty              lda       #write              reset write paras
                    sta       toblok+iobfc,u
                    rts
**
wlftty              lda       #wrln               reset write paras
                    sta       toblok+iobfc,u
                    rts
**
scstty              lda       #write              reset write paras
                    sta       toblok+iobfc,u
                    bra       fcstty
**
csctty              bsr       ingtty              copy tty paras
                    clr       scfwkg+PD.BSP-PD.OPT,u
                    clr       scfwkg+PD.DEL-PD.OPT,u
                    clr       scfwkg+PD.EOF-PD.OPT,u
                    clr       scfwkg+PD.RPR-PD.OPT,u
                    clr       scfwkg+PD.DUP-PD.OPT,u
                    clr       scfwkg+PD.INT-PD.OPT,u
                    clr       scfwkg+PD.QUT-PD.OPT,u
                    clr       scfwkg+PD.EKO-PD.OPT,u echo
                    lda       #wrln               reset write paras
                    sta       toblok+iobfc,u
**
fcstty              com       scfwkg+PD.EKO-PD.OPT,u echo
**
instty              ldd       #$0000              set tty paras
                    leax      scfwkg,u            point to scf work
                    os9       I$SetStt            set tty info
                    rts
**
lastty              lda       scfopg,u            restore pause
                    ldb       scfopp,u
                    sta       scfolg+PD.PAU-PD.OPT,u
                    stb       scfolp+PD.PAU-PD.OPT,u
                    lda       #$ff                set tty switch
                    sta       ttyswt,u
**
inrtty              lda       #read               reset read paras
                    sta       tiblok+iobfc,u
**
inftty              lda       #wrln               reset write paras
                    sta       toblok+iobfc,u
**
fintty              ldd       #$0000              final reset tty paras
                    leax      scfolg,u            point to scf orig area
                    os9       I$SetStt            set tty info
                    ldd       #$0100              reset tty paras
                    leax      scfolp,u            point to scf orig
                    os9       I$SetStt            set tty info
**
ingtty              ldd       #$0000              get tty paras
                    leax      scfwkg,u            point to scf work
                    os9       I$GetStt            get tty info
                    ldd       #$0100              get tty paras
                    leax      scfwkp,u            point to scf work
                    os9       I$GetStt            get tty info
                    rts
**
inbtty              lda       #rdln               set tty paras for buffer
                    sta       tiblok+iobfc,u
                    bra       inftty
**
inifil              lda       #read               set up i/o blocks
                    sta       inblok+iobfc,u
                    sta       tiblok+iobfc,u
                    lda       #write
                    sta       otblok+iobfc,u
                    lda       #wrln
                    sta       prblok+iobfc,u
                    sta       toblok+iobfc,u
                    ldd       #buftrm
                    std       tiblok+iobbl,u
                    std       toblok+iobbl,u
                    std       toblok+iobcc,u
                    ldd       #buflen
                    std       inblok+iobbl,u
                    std       otblok+iobbl,u
                    std       otblok+iobcc,u
                    std       prblok+iobbl,u
                    std       prblok+iobcc,u
                    ldd       #$0001
                    std       toblok+iobfd,u
                    incb
                    leax      inbuff,u
                    stx       inblok+iobba,u
                    stx       inblok+iobca,u
                    leax      otbuff,u
                    stx       otblok+iobba,u
                    stx       otblok+iobca,u
                    leax      tibuff,u
                    stx       tiblok+iobba,u
                    stx       tiblok+iobca,u
                    leax      tobuff,u
                    stx       toblok+iobba,u
                    stx       toblok+iobca,u
                    leax      prbuff,u
                    stx       prblok+iobba,u
                    stx       prblok+iobca,u
                    ldd       #$0000
                    std       inlrec,u
                    sta       inlrec+2,u
                    ldd       #$ffff
                    std       curmod,u
                    std       nxtmod,u
                    sta       curmod+2,u
                    sta       nxtmod+2,u
                    rts
