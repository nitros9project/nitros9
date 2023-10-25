********************************************************************
* CoVDG - VDG Console Output Subroutine for VTIO
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00
*
*          2003/09/22  Rodney Hamilton
* recoded dispatch table fcbs, fixed cursor color bug
*
*          2017/12/20  Boisy Pitre
* Added support for CoCoVGA 64x32 mode
*
*   2      2018/03/02  David Ladd
*        - 2018/03/24  L. Curtis Boyle
* General optimizations, and support for new V.ClrBlk and V.CpyBlk
*   vector calls (from VTIO) for either 6309 TFM for mini-stack blasting
*   (4 bytes/chunk) for screen scroll and screen clears (full & partial)
* Also, CoVGA support integrated/completed for 64x32 text mode, and SS.Cursr
*   GetStat call bugs fixed (for both CoVGA and CoVDG)

                    nam       CoVDG
                    ttl       VDG Console Output Subroutine for VTIO

* Disassembled 98/08/23 17:47:40 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

                    ifne      COCOVGA
COLSIZE             equ       64
ROWSIZE             equ       32
MODFLAG             equ       ModCoVGA
                    else
COLSIZE             equ       32
ROWSIZE             equ       16
MODFLAG             equ       ModCoVDG
                    endc

u0000               rmb       0
size                equ       .
                    fcb       $07

name                equ       *
                    ifne      COCOVGA
                    fcs       /CoVGA/
                    else
                    fcs       /CoVDG/
                    endc
                    fcb       edition

* Init
Init                pshs      y,x                 save regs
                    lda       #$AF
                    sta       <V.CColr,u          save default color cursor
                    pshs      u                   save static ptr
                    ldd       #COLSIZE*ROWSIZE+256 allocate screen + 256 bytes for now
                    os9       F$SRqMem            get it
                    tfr       u,d                 put ptr in D
                    leax      ,u                  and X
                    bita      #$01                odd page?
                    beq       L0052               branch if not
                    leax      >256,x              else move X up 256 bytes
                    bra       L0056               and return first 256 bytes

L0052               leau      >COLSIZE*ROWSIZE,u  else move X up 512 bytes
L0056               ldd       #256                and return last 256 bytes
                    os9       F$SRtMem            free it!
                    puls      u                   restore static ptr
                    stx       <V.ScrnA,u          save VDG screen memory
                    pshs      y
                    leay      -$0E,y
                    clra
                    clrb
                    jsr       [<V.DspVct,u]       display screen (SetDsply routine in VTIO) (Preserves X)
                    puls      y
                    stx       <V.CrsrA,u          save start cursor position
                    leax      >COLSIZE*ROWSIZE,x  point to end of screen
                    stx       <V.ScrnE,u          save it
LDClrCh             lda       #$60                get default character
                    sta       <V.CChar,u          put character under the cursor
                    sta       <V.Chr1,u           only referenced here ??

                    ifne      COCOVGA
***** START OF COCOVGA 64x32 MODE
                    clr       <V.Caps,u           lowercase mode
                    pshs      cc,u
                    orcc      #IntMasks           Shut off IRQ/FIRQ
                    ldx       #$FF03              Point to PIA
                    lda       ,x                  Get current state of PIA
                    pshs      a                   Save copy
                    lda       ,x                  Now, force things necessary for CocoVGA to work
                    ora       #$04                ensure PIA 0B is NOT dir setting
                    sta       ,x
                    lda       ,x
                    anda      #$fd                vsync irq - trigger falling edge
                    sta       ,x
                    lda       ,x
                    ora       #$01                enable vsync IRQ
                    sta       ,x
                    leax      VGASetup,pcr        Point to set up values (9 of them)
                    ldu       <V.ScrnA,u          CoVGA requires are setup sequence to be at start of 512 byte boundary
                    ldb       #VGASetupLen        This routine copies our 9 bytes to the start of the screen (Based on
x@                  lda       ,x+
                    sta       ,u+
                    decb
                    bne       x@

                    lda       $FF02               clear any pending vsync
tlp@                lda       $FF03               wait for flag to indicate
                    bpl       tlp@                falling edge of FS
                    lda       $FF02               clear vsync interrupt flag

