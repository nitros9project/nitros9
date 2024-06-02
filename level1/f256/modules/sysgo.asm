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
SignOn
                    puls      u
                    leax      Logo,pcr            point to Nitros-9 banner
                    ldy       #LogoLen
                    lda       #$01                standard output
                    os9       I$Write
                    leax      BLogo,pcr           newline
                    ldy       #BLogoLen
                    os9       I$Writln
                    leax      ColorBar,pcr        point to color bar
                    ldy       #CBLen
                    os9       I$Write
                    leax      CrRtn,pcr
                    ldy       #$0001
                    os9       I$WritLn

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

Logo                
                    fcb $1B,$20,$02,$00,$00,$50,$18,$01,$06,$04
*                    fcb $1B,$33,$06,$1B,$32,$01,$0C                   set BG blue,FG wht, CLS, NewLine
                    fcb	$1B,$32,$06,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB					center outline
                    fcb	$1B,$32,$00,$5F,$5F,$5F,$1B,$32,$06,$5F	outline
                    fcb	$5F,$5F,$5F,$1B,$32,$00,$5F,$5F,$1B,$32
                    fcb	$06,$5F,$1B,$32,$00,$5F,$5F,$1B,$32,$06
                    fcb	$5F,$5F,$5F,$5F,$1B,$32,$00,$5F,$5F,$1B
                    fcb	$32,$06,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F        
                    fcb	$1B,$32,$06,$5F,$5F,$5F,$5F,$1B,$32,$00
                    fcb	$5F,$5F,$5F,$5F,$5F,$5F,$1B,$32,$0B,$5F
                    fcb	$1B,$32,$06,$5F,$5F,$1B,$32,$00,$5F,$5F        
                    fcb	$5F,$5F,$5F,$1B,$32,$0B,$5F,$1B,$32,$06
                    fcb	$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$1B
                    fcb	$32,$00,$5F,$5F,$5F,$5F,$5F,$1B,$32,$0B
                    fcb	$5F,$1B,$32,$06,$5F,$5F,$5F,$DD,$DD,$DD
                    fcb	$DD,$DD,$DD,$DD,$DD
                    fcb	$1B,$32,$06,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB					center line
                    fcb	$1B,$32,$02,$DB,$DB,$DB,$BC,$1B,$32,$06
                    fcb	$DB,$DB,$DB,$1B,$32,$02,$DB,$DB,$1B,$32
                    fcb	$00,$B3,$1B,$32,$08,$DB,$DB,$1B,$32,$00
                    fcb	$B3,$1B,$32,$06,$DB,$1B,$32,$00,$5F,$5F	
                    fcb	$1B,$32,$07,$DB,$DB,$1B,$32,$00,$B4,$5F
                    fcb	$5F,$1B,$32,$06,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$1B,$32,$01,$B5,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$1B,$33,$0B,$B7,$1B,$33,$06,$1B
                    fcb	$32,$0B,$B3,$1B,$32,$01,$B5,$DB,$DB,$DB
                    fcb	$DB,$DB,$1B,$33,$0B,$B7,$1B,$33,$06,$1B
                    fcb	$32,$0B,$B3,$1B,$32,$06,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$DB,$1B,$32,$01,$B5,$DB,$DB,$DB
                    fcb	$DB,$DB,$1B,$33,$0B,$B7,$1B,$33,$06,$1B
                    fcb	$32,$0B,$B3,$1B,$32,$06,$DB,$DB,$DB,$DB
                    fcb	$DB,$1B,$32					end line 1
                    fcb	$06,$DD,$DD,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$DB,$DB,$DB				center line
                    fcb	$1B,$32,$02,$DB,$DB,$BB,$DB,$BC,$1B,$32
                    fcb	$06,$DB,$DB,$1B,$32,$02,$DB,$DB,$1B,$32
                    fcb	$00,$B3,$5F,$5F,$1B,$32,$06,$DB,$1B,$32
                    fcb	$00,$1B,$32,$07,$B9,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$1B,$32,$00,$B3,$1B,$32,$06,$DB
                    fcb	$1B,$32,$00,$5F,$5F,$5F,$5F,$1B,$32,$0B
                    fcb	$5F,$1B,$32,$06,$DB,$1B,$32,$01,$DB,$DB
                    fcb	$1B,$32,$00,$B3,$1B,$32,$06,$DB,$DB,$DB
                    fcb	$1B,$32,$01,$DB,$DB,$1B,$32,$0B,$B3,$1B
                    fcb	$32,$01,$DB,$DB,$1B,$32,$00,$B4,$5F,$5F
                    fcb	$5F,$1B,$32,$0B,$5F,$1B,$32,$06,$DB,$1B
                    fcb	$32,$00,$5F,$5F,$5F,$5F,$5F,$5F,$1B,$32
                    fcb	$06,$DB,$1B,$32,$01,$DB,$DB,$1B,$32,$00
                    fcb	$B4,$5F,$5F,$1B,$32,$01,$DB,$DB,$1B,$32
                    fcb	$0B,$B3					end line 2
                    fcb	$1B,$32,$06,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB	center line
                    fcb	$DB,$DB,$1B,$32,$02,$DB,$DB,$1B,$32,$06
                    fcb	$DB,$1B,$32,$02,$BB,$DB,$BC,$1B,$32,$06
                    fcb	$DB,$1B,$32,$02,$DB,$DB,$1B,$32,$00,$B3
                    fcb	$1B,$32,$08,$DB,$DB,$1B,$32,$00,$B3,$1B
                    fcb	$32,$06,$DB,$DB,$DB,$1B,$32,$07,$DB,$DB
                    fcb	$1B,$32,$00,$B3,$1B,$32,$06,$DB,$DB,$DB
                    fcb	$1B,$32,$05,$B5,$DB,$DB,$DB,$DB,$1B,$33
                    fcb	$06,$1B,$33,$0B,$B7,$1B,$33,$06,$1B,$32
                    fcb	$0B,$B3,$1B,$32,$01,$DB,$DB,$1B,$32,$00
                    fcb	$B3,$1B,$32,$06,$DB,$DB,$DB,$1B,$32,$01
                    fcb	$DB,$DB,$1B,$32,$0B,$B3,$1B,$32,$01,$B6
                    fcb	$DB,$DB,$DB,$DB,$DB,$1B,$33,$0B,$B7,$1B
                    fcb	$33,$06,$1B,$32,$0B,$B3,$1B,$32,$01,$DB
                    fcb	$DB,$1B,$32,$0F,$DB,$1B,$32,$0C,$DB,$1B
                    fcb	$32,$0B,$DB,$1B,$32,$00,$DB,$1B,$32,$06
                    fcb	$DB,$1B,$32,$01,$B6,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$1B,$32,$0B,$B3				end line 3
                    fcb	$1B,$32,$06,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB	center line
                    fcb	$DB,$DB,$1B,$32,$02,$DB,$DB,$1B,$32,$06
                    fcb	$DB,$DB,$1B,$32,$02,$BB,$DB,$BC,$DB,$DB
                    fcb	$1B,$32,$00,$B3,$1B,$32,$08,$DB,$DB,$1B
                    fcb	$32,$00,$B3,$1B,$32,$06,$DB,$DB,$DB,$1B
                    fcb	$32,$07,$DB,$DB,$1B,$32,$00,$B4,$5F,$1B
                    fcb	$32,$06,$DB,$DB,$1B,$32,$05,$DB,$DB,$1B
                    fcb	$32,$00,$B3,$1B,$32,$06,$DB,$DB,$1B,$32
                    fcb	$05,$DF,$1B,$32,$06,$DB,$1B,$32,$01,$DB
                    fcb	$DB,$1B,$32,$00,$B4,$5F,$5F,$5F,$1B,$32
                    fcb	$01,$DB,$DB,$1B,$32,$0B,$B3,$1B,$32,$06
                    fcb	$DB,$1B,$32,$00,$5F,$5F,$5F,$5F,$1B,$32
                    fcb	$01,$DB,$DB,$1B,$32,$0B,$B3,$1B,$32,$06
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$1B,$32
                    fcb	$00,$5F,$5F,$5F,$5F,$1B,$32,$01,$DB,$DB
                    fcb	$1B,$32,$0B,$B3				end line 4
                    fcb	$1B,$32,$06,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB	
                    fcb	$DB,$DB					center font
                    fcb	$1B,$32,$02,$DB,$DB,$1B,$32,$06,$DB,$DB
                    fcb	$DB,$1B,$32,$02,$BB,$DB,$DB,$DB,$1B,$32
                    fcb	$00,$B3,$1B,$32,$08,$DB,$DB,$1B,$32,$00
                    fcb	$B3,$1B,$32,$06,$DB,$DB,$DB,$1B,$32,$07
                    fcb	$DB,$DB,$DB,$BA,$1B,$32,$06,$DB,$DB,$1B
                    fcb	$32,$05,$DB,$DB,$1B,$32,$00,$B3,$1B,$32
                    fcb	$06,$DB,$DB,$DB,$DB,$1B,$32,$01,$B6,$DB
                    fcb	$DB,$DB,$DB,$DB,$DB,$B8,$1B,$32,$06,$DB
                    fcb	$1B,$32,$01,$B9,$DB,$DB,$DB,$DB,$DB,$B8
                    fcb	$1B,$32,$06,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$1B,$32,$01,$B9,$DB,$DB,$DB,$DB,$DB
                    fcb	$B8						end line 5
                    fcb	$1B,$32,$06,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB,$1B,$32,$01		reset FG white	
