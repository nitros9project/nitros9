                    nam       P1
                    ttl       os9 device descriptor

* Disassembled 1900/00/00 00:26:38 by Disasm v1.5 (C) 1988 by RML

                    ifp1
*         use   /dd/defs/os9defs
                    use       defsfile
                    endc
tylg                set       Devic+Objct
atrv                set       ReEnt+rev
rev                 set       $01
                    mod       eom,name,tylg,atrv,mgrnam,drvnam
                    fcb       $03                 mode byte
                    fcb       $FF                 extended controller address
                    fdb       $FF04               physical controller address
                    fcb       initsize-*-1        initilization table size
                    fcb       $00                 device type:0=scf,1=rbf,2=pipe,3=scf
                    fcb       $00                 case:0=up&lower,1=upper only
                    fcb       $00                 backspace:0=bsp,1=bsp then sp & bsp
                    fcb       $00                 delete:0=bsp over line,1=return
                    fcb       $00                 echo:0=no echo
                    fcb       $01                 auto line feed:0=off
                    fcb       $00                 end of line null count
                    fcb       $00                 pause:0=no end of page pause
                    fcb       $42                 lines per page
                    fcb       $00                 backspace character
                    fcb       $00                 delete line character
                    fcb       $00                 end of record character
                    fcb       $00                 end of file character
                    fcb       $00                 reprint line character
                    fcb       $00                 duplicate last line character
                    fcb       $00                 pause character
                    fcb       $00                 interrupt character
                    fcb       $00                 quit character
                    fcb       $00                 backspace echo character
                    fcb       $00                 line overflow character (bell)
                    fcb       $00                 init value for dev ctl reg
                    fcb       $03                 baud rate
                    fdb       name                copy of descriptor name address
                    fcb       $11                 acia xon char
                    fcb       $13                 acia xoff char
initsize            equ       *
name                equ       *
                    fcs       /P1/
mgrnam              equ       *
                    fcs       /scf/
drvnam              equ       *
                    fcs       /acia51/
                    emod
eom                 equ       *
                    end
