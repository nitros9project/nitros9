********************************************************************
* keydrv - Keyboard subroutine module for Wildbits VTIO
*
* Level 2 version: the multiterminal vtio's keyboard module.  Level 2
* recipes find this file before level1/wildbits/modules/keydrv_k2.asm, which
* Level 1 keeps using.  It adds terminal switching (Alt+Left/Right), the
* held-key table gr.KeyLive for SS.LiveKeys, and key repeat by key position.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2024/02/17  Boisy G. Pitre
* Started.
*
*  2        2024/06/17  Boisy G. Pitre (Waco, TX)
* Fixed the SS.KySns routine to properly set/clear D.KySns bits for supported keys,
* and added support for V.PAU.
*
*  3        2024/06/26  Boisy G. Pitre
* Added an optimization check to prevent needing to do a full scan every SOF interrupt
* thanks to a suggestion by @gadget.
*
*  4       2025/09/12   John A. Federico
* Modified driver for K2 Optical Keyboard
*
*  5       2026/09/14   John A. Federico
* Key repeat is cleared on keyup by key position (V.RptKey) instead of by
* character, so a Shift change between press and release no longer leaves
* the repeat stuck.
*
*  6       2026/10/13   John A. Federico
* Key repeat is the core's (hardware typematic, v8_rc8+ K2 cores) and the
* keyboard has its own interrupt (KBD_IRQSvc); vtio's AltISR no longer polls
* it or times the repeat.  Based on Roger Taylor's
* wb/k2_core_typematic_support.
*
*  7       2026/10/27   John A. Federico
* Space sets SPACEBIT in D.KySns (the matrix had C$SPAC, not kSPACE, so it
* never reached the arrow path), as on the Jr2; gr.KeyLive still holds $20.


                    use       defsfile
                    use       wildbits_vtio.d

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       3

                    mod       eom,name,tylg,atrv,start,size

size                equ       V.Last

                    fcb       UPDAT.+EXEC.

name                fcs       /keydrv/
                    fcb       edition

                    org       V.KeyDrvStat
V.META              rmb       1         the state of the Wildbits "META" key
DownRightStates     rmb       1         the state of the down and right arrow keys during polling
V.RptKey            rmb       1         table index (row*8+col) of the key that armed the repeat
V.RowChg            rmb       1         nonzero = some row changed during this FIFO event

* keydrv has three 3-byte entry points:
*   - Init
*   - Term
*   - AltISR: not called any more.  The keyboard has its own interrupt
*     (KBD_IRQSvc); the entry is kept so the table matches keydrv_ps2.
start               lbra      Init
                    lbra      Term
                    lbra      AltISR
AltISR              rts

********************************************************************
* Key repeat is the core's (OKB.TypDly/TypPer/TypCtl, set in Init).
* While a key is held, the core pushes the whole matrix again every
* repeat period; an event in which no row changed is such a push, and
* ReadFIFOData buffers V.LastCh again.  BufferChar sets V.LastCh and
* ProcessRow records the key's table index (row*8+col) in V.RptKey.
* A keyup clears V.LastCh only when its index matches V.RptKey.
* Matching by position rather than by character matters because the
* key table follows Shift: a Shift change between press and release (or
* Shift lifted in the same FIFO frame as a key in a later row) used to
* look the key up as a different character and leave the repeat stuck.
* It also keeps Backspace/Left ($08) and Tab/Right ($09) from cancelling
* each other.  KEYDELAY1 (=30) and KEYDELAY (=5) are in wildbits_vtio.d,
* in frames.

