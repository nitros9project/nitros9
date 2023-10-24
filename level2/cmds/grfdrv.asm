********************************************************************
* GrfDrv - NitrOS-9 Windowing Driver
*
* $Id$
*
* Copyright (c) 1982 Microware Corporation
* Modified for 6309 Native mode by Bill Nobel - Gale Force Enterprises
* Also contains Kevin Darlings FstGrf patches & 1 meg routines
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
** 08/11/92 - Active in Native mode No apparent bugs
** Additional bugfixes/optomizations by Bill Nobel & L. Curtis Boyle
**   09/01/92 - present
** NitrOS9 V1.10
**   05/26/93 - 3 cycle speedup in hardware text alpha put @ L0F6B
** NitrOS9 V1.11
**   07/14/93 - Eliminated useless LDB 8,Y @ L01B5
**   07/14/93 - Eliminated BMI's from L01D2; replace BGT's with BHI's
**   07/15/93 - Save 1 cycle/byte in Composite conversion in Select routine
**            - Changed some pixel calcs in L06xx to use LSLD instead of
**              MUL's by 8 (longer, but ends up being 12 cycles faster)
**            - Moved L017C routine to be near Gfx cursor updates (1 cycle
**              faster their and for Points with Pset buffers as well)
**            - Moved SysRet routine near Alpha Put area to speed text output
**              by 4 cycles (whether error or not)
**            - Modified routine @ L0F04 to save up to 2 cycles per line
**              of PutBlk
**            - Modified L0E2F & L0F20 routines to speed up checks for
**              stopping non-TFM PutBlk's
**            - Changed LEAX B,X to ABX in FFill @ L1C5F
**              Also change LEAS -2,s / PSHS D to PSHS X,D @ L1DCB (FFill)
**   07/16/93 - Changed L012B routine to LDX first, then PSHS, eliminating
**              the need for the STX 2,S (saves 2 bytes/6 cycles)
**            - Got rid of LEAY/PSHS Y/PULS Y in L012B since 8 bit addressing
**              is same speed as 5
**   07/20/93 - Modified Alpha Put to have a shortcut if writing to the
**              same window as GRFDRV wrote to the last time it was run
**            - Moved L1F08 & L1F18 routines closer to LINE to allow BSR's
**            - Removed redundant BRA L0FF8 in 2 color gfx text put routine
**            - Replaced 2 BRA L102D's with PULS A,PC (same size but saves
**              3 cycles)
**            - Replaced BRA L0A38 in L0A1C routine with PULS PC,Y,A
**            - Replaced BRA L0AA6 in L0A75 routine with PULS PC,Y,X,B
**            - Replaced BRA L0BE1 in L0BA2 routine with CLRB / LBRA SysRet
**            - Replaced BRA L1ADD's in L1A9D routines with PULS PC,X,D's
**              (In Ellipse/Circle/Arc routines)
**   07/28/93 - Modified L11CA routine to eliminate 1 LBRA (saves 4 cycles)
**            - Modified pixel XOR routine to save 3 cycles (used by Gfx
**              Cursor)
**            - Changed CMPW to CMPF when checking gfx coords @ L1E86
**   08/06/93 - Changed BSR Lxxxx / RTS to BRA Lxxxx in following locations:
**              L13AD (2), Just before L0516, L0798, Just before L1A97, L1D3C
** NitrOS9 V1.16
**   08/30/93 - Took out DECD/DECB @ L0D27 (GPBuf wrap checks), changed BHI's
**              to BHS's
**   08/30/93 - L0E14 replaced LDA / ANDA with TIM
**   08/31/93 - L0B79 changed registers around for split or normal Move buffer
**              to shrink & speed up copy slightly
**   09/01/93 - L0C96 - change BLE in overwrap GP Buffer to BLO ($4000 is in
**              next block)
**   09/22/93 - Moved L1BE8 to eliminate BSR (only called once)
**            - Moved L1BDD to L18B7 (only called once)
**            - Optomized 1BC9 by 7 cycles (multiply 5 byte integer x2)
**   09/23/93 - Remarked out L1B4B (never called-for filled circle/ellipse?)
**            - Moved L1B5D to L1BB4 (only called once)
**   09/27/93 - Moved L1BF3 to L1BCB (only called once)
**   09/28/93 - Sped up/shrunk RGB color copy in Select routine with LDQ
**            - Sped up of 2 color text by 18 cycles/character (changed
**              branch compare order @ L1051
**            - Sped up of normal gfx text @ L10ED, and shortened code @
**              L10FE/L1109 by moving PULS B, and optomized L1109 branch
**              compare order (same as L1051)
**            - Changed <$A9,u vector to use ,W instead (<>2 color txt on gfx
**              (NOTE: Type 7 window (640x200x4) tests are over 8% faster)
**   10/04/93 - Shortened L0FD6 (changed BNE/BRA to a BEQ/fall through) so
**              Proportional & 2 color fonts are faster
**            - Moved L122F to before L121A (eliminate BRA for wrap to next
**              line)
**            - Did optomization @ L127E for non-full screen width screen
**              scrolls (also called by Insert line & Delete line)
**            - Took out redundant LDB <$60 @ L13E3 (clear to end of screen)
**            - Attempted opt of L10A4 to eliminate EXG X,Y
**            - Re-arranged L10FA (Gfx text, not 2 color/normal) so it is
**              optomized for actual text, not the cursor
**   10/08/93 - Changed L1E2C to use LEAX B,U (since B always <$80) since
**              same speed but shorter
**            - Changed BHI L1DEB @ L1DCB to LBHI L1C93 (1 byte longer but
**              2 cycles shorter)
**            - Changed L017C (map GP Buffer blocks, both in GRFDRV DAT &
**              immediate) to use DP instead of <xxxx,u vars.
**            - Changed L0E70 to not bother changing U because of L017C change
**            - Modified Gfx screen map-in routine @ MMUOnly to use
**              DP addressing instead of ,X (eliminates LEAX too), saving
**              mem & 11 cycles per map
**            - Also removed PSHSing X in above routine & calls to it since
**              not needed anymore
**            - Changed L01FB to use LDX #$1290 instead of LEAX >$190,u
**            - Changed all [...],u to use DP or immediate mode whenever
**              possible
**            - Changed EXG X,Y @ L03FF to TFR X,Y (since X immediately
**              destroyed) (part of DWEnd to check if last window on scrn)
**            - Eliminated useless BRA PutIt2 @ L0C96
**            - Removed PSHS/PULS of U in L0C8F (L0E70 no longer destroys U)
**   10/19/93 - Change L1F18 to use LDB #1/ABX instead of LEAX 1,X (2 cycles
**              faster)
**            - Removed LDU #$1100 @ L0EB2 since change to L0E70 (GP buffer)
**   10/20/93 - BUG FIX: Changed CMPF <$1E,Y @ L1E86 to CMPW <$1D,Y (otherwise
**              routines that use th 16 bit Y coord for calculations screwed
**              up on values >255) - MAY WANT TO TO CHANGE LATER TO HAVE HARD
**              CODED 0 BYTE AS MSB OF Y COORDS AND SWITCH ALL CALCS POSSIBLE
**              TO 8 BIT (OR LEAVE 16 BIT FOR VERTICAL SCROLLABLE SCREEN
**              OPTIONS)
**            - Moved L1E86 to L1DF8 (eliminates BRA from most X,Y coord pairs)
**            - Moved L1F1D/L1F2C/L1F42 (right direction FFill vectors) to
**              within FFill (only called once, eliminates LBSR/RTS)
**            - Moved L1CC2 to eliminate BRA (eats coords off of FFill stack?)
**            - L1D1E subroutine removed, embedded in places where called
**            - L1DAA: eliminated LDD <$47 & changed CMPD <$4B to CMPW <$4B
**            - L1DCB: changed to use both D & W to save code space & time
**   10/21/93 - L1D14 subroutine removed, embedded in 2 places where called
**            - Changed BHI L1D03 to LBHI L1C93 @ L1D55 & eliminated L1D03
**              label
**            - Changed BRA L1C93 at end of L1CF8 to LBRA L1CF8
**            - Moved L1186 (CurXY) to before L1129 (CTRL codes) to allow
**              3 LBEQ's to change to BEQ's (Cursor left,right & up) -
**              shrinks GRFDRV by 6 bytes
**            - Modified L158B (update cursor) to not PSHS/PULS Y unless on
**              Gfx screen (speeds text cursor updates by 9 cyc/1 byte)
**            - Changed LBSR to BSR (L15BF) in PutGC (L1531)
**            - Attempted to move L06A4-L1FB2 to just before Point (L1635)
**              & changed leax >L1FA3,pc to LEAX <L1FA3,pc in L15FE (saves
**              2 cycles & 2 bytes)
**   10/25/93 - Changed GRFDRV entry point to use LDX instead of LEAX
**              (2 cycles faster)
**            - Changed all LEA* xxxx,pc to use LDX #GrfStrt+xxxx (2 cyc fstr)
**            - Changed GRFDRV entry point to do LDX / JMP ,X (1 byte shorter &
**              2 cycles faster)
**   11/02/93 - Modified Init routine to be shorter & faster
**            - Took old 2 line L18B3 routine, put the label in front of
**              stx <$A1 just past L18BF
**   11/03/93 - Removed the last of [<$xx,u] labels, changed FFill to use
**              JSR ,U instead of JSR [$<64,U]
**            - Removed LDU 4,s from L0B2E, and remove PSHS/PULS U from
**              L0ACD, L0B35, L0B38
**            - In L0B79 (Move Buffer command), optomized to not PSHS/PULS
**              Y, use U instead for ptr (13 cyc faster/72 byte block, 5 bytes
**              shorter)
**            - Added LDU <$64 in L0E97, changed JSR [$>1164] in L0EE1 to
**              JSR ,U (PutBlk on different screen types)
**   11/04/93 - Change all LBRA xxxx to JMP GrfStrt+xxxx (1 cycle faster)
**   11/10/93 - Added window table references from cc3global.defs
**            - Added screen table references from cc3global.defs
**            - Added graphics table references from cc3global.defs
**            - Added graphics buffer references from cc3global.defs
**   11/12/93 - Removed code that has been moved to CoWin/CoGrf
**   12/15/93 - Changed TST Wt.BSW,y @ L0F8E to LDB Wt.BSW,y (cycle faster)
**   12/21/93 - Moved L1E9D to near next line routine to speed up some alpha
**              writes. Also used U instead of Y in L1E9D (smaller & a cycle
**              faster)
**   02/23/94 - Moved L0BE4 error routine earlier to allow short branch to it
**              from L0B3F (GPLoad), also optomized for no-error (5 cycles
**              faster, 2 bytes smaller)
**   02/24/94 - Changed lbcs L0BE7 @ L0B52 to BCS
**   04/14/94 - Changed CMPB >$FFAC to CMPB <$90 (saves 1 byte/cycle & poss-
**              ibly fixes bug for >512K machines) in L012B & L0173
**            - Got rid of CLR >$1003 @ L0177, changed BSR L012B to BSR L0129
**            - Changed CMPD #$4000 to CMPA #$40 @ L0B79 & L0C96 (also fixed
**              bug @ L0B79-changed BLS MoveIt to BLO MoveIt)
**   04/15/94 - Changed L0E14 & L0E24 to use 640/320 base to eliminate INCD,
**              also optomized by using LSRD instead of 2 separate LDD's
**            - Moved INCB from L0E2F to L0E03 to allow L0E24 to fall through
**              faster (by also changing LDB #MaxLine to LDB #MaxLine+1)
**   04/21/94 - Change all occurences of >$1003 (last window GRFDRV accessed)
**              to <$A9 (since now free) to speed up/shrink checks.
**            - Attempted mod for hware text screens: faster if >1 window
**              being written to at once
**   04/25/94 - Removed LDX #$FF90 from late in L08A4, changed STD 8,x to
**              STD >$FF98 (Select routine-saves 4 cycles/2 bytes
**            - Attempted mod @ L05C0: Changed 1st TST <$60 to LDE <$60, and
**              2nd to TSTE (also changed 3 LSLD's in Y coord to LSLB's)
**              (CWArea routine)
**   04/26/94 - Changed L11E1 (Home cursor) to move CLRD/CLRW/STQ Wt.CurX,y
**              to end (just before RTS) to allow removal of CLRD/CLRW @
**              L1377 (CLS)
**   04/27/94 - Changed GFX text routines (non-2 color) to use U as jump
**              vector instead of W (has changes @ L0FEC,L10D9,L10FE,L15A5)
**            - Changed pixel across counter from <$97 to E reg in Gfx text
**              routine (changes @ L10D1,L10FE)
**   05/04/94 - Attempted to remove PSHS X/PULS X from L0C0B (used by GetBlk
**              and Overlay window saves)
**              Also changed LBSR L0CBD to BSR @ L0BEA (part of OWSet save)
**   05/05/94 - Changed L0B79: Took out TFR A,B, changed CLRA to CLRE, changed
**              TFR D,W to TFR W,D (reflects change in CoWin)
**   05/08/94 - Eliminated LDB #$FF @ L108C, change BNE above it to go to
**              L108E instead (saves 2 cyc/bytes in proportional fonts)
**            - Change to L127E to move LDF to just before BRA (saves 3 cyc
**              on partial width screen scrolls)
**            - Changed TST <$60 @ L1260 to LDB <$60 (saves 1 cycle)
**   06/15/94 - Changed TST >$1038 @ L0080 to LDB >$1038 (saves 1 cycle)
**            - Changed TST St.Sty,x @ L0335 to LDB St.Sty,x (save 1 cyc)
**            - Eliminated LDA St.Sty,x @ L0343
**            - Changed TST <$59 to LDB <$59 @ L046A (OWSet)
**            - Changed TST Wt.FBlk,y @ L0662 to LDB Wt.FBlk,y (Font)
** NitrOS9 V1.21 Changes
**   10/16/94 - Changed L0FBE to BSR L100F instead of L1002, added L100F (PSHS
**              A), saves 5 cycles per alpha put onto graphics screen
**   10/22/94 - Eliminated useles LDB <$60 @ L029B
**            - Eliminated PSHS X/PULS X @ L0366 by changing PSET/LSET vector
**              settings to use Q since immediate mode instead of indexed now
**              (saves 6 bytes/>12 cycles in Window Inits)
**            - Changed L106D: changed LDX/STX to use D, eliminated LDX ,S
**              (Part of font on multi-colored windows;saves 2 bytes/4 cyc)
**   10/30/94 - Changed L126B (full width screen scroll) by taking out label,
**              (as well as L1260), and taking out PSHS/PULS X
**            - Changed TST <$60 to LDB <$60 @ L12C5, changed BRA L128E @
**              L12DC to BRA L1354 (Saves 3 cycles when using Delete Line on
**              bottom line of window)
**            - Moved CLRE in L142A to just before L142A (saves 2 cycles per
**              run through loop) (same thing with CLRE @ L1450)
**            - Deleted L146F, moved label for it to PULS pc,a @ ClsFGfx
** ATD:
**   12/23/95 - have SCF put text-only data at $0180, and have new call
**              to grfdrv to do a block PUT of the text data.
**              Added new L0F4B, and labels L0F4B.1 and L0F4B.2
**              cuts by 40% the time required for alpha screen writes!
**   12/26/95 - moved Line/Bar/Box common code to i.line routine
**              +6C:-40B, only called once per entry, so it's OK
**   12/28/95 - added LBSR L0177 just before font set up routine at L1002
**              changed lbsr L0177, lbsr L1002 to lbsr L0FFF: gets +0C:-3B
**              par call from L1478, L116E, L1186, L1129
**            - replaced 3 lines of code at L1641, i.line, L1C4F with
**              lbsr L1884: map in window and verify it's graphics
**              it's only called once per iteration, so we get 3 of +11C:-6B
**   02/08/96 - added fast fonts on byte boundaries to L102F
**            - added TFM for horizontal line if LSET=0 and no PSET
**            - removed most of graphics screen CLS code for non-byte
**              boundary windows.  They don't exist, the code is unnecessary.
**            - changed many ADDR D,r  to LEAr D,r where speed was unimportant
**   02/13/96 - fixed font.2 routine to properly handle changes in foreground
**              and background colors: ~13 bytes smaller. (other changes???)
**            - added special code to fast horizontal line routine at L16E0
**              to do the line byte by byte: saves a few cycles, but 2B larger
**   02/14/96 - added 'ldu <$64' U=pset vector to i.line, bar/box. -6 bytes,
**              and timed at -18 clock cycles/byte for XOR to full-screen
**              or 14/50 = 0.28 second faster per screen (iteration)
**  02/16/96  - shrunk code for $1F handler. Smaller and faster.
**  02/18/96  - Discovered that NitrOS-9 will allow GetBlk and PutBlk on
**              text screens!  Checked: GET on text and PUT on gfx crashes
**              the system, ditto for other way around.  Stock OS-9 does NOT
**              allow PutBlk or GetBlk on text! No error, but no work, either.
**            - Added code to PutBlk to output E$IWTyp if mixing txt and gfx
**              GetBlk/PutBlk, but we now allow Get and put on text screens.
**  02/20/96  - minor mods to update video hardware at L08A4: use U
**            - Added 'L1B63 LDD #1' to replace multiple LDD #1/lbsr L1B64
**            - moved code around to optimize for size in arc/ellipse/circle
**              without affecting speed at all.
**  02/24/96  - added special purpose code for LSET AND, OR, XOR and NO PSET
**              to put pixels 2 bytes at a time... full-screen BAR goes from
**              1.4 to .35 seconds, adds ~75 bytes.
**            - Added code to check for 24/25 line windows in video set code
**              from DWSET: Wt.DfSZY=24 uses old 192 line video defs
**  02/25/96  - removed 24/25-line check code, optimized video hardware update
**  02/26/96  - fixed fast TFM and XOR (double byte) horizontal line to
**              update <$47 properly
**            - rearranged BOX routine to cut out extra X,Y updates
**  02/29/96  - optimized BOX routine: smaller and marginally faster
**  03/05/96  - moved PSET setup routines to L1884 for Point, Line, Bar, Box
**              Arc, Circle, Ellipse, and FFill.
**            - modified FFILL to do left/right checking, and right painting
**              to do byte operations, if possible.  Speeds up FFILL by >20%
**  03/07/96  - modified FFILL to search (not paint) to the right, and to
**              call the fast horizontal line routine. 2-color screen FFILLs
**              take 1/10 the time of v1.22k: 16-color takes 1/2 of the time!
**  03/17/96  - added TFM and left/right pixel fixes so non-PSET/LSET odd
**              pixel boundary PutBlks can go full-speed.
**  03/18/96  - optimized the fast-font routine.  16-color screens ~5% faster
**  04/05/96  - addeed special-purpose hardware text screen alpha put routine
**              about 30% faster than before: 5 times over stock 'Xmas GrfDrv'
**            - merged cursor On/Off routines at L157A: smaller, ~10c slower
**            - saved 1 byte in invert attribute color routine
**            - moved FastHTxt routine (i.e. deleted it: smaller, 3C slower)
**            - L0516 and L0581: added 'xy.intoq' routine to set up X,Y size
**              for text/graphics screens
** V2.00a changs (LCB)
** 05/25/97-05/26/97 - added code to support 224 char fonts on graphics
**            screens
**          - Changed 3 LBSR's to BSR's (@ L01B5,L1BB4,L1D40)
** 12/02/97 - Attempted to fix GetBlk, PutBlk & GPLoad to handle full width
**            lines @ L0BAE (GetBlk), L0CBB (PutBlk),
**            NOTE: TO SAVE SPACE GRFDRV, MAYBE HAVE CoWin DO THE INITIAL
**              DEC ADJUSTMENTS, AND JUST DO THE INC'S IN GRFDRV
** 07/10/98 - Fixed OWSet/CWArea bug: changed DECB to DECD @ L05C0
** 07/21/98 - Fixed screen wrap on CWAREA or Overlay window on hardware text
**            screens by adding check @ ftxt.ext
** 07/28/98 - Fixed FFill "infinite loop" bug (See SnakeByte game), I think.
** 07/30/98 - Filled Circle/Ellipse added ($1b53 & $1b54)
** 09/17/03 - Added trap for windows overlapping 512K bank; RG.
**            Required changing a bsr L0306 to lbsr L0306 near L02A7
** 09/25/03 - Many changes for 6809 only code. Use <$B5 to store regW
**            Probably could use some trimming. RG
** 02/26/07 - Changed Line routine to improve symmetry. The changes will permit
**            the removal of the FastH and FastV routines if desired. The new
**            Normal Line will correctly draw horizontal or vertical lines. RG
*****************************************************************************
* NOTE: The 'WHITE SCREEN' BUG MAY BE (IF WE'RE LUCKY) ALLEVIATED BY CLR'ING
* OFFSET 1E IN THE STATIC MEM FOR THE WINDOW, FORCING THE WINDOWING DRIVERS
* TO RESTART RIGHT FROM THE DEVICE DESCRIPTOR, INSTEAD OF ASSUMING THE DATA IN
* STATIC MEM TO BE CORRECT??

                    nam       GrfDrv
                    ttl       NitrOS-9 Windowing Driver

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

GrfStrt             equ       $4000               Position of GRFDRV in it's own task

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             equ       14

* NOTE: Following set has meaning only if 25 text line mode is selected
TV                  set       $00                 Set to 1 for 25 line TV res. (200 vs. 225)

                    mod       eom,name,tylg,atrv,entry,size
size                equ       .

                    fcb       $07

name                fcs       /GrfDrv/
                    fcb       edition

******************************
* Main entry point
*   Entry: B=Internal function code (from CoGRF or CoWin)
*          A=Character (for Write routine)
*          U=Pointer to GRFDRV memory area ($1100 in system)
*          Y=Current window Window Table Pointer
*    Stack area is from $1b80 to $1fff in block 0
*   When function call vector is executed via JMP ,X
*     DP has been set to $11 to allow direct page access to GRFDRV variables


entry               equ       *
                    ifne      H6309
                    lde       #GrfMem/256         Direct page for GrfDrv
                    tfr       e,dp
                    else
                    pshs      a
                    lda       #GrfMem/256
                    tfr       a,dp
                    puls      a
                    endc
                    tstb                          initialization?
                    bne       grfdrv.1            no, do other stuff
                    bra       L0080               do relative jump to the init routine

grfdrv.1            ldx       #GrfStrt+L0028      Point to function vector table
                    jmp       [b,x]               Execute function

* GrfDrv function code vector table
L0028               fdb       L0080+GrfStrt       Initialization ($00)
                    fdb       L0104+GrfStrt       Terminate      ($02)
                    fdb       L019D+GrfStrt       DWSet          ($04)
                    fdb       fast.chr+GrfStrt    buffered writes... ($06)
                    fdb       L03CB+GrfStrt       DWEnd          ($08)
                    fdb       L046A+GrfStrt       OWSet          ($0A)
                    fdb       L053A+GrfStrt       OWEnd          ($0C)
                    fdb       L056E+GrfStrt       CWArea         ($0E)
                    fdb       L07D7+GrfStrt       Select         ($10)
                    fdb       L0611+GrfStrt       PSet           ($12)
                    fdb       $0000               Border         ($14) NOW IN CoWin
                    fdb       $0000               Palette        ($16) NOW IN CoWin
                    fdb       L063C+GrfStrt       Font           ($18)
                    fdb       L068B+GrfStrt       GCSet          ($1A)
                    fdb       $0000               DefColor       ($1C) NOW IN CoWin
                    fdb       L06A4+GrfStrt       LSet           ($1E)
                    fdb       L0707+GrfStrt       FColor         ($20)
                    fdb       L0726+GrfStrt       BColor         ($22)
                    fdb       $0000               TChrSW         ($24) NOW IN CoWin
                    fdb       $0000               PropSW         ($26) NOW IN CoWin
                    fdb       $0000               Scale          ($28) NOW IN CoWin
                    fdb       $0000               Bold           ($2A) NOW IN CoWin
                    fdb       L08DC+GrfStrt       DefGB          ($2C)
                    fdb       L0A3A+GrfStrt       KillBuf        ($2E)
                    fdb       L0B3F+GrfStrt       GPLoad         ($30)
                    fdb       L0B79+GrfStrt       Move buffer    ($32)
                    fdb       L0BAE+GrfStrt       GetBlk         ($34)
                    fdb       L0CBB+GrfStrt       PutBlk         ($36)
                    fdb       L0F31+GrfStrt       Map GP buffer  ($38)
                    fdb       L0F4B+GrfStrt       Alpha put      ($3A)
                    fdb       L1129+GrfStrt       Control codes  ($3C)
                    fdb       L116E+GrfStrt       Cursor on/off  ($3E)
                    fdb       L1478+GrfStrt       $1f codes      ($40)
                    fdb       L1186+GrfStrt       Goto X/Y       ($42)
                    fdb       L151B+GrfStrt       PutGC          ($44)
                    fdb       L1500+GrfStrt       Update Cursors ($46)
                    fdb       L1635+GrfStrt       Point          ($48)
                    fdb       L1654+GrfStrt       Line           ($4A)
                    fdb       L1790+GrfStrt       Box            ($4C)
                    fdb       L17FB+GrfStrt       Bar            ($4E)
                    fdb       L1856+GrfStrt       Circle         ($50)
                    fdb       L18BD+GrfStrt       Ellipse        ($52)
                    fdb       L1860+GrfStrt       Arc            ($54)
                    fdb       L1C4F+GrfStrt       FFill          ($56)

* Initialization entry point
* Entry: U=$1100
*       DP=$11
*        B=$00
L0080               ldb       >WGlobal+g0038      have we been initialized?
                    bmi       L0102               yes, exit
                    coma
                    sta       >WGlobal+g0038      Put it back
* Initialize window entries
                    ldx       #WinBase-$10        Point to start of window tbl entries
                    ifne      H6309
                    ldq       #$2040FFFF          Max # window/size of each entry/Table init code
L0097               stw       ,x                  Initialize table pointer
                    abx                           Move to next entry
                    deca                          Done?
                    bne       L0097               No keep going
                    else
                    pshs      u
                    ldd       #$2040
                    ldu       #$FFFF
L0097               stu       ,x
                    abx
                    deca
                    bne       L0097
                    stu       <$B5
                    puls      u
                    endc
* Initialize screen tables
                    ldx       #STblBse+1          Point to 2nd byte of scrn tbls - 1st block # used
                    ldd       #$1020              smaller than the ldb/lde
* ATD: doing CLR is slightly slower than STA, but this code is executed only
* once, so we optimize for size, not speed
L00A9               clr       ,x                  Set first block # used (A=0 from L0097 loop)
                    abx                           Move to next entry
                    deca                          Done?
                    bne       L00A9               No, keep goin
* Initialize DAT image
                    clrb                          Set System bank as first one (a already 0)
                    std       <$87
                    ifne      H6309
                    ldq       #$333E333E          Get blank image
                    std       <$89                Save it in rest
* NOTE: IF 16K GRFDRV DONE,CHANGE FOLLOWING LINE TO STD <$8F
* Set entire table as this will be reset below as needed. RG.
                    stq       <$8D
                    stq       <$91
                    std       <$95
                    else
                    ldd       #$333E              Since 6809 version is >8K save some steps
                    std       <$89
                    std       <$8F
                    std       <$91
                    std       <$93
                    std       <$95
*         std   <$B5
                    endc
                    tfr       pc,d                Get current location in memory
                    lsra                          Calculate DAT image offset
                    lsra
                    lsra
                    lsra
                    anda      #$0E                Mask off rest of bits
                    ldy       >D.SysPrc           Get system process descriptor pointer
                    leay      <P$DATImg,y         Point to DAT Image
* NOTE: IF 16K GRFDRV DONE,WILL HAVE TO COPY 4 (NOT 2) BYTES OF DAT IMAGE
                    ifne      H6309
                    ldd       a,y                 Get the DAT image of myself
                    std       <$8B                Save it to new task
                    else
                    leay      a,y
                    ldd       ,y++
                    std       <$8B
                    ldd       ,y                  get next two bytes
                    std       <$8D
                    endc
                    ldy       >D.TskIPt           Get task image pointer
                    ldx       #GrfMem+gr0087      Point to grfdrv DAT image tbl
                    stx       2,y                 Save it as second task
* ATD: changed from $1C98 for more lee-way on the stack
                    ldd       #$1CB0              low address for stack: L1DC4, L1DEE
                    std       <$3B                Save in GRFDRV mem
                    ifne      H6309
                    clrd                          Get screen table initialization
                    clrw                          (CLRQ)
                    stq       <$2e                Init current screen table ptr & window entry
                    stq       <$3d                Init X/Y coords Gfx cursor was last ON at
                    else
                    clra
                    clrb
                    std       <$2e
                    std       <$30
                    std       <$3d
                    std       <$3f
*         std   <$B5
                    endc
                    stb       <$32                Clear out block #'s for G/P buffer (Current,
                    stb       <$35                previous)
                    std       <$39                Text cursor & gfx cursors off
L0102               clra
                    tfr       a,dp                Set DP to 0 for Wind/CoGrf, which need it there
                    rts                           Return

* Termination routine
L0104               clr       <$0038              Clear group #
                    clr       <$007D              Clear buffer block #
                    ldb       <$0032              Get last block used
                    beq       L0115               If 0, return to system
                    ldx       <$0033              Get offset into last block we used
                    lbsr      L0A55               Deallocate that buffer
                    bcc       L0104               Keep doing until all are deallocated
                    jmp       >GrfStrt+SysRet     Return to system with error if can't
L0115               jmp       >GrfStrt+L0F78      Exit system

* Setup GrfDrv memory with data from current window table
* Entry: Y=Window table ptr
* Puts in following:
*   PSET/LSET vectors & offsets
*   Foreground/background palettes
*   Maximum X&Y coords for window
*   Screen type
*   Start block # of screen
*   # bytes / row of text
* NOTE: USING A 2 BYTE FREE MEMORY LOCATION SOMEWHERE IN BLOCK 0, KEEP A
*  'LAST WINDOW' ACCESSED COPY OF THE WINDOW TABLE PTR. IF IT HAS NOT CHANGED
*  WHEN IT GETS HERE (OR WHATEVER CALLS HERE) FROM THE 'LAST WINDOW' ACCESSED,
*  SKIP THIS ENTIRE ROUTINE
L0129               clr       <$A9                Special entry pt for DWSet,Select,UpdtWin,PutGC
L012B               ldx       Wt.STbl,y           Get screen table ptr
                    pshs      d                   Preserve register
                    ldd       Wt.PVec,y           Get PSet vector for this window
                    ifne      H6309
                    ldw       Wt.POff,y           Get PSet offset for this window
                    stq       <$64                Save Pset vector & PSet offset
                    else
                    std       <$64
                    ldd       Wt.POff,y
                    std       <$66
                    endc
                    ldd       Wt.LVec,y           Get LSet vector
                    std       <$68                Save it for this window
                    ldd       Wt.Fore,y           Get Foreground/Background prn
                    std       <$61                Save it for this window
                    ifne      H6309
                    ldq       Wt.MaxX,y           Get max. X & Y coords from table
                    stq       <$6A                Save in Grfdrv mem
                    else
                    ldd       Wt.MaxX,y
                    std       <$6A
                    ldd       Wt.MaxX+2,y
                    std       <$6C
                    std       <$B5
                    endc
                    lda       St.BRow,x           Get # bytes per row
                    sta       <$63                Save it for this window
                    ldd       St.Sty,x            Get screen type & first block #
                    sta       <$60                Save screen type for this window
* Setup Task 1 MMU for Window: B=Start block # of window
*   As above, may check start block # to see if our 4 blocks are already
*   mapped in (just check block # in B with block # in 1st DAT entry).
*   Since 4 blocks are always mapped in, we know the rest is OK
* This routine always maps 4 blocks in even if it is only a text window
* which only has to map 1 block. Slight opt (2 cycles) done 03/01/93
* Attempted opt: cmpb/beq noneed 03/12/93
MMUOnly             cmpb      <$90                Is our screen block set already here?
                    beq       noneed              Yes, don't bother doing it again
                    clra                          Get block type for DAT image
                    std       <$8f                Save screen start in my image
                    stb       >$FFAC              Save 1st screen block to MMU

                    tst       <$60                Hardware text (only 1 block needed?)
                    bmi       noneed              yes, no need to map in the rest of the blocks

                    incb                          Get 2nd block
                    std       <$91                Save it in my image
                    stb       >$FFAD              Save it to MMU
                    incb                          Get 3rd block
                    std       <$93                Save it to my image
                    stb       >$FFAE              Save it to MMU
                    incb                          Get 4th block
                    std       <$95                Save it to my image
                    stb       >$FFAF              Save it to MMU
noneed              puls      d,pc                Restore D & return

* Setup the MMU only: called twice from the screen setup routines
* This could be just before MMUOnly, with a 'fcb $8C' just before the PSHS
* to save one more byte, but L0129 is called a lot more often than this is
L0173               pshs      d                   save our registers
                    bra       MMUOnly             go set up the MMU registers, if necessary

* Entry point for Alpha Put
L0175               cmpy      <$A9                Same as previous window GRFDRV alpha putted to?
                    lbeq      L150C               Yes, skip map/setup, update cursors
* Normal entry point
L0177               bsr       L0129               Mark Tbl Ptr bad, map in window,set up GRFDRV vars for it
L0179               jmp       >GrfStrt+L150C      Update text & gfx cursors if needed

* DWSet routine
* ATD: Next 9 lines added to support multiple-height screens.
* We MUST have a screen table in order to do St.ScSiz checks (24, 25, 28).
* GrfDrv is a kernel task (not task switched), so we point X to the possible
* screen table
L019D               ldx       Wt.STbl,y           get screen table
                    bpl       L01A0               $FFFF is a flag saying it's unallocated
                    lbsr      FScrTbl             find a screen table
                    bcs       L01C5               exit on error
                    clr       St.ScSiz,x          clear screen size flag: not defined yet

L01A0               bsr       L01C8               Check coordinates and size
                    bcs       L01C5               Error, exit
                    lda       <$60                Get screen type requested
                    cmpa      #$FF                Current screen?
                    bne       L01B0               No, go create a new screen for the window
                    bsr       L01FB               Make sure window can be fit on current screen
                    bcs       L01C5               Nope, return with error
                    lbsr      L150C               Update Text & Gfx cursors
                    bra       L01B5               Do hardware setup for new window & return to system

* Make window on new screen : have to change so it sets up defaults & colors
* BEFORE it clears the screen
L01B0               lbsr      L0268               Go set up a new screen table (INCLUDES CLR SCRN)
                    bcs       L01C5               If error, return to system with that error
* All window creates come here
L01B5               equ       *
                    ifne      H6309
                    bsr       L0129               go setup data & MMU for new window
                    else
                    lbsr      L0129
                    endc
                    lbsr      L0366               setup default values
                    lda       #$FF                Change back window# link to indicate there is none
                    sta       Wt.BLnk,y
* ATD: same next 3 lines as at L03F4
                    lbsr      L1377               Call CLS (CHR$(12)) routine
                    clrb                          No errors
L01C5               jmp       >GrfStrt+SysRet     return to system

* Check screen coordinates
* Entry: X = screen table pointer
L01C8               lda       <$60                get current window STY marker
                    cmpa      #$FF                current screen?
                    bne       L01D2               no, go on
                    lda       ,x                  Get current screen type (from screen table ptr)
L01D2               ldu       #GrfStrt+L01F9      Point to width table
                    anda      #$01                only keep resolution bit (0=40 column, 1=80)
                    ldb       Wt.CPX,y            get current X start
*         cmpb  a,u          within range?
*         bhi   L01F5        no, exit with error
                    addb      Wt.SZX,y            calculate size
                    bcs       L01F5               added line: exit if 8-bit overflow
                    cmpb      a,u                 still within range?
                    bhi       L01F5               no, error out

* ATD: These lines added for screen size support
                    lda       St.ScSiz,x          get screen size
                    bne       L01E0               skip ahead if already initialized
                    lda       #25                 get maximum screen size in A

L01E0               ldb       Wt.CPY,y            get current Y start
                    ifne      H6309
                    cmpr      a,b                 within maximum?
                    else
                    pshs      a
                    cmpb      ,s+
                    endc
                    bhi       L01F5               no, error out
                    addb      Wt.SZY,y            calculate size: Now B = maximum size of the window
                    bcs       L01F5               added line: exit if 8-bit overflow
                    ifne      H6309
                    cmpr      a,b                 still within maximum?
                    else
                    pshs      a
                    cmpb      ,s+
                    endc
                    bhi       L01F5               no, error out

                    cmpa      St.ScSiz,x          do we have the current screen size?
                    beq       L01F3               yes, skip ahead

                    cmpb      #24                 do we have a 24-line screen?
                    bhi       L01F1               no, it's 25: skip ahead
                    deca                          25-1=24 line screen, if window <= 24 lines

L01F1               sta       St.ScSiz,x          save the size of the screen
L01F3               clrb                          clear carry
                    rts                           return

L01F5               comb                          Set carry
                    ldb       #E$ICoord           Get error code for Illegal co-ordinate
                    rts                           Return
* Maximum widths of text & graphic windows table
L01F9               fcb       40,80

* Check if Current screen DWSET request can be honored (carry set & b=error
*   # if we can't)
* Entry: Y=Ptr to our (new window) window table
* NOTE: It has to check all active windows. If it it fits without overlap
*         on all of them, then it will obviously fit with several on the same
*         screen.
L01FB               ldx       #WinBase            Point to start of window tables
                    ifne      H6309
                    lde       #MaxWind            Get maximum number of windows (32)
                    else
                    pshs      a
                    lda       #MaxWind
                    sta       <$B5
                    puls      a
                    endc
L0206               equ       *
                    ifne      H6309
                    cmpr      y,x                 Is this our own window table entry?
                    else
                    pshs      y
                    cmpx      ,s++
                    endc
                    beq       L021B               Yes, skip it (obviously)
                    ldd       Wt.STbl,x           Get screen table pointer of search window
                    bmi       L021B               High bit set means not active, skip to next
                    cmpd      Wt.STbl,y           Same screen as ours?
                    bne       L021B               No, skip to next
                    lda       Wt.BLnk,x           Is this entry for an overlay window?
                    bpl       L021B               Yes, useless to us
                    bsr       L0224               Go make sure we will fit
                    bcs       L0223               Nope, return with error
L021B               ldb       #Wt.Siz             Move to next entry (originally leax $40,x, but
                    abx                           believe it or not, this is faster in native)
                    ifne      H6309
                    dece                          Done?
                    else
                    dec       <$B5
                    endc
                    bne       L0206               No, go back
                    clrb                          Clear errors
L0223               rts                           Return

* Routine to make sure a 'current screen' DWSet window will fit with other
*   windows already on that screen
* Entry: X=Ptr to window table entry that is on same screen as us
*        Y=Ptr to our window table entry
* Exit: Carry clear if it will fit

L0224               equ       *
                    ifne      H6309
                    tim       #Protect,Wt.BSW,x   Is this window protected?
                    else
                    pshs      b
                    ldb       Wt.BSW,x
                    bitb      #Protect
                    puls      b
                    endc
                    beq       L0262               No, window can overlap/write wherever it wants
                    lda       Wt.CPX,y            get our new window's requested Left border
                    cmpa      Wt.DfCPX,x          Does it start on or past existing windows left border?
                    bge       L023A               Yes, could still work - check width
                    adda      Wt.SZX,y            add in our requested width
                    cmpa      Wt.DfCPX,x          Does our right border go past existing's left border?
                    bgt       L0246               Yes, could still work if Y is somewhere empty(?)
                    clrb                          No X coord conflict at all...will be fine
                    rts
* Comes here only if our window will start past left side of existing window
L023A               ldb       Wt.DfCPX,x          Get existing windows left border value
                    addb      Wt.DfSZX,x          Calculate existing window's right border
                    ifne      H6309
                    cmpr      b,a                 Our X start greater than existing windows right border?
                    else
                    pshs      b
                    cmpa      ,s+
                    endc
                    bge       L0262               Yes, legal coordinate
* X is fine, start checking Y
L0246               lda       Wt.CPY,y            Get our new window's requested top border value
                    cmpa      Wt.DfCPY,x          Compare with existing window's top border
L024B               bge       L0256               If we are lower on screen, jump ahead
                    adda      Wt.SZY,y            Calculate our bottom border
                    cmpa      Wt.DfCPY,x          Is it past the top border of existing window?
                    bgt       L0264               Yes, illegal coordinate
                    clrb                          Yes, window will fit legally, return with no error
                    rts

* Comes here only if our window will start below top of existing window
L0256               ldb       Wt.DfCPY,x          Get existing window's top border value
                    addb      Wt.DfSZY,x          Calculate existing window's bottom border
                    ifne      H6309
                    cmpr      b,a                 Our Y start less than bottom of existing?
                    else
                    pshs      b
                    cmpa      ,s+
                    endc
                    blt       L0264               Yes, would overlap, return error
L0262               clrb                          Yes, window will fit legally, return with no error
                    rts
L0264               comb                          Window won't fit with existing windows
                    ldb       #E$IWDef
L0286               rts

* Setup a new screen table
*L0268    bsr   FScrTbl      search for a screen table
*         bcs   L0286        not available, return
* X=Screen tbl ptr, Y=Window tbl ptr
L0268               stx       Wt.STbl,y           save the pointer in window table
                    ldb       <$60                get screen type
                    stb       St.Sty,x            save it to screen table
                    bsr       L029B               go setup screen table (Block & addr #'s)
                    bcs       L0286               couldn't do it, return
                    ldb       <$5A                get border color
                    stb       St.Brdr,x           save it in screen table
* This line added
                    ldb       Wt.Back,y           Get background color from window table
                    lbsr      L0791               get color mask for bckgrnd color
                    lbsr      L0335               clear the screen (with bckgrnd color)
                    leax      St.Pals,x           Point to palette regs in screen table
                    ldd       >WGlobal+G.DefPal   Get system default palette pointer
                    ifne      H6309
                    ldw       #16                 16 palettes to copy
                    tfm       d+,x+               Copy into screen table
                    else
                    pshs      b,y
                    tfr       d,y
                    ldb       #8
                    stb       ,s
L0287b              ldd       ,y++
                    std       ,x++
                    dec       ,s
                    bne       L0287b
                    puls      b,y
                    endc
                    clrb                          No error & return
                    rts                           Get back scrn tbl ptr & return

* Search for a empty screen table
FScrTbl             ldx       #STblBse+1          Point to screen tables+1
                    ldd       #$10*256+St.Siz     get # table entrys & entry size
L028D               tst       ,x                  already allocated a block?
                    bne       Yes                 Yes, go to next one
                    leax      -1,x                Bump pointer back by $980 based
                    clrb                          No error & return
                    rts

Yes                 abx                           move to next one
                    deca                          done?
                    bne       L028D               no, keep looking
                    comb                          set carry for error
                    ldb       #E$TblFul           get error code
                    rts                           return

* Setup screen table
* Entry: Y=Window table ptr
*        B=screen type (flags still set based on it too)
L029B               pshs      y                   preserve window table pointer
                    bpl       L02BB               Screen type not text, go on
                    ldy       #STblBse            Point to screen tables
                    lda       #$10                get # screen tables
* Search screen tables
L02A7               ldb       St.Sty,y            is it text?
                    bpl       L02B3               no, go to next one
                    ldb       St.SBlk,y           get memory block #
                    beq       L02B3               don't exist, go to next one
                    lbsr      L0306               search window block for a spot
                    bcc       L02DE               found one, go initialize it
L02B3               leay      St.Siz,y            move to next screen table
                    deca                          done?
                    bne       L02A7               no, keep going

* No screen available, get a new screen block
* NOTE: Should be able to change L02F1 loop to use W/CMPE to slightly
*       speed up/shrink
                    ldb       <$60                get STY marker
L02BB               lda       #$FF                preset counter
                    sta       <$B3                unused grfdrv space
                    ldy       #GrfStrt+L02FA-1    Point to RAM block table
                    andb      #$F                 make it fit table
                    ldb       b,y                 get # blocks needed
                    stb       <$B4                save number of blocks, unused space
OVLAP               inc       <$B3                update counter, unused space
                    ldb       <$B4                get number of blocks needed
                    os9       F$AlHRAM            AlHRAM Allocate memory ***********
                    bcs       L02EF               no memory, return error
                    pshs      b                   save starting block #
                    andb      #$3F                modulo 512K
                    pshs      b                   save modulo starting block
                    ldb       <$B4                regB now # blocks requested
                    decb                          set to base 0
                    addb      ,s
                    andb      #$3F                final block # modulo 512K
                    cmpb      ,s+                 compare with first block
                    blo       OVLAP               overlapped 512K boundary so ask for more RAM
                    bsr       DeMost
                    puls      b                   get starting block #
                    lda       <$B3
                    leas      a,s                 yank temps
                    ldy       #$8000              get default screen start
                    pshs      b,y                 save that & start block #
                    lbsr      L0173               setup MMU with screen
* Mark first byte of every possible screen in block with $FF
                    ldb       #$FF
L02D6               stb       ,y                  save marker
                    bsr       L02F1               move to next one
                    blo       L02D6               not done, keep going
                    puls      b,y                 restore block # & start address
* Initialize rest of screen table
L02DE               stb       St.SBlk,x           save block # to table
                    sty       St.LStrt,x          save logical screen start
                    lda       <$0060              get screen type
                    anda      #$F                 make it fit table
                    ldy       #GrfStrt+L0300-1    Point to width table
                    lda       a,y                 get width
                    sta       St.BRow,x           save it to screen table
                    clrb                          clear errors
L02EF               puls      y,pc                return

* Get rid of allocated blocks that overflowed 512K bank; RG.
DeMost              tst       <$B3                if none then return
                    beq       DA020
                    lda       <$B3
                    pshs      a,x
                    leay      6,s                 a,x,rts,b; point to first bad group
DA010               clra
                    ldb       ,y+                 get starting block number
                    tfr       d,x
                    ldb       <$B4                number of blocks
                    os9       F$DelRAM            de-allocate the blocks *** IGNORING ERRORS ***
                    dec       ,s                  decrease count
                    bne       DA010
                    puls      a,x
DA020               rts

* Move to next text screen in memory block
L02F1               leay      >$0800,y            move Y to next text screen start
                    cmpy      #$A000              set flags for completion check
L02F9               rts                           return

* Memory block requirement table (# of 8K banks)
L02FA               fcb       2                   640 2 color
                    fcb       2                   320 4 color
                    fcb       4                   640 4 color
                    fcb       4                   320 16 color
                    fcb       1                   80 column text
                    fcb       1                   40 column text

* Screen width in bytes table (# bytes/line)
L0300               fcb       80                  640 2 color
                    fcb       80                  320 4 color
                    fcb       160                 640 4 color
                    fcb       160                 320 16 color
                    fcb       160                 80 column
                    fcb       80                  40 column text

* Look for a empty window in a text screen memory block
L0306               pshs      d,x,y               Preserve regs
                    lbsr      L0173               go map in the screen
                    ldy       #$8000              get screen start address
                    ldb       #$FF                get used marker flag
L0311               cmpb      ,y                  used?
                    beq       L031C               no, go see if it will fit
L0315               bsr       L02F1               move to next screen
                    bcs       L0311               keep looking if not outside of block
L0319               comb                          set carry
                    puls      d,x,y,pc            return

L031C               lda       <$0060              get screen type
                    cmpa      #$86                80 column text?
                    beq       L032F               yes, return
                    leax      $0800,y             move to next screen to check if it will fit
                    cmpx      #$A000              will it fit in block?
                    bhs       L0319               no, return error
                    cmpb      ,x                  is it already used?
                    bne       L0315               yes, return error
L032F               clrb                          clear error status
                    puls      d,x
                    leas      2,s                 dump screen table pointer to keep screen address
                    rts                           return

* Clear screen (not window, but whole screen)
* Entry: B=Background color mask byte (from $6,x in window table)
*        X=Ptr to screen table
* Currently comes in with foreground color though.
* ATD: only called once, from just above...
L0335               pshs      x,y                 save regs
                    lda       #C$SPAC             get a space code
                    std       <$0097              init screen clear value to $00 (or attribute)
                    ldb       St.Sty,x            is window text?
L0343               ldy       St.LStrt,x          get screen start
                    andb      #$F                 make it fit table
                    lslb                          adjust for 2 bytes entry
                    ldx       #GrfStrt+L035A-2    Point to screen length table
                    ifne      H6309
                    ldw       b,x                 get length
                    else
                    pshs      x
                    ldx       b,x
                    stx       <$B5
                    puls      x
                    endc
                    cmpb      #$8                 Text mode?
                    bls       ClrGfx              No, do Graphics screen clear
* Clear text screen
                    ldx       <$0097              get screen clear codes ($2000)
                    ifne      H6309
                    tfr       w,d                 Move count to D
                    tfr       y,w                 Move ptr to faster indexing register
L0352               stx       ,w++                Store blank char on screen
                    decd      Dec                 counter
                    bne       L0352
                    else
                    ldd       <$B5
L0352               stx       ,y++
                    subd      #1
                    bne       L0352               Do until done screen
                    sty       <$B5
                    endc
                    puls      x,y,pc              Get back regs & return

* Screen length table
L035A               fdb       80*MaxLines*8       640 2 color   (gfx are 1 byte counts)
                    fdb       80*MaxLines*8       320 4 color
                    fdb       160*MaxLines*8      640 4 color
                    fdb       160*MaxLines*8      320 16 color
                    fdb       160*Maxlines/2      80 column text  (txt are 2 byte counts)
                    fdb       80*MaxLines/2       40 column text

* Clear a graphics screen
ClrGfx              ldx       #$1098              Point to clear code char.
                    ifne      H6309
                    tfm       x,y+                Clear screen
                    else
                    pshs      a
                    lda       ,x
                    ldx       <$B5
ClrGfx2             sta       ,y+
                    leax      -1,x
                    bne       ClrGfx2
                    stx       <$B5
                    puls      a
                    endc
                    puls      x,y,pc              Restore regs & return

* Part of window init routine
* Entry: Y=Window table ptr
*        X=Screen table ptr
L0366               ldd       #(TChr!Scale!Protect)*256 Transparency off & protect/Scale on
                    stb       Wt.GBlk,y           Graphics cursor memory block #0
                    std       Wt.BSW,y            Character switch defaults & Lset type 0
                    stb       Wt.PBlk,y           Pset block #0
                    ifne      H6309
* Assembler can't do $10000x#
*         ldq   #(GrfStrt+L1FA9)*65536+(GrfStrt+L1F9E) Normal LSET/PSET vector
                    fcb       $cd
                    fdb       GrfStrt+L1FA9,GrfStrt+L1F9E
                    stq       Wt.LVec,y           Save vectors
                    else
                    ldd       #GrfStrt+L1F9E
                    std       Wt.LVec+2,y
                    std       <$B5
                    ldd       #GrfStrt+L1FA9
                    std       Wt.LVec,y
                    endc
                    ldb       Wt.Fore,y           Get foreground palette #
                    lbsr      L074C               Get bit mask for this color
                    stb       Wt.Fore,y           Store new foreground bit mask
                    stb       <$0061              Store new foreground bit mask in GRFDRV's global
                    ldb       Wt.Back,y           Get background palette #
                    lbsr      L074C               Get bit mask for this color
                    stb       Wt.Back,y           Store new background bit mask
                    stb       <$0062              Store bckground bit mask in GRFDRV's global mem
                    lbsr      L079B               Set default attributes to new colors
                    ldd       St.LStrt,x          Get screen logical start
                    bsr       L03A9               Go copy scrn address/X&Y start to defaults area
                    clr       Wt.FBlk,y           Font memory block to 0 (no font yet)
* get group & buffer for font
                    ldd       #$C801              Default group/buffer number for font
                    std       <$0057
                    lbsr      L0643               Go set up for font
                    clrb                          No error and return
                    rts
* Move screen start address, X & Y coordinate starts of screen to 'default'
*   areas.  The first set is for what the window is currently at (CWArea
*   changes, for example), and the second set is the maximums of the window
*   when it was initialized, and thusly the maximums that can be used until
*   it is DWEnd'ed and DWSet'ed again.
* Entry :x= Screen table ptr
*        y= Window table ptr
*        d= Screen logical start address
L03A9               lbsr      L0581               Go set up window/character sizes
                    ifne      H6309
                    ldq       Wt.LStrt,y          Get screen start addr. & X coord start
                    stq       Wt.LStDf,y          Save as 'window init' values
                    else
                    ldd       Wt.LStrt,y
                    std       Wt.LStDf,y
                    ldd       Wt.LStrt+2,y
                    std       Wt.LStDf+2,y
                    std       <$B5
                    endc
                    ldd       Wt.SZX,y            Get Y coord start
                    std       Wt.DfSZX,y          Set default Y coord start
                    rts

* DWEnd entry point : NOTE: the LDD #$FFFF was a LDD #$FFFE from Kevin
*   Darling's 'christmas' patch. It is supposed to have something to do
*   with INIZ'ed but not screen allocated windows.
L03CB               lbsr      L0177               Go map in window
                    ldd       #$FFFF              Set screen table ptr to indicate not active
                    std       Wt.STbl,y
* This routine checks to see if we are the last window on the current screen
* Carry set if there is there is another window on our screen
* (Originally a subroutine...moved to save 2 bytes & 5 cycles
* Entry: Y=window table ptr
*        X=Screen table ptr?
L03FF               pshs      y,x                 Preserve window table & screen table ptrs
                    tfr       x,y                 Move for ABX
                    ldx       #WinBase            Point to window table entries
                    ldd       #MaxWind*256+Wt.Siz Get # entries & size
L0407               cmpy      Wt.STbl,x           Keep looking until we find entry on our screen
                    beq       L0414               Found one, error
                    abx                           Bump to next one
                    deca                          Keep doing until all 32 window entries are done
                    bne       L0407
                    clrb                          We were only window on screen, no error
*ATD: FCB $21: BRN = skip 1 byte
*         bra   L0415
                    fcb       $21                 BRN foo = skip one byte, same speed 1 byte less
L0414               comb                          Set flag (there is another window on screen)
L0415               puls      y,x                 Restore window table & screen table ptrs
                    bcs       L03F4               Not only window, CLS our area before we exit
                    bsr       L0417               Only one, deallocate mem for screen if possible
                    cmpy      <$002E              Our window table ptr same as current ptr?
* Note: The following line was causing our screen to clear which wrote over
* the $FF value we wrote at the beginning to flag the screen memory as free.
* This caused a memory leak in certain situations, like:
* iniz w1 w4;echo>/w1;echo>/w4;deiniz w4 w1
*         bne   L03F4          No, Clear our screen & exit
                    bne       L03F5               No, just exit
                    ifne      H6309
                    clrd                          Yes, clear current window & screen table ptrs
                    clrw
                    stq       <$2E
                    else
                    clra
                    clrb
                    std       <$2E
                    std       <$30
                    std       <$B5
                    endc
* Clear palettes to black
                    sta       >$ff9a              Border
                    ifne      H6309
                    stq       >$ffb0              And all palette regs
                    stq       >$ffb4
                    stq       >$ffb8
                    stq       >$ffbc
                    else
                    pshs      b,x
                    ldx       #$ffb0
                    ldb       #16
L03FCb              sta       ,x+
                    decb
                    bne       L03FCb
                    puls      b,x
                    endc
L03FC               jmp       >GrfStrt+SysRet     Return to system

* CLS our old screen with background color & leave if we weren't only window
*   on the screen (for Multi-Vue, for example)
L03F4               ldb       St.Back,x           Get background palette reg from screen table
                    stb       <$0062              Put into background RGB Data
                    lbsr      L1377               CLS the area we were in
*         clrb                 No errors
L03F5               jmp       >GrfStrt+L0F78      Return to system

* Called by DWEnd if we were only window on physical screen
* Entry: Y=window table ptr
*        X=screen table ptr
L0417               pshs      y                   Preserve window table pointer
                    lda       St.Sty,x            Get screen type
                    bpl       L043F               Graphics screen, can definately de-allocate
* Text window - could be others still active in 8K block
                    ldy       St.LStrt,x          Get screen phys. addr from screen table
                    ldb       #$FF                Mark this part of 8K block as unused
                    stb       ,y
                    cmpa      #$85                Is this an 80 column hardware text window?
                    bne       L042E               No, 40 column so just mark the 1 half
                    leay      >$0800,y            80 column so mark both halves as unused (since
                    stb       ,y                  routine below checks for 40 column markers)
L042E               ldy       #$8000              Point to first of 4 possible windows in block
* Check if entire 8K block is empty... if it is, deallocate it
L0432               cmpb      ,y                  Is this one already marked as unused?
                    bne       L0455               No, can't deallocate block so skip ahead
                    lbsr      L02F1               Yes, move to next text screen start in block
                    blo       L0432               Not last one, keep checking
                    ldb       #$01                # of memory blocks in this screen
                    bra       L0445               Deallocate the block from used memory pool
* If a graphics screen, get # blocks to deallocate
L043F               ldy       #GrfStrt+L02FA-1    Get # mem blocks for this screen
                    ldb       a,y
* Deallocate memory block(s) from screen since they are now unused
L0445               pshs      x,b                 Preserve screen table ptr & # blocks
                    clra                          clear MSB of D
                    ldb       St.SBlk,x           Get MMU start block # for screen
                    tfr       d,x                 Move to X
                    puls      b                   Get back # blocks to deallocate
                    os9       F$DelRAM            Deallocate the memory
* 03/02/92 MOD: A BAD DELRAM CALL WOULD LEAVE X ON THE STACK WHEN IT BCS'ED
* TO L0458, SO THE PULS & BCS ARE SWAPPED TO SET THE STACK CORRECTLY
                    puls      x                   get screen table ptr back
                    bcs       L0458               If error, return with error flags
L0455               clrb                          No error and set start block # to 0 (to indicate
                    stb       St.SBlk,x           not used)
L0458               puls      pc,y                Restore window table ptr & return

* Part of OWSet
* Entry: Y=New overlay window table ptr
* Exit: Overlay window table ptr on stack, Y=Parent window table ptr
L045A               puls      d                   Get RTS address
                    pshs      y,d                 Swap RTS address & Y on stack
                    ldb       Wt.BLnk,y           Get parent window #
                    lda       #Wt.Siz             Size of window table entries
                    mul
                    ldy       #WinBase            Point to start of window tables
                    leay      d,y                 Point to parent window entry
                    rts

* OWSet Entry point
L046A               bsr       L045A               Get parent window table ptr
                    lbsr      L0177               Map in parent window & setup grfdrv mem from it
                    ldd       ,s                  Y=parent, d=overlay
                    exg       y,d                 d=parent, y=overlay
                    std       ,s                  Stack=Parent window ptr, Y=Overlay window ptr
                    bsr       L049D               Check legitamacy of overlay coords & size
                    bcs       L049A               Illegal, exit with Illegal Coord error
                    ldd       Wt.STbl,x           Get root window's screen table ptr
                    std       Wt.STbl,y           Dupe into overlay window's screen table ptr
                    bsr       L04CC               Set up overlay window table from root table
                    ldb       <$0059              Save switch on?
                    beq       L0490               No, don't save original area (or clear it)
                    lbsr      L0516               Calculate sizes
                    bcs       L049A               error, return to system
                    ldb       Wt.Back,y           Get background color
                    stb       <$62                Make current background color
                    lbsr      L1377               CLS the overlay window area
L0490               puls      x                   Get parent's window table ptr
                    cmpx      <$002E              Is it the current window?
                    bne       L0499               No, exit without error
                    sty       <$002E              Make overlay window the current window
L0499               clrb                          No errors
L049A               jmp       >GrfStrt+SysRet     Return to system

* Make sure overlay window coords & size are legit
L049D               bsr       L04BA               Get pointer to 'root' device window into X
L049F               ldb       Wt.CPX,y            Get X coord start of overlay window
                    bmi       L04B7               If >=128 then exit with error
                    addb      Wt.SZX,y            Add current X size to X start
                    bcs       L04B7               added line: exit if 8-bit overflow
                    cmpb      Wt.DfSZX,x          Compare with maximum X size allowed
                    bhi       L04B7               Too wide, exit with error
                    ldb       Wt.CPY,y            Get current Y coord start
                    bmi       L04B7               If >=128 then exit with error
                    addb      Wt.SZY,y            Add current Y size to Y start
                    bcs       L04B7               added line: exit if 8-bit overflow
                    cmpb      Wt.DfSZY,x          Compare with maximum Y size allowed
                    bhi       L04B7               Too high, exit with error
                    clrb                          Will fit, exit without error
L04CB               rts

L04B7               jmp       >GrfStrt+L01F5      Exit with illegal coordinate error

* Search for device window entry at the bottom of this set of overlay windows
* Entry: Y=Current window ptr
* Exit:  X=Pointer to 'root' device window (in case of multiple overlays)
L04BA               tfr       y,x                 Move current window ptr to X
L04BC               ldb       Wt.BLnk,x           Get back window # link
                    bmi       L04CB               If overlay window itself, skip ahead
                    ldx       #WinBase            Point to start of window tables
                    lda       #Wt.Siz             Size of each entry
                    mul                           Calculate address of back window table entry
                    ifne      H6309
                    addr      d,x
                    else
                    leax      d,x
                    endc
                    bra       L04BC               Keep looking back until device window is found

* Set up new overlay window table based on root window information
* Entry: X=root window ptr, Y=overlay window ptr
L04CC               clr       Wt.OBlk,y           Overlay memory block #=0
                    lbsr      L079B               Go make default attribute byte from FG/BG colors
                    lda       Wt.Attr,x           Get the default attribute byte from root
                    anda      #$C0                Mask out all but Blink & Underline
                    ora       Wt.Attr,y           Merge with overlay window's colors
                    sta       Wt.Attr,y           Save new attribute byte
                    ifne      H6309
                    ldq       Wt.BSW,x            Set up other defaults in overlay based on root
                    stq       Wt.BSW,y
                    ldq       Wt.LVec,x
                    stq       Wt.LVec,y
                    else
                    ldd       Wt.BSW,x
                    std       Wt.BSW,y
                    ldd       Wt.BSW+2,x
                    std       Wt.BSW+2,y
                    ldd       Wt.LVec,x
                    std       Wt.LVec,y
                    ldd       Wt.LVec+2,x
                    std       Wt.LVec+2,y
                    endc
                    ldd       Wt.FOff+1,x
                    std       Wt.FOff+1,y
                    ldb       Wt.GBlk,x
                    stb       Wt.GBlk,y
                    ldd       Wt.GOff,x
                    std       Wt.GOff,y
                    ldb       Wt.Fore,y           Get foreground palette
                    lbsr      L074C               Get bit mask if gfx window
                    stb       Wt.Fore,y           Store color or mask
                    ldb       Wt.Back,y           Get background palette
                    lbsr      L074C               Get bit mask if gfx window
                    stb       Wt.Back,y           Store color or mask
                    ldd       Wt.LStrt,x          Get screen logical start address
                    jmp       >GrfStrt+L03A9      Set up rest of window table & return

* Entry: X=root window table ptr
*        Y=Overlay window table ptr
* Exit:  <$4F=X screen size (chars if hware text, pixels if Gfx)
*        <$51=Y screen size (char lines if hware text, pixels if Gfx)
L0516               pshs      x                   Preserve root window table ptr
                    bsr       xy.intoq            get X,Y size for text/gfx into Q
                    ifne      H6309
                    stq       <$4F                Save X and Y screen size (chars or pixels)
                    else
                    pshs      d
                    std       <$4F
                    ldd       <$B5
                    std       <$51
                    puls      d
                    endc
                    clrb
                    std       <$0047              Set current X coordinate to 0
                    lbsr      L0BEA               Calculate # bytes wide overlay is
                    puls      pc,x                Restore root window table ptr & return

* OWEnd entry point
L053A               lbsr      L0177               Map in window & set up Grfdrv mem from it
                    cmpy      <$2E                Is this the current interactive window?
                    bne       L054A               No, skip ahead
                    lbsr      L045A               Yes, get parent window tbl ptr into Y
                    sty       <$002E              Make parent window the new interactive window
                    puls      y                   Get overlay window tbl ptr back
L054A               ldb       Wt.OBlk,y           Get MMU block # of overlay window
                    beq       L0562               If none, save switch was off, so skip ahead
                    lbsr      L017C               Map in get/put block
                    stb       <$007D              Save block #
                    ldd       Wt.OOff,y           Get ptr to buffer start in block
                    std       <$007E              Save that too
                    lbsr      L0CF8               Go put it back on the screen
                    lbsr      L092B               Hunt down the overlay window GP Buffer
                    lbsr      L0A55               Kill the buffer (free it up)
L0562               ldd       #$FFFF              Mark window table entry as unused
                    std       Wt.STbl,y
                    bra       L057D               Exit without error

L0569               comb
                    ldb       #E$IllCmd           Exit with Illegal Command error
                    bra       L057E

* CWArea entry point
L056E               lbsr      L0177               Map in the window
                    tfr       y,x                 Move window tbl ptr to X
                    lbsr      L049F               Make sure coords will fit in orig. window sizes
                    bcs       L057E               No, exit with error
                    ldd       Wt.LStDf,y          get screen logical start
                    bsr       L0581               go do it
L057D               clrb                          No error
L057E               jmp       >GrfStrt+SysRet     return to system

* This routine is ONLY called from L0516 (CWArea) and L0581 (OWSet)
* As these routines are not called too often, we can add 10 clock cycles
xy.intoq            clra                          clear carry for ROLW, below
                    ldb       Wt.SZY,y            Get current Y size of overlay window into W
                    ifne      H6309
                    tfr       d,w                 move Y-size into W
                    else
                    std       <$B5
                    endc
                    ldb       Wt.SZX,y            Get current X size of overlay window into D
                    tst       <$60                Test screen type
                    bmi       L0530               If hardware text, exit without doing more shifts
                    ifne      H6309
                    rolw                          multiply by 8 for # pixels down
                    rolw
                    rolw                          E=$00 and CC.C=0 from above,so this is really ASLW
                    lslb                          Multiply by 8 for # pixels across
                    lsld                          A=$00 from CLRA, above.  Max 80
                    lsld
                    else
                    lsl       <$B6
                    rol       <$B5
                    lsl       <$B6
                    rol       <$B5
                    lsl       <$B6
                    rol       <$B5
                    lslb
                    lslb
                    rola
                    lslb
                    rola
                    endc
L0530               rts

* Entry :x= Screen table ptr
*        y= Window table ptr
*        d= Screen logical start address
L0581               pshs      d,x                 Preserve Screen start & screen tbl ptr
                    ldb       <$0060              get STY marker
                    andb      #$0F                keep only first 4 bits
                    ldx       #GrfStrt+L05E1-1    Point to # bytes/text char table
                    ldb       b,x                 get number bytes/char
                    stb       Wt.CWTmp,y          Preserve # bytes/char
                    lda       Wt.SZX,y            get current X size (of window)
                    mul                           Calculate # bytes wide window is
                    stb       Wt.XBCnt,y          Preserve #bytes wide window is
                    clra                          #bytes per row MSB to 0
                    ldb       <$0063              Get #bytes per row on screen
                    tst       <$0060              Text or graphics screen?
                    bmi       L05A1               If text, we already have # bytes per row
                    ifne      H6309
                    lsld                          If graphics, multiply x 8 since each text row
                    lsld                          is 8 sets of lines
                    lsld
                    else
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    endc
L05A1               std       Wt.BRow,y           Preserve # bytes/text row (8 lines if gfx)
                    clra
                    ldb       Wt.CPY,y            Get Upper left Y coord of window
                    ifne      H6309
                    muld      Wt.BRow,y           Calculate Y coordinate start
                    stw       <$0097              save Y offset
                    else
                    pshs      x,y,u
                    ldx       Wt.BRow,y
                    lbsr      MUL16
                    stu       <$97
                    stu       <$B5
                    puls      x,y,u
                    endc
                    lda       Wt.CPX,y            get X coordinate start
                    ldb       Wt.CWTmp,y          get # bytes per text character
                    mul                           calculate where X starts
                    addd      ,s++                add it to screen start address
                    addd      <$0097              add in Y offset
                    std       Wt.LStrt,y          get screen logical start
                    lbsr      L11E1               home cursor
                    ldb       <$0060              get STY marker
                    bmi       L05C0               text, don't need scale factor
                    bsr       L05E7               calculate scaling factor
* Calculate window X size in either pixels or characters
* Q is D:W  D=X size, W=Y size
L05C0               bsr       xy.intoq            get X and Y for text/gfx into Q
                    ifne      H6309
                    decw                          adjust Y to start at 0
                    decd      adjust              X to start at 0
                    stq       Wt.MaxX,y           save maximum X co-ordinate
                    else
                    subd      #1
                    std       Wt.MaxX,y
                    pshs      d
                    ldd       <$B5
                    subd      #1
                    std       <$B5
                    std       Wt.MaxX+2,y
                    puls      d
                    endc
                    puls      x,pc                restore & return

* # bytes for each text char
L05E1               fcb       $01                 640 2 color
                    fcb       $02                 320 4 color
                    fcb       $02                 640 4 color
                    fcb       $04                 320 16 color
                    fcb       $02                 80 column text (includes attribute byte)
                    fcb       $02                 40 column text (includes attribute byte)

* Graphic window scaling constants (When multiplied by the maximum width/
* height of the screen in characters, they equal 256. The resulting figure
* is rounded up by 1 if the result has a fraction >=.8.
* The resulting rounded figure (1 byte long) is then used by multiplying
* it with the coordinate requested, and then dividing by 256 (dropping
* the least significiant byte). The resulting 2 byte number is the scaled
* coordinate to actually use.)
* The actual scaling factor is a 16x8 bit multiply (Scale factor by # of
* columns/rows) into a 3 byte #. If the LSB is >=$CD (.8), then round up
* the 2nd byte by 1 (MSB is unused). The 2nd byte is the scaling factor.
* X scaling constants for 640x screen
XSclMSB             fdb       $0333               X Scaling factor (~3.2)

* Y scaling constants (note: fractional part of 200 line has changed from
* $3f to $3e, since that is closer to get the 256 mod value)
YScl192             fdb       $0AAB               Y Scaling factor for 192 row scrn (~10.668)
YScl200             fdb       $0A3E               Y Scaling factor for 200 row scrn (~10.2422)

* Calculate scaling factors for a graphics window (# row/columns*scale factor)
* Must be as close to 256 as possible
L05E7               clra                          D=# of columns
                    ldb       Wt.SZX,y
                    ifne      H6309
                    muld      <XSclMSB,pc         Multiply by X scaling factor
                    cmpf      #$cd                Need to round it up if >=.8?
                    else
                    pshs      x,y,u
                    ldx       <XSclMSB,pc
                    lbsr      MUL16
                    stu       <$B5
                    tfr       u,d
                    cmpb      #$cd
                    tfr       y,d
                    puls      x,y,u
                    endc
                    blo       saveXscl            No, save result
                    ifne      H6309
                    ince                          Round it up
saveXscl            ste       Wt.SXFct,y          Save X scaling multiplier
                    else
                    inc       <$B5
saveXscl            pshs      a
                    lda       <$B5
                    sta       Wt.SXFct,y
                    puls      a
                    endc
                    ldb       Wt.SZY,y            D=# of rows (A=0 from MULD already)
                    cmpb      #25                 Is it the full 25 lines?
                    blo       useold              No, use old scaling factor for compatibility
                    ifne      H6309
                    muld      <YScl200,pc         Multiply by 200 line Y scaling factor
                    else
                    pshs      x,y,u
                    ldx       <YScl200,pc
                    lbsr      MUL16
                    stu       <$B5
                    tfr       y,d
                    puls      x,y,u
                    endc
                    bra       chkrnd
useold              equ       *
                    ifne      H6309
                    muld      <YScl192,pc         Multiply by 192 line Y scaling factor
                    else
                    pshs      x,y,u
                    ldx       <YScl192,pc
                    lbsr      MUL16
                    stu       <$B5
                    tfr       y,d
                    puls      x,y,u
                    endc
chkrnd              equ       *
                    ifne      H6309
                    cmpf      #$cd                Need to round it up if >=.8?
                    else
                    pshs      b
                    ldb       <$B6
                    cmpb      #$cd
                    puls      b
                    endc
                    blo       saveYscl            No, save result
                    ifne      H6309
                    ince                          Round it up
                    else
                    inc       <$B5
                    endc
saveYscl            equ       *
                    ifne      H6309
                    ste       Wt.SYFct,y          Save Y scaling multiplier
                    else
                    pshs      a
                    lda       <$B5
                    sta       Wt.SYFct,y
                    puls      a
                    endc
                    rts

* PSet entry point - Change <$16,y vector to proper pattern drawing
L0611               ldb       <$0057              get group mem block #
                    bne       L061D               If a pattern is wanted, go find it
                    stb       Wt.PBlk,y           Set memory block # to 0 (PSET patterning off)
                    ldx       #GrfStrt+L1F9E      Point to normal PSET vector
                    bra       L0635               Go preserve vector & exit without error

L061D               lbsr      L0930               Go search buffers for the one we want
                    bcs       L0639               If the buffer doesn't exist, exit with error
                    stb       Wt.PBlk,y           Save PSET block #
                    leax      Grf.Siz,x           Skip Gfx buffer header
                    stx       Wt.POff,y           Save offset to actual graphics data
                    ldb       [Wt.STbl,y]         Get screen type from screen table
                    ldx       #GrfStrt+L1FB4-1    Point to table (-1 since scrn type 0 illegal)
                    ldb       b,x                 Get unsigned offset for vector calculation
                    abx                           Calculate address of vector
L0635               stx       Wt.PVec,y           Preserve PSET vector
L0638               jmp       >GrfStrt+L0F78      Return to system, without any errors

* Font entry point
L063C               lbsr      L0177               Map in window
                    bsr       L0643               Go set font group #
L0639               jmp       >GrfStrt+SysRet     Return to system

L0643               ldb       <$0057              get block number for font buffer
                    bne       L064A               If there is one, go set it up
                    stb       Wt.FBlk,y           Set font memory block # to 0 (no fonts)
                    rts

L064A               lbsr      L1002               Go set the font ('.' font default if none)
                    lbsr      L0930               Search buffers for proper one
                    bcs       L0684               Error, skip ahead
                    pshs      x,b                 Preserve graphics buffer table ptr & b
                    ldd       Grf.XSz,x           Get X size of buffer
                    cmpd      #6                  6 pixel wide buffer?
                    beq       L0662               Yes, go on
                    cmpd      #8                  8 pixel wide buffer?
                    bne       L0685               Not a font, report buffer # error
* It is a buffer size that matches those acceptable to fonts
L0662               ldd       Grf.YSz,x           Get Y size of buffer
                    cmpd      #8                  8 pixel high buffer?
                    bne       L0685               No, report buffer # error
                    stb       Grf.XBSz,x          Preserve font height
                    ldd       Grf.XSz,x           Get X size of buffer again
                    cmpd      <$006E              Get X pixel count
                    beq       L067D               Same, set up normally
                    ldb       Wt.FBlk,y           Check font block #
                    beq       L067D               If there is none, exit normally (pointing to '.')
                    lbsr      L11CD               If not, do CR & set up width of line
L067D               puls      x,b                 Get back regs
                    stb       Wt.FBlk,y           Store block # where font is
                    stx       Wt.FOff,y           Store offset to font within 8K block
                    clrb                          No error and return
L0684               rts

* Can't do font
L0685               puls      x,b                 Get block # and graphics table buffer ptr back
                    ldb       #E$BadBuf           bad buffer # error
                    coma                          Set error flag
                    rts

* GCSet entry point
L068B               lbsr      L0177               Map in window
                    ldb       <$0057              Get group # for graphics cursor
                    bne       L0697               There is one, go process
                    stb       Wt.GBlk,y           Set to 0 to flag that graphics cursor is off
                    bra       L0639               Return to system
L0697               lbsr      L0930               Go search graphics buffers for the one we want
                    bcs       L0639               Can't find, return to system with error
                    stb       Wt.GBlk,y           Store block # of graphics cursor
                    stx       Wt.GOff,y           Store offset into block for graphics cursor
                    bra       L0638               Return to system with no errors

* FColor entry point
L0707               ldb       [Wt.STbl,y]         Get screen type from screen table
                    stb       <$0060              Save as current screen type
                    ldb       <$005A              Get palette number from user
                    bsr       L074C               Go get mask for it
                    stb       Wt.Fore,y           Save foreground palette #
                    ifne      H6309
                    tim       #Invers,Wt.BSW,y    Inverse on?
                    else
                    ldb       Wt.BSW,y            regB does not need to be preserved
                    bitb      #Invers
                    endc
                    bne       L0738               Yes, go process for that
L0719               ldb       <$005A              get palette register number
                    lslb                          Move into foreground of attribute byte
                    lslb
                    lslb
                    andb      #$38                Clear out blink/underline & background
                    lda       Wt.Attr,y           Get default attributes
                    anda      #$C7                Mask out foreground
                    bra       L0742               OR in new foreground

* BColor entry point
L0726               ldb       [Wt.STbl,y]         Get screen type from screen table
                    stb       <$0060              save it in global
                    ldb       <$005A              get palette register #
                    bsr       L074C
                    stb       Wt.Back,y           save background into window table
                    ifne      H6309
                    tim       #Invers,Wt.BSW,y    Inverse on?
                    else
                    ldb       Wt.BSW,y            regB does not need to be preserved
                    bitb      #Invers
                    endc
                    bne       L0719               If set, do masking to switch fore/bck ground colors

L0738               ldb       <$005A              Get palette register #
                    andb      #$07                Force to 0-7 only
                    lda       Wt.Attr,y           Get default attributes
                    anda      #$F8                Mask out background
L0742               equ       *
                    ifne      H6309
                    orr       b,a                 Merge the color into attribute byte
                    else
                    pshs      b
                    ora       ,s+
                    endc
                    sta       Wt.Attr,y           Store new default attribute
L0748               clr       <$A9                No error, clear flag & return to system
                    jmp       >GrfStrt+SysRet

* Convert color to allowable ones for screen type
* NOTE: see if we can swap a/b roles to allow ABX instead of LEAX A,X
L074C               pshs      x,a                 Preserve screen table ptr & a
                    lda       <$0060              get STY marker
                    bmi       L075D               text or same screen, return
                    ldx       #GrfStrt+L075F-1    Point to mask table
                    lda       a,x                 Get offset to proper mask set
                    leax      a,x                 Point to the mask table
                    andb      ,x+                 Mask out bits we can't use on this type screen
                    ldb       b,x                 Get bit mask for the foreground color
L075D               puls      pc,x,a              restore regs & return

L075F               fcb       L0763-(L075F-1)     $05   (640/2 color table offset)
                    fcb       L0766-(L075F-1)     $08   (320/4 color table offset)
                    fcb       L0766-(L075F-1)     $08   (640/4 color table offset)
                    fcb       L076B-(L075F-1)     $0d   (320/16 color table offset)

* Color masks for 640 2 color
L0763               fcb       $01
                    fcb       $00,$ff

* Color masks for 640 and 320 4 color
L0766               fcb       $03
                    fcb       $00,$55,$aa,$ff

* Color masks for 320 16 color
L076B               fcb       $0f
                    fcb       $00,$11,$22,$33,$44,$55,$66,$77
                    fcb       $88,$99,$aa,$bb,$cc,$dd,$ee,$ff

* Get foreground color mask
L0791               tst       ,x                  Check screen type?
                    bpl       L074C               If graphics, mask out values scrn type can't use
                    andb      #$07                Just least significiant 3 bits
                    rts

* Make default attribute byte from current fore/background colors (blink &
*   underline forced off)
L079B               ldb       Wt.Fore,y           Get foreground palette #
                    andb      #$07                Use only 0-7
                    lslb                          Shift to foreground color position
                    lslb
                    lslb
                    lda       Wt.Back,y           Get background palette #
                    anda      #$07                Use only 0-7
                    ifne      H6309
                    orr       a,b                 Merge foreground & background
                    else
                    pshs      a
                    orb       ,s+
                    endc
                    stb       Wt.Attr,y           Set new default attributes
                    rts

* Select entry point
* Entry: Y=Newly selected window pointer
* ATD: !! Save DP, too.
L07D7               pshs      y                   save Window table ptr we will be going to
                    ldy       <$002E              get window table ptr we are going from
                    beq       L07E1               If none, skip ahead
                    lbsr      L0177               set variables/MMU & update cursors on old window
L07E1               ldb       >WGlobal+G.CurTik   Reload counter for # ticks/cursor updates
                    stb       >WGlobal+G.CntTik
                    ldy       ,s                  get 'to' window table pointer
                    lbsr      L0129               Map in window & setup grfdrv mem for new window
                    sty       <$002E              save it as current window entry
                    stx       <$0030              set current screen table pointer
                    tfr       x,y                 Move to Y reg
L08DB               ldx       #$FF90              point to Gime registers
*ATD: Do a TFR 0,DP: larger but faster?
                    ldu       #$0090              point to shadow RAM for GIME hardware
                    ifne      H6309
                    aim       #$7f,,u             remove Coco 1/2 compatibility bit: set from CoVDG
                    ldb       ,u                  get new value
                    else
                    ldb       ,u
                    andb      #$7f
                    stb       ,u
                    endc
                    stb       ,x                  save it to GIME
* Calculate extended screen address for 1 or 2 Meg upgrade
* Entry: X=$FF90 (start of GIME regs)
*        Y=Screen table ptr
* Exits: With GIME (and shadow regs) pointing to proper GIME screen address &
*        proper 512k bank (via Disto's DAT) that screen is in (0-3 for up to
*        2 Meg of RAM)
                    clra
                    sta       $0F,x               Set horizontal scroll to 0
                    sta       $0F,u               And set it's shadow
                    ldb       St.SBlk,y           Get block # of screen
                    ifne      H6309
                    lsld                          Multiply by 4 (to shift which 512k bank into A)
                    lsld
                    else
                    lslb
                    rola
                    lslb
                    rola
                    endc
                    stb       <$0082              Remainder is the block #(0-3F) in this 512k bank
*                         No, remainder is V.OFF1 of this block. RG.
                    clrb                          vertical scroll=0
                    std       $0B,x               Set which of up to 4 512K banks video is from
                    std       $0B,u               And set it's shadow, along with vertical scroll
                    ldd       St.LStrt,y          Get screen logical start
                    suba      #$80                Subtract $80 from MSB of that address
                    ifne      H6309
                    lsrd                          Divide result by 8
                    lsrd
                    lsrd
                    else
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    endc
                    adda      <$0082              Add to MSB of 24 bit extended screen address
                    std       $0D,x               Store result into GIME's vertical offset register
                    std       $0D,u               and it's shadow

                    ldx       #GrfStrt+L086A.24-2 GIME setup table for 24-line screens
                    ldb       St.ScSiz,y          get screen size into B
                    cmpb      #24                 24-line screens?
                    beq       L0840               if so: skip ahead; else get 25-line pointer
                    ldx       #GrfStrt+L086A.25-2 GIME setup table for 25-line screens

L0840               ldb       ,y                  get screen type we need
                    andb      #$0F                keep only first 4 bits
                    lslb                          multiply by 2 (2 bytes per entry)
                    abx                           find entry
                    lda       $08,u               get current GIME video mode register
                    anda      #$78                keep only non video bits
                    ora       ,x                  bring in new video mode
                    ldb       1,x                 get Video resolution
* ATD: for new 'garbage-less' CLRing, and new clock, save these values
* at $08,u, and set $06,u: The clock will clear the flag at $0096, and update
* the GIME video hardware at the _start_ of the IRQ process.
                    std       $08,u               save new GIME shadow registers
                    std       >$FF98              save it to GIME
* Set up colors on GIME for newly selected window
                    ldb       St.Brdr,y           Get current border palette #
                    leay      St.Pals,y           Point to palette register data in scrn tbl
                    ifne      H6309
                    ldf       >WGlobal+G.MonTyp   Get monitor type in F for faster translates
                    endc
                    ldb       b,y                 Get border color
                    stb       $0A,u               Save new border color to GIME shadow
                    ifne      H6309
                    tstf                          Need to convert color?
                    else
                    tst       >WGlobal+G.MonTyp
                    endc
                    bne       DoBord              Nope
                    ldx       #GrfStrt+L0884      Point to translation table
                    ldb       b,x                 Get composite version
DoBord              stb       >$ff9a              Save it on GIME
                    ldu       #$FFB0              U=GIME palette reg. ptr
                    ifne      H6309
                    tstf                          Rest of colors need translation?
                    else
                    tst       >WGlobal+G.MonTyp
                    endc
                    bne       FstRGB              No, use TFM
* Composite translate here
                    lda       #$10                A=# of colors
L0851               ldb       ,y+                 Get RGB color
                    ldb       b,x                 Get composite version
                    stb       ,u+                 Save it to GIME
                    deca                          Done?
                    bhi       L0851               No, keep going
                    bra       DnePaltt            Done, go do Gfx cursor
FstRGB              equ       *
                    ifne      H6309
                    ldw       #$0010              Palette register ptr & # palette regs
                    tfm       y+,u+               Move them onto GIME
                    else
                    pshs      d
                    ldb       #16
FstRGB2             lda       ,y+
                    sta       ,u+
                    decb
                    bne       FstRGB2
                    clra
                    std       <$B5
                    puls      d
                    endc

* ATD: PULS DP, too
DnePaltt            puls      y                   Restore window entry
                    ifne      H6309
                    ldq       <$3D                Get last coords that Gfx cursor was ON at
                    stq       <$5B                Save as current coords of Gfx cursor
                    else
                    ldd       <$3F
                    std       <$5D
                    std       <$B5
                    ldd       <$3D
                    std       <$5B
                    endc
                    lbsr      L153B               Update 'last gfx cursor on' position to new one
                    jmp       >GrfStrt+L0F78      return to system: no errors

* GIME graphics register values
*     1st byte goes to $ff98
*     2nd byte goes to $ff99
* NOTE: To change to 25 line TV res (200 not 225), change $0475 & $0465 to
* $033D & $032D respectively (approx $825 in V1.15+)
*       ifeq MaxLines-25
L086A.25            fdb       $8034               640x200 2 color
                    fdb       $8035               320x200 4 color
                    fdb       $803D               640x200 4 color
                    fdb       $803E               320x200 16 color
                    ifeq      TV-1
                    fdb       $033D               80x25, 200 line screen
                    fdb       $032D               40x25, 200 line screen
                    else
                    fdb       $0475               80x25, 225 line screen
                    fdb       $0465               40x25, 225 line screen
                    endc

*       else
L086A.24            fdb       $8014               640x192 2 color
                    fdb       $8015               320x192 4 color
                    fdb       $801D               640x192 4 color
                    fdb       $801E               320x192 16 color
                    fdb       $0315               80x24, 192 line screen
                    fdb       $0305               40x24, 192 line screen
*       endc

* 64 color translation table for RGB to composite monitor
L0884               fcb       $00,$0c,$02,$0e,$07,$09,$05,$10
                    fcb       $1c,$2c,$0d,$1d,$0b,$1b,$0a,$2b
                    fcb       $22,$11,$12,$21,$03,$01,$13,$32
                    fcb       $1e,$2d,$1f,$2e,$0f,$3c,$2f,$3d
                    fcb       $17,$08,$15,$06,$27,$16,$26,$36
                    fcb       $19,$2a,$1a,$3a,$18,$29,$28,$38
                    fcb       $14,$04,$23,$33,$25,$35,$24,$34
                    fcb       $20,$3b,$31,$3e,$37,$39,$3f,$30

* DefGPB entry point
L08DC               bsr       L08E1               go do it
                    jmp       >GrfStrt+SysRet     return to system

* Entry point for internal DefGPB (Ex. Overlay window)
L08E1               ldd       <$80                get buffer length requested
                    addd      #$001F              round it up to even multiples of 32 bytes
                    andb      #$E0                (to allow for header)
                    std       <$80                Preserve new value
                    ldb       <$57                get group
                    cmpb      #$FF                overlay window save?
                    beq       L08F8               yes, skip ahead
                    tst       <$32                No, has there been any buffers?
                    beq       L08F8               no, go make one
                    bsr       L0930               Yes, see if we can fit one in
                    bcc       L096A               Return Bad/Undefined buffer error
L08F8               ldd       <$80                get requested length including header
                    cmpd      #$2000              over 8k?
                    bhi       L090A               yes, skip ahead
                    bsr       L0975               Find block & offset to put it (new or old)
                    bcs       L090A               If couldn't find/allocate, skip ahead
                    lda       #$01                1 8K block used for this buffer
                    sta       Grf.NBlk,x
                    bra       L090F               Skip ahead
* Couldn't find existing block that would fit it
L090A               lbsr      L09A8               Go allocate blocks & map 1st one in
                    bcs       L0928               Error, exit with it
L090F               stb       <$007D              Save start block #
                    stx       <$007E              Save offset into block
                    lbsr      L09FC               Update get/put buffer header & last used in global
                    ldd       <$0057              Get group & buffer #
                    std       Grf.Grp,x           save group & buffer # into buffer header
                    ldd       <$0080              Get buffer size (not including header)
                    std       Grf.BSz,x           save buffer size in buffer header
                    ifne      H6309
                    clrd
                    clrw
                    stq       Grf.XSz,x           Init X and Y sizes to 0
                    else
                    clra
                    clrb
                    std       Grf.XSz,x
                    std       Grf.XSz+2,x
                    std       <$B5
                    endc
                    std       Grf.LfPx,x          Init Pixel masks for 1st & last bytes in block
                    stb       Grf.STY,x           set internal screen type marker
L0928               rts

* Set vector for overlay window buffer search
L092B               ldx       #GrfStrt+L093F      Point to overlay window bffr search routine
                    bra       L0933               set the vector & do search

* Set vector for graphics buffer search
L0930               ldx       #GrfStrt+L0949      Point to normal buffer search routine
L0933               stx       <$A1                save the search routine vector
                    bsr       L096E               initialize previous table pointers
                    ldb       <$32                get the last block # we used for buffers
                    beq       L096A               Wasn't one, return error
                    ldx       <$33                get last offset
                    bra       L0961               go map it in & do search routine

* Overlay window buffer search
L093F               cmpb      Wt.OBlk,y           is this the right overlay?
                    bne       L0957               no, move to next one and come back again
                    cmpx      Wt.OOff,y           set conditions for offset match
                    bra       L0955               go check it

* Graphics buffer search
L0949               lda       <$0057              get group we're looking for
                    cmpa      Grf.Grp,x           find it?
                    bne       L0957               nope, keep looking
                    lda       <$0058              get buffer #
                    beq       L0968               done, return
                    cmpa      Grf.Buff,x          match?
L0955               beq       L0968               yes, return
L0957               stb       <$007D              save it as previous block #
                    stx       <$007E              save previous offset
                    ldb       Grf.Bck,x           get back block # link
                    beq       L096A               there isn't one, return
                    ldx       Grf.Off,x           get offset
L0961               lbsr      L017C               go map it in
                    jmp       [>GrfMem+gr00A1]    Do search again
L0968               clra                          No error & exit
                    rts
L096A               comb                          Bad buffer # error & exit
                    ldb       #E$BadBuf
                    rts

* Initialize previous buffer pointers
L096E               equ       *
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    stb       <$7D                Buffer block #
                    std       <$7E                Buffer offset #
                    rts

* Called by DefGPB
* Find get/put buffer & block # with room (or make new one)
* Exit: B=Block #, X=Ptr to where next GP buffer could go
L0975               pshs      b,y                 Preserve regs
                    ldy       <$0080              get size of buffer requested
                    ldx       #GrfStrt+L0AE0      Set vector to find empty space in a block big
                    stx       <$00A1              enough to fit the size we want
                    lbsr      L0ACD               Go find it
                    bcs       L09A6               Couldn't find, exit with carry set
                    stb       ,s                  Change B on stack to block # we found
                    ldd       Grf.BSz,x           Get buffer size from GP header
                    subd      <$0080              Subtract the buffer size we need
                    bne       L099B               If not exact fit, skip ahead
                    pshs      x                   Preserve GP buffer ptr a sec
                    lbsr      L0A1C               Map in previous block or new block?
                    puls      x                   Restore GP buffer ptr
                    ldb       ,s                  Get block # we found
                    lbsr      L017C               Go map it in
                    bra       L09A5               exit without error
L099B               subd      #$0020              Don't include GP header in GP's buffer size
                    std       Grf.BSz,x           Store size into GP header's size
                    leax      Grf.Siz,x           Point to start of actual GP buffer data
                    leax      d,x                 Point to where next GP buffer will go
L09A5               clra                          No error
L09A6               puls      pc,y,b              Restore regs and return

* If initial search couldn't find/fit block, or if size>8K, go here
* Some of stack pushing/Temp storing could be done in E/F instead
* Particularily <$99
* Map in buffer needed (or 1st block of it if >8K)
L09A8               ldd       <$80                Get original size we wanted
                    addd      #$0020              Add block header size
                    std       <$97                Preserve into temp area
                    addd      #$1FFF              Round up to 8K
                    lsra                          Divide by 32 for # blocks needed
                    lsra
                    lsra
                    lsra
                    lsra
                    tfr       a,b                 Dupe into B
                    ifne      H6309
                    tfr       a,f                 And into F
                    else
                    sta       <$B6
                    endc
                    os9       F$AllRAM            Allocate memory
                    bcs       L09FB               Couldn't allocate, return with error
                    ifne      H6309
                    tfr       b,e                 Preserve start block #
                    cmpf      #$01
                    else
                    stb       <$B5
                    ldb       <$B6                regB does not need to be preserved
                    cmpb      #1
                    endc
                    bhi       L09EE               If more than 1 block requested, skip ahead
                    ldd       #$2000              8k
                    subd      <$97                Calculate # bytes left in block after our buffer
                    anda      #$1F                Round to within 8K
                    std       <$9B                Store in another temp
                    beq       L09EE               Exact size of 8K block, skip ahead
                    ldd       #$2000              Size of block
                    subd      <$9B                subtract rounded size left in block
                    adda      #$20                Add 8K so it points to address in GRFDRV's get/
                    tfr       d,x                 put buffer block (which is where it will be)
                    ifne      H6309
                    tfr       e,b                 B=Start block # of allocated RAM
                    else
                    ldb       <$B5
                    endc
                    lbsr      L017C               map it in
                    bsr       L0A0C               Set up new block hdr's back links & current
                    ldd       <$9B                Get # bytes left in block
                    subd      #$0020              Subtract header size
                    std       Grf.BSz,x           Preserve buffer size in header

L09EE               ldx       #$2000              Start address of GRFDRV's get/put buffer block
                    ifne      H6309
                    tfr       e,b                 Move start block # to proper register
                    else
                    ldb       <$B5
                    endc
                    lbsr      L017C               Map it in
                    ifne      H6309
                    stf       Grf.NBlk,x          Save # of blocks needed for whole buffer
                    else
                    lda       <$B6
                    sta       Grf.NBlk,x
                    endc
                    clra                          No error & return
L09FB               rts

* Update last get/put buffer used info & Get/Put buffer header
* Updates $32 & $33-$34
* Entry: D=Size left in second block
L09FC               pshs      d                   Preserve D
                    lda       <$32                Get last mapped in block for Get/Put buffers
                    sta       Grf.Bck,x           Make that the block # for our header
                    stb       <$32                Put our new last mapped block
                    ldd       <$33                Get last mapped offset
                    std       Grf.Off,x           Put that into our header
                    stx       <$33                Put our new offset into the last mapped offset
                    puls      pc,d                restore D & return

* Update current get/put buffer info & Get/Put Buffer header
* Updates $35 & $36-$37
*Entry: X=ptr to start of buffer header in GRFDRV's 2nd block (Get/put buffer)
L0A0C               pshs      d                   Preserve D
                    lda       <$35                Get current block/group #
                    sta       Grf.Bck,x           Make new block's back ptrs. point to it
                    stb       <$35                Make current ptr to start block we just allocated
                    ldd       <$36                Get current offset
                    std       Grf.Off,x           Put into new block's offset
                    stx       <$36                Make current offset our new one
                    puls      pc,d                Restore D and return

* Make current GP buffer block & offset same as previous block & offset
*  (or map in new one and set it's header up if there is no previous one)
L0A1C               pshs      y,a                 Preserve regs
                    lda       Grf.Bck,x           get back block link #
                    ldy       Grf.Off,x           Get offset in back block to it's header
                    ldx       <$7E                Get previous blocks offset to buffer
                    ldb       <$7D                and it's block #
                    bne       L0A30               None mapped in, go map it in
                    sta       <$35                Make into current block & offset
                    sty       <$36
                    puls      pc,y,a              Restore regs & return
L0A30               lbsr      L017C               Bring in 8K buffer block we need
                    sta       Grf.Bck,x           Set up GP block header
                    sty       Grf.Off,x
L0A38               puls      pc,y,a

* KillBuf entry point
L0A3A               ldb       #$01                Set a temporary flag
                    stb       <$0097
L0A3E               lbsr      L0930               Go search for buffer (returns X=Buffer ptr)
                    bcs       L0A4D               Couldn't find it, exit
                    clr       <$0097              Found it, clear flag
                    bsr       L0A55
                    bcs       L0A52
                    ldb       <$0058
                    beq       L0A3E
L0A4D               lda       <$0097              Get flag
                    bne       L0A52               Didn't get killed, return to system with error
                    clrb                          No error
L0A52               jmp       >GrfStrt+SysRet     Return to system

L0A55               pshs      y,x,b               Preserve regs (Window tbl ptr,gfx bffr ptr,block#)
                    lda       Grf.NBlk,x          Get # blocks used
                    sta       <$009F              Save it
                    lda       Grf.Bck,x           Get back block #
                    ldy       Grf.Off,x           Get back block header offset
                    ldb       <$007D              Get current buffer block #
                    bne       L0A6B               There is one, continue
                    sta       <$0032              Save back block as last block used
                    sty       <$0033              And it's offset
                    bra       L0A75

L0A6B               lbsr      L017C               Go map in GP Block
                    ldx       <$007E
                    sta       Grf.Bck,x
                    sty       Grf.Off,x
L0A75               ldb       ,s
                    lda       <$009F
                    cmpa      #$01
                    bgt       L0A9E
                    tfr       b,a
                    bsr       L0AA8
                    bcc       L0A94
                    ldx       #GrfStrt+L0AF4
                    stx       <$00A1
                    ldx       1,s
                    bsr       L0ACD
                    lbsr      L017C
                    lbsr      L0A0C
                    puls      pc,y,x,b

L0A94               ldx       #GrfStrt+L0B1E
                    stx       <$00A1
                    ldx       1,s
                    bsr       L0ACD
L0A9E               clra
                    tfr       d,x
                    ldb       <$009F
                    os9       F$DelRAM            Deallocate the memory
L0AA6               puls      pc,y,x,b

L0AA8               pshs      x,b
                    ldb       <$0032
                    beq       L0AC7
                    cmpa      <$0032
                    beq       L0ACA
                    ldx       <$0033
                    bra       L0AC2

L0AB6               cmpa      Grf.Bck,x
                    beq       L0ACA
                    tst       Grf.Bck,x
                    beq       L0AC7
                    ldb       Grf.Bck,x
                    ldx       Grf.Off,x
L0AC2               lbsr      L017C
                    bra       L0AB6
L0AC7               clrb
                    puls      pc,x,b
L0ACA               comb
                    puls      pc,x,b

* Subroutine called by L0975 (of DefGPB)
* Entry: Y=Size of buffer requested (including $20 byte header)
L0ACD               pshs      d,x                 Preserve regs
L0ACF               lbsr      L096E               initialize previous buffer ptrs to 0 ($7D-$7F)
                    ldb       <$35                get last buffer block #
                    beq       L0B35               If 0, exit with carry set
                    ldx       <$36                get offset of last one into 8K block
                    bra       L0B2E               Go map in get/put memory block & continue

* <8K buffer define vector goes here
* Entry: X=Offset to current buffer being checked in current 8K block
*        Y=Size wanted
L0AE0               cmpy      Grf.BSz,x           Will requested size fit?
                    bhi       L0B22               Too big, keep looking backwards
                    bra       L0B38               Exit with carry clear & B=block #, X=offset

L0AE7               tfr       u,d
                    addd      Grf.BSz,u
                    addd      #Grf.Siz
                    ifne      H6309
                    cmpr      x,d
                    else
                    pshs      x
                    cmpd      ,s++
                    endc
                    rts

* A vectored routine (usually pointed to by $A1)
L0AF4               cmpb      1,s
                    bne       L0B22
                    ldu       2,s
                    ldb       Grf.Bck,x
                    stb       Grf.Bck,u
                    ldd       Grf.Off,x
                    std       Grf.Off,u
                    exg       x,u
                    bsr       L0AE7
                    beq       L0B0E
                    exg       x,u
                    bsr       L0AE7
                    bne       L0B22
L0B0E               stu       2,s
                    ldd       Grf.BSz,u
                    addd      Grf.BSz,x
                    addd      #Grf.Siz
                    std       Grf.BSz,u
L0B19               lbsr      L0A1C
                    bra       L0ACF
L0B1E               cmpb      ,s
                    beq       L0B19
* Search backwards through existing 8K blocks allocated for Get/Put buffers
* until we hit beginning
L0B22               ldb       <$8A                Get GrfDrv MMU block # for get/put buffer block
                    stb       <$7D                Move to block #
                    stx       <$7E                Save offset into block as well
                    ldb       Grf.Bck,x           Get back block link #
                    beq       L0B35               None, exit with carry set
                    ldx       Grf.Off,x           Get back block header offset
* Entry: X=offset into current 8K buffer/block # last used for buffer
L0B2E               lbsr      L017C               Map in Get/Put buffer memory block
                    jmp       [>GrfMem+gr00A1]    Jump to vector (can be AE0 below)

L0B35               comb                          Set carry, restore regs & return
                    puls      pc,x,d

L0B38               stb       1,s                 Buffer fits, put block & offset into B & X
                    stx       2,s
                    clrb                          No error
                    puls      pc,x,d              Restore new regs and return

* GPLoad entry point
L0B3F               lbsr      L0930               go look for group/buffer # requested
                    bcs       L0B52               Didn't find, go create one
                    ifne      H6309
                    ldw       Wt.BLen,y           Get size requested
                    cmpw      Grf.BSz,x           Will it fit in existing buffer?
                    else
                    pshs      d
                    ldd       Wt.BLen,y           Get size requested
                    std       <$B5
                    cmpd      Grf.BSz,x           Will it fit in existing buffer?
                    puls      d
                    endc
                    bls       L0B60               Yes, go do it
                    ifne      H6309
                    bra       L0BE4               No, exit with buffer size too small error
                    else
                    lbra      L0BE4
                    endc

L0B52               ldd       Wt.BLen,y           Get size requested
                    std       <$0080              Save in grfdrv mem
                    lbsr      L08E1               Go define a get/put buffer for ourselves
                    lbcs      L0BE7               Couldn't find room, exit with error
                    ldb       <$007D              Get buffer block #
L0B60               stb       Wt.NBlk,y           Save buffer block # to GPLoad into
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       <$47                Working X coord to 0?
                    ldb       <$60                Get screen type
* Possible bug: doesn't check if text screen first?
                    lbsr      L0C2B               Directly into Graphics size calculation
                    lbsr      L0C69               Go setup the GP buffer header
                    leax      Grf.Siz,x           Point past GP header (to where data would go)
                    stx       Wt.NOff,y           Save ptr to where next GPLoad will go
                    jmp       >GrfStrt+L0F78      no errors, and exit

* Move buffer entry point (This ONLY gets called via the Move Buffer vector
*   from CoGRF or CoWin)
* It's used to do Get/Put buffer loads in small chunks since GRFDRV's memory
*   map can't fit a window's static mem
* Entry: F=Byte count (Maximum value=72 / $42)
*        Y=Window table ptr
L0B79               ldb       Wt.NBlk,y           get block # for next graphic buffer
                    stb       <$0097              save it
                    lbsr      L017C               go map it in
                    ldx       Wt.NOff,y           get offset into block
                    ldu       #$1200              Point to buffer of where GRFInt/CoWin put info
                    ifne      H6309
                    clre                          make 16 bit number in W
                    tfr       w,d                 dupe count into D
                    addr      x,d                 Point to current block offset+size of request
                    else
                    clra
                    sta       <$B5
                    ldb       <$B6                loaded in CoWin
                    pshs      x
                    addd      ,s++                addr x,d
                    endc
                    cmpa      #$40                Past end of GP buffer's 8K block?
                    blo       MoveIt              No, go move whole thing in one shot
* Move data between 2 blocks of memory
                    ldd       #$4000              calculate how much will fit in first pass
                    ifne      H6309
                    subr      x,d
                    subr      d,w                 move leftover to D
                    exg       d,w                 Move first chunk size to W
                    tfm       u+,x+               move first chunk
                    tfr       d,w                 move leftover back to W
                    else
                    pshs      x                   save regX
                    subd      ,s++                subr x,d
                    pshs      d,y                 save regD regY
                    ldd       <$B5
                    subd      ,s                  subr d,w
                    std       <$B5                this is the value of regW after tfm & tfr d,w
                    ldy       ,s++                get counter regD after subr x,d & exg d,w
                    beq       LMoveb
LMove               lda       ,u+
                    sta       ,x+
                    leay      -1,y
                    bne       LMove
LMoveb              puls      y                   restore regY
                    lda       <$B5                may not be needed
                    endc
                    inc       <$0097              increment to next block #
                    ldb       <$0097              get new block #
                    lbsr      L017C               map it in
                    ldx       #$2000              reset pointer to start of block
MoveIt              equ       *
                    ifne      H6309
                    tfm       u+,x+               Block copy buffer into GP buffer
                    else
                    pshs      y
                    ldy       <$B5
                    beq       LMove2b
LMove2              lda       ,u+
                    sta       ,x+
                    decb
                    leay      -1,y
                    bne       LMove2
                    sty       <$B5
LMove2b             puls      y
                    endc
L0BA2               ldb       <$0097              get the block #
                    stb       Wt.NBlk,y           update it in table
                    stx       Wt.NOff,y           save next offset in table
                    jmp       >GrfStrt+L0F78      no errors, and exit grfdrv

L0BE4               comb                          Buffer size too small error
                    ldb       #E$BufSiz
L0BE7               jmp       >GrfStrt+SysRet

* GetBlk entry point
L0BAE               lbsr      L1DF6               Go scale X/Y coords @ <$47-$4A,check if in range
                    bcs       L0BE7               No, exit with error
                    ifne      H6309
                    ldq       <$4f                Get X/Y sizes
                    decd      Bump                down by 1 each since size, not coord
                    decw
                    stq       <$4f                Save
                    else
                    ldd       <$51
                    subd      #1
                    std       <$51
                    std       <$B5
                    ldd       <$4f
                    subd      #1
                    std       <$4f
                    endc
                    lbsr      L1E01               Go scale X/Y Sizes @ <$4f-$52,check if in range
                    bcs       L0BE7               No, exit with error
                    ifne      H6309
                    ldq       <$4f                Get X/Y sizes
                    incd                          Bump back up
                    incw
                    stq       <$4f                Save
                    else
                    ldd       <$51
                    addd      #1
                    std       <$51
                    std       <$B5
                    ldd       <$4f
                    addd      #1
                    std       <$4f
                    endc
                    lbsr      L0177               Map in window & setup some GRFDRV vars.
                    bsr       L0C0B               Calc width of buffer in bytes & next line offset
                    lbsr      L0930               Go search for GP buffer
                    bcc       L0BC9               Found it, skip ahead
                    lbsr      L08E1               Couldn't, create one
                    bcc       L0BD4               Got one, skip ahead
                    bra       L0BE7               Otherwise, exit with error

* Found GP buffer already defined
L0BC9               stb       <$007D              Save block #
                    stx       <$007E              Save offset into block
                    ldd       <$0080              Get buffer length
                    cmpd      Grf.BSz,x           Within range of buffer's current length?
                    bhi       L0BE4               No, exit with Buffer Size Too Small error
* GP buffer will fit requested data size
L0BD4               lbsr      L0C69               Go set up the GP buffer's header
                    lbsr      L1E9D               Go calculate addr. on screen to start GETting @
                    stx       <$0072              Save it
                    ldx       <$007E              Get offset into GP buffer block
                    lbsr      L0C8D               Go copy from screen into buffer
L0BE1               jmp       >GrfStrt+L0F78      exit with no errors

* Save switch on- comes here to save screen contents under overlay window
* into a get/put buffer
* Entry: Y=Current (or current Overlay) window ptr
L0BEA               ldd       Wt.LStrt,y          Get screen logical start address
                    std       <$72                Make it the overlay window save start
                    bsr       L0C0B               Calculate sizes in bytes, etc.
                    ldd       #$FFFF              Group & buffer # to $FF
                    std       <$57
                    lbsr      L08E1               Define get/put buffer for overlay window
                    bcs       L0C0A               Error defining buffer;exit with it
                    ldb       <$007D              Get MMU block # for overlay window copy
                    stb       Wt.OBlk,y           Save in window table
                    ldd       <$007E              Get offset into MMU block for overlay window copy
                    std       Wt.OOff,y           Save it in window table
                    bsr       L0C69               Set up get/put buffer header
                    bsr       L0C8D               Preserve screen under overlay window
                    clrb                          No error & return
L0C0A               rts

* Setup # bytes wide overlay window is & offset to get to next line in overlay
*   window when saving/restoring
* Entry: Y=Current (or current Overlay) window ptr
L0C0B               ldb       <$60                Get screen type
                    bpl       L0C18               If gfx window, skip ahead
                    ldb       <$50                Get LSB of X size of overlay window
                    lslb                          Multiply x2 (for attribute byte)
                    stb       <$09                Save width of window (in bytes)
                    bra       L0C1C               Skip ahead

L0C18               bsr       L0C2B               Calculate width info for Gfx windows
                    ldb       <$09                Get # bytes for width of window
L0C1C               lda       <$52                Get height of window in bytes
                    mul                           Calculate total # bytes needed
                    std       <$80                Preserve # bytes needed to hold saved area
                    ldb       <$63                Get # bytes per row on screen
                    subb      <$09                Subtract # bytes wide saved area will be
                    stb       <$0A                Store # bytes to next line after current width is done
                    rts                           Return

* Calculate GP buffer width in bytes for graphics, & # pixels used in first &
*  last bytes of each GP buffer line
*   (Used by GetBlk, GPLoad, OWSet)
* Entry: B=Screen type
L0C2B               lda       #%00000111          2 color divide by 8 mask
                    decb
                    beq       L0C38               For 640x200x2 screens
                    lda       #%00000001
                    cmpb      #$03                If 320x200x16, divide by 2 mask
                    beq       L0C38
                    lda       #%00000011          If any 4 color gfx window, divide by 4 mask
L0C38               sta       <$97                Preserve mask for # pixels used in 1 byte
                    ldb       <$48                Get working X coordinate LSB (0 from OWSet)
                    comb                          Make 'hole' to calculate # pixels
                    andb      <$97                Use mask to calculate # pixels used
                    incb                          Make base 1
                    stb       <$06                Preserve # pixels used in 1st byte of GP line
                    clra                          D=# pixels used in last byte
                    cmpd      <$4F                More than # bytes on screen?
                    bge       L0C53               Yes,
                    ldb       <$50                Otherwise, get LSB of X size in bytes
                    subb      <$06                Subtract # pixels used in first byte
                    andb      <$97                Calculate # pixels in last byte
                    bne       L0C53               If not 0, it is legit
                    ldb       <$97                If it is 0, then use full byte's worth
                    incb
L0C53               stb       <$07                Save # pixels used in last byte of GP line
                    clra                          D=# of pixels wide GP buffer is
                    ldb       <$48                Get LSB of 'working' X coordinate
                    andb      <$97                AND it with # pixels/byte
                    addd      <$4F                Add value to X size (in bytes)
                    addb      <$97                Add # pixels/byte
                    adca      #$00                Make into D register
* Divide loop: Divide by 4 for 16 color, by 8 for 4 color & by 16 for 2 color
L0C60               equ       *
                    ifne      H6309
                    lsrd                          Divide by 2
                    else
                    lsra
                    rorb
                    endc
                    lsr       <$97                Shift right
                    bne       L0C60               until we hit first 0 bit
                    stb       <$09                # bytes for width of overlay window
                    rts

* Setup buffer header
L0C69               equ       *
                    ifne      H6309
                    ldq       <$004F              get X & Y sizes (in pixels)
                    stq       Grf.XSz,x           save it in buffer header
                    else
                    ldd       <$51
                    std       Grf.XSz+2,x
                    std       <$B5
                    ldd       <$4F
                    std       Grf.XSz,x
                    endc
                    ldb       <$0060              get screen type
                    stb       Grf.STY,x           save it in header
                    ldd       <$0006              Get start & end pixel masks (for uneven bytes)
                    std       Grf.LfPx,x          save them in header
                    ldb       <$0009              Get width of buffer in bytes?
                    stb       Grf.XBSz,x          save it in header
                    clra                          D=B
                    std       <$004F              Save into working X coord
                    rts

* Move get/put buffer to screen
* Entry: Y=Ptr to GP buffer?
L0C81               tfr       y,x                 X=Ptr to GP buffer
                    lda       <$0097              Get # bytes to start on next GP line on screen
                    sta       <$000A              Save in another spot
                    lda       #$01                flag we're going to screen
                    fcb       $21                 skip 1 byte

* Move get/put buffer to mem
L0C8D               clra                          Flag we're going to memory
                    sta       <$0099              save flag
* Move buffer to screen/mem
* Attempt reversing roles of D & W
                    pshs      y                   preserve y
                    leay      Grf.Siz,x           get pointer to raw buffer data
                    ldx       <$0072              get address of screen
L0C96               ldb       <$0050              Get width count of buffer
                    bsr       PutOneL             put one line
                    ldb       <$000A              get width # bytes to start of next GP line on scrn
                    abx                           move to next line
                    dec       <$0052              done height?
                    bne       L0C96               no, go do next line
                    puls      pc,y                restore & return

* put one line from a GP buffer onto the screen
PutOneL             clra                          make 16-bit number of width of GP buffer
                    ifne      H6309
                    tfr       d,w                 copy it to W
                    addr      y,d                 check if we will need to get next GP 8k bank
                    else
                    std       <$B5
                    pshs      y
                    addd      ,s++
                    endc
                    cmpa      #$40                do we?
                    blo       L0C98               nope, go do it
                    ldd       #$4000              calculate # bytes we can do from this 8k bank
                    ifne      H6309
                    subr      y,d
                    subr      d,w                 calculate leftover into W
                    exg       d,w                 Swap for copy
                    else
                    pshs      y
                    subd      ,s++                subr y,d
                    pshs      d,u                 save regD & regU
                    ldd       <$B5                get regW
                    subd      ,s                  subr d,w regD now = regW
                    ldu       ,s++                get regD
                    stu       <$B5                exg d,w
                    puls      u
                    endc
                    bsr       L0C98               move first chunk
                    ifne      H6309
                    tfr       d,w                 Move remainder to W
                    else
                    std       <$B5
                    endc
                    lbsr      L0E70               go map in next block & reset buffer pointer

* Move a graphics line of data
* Entry: W=# contigous bytes to move
L0C98               tst       <$0099              going to screen or mem?
                    bne       L0CA2               screen, go move it
                    ifne      H6309
                    tfm       x+,y+               Copy from screen to mem
                    rts
                    else
                    pshs      a,x,u
                    tfr       x,u
                    ldx       <$B5
                    beq       LMove3b
LMove3              lda       ,u+
                    sta       ,y+
                    leax      -1,x
                    bne       LMove3
                    stx       <$B5
                    stu       1,s
LMove3b             puls      a,x,u,pc
                    endc

L0CA2               equ       *
                    ifne      H6309
                    tfm       y+,x+               Copy from mem to screen
                    rts
                    else
                    pshs      a,x,u
                    tfr       x,u
                    ldx       <$B5
                    beq       LMove4b
LMove4              lda       ,y+
                    sta       ,u+
                    leax      -1,x
                    bne       LMove4
                    stx       <$B5
                    stu       1,s
LMove4b             puls      a,x,u,pc
                    endc

* PutBlk entry point
* Entry from GRF/WINDInt:
* <$57=Group #
* <$58=Buffer #
* <$47=Upper left X coord
* <$49=Upper left Y coord
L0CBB               lbsr      L0177               Go map in window & setup some GRFDRV vars
                    lbsr      L0930               search & map in get put buffer
                    bcs       L0CF5               Error; exit with it
                    stb       <$007D              save block # of buffer
                    stx       <$007E              save offset into block buffer starts at
                    ifne      H6309
                    ldq       Grf.XSz,x           Get X&Y Sizes of buffer
                    decd      Adjust              since width, not coord
                    decw
                    stq       <$4F                Save them
                    else
                    ldd       Grf.XSz+2,x
                    subd      #1
                    std       <$51
                    std       <$B5
                    ldd       Grf.XSz,x
                    subd      #1
                    std       <$4f
                    endc
                    lbsr      L1DF6               Check validity/scale starting X/Y coords
                    bcs       L0CF5               Error, exit with it
                    lbsr      L1E01               Check validity/scale X&Y sizes
                    bcs       L0CF5               Error; exit with it
                    ifne      H6309
                    ldq       <$4f                Adjust widths back
                    incd
                    incw
                    stq       <$4f
                    else
                    ldd       <$51
                    addd      #1
                    std       <$51
                    std       <$B5
                    ldd       <$4f
                    addd      #1
                    std       <$4f
                    endc
                    lbsr      L1E9D               calculate screen address & start pixel mask
                    stx       <$0072              save screen address
                    stb       <$0074              Save start pixel mask
                    ldy       <$007E              get ptr to GP buffer
                    lda       #$01                Flag to indicate we have to check size vs. window
                    bsr       L0D14               Go set up start/end pixel masks & check scrn types
                    bcs       L0CEE               If screen type different or has to be clipped, go
                    lbsr      L0D9D               Screen types same & fits; do normal putting
                    bra       L0CF4               return without error
* Get/put width buffer's original screen type being different from actual
*   screen type or will go ever edge of window go here
L0CEE               lbsr      L0E03               ??? Do set up for screen type conversions
                    lbsr      L0E97               Do actual PUTting
L0CF4               clrb                          No error & return to system
L0CF5               jmp       >GrfStrt+SysRet

* Place Overlay window's original contents back on screen
L0CF8               pshs      y                   Preserve window table ptr
                    ldd       Wt.LStrt,y          get screen logical start address
                    std       <$0072              Save it
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       <$0047              'Working' X Coord to 0
                    ldy       <$007E              Get offset to buffer
                    bsr       L0D14               Go verify that overlay can fit back on screen
                    bcs       L0D0F               Couldn't put, exit with error
                    lbsr      L0C81               Move get/put buffer to screen (fast put)
                    clrb                          No error & return
                    puls      pc,y
L0D0F               comb
                    ldb       #$BE                get internal integrity check error
                    puls      pc,y

* Check for common screen type between window & buffer, and check if the
* PUT will need to be clipped. If screen types different or clipping
* required, exit with carry set
L0D14               pshs      x                   Save screen address
                    ldb       <$0060              get screen type
                    cmpb      Grf.STY,y           Same as screen type of GP buffer's screen type?
                    beq       GdTyp               Yes, no problem so far
* 03/03/93 mod: 4 color windows will count as same type
                    tstb                          (to properly check high bit)
                    bmi       L0D63               If text, exit with carry set
                    bitb      #$02                Check 4 color mode bit
                    beq       L0D63               Not a 4 color mode, so set carry & exit
                    ifne      H6309
                    tim       #$02,Grf.STY,y      Check 4 color mode bit in buffer's screen type
                    else
                    pshs      a
                    lda       Grf.STY,y
                    bita      #2
                    puls      a
                    endc
                    beq       L0D63               It's no a 4 color mode, so set carry & exit
GdTyp               tstb                          graphics window?
                    bpl       L0D27               yep, go on
                    ldb       #$FF                Group # forced to $FF (overlay window)
                    stb       <$0000              Set right based pixel mask to all
                    stb       <$0001              Ditto for left based
                    bra       L0D58               Skip ahead
* Process graphics put (A=1 if straight from PutBlk,0 if from OWEnd)
* If A=1, need to see if window fits (L0D27 routine)
* If A=0, we already know it did, so we can skip size checks

* Should change CLIPPING checks so that it just changes some DP variables
*  for # bytes to print line, # bytes per line on screen & # bytes per line
*  in GP buffer. That way even byte/same color mode clipped GP buffers will go
*  full speed as well.
L0D27               bsr       L0D94               set up <$50 = X-count, <$52 = y-count
                    tsta                          Do we already know size is legit?
                    beq       L0D3F               Yes, skip ahead
* don't bother for now to do clipping on X-boundaries, i.e. off rhs of the
* screen
                    ldd       Grf.XSz,y           size in pixels of the GP buffer
                    ldd       <$0047              Get upper left X coord of PUT
                    addd      Grf.XSz,y           Add X size of GP buffer
                    cmpd      <$006A              past max X coord.?  (i.e. 319)
                    bls       L0D30               no, don't clip it
                    ifne      H6309
                    decd      are                 we overflowing by one pixel  (i.e.320)
                    else
                    subd      #1
                    endc
                    cmpd      <$006A              check against highest allowed X
                    bne       L0D63               not the same, so we go clip it
L0D30               ldd       Grf.YSz,y           Get Y size: ATD: 16-bit, so we can check for >256!
                    addd      <$0049              add it to upper left Y coord. ( max 199)
                    cmpd      <$006C              past max Y coord.?
                    blo       L0D3F               no, don't bother clipping it
* Y coord clipping added 03/10/96 by ATD
                    ldd       <$006C              get max. Y coord
                    subd      <$0049              take out starting Y coord
                    ifne      H6309
                    incd                          make it PUT at least one line...
                    else
                    addd      #1
                    endc
                    stb       <$52                save y-count of pixels to do

* Divide by # pixels / byte to see if even byte boundary
L0D3F               ldb       <$0060              get screen type
                    ldx       #GrfStrt+L0D70-1    Point to powers of 2 division table
                    lda       <$0048              get LSB of X coord.
                    coma                          invert it
                    anda      b,x                 Get # ^2 divisions
                    inca                          Add 1
                    cmpa      Grf.LfPx,y          Same as # pixels used in 1st byte of GP buffer?
                    bne       L0D63               No, set carry indicating non-even byte boundary
                    bsr       L0D66               Go get starting/ending pixel masks
                    sta       <$0000              Save right-based mask
                    ldd       Grf.RtPx,y          Get right based pixel mask & GP buffer type
                    bsr       L0D66               Go get starting/ending pixel masks
                    stb       <$0001              Save left-based pixel mask
                    fcb       $8C                 skip setting up
* Text put comes here with B=Group # ($FF) for overlay windows
* Entry: B=buffer block #
L0D58               bsr       L0D94               Move x-size to $50 y-size to $52
                    ldb       <$0063              Get # bytes/row for screen
                    subb      <$0050              subtract LSB of X size
                    stb       <$0097              Save width of buffer
                    clrb                          No error, restore screen address & return
                    puls      pc,x
L0D63               comb                          Different screen types or clipping required, set
                    puls      pc,x                carry, restore screen address & return

* Entry: B=Gfx screen type (1-4)
* A=# pixels to go in?
L0D66               ldx       #GrfStrt+L0D74-1    Point to table
                    ldb       b,x                 Get vector offset to proper table
                    abx                           Calculate vector
                    lsla                          2 bytes/entry
                    ldd       a,x                 Get both masks & return
                    rts

* Some sort of bit mask table - appears to be used in a LSR loop after inverted
*   ,will continue loop until the carried bit changes to 0
L0D70               fcb       %00000111           640x200x2
                    fcb       %00000011           320x200x4
                    fcb       %00000011           640x200x4
                    fcb       %00000001           320x200x16

* Vector table based on screen type (points to following 3 tables)
L0D74               fcb       L0D78-(L0D74+1)     640x200x2
                    fcb       L0D88-(L0D74+1)     320x200x4
                    fcb       L0D88-(L0D74+1)     640x200x4
                    fcb       L0D90-(L0D74+1)     320x200x16

* 2 color masks (2 bytes/entry)
L0D78               fcb       %00000001,%10000000
                    fcb       %00000011,%11000000
                    fcb       %00000111,%11100000
                    fcb       %00001111,%11110000
                    fcb       %00011111,%11111000
                    fcb       %00111111,%11111100
                    fcb       %01111111,%11111110
                    fcb       %11111111,%11111111

* 4 color masks
L0D88               fcb       %00000011,%11000000
                    fcb       %00001111,%11110000
                    fcb       %00111111,%11111100
                    fcb       %11111111,%11111111

* 16 color masks
L0D90               fcb       %00001111,%11110000
                    fcb       %11111111,%11111111

* Copy X Size & Y size from GP buffer header
* Entry: Y=GP buffer header ptr
L0D94               ldb       Grf.XBsz,y          Get X size of GP buffer in bytes
                    stb       <$50                Save X size of GP buffer in bytes
                    ldb       Grf.YSz+1,y         Get Y size of GP buffer in bytes
                    stb       <$52                Save Y size of GP buffer in bytes (pixels)
                    rts

* Put buffer with buffer's screen type matching actual screen type
L0D9D               ldb       <$60                Get screen type
                    ldx       #GrfStrt+L16B1-1    Point to table
                    lda       b,x                 Get # pixels per byte for this screen type
                    tfr       a,b                 Dupe for D comparison
* no PSET?
                    ldx       #GrfStrt+L1F9E      Point to 'normal' PSET vector
                    cmpx      <$64                Is that the current one?
                    bne       L0DBE               No, use slow PUT
* no LSET?
                    ldx       #GrfStrt+L1FA9      Point to 'normal' LSET vector
                    cmpx      <$68                Is that the current one?
                    bne       L0DBE               Yes, can use TFM PUT
* no even byte boundary?
                    cmpd      Grf.LfPx,y          Even byte boundary on both left & right sides?
                    lbeq      L0C81               yes, go do fast TFM put
* odd pixel boundaries: do 1st pixel slow, use TFM for the rest
                    sta       <$0099              flag we're copying to the screen
                    ldd       <$00                masks for pixels to keep from GP buffer
                    ifne      H6309
                    comd
                    else
                    coma
                    comb
                    endc
                    std       <$20                masks for pixels to keep from screen
                    ldx       <$0072              get start address for PUT
                    leay      $20,y               skip GP buffer header
* do first byte of the line: almost a complete TFM
Put.ATFM            lda       ,x                  grab first byte
                    anda      <$20                get only pixels we want to keep
                    ldb       ,y                  grab pixels from GP buffer
                    andb      <$00                get the ones we want to keep
                    ifne      H6309
                    orr       b,a                 OR the pixels together
                    else
                    pshs      b
                    ora       ,s+
                    endc
                    sta       ,y                  save in the GP buffer
                    ldd       <$4F                get width of GP buffer in bytes
                    ifne      H6309
                    decd      account             for 0th byte
                    else
                    subd      #1
                    endc
                    lda       d,x                 get right hand byte from the screen
                    pshs      a                   save end byte
                    ifne      H6309
                    incd
                    else
                    addd      #1
                    endc
                    lbsr      PutOneL             blast it over using TFM
* do the last byte of the line
* this kludge is necessary because doing it the proper way would add a LOT
* of code to check for GP buffer 8k block boundaries.  It won't be noticed
* except for really large PutBlks.  Oh well.
                    lda       <$0001              get end pixel mask
                    anda      -1,x                keep only the pixels we want
                    ldb       <$0021              inverted mask
                    andb      ,s+                 AND in with original screen data
                    ifne      H6309
                    orr       b,a                 OR in the pixel we put on the screen
                    else
                    pshs      b
                    ora       ,s+
                    endc
                    sta       -1,x                save it
                    ldb       <$0097              get width of the screen
                    abx                           go to the next line
                    dec       <$52                count down one line
                    bne       Put.ATFM
                    rts

* Either not even byte, or PSET/LSET or not defaults:use slow PUT
L0DBE               sta       <$05                Save # pixels/byte
                    pshs      y                   Save Get/Put buffer ptr
                    ldu       <$64                Get PSET vector
                    ifne      H6309
                    ldw       <$68                Get LSET vector (for PSET routine)
                    else
                    ldx       <$68
                    stx       <$B5
                    endc
                    leay      <$20,y              Skip buffer header
                    ldx       <$72                Get address of where to start PUTting on scrn
                    inc       <$97                Save # bytes to start of next line GP buffer
                    dec       <$50                Adjust X byte count down for base 0
* Loop from here to end of L0DFA - Move Get/Put buffer onto screen using LSET
* logic.
* This outside part does the 1st byte's worth of pixels
* NOTE: X=ptr to current byte being done on screen
*       Y=ptr to current byte being done in GP buffer
L0DCB               ldb       <$00                Get pixel mask for 1st byte of 1st line in buffr
                    lda       <$50                Get LSB of X size
                    beq       L0DED               If 0, just 1 byte to do - use last byte routine
                    sta       <$99                Save LSB of X size
* This part does all the full-byte pixels
L0DD5               ldb       #$FF                Mask byte- all bits
L0DD7               lda       ,y+                 Get bits to set from GP buffer
                    jsr       ,u                  Put on screen
                    ldb       #1                  Screen ptr bump count
                    abx                           Bump screen ptr
                    cmpy      #$4000              Done current 8K block of Get/put buffer?
                    blo       L0DE7               No, continue normally
                    lbsr      L0E70               Yes, go map in next block
L0DE7               dec       <$99                Dec X byte count
                    bne       L0DD5               Continue moving until done X size
* This part does the last byte's worth of pixels
                    ldb       <$01                Get pixel mask for last byte of last line
L0DED               lda       ,y+                 Get last byte for current line in GP buffer
                    jsr       ,u                  Put it on screen
                    cmpy      #$4000              Done 8K block yet?
                    blo       L0DFA               No, skip ahead
                    lbsr      L0E70               Yes, go map in next block
L0DFA               ldb       <$0097              Get # bytes to beginning of next line
                    abx                           Point to start of next line
                    dec       <$0052              Dec # of lines counter
                    bne       L0DCB               Continue putting until done
                    puls      pc,y                Restore GP buffer ptr & return

* Put buffer with buffer's screen type different than original
L0E03               pshs      y                   Save GP buffer ptr?
                    ldd       <$006A              Get max. allowed X coordinate
                    subd      <$0047              Subtract working X coordinate
                    ifne      H6309
                    incd                          Base 1
                    else
                    addd      #1
                    endc
                    std       <$009B              Save width of some sort
                    ldb       <$006D              Get max. allowed Y coordinate
                    subb      <$004A              Calc height of some sort
                    incb                          Make base 1
                    bra       L0E2F               Save it

i.iwtyp             comb
                    ldb       #E$IWTyp
                    jmp       >GrfStrt+SysRet

* Called from Mouse cursor routine @ L15FE
L0E14               pshs      y                   Preserve GP buffer ptr
                    ldd       #320                Default res to 320 (Base 1)
                    ifne      H6309
                    tim       #$01,<$60           Get res bit from screen type
                    else
                    pshs      a
                    lda       <$60
                    bita      #1
                    puls      a
                    endc
                    beq       L0E24               It is 320 mode, skip ahead
                    ifne      H6309
                    lsld                          Multiply by 2 to get 640
                    else
                    lslb
                    rola
                    endc

L0E24               subd      <$3D                Subtract last X coord Gfx cursor was ON at
                    std       <$009B              Save # pixels to end of screen
                    ldb       #MaxLine+1          Full height of screen
                    subb      <$0040              Calculate # pixels remaining

L0E2F               stb       <$00A0              Save it
                    lbsr      L1EF1               Setup pix mask & shift vector ($79 & $7A)
                    lbsr      L0D94               Set up element X&Y sizes (in bytes)
* B=Height of GP buffer (also in <$52) in bytes
                    cmpb      <$00A0              Compare with room left on window Y axis
                    bls       FullSz
                    ldb       <$00A0              Get remaining # lines on window
                    stb       <$0052              Save as our single counter of lines left
FullSz              ldd       Grf.LfPx,y          Get # pixels used in 1st byte & last byte
                    std       <$0006              Save them
                    ldx       #GrfStrt+L075F-1    Point to color mask table index
                    ldb       <$0060              Get screen type
* ATD: Added to get around problem of GetBlk on text screen, and PutBlk
* on gfx screen crashing the system!
* We now allow GETBlk and PutBlk on text screens, too!
                    eorb      Grf.STY,y           EOR with buffer sty type
                    bmi       i.iwtyp             exit IMMEDIATELY if mixing text and gfx puts
                    ldb       <$0060              get screen type again
                    ldb       b,x                 Calc. offset to proper color mask table
                    abx
                    lda       ,x+                 Get active bits mask (0001, 0011 or 1111)
                    stx       <$0002              Save base of color mask table
                    ldx       #GrfStrt+L0E7C-1    Point to index for pixel tables
                    ldb       Grf.STY,y           Get GP buffers original screen type
                    ldb       b,x                 Calc ptr to proper pixel table
                    abx
                    ldb       ,x                  Get offset for default shift?
                    leay      b,x                 Get vector for 4, 2 or 1 shift
                    sty       <$00A3              Save it
                    anda      1,x                 And bit mask from scrn with bit mask from GP bfr
                    sta       <$0008              Save it
                    ldb       2,x                 Get # pixels/byte for GP buffer type
                    stb       <$0005              Save it
                    ldb       <$0006              Get # pixels used in 1st byte of GP buffer line
                    addb      #$02                Adjust up to skip bit mask & # pixels/byte
                    ldb       b,x                 Get offset
                    leay      b,x                 Save vectors for bit shifts
                    sty       <$00A1
                    sty       <$00A5
                    puls      pc,y                Restore GP buffer ptr & return?

* Get next 8K block of get/put buffers
* Exit: Y=Ptr to start of block ($2000)
L0E70               inc       <$007D              Increment buffer block #
                    ldb       <$007D              Get it
                    lbsr      L017C               Go map in next block in get/put buffer
                    ldy       #$2000              Y=Ptr to start of GP buffer block
                    rts

* Index to proper tables for GP buffer's original screen types
L0E7C               fcb       L0E80-(L0E7C-1)     Type 5 (2 color)
                    fcb       L0E8B-(L0E7C-1)     Type 6 (4 color)
                    fcb       L0E8B-(L0E7C-1)     Type 7 (4 color)
                    fcb       L0E92-(L0E7C-1)     Type 8 (16 color)
* All of following tables' references to pixel # are based on 1 being the
*  far left pixel in the byte
* Vector table for GP buffer's taken from 2 color screens
L0E80               fcb       L0EE0-L0E80         <$00A3 vector
                    fcb       %00000001           Bit mask for 1 pixel
                    fcb       8                   # pixels /byte
                    fcb       L0EE1-L0E80         Shift for 1st pixel
                    fcb       L0EDA-L0E80         Shift for 2nd pixel
                    fcb       L0EDB-L0E80         Shift for 3rd pixel
                    fcb       L0EDC-L0E80         Shift for 4th pixel
                    fcb       L0EDD-L0E80         Shift for 5th pixel
                    fcb       L0EDE-L0E80         Shift for 6th pixel
                    fcb       L0EDF-L0E80         Shift for 7th pixel
                    fcb       L0EE0-L0E80         Shift for 8th pixel
* Vector table for GP buffer's taken from 4 color screens
L0E8B               fcb       L0EDF-L0E8B         <$00A3 vector
                    fcb       %00000011           Bit mask for 1 pixel
                    fcb       4                   # pixels/byte
                    fcb       L0EE1-L0E8B         Shift for 1st pixel
                    fcb       L0EDB-L0E8B         Shift for 2nd pixel
                    fcb       L0EDD-L0E8B         Shift for 3rd pixel
                    fcb       L0EDF-L0E8B         Shift for 4th pixel
* Vector table for GP buffer's taken from 16 color screens
L0E92               fcb       L0EDD-L0E92         <$00A3 vector
                    fcb       %00001111           Bit mask for 1 pixel
                    fcb       2                   # pixels/byte
                    fcb       L0EE1-L0E92         Shift for 1st pixel
                    fcb       L0EDD-L0E92         Shift for 2nd pixel

L0E97               leay      Grf.Siz,y           Skip GP buffer header
                    pshs      y                   Save ptr to raw GP buffer data
                    ldx       <$0072              Get ptr to start of buffer placement on screen
                    ldu       <$64                Get PSET vector for main loop @ L0EE1
                    fcb       $8C                 skip 2 bytes: same cycle time, 1 byte shorter

L0E9E               stx       <$0072              Save get/put screen start address
L0EA0               ldd       <$009B              ??? x-count to do
                    std       <$009D              ???
                    lda       <$0050              Get LSB of X size (in bytes)
                    sta       <$0004              Save # bytes left in width (including partials)
                    ldb       <$0006              Get # of pixels used in 1st byte of GP line
                    stb       <$0097              Save as # pixels left to do in current byte
                    ldd       <$00A5              Get A5 vector
                    std       <$00A1              Save as A1 vector
                    ldb       <$0074              Get pixel mask for 1st byte of GP buffer on scrn
                    ifne      H6309
                    ldw       <$68                Get LSET vector
                    else
                    ldy       <$68
                    sty       <$B5
                    endc

L0EB2               ldy       ,s                  Get buffer data ptr
                    cmpy      #$4000              At end of 8K block yet?
                    blo       L0EC1               No, continue
                    stb       <$0099              Save B
                    bsr       L0E70               Go map in next 8K block
                    ldb       <$0099              Restore B
L0EC1               lda       ,y+                 Get byte of data from GP buffer
                    sty       ,s                  Save updated buffer ptr
                    ldy       #GrfStrt+L0EE1      Check if <$A1 vector points here
                    cmpy      <$00A1              no shifting of bits?
                    beq       L0ED6               It does, call vector
                    lsla                          Doesn't, shift buffer data left 1 first
L0ED6               ldy       <$0002              Get ptr to table of bit masks for colors
                    jmp       [>GrfMem+gr00A1]    Place byte from GP buffer on screen

* Bit shifter for adjusting pixel placements in non-aligned, possible differ-
*  ent screen type, Get/put buffers
* Entry: W=LSET vector (for use with <$64,u vector)
L0EDA               rola                          Adjust pixel to proper place in byte
L0EDB               rola
L0EDC               rola
L0EDD               rola
L0EDE               rola
L0EDF               rola
L0EE0               rola
L0EE1               pshs      cc,d                Save carry & pixel/color masks
                    ldd       <$009D              ??? Get some sort of counter (X width?)
                    beq       L0EFA               If 0, skip ahead
                    ifne      H6309
                    decd      Drop                it down
                    else
                    subd      #1
                    endc
                    std       <$009D              Save it
                    ldd       1,s                 Get pixel/color masks back
                    anda      <$0008              Mask out all but common bits of screen/buffer types
                    lda       a,y                 Get proper color bit mask
                    jsr       ,u                  Put pixel on screen
                    ldb       2,s                 Restore original pixel bit mask
                    lbsr      L1F0E               B=New pixel mask, X=new scrn addr. (if chng)
                    stb       2,s                 Save pixel mask for next pixel
L0EFA               dec       <$0097              Dec # pixels left in current byte
                    beq       L0F04               Done byte, skip ahead
                    puls      d,cc                Restore pixel/color masks & carry
                    jmp       [>GrfMem+gr00A3]    Call vector

* Current byte's worth of pixels done: set up next byte
L0F04               leas      3,s                 Eat stack
                    lda       <$0004              Get # bytes wide GP buffer is
                    deca                          Decrement it
                    beq       L0F20               If totally done buffer width, go to next line
                    sta       <$0004              Save new total
                    deca                          If only 1, set up for partially used last byte
                    beq       L0F14
                    lda       <$0005              Get # pixels/byte in GP buffer for full byte
                    fcb       $8C                 skip 2 bytes: same cycle time, 1 byte shorter

L0F14               lda       <$0007              Get # pixels to do in last (partial) byte of bfr
L0F16               sta       <$0097              Save # pixels to do in next byte
                    ldy       <$00A3              Move last byte partial vector to normal
                    sty       <$00A1              so we can use same routines
                    bra       L0EB2               Go finish off the last byte

* Done current line of GP buffer, set up for next line
L0F20               ldx       <$0072              Get screen addr of current line in GP buffer
                    ldb       <$0063              Get # bytes/row on screen
                    abx                           Point to start of next line on screen
                    dec       <$0052              Dec # lines left on window / GP buffer
                    lbne      L0E9E               If not bottom, continue PUTting
                    puls      pc,y                As far as we can go, restore Y & return

* Map GP buffer entry point
L0F31               lbsr      L0930               find the buffer
                    lbcs      SysRet              If error, exit back to system with it
                    stb       <$0097              save starting block number
                    ldb       Grf.NBlk,x          number of blocks in the buffer
                    stb       <$0099              save count
                    ldd       Grf.BSz,x           size of data inside the buffer
                    std       <$009B              save size of the buffer
                    leax      Grf.Siz,x           point to the start of the buffer data itself
                    tfr       x,d                 move into math register
                    anda      #$1F                keep offset within the block
                    std       <$009D              save offset
                    lbra      L0F78               exit with no error

* ATD: this special-purpose text routine results in gfx screens being
* marginally slower, but it saves ~170 clock cycles per character put
* on a gfx screen.

fast.set            dec       <$0083              account for the first character we printed out
* reset the various parameters after falling off the rhs of the screen
fast.txt            puls      u                   restore pointer to our fast text
                    ifne      H6309
                    ldw       Wt.CurX,y           move current X position into W
                    else
                    ldx       Wt.CurX,y
                    stx       <$B5
                    endc
                    ldx       Wt.Cur,y            get current cursor address on the screen
                    ldb       Wt.Attr,y           grab current attributes
ftxt.lp             lda       ,u+                 get a character
                    lbsr      txt.fixa            fix A so it's printable
                    lbsr      L0F7C.0             do more text screen fixes, and STD ,X++
                    ifne      H6309
                    incw                          right one character BEFORE counting down
                    else
                    pshs      x
                    ldx       <$B5
                    leax      1,x
                    stx       <$B5
                    puls      x
                    endc
                    dec       <$83                count down
                    beq       ftxt.ex             exit if it's zero: we're done here
                    ifne      H6309
                    cmpw      Wt.MaxX,y           are we at the rhs of the screen?
                    else
                    pshs      x
                    ldx       <$B5
                    cmpx      Wt.MaxX,y
                    puls      x
                    endc
                    bls       ftxt.lp             no, continue doing fast text put
                    pshs      u                   save text pointer
                    lbsr      L1238               zero out X coord, do scroll, etc
                    bra       fast.txt            and go reset out parameters

ftxt.ex             equ       *
                    ifne      H6309
                    cmpw      Wt.MaxX,y           Are we at the right hand side of the screen?
                    else
                    pshs      x
                    ldx       <$B5
                    cmpx      Wt.MaxX,y
                    puls      x
                    endc
                    bls       NoScroll            No, exit normally
                    lbsr      L1238               Do scroll stuff
                    ifne      H6309
                    clrw                          Zero out current X coord
                    else
                    clr       <$B5
                    clr       <$B6
                    endc
NoScroll            equ       *
                    ifne      H6309
                    stw       Wt.CurX,y           save current X coordinate
                    else
                    pshs      x
                    ldx       <$B5
                    stx       Wt.CurX,y
                    puls      x
                    endc
                    lbsr      L11D1               set up for the next call
                    lbra      L0F78               exit without error

* entry: A = number of characters at $0180 to write
*        Y = window table pointer
fast.chr            ldx       #$0180              where the data is located
* ATD: $83 is unused by anything as far as I can tell.
                    sta       <$83                save count of characters to do for later
                    lda       ,x+                 get the first character
                    pshs      x                   save address of character
                    lbsr      L0F4B.1             ensure window is set up properly during 1st chr.
* perhaps the DEC <$83 could be here... remove FAST.SET, and fix f1.do

                    lda       <$60                is it a text screen?
                    bmi       fast.set            yes, make it _really_ fast

                    ldb       <$006F              get X size of font
                    cmpb      #$08                Even byte wide size font?
                    ifne      H6309
                    bne       f1.do               no, go setup for multi-color/shiftable screen
                    else
                    lbne      f1.do
                    endc
                    ldx       <$B0                get cached font pointer
                    ifne      H6309
                    beq       f1.do               didn't find a font: skip ahead
                    tim       #Prop,<$E           Proportional?
                    else
                    lbeq      f1.do
                    pshs      a
                    lda       <$E
                    bita      #Prop
                    puls      a
                    endc
                    bne       f1.do               yes, use slow method

* OK.  Now we have GFX screens only here, at least one character printed
* to ensure that the buffers etc. are set up and mapped in.  We can now go to
* special-purpose routine for fixed-width 8x8 fonts: ~15% speedup!
                    ldd       Grf.BSz,x
                    leax      Grf.Siz,x           point X to the first character in the font
                    leau      d,x                 point U to the absolute end-address of the font
* Moved the DP saves from $B2 to $B9; RG
                    stu       <$B9                save the pointer for later
                    clra
                    ldb       Wt.CWTmp,y          get bytes per font character
                    std       <$BB
                    ldd       Wt.MaxX,y           get maximum X position (e.g. 319, 639)
                    ifne      H6309
                    incd                          count up one
                    else
                    addd      #1
                    endc
                    subd      #$0008              point D to the last X position possible for
                    std       <$BD                a character, and save it

* Note: W *SHOULD* be set up properly from the previous call to print one
* character, but that character might have caused the text to wrap, and thus
* destroy W
                    ldu       #GrfStrt+Fast.pt-2  point to fast font put table
                    ldb       <$0060              get screen type
                    aslb                          2 bytes per entry
                    ifne      H6309
                    ldw       b,u                 grab pointer to routine to use
                    else
                    pshs      x
                    ldx       b,u
                    stx       <$B5
                    puls      x
                    endc
                    puls      u                   restore character pointer
                    bra       f2.do               jump to the middle of the loop

* U = pointer to characters to print
* Y = window table pointer
* X = font GP buffer pointer
f2.next             lda       ,u+                 grab a character
                    pshs      x,y,u               save all sorts of registers
                    bsr       txt.fixa            fix the character in A so it's printable
                    tfr       a,b                 move character to B
                    clra                          make 16-bit offset
                    ifne      H6309
                    lsld                          ALL fonts are 8 pixels high
                    lsld
                    lsld
                    addr      d,x                 point to the font data
                    else
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    leax      d,x
                    endc
                    cmpx      <$B9                are we within the font's memory buffer?
                    blo       f2.fnt              yes, we're OK
                    ldx       #GrfStrt+L0FFA      otherwise point to default font character '.'

f2.fnt              lbsr      L102F.1             go print the character on the screen
                    ldy       2,s                 get window pointer again
                    ldd       Wt.Cur,y            get current cursor address
                    addd      <$BB                add in bytes per character
                    std       Wt.Cur,y
                    ldd       Wt.CurX,y           Get X coordinate
                    addd      #$0008              Add to X pixel count (1, 6 or 8?)
                    std       Wt.CurX,y           Update value
                    cmpd      <$BD                Compare with maximum X coordinate
                    bls       f2.do1              If not past right hand side, leave
                    ifne      H6309
                    pshsw     save                pointer to which font-put routine to use
                    else
                    pshs      x,y
                    ldx       <$B5
                    stx       2,s
                    puls      x
                    endc
                    lbsr      L1238               fix X,Y coordinate, scroll screen, set up bitmasks
                    ifne      H6309
                    pulsw
                    else
                    ldx       ,s++
                    stx       <$B5
                    endc
f2.do1              puls      x,y,u               restore registers
f2.do               dec       <$83                count down
                    bne       f2.next             continue
                    bra       L0F78               and exit if we're all done

f1.next             lda       ,x+
                    pshs      x
                    bsr       L0F4B.2             put one character on the screen
f1.do               puls      x                   restore count, pointer
                    dec       <$83                count down
                    bne       f1.next             continue
                    bra       L0F78               and exit if we're all done

* L0F4B.1 is now a subroutine to put one character on the screen...
* Alpha put entry point
* Entry: A = Character to write
*        Y = window table ptr
* 07/19/93: LBSR L0177 to L0175
L0F4B.1             lbsr      L0175               Switch to the window we are writing to
                    lbsr      L1002               set up character x,y sizes and font pointers
                    sty       <$A9                Save window tbl ptr from this Alpha put
                    tsta                          Is the character ASCII 127 or less?
L0F4B.2             bsr       txt.fixa            fix A: adds 10 cycles for slow puts and gfx puts

                    ldb       <$0060              Get screen type
                    bpl       L0F73               If gfx  screen, go do it
                    bsr       L0F7C               go print it on-screen
                    fcb       $8C                 skip the next 2 bytes
L0F73               bsr       L0FAE               go print graphic font
L0F75               lbra      L121A               check for screen scroll and/or next line

* L.C.B - Add a flag that signifies that we are doing a GFX font, and that the
*         font buffer size is $700 bytes. If this flag is set at entry to this
*         routine (after bpl), return to print it.
txt.fixa            bpl       L0F6B               Yes, go print it
                    tst       <grBigFnt           Gfx mode with a 224 char font?
                    beq       Norm                No, do normal remapping
                    cmpa      #$e0                Last 31 chars?
                    blo       BigOut              No, exit
                    suba      #$e0                Point to 1st 31 chars in font
BigOut              rts

Norm                cmpa      #$BF
                    bhi       L0F61               Anything >=$C0 gets wrapped back
                    anda      #$EF                Mask out high bit
                    suba      #$90
                    cmpa      #$1A
                    bhs       L0F6B               yes, go print it
L0F5D               lda       #'.                 Change illegal character to a period
                    rts

L0F61               anda      #$DF
                    suba      #$C1
                    bmi       L0F5D               yes, change it to a period
                    cmpa      #$19
                    bhi       L0F5D               yes, change it to a period
L0F6B               rts

* this adds 10 cycles to any normal alpha put, but it should
* save us lots of cycles later!
L0F4B               bsr       L0F4B.1             do internal alpha-put routine

* Return to the system without any errors
L0F78               clrb                          No errors

* Return to system (Jumps to [D.Flip0] with X=system stack ptr & A=CC status)
SysRet              tfr       cc,a                save IRQ status for os9p1
                    orcc      #IntMasks           Shut off interrupts
                    ldx       >WGlobal+G.GrfStk   Get system stack ptr
                    clr       >WGlobal+G.GfBusy   Flag that Grfdrv will no longer be task 1
                    ifne      H6309
                    tfr       0,dp                Restore system DP register for os9p1
                    else
                    pshs      a
                    clra
                    tfr       a,dp
                    puls      a
                    endc
                    jmp       [>D.Flip0]          Return to system

* Print text to hardware text - optimized for lowercase, then upper
* Can be switched around by swapping blo/bhi sections
L0F7C               ldb       Wt.Attr,y
                    ldx       Wt.Cur,y
L0F7C.0             cmpa      #$60                Convert ASCII reverse apostrophe to apostrophe
                    bhi       L0F8E               Above is safe, go straight to print
                    bne       L0F88               No, try next
                    lda       #$27                GIME apostrophe
                    bra       L0F8E               Skip rest
L0F88               cmpa      #$5E                Convert ASCII carat to GIME carat
                    blo       L0F8E               Below is safe, go straight to print
                    bne       L0F82               No, has to be Underscore
                    lda       #$60                GIME carat
                    fcb       $8C                 skip 2 bytes: same cycle time, 1 byte shorter

L0F82               lda       #$7F                Convert ASCII underscore to GIME underscore
* ATD: the back of the window OS-9 manual says that the transparent character
* switch is supported only on gfx screens, so we don't support it here!
*L0F8E    ldx   Wt.Cur,y     get cursor address on screen
*         ldb   Wt.Attr,y    get attributes from the window table
*         tst   Wt.BSW,y     transparent characters?
*         bmi   L0FA4        no, go on
*         IFNE  H6309
*         aim   #$07,1,x     mask off everything but background attributes
*         ELSE
*         pshs  a
*         lda   1,x
*         anda  #7
*         sta   1,x
*         puls  a
*         ENDC
*         andb  #$F8         get rid of background color
*         orb   1,x          merge in background color
L0F8E               std       ,x++                save character & attribute to screen
                    rts                           Check for screen scroll/new line

* Print text to graphics window
* Note: $61 & $62 contain the bit masks for the foreground & background colors
*   for the whole width of the byte (ex. a 2 color would be a $00 or $ff)
L0FAE               pshs      a,y                 Preserve character to print & Window table ptr
                    ldb       Wt.BSW,y            get current attributes
                    stb       <$000E              save 'em for quicker access
                    bitb      #Invers             inverse on?
                    beq       L0FBE               no, go on
* 07/20/93 mod: Get colors from window table instead of GRFDRV mem for speedup
                    ldd       Wt.Fore,y           Get fore/back colors
                    exg       a,b                 exchange 'em
                    std       <$0061              save 'em back
L0FBE               ldx       <$00B0              get cached font pointer
                    beq       L0FCC               if none, point to '.' font character
                    ldb       Grf.XSz+1,x         get x-size of the font
                    stb       <$006F              save here again: proportional fonts destroy it
                    lda       ,s                  grab again the character to print
* ATD: is this next line really necessary?  The code at L064A ENSURES that
* Grf.XBSz = Grf.YSz = $08, so this next line could be replaced by a LDB #8
                    ldb       Grf.XBSz,x          get size of each buffer entry in bytes
                    mul                           Calculate offset into buffer for character
                    cmpd      Grf.BSz,x           Still in our buffer? (Not illegal character?)
                    blo       L0FD1               yes, go on
L0FCC               ldx       #GrfStrt+L0FFA      Point to default font char ('.')
                    bra       L0FD6

L0FD1               addd      #Grf.Siz            Add 32 (past header in Gfx buffer table?)
                    ifne      H6309
                    addr      d,x                 Point to the character within buffer we need
                    else
                    leax      d,x
                    endc
L0FD6               ldb       <$006F              get X size of font
                    cmpb      #$08                Even byte wide size font?
                    bne       L0FEC               no, go setup for multi-color/shiftable screen
                    ifne      H6309
                    tim       #Prop,<$E           Proportional?
                    else
                    pshs      a
                    lda       <$E
                    bita      #Prop
                    puls      a
                    endc
                    beq       L102F               no, use fast method
* Setup for multi-color/shiftable gfx text
L0FEC               ldu       #GrfStrt+L10DF      Normal gfx text vector
                    ldy       1,s                 get window table pointer back
                    lbsr      L106D               go print it
L0FF8               puls      a,y,pc              return

* Default font character if no font buffer defined ('.')
L0FFA               fcb       %00000000
                    fcb       %00000000
                    fcb       %00000000
                    fcb       %00000000
                    fcb       %00000000
                    fcb       %00000000
                    fcb       %00010000
                    fcb       %00000000

* Check if font buffers defined?
L0FFF               lbsr      L0177
L1002               pshs      a                   save character
                    ldb       <$0060              get STY marker
                    bpl       L1011               graphics, go on
* Set text font H/W
                    ldd       #$0001              get text font size
                    std       <$006E
                    std       <$0070
* Added LCB 97/05/26 for 224 char font support
                    sta       <grBigFnt           Flag that this is not a 224 char font
                    puls      a,pc                larger, but faster than LDQ/bra L1022

* Set undefined graphics font H/W
* L100F is ONLY called from alpha put routine, above.
L100F               pshs      a                   Preserve A (so PULS PC,A works)
L1011               ldb       Wt.FBlk,y           any font defined?
                    bne       L101F               yes, go map it in & get X/Y sizes
                    comb                          set carry
                    ifne      H6309
                    ldq       #$00080008          get default width & height
                    tfr       0,x                 make garbage font ptr
                    else
                    ldd       #8
                    std       <$B5
                    ldx       #0
                    endc
                    bra       L1020

* Setup defined graphics font H/W
L101F               lbsr      L017C               map in font block
                    ldx       Wt.FOff,y           get offset of font in mem block
                    clrb                          clear carry
                    ifne      H6309
                    ldq       Grf.XSz,x           Get width & height from window table
                    else
                    ldd       Grf.XSz+2,x
                    std       <$B5
                    ldd       Grf.XSz,x
                    endc
L1020               stx       <$B0                cache font pointer for later
L1022               equ       *
                    ifne      H6309
                    stq       <$6e                Set working copies
                    else
                    std       <$6e
                    ldd       <$B5
                    std       <$70
                    endc
* LCB 05/25/97 - Added flag for 224 char fonts
                    ldd       #$700               Size of font we are checking for
                    cmpd      Grf.BSz,x           Is this a big font?
                    bne       NotBig
                    incb                          Flag it is a big font
NotBig              stb       <grBigFnt           Set flag for 224 char font
                    puls      a,pc                return

L102F               bsr       L102F.2
                    bra       L0FF8

* fast draw a graphic font character to a graphics window
* If inverse was selected, they have already been swapped
* Note: <$61 contains the foreground color mask, <$62 contains the background
*   color mask.
* Entry: Y=window table pointer
*        X=Ptr to char in font we are printing
L102F.2             ldu       #GrfStrt+Fast.pt-2  point to fast font put table
                    ldb       <$0060              get screen type
                    aslb                          2 bytes per entry
                    ifne      H6309
                    ldw       b,u                 grab pointer to routine to use
                    else
                    pshs      x
                    ldx       b,u
                    stx       <$B5
                    puls      x
                    endc

L102F.1             ldy       Wt.Cur,y            get cursor address on screen
                    exg       x,y                 Swap Cursor address & font address

                    ldu       #GrfStrt+fast.tbl   point to table of expanded pixels

                    lda       <$71                get font height
                    deca                          adjust it for double branch compare
                    sta       <$20                save in temp buffer for later

L1039               lda       ,y+                 get a line of character (8 pixels)
                    ifne      H6309
                    tim       #Bold,<$0E          Bold attribute on?
                    else
                    pshs      a
                    lda       <$0E
                    bita      #Bold
                    puls      a
                    endc
                    beq       L1044               no, skip bold mask
                    lsra                          shift pixel pattern
                    ora       -1,y                merge it with original to double up pixels
L1044               equ       *
                    ifne      H6309
                    jsr       ,w                  do a full 8-pixel width of bytes
                    else
                    jsr       [>GrfMem+$B5]
                    endc
                    ldb       <$0063              get bytes per line
                    abx                           move screen address to next line
                    dec       <$20                done 7 or 8 lines?
                    bgt       L1039               No, go do next line
                    bmi       L1052               yes, return
                    ifne      H6309
                    tim       #Under,<$0E         Underline attribute on?
                    else
                    lda       <$0E
                    bita      #Under
                    endc
                    beq       L1039               No, go do last byte of font
                    lda       #$ff                Underline byte
                    bra       L1044               Go put it in instead

fast.pt             fdb       GrfStrt+font.2      2 color font
                    fdb       GrfStrt+Font.4      4 color
                    fdb       GrfStrt+Font.4      4 color
                    fdb       GrfStrt+Font.16     16 color

* smaller than old method.  Perhaps slower, but it should get the right
* foreground/background colors
font.2              tfr       a,b                 move font character into mask
                    comb                          invert it
ChkTChr             tst       <$0E                Transparent attribute on?
                    bpl       L1051               if transparent, do only foreground colors
                    andb      <$0062              AND in background color: 0 or 1
                    fcb       $8C                 skip 2 bytes

L1051               andb      ,x                  AND in background
                    anda      <$0061              AND in foreground color
                    ifne      H6309
                    orr       b,a                 OR in the background that's already there
                    else
                    pshs      b
                    ora       ,s+
                    endc
                    sta       ,x                  save font to screen
L1052               rts                           and return

font.16             bsr       get.font            expand it once
                    pshs      a,x                 save low byte, and current X coordinate
                    tfr       b,a                 move right hand mask into A
                    leax      2,x                 do the right side of the font first
                    bsr       font.4              expand it again, and do another 2 bytes
                    puls      a,x                 restore left hand byte and screen position

font.4              bsr       get.font            get the font data into 2 bytes
                    pshs      d                   save mask
                    ifne      H6309
                    comd                          invert it for background check
                    else
                    coma
                    comb
                    endc
                    tst       <$0E                check transparent flag
                    bpl       fast.for            if transparent, only do foreground colors
                    anda      <$62                AND in background color
                    andb      <$62                into both A and B
                    bra       fast.st

fast.for            equ       *
                    ifne      H6309
                    andd      ,x                  AND in background of screen if transparent
                    else
                    anda      ,x
                    andb      1,x
                    endc
fast.st             std       ,x                  save new background of the screen
                    puls      d                   restore the old pixel mask
                    anda      <$61                AND in foreground color
                    andb      <$61                B, too
                    ifne      H6309
                    ord       ,x                  OR in background that's already there
                    else
                    ora       ,x
                    orb       1,x
                    endc
                    std       ,x                  save it on-screen
                    rts

* convert a byte of font data into pixel data
* This table turns a 2-color nibble (4 pixels) into a 4-color byte (4 pixels)
* The llokup is done twice for 16-color screens
fast.tbl            fcb       $00,$03,$0C,$0F
                    fcb       $30,$33,$3C,$3F
                    fcb       $C0,$C3,$CC,$CF
                    fcb       $F0,$F3,$FC,$FF

* A = font byte data
* U = pointer to fast.tbl, above
* returns D = pixel mask for this byte for a 4-color screen
get.font            pshs      a
                    anda      #$0F
                    ldb       a,u                 get rightmost byte
                    puls      a
                    lsra
                    lsra
                    lsra
                    lsra                          move high nibble into low nibble
                    lda       a,u                 get leftmost byte
                    rts
* ATD: end of new font routines

* Draw a graphic font to multi color windows
* May want to change so E/F contains the byte from the font/screen mem to use
*   register to register AND/OR, etc.
L106D               pshs      x                   save font address
                    ldd       #GrfStrt+L10CF      Point to default graphic plot routine
                    std       <$0010              Save vector
                    ifne      H6309
                    tim       #Prop,<$E           Proportional spacing?
                    else
                    lda       <$E                 no need to preserve regA
                    bita      #Prop
                    endc
                    beq       L10A4               no, skip finding font size
* Calc positioning for proportional spacing
                    ldb       <$0071              Get Y pixel count
                    decb                          dec by 1 (0-7?)
                    clra                          Clear out byte for mask checking
* This goes through all 8 bytes of a font character, ORing them into A
* The resultant byte on completion of the loop has all bits set that will be
L1080               ora       b,x                 Mask in byte from font
                    decb                          Dec counter (& position in font)
                    bpl       L1080               Still more to check, continue
                    tsta                          Check byte still clear?
                    bne       L108E               No, skip ahead (B=$ff at this point)
                    lsr       <$006F              Divide X pixel count by 2 if it is
                    bra       L10A4               Start printing with normal vector

* Non-blank char
L108E               decb                          dec B (# active pixels counter)
                    lsla                          Shift merged pixel mask byte left 1 bit
                    bcc       L108E               Pixel is unused in font char, keep looking
* Found pixel that will be needed, set up vector to shift char to be flush
* left
* Should move this table so that ABX can be used instead (move table to before
*   shift routines
                    ldx       #GrfStrt+L10CF+2    Point to shifting gfx text plot routine
                    leax      b,x
                    stx       <$0010              Save the vector
* Count # pixels that will be active
                    ldb       #$01                Set up counter for #pixels to print (min.=2)
L109E               incb                          Inc counter
                    lsla                          Shift out merged pixel mask byte
                    bcs       L109E               Until we either hit blank or run out
                    stb       <$006F              Save # pixels to print in X pixel count

* Main printing starts here - sets up for outside loop (at L10BB)
L10A4               ldb       Wt.FMsk,y           Get start pixel mask (may be into byte for prop.)
                    stb       <$000F              Save in GrfDrv mem
                    ldx       Wt.Cur,y            get address of cursor in screen mem
                    puls      y                   Get font address
                    lda       <$0071              Get # bytes high char is
                    deca                          bump down by 1 (base 0)
                    sta       <$0099              Save in temp (as counter)
                    stx       <$000C              Save cursor address
                    lbsr      L1EF1               Set up mask & vector to bit shift routine
                    ldx       <$000C              Get cursor address
* Outside loop for Gfx font - A is byte of 2 color font data we are currently
* doing
L10BB               lda       ,y+                 Get line of font data
                    ifne      H6309
                    tim       #$20,<$E            Bold text?
                    else
                    pshs      a
                    lda       <$E
                    bita      #$20
                    puls      a
                    endc
                    beq       L10C6               No, skip doubling up pixels
                    lsra                          shift it right 1
                    ora       -1,y                merge with original to double up pixels
L10C6               jmp       [>GrfMem+gr0010]    Flush left the font data in byte

* Bit shift offsets for proportional fonts
* Outside loop: A=byte from font data in 2 color format
* Will take byte of font data in A and make it flush left
L10C9               lsla
L10CA               lsla
L10CB               lsla
L10CC               lsla
L10CD               lsla
L10CE               lsla
* Entry point for non-proportional fonts - byte already flush left (6 or 8)
L10CF               sta       <$000B              Save flush left font byte, 1 bit/pixel
                    ifne      H6309
                    lde       <$006F              get X width of font char in pixels
                    else
                    ldb       <$6F
                    stb       <$B5
                    endc
                    ldb       <$000F              Get bit mask for start pixel on screen
* NOTE: SHOULD TRY TO BUILD A WHOLE BYTE'S WORTH OF PIXELS INTO B TO PUT AS
* MANY PIXELS ONTO SCREEN AT ONCE - NEED TO KNOW HOW MANY PIXELS LEFT IN BYTE
* FROM START THOUGH (COULD USE F AS COUNTER)
                    pshs      b                   Save pixel mask on stack
                    stx       <$000C              save screen address
                    jmp       ,u                  Put it on screen (calls 10DF or 10FA only)

* Print line of font char onto screen
* Inside loop: does 1 pixel at a time from font byte (stored in $000B)
L10DF               lsl       <$000B              Shift pixel into carry from font byte
                    bcs       L10EB               Pixel is set, put it on screen in foregrnd color
                    lda       <$000E              Pixel is not used, transparent characters?
                    bpl       L10FE               No, skip this pixel entirely
                    lda       <$0062              Transparent, get bckgrnd color full byte bit mast
                    bra       L10ED               Go put it on screen

* Used by Update Window Cursor updates (Inverse for cursor)
L10FA               eorb      ,x                  Invert data on screen with bit data
                    stb       ,x                  Save it on screen (Invert for cursor)
                    bra       L10FE               Check if we have more to do

L10EB               lda       <$0061              get foreground color full byte bit mask
* Entry: B=Current pixel mask
*        A=Color mask (can be fore or background)
L10ED               equ       *
                    ifne      H6309
                    andr      b,a                 Keep only color data we can use
                    else
                    pshs      b
                    anda      ,s+
                    endc
                    comb                          Make 'hole' with font data
                    andb      ,x                  & screen data
                    ifne      H6309
                    orr       b,a                 Merge font color onto existing screen byte
                    else
                    pshs      b
                    ora       ,s+
                    endc
                    sta       ,x                  Save result onto screen

L10FE               equ       *
                    ifne      H6309
                    dece                          Dec # pixels left on current font line
                    else
                    dec       <$B5
                    endc
                    puls      b                   Get current pixel mask again
                    beq       L1109               Done current line, skip ahead
                    lbsr      L1F0E               Move to next pixel position
                    pshs      b                   Save new pixel mask on stack
                    jmp       ,u                  Put it on screen (calls 10DF or 10FA only)
* End of inside loop (each pixel within font byte)

L1109               ldx       <$000C              get start of char. screen address again
                    ldb       <$0063              Get # bytes per row on screen
                    abx                           Point to next line on screen
                    dec       <$0099              Are we done whole char (or on last line)?
                    bgt       L10BB               No, continue drawing char
                    bmi       L1120               Totally done, exit
* on last line ($99=0)
                    ifne      H6309
                    tim       #Under,<$0E         Underline requested?
                    else
                    lda       <$0E
                    bita      #Under
                    endc
                    beq       L10BB               No, go draw last line
                    lda       #$FF                Underline code
                    bra       L10CF               Go draw it
* End of outside loop (for each line with font)

L1120               rts                           Return

* 2 color mode pixel mask table
L1EE0               fcb       $07                 Mask for pixel #'s we care about
                    fcb       $80,$40,$20,$10,$08,$04,$02,$01

* 4 color mode pixel mask table
L1EE9               fcb       $03                 Mask for pixel #'s we care about
                    fcb       $c0,$30,$0c,$03

* 16 color mode pixel mask table
L1EEE               fcb       $01                 Mask for pixel #'s we care about
                    fcb       $f0,$0f

* Goto X/Y entry point
L1186               lbsr      L0FFF               Set up font sizes (and font if on gfx screen)
                    ldb       <$0047              Get X coord
                    subb      #$20                Kill off ASCII part of it
                    lda       <$006F              Get # pixels wide each text char is
                    mul                           Calculate # pixels into screen to start at
                    std       <$0047              Preserve Start pixel # as 'working' X coord
                    addd      <$006E              Add width in pixels again (calculate end X coord)
                    ifne      H6309
                    decd      Adjust
                    else
                    subd      #1
                    endc
                    cmpd      Wt.MaxX,y           Would we be past end of window?
                    bhi       L11CA               Yes, exit out of grfdrv
                    ldb       <$0049              Get Y coord
                    subb      #$20                Kill off ASCII part of it
                    lda       <$0071              Get Y size of font in bytes
                    mul                           Calculate # bytes from top of screen to start at
                    std       <$0049              Save it
                    addd      <$0070              Bump down by 1 more text char Y size
                    ifne      H6309
                    decd      Adjust
                    else
                    subd      #1
                    endc
                    cmpd      Wt.MaxY,y           Would end of char go past bottom of window?
                    bhi       L11CA               Yes, exit out of grfdrv
                    ifne      H6309
                    ldq       <$0047              Get x & y coords
                    stq       Wt.CurX,y           Move into window table (-2 to +1)
                    else
                    ldd       <$49
                    std       Wt.CurX+2,y
                    std       <$B5
                    ldd       <$47
                    std       Wt.CurX,y
                    endc
                    bsr       NewEnt              Originally bsr L11D1 (redundant)
L11CA               jmp       >GrfStrt+L0F78

* Control code processer
* ATD: 69 bytes old method, 47 new method
L1129               lbsr      L0FFF               Set up font sizes (and font if on gfx screen)
                    deca                          make 1-D = 0-C
                    bmi       L1130               if 0 or smaller, exit
                    cmpa      #$0D                too high? (now 0-C instead of 1-D)
                    bhs       L1130               yes, exit

                    ldx       #GrfStrt+T.1133     point to offset table to use
                    asla                          2 bytes per entry
                    ldd       a,x                 get pointer to routine
                    jsr       d,x                 call it
L1130               jmp       >GrfStrt+L0F78      return to CoWin: No errors

T.1133              fdb       L11E1-T.1133        1 home cursor
                    fdb       L1130-T.1133        2   GOTO X,Y: handled elsewhere
                    fdb       L1352-T.1133        3 erase current line
                    fdb       L135F-T.1133        4 erase to end of line
                    fdb       L1130-T.1133        5   cursor on/off: handled elsewhere
                    fdb       L121A-T.1133        6 cursor right
                    fdb       L1130-T.1133        7   BELL: handled elsewhere
                    fdb       L11F9-T.1133        8 cursor left
                    fdb       L122F-T.1133        9 cursor up
                    fdb       L123A-T.1133        A cursor down (LF)
                    fdb       L138D-T.1133        B erase to end of screen
                    fdb       L1377-T.1133        C clear screen
                    fdb       L11CD-T.1133        D cursor to LHS of the screen (CR)

* Calculate screen logical address based on X/Y text coordinates
* Exit: X=Screen logical address pointing to X,Y text coordinate location
*       If graphics screen, B=Mask for specific pixel
L1E9D               ldx       Wt.LStrt,y          get screen logical start
* Calculate offset for Y location
L1E9F               lda       <$004A              get Y coordinate (0-199)
                    ldb       <$0063              get bytes/row
                    mul                           Calculate # bytes into screen to go
                    ifne      H6309
                    addr      d,x                 Add to screen start
                    else
                    leax      d,x
                    endc
                    ldb       <$0060              get screen type
                    bpl       L1EB5               graphics screen, go adjust X coordinate
* Calculate offset for X location (text only)
                    ldb       <$0048              Get X coordinate
                    lslb                          account for attribute byte
                    abx                           point X to screen location & return
                    rts

* Calculate offset for X location (gfx only)
* Fast horizontal and vertical lines call this after doing a LDW <$68 (LSET)
L1EB5               pshs      u                   Preserve U
                    cmpb      #$04
                    bne       L1EC0
* 16 color screens (2 pixels/byte)
                    ldd       <$0047              get requested X coordinate
                    ldu       #GrfStrt+L1EEE      Point to 2 pixel/byte tables
                    bra       L1ED4               Adjust screen address accordingly

L1EC0               cmpb      #$01                640 2 color screen?
                    beq       L1ECB               Yes, go process it
* 4 color screens go here (4 pixels/byte)
                    ldd       <$0047              Get requested X coordinate
                    ldu       #GrfStrt+L1EE9      Point to 4 pixel/byte tables
                    bra       L1ED2               Adjust Screen address accordingly
* 2 color screens go here (8 pixels/byte)
L1ECB               ldd       <$0047              Get requested X coordinate
                    ldu       #GrfStrt+L1EE0      Point to 8 pixel/byte tables
                    ifne      H6309
                    lsrd                          Divide by 8 for byte address
L1ED2               lsrd                          divide by 4
L1ED4               lsrd                          divide coordinate by 2 (to get Byte offest)
                    addr      d,x                 Point X to byte offset for pixel
                    else
                    lsra
                    rorb
L1ED2               lsra
                    rorb
L1ED4               lsra
                    rorb
                    leax      d,x
                    endc
                    ldb       <$0048              Get LSB of X coordinate requested
                    andb      ,u+                 Mask out all but pixels we need to address
                    ldb       b,u                 Get mask for specific pixel we need
                    puls      pc,u                Restore Y & exit

* Cursor to left margin (CR)
L11CD               equ       *
                    ifne      H6309
                    clrd                          Set X coordinate to 0
                    else
                    clra
                    clrb
                    endc
                    std       Wt.CurX,y
L11D1               equ       *
                    ifne      H6309
                    ldq       Wt.CurX,y           Copy window table x,y coord to grfdrv x,y
                    stq       <$0047
                    else
                    ldd       Wt.CurX+2,y
                    std       <$49
                    ldd       Wt.CurX,y
                    std       <$47
                    endc
NewEnt              bsr       L1E9D               Go calculate screen logical address
                    stx       Wt.Cur,y            Preserve screen location
                    stb       Wt.FMsk,y           Preserve x coord (adjusted by x2 for text attr
                    rts                           if needed)

* Home cursor
L11E1               ldd       Wt.LStrt,y          Make cursor address same as upper left of screen
                    std       Wt.Cur,y
                    ldx       #GrfStrt+L1F00-2    Point to bit mask/vector table
                    ldb       <$0060              Get screen type
                    bmi       L11F8               If text, exit
                    lslb                          Multiply x2 to get table entry
                    ldb       b,x                 Get bit mask
                    stb       Wt.FMsk,y           Preserve it
L11F8               equ       *
                    ifne      H6309
                    clrd                          Clear out x & y coord's in window table
                    clrw
                    stq       Wt.CurX,y
                    else
                    clra
                    clrb
                    std       <$B5
                    std       Wt.CurX,y
                    std       Wt.CurX+2,y
                    endc
                    rts

* Cursor left
L11F9               ldd       Wt.CurX,y
                    subd      <$006E              Subtract X pixel count
                    std       Wt.CurX,y
                    bpl       L11D1               Didn't wrap into negative, leave
                    ldd       Wt.MaxX,y           Get Max X coordinate
                    subd      <$006E              subtract X pixel count
                    ifne      H6309
                    incd                          Bump up by 1
                    else
                    addd      #1
                    endc
                    std       Wt.CurX,y           Save new X coordinate
                    ldd       ,y                  Get Y coordinate
                    subd      <$0070              Subtract Y pixel count
                    std       Wt.CurY,y           Save updated Y coordinate
                    bpl       L11D1               Didn't wrap into negative, leave
                    ifne      H6309
                    clrd                          Set coordinates to 0,0
                    else
                    clra
                    clrb
                    endc
                    std       Wt.CurX,y           Save X coordinate
                    std       Wt.CurY,y           Save Y coordinate
                    rts

* Cursor Up
L122F               ldd       Wt.CurY,y           Get Y coordinate
                    subd      <$0070              Subtract Y pixel size
                    bpl       GoodUp              If not at top, save coordinate
                    rts                           Otherwise, exit
GoodUp              std       Wt.CurY,y           Save new Y coordinate
                    bra       L11D1               Leave

* Cursor right
L121A               ldd       Wt.CurX,y           Get X coordinate
                    addd      <$006E              Add to X pixel count (1, 6 or 8?)
                    std       Wt.CurX,y           Update value
                    addd      <$006E              Add to X pixel count again
                    ifne      H6309
                    decd      Dec                 by 1
                    else
                    subd      #1
                    endc
                    cmpd      Wt.MaxX,y           Compare with maximum X coordinate
                    bls       L11D1               If not past right hand side, leave
L1238               bsr       L11CD               Zero out X coordinate

* Cursor Down (LF)
* Called by font change. Entry= Y=window table ptr, X=Screen addr, B=X coord
* on current line on physical screen
L123A               ldd       Wt.CurY,y           Get current Y coord
                    addd      <$0070              Add to Y pixel count
                    tfr       d,x                 Move result to X
                    addd      <$0070              Add Y pixel count again
                    ifne      H6309
                    decd      decrement           by 1
                    else
                    subd      #1
                    endc
                    cmpd      Wt.MaxY,y           compare with Maximum Y coordinate
                    bhi       L124F               If higher (scroll needed), skip ahead
                    stx       Wt.CurY,y           Store +1 Y coordinate
                    bra       L11D1               Update grfdrv's X&Y ptrs & leave

* new Y coord+1 is >bottom of window goes here
L124F               pshs      y                   Preserve window table ptr
                    ldb       Wt.XBCnt,y          Get width of window in bytes
                    stb       <$0097              Save since Y will disappear
                    clra                          Clear MSB of D
                    ldb       <$0063              Get # bytes per row of screen
                    std       <$0099              preserve value (16 bit for proper ADDR)
                    ldd       Wt.CurY,y           Get current Y coord
                    std       <$009D              Preserve
                    lda       Wt.SZY,y            Get current Y size
                    deca                          0 base
                    sta       <$009B              Preserve
                    beq       L128A               If window only 1 line high, then no scroll needed
                    ldx       Wt.LStrt,y          Get screen logical start addr. (top of screen)
                    ldd       Wt.BRow,y           Get # bytes/text row (8 pixel lines if gfx)
                    tfr       x,y                 Move screen start addr. to Y
                    ifne      H6309
                    addr      d,x                 X=Screen addr+1 text line
                    else
                    leax      d,x
                    endc
                    lda       <$009B              Get Y size (0 base)
                    ldb       <$0060              Check screen type
                    bmi       L1267               If text, skip ahead
                    lsla                          Multiply by 8 (# pixel lines/text line)
                    lsla
                    lsla
                    sta       <$009B              Y size into # pixel lines, not text lines
* Special check for full width windows
L1267               ldb       <$97                Get width of window in bytes
                    cmpb      <$63                Same as screen width?
                    bne       L127B               No, do normal scroll
L1267a              mul                           Calculate size of entire window to move
* Scroll entire window in one shot since full width of screen
                    ifne      H6309
                    tfr       d,w                 Move to TFM size reg.
                    tfm       x+,y+               Move screen
                    else
* Note, the following code will work as long as D is an even number...
* Which it should be since all screen widths are even numbers (80, 40, etc)
                    pshs      u
                    tfr       x,u
L1267b              pulu      x
                    stx       ,y++
                    subd      #$0002
                    bgt       L1267b
                    puls      u
                    endc
                    bra       L128A               Exit scroll routine

* Scroll window that is not full width of screen
L127B               equ       *
                    ifne      H6309
                    ldd       <$0099              Get # bytes/row for screen
                    ldf       <$0097              Get # bytes wide window is
                    clre
                    subr      w,d                 Calc # bytes to next line
L127E               tfm       x+,y+               Block move the line
                    else
                    ldd       <$0099              Get # bytes/row for screen
                    pshs      d
                    clra
                    ldb       <$97
                    std       <$B5                regW loaded
                    puls      d
                    subd      <$B5                subr w,d
L127E               pshs      d,x,u
                    ldb       <$B6                get regW
                    clra
                    tfr       x,u
                    tfr       d,x
L127Eb              lda       ,u+
                    sta       ,y+
                    leax      -1,x
                    bne       L127Eb
                    stx       <$B5
                    stu       2,s
                    puls      d,x,u
                    endc
                    dec       <$009B              Dec # lines to still copy
                    beq       L128A               If done, exit
                    ifne      H6309
                    addr      d,x                 Bump start ptr by 1 line
                    addr      d,y                 Bump end ptr by 1 line
                    ldf       <$0097              Get width of window in bytes
                    else
                    leax      d,x
                    leay      d,y
                    pshs      b
                    ldb       <$97
                    stb       <$B6
                    puls      b
                    endc
                    bra       L127E               Do until we have moved all the lines

L128A               puls      y                   Get back window table ptr
L128C               ldd       <$009D              Get back current Y coord
L128E               bra       L1354               Go clear new line & exit

* Insert line
L1291               pshs      y                   Save window table ptr
                    ldd       Wt.CurY,y           Get current Y coord
                    std       <$009D              Preserve it
                    ldb       Wt.XBCnt,y          Get width of window in bytes
                    stb       <$0097              Save in fast mem
                    clra                          Get # bytes/row into D
                    ldb       <$0063              (16 bit for ADDR)
                    ifne      H6309
                    negd                          Make negative (since scrolling down?)
                    else
                    coma
                    comb
                    addd      #1
                    endc
                    std       <$0099              Preserve it
                    ldb       Wt.SZY,y            Get current Y size
                    decb                          0 base
                    lda       <$0071              Get Y pixel count
                    mul                           Multiply by current Y size
                    tfr       b,a                 Dupe result
                    deca                          Don't include line we are on
                    subb      Wt.CurY+1,y         Subtract Y coord of cursor
                    cmpb      <$0071              Compare with Y pixel count
                    blo       L128A               If on bottom line, don't bother
                    stb       <$009B              Save # lines to leave alone
                    ldb       <$0063              Get #bytes/row
                    mul                           Calculate # bytes to skip scrolling
                    addd      Wt.LStrt,y          Add to screen start address
                    tfr       d,x                 Move to top of scroll area reg. for TFM
                    addd      Wt.BRow,y           Add # bytes/text row
                    tfr       d,y                 Move to bottom of scroll area reg. for TFM
                    bra       L127B               Do insert scroll

* Delete line
L12C5               pshs      y                   Save window table ptr
                    ldb       Wt.XBCnt,y          Get width of window in bytes
                    stb       <$0097              Save it
                    clra                          Get # bytes/row on screen into D
                    ldb       <$0063
                    std       <$0099              Save for ADDR loop
                    lda       Wt.SZY,y            Get current Y size
                    deca                          0 base
                    ldb       <$0060              Check screen type
                    bmi       L12DC               If text, skip ahead
                    lsla                          Multiply x8 (height of font)
                    lsla
                    lsla
L12DC               suba      Wt.CurY+1,y         Subtract current Y location
                    bhi       L12E6               Not on bottom of screen, continue
                    puls      y                   On bottom, get back window table ptr
                    ldd       Wt.CurY,y           Get Y coord back
                    bra       L1354               Just clear the line & exit

L12E6               sta       <$009B              Save # lines to scroll
                    ldd       Wt.MaxY,y           Get Maximum Y coordinate
                    subd      <$0070              Subtract Y pixel count
                    ifne      H6309
                    incd                          Base 1
                    else
                    addd      #1
                    endc
                    std       <$009D              Save size of area to scroll for delete
                    lda       <$0063              Get # bytes/row
                    ldb       Wt.CurY+1,y         Get Y coord of cursor
                    mul                           Calculate offset to top of area to scroll
                    addd      Wt.LStrt,y          Add to Screen logical start address
                    tfr       d,x                 Move to top of window reg. for TFM
                    ldd       Wt.BRow,y           Get # bytes/text row
                    tfr       x,y                 Swap top of window to bottom since reverse scroll
                    ifne      H6309
                    addr      d,x                 Calculate top of window reg. for backwards TFM
                    else
                    leax      d,x
                    endc
                    jmp       >GrfStrt+L127B      Go delete the line

* Erase current line
L1352               ldd       Wt.CurY,y           Get Y coordinate
L1354               std       <$0049              Preserve 'working' Y coordinate
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       <$0047              'Working' X coordinate to 0
                    ldd       Wt.MaxX,y           Get maximum X coordinate
                    bra       L136C

* Erase to end of line
L135F               equ       *
                    ifne      H6309
                    ldq       Wt.CurX,y           Get X & Y coordinates
                    stq       <$0047              Save as 'working' copies
                    else
                    ldd       Wt.CurX+2,y
                    std       <$49
                    ldd       Wt.CurX,y
                    std       <$47
                    endc
                    ldd       Wt.MaxX,y           Get maximum X coordinate
                    subd      Wt.CurX,y           Subtract X coordinate
L136C               equ       *
                    ifne      H6309
                    incd                          Add 1 to X size
                    else
                    addd      #1
                    endc
                    std       <$004F              New X size (in bytes)
                    ldd       <$0070              Get Y pixel count
                    std       <$0051              New Y size (in bytes)
                    bra       L13AD

* CLS (Chr$(12))
L1377               lbsr      L11E1               Home cursor (D&W are 0 on exit)
                    ifne      H6309
                    stq       <$0047
                    else
*         pshs  d            not needed because D=W=0
*         ldd   <$B5
                    std       <$49
*         puls  d
                    std       <$47
                    endc
                    ldd       Wt.MaxX,y           Get maximum X coordinate
                    ifne      H6309
                    incd                          Bump up by 1
                    else
                    addd      #1
                    endc
                    std       <$004F              New X size
                    ldd       Wt.MaxY,y           Get maximum Y coordinate
                    bra       L13A8

* Erase to end of screen
L138D               bsr       L135F               Erase to end of current line first
                    ifne      H6309
                    clrd                          'working' X coordinate to 0
                    else
                    clra
                    clrb
                    endc
                    std       <$0047
                    ldd       Wt.CurY,y
                    addd      <$0070              Add Y pixel count
                    std       <$0049              New Y coordinate
                    ldd       Wt.MaxX,y           Get maximum X coordinate
                    ifne      H6309
                    incd                          bump up by 1
                    else
                    addd      #1
                    endc
                    std       <$004F              New X size
                    ldd       Wt.MaxY,y           Get maximum Y coordinate
                    subd      <$0049              Subtract Y coordinate
                    bmi       L13B7               If negative, skip
L13A8               equ       *
                    ifne      H6309
                    incd                          Bump up by 1
                    else
                    addd      #1
                    endc
                    std       <$0051              Save Y size
* Erase to end of screen/line comes here too
L13AD               lbsr      L1E9D               get screen logical start address into X
* and also the starting pixel mask into B.
                    lda       <$0060              Get screen type
                    bpl       L13E3               Do CLS on gfx screen & return
* Do the CLS on text screen
                    lda       #$20                Space character
                    ldb       Wt.Attr,y           Get default attributes
                    andb      #$38                Mask out Flash/Underline & bckgrnd color
                    orb       <$0062              Mask in background color
                    ifne      H6309
                    tfr       x,w                 move pointer to faster index register
                    else
                    stx       <$B5
                    endc
                    tfr       d,x                 Move into proper register for clear loop
                    ldb       <$0063              Get #bytes/row
                    subb      <$0050              Subtract width twice for char. & attribute
                    subb      <$0050              B=# bytes to skip to go to next line
                    beq       ClsFTxt             If full width screen, use optomized routine

L13CF               lda       <$0050              Get width of line in chars?
                    ifeq      H6309
                    pshs      u
                    ldu       <$B5
                    endc
L13D4               equ       *                   * Only called as loop
                    ifne      H6309
                    stx       ,w++                Put attr/char on screen
                    else
                    stx       ,u++
                    endc
                    deca                          Dec counter of how many bytes this line
                    bne       L13D4               Do until line is done
                    ifne      H6309
                    addr      d,w                 after all, A=0
                    else
                    leau      d,u
                    stu       <$B5
                    puls      u
                    endc
                    dec       <$0052              Dec line count
                    bne       L13CF               Do until rest of screeen done
L13B7               rts                           Restore window table ptr & return

* Optomized routine for full width text screens
* Entry: W=attribute/char to fill with
ClsFTxt             ldb       <$0050              Get # chars per line
                    lda       <$0052              Get # of rows (lines)
                    mul                           # chars till end of screen
                    ifeq      H6309
                    pshs      u
                    ldu       <$B5
                    endc
FstClrT             equ       *
                    ifne      H6309
                    stx       ,w++                Put attr/char on screen
                    decd      Dec                 counter
                    else
                    stx       ,u++
                    subd      #1
                    endc
                    bne       FstClrT             Do until done
                    ifne      H6309
                    rts                           Restore window table ptr & return
                    else
                    stu       <$B5
                    puls      u,pc
                    endc

* Part of CLS/Erase to end of screen/line - Gfx only
* all coords & sizes should be pixel based
*   the cmpx's at the bottom should be F or E (screen type)
* NOTE: <$48 contains a 0 when coming in here for CLS
*   If this is the only way to get here, may change lda/coma to lda #$ff
* <$4F=X size in pixels (1-640) to clear
* <$51=Y size in pixels (1-200) to clear
* This routine calculates the pixel mask if you are clearing from the middle
* of a byte to properly handle proportional chars or 6 pixel fonts
* ATD: OK, MOST clears are on 8x8 pixel boundaries, but for proportional, etc.
* fonts and clear to EOL, we may be in the middle of a byte.  In that case,
* do a BAR.  It's slower, but a lot smaller code.
* Entry: A=Screen type
*        B= starting pixel mask for this byte: important for pixel boundaries!
*        X=absolute address of the start of the screen
L13E3               ldu       #GrfStrt+L0D70-1    mask for pixels
                    lda       a,u                 grab mask (7,3,1)
                    tstb                          is the high bit of the pixel mask set?
                    bmi       L13F0               yes, we're starting on a byte boundary
                    pshs      a,x                 save X-coord mask, and screen ptr for later
                    tfr       b,a                 get another copy of the pixel mask

L13E5               lsrb                          move the mask one bit to the right
                    ifne      H6309
                    orr       b,a                 make A the right-most mask
                    else
                    pshs      b
                    ora       ,s+
                    endc
                    bcc       L13E5               the low bits of A will be the pixel mask
                    tfr       a,b                 copy A to B again
                    coma
                    andb      <$62                AND with full-byte background color mask
                    std       <$97                save screen mask, background color
                    ifne      H6309
                    lde       <$52                get the lines to clear
                    else
                    ldb       <$52
                    stb       <$B5
                    endc
                    ldb       <$63                get the size of the screen

L13E8               lda       ,x                  grab a byte off of the screen
                    anda      <$97                AND in only the screen pixels we want
                    ora       <$98                OR in the background color
                    sta       ,x                  save the updated byte
                    abx                           go to the next screen line
                    ifne      H6309
                    dece                          count down
                    else
                    dec       <$B5
                    endc
                    bne       L13E8               continue until done

                    puls      a,x                 restore X coord mask and screen ptr
                    leax      1,x                 we've done these bytes already

L13F0               inca                          now B=number of pixels per byte (8,4,2);A not B; RG
                    ldb       <$62                Get backgrnd full-byte pixel mask
                    pshs      d                   save pixels/byte, color mask
                    ldd       <$004F              Get X size (in pixels)
                    ifne      H6309
                    divd      ,s+                 divide by pixels/byte: B=bytes wide the window is
* PANIC if A<>0!!!          leave mask on stack for later use
                    else
                    clr       ,-s
L13F0b              inc       ,s
                    subb      1,s
                    sbca      #0
                    bcc       L13F0b
*         addb  1,s
*         tfr   b,a         don't care about remainder
                    puls      b
                    decb
                    leas      1,s
                    endc
                    cmpb      <$0063              Get # bytes/row on screen
                    beq       ClsFGfx             full width of screen: do complete TFM

                    stb       <$97                save width of window for later
                    subb      <$0063              subtract width of window from width of screen
                    negb                          now B=offset from X-end,Y to X-start,Y+1

                    lda       <$52                Get # lines to clear
                    ifne      H6309
                    clre                          W for TFM size
L1450               ldf       <$97                Get width of window in bytes
                    tfm       s,x+                Clear out line
                    else
L1450               pshs      d,y
                    clra
                    ldb       <$97
                    tfr       d,y
                    lda       4,s
L1450b              sta       ,x+
                    leay      -1,y
                    bne       L1450b
                    sty       <$B5
                    puls      d,y
                    endc
                    deca                          Dec line counter
                    beq       L146F               done, exit
                    abx                           Bump to start of next line
                    bra       L1450               Keep clearing until done

* Clearing Gfx screen/even byte start/full width window
* Entry: B=width of screen/window in bytes
ClsFGfx             lda       <$52                Get # lines to clear
                    mul                           Calculate # bytes for remainder of screen
                    ifne      H6309
                    tfr       d,w                 Move to TFM size register
                    tfm       s,x+                Clear out remainder of screen
                    else
                    cmpd      #0
                    beq       L146F
                    pshs      d,y
                    tfr       d,y                 tfr d,w
                    lda       4,s                 get ,s
L146Fb              sta       ,x+
                    leay      -1,y
                    bne       L146Fb
                    sty       <$B5
                    puls      d,y
                    endc
L146F               puls      pc,a                Eat a & return

* $1f code processor
*L1478    lbsr  L0177          Map in window/setup GRFDRV mem/update cursors
L1478               lbsr      L0FFF               Set up font info
                    bsr       L1483               Perform $1F function
                    jmp       >GrfStrt+L0F78      Return to Grf/Wind Int: no errors

L1483               suba      #$20                Inverse on? (A=$20)
                    beq       L14A8               yes, go do it
                    deca                          A=$21 Inverse off?
                    beq       L14C4
                    deca                          A=$22 Underline on?
                    beq       L14D0
                    deca                          A=$23 Underline off?
                    beq       L14D9
                    deca                          A=$24 Blink on?
                    beq       L14E2
                    deca                          A=$25 blink off?
                    beq       L14E9
                    suba      #$30-$25            A=$30 Insert line?
                    lbeq      L1291
                    deca                          A=$31 Delete line?
                    lbeq      L12C5
                    rts

* Inverse ON
L14A8               ldb       Wt.BSW,y            Get window bit flags
                    bitb      #Invers             Inverse on?
                    bne       L14C3               Already on, leave it alone
                    orb       #Invers             Set inverse on flag
                    stb       Wt.BSW,y            Save new bit flags

L14B2               lda       Wt.Attr,y           Get default attributes
                    lbsr      L15B2               Go swap Fore/Background colors into A
                    ldb       Wt.Attr,y           Get default attributes again
                    andb      #$c0                Mask out all but Blink & underline
                    ifne      H6309
                    orr       a,b                 Mask in swapped colors
                    else
                    pshs      a
                    orb       ,s+
                    endc
                    stb       Wt.Attr,y           Save new default attribute byte & return
L14C3               rts

* Inverse OFF
L14C4               ldb       Wt.BSW,y            Get window bit flags
                    bitb      #Invers             Inverse off?
                    beq       L14C3               Already off, leave
                    andb      #^Invers            Shut inverse bit flag off
                    stb       Wt.BSW,y            Save updated bit flags
                    bra       L14B2               Go swap colors in attribute byte

L14D0               equ       *
                    ifne      H6309
                    oim       #Under,Wt.Attr,y
                    oim       #Under,Wt.BSW,y
                    else
                    pshs      a
                    lda       Wt.Attr,y
                    ora       #Under
                    sta       Wt.Attr,y
                    lda       Wt.BSW,y
                    ora       #Under
                    sta       Wt.BSW,y
                    puls      a
                    endc
                    rts

L14D9               equ       *
                    ifne      H6309
                    aim       #^Under,Wt.Attr,y
                    aim       #^Under,Wt.BSW,y
                    else
                    pshs      a
                    lda       Wt.Attr,y
                    anda      #^Under
                    sta       Wt.Attr,y
                    lda       Wt.BSW,y
                    anda      #^Under
                    sta       Wt.BSW,y
                    puls      a
                    endc
                    rts

* Blink on
L14E2               equ       *
                    ifne      H6309
                    oim       #TChr,Wt.Attr,y
                    else
                    pshs      a
                    lda       Wt.Attr,y
                    ora       #TChr
                    sta       Wt.Attr,y
                    puls      a
                    endc
                    rts

* Blink off
L14E9               equ       *
                    ifne      H6309
                    aim       #^TChr,Wt.Attr,y
                    else
                    pshs      a
                    lda       Wt.Attr,y
                    anda      #^TChr
                    sta       Wt.Attr,y
                    puls      a
                    endc
                    rts

* Cursor On/Off entry point
L116E               lbsr      L0FFF               Set up font sizes (and font if on gfx screen)
                    bsr       L1179               Do appropriate action
                    bra       L1508

L1179               suba      #$20                A=$20  Cursor Off?
                    beq       L14F8               Yes, go do it
                    deca                          A=$21  Cursor on?
                    beq       L14F0               Yes, go do it
                    rts                           Neither, return

* Update Window entrypoint - Put txt & Gfx cursors back on scrn
L1500               lbsr      L0129               Map the window in & setup Grfdrv mem
                    bsr       L1563               Put text cursor back on window
L1505               lbsr      L15BF               Put gfx cursor back on window
L1508               jmp       >GrfStrt+L0F78      no error & exit

* This takes the gfx/txt cursors off the screen before returning to original
* Grfdrv call
L150C               pshs      y,x,d               Preserve regs
                    bsr       L157A               Take text cursor off (restore original char)
                    lbsr      L15E2               Take Gfx cursor off (restore original screen)
                    ldb       >WGlobal+G.CurTik   Get restart counter for # clock interrupts per
                    stb       >WGlobal+G.CntTik   cursor update & make it current counter
                    puls      pc,y,x,d            Restore regs & return

* PutGC entry point (Took out mapping in window since the CMPY only lets us
* do anything if it IS mapped in currently
L151B               lbsr      L0129               Map in window & setup Grfdrv vars
                    cmpy      <$002E              Are we the current active window (window tbl)?
                    bne       L1508               No, don't bother with PutGC
                    ldd       <$005B              Get Graphics cursor X coord
                    cmpd      <$003D              Same as last used graphics cursor coord?
                    bne       L1531               No, go draw new graphics cursor
                    ldd       <$005D              Get Graphics cursor Y coord
                    cmpd      <$003F              Same as last used graphics cursor coord?
                    beq       L1508               Yes, don't bother updating
L1531               lbsr      L15E2               Put original data under cursor back to normal
                    bsr       L153B               Update 'last gfx cursor' on position to new one
                    bra       L1505               put gfx cursor back on screen, and exit: +3C:-3B

L153B               ldd       <$0047              Get current 'working' X & Y coords
                    ldx       <$0049
                    pshs      d,x                 Save them on stack
                    ifne      H6309
                    ldq       <$005b              Get new graphics cursor X & Y coords
                    stq       <$0047              Save as working copies for Put routines
                    stq       <$003d              Also, make them the new 'last position' coords
                    else
                    ldd       <$5d
                    std       <$B5
                    std       <$49
                    std       <$3f
                    ldd       <$5b
                    std       <$47
                    std       <$3d
                    endc
                    ldx       Wt.STbl,y           Get screen table ptr
                    ldx       St.LStrt,x          Get screen start address
                    lbsr      L1E9F               Screen address to put=X, start pixel mask=B
                    stx       <$0041              Save screen ptr
                    stb       <$0043              Save start pixel mask
                    puls      d,x                 Get back original 'working' coords
                    std       <$0047
                    stx       <$0049              Put them back for original GrfDrv function
L1579               rts

* Cursor on
L14F0               equ       *
                    ifne      H6309
                    aim       #^NoCurs,Wt.BSW,y   Set cursor flag to on
                    else
                    lda       Wt.BSW,y
                    anda      #^NoCurs
                    sta       Wt.BSW,y
                    endc
* Update txt cursor (on gfx or txt screens) from UPDATE Window 'hidden' call
L1563               lda       #$01                put the cursor on the screen
                    bra       L157B

* Cursor off
L14F8               equ       *
                    ifne      H6309
                    oim       #NoCurs,Wt.BSW,y    Set cursor flag to off
                    else
                    lda       Wt.BSW,y
                    ora       #NoCurs
                    sta       Wt.BSW,y
                    endc
* Update text cursor (on gfx or text screens) from within Grfdrv
L157A               clra                          take the cursor off of the screen

L157B               cmpy      <$002E              We on current window?
                    bne       L1579               No, exit
                    ifne      H6309
                    tim       #NoCurs,Wt.BSW,y    Cursor enabled?
                    else
                    pshs      a
                    lda       Wt.BSW,y
                    bita      #NoCurs
                    puls      a
                    endc
                    bne       L1579               No, exit
                    cmpa      <$0039              get cursor on screen flag
                    beq       L1579               same state as last time, exit
                    sta       <$0039              cursor is ON the screen
                    lbsr      L1002               Set up fonts, character sizes
                    bra       L158B               go put the cursor on-screen

* Cursor on
*L14F0    aim   #^NoCurs,Wt.BSW,y         Set cursor flag to on
* Update txt cursor (on gfx or txt screens) from UPDATE Window 'hidden' call
*L1563    cmpy  <$002E         We on current window?
*         bne   L1579          No, exit
*         tim   #NoCurs,Wt.BSW,y Cursor on?
*         bne   L1579          No, exit
*         ldb   <$0039       get GP buffer block number
*         bne   L1579        none, exit
*         lbsr  L1002          Set up font counts
*         bsr   L158B
*         inc   <$0039       cursor is ON the screen
*L1579    rts

* Cursor off
*L14F8    oim   #NoCurs,Wt.BSW,y         Set cursor flag to off
* Update text cursor (on gfx or text screens) from within Grfdrv
*L157A    cmpy  <$002E       We on current window?
*         bne   L158A        No, exit
*         ldb   <$0039
*         beq   L158A
*         lbsr  L1002        setup font counts
*         bsr   L158B
*         clr   <$0039       cursor is OFF of the screen
*L158A    rts

* Handle char. under cursor on Hware Text screen
* Entry: Y=window table ptr
* Exit: Attribute byte on screen has fore/bckground colors reversed
L158B               ldx       Wt.Cur,y            get cursor physical address
                    ldb       <$0060              get screen type
                    bpl       L15A5               Skip ahead if gfx screen
                    lda       1,x                 Get attribute byte of char. under cursor
                    bsr       L15B2               Get inversed fore/bck ground colors mask into A
                    ldb       1,x                 Get original attribute byte back
                    andb      #%11000000          Mask out all but blink & underline
                    ifne      H6309
                    orr       a,b                 Merge in swapped colors mask
                    else
                    pshs      a
                    orb       ,s+
                    endc
                    stb       1,x                 Set new attributes for this char
                    rts

* Set attributes on Gfx screen
L15A5               pshs      y                   Save window table ptr
                    ldu       #GrfStrt+L10FA      Setup vector for cursor on Gfx screen
                    clr       <$000E              Shut off all attributes
                    lbsr      L106D               Go put inversed char (under cursor) on screen
                    puls      pc,y                Restore window tbl ptr & return

* Flip fore/background color masks for hardware text attribute byte
* Entry:A=attribute byte for h/ware text screen
* Exit: A=Reversed color masks
L15B2               clrb                          no attributes here yet
                    anda      #%00111111          Mask out blinking, underline bits
                    ifne      H6309
                    lsrd                          one byte smaller than old method
                    lsrd                          move foreground in A to background in A,
                    lsrd                          background in A to 3 high bits of B
                    else
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    endc
                    lsrb                          shift background in B 2 bits: blink & underline
                    lsrb                          now background in A is in foreground in B
                    ifne      H6309
                    orr       b,a                 Merge two masks together in A
                    else
                    pshs      b
                    ora       ,s+
                    endc
                    rts

* Update Gfx Cursor - UPDATE Window 'hidden' call version - Put it on scrn
L15BF               pshs      y,x                 Preserve window & screen tbl ptrs
                    ldx       Wt.STbl,y           Get scrn tbl ptr from window tbl
                    cmpx      <$0030              Same as current screen?
                    bne       L15E0               No, leave
                    ldb       <$003A              Get Gfx cursor XOR'd on/off flag
                    bne       L15E0               It's already on screen, exit
                    ldb       Wt.GBlk,y           Get memory block # of gfx cursor
                    stb       <$0044              Save in Grfdrv mem
                    beq       L15E0               If there is no Gfx cursor defined, exit
                    bsr       L017C               Map in Gfx cursor GP buffer block
                    ldy       Wt.GOff,y           Get ptr to actual shape in block
                    sty       <$0045              Save it in Grfdrv mem
                    bsr       L15FE               XOR mouse cursor onto screen (put it on)
                    inc       <$003A              Set Gfx cursor XOR flag to 'ON'
L15E0               puls      pc,y,x              Restore regs & return

* Update Gfx cursor - from within GRFDRV - Take old one off scrn
L15E2               pshs      y,x
                    ldx       Wt.STbl,y
                    cmpx      <$0030
                    bne       L15FC
                    ldb       <$003A              is the Gfx cursor on the screen?
                    beq       L15FC               no, exit.
                    ldb       <$0044              grab gfx cursor GP buffer number
                    beq       L15E0               if none, exit
                    bsr       L017C               map in get/put buffer
                    ldy       <$0045              grab pointer to cursor in block
                    bsr       L15FE               XOR mouse cursor onto screen (take off old one)
                    clr       <$003A              Set Gfx cursor XOR flag to 'OFF'
L15FC               puls      pc,y,x

* XOR mouse cursor onto screen
L15FE               ldb       <$0060              Get screen type
                    bmi       L1634               Text; exit
                    ldd       <$004F              Get original X & Y sizes
                    ldx       <$0051
                    pshs      x,d                 Save them
                    ldd       <$0064              Get original Pset & Lset vectors
                    ldx       <$0068
                    pshs      x,d                 Save them
                    ldd       <$0041              Get screen address of Gfx cursor
                    std       <$0072              Save as GP buffer start position
                    ldb       <$0043              Get pixel mask for start of Gfx cursor
                    stb       <$0074              Save as GP buffer pixel mask start
                    ldx       #GrfStrt+L1F9E      Force PSET to 'off'
                    stx       <$0064
                    ldx       #GrfStrt+L1FA3      For LSET to XOR
                    stx       <$0068
                    lbsr      L0E14               set up for different STY in buffer/screen
                    lbsr      L0E97               go put the cursor on-screen
                    puls      x,d                 Restore original vectors
                    std       <$0064
                    stx       <$0068
                    puls      x,d                 Restore original X/Y sizes
                    std       <$004F
                    stx       <$0051
L1634               rts                           return

* Bring in Get/Put buffer memory bank - put into GRFDRV DAT Img @ <$87
* Entry: B=MMU block # to get
L017C               clr       <$89                Make sure System Global is first
                    stb       <$8A                Save Block number of Get/Put buffer
                    stb       >$FFA9              Save it to MMU as well
                    rts                           Return

* LSet entry point
L06A4               ldx       #GrfStrt+L06BC      Point to LSET vector table
                    ldb       Wt.LSet,y           Get LSet type
                    cmpb      #$03                If higher than 3, error
                    bhi       L06B7
                    ldb       b,x                 Get vector offset
                    abx                           Calculate vector
                    stx       Wt.LVec,y           Save LSet table vector
                    jmp       >GrfStrt+L0F78      Return to system without error

L06B7               comb                          Return to system with Illegal argument error
                    ldb       #E$IllArg
                    jmp       >GrfStrt+SysRet

* Retain "magic" spacing
                    ifeq      H6309
L1FA3b              equ       *
                    pshs      a
                    orb       ,s+
                    bra       L1FA3c
                    endc

* LSet vector table
L06BC               fcb       L1FA9-L06BC         Normal vector
                    fcb       L1FA7-L06BC         AND logical vector
                    fcb       L1FAE-L06BC         OR logical vector
                    fcb       L1FA3-L06BC         XOR logical vector
* LSET routines here: affecting how pixels go on screen
* The proper vector is stored in the window table @ <$14,y
* Entry: X=address of pixel to change
*        B=Bit mask of specific pixel to change (1, 2 or 4 bits)
*        A=Bits to actually set (color palette #)
*        A&B are also both preserved on the stack by the calling routine
* XOR
L1FA3               eora      ,x                  EOR new bits onto what is on screen
                    sta       ,x                  and save onto screen
                    rts                           5 bytes
* AND
L1FA7               anda      ,x                  AND new color onto what is on screen
* Normal
L1FA9               comb                          Make 'hole' for transparent putting
                    andb      ,x                  Create mask of bits already on screen
                    ifne      H6309
                    orr       a,b                 Merge color & bit mask
                    else
                    nop       keep                byte count the same
                    bra       L1FA3b
                    endc
L1FA3c              stb       ,x                  Save new byte
                    rts
* OR
L1FAE               ora       ,x                  Merge new color onto screen
                    sta       ,x                  and store them
L1FB2               rts                           return

* do a word of pixels at one time
* This is an ALAN DEKOK MAGIC ROUTINE! Do NOT CHANGE ANYTHING
* Likewise, do NOT change any offsets at the normal pixel routines at
* L1FA3 and following!
Pix.XOR             equ       *
                    ifne      H6309
                    eord      ,x                  offset 0
                    else
                    nop
                    bra       PEOR                keep byte count same
                    endc
PXOR2               std       ,x++
                    rts

Pix.AND             equ       *
                    ifne      H6309
                    andd      ,x                  offset 6
                    else
                    nop
                    bra       PAND
                    endc
PAND2               std       ,x++
                    rts

                    fcc       /ALAND/             space fillers

Pix.OR              equ       *
                    ifne      H6309
                    ord       ,x                  offset 17
                    else
                    ora       ,x
                    orb       1,x
                    endc
                    std       ,x++
                    rts
* End of ATD's magic routine!
                    ifeq      H6309
PEOR                eora      ,x
                    eorb      1,x
                    bra       PXOR2
PAND                anda      ,x
                    andb      1,x
                    bra       PAND2
                    endc

* Point entry point
L1635               bsr       I.point             map screen and PSET block in, scale coordinates
                    bcs       L1688               Error scaling, exit with it
                    lbsr      L1E9D               Get:X=ptr to byte on screen,B=bit mask for pixel
                    lda       <$0061              Get foreground color
                    ifne      H6309
                    ldw       <$68                Get LSET vector
                    else
                    pshs      x
                    ldx       <$68
                    stx       <$B5
                    puls      x
                    endc
                    jsr       ,u                  Put pixel on screen
                    bra       L1687               Exit without error

* Line entry point
* ATD: Line/bar/box set up screen: saves ~40 bytes, adds 6 clock cycles
I.line              lbsr      L1DFD               scale 2nd set of coordinates
                    bcs       L16B0               error: exit to a convenient RTS
I.point             lbsr      L1884               map in window, and verify it's graphics
                    ldu       <$64                get PSET vector for line/bar/box routines
                    lbra      L1DF6               Scale 1st set of coords

* Line entry point
L1654               bsr       I.line              internal line set up routine
                    bcs       L1688               Error; exit
                    ifne      H6309
                    ldw       <$68                Get LSET vector
                    else
                    ldd       <$68
                    std       <$B5
                    endc
                    ldd       <$0049              Get 'working' Y coordinate
                    cmpd      <$004D              Same as current Y coordinate?
                    bne       L1679               No, check X
                    bsr       L168B               Do 'fast' horizontal line
                    bra       L1687               Return to system without error

L1679               ldd       <$0047              Get 'working' X coordinate
                    cmpd      <$004B              Same as current X coordinate?
                    bne       L1684               No, use 'normal' line routine
                    lbsr      L16F4               Do 'fast' vertical line
                    bra       L1687               Return to system without error

L1684               lbsr      L1724               Do 'normal' line routine
L1687               clrb                          No error
L1688               jmp       >GrfStrt+SysRet     Return to system

* Swap start & end X coords if backwards ($47=Start, $4B=End)
L16A3               ldd       <$004B              Get end X coord
                    cmpd      <$0047              Compare with start X coord
                    bge       L16B0               Proper order, leave
L16AA               ldx       <$0047              Swap the 2 X coord's around
                    std       <$0047
                    stx       <$004B
L16B0               rts

* # of pixels/byte table
L16B1               fcb       $08                 640x200x2 color
                    fcb       $04                 320x200x4 color
                    fcb       $04                 640x200x4 color
                    fcb       $02                 320x200x16 color

* Fast horizontal line routine
L168B               bsr       L16A3               Make sure X coords in right order
L168D               lbsr      L1EF1               <$79=Start of byte pixel mask, <$77=Shift vector
* Entry point from FFILL
L1690               ldd       <$004B              Get end X coord of line
                    subd      <$0047              # pixels wide line is
                    ifne      H6309
                    incd                          +1 (base 1)
                    else
                    addd      #1
                    endc
                    std       <$0099              Save # of pixels left
                    lbsr      L1E9D               X=Mem ptr to 1st pixel, B=Mask for start pixel
                    lda       <$0061              Get foreground color mask (full byte)
                    ldy       <$0099              Get # pixels to do

* "Fast" horizontal line draw
* Entry: Y = # pixels left
*        A = Color bit mask
*        X = Screen address
*        B = mask for first pixel
*        W = address of LSET routine
*        U = address of PSET routine
L16B5               pshs      u,y,x,d             Preserve X & D, and reserve 4 bytes on stack
                    sta       6,s                 Save Full byte color mask
                    ldx       #GrfStrt+L16B1-1    Point to # pixels/byte table
                    ldb       <$0060              Get screen type
                    clra                          Clear high byte
                    ldb       b,x                 Get # pixels/byte for screen type
                    std       4,s                 Save overtop original Y on stack
                    puls      x,d                 Restore Screen ptr & Color/pixel masks
                    tstb                          is the pixel mask at the high bit of the byte?
                    bmi       L16D5               yes, start off with a check for TFM
*         bra   L16C9          Start drawing
                    fcb       $8C                 skip 2 bytes: same cycle time, 1 byte shorter

* Stack now has: 0,s = # pixels per byte (2,4 or 8, 16 bit # for Y compare)
*                2,s = Color mask
*                3,s = Garbage? (LSB of U)
*                Y   = # pixels left in line
* Put single pixels on the screen
L16C7               ldb       <$0079              Get bit mask for 1st pixel in byte
L16C9               std       <$97                Save current color & bit masks
                    jsr       ,u                  put pixel on the screen
                    leay      -1,y                Bump line pixel count down by 1
                    lbeq      L16F2               Done line, exit
                    ldd       <$97                Get color & bit masks back
* Set up bit pattern for next pixel, including changing byte position
                    jsr       >GrfStrt+L1F08      Set up for next pixel (scrn address & bit mask)
                    bpl       L16C9               (1st bit would be set if next byte, keep going)
* If on last byte, Y<#pixels per byte, so will use above loop
* If not on last byte, Y>#pixels per byte, so can 'cheat' & do 1 byte at a
* time below
L16D5               cmpy      ,s                  Done pixel count for current byte (or last byte)
                    blo       L16C7               No, keep going
* Draw remainder of line 1 full byte (2,4 or 8 pixels) at a time
* ATD: GrfStrt+L1FA9 is the normal PUT (no fancy stuff) routine
L16D7               tfr       y,d                 get number of pixels left into D
                    ifne      H6309
                    divd      1,s                 divide it by the number of pixels in 1 byte
                    else
                    clr       ,-s
L16D7b              inc       ,s
                    subb      2,s
                    sbca      #0
                    bcc       L16d7b
                    addb      2,s
                    tfr       b,a
                    puls      b
                    decb
                    endc
                    pshs      a                   save remainder for later
                    clr       ,-s                 and make remainder on-stack 16-bit
                    pshs      b                   save number of bytes to do

* now we have:
* B   = number of bytes to do a full byte at a time
* 0,S = number of bytes to do a full byte at a time
* 1,s = remainder of pixels in last byte to do
* 3,s = pixels per byte
* 5,s = color mask

                    lda       #(GrfStrt+L1F9E)&$00FF point to NO pset vector
                    cmpa      <$64+1              is it just a normal color routine?
                    bne       L16E2               no, it's a PSET, so go do it especially

                    ifne      H6309
                    cmpw      #GrfStrt+L1FA9      is it the normal PUT routine?
                    else
                    pshs      x
                    ldx       <$B5
                    cmpx      #GrfStrt+L1FA9
                    puls      x
                    endc
                    bne       L16E0               no, go use old method

                    clra
                    ifne      H6309
                    tfr       d,w                 into TFM counter register
                    endc
                    leay      5,s                 point to full byte color mask
                    ifne      H6309
                    tfm       y,x+                move everything else a byte at a time
* LDW MUST go before the call to L16F2!
                    ldw       #GrfSTrt+L1FA9      and restore vector to normal PUT routine
                    else
                    pshs      x,u
                    tfr       x,u
                    tfr       d,x
                    lda       ,y
L16DEb              sta       ,u+
                    leax      -1,x
                    bne       L16DEb
                    ldd       #GrfSTrt+L1FA9
                    std       <$B5
                    stu       ,s
                    puls      x,u
                    endc
L16DE               puls      b                   restore number of full bytes to do
                    lda       3,s                 get number of pixels per byte
                    mul                           get number of pixels done
                    addd      <$47                add to current X coordinate
                    std       <$47                and save as current X coordinate
L16DF               ldy       ,s++                restore 16-bit remainder of pixels: GET CC.Z bit
                    beq       L16F2               exit quickly if done all of the bytes
                    lda       2,s                 get pixel mask
                    bra       L16C7               and do the last few pixels of the line

L16E0               lsrb                          divide by 2
                    beq       L16E2               only 1 pixel to do, go do it.

* here we have 2 or more pixels to do full-byte, so we go to a method
* using D: much magic here!
* W = pointer to LSET routine
* U = pointer to routine that does ANDR B,A  JMP ,W
                    ifne      H6309
                    subw      #GrfStrt+L1FA3      point to start of LSET routines
                    else
                    pshs      d
                    ldd       <$B5
                    subd      #GrfSTrt+L1FA3
                    std       <$B5
                    puls      d
                    endc
                    beq       pix.do              skip fancy stuff for XOR
                    ifne      H6309
                    incf                          go up by one byte
                    else
                    inc       <$B6
                    endc
pix.do              ldu       #GrfStrt+Pix.XOR    point to double-byte pixel routines
                    ifne      H6309
                    leau      f,u                 point U to the appropriate routine
                    tfr       b,f                 move counter to a register
                    else
                    pshs      a
                    lda       <$B6
                    leau      a,u
                    stb       <$B6
                    puls      a
                    endc
pix.next            lda       5,s                 grab full-byte color mask
                    tfr       a,b                 make D=color mask
                    jsr       ,u                  call 2-byte routine
                    ifne      H6309
                    decf
                    else
                    dec       <$B6
                    endc
                    bne       pix.next
                    ifne      H6309
                    ldw       <$68                get LSET vector
                    else
                    ldu       <$68
                    stu       <$B5
                    endc
                    ldu       <$64                and PSET vector again
                    ldb       ,s                  get number of bytes left to do: do NOT do PULS!
                    andb      #1                  check for odd-numbered bytes
                    beq       L16DE               if done all the bytes, exit: does a PULS B
                    stb       ,s                  save the count of bytes to do: =1, and do one byte

* PSET+LSET full byte line draws come here
L16E2               ldb       #$FF                Full byte bit mask
                    lda       5,s                 Get color mask
                    jsr       ,u                  put the pixel on the screen
                    leax      1,x                 Bump screen ptr up by 1
                    ldd       3,s                 get number of pixels per byte
                    addd      <$0047              Update 'working' X-cord to reflect pixels we did
                    std       <$0047              Save result
                    dec       ,s                  decrement counter
                    bne       L16E2               continue until done
                    leas      1,s                 kill the counter off of the stack
                    bra       L16DF               restore 16-bit pixel remainder, and do last byte

L16F2               puls      pc,x,d              Restore regs & return when done

* Fast vertical line routine
L16F4               bsr       L1716               Make sure Y coords in right order
L16F6               ldd       <$004D              Calculate height of line in pixels
                    subb      <$004A
                    incb                          Base 1
                    std       <$0099              Save height
                    lbsr      L1E9D               Calculate screen address & pixel mask
                    lda       <$0061              Get color mask
                    std       <$0097              Save color & pixel masks
                    ldy       <$0099              Get Y pixel counter
L1707               ldd       <$0097              Get color & pixel mask
                    jsr       ,u                  Put pixel on screen
                    ldb       <$0063              Get # bytes to next line on screen
                    abx                           Point to it
                    inc       <$004A              Bump up working Y coord
                    leay      -1,y                Dec. Y counter
                    bne       L1707               Do until done
                    rts

* Swap Y coords so lower is first
L1716               ldd       <$004D              Get current Y coord
                    cmpd      <$0049              Compare with destination Y coord
                    bge       L1723               If higher or same, done
L171D               ldx       <$0049
                    std       <$0049
                    stx       <$004D
L1723               rts

* Next pixel calcs - See if <$47 could not be done outside the loop by a
*  simple ADDD (if needed at all)
* If it is needed in loop for some, simply have the ones that don't need to
*  come in at L1F0E instead
* Called from Fast Horizontal Line L16C9, Normal Line L177D, Flood Fill L1CD4
* Entry: <$0047 = Working X coord
*   B=Bit mask for current pixel
*   X=Screen address
* Exit:
*   B=Bit mask for new pixel (high bit set if starting new byte)
*   X=New screen address (may not have changed)
* ATD: Could replace calls to L1F08 with jsr [>GrfMem+gr0077], and move 'lsrb's
* from L1F14 here, to the TOP of the routine.  That would convert a
* JSR >foo, JMP[>GrfMem+gr0077] to a jsr [>], saving 4 cycles, adding 2 bytes per call
* Also, the 'inc' does NOT affect the carry.
L1F08               inc       <$0048              Inc LSB of working X coord
                    bne       L1F0E               Didn't wrap, skip ahead
                    inc       <$0047              Inc MSB of working X coord
L1F0E               lsrb                          Shift to next bit mask
                    bcs       L1F18               Finished byte, reload for next
                    jmp       [>GrfMem+gr0077]    Shift B more (if needed) depending on scrn type

L1F18               ldb       #1                  Bump screen address by 1
                    abx
                    ldb       <$0079              Get start single pixel mask (1,2 or 4 bits set)
                    rts

* Routine to move left for Normal Line L177D. Needed to get correct symmetry
LeftMV              pshs      d
                    ldd       <$0047
                    subd      #1
                    std       <$0047
                    puls      d
Lmore               lslb
                    bcs       Lmore2
                    jmp       [>GrfMem+gr007A]
Lmore2              leax      -1,x
                    ldb       <$007C
                    rts

* A dX or dY of 1 will step the line in the middle. The ends of the line
* are not swapped. The initial error is a function of dX or dY.
* A flag for left/right movement <$12 is used.
* Normal line routine
L1724               clr       <$0012              flag for X swap
                    ldd       <$004B              current X
                    subd      <$0047              new X
                    std       <$0013              save dX
                    bpl       L1734
                    com       <$0012              flag left movement
                    ifne      H6309
                    negd                          make change positive
                    else
                    nega
                    negb
                    sbca      #0
                    endc
                    std       <$0013              force dX>0
L1734               ldb       <$0063              BPL bytes/line
                    clra
                    std       <$0017              save 16-bit bytes per line
                    ldd       <$004D              current Y
                    subd      <$0049              subtract working Y
                    std       <$0015              save dY
                    bpl       L1753               if positive
                    ifne      H6309
                    negd                          make change positive
                    else
                    nega
                    negb
                    sbca      #0
                    endc
                    std       <$0015              force dY>0
                    ldd       <$0017              up/down movement; up=+ down=-
                    ifne      H6309
                    negd
                    else
                    nega
                    negb
                    sbca      #0
                    endc
                    std       <$0017              now points the correct direction

L1753               ldd       <$0013              compare dX with dY to find larger
                    cmpd      <$0015
                    bcs       Ylarge
                    ifne      H6309
                    asrd                          error = dX/2
                    bra       Lvector
Ylarge              ldd       <$0015
                    negd
                    asrd                          error = -dY/2
                    else
                    asra
                    rorb
                    bra       Lvector
Ylarge              ldd       <$0015
                    nega
                    negb
                    sbca      #0
                    asra
                    rorb
                    endc
Lvector             std       <$0075              error term
                    lbsr      L1EF1               Set up <$77 right bit shift vector & <$79 pixel mask
* for symmetry
                    lbsr      L1F1D               Set up <$7A left bit shift vector & <$79 pixel mask
                    lbsr      L1E9D               Calculate screen addr into X & pixel mask into B
                    stb       <$0074              Save pixel mask
L1760               ldb       <$0074              Get pixel mask
                    lda       <$0061              Get color mask
                    jsr       ,u
L1788               ldd       <$0047              finished with X movement?
                    cmpd      <$004B
                    bne       L1788b
                    ldd       <$0049              finished with Y movement?
                    cmpd      <$004D
                    bne       L1788b
                    rts                           finished fo leave
L1788b              ldd       <$0075              get error
                    bpl       L177D               if >=0
                    addd      <$0013              add in dX
                    std       <$0075              save new working error
                    ldd       <$0017              get BPL
                    ifne      H6309
                    addr      d,x
                    bcs       L1779               test direction not result
                    else
                    leax      d,x                 will not change regCC N
                    bmi       L1779
                    endc
                    inc       <$004A              go down one Y-line
                    bra       L1760

L1779               dec       <$004A              decrement y-count
                    bra       L1760

L177D               subd      <$0015              take out one BPL
                    std       <$0075              save new count
                    ldb       <$0074              grab pixel mask
                    tst       <$12                flag for left/right movement
                    bne       L177D2
                    lbsr      L1F08               go right one pixel
L177D3              stb       <$0074              save new pixel mask
                    bra       L1760               loop to draw it
L177D2              lbsr      LeftMV              go left one pixel
                    bra       L177D3

* Box entry point
* The optimizations here work because the special-purpose horizintal and
* vertical line routines only check start X,Y and end X OR Y, not BOTH of
* the end X,Y.  We can use this behaviour to leave in end X or Y coordinates
* that we want to use later.
* Possible problem: If the normal line routine is fixed to work properly,
* there won't be much need for the fast vertical line routine, and we'll have
* to fix up the X coordinates here.
L1790               lbsr      I.Line              internal line/bar/box setup
                    bcs       L17F9               Error; exit
                    lbsr      L16A3               Make sure X coords in right order
                    lbsr      L1716               Make sure Y coords in right order
                    leas      -4,s                Make 4 byte buffer on stack
                    ifne      H6309
                    ldq       <$47                Copy upper left coords: SX,SY
                    stq       ,s                  save on the stack
                    else
                    ldd       <$49
                    std       2,s
                    ldd       <$47
                    std       ,s
                    endc
                    pshs      y                   Save window table ptr
                    ifne      H6309
                    ldw       <$68                Get LSET vector
                    else
                    pshs      x
                    ldx       <$68
                    stx       <$B5
                    puls      x
                    endc
* enters with SX,SY ; EX,EY
                    lbsr      L168D               Do fast horizontal line: 0,0 -> X,0
* leaves with $47-$4D = EX+1,SY ; EX,EY
                    ldd       <$4B                grab EX+1 (incremented after line)
                    std       <$47                save proper EX
                    ldy       ,s                  grab window table pointer again: for L1E9D call
                    lbsr      L16F6               Do fast vertical line: X,0 -> X,Y
* leaves with $47-$4D = EX,EY+1 ; EX,EY
                    ldd       4,s                 get SY
                    std       <$49                save SY again
                    ldd       2,s                 get SX
                    std       <$47                save SX again
                    ldy       ,s                  get window table ptr
* enters with SX,SY ; EX,EY
                    lbsr      L16F6               Do other fast vertical line 0,0 -> 0,Y
* leaves with $47-$4D = SX,EY ; EX,EY
                    ldy       ,s                  restore window table pointer
                    ldd       <$4D                grab EY+1 (incremented after line)
                    std       <$49                save EY
                    lbsr      L168D               Do final fast horizontal line: 0,Y -> X,Y
                    leas      6,s                 Eat stack buffer
                    clrb                          No error & return
L17F9               jmp       >GrfStrt+SysRet

* Bar entry point
L17FB               lbsr      I.Line              internal line/bar/box routine
                    bcs       L1853
                    lbsr      L16A3               Make sure X coords in right order
                    lbsr      L1716               Make sure Y coords in right order
                    ifne      H6309
                    ldw       <$68                Get LSET vector
                    else
                    ldd       <$68
                    std       <$B5
                    endc

* internal BAR routine called from CLS for non-byte boundary clear to EOL
i.bar               ldd       <$0047              grab start X coordinate
                    std       <$0099              save it for later
                    subd      <$4B                take out end X coordinate
                    ifne      H6309
                    negd                          negate it
                    incd                          add one
                    else
                    coma
                    comb
                    addd      #2
                    endc
                    std       <$9B                save for later
                    lbsr      L1EF1               Set up <$79 bit mask & <$77 bit shft vector
                    lbsr      L1E9D               Calculate scrn ptr & 1st bit mask
                    lda       <$0061              Get color mask
                    std       <$009D              Save color mask & pixel mask
                    ldd       <$004D
                    subb      <$004A
                    incb
                    tfr       d,y                 Move # horizontal lines to draw to Y
L1839               pshs      y,x                 Preserve # lines left & screen ptr
                    ldy       <$009B
                    ldd       <$009D              Get color & pixel masks
                    lbsr      L16B5               Do fast horizontal line
                    puls      y,x                 Get # lines left & screen ptr
                    ldb       <$0063              Bump ptr to start of next line in bar
                    abx
                    inc       <$004A              Bump up Y coord
                    ldd       <$0099              get saved starting X coordinate
                    std       <$0047              save as current X coordinate
                    leay      -1,y                Bump line counter
                    bne       L1839               Draw until done
                    clrb                          No error & return
L1853               jmp       >GrfStrt+SysRet

* Circle entry point
L1856               bsr       L1884               Make sure window is graphics
                    ldd       <$53                Get radius (horizontal)
                    ifne      H6309
                    lsrd                          Calculate vertical radius for 'perfect circle'
                    else
                    lsra
                    rorb
                    endc
                    std       <$55                Vertical radius=Horizontal radius/2
                    bra       L18BF               Go to appropriate place in ellipse routine

* Arc entry point
L1860               bsr       L1884               Make sure window is graphics
                    lbsr      L1E05               Go scale start 'clip' coords, check if legal
                    bcs       L1853               Illegal coordinate, exit with error
                    lbsr      L1E24               Go scale end 'clip' coords, check if legal
                    bcs       L1853               Illegal coordinate, exit with error
                    ldd       <$0020              Get start clip X coord
                    cmpd      <$0024              Same as end clip X coord?
                    bne       L188E               No, skip ahead
                    ldx       #GrfStrt+L1A9D      Point to vertical line clip vector
                    ldd       <$0022              Get start clip Y coord
                    cmpd      <$0026              Same as end clip Y coord?
                    blt       L18B3               If lower, skip ahead
                    ldx       #GrfStrt+L1AA4      End X clip is to right of Start vector
                    bra       L18B3               Go save vector & continue

L1884               lbsr      L0177               Map in window
                    ldb       <$60                Get screen type
                    lbmi      L0569               If text, return with Error 192
                    ldb       Wt.PBlk,y           Get Pattern memory block
                    beq       L18BC               None, exit to a convenient RTS
                    lbra      L017C               Map that block in

* Different X coord clip coords
L188E               ldx       <$0022              Get start Y coord
                    cmpx      <$0026              Same as end Y coord?
                    bne       L18A3               No, skip ahead
                    ldx       #GrfStrt+L1AAB      Point to horizontal line clip vector
                    cmpd      <$0024              Is start X coord left of end X coord?
                    blt       L18B3               Yes, use this vector
                    ldx       #GrfStrt+L1AB1      Point to horizontal line/to right vector
                    bra       L18B3               Go save the vector & continue

* Different X & Y clip coords
L18A3               ldx       #GrfStrt+L1AB7      Point to 'normal' Arc Clip line vector
                    ldd       <$0020              Get start X coord
                    subd      <$0024              Calculate X clip line width
                    std       <$0097              Save it
                    ldd       <$0022              Get start Y coord
                    subd      <$0026              Calculate Y clip line height
                    std       <$0099              Save it
                    bra       L18B3               Go save vector & continue

L18B7               lbsr      L1B3B               Copy 5 byte integer from ,Y to ,X
* Shift 5 byte number pointed to by X to the left 1 bit
L1BDD               lsl       4,x                 (four 7 cycles & one 6 cycle)
                    ifne      H6309
                    ldq       ,x                  Get rest of 5 byte #
                    rolw                          Shift it all left
                    rold
                    stq       ,x                  Store result
                    else
                    ldd       2,x
                    rolb
                    rola
                    std       2,x
                    std       <$B5
                    ldd       ,x
                    rolb
                    rola
                    std       ,x
                    endc
L18BC               rts                           Exit

* Ellipse entry point
L18BD               bsr       L1884               Make sure we are on graphics screen
L18BF               ldx       #GrfStrt+L1ABB      Point to 'no clipping' routine
L18B3               stx       <$A1                Preserve clipping vector
* Clipping vector setup, start processing ARC
L18C5               lbsr      L1DF6               Make sure coord's & scaling will work
                    bcs       L18D4               Error, return to system with error #
                    lbsr      L1E28               Go make sure X & Y Radius values are legit
L18D4               lbcs      L1A75               Nope, exit with error
                    ifne      H6309
                    ldq       <$47                Get Draw pointer's X & Y Coordinates
                    stq       <$18                Make working copies
                    clrd                          Set some variable to 0
                    else
                    ldd       <$47
                    std       <$18
                    ldd       <$49
                    std       <$1A
                    clra
                    clrb
                    endc
                    std       <$1C                Store it
                    ldd       <$55                Get Y radius value
                    std       <$1E                Move to working area
                    leas      <-$3E,s             Make a 62 byte working stack area
                    sty       <$3C,s              Preserve Y in last 2 bytes of stack area
                    leax      $05,s               Point X into stack working area
                    ldd       <$0053              Get horizontal radius
                    lbsr      L1BA1.0             ATD: lbsr L1B32 moved for size
                    tfr       x,y
                    leax      <$14,s
                    ldd       <$0055
                    lbsr      L1BB1
                    leax      $0A,s
                    bsr       L18B7
                    tfr       x,y
                    leax      $0F,s
                    bsr       L18B7
                    leax      <$19,s
                    ldd       <$0055
                    lbsr      L1BA1.0             ATD: lbsr L1B32 moved for size
                    tfr       x,y
                    leax      <$1E,s
                    bsr       L18B7
                    tfr       x,y
                    leax      <$23,s
                    bsr       L18B7
                    leax      <$28,s
                    lbsr      L1B32.0             ATD: CLRD moved for size
                    leax      <$2D,s
                    ldd       <$001E
                    lbsr      L1B32
                    ifne      H6309
                    decd      Doesn't             affect circle
                    else
                    subd      #1
                    endc
                    lbsr      L1BA1
                    leay      $0A,s
                    lbsr      L1BB4
                    leay      $05,s
                    bsr       L19C3
                    leax      ,s
                    bsr       L19C6
                    lbsr      L1B63               ATD: LDD moved for size
                    leay      <$1E,s
                    lbsr      L1BB4
                    tfr       x,y
                    bsr       L19C3.0             ATD: LEAX moved for size
                    leax      <$32,s
                    bsr       L19C6.0             ATD: LEAY moved for size
                    bsr       L19C0.0             ATD: LDD moved for size
                    leax      <$37,s
                    leay      <$1E,s
                    lbsr      L1B3B
L1970               leax      <$14,s
                    leay      <$28,s
                    lbsr      L1C2E
                    ble       L19CC
                    lbsr      L1A78
                    tst       <$2D,s
                    bmi       L19A0
                    leax      <$32,s
                    leay      $0F,s
                    bsr       L19C3
                    tfr       x,y
                    bsr       L19C3.0             ATD: LEAX moved for size
                    leax      <$14,s
                    leay      $05,s

* [X] = [X] - [Y] : leave [Y] alone
* ONLY called once.  Moving it would save 1 byte (rts) (save LBSR, convert
* 3 BSRs to LBSRs), and save
* one LBSR/rts (11 cycles), and convert 3 BSR to LBSR (+3)
* can also get rid of superfluous exg x,y at the end of the routine
* used to be a stand-alone routine
L1B92               lbsr      L1C11.0             negate 5 byte [Y]: ATD: EXG X,Y moved for size
                    exg       x,y
                    lbsr      L1B7A               40 bit add: [X] = [X] + [Y]
                    lbsr      L1C11.0             negate 5 byte int: ATD: EXG X,Y moved for size
                    ldd       <$001E
                    ifne      H6309
                    decd      Doesn't             affect circle
                    else
                    subd      #1
                    endc
                    std       <$001E
L19A0               leax      <$37,s
                    leay      <$23,s
                    bsr       L19C3
                    tfr       x,y
                    bsr       L19C3.0             ATD: LEAX moved for size
                    leax      <$28,s
                    leay      <$19,s
                    bsr       L19C3
                    ldd       <$001C
                    ifne      H6309
                    incd                          Doesn't affect circle
                    else
                    addd      #1
                    endc
                    std       <$001C
                    bra       L1970

L19C0.0             ldd       <$001E              ATD: moved here for size
L19C0               jmp       >GrfStrt+L1BA1

L19C3.0             leax      <$2D+2,s            ATD: moved here for size
L19C3               jmp       >GrfStrt+L1B7A      add 40 bit [X] = [X] + [Y]

L19C6.0             leay      <$0F+2,s            ATD: moved here for size
L19C6               lbsr      L1B3B
                    jmp       >GrfStrt+L1C11      negate 5-byte integer

L19CC               leax      <$2D,s
                    ldd       <$001C
                    lbsr      L1B32
                    ifne      H6309
                    incd                          Doesn't affect circle
                    else
                    addd      #1
                    endc
                    bsr       L19C0
                    leay      <$1E,s
                    lbsr      L1BB4
                    leax      ,s
                    ldd       <$001E
                    lbsr      L1B32
                    subd      #$0002
                    bsr       L19C0
                    lbsr      L1B63               ATD: LDD moved for size
                    leay      $0A,s
                    lbsr      L1BB4
                    tfr       x,y
                    bsr       L19C3.0             ATD: LEAX moved for size
                    leax      ,s
                    leay      $0A,s
                    bsr       L19C6
                    lbsr      L1B63               ATD: LDD moved for size
                    leay      <$19,s
                    lbsr      L1BB4
                    tfr       x,y
                    bsr       L19C3.0             ATD: LEAX moved for size
                    leax      <$32,s
                    leay      <$23,s
                    lbsr      L1B3B
                    ldd       <$001C
                    bsr       L19C0
                    leax      <$37,s
                    bsr       L19C6.0             ATD: LEAY moved for size
                    bsr       L19C0.0             ATD: LDD moved for size
                    leay      $0A,s
                    bsr       L19C3
L1A32               ldd       <$001E
                    cmpd      #$FFFF              change to INCD?
                    beq       L1A71               won't be affected by INCD: exit routine
                    bsr       L1A78               draw pixel: shouldn't be affected by INCD
                    tst       <$2D,s
                    bpl       L1A57
                    leax      <$32,s
                    leay      <$23,s
                    bsr       L1A6E
                    tfr       x,y
                    bsr       L1A6E.0             ATD: LEAX moved for size
                    ldd       <$001C
                    ifne      H6309
                    incd                          Doesn't affect Circle
                    else
                    addd      #1
                    endc
                    std       <$001C
L1A57               leax      <$37,s
                    leay      $0F,s
                    bsr       L1A6E
                    tfr       x,y
                    bsr       L1A6E.0             ATD: LEAX moved for size
                    ldd       <$001E
                    ifne      H6309
                    decd      Doesn't             affect circle
                    else
                    subd      #1
                    endc
                    std       <$001E
                    bra       L1A32

L1A6E.0             leax      <$2D+2,s            ATD: moved here for size
L1A6E               jmp       >GrfStrt+L1B7A

L1A71               leas      <$3E,s
                    clrb
L1A75               jmp       >GrfStrt+SysRet

* Draw all 4 points that one calculation covers (opposite corners)
* (Ellipse & Circle)
L1A78               ldy       <$3E,s              Get window table ptr back (for [>GrfMem+gr00A1])
                    ldd       <$001C              grab current X offset from center
                    ldx       <$001E              grab current Y offset from center
* At this point, add check for filled flag. If set, put x,y pairs in
* for line command call (with bounds checking) & call line routine 2 times
* (once for top line, once for bottom line)
                    tst       <$b2                We doing a Filled Ellipse/Circle?
                    beq       NotFill             No, do normal
                    bsr       SetX                Do any adjustments to start X needed
                    std       <$47                Save as start X
                    std       <$AD                Save copy
                    ldd       <$1C                Get current X offset again
                    ifne      H6309
                    negd                          Negate for coord on other side of radius
                    else
                    coma
                    comb
                    addd      #1
                    endc
                    bsr       SetX                Do any adjustments
                    std       <$4b                Save end X coord
                    std       <$AF                Save Copy
                    tfr       x,d                 Copy current Y offset into D
                    pshs      x,y,u               Preserve regs for HLine call
                    bsr       DoHLine             Do line (if necessary)
                    ldy       2,s                 Get window table ptr back for checks
                    ifne      H6309
                    ldq       <$AD                Get original X coords back
                    std       <$47                Save Start X
                    stw       <$4b                Save End X
                    else
                    ldd       <$AF
                    std       <$B5
                    std       <$4b
                    ldd       <$AD
                    std       <$47
                    endc
                    ldd       ,s                  Get Y coord back
                    ifne      H6309
                    negd                          Negate for coord on other side of radius
                    else
                    coma
                    comb
                    addd      #1
                    endc
                    bsr       DoHLine             Do line (if necessary)
                    puls      x,y,u,pc            Restore regs & return

* NOTE: THIS WILL MODIFY <$47 AS IT GOES THROUGH THE LINE!
DoHLine             bsr       SetY                Do Y adjustments
                    cmpa      #$FF                Off window?
                    beq       SaveStrX            Yes, return without drawing
                    std       <$49                Save Y coord for fast horizontal line
                    ifne      H6309
                    ldw       <$68                Get LSET vector
                    else
                    ldu       <$68
                    stu       <$B5
                    endc
                    ldu       <$64                Get PSET vector
                    jmp       >GrfStrt+L168B      Call fast horizontal line & return from there

* Calc X coord & make sure in range
SetX                addd      <$18                Add X center point
                    bmi       OffLeft             Off left hand side, use 0
                    cmpd      Wt.MaxX,y           Past right hand side?
                    bls       SaveStrX            No, save start X
                    ldd       Wt.MaxX,y           Get right side of window
SaveStrX            rts

OffLeft             equ       *
                    ifne      H6309
                    clrd                          0 X Coord start
                    else
                    clra
                    clrb
                    endc
                    rts

* Calc Y coord & make sure in range
SetY                addd      <$1a                Add Y center point
                    bmi       OffTop              Off top, not drawable
                    cmpd      Wt.MaxY,y           Past bottom?
                    bhi       OffTop              Yes, not drawable
SaveStrY            rts

OffTop              lda       #$FF                Flag that it is off the window
                    rts

* Not filled circle or ellipse
NotFill             bsr       L1A97               Draw X,Y
                    ifne      H6309
                    negd                          invert X
                    else
                    coma
                    comb
                    addd      #1
                    endc
                    bsr       L1A97               Draw -X,Y
                    exg       d,x                 Invert Y
                    ifne      H6309
                    negd                          invert X
                    else
                    coma
                    comb
                    addd      #1
                    endc
                    exg       d,x
                    bsr       L1A97               Draw inverted X, inverted Y pixel
                    ldd       <$001C              Last, draw X,-Y
L1A97               pshs      x,d                 Preserve x,y coords
                    jmp       [>GrfMem+gr00A1]    Draw point (L1ABB if circle/ellipse)

* NOTE: THE FOLLOWING 6 LABELS (L1A9D, L1AA4, L1AAB, L1AB1, L1AB7 & L1ABB)
*   ARE POINTED TO BY >GrfMem+gr00A1, DEPENDING ON WHETHER ARC IS ON OR NOT, AND THE
*   COORDINATES ARE WITHIN CERTAIN BOUNDARIES. THE ENTRY CONDITIONS FOR ALL
*   6 OF THESE ARE:
* D=X coord offset from center point
* X=Y coord offset from center point
* (ARC) Vertical clip line, start Y > end Y coord vector
L1A9D               cmpd      <$0020              >= start clip X coord?
                    bge       L1ABB               Yes, go draw point
                    puls      pc,x,d              No, return

* (ARC) Vertical clip line, start Y < end Y coord vector
L1AA4               cmpd      <$0020              <= start clip X coord?
                    ble       L1ABB               Yes, go draw point
                    puls      pc,x,d              No, return

* (ARC) Horizontal clip line, start X < end X coord vector
L1AAB               cmpx      <$0022              <= start clip Y coord?
                    ble       L1ABB               Yes, go draw point
                    puls      pc,x,d              No, return

* (ARC) Horizontal clip line, start X > end X coord vector
L1AB1               cmpx      <$0022              >= start clip Y coord?
                    bge       L1ABB               Yes, go draw point
                    puls      pc,x,d              No, return

* (ARC) Clip line is diagonal in some way
L1AB7               bsr       L1ADF               Check if within range of diagonal clip line
                    bgt       L1ADD               If out of range, don't put pixel on screen
* Entry point for 'No clipping' routine pixel put
* Entry: D=X offset from center point
*        X=Y offset from center point
L1ABB               addd      <$0018              Add X offset to center point X
                    bmi       L1ADD               Off of left side of window, don't bother
                    cmpd      Wt.MaxX,y           Past right side of window?
                    bhi       L1ADD               Yes, don't bother
                    std       <$0047              Save X for Point routine
                    tfr       x,d                 Move Y offset to D
                    addd      <$001A              Add Y offset to center point Y
                    bmi       L1ADD               Off of top of window, don't bother
                    cmpd      Wt.MaxY,y           Past bottom of window?
                    bhi       L1ADD               Yes, don't bother
                    std       <$0049              Save Y coord for Point routine
                    lbsr      L1E9D               Calculate scrn addr:X, bit mask into B
                    lda       <$0061              Get color mask
                    ifne      H6309
                    ldw       <$68                Get LSET vector
                    else
                    pshs      x
                    ldx       <$68
                    stx       <$B5
                    puls      x
                    endc
                    jsr       [>GrfMem+gr0064]    Put pixel on screen
L1ADD               puls      pc,x,d              Restore regs & return

* Uses signed 16x16 bit multiply
* Called by Arc (probably in clipping coordinates)
L1ADF               pshs      x,d
                    leas      -4,s
                    tfr       x,d
                    subd      <$26
                    ifne      H6309
                    muld      <$97                Calculate 1st result
                    stq       ,s                  Save 24 bit result
                    else
                    pshs      x,y,u
                    ldx       <$97
                    bsr       MUL16
                    sty       6,s
                    stu       8,s
                    stu       <$B5
                    puls      x,y,u
                    endc
                    ldd       4,s
                    subd      <$24
                    ifne      H6309
                    muld      <$99                Calculate 2nd result
                    else
                    pshs      x,y,u
                    ldx       <$99
                    bsr       MUL16
                    stu       <$B5
                    tfr       y,d
                    puls      x,y,u
                    endc
                    cmpb      1,s                 Compare high byte with original multiply
                    bne       L1AF9               Not equal, exit with CC indicating that
                    ifne      H6309
                    cmpw      2,s                 Check rest of 24 bit #
                    else
                    ldd       <$B5
                    cmpd      2,s
                    endc
L1AF9               leas      4,s                 Eat our buffer
                    puls      pc,x,d              Restore regs & return

                    ifeq      H6309
MUL16               pshs      d,x,y,u             XmulD returns Y&U
                    clr       4,s
                    lda       3,s
                    mul
                    std       6,s
                    ldd       1,s
                    mul
                    addb      6,s
                    adca      #0
                    std       5,s
                    ldb       ,s
                    lda       3,s
                    mul
                    addd      5,s
                    std       5,s
                    bcc       MUL16b
                    inc       4,s
MUL16b              lda       ,s
                    ldb       2,s
                    mul
                    addd      4,s
                    clra
                    std       4,s
                    puls      d,x,y,u,pc
                    endc

L1B32.0             equ       *
                    ifne      H6309
                    clrd                          ATD: moved here for size
L1B32               clrw
                    stw       ,x
                    ste       2,x
                    else
                    clra
                    clrb
L1B32               pshs      d
                    clra
                    clrb
                    std       <$B5
                    std       ,x
                    sta       2,x
                    puls      d
                    endc
                    std       3,x
                    rts

L1B3B               pshs      d
                    ifne      H6309
                    ldq       ,y
                    stq       ,x
                    else
                    ldd       2,y
                    std       <$B5
                    std       2,x
                    ldd       ,y
                    std       ,x
                    endc
                    ldb       4,y
                    stb       4,x
                    puls      pc,d

L1B52               exg       y,u
                    exg       x,y
                    bsr       L1B3B
                    exg       x,y
                    exg       y,u
                    rts

* Called by ellipse
* Add 16 bit to 40 bit number @ X (but don't carry in 5th byte)
L1B63               ldd       #$0001              for circle, etc. above
L1B64               pshs      d
                    addd      3,x
                    std       3,x
                    ldd       #$0000              For using carry
                    ifne      H6309
                    adcd      1,x
                    else
                    adcb      2,x
                    adca      1,x
                    endc
                    std       1,x
                    ldb       #$00                *CHANGE: WAS CLRB, BUT THAT WOULD SCREW CARRY UP
                    adcb      ,x
                    stb       ,x
                    puls      pc,d

* Add 40 bit # @ X to 40 bit # @ Y; result into X
L1B7A               pshs      d
                    ldd       3,x
                    addd      3,y
                    std       3,x
                    ldd       1,x
                    ifne      H6309
                    adcd      1,y
                    else
                    adcb      2,y
                    adca      1,y
                    endc
                    std       1,x
                    ldb       ,x
                    adcb      ,y
                    stb       ,x
                    puls      pc,d

L1BA1.0             bsr       L1B32
L1BA1               pshs      y,d
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    pshs      d                   Put 3 0's on stack
                    pshs      b
                    tfr       s,y
                    bsr       L1BB4
                    leas      3,s
                    puls      pc,y,d

L1BB1               bsr       L1B32               Make 5 byte integer of D @ X
L1BB4               pshs      u,y,d               Preserve regs on stack
                    leas      -10,s               Make buffer for two 5 byte integers
                    tfr       s,u                 Point U to first buffer
* Was subroutine 1B5D
                    exg       x,u                 Swap temp ptr with X ptr
                    bsr       L1B3B               Copy 5 byte # from Y to X (into 1st temp buffer)
                    exg       x,u                 Swap ptrs back

                    tfr       u,y                 Move stack ptr to Y
                    leau      5,u                 Point U to 2nd 5 byte buffer
                    bsr       L1B52
                    ifne      H6309
                    bsr       L1B32.0             ATD: CLRD moved for size
                    else
                    lbsr      L1B32.0
                    endc
                    bra       L1BCB

L1BC9               lsl       4,y                 Multiply 5 byte integer by 2
                    ifne      H6309
                    ldq       ,y
                    rolw
                    rold
                    stq       ,y
                    else
                    ldd       2,y
                    rolb
                    rola
                    std       2,y
                    ldd       ,y
                    rolb
                    rola
                    std       ,y
                    endc

* Loop-Divide U by 2 until U=0 or uneven divide
*  (each time, multiply Y by 2)
* When U=0 & no remainder, exits
* When U=0 & remainder, 5 byte # @ X = that # + 5 byte # @ Y
* NOTE: If it works, change below & L1C06 to use LDQ/RORD/RORW/STQ
L1BCB               lsr       ,u                  Divide 5 byte integer by 2
                    bne       L1C06               If any non-zero bytes, make sure to clear 0 flag
                    ror       1,u
                    bne       L1C08
                    ror       2,u
                    bne       L1C0A
                    ror       3,u
                    bne       L1C0C
                    ror       4,u
* If it gets this far, the resulting 5 byte # is zero
                    beq       L1BD5               If result=0, skip ahead
NewLbl              bcc       L1BC9               If no remainder, multiply Y by 2 again
                    bsr       L1B7A               X=X+Y (5 byte #'s @ register names)
                    bra       L1BC9               Continue (multiply Y by 2 & divide U by 2 again)

L1BD5               bcc       L1BD9               If result=0 & no remainder, done & return
                    bsr       L1B7A               X=X+Y (5 byte #'s @ register names)
L1BD9               leas      10,s                Eat 2 5 byte integers off of stack
                    puls      pc,u,y,d            Restore regs & return

L1C06               ror       1,u                 Finishes divide by 2 with non-zero result
L1C08               ror       2,u
L1C0A               ror       3,u
L1C0C               ror       4,u
                    bra       NewLbl              Continue

* Negate 5 byte integer
L1C11.0             exg       x,y                 ATD: moved here for size
L1C11               com       ,x                  Invert # @ X
                    com       1,x
                    com       2,x
                    com       3,x
                    com       4,x

                    inc       4,x
                    bne       L1C2D
                    inc       3,x
                    bne       L1C2D
                    inc       2,x
                    bne       L1C2D
                    inc       1,x
                    bne       L1C2D
                    inc       ,x
L1C2D               rts

L1C2E               pshs      d
                    ldd       ,x
                    cmpd      ,y
                    bne       L1C4D
                    ldd       $02,x
                    cmpd      $02,y
                    bne       L1C44
                    ldb       $04,x
                    cmpb      $04,y
                    beq       L1C4D
L1C44               bhi       L1C4A
                    lda       #$08
                    fcb       $21                 skip one byte: same cycle time, 1 byte smaller
L1C4A               clra
L1C4B               tfr       a,cc
L1C4D               puls      pc,d


* FFill entry point
L1C4F               lbsr      L1884               ATD: +11C:-6B  exit if screen is text
                    ldb       #$01                Set flag that no error has occurred
                    stb       <$b1                LCB:Set flag that this is the 1st time through
                    stb       <$002A
                    lbsr      L1DF6               Check/calculate scaling
                    lbcs      L1CBF               Illegal coordinate, exit
                    ifne      H6309
                    ldq       <$47                Get original X,Y start (now scaled)
                    stq       <$AD                Save them
                    else
                    ldd       <$49
                    std       <$B5
                    std       <$AF
                    ldd       <$47
                    std       <$AD
                    endc
                    lbsr      L1E9D               Calculate screen address to start filling @
                    stx       <$0072              Save ptr to start pixel on physical screen
                    stb       <$0074              Save bit mask for start pixel
* replaced the code above with this: slightly larger, but L1F4B is smaller,
* and this code is only executed once, while L1F4B is executed many times
* the additional benefit is that <$0028 is now the full-byte color mask
* instead of the single pixel mask, and we can do byte-by-byte checks!
                    andb      ,x                  get first pixel: somewhere in the byte...
                    ldx       #GrfStrt+L075F-1    point to table of pixel masks
                    lda       <$0060              Get screen type
                    lda       a,x                 Get subtable ptr
                    leax      a,x                 Point to proper screen table
                    lda       2,x                 skip mask, color 0, get color 1 full-byte mask
                    mul                           multiple color by $FF, $55, or $11 (1,4,16-color)
                    ifne      H6309
                    orr       b,a                 bits are all mixed up: OR them together
                    else
                    pshs      b
                    ora       ,s+
                    endc
* now A = full-byte color mask for the color we want to FFILL on
                    ldx       #GrfStrt+L16B1-1    point to pixels/byte table
                    ldb       <$0060              get screen type again
                    ldb       b,x                 get B=pixels per byte
                    std       <$0028              save full-byte color mask, pixels per byte
* end of inserted code: a bit larger, but MUCH faster in the end
                    cmpa      Wt.Fore,y           background color as current foreground color?
                    beq       L1CB7               Yes, exit if no stack overflow occurred
                    clr       ,-s                 save y-direction=0: done FFILLing
                    lbsr      L1EF1               Setup start pixel mask & vector for right dir.
                    bsr       L1F1D
                    ldx       <$0072
                    lbra      L1CC6
* Setup up bit mask & branch table for flood filling in the left direction
L1F1D               lda       <$0060              Get screen type
                    ldx       #GrfStrt+L1F2C-2    Point to table
                    lsla                          x2 for table offset
                    ldd       a,x                 Get mask and branch offset
                    sta       <$007C              Preserve bit mask
                    abx                           Store vector to bit shift routine
                    stx       <$007A              save for later
                    rts

* Bit shift table to shift to the left 3,1 or 0 times
* Used by FFill when filling to the left
L1F2C               fcb       $01,L1F45-(L1F2C-2) $1b  640 2-color
                    fcb       $03,L1F44-(L1F2C-2) $1a  320 4-color
                    fcb       $03,L1F44-(L1F2C-2) $1a  640 4-color
                    fcb       $0f,L1F42-(L1F2C-2) $18  320 16-color
* Bit shifts based on screen type
L1F42               lslb
                    lslb
L1F44               lslb
L1F45               rts

X1F08               lda       <$0028              get full-byte background color mask
                    cmpa      ,x                  same as the byte we're on?
                    beq       X1F16               yes, skip ahead
                    leau      1,u                 otherwise go to the right one pixel
X1F0E               lsrb                          Shift to next bit mask
                    bcs       X1F18               Finished byte, reload for next
                    jmp       [>GrfMem+gr0077]    Shift B more (if needed) depending on scrn type

* background is a byte value, but we don't know what the X coord is
X1F16               clra
                    ldb       <$29                pixels per byte
                    ifne      H6309
                    addr      d,u                 go to the right one byte
                    else
                    leau      d,u
                    endc
                    decb                          make 2,4,8 into 1,3,7
                    ifne      H6309
                    comd                          get mask
                    andr      d,u                 force it to the left-most pixel of the byte
                    else
                    coma
                    comb
                    pshs      d
                    tfr       u,d
                    anda      ,s
                    andb      1,s
                    tfr       d,u
                    puls      d
                    endc
X1F18               ldb       #1                  Bump screen address by 1
                    abx
                    ldb       <$0079              Get start single pixel mask (1,2 or 4 bits set)
                    rts

* Switch to next line for FFill
L1CC2               leas      4,s                 Eat last set of X start ($47), end ($9B)
* $101B is a counter counted down continuously by VTIO.
* this is DEBUG code... check out 1D28: if no NEW PIXEL is put down for
* 255 ticks (~4 seconds), exit with error.
* May have to add it back in for SnakeByte Pattern paint bug?
L1C93               ldb       ,s+                 grab y-direction to travel
                    beq       L1CB7               if zero, check if we're done
                    stb       <$002B              save direction to travel in
                    addb      ,s+                 add into saved Y-coordinate
                    cmpb      <Wt.MaxY+1,y        check against the maximum Y position
                    bhi       L1CC2               too high, eat X start,end and go DOWN
                    stb       <$004A              save current Y-position
                    puls      d,x                 restore X start, X end
                    std       <$0047              save it for later
                    stx       <$004B              save that, too
                    lbsr      L1E9D               get X=logical screen coordinates, B=pixel mask
                    stb       <$0074              save starting pixel mask
                    jmp       >GrfStrt+L1D40      go do some painting

* Check if done filling or if error occurred
L1CB7               clrb                          Clear carry as default (no error)
                    ldb       <$002A              Get done/error flag
                    bne       L1CBF               Done flag, exit without error
L1CBC               ldb       #E$StkOvf           Stack overflow error
                    coma
L1CBF               jmp       >GrfStrt+SysRet

* Move 1 pixel to left (for FFill)
* <$0028 = full-byte color mask to paint on
* <$0029 = pixels per byte
L1F34               lda       ,x                  get current byte
                    cmpa      <$0028              full-byte background color?
                    beq       L1F3C               yes, go do full-checks
                    leau      -1,u                drop down by 1
                    lslb                          Move pixel mask to left by 1
                    bcs       L1F46               If finished byte, skip ahead
                    jmp       [>GrfMem+gr007A]    Adjust for proper screen type (further LSLB's)

L1F3C               clra                          make A=0
                    ldb       <$0029              get 16-bit value of pixels per byte
                    decb                          get 7,3,1 pixel mask
                    ifne      H6309
                    comd                          get pixel mask, with low bits cleared out,
                    andr      d,u                 i.e. ensure we're to the LEFT as far as possible
                    else
                    coma
                    comb
                    pshs      d
                    tfr       u,d
                    anda      ,s
                    andb      1,s
                    tfr       d,u
                    puls      d
                    endc
                    leau      -1,u                go to the left one pixel

L1F46               ldb       <$007C              Get start pixel mask (on right side)
                    leax      -1,x                Bump screen's pixel ptr left & return
                    rts

* search until we find the left-most pixel which is NOT the paint on pixel,
* or the edge of the screen
* Exits with B=pixel mask
* W = current X position
* U = W
FFILL.1             ldb       <$0074              Get pixel mask for pixel we are doing
                    ldu       <$0047
L1CC8               lbsr      L1F4B               check pixel
                    bne       L1CD4               backup if not the background color pixel
                    bsr       L1F34               exits with U = x-coord
                    ifne      H6309
                    cmpr      0,u                 has it filled to line position -1?
                    else
                    cmpu      #0
                    endc
                    bpl       L1CC8               we're still on the same color, continue
* we've found the left boundary, go to the right
L1CD4               equ       *
                    ifne      H6309
                    bra       X1F08               go to the right one pixel: account for extra DECW
                    else
                    lbra      X1F08
                    endc

L1CC6               bsr       FFILL.1
                    stu       <$0047
                    stu       <$009B              save for later
                    bsr       FFILL.2             paint to the right, a pixel at a time
                    lda       #$FF                get a flag: go UP one line
                    bsr       L1D05               set up for another fill
                    lda       #$01                get a flag: go DOWN one line
                    bsr       L1D05               save more things on the stack
                    bra       L1C93               go do another line

* paint to the right, a pixel at a time.
* Exits with B=pixel mask
* W = current X position
* U = W
FFILL.2             ldu       <$0047
                    stu       <$20                save X-start for this fill routine
                    clr       <$2C                clear flag: no pixels done yet
ffill.2a            bsr       L1F4B               check if we hit color other than background
                    bne       L1CEA               yes, skip ahead
                    lbsr      X1F08               go to the right one pixel
                    stb       <$2C
                    cmpu      Wt.MaxX,y           Are we at right side of window?
                    bls       FFILL.2a            no, continue
* we've gone too far to the right
L1CEA               bsr       L1F34               back up one pixel
* ATD: New routine added.  Do a horizontal line from left to right!
* This is not substantially faster, perhaps, but it does look better.
                    pshs      d
                    lda       <$2C                check flag
                    beq       L1D03               skip ahead: no pixels to draw
* LCB: New routine added to check if we are redoing the 1st pixel we started
* painting at. If we are exit (Helps fill certain PSET variations that allow
* infinite recursions (loops) that hang Grfdrv)
                    lda       <$B1                Get flag that we are on 1st line of FFill
                    beq       DoChecks            Not 1st time, do checks
                    clr       <$B1                Clear flag & do draw
                    bra       Not1st

DoChecks            ldd       <$AF                Get Y value from 1st FFill line
                    cmpd      <$49                Same as current?
                    bne       Not1st              No, go draw
                    cmpu      <$AD                right side X lower or same as original X?
                    bhi       Not1st              No, draw it
                    ldd       <$20                Get left X coord
                    cmpd      <$AD                left side X higher or same as original X?
                    blo       Not1st              No, draw it
                    leas      4,s                 We already did this, eat stack & exit w/o error
                    clrb
                    jmp       >GrfStrt+SysRet

Not1st              ldd       <$4B                get old coordinate: U=<$0047 already
                    pshs      d,x,y,u
                    stu       <$4B                save as X-end
                    ldd       <$20                get LHS X coordinate
                    std       <$47                save for the line routine
* ATD: warning: This routine trashes W!
                    ifne      H6309
                    ldw       <$68                get LSET vector
                    else
                    ldu       <$68
                    stu       <$B5
                    endc
                    ldu       <$64                and PSET vector
                    jsr       >GrfStrt+L1690      do fast horizontal line
                    puls      d,x,y,u             restore registers
                    std       <$004B              save
L1D03               stu       <$0047              save
                    puls      d,pc

L1D05               puls      u                   restore PC of calling routine
                    ldb       <$004A              get B=working Y coordinate
                    pshs      y,x,d               save PC, and 4 junk bytes; ???RG
                    ifne      H6309
                    ldw       <$0047              Get 'working' X coord
                    else
                    ldd       <$47
                    std       <$B5
                    std       4,s                 see stq 2,s below
                    endc
                    ldd       <$009B              and left-most pixel we were at
                    ifne      H6309
                    stq       2,s                 save X start, end positions on the stack
                    else
                    std       2,s                 see std 4,s above
                    endc
                    jmp       ,u                  return to calling routine

* ATD: mod: <$0028 is full-byte color mask
* Entry: X=ptr to current byte on screen
*        B=bit mask for current pixel
* Exit:  B=bit mask for current pixel
*        CC set to check if we hit border of FFill
L1F4B               pshs      b                   Preserve pixel mask
                    tfr       b,a                 Duplicate it
                    anda      ,x                  Get common bits between screen/mask
                    andb      <$0028              and common bits between full-byte color and mask
                    ifne      H6309
                    cmpr      b,a                 are the 2 colors the same?
                    else
                    pshs      b
                    cmpa      ,s+
                    endc
                    puls      pc,b                Restore pixel mask & return

* start painting at a new position.
* <$47=start X, <$49=current Y,  <$4B=end X
* Check to the left for bounds
L1D40               ldu       <$0047              get current X
                    leau      -2,u                go to the left 2 pixels? : wrap around stop pixel
                    stu       <$009B              save position
                    lbsr      FFILL.1             search to the left
                    bra       L1D58               skip ahead

L1D55               lbsr      X1F08               go to the right one pixel
L1D58               stu       <$0047              save X coordinate
                    cmpu      <$004B              check against X-end from previous line
                    lbhi      L1C93               too far to the right, skip this line
                    bsr       L1F4B               check the pixel
                    bne       L1D55               not the same, go to the right
                    stb       <$0074              save starting pixel mask
                    cmpu      <$009B              check current X against saved start (X-2)
                    bgt       L1D87               higher, so we do a paint to the right
                    bsr       L1DEE               check stack
                    beq       L1D87               if 0: stack is too low
                    ldu       <$009B              grab X
                    ldd       <$0047              grab current X
* ATD: removed check for X coord <0, as the above call to X1F08 ensures it's
* at least 0.
                    pshs      d,u                 Save X start, X end coordinates
                    ldb       <$004A              Get Y coord
                    lda       <$002B              Get save current Y-direction
                    nega                          Change direction
                    pshs      d                   Save direction flag and Y coord
L1D87               ldd       <$0047              Get current X coord
                    std       <$009B              Save duplicate (for direction change???)
                    ldb       <$0074              Get current pixel mask

* Paint towards right side
L1D98               lbsr      FFILL.2
                    stb       <$0074              Save new start pixel mask
                    bsr       L1DEE               check stack
                    beq       L1DAA               if 0: stack is too low
                    lda       <$002B              grab direction flag
                    bsr       L1D05               save current X start, end on-stack
                    ldb       <$0074              grab starting pixel mask
                    ldu       <$0047              restore current X-coord

* Small loop
L1DAA               lbsr      X1F08               Adjust for next pixel on the right
                    stb       <$0074              Save new pixel mask
                    stu       <$0047              and new X-coord
                    cmpu      Wt.MaxX,y           Hit right side of window?
                    bgt       L1DC4               Yes, skip ahead
                    cmpu      <$004B              Is current X coord going past Draw ptr X coord?
                    bgt       L1DC4               Yes, skip ahead
                    bsr       L1F4B               Check if we are hitting a drawn border
                    bne       L1DAA               No, keep FFilling
                    bra       L1D87               paint to RHS of the screen

* could be subroutine call to L1DEE
* saves 6 bytes, adds 10 clock cycles
L1DC4               cmps      <$003B              Stack about to get too big?
                    bhi       L1DCB               No, continue
                    clr       <$002A              Yes, set flag to indicate stack overflow
L1DCB               leau      -1,u                go to the left one pixel
                    stu       <$0047              Save X coord
                    ldd       <$004B              Get draw ptr X coord
                    addd      #2                  Bump up by 2
                    ifne      H6309
                    cmpr      u,d                 Past current X coord in FFill?
                    else
                    pshs      u
                    cmpd      ,s++
                    endc
                    lbhi      L1C93               Yes, go change Y-direction
                    pshs      d,u                 Save draw ptrs X+2, current X coord
                    ldb       <$004A              Get working Y coord
                    lda       <$002B              get y-direction flag
                    nega                          Change direction?
                    pshs      d                   Save direction flag and Y coord
L1DEB               jmp       >GrfStrt+L1C93      go do another direction

L1DEE               cmps      <$003B              check against lowest possible stack
                    bhi       L1DF5               Question:  Why not just an in-line check?
                    clr       <$002A              clear flag: stack is too low
L1DF5               rts

L1DF6               ldb       #$47                get offset in grfdrv mem to working X coord
L1DF8               bsr       L1E2C
* Check requested X/Y co-ordinates to window table to see if they are in range
L1E86               equ       *
                    ifne      H6309
                    ldq       ,x                  Get requested X & Y coordinates
                    else
                    ldd       2,x
                    std       <$B5
                    ldd       ,x
                    endc
                    cmpd      Wt.MaxX,y           X within max. range of window?
                    bhi       L1E99               No, return error
                    ifne      H6309
                    cmpw      Wt.MaxY,y           Y within max. range of window? (keep it 16-bit)
                    else
                    pshs      x
                    ldx       <$B5
                    cmpx      Wt.MaxY,y
                    puls      x
                    endc
                    bhi       L1E99               No, return error
                    andcc     #^Carry             They work, return without error
                    rts

L1E99               comb                          set carry
                    ldb       #E$ICoord           get error code
                    rts                           return

L1DFD               ldb       #$4B                Get offset in grfdrv mem to current X coord
                    bra       L1DF8
L1E01               ldb       #$4F                Get offset in Grfdrv mem to X size
                    bra       L1DF8

L1E05               ldb       #$20                Point to Arc 'clip line' Start coordinate
* Check both X and Y coordinates and see if valid (negative #'s OK)
* Entry : B=Offset into GRFDRV mem to get X & Y (16 bit) coordinates
L1E07               bsr       L1E2C               Do offset of X into grfdrv space by B bytes
                    ifne      H6309
                    ldw       #639                Maximum value allowed
                    else
                    pshs      x
                    ldx       #639
                    stx       <$B5
                    puls      x
                    endc
                    bsr       L1E13               Check if requested coordinate is max. or less
                    bcs       L1E23               Error, exit
                    ifne      H6309
                    ldw       #MaxLines*8-1       Maximum Y coord allowed; check it too
                    else
                    pshs      x
                    ldx       #MaxLines*8-1
                    stx       <$B5
                    puls      x
                    endc
* Make sure 16 bit coordinate is in range
* Entry: W=Maximum value allowed
*        X=Pointer to current 16 bit number to check
* Exit:  B=Error code (carry set if error)

L1E13               ldd       ,x++                Get original value we are checking
                    bpl       L1E1D               Positive, do the compare
                    ifne      H6309
                    negd                          Flip a negative # to a positive #
L1E1D               cmpr      w,d                 If beyond maximum, return with Illegal coord error
                    else
                    coma
                    comb
                    addd      #1
L1E1D               cmpd      <$B5
                    endc
                    bgt       L1E99
                    clrb                          In range, no error
L1E23               rts

L1E24               ldb       #$24                Point to Arc 'clip line' end coordinate
                    bra       L1E07

L1E28               ldb       #$53                Point to Horizontal Radius
                    bra       L1E07

* Offset X into grfdrv mem by B bytes (to point to 2 byte coordinates)
L1E2C               ldx       #GrfMem             Point to GRFDRV mem
                    abx                           Point X to X,y coord pair we are working with
                    ifne      H6309
                    tim       #Scale,Wt.BSW,y     Scaling flag on?
                    else
                    pshs      a
                    lda       Wt.BSW,y
                    bita      #Scale
                    puls      a
                    endc
                    beq       L1E39               no, return
                    ldd       Wt.SXFct,y          Get X & Y scaling values
                    bne       L1E3A               If either <>0, scaling is required
L1E39               rts                           If both 0 (256), scaling not required

* Scaling required - Scale both X & Y coords
* Change so ldb ,s/beq are both done before ldx ,y (will save time if that
* particular axis does not require scaling)
* Entry:X=Ptr to X,Y coordinate pair (2 bytes each)
*       Y=Window tble ptr
*       A=X scaling multiplier
*       B=Y scaling multiplier
L1E3A               pshs      a                   Preserve X scaling value
                    tstb                          Y need scaling?
                    beq       NoY                 No, skip scaling it
* ATD: 10 bytes smaller, 20 cycles longer
* leax 2,x
* bsr L1E4A
* leax -2,s
                    clra                          D=Y scaling value
                    ifne      H6309
                    muld      2,x                 Multiply by Y coordinate
                    tfr       b,a                 Move 16 bit result we want to D
                    tfr       e,b
                    cmpf      #$cd                Round up if >=.8 leftover
                    else
                    pshs      x,y,u
                    ldx       2,x
                    lbsr      MUL16
                    tfr       y,d
                    stu       <$B5
                    puls      x,y,u
                    tfr       b,a
                    ldb       <$B6
                    cmpb      #$cd                cmpf #$cd
                    pshs      cc                  save result
                    ldb       <$B5                tfr e,b
                    puls      cc
                    endc
                    blo       L1E48               Fine, store value & do X coord
                    ifne      H6309
                    incd                          Round up coordinate
                    else
                    addd      #1
                    endc
L1E48               std       2,x                 Save scaled Y coordinate
NoY                 ldb       ,s+                 Get X scaling value
                    beq       L1E52               None needed, exit
L1E4A               clra                          D=X scaling value
                    ifne      H6309
                    muld      ,x                  Multiply by X coordinate
                    tfr       b,a                 Move 16 bit result we want to D
                    tfr       e,b
                    cmpf      #$cd                Round up if >=.8 leftover
                    else
                    pshs      x,y,u
                    ldx       ,x
                    lbsr      MUL16
                    stu       <$B5
                    tfr       y,d
                    puls      x,y,u
                    tfr       b,a
                    ldb       <$B6
                    cmpb      #$cd                cmpf #$cd
                    pshs      cc                  save result
                    ldb       <$B5                tfr e,b
                    puls      cc
                    endc
                    blo       L1E50               Fine, store value & return
                    ifne      H6309
                    incd                          Round up coordinate
                    else
                    addd      #1
                    endc
L1E50               std       ,x                  Save new X coordinate
L1E52               rts                           Return

L1EF1               lda       <$0060              get screen type
                    ldx       #GrfStrt+L1F00-2    Point to mask & offset table
                    lsla                          account for 2 bytes entry
                    ldd       a,x                 get mask & offset
                    sta       <$0079              Preserve mask
                    abx                           Point to bit shift routine
                    stx       <$0077              Preserve vector to bit shift routine
                    rts

* Bit shift table to shift to the right 3,2,1 or 0 times
L1F00               fcb       $80,L1F17-(L1F00-2) $19    640 2 color
                    fcb       $c0,L1F16-(L1F00-2) $18    320 4 color
                    fcb       $c0,L1F16-(L1F00-2) $18    640 4 color
                    fcb       $f0,L1F14-(L1F00-2) $16    320 16 color

L1F14               lsrb
                    lsrb
L1F16               lsrb
L1F17               rts

* PSET vector table - if PSET is on. Otherwise, it points to L1F9E, which
* does an AND to just keep the 1 pixel's worth of the color mask and calls
* the proper LSET routine
L1FB4               fcb       L1F60-(L1FB4-1)     640x200x2
                    fcb       L1F6E-(L1FB4-1)     320x200x4
                    fcb       L1F6E-(L1FB4-1)     640x200x4
                    fcb       L1F7C-(L1FB4-1)     320x200x16

* PSET vector ($16,y) routine - 2 color screens
L1F60               pshs      x,b                 Preserve scrn ptr & pixel mask
                    bsr       L1F95               Calculate pixel offset into pattern buffer
                    abx                           Since 1 bit/pixel, that is address we need
                    ldb       <$0048              Get LSB of X coord
                    lsrb                          Divide by 8 for byte offset into pattern buffer
                    lsrb
                    lsrb
                    andb      #%00000011          MOD 4 since 2 color pattern buffer 4 bytes wide
                    bra       L1F88               Go merge pattern buffer with pixel mask

* PSET vector ($16,y) routine - 4 color screens
L1F6E               pshs      x,b                 Preserve scrn ptr & pixel mask
                    bsr       L1F95               Calculate pixel offset into pattern buffer
                    lslb                          Since 2 bits/pixel, multiply vert. offset by 2
                    abx
                    ldb       <$0048              Get LSB of X coord
                    lsrb                          Divide by 4 for byte offset into pattern buffer
                    lsrb
                    andb      #%00000111          MOD 8 since 4 color pattern buffer 8 bytes wide
                    bra       L1F88               Go merge pattern buffer with pixel mask

* PSET vector ($16,y) routine - 16 color screens
L1F7C               pshs      x,b                 Preserve scrn ptr & pixel mask
                    bsr       L1F95               Calculate pixel offset into pattern buffer
                    lslb                          Since 4 bits/pixel, multiply vert. offset by 4
                    lslb
                    abx
                    ldb       <$0048              Get LSB of X coord
                    lsrb                          Divide by 2 for byte offset into pattern buffer
                    andb      #%00001111          MOD 16 since 16 color pattern buffer 16 bytes wide
L1F88               ldb       b,x                 Get proper byte from pattern buffer
                    andb      ,s+                 Only keep bits that are in pixel mask
                    puls      x                   Restore screen ptr

* DEFAULT PSET ROUTINE IF NO PATTERN BUFFER IS CURRENTLY ACTIVE. POINTED TO
* BY [$64,u], usually called from L1F5B
L1F9E               equ       *
                    ifne      H6309
                    andr      b,a                 Only keep proper color from patterned pixel mask
                    jmp       ,w                  Call current LSET vector
                    else
                    pshs      b
                    anda      ,s+
                    jmp       [>GrfMem+$B5]
                    endc
* Calculate pixel offset into pattern buffer (32x8 pixels only) from Y coord
* Exit: X=ptr to start of data in pattern buffer
*       B=Pixel offset within buffer to go to
L1F95               ldx       <$0066              Get current pattern's buffer ptr
                    ldb       <$004A              Calculate MOD 8 the line number we want
                    andb      #%00000111          to get data from the Pattern buffer
                    lslb                          Multiply by 4 to calculate which line within
                    lslb                          Pattern buffer we want (since 32 pixels/line)
                    rts

                    emod
eom                 equ       *
                    end
