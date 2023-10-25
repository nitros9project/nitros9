*****************************
* OS9 DASM VERSION 1.0      *
* (C)1992 J.R.COLLYER       *
*****************************

                    ifp1
                    use       os9.d
                    endc

begin               mod       len,name,prgrm+objct,reent+1,entry,dsize
lf                  equ       $0A
cr                  equ       $0D
sp                  equ       $20
mask                equ       $FF
on                  equ       $FF
stacksz             equ       200
buffsiz             equ       24576
pagesiz             equ       8192
pagenum             equ       3
path                rmb       1
dpath               rmb       1
mode                rmb       1
pflag               rmb       1
bflag               rmb       1
count               rmb       1
errnum              rmb       1
listflg             rmb       1
linkcnt             rmb       1
address             rmb       2
saveadr             rmb       2
auxaddr             rmb       2
endaddr             rmb       2
moduloc             rmb       2
pointer             rmb       2
endbuff             rmb       2
counter             rmb       2
linkaddr            rmb       2
curstack            rmb       2
lststack            rmb       2
firstack            rmb       2
branchad            rmb       2
offsopt             rmb       1
offsflg             rmb       1
gimicnt             rmb       1
gimidat             rmb       3
gimisys             rmb       5
xaddress            rmb       2
pcaller             rmb       1
peflg               rmb       1
psflg               rmb       1
paddress            rmb       2
pendaddr            rmb       2
turn                rmb       1
status              rmb       4
eko                 rmb       1
                    rmb       27
linknam             rmb       stacksz
iobuff              rmb       stacksz
adrstack            rmb       stacksz
buffer              rmb       buffsiz
                    rmb       stacksz
                    rmb       stacksz
dsize               equ       .
name                fcs       /Dasm/
                    fcc       /(C)1992 J.R.COLLYER/
                    fcb       1
entry               decb
                    beq       noparams
                    lbra      params
noparams            incb
                    stb       path
                    leay      copyr,pcr
                    bsr       echo
                    lbsr      init
centry              leay      prompt,pcr
                    bsr       echo
                    lbsr      getsta
                    clr       eko,u
                    lbsr      setsta
                    clra
                    leax      iobuff,u
inkey               ldb       #1
                    os9       i$getstt
                    bcs       inkey
                    ldy       #1
                    os9       i$read
                    lbcs      exit
                    leay      commands,pcr
                    lda       ,x
                    cmpa      #'a
                    blo       cloop
                    suba      #sp
                    sta       ,x
cloop               leay      3,y
                    lda       ,y
                    beq       errcom
                    cmpa      ,x
                    bne       cloop
                    ldd       1,y
                    leay      begin,pcr
                    jsr       d,y
                    bra       centry
errcom              bsr       comerr
                    bra       centry
comerr              bsr       echoon
                    leay      whatmsg,pcr
                    bsr       echo
                    rts
errmsg              stb       errnum
                    leay      prompt,pcr
                    bsr       echo
                    ldb       errnum
                    lda       #2
                    os9       f$perr
                    rts
crlf                lda       #cr
                    sta       ,x+
                    clra
                    sta       ,x
                    leay      iobuff,u
echo                pshs      u
                    tfr       y,x
                    tfr       y,u
                    ldy       #0
outsize             ldb       ,u+
                    beq       print
                    leay      1,y
                    bra       outsize
print               lda       path
                    os9       i$writln
                    lbcs      fatal
                    puls      u
                    rts
input               leax      iobuff,u
                    ldy       #stacksz
                    clra
                    os9       i$readln
                    bcs       errmsg
                    rts
skip                lda       ,x+
                    cmpa      #sp
                    beq       skip
                    leax      -1,x
                    rts
commons             bsr       echoon
                    bsr       echo
                    bsr       input
                    leax      iobuff,u
                    bsr       skip
                    rts
getsta              leax      status,u
                    ldd       #0
                    os9       i$getstt
                    lbcs      exit
                    rts
setsta              os9       i$setstt
                    lbcs      exit
                    rts
echoon              bsr       getsta
                    inc       eko,u
                    bra       setsta
shell               leay      shellmsg,pcr
                    bsr       commons
                    clra
                    clrb
                    pshs      u
                    tfr       x,u
                    tfr       d,y
shell2              leay      1,y
                    lda       ,x+
                    cmpa      #cr
                    bne       shell2
                    clra
                    leax      rshell,pcr
                    os9       f$fork
                    lbcs      fatal
                    os9       f$wait
                    lbcs      fatal
                    puls      u
sheout              rts
link                leay      linkmsg,pcr
                    bsr       commons
                    cmpa      #cr
                    beq       sheout
                    cmpa      #'.
                    beq       setlinke
                    cmpa      #'@
                    beq       setlinkx
pelink              clra
                    pshs      x
                    pshs      u
                    os9       f$link
                    lbcs      lfatal
                    tfr       u,x
                    ldd       2,x
                    subd      #3
                    puls      u
                    stx       moduloc,u
                    sty       address,u
                    sty       linkaddr,u
                    leay      d,x
                    sty       endaddr,u
                    puls      x
                    pshs      x,u
                    os9       f$prsnam
                    puls      x,u
                    lbcs      errmsg
                    pshs      x,u
                    leay      linknam,u
                    os9       f$cmpnam
                    puls      x,u
                    bcs       savlnam
                    lda       linkcnt,u
                    cmpa      #on
                    bhs       lnkout
                    inc       linkcnt,u
lnkout              rts
savlnam             pshs      x
                    clr       linkcnt,u
                    leay      linknam,u
putkinam            lda       ,x+
                    cmpa      #cr
                    beq       sitit
                    sta       ,y+
                    bra       putkinam
sitit               leay      -1,y
                    lda       ,y
                    ora       #$80
                    sta       ,y
                    puls      x,pc
setlinkx            ldy       linkaddr,u
                    sty       address,u
                    rts
setlinke            ldy       moduloc,u
                    sty       address,u
                    rts
unlink              lbsr      echoon
                    tst       linkcnt,u
                    beq       notlink
                    dec       linkcnt,u
                    leay      ulinkmsg,pcr
                    lbsr      echo
                    pshs      u
                    exg       u,x
                    ldu       moduloc,x
                    os9       f$unlink
                    bcs       fatal
                    puls      u
                    rts
notlink             leay      notlkmsg,pcr
                    lbsr      echo
                    rts
fatal               puls      u
                    lbra      errmsg
lfatal              puls      u
                    puls      x
                    lbra      errmsg
quit                leay      exitmsg,pcr
                    lbsr      commons
                    ora       #sp
                    cmpa      #'y
                    beq       exexit
                    rts
exexit              clrb
exit                os9       f$exit
help                lbsr      echoon
                    leay      helpmsg,pcr
                    lbsr      echo
                    rts
jump                leay      jumpmsg,pcr
                    lbsr      commons