********************************************************************
* Read all 8 pairs of bytes from FIFO and process
* 8 pairs represent 9 row keyboard matrix (Rows 0-8)
* This reads the columns for rows 0-7. (8 pairs of bytes)
* Row 8 is contained in the first bit of the row byte.
* Build Row 8 a bit at a time from the first bit of row byte for Rows 0-7,
* then run it through the loop at the end to process Row #8
*
* OKB.Base = base address of Optical Keyboard $FE10
* D.RowState = historical value (last value) for the column bits
* for a particular row - used to detect changed keys
* WBKKyDn = raw column bits and is used to determine
* KeyUp/Down state.
*
* Get the column bits for Row X, eora with historical bits to
* find the changed bits only.  Then act on those changed bits.
* KeyDown will buffer key.  Ignore keyup for non-modifier keys.
* Process keyup for modifier keys.
*
* Optical keyboard fills FIFO with matrix on keyup or keydown
* in 2 byte pais:
*  |4bits|4bits|  |          8 bits         |
*  |Row# |Row8 |  |Row Maxtrix Bits Cols 0-7|
********************************************************************
ReadFIFOData        clr       V.RowChg,u ; no row change seen yet this event
* gr.KeyLive is rebuilt from scratch here: the FIFO carries the whole
* matrix on every event, so the array cannot drift or strand a key.
                    ldx       #gr.KeyLive
                    ldb       #KeyLiveSz
clrlive@            clr       ,x+
                    decb
                    bne       clrlive@
                    ldx       #OKB.Base ; point to optical keyboard
                    ldb       #0        ; 8 pairs to read
                    ldy       #D.RowState ; historical column bits
                    leas      -1,s      ; store Row8 columns on stack
                    clr       ,s        ; clear Row8 columns
read_loop@          lda       OKB.Data,x ; read row byte
                    rora                ; build Row8 by rotating bit
                    ror       ,s        ; onto the stack
loadcol@            lda       OKB.Data,x ; read column byte
doRow8@             sta       D.WBKKyDn ; store in current column keys down
                    eora      b,y
                    beq       skipprocess@ ; if the column is 0, skip processing
                    lbsr      ProcessRow ; column is not zero, process keydown
skipprocess@        lda       D.WBKKyDn ; load raw column value
cont@               sta       b,y       ; store as historical value
                    lbsr      AddRowLive ; record this row's held keys
                    incb                ; increment to last row
                    cmpb      #8
                    bhi       row9end@  ; if 9, then end
                    bne       read_loop@ ; if not 8, then keep looping
                    puls      a         ; if 8, pull Row8 from stack and process
                    bra       doRow8@
* An event in which no row changed is the core's repeat push: buffer the
* held character again.  (Modifier-only holds never set V.LastCh, so they
* repeat nothing.)
row9end@            tst       V.RowChg,u ; did any row change this event?
                    bne       rfdone@   ; yes - normal key event, done
                    lda       V.LastCh,u ; repeatable character held?
                    beq       rfdone@   ; no - nothing to repeat
                    lbsr      BufferChar ; emit the held character again
                    lbsr      HandleSignals ; and signal it like any keypress
rfdone@             rts

********************************************************************
* ProcessRow - process changes in keyboard row
* b=row a=eora changed bits
* Process 1 bit at a time, if keydown, then buffer
* If modifer key, handle keyup and keydown
* In the loop X = start of the key table and B = the key's table index
* (row*8+col), so b,x is the key and B identifies it for V.RptKey.
* KeyDownTest masks B down to the column itself.

ProcessRow          pshs      d,x,y
                    inc       V.RowChg,u ; a row changed - this is a real key event
                    lda       D.KySns   ; check SHIFT to set correct key table
                    bita      #SHIFTBIT
                    beq       noshift@
                    leax      WBKShiftKeys,pcr
                    bra       rowcomp@
noshift@            leax      WBKKeys,pcr ; get the current key index
rowcomp@            lda       ,s        ; get the eora changed bits
                    lslb                ; multiply row x8 to get the offset
                    lslb
                    lslb                ; b = index of the row's first key
