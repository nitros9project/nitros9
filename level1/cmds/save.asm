********************************************************************
* Save - Save module from memory to disk
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   3      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.

                    nam       Save
                    ttl       Save module from memory to disk

* Disassembled 98/09/14 23:45:22 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       3

                    mod       eom,name,tylg,atrv,start,size

                    org       0
fpath               rmb       451
size                equ       .

name                fcs       /Save/
                    fcb       edition

start               leay      -1,y                back up Y by one
                    pshs      y,x                 save X Y on stack
                    cmpx      $02,s               one byte on command line? (CR)
                    bcc       ExitOk              branch if so
                    ldd       #WRITE.*256+PEXEC.+PREAD.+EXEC.+UPDAT.
                    os9       I$Create            create file of same name as arg
                    bcs       Exit                branch if error
                    sta       <fpath              save path
                    lda       ,x                  get char after arg
                    cmpa      #C$CR               CR?
                    bne       NextMod             branch if not
                    ldx       ,s                  else get ptr to start of cmd line
NextMod             lda       ,x+                 get char
                    cmpa      #C$SPAC             space?
                    beq       NextMod             branch if so
                    cmpa      #C$COMA             coma?
                    beq       NextMod             branch if so
                    leax      -$01,x              else backup 1
                    clra                          clear ty/lang
                    os9       F$Link              link to module
                    bcs       Exit                branch if error
                    stx       ,s                  save X
                    leax      ,u                  point to start of module
                    ldy       M$Size,x            get module size in y
                    lda       <fpath              get path to file
                    os9       I$Write             write module to file
                    pshs      b,cc
                    os9       F$UnLink            unlink module
                    ror       ,s+
                    puls      b
                    bcs       Exit
                    ldx       ,s                  get param pointer
                    cmpx      $02,s               end of param?
                    bcs       NextMod             branch of not
                    os9       I$Close             else close path
                    bcs       Exit                branch if error
ExitOk              clrb
Exit                os9       F$Exit

                    emod
eom                 equ       *
                    end
