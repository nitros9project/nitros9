********************************************************************
* VTIO - NitrOS-9 Level 1 Video Terminal I/O driver
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  12      ????/??/??  ???
* From Tandy OS-9 Level One VR 02.00.00.
*
*  12r1    2003/09/11  Rodney V. Hamilton
* Modified key table to include $7F, $1D, $1E and $1F codes.
*
*          2004/11/28  P.Harvey-Smith
* Added code to remap Dragon keyboard inputs to CoCo format.
*
*          2004/12/02  P.Harvey-Smith
* Changed the way that the entry points for the co?? drivers are
* called, so that we can have up to 7 different drivers.
* Integrated changes needed for the co51 driver from Dragon Data
* OS-9.
*
*          2005/04/24  P.Harvey-Smith
* Added cursor flash call to AltIRQ routine, this decrements a
* counter and when zero calls the routine contained in V.Flash
* ccio initialises this to point to an rts, the individual COxx
* routine can over-ride this in it's init, this should point to
* a routine to flash the cursor which should end in an rts.
*
*   1      2005/11/26  Boisy G. Pitre
* Renamed to VTIO.
*
*   2      2018/02/07  David Ladd
*                      L. Curtis Boyle
* Updated GoGrfo to load GrfDrv if GrfDrv was not found in memory
* using a new load routine called LoadSub
*   3      2018/02/15  David Ladd
*                      L. Curtis Boyle
* Fixed bug with SS.Ready GetStat call - it was not saving the # of chars
* available in the keyboard buffer to caller's B register
*
*   4      2018/03/02  David Ladd
*                      L. Curtis Boyle
* Fixed SS.ComSt call so that changing Coco 3 or Coco2B T1 VDG between real
* lowercase and inverse video takes effect as soon as the call is made (it
* setting flags, but not updating the hardware until the next switch to Graphics
* mode and back to text mode happened.
* Also some more general optimizations, and installed the V.ClrBlk and V.CpyBlk
* vectors calls (to use 6309 TFM and 6809 mini-stack blasting) for memory clears
* and memory copies. These will also be accessible from VTIO's other co-modules,
* for a speed increase.

                    nam       VTIO
                    ttl       OS-9 Level One V2 CoCo I/O driver

                    ifp1
                    use       defsfile
;         use   scfdefs
                    use       cocovtio.d
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

size                equ       V.Last

                    fcb       UPDAT.+EXEC.

name                fcs       /VTIO/
                    fcb       edition

* Init
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Init
* MESS Debug lines for Phill
*        pshs   y
*       ldy     #$aa55
*       ldy     #V.5136
*       ldy     #V.51End
*       puls    y

                    stu       >D.KbdSta           store devmem ptr
                    leax      <V.SCF,u            Point to start of mem to clear
                    ldd       #V.51End-V.SCF      0 byte to clear with, and size of static mem to clear
L002E               sta       ,x+                 clear mem
                    decb                          decrement counter
                    bne       L002E               continue if more
                    ifeq      PwrLnFreq-Hz60
                    lda       #CFlash60hz         initialize
                    else
                    lda       #CFlash50hz         initialize
                    endc
                    sta       >V.FlashTime,u
                    leax      <FlashCursor,pcr    Point to dummy cursor flash (just an rts).
                    stx       V.Flash,u           Setup cursor flash
                    coma                          A = $FF
                    comb                          B = $FF
                    ifeq      coco2b+coco2b_6309+deluxe-1
                    clr       <V.Caps,u
                    else
                    stb       <V.Caps,u
                    endc
                    std       <V.LKeyCd,u
                    std       <V.2Key2,u
* I presume this should also get IFEQ to specify 50 for PAL systems
                    lda       #60                 Init clock ctr to 60
                    sta       <V.ClkCnt,u
                    leax      <AltIRQ,pcr         get IRQ routine ptr
                    stx       >D.AltIRQ           store in AltIRQ
                    leax      >SetDsply,pcr       get display vector
                    stx       <V.DspVct,u         store in vector address
                    leax      >XY2Addr,pcr        get address of XY2Addr
                    stx       <V.CnvVct,u         Save as vector get mem location and pixel mask based on X,Y coords on gfx screen
                    leax      >ClrBlk,pcr         get address for mini-stack blast clear mem routine
                    stx       >V.ClrBlk,u         Save as vector
                    leax      >CpyBlk,pcr         get address for mini-stack blast mem copy (scroll) routine
                    stx       >V.CpyBlk,u         Save as vector
                    ldd       <IT.PAR,y           get parity and baud
                    lbra      SetupTerm           process them

* Read
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    A  = character read
*    CC = carry set on error
*    B  = error code
*
Read
*       pshs    y
*       ldy     #$aa57
*       puls    y

                    leax      V.InBuf,u           point X to input buffer
                    ldb       V.IBufT,u           get tail pointer
                    orcc      #IRQMask            mask IRQ
                    cmpb      V.IBufH,u           same as head pointer
                    beq       Put2Bed             if so, buffer is empty, branch to sleep
                    abx                           X now points to curr char
                    lda       ,x                  get char
                    bsr       L009D               check for tail wrap
                    stb       V.IBufT,u           store updated tail
                    andcc     #^(IRQMask+Carry)   unmask IRQ
FlashCursor
                    rts

Put2Bed             lda       V.BUSY,u            get calling process ID
                    sta       V.WAKE,u            store in V.WAKE
                    andcc     #^IRQMask           clear interrupts
                    ldx       #$0000
                    os9       F$Sleep             sleep forever
                    clr       V.WAKE,u            clear wake
                    ldx       <D.Proc             get pointer to current proc desc
                    ldb       <P$Signal,x         get signal recvd
                    beq       Read                branch if no signal
                    cmpb      #S$Window           window signal?
                    bhs       Read                Window signal or higher (none of the main system ones), go read
                    coma                          Otherwise, return with signal code as error
                    rts

* Check if we need to wrap around tail pointer to zero
L009D               incb                          increment pointer
                    cmpb      #$7F                at end?
                    bls       L00A3               branch if not
                    clrb                          else clear pointer (wrap to head)
L00A3               rts

*
* IRQ routine for keyboard
*
AltIRQ
*        pshs   y
*       ldy     #$aa58
*       puls    y
                    ldu       >D.KbdSta           get keyboard static memory ptr
                    ldb       <V.CFlg1,u          graphics screen currently being displayed?
                    beq       L00B7               branch if not
                    ldb       <V.Alpha,u          alpha mode?
                    beq       L00B7               branch if so
                    lda       <V.PIA1,u
                    lbsr      SetDsply            set up display
L00B7               ldx       #PIA0Base           point to PIA base
                    clra
                    clrb
                    std       <V.KySns,u          clear keysense byte
                    bsr       L00E8               get bits
                    bne       L00CC
                    clr       2,x                 clear PIA0Base+2
                    lda       ,x                  get byte from PIA
                    coma                          invert
                    anda      #$7F                strip off hi bit
                    bne       L00F1               branch if any bit set
L00CC               clra
                    clrb
                    std       <V.KTblLC,u         clear
                    coma                          A = $FF
                    tst       <V.Spcl,u           special key?
                    bne       l@                  branch if so
                    sta       <V.LKeyCd,u
l@                  stb       <V.Spcl,u           clear for next time
                    comb
                    sta       <V.2Key1,u
                    std       <V.2Key2,u

CheckFlash
                    dec       V.FlashCount,u      Dec flash counter
                    bne       AltIRQEnd           Still more, just call clock module.
FlashTime
                    jsr       [V.Flash,u]         Call flash routine
* 6809/6309 NOTE: Should add IFEQ of some sort here for CFlash50hz or CFlash60hz - but I am not
*  sure what to compare it with
                    lda       >V.FlashTime,u      Re-init count
                    sta       V.FlashCount,u
AltIRQEnd
                    jmp       [>D.Clock]          jump into clock module

L00E8               comb
                    stb       2,x                 strobe one column
                    ldb       ,x                  read PIA #0 row states
                    comb                          invert bits so 1=key pressed
                    andb      #$03                mask out all but lower 2 bits
                    rts

L00F1               bsr       L015C
                    bmi       L00CC
                    clrb
                    bsr       L00E8               Scan keyboard?
                    bne       L00CC               Key pressed, go process
                    cmpa      <V.6F,u             Check flag: Same as last key pressed?
                    bne       L010E               No, skip ahead
                    ldb       <V.ClkCnt,u         Get clock tick count
                    beq       L010A               If 0, reload it with 5
                    decb                          Otherwise, drop by 1 & save back
L0105               stb       <V.ClkCnt,u
                    bra       CheckFlash          Check of we should flash cursor (separate counter)

L010A               ldb       #$05                Set clock counter back to 5
                    bra       L011A               Save it and continue

L010E               sta       <V.6F,u             Save copy of key pressed?
                    ldb       #$05                Default timer to 5 tickets
                    tst       <V.KySame,u         Same key as last time?
                    bne       L0105               Yes, save clock tick count of 5, check for cursor flash
                    ldb       #60                 No, set clock tick count to 60
L011A               stb       <V.ClkCnt,u
                    ldb       V.IBufH,u           get head pointer in B
                    leax      V.InBuf,u           point X to input buffer
                    abx                           X now holds address of head
                    lbsr      L009D               check for tail wrap
                    cmpb      V.IBufT,u           B at tail?
                    beq       L012F               branch if so
                    stb       V.IBufH,u
L012F               sta       ,x                  store our char at ,X
                    beq       WakeIt              if nul, do wake-up
                    cmpa      V.PCHR,u            pause character?
                    bne       L013F               branch if not
                    ldx       V.DEV2,u            else get dev2 statics
                    beq       WakeIt              branch if none
                    sta       V.PAUS,x            else set pause request
                    bra       WakeIt

L013F               ldb       #S$Intrpt           get interrupt signal
                    cmpa      V.INTR,u            our char same as intr?
                    beq       L014B               branch if same
                    ldb       #S$Abort            get abort signal
                    cmpa      V.QUIT,u            our char same as QUIT?
                    bne       WakeIt              branch if not
L014B               lda       V.LPRC,u            get ID of last process to get this device
                    bra       L0153               go for it

WakeIt              ldb       #S$Wake             get wake signal
                    lda       V.WAKE,u            get process to wake
L0153               beq       L0158               branch if none
                    os9       F$Send              else send wakeup signal
L0158               clr       V.WAKE,u            clear process to wake flag
                    bra       AltIRQEnd           and move along

L015C               clra
                    clrb
                    std       <V.ShftDn,u         SHIFT/CTRL flag; 0=NO $FF=YES
                    std       <V.KeyFlg,u
* %00000111-Column # (Output, 0-7)
* %00111000-Row # (Input, 0-6)
                    coma
                    comb
                    std       <V.Key1,u           key 1&2 flags $FF=none
                    sta       <V.Key3,u           key 3     "
                    deca                          lda #%11111110
                    sta       2,x                 write column strobe
L016F               lda       ,x                  read row from PIA0Base

                    ifne      (tano+d64+dalpha+dplus)
                    lbsr      DragonToCoCo        Translate Dragon keyboard layout to CoCo
                    endc

                    coma                          invert so 1=key pressed
                    anda      #$7F                keep only keys, bit 0=off 1=on
                    beq       L0183               no keys pressed, try next column
                    ldb       #$FF                preset counter to -1
L0178               incb
                    lsra                          bit test regA
                    bcc       L017F               no key, brach
                    lbsr      L0221               convert column/row to matrix value and store
L017F               cmpb      #$06                max counter
                    bcs       L0178               loop if more bits to test
L0183               inc       <V.KeyFlg,u         counter; used here for column
                    orcc      #Carry              bit marker; disable strobe
                    rol       $02,x               shift to next column
                    bcs       L016F               not finished with columns so loop
                    lbsr      L0289               simultaneous check; recover key matrix value
                    bmi       L020A               invalid so go
                    cmpa      <V.LKeyCd,u         last keyboard code
                    bne       L0199
                    inc       <V.KySame,u         Same, set "Key pressed same as last time" flag
L0199               sta       <V.LKeyCd,u         setup for last key pressed
                    beq       L01B9               if @ key, use lookup table
                    suba      #$1A                the key value (matrix) of Z
                    bhi       L01B9               not a letter, so go
                    adda      #$1A                restore regA
                    ldb       <V.CtrlDn,u         CTRL flag
                    bne       L01E9               CTRL is down so go
                    adda      #$40                convert to ASCII value; all caps
                    ldb       <V.ShftDn,u         shift key flag
                    eorb      <V.Caps,u           get current device static memory pointer
                    andb      #$01                tet caps flag
                    bne       L01E9               not shifted so go
                    adda      #$20                convert to ASCII lowercase
                    bra       L01E9

* Not a letter key, use the special keycode lookup table
* Entry: A = table index (matrix scancode-26)
L01B9               ldb       #3                  three entries per key (normal, SHIFT, CTRL)
                    mul                           convert index to table offset
                    lda       <V.ShftDn,u         shift key flag
                    beq       L01C4               not shifted so go
                    incb                          else adjust offset for SHIFTed entry
                    bra       L01CB               and do it

L01C4               lda       <V.CtrlDn,u         CTRL flag?
                    beq       L01CB
                    addb      #$02                Yes, adjust offset for CTRL key
L01CB               lda       <V.KySnsF,u         key sense flag?
                    beq       L01D4               not set, so go
                    cmpb      #$11                spacebar?
                    ble       L0208               must be an arrow so go
L01D4               cmpb      #$4C                ALT key? (SHOULD BE $4C???)
                    blt       L01DD               not ALT, CTRL, F1, F2 or SHIFT so go
                    inc       <V.AltDwn,u         flag special keys (ALT, CTRL)
                    subb      #$06                adjust offset to skip them
L01DD               pshs      x                   save X
                    leax      >KeyTbl,pcr         point to keyboard table
                    lda       b,x                 Get key from tbl
                    puls      x
                    bmi       L01FD               if A = $81 - $84, special key
* several entries to this routine from any key press; A is already ASCII
L01E9               ldb       <V.AltDwn,u         was ALT flagged?
                    beq       L01FA               no, so go
                    cmpa      #$3F                ?
                    bls       L01F8               # or code
                    cmpa      #$5B                [
                    bhs       L01F8               capital letter so go
                    ora       #$20                convert to lower case
L01F8               ora       #$80                set for ALT characters
L01FA               andcc     #^Negative          not negative
                    rts

* Flag that special key was hit
L01FD               inc       <V.Spcl,u           Set flag
                    ldb       <V.KySame,u         Key pressed same as last checked?
                    bne       L0208               Yes, set negative flag & return
                    com       <V.Caps,u           No, flip state of Caps lock flag
L0208               orcc      #Negative           set negative
L020A               rts

* Calculate arrow keys for key sense byte
L020B               pshs      d                   convert column into power of 2
                    clrb
                    orcc      #Carry
                    inca
L0211               rolb
                    deca
                    bne       L0211
                    bra       L0219

L0217               pshs      d
L0219               orb       <V.KySns,u          previous value of column
                    stb       <V.KySns,u
                    puls      pc,d

* Check special keys (SHIFT, CTRL, ALT)
L0221               pshs      d
                    cmpb      #$03                is it row 3?
                    bne       L0230
                    lda       <V.KeyFlg,u         get column #
                    cmpa      #$03                is it column 3?; ie up arrow
                    blt       L0230               if lt it must be a letter
                    bsr       L020B               its a non letter so bsr
L0230               lslb                          B*8 8 keys per row
                    lslb
                    lslb
                    addb      <V.KeyFlg,u         add in the column #
                    beq       L025D
                    cmpb      #$33                ALT
                    bne       L0243
                    inc       <V.AltDwn,u         ALT down flag
                    ldb       #$04
                    bra       L0219

L0243               cmpb      #$31                CLEAR?
                    beq       L024B
                    cmpb      #$34                CTRL?
                    bne       L0252
L024B               inc       <V.CtrlDn,u         CTRL down flag
                    ldb       #$02
                    bra       L0219

L0252               cmpb      #$37                SHIFT key
                    bne       L0262
                    com       <V.ShftDn,u         SHIFT down flag
                    ldb       #$01
                    bra       L0219

L025D               ldb       #$04
                    bsr       L0217
                    clrb
* Check how many key (1-3) are currently being pressed
* Exit: <V.Key1 entries updated (up to 3)
*       B=# keys pressed (1,2,3)
L0262               pshs      x
                    leax      <V.Key1,u           1st key table
                    bsr       L026D
                    puls      x
                    puls      pc,d

L026D               pshs      a
                    lda       ,x
                    bpl       L0279
                    stb       ,x
                    ldb       #1
                    puls      pc,a

L0279               lda       1,x
                    bpl       L0283
                    stb       1,x
                    ldb       #2
                    puls      pc,a

L0283               stb       2,x
                    ldb       #3
                    puls      pc,a

* simultaneous key test
L0289               pshs      y,x,b
                    bsr       L02EE
                    ldb       <V.KTblLC,u         key table entry #
                    beq       L02C5
                    leax      <V.2Key1,u          point to 2nd key table
                    pshs      b
L0297               leay      <V.Key1,u           1st key table
                    ldb       #3                  # of keys to check
                    lda       ,x                  get key #1
                    bmi       L02B6               go if invalid? (no key)
L02A0               cmpa      ,y                  is it a match?
                    bne       L02AA               go if not a matched key
                    clr       ,y
                    com       ,y                  set value to $FF
                    bra       L02B6

L02AA               leay      1,y
                    decb
                    bne       L02A0
                    lda       #$FF
                    sta       ,x
                    dec       <V.KTblLC,u         key table entry #
L02B6               leax      1,x
                    dec       ,s                  column counter
                    bne       L0297
                    leas      1,s
                    ldb       <V.KTblLC,u         key table entry (can test for 3 simul keys)
                    beq       L02C5
                    bsr       L0309
L02C5               leax      <V.Key1,u           1st key table
                    lda       #$03
L02CA               ldb       ,x+
                    bpl       L02DE
                    deca
                    bne       L02CA
                    ldb       <V.KTblLC,u         key table entry (can test for 3 simul keys)
                    beq       L02EA
                    decb
                    leax      <V.2Key1,u          2nd key table
                    lda       b,x
                    bra       L02E8

L02DE               tfr       b,a
                    leax      <V.2Key1,u          2nd key table
                    bsr       L026D
                    stb       <V.KTblLC,u
L02E8               puls      pc,y,x,b

L02EA               orcc      #Negative           flag negative
                    puls      pc,y,x,b

L02EE               ldd       <V.ShftDn,u         Get Shift and CTRL key down flags
                    bne       L0301               At least one of them is down, return
                    lda       #3                  3 keys to check
                    leax      <V.Key1,u           Point to 1st key pressed
* 6809/6309 could ,x+, remove leax 1,x, and change L0302 to stb -1,x. X is destroyed on return anyways
* would slightly slow down single key press (speed up multi-presses), but save 2 bytes. LCB
L02F8               ldb       ,x                  Get the keypress
                    beq       L0302               None, Flip to $FF, write back, and flag ALT key is pressed.
                    leax      1,x                 Bump to next keypress
                    deca                          Done all 3?
                    bne       L02F8               no, keep going
L0301               rts                           Yes, return

L0302               comb
                    stb       ,x
                    inc       <V.AltDwn,u         Set flag that ALT key is pressed
                    rts

* Sort 3 byte packet @ G.2Key1 according to sign of each byte
* so that positive #'s are at beginning & negative #'s at end
* NOTE: The only call to come here destroys X immediately on return (L02B6),
*
L0309               leax      <V.2Key1,u          2nd key table
                    bsr       L0314               sort bytes 1 & 2
                    leax      1,x
                    bsr       L0314               sort bytes 2 & 3
                    leax      -1,x                sort 1 & 2 again (fall thru for third pass)
L0314               lda       ,x                  get current byte
                    bpl       L0320               positive - no swap
                    ldb       1,x                 get next byte
                    bmi       L0320               negative - no swap
                    sta       1,x                 swap the bytes
                    stb       ,x
L0320               rts

;
; Convert Dragon Keyboard mapping to CoCo.
;
; Entry a=Dragon formatted keyboard input from PIA
; Exit  a=CoCo formatted keyboard input from PIA
;
                    ifne      (tano+d64+dalpha+dplus)
DragonToCoCo
                    pshs      b                   Save B
                    sta       ,-s                 Save Dragon formatted keyboard on stack
                    tfr       a,b                 Take a copy of keycode
                    ifne      H6309
                    andd      #%0100000000000011  replaces next two lines
                    else
                    anda      #%01000000          Top row same on both machines
                    andb      #%00000011          shift bottom 2 rows up 4 places
                    endc
                    lslb
                    lslb
                    lslb
                    lslb
                    pshs      b
                    ora       ,s+
                    ldb       ,s                  Get original dragon formatted one back (-2 cyc)
                    andb      #%00111100          Shift middle 4 rows down 2 places
                    lsrb
                    lsrb
                    stb       ,s                  Save shifted version on stack (-2 cyc)
                    ora       ,s+                 recombine rows
                    puls      b,pc                Restore original B & return
                    endc

* Key Table
* 1st column = key (no modifier)
* 2nd column = SHIFT+key
* 3rd column = CTRL+key
KeyTbl              fcb       $00,$40,$60         ALT @ `
                    fcb       $0c,$1c,$13         UP
                    fcb       $0a,$1a,$12         DOWN
                    fcb       $08,$18,$10         LEFT
                    fcb       $09,$19,$11         RIGHT
                    fcb       $20,$20,$20         SPACEBAR
                    fcb       $30,$30,$81         0 0 capslock
                    fcb       $31,$21,$7c         1 ! |
                    fcb       $32,$22,$00         2 " null
                    fcb       $33,$23,$7e         3 # ~
                    fcb       $34,$24,$1d         4 $ RS  (was null)
                    fcb       $35,$25,$1e         5 % GS  (was null)
                    fcb       $36,$26,$1f         6 & US  (was null)
                    fcb       $37,$27,$5e         7 ' ^
                    fcb       $38,$28,$5b         8 ( [
                    fcb       $39,$29,$5d         9 ) ]
                    fcb       $3a,$2a,$00         : * null
                    fcb       $3b,$2b,$7f         ; + del (was null)
                    fcb       $2c,$3c,$7b         , < {
                    fcb       $2d,$3d,$5f         - = _
                    fcb       $2e,$3e,$7d         . > }
                    fcb       $2f,$3f,$5c         / ? \
                    fcb       $0d,$0d,$0d         ENTER key
                    fcb       $00,$00,$00         CLEAR key
                    fcb       $05,$03,$1b         BREAK key
                    fcb       $31,$33,$35         F1 key
                    fcb       $32,$34,$36         F2 key


start               lbra      Init
                    lbra      Read
                    bra       Write
                    nop       Could               be used for a constant
                    lbra      GetStat
                    lbra      SetStat
* Term
* Entry: U  = address of device memory area
* Exit:  CC = carry set on error
*        B  = error code
Term                pshs      cc
                    orcc      #IRQMask            mask interrupts
                    ldx       >D.Clock            get clock vector
                    stx       >D.AltIRQ           and put back in AltIRQ
                    puls      pc,cc               Restore interrupts & return

* Write - move to just after initial jump table to make short branch, since this
*  will be the most often used routine in VTIO
*
* Entry:
*    A  = character to write
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Write               ldb       <V.NGChr,u          are we in the process of getting parameters?
                    bne       PrmHandl            yes, go process character as parameter
                    sta       <V.WrChr,u          No, save character to write
                    ldb       V.51EscSeq,u        in Escape sequence?
                    bne       GoCo                yes, send to COHR
                    cmpa      #C$SPAC             space or higher?
                    bhs       GoCo                yes, normal write
                    cmpa      #$1B                * COHR Escape Code?
                    beq       GoCo
                    cmpa      #$1E                escape sequence $1E or $1F?
                    bhs       Escape              yes, go process
                    cmpa      #$0F                GFX codes?
                    lbhs      GfxDispatch         branch if so
                    cmpa      #C$BELL             bell?
                    lbeq      Ding                if so, ring bell
* Here we call the CO-module to write the character
GoCo                lda       <V.CurCo,u          get CoVDG/CoWP flag
CoWrite             ldb       #$03                we want to write
CallCO              leax      <V.GrfDrvE,u        get base pointer to CO-entries
                    pshs      a                   Save Co Module bit flags
                    tsta                          Is it GrfDrv we are trying to init?
                    beq       IsGrfDrv            Yes, skip getting offset
                    lbsr      GetModOffset        Get offset for entry point for the Co-module we are going to use
IsGrfDrv            ldx       a,x                 get pointer to Entry point of Co-module
                    puls      a                   Get back Co module bit flags
                    beq       NoIOMod             branch if no module (X<>0)
                    lda       <V.WrChr,u          get character to write
L039D               jmp       b,x                 Call co-module with char to write

NoIOMod             comb                          Module not found error
                    ldb       #E$MNF
                    rts

* Parameter handler - currently ONLY handles 1 or 2 bytes of parameters. Any additions that require
*   more will require code changes here.
* Entry: A=byte parameter currently processing
*        B=# bytes still left to get
PrmHandl            cmpb      #2                  Still two parameters left?
                    beq       L03B0               Yes, save this parameter byte, update counter, and go get the last one
                    sta       <V.NChr2,u          NO, we only needed 1, which we now have. Save byte in V.NChr2
                    clr       <V.NGChr,u          clear how many more bytes we need as parameters
                    jmp       [<V.RTAdd,u]        jump to return address to routine that asked for parameters in the 1st place

L03B0               sta       <V.NChar,u          store 1st parameter byte in V.NChar
                    dec       <V.NGChr,u          decrement parameter counter
                    clrb                          Return w/o error, to go get the 2nd parameter byte
                    rts

Escape              beq       L03C5               if $1E, we conveniently ignore it
                    leax      <COEscape,pcr       else it's $1F... set up to get next char
L03BD               ldb       #$01                This entry point requests 1 byte of parameters
L03BF               stx       <V.RTAdd,u
                    stb       <V.NGChr,u
L03C5               clrb
                    rts

COEscape            ldb       #$03                'Write' offset into CO-module
                    lbra      JmpCO

* Show VDG or Graphics screen. Set up as a vector (V.DspVct)
* Entry: B = 0 for VDG, 1 for Graphics
*        A = color setting of some sort
SetDsply            pshs      x,a
                    stb       <V.Alpha,u          save passed flag in B
                    lda       >PIA1Base+2
                    anda      #%00000111          mask out all but lower 3 bits
                    ora       ,s+                 OR in passed A
                    tstb                          display graphics?
                    bne       L03DE               branch if so
                    ifne      COCOVGA
                    ora       #$A0                VGA - force VDG to CG2 (which CocoVGA takes control of)
                    endc
                    ora       <V.CFlag,u          Merge in true lowercase bit as well
L03DE               sta       >PIA1Base+2
                    sta       <V.PIA1,u
                    ldx       #$FFC6              Point to SAM to set up where to map
                    tstb                          display graphics?
                    bne       DoGfx               Yes, do that
* Set up VDG screen for text
                    ifne      COCOVGA
* VGA - Set VDG for CG2, which CocoVGA takes over for the 64x32 text mode
                    stb       -6,x                clear GM0
                    stb       -3,x                set GM1
                    stb       -2,x                clear GM2
                    else
* VDG - Set VDG to Alpha mode
                    stb       -6,x                $FFC0  Set up for 32x16 text screen
                    stb       -4,x                $FFC2
                    stb       -2,x                $FFC4
                    endc
                    lda       <V.ScrnA,u          get pointer to alpha screen
                    bra       L0401

* Set up VDG screen for graphics (6144 byte modes only - PMODE 3 or 4)
DoGfx               stb       -6,x                $FFC0
                    stb       -3,x                $FFC3
                    stb       -1,x                $FFC5
                    lda       <V.SBAdd,u          get pointer to graphics screen (just need hi byte-VDG needs 512 byte boundaries)
L0401               ldb       #$07                7 SAM double-byte settings to do
                    lsra
L0407               lsra
                    bcs       L0410               If bit set, store on odd byte
                    sta       ,x++                bit clear, store on even byte (Faster (not important), smaller)
                    bra       L0414

L0410               leax      1,x
                    sta       ,x+
L0414               decb                          Done all 7 mem pairs?
                    bne       L0407               No, keep going until done
                    clrb                          Return w/o error
                    puls      pc,x

* Return key sense information
SSKYSNS             ldb       <V.KySns,u          get key sense info
                    stb       R$A,x               put in caller's A
                    clrb
                    rts

* Return screen size
SSSCSIZ             clra                          clear upper 8 bits of D
                    ldb       <V.Col,u            get column count
                    std       R$X,x               save in X
                    ldb       <V.Row,u            get row count
                    std       R$Y,x               save in Y
                    clrb                          no error
                    rts

* GetStat
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
GetStat             sta       <V.WrChr,u          save off stat code
                    cmpa      #SS.EOF             EOF call?
                    beq       SSEOF               Yes, exit w/o error
                    ldx       PD.RGS,y            Get ptr to caller's regs (all other calls require this)
                    cmpa      #SS.Ready           Data ready call? (keyboard buffer)
                    bne       L0439               No, check next
                    lda       V.IBufH,u           get buff tail ptr
                    suba      V.IBufT,u           num of chars ready in A
                    sta       R$B,x               Save for caller
                    lbeq      NotReady            If no data in keyboard buffer, return with Not Ready error
SSEOF               clrb
                    rts

L0439               cmpa      #SS.Joy             joystick?
                    beq       SSJOY               branch if so
                    cmpa      #SS.ScSiz           screen size?
                    beq       SSSCSIZ             branch if so
                    cmpa      #SS.KySns           keyboard sense?
                    beq       SSKYSNS             branch if so
                    cmpa      #SS.DStat           display status?
                    beq       SSDSTAT             branch if so
                    ldb       #$06                getstat entry into CO-module
                    lbra      JmpCO

* Get joystick values. Could move ldy up to just after ORCC, and then ldx #PIA0Base+1
* then, for the 8 references to PIA0Base, use no offset/5 bit offset (saves 8 bytes,
* and 3 cycles - hopefully that doesn't screw up joystick reads with jitter, etc.
SSJOY               pshs      y,cc
                    orcc      #IRQMask            mask interrupts
                    lda       #$FF
                    sta       >PIA0Base+2
                    ldb       >PIA0Base
                    ldy       R$X,x               get joystick number to poll
                    bne       L0481
                    andb      #$01
                    bne       L0485
                    bra       L0486

L0481               andb      #$02
                    beq       L0486
L0485               clra
L0486               sta       R$A,x
                    lda       >PIA0Base+3
                    ora       #$08
                    leay      ,y
                    bne       L0494
                    anda      #$F7
L0494               ldy       #PIA0Base+1         Point to PIA most used address in following routine
                    sta       2,y                 PIA0Base+3
                    lda       ,y                  PIA0Base+1
                    anda      #$F7
                    bsr       L04B3
                    std       R$X,x               Save X coord of joystick
                    lda       ,y                  PIA0Base+1
                    ora       #$08
                    bsr       L04B3
                    pshs      d
                    ldd       #63
                    subd      ,s++
                    std       R$Y,x               Save Y coord of joystick
                    clrb
                    puls      pc,y,cc

L04B3               sta       ,y                  PIA0Base+1
                    ldd       #$7F40
L04C7               pshs      b
                    sta       >PIA1Base
                    tst       -1,y                PIA0Base
                    bpl       L04D5
                    adda      ,s+
L04BC               lsrb
                    cmpb      #$01
                    bhi       L04C7
                    lsra
                    lsra
                    tfr       a,b
                    clra
                    rts

L04D5               suba      ,s+
                    bra       L04BC

* Return display status
* Entry: A = path
* Exit: A = color code of pixel at cursor address
*       X = address of graphics display memory
*       Y = graphics cursor address; X = MSB, Y = LSB
SSDSTAT             lbsr      GfxActv             gfx screen allocated?
                    bcs       L050E               branch if not
                    ldd       <V.GCrsX,u          else get X/Y gfx cursor position
                    bsr       XY2Addr             Get pixel coords: Y=ptr to start of screen, X=ptr to pixel byte, A=pixel mask within byte
                    tfr       a,b                 Duplicate pixel mask
                    andb      ,x                  Keep only the pixels worth of bits from screen
* Loop to figure out color. Shifts until set bits both in actual color byte, and mask byte, shift out
L04E7               bita      #$01                Loop to figure out color-have we shifted enough to get the first bit of pixel?
                    bne       L04F6               Yes, shifted enough to get active pixel to far right
                    lsra                          no, still going; Shift pixel mask to the right
                    lsrb                          Shift color bits of pixel to right as well
                    tst       <V.Mode,u           Are we in 2 color mode?
                    bmi       L04E7               Yes, loop back
                    lsra                          4 color mode, move both to right one more bit (2 bits per pixel)
                    lsrb
                    bra       L04E7               Check if we have found active pixel yet.

L04F6               pshs      b                   Save pixel color (last 1 or 2 bits)
                    ldb       <V.PMask,u          get pixel color mask in B
                    andb      #%11111100          Only keep 2 bits (covers both 2 and 4 color modes)
                    orb       ,s+                 Merge with actual color value in pixel
                    ldx       PD.RGS,y            get caller's regs
                    stb       R$A,x               place pixel color in A
                    ldd       <V.GCrsX,u
                    std       R$Y,x               cursor X/Y pos in Y,
                    ldd       <V.SBAdd,u
                    std       R$X,x               and screen addr in X
                    clrb
L050E               rts

* This vector also gets called from Grfdrv via V.CnvVct
* Entry: A = X coord, B = Y coord
* Exit: Y=Base address of screen, X=ptr to byte on screen, A=pixel mask for specific pixel
XY2Addr             pshs      y,d                 save off regs
                    ldb       <V.Mode,u           get video mode
                    bpl       L0517               branch if 128x192 (divide A by 4)
                    lsra                          else divide by 8
L0517               lsra
                    lsra
                    pshs      a                   save on stack (A=horizontal byte on line pixel will be on)
                    ldb       #191                get max Y
                    subb      2,s                 subtract from Y on stack
                    lda       #32                 bytes per line
                    mul
                    addb      ,s+                 add offset on stack
                    adca      #$00
                    ldx       <V.SBAdd,u          get base address of gfx screen
                    leax      d,x                 Point to byte pixel will be drawing on
                    lda       ,s                  pick up original X coord
                    stx       ,s                  put offset addr on stack
                    anda      <V.PixBt,u          Just keep X pixel 0-7 (or 0-3)
                    ldx       <V.MTabl,u          Get ptr to pixel mask table (already set up for 4 or 8)
                    lda       a,x                 Get mask for specific pixel we will be drawing
                    puls      pc,y,x              X = offset address, Y = base, A=pixel mask

* SetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
SetStat             sta       <V.WrChr,u          save function code
                    ldx       PD.RGS,y            get caller's regs
                    cmpa      #SS.ComSt
                    lbeq      SSCOMST
                    cmpa      #SS.AAGBf
                    beq       SSAAGBF
                    cmpa      #SS.SLGBf
                    beq       SSSLGBF
                    cmpa      #SS.KySns
                    bne       CoGetStt
                    ldd       R$X,x               get caller's key sense set data
                    beq       L0558               branch if zero
                    ldb       #$FF                else set all bits
L0558               stb       <V.KySnsF,u         store value in KySnsFlag
L055B               clrb
L055C               rts

CoGetStt            ldb       #$09                CO-module setstat
JmpCO               pshs      b
                    lda       <V.CurCo,u          get CO-module in use
                    lbsr      CallCO
                    puls      a
                    bcc       L055B
                    tst       <V.GrfDrvE,u        GrfDrv linked?
                    beq       L055C
                    tfr       a,b
                    clra                          GrfDrv address offset in statics
                    lbra      CallCO              call it

* Reserve an additional graphics buffer (up to 2)
SSAAGBF             ldb       <V.Rdy,u            was initial buffer allocated with $0F?
                    lbeq      NotReady            branch if not
                    pshs      b                   save buffer number
                    leay      <V.AGBuf,u          point to additional graphics buffers
                    ldd       ,y                  first entry empty?
                    beq       L058E               branch if so
                    leay      2,y                 else move to next entry
                    inc       ,s                  increment B on stack
                    ldd       ,y                  second entry empty?
                    bne       L059E               if not, no room for more... error out
L058E               lbsr      GetMem              allocate graphics buffer memory
                    bcs       L05A1               branch if error
                    std       ,y                  save new buffer pointer at ,Y
                    std       R$X,x               and in caller's X
                    puls      b                   get buffer number off stack
                    clra                          clear hi byte of D
                    std       R$Y,x               and put in caller's Y (buffer number)
                    clrb                          call is ok
                    rts                           and return

L059E               ldb       #E$BMode
                    coma
L05A1               puls      pc,a

* Select a graphics buffer
SSSLGBF             ldb       <V.Rdy,u            was initial buffer allocated with $0F?
                    lbeq      NotReady            branch if not
                    ldd       R$Y,x               else get buffer number from caller
                    cmpd      #$0002              compare against high
                    bhi       BadMode             branch if error
                    leay      <V.GBuff,u          point to base graphics buffer address
                    lslb                          multiply by 2
                    ldd       b,y                 get pointer
                    beq       BadMode             branch if error
                    std       <V.SBAdd,u          else save in current
                    ldd       R$X,x               get select flag
                    beq       L05C3               if zero, do nothing
                    ldb       #$01                else set display flag
L05C3               stb       <V.CFlg1,u          save display flag
NoError             clrb
                    rts

BadMode             comb                          Exit with Bad Mode error
                    ldb       #E$BMode
                    rts

*SS.Comst GetStat - has some features not documented
* Entry (From caller):
* A=path
* B=$28 (SS.Comst code)
* NOTE: Since the co-modules are (currently) mutually exclusive (maybe not WP?), change
*   this system to use lsra and use last 3 bits as driver #, or something similar
* NOTE 2: Because of the way this is set up now, one could change the co-module on the fly
* so it will try to load each co-module as assigned, until one runs out of RAM. Some of them
* may interfere with each other when changing as well.
* Y=Option flags (high byte of Y)
*   xxxxxxx1 = True lowercase ON (for Coco 3, Coco2B, possibly CoVGA)
*   xxxxxx1x = Use CoVDG Co-module (32x16)
*   xxxxx1xx = Use CoWP (Wordpak) 80x25
*   xxxx1xxx = Use CoHR (51x25 PMODE 4)
*   xxx1xxxx = Use Co42 (42x25 PMODE 4)
*   xx1xxxxx = Use CoVGA (64x32 CocoVGA adaptor)
SSCOMST             ldd       R$Y,x               Get caller's Y
SetupTerm
                    bita      #ModCoVDG           32x16 VDG bit flag set?
                    beq       GoCoWP              No, go check next co-module type
                    ldb       #$10                assume true lower case TRUE
                    bita      #$01                true lowercase bit set?
                    bne       GoCoVDG             Yes, branch if so
                    clrb                          true lower case FALSE
GoCoVDG             stb       <V.CFlag,u          save lowercase flag
                    lda       #ModCoVDG           CoVDG is loaded bit
                    ldx       #$2010              32x16
                    pshs      u,y,x,a
                    leax      <CoVDG,pcr
                    lbsr      LoadCoModule
                    puls      u,y,x,a
                    bcs       L0600
                    stx       <V.Col,u
                    sta       <V.CurCo,u
                    ldb       <V.Alpha,u
                    bne       NoError
                    lbra      SetDsply


* 6809/6309 - Try embedding LoadCoModule since short and only called from here.
* Entry: X=ptr to co-module name
SetupCoModule
                    lbsr      LoadCoModule        Load Co-module if not already loaded
                    puls      u,y,x,a
                    bcs       L0600               Couldn't load/link co-module, return with error
                    stx       <V.Col,u            save screen size
                    sta       <V.CurCo,u          current module in use? ($02=CoVDG, $04=C080, etc.)
L0600               rts

* All co-modules except grfdrv

CoVDG               fcs       /CoVDG/
CoWP                fcs       /CoWP/
CoDPlus             fcs       /CoDPlus/
CoHR                fcs       /CoHR/
Co42                fcs       /Co42/
CoVGA               fcs       /CoVGA/

GoCoWP              bita      #ModCoWP            CoWP needed ?
                    beq       GoCoDPlus           No, try next co-module
                    stb       <V.CFlag,u          allow lowercase
                    clr       <V.Caps,u           set caps off
                    lda       #ModCoWP            'CoWP is loaded' bit
                    ldx       #$5019              80x25 WordPark RS supports 25 lines
                    pshs      u,y,x,a
                    leax      <CoWP,pcr
                    bra       SetupCoModule

GoCoDPlus
                    bita      #ModCoDPlus         Dragon Plus 80 column
                    beq       GOCoVGA
                    stb       <V.CFlag,u          allow lowercase
                    clr       <V.Caps,u           set caps off
                    lda       #ModCoDPlus         CoDPlus is loaded bit
                    ldx       #$5018              80x24
                    pshs      u,y,x,a
                    leax      <CoDPlus,pcr
                    bra       SetupCoModule

GoCoVGA             bita      #ModCoVGA           64x32 CoVGA?
                    beq       GoCo42              No, then try next co-module
                    stb       <V.CFlag,u          allow lowercase
                    lda       #ModCoVGA           CoVGA is loaded bit
                    ldx       #$4020              64x32
                    pshs      u,y,x,a
                    leax      <CoVGA,pcr
                    bra       SetupCoModule

GOCo42              bita      #ModCo42            42x24 gfx term?
                    beq       GOCoHR              No, try 51 column co-module
                    ldb       #$10                Flag that we can do real lowercase
                    stb       <V.CFlag,u
                    clr       <V.Caps,u           Caps lock OFF
                    lda       #ModCo42            'Co42 is loaded' bit
                    ldx       #$2A18              42x24
                    pshs      u,y,x,a
                    leax      <Co42,pcr
                    lbra      SetupCoModule

GOCoHR              ldb       #$10
                    stb       <V.CFlag,u
                    clr       <V.Caps,u
                    lda       #ModCoHR            'CoHR is loaded' bit
                    ldx       #$3318              51x24
                    pshs      u,y,x,a
                    leax      <CoHR,pcr
                    lbra      SetupCoModule

LoadCoModule
                    bita      <V.COLoad,u         Module loaded?
                    beq       L0608               No, try loading
L0606               clrb                          Yes, return with no error
                    rts

L0608               pshs      y,x,a               Preserve regs
                    bsr       LinkSub             Try to link to Co-module
                    bcc       L061F               Got, save it's entry pointer in co-module entry table
                    ldx       1,s                 get pointer to co-module name again from stack
                    bsr       LoadSub
                    bcc       L061F               Loaded; save it's entry pointer in co-module entry table
                    puls      y,x,a
                    lbra      NoIOMod             Couldn't even load, return Module Not Found error

L061F               leax      <V.GrfDrvE,u        get base pointer to CO-entries
                    lda       ,s
                    bsr       GetModOffset        Get offset in table
                    sty       a,x                 Save address
                    puls      y,x,a
                    clrb                          CO-module init offset
                    lbra      CallCO              call it

; Get module offset from V.GrfDrvE into A reg.
; I had to do this because the previous system would only work
; properly for 2 entries !
GetModOffset
                    pshs      b
                    clrb                          Calculate address offset
AddrFind            bita      #$01                Done all shifts ?
                    bne       AddrDone
                    addb      #$2                 increment addr offset ptr
                    lsra
                    bra       AddrFind            Test again

AddrDone            tfr       b,a                 output in a
                    puls      b,pc

* Link to subroutine
LinkSub             pshs      u
                    lda       #Systm+Objct
                    os9       F$Link
                    puls      pc,u

* Load subroutine
LoadSub             pshs      u
                    lda       #Systm+Objct
                    os9       F$Load
                    puls      pc,u

GfxDispatch
                    cmpa      #$15                GrfDrv-handled code?
                    bhs       GoGrfo              Yep, pass code over to it
                    cmpa      #$0F                display graphics code? NEED TO FIND OUT IF COHR/CO42 SHOULD SKIP THIS
                    beq       Do0F                branch if so
                    suba      #$10
                    bsr       GfxActv             check if first gfx screen was alloc'ed
                    bcs       L0663               if not, return with error
                    leax      gfxtbl,pcr          else point to jump table
                    ldb       a,x                 get address of routine
                    jmp       b,x                 jump to it


GfxActv             ldb       <V.Rdy,u            gfx screen allocated?
                    bne       L0606               Yes, exit with no error
NotReady            comb                          No, exit with Not Ready error
                    ldb       #E$NotRdy
L0663               rts

GoGrfo              bsr       GfxActv             Is a graphics screen already active?
                    bcs       L0663               No, return with error
                    ldx       <V.GrfDrvE,u        get GrfDrv entry point
                    bne       L0681               branch if not zero
                    pshs      y,a                 else preserve regs
                    leax      <GrfDrv,pcr         get pointer to name string
                    bsr       LinkSub             link to GrfDrv
                    bcc       L067B               branch if ok
                    leax      <GrfDrv,pcr         get pointer to name string
                    bsr       LoadSub
                    bcc       L067B
                    puls      pc,y,a              else exit with error

GrfDrv              fcs       /GrfDrv/

L067B               sty       <V.GrfDrvE,u        save module entry pointer
L067F               puls      y,a                 restore regs
L0681               clra                          A = GrfDrv address offset in statics
                    lbra      CoWrite

* Allocate GFX mem -- we must allocate on a 512 byte page boundary
GetMem              pshs      u                   save static pointer
                    ldd       #6144+256           allocate graphics memory + 1 page ($1900) to allow for 512 byte boundary
                    os9       F$SRqMem            do it
                    bcc       L0691               We got the memory; figure out 512 byte boundary, return un-needed 256 bytes
                    puls      pc,u                else return with error

L0691               tfr       u,d                 move mem ptr to D
                    puls      u                   restore static mem ptr
                    tfr       a,b                 move high 8 bits to lower
                    bita      #$01                odd page?
                    beq       L069F               No, even 512 start, so we will return last 256 byte page to mem pool
                    adda      #$01                Make even (SAM/VDG needs 512 byte boundaries for screens)
                    bra       L06A1               Return the first 256 byte page to the mem pool

L069F               addb      #$18                Point to last 256 byte page (we will return to mem pool)
L06A1               pshs      u,a                 Save static mem ptr and high byte start mem ptr of screen
                    tfr       b,a                 Move high byte start mem ptr of 256 bytes we are returning
                    clrb                          D=start ptr of page we are returning
                    tfr       d,u                 Move to reg for system call
                    ldd       #256                256 bytes to return
                    os9       F$SRtMem            return page
                    puls      u,a                 Restore regs
                    bcs       L06B3               branch if error
                    clrb
L06B3               rts

* $0F - display graphics
Do0F                leax      <DispGfx,pcr        Get address to call after we get 2 parameter bytes
                    ldb       #$02                2 bytes more to get
                    lbra      L03BF               Go get them, come back to DispGfx when done

DispGfx             ldb       <V.Rdy,u            already allocated initial buffer?
                    bne       L06D1               Yes, skip allocating
                    bsr       GetMem              else get graphics memory
                    bcs       L06B3               Couldn't get RAM; return with error
                    std       <V.SBAdd,u          save ptr to graphics RAM
                    std       <V.GBuff,u          And again
                    inc       <V.Rdy,u            ok, we're ready
                    lbsr      Do13                clear gfx mem
L06D1               lda       <V.NChr2,u          get 2nd parm (color set/foreground/background color selection)
                    sta       <V.PMask,u          save color set (0-15)
                    anda      #%00000011          mask out all but lower 2 bits
                    leax      <Mode1Clr,pcr       point to color mask table
                    lda       a,x                 get byte
                    sta       <V.Msk1,u           save mask byte here
                    sta       <V.Msk2,u           and here
                    lda       <V.NChar,u          get 1st parm (gfx mode) mode byte (0-1)
                    cmpa      #$01                compare against max
                    bls       L06F0               branch if valid
                    lbra      BadMode             else invalid mode specified, send error

L06F0               blo       L0710               branch if 256x192
* NOTE: CHECK CO-MODULES; I DON'T SEE V.MCol or V.MCol+1 being used ANYWHERES in VTIO
                    ldd       #$C003              4 color mode; Make pixel masks for start and end pixels in a byte
                    std       <V.MCol,u           Save them for re-use
                    ldd       #$E001
                    stb       <V.Mode,u           128x192 4 color mode
                    ldb       <V.NChr2,u
                    andb      #$08
                    beq       L0709
                    lda       #$F0
L0709               ldb       #$03                Base 0 # pixels in a byte
                    leax      <L0742,pcr          Point to 4 color pixel masks table
                    bra       L072D

L0710               ldd       #$8001              2 color mode; Make pixel masks for start and end pixels in a byte
                    std       <V.MCol,u           Save them for re-use
                    lda       #$FF
                    tst       <V.Msk1,u
                    beq       L0723
                    sta       <V.Msk1,u
                    sta       <V.Msk2,u
L0723               sta       <V.Mode,u           256x192 mode
                    ldd       #$F007              ? & Base 0 # pixels in a byte
                    leax      <L0746,pcr          Point to 2 color pixel masks table
L072D               stb       <V.PixBt,u          Save base 0 # pixels in a byte
                    stx       <V.MTabl,u          Save ptr to pixel mask table
                    ldb       <V.NChr2,u
                    andb      #$04
                    lslb
                    ifne      H6309
                    orr       b,a
                    else
                    pshs      b
                    ora       ,s+
                    endc
                    ldb       #$01
* Indicate screen is current
                    lbra      SetDsply

* 128x192 color mask table for 4 color modes
Mode1Clr            fcb       $00,$55,$aa,$ff

* 4 color pixel masks
L0742               fcb       $c0,$30,$0c,$03

* 2 color pixel masks
L0746               fcb       $80,$40,$20,$10,$08,$04,$02,$01

* $11 - set color
Do11                leax      <SetColor,pcr       set up return address
                    lbra      L03BD

SetColor            clr       <V.NChar,u          get next char
                    lda       <V.Mode,u           which mode?
                    bmi       L075F               branch if 256x192
                    inc       <V.NChar,u
L075F               lbra      L06D1

* $12 - end graphics. This needs to be modified to properly handle CoHR/Co42 co-modules;
* since they *replace* the original alpha mode, they should never be de-allocated. Only
* extra pages should be de-allocated.
Do12                leax      <V.GBuff,u          point to first buffer
                    ifne      H6309
                    tfr       0,y                 Same speed/2 bytes smaller on 6309
                    else
                    ldy       #0                  Y = 0
                    endc
                    ldb       #3                  free 3 gfx screens max
                    pshs      u,b
L076D               ldd       #6144               size of graphics screen
                    ldu       ,x++                get address of graphics screen
                    beq       L077A               branch if zero
                    sty       -2,x                else clear entry
                    os9       F$SRtMem            and return memory
L077A               dec       ,s                  decrement counter
                    bgt       L076D               keep going if not end
                    ldu       ,x                  flood fill buffer?
                    beq       L0788               No, skip return flood fill buffer memory to system
                    ldd       #512                else get size
                    os9       F$SRtMem            and free memory
L0788               puls      u,b                 restore regs
                    clra
                    sta       <V.Rdy,u            gfx mem no longer allocated
                    lbra      SetDsply

* Jump table for graphics codes $10-$14
gfxtbl              fcb       Do10-gfxtbl         $10 - Preset Screen
                    fcb       Do11-gfxtbl         $11 - Set Color
                    fcb       Do12-gfxtbl         $12 - End Graphics
                    fcb       Do13-gfxtbl         $13 - Erase Graphics
                    fcb       Do14-gfxtbl         $14 - Home Graphics Cursor

Do10                leax      <Preset,pcr         set up return address
                    lbra      L03BD

Preset              lda       <V.NChr2,u          get param byte
                    tst       <V.Mode,u           which mode?
                    bpl       L07A7               branch if 128x192 4 color
                    ldb       #$FF                assume we will clear with $FF
                    anda      #$01                mask out all but 1 bit (2 colors)
                    beq       Do13                erase graphic screen with color $00
                    bra       L07B2               else erase screen with color $FF

L07A7               anda      #$03                mask out all but 2 bits (4 colors)
                    leax      <Mode1Clr,pcr       point to color table
                    ldb       a,x                 get appropriate byte
                    bra       L07B2               and start the clearing

* Erase graphics screen. Changed to use new V.ClrBlk vector (mini stack blast
* for 6809, TFM for 6309)
* Long term - make a system call for this, so that all system modules (and
* even user programs) can use it. Mini-stack blast for 6809, tfm for 6309)
* This would clear a contiguous chunk of RAM (in 4 byte chunks only).
* Entry for clearing with color 0
Do13                clrb                          Color 0 to clear with
* Entry for clearing with color in B
L07B2               pshs      b,u                 Save color code & static mem ptr
                    ldy       >V.ClrBlk,u         Get ptr to ClrBlk routine
                    ldd       #6144               Size of gfx screen to clear
                    addd      <V.SBAdd,u          Add size to ptr to start of screen
                    tfr       d,u                 U=ptr to end of screen+1
                    ldx       #6144               Size to clear into register for vector
                    puls      b                   Get color code back
                    jsr       ,y                  Call ClrBlk vector
                    puls      u                   Get back static mem ptr
* Home Graphics cursor
Do14                clra
                    clrb
                    std       <V.GCrsX,u
                    rts

*
* Ding - tickle CoCo's PIA to emit a sound
* 6809/6309 - preserve X as well, and then ldx #PIA0Base+3 and used ,x offsets
* NOTE: This is much more sophisticated than the Dragon version. Not sure if
* it has to be. (See DoBell in CoHR/Co42)
Ding                pshs      d,x
                    ldx       #PIA0Base+3         Point to most common address we will be using
                    lda       -2,x                >PIA0Base+1
                    ldb       ,x                  >PIA0Base+3
                    pshs      d
                    ifne      H6309
                    andd      #$F7F7
                    else
                    anda      #$F7
                    andb      #$F7
                    endc
                    sta       -2,x                >PIA0Base+1
                    stb       ,x                  >PIA0Base+3
                    lda       >PIA1Base+3
                    pshs      a
                    ora       #$08
                    sta       >PIA1Base+3
                    ldb       #10                 Outside loop ctr
L07E6               lda       #$FE
                    bsr       DingDuration
                    lda       #$02
                    bsr       DingDuration
                    decb
                    bne       L07E6
                    puls      a
                    sta       >PIA1Base+3
                    puls      d
                    sta       -2,x                >PIA0Base+1
                    stb       ,x                  >PIA0Base+3
                    puls      pc,x,d

DingDuration
                    sta       >PIA1Base
                    lda       #128
L0805               inca
                    bne       L0805
                    rts

* Since these are called by a JSR vector, they doesn't need to be near anything, so put
* both ClrBlk & CpyBlk at end of VTIO, and set up vectors to them in VTIO Init routine

* ClrBlk - Clear contiguous block of memory with a byte value (grfdrv level II text mode
* patches will need 16 bit word value to cover attribute/character bytes)
* HOPEFULLY OPTIMIZED SMALLER FOR 6809 03/12/2018 LCB
* Entry: B=byte value to clear with
*        X=size
*        U=ptr to end+1 of memory to clear up to
*  Exit: U=Ptr to start of block of memory cleared (if 6809) OR
*          Ptr to end of block of memory cleared (if 6309)
*        NOTE that D and X are destroyed in 6809 version
* Will need to check all calling routines from various modules, to see which of above
*  should be default (if ptr is needed), and adjust the other to match
* ClrBlk (aside from set up and/or leftover bytes) takes 3 cyc/byte in 6309 mode, and
*   3.5 cyc/byte in 6809 mode (except every 1,024th byte takes a few extra)
* Since these are called by a JSR vector, they doesn't need to be near anything, so put
* both ClrBlk & CpyBlk at end of VTIO, and set up vectors to them in VTIO Init routine
ClrBlk
                    ifne      H6309
                    pshs      b                   Save value to clear with
                    tfr       x,w                 Move size to TFM size register
                    subr      w,u                 Calc start ptr of block (TFM can't do 1 location to decrementing address)
                    tfm       s,u+                Clear mem
                    puls      b,pc                Eat stack & return
                    else
                    tfr       b,a                 D=double copy of value to clear memory with
                    exg       x,d                 D=Size to clear (in bytes), X=2 byte value to clear with
                    pshs      b,x                 Save 16 bit value to clear with, & LSB of size (to check for leftover bytes)
                    lsra                          Divide size by 4 (since we are doing 4 bytes at a time)
                    rorb
                    lsra
                    rorb
                    pshs      d                   Save mini-stackblast counters
                    ldd       2,s                 Get A=LSB of # of bytes to clear, B=byte to clear with
                    anda      #$3                 Non-even multiple of 4?
                    beq       NoOdd               Even, skip single byte cleanup copy
OverLp              stb       ,-u                 Save odd bytes
                    deca
                    bne       OverLp
NoOdd               ldd       ,s++                Get Mini-stack blast ctrs back
                    beq       ExitClrB            No 4 byte blocks, done
                    tsta                          Special case: Is A=0?
                    bne       NormClr             No, start stack blasting
                    inca                          If A=0, bump to 1 so we don't wrap and try to do 256 1K copies
NormClr             leay      ,x                  Dupe 16 bit clear value to Y
ClrLp               pshu      x,y                 Clear 4 bytes
                    decb                          Dec "leftover" (<256) 4 byte block counter
                    bne       ClrLp               Keep doing till that chunk is done
                    deca                          Dec 1Kbyte counter
                    bne       ClrLp               Still going (B has been set to 0, so inner loop is 256 now)
ExitClrB            puls      b,x,pc              Eat temp regs & return
                    endc

* CpyBlk - Copy contiguous block of memory with a byte value (for screen scrolling, insert/delete line,etc.)
* New, more optimized version (I hope) as of March 12, 2018
* Entry: D=size of copy
*        Y=ptr to destination of copy
*        U=ptr to source of copy (PULU from here on 6809 version)
*  Exit: U=Ptr to end of source copy+1
*        Y=Ptr to end of dest copy+1
*        D=NOTE: NEW CODE WILL HAVE D AS END ADDRESS OF SOURCE OF COPY
* NOTE: No routines in VTIO use this call - it will be called from sub-modules. Putting it in here
* since VTIO always gets initialized first.
                    ifne      H6309
CpyBlk              tfr       d,w                 Copy size to TFM size register
                    tfm       u+,y+               Copy memory
                    rts
                    else
CpyBlk              leax      d,u                 Calculate source end address
                    pshs      x                   Save on stack to compare with so we know when to stop
                    andb      #$03                Check if we have odd bytes leftover (1-3)
                    beq       CpyLpSt             No, skip to check if copy is done, and stack blast 4 byte chunks if yes
CpyLp2              lda       ,u+                 (6) Copy extra 1-3 bytes
                    sta       ,y+                 (6)
                    decb                          (2)
                    bne       CpyLp2              (3)
                    bra       CpyLpSt             Start with cmpu to end of copy (if copy was only 1-3 bytes, we are done already)

* Now, copy all 4 byte chunks. End address remains the same, so we can eliminate some stuff we had before
CpyLp               pulu      d,x                 Get 4 bytes from source (ascending order)
                    std       ,y++                Copy to destination
                    stx       ,y++
CpyLpSt             cmpu      ,s                  Done 4 byte blast copy?
                    blo       CpyLp               No, keep doing until done
                    puls      pc,d                Get end address of source copy and return
                    endc
                    emod
eom                 equ       *
                    end
