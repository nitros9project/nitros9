********************************************************************
* SysGo - Kickstart program module
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/03/06  Boisy G. Pitre
* Forked from CoCo 3 specific port.
*
*   2      2025/08/23  Matt Massie
* Support Wildbits K,K2,Jr,Jr2 models.
*
*   3      2025/12/26  Matt Massie
* Forks scfg -dl to  load default palettes for models or reads
* sys/defaultsettings for foreground, background, screen size, font to load. 

                    section   bss
InitAddr            rmb       2                    
                    rmb       100
                    endsect
                    
* Default process priority
DefPrior            set       128
                    
                    section   code
ExecDir             fcc       ".../CMDS"
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

InitScrn            fcc       "scfg"
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

* Identity routine
* Exit: A = $02 (Wildbits/Jr), $12 (Wildbits/K), $1A (Wildbits/Jr2), $16 (Wildbits/K2)

ShowMachType        ldx       #SYS0
                    lda       7,x
                    cmpa      #$02                          Jr?
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

* Set default time
                    leax      DefTime,pcr
                    os9       F$STime             set current time to start ticker (RTC will update time at top of minute)

* Change DATA & EXEC directories
                    leax      Init,pcr
                    clra
                    pshs      u
                    os9       F$Link
                    tfr       u,x
                    puls      u
                    lbcs      DeadEnd
                    stx       InitAddr,u
                    ldd       SysStr,x
                    leax      d,x
                    lda       #READ.
                    os9       I$ChgDir
                    lbcs      DeadEnd
                    leax      >ExecDir,pcr
                    lda       #EXEC.
                    os9       I$ChgDir            change the execution directory

* Fork scfg -dl here
* sets sys/defaultsettings if exists
* Show banner
DoScrnInit          pshs      u
                    leax      >InitScrn,pcr
                    leau      >InitScrn2,pcr
                    ldd       #256
                    ldy       #InitScrnL2
                    os9       F$Fork
                    bcs       Next@               startup failed
                    os9       F$Wait
Next@               puls      u

* Write OS name and Machine name strings
DoInit              ldx       InitAddr,u
                    ldd       OSName,x            point to OS name in INIT module
                    leax      d,x                 
                    lbsr      PUTS
                    lbsr      PUTCR
                    ldx       InitAddr,u
                    ldd       InstallName,x       point to install name in INIT module
                    leax      d,x
                    lbsr      PUTS
                    lbsr      ShowMachType
                    lbsr      PUTCR
                    pshs      u,y

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
                    ldd       #256
                    ldy       #$0001
                    os9       F$Fork
                    bcs       next@               autoex failed
                    os9       F$Wait
next@               puls      u,y
FrkShell            leax      >ShellPrm,pcr
                    leay      ,u
                    ldb       #ShellPL
loop@               lda       ,x+
                    sta       ,y+
                    decb
                    bne       loop@
* Fork final shell here
                    leax      >Shell,pcr
                    lda       #$01                D = 256 (B already 0 from above)
                    ldy       #ShellPL
                    ifgt      Level-1
                    os9       F$Chain             this should not return
                    ldb       #$06                it did! Fatal. Load error code
                    bra       Crash
DeadEnd             ldb       #$04                error code
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
