********************************************************************
* SysGo - Kickstart program module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      2023/09/25  Boisy G. Pitre
* Custom SysGo for FEU
*

                    nam       SysGo
                    ttl       Kickstart program module

                    use       ../defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       $00

                    mod       eom,name,tylg,atrv,start,size

                    org       0
                    rmb       250
size                equ       .

name                fcs       /SysGo/
                    fcb       edition

* Default process priority
DefPrior            set       128

DefDev              equ       *
                    fcc       "/DD"
                    fcb       C$CR
ExecDir             equ       *
                    fcc       "CMDS"
                    fcb       C$CR

Shell               fcc       "Shell"
                    fcb       C$CR
AutoEx              fcc       "AutoEx"
                    fcb       C$CR
AutoExPr            fcc       ""
                    fcb       C$CR
AutoExPrL           equ       *-AutoExPr

ShellPrm            equ       *
CRtn                fcb       C$CR
ShellPL             equ       *-ShellPrm

* Default time packet
DefTime             fcb       86,1,1,0,0,0

Init                fcs       /Init/

**********************************************************
* SysGo Entry Point
**********************************************************
start               leax      >IcptRtn,pcr
                    os9       F$Icpt
* Set priority of this process
                    os9       F$ID
                    ldb       #DefPrior
                    os9       F$SPrior

* Set default time
                    leax      >DefTime,pcr
                    os9       F$STime             set time to default

* Change EXEC and DATA dirs
                    leax      >ExecDir,pcr
                    lda       #EXEC.
                    os9       I$ChgDir            change exec. dir
                    leax      >DefDev,pcr

* Made READ. so that no write occurs at boot (Boisy on Feb 5, 2012)
                    lda       #READ.
                    os9       I$ChgDir            change data dir.
                    bcs       L0125

L0125               equ       *
                    pshs      u,y

* Fork AutoEx here
DoAuto              leax      >AutoEx,pcr
                    leau      >CRtn,pcr
                    ldd       #$0100
                    ldy       #$0001
                    os9       F$Fork
                    bcs       L0186               AutoEx failed..
                    os9       F$Wait

L0186               equ       *
                    puls      u,y
FrkShell            leax      >ShellPrm,pcr
                    leay      ,u
                    ldb       #ShellPL
L0190               lda       ,x+
                    sta       ,y+
                    decb
                    bne       L0190
* Fork final shell here
                    leax      >Shell,pcr
                    lda       #$01                D = 256 (B already 0 from above)
                    ldy       #ShellPL
                    os9       F$Fork              Level 1.
                    bcs       DeadEnd             Fatal.
                    os9       F$Wait
                    bcc       FrkShell            OK, go start shell.
DeadEnd             bra       DeadEnd

IcptRtn             rti

                    emod
eom                 equ       *
                    end