LogoLen             equ	*-Logo
ColorBar            fcb	$1B,$32,$06
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB	center bar
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$1B,$32,$02,$DF,$DF,$DF,$1B,$32,$08,$DF	color bar
                    fcb	$DF,$DF,$1B,$32,$07,$DF,$DF,$DF,$1B,$32
                    fcb	$05,$DF,$DF,$DF,$1B,$32,$0E,$DF,$DF,$DF
                    fcb	$1B,$32,$04,$DF,$DF,$DF,$1B,$32,$01,$DF
                    fcb	$DF,$DF,$1B,$32,$0F,$DF,$DF,$DF,$1B,$32
                    fcb	$0C,$DF,$DF,$DF,$1B,$32,$0B,$DF,$DF,$DF
                    fcb	$1B,$32,$03,$DF,$DF,$DF,$1B,$32,$0A,$DF
                    fcb	$DF,$DF,$1B,$32,$0D,$DF,$DF,$DF,$1B,$32
                    fcb	$09,$DF,$DF,$DF,$1B,$32,$00,$DF,$DF,$DF
                    fcb	$1B,$32,$01					reset FG White
CBLen               equ	*-ColorBar
BLogo               fcb	$1B,$32,$06,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB		center line
                    fcb	$1B,$32,$00,$5F,$5F,$5F,$5F,$5F,$5F,$5F
                    fcb	$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F
                    fcb	$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F
                    fcb	$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F
                    fcb	$5F,$5F,$5F,$5F,$5F,$5F,$5F,$5F
                    fcb	C$CR,C$LF
BLogoLen            equ	*-BLogo

                    emod
eom                 equ       *
                    end
