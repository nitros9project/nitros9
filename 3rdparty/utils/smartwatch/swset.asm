********************************************************************
* SWSet - Set time in SmartWatch
*
* $Id$
*
* Copyright May, 1990 by Robert Gault
*
* SWSET will set the smartwatch in either 12hr or 24hr mode
* time will be sent to OS-9 in 24hr mode for compatability
* see new DATE which presents time in 12hr. mode with day of week
* and SWREAD which sends data from clock to OS-9
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
* 1      Revised: clock disable; no relocation          RG  95/07/04
*        Revised to accommodate Level1 & Level2 so      RG  04/07/28
*        relocation of code brought back.

                    nam       SWSet
                    ttl       Set time in SmartWatch

                    ifp1
                    use       defsfile
                    endc

type                set       prgrm+objct
revs                set       reent+1
edition             set       1

                    mod       pgrmend,name,type,revs,start,size


locblk0             rmb       2                   pointer to block 0
locblk3E            rmb       2                   pointer to block $3E ie. disk ROM
temp1               rmb       1
temp2               rmb       1
clkbyte             rmb       1
clkflag             rmb       1
mpiimage            rmb       1
alrtimag            rmb       8                   storage for the alert code with following:
csec                rmb       1
sec                 rmb       1
min                 rmb       1
hour                rmb       1
daywk               rmb       1
daymn               rmb       1
month               rmb       1
year                rmb       1
stopbyte            rmb       1
rawdata             rmb       18
relocimg            rmb       300
stack               rmb       200
size                equ       .

rom                 equ       $FFDE
ram                 equ       $FFDF
cartI               equ       $FF22
skp1                equ       $21
skp2                equ       $8C                 code for cmpx #nn

name                fcs       /SWSet/
                    fcb       edition

clknfnd             fcb       C$LF
                    fcc       /no clock found/
                    fcb       C$LF
                    fcc       /I'm running Setime/
                    fcb       C$CR
setime              fcc       /setime/
                    fcb       C$CR
swread              fcc       /swread/
                    fcb       C$CR

query               lda       #1
                    os9       I$Writln
                    clra                          path 0
                    leax      temp1,u             storage
                    ldy       #1
                    os9       I$Read
                    lda       temp1               get key
                    rts

noroom              lda       #2
                    leax      mesroom,pcr
                    ldy       #50
                    os9       I$WritLn
                    clrb
                    os9       F$Exit

start               leax      alrtimag,u          point to image of alert code
                    ldb       #8
                    leay      alert,pcr
s1loop              lda       ,y+                 transfer to data
                    sta       ,x+
                    decb
                    bne       s1loop
                    ldb       #8
s2loop              clr       ,x+                 clear out the time date data
                    decb
                    bne       s2loop
                    dec       ,x                  mark stop byte
                    lda       MPI.Slct
                    anda      #3                  keep IRQ
                    ora       #$30                start with slot 4
                    sta       mpiimage            save setting
                    lda       #1
                    leax      crmesage,pcr        copyright message
                    ldy       #mesage1-crmesage
                    os9       I$WritLn
getfunc             leax      mesage1,pcr         select	time or disable clock
                    ldy       #mesage2-mesage1
                    bsr       query
                    anda      #$DF
                    cmpa      #'D                 disable
                    lbeq      killit
                    cmpa      #'T                 timer
                    lbeq      doit
                    cmpa      #'C                 clock
                    bne       getfunc
getday              leax      mesage2,pcr
                    ldy       #mesage3-mesage2    get day of week
                    bsr       query
                    suba      #'0
                    blo       getday
                    cmpa      #7
                    bhi       getday
                    sta       daywk               convert from ascii to number
tmode               leax      mesage3,pcr         12	or 24 hour time
                    ldy       #mesage4-mesage3
                    lbsr      query
                    cmpa      #'1                 error trap
                    blo       tmode
                    cmpa      #'2
                    bhi       tmode
                    beq       date
                    lda       #%10000000          12 hr bit
                    sta       hour
getAMPM             leax      mesage4,pcr
                    ldy       #mesage5-mesage4
                    lbsr      query
                    clrb
                    anda      #$df
                    cmpa      #'A
                    beq       AMPMcode
                    cmpa      #'P
                    bne       getAMPM
                    ldb       #%100000            PM bit
AMPMcode            orb       hour
                    stb       hour
date                leax      mesage5,pcr         get date and time
                    lda       #1
                    ldy       #endmes-mesage5
                    os9       I$Writln
                    clra
                    leax      rawdata,u
                    ldy       #18
                    os9       I$ReadLn
                    leax      rawdata,u
                    clr       temp1
                    bsr       ascbcd
                    stb       year
                    bsr       ascbcd
                    stb       month
                    bsr       ascbcd
                    stb       daymn
                    bsr       ascbcd
                    tst       hour
                    beq       sthour
                    cmpb      #$12                max in 12 hour mode
                    bhi       date
                    orb       hour
sthour              stb       hour
                    bsr       ascbcd
                    stb       min
                    bsr       ascbcd
                    stb       sec
                    bra       doit

ascbcd              clr       temp2
                    bsr       data1
                    bne       noinfo
                    com       temp2
                    tfr       a,b
                    bsr       data1
                    bne       endasc
                    lslb
                    lslb
                    lslb
                    lslb
                    pshs      a
                    addb      ,s+
*        inca
endasc              rts
noinfo              leas      2,s
                    bra       doit

