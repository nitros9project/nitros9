********************************************************************
* scdwvdesc - Drivewire Virtual Device Descriptor
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0.3    2009/12/??  Aaron Wolfe
* Added SHARE. bit to mode.
*
*   0.4    2009/12/27  Boisy G. Pitre
* Removed SHARE. bit from mode because of tsmon issues.
*
*   0.5    2009/12/29  Boisy G. Pitre
* Made U and T descriptor templates. Backspace is now $7F for
* telnet clients which are likely to access the T ports.
*
* This descriptor has slightly different defaults, intended to be used as
* the channel for the DriveWire utilities
*
*   0.6    2010/01/12  Boisy G. Pitre
* Renamed.
*
*   0.7    2010/01/20  Boisy G. Pitre
* No more /N0.  /Term is /N0.
*
*   0.8    2010/05/28  Aaron Wolfe
* /N14 is now /MIDI

                    nam       scdwdesc
                    ttl       DriveWire Virtual Device Descriptor

                    ifp1
                    use       defsfile
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $07

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       SHARE.+UPDAT.       mode byte
                    fcb       HW.Page             extended controller address
                    fdb       $FF00+Addr          physical controller address
                    fcb       initsize-*-1        initilization table size
                    fcb       DT.SCF              device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       $00                 case:0=up&lower,1=upper only
                    fcb       $01                 backspace:0=bsp,1=bsp then sp & bsp
                    fcb       $00                 delete:0=bsp over line,1=return
                    ifeq      Addr-0
                    fcb       $01                 echo:0=no echo
                    fcb       $01                 auto line feed:0=off
                    else
                    ifgt      Addr-14
                    fcb       $01                 echo:0=no echo
                    fcb       $01                 auto line feed:0=off
                    else
                    fcb       $00                 echo:0=no echo
                    fcb       $00                 auto line feed:0=off
                    endc
                    endc
                    fcb       $00                 end of line null count
                    fcb       $00                 pause:0=no end of page pause
                    fcb       24                  lines per page (not a safe assumption anymore!)
                    ifeq      Addr-14
                    fcb       0                   backspace character (on most telnet clients)
                    fcb       0                   delete line character
                    fcb       0                   end of record character
                    fcb       0                   end of file character
                    fcb       0                   reprint line character
                    fcb       0                   duplicate last line character
                    fcb       0                   pause character
                    fcb       0                   interrupt character
                    fcb       0                   quit character
                    fcb       0                   backspace echo character
                    fcb       0                   line overflow character (bell)
                    else
                    fcb       C$BSP               backspace character (on most telnet clients)
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
                    endc
                    fcb       $00                 mode byte for terminal descriptor
                    fcb       B600                baud rate (not used, maybe future assignment?)
                    fdb       name                copy of descriptor name address
                    fcb       $00                 acia xon char (not used, maybe future assignment?)
                    fcb       $00                 acia xoff char (not used, maybe future assignment?)
                    fcb       80                  (szx) number of columns for display
                    fcb       24                  (szy) number of rows for display
initsize            equ       *

name                equ       *
                    ifeq      Addr-0
                    fcs       /Term/
                    else
                    ifeq      Addr-14
                    fcs       /MIDI/
                    else
                    ifeq      Addr-255
                    fcs       'N'
                    else
                    ifgt      Addr-15
                    ifeq      Addr-16
                    fcs       /Term/
                    else
                    fcc       /Z/
                    fcb       176+Addr-16
                    endc
                    else
                    fcc       /N/
                    ifgt      Addr-9
                    fcc       '1'
                    fcb       176+Addr-10
                    else
                    fcb       176+Addr
                    endc
                    endc
                    endc
                    endc
                    endc
mgrnam              fcs       /SCF/
drvnam              fcs       /scdwv/

                    emod
eom                 equ       *
                    end

