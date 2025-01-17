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

                    section   bss
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

SetupPalette        bsr       F256Type
                    cmpa      #$02                          F256 Jr?
                    beq       @showJr
@showK              leax      KPal,pcr
                    ldy       #KPalLen
                    bra       show@
@showJr             leax      JrPal,pcr
                    ldy       #JrPalLen
show@               lda       #1
                    os9       I$Write
                    lbra      PUTCR
                                                                                
**********************************************************
* SysGo Entry Point
**********************************************************
__start             leax      >IcptRtn,pcr
                    os9       F$Icpt

* Set priority of this process
                    os9       F$ID
                    ldb       #DefPrior
                    os9       F$SPrior

* Show banner
SignOn              bsr       SetupPalette
                    leax      Logo,pcr            point to Nitros-9 banner
                    ldy       #LogoLen
                    lda       #$01                standard output
                    os9       I$Write
                    leax      BLogo,pcr           newline
                    ldy       #BLogoLen
                    os9       I$Write
                    leax      ColorBar,pcr        point to color bar
                    ldy       #CBLen
                    os9       I$Write
                    lbsr      PUTCR

* Write OS name and Machine name strings
                    leax      Init,pcr
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


FGP                 set $07
BGP                 set $0A

UCH                 set $5F

KPal
* Set up 80x30 window with foreground and background colors as same
                    fcb $1B,$20,$02,$00,$00,$50,$18,BGP,BGP,$00
                    fcb $1B,$60,FGP,$FF,$FF,$00,$FF
                    fcb $1B,$60,BGP,$4F,$00,$80,$FF
                    fcb $1B,$61,BGP,$4F,$00,$80,$FF
KPalLen             equ *-KPal                    

JrPal
* Set up 80x30 window with foreground and background colors as same
                    fcb $1B,$20,$02,$00,$00,$50,$18,BGP,BGP,$00
                    fcb $1B,$60,FGP,$FF,$FF,$00,$FF
                    fcb $1B,$60,BGP,$50,$00,$00,$FF
                    fcb $1B,$61,BGP,$50,$00,$00,$FF
JrPalLen            equ *-JrPal                    

