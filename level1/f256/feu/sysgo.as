********************************************************************
* SysGo - Kickstart program module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2023/09/25  Boisy G. Pitre
* Custom SysGo for FEU.

                    section   bss
stack               rmb       200
                    endsect
                    
                    section   code

* Device table -- we try to I$ChgDir to each of these devices until one works.
* NOTE: It's assumed in the code that each device descriptor is 7 bytes in length!
DevTable            fcc       "/c0/feu"
                    fcb       C$CR
                    fcc       "/s0/feu"
                    fcb       C$CR
*                    fcc       "/x0"
*                    fcb       C$CR
                    fcc       "/f0/feu"
                    fcb       C$CR
                    fcb       $00
                    
* Default process priority
DefPrior            set       128

ExecDir             equ       *
                    fcc       "..../CMDS"
                    fcb       C$CR
ExecDirL            equ       *-ExecDir

Shell               fcc       "shell"
                    fcb       C$CR

Startup             fcc       "startup -p"
                    fcb       C$CR
StartupL            equ       *-Startup

ShellPrm            equ       *
CRtn                fcb       C$CR
ShellPL             equ       *-ShellPrm

* Default time packet
DefTime             fcb       86,1,1,0,0,0

Init                fcs       /Init/

**********************************************************
* SysGo Entry Point
**********************************************************
__start             leax      >IcptRtn,pcr
                    os9       F$Icpt
* Set priority of this process
                    os9       F$ID
                    ldb       #DefPrior
                    os9       F$SPrior

* Set default time
                    leax      >DefTime,pcr
                    os9       F$STime             set time to default

                    leax      >DevTable,pcr
trynext@
                    lda       #READ.
                    os9       I$ChgDir
                    bcc       DoExec
                    leax      8,x
                    tst       ,x                  at end of table?
                    bne       trynext@

DoExec              leax      -7,x
                    lda       #EXEC.
                    os9       I$ChgDir
                    leax      ExecDir,pcr
                    os9       I$ChgDir

* Check if SHIFT key is held down -- if so, bypass startup
                    lda       #1
                    ldb       #SS.KySns
                    os9       I$GetStt
                    bcs       FrkShell
                    bita      #SHIFTBIT  check for SHIFT down
                    bne       FrkShell  bypass startup if down
                    
* Fork shell startup here
DoStartup           equ       *
                    pshs      u,y
                    leax      >Shell,pcr
                    leau      >Startup,pcr
                    ldd       #(Prgrm+Objct)*256+4
                    ldy       #StartupL
                    os9       F$Fork
                    bcs       cont@              startup failed
                    os9       F$Wait
cont@
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
                    ldd       #(Prgrm+Objct)*256+4
                    ldy       #ShellPL
                    os9       F$Fork              Level 1.
                    bcs       DeadEnd             Fatal.
                    os9       F$Wait
                    bcc       FrkShell            OK, go start shell.
DeadEnd             bra       DeadEnd

IcptRtn             rti

                    endsect
                    