loop@               lsla
                    bcc       nextbit@  ; if bit is clear, move to next bit
                    pshs      a
                    lda       b,x       ; get the key from the table
                    cmpa      #$EF      ; modifier keys defined as $F0 and greater
                    bhi       processmodifier ; if modifier,process modifier key
                    cmpa      #$DF
                    bhi       processarrows
                    lbsr      KeyDownTest ; check if key is down or up
                    bcc       rstkeyrpt@ ; keyup - ignore
bufferit@           stb       V.RptKey,u ; keydown - remember which key arms the repeat
                    lbsr      BufferChar ; buffer the character
                    lbsr      HandleSignals ; signal key in buffer
                    bra       skipbuffer@
rstkeyrpt@          cmpb      V.RptKey,u ; on key up, is this the key that armed the repeat?
                    bne       skipbuffer@ ; if not the same, skip
                    clr       V.LastCh,u ; if same, the repeat stops
skipbuffer@         puls      a
nextbit@            incb
                    bitb      #7        ; low 3 bits wrap to 0 after column 7
                    bne       loop@
                    puls      d,x,y,pc
********************************************************************
* Process Modifier - handle modifier keys and KeySns
processmodifier     lbsr      KeyDownTest ; check if modifier is KeyUp/Down
                    bcc       pupmodifier ; keyUp - clear modifier bits
                    pshs      d,x
                    ldb       D.KySns   ; set KySns keydown modifier bits
                    cmpa      #META     ; check for META key
                    blo       stdkey@   ; if less than, then process std mod keys
                    beq       doMeta@   ; if equal, then process meta key
                    bhi       doCapslock@ ; if higher, then process caps lock
doMeta@             bra       moddone@  ; process meta key
doCapslock@         lda       V.CAPSLck,u ; load caps lock bit
                    eora      #SHIFTBIT ; invert caps lock state bit
                    sta       V.CAPSLck,u ; save it back
                    bne       doled@    ; if >1, then turn on led
                    andb      #^SHIFTBIT ; if not, then turn off shift bit
doled@              lda       SYS0      ; get led bits
                    eora      #SYS_CAP_EN ; toggle caps lock led
                    sta       SYS0      ; save led bits
                    bra       moddone@  ; done
stdkey@             suba      #$F0      ; std keys, subtract to get index
                    leax      ModTbl,pcr ; load table
                    orb       a,x       ; or the bits from the table
moddone@            stb       D.KySns   ; store the KySNS
                    puls      d,x
                    bra       skipbuffer@
********************************************************************
* Process Modifier Up - handle modifier keys and KeySns
pupmodifier         pshs      d,x
                    ldb       D.KySns   ; set KySns keyup modifier bits
                    cmpa      #META     ; check for meta key
                    blo       stdupkey@ ; if lower, then process std modifityh
                    beq       doMetaUp@ ; if equal process meta-up
                    bra       modupdone@
doMetaUp@           bra       modupdone@
stdupkey@           suba      #$F0      ; subtract to get index
                    leax      ModUpTbl,pcr ; load table
                    andb      a,x       ; get value from table
modupdone@          stb       D.KySns   ; save new KySns
                    puls      d,x
                    bra       skipbuffer@
********************************************************************
* Process Arrows - handle arrow keys and KeySns
* Set KySns flags for arrows and translate arrow to appropriate key value
processarrows       bsr       KeyDownTest ; check if modifier is KeyUp/Down
                    bcc       puparrows ; keyUp - clear modifier bits
                    pshs      d,x
                    ldb       D.KySns   ; set KySns keydown modifier bits
