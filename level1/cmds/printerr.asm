********************************************************************
* Printerr - OS-9 Level One printerr routine
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   6      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*   7      2002/07/13  Boisy G. Pitre
* Changed /D0 to /DD.

                    nam       Printerr
                    ttl       OS-9 Level One printerr routine

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       7

                    mod       eom,name,tylg,atrv,start,size

                    org       0
s.erpath            rmb       1
s.flpath            rmb       1
s.errcod            rmb       1
                    rmb       2
s.buffer            rmb       81
size                equ       .

name                fcs       /Printerr/
                    fcb       edition

ErrFile             fcc       "/DD/SYS/ERRMSG"
                    fcb       C$CR
*         fcc   ",,,,,,,,,,,,"

ErrMsg              fcc       "Error #"
                    fcb       $FF

SysSVC              fcb       F$PErr
                    fdb       FPErr-*-2
                    fcb       $80

start               clra                          any module
                    leax      <name,pcr           point to name
                    os9       F$Link              link one extra time
                    bcs       error               branch if error
                    leay      <SysSVC,pcr         point to system service table
                    os9       F$SSvc              add it to system calls
                    clrb                          clear carry
error               os9       F$Exit              and exit

FPErr               ldx       <D.Proc             get current process pointer
                    lda       P$PATH+2,x          get stderr path
                    beq       Exit2               branch if not open
                    leas      <-size,s            else make room on stack
                    ldb       R$B,u               get error code
                    leau      ,s                  point U to save area
                    sta       s.erpath,u          store path
                    stb       s.errcod,u          store error code
                    bsr       PErrOrg             print error as originally done
                    lda       #READ.              read access mode
                    leax      >ErrFile,pcr        point to error file
                    os9       I$Open              open path to it
                    sta       s.flpath,u          save path to file
                    bcs       Exit1               branch if error
                    bsr       FindErr             attempt to find line that matches error code
                    bcs       Close               if error, close file and return to OS-9
                    bne       Close
NxtLine             bsr       WriteLn             else write line
                    bsr       ReadLine            read next line
                    bcs       Close               branch if error
                    ldb       ,x                  get first byte of line just read
                    cmpb      #'0                 number?
                    bcs       NxtLine             branch if not
Close               lda       s.flpath,u          get path
                    os9       I$Close             close path to error file
Exit1               leas      <size,s             clean stack
Exit2               clrb                          clear carry
                    rts                           and return to OS-9

FindErr             bsr       ReadLine            read line
                    bcs       FindRts             branch if error
                    bsr       ASC2Byte            get error number
                    cmpa      #'0
                    bcc       FindErr
                    cmpb      s.errcod,u          same as error?
                    bne       FindErr             branch if not
FindRts             rts

* read a line from the error file
ReadLine            lda       s.flpath,u          get path number of file
                    leax      s.buffer,u          point X to buffer
                    ldy       #80                 max 80 chars
                    os9       I$ReadLn            read line
                    rts

PErrOrg             leax      >ErrMsg,pcr         point X to error header
                    leay      s.buffer,u          point Y to buffer area
                    lda       ,x+                 get byte at X
CopyLoop            sta       ,y+                 and store it at Y
                    lda       ,x+                 get byte...
                    bpl       CopyLoop            while hi bit not set in A
                    ldb       s.errcod,u          get error number
                    lda       #$2F                start out just below '0
Hundreds            inca                          increment A
                    subb      #100                subtract
                    bcc       Hundreds            continue if carry clear
                    sta       ,y+                 else store as character
                    lda       #$3A                start out just beyond '9
Tens                deca                          decrement A
                    addb      #10                 add 10 to B
                    bcc       Tens                continue if carry clear
                    sta       ,y+                 save A
                    tfr       b,a                 transfer
                    adda      #$30                add '0
                    ldb       #C$CR
                    std       ,y+
                    leax      s.buffer,u          point X at buffer
WriteLn             ldy       #80                 max string len
                    lda       s.erpath,u          get stderr path
                    os9       I$WritLn            write it out
                    rts

ASC2Byte            clrb                          clear B
ASC2BLp             lda       ,x+                 get byte from X
                    suba      #'0                 make 8 bit integer
                    cmpa      #$09                compare against 9
                    bhi       ASC2BEx             branch if greater
                    pshs      a                   else save A
                    lda       #10                 multiply by 10
                    mul                           do it
                    addb      ,s+                 add on stack
                    bcc       ASC2BLp             if carry clear, do it again
ASC2BEx             lda       -1,x                load byte
                    rts                           return

                    emod
eom                 equ       *
                    end