pjump               leay      address,u
                    sty       auxaddr,u
                    bsr       ejaddr
                    tstb
                    bne       adrerr
                    ldd       address,u
                    std       paddress,u
                    tst       offsopt,u
                    bne       pjump1
                    bra       pjump2
pjump1              pshs      d
                    ldd       moduloc,u
                    addd      ,s++
                    std       address,u
pjump2              clrb
                    rts
ejaddr              cmpa      #cr
                    beq       addrerr
                    ldd       ,y
                    std       saveadr,u
                    clr       count
                    clrb
                    bsr       hexcalc
                    tst       count
                    beq       addrerr
                    clr       count
                    bsr       hexcalc
                    tst       count
                    beq       addrerr
                    stb       ,y+
                    clr       count
                    clrb
                    bsr       hexcalc
                    tst       count
                    beq       addrerr
                    clr       count
                    bsr       hexcalc
                    tst       count
                    beq       addrerr
                    stb       ,y
                    clrb
                    rts
hexcalc             lda       ,x
                    cmpa      #'0
                    blo       jout
                    cmpa      #'9
                    bls       makebin
                    anda      #%11011111
                    cmpa      #'A
                    blo       jout
                    cmpa      #'F
                    bhi       jout
                    suba      #7
makebin             suba      #'0
                    pshs      a
                    lda       #16
                    mul
                    addb      ,s+
                    leax      1,x
                    inc       count
jout                rts
addrerr             ldd       saveadr,u
                    ldy       auxaddr,u
                    std       ,y
bckcall             clrb
                    decb
                    rts
adrerr              tst       pcaller,u
                    bne       bckcall
                    leay      prompt,pcr
                    lbsr      echo
                    leay      adrmsg,pcr
                    lbsr      echo
                    rts
chngend             leay      endadmsg,pcr
                    lbsr      commons
pchgend             leay      endaddr,u
                    sty       auxaddr,u
                    bsr       ejaddr
                    tstb
                    bne       adrerr
                    ldd       endaddr,u
                    std       pendaddr,u
                    tst       offsopt,u
                    bne       pchg1
pchg                clrb
                    rts
pchg1               pshs      d
                    ldd       moduloc,u
                    addd      ,s++
                    std       endaddr,u
                    bra       pchg
setmode             leay      getmode,pcr
                    lbsr      commons
                    pshs      u
                    leau      mode,u
                    bsr       onoff
                    puls      u
tellmode            leay      prompt,pcr
                    lbsr      echo
                    tst       mode
                    bmi       pmon
                    leay      modemsg2,pcr
                    bra       pmode
pmon                leay      modemsg1,pcr
pmode               lbsr      echo
                    rts
printer             leay      prtermsg,pcr
                    lbsr      commons
                    pshs      u
                    leau      pflag,u
                    bsr       onoff
                    puls      u
tellprt             leay      prompt,pcr
                    lbsr      echo
                    tst       pflag
                    bmi       ponm
                    leay      scrmsg,pcr
                    bra       pp
ponm                leay      prtmsg,pcr
pp                  lbsr      echo
                    rts
onoff               cmpa      #'+
                    beq       iton
                    cmpa      #'-
                    bne       exonoff
                    clr       ,u
                    bra       exonoff
iton                lda       #on
                    sta       ,u
exonoff             rts
bcom                leay      buffmsg,pcr
                    lbsr      commons
                    cmpa      #cr
                    beq       tellb
                    cmpa      #'.
                    beq       buffe
                    cmpa      #'@
                    beq       buffx
                    tfr       a,b
                    orb       #sp
                    cmpb      #'c
                    beq       clsbuff
                    cmpb      #'l
                    beq       list
                    pshs      u
                    leau      bflag,u
                    bsr       onoff
                    puls      u
tellb               leay      prompt,pcr
                    lbsr      echo
                    tst       bflag
                    bmi       bonm
                    leay      buff1,pcr
                    bra       bmexit
bonm                leay      buff2,pcr
bmexit              lbsr      echo
                    rts
time                tst       listflg,u
                    beq       timeout
                    ldx       #$3FFF
timel               leax      -1,x
                    bne       timel
timeout             rts
list                lda       #on
                    sta       listflg,u
                    bsr       listbuff
                    clr       listflg,u
                    rts
buffe               leay      buffer,u
                    bra       buffex
buffx               ldy       xaddress,u
buffex              sty       address,u
                    rts
clsbuff             leax      buffer,u
                    pshs      x
clsloop             clr       ,x+
                    cmpx      pointer,u
                    blo       clsloop
                    puls      x
                    stx       pointer,u
                    clr       counter,u
                    clr       1+counter,u
                    clr       mode
                    clr       bflag
                    rts
listbuff            ldx       counter,u
                    cmpx      #0
                    beq       listout
                    pshs      x
                    leay      buffer,u
                    bra       lbl1
lbloop              puls      y
lbl0                lda       ,y+
                    bne       lbl0
lbl1                pshs      y
                    lbsr      echo
                    bsr       time
                    ldx       counter,u
                    leax      -1,x
                    stx       counter,u
                    cmpx      #0
                    bne       lbloop
                    puls      y
                    puls      x
                    stx       counter,u
listout             rts
back                lbsr      echoon
                    clr       mode
                    leax      iobuff,u
                    ldd       address,u
                    subd      #1
                    tfr       d,y
                    tst       offsopt,u
                    beq       back2
                    lbsr      setoffs
back2               lbsr      outhex2
                    lbra      next
ascii               lbsr      echoon
ascii2              clr       mode
                    leax      iobuff,u
                    ldd       address,u
                    tfr       d,y
                    tst       offsopt,u
                    beq       ascii3
                    lbsr      setoffs
ascii3              lbsr      outhex2
                    lbsr      space1
                    ldb       ,y+
                    pshs      b
                    lbsr      outhex1
                    lbsr      space2
                    puls      b
                    cmpb      #'z+1
                    bhs       dot
                    cmpb      #sp
                    blo       dot
                    stb       ,x+
                    lbra      next
dot                 ldb       #'.
                    stb       ,x+
                    lbra      next
read                leay      fname,pcr
                    lbsr      commons
                    cmpa      #cr
                    beq       readout
                    lda       #exec.+read.
                    os9       i$open
                    lbcs      errmsg
                    sta       dpath
                    bsr       moduread
                    bsr       moduadrs
                    clr       bflag
                    clr       mode
readout             rts
moduread            leax      buffer,u
                    ldy       #buffsiz
                    os9       i$read
                    bcs       chkeof
                    lda       dpath
                    os9       i$close
                    rts
chkeof              cmpb      #e$eof
                    lbne      errmsg
                    lda       dpath
                    os9       i$close
                    lbcs      errmsg
                    rts
