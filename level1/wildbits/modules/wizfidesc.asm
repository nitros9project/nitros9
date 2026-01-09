********************************************************************
* wizfidesc - WizFi360 device descriptor
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

                    ifp1
                    use       defsfile
                    endc

tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $07

Base                set       $FF20
*Connection          set       $0
*DeviceMode          set       $08

                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       UPDAT.       mode byte
                    fcb       HW.Page             extended controller address
                    fdb       Base+Connection+DeviceMode               physical controller address has extra info
                    fcb       initsize-*-1        initilization table size
                    fcb       DT.SCF              device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       $00                 case:0=up&lower,1=upper only
                    fcb       $01                 backspace:0=bsp,1=bsp then sp & bsp
                    fcb       $00                 delete:0=bsp over line,1=return
                    fcb       $01                 echo:0=no echo
                    fcb       $01                 auto line feed:0=off
                    fcb       $00                 end of line null count
                    fcb       $00                 pause:0=no end of page pause
                    fcb       60                  lines per page (not a safe assumption anymore!)
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
                    fcb       PARNONE             parity
                    fcb       STOP1+WORD8+1       stop bits/word size/baud rate
                    fdb       name                copy of descriptor name address
                    fcb       $00                 acia xon char (not used, maybe future assignment?)
                    fcb       $00                 acia xoff char (not used, maybe future assignment?)
                    fcb       80                  (szx) number of columns for display
                    fcb       60                  (szy) number of rows for display
                    fcb       $00                 Extended type
initsize            equ       *

name                equ       *
 ifeq DeviceMode
  fcs /wz/
  else
                    fcc       /wz/
                    fcb       Connection+$30+$80
 endc                    
mgrnam              fcs       /scf/
drvnam              fcs       /wizfi/

                    emod
eom                 equ       *
                    end