********************************************************************
* Alt+Left / Alt+Right switch terminals instead of producing a
* character, the same as keydrv_ps2's DoLeftArrowDown/DoRightArrowDown.
* Tested here on the arrow's KEYDOWN and nowhere else: a latched ALTBIT
* plus any later key used to look like a switch in the PS/2 driver.
* SwitchTerm's SW.Next walks UP the terminal ids, so Alt+Right takes you
* toward /vt1, /vt2 and Alt+Left back toward /term.
*
* Exits through skipbuffer@ rather than bufferit@ - the K2 equivalent of
* the PS/2 driver's 'comb' (do not treat as input).  That also means no
* key repeat is armed, so holding Alt+Left does not repeat the switch,
* which is what the PS/2 driver does too.
*
* ORDERING: rows are scanned 0..8 and the FIFO delivers the whole matrix
* per event, so a same-scan Alt press is seen AFTER kLEFT (row 0 col 5)
* and BEFORE kRIGHT (row 8 col 1); RALT is row 6 col 2.  Press Alt first
* - which is what anyone actually does, and it is then already latched
* from its own earlier event.  Land both keys inside one 16ms scan and
* Alt+Left emits its character ($08) instead of switching.
********************************************************************
                    bitb      #ALTBIT   ; alt held?
                    beq       noswitch@
                    cmpa      #kLEFT
                    beq       switchl@
                    cmpa      #kRIGHT
                    bne       noswitch@
                    lda       #SW.Next  ; alt+Right = next terminal
                    bra       switch@
switchl@            lda       #SW.Prev  ; alt+Left = previous terminal
switch@             sta       >gr.SwitchReq
                    andb      #^(LEFTBIT+RIGHTBIT) ; keep ALTBIT if Alt still down
                    stb       D.KySns
                    puls      d,x
                    lbra      skipbuffer@ ; do not treat as input
noswitch@           leax      ModChrTbl,pcr ; get ModChr table
                    suba      #$E0      ; subtract to get index
                    orb       a,x       ; set KySns value
                    stb       D.KySns   ; store KySns
                    leax      ChrTbl,pcr ; change to char table
                    lda       a,x       ; get arrow character
                    sta       ,s        ; replace stack value
arrowdone@          puls      d,x
                    lbra      bufferit@ ; buffer arrow character
********************************************************************
* Process Arrows Up - handle arrow    keys and KeySns
puparrows           pshs      d,x
                    ldb       D.KySns   ; set KySns keyup modifier bits
                    leax      ModChrUpTbl,pcr ; get ModChrUp table
                    suba      #$E0      ; subtract to get index
                    andb      a,x       ; and KySns with up value to erase
                    stb       D.KySns   ; store KySns
arrowupdone@        puls      d,x
                    lbra      rstkeyrpt@ ; skip buffering on keyup
********************************************************************
* KeyDown Test - check bit in original keypress
* on entry b = key table index (low 3 bits = column to test),
* raw row value is stored in D.WBKKyDn
* Carry  1=keydown 0=keyup
KeyDownTest         pshs      d,x
                    andb      #7        ; column only
                    leax      keybits,pcr
                    lda       D.WBKKyDn
                    andcc     #$FE
                    bita      b,x
                    beq       end@
                    orcc      #$01
end@                puls      d,x,pc

keybits             fcb       $80,$40,$20,$10,$08,$04,$02,$01

********************************************************************
* AddRowLive - add row B's held keys to gr.KeyLive
*
* Entry: A = the row's raw column bits (1 = down, column 0 = bit 7)
*        B = the row number (0-8)
* Exit:  A, B, X, Y preserved; CC clobbered
*
* Called for EVERY row, changed or not - that is the point.  ProcessRow
* sees only rows and bits that CHANGED, so a key still held but unmoved
* this event is invisible there.  Modifiers ($F0-$F4) and arrows
* ($E0-$E3) are skipped; they live in D.KySns.  Space (kSPACE) is in
* both: SPACEBIT in D.KySns and C$SPAC here, as keydrv_ps2 does.  WBKKeys (unshifted) is
* always used, so a key has one identity whatever Shift is doing.
********************************************************************
AddRowLive          pshs      d,x,y
                    tsta                ; nothing down in this row?
                    beq       arldone@
                    lslb                ; b = row*8 = the row's first key index
                    lslb
                    lslb
                    leay      WBKKeys,pcr