* PROGRAM THE COCOVGA COMBO LOCK
BT13                ldx       #$FF22              Point to PIA
                    lda       ,x                  GET CURRENT PIA VALUE
                    tfr       A,B                 COPY TO B REG TOO
                    anda      #$07                MASK OFF BITS WE'LL CHANGE
                    ora       #$90                SET COMBO LOCK 1 BITS
                    sta       ,x                  WRITE TO PIA FOR COCOVGA
                    anda      #$07                CLEAR UPPER BITS
                    ora       #$48                SET COMBO LOCK 2 BITS
                    sta       ,x                  WRITE TO PIA
                    anda      #$07                CLEAR UPPER BITS
                    ora       #$A0                SET COMBO LOCK 3 BITS
                    sta       ,x                  WRITE TO PIA
                    anda      #$07                CLEAR UPPER BITS
                    ora       #$F8                SET COMBO LOCK 4 BITS
                    sta       ,x                  WRITE TO PIA
                    lda       ,x                  get current PIA value
                    anda      #$07                CLEAR UPPER BITS
* 6809/6309 - Isn't this next line useless? It does not change any bits, ever
                    ora       #$00                SET REGISTER BANK 0 FOR COCOVGA
                    sta       ,x                  WRITE TO PIA
                    sta       $FFC0               clear SAM_V0  (Force SAM to text mode)
                    sta       $FFC2               clear SAM_V1
                    sta       $FFC4               clear SAM_V2

* Wait for next VSYNC so CoCoVGA can process data from the current video page
tlp@                lda       $FF03
                    bpl       tlp@

* Restore PIA state and return to text mode - restore original video mode, SAM page
* VDG -> CG2:
                    lda       ,x
                    anda      #$8F
                    ora       #$A0
                    sta       ,x

* SAM -> CG2:
                    sta       $FFC0               clear GM0
                    sta       $FFC3               set GM1
                    sta       $FFC4               clear GM2 FFC4
                    puls      a
                    sta       $FF03               Restore PIA to original state
                    puls      u,cc
***** END OF COCOVGA 64x32 MODE
                    endc
                    lbsr      ClrScrn             clear the screen
* Setup page to
                    ldb       <V.COLoad,u
                    orb       #MODFLAG            set to CoVDG found (?)
L0086               stb       <V.COLoad,u
                    clrb
*The next line is only for testing to see where VGA is breaking
                    puls      pc,y,x

                    ifne      COCOVGA
***** START OF COCOVGA 64x32 MODE
VGASetup            fcb       $00                 Reset register
                    fcb       $81                 Edit mask
                    fcb       $00                 Reserved
                    fcb       $03                 Font (lowercase/t1 character set enabled)
                    fcb       $00                 Artifact (off)
                    fcb       $00                 Extras (off)
                    fcb       $00                 Reserved
                    fcb       $00                 Reserved
                    fcb       $02                 Enhanced Modes (64 column enabled)
VGASetupLen         equ       *-VGASetup
***** END OF COCOVGA 64x32 MODE
                    endc

start               lbra      Init                Hopefully once we tighten INIT code, this can go back to BRA
                    bra       Write
                    nop       Can                 be used for a constant
                    lbra      GetStat
                    lbra      SetStat
Term                pshs      y,x
                    pshs      u                   save U
                    ldd       #COLSIZE*ROWSIZE    VDG memory size
                    ldu       <V.ScrnA,u          get pointer to memory
                    os9       F$SRtMem            return to system
                    puls      u                   restore U
                    ldb       <V.COLoad,u
                    andb      #~MODFLAG
                    bra       L0086
* Write
* Entry: A = char to write
*        Y = path desc ptr
Write               tsta                          Alt (hi bit) char?
                    bmi       L00D0               Yes, go straight to print
                    cmpa      #$1F                Ctrl char? ($00-$1F)?
                    bls       Dispatch            Yes, special handling
                    ldb       <V.CFlag,u          regular ASCII char; get true lowercase flag
                    beq       L00B0               Not set, skip ahead
