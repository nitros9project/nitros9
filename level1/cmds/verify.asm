********************************************************************
* Verify - Verify a module's CRC
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*   6      2003/01/18  Boisy G. Pitre
* Option modified to require dash in front.

                    nam       Verify
                    ttl       Verify a module's CRC

* Disassembled 98/09/15 00:03:43 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       6

                    mod       eom,name,tylg,atrv,start,size

                    org       0
crc1                rmb       1
crc2                rmb       1
crc3                rmb       1
readcnt             rmb       2
dovfy               rmb       1
bufptr              rmb       2
bufsiz              rmb       2
bytesrd             rmb       57
u0043               rmb       195
buffer              rmb       1000
size                equ       .

name                fcs       /Verify/
                    fcb       edition

start               leas      >buffer,u           point S to buffer
                    sts       <bufptr             save pointer to buffer
                    tfr       y,d                 transfer end of our mem to D
                    subd      <bufptr             subtract bufptr address
                    std       <bufsiz
                    clr       <dovfy
L0023               ldd       ,x+                 get two chars
                    cmpa      #C$SPAC             space?
                    beq       L0023               branch if so
                    andb      #$5F                make uppercase
                    cmpd      #$2D55              -U ?
                    bne       L0031
                    inc       <dovfy              we will do verify
L0031               ldd       #M$IDSize           get module id size
                    std       <readcnt            save read count
                    lbsr      DoRead
                    bcs       L004D
                    cmpy      #M$IDSize
                    bne       BadMod
                    ldd       ,x                  get first two bytes
                    cmpd      #M$ID12             OS-9 module sync bytes?
                    bne       BadMod              branch if not
                    bsr       DoCRCChk            check header parity
                    bra       L0031
L004D               cmpb      #E$EOF              end of file error?
                    bne       Exit                branch if not
                    clrb                          else clear carry
Exit                os9       F$Exit              and exit

BadMod              ldb       #E$BMID
                    bra       Exit

* Here is where we check the module
DoCRCChk            clrb
* First we will check the header parity
                    lda       #M$Parity
L005C               eorb      ,x+
                    deca
                    bne       L005C
                    lda       <dovfy              get verify flag
                    bne       UpdtHdrP            branch if we must do verify
                    eorb      ,x
                    incb
                    beq       L0070
                    leax      >HdrBad,pcr
                    bra       L0074
L0070               leax      >HdrGood,pcr
L0074               lbsr      WriteLn
                    bra       L007C
UpdtHdrP            comb
                    stb       ,x
L007C               ldx       <bufptr
                    ldy       $02,x
                    leay      -$03,y
                    sty       <readcnt
                    ldd       #$FFFF
                    std       <crc1
                    stb       <crc3
                    bsr       L00D6
                    lda       <dovfy
                    bne       UpdtCRC
                    ldd       #$0003
                    std       <readcnt
                    bsr       L00D6
                    lda       <crc1
                    cmpa      #CRCCon1
                    bne       L00A8
                    ldd       <crc2
                    cmpd      #CRCCon23
                    beq       L00AE
L00A8               leax      >CRCBad,pcr
                    bra       L00B2
L00AE               leax      >CRCGood,pcr
L00B2               bsr       WriteLn
                    bra       L00CF
UpdtCRC             com       <crc1
                    com       <crc2
                    com       <crc3
                    lda       #$01                to standard out
                    leax      ,u                  point to CRCs
                    ldy       #$0003              3 bytes
                    os9       I$Write             write it out
                    bcs       Exit                branch if error
                    clra
                    os9       I$Read
                    bcs       Exit
L00CF               rts
L00D0               bsr       DoRead
                    lbcs      Exit
L00D6               ldy       <bytesrd
                    beq       L00D0
                    os9       F$CRC
                    lda       <dovfy
                    beq       L00EB
                    lda       #$01                standard output
                    os9       I$Write             write it
                    lbcs      Exit                branch if error
L00EB               ldd       <readcnt
                    subd      <bytesrd
                    std       <readcnt
                    bne       L00D0
                    std       <bytesrd
                    rts

DoRead              clra
                    ldx       <bufptr             get buffer pointer
                    ldy       <bufsiz             get buffer size
                    cmpy      <readcnt            compare against read count
                    bls       ExecRead            if lower, use bufsiz
                    ldy       <readcnt            else read count
ExecRead            os9       I$Read              read data
                    sty       <bytesrd            save read count
                    rts

WriteLn             lda       #$02
                    ldy       #80
                    os9       I$WritLn
                    rts

HdrGood             fcc       "Header parity is correct."
                    fcb       C$CR

HdrBad              fcc       "Header parity is INCORRECT !"
                    fcb       C$CR

CRCGood             fcc       "CRC is correct."
                    fcb       C$CR

CRCBad              fcc       "CRC is INCORRECT !"
                    fcb       C$CR

                    emod
eom                 equ       *
                    end