moduadrs            leax      buffer,u
                    stx       moduloc,u
                    ldd       2,x
                    subd      #3
                    leay      d,x
                    sty       endaddr,u
                    ldd       9,x
                    leay      d,x
                    sty       address,u
                    sty       xaddress,u
                    rts
write               leay      fname,pcr
                    lbsr      commons
                    lda       ,x
                    cmpa      #cr
                    beq       writout
                    cmpa      #'*
                    beq       makefile
                    bra       openfile
makefile            leax      1,x
                    lbsr      skip
                    lda       ,x
                    cmpa      #cr
                    beq       writout
                    lda       #updat.
                    ldb       #$0B
                    os9       i$create
                    lbcs      errmsg
                    sta       dpath
                    bsr       outdisk
outwrit             lda       dpath
                    os9       i$close
                    lbcs      errmsg
                    clr       mode
                    clr       bflag
writout             rts
openfile            lda       #updat.
                    os9       i$open
                    lbcs      errmsg
                    sta       dpath
                    bsr       seek
                    bsr       outdisk
                    bra       outwrit
seek                pshs      u
                    lda       dpath
                    ldb       #$02
                    os9       i$getstt
                    lbcs      fatal
                    os9       i$seek
                    lbcs      fatal
                    puls      u
                    rts
chkbuff             ldx       pointer,u
                    cmpx      endbuff,u
                    bhs       outb2
                    leay      iobuff,u
bufloop             lda       ,y+
                    sta       ,x+
                    beq       bnl
                    bra       bufloop
bnl                 leay      pointer,u
                    stx       ,y
                    ldx       counter,u
                    leax      1,x
                    stx       counter,u
                    rts
outb2               leay      prompt,pcr
                    lbsr      echo
                    leay      bfull,pcr
                    lbsr      echo
                    clr       bflag
                    clr       mode
                    rts
outdisk             lda       dpath
                    ldb       path
                    sta       path
                    stb       dpath
                    lbsr      listbuff
                    lda       path
                    ldb       dpath
                    sta       dpath
                    stb       path
                    rts
branch              lbsr      echoon
                    ldx       curstack,u
                    cmpx      lststack,u
                    beq       nomove
                    ldy       address,u
                    sty       ,x++
                    stx       curstack,u
                    ldx       branchad,u
                    stx       address,u
                    lbra      ddentry
nomove              leay      stackms1,pcr
nomove1             lbsr      echo
                    rts
return              lbsr      echoon
                    ldx       curstack,u
                    cmpx      firstack,u
                    bhi       yesmove
                    leay      stackms2,pcr
                    bra       nomove1
yesmove             ldy       ,--x
                    stx       curstack,u
                    sty       address,u
                    lbra      ddentry
                    leay      stackms2,pcr
                    lbsr      echo
                    rts
offscom             leay      offsmsg,pcr
                    lbsr      commons
                    pshs      u
                    leau      offsopt,u
                    lbsr      onoff
                    puls      u
telloffs            leay      prompt,pcr
                    lbsr      echo
                    tst       offsopt,u
                    bmi       offson
                    leay      offsmsg2,pcr
                    bra       offsmode
offson              leay      offsmsg1,pcr
offsmode            lbsr      echo
                    rts
gimicom             leay      gimimsg,pcr
                    lbsr      commons
                    clr       gimicnt,u
                    leay      gimidat,u
gimiloop            lda       ,x+
                    cmpa      #cr
                    beq       gimichk
                    cmpa      #sp
                    beq       gimiloop
                    cmpa      #',
                    beq       gimiloop
                    leax      -1,x
                    clr       count
                    clrb
                    lbsr      hexcalc
                    tst       count
                    beq       gimibad
                    clr       count
                    lbsr      hexcalc
                    tst       count
                    beq       gimibad
                    cmpb      #mask
                    bls       nologic
                    orb       #mask
                    andb      #mask
nologic             stb       ,y+
                    inc       gimicnt,u
                    ldb       #pagenum
                    cmpb      gimicnt,u
                    bne       gimiloop
gimichk             tst       gimicnt,u
                    beq       gimiprt
                    clra
                    clrb
gimiloo             addd      #pagesiz
                    dec       gimicnt,u
                    bne       gimiloo
                    leay      gimidat,u
                    exg       d,y
                    ldx       #0
                    pshs      u
                    leau      buffer,u
                    swi2
                    fcb       $1B
                    lbcs      fatal
                    puls      u
gimiprt             leay      buffer,u
                    sty       address,u
                    leay      prompt,pcr
                    lbsr      echo
                    lbra      ascii2
gimibad             leay      prompt,pcr
                    lbsr      echo
                    ldb       turn,u
                    eorb      #on
                    stb       turn,u
                    beq       nxturn
                    leay      gimimsg1,pcr
gbadout             lbsr      echo
                    rts
nxturn              leay      gimimsg2,pcr
                    bra       gbadout
init                ldb       #100
                    leax      dpath,u
initloop            clr       ,x+
                    decb
                    bne       initloop
                    leax      buffer,u
                    stx       pointer,u
                    ldd       #buffsiz
                    leay      d,x
                    sty       endbuff,u
                    ldd       #$FFEF
                    std       endaddr,u
prgmdat             lda       #mask               top page
                    ldb       #8
                    leay      gimidat,u
prgdatlp            sta       ,y+
                    deca
                    decb
                    bne       prgdatlp
                    lda       #on
                    sta       turn,u
                    leay      dasmmsg,pcr
                    leax      linknam,u
stuff1              lda       ,y+
                    sta       ,x+
                    bne       stuff1
initstak            leax      adrstack,u
                    stx       curstack,u
                    stx       firstack,u
                    ldd       #stacksz
                    leay      d,x
                    sty       lststack,u
                    rts
setoffs             pshs      a
                    lda       #on
                    sta       offsflg,u
                    puls      a
                    rts
dentry              lbsr      echoon
ddentry             ldy       address,u
                    leax      iobuff,u
                    pshs      y
                    ldd       ,s
                    tst       offsopt,u
                    beq       dentry2
                    bsr       setoffs
dentry2             lbsr      outhex2
                    lbsr      space1
                    puls      y
                    ldb       ,y+
                    tfr       b,a
                    bita      #$80
                    lbmi      grp80
                    anda      #$F0
                    lbeq      grp0
                    cmpa      #$10
                    lbeq      grp10
                    cmpa      #$20
                    lbeq      grp20
                    cmpa      #$30
                    lbeq      grp30
                    cmpa      #$60
                    lbeq      grp60
                    cmpa      #$70
                    lbeq      grp70
                    pshs      b
                    pshs      y
                    andb      #$0F
                    lbsr      set
                    puls      y
                    puls      b
                    andb      #$F0
                    cmpb      #$50
                    beq       grp50
                    lda       #'a
                    bra       save
grp50               lda       #'b
save                sta       ,x+
next                sty       address,u
                    lbsr      crlf
