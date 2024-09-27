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

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       5

                    mod       eom,name,tylg,atrv,start,size

maxreadlen          equ       200
                    org       0
filepath            rmb       1
parmptr             rmb       2
readbuff            rmb       maxreadlen+1
stack               rmb       200
size                equ       .

name                fcs       /List/
                    fcb       edition

start               stx       <parmptr            save parameter pointer
                    lda       #READ.              read access mode
                    os9       I$Open              open file
                    bcs       ex@                 branch if error
                    sta       <filepath           else save path to file
                    stx       <parmptr            and updated parameter pointer
l@                  lda       <filepath           get path
                    leax      readbuff,u          point X to read buffer
                    ldy       #maxreadlen         read up to the maximum length
                    os9       I$ReadLn            read it!
                    bcs       ckeof@              branch if error
                    lda       #1                  standard output
                    os9       I$WritLn            write line to stdout
                    bcc       l@                  branch if ok
                    bra       ex@                 else exit
ckeof@              cmpb      #E$EOF              did we get an EOF error?
                    bne       ex@                 exit if not
                    lda       <filepath           else get path
                    os9       I$Close             and close it
                    bcs       ex@                 branch if error
                    ldx       <parmptr            get param pointer
                    lda       ,x                  get char
                    cmpa      #C$CR               end of command line?
                    bne       start               branch if not
                    clrb                          else clear carry
ex@                 os9       F$Exit              and exit

                    emod
eom                 equ       *
                    end
