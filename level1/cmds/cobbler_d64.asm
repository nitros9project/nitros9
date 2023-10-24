********************************************************************
* Cobbler - Make a bootstrap file
*
* $Id$
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*   5    From Dragon OS-9 Level One VR 01.02.00
*   6    New cobbler saves from address $EF00 instead of $F000

                    nam       Cobbler
                    ttl       Make a bootstrap file

* Disassembled 02/04/03 23:11:02 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       6

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       1
DevFd               rmb       3
BTLSN               rmb       1
u0005               rmb       2
BtSiz               rmb       2
sttbuf              rmb       20
u001D               rmb       2
u001F               rmb       10
u0029               rmb       2
devnam              rmb       32
u004B               rmb       16
u005B               rmb       1
u005C               rmb       7
u0063               rmb       682
size                equ       .

name                fcs       /Cobbler/
                    fcb       edition

HelpMsg             fcb       C$LF
                    fcc       "Use: Cobbler </devname>"
                    fcb       C$LF
                    fcc       "    to create a new system disk"
                    fcb       C$CR
L004E               fcb       C$LF
                    fcc       "Error writing kernel track"
                    fcb       C$CR
L006A               fcb       C$LF
                    fcc       "Warning - Kernel track has"
                    fcb       C$LF
                    fcc       "not been allocated properly."
                    fcb       C$LF
                    fcc       "Track not written."
                    fcb       C$CR
L00B6               fcb       C$LF
                    fcc       "Error - OS9boot file fragmented"
                    fcb       C$LF
                    fcc       " This disk will not bootstrap."
                    fcb       C$CR
BfNam               fcc       "OS9Boot "
                    fcb       $FF
start               equ       *
                    clrb
                    lda       #'/
                    cmpa      ,x
                    lbne      Usage
                    os9       F$PrsNam
                    lbcs      Usage
                    lda       #'/
                    cmpa      ,y
                    lbeq      Usage
                    leay      <devnam,u
L011A               sta       ,y+
                    lda       ,x+
                    decb
                    bpl       L011A
                    sty       <u0029
                    lda       #'@
                    ldb       #$20
                    std       ,y++
                    leax      <devnam,u
                    lda       #UPDAT.
                    os9       I$Open
                    sta       <DevFd
                    lbcs      Usage
                    ldx       <u0029
                    leay      >BfNam,pcr
                    lda       #'/
L0140               sta       ,x+
                    lda       ,y+
                    bpl       L0140
                    lda       <DevFd
                    pshs      u
                    ldx       #$0000
                    ldu       #$0015              probably DD.BT
                    os9       I$Seek
                    puls      u
                    lbcs      Exit
                    leax      BTLSN,u
                    ldy       #$0005
                    os9       I$Read              Read bootstrap sector + size = 5 bytes
                    lbcs      Exit
                    ldd       <BtSiz
                    beq       L017B
                    leax      <devnam,u
                    os9       I$Delete
                    clra
                    clrb
                    sta       <BTLSN
                    std       <u0005
                    std       <BtSiz
                    lbsr      UpLSN0
L017B               lda       #WRITE.
                    ldb       #UPDAT.
                    leax      <devnam,u
                    os9       I$Create
                    sta       <u0000
                    lbcs      Exit
                    ldd       >$0068
                    subd      >$0066
                    tfr       d,y
                    std       <BtSiz
                    ldx       >$0066
                    lda       <u0000
                    os9       I$Write
                    lbcs      Exit
                    leax      sttbuf,u
                    ldb       #SS.OPT
                    os9       I$GetStt
                    lbcs      Exit
                    lda       <u0000
                    os9       I$Close
                    lbcs      Usage
                    pshs      u
                    ldx       <u001D,u
                    lda       <u001F,u
                    clrb
                    tfr       d,u
                    lda       <DevFd
                    os9       I$Seek
                    puls      u
                    lbcs      Exit
                    leax      <u004B,u
                    ldy       #$0100
                    os9       I$Read
                    lbcs      Exit
                    ldd       <u0063,u
                    lbne      Fragd
                    ldb       <u005B,u
                    stb       <BTLSN
                    ldd       <u005C,u
                    std       <u0005
                    lbsr      UpLSN0
                    lbsr      SkLSN1
                    leax      <u004B,u
                    ldy       #$0100
                    os9       I$Read
                    bcs       wrerr
                    lda       ,x
                    anda      #$3F
                    eora      #$3F
                    bne       NotAllo
                    lda       $01,x
                    eora      #$FF
                    bne       NotAllo
                    lda       $02,x
                    anda      #$90
                    eora      #$90
                    bne       NotAllo
                    ldx       #Bt.Start           Address of kernel in RAM
                    ldy       #Bt.Size            Amount to write
                    lda       <DevFd
                    os9       I$Write
                    bcs       ETrack
                    os9       I$Close
                    bcs       Exit
                    clrb
                    bra       Exit

SkLSN1              pshs      u
                    lda       <DevFd
                    ldx       #$0000
                    ldu       #$0100
                    os9       I$Seek              Seek to allocation map at LSN 1
                    puls      pc,u

Usage               leax      >HelpMsg,pcr
wrerr               pshs      b
                    lda       #$02
                    ldy       #$0100
                    os9       I$WritLn
                    comb
                    puls      b
Exit                os9       F$Exit

Fragd               leax      >L00B6,pcr
                    clrb
                    bra       wrerr

ETrack              leax      >L004E,pcr
                    clrb
                    bra       wrerr
*
* Write warning
NotAllo             leax      >L006A,pcr
                    clrb
                    bra       wrerr
*
* Update the identification sector on LSN 0
*
UpLSN0              pshs      u
                    ldx       #$0000
                    ldu       #$0015              probably DD.BT
                    lda       <DevFd
                    os9       I$Seek
                    puls      u
                    bcs       Exit
                    leax      BTLSN,u
                    ldy       #$0005
                    os9       I$Write
                    bcs       Exit
                    rts
                    emod
eom                 equ       *
