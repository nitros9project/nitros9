********************************************************************
* go51 - The 51 column by 24 line video display
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      ????/??/??  ???
* From Dragon OS-9 Level One VR 01.02.00.

                    nam       go51
                    ttl       The 51 column by 24 line video display

* Disassembled 02/07/06 21:10:42 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
ioptr               rmb       2
drvrptr             rmb       2
drvrsiz             rmb       2
optbuf              rmb       32
size                equ       .

name                fcs       /go51/
                    fcb       edition

IOMod               fcs       /KBVDIO/
IOModL              equ       *-IOMod
Driver              fcs       /drvr51/
Desc                fcs       /term/

start               leax      >IOMod,pcr          point to I/O module
                    lbsr      DoLink              link to it
                    lbcs      Bye                 branch if error
                    stx       ioptr,u             save ptr to module
                    lbsr      DoUnlink            unlink it
                    leax      >Driver,pcr         point to driver
                    lbsr      DoLink              link to it
                    lbcs      Bye                 branch if error
                    stx       drvrptr,u           save ptr to driver
                    ldd       M$Size,x            get module size
                    std       drvrsiz,u           save driver size
                    pshs      u,cc
                    orcc      #IntMasks           mask interrupts
                    ldx       >D.AltIRQ
                    stx       >D.IRQ              swap irq vector
                    ldy       ioptr,u
                    ldx       drvrsiz,u           get driver size
                    ldu       drvrptr,u           get driver pointer
L0054               lda       ,u+
                    sta       ,y+
                    leax      -$01,x
                    bne       L0054
                    ldx       #$FF00
                    lda       $01,x
                    ora       #$30
                    anda      #$F7
                    sta       $01,x
                    lda       $03,x
                    anda      #$F6
                    ora       #$30
                    sta       $03,x
                    ldx       #$FF20
                    lda       $03,x
                    ora       #$38
                    sta       $03,x
                    puls      u,cc
                    ldx       drvrptr,u           get pointer to driver module
                    lbsr      DoUnlink            unlink it
                    ldx       ioptr,u             get io mod pointer
                    ldd       M$Name,x            get offset to I/O module name
                    leax      d,x                 point X to name
                    leay      >IOMod,pcr
                    ldb       #IOModL
L008B               lda       ,y+
                    sta       ,x+
                    decb
                    bne       L008B
                    lda       #$01                standard output
                    ldb       #SS.Opt             option getstat
                    leax      optbuf,u            point to buffer
                    os9       I$GetStt            get status
                    bcs       Bye                 branch if error
                    clr       (PD.UPC-PD.OPT),x
                    lda       #24
                    sta       (PD.PAG-PD.OPT),x
                    lda       #$01
                    ldb       #SS.Opt
                    os9       I$SetStt
                    bcs       Bye
                    leax      >Desc,pcr
                    lda       #Devic+Objct
                    pshs      u
                    os9       F$Link
                    tfr       u,x
                    puls      u
                    bcs       Bye
                    clr       <IT.UPC,x           clear uppercase flag
                    lda       #24                 new screen has 24 lines
                    sta       <IT.PAG,x           save it
                    bsr       DoUnlink
                    clrb
Bye                 os9       F$Exit

DoLink              pshs      u
                    lda       #Drivr+Objct
                    os9       F$Link
                    tfr       u,x
                    puls      pc,u

DoUnlink            pshs      u
                    tfr       x,u
                    os9       F$UnLink
                    puls      pc,u

                    emod
eom                 equ       *
                    end
