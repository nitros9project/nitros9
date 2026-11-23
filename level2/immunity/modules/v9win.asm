********************************************************************
* V9 - V9958 (SuperSprite-FM+) text screen descriptor
*
* DRAFT, not assembled. Based on vdgwin.asm. Assemble with -DCOLS=40 or
* -DCOLS=80. CLEAR / SHIFT-CLEAR switch between this screen and the VDG
* ones. The parity byte tells CoVDG (built with -DSSFM=1) that this is a
* V9958 screen: bit 6 = V9958 screen, bit 5 = 80 columns.
********************************************************************

                    nam       V9
                    ttl       V9958 text screen descriptor

                  IFP1
                    use       defsfile
                    use       cocovtio.d
                  ENDC

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

szx                 set       COLS      number of columns for display
szy                 set       24        number for rows for display
wnum                set       9         descriptor number: name /V9
sty                 set       1         window type
cpx                 set       0         x cursor position
cpy                 set       0         y cursor position
prn1                set       Black.    foreground color
prn2                set       Green.    background color
prn3                set       Black.    border color

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       READ.+WRITE. mode byte
                    fcb       HW.Page   extended controller address
                    fdb       A.V1-1+wnum physical controller address ($FFC9)
                    fcb       initsize-*-1 initilization table size
                    fcb       DT.SCF    device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       $00       case:0=up&lower,1=upper only
                    fcb       $01       backspace:0=bsp,1=bsp then sp & bsp
                    fcb       $00       delete:0=bsp over line,1=return
                    fcb       $01       echo:0=no echo
                    fcb       $01       auto line feed:0=off
                    fcb       $00       end of line null count
                    fcb       $01       pause:0=no end of page pause
                    fcb       szy       lines per page
                    fcb       C$BSP     backspace character
                    fcb       C$DEL     delete line character
                    fcb       C$CR      end of record character
                    fcb       C$EOF     end of file character
                    fcb       C$RARR    reprint line character
                    fcb       C$SHRARR  duplicate last line character
                    fcb       C$PAUS    pause character
                    fcb       C$INTR    interrupt character
                    fcb       C$QUIT    quit character
                    fcb       C$BSP     backspace echo character
                    fcb       C$BELL    line overflow character (bell)
* Parity byte: $40 = V9958 screen, +$20 for 80 columns (see ssfm.asm)
                  IFEQ    COLS-80
                    fcb       $60       init value for dev ctl reg
                  ELSE
                    fcb       $40       init value for dev ctl reg
                  ENDC
                    fcb       $00       baud rate
                    fdb       name      copy of descriptor name address
                    fcb       $00       acia xon char
                    fcb       $00       acia xoff char
                    fcb       szx       (szx) number of columns for display
                    fcb       szy       (szy) number of rows for display
                    fcb       wnum      window number
                    fcb       $01       data in rest of descriptor valid
                    fcb       sty       (sty) window type
                    fcb       cpx       (cpx) x cursor position
                    fcb       cpy       (cpy) y cursor position
                    fcb       prn1      (prn1) foreground color
                    fcb       prn2      (prn2) background color
                    fcb       prn3      (prn3) border color
initsize            equ       *

name                fcc       /V/
                    fcb       176+wnum
mgrnam              fcs       /SCF/
drvnam              fcs       /VTIO/

                    emod
eom                 equ       *
                    end
