********************************************************************
* term_pt - Pico-Thing Virtual 6850 ACIA Device Descriptor
*
* Console terminal descriptor for the virtual MC6850 ACIA
* provided by the Pico at $FFC4-$FFC5.
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

                    fdb       ACIABase  physical controller address ($FFC4)

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
                    fcb       $7F       IT.BSP backspace character (DEL, as modern terminals send)
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
                    fcb       STOP1+WORD8+B9600 IT.BAU 1 stop bit, 8 bits, 9600 baud
                    fdb       name      IT.D2P copy of descriptor name address
                    fcb       C$XON     IT.XON xon character
                    fcb       C$XOFF    IT.XOFF xoff character
                    fcb       80        IT.COL number of columns
                    fcb       25        IT.ROW number of rows
                    fcb       $00       IT.XTYP not extended type
initsize            equ       *

name                fcs       /Term/

mgrnam              fcs       /SCF/
drvnam              fcs       /sc6850/

                    emod
eom                 equ       *
                    end
