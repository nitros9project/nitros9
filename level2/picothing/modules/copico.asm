********************************************************************
* CoPico - Co-module for Pico-Thing Graphics Console
*
* Stub co-module with 6 entry points matching the standard
* CoXXX interface (CoInit, CoWrite, CoGetStt, CoSetStt,
* CoTerm, CoWinSpc).
*
* This will eventually send high-level command messages to
* a separate Graphics Pico over the E-clocked link.
* For now all entry points return success.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial skeleton for Pico-Thing

                    nam       CoPico
                    ttl       Co-module for Pico-Thing Graphics Console

                  IFP1
                    use       defsfile
                    use       cocovtio.d
                  ENDC

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       0
size                equ       .

name                fcs       /CoPico/
                    fcb       edition

* entry point dispatch table
* six entries at 3-byte intervals
start               lbra      Init      $00 co-module init
                    lbra      Write     $03 write character
                    lbra      GetStat   $06 get status
                    lbra      SetStat   $09 set status
                    lbra      Term      $0C terminate
                    lbra      WinSpc    $0F window special processing

*------------------------------------------------------------
* Init - initialize the co-module
*
* Entry: Y = path descriptor pointer
*        U = device static memory pointer
* Exit:  B = 0, carry clear
*
Init                clrb
                    rts

*------------------------------------------------------------
* Write - write a character to the display
*
* Entry: A = character to write (printable, control, or ESC param)
*        Y = path descriptor pointer
*        U = device static memory pointer
* Exit:  B = 0, carry clear
*
* TODO: translate character/escape sequences into CoPico
*       command messages and send to Graphics Pico
*
Write               clrb
                    rts

*------------------------------------------------------------
* GetStat - get device status
*
* Entry: A = status code
*        Y = path descriptor pointer
*        U = device static memory pointer
* Exit:  carry set, B = E$UnkSvc for unhandled codes
*
GetStat             comb
                    ldb       #E$UnkSvc
                    rts

*------------------------------------------------------------
* SetStat - set device status
*
* Entry: A = status code
*        Y = path descriptor pointer
*        U = device static memory pointer
* Exit:  carry set, B = E$UnkSvc for unhandled codes
*
SetStat             comb
                    ldb       #E$UnkSvc
                    rts

*------------------------------------------------------------
* Term - terminate the co-module
*
* Entry: Y = path descriptor pointer
*        U = device static memory pointer
* Exit:  B = 0, carry clear
*
Term                clrb
                    rts

*------------------------------------------------------------
* WinSpc - window special processing
*
* Entry: A = sub-function code
*        Y = path descriptor pointer
*        U = device static memory pointer
* Exit:  B = 0, carry clear
*
WinSpc              clrb
                    rts

                    emod
eom                 equ       *
                    end
