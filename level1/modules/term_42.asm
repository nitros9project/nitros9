********************************************************************
* TERM - Hi-Res 40x24 Device Descriptor
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          ????/??/??
* From Tandy OS-9 Level One VR 02.00.00
*
* Modified from 51 col driver to suit 40 column software
* driver from Dragon Data OS-9, 2004-12-02 P.Harvey-Smith.
*



                    nam       TERM
                    ttl       Hi-Res 42x24 Device Descriptor

* Disassembled 98/08/23 17:19:25 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
;         use   scfdefs
                    use       cocovtio.d
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       UPDAT.              mode byte
                    fcb       HW.Page             extended controller address
                    fdb       $C000               physical controller address
                    fcb       initsize-*-1        initilization table size
                    fcb       DT.SCF              device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       $00                 case:0=up&lower,1=upper only
                    fcb       $01                 backspace:0=bsp,1=bsp then sp & bsp
                    fcb       $00                 delete:0=bsp over line,1=return
                    fcb       $01                 echo:0=no echo
                    fcb       $01                 auto line feed:0=off
                    fcb       $00                 end of line null count
                    fcb       $01                 pause:0=no end of page pause
                    fcb       24                  lines per page
                    fcb       C$BSP               backspace character
                    fcb       C$DEL               delete line character
                    fcb       C$CR                end of record character
                    fcb       C$EOF               end of file character
                    fcb       C$RPRT              reprint line character
                    fcb       C$RPET              duplicate last line character
                    fcb       C$PAUS              pause character
                    fcb       C$INTR              interrupt character
                    fcb       C$QUIT              quit character
                    fcb       C$BSP               backspace echo character
                    fcb       C$BELL              line overflow character (bell)
                    fcb       ModCo42             init value for dev ctl reg
                    fcb       $00                 baud rate
                    fdb       name                copy of descriptor name address
                    fcb       $00                 acia xon char
                    fcb       $00                 acia xoff char
                    fcb       42                  (szx) number of columns for display
                    fcb       24                  (szy) number of rows for display
initsize            equ       *

name                fcs       /TERM/
mgrnam              fcs       /SCF/
drvnam              fcs       /VTIO/

                    emod
eom                 equ       *
                    end