arlbit@             lsla                ; next column into the carry
                    bcc       arlnext@
                    pshs      a
                    lda       b,y       ; the key at this position
                    beq       arlskip@  ; an unpopulated position
                    cmpa      #kSPACE   ; space is held as its character
                    bne       arlmod@
                    lda       #C$SPAC
arlmod@             cmpa      #$DF      ; modifier or arrow?
                    bhi       arlskip@  ; yes - it is in D.KySns
                    bsr       AddKeyLive
arlskip@            puls      a
arlnext@            incb
                    bitb      #7        ; low 3 bits wrap to 0 after column 7
                    bne       arlbit@
arldone@            puls      d,x,y,pc

********************************************************************
* AddKeyLive - put key code A in the first free gr.KeyLive slot
*
* Entry: A = an unshifted key code (never 0)
* Exit:  A, B, X, Y preserved; CC clobbered.  A full array drops the
*        key: the rebuild fills in scan order, so the lowest row and
*        column win.  No duplicate check is needed - each matrix
*        position is visited once per rebuild.
********************************************************************
AddKeyLive          pshs      b,x
                    ldx       #gr.KeyLive
                    ldb       #KeyLiveSz
aklfind@            tst       ,x
                    beq       aklput@
                    leax      1,x
                    decb
                    bne       aklfind@
                    puls      b,x,pc    ; no room - drop it
aklput@             sta       ,x
                    puls      b,x,pc

********************************************************************
* BufferChar - take the char in a and place in buffer
* Advance the circular buffer one character.

BufferChar          pshs      d,x,y
* WILDBITS 2026-09-09 (wb/k2_core_typematic_support): NEVER BUFFER A NUL. Row 8 of both key tables has
* six unmapped positions, so a spurious or stuck bit yields $00.  Buffered, any program that polls for
* input reads $00 for ever (UltiMusE III's hang).  Guarded here because every path in (key-down, arrows,
* the repeat) comes through.
                    tsta                ; unmapped key position?
                    beq       bye@      ; yes - drop it, never reaches the buffer
                    sta       V.LastCh,u ; the character the core's repeat pushes buffer again
                    ldb       V.IBufH,u ; get buffer head pointer in B
                    leay      V.KSBuf,u
                    leay      b,y
                    leax      V.InBuf,u ; point X to the input buffer
                    abx                 ; x now holds address of the head pointer
                    lbsr      IncNCheck ; increment the pointer and check for tail wrap
                    cmpb      V.IBufT,u ; is B at the tail? (if so, the input buffer is full)
                    beq       bye@      ; branch if the input buffer is full (drop the character)
                    stb       V.IBufH,u ; update the buffer head pointer
                    tst       V.CAPSLck,u ; test if caps lock is on
                    beq       checkctrl@ ; if not, then go to CTRL check
                    bsr       CapAlpha  ; if on, then capitalize character if alpha char
checkctrl@          ldb       D.KySns   ; check for CTRLBIT
                    bitb      #CTRLBIT
                    beq       checkalt@
                    bsr       CapAlpha
                    bcc       checkalt@
                    suba      #$40      ; subtract #$40 if CTRL down and a-z pressed
                    sta       ,s
                    bra       bufferit@
checkalt@           bitb      #ALTBIT
                    beq       bufferit@
                    bsr       CapAlpha
                    bcc       checknum@
                    adda      #$40
                    bra       bufferit@
checknum@           bsr       AltNum
bufferit@           sta       ,x        ; place the character in the buffer
* Store the KySns in the KSBuf
BufferKSns          lda       D.KySns
                    sta       ,y        ; place the D.KySns in the KS buffer
bye@                puls      d,x,y
                    rts                 ; return

* Check if we need to wrap around tail pointer to zero.
IncNCheck           incb                ; increment the next character pointer
                    cmpb      #KBufSz-1 ; are we pointing to the end of the buffer?
                    bls       ex@       ; branch if not
                    clrb                ; else clear the pointer (wraps to head)
