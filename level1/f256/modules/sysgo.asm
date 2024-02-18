********************************************************************
* SysGo - Kickstart program module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      1998/10/12  Boisy G. Pitre
* Taken from OS-9 L2 Tandy distribution and modified banner for V3.
*
*   5r2    2003/01/08  Boisy G. Pitre
* Fixed fork behavior so that if 'shell startup' fails, system doesn't
* jmp to Crash, but tries AutoEx instead.  Also changed /DD back to /H0
* for certain boot floppy cases.
*
*          2003/09/04  Boisy G. Pitre
* Back-ported to OS-9 Level One.
*
*   5r3    2003/12/14  Boisy G. Pitre
* Added SHIFT key check to prevent startup/autoex from starting if
* held down.  Gene Heskett, this Bud's for you.

                    nam       SysGo
                    ttl       Kickstart program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $03
edition             set       $05

                    mod       eom,name,tylg,atrv,start,size


                    org       0
MMUST               rmb       1
MMUSL1              rmb       1
InitAddr            rmb       2
                    rmb       250
size                equ       .

name                fcs       /SysGo/
                    fcb       edition

* Default process priority
DefPrior            set       128

Banner              equ       *
                    fcc       /                        (C) 2014 The NitrOS-9 Project/
CrRtn               fcb       C$CR,C$LF
                    fcb       C$CR,C$LF
                    ifeq      ROM
                    ifne      NOS9DBG
                    fcc       "**   DEVELOPMENT BUILD   **"
                    fcb       C$CR,C$LF
                    fcc       "** NOT FOR DISTRIBUTION! **"
                    fcb       C$CR,C$LF
                    endc
                    dts
                    fcb       C$CR,C$LF
                    fcc       !http://www.nitros9.org!
                    fcb       C$CR,C$LF
                    endc

                    fcb       C$LF
BannLen             equ       *-Banner

                    ifeq      ROM
DefDev              equ       *
                    ifne      DD
                    fcc       "/DD"
                    else
                    fcc       "/H0"
                    endc
                    fcb       C$CR
HDDev               equ       *
                    ifne      DD
                    fcc       "/DD/"
                    else
                    fcc       "/H0/"
                    endc
ExecDir             fcc       "CMDS"
                    fcb       C$CR
                    endc

Shell               fcc       "Shell"
                    fcb       C$CR
AutoEx              fcc       "AutoEx"
                    fcb       C$CR
AutoExPr            fcc       ""
                    fcb       C$CR
AutoExPrL           equ       *-AutoExPr

                    ifeq      ROM
Startup             fcc       "startup -p"
                    fcb       C$CR
StartupL            equ       *-Startup
                    endc

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

                    ifeq      atari+corsham+f256
                    ifeq      Level-1
* BASIC reset code (CoCo port only)
BasicRst            fcb       $55
                    neg       <$0074
                    nop
                    clr       >PIA0Base+3
                    nop
                    nop
                    sta       >$FFDF              turn off ROM mode
                    jmp       >Bt.Start+2         jump to boot
BasicRL             equ       *-BasicRst
                    endc
                    endc

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
                    os9        F$ID
                    ldb        #DefPrior
                    os9        F$SPrior
                    
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

* Show rest of banner
SignOn
		    
                    puls      u
                    lda       MMU_MEM_CTRL        get current MLUT -  MMU_MEM_CTRL $FFA0
                    sta       MMUST,u             store MMU State
                    ldb       MMU_SLOT_1          get current MMU SLOT 1 - MMU_SLOT_1 $FFA9
                    stb       MMUSL1,u            store MMU Slot 1
                    lda       MMU_SLOT_7          get MMU slot 7 $FFAF
                    cmpa      #$07                is it Ram mode
                    beq       ram@			
                    lda       #$11                enable editing Flash mode MLUT 1
                    bra       cont@
ram@                lda       #$00                enable editing Ram mode MLUT 0
cont@               sta       MMU_MEM_CTRL        update $FFA0
                    lda       #$C1                MMU Page $C1 to SLOT 1 - font memory
                    sta       MMU_SLOT_1          update $FFA9
                    leax      FONTS,pcr           point to custom FONTS
                    ldy       #$2598              point to character 179	
                    ldb       #$50                FONT byte count