* VDG-T1 translations
                    cmpa      #$5E                ^ symbol?
                    bne       L00A0               Nope, check next
                    clra                          0 char on VDG
                    bra       L00D0               Put on screen

L00A0               cmpa      #$5F                _ Underline char?
                    bne       L00A8               No, check next
                    lda       #$1F                $1F char on VDG
                    bra       L00D0               Put on screen

L00A8               cmpa      #$60                ' Single quote?
                    bne       L00C0               No, skip ahead to common translations
                    lda       #$67                $67 char on VDG
                    bra       L00D0

* Regular VDG translations
L00B0               cmpa      #$7C                | Pipe symbol?
                    bne       L00B8               No, check next
                    lda       #$21                Yes, change to ! pipe symbol
                    bra       L00D0               Put on screen

L00B8               cmpa      #$7E                ~ Tilde symbol?
                    bne       L00C0               Nope, go do common translations
                    lda       #$2D                Tilde symbol for VDG
                    bra       L00D0               Put on screen

* Common translation to both VDG chips
L00C0               cmpa      #$60                Char below $60?
                    blo       L00C8               Yes, check next range
                    suba      #$60                Drop by $60 for VDG translation
                    bra       L00D0               Put on screen

L00C8               cmpa      #$40                Char below $40?
                    blo       L00CE               Yes, Flip case bit only
                    suba      #$40                Drop for VDG
L00CE               eora      #$40                Force to non-inverse chars on regular VDG
L00D0               ldx       <V.CrsrA,u          get cursor address in X
                    sta       ,x+                 store character at address
                    stx       <V.CrsrA,u          update cursor address
                    cmpx      <V.ScrnE,u          end of screen?
                    blo       L00DF               No, just display the cursor
                    bsr       SScrl               Yes, scroll the screen first
L00DF               bra       ShowCrsr            And turn the cursor back on

* Screen Scroll Routine
SScrl               ldd       #COLSIZE*ROWSIZE-COLSIZE Size of screen minus one line
                    ldx       >V.ClrBlk,u         Get Clear block vector for later
                    pshs      u,x                 Save static mem ptr & Clear block vector
                    ldx       >V.CpyBlk,u         Get vector to Copy block
                    ldy       <V.ScrnA,u          Get ptr to start of text screen
                    leau      <COLSIZE,y          Point to start of 2nd line
                    jsr       ,x                  Call copy block vector (U will point to end of screen+1)
                    ldx       #COLSIZE            Size of block to clear (bottom line)
                    ldb       #$60                VDG Space char
                    puls      y                   Get clear block vector
                    jsr       ,y                  Clear last line (U was pointing to end of last line from above, so it picks up where it left off. I think)
* Since 6309 returns with U=ptr to end of screen, and 6809 returns with ptr to start of last line,
*   we need to differentiate here
                    ifne      H6309
                    leax      -COLSIZE,u          6309 - Bump back to start of last line
                    else
                    leax      ,u                  6809 - already pointing to start of last line
                    endc
                    puls      u                   Get back static mem ptr
                    stx       <V.CrsrA,u          Save new cursor position (Start of last line)
                    rts                           & return

* Ctrl char ($00-$1F) special char dispatch
Dispatch            cmpa      #$1B                escape code?
                    bhs       bad                 branch if same or greater (special control codes for screen controls)
                    cmpa      #$0E                $0E?
                    bhi       L0102               branch if higher than
                    leax      <DCodeTbl,pcr       deal with screen codes
                    lsla                          adjust for table entry size
                    ldd       a,x                 get address in D
                    jmp       d,x                 and jump to routine
*
bad                 comb                          Exit with Write Error
                    ldb       #E$Write
L0102               rts