Logo                
* Draw first line
                    fcb $DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB					center outline
                    fcb	$1B,$32,$00
                    fcb UCH,UCH,UCH
                    fcb $1B,$32,BGP
                    fcb	UCH,UCH,UCH,UCH
                    fcb $1B,$32,$00
                    fcb UCH,UCH                                             outline
                    fcb $1B,$32,BGP
                    fcb	UCH
                    fcb $1B,$32,$00
                    fcb UCH,UCH
                    fcb $1B,$32,BGP
                    fcb	UCH,UCH,UCH,UCH
                    fcb $1B,$32,$00
                    fcb UCH,UCH
                    fcb $1B,$32,BGP
                    fcb UCH,UCH,UCH,UCH,UCH,UCH,UCH,UCH        
                    fcb	$1B,$32,BGP
                    fcb UCH,UCH,UCH,UCH
                    fcb $1B,$32,$00
                    fcb	UCH,UCH,UCH,UCH,UCH,UCH
                    fcb $1B,$32,$0B
                    fcb UCH
                    fcb	$1B,$32,BGP
                    fcb UCH,UCH
                    fcb $1B,$32,$00
                    fcb UCH,UCH        
                    fcb	UCH,UCH,UCH
                    fcb $1B,$32,$0B
                    fcb UCH
                    fcb $1B,$32,BGP
                    fcb	UCH,UCH,UCH,UCH,UCH,UCH,UCH,UCH,UCH
                    fcb $1B,$32,$00
                    fcb UCH,UCH,UCH,UCH,UCH
                    fcb $1B,$32,$0B
                    fcb	UCH
                    fcb $1B,$32,BGP
                    fcb UCH,UCH,UCH,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD
                    fcb	$1B,$32,BGP
                    fcb $DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB					center line
                    fcb	$1B,$32,$02
                    fcb $DB,$DB,$DB,$BC
                    fcb $1B,$32,BGP
                    fcb	$DB,$DB,$DB
                    fcb $1B,$32,$02
                    fcb $DB,$DB
                    fcb $1B,$32,$00,$B3
                    fcb $1B,$32,$08
                    fcb $DB,$DB
                    fcb $1B,$32,$00
                    fcb	$B3
                    fcb $1B,$32,BGP
                    fcb $DB
                    fcb $1B,$32,$00
                    fcb UCH,UCH	
                    fcb	$1B,$32,$07
                    fcb $DB,$DB
                    fcb $1B,$32,$00
                    fcb $B4,UCH,UCH
                    fcb $1B,$32,BGP
                    fcb $DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb $1B,$32,$01
                    fcb $B5,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb $1B,$33,$0B
                    fcb $B7
                    fcb $1B,$33,BGP
                    fcb $1B,$32,$0B
                    fcb $B3
                    fcb $1B,$32,$01
                    fcb $B5,$DB,$DB,$DB,$DB,$DB
                    fcb $1B,$33,$0B
                    fcb $B7
                    fcb $1B,$33,BGP
                    fcb $1B,$32,$0B
                    fcb $B3
                    fcb $1B,$32,BGP
                    fcb $DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb $1B,$32,$01
                    fcb $B5,$DB,$DB,$DB,$DB,$DB
                    fcb $1B,$33,$0B
                    fcb $B7
                    fcb $1B,$33,BGP
                    fcb $1B,$32,$0B
                    fcb $B3
                    fcb $1B,$32,BGP
                    fcb $DB,$DB,$DB,$DB,$DB
                    fcb $1B,$32,BGP					end line 1
                    fcb	$DD,$DD,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$DB,$DB,$DB				center line
                    fcb	$1B,$32,$02
                    fcb $DB,$DB,$BB,$DB,$BC
                    fcb $1B,$32,BGP
                    fcb $DB,$DB
                    fcb $1B,$32,$02
                    fcb $DB,$DB
                    fcb $1B,$32,$00
                    fcb $B3,UCH,UCH
                    fcb $1B,$32,BGP
                    fcb $DB
                    fcb $1B,$32,$00
                    fcb $1B,$32,$07
                    fcb $B9,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb $1B,$32,$00
                    fcb $B3
                    fcb $1B,$32,BGP
                    fcb $DB
                    fcb	$1B,$32,$00
                    fcb UCH,UCH,UCH,UCH
                    fcb $1B,$32,$0B
                    fcb	UCH
                    fcb $1B,$32,BGP
                    fcb $DB
                    fcb $1B,$32,$01
                    fcb $DB,$DB
                    fcb	$1B,$32,$00
                    fcb $B3
                    fcb $1B,$32,BGP
                    fcb $DB,$DB,$DB
                    fcb	$1B,$32,$01
                    fcb $DB,$DB
                    fcb $1B,$32,$0B
                    fcb $B3
                    fcb $1B,$32,$01
                    fcb $DB,$DB
                    fcb $1B,$32,$00
                    fcb $B4,UCH,UCH,UCH
                    fcb $1B,$32,$0B
                    fcb UCH
                    fcb $1B,$32,BGP
                    fcb $DB
                    fcb $1B,$32,$00
                    fcb UCH,UCH,UCH,UCH,UCH,UCH
                    fcb $1B,$32,BGP
                    fcb $DB
                    fcb $1B,$32,$01
                    fcb $DB,$DB
                    fcb $1B,$32,$00
                    fcb	$B4,UCH,UCH
                    fcb $1B,$32,$01
                    fcb $DB,$DB
                    fcb $1B,$32,$0B
                    fcb $B3					end line 2
                    fcb	$1B,$32,BGP
                    fcb $DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB	center line
                    fcb	$DB,$DB
                    fcb $1B,$32,$02
                    fcb $DB,$DB
                    fcb $1B,$32,BGP
                    fcb	$DB
                    fcb $1B,$32,$02
                    fcb $BB,$DB,$BC
                    fcb $1B,$32,BGP
                    fcb	$DB
                    fcb $1B,$32,$02
                    fcb $DB,$DB
                    fcb $1B,$32,$00,$B3
                    fcb	$1B,$32,$08
                    fcb $DB,$DB
                    fcb $1B,$32,$00
                    fcb $B3
                    fcb $1B,$32,BGP
                    fcb $DB,$DB,$DB
                    fcb $1B,$32,$07
                    fcb $DB,$DB
                    fcb	$1B,$32,$00
                    fcb $B3
                    fcb $1B,$32,BGP
                    fcb $DB,$DB,$DB
                    fcb	$1B,$32,$05
                    fcb $B5,$DB,$DB,$DB,$DB
                    fcb $1B,$33,BGP
                    fcb $1B,$33,$0B
                    fcb $B7
                    fcb $1B,$33,BGP
                    fcb $1B,$32,$0B
                    fcb $B3
                    fcb $1B,$32,$01
                    fcb $DB,$DB
                    fcb $1B,$32,$00
                    fcb	$B3
                    fcb $1B,$32,BGP
                    fcb $DB,$DB,$DB
                    fcb $1B,$32,$01
                    fcb	$DB,$DB
                    fcb $1B,$32,$0B
                    fcb $B3
                    fcb $1B,$32,$01
                    fcb $B6
                    fcb	$DB,$DB,$DB,$DB,$DB
                    fcb $1B,$33,$0B
                    fcb $B7
                    fcb $1B,$33,BGP
                    fcb $1B,$32,$0B
                    fcb $B3
                    fcb $1B,$32,$01
                    fcb $DB,$DB
                    fcb $1B,$32,$0F
                    fcb $DB
                    fcb $1B,$32,$0C
                    fcb $DB
                    fcb $1B,$32,$0B
                    fcb $DB
                    fcb $1B,$32,$00
                    fcb $DB
                    fcb $1B,$32,BGP
                    fcb	$DB
                    fcb $1B,$32,$01
                    fcb $B6,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb $1B,$32,$0B
                    fcb $B3				end line 3
                    fcb	$1B,$32,BGP
                    fcb $DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB	center line
                    fcb	$DB,$DB
                    fcb $1B,$32,$02
                    fcb $DB,$DB
                    fcb $1B,$32,BGP
                    fcb	$DB,$DB
                    fcb $1B,$32,$02
                    fcb $BB,$DB,$BC,$DB,$DB
                    fcb	$1B,$32,$00
                    fcb $B3
                    fcb $1B,$32,$08
                    fcb $DB,$DB
                    fcb $1B,$32,$00
                    fcb $B3
                    fcb $1B,$32,BGP
                    fcb $DB,$DB,$DB
                    fcb $1B,$32,$07
                    fcb $DB,$DB
                    fcb $1B,$32,$00
                    fcb $B4,UCH
                    fcb $1B,$32,BGP
                    fcb $DB,$DB
                    fcb $1B,$32,$05
                    fcb $DB,$DB
                    fcb $1B,$32,$00
                    fcb $B3
                    fcb $1B,$32,BGP
                    fcb $DB,$DB
                    fcb $1B,$32,$05
                    fcb $DF
                    fcb $1B,$32,BGP
                    fcb $DB
                    fcb $1B,$32,$01
                    fcb $DB,$DB
                    fcb $1B,$32,$00
                    fcb $B4,UCH,UCH,UCH
                    fcb $1B,$32,$01
                    fcb $DB,$DB
                    fcb $1B,$32,$0B
                    fcb $B3
                    fcb $1B,$32,BGP
                    fcb	$DB
                    fcb $1B,$32,$00
                    fcb UCH,UCH,UCH,UCH
                    fcb $1B,$32,$01
                    fcb $DB,$DB
                    fcb $1B,$32,$0B
                    fcb $B3
                    fcb $1B,$32,BGP
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb $1B,$32,$00
                    fcb UCH,UCH,UCH,UCH
                    fcb $1B,$32,$01
                    fcb $DB,$DB
                    fcb	$1B,$32,$0B
                    fcb $B3				end line 4
                    fcb	$1B,$32,BGP
                    fcb $DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB	
                    fcb	$DB,$DB					center font
                    fcb	$1B,$32,$02
                    fcb $DB,$DB
                    fcb $1B,$32,BGP
                    fcb $DB,$DB
                    fcb	$DB
                    fcb $1B,$32,$02
                    fcb $BB,$DB,$DB,$DB
                    fcb $1B,$32,$00
                    fcb $B3
                    fcb $1B,$32,$08
                    fcb $DB,$DB
                    fcb $1B,$32,$00
                    fcb	$B3
                    fcb $1B,$32,BGP
                    fcb $DB,$DB,$DB
                    fcb $1B,$32,$07
                    fcb	$DB,$DB,$DB,$BA
                    fcb $1B,$32,BGP
                    fcb $DB,$DB
                    fcb $1B,$32,$05
                    fcb $DB,$DB
                    fcb $1B,$32,$00
                    fcb $B3
                    fcb $1B,$32,BGP
                    fcb $DB,$DB,$DB,$DB
                    fcb $1B,$32,$01
                    fcb $B6,$DB,$DB,$DB,$DB,$DB,$DB,$B8
                    fcb $1B,$32,BGP
                    fcb $DB
                    fcb	$1B,$32,$01
                    fcb $B9,$DB,$DB,$DB,$DB,$DB,$B8
                    fcb	$1B,$32,BGP
                    fcb $DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb $1B,$32,$01
                    fcb $B9,$DB,$DB,$DB,$DB,$DB
                    fcb	$B8						end line 5
                    fcb	$1B,$32,BGP
                    fcb $DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB
                    fcb $1B,$32,FGP	            reset FG