ex@                 rts

********************************************************************
* cap alpha - if this is an alpha character, capitalize it
* if alpha char then also set cc to 1, otherwise 0
CapAlpha            pshs      a
                    anda      #$5F      ; make character uppercase
                    cmpa      #$41      ; compare to 'A'
                    blo       notalpha@
                    cmpa      #$5A      ; compare to 'Z'
                    bhi       notalpha@
                    sta       ,s        ; if alpha, change stored stack value
                    orcc      #$01      ; set cc to 1
                    puls      a,pc
notalpha@           andcc     #$FE      ; if not alpha, set cc to 0
                    puls      a,pc

********************************************************************
* cap alpha - if this is an alpha character, capitalize it
* if alpha char then also set cc to 1, otherwise 0
AltNum              pshs      x
                    cmpa      #$30      ; compare to '0'
                    blo       notnum@
                    cmpa      #$39      ; compare to '9'
                    bhi       notnum@
                    suba      #$30
                    leax      AltNumTbl,pcr
                    lda       a,x
notnum@             puls      x,pc

AltNumTbl           fcb       $5C,0,0,0,$A3,$A4,0,$7E,$60,$7C
********************************************************************
* HandleSignals - Once something is in the buffer, wake a process
* to receive the input and handle pause, interrupt and abort keys

* Check for pause character, and create pause request
HandleSignals       pshs      d,x
                    cmpa      V.PCHR,u  ; pause character?
                    bne       int@      ; branch for interrrupt/abort char
                    ldx       V.DEV2,u  ; else get dev2 statics
                    beq       wake@     ; branch if none
                    sta       V.PAUS,x  ; else set pause request
* Wake up any process if it's sleeping waiting for input.
wake@               ldb       #S$Wake   ; get the wake signal
                    lda       V.WAKE,u  ; is there a process asleep waiting for input?
noproc@             beq       nextrow   ; branch if not
                    clr       V.WAKE,u  ; else clear the wake flag
send@               os9       F$Send    ; and send the signal in B
nextrow             puls      d,x
                    rts
* Handle Interrupt/Abort Character (like CTRL+C or Esc)
int@
                    ldb       #S$Intrpt ; get the interrupt signal
                    cmpa      V.INTR,u  ; is our character same as the interrupt signal?
                    beq       getlproc@ ; branch if it's the same
                    ldb       #S$Abort  ; get the abort signal
                    cmpa      V.QUIT,u  ; is our character same as the abort signal?
                    bne       CheckSig  ; branch if it isn't
getlproc@           lda       V.LPRC,u  ; else get the ID of the last process to use this device
                    bra       noproc@   ; branch
* Signal on Data Ready
CheckSig            lda       <V.SSigID,u ; send signal on data ready?
                    beq       wake@     ; no, just go wake up the process
                    ldb       <V.SSigSg,u ; else get the signal code
                    clr       <V.SSigID,u ; clear signal ID
                    bra       send@


********************************************************************
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
Init                clr       V.CAPSLck,u
                    clr       V.LastCh,u
                    ldx       #D.RowState ; point to the row state globals
                    ldb       #9        ; b = 9 (bytes to set)
l@                  clr       ,x+       ; set byte at X with $FF and increment X
                    decb                ; decrement B
                    bne       l@        ; keep doing until B is 0
                    ldx       #gr.KeyLive ; no keys are held yet
                    ldb       #KeyLiveSz
l2@                 clr       ,x+
                    decb
                    bne       l2@
* Key repeat is the core's (hardware typematic, v8_rc8+ K2 cores).
                    ldx       #OKB.Base
                    lda       #KEYDELAY1 ; initial delay in frames (=30, 500ms)
                    sta       OKB.TypDly,x
                    lda       #KEYDELAY ; repeat period in frames (=5, 12 cps)
                    sta       OKB.TypPer,x
                    lda       #$01
                    sta       OKB.TypCtl,x ; enable hardware key repeat
