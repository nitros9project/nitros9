* Tandy Level Two: observe one process's DAT and P$Links around a double unlink.
* F$Load /dd/cmds/mall must return WCreate; F$Link obtains MonType.
                    use       defsfile
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,size
                    org       0
moda                rmb       2
modb                rmb       2
carrybit            rmb       1
bvalue              rmb       1
savedpid            rmb       1
desc                rmb       512
linebuf             rmb       256
                    rmb       256
size                equ       .
name                fcs       /DUnlink/
                    fcb       1
filename            fcc       "/dd/cmds/mall"
                    fcb       C$CR
secondname          fcs       /MonType/
phase0              fcc       "0 BEFORE LOAD"
                    fcb       0
phase1              fcc       "1 LOAD MALL"
                    fcb       0
phase2              fcc       "2 LINK MONTYPE"
                    fcb       0
phase3              fcc       "3 UNLINK WCREATE"
                    fcb       0
phase4              fcc       "4 UNLINK WCREATE AGAIN"
                    fcb       0
phase5              fcc       "5 UNLINK MONTYPE"
                    fcb       0
pidtext             fcc       " PID="
                    fcb       0
atext               fcc       " A="
                    fcb       0
btext               fcc       " B="
                    fcb       0
ctext               fcc       " C="
                    fcb       0
resulttext          fcc       " BREG="
                    fcb       0
dattext             fcb       C$CR
                    fcc       "DAT  : "
                    fcb       0
linktext            fcb       C$CR
                    fcc       "LINKS: "
                    fcb       0
complete            fcc       "DOUBLEUNLINKDONE"
                    fcb       C$CR
start               clra
                    clrb
                    std       moda,u
                    std       modb,u
                    sta       carrybit,u
                    sta       bvalue,u
                    leax      phase0,pcr
                    lbsr      snapshot
                    leax      filename,pcr
                    clra
                    pshs      u
                    os9       F$Load
                    tfr       u,x
                    puls      u
                    lbcs      fail
                    stx       moda,u
                    lbsr      status
                    leax      phase1,pcr
                    lbsr      snapshot
                    leax      secondname,pcr
                    clra
                    pshs      u
                    os9       F$Link
                    tfr       u,x
                    puls      u
                    lbcs      fail
                    stx       modb,u
                    lbsr      status
                    leax      phase2,pcr
                    lbsr      snapshot
                    ldx       moda,u
                    lbsr      unlink
                    leax      phase3,pcr
                    lbsr      snapshot
                    ldx       moda,u
                    lbsr      unlink
                    leax      phase4,pcr
                    lbsr      snapshot
                    ldx       modb,u
                    lbsr      unlink
                    leax      phase5,pcr
                    lbsr      snapshot
                    lda       #1
                    leax      complete,pcr
                    ldy       #16
                    os9       I$WritLn
                    clrb
fail                os9       F$Exit
unlink              pshs      u
                    tfr       x,u
                    os9       F$UnLink
                    puls      u
status              tfr       cc,a
                    anda      #Carry
                    sta       carrybit,u
                    stb       bvalue,u
                    rts
snapshot            pshs      x
                    os9       F$ID
                    lbcs      fail
                    sta       savedpid,u
                    leax      desc,u
                    os9       F$GPrDsc
                    lbcs      fail
                    puls      x
                    leay      linebuf,u
                    bsr       text
                    leax      pidtext,pcr
                    bsr       text
                    lda       savedpid,u
                    lbsr      hexbyte
                    leax      atext,pcr
                    bsr       text
                    ldd       moda,u
                    lbsr      hexword
                    leax      btext,pcr
                    bsr       text
                    ldd       modb,u
                    lbsr      hexword
                    leax      ctext,pcr
                    bsr       text
                    lda       carrybit,u
                    lbsr      hexbyte
                    leax      resulttext,pcr
                    bsr       text
                    lda       bvalue,u
                    lbsr      hexbyte
                    leax      dattext,pcr
                    bsr       text
                    leax      desc+P$DATImg,u
                    bsr       words
                    leax      linktext,pcr
                    bsr       text
                    leax      desc+P$Links,u
                    bsr       words
                    lda       #C$CR
                    sta       ,y+
                    tfr       y,d
                    leax      linebuf,u
                    pshs      x
                    subd      ,s++
                    tfr       d,y
                    lda       #1
                    os9       I$Write
                    lbcs      fail
                    rts
text                lda       ,x+
                    beq       textdone
                    sta       ,y+
                    bra       text
textdone            rts
words               ldb       #8
wordloop            pshs      b
                    ldd       ,x++
                    bsr       hexword
                    lda       #C$SPAC
                    sta       ,y+
                    puls      b
                    decb
                    bne       wordloop
                    rts
hexword             pshs      b
                    bsr       hexbyte
                    puls      a
hexbyte             pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       digit
                    puls      a
                    anda      #$0F
digit               adda      #'0
                    cmpa      #'9
                    bls       emit
                    adda      #7
emit                sta       ,y+
                    rts
                    emod
eom                 equ       *
