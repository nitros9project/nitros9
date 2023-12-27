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
**            - In L0B79 (Move Buffer command), optimized to not PSHS/PULS
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
** V2.00a changes (LCB)
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
** Repository changes (RG)
** 09/17/03 - Added trap for windows overlapping 512K bank; RG.
**            Required changing a bsr L0306 to lbsr L0306 near L02A7
** 09/25/03 - Many changes for 6809 only code. Use <$B5 to store regW
**            Probably could use some trimming. RG
** 02/26/07 - Changed Line routine to improve symmetry. The changes will permit
**            the removal of the FastH and FastV routines if desired. The new
**            Normal Line will correctly draw horizontal or vertical lines. RG
**     NOTE: THIS CHANGE HAS CAUSED DISTORTIONS ON SOME PROGRAMS (NOTABLY, SHAWN
**           DRISCOLL'S GUIB Diamond
** EOU Beta 1 changes - Hardware transparency re-enabled, as per Version 3.0 upgrade.
**            (allows using transparency switch to switch between current background
**             colour setting, and leaving background color currently at text printing
**             location.
** EOU Beta 2 changes (LCB)
** 11/13/18 - Fixed (along with CoWin) to allow grfdrv loaded outside of system map (BN)
** 11/21/18 - Started changes (mostly for 6809 version) to use new DP address <grScrtch
**            for immediate temp storage instead of stack (saves 4 cycles per save/restore
**            or save/manipulate/check (LCB). Done in get.font, L01E0, L01FB, L0206,L023A,
**            L0256
** 11/21/18 - Implemented mini-stack blast clear routine (4 byte even version only so far)
**            used by screen clear (both text and graphics modes) in DWSet, and resetting
**            all palettes to black when DWEnding last window on a screen.
** 11/26/18 - Implemented StkBlCpy routine used for screen scrolling, PutBlk and GPLoad for
**            6809.
** EOU Beta 3 changes (LCB)
** 12/02/18 - Implemented StkBlClr routine used for CLS, clear to end of line, clear to end
**            of screen for full width text screens. Both 6809 & 6309
** 12/03/18 - Implemented StkBlClr routine used for CLS, clear to end of line, clear to end
**            of screen for partial width graphics screens (6809)
** EOU Beta 4 changes (LCB)
** 12/24/18 - Attempted to optimize StkBlClr for 1-3 byte leftovers to be two bytes smaller,
**            and 1/2 (6309) or 2/4 cycles (6809) faster
** 03/11/19 - Implemented Erik Gavriluk's more mathematically accurate composite color
**            conversion table at L0884
** EOU Beta 5 changes (LCB)
** 06/24/19 - Shrunk main entry routine by 2 bytes
**          - Removed unneeded std in L0366 (Window init/6809)
**          - shrunk/sped up L03A9 by removing un-needed std <$B5
** 06/27/19 - 6809 - replaced MUL16 routine (unsigned, which breaks ARC) with original
**            routine (with some mods for NitrOS-9) with signed 16x16=24 bit (sign extended
**            to 32 bit), which fixes ARC bug (from at least 2006). This only affected
**            diagonal clip lines with mixed signs. (LCB)
** 06/28/19 - 6309 - Fixed clear graphics screen (not window) routine, which was getting the
**            byte to clear with from the wrong memory location. (LCB)
** 06/30/19 - 6809 - Optimized scaling routine @ L05E7 for both speed & size (LCB)
** 04/26/20 - Both 6809/6309 - optimize text out routine to test for no hi bit characters
**            *before* calling txt.fixa. Will make code 4 bytes bigger, but speed up text
**            output for non-high bit characters by 10 (6309) or 12 (6809) cycles per char.
** EOU Beta 6 changes (LCB)
** 07/31/20 - Slightly shrunk Nano vertical screen size checks @ L01E0
** 08/06/20 - Optimized mini stack blast copy routine (6809) to 8 bytes/chunk. Speeds up
**             scrolling,etc. especially for full width screen scrolls. Also wide get/put
**             buffers, palette copies (may have to change anyways for VSYNC "snow" issues)
**             and, to a lesser extend, GPLoad). LCB
** 08/24/20 - Hacked a workaround to possible "infinite loop" FFill's with patterns. It now
**            has a sanity check that will exit (usually with a stack overflow error) if this
**            is happening. Only happens with certain patterns, and complex, large fill areas.
**          - Also sped up proportional and 6 pixel wide fonts slightly for both CPU's (up to
**            several percent).
**          - Optimized wide LSet's to be slightly faster for both CPU's as well.
** EOU Beta 6.0.1 changes (LCB)
** 12/29/20 - Fixed bug on Y clipping in PutBlk @ L0D30 - changed BLO to BLS
** 01/07/20 - Slight speed increase for double byte drawing with XOR,AND,OR Logic.
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

* NOTE: Following set has meaning only if 25 text line mode is selected. 28 lines will always use 225
*   resolution, obviously.
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
                    IFNE      H6309
                    lde       #GrfMem/256         Direct page for GrfDrv
                    tfr       e,dp
                    ELSE
                    pshs      a
                    lda       #GrfMem/256
                    tfr       a,dp
                    puls      a
                    ENDC
                    tstb                          initialization?
                    beq       L0080               Yes, go do

grfdrv.1            ldx       #GrfStrt+L0028      Point to function vector table
                    jmp       [b,x]               Execute function

* GrfDrv function code vector table. We should look at changing entry
*   values between CoWin/CoGrf and here to remove the 0'd out ones to
*   save some RAM (12 bytes at current) that are wasted. LCB
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
L0102               clra
                    tfr       a,dp                Set DP to 0 for Wind/CoGrf, which need it there
                    rts                           Return

* Termination routine
L0104               clr       <gr0038             Clear group #
                    clr       <gr007D             Clear buffer block #
                    ldb       <gr0032             Get last block used for GP buffers
                    beq       L0115               If 0, return to system
                    ldx       <gr0033             Get offset into last block we used
                    lbsr      L0A55               Deallocate that buffer
                    bcc       L0104               Keep doing until all are deallocated
                    jmp       >GrfStrt+SysRet     Return to system with error if can't

L0115               jmp       >GrfStrt+L0F78      Exit system

* Setup GrfDrv memory with data from current window table
* Entry: Y=Window table ptr
*        X=Screen table ptr
* Copies following from Screen & Window tables into Grfdrv working mem:
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
* Special entry pt for DWSet,Select,UpdtWin,PutGC
L0129               clr       <gr00A9             Clear MSB of last window tbl ptr grfdrv used (void it basically)
L012B               ldx       Wt.STbl,y           Get screen table ptr
                    pshs      d                   Preserve register
                    ldd       Wt.PVec,y           Get PSet vector for this window
                    IFNE      H6309
                    ldw       Wt.POff,y           Get PSet offset for this window
                    stq       <gr0064             Save Pset vector & PSet offset
                    ELSE
                    std       <gr0064             Save PSet vector
                    ldd       Wt.POff,y           Get PSet offset
                    std       <gr0066             Save PSet offset
                    ENDC
                    ldd       Wt.LVec,y           Get LSet vector
                    std       <gr0068             Save it for this window
                    ldd       Wt.Fore,y           Get Foreground/Background prn
                    std       <gr0061             Save in Grfdrv mem
                    IFNE      H6309
                    ldq       Wt.MaxX,y           Get max. X & Y coords from table
                    stq       <gr006A             Save in Grfdrv mem
                    ELSE
                    ldd       Wt.MaxX,y           Get max X coord from table
                    std       <gr006A             Save in Grfdrv mem
                    ldd       Wt.MaxY,y           Get max Y coord from table
                    std       <gr006C             Save in grfdrv mem
                    std       <gr00B5             Save copy in temp W register holder for 6809
                    ENDC
                    lda       St.BRow,x           Get # bytes per row
                    sta       <gr0063             Save it for this window
                    ldd       St.Sty,x            Get screen type & first block #
                    sta       <Gr.STYMk           Save screen type for this window
* Setup Task 1 MMU for Window: B=Start block # of window
*   As above, may check start block # to see if our 4 blocks are already
*   mapped in (just check block # in B with block # in 1st DAT entry).
*   Since 4 blocks are always mapped in, we know the rest is OK
* This routine always maps 4 blocks in even if it is only a text window
* which only has to map 1 block. Slight opt (2 cycles) done 03/01/93
* Attempted opt: cmpb/beq noneed 03/12/93
MMUOnly             cmpb      <gr0087+9           ($90) Is our screen block set already here?
                    beq       noneed              Yes, don't bother doing it again
                    clra                          Get block type for DAT image
                    std       <gr0087+8           ($8f) Save screen start in my image
                    stb       >$FFAC              Save 1st screen block to MMU
* 30/08/2016 BN removed for NanoMate double height
                    IFEQ      MATCHBOX
                    tst       <$60                Hardware text (only 1 block needed?)
                    bmi       noneed              yes, no need to map in the rest of the blocks
                    ENDC
                    incb                          Get 2nd block
                    std       <gr0087+$A          $91 Save it in my image
                    stb       >$FFAD              Save it to MMU
                    incb                          Get 3rd block
                    std       <gr0087+$C          $93 Save it to my image
                    stb       >$FFAE              Save it to MMU
                    incb                          Get 4th block
                    std       <gr0087+$E          $95 Save it to my image
                    stb       >$FFAF              Save it to MMU
noneed              puls      d,pc                Restore D & return

* Setup the MMU only: called twice from the screen setup routines
* This could be just before MMUOnly, with a 'fcb $8C' just before the PSHS
* to save one more byte, but L0129 is called a lot more often than this is
L0173               pshs      d                   save our registers
                    bra       MMUOnly             go set up the MMU registers, if necessary

* Entry point for Alpha Put
L0175               cmpy      <gr00A9             Same as previous window GRFDRV alpha putted to?
                    lbeq      L150C               Yes, skip map/setup, update cursors
* Normal entry point
L0177               bsr       L0129               Mark Tbl Ptr bad, map in window,set up GRFDRV vars for it
L0179               jmp       >GrfStrt+L150C      Update text & gfx cursors if needed, return from there

* DWSet routine
* ATD: Next 9 lines added to support multiple-height screens.
* We MUST have a screen table in order to do St.ScSiz checks (24, 25, 28).
* GrfDrv is a kernel task (not task switched), so we point X to the possible
* screen table
L019D               ldx       Wt.STbl,y           get screen table ptr
                    bpl       L01A0               hi bit clear, already allocated so skip ahead
                    lbsr      FScrTbl             hi bit SET ($FFFF); find/allocate a new screen table entry
                    bcs       L01C5               exit on error
                    clr       St.ScSiz,x          clear screen size flag: not defined yet
L01A0               bsr       L01C8               Check coordinates and size
                    bcs       L01C5               Error, exit
                    lda       <Gr.STYMk           Get screen type requested
                    cmpa      #$FF                Current screen?
                    bne       L01B0               No, go create a new screen for the window
                    IFNE      MATCHBOX
                    lbsr      L01FB               Make sure window can be fit on current screen
                    ELSE
                    bsr       L01FB               Make sure window can be fit on current screen
                    ENDC
                    bcs       L01C5               Nope, return with error
                    lbsr      L150C               Update Text & Gfx cursors
                    bra       L01B5               Do hardware setup for new window & return to system

* Make window on new screen : have to change so it sets up defaults & colors
* BEFORE it clears the screen
L01B0               lbsr      L0268               Go set up a new screen table (INCLUDES CLR SCRN)
                    bcs       L01C5               If error, return to system with that error
* All window creates come here
L01B5               equ       *
                    IFNE      H6309
                    bsr       L0129               go setup data & MMU for new window
                    ELSE
                    lbsr      L0129
                    ENDC
                    lbsr      L0366               setup default values
                    lda       #$FF                Change back window# link to indicate there is none
                    sta       Wt.BLnk,y
* ATD: same next 3 lines as at L03F4
                    lbsr      L1377               Call CLS (CHR$(12)) routine
                    clrb                          No errors
L01C5               jmp       >GrfStrt+SysRet     return to system

* Check screen coordinates
* Entry: X = screen table pointer
L01C8               lda       <Gr.STYMk           get current window STY marker
                    cmpa      #$FF                current screen?
                    bne       L01D2               no, go on
                    lda       ,x                  Get current screen type (St.Sty)
L01D2               ldu       #GrfStrt+L01F9      Point to width table
                    anda      #$01                only keep resolution bit (0=40 column, 1=80)
                    ldb       Wt.CPX,y            get current X start
                    addb      Wt.SZX,y            calculate size
                    bcs       L01F5               added line: exit if 8-bit overflow
                    cmpb      a,u                 still within range?
                    bhi       L01F5               no, error out
* ATD: These lines added for screen size support
                    lda       St.ScSiz,x          get screen size
                    bne       L01E0               skip ahead if already initialized
                    IFNE      MATCHBOX
* 30/08/2016 BN Changed to support NanoMate 60 line mode
                    lda       #60                 get maximum screen size in A (25 by default)
                    ELSE
* LCB 6809/6309 Change MaxLines in defs to 28 for Beta 6
                    lda       #MaxLines           get maximum screen size in A (25 by default)
                    ENDC
L01E0               ldb       Wt.CPY,y            get current Y start
                    IFNE      H6309
                    cmpr      a,b                 within maximum?
                    ELSE
                    sta       <grScrtch
                    cmpb      <grScrtch           within maximum?
                    ENDC
                    bhi       L01F5               no, error out
                    addb      Wt.SZY,y            calculate size: Now B = maximum size of the window
                    bcs       L01F5               added line: exit if 8-bit overflow
                    IFNE      H6309
                    cmpr      a,b                 still within maximum?
                    ELSE
                    sta       <grScrtch
                    cmpb      <grScrtch           still within maximum?
                    ENDC
                    bhi       L01F5               no, error out
                    cmpa      St.ScSiz,x          do we have the current screen size?
                    beq       L01F3               yes, skip ahead
                    IFNE      MATCHBOX
* 30/08/2016 BN Matchbox has 6 screen sizes to check
* start at lowest
                    cmpb      #24                 do we have a 24-line screen?
                    bne       Nano1               no, skip ahead
                    lda       #24                 24 line screen, if window <= 24 lines
                    bra       L01F1
Nano1               cmpb      #25                 25 line?
                    bne       Nano2
                    lda       #25                 set 25 line screen
                    bra       L01F1
Nano2               cmpb      #48                 48 line?
                    bne       Nano3
                    lda       #48                 48 line screen
                    bra       L01F1
Nano3               cmpb      #50                 50 line?
                    bne       Nano4
                    lda       #50                 48 line screen
                    bra       L01F1
Nano4               cmpb      #56                 56 line?
                    bne       Nano5
                    lda       #56                 56 line screen
                    bra       L01F1
Nano5               cmpb      #60                 60 line?
                    bne       L01F5               no, error out (slight optimization by LCB)
                    lda       #60                 60 line screen
                    ELSE
* LCB - may need tweak for 24/25/28 lines here?
                    cmpb      #24                 do we have a 24-line screen?
                    bhi       L01F1               no, it's 25: skip ahead
                    deca                          25-1=24 line screen, if window <= 24 lines
                    ENDC
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
                    IFNE      H6309
                    lde       #MaxWind            Get maximum number of windows (32)
                    ELSE
                    sta       <grScrtch
                    lda       #MaxWind            Get maximum number of windows (32)
                    sta       <gr00B5             Save in 6809 E "register"
                    lda       <grScrtch
                    ENDC
L0206               equ       *
                    IFNE      H6309
                    cmpr      y,x                 Is this our own window table entry?
                    ELSE
                    sty       <grScrtch           Save current window table ptr
                    cmpx      <grScrtch           Same as one we are currently checking?
                    ENDC
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
                    IFNE      H6309
                    dece                          Done?
                    ELSE
                    dec       <gr00B5             Dec "E register" counter
                    ENDC
                    bne       L0206               No, go back
                    clrb                          Clear errors
L0223               rts                           Return

* Routine to make sure a 'current screen' DWSet window will fit with other
*   windows already on that screen
* Entry: X=Ptr to window table entry that is on same screen as us
*        Y=Ptr to our window table entry
* Exit: Carry clear if it will fit
L0224               equ       *
                    IFNE      H6309
                    tim       #Protect,Wt.BSW,x   Is this window protected?
                    ELSE
                    pshs      b
                    ldb       Wt.BSW,x            Is this window protected?
                    bitb      #Protect
                    puls      b
                    ENDC
                    beq       L0262               No, window can overlap/write wherever it wants, return with no error
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
                    IFNE      H6309
                    cmpr      b,a                 Our X start greater than existing windows right border?
                    ELSE
                    stb       <grScrtch
                    cmpa      <grScrtch           Our X start greater than existing windows right border?
                    ENDC
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
                    IFNE      H6309
                    cmpr      b,a                 Our Y start less than bottom of existing?
                    ELSE
                    stb       <grScrtch
                    cmpa      <grScrtch           Our Y start less than bottom of existing?
                    ENDC
                    blt       L0264               Yes, would overlap, return error
L0262               clrb                          Yes, window will fit legally, return with no error
                    rts

L0264               comb                          Window won't fit with existing windows, exit with
                    ldb       #E$IWDef            Illegal Window Definition error
L0286               rts

* Setup a new screen table
*L0268    bsr   FScrTbl      search for a screen table
*         bcs   L0286        not available, return
* X=Screen tbl ptr, Y=Window tbl ptr
L0268               stx       Wt.STbl,y           save the pointer in window table
                    ldb       <Gr.STYMk           get screen type
                    stb       St.Sty,x            save it to screen table
                    bsr       L029B               go setup screen table (Block & addr #'s)
                    bcs       L0286               couldn't do it, return
                    ldb       <gr005A             get border color
                    stb       St.Brdr,x           save it in screen table
* This line added
                    ldb       Wt.Back,y           Get background color from window table
                    lbsr      L0791               get color mask for bckgrnd color (into B)
                    lbsr      L0335               clear the screen (with bckgrnd color)
                    IFNE      H6309
                    leax      St.Pals,x           Point to palette regs in screen table
                    ldd       >WGlobal+G.DefPal   Get system default palette pointer
                    ldw       #16                 16 palettes to copy
                    tfm       d+,x+               Copy into screen table
                    clrb                          No error & return
                    rts                           Get back scrn tbl ptr & return
                    ELSE
                    pshs      x,y,u               Save regs (D doesn't need preserved)
                    ldd       #16                 16 palettes to copy
                    ldu       >WGlobal+G.DefPal   Get system default palette pointer
                    leay      St.Pals,x           Point to destination of copy
                    lbsr      StkBlCpy            Copy all 16 palettes over
                    clrb                          No error
                    puls      x,y,u,pc            Restore regs & return (don't think I need to update X?)
                    ENDC

* Search for a empty screen table
FScrTbl             ldx       #STblBse+1          Point to screen tables+1 (so no offset to check start block #)
                    ldd       #16*256+St.Siz      A=# table entries, B=entry size
L028D               tst       ,x                  already allocated a block?
                    bne       Yes                 Yes, go to next one
                    leax      -1,x                No, bump pointer back to start of screen table entry
                    clrb                          No error & return
                    rts

Yes                 abx                           move to next one
                    deca                          done?
                    bne       L028D               no, keep looking
                    comb                          Yes, exit with screen table full error
                    ldb       #E$TblFul
                    rts

* Setup screen table
* Entry: Y=Window table ptr (which is already populated)
*        B=screen type (flags still set based on it too)
*        X=screen table ptr
L029B               pshs      y                   preserve window table pointer
                    bpl       L02BB               Screen type is graphics, skip ahead
                    ldy       #STblBse            Hardware text, point to screen tables (we will look to share MMU block)
                    lda       #STblMax            get max # screen tables (16)
* Search screen tables
L02A7               ldb       St.Sty,y            Get screen mode type
                    bpl       L02B3               Graphics, skip to next one
                    ldb       St.SBlk,y           Hardware text, get screen's memory block #
                    beq       L02B3               don't exist, skip to next one
* LCB 6809/6309 - check if St.ScSiz is 28 here: If it is, and St.Sty is $85, skip to ldb <Gr.STYMk
* above L02BB (just get a new MMU block). If x24/x25, or x28 AND St.Sty is $86, do this LBSR
                    lbsr      L0306               search window block for a big enough empty spot
                    bcc       L02DE               found one, go initialize it
L02B3               leay      St.Siz,y            move to next screen table
                    deca                          done?
                    bne       L02A7               no, keep going
* No screen available, get a new screen block
* NOTE: Should be able to change L02F1 loop to use W/CMPE to slightly
*       speed up/shrink
                    ldb       <Gr.STYMk           get STY marker
L02BB               lda       #$FF                preset counter
                    sta       <gr00B3             save in temp
                    ldy       #GrfStrt+L02FA-1    Point to RAM block table
                    andb      #$F                 make it fit table
                    ldb       b,y                 get # blocks needed
                    stb       <gr00B4             save number of blocks in temp2
OVLAP               inc       <gr00B3             update counter in temp
                    ldb       <gr00B4             get number of blocks needed
                    os9       F$AlHRAM            AlHRAM Allocate memory
                    bcs       L02EF               no memory, return error
                    pshs      b                   save starting block #
                    andb      #$3F                modulo 512K
                    pshs      b                   save modulo starting block
                    ldb       <gr00B4             regB now # blocks requested
                    decb                          set to base 0
                    addb      ,s
                    andb      #$3F                final block # modulo 512K
                    cmpb      ,s+                 compare with first block
                    blo       OVLAP               overlapped 512K boundary so ask for more RAM
                    bsr       DeMost              De-allocate any MMU blocks that overflowed 512k bank
                    puls      b                   get starting block #
                    lda       <gr00B3             Get counter
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
                    lda       <Gr.STYMk           get screen type
                    anda      #$F                 make it fit table
                    ldy       #GrfStrt+L0300-1    Point to width table
                    lda       a,y                 get width
                    sta       St.BRow,x           save it to screen table
                    clrb                          clear errors
L02EF               puls      y,pc                return

* Get rid of allocated blocks that overflowed 512K bank; RG.
DeMost              lda       <gr00B3             Get # of blocks
                    beq       L02F9               None, return
                    pshs      a,x
                    leay      6,s                 a,x,rts,b; point to first bad group
DA010               clra
                    ldb       ,y+                 get starting block number
                    tfr       d,x
                    ldb       <gr00B4             number of blocks
                    os9       F$DelRAM            de-allocate the blocks *** IGNORING ERRORS ***
                    dec       ,s                  decrease count
                    bne       DA010
                    puls      a,x,pc

* Move to next text screen in memory block
L02F1               leay      >$0800,y            move Y to next text screen start
                    cmpy      #$A000              set flags for completion check
L02F9               rts                           return

* Memory block requirement table (# of 8K banks)
L02FA               fcb       2                   640 2 color
                    fcb       2                   320 4 color
                    fcb       4                   640 4 color
                    fcb       4                   320 16 color
                    IFNE      MATCHBOX
* 30/08/2016 BN Changed to 2 blocks for Matchbox double height
                    fcb       2                   80 column text
                    fcb       2                   40 column text
                    ELSE
                    fcb       1                   80 column text
                    fcb       1                   40 column text
                    ENDC

* Screen width in bytes table (# bytes/line)
L0300               fcb       80                  640 2 color
                    fcb       80                  320 4 color
                    fcb       160                 640 4 color
                    fcb       160                 320 16 color
                    fcb       160                 80 column
                    fcb       80                  40 column text

* Look for a empty window in a hardware text screen memory block
* Will only get here if: 1) NOT 80x28 hardware text.
* Entry: B=hardware text screens MMU block #
*        A=reserved in calling routine, DO NOT CHANGE
*        Y=screen table entry ptr
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

L031C               lda       <Gr.STYMk           get screen type
                    cmpa      #$86                80 column text?
                    beq       L032F               yes, return
* 6809/6309 NOTE: This calc only works for x24 and x25 screens. x28 (actually need x29
*   to clear last line of pixels on x225 screen) will take $910 bytes for 40 column, and
*   80 column will take $1220 bytes. So x28 will double the leax value ($1000 instead of $800)
* likely use St.ScSiz to do a second leax $0800,x. 80x28 will require a full block period.
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
**** BEGINNING OF NEW CODE TO TEST (OR CRASH) ****
L0335               pshs      x,y,u               save regs
                    lda       #C$SPAC             get a space code
                    std       <gr0097             init screen clear value to color/attribute
                    ldb       St.Sty,x            Get screen type
                    ldu       St.LStrt,x          get screen start address
                    andb      #%00001111          Strip high nibble (gfx vs. txt)
                    lslb                          adjust for 2 bytes entry
* LCB 6809/6309 - lda St.ScSiz,x here.
                    ldx       #GrfStrt+L035A-2    Point to screen length table
                    cmpb      #8                  text mode (types 5 and up)?
                    bls       ClrGfx              No, do graphics clear
* LCB 6809/6309 - if A=28, then addb #4 (point to 2 new entries for 80 col/29 line & 40 col/29 line)
                    ldx       b,x                 Get size to lear
                    ldd       <gr0097             Get char/attribute byte pair to clear with
                    lbsr      StkBlCl2            Clear screen (Mini stack blast - almost same speed either CPU)
                    puls      x,y,u,pc            Restore regs & return

* Screen length table - once we get mini-stackblast, 6809 version for sure (and hardware text
* for both) should be in 4 byte counts, or 1K blocks & leftover 4 byte blocks.
* NOTE: we will clear 29 lines for hardware text lines? Or use supplemental 2 entries
L035A               fdb       80*MaxLines*8       640 2 color   (gfx are 1 byte counts)
                    fdb       80*MaxLines*8       320 4 color
                    fdb       160*MaxLines*8      640 4 color
                    fdb       160*MaxLines*8      320 16 color
                    fdb       160*MaxLines        80 column text  (2 bytes/char because of attribute byte)
                    fdb       80*MaxLines         40 column text  (2 bytes/char because of attribute byte)
* Add in for x28 hardware text support (clears 29th line since Row 225 still shows up)
*         fdb   160*29      80 column text  (2 bytes/char because of attribute byte)
*         fdb   80*29       40 column text  (2 bytes/char because of attribute byte)

* Clear a graphics screen. On 32,000 byte screen, TFM is <150 cycles faster than pshu, but
* takes less room to set up.
* Entry: X=ptr to screen table
*        B=offset into table for size of current screen type (in bytes)
*        U=ptr to screen start
*        <$98 = byte value to clear screen with
ClrGfx
                    IFNE      H6309
                    ldw       b,x                 (7) Get size of gfx screen to clear
* was $1098
                    ldx       #GrfMem+gr0098      (3) Point to clear code char
                    tfm       x,u+                (96006 worst case) Clear screen
                    puls      u,x,y,pc            Restore regs & return
                    ELSE
                    ldx       b,x                 (6) Get size of screen to clear (in bytes)
                    ldb       <gr0098             (3) Get value to clear with
                    lbsr      StkBlClr            (7) Do mini stack blast clear (4 byte multiple ONLY version)
                    puls      x,y,u,pc            Restore regs & return
                    ENDC

**** END OF NEW TEST CODE ****

* Part of window init routine
* Entry: Y=Window table ptr
*        X=Screen table ptr
L0366               ldd       #(TChr!Scale!Protect)*256 Transparency off & protect/Scale on
                    stb       Wt.GBlk,y           Graphics cursor memory block #0
                    std       Wt.BSW,y            Character switch defaults & LSet type set to 0
                    stb       Wt.PBlk,y           PSet block #0
                    IFNE      H6309
* Assembler can't do $10000x#
*         ldq   #(GrfStrt+L1FA9)*65536+(GrfStrt+L1F9E) Normal LSET/PSET vector
                    fcb       $cd
                    fdb       GrfStrt+L1FA9,GrfStrt+L1F9E
                    stq       Wt.LVec,y           Save vectors
                    ELSE
                    ldd       #GrfStrt+L1F9E      Normal PSet vector
                    std       Wt.PVec,y
                    ldd       #GrfStrt+L1FA9      Normal LSet vector
                    std       Wt.LVec,y
                    ENDC
                    ldb       Wt.Fore,y           Get foreground palette #
                    lbsr      L074C               Get bit mask for this color
                    stb       Wt.Fore,y           Store new foreground bit mask
                    stb       <gr0061             Store new foreground bit mask in GRFDRV's global
                    ldb       Wt.Back,y           Get background palette #
                    lbsr      L074C               Get bit mask for this color
                    stb       Wt.Back,y           Store new background bit mask
                    stb       <gr0062             Store background bit mask in GRFDRV's global mem
                    lbsr      L079B               Set default attributes to new colors
                    ldd       St.LStrt,x          Get screen logical start
                    bsr       L03A9               Go copy scrn address/X&Y start to defaults area
                    clr       Wt.FBlk,y           Font memory block to 0 (no font yet)
* get group & buffer for font
                    ldd       #Grp.Fnt*256+Fnt.S8x8 ($C801)  Default group/buffer number for font
                    std       <gr0057             Save working copies
                    lbsr      L0643               Go set up for font
                    clrb                          No error and return
                    rts

* Move screen start address, X & Y coordinate starts of screen to 'default'
*   areas.  The first set is for what the window is currently at (CWArea
*   changes, for example), and the second set is the maximums of the window
*   when it was initialized, and thusly the maximums that can be used until
*   it is DWEnd'ed and DWSet'ed again.
* Entry: x= Screen table ptr
*        y= Window table ptr
*        d= Screen logical start address
L03A9               lbsr      L0581               Go set up window/character sizes
                    IFNE      H6309
                    ldq       Wt.LStrt,y          Get screen start addr. & X/Y coord start
                    stq       Wt.LStDf,y          Save as 'window init' values (defaults for window initialized)
                    ELSE
                    ldd       Wt.LStrt,y          Get screen start addr
                    std       Wt.LStDf,y          Save as window default screen start address
                    ldd       Wt.CPX,y            Get current X/Y coord start
                    std       Wt.DfCPX,y          Save as window default X/Y coord start
                    ENDC
                    ldd       Wt.SZX,y            Get current X/Y size (current CWArea)
                    std       Wt.DfSZX,y          Save as window default X/Y current size (current CWArea)
                    rts

* DWEnd entry point : NOTE: the LDD #$FFFF was a LDD #$FFFE from Kevin
*   Darling's 'christmas' patch. It is supposed to have something to do
*   with INIZ'ed but not screen allocated windows. Or maybe something with
*   overlapping windows?
L03CB               lbsr      L0177               Go map in window
                    ldd       #$FFFF              Set screen table ptr to indicate not active
                    std       Wt.STbl,y
* This routine checks to see if we are the last window on the current screen
* Carry set if there is there is another window on our screen
* (Originally a subroutine...moved to save 2 bytes & 5 cycles
* Entry: Y=window table ptr
*        X=Screen table ptr?
L03FF               pshs      y,x                 Preserve window table & screen table ptrs
                    leay      ,x                  Move for ABX
                    ldx       #WinBase            Point to window table entries
                    ldd       #MaxWind*256+Wt.Siz Get # entries & size
L0407               cmpy      Wt.STbl,x           Keep looking until we find entry on our screen
                    beq       L0414               Found one, error
                    abx                           Bump to next one
                    deca                          Keep doing until all 32 window entries are done
                    bne       L0407
                    clrb                          We were only window on screen, no error
                    fcb       $21                 BRN opcode=skip one byte, same speed 1 byte less
L0414               comb                          Set flag (there is another window on screen)
L0415               puls      y,x                 Restore window table & screen table ptrs
                    bcs       L03F4               Not only window, CLS our area before we exit
                    bsr       L0417               Only one, deallocate mem for screen if possible
                    cmpy      <gr002E             Our window table ptr same as current ptr?
* Note: The following line was causing our screen to clear which wrote over
* the $FF value we wrote at the beginning to flag the screen memory as free.
* This caused a memory leak in certain situations, like:
* iniz w1 w4;echo>/w1;echo>/w4;deiniz w4 w1
*         bne   L03F4          No, Clear our screen & exit
                    bne       L03F5               No, just exit
                    IFNE      H6309
                    clrd                          Yes, clear current window & screen table ptrs
                    clrw
                    stq       <gr002E
                    ELSE
                    clra                          Yes, clear current window & screen table ptrs
                    clrb
                    std       <gr002E
                    std       <gr0030
                    ENDC
* Clear palettes to black
                    sta       >BordReg            ($ff9a) Border
                    IFNE      H6309
                    stq       >PalAdr             ($ffb0)  And all palette regs
                    stq       >PalAdr+4           ($ffb4)
                    stq       >PalAdr+8           ($ffb8)
                    stq       >PalAdr+12          ($ffbc)
                    ELSE
* NEW CODE - 1 byte longer, but faster
                    pshs      x,y,u               save regs
                    tfr       d,x                 X=0 (setting palettes to 0)
                    ldu       #PalAdr+16          ($ffb0+16) Point to end of palettes+1
                    ldd       #4                  Doing 4 sets of 4 byte clears (A=1 to get out of loop)
                    lbsr      FourBClr            Clear all 16 to black
                    puls      x,y,u               2 restore regs=17 bytes
                    ENDC
L03FC               jmp       >GrfStrt+SysRet     Return to system

* CLS our old screen with background color & leave if we weren't only window
*   on the screen (for Multi-Vue, for example)
L03F4               ldb       St.Back,x           Get background palette reg from screen table
                    stb       <gr0062             Put into background RGB Data
                    lbsr      L1377               CLS the area we were in
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
                    bsr       L049D               Check legitimacy of overlay coords & size
                    bcs       L049A               Illegal, exit with Illegal Coord error
                    ldd       Wt.STbl,x           Get root window's screen table ptr
                    std       Wt.STbl,y           Dupe into overlay window's screen table ptr
                    bsr       L04CC               Set up overlay window table from root table
                    ldb       <gr0059             Save switch on?
                    beq       L0490               No, don't save original area (or clear it)
                    lbsr      L0516               Calculate sizes
                    bcs       L049A               error, return to system
                    ldb       Wt.Back,y           Get background color
                    stb       <gr0062             Make current background color
                    lbsr      L1377               CLS the overlay window area
L0490               puls      x                   Get parent's window table ptr
                    cmpx      <gr002E             Is it the current window?
                    bne       L0499               No, exit without error
                    sty       <gr002E             Make overlay window the current window
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
L04BA               leax      ,y                  Move current window ptr to X
L04BC               ldb       Wt.BLnk,x           Get back window # link
                    bmi       L04CB               If overlay window itself, skip ahead
                    ldx       #WinBase            Point to start of window tables
                    lda       #Wt.Siz             Size of each entry
                    mul                           Calculate address of back window table entry
                    IFNE      H6309
                    addr      d,x
                    ELSE
                    leax      d,x
                    ENDC
                    bra       L04BC               Keep looking back until device window is found

* Set up new overlay window table based on root window information
* Entry: X=root window ptr, Y=overlay window ptr
L04CC               clr       Wt.OBlk,y           Overlay memory block #=0
                    lbsr      L079B               Go make default attribute byte from FG/BG colors
                    lda       Wt.Attr,x           Get the default attribute byte from root
                    anda      #Blink+Under        Mask out all but Blink & Underline
                    ora       Wt.Attr,y           Merge with overlay window's colors
                    sta       Wt.Attr,y           Save new attribute byte
                    IFNE      H6309
                    ldq       Wt.BSW,x            Copy BSW, LSet Type, Font Mem Blk#, MSB of Font offset to overlay window
                    stq       Wt.BSW,y
                    ldq       Wt.LVec,x           Copy LSet/PSet vectors to overlay window
                    stq       Wt.LVec,y
                    ELSE
                    ldd       Wt.BSW,x            Copy BSW character switches & LSet type to overlay window
                    std       Wt.BSW,y
                    ldd       Wt.FBlk,x           Copy font mem block # & MSB of font offset to overlay window
                    std       Wt.FBlk,y
                    ldd       Wt.LVec,x           Copy LSet vector to overlay window
                    std       Wt.LVec,y
                    ldd       Wt.PVec,x           Copy PSet vector to overlay window
                    std       Wt.PVec,y
                    ENDC
                    ldd       Wt.FOff+1,x         Copy LSB of font offset & PSet mem block # to overlay window
                    std       Wt.FOff+1,y
                    ldb       Wt.GBlk,x           Copy Graphics cursor mem block # to overlay window
                    stb       Wt.GBlk,y
                    ldd       Wt.GOff,x           Copy Graphics cursor offset to overlay window
                    std       Wt.GOff,y
                    ldb       Wt.Fore,y           Get foreground palette
                    lbsr      L074C               Get bit mask if gfx window
                    stb       Wt.Fore,y           Store foreground color or mask
                    ldb       Wt.Back,y           Get background palette
                    lbsr      L074C               Get bit mask if gfx window
                    stb       Wt.Back,y           Store background color or mask
                    ldd       Wt.LStrt,x          Get screen logical start address
                    jmp       >GrfStrt+L03A9      Set up rest of window table & return

* Entry: X=root window table ptr
*        Y=Overlay window table ptr
* Exit:  <$4F=X screen size (chars if hware text, pixels if Gfx)
*        <$51=Y screen size (char lines if hware text, pixels if Gfx)
L0516               pshs      x                   Preserve root window table ptr
                    bsr       xy.intoq            get X,Y size for text/gfx into Q
                    IFNE      H6309
                    stq       <gr004F             Save X and Y screen size (chars or pixels)
                    ELSE
                    std       <gr004F             Save X screen size
                    ldd       <gr00B5             Get Y screen size from "W Register" copy
                    std       <gr0051             Save Y screen size
                    lda       <gr004F             Restore A
                    ENDC
                    clrb
                    std       <gr0047             Set current "working" X coordinate to 0
                    lbsr      L0BEA               Calculate # bytes wide overlay is
                    puls      pc,x                Restore root window table ptr & return

* OWEnd entry point
L053A               lbsr      L0177               Map in window & set up Grfdrv mem from it
                    cmpy      <gr002E             Is this the current interactive window?
                    bne       L054A               No, skip ahead
                    lbsr      L045A               Yes, get parent window tbl ptr into Y
                    sty       <gr002E             Make parent window the new interactive window
                    puls      y                   Get overlay window tbl ptr back
L054A               ldb       Wt.OBlk,y           Get MMU block # of overlay window
                    beq       L0562               If none, save switch was off, so skip ahead
                    lbsr      L017C               Map in get/put block
                    stb       <gr007D             Save GP buffer block #
                    ldd       Wt.OOff,y           Get ptr to buffer start in block
                    std       <gr007E             Save gp buffer start offset within block
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
                    leax      ,y                  Move window tbl ptr to X
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
                    IFNE      H6309
                    tfr       d,w                 move Y-size into W
                    ELSE
                    std       <gr00B5             Save Y size into "W register" 6809
                    ENDC
                    ldb       Wt.SZX,y            Get current X size of overlay window into D
                    tst       <Gr.STYMk           Test screen type
                    bmi       L0530               If hardware text, exit without doing more shifts
                    IFNE      H6309
                    rolw                          multiply by 8 for # pixels down
                    rolw
                    rolw                          E=$00 and CC.C=0 from above,so this is really ASLW
                    lslb                          Multiply by 8 for # pixels across
                    lsld                          A=$00 from CLRA, above.  Max 80
                    lsld
                    ELSE
                    lsl       <gr00B6             multiply "W register" by 8 for # pixels down
                    rol       <gr00B5
                    lsl       <gr00B6
                    rol       <gr00B5
                    lsl       <gr00B6
                    rol       <gr00B5
                    lslb                          multiply X size by 8 for # of pixels across
                    lslb                          A=$00 from CLRA above. Max 80
                    rola
                    lslb
                    rola
                    ENDC
L0530               rts

* Set up window/character sizes
* Entry :x= Screen table ptr
*        y= Window table ptr
*        d= Screen logical start address
L0581               pshs      d,x                 Preserve Screen start & screen tbl ptr
                    ldb       <Gr.STYMk           get screen type
                    andb      #$0F                keep only first 4 bits (mask out hardware text mode bit flag)
                    ldx       #GrfStrt+L05E1-1    Point to # bytes/text char table
                    ldb       b,x                 get number bytes/char
                    stb       Wt.CWTmp,y          Preserve # bytes/char
                    lda       Wt.SZX,y            get current X size (of window)
                    mul                           Calculate # bytes wide window is
                    stb       Wt.XBCnt,y          Preserve #bytes wide window is
                    clra                          #bytes per row MSB to 0
                    ldb       <gr0063             Get # bytes per row on screen
                    tst       <Gr.STYMk           Text or graphics screen?
                    bmi       L05A1               If text, we already have # bytes per row
                    IFNE      H6309
                    lsld                          If graphics, multiply x 8 since each text row
                    lsld                          is 8 sets of lines
                    lsld
                    ELSE
                    lslb                          If graphics, multiply x 8 since each text row
                    rola                          is 8 sets of lines
                    lslb
                    rola
                    lslb
                    rola
                    ENDC
L05A1               std       Wt.BRow,y           Preserve # bytes/text row (8 lines if gfx)
                    clra
                    ldb       Wt.CPY,y            D=Upper left Y coord of window
                    IFNE      H6309
                    muld      Wt.BRow,y           Calculate Y coordinate start
                    stw       <gr0097             save Y offset into temp
                    ELSE
                    pshs      x,y,u
                    ldx       Wt.BRow,y           Calculate Y coordinate start
                    lbsr      MUL16
                    stu       <gr0097             Save Y offset into temp
                    puls      x,y,u
                    ENDC
                    lda       Wt.CPX,y            get X coordinate start
                    ldb       Wt.CWTmp,y          get # bytes per text character
                    mul                           calculate where X starts
                    addd      ,s++                add it to screen start address
                    addd      <gr0097             add in Y offset
                    std       Wt.LStrt,y          get screen logical start
                    lbsr      L11E1               home cursor
                    ldb       <Gr.STYMk           get screen type
                    bmi       L05C0               hardware text, don't need scale factor
                    bsr       L05E7               calculate scaling factor
* Calculate window X size in either pixels or characters
* Q is D:W  D=X size, W=Y size
L05C0               bsr       xy.intoq            get X and Y for text/gfx into Q
                    IFNE      H6309
                    decw                          adjust Y to start at 0
                    decd      adjust              X to start at 0
                    stq       Wt.MaxX,y           save maximum X co-ordinate
                    puls      x,pc                restore & return
                    ELSE
                    subd      #1
                    std       Wt.MaxX,y           Save MaxX as base 0
                    pshs      d                   Save on stack for exit
                    ldd       <gr00B5             Get MaxY from "W register" and make base 0
                    subd      #1
                    std       <gr00B5             Save back in "W register"
                    std       Wt.MaxX+2,y         And as maximum X coord
                    puls      d,x,pc
                    ENDC

* # bytes for each 8 pixel wide text char
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
* the least significant byte). The resulting 2 byte number is the scaled
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
                    IFNE      H6309
L05E7               clra                          D=# of columns
                    ldb       Wt.SZX,y
                    muld      <XSclMSB,pc         Multiply by X scaling factor
                    cmpf      #$cd                Need to round it up if >=.8?
                    blo       saveXscl            No, save result
                    ince                          Round it up
saveXscl            ste       Wt.SXFct,y          Save X scaling multiplier
                    ldb       Wt.SZY,y            D=# of rows (A=0 from MULD already)
                    cmpb      #25                 Is it the full 25 lines?
                    blo       useold              No, use old scaling factor for compatibility
                    muld      <YScl200,pc         Multiply by 200 line Y scaling factor
                    bra       chkrnd

useold              muld      <YScl192,pc         Multiply by 192 line Y scaling factor
chkrnd              cmpf      #$cd                Need to round it up if >=.8?
                    blo       saveYscl            No, save result
                    ince                          Round it up
saveYscl            ste       Wt.SYFct,y          Save Y scaling multiplier
                    rts
                    ELSE
L05E7               clra                          D=# of columns
                    ldb       Wt.SZX,y            Get width of window
                    pshs      x,y,u               Save regs
                    ldx       <XSclMSB,pc         Get X scaling factor
                    lbsr      MUL16               Y:U=D*X (signed)
                    tfr       u,d                 and move to D
                    cmpb      #$cd                Need to round it up if >=/8?
                    puls      x,y,u               Restore index regs
                    blo       saveXscl            No rounding needed, save result
                    inca                          Yes, round up
saveXscl            sta       Wt.SXFct,y          Save as X scaling factor
                    clra
                    ldb       Wt.SZY,y            D=# of rows (A=0 from MULD already)
                    cmpb      #25                 Is it the full 25 lines?
                    pshs      x,y,u               Save regs
                    blo       useold              No, use old scaling factor for compatibility
                    ldx       <YScl200,pc         Use 25/200 scaling factor
DoYScl              lbsr      MUL16               Y:U=D*X (signed)
                    tfr       u,d                 Copy LSW to D
                    puls      x,y,u               Get index regs back
chkrnd              cmpb      #$cd                Need to round it up if >=.8?
                    blo       saveYscl            No, save result
                    inca                          Yes, round up scaling factor
saveYscl            sta       Wt.SYFct,y          Save Y scaling factor into window table & return
                    rts

useold              ldx       <YScl192,pc         Use 25/200 scaling factor
                    bra       DoYScl
                    ENDC

* PSet entry point - Change <$16,y vector to proper pattern drawing
L0611               ldb       <gr0057             get Pset group mem block #
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

L0643               ldb       <gr0057             get block number for font buffer
                    bne       L064A               If there is one, go set it up
                    stb       Wt.FBlk,y           Set font memory block # to 0 (no fonts)
                    rts

L064A               lbsr      L1002               Go set the font ('.' font default if none)
                    lbsr      L0930               Search buffers for proper one
                    bcs       L0684               Error, skip ahead
                    pshs      x,b                 Preserve graphics buffer table ptr & b
* 6809/6309 - Since we already have proportional fonts, we should be able to make this
*  more variable in width, using existing routines. Y is easy to implement, except do we
*  still force windows to be even sets of 8 high for other calcs (like window sizes for overlays)?
* LCB note: I would say yes for now - force whatever font size picked to fit within x8 pixel window
*  area width/height. This would work like 6 pixel width fonts work like now (windows still defined
*  by 8 pixel wide character "widths". We should still have sanity checks, though.
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
                    cmpd      <gr006E             Get X pixel count
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
                    ldb       <gr0057             Get group # for graphics cursor
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
                    stb       <Gr.STYMk           Save as current screen type
                    ldb       <gr005A             Get palette number from user
                    bsr       L074C               Go get mask for it
                    stb       Wt.Fore,y           Save foreground palette #
                    IFNE      H6309
                    tim       #Invers,Wt.BSW,y    Inverse on?
                    ELSE
                    ldb       Wt.BSW,y            regB does not need to be preserved
                    bitb      #Invers             Inverse on?
                    ENDC
                    bne       L0738               Yes, go process for that
L0719               ldb       <gr005A             get palette register number
                    lslb                          Move into foreground of attribute byte
                    lslb
                    lslb
                    andb      #%00111000          $38  Clear out blink/underline & background
                    lda       Wt.Attr,y           Get default attributes
                    anda      #%11000111          $C7  Mask out foreground
                    bra       L0742               OR in new foreground

* BColor entry point
L0726               ldb       [Wt.STbl,y]         Get screen type from screen table
                    stb       <Gr.STYMk           Save as current screen type
                    ldb       <gr005A             get palette register #
                    bsr       L074C
                    stb       Wt.Back,y           save background into window table
                    IFNE      H6309
                    tim       #Invers,Wt.BSW,y    Inverse on?
                    ELSE
                    ldb       Wt.BSW,y            regB does not need to be preserved
                    bitb      #Invers             Inverse on?
                    ENDC
                    bne       L0719               Yes, do masking to switch fore/bck ground colors

L0738               ldb       <gr005A             Get palette register #
                    andb      #$07                Force to 0-7 only
                    lda       Wt.Attr,y           Get default attributes
                    anda      #$F8                Mask out background
L0742               equ       *
                    IFNE      H6309
                    orr       b,a                 Merge the color into attribute byte
                    ELSE
                    stb       <grScrtch
                    ora       <grScrtch           Merge the color into attribute byte
                    ENDC
                    sta       Wt.Attr,y           Store new default attribute
L0748               clr       <gr00A9             No error, Clear out MSB of last window tbl ptr Grfdrv used (invalidate it)
                    jmp       >GrfStrt+SysRet

* Convert color to allowable ones for screen type
* NOTE: see if we can swap a/b roles to allow ABX instead of LEAX A,X
* Entry: B=color # to get mask for
* Exit:  B=full byte mask for color (based on screen type)
L074C               pshs      x,a                 Preserve screen table ptr & a
                    lda       <Gr.STYMk           get screen type
                    bmi       L075D               hardware text or same screen, return
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
L0763               fcb       %00000001           single bit per pixel
                    fcb       $00,$ff             Full byte color masks (2 colors)

* Color masks for 640 and 320 4 color
L0766               fcb       %00000011           2 bits per pixel
                    fcb       $00,$55,$aa,$ff     Full byte color masks (4 colors)

* Color masks for 320 16 color
L076B               fcb       %00001111           4 bits per pixel
                    fcb       $00,$11,$22,$33,$44,$55,$66,$77 Full byte color masks (16 colors)
                    fcb       $88,$99,$aa,$bb,$cc,$dd,$ee,$ff

* Get color mask
* Entry: B=color code
* Exit:  B=color mask
L0791               tst       ,x                  Check screen type?
                    bpl       L074C               If graphics, mask out values scrn type can't use
                    andb      #$07                Just least significant 3 bits
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
                    IFNE      H6309
                    orr       a,b                 Merge foreground & background
                    ELSE
                    sta       <grScrtch
                    orb       <grScrtch           Merge foreground & background
                    ENDC
                    stb       Wt.Attr,y           Set new default attributes
                    rts

* Select entry point
* Entry: Y=Newly selected window pointer
* ATD: !! Save DP, too.
L07D7               pshs      y                   save Window table ptr we will be going to
                    ldy       <gr002E             get window table ptr we are going from
                    beq       L07E1               If none, skip ahead
                    lbsr      L0177               set variables/MMU & update cursors on old window
L07E1               ldb       >WGlobal+G.CurTik   Reload counter for # ticks/cursor updates
                    stb       >WGlobal+G.CntTik
                    ldy       ,s                  get 'to' window table pointer
                    lbsr      L0129               Map in window & setup grfdrv mem for new window
                    sty       <gr002E             save it as current window entry ptr
                    stx       <gr0030             save current screen table ptr
                    leay      ,x                  Move to Y Reg
L08DB               ldx       #$FF90              point to GIME registers
*ATD: Do a TFR 0,DP: larger but faster?
                    ldu       #$0090              point to shadow RAM for GIME hardware
                    IFNE      H6309
                    aim       #$7f,,u             remove Coco 1/2 compatibility bit: set from CoVDG
                    ldb       ,u                  get new value
                    ELSE
                    ldb       ,u                  remove Coco 1/2 compatibility bit: set from CoVDG
                    andb      #$7f
                    stb       ,u
                    ENDC
                    stb       ,x                  save it to GIME
* Calculate extended screen address for 1 or 2 Meg upgrade
* Entry: X=$FF90 (start of GIME regs)
*        Y=Screen table ptr
*        U=Ptr to GIME shadow registers ($0090/D.HINIT)
* Exits: With GIME (and shadow regs) pointing to proper GIME screen address &
*        proper 512k bank (via Disto's DAT) that screen is in (0-3 for up to
*        2 Meg of RAM)
                    clra
                    sta       $0F,x               Set horizontal scroll to 0
                    sta       $0F,u               And set it's shadow
                    ldb       St.SBlk,y           Get block # of screen
                    IFNE      H6309
                    lsld                          Multiply by 4 (to shift which 512k video bank into A)
                    lsld
                    ELSE
                    lslb                          Multiply by 4 (to shift which 512k video bank into A)
                    rola
                    lslb
                    rola
                    ENDC
                    stb       <gr0082             Remainder is V.OFF1 of this block. RG.
                    clrb                          A=512k Video bank # (0-3), B=vertical scroll offset (0)
                    std       $0B,x               Save which of up to 4 512K banks video is in (Disto DAT video extension register)
                    std       $0B,u               & vertical scroll offest. Also save to it's shadow.
                    ldd       St.LStrt,y          Get screen logical start
                    suba      #$80                Subtract $80 from MSB of that address
                    IFNE      H6309
                    lsrd                          Divide result by 8
                    lsrd
                    lsrd
                    ELSE
                    lsra                          Divide result by 8
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    ENDC
                    adda      <gr0082             Add to MSB of 24 bit extended screen address
                    std       $0D,x               Store result into GIME's vertical offset register
                    std       $0D,u               and it's shadow
                    ldx       #GrfStrt+L086A.24-2 GIME setup table for 24-line screens
                    ldb       St.ScSiz,y          get screen size into B
                    cmpb      #24                 24-line screens?
                    beq       L0840               if so: skip ahead; else get 25-line pointer
                    ldx       #GrfStrt+L086A.25-2 GIME setup table for 25-line screens
* LCB 6809/6309 - need to add 28 line support for hardware text screens ONLY
                    IFNE      MATCHBOX
* 30/08/2016 BN Nanomate extra text modes
                    cmpb      #25
                    beq       L0840
                    ldx       #GrfStrt+L086A.48-2 GIME setup table for 48-line screens
                    cmpb      #48
                    beq       L0840
                    ldx       #GrfStrt+L086A.50-2 GIME setup table for 50-line screens
                    cmpb      #50
                    beq       L0840
                    ldx       #GrfStrt+L086A.60-2 GIME setup table for 60-line screens
                    cmpb      #60
                    beq       L0840
                    ldx       #GrfStrt+L086A.56-2 GIME setup table for 56-line screens
                    ENDC
L0840               ldb       ,y                  get screen type we need (St.Sty)
                    andb      #$0F                keep only last 4 bits
                    lslb                          multiply by 2 (2 bytes per entry)
                    abx                           find entry
                    lda       $08,u               get current GIME shadow video mode register
                    anda      #%01111000          $78 keep only non video bits (comp phase, monochrome, 50/60Hz vido flag)
                    ora       ,x                  merge in new video mode
                    ldb       1,x                 get Video resolution
* ATD: for new 'garbage-less' CLRing, and new clock, save these values
* at $08,u, and set $06,u: The clock will clear the flag at $0096, and update
* the GIME video hardware at the _start_ of the IRQ process.
                    std       $08,u               save new GIME shadow registers (Video mode/video resolution)
                    std       >$FF98              save them to GIME
                    IFNE      MATCHBOX
* 30/08/2016 BN Mod for NanoMate 60 row
                    ldb       St.ScSiz,y
                    cmpb      #25
                    ble       no60
* enable double height on Matchbox for modes above 25 lines
                    ldb       >$FF10
                    orb       #$20
                    stb       >$FF10
                    bra       no61

* disable double height on Nanomate
no60                ldb       >$FF10
                    andb      #$df
                    stb       >$FF10
no61
                    ENDC
* Set up colors on GIME for newly selected window
                    ldb       St.Brdr,y           Get current border palette #
                    leay      St.Pals,y           Point to palette register data in scrn tbl
                    IFNE      H6309
                    ldf       >WGlobal+G.MonTyp   Get monitor type in F for faster translates
                    ENDC
                    ldb       b,y                 Get border color
                    stb       $0A,u               Save new border color to GIME shadow
                    IFNE      H6309
                    tstf                          Need to convert color?
                    ELSE
                    tst       >WGlobal+G.MonTyp   Need to convert color?
                    ENDC
                    bne       DoBord              Nope, use current border color
                    ldx       #GrfStrt+L0884      Point to translation table
                    ldb       b,x                 Get composite version
DoBord              stb       >$ff9a              Save it on GIME Border register
                    ldu       #$FFB0              U=GIME palette reg. ptr
                    IFNE      H6309
                    tstf                          Rest of colors need translation?
                    ELSE
                    tst       >WGlobal+G.MonTyp   Rest of colors need translation?
                    ENDC
                    bne       FstRGB              No, use TFM
* Composite translate here
* LCB: MAY NEED HSYNC TRICK HERE (SEE NITROS9 1.15 VDG SAMPLE CODE), BUT THAT MEANS THAT WE HAVE
*  TO PRE-TRANSLATE THE COMPOSITE VERSIONS (MAYBE ON THE STACK?), AND THEN DO 3 STACK BLASTS WITH
*  HSYNC.
                    lda       #$10                A=# of colors
L0851               ldb       ,y+                 Get RGB color
                    ldb       b,x                 Get composite version
                    stb       ,u+                 Save it to GIME
                    deca                          Done?
                    bhi       L0851               No, keep going
                    bra       DnePaltt            Done, go do Gfx cursor

* SEE ABOVE - IF WE BUILD STACK COPY (LEAS -16,S, THEN POINT U TO S).
FstRGB              equ       *
                    IFNE      H6309
                    ldw       #$0010              Palette register ptr & # palette regs
                    tfm       y+,u+               Move them onto GIME
                    ELSE
                    pshs      x,u                 Save regs (don't bother with Y since we are restoring it after anyways)
                    exg       y,u                 Swap dest/src ptr for subroutine
                    ldd       #16                 16 palettes to copy
                    lbsr      StkBlCpy            Copy palettes
                    puls      x,u                 Restore regs
                    ENDC

* ATD: PULS DP, too
DnePaltt            puls      y                   Restore window table ptr we are going to
                    IFNE      H6309
                    ldq       <gr003D             Get last coords that Gfx cursor was ON at
                    stq       <gr005B             Save as current coords of Gfx cursor
                    ELSE
                    ldd       <gr003F             Get last X coord that Gfx cursor was ON at
                    std       <gr005D             Save as current X coord of Gfx cursor
* LCB 6809 - this should not be NOT needed, since L153B promptly destroys Q
                    std       <gr00B5             Save Reg W copy (likely not needed)
                    ldd       <gr003D             Get last Y coord that Gfx cursor was ON at
                    std       <gr005B             Save as current Y coord of Gfx cursor
                    ENDC
                    lbsr      L153B               Update 'last gfx cursor on' position to new one
                    jmp       >GrfStrt+L0F78      return to system: no errors

* GIME graphics register values
*     1st byte goes to $ff98
*     2nd byte goes to $ff99
* LCB NOTE: Should change to autosense whether we are in RGB/Mono mode, or composite/tv
* mode. 25 line hardware text screens would use 225 scanlines on RGB/Mono, but only 200
* on composite TV. 28 line mode will always use 225 scanlines, of course
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

                    IFNE      MATCHBOX
L086A.48            fdb       $8014               640x192 2 color
                    fdb       $8015               320x192 4 color
                    fdb       $801D               640x192 4 color
                    fdb       $801E               320x192 16 color
                    fdb       $0315               80x48, 192 line screen
                    fdb       $0305               40x48, 192 line screen

L086A.50            fdb       $8034               640x192 2 color
                    fdb       $8035               320x192 4 color
                    fdb       $803D               640x192 4 color
                    fdb       $803E               320x192 16 color
                    fdb       $033D               80x50, 200 line screen
                    fdb       $032D               40x50, 200 line screen

L086A.60            fdb       $8054               640x192 2 color
                    fdb       $8055               320x192 4 color
                    fdb       $805D               640x192 4 color
                    fdb       $804E               320x192 16 color
                    fdb       $035D               80x24, 192 line screen
                    fdb       $034D               40x24, 192 line screen

L086A.56            fdb       $8074               640x192 2 color
                    fdb       $8075               320x192 4 color
                    fdb       $807D               640x192 4 color
                    fdb       $806E               320x192 16 color
                    fdb       $037D               80x24, 192 line screen
                    fdb       $036D               40x24, 192 line screen
                    ENDC

* New table based on Erik Gavriluk's conversion chart. Will experiment with, but
*  Nick Marentes swears it is closer than the original table
L0884               fcb       $00,$0A,$03,$0E,$06,$09,$04,$10 0-7
                    fcb       $1B,$1B,$1C,$1C,$1A,$1B,$1C,$2B 8-15
                    fcb       $12,$1F,$22,$21,$13,$1F,$22,$21 16-23
                    fcb       $1E,$2D,$2F,$3E,$1E,$2C,$2F,$3E 24-31
                    fcb       $16,$18,$15,$17,$16,$27,$26,$26 32-39
                    fcb       $19,$2A,$29,$2A,$28,$29,$27,$39 40-47
                    fcb       $24,$24,$23,$22,$25,$25,$34,$34 48-55
                    fcb       $20,$3B,$31,$3D,$36,$38,$33,$30 56-63

* Original 64 color translation table for RGB to composite monitor
*L0884    fcb   $00,$0c,$02,$0e,$07,$09,$05,$10
*         fcb   $1c,$2c,$0d,$1d,$0b,$1b,$0a,$2b
*         fcb   $22,$11,$12,$21,$03,$01,$13,$32
*         fcb   $1e,$2d,$1f,$2e,$0f,$3c,$2f,$3d
*         fcb   $17,$08,$15,$06,$27,$16,$26,$36
*         fcb   $19,$2a,$1a,$3a,$18,$29,$28,$38
*         fcb   $14,$04,$23,$33,$25,$35,$24,$34
*         fcb   $20,$3b,$31,$3e,$37,$39,$3f,$30

* DefGPB entry point
L08DC               bsr       L08E1               go do it
                    jmp       >GrfStrt+SysRet     return to system

* Entry point for internal DefGPB (Ex. Overlay window)
L08E1               ldd       <gr0080             get buffer length requested
                    addd      #$001F              round it up to even multiples of 32 bytes
                    andb      #$E0                (to allow for header)
                    std       <gr0080             Preserve new value
                    ldb       <$57                get group
                    incb                          Overlay window save (B was $FF)?
                    beq       L08F8               yes, skip ahead
                    tst       <gr0032             No, has there been any buffers?
                    beq       L08F8               no, go make one
                    bsr       L0930               Yes, see if we can fit one in
                    bcc       L096A               Return Bad/Undefined buffer error
L08F8               ldd       <gr0080             get requested length including header
                    cmpd      #$2000              over 8k?
                    bhi       L090A               yes, skip ahead
                    bsr       L0975               Find block & offset to put it (new or old)
                    bcs       L090A               If couldn't find/allocate, skip ahead
                    lda       #$01                1 8K block used for this buffer
                    sta       Grf.NBlk,x          Save # of blocks
                    bra       L090F               Skip ahead

* Couldn't find existing block that would fit it
L090A               lbsr      L09A8               Go allocate blocks & map 1st one in
                    bcs       L0928               Error, exit with it
L090F               stb       <gr007D             Save start block #
                    stx       <gr007E             Save offset into block
                    lbsr      L09FC               Update get/put buffer header & last used in global
                    ldd       <gr0057             Get group & buffer #
                    std       Grf.Grp,x           save group & buffer # into buffer header
                    ldd       <gr0080             Get buffer size (not including header)
                    std       Grf.BSz,x           save buffer size in buffer header
                    IFNE      H6309
                    clrd
                    clrw
                    stq       Grf.XSz,x           Init X and Y sizes to 0
                    ELSE
                    clra
                    clrb
                    std       Grf.XSz,x           Init X size to 0
                    std       Grf.XSz+2,x         Init Y size to 0
                    std       <gr00B5             Save "W register" for 6809
                    ENDC
                    std       Grf.LfPx,x          Init Pixel masks for 1st & last bytes in block
                    stb       Grf.STY,x           set internal screen type marker
L0928               rts

* Set vector for overlay window buffer search
L092B               ldx       #GrfStrt+L093F      Point to overlay window buffer search routine
                    bra       L0933               set the vector & do search

* Set vector for graphics buffer search
L0930               ldx       #GrfStrt+L0949      Point to normal buffer search routine
L0933               stx       <gr00A1             save the search routine vector
                    bsr       L096E               initialize previous table pointers
                    ldb       <gr0032             get the last block # we used for buffers
                    beq       L096A               Wasn't one, return error
                    ldx       <gr0033             get last offset
                    bra       L0961               go map it in & do search routine

* Overlay window buffer search
L093F               cmpb      Wt.OBlk,y           is this the right overlay?
                    bne       L0957               no, move to next one and come back again
                    cmpx      Wt.OOff,y           set conditions for offset match
                    bra       L0955               go check it

* Graphics buffer search
L0949               lda       <gr0057             get buffer group # we're looking for
                    cmpa      Grf.Grp,x           find it?
                    bne       L0957               nope, keep looking
                    lda       <gr0058             get buffer #
                    beq       L0968               done, return
                    cmpa      Grf.Buff,x          match?
L0955               beq       L0968               yes, return
L0957               stb       <gr007D             save it as previous block #
                    stx       <gr007E             save previous offset
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
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
                    stb       <gr007D             Buffer block #
                    std       <gr007E             Buffer offset #
                    rts

* Called by DefGPB
* Find get/put buffer & block # with room (or make new one)
* Exit: B=Block #, X=Ptr to where next GP buffer could go
L0975               pshs      b,y                 Preserve regs
                    ldy       <gr0080             get size of buffer requested
                    ldx       #GrfStrt+L0AE0      Set vector to find empty space in a block big
                    stx       <gr00A1             enough to fit the size we want
                    lbsr      L0ACD               Go find it
                    bcs       L09A6               Couldn't find, exit with carry set
                    stb       ,s                  Change B on stack to block # we found
                    ldd       Grf.BSz,x           Get buffer size from GP header
                    subd      <gr0080             Subtract the buffer size we need
                    bne       L099B               If not exact fit, skip ahead
                    pshs      x                   Preserve GP buffer ptr a sec
                    lbsr      L0A1C               Map in previous block or new block?
                    puls      x                   Restore GP buffer ptr
                    ldb       ,s                  Get block # we found
                    lbsr      L017C               Go map it in
                    bra       L09A5               exit without error

L099B               subd      #Grf.Siz            Don't include GP header in GP's buffer size
                    std       Grf.BSz,x           Store size into GP header's size
                    leax      Grf.Siz,x           Point to start of actual GP buffer data
                    leax      d,x                 Point to where next GP buffer will go
L09A5               clra                          No error
L09A6               puls      pc,y,b              Restore regs and return

* If initial search couldn't find/fit block, or if size>8K, go here
* Some of stack pushing/Temp storing could be done in E/F instead
* Particularly <$99
* Map in buffer needed (or 1st block of it if >8K)
L09A8               ldd       <gr0080             Get original size we wanted
                    addd      #Grf.Siz            Add GP header size
                    std       <gr0097             Preserve into temp area
                    addd      #$1FFF              Round up to 8K
                    lsra                          Divide by 32 for # blocks needed
                    lsra
                    lsra
                    lsra
                    lsra
                    tfr       a,b                 Dupe into B
                    IFNE      H6309
                    tfr       a,f                 And into F
                    ELSE
                    sta       <gr00B6             Save into "Register F" for 6809
                    ENDC
                    os9       F$AllRAM            Allocate memory
                    bcs       L09FB               Couldn't allocate, return with error
                    IFNE      H6309
                    tfr       b,e                 Preserve start block #
                    cmpf      #$01                Just 1 block requested?
                    ELSE
                    stb       <gr00B5             Save into "Register E" for 6809
                    ldb       <gr00B6             Get "Register F" for 6809
                    cmpb      #1                  Just 1 block requested?
                    ENDC
                    bhi       L09EE               If more than 1 block requested, skip ahead
                    ldd       #$2000              8k
                    subd      <gr0097             Calculate # bytes left in block after our buffer
                    anda      #$1F                Round to within 8K
                    std       <gr009B             Store in another temp
                    beq       L09EE               Exact size of 8K block, skip ahead
                    ldd       #$2000              Size of block
                    subd      <gr009B             subtract rounded size left in block
                    adda      #$20                Add 8K so it points to address in GRFDRV's get/
                    tfr       d,x                 put buffer block (which is where it will be)
                    IFNE      H6309
                    tfr       e,b                 B=Start block # of allocated RAM
                    ELSE
                    ldb       <gr00B5             Get "Register E" for 6809
                    ENDC
                    lbsr      L017C               map it in
                    bsr       L0A0C               Set up new block hdr's back links & current
                    ldd       <gr009B             Get # bytes left in block
                    subd      #Grf.Siz            Subtract header size
                    std       Grf.BSz,x           Preserve buffer size in header
L09EE               ldx       #$2000              Start address of GRFDRV's get/put buffer block
                    IFNE      H6309
                    tfr       e,b                 Move start block # to proper register
                    ELSE
                    ldb       <gr00B5             Get "Register E" for 6809
                    ENDC
                    lbsr      L017C               Map it in
                    IFNE      H6309
                    stf       Grf.NBlk,x          Save # of blocks needed for whole buffer
                    ELSE
                    lda       <gr00B6             Get "Register F" for 6809
                    sta       Grf.NBlk,x
                    ENDC
                    clra                          No error & return
L09FB               rts

* Update last get/put buffer used info & Get/Put buffer header
* Updates $32 & $33-$34
* Entry: D=Size left in second block
L09FC               pshs      d                   Preserve D
                    lda       <gr0032             Get last mapped in block for Get/Put buffers
                    sta       Grf.Bck,x           Make that the block # for our header
                    stb       <gr0032             Put our new last mapped block
                    ldd       <gr0033             Get last mapped offset
                    std       Grf.Off,x           Put that into our header
                    stx       <gr0033             Put our new offset into the last mapped offset
                    puls      pc,d                restore D & return

* Update current get/put buffer info & Get/Put Buffer header
* Updates $35 & $36-$37
*Entry: X=ptr to start of buffer header in GRFDRV's 2nd block (Get/put buffer)
L0A0C               pshs      d                   Preserve D
                    lda       <gr0035             Get current block/group #
                    sta       Grf.Bck,x           Make new block's back ptrs. point to it
                    stb       <gr0035             Make current ptr to start block we just allocated
                    ldd       <gr0036             Get current offset
                    std       Grf.Off,x           Put into new block's offset
                    stx       <gr0036             Make current offset our new one
                    puls      pc,d                Restore D and return

* Make current GP buffer block & offset same as previous block & offset
*  (or map in new one and set it's header up if there is no previous one)
L0A1C               pshs      y,a                 Preserve regs
                    lda       Grf.Bck,x           get back block link #
                    ldy       Grf.Off,x           Get offset in back block to it's header
                    ldx       <gr007E             Get previous blocks offset to buffer
                    ldb       <gr007D             and it's block #
                    bne       L0A30               None mapped in, go map it in
                    sta       <gr0035             Make into current block & offset
                    sty       <gr0036
                    puls      pc,y,a              Restore regs & return

L0A30               lbsr      L017C               Bring in 8K buffer block we need
                    sta       Grf.Bck,x           Set up GP block header
                    sty       Grf.Off,x
L0A38               puls      pc,y,a

* KillBuf entry point
L0A3A               ldb       #$01                Set a temporary flag
                    stb       <gr0097
L0A3E               lbsr      L0930               Go search for buffer (returns X=Buffer ptr)
                    bcs       L0A4D               Couldn't find it, exit
                    clr       <gr0097             Found it, clear flag
                    bsr       L0A55
                    bcs       L0A52
                    ldb       <gr0058             Get buffer #
                    beq       L0A3E               None, loop back
L0A4D               lda       <gr0097             Get flag
                    bne       L0A52               Didn't get killed, return to system with error
                    clrb                          No error
L0A52               jmp       >GrfStrt+SysRet     Return to system

L0A55               pshs      y,x,b               Preserve regs (Window tbl ptr,gfx bffr ptr,block#)
                    lda       Grf.NBlk,x          Get # blocks used
                    sta       <gr009F             Save it
                    lda       Grf.Bck,x           Get back block #
                    ldy       Grf.Off,x           Get back block header offset
                    ldb       <gr007D             Get current buffer block #
                    bne       L0A6B               There is one, continue
                    sta       <gr0032             Save back block as last block used
                    sty       <gr0033             And it's offset
                    bra       L0A75

L0A6B               lbsr      L017C               Go map in GP Block
                    ldx       <gr007E             Get buffer offset
                    sta       Grf.Bck,x           Save back block #
                    sty       Grf.Off,x           Save back block header offset
L0A75               ldb       ,s                  Get block #
                    lda       <gr009F             Get # of blocks used
                    deca                          >1?
                    bgt       L0A9E               Yes, go handle
                    tfr       b,a                 Just one, move block # to A
                    bsr       L0AA8
                    bcc       L0A94
                    ldx       #GrfStrt+L0AF4      Point to vector
                    stx       <gr00A1             Save as active vector
                    ldx       1,s
                    bsr       L0ACD
                    lbsr      L017C
                    lbsr      L0A0C
                    puls      pc,y,x,b

L0A94               ldx       #GrfStrt+L0B1E      Point to vector
                    stx       <gr00A1             Save as active vector
                    ldx       1,s
                    bsr       L0ACD
L0A9E               clra
                    tfr       d,x
                    ldb       <gr009F             Get # of blocks used
                    os9       F$DelRAM            Deallocate the memory
L0AA6               puls      pc,y,x,b

* Part of KillBuf
* Entry: A=block #
L0AA8               pshs      x,b
                    ldb       <gr0032             Get last block # we used for GP buffer
                    beq       L0AC7               None, exit with carry clear
                    cmpa      <gr0032             New block # same as last?
                    beq       L0ACA               Yes, exit with carry set
                    ldx       <gr0033             No, get last offset we used
                    bra       L0AC2               skip ahead

* Entry: A=GP Buffer block # to search for
* Exit:  If same GP block # found:
*           CC=Carry set
*           B=Block # found
*           X=Offset into block # found
*         If no match found:
*           CC=Carry clear
*           B=0
L0AB6               cmpa      Grf.Bck,x           Same as back block link #?
                    beq       L0ACA               Yes, exit with carry set
                    tst       Grf.Bck,x           Is back block link # empty (0)?
                    beq       L0AC7               Yes, exit with carry clear
                    ldb       Grf.Bck,x           No, get back block link #
                    ldx       Grf.Off,x           And get back block header offset
L0AC2               lbsr      L017C               Go map in Get/Put buffer MMU block (block # in B)
                    bra       L0AB6               Keep working backwards through linked list until match found, or beginning of list

L0AC7               clrb
                    puls      pc,x,b

L0ACA               comb
                    puls      pc,x,b

* Subroutine called by L0975 (of DefGPB)
* Entry: Y=Size of buffer requested (including $20 byte header)
L0ACD               pshs      d,x                 Preserve regs
L0ACF               lbsr      L096E               initialize previous buffer ptrs to 0 ($7D-$7F)
                    ldb       <gr0035             get GP buffer block #
                    beq       L0B35               If 0, exit with carry set
                    ldx       <gr0036             get GP buffer offset within 8K block
                    bra       L0B2E               Go map in get/put memory block & continue

* <8K buffer define vector goes here
* Entry: X=Offset to current buffer being checked in current 8K block
*        Y=Size wanted
L0AE0               cmpy      Grf.BSz,x           Will requested size fit?
                    bhi       L0B22               Too big, keep looking backwards
                    bra       L0B38               Exit with carry clear & B=block #, X=offset

* See if requested GP buffer size will fit into existing GP buffer entry
* Entry: U=ptr to GP buffer table entry we are checking
*        X=size requested (including header)
* Exit: flags set from compare
L0AE7               tfr       u,d                 Move out GP buffer table ptr to D
                    addd      Grf.BSz,u           Add GP buffer's data size
                    addd      #Grf.Siz            Add header size (D is now full size of GP buffer incl. header)
                    IFNE      H6309
                    cmpr      x,d                 Will requested buffer fit in GP buffer we are checking?
                    ELSE
                    stx       <grScrtch
                    cmpd      <grScrtch           Will requested buffer fit in GP buffer we are checking?
                    ENDC
                    rts

* A vectored routine (usually pointed to by $A1). Part of GP buffer searching
* I think this is to remove a GP buffer from the linked list
L0AF4               cmpb      1,s
                    bne       L0B22
                    ldu       2,s                 Get ptr to GP buffer we are modifying
                    ldb       Grf.Bck,x           Get MMU Block # of previous entry in linked list
                    stb       Grf.Bck,u           Save as previous entry in one we are modifying
                    ldd       Grf.Off,x           Do the same for offset within the MMU block
                    std       Grf.Off,u
                    exg       x,u                 Swap source/dest GP buffer table entry ptrs
                    bsr       L0AE7               Will it fit?
                    beq       L0B0E               Exact size match, skip ahead
                    exg       x,u                 Not exact match, swap ptrs back
                    bsr       L0AE7               Check if it fits the other direction
                    bne       L0B22               Not same size, skip ahead
L0B0E               stu       2,s                 Save ptr on stack
                    ldd       Grf.BSz,u           Get buffer size from this entry
                    addd      Grf.BSz,x           Add buffer size from other entry
                    addd      #Grf.Siz            Add GP header size
                    std       Grf.BSz,u           Save as new size
L0B19               lbsr      L0A1C               Map buffer in
                    bra       L0ACF

L0B1E               cmpb      ,s
                    beq       L0B19
* Search backwards through existing 8K blocks allocated for Get/Put buffers
* until we hit beginning
L0B22               ldb       <gr0087+3           ($8A) Get GrfDrv MMU block # for GP buffer block (2nd block in grfdrv map)
                    stb       <gr007D             Move to block #
                    stx       <gr007E             Save offset into block as well
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
                    IFNE      H6309
                    ldw       Wt.BLen,y           Get size requested
                    cmpw      Grf.BSz,x           Will it fit in existing buffer?
                    ELSE
                    pshs      d
                    ldd       Wt.BLen,y           Get size requested
                    std       <gr00B5             Save in "W register" 6809
                    cmpd      Grf.BSz,x           Will it fit in existing buffer?
                    puls      d
                    ENDC
                    bls       L0B60               Yes, go do it
                    bra       L0BE4               No, exit with buffer size too small error

* Create new GP buffer
L0B52               ldd       Wt.BLen,y           Get size requested
                    std       <gr0080             Save as buffer length
                    lbsr      L08E1               Go define a get/put buffer for ourselves
                    bcs       L0BE7               Couldn't find room, exit with error
                    ldb       <gr007D             Get buffer block #
L0B60               stb       Wt.NBlk,y           Save buffer block # to GPLoad into
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       <gr0047             Working X coord to 0?
                    ldb       <Gr.STYMk           Get screen type
* Since we now allow get/put on hardware text screens, should be able to
                    lbsr      L0C2B               Directly into Graphics size calculation
                    lbsr      L0C69               Go setup the GP buffer header
                    leax      Grf.Siz,x           Point past GP header (to where data would go)
                    stx       Wt.NOff,y           Save ptr to where next GPLoad will go
                    jmp       >GrfStrt+L0F78      no errors, and exit

* Move buffer entry point (This ONLY gets called via the Move Buffer vector
*   from CoGRF or CoWin)
* It's used to do Get/Put buffer loads in small chunks since GRFDRV's memory
*   map can't fit a window's static mem
* Entry: F=Byte count (Maximum value=72 / $42 is in constant gb0000. Default 72, there is room for a little more
*        (On 6809, this value is at <$B6). OR we can use the remaining 56 bytes for something else.
*         Possible proposal is bump up to 96, then save 32 for other things?)
* Will be single pass of up to 72 bytes if we are not crossing an MMU boundary. Done in
* 2 chunks if we are crossing an MMU boundary
*        Y=Window table ptr
L0B79               ldb       Wt.NBlk,y           get block # for next graphic buffer
                    stb       <gr0097             save temp copy
                    lbsr      L017C               go map it in (uses B only, does not modify registers)
                    ldx       Wt.NOff,y           get offset into block (dest ptr)
                    ldu       #GPBuf              ($1200) Point to buffer of where GRFInt/CoWin put info (src ptr)
                    IFNE      H6309
                    clre                          make 16 bit number in W
                    tfr       w,d                 dupe count into D
                    addr      x,d                 Point to current block offset+size of request
                    ELSE
                    clra                          Make copy size 16 bits in both D and <$B5
                    sta       <gr00B5             Save "Register E" 6809
                    ldb       <gr00B6             Get # bytes to copy from "Reg W" (was set in CoWin (max 72))
                    stx       <grScrtch           Add size to destination ptr
                    addd      <grScrtch
                    ENDC
                    cmpa      #$40                Past end of GP buffer's 8K block?
                    blo       MoveIt              No, go move whole thing in one shot
* Move data between 2 blocks of memory
                    ldd       #$4000              calculate how much will fit in first pass
                    IFNE      H6309
                    subr      x,d
                    subr      d,w                 move leftover to D
                    exg       d,w                 Move first chunk size to W
                    tfm       u+,x+               move first chunk
                    tfr       d,w                 move leftover back to W
                    ELSE
                    subd      <grScrtch           Calculate how many bytes we are copying within current MMU block
                    pshs      d,y                 save D (# bytes we can copy in current block) & Y (window tbl ptr)
                    ldd       <gr00B5             Get size of copy again from "Reg W"
                    subd      ,s                  Subtract # of bytes we can copy within current MMU block (subr d,w)
                    std       <gr00B5             Save # of bytes to do on 2nd pass (other MMU block) this is the value of W after tfm/tfr d,w
                    ldd       ,s++                get # bytes to copy in 1ast pass
                    beq       LMoveb              If none, skip to 2nd pass
                    leay      ,x                  Move dest ptr to Y for subroutine
                    bsr       StkBlCpy            Copy chunk over
LMoveb              puls      y                   restore window table ptr
                    ENDC
                    inc       <gr0097             increment to next block #
                    ldb       <gr0097             get new block #
                    lbsr      L017C               map it in (changes no registers), saves B only
                    ldx       #$2000              reset dest pointer to start of block
* Entry: U=src ptr
*        X=dest ptr
*        W or <$B5=copy size (in bytes) for pass 2
MoveIt              equ       *
                    IFNE      H6309
                    tfm       u+,x+               Block copy buffer into GP buffer
                    ELSE
                    ldd       <gr00B5             Get # of bytes to copy
                    beq       L0BA2               None left, skip ahead
                    pshs      y                   Preserve Window table ptr
                    leay      ,x                  Move dest ptr to Y
                    bsr       StkBlCpy            Copy chunk
                    leax      ,y                  Move dest ptr to X (to save below)
                    puls      y                   Get window table ptr back
                    ENDC
L0BA2               ldb       <gr0097             get the block #
                    stb       Wt.NBlk,y           update it in table
                    stx       Wt.NOff,y           save next offset in table
                    jmp       >GrfStrt+L0F78      no errors, and exit grfdrv

L0BE4               comb                          Buffer size too small error
                    ldb       #E$BufSiz
L0BE7               jmp       >GrfStrt+SysRet

                    IFEQ      H6309
* NOTE: Once we have it working, will move to be near screen scrolling, so we can BSR
* from there. That will be used much more often then loading a GP buffer
* Mini stack blast copy - works on odd # of bytes. Will use stack pull 4 bytes/time when
* possible.
* If you know that you are doing even 4 byte multiple, you will need D & Y pushed to the stack
*   and enter with X being the end copy address (for source)
* Entry: D=size of copy
*        U=Source ptr
*        Y=Dest ptr
* Exit: U=ptr to end of source
*       Y=ptr to end of dest
* X not preserved!
StkBlCpy            pshs      d,y                 Save dest ptr & size
                    leax      d,u                 Point to end of source copy
                    pshs      x                   Save that as where to stop copying
                    andb      #$07                1st, check if non-even multiple of 8 bytes
                    beq       ChkBlst             Even multiple of 8, go straight to mini-stack blast
OddCpy              lda       ,u+                 Otherwise, copy 1-7 bytes 1 at at time until we line up with a 8 byte boundary
                    sta       ,y+
                    decb                          Done odd bytes?
                    bne       OddCpy              No, keep copying 1 at a time
                    bra       ChkBlst             Yes, finish any remaining 4 bytes/time with stack blast*

* Mini stack blast copy ver 2 - does 8 byte stack blast for read, 8 byte 'normal' write
* 46 cycles/8 bytes copied (8 byte)
* Entry: U=ptr to src
*        Y=ptr to dest
*        0,s=ptr to stop at (for source)
BlstCpy             pulu      d,x                 (9 cyc) Get 4 bytes really quickly
                    std       ,y                  (5 cyc) Save them in output buffer
                    stx       2,y                 (6 cyc)
                    pulu      d,x                 (9 cyc) and 4 more bytes
                    std       4,y                 (6 cyc) Save them in output buffer
                    stx       6,y                 (6 cyc)
                    leay      8,y                 (5 cyc) Move output buffer ptr ahead by 8
ChkBlst             cmpu      ,s                  (7 cyc) Are we done?
                    blo       BlstCpy             (3 cyc)
                    sty       4,s                 Save new dest address (is this needed)
                    leas      2,s                 Eat stop address
                    puls      d,y,pc              Restore regs & return

                    ENDC


* GetBlk entry point
L0BAE               lbsr      L1DF6               Go scale X/Y coords @ <$47-$4A,check if in range
                    bcs       L0BE7               No, exit with error
                    IFNE      H6309
                    ldq       <gr004F             Get X/Y sizes
                    decd      Bump                down by 1 each since size, not coord
                    decw
                    stq       <gr004F             Save modified versions
                    ELSE
                    ldd       <gr0051             Get Y size
                    subd      #1                  Bump down by 1 since size, not coord
                    std       <gr0051             Save updated version
                    ldd       <gr004F             Get X size
                    subd      #1                  Bump down by 1 since size, not coord
                    std       <gr004F             Save updated version
                    ENDC
                    lbsr      L1E01               Go scale X/Y Sizes @ <$4f-$52,check if in range
                    bcs       L0BE7               No, exit with error
                    IFNE      H6309
                    ldq       <gr004F             Get X/Y sizes
                    incd                          Bump back up
                    incw
                    stq       <gr004F             Save
                    ELSE
                    ldd       <gr0051             Get Y size
                    addd      #1                  Bump back up
                    std       <gr0051             Save it back
                    ldd       <gr004F             Get X size
                    addd      #1                  Bump it back up
                    std       <gr004F             Save it back
                    ENDC
                    lbsr      L0177               Map in window & setup some GRFDRV vars.
                    bsr       L0C0B               Calc width of buffer in bytes & next line offset
                    lbsr      L0930               Go search for GP buffer
                    bcc       L0BC9               Found it, skip ahead
                    lbsr      L08E1               Couldn't, create one
                    bcc       L0BD4               Got one, skip ahead
                    bra       L0BE7               Otherwise, exit with error

* Found GP buffer already defined
L0BC9               stb       <gr007D             Save block #
                    stx       <gr007E             Save offset into block
                    ldd       <gr0080             Get buffer length
                    cmpd      Grf.BSz,x           Within range of buffer's current length?
                    bhi       L0BE4               No, exit with Buffer Size Too Small error
* GP buffer will fit requested data size
L0BD4               lbsr      L0C69               Go set up the GP buffer's header
                    lbsr      L1E9D               Go calculate addr. on screen to start GETting @
                    stx       <gr0072             Save it
                    ldx       <gr007E             Get offset into GP buffer block
                    lbsr      L0C8D               Go copy from screen into buffer
L0BE1               jmp       >GrfStrt+L0F78      exit with no errors

* Save switch on- comes here to save screen contents under overlay window
* into a get/put buffer
* Entry: Y=Current (or current Overlay) window ptr
L0BEA               ldd       Wt.LStrt,y          Get screen logical start address
                    std       <gr0072             Make it the overlay window save start
                    bsr       L0C0B               Calculate sizes in bytes, etc.
                    ldd       #$FFFF              Group & buffer # to $FF
                    std       <gr0057             Save them
                    lbsr      L08E1               Define get/put buffer for overlay window
                    bcs       L0C0A               Error defining buffer;exit with it
                    ldb       <gr007D             Get MMU block # for overlay window copy
                    stb       Wt.OBlk,y           Save in window table
                    ldd       <gr007E             Get offset into MMU block for overlay window copy
                    std       Wt.OOff,y           Save it in window table
                    bsr       L0C69               Set up get/put buffer header
                    bsr       L0C8D               Preserve screen under overlay window
                    clrb                          No error & return
L0C0A               rts

* Setup # bytes wide overlay window is & offset to get to next line in overlay
*   window when saving/restoring
* Entry: Y=Current (or current Overlay) window ptr
L0C0B               ldb       <Gr.STYMk           Get screen type
                    bpl       L0C18               If gfx window, skip ahead
                    ldb       <gr004F+1           Get LSB of X size of overlay window
                    lslb                          Multiply x2 (for attribute byte)
                    stb       <gr0009             Save width of window (in bytes)
                    bra       L0C1C               Skip ahead

L0C18               bsr       L0C2B               Calculate width info for Gfx windows
                    ldb       <gr0009             Get # bytes for width of window
L0C1C               lda       <gr0051+1           Get height of window in bytes
                    mul                           Calculate total # bytes needed
                    std       <gr0080             Preserve # bytes needed to hold saved area
                    ldb       <gr0063             Get # bytes per row on screen
                    subb      <gr0009             Subtract # bytes wide saved area will be
                    stb       <gr000A             Store # bytes to next line after current width is done
                    rts                           Return

* Calculate GP buffer width in bytes for graphics, & # pixels used in first &
*  last bytes of each GP buffer line
*   (Used by GetBlk, GPLoad, OWSet)
* Entry: B=Screen type
L0C2B               lda       #%00000111          2 color divide by 8 mask
                    decb
                    beq       L0C38               For 640x200x2 screens
                    lsra                          %00000011 divide by 2 mask
                    cmpb      #$03                16 color?
                    bne       L0C38               No, leave as 4 color divide by 2 mask
                    lsra                          16 color divide by 2 mask
L0C38               sta       <gr0097             Preserve mask for # pixels used in 1 byte
                    ldb       <gr0047+1           Get working X coordinate LSB (0 from OWSet)
                    comb                          Make 'hole' to calculate # pixels
                    andb      <gr0097             Use mask to calculate # pixels used
                    incb                          Make base 1
                    stb       <gr0006             Preserve # pixels used in 1st byte of GP line
                    clra                          D=# pixels used in last byte
                    cmpd      <gr004F             More than # bytes on screen?
                    bge       L0C53               Yes,
                    ldb       <gr004F+1           Otherwise, get LSB of X size in bytes
                    subb      <gr0006             Subtract # pixels used in first byte
                    andb      <gr0097             Calculate # pixels in last byte
                    bne       L0C53               If not 0, it is legit
                    ldb       <gr0097             If it is 0, then use full byte's worth
                    incb
L0C53               stb       <gr0007             Save # pixels used in last byte of GP line
                    clra                          D=# of pixels wide GP buffer is
                    ldb       <gr0047+1           Get LSB of 'working' X coordinate
                    andb      <gr0097             AND it with # pixels/byte
                    addd      <gr004F             Add value to X size (in bytes)
                    addb      <gr0097             Add # pixels/byte
                    adca      #$00                Make into D register
* Divide loop: Divide by 4 for 16 color, by 8 for 4 color & by 16 for 2 color
L0C60               equ       *
                    IFNE      H6309
                    lsrd                          Divide by 2
                    ELSE
                    lsra
                    rorb
                    ENDC
                    lsr       <gr0097             Shift right
                    bne       L0C60               until we hit first 0 bit
                    stb       <gr0009             # bytes for width of overlay window
                    rts

* Setup GP buffer header
L0C69               equ       *
                    IFNE      H6309
                    ldq       <gr004F             get X & Y sizes (in pixels)
                    stq       Grf.XSz,x           save it in buffer header
                    ELSE
                    ldd       <gr0051             Get Y size (in pixels)
                    std       Grf.XSz+2,x         Save in GP buffer header
                    std       <gr00B5             Save "Register W"
                    ldd       <gr004F             Get X size (in pixels)
                    std       Grf.XSz,x           Save in GP buffer header
                    ENDC
                    ldb       <Gr.STYMk           Get screen type
                    stb       Grf.STY,x           save it in header
                    ldd       <gr0006             Get start & end pixel masks (for uneven bytes)
                    std       Grf.LfPx,x          save them in header
                    ldb       <gr0009             Get width of buffer in bytes
                    stb       Grf.XBSz,x          save it in header
                    clra                          D=B
                    std       <gr004F             Save into working X coord
                    rts

* Move get/put buffer to screen
* Entry: Y=Ptr to GP buffer?
L0C81               leax      ,y                  X=Ptr to GP buffer
                    lda       <gr0097             Get # bytes to start on next GP line on screen
                    sta       <gr000A             Save in another spot
                    lda       #$01                flag we're going to screen
                    fcb       $21                 skip 1 byte (BRN opcode)
* Move get/put buffer from screen to GP Buffer
L0C8D               clra                          Flag we're going to memory
                    sta       <gr0099             save flag
* Move buffer to screen/mem
* Attempt reversing roles of D & W
                    pshs      y                   preserve y
                    leay      Grf.Siz,x           get pointer to raw buffer data
                    ldx       <gr0072             get address on screen we are doing
L0C96               ldb       <gr004F+1           Get width count of buffer
                    bsr       PutOneL             put one line
                    ldb       <gr000A             get width # bytes to start of next GP line on scrn
                    abx                           move to next line
                    dec       <gr0051+1           done height?
                    bne       L0C96               no, go do next line
                    puls      pc,y                restore & return

* put one line from a GP buffer onto the screen
PutOneL             clra                          make 16-bit number of width of GP buffer
                    IFNE      H6309
                    tfr       d,w                 copy it to W
                    addr      y,d                 check if we will need to get next GP 8K bank
                    ELSE
                    std       <gr00B5             Copy it to "W register" for 6809
                    sty       <grScrtch
                    addd      <grScrtch           check if we will need to get next GP 8K bank
                    ENDC
                    cmpa      #$40                do we?
                    blo       L0C98               nope, go do it
                    ldd       #$4000              calculate # bytes we can do from this 8k bank
                    IFNE      H6309
                    subr      y,d
                    subr      d,w                 calculate leftover into W
                    exg       d,w                 Swap for copy
                    ELSE
                    sty       <grScrtch
                    subd      <grScrtch           D=D-Y
                    pshs      d,u                 save regD & regU
                    ldd       <gr00B5             get regW
                    subd      ,s                  subr d,w regD now = regW
                    ldu       ,s++                get regD
                    stu       <gr00B5             exg d,w
                    puls      u
                    ENDC
                    bsr       L0C98               move first chunk
                    IFNE      H6309
                    tfr       d,w                 Move remainder to W
                    ELSE
                    std       <gr00B5             Save size to copy in 2nd chunk
                    ENDC
                    lbsr      L0E70               go map in next block & reset buffer pointer
* Move a graphics line of data
* Entry: W=# contiguous bytes to move
L0C98               tst       <gr0099             going to screen or mem?
                    bne       L0CA2               screen, go move it
                    IFNE      H6309
                    tfm       x+,y+               Copy from screen to mem
                    rts

                    ELSE
* Entry: X=src ptr
*        Y=Dest ptr
*        <$B5=# of bytes to copy
* Exit:  X=end src ptr
*        Y=end dest ptr
*        A,U is preserved
*      <$B5 zeroed out (this may not be necessary)
CallCpy             pshs      d,x,u               Preserve size, X (src ptr), U
                    leau      ,x                  U=src ptr
                    ldd       <gr00B5             D=# of bytes to copy
                    beq       LMove3b             If none, restore regs & exit
                    lbsr      StkBlCpy            Go copy line
                    stu       2,s                 Save updated src ptr on stack to pull into X
LMove3b             puls      d,x,u,pc
                    ENDC

L0CA2               equ       *
                    IFNE      H6309
                    tfm       y+,x+               Copy from mem to screen
                    rts

                    ELSE
* Change to use mem copy vector later
                    exg       x,y
                    bsr       CallCpy
                    exg       x,y
                    rts
                    ENDC

* PutBlk entry point
* NOTE: POSSIBLE EXTENSION - ALLOW NEGATIVE START X/Y COORDS, SO THAT ONE CAN SCROLL GET/PUT
*  BUFFERS OFF THE TOP/LEFT OF THE SCREEN. USE SIGNED 16 BIT NUMBERS FOR X/Y START COORDS.
* CLIPPING ON BOTTOM WAS ALREADY DONE BY ALAN FOR HIGH SPEED; NEED TO ALLOW SAME FOR OTHER 3
* SIDES (NOTE BY LCB)
* Entry from GRF/WINDInt:
* <$57=Group #
* <$58=Buffer #
* <$47=Upper left X coord
* <$49=Upper left Y coord
* Uses:
* <$4F=X size of GP buffer (bytes)
* <$51=Y size of GP buffer
L0CBB               lbsr      L0177               Go map in window & setup some GRFDRV vars
                    lbsr      L0930               search & map in get put buffer
                    bcs       L0CF5               Error; exit with it
                    stb       <gr007D             save block # of buffer
                    stx       <gr007E             save offset into block buffer starts at
                    IFNE      H6309
                    ldq       Grf.XSz,x           Get X&Y Sizes of buffer
                    decd      Adjust              since size, not coord
                    decw
                    stq       <gr004F             Save local copies
                    ELSE
                    ldd       Grf.YSz,x           Get Y size of GP buffer
                    subd      #1                  base 0
                    std       <gr0051             Save adjusted version
                    ldd       Grf.XSz,x           Get X size of GP buffer
                    subd      #1                  base 0
                    std       <gr004F             Save adjusted version
                    ENDC
                    lbsr      L1DF6               Check validity/scale starting X/Y coords
                    bcs       L0CF5               Error, exit with it
                    lbsr      L1E01               Check validity/scale X&Y sizes
                    bcs       L0CF5               Error; exit with it
                    IFNE      H6309
                    ldq       <gr004F             Restore original base 1 sizes back
                    incd
                    incw
                    stq       <gr004F
                    ELSE
                    ldd       <gr0051             Restore original base 1 sizes back
                    addd      #1
                    std       <gr0051             Y coord first
                    ldd       <gr004F             and X coord
                    addd      #1
                    std       <gr004F
                    ENDC
                    lbsr      L1E9D               calculate screen address & start pixel mask
                    stx       <gr0072             save screen address
                    stb       <gr0074             Save pixel mask for pixel we are doing
                    ldy       <gr007E             get offset ptr to start of GP buffer
                    lda       #$01                Flag to indicate we have to check size vs. window (overlay windows don't need)
                    bsr       L0D14               Go set up start/end pixel masks & check scrn types
                    bcs       L0CEE               If screen type different or has to be clipped, go
                    lbsr      L0D9D               Screen types same & fits; do normal putting
                    bra       L0CF4               return without error

* Get/put width buffer's original screen type being different from actual
*   screen type or will go ever edge of window go here
L0CEE               lbsr      L0E03               Do set up for screen type conversions
                    lbsr      L0E97               Do actual PUTting
L0CF4               clrb                          No error & return to system
L0CF5               jmp       >GrfStrt+SysRet

* Place Overlay window's original contents back on screen
L0CF8               pshs      y                   Preserve window table ptr
                    ldd       Wt.LStrt,y          get screen logical start address
                    std       <gr0072             Save it
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       <gr0047             'Working' X Coord to 0
                    ldy       <gr007E             Get offset to buffer
                    bsr       L0D14               Go verify that overlay can fit back on screen
                    bcs       L0D0F               Couldn't put, exit with error
                    lbsr      L0C81               Move get/put buffer to screen (fast put)
                    clrb                          No error & return
                    puls      pc,y

L0D0F               comb
                    ldb       #E$Bug              Get internal integrity check error
                    puls      pc,y

* Check for common color mode between window & buffer, and check if the
* PUT will need to be clipped. If screen types different or clipping
* required, exit with carry set
* 6809/6309 - LCB need to change: allow X clipping if screen type the same &
*   start pixel mask the same, and adjust X size (like Alan did with Y clipping)
*   Also, add negative start positions that will clip on the top and bottom
L0D14               pshs      x                   Save screen address
                    ldb       <Gr.STYMk           get screen type
                    cmpb      Grf.STY,y           Same as screen type of GP buffer's screen type?
                    beq       GdTyp               Yes, no problem so far
* 03/03/93 mod: 4 color windows will count as same type
                    tstb                          (to properly check high bit)
                    bmi       L0D63               If text, exit with carry set
                    bitb      #$02                Check 4 color mode bit
                    beq       L0D63               Not a 4 color mode, so set carry & exit
                    IFNE      H6309
                    tim       #$02,Grf.STY,y      Check 4 color mode bit in buffer's screen type
                    ELSE
                    pshs      a                   Check 4 color mode bit in buffer's screen type
                    lda       Grf.STY,y
                    bita      #2
                    puls      a
                    ENDC
                    beq       L0D63               It's not a 4 color mode, so set carry & exit
GdTyp               tstb                          graphics window?
                    bpl       L0D27               yep, go on
                    ldb       #$FF                Hardware text; group # forced to $FF (overlay window)
                    stb       <gr0000             Also force "pixel mask" for 1st byte of GP line to all bits
                    stb       <gr0001             Force "pixel mask" for last byte of GP line to all bits
                    bra       L0D58               Skip ahead

* Process graphics PutBlk
* Entry: A=1 if straight from PutBlk, A=0 if from OWEnd with save switch on)
* If A=1, need to see if GP Buffer fits on window (L0D27 routine)
* If A=0, we already know it did, so we can skip size checks
* NOTE: If we are MANUALLY doing a hardware text get/put, this should be A=1
*   and check to see it isn't running off the right (as opposed to Overlay)
* Should change CLIPPING checks so that it just changes some DP variables
*  for # bytes to print line, # bytes per line on screen & # bytes per line
*  in GP buffer. That way even byte/same color mode clipped GP buffers will go
*  full speed as well. We have plenty of room at the end of Grfdrv global mem
L0D27               bsr       L0D94               set up <$50 = X-count, <$52 = y-count
                    tsta                          Do we already know size is legit?
                    beq       L0D3F               Yes, skip ahead
* don't bother for now to do clipping on X-boundaries, i.e. off rhs of the
* screen
                    ldd       <gr0047             Get upper left X coord of PUT
                    addd      Grf.XSz,y           Add X size of GP buffer
                    cmpd      <gr006A             past max X coord.?  (i.e. 319)
                    bls       L0D30               no, don't clip it
                    IFNE      H6309
                    decd      are                 we overflowing by one pixel  (i.e.320)
                    ELSE
                    subd      #1
                    ENDC
                    cmpd      <gr006A             check against highest allowed X
                    bne       L0D63               not the same, so we go clip it
L0D30               ldd       Grf.YSz,y           Get GP Buffer Y size: ATD: 16-bit, so we can check for >256!
                    addd      <gr0049             add it to upper left Y coord. ( max 199)
                    cmpd      <gr006C             past max Y coord.?
                    bls       L0D3F               no, don't bother clipping it (BUG FIX LCB 12/29/2020 BLO to BLS
* Y coord clipping added 03/10/96 by ATD
                    ldd       <gr006C             get max. Y coord
                    subd      <gr0049             take out starting Y coord
                    IFNE      H6309
                    incd                          make it PUT at least one line...
                    ELSE
                    addd      #1
                    ENDC
                    stb       <gr0051+1           save y-count of pixels to do
* Divide by # pixels / byte to see if even byte boundary
L0D3F               ldb       <Gr.STYMk           get screen type
                    ldx       #GrfStrt+L0D70-1    Point to powers of 2 division table
                    lda       <gr0047+1           get LSB of X coord.
                    coma                          invert it
                    anda      b,x                 Get # ^2 divisions
                    inca                          Add 1
                    cmpa      Grf.LfPx,y          Same as # pixels used in 1st byte of GP buffer?
                    bne       L0D63               No, set carry indicating non byte aligned PUT vs. GET
                    bsr       L0D66               Go get pixel masks for first and last byte of each GP line
                    sta       <gr0000             Save pixel mask for 1st byte of GP line
                    ldd       Grf.RtPx,y          Get right based pixel mask & GP buffer screen type
                    bsr       L0D66               Go get starting/ending pixel masks
                    stb       <gr0001             Save pixel mask for last byte of GP line
                    fcb       $8C                 skip setting up
* Text put comes here with B=Group # ($FF) for overlay windows
* Entry: B=buffer block #
L0D58               bsr       L0D94               Move x-size to $50 y-size to $52 (16 bit is $4F and $51 respectively)
                    ldb       <gr0063             Get # bytes/row for screen
                    subb      <gr004F+1           subtract LSB of X size
                    stb       <gr0097             Save # bytes to skip to start of next GP line after current line is done
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

* Powers of 2 shift table
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

* pixel masks for first & last byte of GP line - for 2 color screens
L0D78               fcb       %00000001,%10000000
                    fcb       %00000011,%11000000
                    fcb       %00000111,%11100000
                    fcb       %00001111,%11110000
                    fcb       %00011111,%11111000
                    fcb       %00111111,%11111100
                    fcb       %01111111,%11111110
                    fcb       %11111111,%11111111

* pixel masks for first & last byte of GP line - for 4 color screens
L0D88               fcb       %00000011,%11000000
                    fcb       %00001111,%11110000
                    fcb       %00111111,%11111100
                    fcb       %11111111,%11111111

* pixel masks for first & last byte of GP line - for 16 color screens

L0D90               fcb       %00001111,%11110000
                    fcb       %11111111,%11111111

* Copy X Size & Y size from GP buffer header
* Entry: Y=GP buffer header ptr
L0D94               ldb       Grf.XBSz,y          Get X size of GP buffer in bytes
                    stb       <gr004F+1           Save X size of GP buffer in bytes
                    ldb       Grf.YSz+1,y         Get Y size of GP buffer in bytes
                    stb       <gr0051+1           Save Y size of GP buffer in bytes (pixels)
                    rts

* Put buffer with buffer's screen type matching actual screen type
L0D9D               ldb       <Gr.STYMk           Get screen type
                    ldx       #GrfStrt+L16B1-1    Point to table
                    lda       b,x                 Get # pixels per byte for this screen type
                    IFNE      H6309
                    tfr       a,b                 Dupe for D comparison
                    ELSE
                    ldb       b,x                 Dupe for D comparison
                    ENDC
* no PSET?
                    ldx       #GrfStrt+L1F9E      Point to 'normal' PSET vector
                    cmpx      <gr0064             Is that the current one?
                    bne       L0DBE               No, use slow PUT
* no LSET?
                    ldx       #GrfStrt+L1FA9      Point to 'normal' LSET vector
                    cmpx      <gr0068             Is that the current one?
                    bne       L0DBE               Yes, can use TFM PUT
* no even byte boundary?
                    cmpd      Grf.LfPx,y          Even byte boundary on both left & right sides?
                    lbeq      L0C81               yes, go do fast TFM put
* odd pixel boundaries: do 1st pixel slow, use TFM for the rest
                    sta       <gr0099             flag we're copying to the screen
                    ldd       <gr0000             get 1st & last byte pixels masks for each GP line
                    IFNE      H6309
                    comd                          Invert to have masks of what pixels to keep from screen
                    ELSE
                    coma                          Invert to have masks of what pixels to keep from screen
                    comb
                    ENDC
                    std       <gr0020             masks for pixels to keep from screen
                    ldx       <gr0072             get start screen address for PUT
                    leay      Grf.Siz,y           skip GP buffer header
* do first byte of the line: almost a complete TFM
Put.ATFM            lda       ,x                  grab first byte from screen
                    anda      <gr0020             only keep pixels we want
                    ldb       ,y                  grab pixels from GP buffer
                    andb      <gr0000             only keep pixels we want from that
                    IFNE      H6309
                    orr       b,a                 Merge GP buffer pixels with screen pixels
                    ELSE
                    stb       <grScrtch           Merge GP buffer pixels with screen pixels
                    ora       <grScrtch
                    ENDC
                    sta       ,y                  save in the GP buffer
                    ldd       <gr004F             get width of GP buffer in bytes
                    IFNE      H6309
                    decd      account             for 0th byte
                    ELSE
                    subd      #1                  account for 0th byte
                    ENDC
                    lda       d,x                 get right hand byte from the screen
                    pshs      a                   save end byte
* NOTE: PutOneL immediately clears A (so it's using unsigned B for width)
                    incb
                    lbsr      PutOneL             blast it over using TFM
* do the last byte of the line
* this kludge is necessary because doing it the proper way would add a LOT
* of code to check for GP buffer 8k block boundaries.  It won't be noticed
* except for really large PutBlks.  Oh well.
                    lda       <gr0001             get pixel mask for last byte of GP line for GP buffer
                    anda      -1,x                keep only the pixels we want from last byte of PutBlk on screen
                    ldb       <gr0020+1           get pixel mask for last byte of GP line on screen
                    andb      ,s+                 AND in with original screen data
                    IFNE      H6309
                    orr       b,a                 OR in the pixels we put on the screen
                    ELSE
                    stb       <grScrtch
                    ora       <grScrtch           OR in the pixels we put on the screen
                    ENDC
                    sta       -1,x                save to screen
                    ldb       <gr0097             Get # bytes to start of next line on screen we are PUTting
                    abx                           Point to it
                    dec       <gr0051+1           Dec # of lines left to PUT
                    bne       Put.ATFM            Still more, keep going
                    rts                           Done PutBlk, return

* Either not even byte, or PSET/LSET or not defaults:use slow PUT
L0DBE               sta       <gr0005             Save # pixels/byte for our screen type
                    pshs      y                   Save ptr to GP buffer
                    ldu       <gr0064             Get P(attern)SET vector
                    IFNE      H6309
                    ldw       <gr0068             Get L(ogic)SET vector (for PSET routine)
                    ELSE
                    ldx       <gr0068             Get L(ogic)SET vector (for PSET routine)
                    stx       <gr00B5             Save in "W register"
                    ENDC
                    leay      <Grf.Siz,y          Skip GP buffer header
                    ldx       <gr0072             Get address of where to start PUTting on scrn
                    inc       <gr0097             Bump up # of bytes to start of next GP line by 1
                    dec       <gr004F+1           Adjust X byte count down for base 0
* Loop from here to end of L0DFA - Move Get/Put buffer onto screen using LSET
* logic.
* NOTE: X=ptr to current byte being done on screen
*       Y=ptr to current byte being done in GP buffer
L0DCB               ldb       <gr0000             Get pixel mask for 1st byte in GP buffer
                    lda       <gr004F+1           Get X byte count of GP buffer
                    beq       L0DED               If 0, just 1 byte to do - use last byte routine
                    sta       <gr0099             Save working copy of # bytes on X axis in GP buffer to do
* This part does all the full-byte pixels
L0DD5               ldb       #$FF                Mask byte- all bits
L0DD7               lda       ,y+                 Get bits to set from GP buffer
                    jsr       ,u                  Put on screen
                    ldb       #1                  Screen ptr bump count
                    abx                           Bump screen ptr
                    cmpy      #$4000              Done current 8K block of Get/put buffer?
                    blo       L0DE7               No, continue normally
                    lbsr      L0E70               Yes, go map in next block
L0DE7               dec       <gr0099             Dec # of bytes on X axis left to do on current line
                    bne       L0DD5               Still more, keep going
* This part does the last byte's worth of pixels
                    ldb       <gr0001             Get pixel mask for last byte on GP line
L0DED               lda       ,y+                 Get last byte for current line in GP buffer
                    jsr       ,u                  Put it on screen
                    cmpy      #$4000              Done 8K block yet?
                    blo       L0DFA               No, skip ahead
                    lbsr      L0E70               Yes, go map in next block, reset Y to $2000 (start of GP MMU block)
L0DFA               ldb       <gr0097             Get # of bytes to start of next line down
                    abx                           Point to it
                    dec       <gr0051+1           Dec # of GP lines left to do
                    bne       L0DCB               Still more, keep doing until done
                    puls      pc,y                Restore GP buffer ptr & return

* Put buffer with buffer's screen type different than original
L0E03               pshs      y                   Save GP buffer ptr?
                    ldd       <gr006A             Get max. allowed X coordinate
                    subd      <gr0047             Subtract working X coordinate
                    IFNE      H6309
                    incd                          Base 1
                    ELSE
                    addd      #1                  Base 1
                    ENDC
                    std       <gr009B             Save width of some sort
                    ldb       <gr006C+1           Get max. allowed Y coordinate
                    subb      <gr0049+1           Calc height of some sort
                    incb                          Make base 1
                    bra       L0E2F               Save it & continue

i.iwtyp             comb                          Exit with Illegal window type error
                    ldb       #E$IWTyp
                    jmp       >GrfStrt+SysRet

* Called from Mouse cursor routine @ L15FE
L0E14               pshs      y                   Preserve GP buffer ptr
                    ldd       #320                Default res to 320 (Base 1)
                    IFNE      H6309
                    tim       #$01,<Gr.STYMk      Get res bit from screen type
                    ELSE
                    pshs      a
                    lda       <Gr.STYMk           Get res bit from screen type
                    bita      #1
                    puls      a
                    ENDC
                    beq       L0E24               It is 320 mode, skip ahead
                    IFNE      H6309
                    lsld                          Multiply by 2 to get 640
                    ELSE
                    lslb
                    rola
                    ENDC
L0E24               subd      <gr003D             Subtract last X coord Gfx cursor was ON at
                    std       <gr009B             Save # pixels until we hit right side screen
                    ldb       #MaxLine+1          Get height of screen (in pixels)
                    subb      <gr003F+1           Subtract last Y coord Gfx cursor was ON at
* Re-entry point from normal GP buffer
L0E2F               stb       <$00A0              Save # of lines until we hit bottom of screen
                    lbsr      L1EF1               Setup pix mask & shift vector (gr0079 & gr007A)
                    lbsr      L0D94               Set up element X&Y sizes (in bytes)
* B=Height of GP buffer (also in <$52) in bytes
                    cmpb      <gr00A0             Compare with number of lines left until bottom of screen
                    bls       FullSz              We can fit entire height of GP buffer; leave gr0052 counter as GP Y size
                    ldb       <gr00A0             Can't fit, get # of lines left until bottom of screen
                    stb       <gr0051+1           Save that as Y size
FullSz              ldd       Grf.LfPx,y          Get # pixels used in 1st byte & last byte of each GP line
                    std       <gr0006             Save working copies
                    ldx       #GrfStrt+L075F-1    Point to color mask table index
                    ldb       <Gr.STYMk           Get screen type
* ATD: Added to get around problem of GetBlk on text screen, and PutBlk
* on gfx screen crashing the system!
* We now allow GETBlk and PutBlk on text screens, too!
                    eorb      Grf.STY,y           EOR with GP buffer screen type
                    bmi       i.iwtyp             exit IMMEDIATELY if mixing text and gfx puts
                    ldb       <Gr.STYMk           get screen type again
                    ldb       b,x                 Get offset to color mask table for our screen type
                    abx                           Point to it
                    lda       ,x+                 Get mask of # of for single pixel for color depth (%0001 or %0011 or %1111)
                    stx       <gr0002             Save base of color mask table for our screen mode
                    ldx       #GrfStrt+L0E7C-1    Point to index for pixel tables
                    ldb       Grf.STY,y           Get GP buffers original screen type
                    ldb       b,x                 Calc ptr to proper pixel table
                    abx                           Point table for our screen type
                    ldb       ,x                  Get offset to "rola" shift routine (how many times to shift bits)
                    leay      b,x                 Point to vector for 4, 2 or 1 shift
                    sty       <gr00A3             Save vector
                    anda      1,x                 And bit mask of single pixel with single pixel bit mask from GP buffer
                    sta       <gr0008             Save it
                    ldb       2,x                 Get # pixels per byte for GP buffer type
                    stb       <gr0005             Save working copy
                    ldb       <gr0006             Get # pixels used in 1st byte of GP buffer line
                    addb      #$02                Add 2 to skip skip bit mask & # pixels/byte entries in table
                    ldb       b,x                 Get offset to proper shift routine
                    leay      b,x                 Save vectors for bit shifts
                    sty       <gr00A1
                    sty       <gr00A5
                    puls      pc,y                Restore GP buffer ptr & return

* Get next 8K block of get/put buffers
* Exit: Y=Ptr to start of block ($2000)
L0E70               inc       <gr007D             Increment buffer block #
                    ldb       <gr007D             Get it
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
L0E80               fcb       L0EE0-L0E80         Vector address for 2 color
                    fcb       %00000001           Bit mask for 1 pixel
                    fcb       8                   # pixels /byte
                    fcb       L0EE1-L0E80         Shift for 1st pixel (no shift)
                    fcb       L0EDA-L0E80         Shift for 2nd pixel (1 bit shift)
                    fcb       L0EDB-L0E80         Shift for 3rd pixel (2 bit shift)
                    fcb       L0EDC-L0E80         Shift for 4th pixel (3 bit shift)
                    fcb       L0EDD-L0E80         Shift for 5th pixel (4 bit shift)
                    fcb       L0EDE-L0E80         Shift for 6th pixel (5 bit shift)
                    fcb       L0EDF-L0E80         Shift for 7th pixel (6 bit shift)
                    fcb       L0EE0-L0E80         Shift for 8th pixel (7 bit shift)
* Vector table for GP buffer's taken from 4 color screens
L0E8B               fcb       L0EDF-L0E8B         Vector address for 4 color
                    fcb       %00000011           Bit mask for 1 pixel
                    fcb       4                   # pixels/byte
                    fcb       L0EE1-L0E8B         Shift for 1st pixel (no shift)
                    fcb       L0EDB-L0E8B         Shift for 2nd pixel (2 bit shift)
                    fcb       L0EDD-L0E8B         Shift for 3rd pixel (4 bit shift)
                    fcb       L0EDF-L0E8B         Shift for 4th pixel (6 bit shift)
* Vector table for GP buffer's taken from 16 color screens
L0E92               fcb       L0EDD-L0E92         Vector address for 16 color
                    fcb       %00001111           Bit mask for 1 pixel
                    fcb       2                   # pixels/byte
                    fcb       L0EE1-L0E92         Shift for 1st pixel (no shift)
                    fcb       L0EDD-L0E92         Shift for 2nd pixel (4 bit shift)

* PutBlk when screen type conversion needed (between GP buffer & screen)
L0E97               leay      Grf.Siz,y           Skip GP buffer header
                    pshs      y                   Save ptr to raw GP buffer data as current position in GP buffer
                    ldx       <gr0072             Get ptr to start of buffer placement on screen
                    ldu       <gr0064             Get PSET vector for main loop @ L0EE1
                    fcb       $8C                 skip 2 bytes (CMPX # opcode) same cycle time, 1 byte shorter
L0E9E               stx       <gr0072             Save updated get/put screen address
L0EA0               ldd       <gr009B             Get # of bytes in GP buffer in currently mapped in GP MMU block
                    std       <gr009D             Save working copy (bytes left in current block?)
                    lda       <gr004F+1           Get # bytes wide GP buffer is
                    sta       <gr0004             Save # bytes left in width (including partially used bytes)
                    ldb       <gr0006             Get # of pixels used in 1st byte of GP line
                    stb       <gr0097             Save as # pixels left to do in 1st byte
                    ldd       <gr00A5             Get A5 vector
                    std       <gr00A1             Save as current vector to use
                    ldb       <gr0074             Get pixel mask for 1st byte of GP buffer on scrn
                    IFNE      H6309
                    ldw       <gr0068             Get LSET vector
                    ELSE
                    ldy       <gr0068             Get LSET vector
                    sty       <gr00B5             Save as "W register"
                    ENDC
L0EB2               ldy       ,s                  Get current position in GP buffer
                    cmpy      #$4000              At end of 8K block yet?
                    blo       L0EC1               No, skip ahead
                    stb       <gr0099             Yes, save B (used in L0E70)
                    bsr       L0E70               Go map in next 8K block of GP Buffer & reset GP buffer ptr to $2000
                    ldb       <gr0099             Restore B
L0EC1               lda       ,y+                 Get byte of data from GP buffer
                    sty       ,s                  Save updated position in GP buffer
                    ldy       #GrfStrt+L0EE1      Check if <$A1 vector points here
                    cmpy      <gr00A1             no bit shifting needed?
                    beq       L0ED6               Correct, call vector
                    lsla                          Bit shifts needed, pre-shift in a 0 on low bit
L0ED6               ldy       <gr0002             Get ptr to table of bit masks for colors
                    jmp       [>GrfMem+gr00A1]    Place byte from GP buffer on screen with bit shifts

* Bit shifter for adjusting pixel placements in non-aligned, possible differ-
*  ent screen type, Get/put buffers
* Entry: W=LSET vector (for use with <$64,u vector)
*        U=PSET vector
*        Y=ptr to start of color masks for our color depth (L0763,L0766,L076B for 2,4,16 color)
*        A=byte from GP buffer
*        B=Pixel mask for current pixel in GP buffer
L0EDA               rola                          Adjust pixel to proper place in byte
L0EDB               rola
L0EDC               rola
L0EDD               rola
L0EDE               rola
L0EDF               rola
L0EE0               rola
L0EE1               pshs      cc,d                Save carry, GP Buffer byte, pixel mask
                    ldd       <gr009D             Get # of bytes left in current MMU 8K block for our GP buffer
                    beq       L0EFA               On last byte of GP buffer (or in current 8K MMU block), do those pixels
                    IFNE      H6309
                    decd      Drop                # of bytes left down by 1
                    ELSE
                    subd      #1                  Drop # of bytes left down by 1
                    ENDC
                    std       <gr009D             Save new bytes left (in GP buffer or current MMU block) count
                    ldd       1,s                 Get GP Buffer byte & pixel mask for current pixel back
                    anda      <gr0008             Only keep bits from combined pixel & color mask
                    lda       a,y                 Get proper color bit mask for color
                    jsr       ,u                  Put pixel on screen via PSET vector (none,2 color,4 color or 16 color pattern)
                    ldb       2,s                 Restore original pixel bit mask
                    lbsr      L1F0E               Move to next pixel (returns B=New pixel mask, X=new screen ptr)
                    stb       2,s                 Save new pixel mask for next pixel
L0EFA               dec       <gr0097             Dec # pixels left in current byte
                    beq       L0F04               Done byte, skip ahead
                    puls      d,cc                Not done, restore GP buffer byte, current pixel mask & carry
                    jmp       [>GrfMem+gr00A3]    Call vector to shift next pixel into our routine

* Current byte's worth of pixels done: set up next byte
L0F04               leas      3,s                 Eat temp stack
                    lda       <gr0004             Get # bytes left in current line of GP buffer
                    deca                          subtract 1 for the one we just finished
                    beq       L0F20               Done current GP buffer line, do next line
                    sta       <gr0004             Not done, save updated # bytes left in current line
                    deca                          We on last byte of GP buffer line?
                    beq       L0F14               Yes, set up with # pixels left in last byte of GP line
                    lda       <gr0005             No, get # pixels/byte in GP buffer for full byte
                    fcb       $8C                 skip 2 bytes (CMPX #): same cycle time, 1 byte shorter
L0F14               lda       <gr0007             Get # pixels to do in last (partial) byte of current GP line
L0F16               sta       <gr0097             Save # pixels to do in current byte
                    ldy       <gr00A3             Move last byte partial vector to normal
                    sty       <gr00A1             so we can use same routines
                    bra       L0EB2               go start next byte from GP buffer

* Done current line of GP buffer, set up for next line
L0F20               ldx       <gr0072             Get screen addr of current line in GP buffer
                    ldb       <gr0063             Get # bytes/row on screen
                    abx                           Point to start of next line on screen
                    dec       <gr0051+1           Dec # lines left on window / GP buffer, whichever is lower
                    lbne      L0E9E               If not done, go do next line
                    puls      pc,y                Done, restore Y (GP buffer raw data ptr (start+Grf.Siz)) & return

* Map GP buffer entry point
L0F31               lbsr      L0930               find the buffer
                    lbcs      SysRet              If error, exit back to system with it
                    stb       <gr0097             save starting block number
                    ldb       Grf.NBlk,x          number of blocks in the buffer
                    stb       <gr0099             save count
                    ldd       Grf.BSz,x           size of data inside the buffer
                    std       <gr009B             save size of the buffer
                    leax      Grf.Siz,x           point to the start of the buffer data itself
                    tfr       x,d                 move into math register
                    anda      #$1F                keep offset within the block
                    std       <gr009D             save offset
                    lbra      L0F78               exit with no error

* ATD: this special-purpose text routine results in gfx screens being
* marginally slower, but it saves ~170 clock cycles per character put
* on a hardware text screen. fast.set & it's routines here are ONLY called
* if writing to a hardware text screen
fast.set            dec       <gr0082+1           account for the first character we already printed out
* reset the various parameters after falling off the rhs of the screen
fast.txt            puls      u                   restore pointer to our fast text
                    IFNE      H6309
                    ldw       Wt.CurX,y           move current X position into W
                    ELSE
                    ldx       Wt.CurX,y           move current X position into "W register"
                    stx       <gr00B5
                    ENDC
                    ldx       Wt.Cur,y            get current cursor address on the screen
                    ldb       Wt.Attr,y           grab current attributes
ftxt.lp             lda       ,u+                 get a character from fast text buffer
                    bpl       nofix               No high bit, skip adjust
                    lbsr      NormRMap            fix A so it's printable
nofix               lbsr      L0F7C.0             do more text screen fixes, and STD ,X++
                    IFNE      H6309
                    incw                          right one character BEFORE counting down
                    ELSE
                    stb       <grScrtch           Preserve B
                    ldb       <gr00B6             Get char X position from "F register"
                    incb                          Increase by 1 (so max 255, so will work with horizontal scrolling later)
                    stb       <gr00B6             Save new position
                    ldb       <grScrtch           Get original B back
                    ENDC
                    dec       <gr0082+1           count down # fast chars left
                    beq       ftxt.ex             exit if it's zero: we're done here
                    IFNE      H6309
                    cmpw      Wt.MaxX,y           are we at the rhs of the screen?
                    ELSE
                    lda       <gr00B6             Get "F register" (note: A is destroyed in either of following code paths)
                    cmpa      Wt.MaxX+1,y         are we at the rhs of the screen? (Hware text ONLY)
                    ENDC
                    bls       ftxt.lp             no, continue doing fast text put
                    pshs      u                   save text pointer
                    lbsr      L1238               zero out X coord, do scroll, etc
                    bra       fast.txt            and go reset out parameters

ftxt.ex             equ       *
                    IFNE      H6309
                    cmpw      Wt.MaxX,y           Are we at the right hand side of the screen?
                    ELSE
                    lda       <gr00B6             Get "F register" (A gets destroyed below, no need to preserve)
                    cmpa      Wt.MaxX+1,y         Are we at the right hand side of the screen?
                    ENDC
                    bls       NoScroll            No, exit normally
                    lbsr      L1238               Do scroll stuff
                    IFNE      H6309
                    clrw                          Zero out current X coord
                    ELSE
                    clra
                    clrb                          Zero out current X coord
                    fcb       $8C                 CMPX # opcode, skip 2 bytes (straight to std Wt.CurX,y)
                    ENDC
NoScroll            equ       *
                    IFNE      H6309
                    stw       Wt.CurX,y           save current X coordinate
                    ELSE
                    ldd       <gr00B5             Save current X coordinate (D gets destroyed in L11D1)
                    std       Wt.CurX,y
                    ENDC
                    lbsr      L11D1               set up for the next call (immediately destroys D & W)
                    lbra      L0F78               exit without error

* entry: A = number of characters at $0180 to write (32 max/6809, 64 max/6309)
*        Y = window table pointer
fast.chr            ldx       #FstGrfBf           ($0180) Point to data for buffered write
* ATD: $83 is unused by anything as far as I can tell.
                    sta       <gr0082+1           ($83) save count of characters to do for later
                    lda       ,x+                 get the first character
                    pshs      x                   save address of character
                    lbsr      L0F4B.1             ensure window is set up properly during 1st chr.
* perhaps the DEC <$83 could be here... remove FAST.SET, and fix f1.do
                    lda       <Gr.STYMk           is it a hardware text screen?
                    bmi       fast.set            yes, make it _really_ fast
                    ldb       <gr006E+1           graphics, get X size of font
                    cmpb      #$08                Even byte wide size font?
                    bne       f1.do               no, go setup for multi-color/shiftable screen
                    ldx       <gr00AF+1           ($B0) get cached font pointer
                    beq       f1.do               didn't find a font: use old slow method
                    IFNE      H6309
                    tim       #Prop,<gr000E       Proportional?
                    ELSE
                    lda       <gr000E
                    bita      #Prop               Proportional?
                    ENDC
                    bne       f1.do               yes, use slow method
* OK.  Now we have GFX screens only here, at least one character printed
* to ensure that the buffers etc. are set up and mapped in.  We can now go to
* special-purpose routine for fixed-width 8x8 fonts: ~15% speedup!
                    ldd       Grf.BSz,x           Get size of font buffer (data only)
                    leax      Grf.Siz,x           point X to the first character in the font
                    leau      d,x                 point U to the absolute end-address of the font
* Moved the DP saves from $B2 to $B9; RG
                    stu       <gr00B9             save the pointer for later
                    clra
                    ldb       Wt.CWTmp,y          get bytes per font character
                    std       <gr00BB             Save it
                    ldd       Wt.MaxX,y           get maximum X position (e.g. 319, 639)
                    subd      #$0007              (D+1-8) point D to the last X position possible for
                    std       <gr00BD             a character, and save it
* Note: W *SHOULD* be set up properly from the previous call to print one
* character, but that character might have caused the text to wrap, and thus
* destroy W
                    ldu       #GrfStrt+Fast.pt-2  point to fast font put table
                    ldb       <Gr.STYMk           get screen type
                    aslb                          2 bytes per entry
                    IFNE      H6309
                    ldw       b,u                 grab pointer to routine to use
                    puls      u                   restore character pointer
                    ELSE
                    pshs      x                   (7) Save X
                    ldx       b,u                 (6) Get ptr to routine to use
                    stx       <gr00B5             (5) Save it in "W register"
                    puls      x,u                 (9) Restore X & character ptr
                    ENDC
                    bra       f2.do               jump to the middle of the loop

* U = pointer to characters to print
* Y = window table pointer
* X = font GP buffer pointer
f2.next             lda       ,u+                 grab a character
                    pshs      x,y,u               save all sorts of registers
                    bpl       f2.next2            If no high bit on character, skip adjust
                    bsr       txt.fixa            fix the character in A so it's printable (does not affect Y)
f2.next2            tfr       a,b                 move character to B
                    clra                          make 16-bit offset
* LCB - We may need to change this to MUL later, once we support variable height fonts
                    IFNE      H6309
                    lsld                          ALL fonts are 8 pixels high
                    lsld
                    lsld
                    addr      d,x                 point to the font data
                    ELSE
                    lslb                          ALL fonts are 8 pixels high
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    leax      d,x                 Point to the font data
                    ENDC
                    cmpx      <gr00B9             are we within the font's memory buffer?
                    blo       f2.fnt              yes, we're OK
                    ldx       #GrfStrt+L0FFA      otherwise point to default font character '.'
f2.fnt              lbsr      L102F.1             go print the character on the screen
                    ldy       2,s                 get window pointer again
                    ldd       Wt.Cur,y            get current cursor address
                    addd      <gr00BB             add in bytes per character
                    std       Wt.Cur,y            Save updated cursor address
                    ldd       Wt.CurX,y           Get X coordinate
                    addd      #$0008              Add to X pixel count (1, 6 or 8?)
                    std       Wt.CurX,y           Update value
                    cmpd      <gr00BD             Compare with maximum X coordinate
                    bls       f2.do1              If not past right hand side, leave
                    IFNE      H6309
                    pshsw     save                pointer to which font-put routine to use
                    ELSE
                    ldd       <gr00B5             Get "W register" ptr to which font-put routine to use
                    pshs      d                   Save before we call L1238
                    ENDC
                    lbsr      L1238               fix X,Y coordinate, scroll screen, set up bitmasks (destroys D)
                    IFNE      H6309
                    pulsw     Restore             ptr to which font-put routine to use
                    ELSE
                    puls      x                   Restore ptr to which font-put routine to use
                    stx       <gr00B5             Save in "W register"
                    ENDC
f2.do1              puls      x,y,u               restore registers
f2.do               dec       <gr0082+1           ($83) Dec # of buffered characters left to write
                    bne       f2.next             Still more, continue
                    bra       L0F78               and exit with no errors if we're all done

* LCB 6809/6309- Might be able to leave stack and do stx ,s / ldx ,s during loop? Marginally faster)
* this loop can be up to 31 times (6809) or 63 times (6309). If so, replace pshs/puls with stx/ldx,
* and add puls x after dec <gr0082+1. This will save 4 cyc/char on 6809, 2 cyc/char on 6309
f1.next             lda       ,x+                 Get char from buffer
                    pshs      x                   Save updated buffer ptr
                    bsr       Not8Wd              put one character on the screen
* f1.next/f1.do is entered here. Stack has current buffered write ptr
f1.do               puls      x                   Restore buffer ptr
                    dec       <gr0082+1           ($83) Dec # of buffered characters left to write
                    bne       f1.next             continue
                    bra       L0F78               and exit if we're all done

* L0F4B.1 is now a subroutine to put one character on the screen...
* Alpha put entry point
* Entry: A = Character to write
*        Y = window table ptr
* 07/19/93: LBSR L0177 to L0175
L0F4B.1             lbsr      L0175               Switch to the window we are writing to
                    lbsr      L1002               set up character x,y sizes and font pointers
                    sty       <gr00A9             Save window tbl ptr from this Alpha put
                    tsta                          Is the character ASCII 127 or less?
Not8Wd              bpl       L0F4D               Yes, skip adjusting
L0F4B.2             bsr       txt.fixa            fix A: adds 10 cycles for slow puts and gfx puts
L0F4D               ldb       <Gr.STYMk           Get screen type
                    bpl       L0F73               If gfx  screen, go do it
                    bsr       L0F7C               hardware text; go print it on-screen
                    fcb       $8C                 skip the next 2 bytes (cmpx # opcode)
L0F73               bsr       L0FAE               go print graphic font
L0F75               lbra      L121A               check for screen scroll and/or next line

* LCB - Added a flag that signifies that we are doing a GFX font, and that the
*       font buffer size is $700 bytes. If this flag is set at entry to this
*       routine (after bpl), return to print it.
* Entry: A=ASCII character to print
* exit:  A=modified character for GIME
txt.fixa            tst       <grBigFnt           Gfx mode with a 224 char font?
                    beq       NormRMap            No, do normal remapping
                    cmpa      #$e0                Last 31 chars?
                    blo       BigOut              No, exit
                    suba      #$e0                Point to 1st 31 chars in font
BigOut              rts

NormRMap            cmpa      #$BF
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
* Single character out Alpha Put entry point
L0F4B               bsr       L0F4B.1             do internal alpha-put routine
* Return to the system without any errors
L0F78               clrb                          No errors
* Return to system (Jumps to [D.Flip0] with X=system stack ptr & A=CC status)
SysRet              tfr       cc,a                save IRQ status for os9p1
                    orcc      #IntMasks           Shut off interrupts
                    ldx       >WGlobal+G.GrfStk   Get system stack ptr
                    clr       >WGlobal+G.GfBusy   Flag that Grfdrv will no longer be task 1
                    IFNE      H6309
                    tfr       0,dp                Restore system DP register for os9p1
                    ELSE
                    pshs      a
                    clra
                    tfr       a,dp
                    puls      a
                    ENDC
                    jmp       [>D.Flip0]          Return to system

* Print text to hardware text - optimized for lowercase, then upper
* Can be switched around by swapping blo/bhi sections. This does one char @ a time
*   and is called from L0F4B.2.
* Entry: Y=Window table ptr
*        A=character to print (pre-conversion)
* Exit: Character/attribute pair put on screen
*       X=updated cursor address
L0F7C               ldb       Wt.Attr,y           Get current attribute byte
                    ldx       Wt.Cur,y            Get address of cursor on screen
* Print text to hardware text entry point from f.txt (fast text) loop
L0F7C.0             cmpa      #$60                Convert ASCII reverse apostrophe to apostrophe
                    bhi       L0F8E               Above is safe, go straight to print
                    bne       L0F88               No, try next
                    lda       #$27                GIME apostrophe
                    bra       L0F8E               Skip rest

L0F88               cmpa      #$5E                Convert ASCII carat to GIME carat
                    blo       L0F8E               Below is safe, go straight to print
                    bne       L0F82               No, has to be Underscore
                    lda       #$60                GIME carat
                    fcb       $8C                 skip 2 bytes (CMPX #opcode): same cycle time, 1 byte shorter
L0F82               lda       #$7F                Convert ASCII underscore to GIME underscore
* Hardware transparency added back in, as it is in version 3.0 upgrade as well
* This keeps the background color in the current character, only changing foreground
*  color, blink and underline attributes to current settings
L0F8E               tst       Wt.BSW,y            transparent characters?
                    bmi       L0FA4               no, go on
                    IFNE      H6309
                    aim       #$07,1,x            mask off everything but background attributes
                    ELSE
                    sta       <grScrtch
                    lda       1,x                 mask off everything but background attributes
                    anda      #7
                    sta       1,x
                    lda       <grScrtch
                    ENDC
                    andb      #$F8                get rid of background color
                    orb       1,x                 merge in background color
L0FA4               std       ,x++                save character & attribute to screen
                    rts                           Check for screen scroll/new line

* Print text to graphics window
* Note: $61 & $62 contain the bit masks for the foreground & background colors
*   for the whole width of the byte (ex. a 2 color would be a $00 or $ff)
L0FAE               pshs      a,y                 Preserve character to print & Window table ptr
                    ldb       Wt.BSW,y            get current attributes
                    stb       <gr000E             save 'em for quicker access
                    bitb      #Invers             inverse on?
                    beq       L0FBE               no, go on
* 07/20/93 mod: Get colors from window table instead of GRFDRV mem for speedup
                    lda       Wt.Back,y           Get background color
                    ldb       Wt.Fore,y           Get foreground color
                    std       <gr0061             save 'em back
L0FBE               ldx       <gr00AF+1           get cached font pointer
                    beq       L0FCC               if none, point to '.' font character
                    ldb       Grf.XSz+1,x         get x-size of the font
                    stb       <gr006E+1           save here again: proportional fonts destroy it
                    lda       ,s                  grab again the character to print
* ATD: is this next line really necessary?  The code at L064A ENSURES that
* Grf.XBSz = Grf.YSz = $08, so this next line could be replaced by a LDB #8
* LCB - leaving as is to allow for variable width fonts in future (can share
* some code with proportional fonts, which already have variable width up to 8)
                    ldb       Grf.XBSz,x          get size of each buffer entry in bytes
                    mul                           Calculate offset into buffer for character
                    cmpd      Grf.BSz,x           Still in our buffer? (Not illegal character?)
                    blo       L0FD1               yes, go on
L0FCC               ldx       #GrfStrt+L0FFA      Point to default font char ('.')
                    bra       L0FD6

L0FD1               addd      #Grf.Siz            Add 32 (past header in Gfx buffer table?)
                    IFNE      H6309
                    addr      d,x                 Point to the character within buffer we need
                    ELSE
                    leax      d,x
                    ENDC
L0FD6               ldb       <gr006E+1           get X size of font
                    cmpb      #$08                Even byte wide size font?
                    bne       L0FEC               no, go setup for multi-color/shiftable screen
                    IFNE      H6309
                    tim       #Prop,<gr000E       Proportional?
                    ELSE
                    pshs      a
                    lda       <gr000E             Proportional?
                    bita      #Prop
                    puls      a
                    ENDC
                    beq       L102F               no, use fast method
* Setup for multi-color/shiftable gfx text
L0FEC               ldu       #GrfStrt+L10DF      Normal gfx text vector
                    ldy       1,s                 get window table pointer back
                    lbsr      L106D               go print it
L0FF8               puls      a,y,pc              return

* Default font character if no font buffer defined ('.')
* LCB 6809/6309 proposed change: 'NF' instead:
L0FFA               fcb       %10010000
                    fcb       %11010000
                    fcb       %10110000
                    fcb       %10010111
                    fcb       %00000100
                    fcb       %00000110
                    fcb       %00000100
                    fcb       %00000100

* Original '.' character if undefined font buffer
*L0FFA    fcb   %00000000
*         fcb   %00000000
*         fcb   %00000000
*         fcb   %00000000
*         fcb   %00000000
*         fcb   %00000000
*         fcb   %00010000
*         fcb   %00000000

* Check if font buffers defined?
L0FFF               lbsr      L0177               Map in window, setup grfdrv vars for it, update cursors
L1002               pshs      a                   save character
                    ldb       <Gr.STYMk           Get screen type
                    bpl       L1011               graphics, skip ahead
* Set text font H/W
                    ldd       #$0001              get text font size to 1x1
                    std       <gr006E             Save font X size
                    std       <gr0070             Save font Y size
* Added LCB 97/05/26 for 224 char font support
                    sta       <grBigFnt           Flag that this is not a 224 char font
                    puls      a,pc                larger, but faster than LDQ/bra L1022

* Set undefined graphics font H/W
* L100F is ONLY called from alpha put routine, above.
L100F               pshs      a                   Preserve A (so PULS PC,A works)
L1011               ldb       Wt.FBlk,y           any font defined?
                    bne       L101F               yes, go map it in & get X/Y sizes
                    comb                          set carry
                    IFNE      H6309
                    ldq       #$00080008          default width & height both 8
                    tfr       0,x                 make garbage font ptr
                    ELSE
                    ldd       #8                  Default width=8
                    std       <gr00B5             Save "W register" (height) to 8
                    ldx       #0                  make garbage font ptr
                    ENDC
                    bra       L1020

* Setup defined graphics font H/W
L101F               lbsr      L017C               map in font block
                    ldx       Wt.FOff,y           get offset of font in mem block
                    clrb                          clear carry
                    IFNE      H6309
                    ldq       Grf.XSz,x           Get width & height from window table
                    ELSE
                    ldd       Grf.XSz+2,x         Get height from window table
                    std       <gr00B5             Save height in "W register"
                    ldd       Grf.XSz,x           Get width from window table
                    ENDC
L1020               stx       <gr00AF+1           cache font pointer for later
L1022               equ       *
                    IFNE      H6309
                    stq       <gr006E             Save working copies of width/height
                    ELSE
                    std       <gr006E             Save working copy width
                    ldd       <gr00B5             Get "W register" height
                    std       <gr0070             Save working copy height
                    ENDC
* LCB 05/25/97 - Added flag for 224 char fonts
                    ldd       #$700               Size of font we are checking for
                    cmpd      Grf.BSz,x           Is this a big font?
                    bne       NotBig
                    incb                          Flag it is a big font
NotBig              stb       <grBigFnt           Set flag for 224 char font
                    puls      a,pc                return

L102F               bsr       L102F.2             fast draw graphic font char
                    bra       L0FF8               restore regs & return

* fast draw a graphic font character to a graphics window
* If inverse was selected, they have already been swapped
* Note: <$61 contains the foreground color mask, <$62 contains the background
*   color mask.
* Entry: Y=window table pointer
*        X=Ptr to char in font we are printing
L102F.2             ldu       #GrfStrt+Fast.pt-2  point to fast font put table
                    ldb       <Gr.STYMk           get screen type
                    aslb                          2 bytes per entry
                    IFNE      H6309
                    ldw       b,u                 grab pointer to routine to use
                    ELSE
                    stx       <grScrtch
                    ldx       b,u                 grab pointer to routine to use
                    stx       <gr00B5             Save in "W register"
                    ldx       <grScrtch
                    ENDC
L102F.1             ldy       Wt.Cur,y            get cursor address on screen
                    exg       x,y                 Swap Cursor address & font address
                    ldu       #GrfStrt+fast.tbl   point to table of expanded pixels
                    lda       <gr0070+1           get font height (lsb of it)
                    deca                          adjust it for double branch compare
                    sta       <gr0020             save in temp buffer for later
L1039               lda       ,y+                 get a line of character (8 pixels) from font
                    IFNE      H6309
                    tim       #Bold,<gr000E       Bold attribute on?
                    ELSE
                    pshs      a
                    lda       <gr000E             Bold attribute on?
                    bita      #Bold
                    puls      a
                    ENDC
                    beq       L1044               no, skip bold mask
                    lsra                          shift pixel pattern
                    ora       -1,y                merge it with original to double up pixels
L1044               equ       *
                    IFNE      H6309
                    jsr       ,w                  do a full 8-pixel width of bytes
                    ELSE
                    jsr       [>GrfMem+gr00B5]    do a full 8-pixel width of bytes
                    ENDC
                    ldb       <gr0063             get bytes per line
                    abx                           move screen address to next line
                    dec       <gr0020             done 7 or 8 lines?
                    bgt       L1039               No, go do next line
                    bmi       L1052               yes, return
* falls through here with us on last line - check we print that line of pixels from font,
*  or if we hardcode $FF for underline
                    IFNE      H6309
                    tim       #Under,<gr000E      Underline attribute on?
                    beq       L1039               No, go do last byte of font
                    ELSE
                    lda       <gr000E             Get attribute copy
                    anda      #Under              Underline attribute on?
                    beq       L1039               No, go do last byte of font
                    ENDC
                    lda       #$FF                Yes, set underline byte
                    bra       L1044               Go put it in instead

* 6809/6309 - one possible speedup (will take a fair bit more space): add 4 more to table, with
* 1st 4 being non-transparency on, and last 4 being transparency on. Then have 6 routines (instead
* of 3), optimized for those two (testing high bit of <gr000E would be done when getting this vector)
* situations, so it would remove TST and bpl, and shrink the routines down slightly (although twice
* as many of them).
Fast.pt             fdb       GrfStrt+Font.2      2 color font
                    fdb       GrfStrt+Font.4      4 color
                    fdb       GrfStrt+Font.4      4 color
                    fdb       GrfStrt+Font.16     16 color

* smaller than old method.  Perhaps slower, but it should get the right
* foreground/background colors
* 2 color font - this runs independent of the other 2.
Font.2              tfr       a,b                 move font character into mask
                    comb                          invert it
ChkTChr             tst       <gr000E             Transparent attribute on?
                    bpl       L1051               if transparent, do only foreground colors
                    andb      <gr0062             AND in background color: 0 or 1
                    fcb       $8C                 skip 2 bytes (cmpx # opcode)
L1051               andb      ,x                  AND in background
                    anda      <gr0061             AND in foreground color
                    IFNE      H6309
                    orr       b,a                 OR in the background that's already there
                    ELSE
                    stb       <grScrtch
                    ora       <grScrtch           OR in the background that's already there
                    ENDC
                    sta       ,x                  save font byte to screen
L1052               rts                           and return

* 16 color font - basically runs 4 color twice
* We could unroll this a bit by PSHSW, and use Q (and not call Font.4, but do all 16 self contained).
*   also see note above about duplicating with transparency check pre-done before calling one of the
*   2 versions of this routine. LCB 6809/6309.
Font.16             bsr       get.font            expand it once
                    pshs      a,x                 save low byte, and current X coordinate
                    tfr       b,a                 move right hand mask into A
                    leax      2,x                 do the right side of the font first
                    bsr       Font.4              expand it again, and do another 2 bytes
                    puls      a,x                 restore left hand byte and screen position

Font.4              bsr       get.font            get the font data into 2 bytes
                    pshs      d                   save mask
                    IFNE      H6309
                    comd                          invert it for background check
                    ELSE
                    coma
                    comb
                    ENDC
                    tst       <gr000E             check transparent flag
                    bpl       fast.for            if transparent, only do foreground colors
* LCB 6309 - it may be worthwhile make foreground/backgrounds 2 adjacent bytes each, for 16
*  bit masking? Check other routines to see which would benefit or hinder this. This would allow
* an ANDD, which is 1 cycle faster. Same with fast.st below, except with <gr0061.
                    anda      <gr0062             AND in background color
                    andb      <gr0062             into both A and B
                    bra       fast.st             Draw on screen

fast.for            equ       *
                    IFNE      H6309
                    andd      ,x                  AND in background of screen if transparent
                    ELSE
                    anda      ,x                  AND in background of screen if transparent
                    andb      1,x
                    ENDC
fast.st             std       ,x                  save new background of the screen
                    puls      d                   restore the old pixel mask
                    anda      <gr0061             AND in foreground color
                    andb      <gr0061             B, too
                    IFNE      H6309
                    ord       ,x                  OR in background that's already there
                    ELSE
                    ora       ,x                  OR in background that's already there
                    orb       1,x
                    ENDC
                    std       ,x                  save it on-screen
                    rts

* convert a byte of font data into pixel data
* This table turns a 2-color nibble (4 pixels) into a 4-color byte (4 pixels)
* The lookup is done twice for 16-color screens
fast.tbl            fcb       $00,$03,$0C,$0F
                    fcb       $30,$33,$3C,$3F
                    fcb       $C0,$C3,$CC,$CF
                    fcb       $F0,$F3,$FC,$FF

* A = font byte data
* U = pointer to fast.tbl, above
* returns D = pixel mask for this byte for a 4-color screen
get.font            sta       <grScrtch           Save original font data byte
                    anda      #%00001111          Just right nibble
                    ldb       a,u                 get rightmost expanded byte into B
                    lda       <grScrtch           Get original font data byte
                    lsra                          Shift left nibble to right for table lookup
                    lsra
                    lsra
                    lsra
                    lda       a,u                 get leftmost byte
                    rts
* ATD: end of new font routines

* Draw a graphic font to multi color windows
* May want to change so E/F contains the byte from the font/screen mem to use
*   register to register AND/OR, etc.
L106D               pshs      x                   save font address
                    ldd       #GrfStrt+L10CF      Point to default graphic plot routine
                    std       <gr0010             Save vector
                    IFNE      H6309
                    tim       #Prop,<gr000E       Proportional spacing?
                    ELSE
                    lda       <gr000E             Proportional spacing
                    bita      #Prop
                    ENDC
                    beq       L10A4               no, skip finding font size
* Calc positioning for proportional spacing
                    ldb       <gr0070+1           Get Y pixel count
                    decb                          dec by 1 (0-7?)
                    clra                          Clear out byte for mask checking
* This goes through all 8 bytes of a font character, ORing them into A
* The resultant byte on completion of the loop has all bits set that will be
L1080               ora       b,x                 Mask in byte from font
                    decb                          Dec counter (& position in font)
                    bpl       L1080               Still more to check, continue
                    tsta                          Check byte still clear?
                    bne       L108E               No, skip ahead (B=$ff at this point)
                    lsr       <gr006E+1           Divide X pixel count by 2 if it is
                    bra       L10A4               Start printing with normal vector

* Non-blank char - 1st, find first active pixel (starting on left side)
L108E               decb                          dec B (# active pixels counter)
                    lsla                          Shift merged pixel mask byte left 1 bit
                    bcc       L108E               Pixel is unused in font char, keep looking
* Found pixel that will be needed, set up vector to shift char to be flush
* left
                    ldx       #GrfStrt+L10CF+2    Point to shifting gfx text plot routine
                    leax      b,x                 Point to # of shifts needed for our start pixel
                    stx       <gr0010             Save the vector
* Count # pixels that will be active
                    ldb       #1                  Set up counter for #pixels to print (min.=2)
L109E               incb                          Inc counter
                    lsla                          Shift out merged pixel mask byte
                    bcs       L109E               Until we either hit blank or run out
                    stb       <gr006E+1           Save # pixels to print in X pixel count
* Main printing starts here - sets up for outside loop (at L10BB)
L10A4               ldb       Wt.FMsk,y           Get start pixel mask (may be into byte for prop.)
                    stb       <gr000F             Save in GrfDrv mem
                    ldx       Wt.Cur,y            get address of cursor in screen mem
                    puls      y                   Get font address
                    lda       <gr0070+1           Get # bytes high char is
                    deca                          bump down by 1 (base 0)
                    sta       <gr0099             Save in temp (as counter)
                    stx       <gr000C             Save cursor address
                    lbsr      L1EF1               Set up mask (gr0079) & vector (gr0077) to proper bit shift routine
                    ldx       <gr000C             Get cursor address back
* Outside loop for Gfx font - A is byte of 2 color font data we are currently
* doing
L10BB               lda       ,y+                 Get line of font data
                    IFNE      H6309
                    tim       #Bold,<gr000E       Bold text?
                    ELSE
                    pshs      a
                    lda       <gr000E
                    bita      #Bold               Bold text?
                    puls      a
                    ENDC
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
L10CF               sta       <gr000B             Save flush left font byte, 1 bit/pixel
                    IFNE      H6309
                    lde       <gr006E+1           get X width of font char in pixels
                    ELSE
                    ldb       <gr006E+1           Get X width of font char in pixels
                    stb       <gr00B5             Save in "W register"
                    ENDC
                    ldb       <gr000F             Get bit mask for start pixel on screen
* NOTE: SHOULD TRY TO BUILD A WHOLE BYTE'S WORTH OF PIXELS INTO B TO PUT AS
* MANY PIXELS ONTO SCREEN AT ONCE - NEED TO KNOW HOW MANY PIXELS LEFT IN BYTE
* FROM START THOUGH (COULD USE F AS COUNTER)
                    stb       <grCrPMsk           Save pixel mask
                    stx       <gr000C             save screen address
                    jmp       ,u                  Put it on screen (calls 10DF or 10FA only)

* Print line of font char onto screen
* Inside loop: does 1 pixel at a time from font byte (stored in $000B)
L10DF               lsl       <gr000B             Shift pixel into carry from font byte
                    bcs       L10EB               Pixel is set, put it on screen in foregrnd color
                    lda       <gr000E             Pixel is not used, transparent characters?
                    bpl       L10FE               No, skip this pixel entirely
                    lda       <gr0062             Transparent, get bckgrnd color full byte bit mask
                    bra       L10ED               Go put it on screen

* Used by Update Window Cursor updates (Inverse for cursor)
L10FA               eorb      ,x                  Invert data on screen with bit data
                    stb       ,x                  Save it on screen (Invert for cursor)
                    bra       L10FE               Check if we have more to do

* Put pixel on screen in foreground color
* Entry: B=Current pixel mask
L10EB               lda       <gr0061             get foreground color full byte bit mask
* Entry: B=Current pixel mask
*        A=Color mask (can be fore or background)
L10ED               equ       *
                    IFNE      H6309
                    andr      b,a                 Keep only color data we can use
                    ELSE
                    stb       <grScrtch
                    anda      <grScrtch           Keep only color data we can use
                    ENDC
                    comb                          Make 'hole' with font data
                    andb      ,x                  Merge in screen data
                    IFNE      H6309
                    orr       b,a                 Merge font color onto existing screen byte
                    ELSE
                    stb       <grScrtch
                    ora       <grScrtch           Merge font color onto existing screen byte
                    ENDC
                    sta       ,x                  Save result onto screen
L10FE               equ       *
                    IFNE      H6309
                    dece                          Dec # pixels left on current font line
                    ELSE
                    dec       <gr00B5             Dec # pixels left on current font line ("E register")
                    ENDC
                    beq       L1109               Done current line, skip ahead (destroys B immediately)
                    ldb       <grCrPMsk           Get current pixel mask again
                    lbsr      L1F0E               Move to next pixel position
                    stb       <grCrPMsk           Save new pixel mask
                    jmp       ,u                  Put it on screen (calls 10DF or 10FA only)
* End of inside loop (each pixel within font byte)

L1109               ldx       <gr000C             get start of char. screen address again
                    ldb       <gr0063             Get # bytes per row on screen
                    abx                           Point to next line on screen
                    dec       <gr0099             Are we done whole char (or on last line)?
                    bgt       L10BB               No, continue drawing char
                    bmi       L1120               Totally done, exit
* on last line ($99=0)
                    IFNE      H6309
                    tim       #Under,<gr000E      Underline requested?
                    ELSE
                    lda       <gr000E
                    bita      #Under              Underline requested?
                    ENDC
                    beq       L10BB               No, go draw last line
                    lda       #$FF                Underline code
                    bra       L10CF               Go draw it
* End of outside loop (for each line with font)

L1120               rts                           Return

* 2 color mode pixel mask table
L1EE0               fcb       %00000111           Mask for pixel #'s not in even byte
                    fcb       $80,$40,$20,$10,$08,$04,$02,$01

* 4 color mode pixel mask table
L1EE9               fcb       %00000011           Mask for pixel #'s not in even byte
                    fcb       $c0,$30,$0c,$03

* 16 color mode pixel mask table
L1EEE               fcb       %00000001           Mask for pixel #'s not in even byte
                    fcb       $f0,$0f

* Goto X/Y entry point
L1186               lbsr      L0FFF               Set up font sizes (and font if on gfx screen)
                    ldb       <gr0047             Get working X coord
                    subb      #$20                Kill off ASCII part of it
                    lda       <gr006E+1           Get # pixels wide each text char is
                    mul                           Calculate # pixels into screen to start at
                    std       <gr0047             Preserve Start pixel # as 'working' X coord
                    addd      <gr006E             Add width in pixels again (calculate end X coord)
                    IFNE      H6309
                    decd      Adjust              to base 0
                    ELSE
                    subd      #1                  Adjust to base 0
                    ENDC
                    cmpd      Wt.MaxX,y           Would we be past end of window?
                    bhi       L11CA               Yes, exit out of grfdrv
                    ldb       <gr0049             Get Y coord
                    subb      #$20                Kill off ASCII part of it
                    lda       <gr0070+1           Get Y size of font in bytes
                    mul                           Calculate # bytes from top of screen to start at
                    std       <gr0049             Save as working Y coord
                    addd      <gr0070             Bump down by 1 more text char Y size
                    IFNE      H6309
                    decd      Adjust              to base 0
                    ELSE
                    subd      #1                  Adjust to base 0
                    ENDC
                    cmpd      Wt.MaxY,y           Would end of char go past bottom of window?
                    bhi       L11CA               Yes, exit out of grfdrv w/o error
                    IFNE      H6309
                    ldq       <gr0047             Get x & y coords
                    stq       Wt.CurX,y           Move into window table (-2 to +1)
                    ELSE
                    ldd       <gr0049             Get Y coord
                    std       Wt.CurY,y           Move into window table
                    ldd       <gr0047             Get X coord
                    std       Wt.CurX,y           Move into window table
                    ENDC
                    bsr       NewEnt              Originally bsr L11D1 (redundant)
L11CA               jmp       >GrfStrt+L0F78      Exit out of grfdrv w/o error

* Control code processor
* Entry: A=ctrl code
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
L1E9F               lda       <gr0049+1           get Y coordinate (0-199)
                    ldb       <gr0063             get bytes/row
                    mul                           Calculate # bytes into screen to go
                    IFNE      H6309
                    addr      d,x                 Add to screen start
                    ELSE
                    leax      d,x                 Add to screen start
                    ENDC
                    ldb       <Gr.STYMk           get screen type
                    bpl       L1EB5               graphics screen, go adjust X coordinate
* Calculate offset for X location (text only)
                    ldb       <gr0047+1           Get X coordinate
                    lslb                          account for attribute byte
                    abx                           point X to screen location & return
                    rts

* Calculate offset for X location (gfx only)
* Fast horizontal and vertical lines call this after doing a LDW <$68 (LSET)
L1EB5               pshs      u                   Preserve U
                    cmpb      #$04                320 16 color screen?
                    bne       L1EC0               No, try next
* 16 color screens (2 pixels/byte)
                    ldd       <gr0047             get requested X coordinate
                    ldu       #GrfStrt+L1EEE      Point to 2 pixel/byte tables
                    bra       L1ED4               Adjust screen address accordingly

L1EC0               cmpb      #$01                640 2 color screen?
                    beq       L1ECB               Yes, go process it
* 4 color screens go here (4 pixels/byte)
                    ldd       <gr0047             Get requested X coordinate
                    ldu       #GrfStrt+L1EE9      Point to 4 pixel/byte tables
                    bra       L1ED2               Adjust Screen address accordingly

* 2 color screens go here (8 pixels/byte)
L1ECB               ldd       <gr0047             Get requested X coordinate
                    ldu       #GrfStrt+L1EE0      Point to 8 pixel/byte tables
                    IFNE      H6309
                    lsrd                          Divide by 8 for byte address
L1ED2               lsrd                          divide by 4
L1ED4               lsrd                          divide coordinate by 2 (to get Byte offest)
                    addr      d,x                 Point X to byte offset for pixel
                    ELSE
                    lsra
                    rorb
L1ED2               lsra
                    rorb
L1ED4               lsra
                    rorb
                    leax      d,x
                    ENDC
                    ldb       <gr0047+1           Get LSB of X coordinate requested
                    andb      ,u+                 Mask out all but pixels we need to address
                    ldb       b,u                 Get mask for specific pixel we need
                    puls      pc,u                Restore U & exit

* Cursor to left margin (CR)
L11CD               equ       *
                    IFNE      H6309
                    clrd                          Set X coordinate to 0
                    ELSE
                    clra                          Set X coordinate to 0
                    clrb
                    ENDC
                    std       Wt.CurX,y
L11D1               equ       *
                    IFNE      H6309
                    ldq       Wt.CurX,y           Copy window table x,y coord to grfdrv "working" x,y
                    stq       <gr0047
                    ELSE
                    ldd       Wt.CurX,y           Copy cursor X coord to grfdrv "working" X
JustY               std       <gr0047
                    ldd       Wt.CurY,y           Copy cursor Y coord to grfdrv "working" Y
                    std       <gr0049
                    ENDC
NewEnt              bsr       L1E9D               Go calculate screen logical address
                    stx       Wt.Cur,y            Preserve screen location
                    stb       Wt.FMsk,y           Preserve x coord (adjusted by x2 for text attr
                    rts                           if needed)

* Home cursor
L11E1               ldd       Wt.LStrt,y          Make cursor address same as upper left of screen
                    std       Wt.Cur,y
                    ldx       #GrfStrt+L1F00-2    Point to bit mask/vector table
                    ldb       <Gr.STYMk           Get screen type
                    bmi       L11F8               If text, skip bit mask calculation
                    lslb                          Multiply x2 to get table entry
                    ldb       b,x                 Get bit mask
                    stb       Wt.FMsk,y           Preserve it
L11F8               equ       *
                    IFNE      H6309
                    clrd                          Clear out x & y coord's in window table
                    clrw
                    stq       Wt.CurX,y
                    ELSE
                    clra                          Clear out x & y coord's in window table
                    clrb
                    std       Wt.CurX,y
                    std       Wt.CurY,y
                    ENDC
                    rts

* Cursor left
L11F9               ldd       Wt.CurX,y           Get current cursor X coord
                    subd      <gr006E             Subtract X pixel count
                    std       Wt.CurX,y           Save updated cursor X coord
                    IFNE      H6309
                    bpl       L11D1               Didn't wrap into negative, leave
                    ELSE
                    bpl       JustY               Didn't wrap into negative, leave
                    ENDC
                    ldd       Wt.MaxX,y           Get Max X coordinate
                    subd      <gr006E             subtract X pixel count
                    IFNE      H6309
                    incd                          Bump up by 1
                    ELSE
                    addd      #1                  Bump up by 1
                    ENDC
                    std       Wt.CurX,y           Save new X coordinate
                    ldd       ,y                  Get Y coordinate
                    subd      <gr0070             Subtract Y pixel count
                    std       Wt.CurY,y           Save updated Y coordinate
                    bpl       L11D1               Didn't wrap into negative, leave
                    IFNE      H6309
                    clrd                          Set coordinates to 0,0
                    ELSE
                    clra                          Set coordinates to 0,0
                    clrb
                    ENDC
                    std       Wt.CurX,y           Save X coordinate
                    std       Wt.CurY,y           Save Y coordinate
                    rts

* Cursor Up
L122F               ldd       Wt.CurY,y           Get Y coordinate
                    subd      <gr0070             Subtract Y pixel size
                    bpl       GoodUp              If not at top, save coordinate
                    rts                           Otherwise, exit

GoodUp              std       Wt.CurY,y           Save new Y coordinate
                    bra       L11D1               Copy to Grfdrv working copies & exit

* Cursor right
L121A               ldd       Wt.CurX,y           Get X coordinate
                    addd      <gr006E             Add to X pixel count (1, 6 or 8?)
                    std       Wt.CurX,y           Save updated X coord
                    addd      <gr006E             Add to X pixel count again
                    IFNE      H6309
                    decd      Dec                 by 1
                    ELSE
                    subd      #1                  Dec by 1
                    ENDC
                    cmpd      Wt.MaxX,y           Compare with maximum X coordinate
                    bls       L11D1               If not past right hand side, copy to Grfdrv working copies & exit
L1238               bsr       L11CD               Zero out X coordinate
* Cursor Down (LF)
* Called by font change. Entry= Y=window table ptr, X=Screen addr, B=X coord
* on current line on physical screen
L123A               ldd       Wt.CurY,y           Get current Y coord
                    addd      <gr0070             Add to Y pixel count
                    tfr       d,x                 Move result to X
                    addd      <gr0070             Add Y pixel count again
                    IFNE      H6309
                    decd      decrement           by 1
                    ELSE
                    subd      #1                  decrement by 1
                    ENDC
                    cmpd      Wt.MaxY,y           compare with Maximum Y coordinate
                    bhi       L124F               If higher (scroll needed), skip ahead
                    stx       Wt.CurY,y           Store +1 Y coordinate
                    bra       L11D1               Copy to grfdrv's working copies & exit

* new Y coord+1 is >bottom of window goes here
L124F               pshs      y                   Preserve window table ptr
                    ldb       Wt.XBCnt,y          Get width of window in bytes
                    stb       <gr0097             Save since Y will disappear
                    clra                          Clear MSB of D
                    ldb       <gr0063             Get # bytes per row of screen
                    std       <gr0099             preserve value (16 bit for proper ADDR)
                    ldd       Wt.CurY,y           Get current Y coord
                    std       <gr009D             Preserve
                    lda       Wt.SZY,y            Get current Y size
                    deca                          0 base
                    sta       <gr009B             Preserve
                    beq       L128A               If window only 1 line high, then no scroll needed
                    ldx       Wt.LStrt,y          Get screen logical start addr. (top of screen)
                    ldd       Wt.BRow,y           Get # bytes/text row (8 pixel lines if gfx)
                    leay      ,x                  Move screen start addr. to Y
                    IFNE      H6309
                    addr      d,x                 X=Screen addr+1 text line
                    ELSE
                    leax      d,x                 X=Screen addr+1 text line
                    ENDC
                    lda       <gr009B             Get Y size (0 base)
                    ldb       <Gr.STYMk           Check screen type
                    bmi       L1267               If text, skip ahead
                    lsla                          Multiply by 8 (# pixel lines/text line)
                    lsla
                    lsla
                    sta       <gr009B             Y size into # pixel lines, not text lines
* Special check for full width windows
L1267               ldb       <gr0097             Get width of window in bytes
                    cmpb      <gr0063             Same as screen width?
                    bne       L127B               No, do normal scroll
L1267a              mul                           Calculate size of entire window to move
* Scroll entire window in one shot since full width of screen
                    IFNE      H6309
                    tfr       d,w                 Move to TFM size reg.
                    tfm       x+,y+               Move screen
                    ELSE
* Entry: D=size of copy (in bytes)
*        X=Src ptr
*        Y=Dest ptr
                    pshs      u                   Save U register
                    leau      ,x                  Point U to src of copy
                    lbsr      StkBlCpy            Mini stack blast the scroll
                    puls      u                   Restore U
                    ENDC
                    bra       L128A               Exit scroll routine

* Scroll window that is not full width of screen. Can scroll either direction
* so some vars are signed.
* Used for scroll, delete line, and insert line
L127B               equ       *
                    IFNE      H6309
                    ldd       <gr0099             Get # bytes/row for screen
                    ldf       <gr0097             W=# bytes wide window is
                    clre
                    subr      w,d                 Calc # bytes to next line
* Entry: X=src ptr of copy
*        Y=dest ptr of copy
L127E               tfm       x+,y+               Block move the line
                    ELSE
                    clra
                    ldb       <gr0097             D=# bytes wide window is
                    std       <grScrtch           Save copy
                    ldd       <gr0099             Get # bytes/row to move (CAN BE SIGNED!)
                    subd      <grScrtch           Subtract # bytes wide window is
                    std       <gr00B5             Save # bytes to skip to next line after current line done (into "W register")
                    ldd       <grScrtch           Get # bytes wide to copy again
                    pshs      u                   Save U
* Entry: D=size of copy
*        X=src ptr
*        Y=dest ptr
L127E               leau      ,x                  U=ptr to src of copy
                    lbsr      StkBlCpy            Copy line
                    leax      ,u                  Move updated src ptr to X
                    ENDC
* Entry: D=# bytes to start of next line
*        X=updated src ptr,
*        Y=updated dest ptr
                    dec       <gr009B             Dec # lines to still copy
                    IFNE      H6309
                    beq       L128A               If done, exit
                    addr      d,x                 Bump start ptr by 1 line (might be signed)
                    addr      d,y                 Bump end ptr by 1 line
                    ldf       <gr0097             Get width of window in bytes
                    ELSE
                    beq       L128A.2             If done, exit
                    ldd       <gr00B5             Get # of bytes to skip for next line (signed)
                    leax      d,x                 Bump src ptr (might be signed)
                    leay      d,y                 Bump dest ptr
                    ldd       <grScrtch           Get # bytes wide to copy again
                    ENDC
                    bra       L127E               Do until we have moved all the lines

                    IFEQ      H6309
L128A.2             puls      u                   Restore U
                    ENDC
L128A               puls      y                   Get back window table ptr
L128C               ldd       <gr009D             Get back current Y coord
L128E               bra       L1354               Go clear new line & exit

* Insert line
L1291               pshs      y                   Save window table ptr
                    ldd       Wt.CurY,y           Get current Y coord
                    std       <gr009D             Preserve it
                    ldb       Wt.XBCnt,y          Get width of window in bytes
                    stb       <gr0097             Save in fast mem
                    clra                          Get # bytes/row into D
                    ldb       <gr0063             (16 bit for ADDR)
                    IFNE      H6309
                    negd                          Make negative (since scrolling down)
                    ELSE
                    coma                          Make negative (since scrolling down)
                    comb
                    addd      #1
                    ENDC
                    std       <gr0099             Preserve it
                    ldb       Wt.SZY,y            Get current Y size
                    decb                          0 base
                    lda       <gr0070+1           Get Y pixel count (1 or 8)
                    mul                           Multiply by current Y size
                    tfr       b,a                 Dupe result
                    deca                          Don't include line we are on
                    subb      Wt.CurY+1,y         Subtract Y coord of cursor
                    cmpb      <gr0070+1           Compare with Y pixel count
                    blo       L128A               If on bottom line, don't bother
                    stb       <gr009B             Save # lines to leave alone
                    ldb       <gr0063             Get #bytes/row
                    mul                           Calculate # bytes to skip scrolling
                    addd      Wt.LStrt,y          Add to screen start address
                    tfr       d,x                 Move to top of scroll area reg. for TFM
                    addd      Wt.BRow,y           Add # bytes/text row
                    tfr       d,y                 Move to bottom of scroll area reg. for TFM
                    bra       L127B               Do insert scroll

* Delete line
L12C5               pshs      y                   Save window table ptr
                    ldb       Wt.XBCnt,y          Get width of window in bytes
                    stb       <gr0097             Save it
                    clra                          Get # bytes/row on screen into D
                    ldb       <gr0063
                    std       <gr0099             Save for ADDR loop
                    lda       Wt.SZY,y            Get current Y size
                    deca                          0 base
                    ldb       <Gr.STYMk           Check screen type
                    bmi       L12DC               If text, skip ahead
                    lsla                          Multiply x8 (height of font)
                    lsla
                    lsla
L12DC               suba      Wt.CurY+1,y         Subtract current Y location
                    bhi       L12E6               Not on bottom of screen, continue
                    puls      y                   On bottom, get back window table ptr
                    ldd       Wt.CurY,y           Get Y coord back
                    bra       L1354               Just clear the line & exit

L12E6               sta       <gr009B             Save # lines to scroll
                    ldd       Wt.MaxY,y           Get Maximum Y coordinate
                    subd      <gr0070             Subtract Y pixel count
                    IFNE      H6309
                    incd                          Base 1
                    ELSE
                    addd      #1                  Base 1
                    ENDC
                    std       <gr009D             Save size of area to scroll for delete
                    lda       <gr0063             Get # bytes/row
                    ldb       Wt.CurY+1,y         Get Y coord of cursor
                    mul                           Calculate offset to top of area to scroll
                    addd      Wt.LStrt,y          Add to Screen logical start address
                    tfr       d,x                 Move to top of window reg. for TFM
                    ldd       Wt.BRow,y           Get # bytes/text row
                    leay      ,x                  Swap top of window to bottom since reverse scroll
                    IFNE      H6309
                    addr      d,x                 Calculate top of window reg. for backwards TFM
                    ELSE
                    leax      d,x                 Calculate top of window reg. for backwards mem copy
                    ENDC
                    jmp       >GrfStrt+L127B      Go delete the line

* Erase current line
L1352               ldd       Wt.CurY,y           Get Y coordinate
L1354               std       <gr0049             Preserve 'working' Y coordinate
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       <gr0047             'Working' X coordinate to 0
                    ldd       Wt.MaxX,y           Get maximum X coordinate
                    bra       L136C               Go figure out other needed coords

* Erase to end of line
L135F               equ       *
                    IFNE      H6309
                    ldq       Wt.CurX,y           Get X & Y coordinates
                    stq       <gr0047             Save as 'working' copies
                    ELSE
                    ldd       Wt.CurY,y           Get Y coord
                    std       <gr0049             Save 'working' copy
                    ldd       Wt.CurX,y           Get X coord
                    std       <gr0047             Save 'working' copy
                    ENDC
                    ldd       Wt.MaxX,y           Get maximum X coordinate
                    subd      Wt.CurX,y           Subtract X coordinate
L136C               equ       *
                    IFNE      H6309
                    incd                          Add 1 to X size
                    ELSE
                    addd      #1                  Add 1 to X size
                    ENDC
                    std       <gr004F             Save new X size (in bytes)
                    ldd       <gr0070             Get Y pixel count
                    std       <gr0051             Save new Y size (in bytes)
                    bra       L13AD

* CLS (Chr$(12))
L1377               lbsr      L11E1               Home cursor (D&W are 0 on exit)
                    IFNE      H6309
                    stq       <gr0047
                    ELSE
                    std       <gr0049
                    std       <gr0047
                    ENDC
                    ldd       Wt.MaxX,y           Get maximum X coordinate
                    IFNE      H6309
                    incd                          Bump up by 1
                    ELSE
                    addd      #1                  Bump up by 1
                    ENDC
                    std       <gr004F             New X size
                    ldd       Wt.MaxY,y           Get maximum Y coordinate
                    bra       L13A8

* Erase to end of screen
L138D               bsr       L135F               Erase to end of current line first
                    IFNE      H6309
                    clrd                          'working' X coordinate to 0
                    ELSE
                    clra                          'working' X coordinate to 0
                    clrb
                    ENDC
                    std       <gr0047
                    ldd       Wt.CurY,y           Get cursor Y position
                    addd      <gr0070             Add Y pixel count
                    std       <gr0049             Save as new working Y coordinate
                    ldd       Wt.MaxX,y           Get maximum X coordinate
                    IFNE      H6309
                    incd                          bump up by 1
                    ELSE
                    addd      #1                  bump up by 1
                    ENDC
                    std       <gr004F             New X size
                    ldd       Wt.MaxY,y           Get maximum Y coordinate
                    subd      <gr0049             Subtract Y coordinate
                    bmi       L13B7               If negative, skip
L13A8               equ       *
                    IFNE      H6309
                    incd                          Bump up by 1
                    ELSE
                    addd      #1                  Bump up by 1
                    ENDC
                    std       <gr0051             Save Y size
* Erase to end of screen/line comes here too
* Entry: Y=Ptr to window table
L13AD               lbsr      L1E9D               get screen logical start address into X
* and also the starting pixel mask into B.
                    lda       <Gr.STYMk           Get screen type
                    bpl       L13E3               Graphics screen, go clear area & exit from there
* Do the CLS on text screen. Use mini stack blast here for both 6809/6309
* At this point, X=ptr to start of area to clear
                    bsr       MakeChar            Make 2 byte (space + attrib)
                    pshs      d,y,u               Save it & U and Y
                    leau      ,x                  Point U to start address to clear from
                    ldb       <gr004F+1           Get width of window area to clear (in chars)
                    lslb                          * 2 to include attribute byte
                    cmpb      <gr0063             Same as width of screen?
                    beq       ClsFTxt             Yes, window is full screen width, go do whole thing in one shot
* Hardware text clear - non full screen width. B=width to clear
                    clra
* 6309 LCB - could we not use E and/or F for some counters here?
* may need to check calling routines
                    std       <grScrtch           Save width to clear (in bytes) it so we don't have to recalculate
HTxtLp              ldx       <grScrtch           Get width to clear
                    ldd       ,s                  Get char/attr bytes
                    bsr       StkBlCl2            Clear line (exits with U=ptr to beginning of line we cleared)
                    clra                          More lines to do, get # of bytes/row on screen into D
                    ldb       <gr0063
                    IFNE      H6309
                    addr      d,u                 Point to start of next line
                    ELSE
                    leau      d,u                 Point to start of next line
                    ENDC
                    dec       <gr0051+1           Dec # of lines high we are doing
                    bne       HTxtLp              done all lines, exit
                    stu       4,s                 Save updated U
                    puls      d,y,u,pc            Restore U,Y & return

* Special optimized routine for full screen width hardware text - clear entire area in one shot
* Entry: U=ptr to start area to clear
ClsFTxt             ldb       <gr0063             Get # bytes per line for screen
                    lda       <gr0051+1           Get # of rows (lines)
                    mul                           D=# chars to clear
                    pshs      d                   Save size (so we can add it later)
                    tfr       d,x                 Move for subroutine
                    ldd       2,s                 Get attrib/char
                    bsr       StkBlCl2            Clear it
                    puls      d                   Get complete size again
                    leau      d,u                 Point to end of copy
                    stu       4,s                 Save over U on stack
                    puls      d,y,u,pc            Restore regs & return

* Get space char/attribute byte set up in D
MakeChar            lda       #C$SPAC             Space character
                    ldb       Wt.Attr,y           Get default attributes
                    andb      #$38                Mask out Flash/Underline & bckgrnd color
                    orb       <gr0062             Mask in background color (D is now space char/attr byte)
L13B7               rts

* Entry: B=Value to clear with (single byte). NOTE: If you enter at StkBlCl2, you can
*          have D=double byte value to clear with (useful for hardware text screens, like in
*          Level II grfdrv)
*        X=Size (in bytes) to clear
*        U=Start address to clear from
* NOTE: No incoming regs preserved!
* NOTE: If you have a 2 byte value (hware text), put that in D, and call via StkBlCl2
* NOTE 2: If you know you are doing an even 4 byte sized clear, you can preload X with the value(s)
*    to clear with, A:B as the # of 4 byte chunks, and U as the ptr to then end of the clear,
*    and jump straight to either NormClr. You do have to add 3 bytes to the stack first
StkBlClr            tfr       b,a                 D=double copy of value to clear memory with
StkBlCl2            exg       x,d                 D=Size to clear (in bytes), X=2 byte value to clear with
                    IFNE      H6309
                    addr      d,u                 Point to end of clear area for stack blast
                    ELSE
                    leau      d,u                 Point to end of clear area for stack blast
                    ENDC
                    pshs      b,x                 Save 16 bit value to clear with, & LSB of size (to check for leftover bytes)
                    lsra                          Divide size by 4 (since we are doing 4 bytes at a time)
                    rorb
                    lsra
                    rorb
                    pshs      d                   Save mini-stackblast counters
                    ldd       2,s                 Get A=LSB of # of bytes to clear, B=byte to clear with
                    anda      #%00000011          Non-even multiple of 4?
                    beq       NoOdd               Even, skip single byte cleanup copy
* LCB - This patch allow 1-3 byte "leftovers" to function properly for both graphics (1 byte value)
*  & text (2 byte values) clears to work, for partial width screens.
* (should allow text and gfx to both work)
OverLp              lsra                          Odd # of bytes?
                    bcc       Do2                 No, skip to 2 byte copy (can only be 2 at this point)
                    stb       ,-u                 Yes, save 1 byte (could be 1 or 3)
Chk2Byte            lsra                          Double byte as well?
                    bcc       NoOdd               No, do 4 byte chunks if needed
Do2                 stx       ,--u                Save double byte value
NoOdd               ldd       ,s++                Get Mini-stack blast ctrs back
                    beq       ExitClrB            No 4 byte blocks, done
NormClr             leay      ,x                  Dupe 16 bit clear value to Y
ClrLp               pshu      x,y                 Clear 4 bytes
                    decb                          Dec "leftover" (<256) 4 byte block counter
                    bne       ClrLp               Keep doing till that chunk is done
                    deca                          Dec 1Kbyte counter
                    bpl       ClrLp               Still going (B has been set to 0, so inner loop is 256 now)
ExitClrB            puls      b,x,pc              Eat temp regs & return

* Entry if known 4 byte multiple to clear ONLY
* Entry if called here: B,X on stack (or leas -3,s if you don't care)
*   X=16 bit value to clear with
*   U=ptr to end of clear ptr+1
*   A=# of 1k blocks to clear
*   B=# of 4 byte "leftover" blocks to clear
FourBClr            pshs      b,x                 Preserve regs for sub
                    bra       NormClr             Do copy

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
                    IFNE      H6309
                    orr       b,a                 make A the right-most mask
                    ELSE
                    stb       <grScrtch
                    ora       <grScrtch           make A the right-most mask
                    ENDC
                    bcc       L13E5               the low bits of A will be the pixel mask
                    tfr       a,b                 copy A to B again
                    coma
                    andb      <gr0062             AND with full-byte background color mask
                    std       <gr0097             save screen mask, background color
                    IFNE      H6309
                    lde       <gr0051+1           Get # of lines to clear
                    ELSE
                    ldb       <gr0051+1           Get # of lines to clear
                    stb       <gr00B5             Save in "W register"
                    ENDC
                    ldb       <gr0063             get the size of the screen
L13E8               lda       ,x                  grab a byte off of the screen
                    anda      <gr0097             AND in only the screen pixels we want
                    ora       <gr0098             OR in the background color
                    sta       ,x                  save the updated byte
                    abx                           go to the next screen line
                    IFNE      H6309
                    dece                          dec # lines to clear
                    ELSE
                    dec       <gr00B5             dec # lines to clear
                    ENDC
                    bne       L13E8               continue until done
                    puls      a,x                 restore X coord mask and screen ptr
                    leax      1,x                 Point to 2nd byte (We have finished first byte column now)
* Even byte boundary for start
L13F0               inca                          now A=number of pixels per byte (8,4,2)
                    ldb       <gr0062             Get background full-byte pixel mask
                    pshs      d                   save pixels/byte, color mask
                    ldd       <gr004F             Get X size (in pixels)
                    IFNE      H6309
                    divd      ,s+                 divide by pixels/byte: B=bytes wide the window is
* PANIC if A<>0!!!          leave mask on stack for later use
                    ELSE
                    clr       <grScrtch           Clear result to start
L13F0b              inc       <grScrtch           Bump up result
                    subb      ,s                  Subtract pixels/byte
                    sbca      #0
                    bcc       L13F0b              Still more possible, subtract again/bump up answer
                    ldb       <grScrtch           Get result NOTE: We don't care about remainder
                    decb                          Adjust back down to final answer (since we borrowed)
                    leas      1,s
                    ENDC
                    cmpb      <gr0063             Are we clearing the full width of the screen?
                    beq       ClsFGfx             Yes, do complete TFM
                    stb       <gr0097             save width of window for later
                    subb      <gr0063             subtract width of window from width of screen
                    negb                          now B=offset from X-end,Y to X-start,Y+1
                    lda       <gr0051+1           Get # lines to clear
                    IFNE      H6309
                    clre                          W for TFM size
L1450               ldf       <gr0097             Get width of window in bytes
                    tfm       s,x+                Clear out line
                    deca                          Dec line ctr
                    beq       L146F               Done, exit
                    abx                           Bump to start of next line
                    bra       L1450               Keep clearing until done

                    ELSE

* Entry: A=# of lines to clear
*        X=ptr to start of line on screen
L1450               ldb       <gr0063             Get # bytes/line on screen
                    std       <grScrtch           Save # of lines we are clearing & bytes/line
                    clra
                    ldb       <gr0097             D=# of bytes wide we are clearing
                    pshs      d,y,u               Save regs
                    leau      ,x                  Point to start of clear
L1450b              ldx       ,s                  Get size to copy into X for subroutine
                    ldb       6,s                 Get full byte color mask
                    lbsr      StkBlClr            Go clear the line
                    ldd       <grScrtch           Get # lines left to clear & bytes/line
                    deca                          Dec line ctr
                    beq       DoneClLn            Done, skip ahead
                    sta       <grScrtch           Save lines left ctr
                    clra                          D=# of bytes/line
                    leau      d,u                 Point to start of next line
                    bra       L1450b              Keep doing until done

DoneClLn            ldb       <gr0097             Get size of copy into D (A=0 from deca to get here)
                    leau      d,u                 Point U to end of last copy
                    stu       ,s                  Save over X on stack
                    puls      x,y,u               Restore regs
                    puls      a,pc                Eat stack & return
                    ENDC

* Clearing Gfx screen/even byte start/full width window
* Entry: B=width of screen/window in bytes
*        X=ptr to start of window area to clear
*        ,s = byte to clear with
ClsFGfx             lda       <gr0051+1           Get # lines to clear
                    mul                           Calculate # bytes for remainder of screen
                    IFNE      H6309
                    tfr       d,w                 Move to TFM size register
                    tfm       s,x+                Clear out remainder of screen
                    ELSE
                    beq       L146F               If window size is 0 bytes, just return
                    pshs      d,x,y,u             Save start screen ptr & U
                    leau      ,x                  Point U to start of window to clear
                    tfr       d,x                 X=size to clear
                    ldb       8,s                 Get byte to clear with
                    lbsr      StkBlClr            Clear window
                    puls      d,x,y,u             Get regs back
                    leax      d,x                 Point X to end of window cleared
                    ENDC
L146F               puls      pc,a                Eat a & return

* $1f code processor
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
                    rts                           No known $1f code, just return

* Inverse ON
L14A8               ldb       Wt.BSW,y            Get window bit flags
                    bitb      #Invers             Inverse on?
                    bne       L14C3               Already on, leave it alone
                    orb       #Invers             Set inverse on flag
                    stb       Wt.BSW,y            Save new bit flags
L14B2               lda       Wt.Attr,y           Get default attributes
                    lbsr      L15B2               Go swap Fore/Background colors into A
                    ldb       Wt.Attr,y           Get default attributes again
                    andb      #Blink+Under        Mask out all but Blink & underline
                    IFNE      H6309
                    orr       a,b                 Mask in swapped colors
                    ELSE
                    sta       <grScrtch
                    orb       <grScrtch           Mask in swapped colors
                    ENDC
                    stb       Wt.Attr,y           Save new default attribute byte & return
L14C3               rts

* Inverse OFF
L14C4               ldb       Wt.BSW,y            Get window bit flags
                    bitb      #Invers             Inverse off?
                    beq       L14C3               Already off, leave
                    andb      #^Invers            Shut inverse bit flag off
                    stb       Wt.BSW,y            Save updated bit flags
                    bra       L14B2               Go swap colors in attribute byte

* Underline ON
L14D0               equ       *
                    IFNE      H6309
                    oim       #Under,Wt.Attr,y    Set Underline in window default attributes
                    oim       #Under,Wt.BSW,y     Set Underline in window bit flags
                    ELSE
                    lda       Wt.Attr,y
                    ora       #Under              Set Underline in window default attributes
                    sta       Wt.Attr,y
                    lda       Wt.BSW,y            And in window bit flags
                    ora       #Under
                    sta       Wt.BSW,y
                    ENDC
                    rts

* Underline OFF
L14D9               equ       *
                    IFNE      H6309
                    aim       #^Under,Wt.Attr,y   Clear Underline in window default attributes
                    aim       #^Under,Wt.BSW,y    Clear Underline in window bit flags
                    ELSE
                    lda       Wt.Attr,y           Clear Underline in window default attributes
                    anda      #^Under
                    sta       Wt.Attr,y
                    lda       Wt.BSW,y            Clear Underline in window bit flags
                    anda      #^Under
                    sta       Wt.BSW,y
                    ENDC
                    rts

* Blink on
L14E2               equ       *
                    IFNE      H6309
                    oim       #Blink,Wt.Attr,y    Set Blink in window default attributes
                    ELSE
                    lda       Wt.Attr,y           Set Blink in window default attributes
                    ora       #Blink
                    sta       Wt.Attr,y
                    ENDC
                    rts

* Blink off
L14E9               equ       *
                    IFNE      H6309
                    aim       #^Blink,Wt.Attr,y   Clear Blink in window default attributes
                    ELSE
                    lda       Wt.Attr,y           Clear Blink in window default attributes
                    anda      #^Blink
                    sta       Wt.Attr,y
                    ENDC
                    rts

* Cursor On/Off entry point
L116E               lbsr      L0FFF               Set up font sizes (and font if on gfx screen)
                    bsr       L1179               Do appropriate action
                    bra       L1508               Return with no error

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
                    cmpy      <gr002E             Are we the current active window (window tbl)?
                    bne       L1508               No, just return
                    ldd       <gr005B             Get Graphics cursor X coord
                    cmpd      <gr003D             Same as last used graphics cursor coord?
                    bne       L1531               No, go draw new graphics cursor
                    ldd       <gr005D             Get Graphics cursor Y coord
                    cmpd      <gr003F             Same as last used graphics cursor coord?
                    beq       L1508               Yes, no update needed, just return
L1531               lbsr      L15E2               Put original data under cursor back to normal
                    bsr       L153B               Update 'last gfx cursor' on position to new one
                    bra       L1505               put gfx cursor back on screen, and exit: +3C:-3B

L153B               ldd       <gr0047             Get current 'working' X & Y coords
                    ldx       <gr0049
                    pshs      d,x                 Save them on stack
                    IFNE      H6309
                    ldq       <gr005B             Get new graphics cursor X & Y coords
                    stq       <gr0047             Save as working copies for Put routines
                    stq       <gr003D             Also, make them the new 'last position' coords
                    ELSE
                    ldd       <gr005D             Get 'working' Y coord
                    std       <gr0049             Save working copy for Put routines
                    std       <gr003F             Save as new 'last position' Y coord
                    ldd       <gr005B             Get 'working' X coord
                    std       <gr0047             Save working copy for Put routines
                    std       <gr003D             Save as new 'last position' X coord
                    ENDC
                    ldx       Wt.STbl,y           Get screen table ptr
                    ldx       St.LStrt,x          Get screen start address
                    lbsr      L1E9F               Screen address to put=X, start pixel mask=B
                    stx       <gr0041             Save screen ptr
                    stb       <gr0043             Save start pixel mask
                    puls      d,x                 Get back original 'working' coords
                    std       <gr0047
                    stx       <gr0049             Put them back for original GrfDrv function
L1579               rts

* Cursor on
L14F0               equ       *
                    IFNE      H6309
                    aim       #^NoCurs,Wt.BSW,y   Set cursor flag to on
                    ELSE
                    lda       Wt.BSW,y            Set cursor flag to on
                    anda      #^NoCurs
                    sta       Wt.BSW,y
                    ENDC
* Update txt cursor (on gfx or txt screens) from UPDATE Window 'hidden' call
L1563               lda       #$01                put the cursor on the screen
                    bra       L157B

* Cursor off
L14F8               equ       *
                    IFNE      H6309
                    oim       #NoCurs,Wt.BSW,y    Set cursor flag to off
                    ELSE
                    lda       Wt.BSW,y            Set cursor flag to off
                    ora       #NoCurs
                    sta       Wt.BSW,y
                    ENDC
* Update text cursor (on gfx or text screens) from within Grfdrv
L157A               clra                          take the cursor off of the screen
L157B               cmpy      <gr002E             We on current window?
                    bne       L1579               No, exit
                    IFNE      H6309
                    tim       #NoCurs,Wt.BSW,y    Cursor enabled?
                    ELSE
                    pshs      a
                    lda       Wt.BSW,y            Cursor enabled?
                    bita      #NoCurs
                    puls      a
                    ENDC
                    bne       L1579               No, exit
                    cmpa      <gr0039             get cursor state on screen flag
                    beq       L1579               same state as last time, exit
                    sta       <gr0039             cursor is ON the screen
                    lbsr      L1002               Set up fonts, character sizes
* Handle char. under cursor on Hware Text screen
* Entry: Y=window table ptr
* Exit: Attribute byte on screen has fore/bckground colors reversed
L158B               ldx       Wt.Cur,y            get cursor physical address
                    ldb       <Gr.STYMk           get screen type
                    bpl       L15A5               Skip ahead if gfx screen
                    lda       1,x                 Get attribute byte of char. under cursor
                    bsr       L15B2               Get inversed fore/bck ground colors mask into A
                    ldb       1,x                 Get original attribute byte back
                    andb      #%11000000          Mask out all but blink & underline
                    IFNE      H6309
                    orr       a,b                 Merge in swapped colors mask
                    ELSE
                    sta       <grScrtch
                    orb       <grScrtch           Merge in swapped colors mask
                    ENDC
                    stb       1,x                 Set new attributes for this char & return
                    rts

* Set attributes on Gfx screen
L15A5               pshs      y                   Save window table ptr
                    ldu       #GrfStrt+L10FA      Setup vector for cursor on Gfx screen
                    clr       <gr000E             Shut off all attributes
                    lbsr      L106D               Go put inversed char (under cursor) on screen
                    puls      pc,y                Restore window tbl ptr & return

* Flip fore/background color masks for hardware text attribute byte
* Entry:A=attribute byte for h/ware text screen
* Exit: A=Reversed color masks
L15B2               clrb                          no attributes here yet
                    anda      #%00111111          Mask out blinking, underline bits
                    IFNE      H6309
                    lsrd                          one byte smaller than old method
                    lsrd                          move foreground in A to background in A,
                    lsrd                          background in A to 3 high bits of B
                    ELSE
                    lsra                          move foreground in A to background in A,
                    rorb                          background in A to 3 high bits of B
                    lsra
                    rorb
                    lsra
                    rorb
                    ENDC
                    lsrb                          shift background in B 2 bits: blink & underline
                    lsrb                          now background in A is in foreground in B
                    IFNE      H6309
                    orr       b,a                 Merge two masks together in A
                    ELSE
                    stb       <grScrtch
                    ora       <grScrtch           Merge two masks together in A
                    ENDC
                    rts

* Update Gfx Cursor - UPDATE Window 'hidden' call version - Put it on scrn
L15BF               pshs      y,x                 Preserve window & screen tbl ptrs
                    ldx       Wt.STbl,y           Get scrn tbl ptr from window tbl
                    cmpx      <gr0030             Same as current screen?
                    bne       L15E0               No, leave
                    ldb       <gr003A             Get Gfx cursor XOR'd on/off flag
                    bne       L15E0               It's already on screen, exit
                    ldb       Wt.GBlk,y           Get memory block # of gfx cursor
                    stb       <gr0044             Save in Grfdrv mem
                    beq       L15E0               If there is no Gfx cursor defined, exit
                    bsr       L017C               Map in Gfx cursor GP buffer block
                    ldy       Wt.GOff,y           Get ptr to actual cursor buffer in MMU block
                    sty       <gr0045             Save it in Grfdrv mem
                    bsr       L15FE               XOR mouse cursor onto screen (put it on)
                    inc       <gr003A             Set Gfx cursor XOR flag to 'ON'
L15E0               puls      pc,y,x              Restore regs & return

* Update Gfx cursor - from within GRFDRV - Take old one off scrn
L15E2               pshs      y,x                 Preserve window & screen tbl ptrs
                    ldx       Wt.STbl,y           Get scrn tbl ptr from window tbl
                    cmpx      <gr0030             Same as current screen?
                    bne       L15FC               No, leave
                    ldb       <gr003A             is the Gfx cursor on the screen?
                    beq       L15FC               no, exit.
                    ldb       <gr0044             grab gfx cursor GP buffer number
                    beq       L15E0               if none, exit
                    bsr       L017C               map in get/put buffer
                    ldy       <gr0045             grab pointer to cursor in block
                    bsr       L15FE               XOR mouse cursor onto screen (take off old one)
                    clr       <gr003A             Set Gfx cursor XOR flag to 'OFF'
L15FC               puls      pc,y,x

* XOR mouse cursor onto screen
L15FE               ldb       <Gr.STYMk           Get screen type
                    bmi       L1634               Text; exit
                    ldd       <gr004F             Get original X & Y sizes
                    ldx       <gr0051
                    pshs      x,d                 Save them
                    ldd       <gr0064             Get original Pset & Lset vectors
                    ldx       <gr0068
                    pshs      x,d                 Save them
                    ldd       <gr0041             Get screen address of Gfx cursor
                    std       <gr0072             Save as GP buffer start position
                    ldb       <gr0043             Get pixel mask for start of Gfx cursor
                    stb       <gr0074             Save as GP buffer pixel mask start
                    ldx       #GrfStrt+L1F9E      Force PSET to 'off'
                    stx       <gr0064
                    ldx       #GrfStrt+L1FA3      For LSET to XOR
                    stx       <gr0068
                    lbsr      L0E14               set up for different STY in buffer/screen
                    lbsr      L0E97               go put the cursor on-screen
                    puls      x,d                 Restore original vectors
                    std       <gr0064
                    stx       <gr0068
                    puls      x,d                 Restore original X/Y sizes
                    std       <gr004F
                    stx       <gr0051
L1634               rts                           return

* Bring in Get/Put buffer memory bank - put into GRFDRV DAT Img @ <$87
* Entry: B=MMU block # to get
L017C               clr       <gr0087+2           clear out $33 "unused" byte of DAT image for 2nd MMU block
                    stb       <gr0087+3           Save actual Block number of Get/Put buffer
                    stb       >$FFA9              Save it to MMU hardware as well
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
                    IFEQ      H6309
L1FA3b              equ       *
                    sta       <grScrtch
                    orb       <grScrtch
                    stb       ,x
                    rts

* 6809 - since we already had to "break out" of magic spacing, just put the
* stb ,x / rts here, and leave the "duplicate" version @ L1FA3C, even though
* it won't be used. (or use those 3 bytes for a constant or something to be
* used from elsewhere)
                    ENDC

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
                    IFNE      H6309
                    orr       a,b                 Merge color & bit mask
                    ELSE
                    bra       L1FA3b
                    nop       keep                byte count the same
                    ENDC
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
* NOTE: For 6809, some of these routines, when they exit the "magic area" because the
* code is longer, can stay out and finish without branching back in. The extra bytes
* can be padded, or used for constants. LCB
Pix.XOR             equ       *
                    IFNE      H6309
                    eord      ,x                  offset 0
                    ELSE
                    bra       PEOR                keep byte count same
                    nop
                    ENDC
PXOR2               std       ,x++
                    rts

Pix.AND             equ       *
                    IFNE      H6309
                    andd      ,x                  offset 6
                    ELSE
                    anda      ,x                  Should save 6 cycles/2 bytes from original, and 6 bytes shorter (PAND removed)
                    anda      1,x
                    ENDC
PAND2               std       ,x++
                    rts

                    fcc       /ALAN/      space fillers (may be put some small useful table here?)
                    IFNE      H6309
                    fcc       /D/         6309 space fillers (maybe put some small useful table here?)
                    ENDC

Pix.OR              equ       *
                    IFNE      H6309
                    ord       ,x                  offset 17
                    ELSE
                    ora       ,x
                    orb       1,x
                    ENDC
                    std       ,x++
                    rts
* End of ATD's magic routine!

                    IFEQ      H6309
PEOR                eora      ,x
                    eorb      1,x
                    std       ,x++                +1 byte, saves 3 cycles every EOR double byte
                    rts
                    ENDC

* Point entry point
L1635               bsr       I.point             map screen and PSET block in, scale coordinates
                    bcs       L1688               Error scaling, exit with it
                    lbsr      L1E9D               Get:X=ptr to byte on screen,B=bit mask for pixel
                    lda       <gr0061             Get foreground color
                    IFNE      H6309
                    ldw       <gr0068             Get LSET vector
                    ELSE
                    stx       <grScrtch
                    ldx       <gr0068             Get LSET vector
                    stx       <gr00B5             Save in "W register"
                    ldx       <grScrtch
                    ENDC
                    jsr       ,u                  Put pixel on screen
                    bra       L1687               Exit without error

* Line entry point
* ATD: Line/bar/box set up screen: saves ~40 bytes, adds 6 clock cycles
I.Line              lbsr      L1DFD               scale 2nd set of coordinates
                    bcs       L16B0               error: exit to a convenient RTS
I.point             lbsr      L1884               map in window, and verify it's graphics
                    ldu       <gr0064             get PSET vector for line/bar/box routines
                    lbra      L1DF6               Scale 1st set of coords

* Line entry point
L1654               bsr       I.Line              internal line set up routine
                    bcs       L1688               Error; exit
                    IFNE      H6309
                    ldw       <gr0068             Get LSET vector
                    ELSE
                    ldd       <gr0068             Get LSET vector
                    std       <gr00B5             Save in "W register"
                    ENDC
                    ldd       <gr0049             Get 'working' Y coordinate
                    cmpd      <gr004D             Same as current Y coordinate?
                    bne       L1679               No, check X
                    bsr       L168B               Do 'fast' horizontal line
                    bra       L1687               Return to system without error

L1679               ldd       <gr0047             Get 'working' X coordinate
                    cmpd      <gr004B             Same as current X coordinate?
                    bne       L1684               No, use 'normal' line routine
                    lbsr      L16F4               Do 'fast' vertical line
                    bra       L1687               Return to system without error

L1684               lbsr      L1724               Do 'normal' line routine
L1687               clrb                          No error
L1688               jmp       >GrfStrt+SysRet     Return to system

* Swap start & end X coords if backwards ($47=Start, $4B=End)
L16A3               ldd       <gr004B             Get end X coord
                    cmpd      <gr0047             Compare with start X coord
                    bge       L16B0               Proper order, return
L16AA               ldx       <gr0047             Swap the 2 X coord's around
                    std       <gr0047
                    stx       <gr004B
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
L1690               ldd       <gr004B             Get end X coord of line
                    subd      <gr0047             # pixels wide line is
                    IFNE      H6309
                    incd                          +1 (base 1)
                    ELSE
                    addd      #1                  +1 (base 1)
                    ENDC
                    std       <gr0099             Save # of pixels left
                    lbsr      L1E9D               X=Mem ptr to 1st pixel, B=Mask for start pixel
                    lda       <gr0061             Get foreground color mask (full byte)
                    ldy       <gr0099             Get # pixels to do
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
                    ldb       <Gr.STYMk           Get screen type
                    clra                          Clear high byte
                    ldb       b,x                 Get # pixels/byte for screen type
                    std       4,s                 Save overtop original Y on stack
                    puls      x,d                 Restore Screen ptr & Color/pixel masks
                    tstb                          is the pixel mask at the high bit of the byte?
                    bmi       L16D5               yes, start off with a check for TFM
                    fcb       $8C                 skip 2 bytes (cmpx # opcode): same cycle time, 1 byte shorter
* Stack now has:
*   0,s = # pixels per byte (2,4 or 8, 16 bit # for Y compare)
*   2,s = Color mask
*   3,s = Garbage? (LSB of U)
*   Y   = # pixels left in line
* Put single pixels on the screen
L16C7               ldb       <gr0079             Get bit mask for 1st pixel in byte
L16C9               std       <gr0097             Save current color & bit masks
                    jsr       ,u                  put pixel on the screen
                    leay      -1,y                Bump line pixel count down by 1
                    bne       L16C9.2             Still more, keep going
                    puls      pc,x,d              done, restore regs & return when done

L16C9.2             ldd       <gr0097             Get color & bit masks back
* Set up bit pattern for next pixel, including changing byte position
                    jsr       >GrfStrt+L1F08      Set up for next pixel (scrn address & bit mask)
                    bpl       L16C9               (1st bit would be set if next byte, keep going)
* If on last byte, Y<#pixels per byte, so will use above loop
* If not on last byte, Y>#pixels per byte, so can 'cheat' & do 1 byte at a
* time below
L16D5               cmpy      ,s                  Done pixel count for current byte (or last byte)?
                    blo       L16C7               No, keep going
* Draw remainder of line 1 full byte (2,4 or 8 pixels) at a time
* ATD: GrfStrt+L1FA9 is the normal PUT (no fancy stuff) routine
L16D7               equ       *
                    IFNE      H6309
                    tfr       y,d                 get number of pixels left into D
                    divd      1,s                 divide it by the number of pixels in 1 byte
                    pshs      a                   save remainder for later
                    clr       ,-s                 and make remainder on-stack 16-bit
                    pshs      b                   Save # of bytes to do
                    ELSE
*For remainder (do first, since it needs to be on stack first anyways):
*Entry: D=# to divide into
*       1,s = # to divide by (2,4,8)
                    ldb       1,s                 Get # pixels per byte for current screen mode
                    subb      #1                  Make it *001, *011 or *111
                    stb       <grScrtch           Save bit shift counter
                    tfr       y,d                 Move # of pixels left to D
                    andb      <grScrtch           Mask for just remainder
                    clra                          Make 16 bit
                    pshs      d                   Save leftover pixel count on stack
                    tfr       y,d                 # of pixels total again
ShftLp              lsra                          Divide by 2
                    rorb
                    lsr       <grScrtch           Shift # of shifts counter
                    bne       ShftLp              Do 1-3 times depending on mode
                    pshs      b                   Save # of full bytes to do
                    ENDC
* now we have:
* B   = number of bytes to do a full byte at a time
* 0,S = number of bytes to do a full byte at a time
* 1,s = remainder of pixels in last byte to do
* 3,s = pixels per byte
* 5,s = color mask
                    lda       #(GrfStrt+L1F9E)&$00FF point to NO pset vector
                    cmpa      <gr0064+1           is it just a normal color routine?
                    bne       L16E2               no, it's a PSET, so go do it especially
                    IFNE      H6309
                    cmpw      #GrfStrt+L1FA9      is it the normal LSet routine?
                    ELSE
                    pshs      x
                    ldx       <gr00B5             Get "W register"
                    cmpx      #GrfStrt+L1FA9      Is it the normal LSet routine?
                    puls      x
                    ENDC
                    bne       L16E0               no, go use old method
                    clra
                    IFNE      H6309
                    tfr       d,w                 into TFM counter register
                    ENDC
                    leay      5,s                 point to full byte color mask
                    IFNE      H6309
                    tfm       y,x+                move everything else a byte at a time
* LDW MUST go before the call to L16F2!
                    ldw       #GrfStrt+L1FA9      and restore vector to normal LSet routine
                    ELSE
                    pshs      d,x,y,u             Save full byte size, X,Y, start ptr of full byte write
                    leau      ,x                  Point U to start of full byte part of line (WORKS)
                    ldx       ,s                  Get # of full bytes to clear back
* at this point:
* U=ptr to start of full byte part of line
* X=# of bytes to clear
                    ldb       ,y                  Get byte value to clear with
                    lbsr      StkBlClr            Clear it
                    ldd       #GrfStrt+L1FA9      Reset the 'W' vector to normal LSet routine
                    std       <gr00B5
                    puls      d,x                 (9) Get size & start ptr
                    abx                           (3) Point to end of part we clear (we know B<=160)
                    puls      y,u                 (9) Restore Y and U
                    ENDC
L16DE               puls      b                   restore number of full bytes to do
                    lda       3,s                 get number of pixels per byte
                    mul                           get number of pixels done
                    addd      <gr0047             add to current X coordinate
                    std       <gr0047             and save as current X coordinate
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
                    IFNE      H6309
                    subw      #GrfStrt+L1FA3      point to start of LSET routines
                    ELSE
                    pshs      d
                    ldd       <gr00B5             Get "W register"
                    subd      #GrfStrt+L1FA3      Point to start of LSET routines
                    std       <gr00B5             Save new one
                    puls      d
                    ENDC
                    beq       pix.do              skip fancy stuff for XOR
                    IFNE      H6309
                    incf                          go up by one byte
                    ELSE
                    inc       <gr00B6             go up by one byte
                    ENDC
pix.do              ldu       #GrfStrt+Pix.XOR    point to double-byte pixel routines
                    IFNE      H6309
                    leau      f,u                 point U to the appropriate routine
                    tfr       b,f                 move counter to a register
                    ELSE
                    lda       <gr00B6             Get "F register"
                    leau      a,u                 Point U to appropriate routine
                    stb       <gr00B6             Save counter in "F register"
                    ENDC
* LCB 6809/6309 - Put the 16 bit color mask into a direct page location,
*   then yank the TFR a,b out of the loop & do ldd instead:
                    lda       5,s                 grab full-byte color mask
                    tfr       a,b                 make D=color mask
                    std       <grDbCMsk           Save it
pix.next            ldd       <grDbCMsk           Get 16 bit color mask
                    jsr       ,u                  Call 2-byte routine
                    IFNE      H6309
                    decf                          Dec ctr of double-bytes left
                    ELSE
                    dec       <gr00B6             Dec ctr of double-bytes left
                    ENDC
                    bne       pix.next            Still more, keep going
                    IFNE      H6309
                    ldw       <gr0068             get LSET vector
                    ELSE
                    ldu       <gr0068             get LSET vector
                    stu       <gr00B5             Save in "W register"
                    ENDC
                    ldu       <gr0064             and PSET vector again
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
                    addd      <gr0047             Update 'working' X-cord to reflect pixels we did
                    std       <gr0047             Save result
                    dec       ,s                  decrement counter
                    bne       L16E2               continue until done
                    leas      1,s                 kill the counter off of the stack
                    bra       L16DF               restore 16-bit pixel remainder, and do last byte

L16F2               puls      pc,x,d              Restore regs & return when done

* Fast vertical line routine
L16F4               bsr       L1716               Make sure Y coords in right order
L16F6               ldd       <gr004D             Calculate height of line in pixels
                    subb      <gr0049+1
                    incb                          Base 1
                    std       <gr0099             Save height
                    lbsr      L1E9D               Calculate screen address & pixel mask
                    lda       <gr0061             Get color mask
                    std       <gr0097             Save color & pixel masks
                    ldy       <gr0099             Get Y pixel counter
L1707               ldd       <gr0097             Get color & pixel mask
                    jsr       ,u                  Put pixel on screen
                    ldb       <gr0063             Get # bytes to next line on screen
                    abx                           Point to it
                    inc       <gr0049+1           Bump up working Y coord
                    leay      -1,y                Dec. Y counter
                    bne       L1707               Do until done
                    rts

* Swap Y coords so lower is first
L1716               ldd       <gr004D             Get current Y coord
                    cmpd      <gr0049             Compare with destination Y coord
                    bge       L1723               If higher or same, done
L171D               ldx       <gr0049             Get destination Y coord
                    std       <gr0049             Save start Y coord as destination
                    stx       <gr004D             Save destination Y coord as start
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
L1F08               inc       <gr0047+1           Inc LSB of working X coord
                    bne       L1F0E               Didn't wrap, skip ahead
                    inc       <gr0047             Inc MSB of working X coord
L1F0E               lsrb                          Shift to next bit mask
                    bcs       L1F18               Finished byte, reload for next
                    jmp       [>GrfMem+gr0077]    Shift B more (if needed) depending on scrn type

L1F18               ldb       #1                  Bump screen address by 1
                    abx
                    ldb       <gr0079             Get start single pixel mask (1,2 or 4 bits set)
                    rts

* Routine to move left for Normal Line L177D. Needed to get correct symmetry
LeftMV              std       <grScrtch           Save D
                    ldd       <gr0047             Get X coord
                    subd      #1                  Dec by 1
                    std       <gr0047             Save it back
                    ldd       <grScrtch           Restore D
Lmore               lslb
                    bcs       Lmore2
                    jmp       [>GrfMem+gr007A]
Lmore2              leax      -1,x
                    ldb       <gr007C
                    rts

* A dX or dY of 1 will step the line in the middle. The ends of the line
* are not swapped. The initial error is a function of dX or dY.
* A flag for left/right movement <$12 is used.
* Normal line routine
L1724               clr       <gr0012             flag for X swap
                    ldd       <gr004B             current X
                    subd      <gr0047             new X
                    std       <gr0013             save dX
                    bpl       L1734
                    com       <gr0012             flag left movement
                    IFNE      H6309
                    negd                          make change positive
                    ELSE
                    nega                          make change positive
                    negb
                    sbca      #0
                    ENDC
                    std       <gr0013             force dX>0
L1734               ldb       <gr0063             Get bytes/row into D
                    clra
                    std       <gr0017             save 16-bit bytes per line
                    ldd       <gr004D             current Y
                    subd      <gr0049             subtract working Y
                    std       <gr0015             save dY
                    bpl       L1753               if positive
                    IFNE      H6309
                    negd                          make change positive
                    ELSE
                    nega                          make change positive
                    negb
                    sbca      #0
                    ENDC
                    std       <gr0015             force dY>0
                    ldd       <gr0017             up/down movement; up=+ down=-
                    IFNE      H6309
                    negd                          Swap direction
                    ELSE
                    nega                          Swap direction
                    negb
                    sbca      #0
                    ENDC
                    std       <gr0017             now points the correct direction
L1753               ldd       <gr0013             compare dX with dY to find larger
                    cmpd      <gr0015
                    bcs       Ylarge
                    IFNE      H6309
                    asrd                          error = dX/2
                    bra       Lvector

Ylarge              ldd       <gr0015
                    negd
                    asrd                          error = -dY/2
                    ELSE
                    asra                          error = dX/2
                    rorb
                    bra       Lvector

Ylarge              ldd       <gr0015
                    nega
                    negb
                    sbca      #0
                    asra                          error = -dY/2
                    rorb
                    ENDC
Lvector             std       <gr0075             error term
                    lbsr      L1EF1               Set up <$77 right bit shift vector & <$79 pixel mask
* for symmetry
                    lbsr      L1F1D               Set up <$7A left bit shift vector & <$79 pixel mask
                    lbsr      L1E9D               Calculate screen addr into X & pixel mask into B
                    stb       <gr0074             Save pixel mask
L1760               ldb       <gr0074             Get pixel mask
                    lda       <gr0061             Get color mask
                    jsr       ,u                  Draw pixel
L1788               ldd       <gr0047             finished with X movement?
                    cmpd      <gr004B
                    bne       L1788b
                    ldd       <gr0049             finished with Y movement?
                    cmpd      <gr004D
                    bne       L1788b
                    rts                           finished so return

L1788b              ldd       <gr0075             get error
                    bpl       L177D               if >=0
                    addd      <gr0013             add in dX
                    std       <gr0075             save new working error
                    ldd       <gr0017             get bytes per line
                    IFNE      H6309
                    addr      d,x
                    bcs       L1779               test direction not result
                    ELSE
                    leax      d,x                 will not change regCC N
                    bmi       L1779
                    ENDC
                    inc       <gr0049+1           go down one Y-line
                    bra       L1760

L1779               dec       <gr0049+1           decrement y-count
                    bra       L1760

L177D               subd      <gr0015             take out one BPL
                    std       <gr0075             save new count
                    ldb       <gr0074             grab pixel mask
                    tst       <gr0012             flag for left/right movement
                    bne       L177D2              Left; go move left 1 pixel
                    lbsr      L1F08               go right one pixel
L177D3              stb       <gr0074             save new pixel mask
                    bra       L1760               loop to draw it

L177D2              lbsr      LeftMV              go left one pixel
                    bra       L177D3              Save new pixel mask & loop to draw it

* Box entry point
* The optimizations here work because the special-purpose horizontal and
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
                    IFNE      H6309
                    ldq       <gr0047             Copy upper left coords: SX,SY
                    stq       ,s                  save on the stack
                    ELSE
                    ldd       <gr0049             Get upper left Y coord
                    std       2,s                 Save on stack
                    ldd       <gr0047             Get upper left X coord
                    std       ,s                  Save on stack
                    ENDC
                    pshs      y                   Save window table ptr
                    IFNE      H6309
                    ldw       <gr0068             Get LSET vector
                    ELSE
                    stx       <grScrtch
                    ldx       <gr0068             Get LSET vector
                    stx       <gr00B5             Save in "W Register"
                    ldx       <grScrtch
                    ENDC
* enters with SX,SY ; EX,EY
                    lbsr      L168D               Do top fast horizontal line: 0,0 -> X,0
* leaves with $47-$4D = EX+1,SY ; EX,EY
                    ldd       <gr004B             grab EX+1 (incremented after line)
                    std       <gr0047             save proper EX
                    ldy       ,s                  grab window table pointer again: for L1E9D call
                    lbsr      L16F6               Do right fast vertical line: X,0 -> X,Y
* leaves with $47-$4D = EX,EY+1 ; EX,EY
                    ldd       4,s                 get SY
                    std       <gr0049             save SY again
                    ldd       2,s                 get SX
                    std       <gr0047             save SX again
                    ldy       ,s                  get window table ptr
* enters with SX,SY ; EX,EY
                    lbsr      L16F6               Do left fast vertical line 0,0 -> 0,Y
* leaves with $47-$4D = SX,EY ; EX,EY
                    ldy       ,s                  restore window table pointer
                    ldd       <gr004D             grab EY+1 (incremented after line)
                    std       <gr0049             save EY
                    lbsr      L168D               Do bottom fast horizontal line: 0,Y -> X,Y
                    leas      6,s                 Eat stack buffer
                    clrb                          No error & return
L17F9               jmp       >GrfStrt+SysRet

* Bar entry point
L17FB               lbsr      I.Line              internal line/bar/box routine
                    bcs       L1853               Error, return with it
                    lbsr      L16A3               Make sure X coords in right order
                    lbsr      L1716               Make sure Y coords in right order
                    IFNE      H6309
                    ldw       <gr0068             Get LSET vector
                    ELSE
                    ldd       <gr0068             Get LSET vector
                    std       <gr00B5             Save in "W Register"
                    ENDC
* internal BAR routine called from CLS for non-byte boundary clear to EOL
i.bar               ldd       <gr0047             grab start X coordinate
                    std       <gr0099             save it for later
                    subd      <gr004B             take out end X coordinate
                    IFNE      H6309
                    negd                          negate it
                    incd                          add one
                    ELSE
                    coma                          negate it and add 1
                    comb
                    addd      #2
                    ENDC
                    std       <gr009B             save for later
                    lbsr      L1EF1               Set up <$79 bit mask & <$77 bit shft vector
                    lbsr      L1E9D               Calculate scrn ptr & 1st bit mask
                    lda       <gr0061             Get foreground color mask
                    std       <gr009D             Save color mask & pixel mask
                    ldd       <gr004D             Get current Y
                    subb      <gr0049+1           Subtract working Y
                    incb                          +1
                    tfr       d,y                 Move # of horizontal lines to draw to Y
L1839               pshs      y,x                 Preserve # lines left & screen ptr
                    ldy       <gr009B
                    ldd       <gr009D             Get color & pixel masks
                    lbsr      L16B5               Do fast horizontal line
                    puls      y,x                 Get # lines left & screen ptr
                    ldb       <gr0063             Bump ptr to start of next line in bar
                    abx
                    inc       <gr0049+1           Bump up Y coord
                    ldd       <gr0099             get saved starting X coordinate
                    std       <gr0047             save as current X coordinate
                    leay      -1,y                Bump line counter
                    bne       L1839               Draw until done
                    clrb                          No error & return
L1853               jmp       >GrfStrt+SysRet

* Circle entry point
L1856               bsr       L1884               Map in screen & make sure its a graphics window
                    ldd       <gr0053             Get horizontal radius
                    IFNE      H6309
                    lsrd                          Calculate vertical radius for 'perfect circle'
                    ELSE
                    lsra                          Calculate vertical radius for 'perfect circle'
                    rorb
                    ENDC
                    std       <gr0055             Vertical radius=Horizontal radius/2
                    bra       L18BF               Go to appropriate place in ellipse routine

* Arc entry point
L1860               bsr       L1884               Map in screen & make sure its a graphics window
                    lbsr      L1E05               Go scale start 'clip' coords, check if legal
                    bcs       L1853               Illegal coordinate, exit with error
                    lbsr      L1E24               Go scale end 'clip' coords, check if legal
                    bcs       L1853               Illegal coordinate, exit with error
                    ldd       <gr0020             Get start clip X coord
                    cmpd      <gr0024             Same as end clip X coord?
                    bne       L188E               No, skip ahead
                    ldx       #GrfStrt+L1A9D      Point to vertical line clip vector
                    ldd       <gr0022             Get start clip Y coord
                    cmpd      <gr0026             Same as end clip Y coord?
                    blt       L18B3               If lower, skip ahead
                    ldx       #GrfStrt+L1AA4      End X clip is to right of Start vector
                    bra       L18B3               Go save vector & continue

L1884               lbsr      L0177               Map in window
                    ldb       <Gr.STYMk           Get screen type
                    lbmi      L0569               If text, return with Error 192
                    ldb       Wt.PBlk,y           Get Pattern memory block
                    beq       L18BC               None, exit to a convenient RTS
                    lbra      L017C               Map that block in

* Different X coord clip coords
L188E               ldx       <gr0022             Get start Y coord
                    cmpx      <gr0026             Same as end Y coord?
                    bne       L18A3               No, skip ahead
                    ldx       #GrfStrt+L1AAB      Point to horizontal line clip vector
                    cmpd      <gr0024             Is start X coord left of end X coord?
                    blt       L18B3               Yes, use this vector
                    ldx       #GrfStrt+L1AB1      Point to horizontal line/to right vector
                    bra       L18B3               Go save the vector & continue

* Different X & Y clip coords
L18A3               ldx       #GrfStrt+L1AB7      Point to 'normal' Arc Clip line vector
                    ldd       <gr0020             Get start X coord
                    subd      <gr0024             Calculate X clip line width
                    std       <gr0097             Save it
                    ldd       <gr0022             Get start Y coord
                    subd      <gr0026             Calculate Y clip line height
                    std       <gr0099             Save it
                    bra       L18B3               Go save vector & continue

L18B7               lbsr      L1B3B               Copy 5 byte integer from ,Y to ,X
* Shift 5 byte number pointed to by X to the left 1 bit
L1BDD               lsl       4,x                 (four 7 cycles & one 6 cycle)
                    IFNE      H6309
                    ldq       ,x                  Get rest of 5 byte #
                    rolw                          Shift it all left
                    rold
                    stq       ,x                  Store result
                    ELSE
                    ldd       2,x
                    rolb
                    rola
                    std       2,x
                    std       <gr00B5             Save in "W register". I don't know if this needed on 6809.
                    ldd       ,x
                    rolb
                    rola
                    std       ,x
                    ENDC
L18BC               rts                           Exit

* Ellipse entry point
L18BD               bsr       L1884               Map in screen & make sure its a graphics window
* Circle comes here after a little set up
L18BF               ldx       #GrfStrt+L1ABB      Point to 'no clipping' routine
L18B3               stx       <gr00A1             Preserve clipping vector
* Clipping vector setup, start processing ARC
L18C5               lbsr      L1DF6               Make sure coord's & scaling will work
                    bcs       L18D4               Error, return to system with error #
                    lbsr      L1E28               Go make sure X & Y Radius values are legit
L18D4               lbcs      L1A75               Nope, exit with error
                    IFNE      H6309
                    ldq       <gr0047             Get Draw pointer's X & Y Coordinates
                    stq       <gr0018             Make working copies
                    clrd                          Set some variable to 0
                    ELSE
                    ldd       <gr0047             Get Draw ptrs X coord
                    std       <gr0018             Save working copy
                    ldd       <gr0049             Get Draw ptrs Y coord
                    std       <gr001A             Save working copy
                    clra
                    clrb
                    ENDC
                    std       <gr001C             Store it
                    ldd       <gr0055             Get Y radius value
                    std       <gr001E             Save working copy
                    leas      <-$3E,s             Make a 62 byte working stack area
                    sty       <$3C,s              Preserve Y in last 2 bytes of stack area
                    leax      5,s                 Point X into stack working area
                    ldd       <gr0053             Get horizontal radius
                    lbsr      L1BA1.0             ATD: lbsr L1B32 moved for size
                    leay      ,x
                    leax      <$14,s
                    ldd       <gr0055             Get vertical radius
                    lbsr      L1BB1
                    leax      $0A,s
                    bsr       L18B7
                    leay      ,x
                    leax      $0F,s
                    bsr       L18B7
                    leax      <$19,s
                    ldd       <gr0055             Get vertical radius
                    lbsr      L1BA1.0             ATD: lbsr L1B32 moved for size
                    leay      ,x
                    leax      <$1E,s
                    bsr       L18B7
                    leay      ,x
                    leax      <$23,s
                    bsr       L18B7
                    leax      <$28,s
                    lbsr      L1B32.0             ATD: CLRD moved for size
                    leax      <$2D,s
                    ldd       <gr001E             Get working copy Y radius
                    lbsr      L1B32
                    IFNE      H6309
                    decd      Doesn't             affect circle
                    ELSE
                    subd      #1
                    ENDC
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
                    leay      ,x
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
                    leay      ,x
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
                    ldd       <gr001E             Dec some sort of counter
                    IFNE      H6309
                    decd      Doesn't             affect circle
                    ELSE
                    subd      #1
                    ENDC
                    std       <gr001E             Save updated value
L19A0               leax      <$37,s
                    leay      <$23,s
                    bsr       L19C3
                    leay      ,x
                    bsr       L19C3.0             ATD: LEAX moved for size
                    leax      <$28,s
                    leay      <$19,s
                    bsr       L19C3
                    ldd       <gr001C
                    IFNE      H6309
                    incd                          Doesn't affect circle
                    ELSE
                    addd      #1
                    ENDC
                    std       <gr001C
                    bra       L1970

L19C0.0             ldd       <gr001E             ATD: moved here for size
L19C0               jmp       >GrfStrt+L1BA1

L19C3.0             leax      <$2D+2,s            ATD: moved here for size
L19C3               jmp       >GrfStrt+L1B7A      add 40 bit [X] = [X] + [Y]

L19C6.0             leay      <$0F+2,s            ATD: moved here for size
L19C6               lbsr      L1B3B
                    jmp       >GrfStrt+L1C11      negate 5-byte integer, return from there

L19CC               leax      <$2D,s
                    ldd       <gr001C
                    lbsr      L1B32
                    IFNE      H6309
                    incd                          Doesn't affect circle
                    ELSE
                    addd      #1
                    ENDC
                    bsr       L19C0
                    leay      <$1E,s
                    lbsr      L1BB4
                    leax      ,s
                    ldd       <gr001E
                    lbsr      L1B32
                    subd      #$0002
                    bsr       L19C0
                    lbsr      L1B63               ATD: LDD moved for size
                    leay      $0A,s
                    lbsr      L1BB4
                    leay      ,x
                    bsr       L19C3.0             ATD: LEAX moved for size
                    leax      ,s
                    leay      $0A,s
                    bsr       L19C6
                    lbsr      L1B63               ATD: LDD moved for size
                    leay      <$19,s
                    lbsr      L1BB4
                    leay      ,x
                    bsr       L19C3.0             ATD: LEAX moved for size
                    leax      <$32,s
                    leay      <$23,s
                    lbsr      L1B3B
                    ldd       <gr001C
                    bsr       L19C0
                    leax      <$37,s
                    bsr       L19C6.0             ATD: LEAY moved for size
                    bsr       L19C0.0             ATD: LDD moved for size
                    leay      $0A,s
                    bsr       L19C3
L1A32               ldd       <gr001E
                    cmpd      #-1                 (was $FFFF) change to INCD?
                    beq       L1A71               won't be affected by INCD: exit routine
                    bsr       L1A78               draw pixel: shouldn't be affected by INCD
                    tst       <$2D,s
                    bpl       L1A57
                    leax      <$32,s
                    leay      <$23,s
                    bsr       L1A6E
                    leay      ,x
                    bsr       L1A6E.0             ATD: LEAX moved for size
                    ldd       <$001C
                    IFNE      H6309
                    incd                          Doesn't affect Circle
                    ELSE
                    addd      #1
                    ENDC
                    std       <gr001C
L1A57               leax      <$37,s
                    leay      $0F,s
                    bsr       L1A6E
                    leay      ,x
                    bsr       L1A6E.0             ATD: LEAX moved for size
                    ldd       <gr001E             Get value
                    IFNE      H6309
                    decd      Doesn't             affect circle
                    ELSE
                    subd      #1
                    ENDC
                    std       <gr001E             Save updated value& loop back
                    bra       L1A32

L1A6E.0             leax      <$2D+2,s            ATD: moved here for size
L1A6E               jmp       >GrfStrt+L1B7A

L1A71               leas      <$3E,s              Eat our temp 62 byte stack; exit w/o error
                    clrb
L1A75               jmp       >GrfStrt+SysRet

* Draw all 4 points that one calculation covers (opposite corners)
* (Ellipse & Circle)
L1A78               ldy       <$3E,s              Get window table ptr back (for [>GrfMem+gr00A1])
                    ldd       <gr001C             grab current X offset from center
                    ldx       <gr001E             grab current Y offset from center
* At this point, add check for filled flag. If set, put x,y pairs in
* for line command call (with bounds checking) & call line routine 2 times
* (once for top line, once for bottom line)
                    tst       <gr00B2             We doing a Filled Ellipse/Circle?
                    beq       NotFill             No, do normal
                    bsr       SetX                Do any adjustments to start X needed
                    std       <gr0047             Save as start X
                    std       <gr00AD             Save copy
                    ldd       <gr001C             Get current X offset again
                    IFNE      H6309
                    negd                          Negate for coord on other side of radius
                    ELSE
                    coma                          Negate for coord on other side of radius
                    comb
                    addd      #1
                    ENDC
                    bsr       SetX                Do any adjustments
                    std       <gr004B             Save end X coord
                    std       <gr00AF             Save Copy
                    tfr       x,d                 Copy current Y offset into D
                    pshs      x,y,u               Preserve regs for HLine call
                    bsr       DoHLine             Do line (if necessary)
                    ldy       2,s                 Get window table ptr back for checks
                    IFNE      H6309
                    ldq       <gr00AD             Get original start/end X coords back
                    std       <gr0047             Save Start X back
                    stw       <gr004B             Save End X back
                    ELSE
                    ldd       <gr00AF             Get original end X coord back
                    std       <gr00B5             Save in "W Register"
                    std       <gr004B             Save end X coord back
                    ldd       <gr00AD             Get original start X coord back
                    std       <gr0047             Save start X coord back
                    ENDC
                    ldd       ,s                  Get Y coord back
                    IFNE      H6309
                    negd                          Negate for coord on other side of radius
                    ELSE
                    coma                          Negate for coord on other side of radius
                    comb
                    addd      #1
                    ENDC
                    bsr       DoHLine             Do line (if necessary)
                    puls      x,y,u,pc            Restore regs & return

* NOTE: THIS WILL MODIFY <$47 AS IT GOES THROUGH THE LINE!
DoHLine             bsr       SetY                Do Y adjustments
                    cmpa      #$FF                Off window?
                    beq       SaveStrX            Yes, return without drawing
                    std       <gr0049             Save Y coord for fast horizontal line
                    IFNE      H6309
                    ldw       <gr0068             Get LSET vector
                    ELSE
                    ldu       <gr0068             Get LSET vector
                    stu       <gr00B5             Save in "W register"
                    ENDC
                    ldu       <gr0064             Get PSET vector
                    jmp       >GrfStrt+L168B      Call fast horizontal line & return from there

* Calc X coord & make sure in range
SetX                addd      <gr0018             Add working X center point
                    bmi       OffLeft             Off left hand side, use 0
                    cmpd      Wt.MaxX,y           Past right hand side?
                    bls       SaveStrX            No, save start X
                    ldd       Wt.MaxX,y           Get right side of window
SaveStrX            rts

OffLeft             equ       *
                    IFNE      H6309
                    clrd                          0 X Coord start
                    ELSE
                    clra                          0 X Coord start
                    clrb
                    ENDC
                    rts

* Calc Y coord & make sure in range
SetY                addd      <gr001A             Add working Y center point
                    bmi       OffTop              Off top, not drawable
                    cmpd      Wt.MaxY,y           Past bottom?
                    bhi       OffTop              Yes, not drawable
SaveStrY            rts

OffTop              lda       #$FF                Flag that it is off the window
                    rts

* Not filled circle or ellipse
NotFill             bsr       L1A97               Draw X,Y
                    IFNE      H6309
                    negd                          invert X
                    ELSE
                    coma                          invert X
                    comb
                    addd      #1
                    ENDC
                    bsr       L1A97               Draw -X,Y
                    exg       d,x                 Invert Y
                    IFNE      H6309
                    negd                          invert X
                    ELSE
                    coma                          invert X
                    comb
                    addd      #1
                    ENDC
                    exg       d,x
                    bsr       L1A97               Draw inverted X, inverted Y pixel
                    ldd       <gr001C             Last, draw X,-Y
L1A97               pshs      x,d                 Preserve x,y coords
                    jmp       [>GrfMem+gr00A1]    Draw point (L1ABB if circle/ellipse)

* NOTE: THE FOLLOWING 6 LABELS (L1A9D, L1AA4, L1AAB, L1AB1, L1AB7 & L1ABB)
*   ARE POINTED TO BY >GrfMem+gr00A1, DEPENDING ON WHETHER ARC IS ON OR NOT, AND THE
*   COORDINATES ARE WITHIN CERTAIN BOUNDARIES. THE ENTRY CONDITIONS FOR ALL
*   6 OF THESE ARE (AND NOTE THAT THESE ARE SIGNED):
* D=X coord offset from center point
* X=Y coord offset from center point
* (ARC) Vertical clip line, start Y > end Y coord vector
L1A9D               cmpd      <gr0020             >= start clip X coord?
                    bge       L1ABB               Yes, go draw point
                    puls      pc,x,d              No, return

* (ARC) Vertical clip line, start Y < end Y coord vector
L1AA4               cmpd      <gr0020             <= start clip X coord?
                    ble       L1ABB               Yes, go draw point
                    puls      pc,x,d              No, return

* (ARC) Horizontal clip line, start X < end X coord vector
L1AAB               cmpx      <gr0022             <= start clip Y coord?
                    ble       L1ABB               Yes, go draw point
                    puls      pc,x,d              No, return

* (ARC) Horizontal clip line, start X > end X coord vector
L1AB1               cmpx      <gr0022             >= start clip Y coord?
                    bge       L1ABB               Yes, go draw point
                    puls      pc,x,d              No, return

* (ARC) Clip line is diagonal in some way
L1AB7               bsr       L1ADF               Check if within range of diagonal clip line
                    bgt       L1ADD               If out of range, don't put pixel on screen
* Entry point for 'No clipping' routine pixel put
* Entry: D=X offset from center point
*        X=Y offset from center point
L1ABB               addd      <gr0018             Add X offset to center point X
                    bmi       L1ADD               Off of left side of window, don't bother
                    cmpd      Wt.MaxX,y           Past right side of window?
                    bhi       L1ADD               Yes, don't bother
                    std       <gr0047             Save X for Point routine
                    tfr       x,d                 Move Y offset to D
                    addd      <gr001A             Add Y offset to center point Y
                    bmi       L1ADD               Off of top of window, don't bother
                    cmpd      Wt.MaxY,y           Past bottom of window?
                    bhi       L1ADD               Yes, don't bother
                    std       <gr0049             Save Y coord for Point routine
                    lbsr      L1E9D               Calculate scrn addr:X, bit mask into B
                    lda       <gr0061             Get color mask
                    IFNE      H6309
                    ldw       <gr0068             Get LSET vector
                    ELSE
                    stx       <grScrtch
                    ldx       <gr0068             Get LSET vector
                    stx       <gr00B5             Save in "W register"
                    ldx       <grScrtch
                    ENDC
                    jsr       [>GrfMem+gr0064]    Put pixel on screen
L1ADD               puls      pc,x,d              Restore regs & return

* Uses signed 16x16 bit multiply
* Called by Arc (probably in clipping coordinates)
L1ADF               pshs      x,d
                    leas      -4,s
                    tfr       x,d
                    subd      <gr0026             Subtract Arc clip line second Y coord
                    IFNE      H6309
                    muld      <gr0097             Calculate 1st result
                    stq       ,s                  Save 24 bit result
                    ELSE
                    pshs      x,y,u
                    ldx       <gr0097
                    bsr       MUL16               Multiply D*X into Y:U
                    sty       6,s                 Save MSW of result
                    stu       8,s                 Save LSW of result
                    stu       <gr00B5             Save U into "W register" MAY NOT BE NEEDED ON 6809
                    puls      x,y,u
                    ENDC
                    ldd       4,s
                    subd      <gr0024             Subtract Arc clip 2nd X coord
                    IFNE      H6309
                    muld      <gr0099             Calculate 2nd result
                    ELSE
                    pshs      x,y,u
                    ldx       <gr0099             Calculate 2nd result
                    bsr       MUL16               Multiply D*X into Y:U
                    stu       <gr00B5             Save U into "W register" THIS ONE IS NEEDED
                    tfr       y,d
                    puls      x,y,u
                    ENDC
                    cmpb      1,s                 Compare high byte with original multiply
                    bne       L1AF9               Not equal, exit with CC indicating that
                    IFNE      H6309
                    cmpw      2,s                 Check rest of 24 bit #
                    ELSE
                    ldd       <gr00B5             Check rest of 24 bit #
                    cmpd      2,s
                    ENDC
L1AF9               leas      4,s                 Eat our buffer
                    puls      pc,x,d              Restore regs & return

                    IFEQ      H6309
* Original code was unsigned only routine - which breaks with relative coords, etc.
* Preserves original D:X, returns 32 bit signed D*X in Y:U, and
*   sets CC flags for compare
* 16x16 SIGNED multiply
* Entry: X=16 bit signed #1
*        D=16 bit signed #2
* NOTE: This only calculates up to 24 bits (then pads to 32), since that is
*   all that Grfdrv actually needs. It should also be noted that the original
* Tandy/Microware Grfdrv I think only did 24 bits to speed it up.
* Exit:  Y:U = 32 bit signed result, and CMP bits set in CC
MUL16               pshs      x,d
                    lda       3,s
                    mul
                    pshs      d
                    lda       5,s
                    ldb       2,s
                    mul
                    addb      ,s+
                    adca      #$00
                    pshs      d
                    ldd       4,s
                    mul
                    addd      ,s
                    std       ,s
                    lda       5,s
                    ldb       3,s
                    mul
                    addb      ,s
                    ldx       1,s
                    tst       3,s
                    bpl       L1B49
                    neg       6,s
                    addb      6,s
L1B49               tst       5,s
                    bpl       L1B51
                    neg       4,s
                    addb      4,s
L1B51               sex                           Force to full 32 bits
                    tfr       d,y                 Move to Y:U
                    tfr       x,u                 DO *NOT* USE LEAU, X HERE - THAT WILL TRASH CC FOR RETURN
                    leas      3,s                 Eat temps
                    puls      d,x,pc              Restore D:X & return
                    ENDC

* Clear 5 bytes at ,x
L1B32.0             equ       *
                    IFNE      H6309
                    clrd                          ATD: moved here for size
L1B32               clrw
                    stw       ,x
                    ste       2,x
                    ELSE
                    clra
                    clrb
L1B32               std       <grScrtch
                    clra
                    clrb
                    std       <gr00B5             Save "W register"  NOT SURE IF NEEDED?
                    std       ,x
                    sta       2,x
                    ldd       <grScrtch
                    ENDC
                    std       3,x
                    rts

* Copy 5 bytes from ,y to ,x
* NOTE: does not preserve W (does preserve D,X,Y)
L1B3B               pshs      d
                    IFNE      H6309
                    ldq       ,y                  Copy 4 bytes from Y to X
                    stq       ,x
                    ELSE
                    ldd       2,y
                    std       <gr00B5             Save "W register"  NOT SURE IF NEEDED?
                    std       2,x
                    ldd       ,y
                    std       ,x
                    ENDC
                    ldb       4,y
                    stb       4,x
                    puls      pc,d

* Copy 5 bytes from ,x to ,u
L1B52               exg       y,u                 Swap registers for subroutine
                    exg       x,y
                    bsr       L1B3B               Copy the 5 bytes
                    exg       x,y                 Restore regs & return
                    exg       y,u
                    rts

* Called by ellipse
* Add 16 bit to 40 bit number @ X (but don't carry in 5th byte)
L1B63               ldd       #$0001              for circle, etc. above
L1B64               pshs      d
                    addd      3,x
                    std       3,x
                    ldd       #$0000              For using carry
                    IFNE      H6309
                    adcd      1,x
                    ELSE
                    adcb      2,x
                    adca      1,x
                    ENDC
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
                    IFNE      H6309
                    adcd      1,y
                    ELSE
                    adcb      2,y
                    adca      1,y
                    ENDC
                    std       1,x
                    ldb       ,x
                    adcb      ,y
                    stb       ,x
                    puls      pc,d

L1BA1.0             bsr       L1B32               Go clear 5 bytes @ ,x
L1BA1               pshs      y,d
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
                    pshs      d                   Put 3 0's on stack
                    pshs      b
                    leay      ,s                  Point Y to the 3 0's
                    bsr       L1BB4
                    leas      3,s
                    puls      pc,y,d

L1BB1               bsr       L1B32               Make 5 byte integer of D @ X
L1BB4               pshs      u,y,d               Preserve regs on stack
                    leas      -10,s               Make buffer for two 5 byte integers
                    leau      ,s                  Point U to first buffer
                    exg       x,u                 Swap temp ptr with X ptr
                    bsr       L1B3B               Copy 5 byte # from Y to X (into 1st temp buffer)
                    exg       x,u                 Swap ptrs back
                    leay      ,u                  Move stack ptr to Y
                    leau      5,u                 Point U to 2nd 5 byte buffer
                    bsr       L1B52               Copy 5 bytes from ,X to ,U
                    IFNE      H6309
                    bsr       L1B32.0             Clear 5 bytes @ ,X
                    ELSE
                    lbsr      L1B32.0             Clear 5 bytes @ ,X
                    ENDC
                    bra       L1BCB

* Multiply 5 byte integer by 2 at ,Y
L1BC9               lsl       4,y                 Multiply 5 byte integer by 2
                    IFNE      H6309
                    ldq       ,y
                    rolw
                    rold
                    stq       ,y
                    ELSE
                    ldd       2,y
                    rolb
                    rola
                    std       2,y
                    ldd       ,y
                    rolb
                    rola
                    std       ,y
                    ENDC

* Loop-Divide U by 2 until U=0 or uneven divide
*  (each time, multiply Y by 2)
* When U=0 & no remainder, exits
* When U=0 & remainder, 5 byte # @ X = that # + 5 byte # @ Y
* NOTE: 6309 - If it works, change below & L1C06 to use LDQ/RORD/RORW/STQ
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

* Negate 5 byte integer w/o using registers
* 6809/6309 - check calling routines; if they don't need D (or Q), we
* may be able to speed this up.
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

* 5 byte compare ,x to ,y. Exits with CC set for higher, equal or lower
L1C2E               pshs      d
                    ldd       ,x
                    cmpd      ,y
                    bne       L1C4D
                    ldd       2,x
                    cmpd      2,y
                    bne       L1C44
                    ldb       4,x
                    cmpb      4,y
                    beq       L1C4D               Exit with zero flag set
L1C44               bhi       L1C4A               set CC for higher
                    lda       #$08                Negative flag bit for CC (set CC for less than)
                    fcb       $21                 skip one byte: same cycle time, 1 byte smaller
L1C4A               clra
L1C4B               tfr       a,cc
L1C4D               puls      pc,d


* FFill entry point
L1C4F               lbsr      L1884               ATD: +11C:-6B  exit if screen is text
                    clra
                    clrb                          Clear # of stack overflows
                    std       <gr00A7             Set flag that no stack overflow error on FFill so far
                    incb
                    stb       <gr00B1             LCB:Set flag that this is the 1st time through
                    ldb       #32                 Max # of times we will check over our start point
                    stb       <gr002A             Set it
                    lbsr      L1DF6               Check/calculate scaling
                    lbcs      L1CBF               Illegal coordinate, exit
* If new technique works, then we only need to copy Y at this point, and leave X start
*  for when we have figured out the line start/end X (both 6809/6309)
                    IFNE      H6309
                    ldq       <gr0047             Get original X,Y start (now scaled)
                    stq       <gr00AD             Save copies
                    ELSE
                    ldd       <gr0049             Get original Y start coord
                    std       <gr00AF             Save copy of original start Y
                    ldd       <gr0047             Get original X start coord
                    std       <gr00AD             Save copy of original start X
                    ENDC
                    lbsr      L1E9D               Calculate screen address to start filling @
                    stx       <gr0072             Save ptr to start pixel on physical screen
                    stb       <gr0074             Save bit mask for start pixel
* replaced the code above with this: slightly larger, but L1F4B is smaller,
* and this code is only executed once, while L1F4B is executed many times
* the additional benefit is that <$0028 is now the full-byte color mask
* instead of the single pixel mask, and we can do byte-by-byte checks!
                    andb      ,x                  get first pixel: somewhere in the byte...
                    ldx       #GrfStrt+L075F-1    point to table of pixel masks
                    lda       <Gr.STYMk           Get screen type
                    lda       a,x                 Get subtable ptr
                    leax      a,x                 Point to proper screen table
                    lda       2,x                 skip mask, color 0, get color 1 full-byte mask
                    mul                           multiple color by $FF, $55, or $11 (1,4,16-color)
                    IFNE      H6309
                    orr       b,a                 bits are all mixed up: OR them together
                    ELSE
                    stb       <grScrtch           bits are all mixed up: OR them together
                    ora       <grScrtch
                    ENDC
* now A = full-byte color mask for the color we want to FFILL on
                    ldx       #GrfStrt+L16B1-1    point to pixels/byte table
                    ldb       <Gr.STYMk           get screen type again
                    ldb       b,x                 get B=pixels per byte
                    std       <gr0028             save full-byte color mask, pixels per byte
* end of inserted code: a bit larger, but MUCH faster in the end
                    cmpa      Wt.Fore,y           background color as current foreground color?
                    beq       L1CB7               Yes, exit if no stack overflow occurred
                    clr       ,-s                 save y-direction=0: done FFILLing (start of would have been dummy 6 byte packet)
                    lbsr      L1EF1               Setup start pixel mask, vector to shift to next pixel for right dir
                    bsr       L1F1D               Setup start pixel mask, vector to shift to next pixel for left dir
                    ldx       <gr0072             Get screen address of pixel we are starting at
                    lbra      L1CC6               Start FFill by painting towards the right

* Setup up bit mask & branch table for Moving to next pixel in left direction
L1F1D               lda       <Gr.STYMk           Get screen type
                    ldx       #GrfStrt+L1F2C-2    Point to table
                    lsla                          x2 for table offset
                    ldd       a,x                 Get mask and branch offset
                    sta       <gr007C             Preserve bit mask (based on far right pixel for color mode)
                    abx                           Store vector to bit shift left to next pixel routine
                    stx       <gr007A             save for later
                    rts

* Bit shift table to shift to the left 3,1 or 0 times
* Used by FFill when filling to the left
L1F2C               fcb       %00000001,L1F45-(L1F2C-2) $1b  640 2-color
                    fcb       %00000011,L1F44-(L1F2C-2) $1a  320 4-color
                    fcb       %00000011,L1F44-(L1F2C-2) $1a  640 4-color
                    fcb       %00001111,L1F42-(L1F2C-2) $18  320 16-color
* Bit shifts based on screen type
L1F42               lslb
                    lslb
L1F44               lslb
L1F45               rts

* Move to right by either 1 pixel or 1 full byte's worth of pixels (if current screen byte is
*  all the same color that we started FFill on)
* Entry: X=ptr to current byte on screen we are checking
*        U=X coord (pixel #)
*        B=Bit shift flags (0001,0011,1111 in least sig nibble) to see when done current byte
* Exit:  X=updated ptr to current byte on screen
*        U=updated X coord (pixel #) - either old+1, or old + 1 full byte added (+2,+4,+8 pixels)
*        B=updated pixel mask for new pixel #
X1F08               lda       <gr0028             get full-byte background color mask
                    cmpa      ,x                  same as the byte we're on?
                    beq       X1F16               yes, no need to check individual bits, skip ahead
                    leau      1,u                 otherwise inc X pixel #
X1F0E               lsrb                          Shift to next bit mask
                    bcs       X1F18               Finished byte, reload for next
                    jmp       [>GrfMem+gr0077]    Shift B more (if needed) depending on scrn type & return from there

* background is a byte value, but we don't know what the X coord is
X1F16               ldb       <gr0029             D=pixels per byte (2,4 or 8)
                    clra
                    IFNE      H6309
                    addr      d,u                 Bump up X pixel # to right by a byte's worth
                    ELSE
                    leau      b,u                 Bump up X pixel # to right by a byte's worth
                    ENDC
                    decb                          make 2,4,8 into 1,3,7
                    IFNE      H6309
                    comd                          get mask
                    andr      d,u                 force it to the left-most pixel of the byte
                    ELSE
                    coma                          get mask
                    comb
                    std       <grScrtch
                    tfr       u,d
                    anda      <grScrtch           force it to the left-most pixel of the byte
                    andb      <grScrtch+1
                    tfr       d,u
                    ldd       <grScrtch
                    ENDC
X1F18               ldb       #1                  Bump screen address by 1
                    abx
                    ldb       <gr0079             Get start single pixel mask (1,2 or 4 bits set)
                    rts

* Switch to next line for FFill
* Entry: 6 byte stack setup (y direction, y pos, x left, x end)
* NOTE: a 0 byte for direction is a special flag (stored at $1FFF - first stack entry)
L1CC2               leas      4,s                 Eat last set of X start ($47), end ($9B)
L1C93               ldb       ,s+                 grab y-direction to travel
                    beq       L1CB7               if zero, we are back at top of stack & are done
                    stb       <gr002B             save direction (signed y offset) to travel in
                    addb      ,s+                 Move to next Y (add to saved Y-coordinate)
                    cmpb      <Wt.MaxY+1,y        check against the maximum Y position
                    bhi       L1CC2               too high, eat X start,end and go DOWN
                    stb       <gr0049+1           save current Y-position
                    puls      d,x                 restore X start, X end
                    std       <gr0047             save it for later
                    stx       <gr004B             save that, too
                    lbsr      L1E9D               get X=logical screen coordinates, B=pixel mask
                    stb       <gr0074             save starting pixel mask
                    jmp       >GrfStrt+L1D40      go do some painting

* Finished; exit cleanly if done filling or return stack overflow error
L1CB7               clrb                          Clear carry as default (no error)
                    ldd       <gr00A7             Get Stack overflow error count
                    beq       L1CBF               No stack overflow detected; exit w/o error
L1CBC               ldb       #E$StkOvf           Stack overflow error
                    coma
L1CBF               jmp       >GrfStrt+SysRet

* Move 1 pixel to left (for FFill)
* Entry: X=ptr to current byte on screen
*        U=X pixel #
*        B=current pixel mask
* <$0028 = full-byte color mask to paint on
* <$0029 = pixels per byte
L1F34               lda       ,x                  get current byte
                    cmpa      <gr0028             full-byte background color?
                    beq       L1F3C               yes, go do full-checks
                    leau      -1,u                drop X pixel # down by 1
                    lslb                          Move pixel mask to left by 1
                    bcs       L1F46               If finished byte, skip ahead
                    jmp       [>GrfMem+gr007A]    Adjust for proper screen type (further LSLB's)

L1F3C               clra                          make A=0
                    ldb       <gr0029             get 16-bit value of pixels per byte
                    decb                          get 7,3,1 pixel mask
                    IFNE      H6309
                    comd                          get pixel mask, with low bits cleared out,
                    andr      d,u                 i.e. ensure we're to the LEFT as far as possible
                    ELSE
                    coma
                    comb
                    std       <grScrtch
                    tfr       u,d                 get pixel mask, with low bits cleared out,
                    anda      <grScrtch           i.e. ensure we're to the LEFT as far as possible
                    andb      <grScrtch+1
                    tfr       d,u
                    ldd       <grScrtch
                    ENDC
                    leau      -1,u                go to the left one pixel
L1F46               ldb       <gr007C             Get start pixel mask (on right side)
                    leax      -1,x                Bump screen's pixel ptr left & return
                    rts

* search until we find the left-most pixel which is NOT the paint on pixel,
* or the edge of the screen (get left pixel position to start paint line at)
* Exits with B=pixel mask
*            W=current X position
*            U=W
FFILL.1             ldb       <gr0074             Get pixel mask for pixel we are doing
                    ldu       <gr0047             Get working X coord
L1CC8               lbsr      L1F4B               check if current pixel color other than background
                    bne       L1CD4               No, backup 1 to last one that was
                    bsr       L1F34               exits with U = x-coord
                    IFNE      H6309
                    cmpr      0,u                 Have we hit left side of window?
                    ELSE
                    cmpu      #0                  Have we hit left side of window?
                    ENDC
                    bpl       L1CC8               we're still on the same color, continue
* we've found the left boundary, go to the right
L1CD4               equ       *
                    IFNE      H6309
                    bra       X1F08               go to the right one pixel or byte: account for extra DECW
                    ELSE
                    lbra      X1F08               go to the right one pixel or byte: account for extra DECW
                    ENDC

* Main FFill loop entered here after initial setup. Note that this is NOT part of the actual
* loop - it just sets up the first line's worth.
L1CC6               bsr       FFILL.1             Get left X coord into U (and bit mask in B)
                    stu       <gr0047             Save working copy
                    stu       <gr009B             save for later
                    stu       <grOrgLtX           Save original left X
                    bsr       FFILL.2             paint to the right, a pixel at a time
                    lda       #-1                 Direction=up (Y offset -1)
                    bsr       L1D05               add stack entry for next UP
                    lda       #1                  Direction=down (Y offset +1)
                    bsr       L1D05               add stack entry for next DOWN
                    bra       L1C93               go do another line

* paint to the right, a pixel at a time.
* Exits with B=pixel mask
* W = current X position
* U = W
FFILL.2             ldu       <gr0047             Get working X pixel #
                    stu       <gr0020             save X-start for this fill routine
                    clr       <gr002C             clear pixel mask (0 also means no pixels done yet)
FFILL.2a            bsr       L1F4B               check if we hit color other than background
                    bne       L1CEA               yes, skip ahead
                    lbsr      X1F08               go to the right one pixel (or full byte if whole byte is background color)
                    stb       <gr002C             Save updated pixel mask
                    cmpu      Wt.MaxX,y           Did we hit right side of window?
                    bls       FFILL.2a            no, keep checking
* we've gone too far to the right
L1CEA               bsr       L1F34               back up one pixel: updates U (pixel #), X (screen byte ptr), B=pixel mask
* ATD: New routine added.  Do a horizontal line from left to right!
* This is not substantially faster, perhaps, but it does look better.
                    pshs      d
                    lda       <gr002C             check flag that we actually have something to draw
                    beq       L1D03               No, save updated X coord & return
* LCB: New routine added to check if we are redoing the 1st pixel we started
* painting at. If we are, exit (Helps fix certain PSet variations that allow
* infinite recursions (loops) that hang Grfdrv - like in SnakeByte game)

* NOTE: THIS IS BREAKING ON SOME MVCANVAS PATTERNS IF WE START ON AN ODD PIXEL
*   NUMBER. IT SEEMS TO BUILD A 6 PIXEL WIDE SECTION (EX. 12-18, 20-26), BUT MISSES
*   THE ODD NUMBERS INBETWEEN, GETTING STUCK IN AN INFINITE LOOP. I FOUND THIS ON
*   ONE SAMPLE USING THE DIAMOND PATTERN TO PAINT, HAPPENING TO PICK AN ODD PIXEL
*   # TO START WITH
* possible solution: Record first ffill line *range* on 1st line
                    lda       <gr00B1             Get flag that we are on 1st line of FFill
                    beq       DoChecks            Not 1st time, do checks
* Now save end X coord of our first actually drawn line (start is already in <gr0020)
                    stu       <grOrgRtX           Is 1st time, save end (right) X coord of first paint line
                    ldd       <gr0020             Get start (left) X coord of first paint line
                    std       <grOrgLtX           Save that too, so we now have X1-X2,Y of first actual painted line
                    clr       <gr00B1             Clear flag & do draw
                    bra       Not1st

DoChecks            ldd       <gr00AF             Get Y value from 1st FFill line
                    cmpd      <gr0049             Same as current?
                    bne       Not1st              No, go draw
* At this point - if we figure out the there is a crossover in the range between our original
* X1-X2 and the new X1 to X2, BSR Not1st (so it still draws it, in case it isn't a full overlap)
* and then fall through to eat the stack and return below
* Entry: U=right X coord of current line to draw
* Now check: if our new line right X coord is <original left, go to Not1st
* if our new line left X coord is > original right, go to Not1st
* otherwise we have an overlap - so BSR Not1st to draw this last line, then fall through eat stack
* and return
                    cmpu      <grOrgLtX           We are on original Y line, is our new right side X < original left?
                    blo       Not1st              Yes, not overlapping, draw normally
                    ldd       <gr0020             Get current left X coord
                    cmpd      <grOrgRtX           is our new left > original right X?
                    bhi       Not1st              Yes, not overlapping, draw normally
* Try #4, simply a way to bail out if we seem stuck in an infinite loop
                    dec       <gr002A             Inc # of times we have passed over original start point
                    bne       Not1st              <=31 continue
                    lbra      L1CB7               >31 Exit (report overflow error if we had an overflow at any point)

Not1st              ldd       <gr004B             get current right X coordinate: U=<$0047 already
                    pshs      d,x,y,u             Save regs so we can get them back after calling horizontal line
                    stu       <gr004B             save right X-end of line to paint
                    ldd       <gr0020             get left X coordinate of line to paint
                    std       <gr0047             save for the line routine
* ATD: warning: This routine trashes W!
                    IFNE      H6309
                    ldw       <gr0068             get LSET vector
                    ELSE
                    ldu       <gr0068             get LSET vector
                    stu       <gr00B5             Save 6809 "W Register" copy
                    ENDC
                    ldu       <gr0064             and PSET vector
                    jsr       >GrfStrt+L1690      do fast horizontal line
                    puls      d,x,y,u             restore registers
                    std       <gr004B             save
L1D03               stu       <gr0047             save updated working X coord
                    puls      d,pc

* Add 6 byte save point on stack:
*   0,s = Y direction (signed: -1=up, +1=down, 0=done filling)
*   1,s = Y position
* 2-3,s = X Start (left) pixel #
* 4-5,s = X End (right) pixel #
* Return to calling routine with these 6 bytes on the stack
*  on the stack
* Entry: A=Y direction (-1,+1, 0=done)
L1D05               puls      u                   Preserve original RTS address from calling routine
                    ldb       <gr0049+1           get B=working Y coordinate
                    pshs      y,x,d               save D, and room for working X start/end coords
                    IFNE      H6309
                    ldw       <gr0047             Get 'working' X coord (End (right) X)
                    ELSE
                    ldd       <gr0047             Get 'working' X coord (End (right) X)
* 6809 - this line is probably not needed
                    std       <gr00B5             Save in "6309 W register" copy
                    std       4,s                 Save end (right) X
                    ENDC
                    ldd       <gr009B             and left-most pixel we were at
                    IFNE      H6309
                    stq       2,s                 save X start (left), end (right) positions on the stack
                    ELSE
                    std       2,s                 save start (left) X
                    ENDC
                    jmp       ,u                  return to calling routine

* ATD: mod: <$0028 is full-byte color mask
* Entry: X=ptr to current byte on screen
*        B=bit mask for current pixel
* Exit:  B=bit mask for current pixel
*        CC set to check if we hit border of FFill
L1F4B               pshs      b                   Preserve pixel mask
                    tfr       b,a                 Duplicate it
                    anda      ,x                  Get common bits between screen/mask
                    andb      <gr0028             and common bits between full-byte color and mask
                    IFNE      H6309
                    cmpr      b,a                 are the 2 colors the same?
                    ELSE
                    stb       <grScrtch
                    cmpa      <grScrtch           are the 2 colors the same?
                    ENDC
                    puls      pc,b                Restore pixel mask & return

* start painting at a new position.
* <$47=start X, <$49=current Y,  <$4B=end X
* Check to the left for bounds
L1D40               ldu       <gr0047             get current X
                    leau      -2,u                go to the left 2 pixels? : wrap around stop pixel
                    stu       <gr009B             save position
                    lbsr      FFILL.1             search to the left
                    bra       L1D58               skip ahead

L1D55               lbsr      X1F08               go to the right one pixel or byte
L1D58               stu       <gr0047             save X coordinate
                    cmpu      <gr004B             check against X-end from previous line
                    lbhi      L1C93               too far to the right, skip this line
                    bsr       L1F4B               check the pixel
                    bne       L1D55               not the same, go to the right
                    stb       <gr0074             save starting pixel mask
                    cmpu      <gr009B             check current X against saved start (X-2)
                    bgt       L1D87               higher, so we do a paint to the right
                    cmps      <gr003B             check against lowest possible stack
                    bhi       StkGd1              Good, continue (add another 6 byte stack save point for fill)
                    ldd       <gr00A7             Bump up stack overflow count
                    IFNE      H6309
                    incd
                    ELSE
                    addd      #1
                    ENDC
                    std       <gr00A7             Save # of overflows detected
                    cmpa      #3                  Have we hit 512?
                    blo       L1D87               No, just skip adding another 6 byte save point on stack & continue
                    lbra      L1CB7               >1023 overflows, abort completely

StkGd1              ldu       <gr009B             grab X (right X?)
                    ldd       <gr0047             grab current X (left X?)
* ATD: removed check for X coord <0, as the above call to X1F08 ensures it's
* at least 0.
                    pshs      d,u                 Save X start, X end coordinates
                    ldb       <gr0049+1           Get Y coord
                    lda       <gr002B             Get current Y-direction (-1 or +1)
                    nega                          Change Y direction
                    pshs      d                   Save direction flag and Y coord
L1D87               ldd       <gr0047             Get current X coord
                    std       <gr009B             Save duplicate (for direction change???)
                    ldb       <gr0074             Get current pixel mask
* Paint towards right side
L1D98               lbsr      FFILL.2
                    stb       <gr0074             Save new start pixel mask
                    cmps      <gr003B             check against lowest possible stack
                    bhi       StkGd2              Good, continue
                    ldd       <gr00A7             Bump up stack overflow count
                    IFNE      H6309
                    incd
                    ELSE
                    addd      #1
                    ENDC
                    std       <gr00A7             Save # of overflows detected
                    cmpa      #3                  Have we hit 1024?
                    blo       L1DAA               No, just skip adding another 6 byte save point on stack & continue
                    lbra      L1CB7               >1023 overflows, abort completely

StkGd2              lda       <gr002B             grab direction flag
                    IFNE      H6309
                    bsr       L1D05               save current X start, end on-stack
                    ELSE
                    lbsr      L1D05               save current X start, end on-stack
                    ENDC
                    ldb       <gr0074             grab starting pixel mask
                    ldu       <gr0047             restore current X-coord
* Small loop
L1DAA               lbsr      X1F08               Adjust for next pixel on the right (or next byte)
                    stb       <gr0074             Save new pixel mask
                    stu       <gr0047             and new X-coord
                    cmpu      Wt.MaxX,y           Hit right side of window?
                    bgt       L1DC4               Yes, skip ahead
                    cmpu      <gr004B             Is current X coord going past Draw ptr X coord?
                    bgt       L1DC4               Yes, skip ahead
                    lbsr      L1F4B               Check if we are hitting a drawn border
                    bne       L1DAA               No, keep FFilling
                    bra       L1D87               paint to RHS of the screen

* could be subroutine call to L1DEE
* saves 6 bytes, adds 10 clock cycles
L1DC4               cmps      <gr003B             Stack about to get too big? (SP=$1CB0 is default check)
                    bhi       L1DCB               No, continue
                    ldd       <gr00A7             Bump up stack overflow count
                    IFNE      H6309
                    incd
                    ELSE
                    addd      #1
                    ENDC
                    std       <gr00A7             Save # of overflows detected
                    cmpa      #3                  Have we hit 1024?
                    blo       L1DCB               No, continue
                    lbra      L1CB7               >1023 overflows, abort completely

L1DCB               leau      -1,u                go to the left one pixel
                    stu       <gr0047             Save X coord
                    ldd       <gr004B             Get draw ptr X coord
                    addd      #2                  Bump up by 2
                    IFNE      H6309
                    cmpr      u,d                 Past current X coord in FFill?
                    ELSE
                    stu       <grScrtch           Past current X coord in FFill?
                    cmpd      <grScrtch
                    ENDC
                    lbhi      L1C93               Yes, go change Y-direction
                    pshs      d,u                 Save draw ptrs X+2, current X coord
                    ldb       <gr0049+1           Get working Y coord
                    lda       <gr002B             get y-direction flag
                    nega                          Change direction
                    pshs      d                   Save direction flag and Y coord
L1DEB               jmp       >GrfStrt+L1C93      go do another direction

* Check validity & scale X/Y coords
L1DF6               ldb       #gr0047             get offset in grfdrv mem to working X coord
* Entry point if using different X/Y coord (current coord, current size)
* B=Offset into GRFDRV global mem to get coord pair
L1DF8               bsr       L1E2C               Scale X/Y coord pair if scaling is turned on
* Check requested X/Y co-ordinates to window table to see if they are in range
                    IFNE      H6309
                    ldq       ,x                  Get requested X & Y coordinates
                    ELSE
                    ldd       2,x                 Get requested Y coordinate
                    std       <gr00B5             Save copy in "W register"
                    ldd       ,x                  Get requested X coordinate
                    ENDC
                    cmpd      Wt.MaxX,y           X within max. range of window?
                    bhi       L1E99               No, return error
                    IFNE      H6309
                    cmpw      Wt.MaxY,y           Y within max. range of window? (keep it 16-bit)
                    ELSE
                    pshs      x
                    ldx       <gr00B5             Get "W register"
                    cmpx      Wt.MaxY,y           Y within max. range of window? (keep it 16-bit)
                    puls      x
                    ENDC
                    bhi       L1E99               No, return error
                    andcc     #^Carry             They work, return without error
                    rts

L1E99               comb                          set carry
                    ldb       #E$ICoord           get error code
                    rts                           return

L1DFD               ldb       #gr004B             Get offset in grfdrv mem to current X,Y coord
                    bra       L1DF8

L1E01               ldb       #gr004F             Get offset in Grfdrv mem to X,Y size
                    bra       L1DF8

L1E05               ldb       #gr0020             Point to Arc 'clip line' Start coordinate
* Check both X and Y coordinates and see if valid (negative #'s OK)
* Entry : B=Offset into GRFDRV mem to get X & Y (16 bit) coordinates
L1E07               bsr       L1E2C               Do offset of X into grfdrv space by B bytes
                    IFNE      H6309
                    ldw       #639                Maximum value allowed
                    ELSE
                    ldd       #639                Maximum value allowed
                    std       <gr00B5             Save in "W register"
                    ENDC
                    bsr       L1E13               Check if requested coordinate is max. or less
                    bcs       L1E23               Error, exit
                    IFNE      H6309
                    ldw       #MaxLines*8-1       Maximum Y coord allowed; check it too
                    ELSE
                    ldd       #MaxLines*8-1       Maximum Y coord allowed, check it too
                    std       <gr00B5             Save back in "W register"
                    ENDC
* Make sure 16 bit coordinate is in range
* Entry: W=Maximum value allowed
*        X=Pointer to current 16 bit number to check
* Exit:  B=Error code (carry set if error)
L1E13               ldd       ,x++                Get original value we are checking
                    bpl       L1E1D               Positive, do the compare
                    IFNE      H6309
                    negd                          Flip a negative # to a positive #
L1E1D               cmpr      w,d                 If beyond maximum, return with Illegal coord error
                    ELSE
                    coma                          Flip a negative # to a positive #
                    comb
                    addd      #1
L1E1D               cmpd      <gr00B5             If beyond maximum, return with Illegal coord error
                    ENDC
                    bgt       L1E99
                    clrb                          In range, no error
L1E23               rts

L1E24               ldb       #gr0024             Point to Arc 'clip line' end coordinate
                    bra       L1E07

L1E28               ldb       #gr0053             Point to Horizontal Radius
                    bra       L1E07

* Offset X into grfdrv mem by B bytes (to point to 2 byte coordinates)
* Entry: B=offset into GRFDRV mem of X,Y coord pair (2 bytes each axis)
* Exit: X=ptr to GRFDRV mem of coords we are working on
*       ,x - 1,x = scaled X coord
*      2,x - 3,x = scaled Y coord
L1E2C               ldx       #GrfMem             Point to GRFDRV mem
                    abx                           Point X to X,y coord pair we are working with
                    IFNE      H6309
                    tim       #Scale,Wt.BSW,y     Scaling flag on?
                    ELSE
                    lda       Wt.BSW,y            Scaling flag on?
                    bita      #Scale
                    ENDC
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
                    IFNE      H6309
                    muld      2,x                 Multiply by Y coordinate
                    tfr       b,a                 Move 16 bit result we want to D
                    tfr       e,b
                    cmpf      #$cd                Round up if >=.8 leftover
                    ELSE
                    pshs      x,y,u               Save regs used in MUL16
                    ldx       2,x
                    lbsr      MUL16               Multiply D*X (returns Y:U)
                    tfr       y,d                 Move high word of result into D
                    stu       <gr00B5             Save low word of result
                    puls      x,y,u               Restore regs
                    tfr       b,a
                    ldb       <gr00B6             Get "F register"
                    cmpb      #$cd                cmpf #$cd
                    pshs      cc                  save result
                    ldb       <gr00B5             tfr e,b
                    puls      cc
                    ENDC
                    blo       L1E48               Fine, store value & do X coord
                    IFNE      H6309
                    incd                          Round up coordinate
                    ELSE
                    addd      #1                  Round up coordinate
                    ENDC
L1E48               std       2,x                 Save scaled Y coordinate
NoY                 ldb       ,s+                 Get X scaling value
                    beq       L1E52               None needed, exit
L1E4A               clra                          D=X scaling value
                    IFNE      H6309
                    muld      ,x                  Multiply by X coordinate
                    tfr       b,a                 Move 16 bit result we want to D
                    tfr       e,b
                    cmpf      #$cd                Round up if >=.8 leftover
                    ELSE
                    pshs      x,y,u
                    ldx       ,x
                    lbsr      MUL16               Multiply by X coordinate
                    stu       <gr00B5             Save in "W register"
                    tfr       y,d
                    puls      x,y,u
                    tfr       b,a
                    ldb       <gr00B6             Get "F register"
                    cmpb      #$cd                cmpf #$cd
                    pshs      cc                  save result
                    ldb       <gr00B5             tfr e,b
                    puls      cc
                    ENDC
                    blo       L1E50               Fine, store value & return
                    IFNE      H6309
                    incd                          Round up coordinate
                    ELSE
                    addd      #1                  Round up coordinate
                    ENDC
L1E50               std       ,x                  Save new X coordinate & return
L1E52               rts

* Setup up bit mask & branch table for next pixel in right direction
L1EF1               lda       <Gr.STYMk           get screen type
                    ldx       #GrfStrt+L1F00-2    Point to mask & offset table (-2 since base 1)
                    lsla                          account for 2 bytes entry
                    ldd       a,x                 get mask & offset
                    sta       <gr0079             Preserve bit mask (based on far left pixel for color mode)
                    abx                           Point to bit shift routine
                    stx       <gr0077             Store vector to bit shift right to next pixel routine
                    rts

* Bit shift table to shift to the right 3,2,1 or 0 times
L1F00               fcb       %10000000,L1F17-(L1F00-2) $19    640 2 color
                    fcb       %11000000,L1F16-(L1F00-2) $18    320 4 color
                    fcb       %11000000,L1F16-(L1F00-2) $18    640 4 color
                    fcb       %11110000,L1F14-(L1F00-2) $16    320 16 color

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
                    ldb       <gr0047+1           Get LSB of X coord
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
                    ldb       <gr0047+1           Get LSB of X coord
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
                    ldb       <gr0047+1           Get LSB of X coord
                    lsrb                          Divide by 2 for byte offset into pattern buffer
                    andb      #%00001111          MOD 16 since 16 color pattern buffer 16 bytes wide
L1F88               ldb       b,x                 Get proper byte from pattern buffer
                    andb      ,s+                 Only keep bits that are in pixel mask
                    puls      x                   Restore screen ptr
* DEFAULT PSET ROUTINE IF NO PATTERN BUFFER IS CURRENTLY ACTIVE. POINTED TO
* BY [$64,u], usually called from L1F5B
L1F9E               equ       *
                    IFNE      H6309
                    andr      b,a                 Only keep proper color from patterned pixel mask
                    jmp       ,w                  Call current LSET vector
                    ELSE
                    stb       <grScrtch           Only keep proper color from patterned pixel mask
                    anda      <grScrtch
                    jmp       [>GrfMem+$B5]       Call current LSET vector
                    ENDC
* Calculate pixel offset into pattern buffer (32x8 pixels only) from Y coord
* Exit: X=ptr to start of data in pattern buffer
*       B=Pixel offset within buffer to go to
L1F95               ldx       <gr0066             Get current pattern's buffer ptr
                    ldb       <gr0049+1           Calculate MOD 8 the line number we want
                    andb      #%00000111          to get data from the Pattern buffer
                    lslb                          Multiply by 4 to calculate which line within
                    lslb                          Pattern buffer we want (since 32 pixels/line)
                    rts

                    emod
eom                 equ       *
                    end