* display functions dispatch table.
DCodeTbl            fdb       L014D-DCodeTbl      $00:no-op (null)
                    fdb       CurHome-DCodeTbl    $01:HOME cursor
                    fdb       CurXY-DCodeTbl      $02:CURSOR XY
                    fdb       DelLine-DCodeTbl    $03:ERASE LINE
                    fdb       ErEOLine-DCodeTbl   $04:CLEAR TO EOL
                    fdb       Do05-DCodeTbl       $05:CURSOR ON/OFF
                    fdb       CurRght-DCodeTbl    $06:CURSOR RIGHT
                    fdb       L014D-DCodeTbl      $07:no-op (bel:handled in VTIO)
                    fdb       CurLeft-DCodeTbl    $08:CURSOR LEFT
                    fdb       CurUp-DCodeTbl      $09:CURSOR UP
                    fdb       CurDown-DCodeTbl    $0A:CURSOR DOWN
                    fdb       ErEOScrn-DCodeTbl   $0B:ERASE TO EOS
                    fdb       ClrScrn-DCodeTbl    $0C:CLEAR SCREEN
                    fdb       Retrn-DCodeTbl      $0D:RETURN
                    fdb       DoAlpha-DCodeTbl    $0E:DISPLAY ALPHA

* $0D - move cursor to start of line (carriage return)
Retrn               bsr       HideCrsr            hide cursor
                    ifne      H6309
                    aim       #~(COLSIZE-1),<V.CrsAL,u Force cursor to beginning of current line (clear low 5 OR 6 bits of address)
                    else
                    tfr       x,d                 put cursor address in D
                    andb      #~(COLSIZE-1)       place at start of line
                    stb       <V.CrsAL,u          and save low cursor address
                    endc
ShowCrsr            ldx       <V.CrsrA,u          get cursor address
                    lda       ,x                  get char at cursor position
                    sta       <V.CChar,u          save it
                    lda       <V.CColr,u          get cursor character
                    beq       L014D               If cursor off, don't put on screen
L014B               sta       ,x                  else turn on cursor
L014D               clrb                          & exit w/o error
                    rts

* $0A - cursor down (line feed)
CurDown             bsr       HideCrsr            hide cursor
                    leax      <COLSIZE,x          move X down one line
                    cmpx      <V.ScrnE,u          at end of screen?
                    blo       L0162               branch if not
                    leax      <-COLSIZE,x         else go back up one line
                    pshs      x                   save cursor position
                    lbsr      SScrl               & scroll the screen
                    puls      x                   restore pointer
L0162               stx       <V.CrsrA,u          save cursor pointer
                    bra       ShowCrsr            show cursor

* $08 - cursor left
CurLeft             bsr       HideCrsr            hide cursor
                    cmpx      <V.ScrnA,u          compare against start of screen
                    bls       L0173               ignore it if at the screen start
                    leax      -1,x                else back up one
                    stx       <V.CrsrA,u          save updated pointer
L0173               bra       ShowCrsr            and show cursor

* $06 - cursor right
CurRght             bsr       HideCrsr            hide cursor
                    leax      1,x                 move to the right
                    cmpx      <V.ScrnE,u          compare against end of screen
                    bhs       L0181               if past end, ignore it
                    stx       <V.CrsrA,u          else save updated pointer
L0181               bra       ShowCrsr            and show cursor

* $0B - erase to end of screen
ErEOScrn            bsr       HideCrsr            kill the cusror
                    bra       L0189               and clear rest of the screen

* $0C - clear screen
ClrScrn             bsr       CurHome             home cursor (and set X=ptr to start of screen)
* Entry point for partial screen clear
* Entry: X=ptr to start address to clear from
* For V.ClrBlk,u, entry is: B=value to clear with, X=size to clear, U=End of clear block address+1
L0189
                    ifne      H6309
                    pshs      u                   Save static mem ptr
                    ldy       <V.ScrnE,u          Get ptr to end of screen
                    subr      x,y                 Calc size of clear by subtracting current cursor address
                    leax      ,y                  X=size to clear
                    ldy       >V.ClrBlk,u         Get Clear Block subroutine address
                    else
                    pshs      x                   Save start addr to clear from
                    ldd       <V.ScrnE,u          Get ptr to end of screen
                    subd      ,s++                Calc size of clear (subtract start addr)
                    tfr       d,x                 Move size to X
                    ldy       >V.ClrBlk,u         Get Clear Block subroutine address
                    pshs      u                   Save static mem ptr
                    endc
                    ldu       <V.ScrnE,u          Point to end address of screen
                    ldb       #$60                VDG Space char
                    jsr       ,y                  Go clear
                    puls      u                   Get static mem ptr back
                    bra       ShowCrsr            Turn cursor back on

