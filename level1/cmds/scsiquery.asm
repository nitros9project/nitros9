********************************************************************
* scsiquery - Get info on SCSI device through SS.DCmd call
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2008/01/21  Boisy G. Pitre
* Created while on the FPSO Kikeh in the South China Sea.

                    nam       scsiquery
                    ttl       Get info on SCSI device through the SS.DCmd call

                    ifp1
                    use       defsfile
                    use       scfdefs
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
code                rmb       1
lsn                 rmb       3
left                rmb       2
path                rmb       1
numbuf              rmb       16
txbuff              rmb       2048                to accomodate CD-ROM sector sizes
                    rmb       200
size                equ       .

StartM              fcc       /SCSI Inquiry Utility/
cr                  fcb       C$CR
VID                 fcc       /Vendor ID  : /
VIDL                equ       *-VID
PID                 fcc       /Product ID : /
PIDL                equ       *-PID
RLV                 fcc       /Revision   : /
RLVL                equ       *-RLV
LBA                 fcc       /Blocks     : /
LBAL                equ       *-LBA
BSZ                 fcc       /Block Size : /
BSZL                equ       *-BSZ

InquiryUnit         fcb       $12,$00,$00,$00,96,$00
ReadCapacity        fcb       $25,$00,$00,$00,$00,$00,$00,$00,$00,$00

name                fcs       /scsiquery/
                    fcb       edition

start
                    leay      txbuff,u
                    ldd       #$2060
l@                  sta       ,y+
                    decb
                    bne       l@
                    leay      txbuff,u

l@                  lda       ,x+
                    cmpa      #C$CR
                    beq       ok@
                    cmpa      #C$SPAC
                    beq       ok@
                    sta       ,y+
                    bra       l@
ok@                 ldd       #'@*256+C$CR
                    std       ,y
                    leax      txbuff,u

                    lda       #READ.
                    os9       I$Open
                    lbcs      exit
                    sta       path,u

                    leax      StartM,pcr
                    lda       #1
                    ldy       #100
                    os9       I$WritLn

* Do INQUIRY
                    leax      txbuff,u
                    leay      InquiryUnit,pcr
                    lda       path,u
                    ldb       #SS.DCmd
                    os9       I$SetStt
                    lbcs      exit

* Show Vendor ID
                    leax      VID,pcr
                    ldy       #VIDL
                    lda       #1
                    os9       I$WritLn

                    leax      txbuff+8,u
                    ldy       #15-8+1
                    lda       #1
                    os9       I$Write
                    leax      cr,pcr
                    ldy       #1
                    os9       I$WritLn

* Show Product ID
                    leax      PID,pcr
                    ldy       #PIDL
                    lda       #1
                    os9       I$WritLn

                    leax      txbuff+16,u
                    ldy       #31-16+1
                    lda       #1
                    os9       I$Write
                    leax      cr,pcr
                    ldy       #1
                    os9       I$WritLn

* Show Revision Level
                    leax      RLV,pcr
                    ldy       #RLVL
                    lda       #1
                    os9       I$WritLn

                    leax      txbuff+32,u
                    ldy       #35-32+1
                    lda       #1
                    os9       I$Write
                    leax      cr,pcr
                    ldy       #1
                    os9       I$WritLn

* Do READ CAPACITY
                    leax      txbuff,u
                    leay      ReadCapacity,pcr
                    lda       path,u
                    ldb       #SS.DCmd
                    os9       I$SetStt
                    bcs       exit

* Show Number of Blocks
                    leax      LBA,pcr
                    ldy       #LBAL
                    lda       #1
                    os9       I$WritLn

                    leax      txbuff,u
                    leay      numbuf,u
                    bsr       itoa
                    lda       #1
                    os9       I$Write

                    leax      cr,pcr
                    ldy       #1
                    os9       I$WritLn

* Show Block Size
                    leax      BSZ,pcr
                    ldy       #BSZL
                    lda       #1
                    os9       I$WritLn

                    leax      txbuff+4,u
                    leay      numbuf,u
                    bsr       itoa
                    lda       #1
                    os9       I$Write

                    leax      cr,pcr
                    ldy       #1
                    os9       I$WritLn

exitok              clrb
exit                os9       F$Exit

* Entry:
* X = address of 32 bit value
* Y = address of buffer to hold number
* Exit:
* X = address of buffer holding number
* Y = length of number string in bytes
itoa                pshs      u,y
                    tfr       y,u
                    ldb       #10                 max number of numbers (10^9)
                    pshs      b                   save count on stack
                    leay      Base,pcr            point to base of numbers
s@                  lda       #$30                put #'0
                    sta       ,u                  at U
s1@                 bsr       Sub32               ,X=,X-,Y
                    inc       ,u
                    bcc       s1@                 if X>0, continue
                    bsr       Add32               add back in
                    dec       ,u+
                    dec       ,s                  decrement counter
                    beq       done@
                    lda       ,s
                    cmpa      #$09
                    beq       comma@
                    cmpa      #$06
                    beq       comma@
                    cmpa      #$03
                    bne       s2@
comma@              ldb       #',
                    stb       ,u+
s2@                 leay      4,y                 point to next
                    bra       s@
done@               leas      1,s
* 1,234,567,890
                    ldb       #14                 length of string with commas + 1
                    ldx       ,s++                get pointer to buffer
a@                  decb
                    beq       ex@
                    lda       ,x+                 get byte
                    cmpa      #'0
                    beq       a@
                    cmpa      #',
                    beq       a@
                    clra
                    tfr       d,y                 transfer count into Y
v@                  leax      -1,x
                    puls      u,pc
ex@                 ldy       #0001
                    bra       v@

* Entry:
* X = address of 32 bit minuend
* Y = address of 32 bit subtrahend
* Exit:
* X = address of 32 bit difference
Sub32               ldd       2,x
                    subd      2,y
                    std       2,x
                    ldd       ,x
                    sbcb      1,y
                    sbca      ,y
                    std       ,x
                    rts


* Entry:
* X = address of 32 bit number
* Y = address of 32 bit number
* Exit:
* X = address of 32 bit sum
Add32               ldd       2,x
                    addd      2,y
                    std       2,x
                    ldd       ,x
                    adcb      1,y
                    adca      ,y
                    std       ,x
                    rts

Base                fcb       $3B,$9A,$CA,$00     1,000,000,000
                    fcb       $05,$F5,$E1,$00     100,000,000
                    fcb       $00,$98,$96,$80     10,000,000
                    fcb       $00,$0f,$42,$40     1,000,000
                    fcb       $00,$01,$86,$a0     100,000
                    fcb       $00,$00,$27,$10     10,000
                    fcb       $00,$00,$03,$e8     1,000
                    fcb       $00,$00,$00,$64     100
                    fcb       $00,$00,$00,$0a     10
                    fcb       $00,$00,$00,$01     1

                    emod
eom                 equ       *
                    end