data1               lda       ,x+
                    beq       nomore
                    cmpa      #C$CR
                    beq       nomore
                    cmpa      #C$SPAC
                    beq       data2
                    cmpa      #'/
                    beq       data2
                    cmpa      #':
                    beq       data2
                    suba      #'0
                    bcs       error
                    cmpa      #9
                    bhi       error
                    orcc      #Zero
                    rts
data2               tst       temp2
                    beq       data1
                    rts
nomore              com       temp1
                    rts
error               leas      4,s
                    lbra      date

doit                equ       *
                    ifgt      Level-1
                    pshs      u
                    ldb       #1
                    ldx       #$3E                disk rom
                    os9       f$mapblk
                    bcs       exit2
                    stu       locblk3E
                    ldx       #0
                    os9       f$mapblk
                    bcs       exit2
                    leax      ,u
                    stx       locblk0
                    ldu       ,s
                    bsr       reloc
                    ldb       #1
                    ldu       locblk3E
                    os9       f$clrblk
                    ldb       #1
                    ldu       locblk0
                    os9       f$clrblk
                    puls      u
                    else
                    tfr       u,d                 look at the start of the program data page
                    cmpa      #$7E
                    lbhs      noroom
                    ldx       #RTC.Base
                    stx       locblk3E
                    ldx       #0
                    stx       locblk0
                    leax      reloc,pcr
                    pshs      u
                    leau      relocimg,u
                    ldy       #endrel-reloc
rl                  lda       ,x+
                    sta       ,u+
                    leay      -1,y
                    bne       rl
                    puls      u
                    jsr       relocimg,u
                    endc
                    tst       clkflag
                    bne       exit
                    lda       #2
                    leax      clknfnd,pcr
                    ldy       #40
                    os9       I$Writln
                    lda       #$11
                    ldb       #2
                    leax      setime,pcr
                    ldy       #0
                    leas      stack,u
                    leau      size,u
                    os9       F$Chain
exit                lda       #$11
                    ldb       #2
                    leax      swread,pcr
                    ldy       #0
                    leas      stack,u
                    leau      size,u
                    os9       F$Chain
exit2               leas      2,s
                    coma
                    os9       F$Exit

killit              lda       #C$SPAC
                    sta       daywk
                    bra       doit

* regX points to system DP, regU points to program DP
reloc               pshs      cc
                    ifgt      Level-1
                    lda       d.hinit,x           get $FF90 image
                    endc
                    ldb       MPI.Slct
                    pshs      d
                    ifgt      Level-1
                    anda      #$CC                external disk rom access
                    endc
                    orcc      #IntMasks
                    ifgt      Level-1
                    sta       $FF90               set for external ROM
                    endc
                    sta       rom
                    ldx       locblk3E
                    ldb       mpiimage            get new value
                    clr       clkflag

findclk             stb       MPI.Slct            set new slot
                    leay      alert,pcr
                    lda       4,x                 clear clock
                    clrb
                    bita      #1
                    beq       low
                    comb
low                 stb       clkbyte
                    bsr       nxtbyte
                    bsr       gettime
                    tst       clkflag
                    bne       found
                    ldb       mpiimage
                    bitb      #$30                test for last try
                    beq       found
                    subb      #$10                next slot
                    stb       mpiimage
                    lbra      findclk

nxtbyte             ldb       #8                  bits/byte
                    lda       ,y+
                    cmpa      #-1
                    bne       nxtbit
                    rts
nxtbit              lsra
                    bcs       high
                    cmpa      ,x                  talk to clock; faster than tst
                    fcb       skp2
high                cmpa      1,x
                    decb
                    bne       nxtbit
                    bra       nxtbyte

gettime             lda       #8                  bytes to read
                    pshs      a
timebyte            ldb       #8
timebit             lsr       4,x                 read clock
                    rora
                    decb
                    bne       timebit
                    cmpa      clkbyte
                    beq       maybe
                    inc       clkflag
maybe               dec       ,s
                    bne       timebyte
                    leas      1,s
                    rts

found               tst       clkflag
                    beq       noclk1
                    leay      alrtimag,u
                    lda       4,x
                    bsr       nxtbyte
noclk1              sta       ram
                    puls      d
                    stb       MPI.Slct
                    tst       cartI
                    sta       $ff90
                    puls      cc,pc

alert               fcb       $C5,$3A,$A3,$5C,$C5,$3A,$A3,$5C,$ff
endrel              equ       *

mesroom             fcb       C$LF
                    fcc       /Don't have relocation memory!/
                    fcb       C$CR
crmesage            fcb       C$LF
                    fcc       /Set Smartwatch/
                    fcb       C$LF
                    fcc       /(c) May, 1990 by Robert Gault/
                    fcb       C$LF
                    fcb       C$CR
mesage1             fcc       /Select clock, timer, or disable/
                    fcb       C$LF
                    fcc       /<C>lock; <T>imer; <D>isable ->/
mesage2             fcb       C$LF
                    fcc       /Enter the day 0-7; Mon=1 Sun=7/
                    fcb       C$LF
                    fcc       /day = ->?	/
mesage3             fcb       C$LF
                    fcc       /Select 12 or 24 hour clock/
                    fcb       C$LF
                    fcc       /<1> = 12; <2> = 24  ->/
mesage4             fcb       C$LF
                    fcc       /Select <A>M or <P>M ->/
mesage5             fcb       C$LF
                    fcc       /Enter as much of the date & time as desired/
                    fcb       C$LF
                    fcc       !yy/mm/dd hh:mm:ss!
                    fcb       C$LF
                    fcc       /->/
endmes              equ       *

                    emod
pgrmend             equ       *
                    end
