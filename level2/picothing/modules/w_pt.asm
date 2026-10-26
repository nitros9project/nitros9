********************************************************************
* w_pt - Pico-Thing video window descriptor, one per window
*
* One shared source for the video window devices, built once per window
* with -DWINNUM=n (the recipe passes it): IT.WND carries the window
* number the VConW driver Selects before it writes.  WINNUM 0 is the
* root/panel and its device is /W0 (the base console); WINNUM 1..7 are
* the overlay windows /W1../W7.  Modelled on the CoCo3 window descriptor
* fields already defined in scf.d (IT.WND/IT.CPX/IT.CPY), so these sit at
* the same offsets the VConW driver reads.
*
* Each window is full-panel (128x30 at 0,0) so a shell sees a normal
* console; DWShow switches which one is on screen.  Served by VConW,
* which reads IT.WND/IT.CPX/IT.CPY/IT.COL/IT.ROW to DWSet the window on
* first write (the root is predefined, so window 0 is never DWSet).
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2026       Created for the /W multi-window model (M5 phase 1)

                  IFP1
                    use       defsfile
                  ENDC

                    ifndef    WINNUM
WINNUM              set       1
                  ENDC

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $00

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       UPDAT.    mode byte: read + write
                    fcb       HW.Page   extended controller address ($FF)
* Port: VID.Data plus the window number ($FF10-$FF17).  VConW addresses the
* registers absolutely and never reads the port, but IOMan shares static
* storage between descriptors with the same driver and port - so a shared
* port would make every window one SCF device with one busy flag, and a read
* waiting on one window would stall writes to all of them.  A distinct port
* gives each window its own static and so its own SCF device state.
                    fdb       VID.Data+WINNUM physical controller address, one per window
                    fcb       initsize-*-1 initialization table size
                    fcb       DT.SCF    IT.DVC device type: scf
                    fcb       $00       IT.UPC case: upper and lower
                    fcb       $01       IT.BSO backspace: bsp then sp then bsp
                    fcb       $00       IT.DLO delete: backspace over line
                    fcb       $01       IT.EKO echo: on
                    fcb       $01       IT.ALF auto line feed: on
                    fcb       $00       IT.NUL end of line null count
                    fcb       $00       IT.PAU pause: no end of page pause
                    fcb       30        IT.PAG lines per page
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
                    fcb       $80       IT.PAR window-descriptor marker (CoCo convention)
                    fcb       $00       IT.BAU baud: not applicable
                    fdb       name      IT.D2P copy of descriptor name address
                    fcb       $00       IT.XON xon character: none
                    fcb       $00       IT.XOFF xoff character: none
                    fcb       128       IT.COL window width in columns
                    fcb       30        IT.ROW window height in rows
* CoCo3 window descriptor block (scf.d overlays these onto IT.XTYP onward)
                    fcb       WINNUM    IT.WND window number (matches device name)
                    fcb       $00       IT.VAL use defaults on init: no
                    fcb       $00       IT.STY screen type default
                    fcb       $00       IT.CPX column start (x)
                    fcb       $00       IT.CPY row start (y)
                    fcb       $00       IT.FGC foreground colour default
                    fcb       $00       IT.BGC background colour default
                    fcb       $00       IT.BDC border colour default
initsize            equ       *

* Window n is named /Wn; window 0 is the root/panel (the base console).
name                fcc       "W"
                    fcb       WINNUM+'0'+$80 window digit, high bit ends the name

mgrnam              fcs       /SCF/
drvnam              fcs       /VConW/

                    emod
eom                 equ       *
                    end
