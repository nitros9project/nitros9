********************************************************************
* term_gfx - Pico-Thing Graphical Console Device Descriptor
*
* Device descriptor for the CoPico graphical terminal.
* Uses VTIO as the SCF driver, which dispatches to CoPico.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial version for Pico-Thing

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       UPDAT.    mode byte
                    fcb       HW.Page   extended controller address ($FF)

                    fdb       $0000     physical controller address (none)

                    fcb       initsize-*-1 initialization table size
                    fcb       DT.SCF    IT.DVC device type: scf
                    fcb       $00       IT.UPC case: upper and lower
                    fcb       $01       IT.BSO backspace: bsp then sp then bsp
                    fcb       $00       IT.DLO delete: backspace over line
                    fcb       $01       IT.EKO echo: echo on
                    fcb       $01       IT.ALF auto line feed: on
                    fcb       $00       IT.NUL end of line null count
                    fcb       $00       IT.PAU pause: no end of page pause
                    fcb       25        IT.PAG lines per page
                    fcb       C$BSP     IT.BSP backspace character
                    fcb       C$DEL     IT.DEL delete line character
                    fcb       C$CR      IT.EOR end of record character
                    fcb       C$EOF     IT.EOF end of file character
                    fcb       C$RPRT    IT.RPR reprint line character
                    fcb       C$RPET    IT.DUP duplicate last line character
                    fcb       C$PAUS    IT.PSC pause character
                    fcb       C$INTR    IT.INT interrupt character
                    fcb       C$QUIT    IT.QUT quit character
                    fcb       C$BSP     IT.BSE backspace echo character
                    fcb       C$BELL    IT.OVF line overflow character (bell)
                    fcb       PARNONE   IT.PAR parity: none
                    fcb       $00       IT.BAU baud (not applicable)
                    fdb       name      IT.D2P copy of descriptor name address
                    fcb       C$XON     IT.XON xon character
                    fcb       C$XOFF    IT.XOFF xoff character
                    fcb       80        IT.COL number of columns
                    fcb       25        IT.ROW number of rows
                    fcb       $80       IT.XTYP window type (hi bit set = window device)
initsize            equ       *

name                fcs       /Term/

mgrnam              fcs       /SCF/
drvnam              fcs       /VTIO/

                    emod
eom                 equ       *
                    end
