********************************************************************
* SysGo - Kickstart program module
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/03/06  Boisy G. Pitre
* Forked from CoCo 3 specific port.
*   2      2025/08/23  Matt Massie
* supports F256 K,K2,Jr,Jr2 models.
*   3      2025/12/26  Matt Massie - this version forks fcfg -dl to load default palettes for models or reads 
* sys/defaultsettings for foreground, background, screen size, font to load. 

                    section   bss
timebuf             rmb         6
                    rmb       100
                    endsect
                    
* Default process priority
DefPrior            set       128
                    
                    section   code
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

InitScrn            fcc       "/dd/cmds/fcfg"
                    fcb       C$CR
InitScrn2           fcc       "-dl"
                    fcb       C$CR
InitScrnL2          equ       *-InitScrn2

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

* F256 identity routine
* Exit: A = $02 (F256 Jr), $12 (F256K), $1A (F256 Jr2), $16 (F256K2)
F256Type            pshs      x
                    ldx       #SYS0
                    lda       7,x
                    puls      x,pc

ShowMachType        bsr       F256Type
                    cmpa      #$02                          F256 Jr?
                    beq       @showJr
                    cmpa      #$16
                    beq       @showK2
                    cmpa      #$1A
                    beq       @showJr2
                    cmpa      #$12
                    bne       bye@
@showK              ldb       #'K
                    lbra      PUTC
@showK2             bsr       @showK
                    bra       @show2
@showJr             lbsr      PRINTS
                    fcc       " Jr"
                    fcb       0
bye@                rts
@showJr2            bsr       @showJr
@show2              ldb       #'2
                    lbra      PUTC
                                                                                
**********************************************************
* SysGo Entry Point
**********************************************************
__start             leax      >IcptRtn,pcr
                    os9       F$Icpt

* Set priority of this process
                    os9       F$ID
                    ldb       #DefPrior
                    os9       F$SPrior

* Fork fcfg -d here
* sets sys/defaultsettings if exists
* Show banner
DoScrnInit          pshs      x,y,u,b,a
                    leax      >InitScrn,pcr
                    leau      >InitScrn2,pcr
                    ldd       #$0100
                    ldy       #InitScrnL2
                    os9       F$Fork
                    bcs       Next@               startup failed
                    os9       F$Wait
Next@               puls      x,y,u,b,a

* Write OS name and Machine name strings
DoInit              leax      Init,pcr
                    clra
                    pshs      u
                    os9       F$Link
                    bcs       SetDefTime
                    ldd       OSName,u            point to OS name in INIT module
                    leax      d,u                 
                    lbsr      PUTS
                    lbsr      PUTCR
                    ldd       InstallName,u       point to install name in INIT module
                    leax      d,u
                    lbsr      PUTS
                    lbsr      ShowMachType
                    lbsr      PUTCR

* Set default time
SetDefTime          puls      u
                    leax      timebuf,u
                    os9       F$Time              get current time
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

                    endsect