options             tst       pflag
                    beq       chkdisk
                    bsr       hardprt
chkdisk             tst       bflag
                    beq       chkauto
                    bsr       diskwrt
chkauto             tst       mode
                    bmi       automat
                    rts
automat             ldd       address,u
                    cmpd      endaddr,u
                    lblo      ddentry
                    rts
hardprt             leax      pmsg,pcr
                    lda       #write.
                    os9       i$open
                    bcc       hard
                    cmpb      #246
                    beq       hardprt
                    lbra      errmsg
hard                sta       dpath
hard1               lda       dpath
                    leax      iobuff,u
                    ldy       #stacksz
                    os9       i$writln
                    bcc       hardout
                    cmpb      #246
                    beq       hard1
                    lbra      errmsg
hardout             lda       dpath
                    os9       i$close
                    lbcs      errmsg
                    rts
diskwrt             lbsr      chkbuff
                    rts
params              ldb       #1
                    stb       path
                    pshs      x
                    lbsr      init
                    puls      x
                    ldb       #on
                    stb       mode
                    stb       pcaller,u
getparm             lbsr      skip
                    lda       ,x+
                    cmpa      #'-
                    lbne      syntax
                    lbsr      skip
                    lda       ,x+
                    ora       #sp
                    cmpa      #'o
                    bne       chkend
                    bsr       chksub
                    stb       offsopt,u
                    bra       getparm
chkend              cmpa      #'e
                    bne       chkstart
                    lbsr      skip
                    lbsr      pchgend
                    tstb
                    lbne      syntaxa
                    bsr       chksub
                    stb       peflg,u
                    bra       getparm
chkstart            cmpa      #'s
                    lbhi      syntax
                    bne       chkmem
                    lbsr      skip
                    lbsr      pjump
                    tstb
                    lbne      syntaxa
                    bsr       chksub
                    stb       psflg,u
                    bra       getparm
chksub              clrb
                    decb
                    rts
chkmem              cmpa      #'m
                    bne       chkread
                    bra       penter
chkread             cmpa      #'r
                    beq       inputr
                    cmpa      #'l
                    lbne      syntax
                    lbsr      skip
                    bsr       psnam
                    clra
                    pshs      x,u
                    os9       f$link
                    bcs       pfatal
                    puls      x,u
                    bsr       psnam
                    lbsr      pelink
                    bra       penter
pfatal              puls      x,u
                    lbra      pexit
psnam               pshs      x
                    lda       #'/
                    cmpa      ,x
                    beq       skip2
                    leax      -1,x
                    sta       ,x
skip2               os9       f$prsnam
                    bcs       syntax
                    lda       #cr
                    sta       ,y
                    puls      x
                    rts
inputr              lbsr      skip
                    lda       ,x
                    cmpa      #cr
                    beq       syntax
                    lda       #exec.+read.
                    os9       i$open
                    bcs       pexit
                    sta       dpath
                    lbsr      moduread
                    lbsr      moduadrs
penter              tst       psflg,u
                    beq       pent10
                    tst       offsopt,u
                    bne       pent05
                    ldd       paddress,u
                    std       address,u
                    bra       pent10
pent05              ldd       paddress,u
                    pshs      d
                    ldd       moduloc,u
                    addd      ,s++
                    std       address,u
                    bra       pent10
pent20              lbsr      ddentry
                    bra       pnoerr
pent10              tst       peflg,u
                    beq       pent20
                    tst       offsopt,u
                    bne       pent15
                    ldd       pendaddr,u
                    std       endaddr,u
                    bra       pent20
pent15              ldd       pendaddr,u
                    pshs      d
                    ldd       moduloc,u
                    addd      ,s++
                    std       endaddr,u
                    bra       pent20
syntax              leay      usemsg,pcr
syntax1             lbsr      echo
                    bra       pnoerr
syntaxa             leay      usemsg,pcr
                    lbsr      echo
                    leay      adrmsg,pcr
                    bra       syntax1
pexit               lda       #2
                    os9       f$perr
pnoerr              clrb
                    os9       f$exit
grp0                pshs      y
                    bsr       set
                    bsr       space2
g00                 bsr       dsign
g01                 puls      y
                    ldb       ,y+
                    lbsr      outhex1
                    lbra      next
grp20               bsr       sub20
g20                 bsr       space2
                    ldb       ,y+
                    sex
                    lbra      sbr
sub20               pshs      y
                    leay      table2,pcr
                    lda       #4
                    bsr       match
                    deca
                    bsr       put
                    puls      y
                    rts
grp70               andb      #$0F
                    pshs      y
                    bsr       set
                    bsr       space2
g70                 bsr       esign
g71                 puls      y
                    ldd       ,y++
                    bsr       outhex2
                    lbra      next
set                 leay      table1,pcr
                    lda       #4
                    bsr       match
                    deca
                    bsr       put
                    rts
match               cmpb      ,y
                    beq       itis
                    leay      a,y
                    bra       match
itis                leay      1,y
                    rts
space2              ldd       #$2020
                    std       ,x++
                    rts
space1              lda       #$20
                    sta       ,x+
                    rts
dsign               lda       #$3C
                    sta       ,x+
                    rts
esign               lda       #$3E
                    sta       ,x+
                    rts
minus               lda       #'-
                    sta       ,x+
                    rts
put                 ldb       ,y+
                    stb       ,x+
                    deca
                    bne       put
                    rts
coma                lda       #',
                    sta       ,x+
                    rts
outhex2             tst       offsflg,u
                    beq       outhex3
                    clr       offsflg,u
                    cmpd      moduloc,u
                    blo       outhex3
                    cmpd      endaddr,u
                    bhi       outhex3
                    subd      moduloc,u
outhex3             exg       a,b
                    bsr       outhex1
                    tfr       a,b
outhex1             pshs      b
                    andb      #$F0
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    bsr       v1
                    puls      b
                    andb      #$0F
v1                  cmpb      #9
                    bls       v2
                    addb      #7
v2                  addb      #$30
                    stb       ,x+
                    rts
grp60               andb      #$0F
                    pshs      y
                    lbsr      set
                    lbsr      space2
                    puls      y
                    ldb       ,y+
                    lbsr      index
                    lbra      next
grp10               pshs      y
                    cmpb      #$10
                    lbeq      s10
                    cmpb      #$12
                    lblo      s11
                    beq       grp12
                    cmpb      #$13
                    beq       grp13
                    cmpb      #$19
                    lblo      grpsb
                    beq       grp19
                    cmpb      #$1D
                    blo       grpccr
                    beq       grpsex
                    lda       #5
                    cmpb      #$1F
                    beq       grp1f
                    leay      rexg,pcr
n1e                 lbsr      put
                    puls      y
                    ldb       ,y+
                    pshs      y
                    pshs      b
                    andb      #$F0
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    bsr       readreg
                    lda       #',
                    sta       ,x+
                    puls      b
                    andb      #$0F
                    bsr       readreg
                    puls      y
                    lbra      next