LogoLen             equ	*-Logo

* Line above color bar
BLogo               fcb	$1B,$32,BGP
                    fcb $DB,$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB		center line
                    fcb	$1B,$32,$00
                    fcb UCH,UCH,UCH,UCH,UCH,UCH,UCH
                    fcb	UCH,UCH,UCH,UCH,UCH,UCH,UCH,UCH,UCH,UCH
                    fcb	UCH,UCH,UCH,UCH,UCH,UCH,UCH,UCH,UCH,UCH
                    fcb	UCH,UCH,UCH,UCH,UCH,UCH,UCH,UCH,UCH,UCH
                    fcb	UCH,UCH,UCH,UCH,UCH,UCH,UCH,UCH
                    fcb	C$CR,C$LF
BLogoLen            equ	*-BLogo

* Color bar
ColorBar            fcb	$1B,$32,BGP
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB	center bar
                    fcb	$DB,$DB,$DB,$DB,$DB,$DB
                    fcb	$1B,$32,$02
                    fcb $DF,$DF,$DF
                    fcb $1B,$32,$08
                    fcb $DF,$DF,$DF	color bar
                    fcb $1B,$32,$07
                    fcb $DF,$DF,$DF
                    fcb $1B,$32,$05
                    fcb $DF,$DF,$DF
                    fcb $1B,$32,$0E
                    fcb $DF,$DF,$DF
                    fcb	$1B,$32,$04
                    fcb $DF,$DF,$DF
                    fcb $1B,$32,$01
                    fcb $DF,$DF,$DF
                    fcb $1B,$32,$0F
                    fcb $DF,$DF,$DF
                    fcb $1B,$32,$0C
                    fcb $DF,$DF,$DF
                    fcb $1B,$32,$0B
                    fcb $DF,$DF,$DF
                    fcb	$1B,$32,$03
                    fcb $DF,$DF,$DF
                    fcb $1B,$32,$0A
                    fcb $DF,$DF,$DF
                    fcb $1B,$32,$0D
                    fcb $DF,$DF,$DF
                    fcb $1B,$32,$09
                    fcb $DF,$DF,$DF
                    fcb $1B,$32,$00
                    fcb $DF,$DF,$DF
                    fcb	$1B,$32,FGP					reset FG
CBLen               equ	*-ColorBar

                    endsect