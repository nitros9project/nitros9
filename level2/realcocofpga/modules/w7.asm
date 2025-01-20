********************************************************************
* W7 - Window descriptor
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

                    nam       W7
                    ttl       Window descriptor

* Disassembled 98/08/23 22:38:05 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

* Window descriptor definitions
* Window descriptor definitions
szx                 set       80                  number of columns for display
szy                 set       24                  number for rows for display
sty                 set       2                   window type
cpx                 set       0                   x cursor position
cpy                 set       0                   y cursor position
prn1                set       White.              foreground color
prn2                set       7                   background color
prn3                set       7                    border color

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       READ.+WRITE.        mode byte
                    fcb       HW.Page             extended controller address
                    fdb       A.W7                physical controller address
                    fcb       initsize-*-1        initilization table size
                    fcb       $00                 device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       $00                 case:0=up&lower,1=upper only
                    fcb       $01                 backspace:0=bsp,1=bsp then sp & bsp
                    fcb       $00                 delete:0=bsp over line,1=return
                    fcb       $01                 echo:0=no echo
                    fcb       $01                 auto line feed:0=off
                    fcb       $00                 end of line null count
                    fcb       $00                 pause:0=no end of page pause
                    fcb       24                  lines per page
                    fcb       C$BSP               backspace character
                    fcb       C$DEL               delete line character
                    fcb       C$CR                end of record character
                    fcb       C$EOF               end of file character
                    fcb       C$RARR              reprint line character
                    fcb       C$SHRARR            duplicate last line character
                    fcb       C$PAUS              pause character
                    fcb       C$INTR              interrupt character
                    fcb       C$QUIT              quit character
                    fcb       C$BSP               backspace echo character
                    fcb       C$BELL              line overflow character (bell)
                    fcb       $80                 init value for dev ctl reg
                    fcb       $00                 baud rate
                    fdb       name                copy of descriptor name address
                    fcb       $00                 acia xon char
                    fcb       $00                 acia xoff char
                    fcb       szx                 (szx) number of columns for display
                    fcb       szy                 (szy) number of rows for display
                    fcb       7                   window number
                    fcb       $01                 data in rest of descriptor valid
                    fcb       sty                 (sty) window type
                    fcb       cpx                 (cpx) x cursor position
                    fcb       cpy                 (cpy) y cursor position
                    fcb       prn1                (prn1) foreground color
                    fcb       prn2                (prn2) background color
                    fcb       prn3                (prn3) border color
initsize            equ       *

name                fcs       /W7/
mgrnam              fcs       /SCF/
drvnam              fcs       /VTIO/

                    emod
eom                 equ       *
                    end