* The keyboard is serviced from its own interrupt - group 3 bit 2, the
* FIFO empty->non-empty edge.  vtio calls Init once (the first INIZ,
* /term).  F$IRQ removes an entry by its U, so the entry is registered
* under KBD_IRQSvc's own address - fixed, unique, and the same whichever
* terminal's Term removes it.  The service takes its statics from
* D.KbdSta (the live terminal), not from U.
                    pshs      u
                    leau      KBD_IRQSvc,pcr ; unique U: the service routine's address
                    ldd       #INT_PENDING_3 ; the shared group-3 pending register
                    leax      KBD_Pckt,pcr ; flip/mask/priority packet
                    leay      KBD_IRQSvc,pcr ; the edge service routine
                    os9       F$IRQ     ; install the handler
                    puls      u
                    bcs       InitEx    ; no table room: no keyboard, carry and B to vtio
* The edge fires only when the FIFO goes from empty to non-empty, so
* whatever it holds now (keys pressed during boot) is dropped first, or
* the keyboard would never interrupt.  Interrupts stay masked so that
* KBD_IRQSvc cannot read the FIFO at the same time.
                    pshs      cc
                    orcc      #IntMasks
                    lda       #INT_OPT_KBD ; clear any keystroke edge latched since boot
                    sta       >INT_PENDING_3 ; (write-1-to-clear, per-bit)
                    ldx       #OKB.Base
drop@               tst       OKB.Stat,x ; 0 = data waiting
                    bne       unmask@
                    lda       OKB.Data,x ; drop a byte
                    bra       drop@
unmask@             lda       >INT_MASK_3 ; then unmask ONLY our bit - this register
                    anda      #^INT_OPT_KBD ; is shared with the WizFi RX/TX bits, so
                    sta       >INT_MASK_3 ; read-modify-write, never absolute stores
                    puls      cc
                    clrb
InitEx              rts                 ; return to the caller

* The exit label above is GLOBAL on purpose - the branch to it crosses
* an os9 call, and the os9 macro breaks @-local label scope in lwasm.
* vtio calls Term from whichever terminal closes last, so it does not ask
* any terminal's statics: it re-masks the bit and removes the entry by the
* fixed U it was registered under. If Init's F$IRQ had failed, the bit was
* never unmasked and the removal just returns an error, ignored.
Term                pshs      cc
                    orcc      #IntMasks
                    lda       >INT_MASK_3 ; re-mask our bit (RMW - shared register)
                    ora       #INT_OPT_KBD
                    sta       >INT_MASK_3
                    puls      cc
                    pshs      u
                    leau      KBD_IRQSvc,pcr ; the unique U we registered with
                    ldd       #INT_PENDING_3
                    ldx       #0        ; x = 0 removes the handler
                    leay      KBD_IRQSvc,pcr
                    os9       F$IRQ
                    puls      u
                    clrb
                    rts                 ; return to the caller

