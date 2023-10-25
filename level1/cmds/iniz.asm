********************************************************************
* Iniz - Initialize a device
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   3      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*   4      2003/01/13  Boisy G. Pitre
* Tightened code, changed behavior slightly.

                    nam       Iniz
                    ttl       Initialize a device

* Disassembled 98/09/10 22:56:37 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       4

lsize               equ       80

                    mod       eom,name,tylg,atrv,start,size

                    org       0
rbuffer             rmb       lsize+1
stack               rmb       64
size                equ       .

name                fcs       /Iniz/
                    fcb       edition

start               lda       ,x                  get command line char
                    cmpa      #C$CR               CR?
                    beq       ReadnInz            branch if so
InizDev             lda       ,x+
                    cmpa      #C$CR
                    beq       ExitOk
                    cmpa      #C$SPAC
                    beq       InizDev
                    cmpa      #PDELIM             pathlist?
                    beq       AttachIt
                    leax      -1,x                else back up X
AttachIt            clra
                    os9       I$Attach            attach to the device at X
                    bcs       Exit                branch if error
                    bra       InizDev

ReadnInz            clra                          from stdin
                    leax      rbuffer,u           point to read buffer
                    ldy       #lsize              get lsize bytes
                    os9       I$ReadLn            read it!
                    bcc       InizDev             branch if error
                    cmpb      #E$EOF              end of file?
                    bne       Exit                branch if not
ExitOk              clrb
Exit                os9       F$Exit

                    emod
eom                 equ       *
                    end
