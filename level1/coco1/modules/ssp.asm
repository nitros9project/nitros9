********************************************************************
* SSP - Speech-Sound Pak device descriptor
*
* by Bruce Isted (CIS 76625,2273)
* released to the Public Domain 87/05/02

* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          ????/??/??

                    nam       SSP
                    ttl       Speech-Sound Pak device descriptor

                    ifp1
                    use       defsfile
                    endc

PageAddr            equ       $07                 extended page address (set to $FF for level 1)
PortAddr            equ       $FF7D               Speech-Sound Pak base address
SVrsn               equ       $00

                    mod       SEnd,SNam,Devic+Objct,ReEnt+SVrsn,MgrNam,DrivrNam
                    fcb       SHARE.+PWRIT.+WRITE. device capabilities
                    fcb       PageAddr
                    fdb       PortAddr
                    fcb       SOptEnd-*-1         option table size
                    fcb       DT.SCF              device type
                    fcb       $00                 case (0=both, 1=upper only)
                    fcb       $00                 backspace (0=bse, 1=bse,sp,bse)
                    fcb       $01                 delete (0=bse over line, 1=CR)
                    fcb       $00                 echo (1=echo)
                    fcb       $00                 auto LF (0=no auto LF)
                    fcb       $00                 EOL null count
                    fcb       $00                 pause (1=page pause)
                    fcb       $00                 lines per page
                    fcb       C$BSP               backspace character
                    fcb       $18                 delete line character
                    fcb       C$CR                end of record character
                    fcb       $00                 end of file character
                    fcb       $04                 reprint line character
                    fcb       $01                 dup last line character
                    fcb       $00                 pause character
                    fcb       $00                 interrupt character
                    fcb       $00                 quit character
                    fcb       $00                 backspace echo character (bse)
                    fcb       $00                 line overflow character
                    fcb       $00                 initialization value (parity)
                    fcb       $00                 baud rate
                    fdb       $0000               attached device name offset
                    fcb       $00                 xon character
                    fcb       $00                 xoff character
SOptEnd             equ       *
SNam                fcs       "SSP"
MgrNam              fcs       "SCF"
DrivrNam            fcs       "SSPak"

                    emod
SEnd                equ       *
                    end