grp1f               leay      rtfr,pcr
                    bra       n1e
readreg             tfr       x,y
                    leax      rbyte,pcr
loop2               cmpb      ,x
                    beq       gotit
                    leax      3,x
                    bra       loop2
gotit               ldb       1,x
                    tst       2,x
                    abx
                    bmi       get2
                    ldb       ,x
                    stb       ,y+
                    bra       rout
get2                ldd       ,x
                    std       ,y++
rout                tfr       y,x
                    rts
grp12               leay      rnop,pcr
                    bra       out10a
grp13               leay      rsync,pcr
                    lda       #4
                    bra       out10b
grp19               leay      rdaa,pcr
                    bra       out10a
grpsex              leay      rsex,pcr
out10a              lda       #3
out10b              lbsr      put
                    puls      y
                    lbra      next
grpccr              cmpb      #$1A
                    bne       grp1c
                    leay      rorcc,pcr
outccr              lda       #7
                    lbsr      put
                    lbra      g01
grp1c               leay      randcc,pcr
                    bra       outccr
grpsb               cmpb      #$16
                    bne       grp17
                    leay      rlbra,pcr
sbout               lda       #5
                    lbsr      put
lbr                 puls      y
                    ldd       ,y++
sbr                 pshs      y
                    addd      ,s
                    std       branchad,u
                    tst       offsopt,u
                    beq       srb2
                    lbsr      setoffs
srb2                lbsr      outhex2
                    puls      y
                    lbra      next
grp17               leay      rlbsr,pcr
                    bra       sbout
grp30               pshs      y
                    cmpb      #$38
                    bhi       rest30
                    cmpb      #$34
                    lblo      lea30
                    tfr       b,a
                    lsrb
                    bcc       push
                    leay      pull,pcr
                    bsr       puss
                    puls      y
                    ldb       ,y+
                    pshs      y
                    leay      order2,pcr
                    lda       #8
loop3               lsrb
                    bsr       tstbit
                    deca
                    bne       loop3
                    bra       out30
push                leay      pshr,pcr
                    bsr       puss
                    puls      y
                    ldb       ,y+
                    pshs      y
                    leay      order1,pcr
                    lda       #8
loop4               lslb
                    bsr       tstbit
                    deca
                    bne       loop4
                    bra       out30
tstbit              bcs       tst30
                    leay      2,y
                    rts
tst30               pshs      d
                    ldd       ,y++
                    tsta
                    bmi       clrp
                    std       ,x++
sep                 lda       #',
                    sta       ,x+
                    puls      d
                    rts
clrp                stb       ,x+
                    bra       sep
puss                pshs      a
                    lda       #3
                    lbsr      put
                    puls      b
                    bsr       usreg
                    rts
usreg               andb      #$02
                    bne       rureg
                    lda       #'s
pit                 sta       ,x+
                    lda       #$20
                    sta       ,x+
                    rts
rureg               lda       #'u
                    bra       pit
out30               puls      y
                    leax      -1,x
                    lbra      next
rest30              cmpb      #$3C
                    beq       ccwait
                    leay      table3,pcr
                    lda       #4
                    lbsr      match
                    deca
                    lbsr      put
                    puls      y
                    lbra      next
ccwait              leay      rccwai,pcr
                    lda       #6
                    lbsr      put
                    lbra      g01
lea30               leay      rlea,pcr
                    lda       #3
                    pshs      b
                    lbsr      put
                    puls      a
                    clrb
                    anda      #$0F
                    pshs      a
loop5               cmpb      ,s
                    beq       dpit
                    incb
                    bra       loop5
dpit                pshs      x
                    leax      lregr,pcr
                    abx
                    lda       ,x
                    puls      x
                    sta       ,x+
                    lbsr      space1
                    puls      a
dpit1               puls      y
                    ldb       ,y+
                    bsr       index
                    lbra      next
index               pshs      b
                    tstb
                    bmi       not5
bit5                bitb      #$10
                    beq       posi
                    orb       #$F0
                    negb
                    lbsr      minus
b5out               lbsr      outhex1
                    lbsr      coma
                    puls      b
                    bsr       rr
                    rts
posi                andb      #$0F
                    bra       b5out
not5                aslb
                    aslb
                    aslb
                    aslb
                    lbcs      indirect
                    beq       rplus1
                    bmi       first
                    aslb
                    bmi       second
                    aslb
                    bmi       third
                    bra       rplus2
first               aslb
                    lbeq      bit8r
                    bmi       rpcrl
                    aslb
                    lbmi      dr
                    aslb
                    lbmi      bit16r
                    lbra      rqq
second              aslb
                    bmi       ar
                    beq       zoro
                    aslb
                    bmi       br
                    lbra      rqq
third               aslb
                    bmi       minus2
                    beq       minus1
                    lbra      rqq
rpcrl               aslb
                    lbeq      bit8pr
                    lbra      bit16p
rr                  pshs      b
                    andb      #$60
                    beq       xregr
                    cmpb      #$20
                    beq       yregr
                    cmpb      #$40
                    beq       uregr
                    cmpb      #$60
                    beq       sregr
                    lbra      rqq
xregr               lda       #'x
                    bra       store
yregr               lda       #'y
                    bra       store
uregr               lda       #'u
                    bra       store
sregr               lda       #'s
store               sta       ,x+
                    puls      b
                    rts
rplus1              puls      b
                    bsr       rplus3
                    lda       #'+
                    sta       ,x+
                    rts
rplus2              puls      b
                    bsr       rplus3
                    ldd       #$2B2B
                    std       ,x++
                    rts
rplus3              lbsr      coma
                    bsr       rr
                    rts
minus1              lbsr      coma
                    lda       #'-
                    sta       ,x+
                    puls      b
                    bra       rr
minus2              lbsr      coma
                    ldd       #$2D2D
                    std       ,x++
                    puls      b
                    bra       rr
zoro                puls      b
                    bra       rplus3
ar                  lda       #'a
                    bra       abd
br                  lda       #'b
                    bra       abd
dr                  lda       #'d
abd                 sta       ,x+
                    puls      b
                    bra       rplus3
bit8r               ldb       ,y+
                    tstb
                    bpl       plus8
                    negb
                    lbsr      minus
plus8               lbsr      outhex1
                    puls      b
                    bra       rplus3
bit16r              ldd       ,y++
                    tsta
                    bpl       plus16
                    coma
                    comb
                    addd      #1
                    pshs      a
                    lbsr      minus
                    puls      a
plus16              lbsr      outhex2
                    puls      b
                    bra       rplus3
bit8pr              ldb       ,y+
                    sex
                    pshs      y
                    addd      ,s
                    tst       offsopt,u
                    beq       bit8pr2
                    lbsr      setoffs
