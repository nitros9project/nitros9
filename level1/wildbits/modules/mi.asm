                    nam       mi
                    ttl       Interrupt-captured MIDI DIN input descriptor

                    ifp1
                    use       defsfile
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $07

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       READ.               mode byte: input only (SHARE.+READ. before 2026-10-02)
                    fcb       HW.Page             extended controller address
                    fdb       $FF30          physical MIDI UART address
                    fcb       initsize-*-1        initialization table size
                    fcb       DT.SCF              device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       $00                 case:0=up&lower,1=upper only
                    fcb       $01                 backspace:0=bsp,1=bsp then sp & bsp
                    fcb       $00                 delete:0=bsp over line,1=return
                    fcb       $00                 echo:0=no echo
                    fcb       $00                 auto line feed:0=off
                    fcb       $00                 end of line null count
                    fcb       $00                 pause:0=no end of page pause
                    fcb       24                  lines per page
                    fcb       0                   backspace character
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
                    fcb       $00                 mode byte for terminal descriptor
                    fcb       B600                baud rate (not used)
* No echo/output device (PD.D2P = 0). SCF's open attaches the device named here with READ/WRITE swapped
* (scf.asm InitDeviceState); "mi" itself made it re-attach this READ.-only device for WRITE -> E$BMode 203
* on every open (dump /mi, list /mi, UME's OpenMidiInput) while iniz mi, which skips SCF, worked.
                    fdb       0                   no echo device (was: name)
                    fcb       $00                 acia xon char (not used)
                    fcb       $00                 acia xoff char (not used)
                    fcb       80                  (szx) number of columns for display
                    fcb       24                  (szy) number of rows for display
initsize            equ       *

name                fcs       /mi/
mgrnam              fcs       /SCF/
drvnam              fcs       /MIDrv/

                    emod
eom                 equ       *
                    end
