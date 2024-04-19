********************************************************************
* SysGo - Kickstart program module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/03/06  Boisy G. Pitre
* Forked from CoCo 3 specific port.

                    nam       SysGo
                    ttl       Kickstart program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       $01

                    mod       eom,name,tylg,atrv,start,size


                    org       0
InitAddr            rmb       2
                    rmb       250
size                equ       .

name                fcs       /SysGo/
                    fcb       edition

* Default process priority
DefPrior            set       128
                    
CrRtn               fcb       C$CR,C$LF

DefDev              fcc       "/DD"
                    fcb       C$CR
ExecDir             fcc       "/DD/CMDS"
                    fcb       C$CR

Shell               fcc       "Shell"
                    fcb       C$CR
AutoEx              fcc       "AutoEx"
                    fcb       C$CR
AutoExPr            fcc       ""
                    fcb       C$CR
AutoExPrL           equ       *-AutoExPr

Startup             fcc       "startup -p"
                    fcb       C$CR
StartupL            equ       *-Startup

ShellPrm            equ       *
                    ifgt      Level-1
                    fcc       "i=/1"
                    endc
CRtn                fcb       C$CR
ShellPL             equ       *-ShellPrm

* Default time packet
* Set to 59 seconds so that at 00 seconds, the RTC (if any) can set the time.
* If no RTC is available, then the soft clock starts at January 1 of the new year.
DefTime             fcb       85,12,31,23,59,59

Init                fcs       /Init/

* Entry: X = pointer to start of nul terminated string
* Exit:  D = length of string
strlen              pshs      x
                    ldd       #-1
go@                 addd      #$0001
                    tst       ,x+
                    bne       go@
                    puls      x,pc

* Display carriage-return/line-feed.
WriteCR             pshs      y
                    leax      CrRtn,pcr
                    ldy       #$0001
                    os9       I$WritLn
                    puls      y,pc

Banner              fcb       $1b,$20,$02,$00,$00,80,30,0,1,1
BannerL             equ       *-Banner

**********************************************************
* SysGo Entry Point
**********************************************************
start               leax      >IcptRtn,pcr
                    os9       F$Icpt
* Set priority of this process
                    os9       F$ID
                    ldb       #DefPrior
                    os9       F$SPrior

* Show banner
                    leax      >Banner,pcr
                    ldy       #BannerL
                    lda       #$01                standard output
                    os9       I$Write             write out banner

* Write OS name and Machine name strings
                    leax      Init,pcr
                    clra
                    pshs      u
                    os9       F$Link
                    bcs       SignOn
                    stx       <InitAddr
                    ldd       OSName,u            point to OS name in INIT module
                    leax      d,u                 point to install name in INIT module
                    bsr       strlen
                    tfr       d,y
                    lda       #$01
                    os9       I$Write
                    bsr       WriteCR
                    ldd       InstallName,u
                    leax      d,u                 point to install name in INIT module
                    bsr       strlen
                    tfr       d,y
                    lda       #$01
                    os9       I$Write
                    bsr       WriteCR

SignOn
                    puls      u
* Set default time
                    leax      >DefTime,pcr
                    os9       F$STime             set time to default

* Change EXEC and DATA dirs
                    leax      >DefDev,pcr
                    lda       #READ.
                    os9       I$ChgDir            change the data directory
                    leax      >ExecDir,pcr
                    lda       #EXEC.
                    os9       I$ChgDir            change the execution directory

L0125               equ       *
                    pshs      u,y
                    ifgt      Level-1
                    os9       F$ID                get process ID
                    lbcs      L01A9               fail
                    leax      ,u
                    os9       F$GPrDsc            get process descriptor copy
                    lbcs      L01A9               fail
                    leay      ,u
                    ldx       #$0000
                    ldb       #$01
                    os9       F$MapBlk
                    bcs       L01A9

* Copy our default I/O ptrs to the system process
                    ldd       <D.SysPrc,u
                    leau      d,u
                    leau      <P$DIO,u
                    leay      <P$DIO,y
                    ldb       #DefIOSiz-1
L0151               lda       b,y
                    sta       b,u
                    decb
                    bpl       L0151
                    endc

* Fork shell startup here
DoStartup           leax      >Shell,pcr
                    leau      >Startup,pcr
                    ldd       #256
                    ldy       #StartupL
                    os9       F$Fork
                    bcs       DoAuto              startup failed
                    os9       F$Wait

* Fork AutoEx here
DoAuto              leax      >AutoEx,pcr
                    leau      >CRtn,pcr
                    ldd       #$0100
                    ldy       #$0001
                    os9       F$Fork
                    bcs       L0186               autoex failed
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
                    ifgt      Level-1
                    os9       F$Chain             this should not return
                    ldb       #$06                it did! Fatal. Load error code
                    bra       Crash
L01A9               ldb       #$04                error code
Crash               jmp       <D.Crash            fatal error
                    else
                    os9       F$Fork              perform the fork
                    bcs       DeadEnd             branch if error
                    os9       F$Wait              else wait
                    bcc       FrkShell            and refork if no error
DeadEnd             bra       DeadEnd             else loop forever
                    endc

IcptRtn             rti

                    emod
eom                 equ       *
                    end
