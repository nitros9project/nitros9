********************************************************************
* dw - command interface to the server
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2010/01/02  Aaron Wolfe
* Most basic implementation using new DW utility API

                    nam       dw
                    ttl       command interface to the server

                    section   __os9
type                equ       Prgrm
lang                equ       Objct
attr                equ       ReEnt
rev                 equ       $00
edition             equ       1
stack               equ       200
                    endsect

                    section   bss
pbuffer             rmb       256
pbend               rmb       2
cbuffer             rmb       256
portdev             rmb       10
portpath            rmb       1
outpath             rmb       1
numbyt              rmb       1
die                 rmb       1
                    endsect

                    section   code

* signal handling
icpt                lda       #1
                    sta       die,u
                    rti

command             fcc       'dw '

* save initial parameters
__start             pshs      d
                    pshs      x
                    clr       die,u
* set intercept handler
                    leax      icpt,pcr            *ptr to handler
                    os9       F$Icpt

                    clra
                    lbsr      TCPOpen
                    lbcs      errex1


gotport             sta       portpath,u

* rawpath
                    lbsr      RawPath

* write command to port
                    lda       portpath,u
                    ldy       #3
                    leax      command,pc
                    os9       I$Write
                    lbcs      errex2

* write parameters to port - X = start addr, y = # bytes, A = path#
                    puls      x
                    puls      y

                    os9       I$WritLn
                    lbcs      errex2

* read result
                    leax      pbuffer,u
                    lda       portpath,u
                    ldy       #1
rrloop              os9       I$Read
                    lbcs      errex2
                    ldb       ,x+
                    cmpb      #C$CR               * end of response
                    bne       rrloop

* look for Fail
                    ldb       pbuffer,u
                    cmpb      #'F
                    bne       gotconn             * we connected

* display failure message
                    lda       #1
                    ldy       #1
                    leax      pbuffer,u
                    ldb       #9                  *skip proto error info (FAIL xxx )
                    abx
prloop              os9       I$Write
                    ldb       ,x+
                    cmpb      #C$CR               *end of response
                    bne       prloop

                    ldy       #2
                    leax      crlf,pc
                    os9       I$Write

                    lbra      done

crlf                fcb       C$CR
                    fcb       C$LF

* response loop
* read 1 byte, this is how many bytes follow in this set.  0 for end of response
gotconn             nop

* check for incoming serial data
rloop               lda       portpath,u
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcc       serinc              read and print the byte

* if we got no data and die is set, bail
                    lda       die,u
                    bne       done

* sleep a while
                    ldx       #0001
                    os9       F$Sleep
                    bra       rloop

* read B bytes from serial, print on screen
serinc              clra
                    tfr       d,y
                    lda       portpath,u
                    leax      pbuffer,u
                    os9       I$Read
                    lbcs      errex2
* print the data to stdout
                    lda       #1
                    leax      pbuffer,u
                    os9       I$Write
                    bra       rloop

done                clrb                          *no errors here
* close port
errex2              lda       portpath,u
                    os9       I$Close

errex1              os9       F$Exit              *goodbye
                    endsect