bit8pr2             lbsr      outhex2
pcrn                lbsr      coma
                    leay      rpcr,pcr
                    lda       #3
                    lbsr      put
                    puls      y
                    puls      b
                    rts
bit16p              ldd       ,y++
                    pshs      y
                    addd      ,s
                    tst       offsopt,u
                    beq       bit16p2
                    lbsr      setoffs
bit16p2             lbsr      outhex2
                    bra       pcrn
indirect            puls      b
                    lda       #$5B
                    sta       ,x+
                    cmpb      #$9F
                    beq       exdirect
                    andb      #$EF
                    lbsr      index
indirout            lda       #$5D
                    sta       ,x+
                    rts
exdirect            ldd       ,y++
                    lbsr      outhex2
                    bra       indirout
rqq                 ldd       #$3F3F
                    std       ,x++
                    puls      b
                    rts
s10                 puls      y
                    ldb       ,y+
                    pshs      y
                    cmpb      #$30
                    blo       cbr
                    cmpb      #$3F
                    beq       os9
                    bhi       srest
x10                 puls      y
                    ldd       #$3F3F
                    std       ,x++
                    lbra      next
cbr                 cmpb      #$20
                    blo       x10
                    lda       #'l
                    sta       ,x+
                    lbsr      sub20
                    lbsr      space1
                    lbra      lbr
os9                 puls      y
                    ldb       ,y+
                    pshs      y
                    pshs      b
                    leay      ros9,pcr
                    lda       #5
                    lbsr      put
                    leay      os9table,pcr
                    puls      b
os9loop             cmpb      ,y+
                    bne       os9next
                    lda       ,y+
                    lbsr      put
os9out              puls      y
                    lbra      next
os9next             pshs      b
                    ldb       ,y+
                    exg       x,y
                    abx
                    exg       x,y
                    puls      b
                    cmpy      ros9end,pcr
                    beq       os9out
                    bra       os9loop
srest               tfr       b,a
                    rolb
                    bmi       overc
                    pshs      b
                    tfr       a,b
                    leay      tab1,pcr
enter11             lda       #6
solve               andb      #$0F
                    lbsr      match
                    deca
                    lbsr      put
                    puls      b
                    rolb
                    bmi       next10
                    rolb
                    lbmi      g00
                    lda       #'#
                    sta       ,x+
                    lbra      g71
next10              rolb
                    lbmi      g70
                    lbra      dpit1
overc               pshs      b
                    tfr       a,b
                    leay      tab2,pcr
                    bra       enter11
s11                 puls      y
                    ldb       ,y+
                    pshs      y
                    cmpb      #$3F
                    lblo      x10
                    bhi       rest11
                    leay      rswi3,pcr
                    lda       #4
                    lbsr      put
                    puls      y
                    lbra      next
rest11              tfr       b,a
                    rolb
                    pshs      b
                    tfr       a,b
                    leay      tab11,pcr
                    bra       enter11
grp80               pshs      y
                    pshs      b
                    tfr       b,a
                    andb      #$F0
                    lslb
                    beq       check1
                    lslb
                    beq       check2
rein80              puls      b
                    tfr       b,a
                    rolb
                    bmi       over8
                    leay      tab80a,pcr
mm80                pshs      b
                    tfr       a,b
                    bra       enter11
over8               leay      tab80b,pcr
                    bra       mm80
check1              cmpa      #$8D
                    beq       rbr
                    leay      tab80a,pcr
check               anda      #$0F
                    cmpa      #$0C
                    bhs       rein80
                    cmpa      #$03
                    beq       rein80
                    tfr       a,b
                    lda       #6
                    lbsr      match
                    deca
                    lbsr      put
                    lda       #'#
                    sta       ,x+
                    puls      b
                    lbra      g01
check2              leay      tab80b,pcr
                    bra       check
rbr                 puls      b
                    leay      rbsr,pcr
                    lda       #3
                    lbsr      put
                    puls      y
                    lbra      g20
rexg                fcc       /exg  /
rtfr                fcc       /tfr  /
rbyte               fcb       0,30,0,1,28,0,2,26,0,3,24,0,4,22,0,5,20,128
                    fcb       8,19,0,9,17,0,10,15,128,11,14,128
                    fcc       /dxyusppcabccdp/
rccwai              fcc       /cwai #/
rlea                fcc       /lea/
lregr               fcc       /xysu/
rpcr                fcc       /pcr/
rnop                fcc       /nop/
rsync               fcc       /sync/
rdaa                fcc       /daa/
rsex                fcc       /sex/
rorcc               fcc       /orcc  #/
randcc              fcc       /andcc #/
rlbra               fcc       /lbra /
rlbsr               fcc       /lbsr /
pull                fcc       /pul/
pshr                fcc       /psh/
order1              fcb       112,99,128,117,128,121,128,120,100,112,128,98,128,97,99,99
order2              fcb       99,99,128,97,128,98,100,112,128,120,128,121,128,117,112,99
table3              fcb       $39
                    fcc       /rts/
                    fcb       $3a
                    fcc       /abx/
                    fcb       $3b
                    fcc       /rti/
                    fcb       $3d
                    fcc       /mul/
                    fcb       $3f
                    fcc       /swi/
rbsr                fcc       /bsr/
table1              fcb       $0
                    fcc       /neg/
                    fcb       $01
                    fcc       /?? /
                    fcb       $02
                    fcc       /?? /
                    fcb       $03
                    fcc       /com/
                    fcb       $04
                    fcc       /lsr/
                    fcb       $05
                    fcc       /?? /
                    fcb       $06
                    fcc       /ror/
                    fcb       $07
                    fcc       /asr/
                    fcb       $08
                    fcc       /asl/
                    fcb       $09
                    fcc       /rol/
                    fcb       lf
                    fcc       /dec/
                    fcb       $0b
                    fcc       /?? /
                    fcb       $0c
                    fcc       /inc/
                    fcb       cr
                    fcc       /tst/
                    fcb       $0e
                    fcc       /jmp/
                    fcb       $0f
                    fcc       /clr/
table2              fcb       $20
                    fcc       /bra/
                    fcb       $21
                    fcc       /brn/
                    fcb       $22
                    fcc       /bhi/
                    fcb       $23
                    fcc       /bls/
                    fcb       $24
                    fcc       /bcc/
                    fcb       $25
                    fcc       /bcs/
                    fcb       $26
                    fcc       /bne/
                    fcb       $27
                    fcc       /beq/
                    fcb       $28
                    fcc       /bvc/
                    fcb       $29
                    fcc       /bvs/
                    fcb       $2a
                    fcc       /bpl/
                    fcb       $2b
                    fcc       /bmi/
                    fcb       $2c
                    fcc       /bge/
                    fcb       $2d
                    fcc       /blt/
                    fcb       $2e
                    fcc       /bgt/
                    fcb       $2f
                    fcc       /ble/
