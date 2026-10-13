                    ifp1
                    use defsfile
                    endc
tylg equ Devic+Objct
atrv equ ReEnt+1
                    mod       eom,name,tylg,atrv,mgrnam,drvnam

                    fcb       UPDAT.       mode byte
                    fcb       HW.Page             extended controller address
                    fdb       RP.Control               fixed K2 mailbox control address
                    fcb       initsize-*-1        initilization table size
                    fcb       DT.SCF              device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       $00                 case:0=up&lower,1=upper only
                    fcb       $01                 backspace:0=bsp,1=bsp then sp & bsp
                    fcb       $00                 delete:0=bsp over line,1=return
                    fcb       $00                 echo:0=no echo (MUST be zero $00)
                    fcb       $00                 auto line feed:0=off
                    fcb       $00                 end of line null count
                    fcb       $00                 pause:0=no end of page pause
                    fcb       60                  lines per page (not a safe assumption anymore!)
                    fcb       C$BSP               backspace character (on most telnet clients)
                    fcb       C$DEL               delete line character
                    fcb       $00                 binary reads must not stop on CR
                    fcb       C$EOF               end of file character
                    fcb       C$RPRT              reprint line character
                    fcb       C$RPET              duplicate last line character
                    fcb       C$PAUS              pause character
                    fcb       C$INTR              interrupt character
                    fcb       C$QUIT              quit character
                    fcb       C$BSP               backspace echo character
                    fcb       C$BELL              line overflow character (bell)
                    fcb       PARNONE             parity
                    fcb       STOP1+WORD8 8-bit transparent transport
                    fdb       name                copy of descriptor name address
                    fcb       $00                 acia xon char (not used, maybe future assignment?)
                    fcb       $00                 acia xoff char (not used, maybe future assignment?)
                    fcb       80                  (szx) number of columns for display
                    fcb       60                  (szy) number of rows for display
                    fcb       $00                 Extended type
initsize            equ       *

name fcs /rp/
mgrnam fcs /SCF/
drvnam fcs /RPDrv/
 emod
eom equ *
 end