********************************************************************
* KBD_IRQSvc - group-3 keyboard edge service routine
*
* Entered by IOMan's IRQ poll with U = the unique address we registered
* (KBD_IRQSvc's own). The keys belong to the LIVE terminal: its statics
* are D.KbdSta, which grfdrv's GF.Switch points at the terminal on screen
* (keydrv_ps2 does the same).  vtio sets it before Init and clears it
* after Term.
* Clear our pending bit BEFORE draining, then drain the FIFO TO EMPTY:
* the edge only re-fires on an empty->non-empty transition, so any byte
* left behind would silence the keyboard.  A byte arriving after the
* final empty check makes a fresh edge and a fresh interrupt.
* Exit: carry clear - IOMan's poll takes carry set as "not mine" and
* goes on to the next entry.
KBD_IRQSvc          pshs      y,u
                    lda       #INT_OPT_KBD
                    sta       >INT_PENDING_3 ; claim our edge (write-1-to-clear, per-bit)
                    ldu       >D.KbdSta ; the live terminal's statics
                    beq       kdone@    ; none
kdrain@             ldx       #OKB.Base
                    tst       OKB.Stat,x ; 0 = optical keyboard with data waiting
                    bne       kdone@
                    lbsr      ReadFIFOData ; decode one snapshot
                    bra       kdrain@   ; and keep going until empty
kdone@              andcc     #^Carry   ; handled
                    puls      y,u,pc

* F$IRQ packet: claim ONLY the keyboard bit of the shared group-3
* register - the WizFi entries claim theirs the same way.
KBD_Pckt            fcb       %00000000 ; flip byte (bits latch high)
                    fcb       INT_OPT_KBD ; mask byte
                    fcb       $F0       ; priority

* WBK key table
HOME                set       $01
END                 set       $03
DEL                 set       $04
ESC                 set       $1B
TAB                 set       $09
ENTER               set       $0D
BKSP                set       $08
BREAK               set       $05
INS                 set       $0F


* Arrow keys reside in $E0-$EF and are treated special by the code.
UP                  set       $0C
DOWN                set       $0A
LEFT                set       $08
RIGHT               set       $09

kUP                 set       $E0
kDOWN               set       $E1
kLEFT               set       $E2
kRIGHT              set       $E3
kSPACE              set       $E4

ModChrTbl           fcb       UPBIT,DOWNBIT,LEFTBIT,RIGHTBIT,SPACEBIT
ModChrUpTbl         fcb       ^UPBIT,^DOWNBIT,^LEFTBIT,^RIGHTBIT,^SPACEBIT
ChrTbl              fcb       UP,DOWN,LEFT,RIGHT,C$SPAC

* Function keys just return some ASCII value
F1                  set       $A1
F2                  set       $A2
F3                  set       $A3
F4                  set       $A4
F5                  set       $A5
F6                  set       $A6
F7                  set       $A7
F8                  set       $A8

* Any key code above $EF is considered a modifier key

LCTRL               set       $F0
LSHIFT              set       $F1
RALT                set       $F2
RSHIFT              set       LSHIFT
META                set       $F3
CAPS                set       $F4

ModTbl              fcb       CTRLBIT,SHIFTBIT,ALTBIT
ModUpTbl            fcb       ^CTRLBIT,^SHIFTBIT,^ALTBIT

WBKKeys
                    fcb       kUP,F5,F3,F1,F7,kLEFT,ENTER,BKSP
                    fcb       LSHIFT,'e,'s,'z,'4,'a,'w,'3
                    fcb       'x,'t,'f,'c,'6,'d,'r,'5
                    fcb       'v,'u,'h,'b,'8,'g,'y,'7
                    fcb       'n,'o,'k,'m,'0,'j,'i,'9
                    fcb       ',,'[,';,'.,CAPS,'l,'p,'-
                    fcb       '/,TAB,RALT,RSHIFT,$01,'','],'=
                    fcb       BREAK,'q,META,kSPACE,'2,LCTRL,BKSP,'1
                    fcb       0,kRIGHT,0,0,0,0,0,kDOWN

WBKShiftKeys
                    fcb       kUP,F6,F4,F2,F8,kLEFT,ENTER,$18
                    fcb       LSHIFT,'E,'S,'Z,'$,'A,'W,'#
                    fcb       'X,'T,'F,'C,'^,'D,'R,'%
                    fcb       'V,'U,'H,'B,'*,'G,'Y,'&
                    fcb       'N,'O,'K,'M,'),'J,'I,'(
                    fcb       '<,'{,':,'>,CAPS,'L,'P,'_
                    fcb       '?,TAB,RALT,RSHIFT,$01,'",'},'+
                    fcb       BREAK,'Q,META,kSPACE,'@,LCTRL,$18,'!
                    fcb       0,kRIGHT,0,0,0,0,0,kDOWN

                    emod
eom                 equ       *
                    end