tab1                fcb       $03
                    fcc       /cmpd /
                    fcb       $0c
                    fcc       /cmpy /
                    fcb       $0e
                    fcc       /ldy  /
                    fcb       $0f
                    fcc       /sty  /
tab2                fcb       $0e
                    fcc       /lds  /
                    fcb       $0f
                    fcc       /sts  /
tab11               fcb       $03
                    fcc       /cmpu /
                    fcb       $0c
                    fcc       /cmps /
tab80a              fcb       $00
                    fcc       /suba /
                    fcb       $01
                    fcc       /cmpa /
                    fcb       $02
                    fcc       /sbca /
                    fcb       $03
                    fcc       /subd /
                    fcb       $04
                    fcc       /anda /
                    fcb       $05
                    fcc       /bita /
                    fcb       $06
                    fcc       /lda  /
                    fcb       $07
                    fcc       /sta  /
                    fcb       $08
                    fcc       /eora /
                    fcb       $09
                    fcc       /adca /
                    fcb       lf
                    fcc       /ora  /
                    fcb       $0b
                    fcc       /adda /
                    fcb       $0c
                    fcc       /cmpx /
                    fcb       cr
                    fcc       /jsr  /
                    fcb       $0e
                    fcc       /ldx  /
                    fcb       $0f
                    fcc       /stx  /
tab80b              fcb       $00
                    fcc       /subb /
                    fcb       $01
                    fcc       /cmpb /
                    fcb       $02
                    fcc       /sbcb /
                    fcb       $03
                    fcc       /addd /
                    fcb       $04
                    fcc       /andb /
                    fcb       $05
                    fcc       /bitb /
                    fcb       $06
                    fcc       /ldb  /
                    fcb       $07
                    fcc       /stb  /
                    fcb       $08
                    fcc       /eorb /
                    fcb       $09
                    fcc       /adcb /
                    fcb       lf
                    fcc       /orb  /
                    fcb       $0b
                    fcc       /addb /
                    fcb       $0c
                    fcc       /ldd  /
                    fcb       cr
                    fcc       /std  /
                    fcb       $0e
                    fcc       /ldu  /
                    fcb       $0f
                    fcc       /stu  /
rswi3               fcc       /swi3/
rshell              fcc       /shell/
                    fcb       cr
ros9                fcc       /os9  /
os9table            fcb       $0,6
                    fcc       /F$Link/
                    fcb       $01,6
                    fcc       /F$Load/
                    fcb       $02,8
                    fcc       /F$UnLink/
                    fcb       $03,6
                    fcc       /F$Fork/
                    fcb       $04,6
                    fcc       /F$Wait/
                    fcb       $05,7
                    fcc       /F$Chain/
                    fcb       $06,6
                    fcc       /F$Exit/
                    fcb       $07,5
                    fcc       /F$Mem/
                    fcb       $08,6
                    fcc       /F$Send/
                    fcb       $09,6
                    fcc       /F$Icpt/
                    fcb       lf,7
                    fcc       /F$Sleep/
                    fcb       $0C,4
                    fcc       /F$ID/
                    fcb       cr,8
                    fcc       /F$SPrior/
                    fcb       $0E,6
                    fcc       /F$SSWI/
                    fcb       $0F,6
                    fcc       /F$Perr/
                    fcb       $10,8
                    fcc       /F$PrsNam/
                    fcb       $11,8
                    fcc       /F$CmpNam/
                    fcb       $12,8
                    fcc       /F$SchBit/
                    fcb       $13,8
                    fcc       /F$AllBit/
                    fcb       $14,8
                    fcc       /F$DelBit/
                    fcb       $15,6
                    fcc       /F$Time/
                    fcb       $16,7
                    fcc       /F$STime/
                    fcb       $17,5
                    fcc       /F$CRC/
                    fcb       $18,8
                    fcc       /F$GPrDsc/
                    fcb       $19,8
                    fcc       /F$GBlkMp/
                    fcb       $1A,8
                    fcc       /F$GModDr/
                    fcb       $1B,8
                    fcc       /F$CpyMem/
                    fcb       $1C,7
                    fcc       /F$SUser/
                    fcb       $1D,8
                    fcc       /F$UnLoad/
                    fcb       $1E,7
                    fcc       /F$Alarm/
                    fcb       $21,8
                    fcc       /F$NMLink/
                    fcb       $22,8
                    fcc       /F$NMLoad/
                    fcb       $27,6
                    fcc       /F$VIRQ/
                    fcb       $28,8
                    fcc       /F$SRqMem/
                    fcb       $29,8
                    fcc       /F$SRtMem/
                    fcb       $2A,5
                    fcc       /F$IRQ/
                    fcb       $2B,6
                    fcc       /F$IOQu/
                    fcb       $2C,7
                    fcc       /F$AProc/
                    fcb       $2D,7
                    fcc       /F$NProc/
                    fcb       $2E,8
                    fcc       /F$VModul/
                    fcb       $2F,8
                    fcc       /F$Find64/
                    fcb       $30,7
                    fcc       /F$All64/
                    fcb       $31,7
                    fcc       /F$Ret64/
                    fcb       $32,6
                    fcc       /F$SSvc/
                    fcb       $33,7
                    fcc       /F$IODel/
                    fcb       $34,7
                    fcc       /F$SLink/
                    fcb       $35,6
                    fcc       /F$Boot/
                    fcb       $36,7
                    fcc       /F$BtMem/
                    fcb       $37,8
                    fcc       /F$GProcP/
                    fcb       $38,6
                    fcc       /F$Move/
                    fcb       $39,8
                    fcc       /F$AllRAM/
                    fcb       $3A,8
                    fcc       /F$AllImg/
                    fcb       $3B,8
                    fcc       /F$DelImg/
                    fcb       $3C,8
                    fcc       /F$SetImg/
                    fcb       $3D,8
                    fcc       /F$FreeLB/
                    fcb       $3E,8
                    fcc       /F$FreeHB/
                    fcb       $3F,8
                    fcc       /F$AllTsk/
                    fcb       $40,8
                    fcc       /F$DelTsk/
                    fcb       $41,8
                    fcc       /F$SetTsk/
                    fcb       $42,8
                    fcc       /F$ResTsk/
                    fcb       $43,8
                    fcc       /F$RelTsk/
                    fcb       $44,8
                    fcc       /F$DATLog/
                    fcb       $46,7
                    fcc       /F$LDAXY/
                    fcb       $48,8
                    fcc       /F$LDDDXY/
                    fcb       $49,7
                    fcc       /F$LDABX/
                    fcb       $4A,7
                    fcc       /F$STABX/
                    fcb       $4B,8
                    fcc       /F$AllPrc/
                    fcb       $4C,8
                    fcc       /F$DelPrc/
                    fcb       $4D,7
                    fcc       /F$ELink/
                    fcb       $4E,8
                    fcc       /F$FModul/
                    fcb       $4F,8
                    fcc       /F$MapBlk/
                    fcb       $50,8
                    fcc       /F$ClrBlk/
                    fcb       $51,8
                    fcc       /F$DelRAM/
                    fcb       $52,8
                    fcc       /F$GCMDir/
                    fcb       $53,8
                    fcc       /F$AlHRam/
                    fcb       $80,8
                    fcc       /I$Attach/
                    fcb       $81,8
                    fcc       /I$Detach/
                    fcb       $82,5
                    fcc       /I$Dup/
                    fcb       $83,8
                    fcc       /I$Create/
                    fcb       $84,6
                    fcc       /I$Open/
                    fcb       $85,8
                    fcc       /I$MakDir/
                    fcb       $86,8
                    fcc       /I$Chgdir/
                    fcb       $87,8
                    fcc       /I$Delete/
                    fcb       $88,6
                    fcc       /I$Seek/
                    fcb       $89,6
                    fcc       /I$Read/
                    fcb       $8A,7
                    fcc       /I$Write/
                    fcb       $8B,8
                    fcc       /I$ReadLn/
                    fcb       $8C,8
                    fcc       /I$WritLn/
                    fcb       $8D,8
                    fcc       /I$GetStt/
                    fcb       $8E,8
                    fcc       /I$SetStt/
                    fcb       $8F,7
                    fcc       /I$Close/
                    fcb       $90,8
                    fcc       /I$DeletX/
                    fcb       0,0