* $01 - home cursor
CurHome             bsr       HideCrsr            hide cursor
                    ldx       <V.ScrnA,u          get pointer to screen
                    stx       <V.CrsrA,u          save as new cursor position
                    bra       ShowCrsr            and show it

* Hides the cursor from the screen
* Exit: X = address of cursor
HideCrsr            ldx       <V.CrsrA,u          get address of cursor in X
                    lda       <V.CChar,u          get value of char under cursor
                    sta       ,x                  put char in place of cursor
NoErr1              clrb                          must be here, in general, for [...] BRA HideCrsr
                    rts

* $05 XX - set cursor off/on/color per XX-32
Do05                ldb       #$01                need additional byte
                    leax      <CrsrSw,pcr         Get vector to return to after we get byte
                    bra       L01E5               Save vector, and go get parameter byte

CrsrSw              lda       <V.NChr2,u          get next char
                    suba      #C$SPAC             take out ASCII space
                    bne       L01BB               branch if not zero
                    sta       <V.CColr,u          else save cursor color zero (no cursor)
                    bra       HideCrsr            and hide cursor

L01BB               cmpa      #11                 >=11?
                    bge       NoErr1              yep, ignore & return w/o error
                    cmpa      #1                  is it one (Blue cursor from level 1)?
                    bgt       L01C7               No, try next
                    lda       #$AF                Yes, default blue cursor color
                    bra       L01D7               and save it

L01C7               cmpa      #2                  is it two (black cursor from level 1)?
                    bgt       L01CF               branch if larger
                    lda       #$A0                else get black cursor color
                    bra       L01D7               and save it

L01CF               lsla                          shift into upper nibble
                    lsla
                    lsla
                    lsla
                    ora       #$8F
L01D7               sta       <V.CColr,u          save new cursor
                    ldx       <V.CrsrA,u          get cursor address
                    lbra      L014B               branch to save cursor in X

* $02 XX YY - move cursor to col XX-32, row YY-32
CurXY               ldb       #2                  we neeed two more parameters
                    leax      <DoCurXY,pcr        Get vector to return to after we get params
L01E5               stx       <V.RTAdd,u          Save it
                    stb       <V.NGChr,u          Save # chars needed as params
                    clrb                          No error, and go get missing param bytes
                    rts

DoCurXY             bsr       HideCrsr            hide cursor
                    ldb       <V.NChr2,u          get ASCII Y-pos
                    subb      #C$SPAC             take out ASCII space
                    lda       #COLSIZE            Calculate vertical offset from start of screen to line we want
                    mul                           multiply it
                    addb      <V.NChar,u          add in X-pos
                    adca      #$00
                    subd      #C$SPAC             take out another ASCII space
                    addd      <V.ScrnA,u          add top of screen address
                    cmpd      <V.ScrnE,u          past end of screen?
                    bhs       NoErr1              Yes, ignore & exit w/o error
                    std       <V.CrsrA,u          otherwise save new cursor address
                    lbra      ShowCrsr            and show cursor

* $04 - erase to end of line
ErEOLine            bsr       HideCrsr            hide cursor
                    tfr       x,d                 move current cursor position to D
                    andb      #COLSIZE-1          number of characters put on this line
                    pshs      b
                    ldb       #COLSIZE            Calculate # of chars left in line
                    subb      ,s+
                    bra       L0223               and clear that many

* $03 - erase line
DelLine             lbsr      Retrn               do a CR
                    ldb       #COLSIZE            line length
* Entry: B=# of bytes to erase, X=ptr to start of copy
L0223               ldy       >V.ClrBlk,u         Get ClrBlk vector (before we destroy u)
                    pshs      u                   Save static mem ptr
                    leau      b,x                 Point U to end of line
                    clra                          D=size
                    tfr       d,x                 Move to X for ClrBlk
                    ldb       #$60                VDG space char
                    jsr       ,y                  Call ClrBlk
                    puls      u                   Get static mem back
                    lbra      ShowCrsr            Turn cursor back on & return from there

