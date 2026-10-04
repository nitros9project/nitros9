********************************************************************
* dwm - DriveWire virtual channel 14 (the DriveWire 4 server's MIDI out) under the name /dwm
*
* 2026-09-29 (user: "add whatever dw drivers are needed to the ume makefiles, and rename 'midi' to 'dwm'"): the
* descriptor level1/modules/scdwvdesc.asm makes with Addr=14 (/MIDI there, /N14 before 2010), renamed /dwm. File
* manager SCF, driver scdwv (built beside it from level1/modules/scdwv.asm), over the dwio already in the wildbits
* bootfiles. Load both (load scdwv dwm) and type /dwm into MIDI Modes > MIDI devices.
* 2026-10-04: moved from the s9 port (cmds/dwm.asm) so the Level 2 bootfile carries it; Addr is set here.

                    nam       dwm
                    ttl       DriveWire MIDI Device Descriptor

                    ifp1
                    use       defsfile
                    endc

Addr                equ       14                  DriveWire server MIDI channel
tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $07

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       SHARE.+UPDAT.       mode byte
                    fcb       HW.Page             extended controller address
                    fdb       $FF00+Addr          physical controller address (the low byte is the channel)
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
                    fdb       name                copy of descriptor name address
                    fcb       $00                 acia xon char (not used)
                    fcb       $00                 acia xoff char (not used)
                    fcb       80                  (szx) number of columns for display
                    fcb       24                  (szy) number of rows for display
initsize            equ       *

name                fcs       /dwm/
mgrnam              fcs       /SCF/
drvnam              fcs       /scdwv/

                    emod
eom                 equ       *
                    end