ros9end             equ       *
copyr               fcb       $0C
                    fcb       7
                    fcc       "DASM (C) 1992"
                    fcb       lf
                    fcc       "J.R.COLLYER"
                    fcb       lf
                    fcb       cr
                    fcb       0
prompt              fcc       "dasm: "
                    fcb       0
whatmsg             fcc       "WHAT ??"
                    fcb       cr
                    fcb       0
adrmsg              fcc       "USE: [HEX DIGITS]"
                    fcb       cr
                    fcb       0
jumpmsg             fcc       "START ADDRESS ? "
                    fcb       0
ulinkmsg            fcc       "UNLINKED MODULE COUNT"
                    fcb       cr
                    fcb       0
notlkmsg            fcc       "MODULE LINK COUNT IS ZERO"
                    fcb       cr
                    fcb       0
linkmsg             fcc       "LINK ? "
                    fcb       0
dasmmsg             fcs       "dasm"
                    fcb       0
shellmsg            fcc       "SHELL ? "
                    fcb       0
getmode             fcc       "AUTO ? "
                    fcb       0
modemsg1            fcc       "AUTO ON"
                    fcb       cr
                    fcb       0
modemsg2            fcc       "AUTO OFF"
                    fcb       cr
                    fcb       0
prtermsg            fcc       "PRINTER ? "
                    fcb       0
prtmsg              fcc       "PRINTER  ON"
                    fcb       cr
                    fcb       0
scrmsg              fcc       "PRINTER  OFF"
                    fcb       cr
                    fcb       0
buffmsg             fcc       "BUFFER ? "
                    fcb       0
buff1               fcc       "BUFFER OFF"
                    fcb       cr
                    fcb       0
buff2               fcc       "BUFFER ON"
                    fcb       cr
                    fcb       0
bfull               fcc       "BUFFER FULL"
                    fcb       cr
                    fcb       0
stackms1            fcc       "ADDRESS STACK IS FULL"
                    fcb       cr
                    fcb       0
stackms2            fcc       "ADDRESS STACK IS EMPTY"
                    fcb       cr
                    fcb       0
helpmsg             fcc       "USE: ARROW KEYS  $ ? A B E G L M O P Q R S U W"
                    fcb       cr
                    fcb       0
fname               fcc       "FILENAME ? "
                    fcb       0
endadmsg            fcc       "END ADDRESS ? "
                    fcb       0
gimimsg             fcc       "GIMI ? "
                    fcb       0
gimimsg1            fcc       "EXAMPLE: 3F,3E,3D [ENTER]"
                    fcb       cr
                    fcb       0
gimimsg2            fcc       "EXAMPLE: FF FE FD [ENTER]"
                    fcb       cr
                    fcb       0
offsmsg             fcc       "OFFSETS ? "
                    fcb       0
offsmsg1            fcc       "OFFSETS ON"
                    fcb       cr
                    fcb       0
offsmsg2            fcc       "OFFSETS OFF"
                    fcb       cr
                    fcb       0
exitmsg             fcc       "QUIT ARE YOU SURE (y/n) ? "
                    fcb       0
pmsg                fcc       "/p"
usemsg              fcb       7
                    fcb       lf
                    fcc       "*************************"
                    fcb       lf
                    fcc       "** OS9 DASM"
                    fcb       lf
                    fcc       "** (C)1992 J.R.COLLYER"
                    fcb       lf
                    fcc       "** usage: dasm <opts> [path] [module]"
                    fcb       lf
                    fcc       "** opts:     -o  use offset addresses"
                    fcb       lf
                    fcc       "**           -s  start address"
                    fcb       lf
                    fcc       "**           -e  end address"
                    fcb       lf
                    fcc       "**           -m  use hard addresses"
                    fcb       lf
                    fcc       "**           -l  link os9 module"
                    fcb       lf
                    fcc       "**           -r  read os9 module"
                    fcb       lf
                    fcc       "**           [ENTER] Interactive mode"
                    fcb       lf
                    fcb       cr
                    fcb       0
commands            fcb       00
                    fdb       0000
                    fcb       $08                 left arrow
                    fdb       return-begin
                    fcb       $09                 right arrow
                    fdb       branch-begin
                    fcb       lf                  down arrow
                    fdb       dentry-begin
                    fcb       $0C                 up arrow
                    fdb       back-begin
                    fcb       $24                 shell command
                    fdb       shell-begin
                    fcb       $3F                 help  command
                    fdb       help-begin
                    fcb       $41                 ASCII command
                    fdb       ascii-begin
                    fcb       $42                 buffer command
                    fdb       bcom-begin
                    fcb       $45                 end address for auto mode
                    fdb       chngend-begin
                    fcb       $47                 gimi
                    fdb       gimicom-begin
                    fcb       $4C                 link  command
                    fdb       link-begin
                    fcb       $4D                 mode  command
                    fdb       setmode-begin
                    fcb       $4F                 offsets
                    fdb       offscom-begin
                    fcb       $50                 printer command
                    fdb       printer-begin
                    fcb       $51                 quit command
                    fdb       quit-begin
                    fcb       $52                 read disk file command
                    fdb       read-begin
                    fcb       $53                 start address
                    fdb       jump-begin
                    fcb       $55                 unlink command
                    fdb       unlink-begin
                    fcb       $57                 disk write
                    fdb       write-begin
                    fcb       0
                    emod
len                 equ       *
                    end
