********************************************************************
* List - List a text file
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.

                    nam       List
                    ttl       List a text file

* Disassembled 98/09/10 23:16:25 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       5

                    mod       eom,name,tylg,atrv,start,size

                    org       0
filepath            rmb       1
parmptr             rmb       2
readbuff            rmb       650
size                equ       .

name                fcs       /List/
                    fcb       edition

start               stx       <parmptr            save parameter pointer
                    lda       #READ.              read access mode
                    os9       I$Open              open file
                    bcs       L0049               branch if error
                    sta       <filepath           else save path to file
                    stx       <parmptr            and updated parm pointer
L001F               lda       <filepath           get path
                    leax      readbuff,u          point X to read buffer
                    ldy       #200                read up to 200 bytes
                    os9       I$ReadLn            read it!
                    bcs       L0035               branch if error
                    lda       #1                  standard output
                    os9       I$WritLn            write line to stdout
                    bcc       L001F               branch if ok
                    bra       L0049               else exit
L0035               cmpb      #E$EOF              did we get an EOF error?
                    bne       L0049               exit if not
                    lda       <filepath           else get path
                    os9       I$Close             and close it
                    bcs       L0049               branch if error
                    ldx       <parmptr            get param pointer
                    lda       ,x                  get char
                    cmpa      #C$CR               end of command line?
                    bne       start               branch if not
                    clrb                          else clear carry
L0049               os9       F$Exit              and exit

                    emod
eom                 equ       *
                    end