L1                  lda       ,x+                 load font byte
                    sta       ,y+                 update font glyph
                    decb                          decrement count
                    bne       L1
                    ldb       MMUSL1,u            restore MMU Slot 1 #$01
                    stb       MMU_SLOT_1	    update MMU SLOT 1 $FFA9
                    lda       MMUST,u             restore MLUT #$00
                    sta       MMU_MEM_CTRL        update MMU $FFA0
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
                    leax      >Banner,pcr
                    ldy       #BannLen               
                    os9       I$Write             write out banner
                    
* Set default time
                    leax      >DefTime,pcr
                    os9       F$STime             set time to default
                    ifeq      ROM
* Change EXEC and DATA dirs
                    leax      >ExecDir,pcr
                    lda       #EXEC.
                    os9       I$ChgDir            change exec. dir
                    leax      >DefDev,pcr
* Made READ. so that no write occurs at boot (Boisy on Feb 5, 2012)
                    lda       #READ.
                    os9       I$ChgDir            change data dir.
                    bcs       L0125
                    leax      >HDDev,pcr
                    lda       #EXEC.
                    os9       I$ChgDir            change exec. dir to HD
                    endc

L0125               equ       *
                    pshs      u,y
                    ifeq      atari+corsham+f256
                    ifeq      Level-1
* Setup BASIC code (CoCo port only)
                    leax      >BasicRst,pcr
                    ldu       #D.CBStrt
                    ldb       #BasicRL
CopyLoop            lda       ,x+
                    sta       ,u+
                    decb
                    bne       CopyLoop
                    else
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

                    lda       #$55                set flag for Color BASIC
                    sta       <D.CBStrt,u
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
                    endc

                    ifeq      ROM
* Fork shell startup here
                    ifeq      atari+corsham+f256
* Added 12/14/03: If SHIFT is held down, startup is not run (CoCo only)
                    lda       #$01                standard output
                    ldb       #SS.KySns
                    os9       I$GetStt
                    bcs       DoStartup
                    bita      #SHIFTBIT           SHIFT key down?
                    bne       L0186               Yes, don't to startup or autoex
                    endc

DoStartup           leax      >Shell,pcr
                    leau      >Startup,pcr
                    ldd       #256
                    ldy       #StartupL
                    os9       F$Fork
                    bcs       DoAuto              Startup failed.
                    os9       F$Wait
                    endc

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
                    ifgt      Level-1
                    os9       F$Chain             Level 2/3. Should not return..
                    ldb       #$06                it did! Fatal. Load error code
                    bra       Crash

L01A9               ldb       #$04                error code
Crash
                    ifne      coco
                    clr       >DPort+$08          turn off disk motor
                    endc
                    jmp       <D.Crash            fatal error
                    else
                    os9       F$Fork              Level 1.
                    bcs       DeadEnd             Fatal.
                    os9       F$Wait
                    bcc       FrkShell            OK, go start shell.
DeadEnd             bra       DeadEnd
                    endc

IcptRtn             rti
Logo                fcb        $1B,$33,$06,$1B,$32,$01,$0C                   set BG blue,FG wht, CLS, NewLine
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
FONTS               fcb	$C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0		char 179 right shadow
                    fcb	$C0,$C0,$C0,$C0,$C0,$C0,$C0,$FF		char 180 right and underline shadow
                    fcb	$07,$1F,$3F,$7F,$7F,$FF,$FF,$FF		char 181 left top rounded
                    fcb	$FF,$FF,$FF,$7F,$7F,$3F,$1F,$07		char 182 left bottom rounded
                    fcb	$E0,$F8,$FC,$FE,$FE,$FF,$FF,$FF		char 183 right top rounded
                    fcb	$FF,$FF,$FF,$FE,$FE,$FC,$F8,$E0		char 184 right bottom rounded
                    fcb	$0F,$1F,$3F,$7F,$7F,$3F,$1F,$0F		char 185 left end cap
                    fcb	$FF,$FE,$FC,$F8,$F0,$E0,$C0,$80		char 186 right forward slant
                    fcb	$FF,$7F,$3F,$1F,$0F,$07,$03,$01		char 187 left reverse slant
                    fcb	$80,$C0,$E0,$F0,$F8,$FC,$FE,$FF		char 188 right reverse slant
                    emod
eom                 equ       *
                    end
