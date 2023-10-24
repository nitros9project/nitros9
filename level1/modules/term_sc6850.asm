********************************************************************
* Term - sc6850 Device Descriptor
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

                    nam       Term
                    ttl       sc6850 Device Descriptor

* Disassembled 98/08/23 21:16:50 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       UPDAT.              mode byte
                    fcb       HW.Page             extended controller address

                    fdb       HwBASE              physical controller address

                    fcb       initsize-*-1        initialization table size
                    fcb       DT.SCF              IT.DVC device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       $00                 IT.UPC case:0=up&lower,1=upper only
                    fcb       $01                 IT.BSO backspace:0=bsp,1=bsp then sp & bsp
                    fcb       $00                 IT.DLO delete:0=bsp over line,1=return
                    fcb       $01                 IT.EKO echo:0=no echo
                    fcb       $01                 IT.ALF auto line feed:0=off
                    fcb       $00                 IT.NUL end of line null count
                    fcb       $01                 IT.PAU pause:0=no end of page pause
* IT.PAG and IT.ROW are set to 25 to match the Multicomp6809 hardware
* terminal. Applications (eg scred) inspect this value and need it to be
* correct. In the case of a "glass teletype" (aka terminal emulator)
* attached to a serial port, it should be set to 25x80 in order for programs
* like scred to work correctly.
                    fcb       25                  IT.PAG lines per page
                    fcb       C$BSP               IT.BSP backspace character
                    fcb       C$DEL               IT.DEL delete line character
                    fcb       C$CR                IT.EOR end of record character
                    fcb       C$EOF               IT.EOF end of file character
                    fcb       C$RPRT              IT.RPR reprint line character
                    fcb       C$RPET              IT.DUP duplicate last line character
                    fcb       C$PAUS              IT.PSC pause character
                    fcb       C$INTR              IT.INT interrupt character
                    fcb       C$QUIT              IT.QUT quit character
                    fcb       C$BSP               IT.BSE backspace echo character
                    fcb       C$BELL              IT.OVF line overflow character (bell)
                    fcb       PARNONE             IT.PAR parity
                    ifne      corsham
                    fcb       STOP2+WORD8+B4800   IT.BAU stop bits/word size/baud rate
                    else
                    fcb       STOP1+WORD8+B9600   IT.BAU stop bits/word size/baud rate
                    endc
                    fdb       name                IT.D2P copy of descriptor name address
                    fcb       C$XON               IT.XON acia xon char
                    fcb       C$XOFF              IT.XOFF acia xoff char
                    fcb       80                  IT.COL (szx) number of columns for display
                    fcb       25                  IT.ROW (szy) number of rows for display
                    fcb       $00                 IT.XTYP 0 => NOT extended type
initsize            equ       *

                    ifdef     TNum                from makefile
                    ifeq      TNum
name                fcs       /T0/
                    endif
                    ifeq      TNum-1
name                fcs       /T1/
                    endif
                    else
name                fcs       /Term/
                    endif     match               IFDEF TNum

mgrnam              fcs       /SCF/
drvnam              fcs       /sc6850/

                    emod
eom                 equ       *
                    end