* $09 - cursor up
CurUp               lbsr      HideCrsr            hide cursor
                    leax      <-COLSIZE,x         move X up one line
                    cmpx      <V.ScrnA,u          We past top of screen?
                    blo       L023E               Yes, leave cursor pos along and turn it back on
                    stx       <V.CrsrA,u          No, save new cursor Y position
L023E               lbra      ShowCrsr            Show cursor & return from there

* $0E - switch screen to alphanumeric mode
DoAlpha             clra
                    clrb                          Text mode
                    jmp       [<V.DspVct,u]       display screen (routine in VTIO)

* GetStat
GetStat             ldx       PD.RGS,y            get caller's regs
                    cmpa      #SS.AlfaS           AlfaS?
                    beq       Rt.AlfaS            branch if so
                    cmpa      #SS.Cursr           Cursr?
                    beq       Rt.Cursr            branch if so

* SetStat - All SetStat calls return "Unknown Service" error
SetStat             comb
                    ldb       #E$UnkSvc
                    rts

* SS.AlfaS getstat
Rt.AlfaS            ldd       <V.ScrnA,u          memory address of buffer
                    std       R$X,x               save in caller's X
                    ldd       <V.CrsrA,u          get cursor address
                    std       R$Y,x               save in caller's Y
                    lda       <V.Caps,u           save caps lock status in A and exit
                    bra       SaveA

* SS.Cursr getstat. NOTE: It appears that X,Y coords are returned with +$20 built in (to match
*   the original CurXY ($02 xx+$20 yy+$20) display code).
Rt.Cursr            ldd       <V.CrsrA,u          get address of cursor
                    subd      <V.ScrnA,u          subtract screen address
                    pshs      d                   D now holds cursor position relative to screen
                    clra
                    andb      #COLSIZE-1          Keep X coord bits only (0-31 or 0-63)
                    addb      #$20                compute column position (+$20 for CurXY offsets)
                    std       R$X,x               save column position to caller's X
                    puls      d                   then divide by 32 for VDG, and 64 for VGA
                    ifne      COCOVGA
                    lsra                          Need three 16 bit divides (/8) - now 8 bit (2048->1024->512->256)
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsrb                          Finish divide by 64 with just 8 bit divides
                    lsrb
                    lsrb
                    else
                    lsra                          16 bit divide - now our result is within 8 bit range(512->256)
                    rorb
                    lsrb                          Finish divide by 32 with just 8 bit divides
                    lsrb
                    lsrb
                    lsrb
                    endc
                    addb      #$20                compute row (+$20 for CurXY offsets
                    std       R$Y,x               and save column to caller's Y
                    ldb       <V.CFlag,u          Get true lowercase flag
                    lda       <V.CChar,u          get character under cursor
                    bmi       SaveA               if hi bit set, return that value to caller
                    cmpa      #$60                Lowercase?
                    bhs       L02A5               Yes, skip ahead
                    cmpa      #$20                #, uppercase, some punctuation?
                    bhs       L02A9               Yes, Change if VDG-T1
                    tstb                          Real lowercase enabled?
                    beq       L02A3               No, convert to ASCII from VDG code
                    tsta                          VDG caret?
                    bne       L029B               No, try some other special ones
                    lda       #$5E                Replace with ASCII caret ^
                    bra       SaveA               save it and exit

L029B               cmpa      #$1F                VDG underscore?
                    bne       L02A3               No, done special checks
                    lda       #$5F                Yes, replace with underscore
                    bra       SaveA

L02A3               ora       #$20                turn it into ASCII from VDG codes
L02A5               eora      #$40                Switch to uppercase
                    bra       SaveA

L02A9               tstb                          True lowercase on with VDG-T1?
                    bne       SaveA               yes, save char
                    cmpa      #$21                No, remap specific codes - exclamation/pipe?
                    bne       L02B4               No, try one more special one
                    lda       #$7C                Replace with actual ASCII pipe
                    bra       SaveA

L02B4               cmpa      #$2D
                    bne       SaveA
                    lda       #$7E                Replace with ASCII tilde
SaveA               sta       R$A,x
                    clrb
                    rts

                    emod
eom                 equ       *
                    end
