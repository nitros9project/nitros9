********************************************************************
* keydrv - Keyboard subroutine module for Wildbits VTIO
*
* Level 2 version: the multiterminal vtio's keyboard module.  Level 2
* recipes find this file before level1/wildbits/modules/keydrv_ps2.asm, which
* Level 1 keeps using.  It adds terminal switching (Alt+Left/Right) and
* the held-key table gr.KeyLive for SS.LiveKeys.
*
* https://wiki.osdev.org/PS2_Keyboard
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2024/02/17  Boisy G. Pitre
* Started.
*
*  2       2024/03/16  Boisy G. Pitre
* Added Wildbits reset when Sys Rq key pressed.
*
*  3        2024/06/17  Boisy G. Pitre (Waco, TX)
* Added support for V.PAU.
*
*  4       2026/10/20  John Federico
* F1-F8 send $A1-$A8, as on the K2 (F1/F2 were $B1/$B2, Shift $B3/$B4;
* F3-F8 sent nothing); Tab sends $09, as on the K2 (it buffered a $00).
* Scan codes $80 and up no longer index in front of the tables (F7 is $83;
* Pause's $E1 sequence is swallowed), and a scan code with no entry no
* longer buffers a NUL.  Resync: the FIFO-empty bit is tested before every read; a
* prefix whose next byte has not come within a tick is dropped (the next
* byte is then read as a new key, not as the rest of a lost sequence);
* overrun/error bytes ($00, $FF, $FC, $FD) and a hot-plug ($AA) clear the
* held keys and modifiers.  Caps Lock no longer waits for the keyboard's
* acknowledgement inside the interrupt (the LED byte follows its $FA),
* keeps the LED state, and does not toggle again on its own key repeat.
* Table-driven: one prefix byte (V.Pfx) and one modifier/arrow table
* (ModTbl) replace the per-prefix handlers, ShiftTbl's pairs replace the
* 128-byte Shift table, and the prefix, reply and error bytes ($AA up)
* share one dispatch table.  1026 -> 1042 bytes, features included.

                    use       defsfile
                    use       wildbits_vtio.d

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       4


* We can use a different MMU slot if we want.
MAPSLOT             equ       MMU_SLOT_1
MAPADDR             equ       (MAPSLOT-MMU_SLOT_0)*$2000

                    mod       eom,name,tylg,atrv,start,size

size                equ       V.Last

                    fcb       UPDAT.+EXEC.

name                fcs       /keydrv/
                    fcb       edition

                    org       V.KeyDrvStat
V.Pfx               rmb       1         prefixes of the key code to come: PF.E0, PF.F0
V.PfxTick           rmb       1         D.Tick when a prefix (or the Pause swallow) started waiting
V.Skip              rmb       1         bytes of the Pause key's sequence still to swallow
V.LEDPend           rmb       1         1 = $ED sent; its $FA sends the LED byte
V.CapsDn            rmb       1         Caps Lock is held (its key repeat does not toggle again)
PF.E0               equ       %00000001 $E0 seen: an extended key
PF.F0               equ       %00000010 $F0 seen: a break (key up)
                    ifgt      .-V.KeyDrvStat-8
                    error     keydrv statics overflow V.KeyDrvStat
                    endc

* keydrv has three 3-byte entry points:
* - Init
* - Term
* - AltISR (called by VTIO at the 60Hz interval)
start               lbra      Init
                    lbra      Term
                    lbra      AltISR

AltISR              rts

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
* Jr PS/2 keyboard initialization
*
* Tell the keyboard to start scanning.
* Do this FIRST before turning off LEDs, or else keyboard fails to respond after
* a reset. +BGP+
*
                    lda       #$FF      ; load the RESET command
                    lbsr      SendToPS2 ; send it to the keyboard
                    lda       #$AA      ; we expect an $AA response
                    lbsr      ReadFromPS2 ; read from the keyboard

                    lda       #$F4      ; load the start scanning command
                    lbsr      SendToPS2 ; send it to the keyboard

                    clr       D.KySns
                    lbsr      KeyLiveClr ; no key is held yet (SS.LiveKeys $C6)

                    clr       V.Pfx,u   ; no prefix pending
                    clr       V.Skip,u
                    ldd       #INT_PENDING_0 ; get the pending interrupt pending address
                    leax      IRQPckt,pcr ; point to the IRQ packet
                    leay      IRQSvc,pcr ; and the service routine
                    os9       F$IRQ     ; install the interrupt handler
                    bcs       ErrExit   ; branch if we have an issue
                    lda       INT_MASK_0 ; else get the interrupt mask byte
                    anda      #^INT_PS2_KBD ; set the PS/2 keyboard interrupt
                    sta       INT_MASK_0 ; and save it back

                    clrb                ; clear the carry flag
                    rts                 ; return to the caller

ErrExit             orcc      #Carry    ; set the carry flag
                    rts                 ; return to the caller

* The F$IRQ packet.
IRQPckt             equ       *
Pkt.Flip            fcb       %00000000 the flip byte
Pkt.Mask            fcb       INT_PS2_KBD the mask byte
                    fcb       $F1       the priority byte

* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term
* K keyboard termination
*

* Jr PS/2 keyboard termination
*
                    ldx       #$0000    ; we want to remove the IRQ table entry
                    leay      IRQSvc,pcr ; point to the interrupt service routine
                    os9       F$IRQ     ; call to remove it (vtio's Term puts D.AltIRQ back)

                    clrb                ; clear the carry
                    rts                 ; return to the caller

***
* IRQ routine for the Jr PS/2 keyboard
*
* INPUT:  A = flipped and masked device status byte
*         U = keyboard data area address
*
* OUTPUT:
*          CC Carry clear
*          D, X, Y, and U registers may be altered
*
* ERROR OUTPUT:  none
*

RAW_KEYBOARD        equ       0

                  IFNE    RAW_KEYBOARD
* Input: A = byte to convert to hex
* Output: A = ASCII character of first digit
*         B = ASCII character of second digit
cvt2hex             pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    cmpa      #9
                    bgt       hex@
                    adda      #$30
                    bra       afthex@
hex@                adda      #$37
afthex@
                    ldb       ,s+
                    andb      #$0F
                    cmpb      #9
                    bgt       hex2@
                    addb      #$30
                    bra       afterhex2@
hex2@               addb      #$37
afterhex2@          rts
                  ENDC

* Send a byte to the PS/2 keyboard and wait for its $FA (Init only: the
* wait reads KBD_IN and would throw key bytes away in the interrupt).
*
* Entry: A = The byte to send to the keyboard.
SendToPS2           bsr       SendByte
                    lda       #$FA
* Entry: A = Response to expect from the keyboard: 65,536 reads, then carry.
* Destroys X.
ReadFromPS2         ldx       #$0000
l@                  cmpa      KBD_IN    ; is the next byte what we expect?
                    beq       ok@
                    leax      -1,x
                    bne       l@
                    comb                ; never came
                    rts
ok@                 clra                ; clear carry
                    rts

* SendByte - send A to the keyboard; do not wait for the reply.
SendByte            sta       PS2_OUT   ; send the byte out to the keyboard
                    lda       #K_WR     ; load the "write" bit
                    sta       PS2_CTRL  ; send it to the control register
                    clr       PS2_CTRL  ; then clear the bit in the control register
                    rts

IRQSvc              ldb       #INT_PS2_KBD ; get the PS/2 keyboard interrupt flag
                    stb       INT_PENDING_0 ; clear the interrupt
* F$IRQ already passed U = registered vtio static. Use D.KbdSta only when
* Init has stored a real 16-bit pointer (active terminal). If it is still
* zero, keep U so we drain the FIFO instead of IRQ-storming, and so boot
* works before vtio Init.
                    ldx       >D.KbdSta
                    beq       getcode
                    tfr       x,u
* Read while the FIFO has bytes: testing KEMP first means an interrupt
* with nothing queued reads nothing, so $00 and $FF are real bytes.
getcode             lda       PS2_STAT
                    bita      #KEMP     ; FIFO empty?
                    lbne      IRQDone   ; yes - done
                    lda       KBD_IN    ; get the key code

                  IFNE    RAW_KEYBOARD
                    lbsr      cvt2hex   ; convert the key code to hexadecimal
                    pshs      b         ; save the hexadecimal character
                    lbsr      BufferChar ; buffer it
                    puls      a         ; get the character
                    lbsr      BufferChar ; buffer it
                    bra       CheckSig  ; wake up any sleeping process waiting on input
                  ENDC

* Resync.  PS/2 key codes carry no sync bit; what can be lost is the rest
* of a sequence.  Its bytes come about 1 ms apart, so a prefix (or the
* Pause swallow) still waiting a tick later lost its next byte: drop it,
* and read this byte as a new key.  D.Tick counts down from TkPerSec to 1.
                    ldb       V.Pfx,u
                    orb       V.Skip,u
                    beq       fresh@    ; nothing waiting
                    ldb       V.PfxTick,u
                    cmpb      >D.Tick
                    beq       fresh@    ; the same tick
                    decb                ; or the next one
                    bne       tk@
                    ldb       #TkPerSec
tk@                 cmpb      >D.Tick
                    beq       fresh@
                    clr       V.Pfx,u   ; stale
                    clr       V.Skip,u
fresh@
* Pause sends E1 14 77 E1 F0 14 F0 77 and no break: swallow it whole.
                    tst       V.Skip,u
                    beq       noskip@
                    dec       V.Skip,u
                    bra       IRQExit
* Prefixes, the keyboard's replies and its error bytes are $AA and up,
* or $00; key codes are below $AA.  One compare sends a key on its way.
noskip@             tsta
                    lbeq      DoErr     ; $00: overrun / key detection error
                    cmpa      #$AA
                    blo       key@
                    leax      CtlTbl,pcr
ctl@                cmpa      ,x++
                    beq       ctlgo@
                    tst       ,x
                    bne       ctl@
                    bra       IRQExit   ; $EE echo and the rest: nothing to do
ctlgo@              ldb       -1,x      ; the handler's offset from CtlBase
                    leax      CtlBase,pcr
                    jmp       b,x
key@                lbsr      DoKey
                    bcs       IRQExit   ; if the carry is set, don't wake process
                    cmpa      V.PCHR,u  ; pause character?
                    bne       int@      ; branch if not
                    ldx       V.DEV2,u  ; else get dev2 statics
                    beq       WakeIt    ; branch if none
                    sta       V.PAUS,x  ; else set pause request
                    bra       WakeIt
int@
                    ldb       #S$Intrpt ; get the interrupt signal
                    cmpa      V.INTR,u  ; is our character same as the interrupt signal?
                    beq       getlproc@ ; branch if it's the same
                    ldb       #S$Abort  ; get the abort signal
                    cmpa      V.QUIT,u  ; is our character same as the abort signal?
                    bne       CheckSig  ; branch if it isn't
getlproc@           lda       V.LPRC,u  ; else get the ID of the last process to use this device
                    bra       noproc@   ; branch
CheckSig            lda       <V.SSigID,u ; send signal on data ready?
                    beq       WakeIt    ; no, just go wake up the process
                    ldb       <V.SSigSg,u ; else get the signal code
                    clr       <V.SSigID,u ; clear signal ID
                    bra       send@
* Wake up any process if it's sleeping waiting for input.
WakeIt              ldb       #S$Wake   ; get the wake signal
                    lda       V.WAKE,u  ; is there a process asleep waiting for input?
noproc@             beq       IRQExit   ; branch if not
                    clr       V.WAKE,u  ; else clear the wake flag
send@               os9       F$Send    ; and send the signal in B
IRQExit             lbra      getcode   ; more bytes queued?
IRQDone             clrb                ; else the clear carry
                    rts                 ; return

* The bytes from $AA up that are not keys: the byte, then its handler's
* offset from CtlBase.  $EE (echo) and anything else are ignored.
CtlTbl              fcb       $E0,DoE0-CtlBase
                    fcb       $F0,DoF0-CtlBase
                    fcb       $E1,DoPause-CtlBase
                    fcb       $FA,DoAck-CtlBase
                    fcb       $FE,DoResend-CtlBase
                    fcb       $AA,DoBAT-CtlBase
                    fcb       $FF,DoErr-CtlBase
                    fcb       $FC,DoErr-CtlBase
                    fcb       $FD,DoErr-CtlBase
                    fcb       0

CtlBase
DoE0                lda       #PF.E0    ; an extended key follows
                    bra       pfx@
DoF0                lda       #PF.F0    ; a break follows
pfx@                ora       V.Pfx,u
                    sta       V.Pfx,u
                    bra       stamp@
* Pause: E1 and 7 more bytes.
DoPause             lda       #7
                    sta       V.Skip,u
stamp@              lda       >D.Tick   ; a byte is now expected within a tick
                    sta       V.PfxTick,u
                    bra       IRQExit
* DoAck - $FA: if Caps Lock's $ED is waiting, send the LED byte now.
DoAck               tst       V.LEDPend,u
                    beq       IRQExit
                    clr       V.LEDPend,u
                    lda       V.LEDStates,u
                    lbsr      SendByte
                    bra       IRQExit
* DoResend - $FE: the keyboard missed our last byte.
DoResend            tst       V.LEDPend,u
                    beq       IRQExit
                    lda       #$ED
                    lbsr      SendByte
                    bra       IRQExit
* DoBAT - $AA: the keyboard reset (hot-plug).  Nothing is held, and its
* LEDs are off: send ours again.
DoBAT               bsr       ResetKeys
                    tst       V.LEDStates,u
                    beq       IRQExit
                    bsr       SendLED
                    bra       IRQExit
* DoErr - an overrun or error byte: bytes were lost, so what is held is
* unknown.  Start clean rather than leave a key or modifier stuck.
DoErr               bsr       ResetKeys
                    bra       IRQExit

* ResetKeys - no prefix pending, nothing held: no modifiers, no arrows, an
* empty gr.KeyLive.
ResetKeys           clr       D.KySns
                    clr       V.Pfx,u
                    clr       V.Skip,u
                    clr       V.CapsDn,u
                    lbra      KeyLiveClr

* SendLED - send $ED; DoAck sends V.LEDStates when the keyboard acknowledges.
SendLED             lda       #$ED
                    lbsr      SendByte
                    lda       #1
                    sta       V.LEDPend,u
                    rts

* Check if we need to wrap around tail pointer to zero.
IncNCheck           incb                ; increment the next character pointer
                    cmpb      #KBufSz-1 ; are we pointing to the end of the buffer?
                    bls       ex@       ; branch if not
                    clrb                ; else clear the pointer (wraps to head)
ex@                 rts                 ; return

********************************************************************
* DoKey - one key event
*
* Entry: A = key code (below $AA, not $00), V.Pfx = its prefixes
* Exit:  carry clear, A = the character to report
*        carry set: no character
********************************************************************
DoKey               ldb       V.Pfx,u   ; b = the prefixes
                    clr       V.Pfx,u   ; the sequence is complete
                    cmpa      #$83      ; f7, the one key code past $7F
                    bne       lo@
                    lda       #$02      ; it has ScanMap's empty slot $02
lo@                 tsta
                    bmi       none@     ; any other code past $7F: not a key we know
                    bitb      #PF.E0
                    beq       look@
                    ora       #$80      ; ModTbl lists an extended key as $80+code
look@               leax      ModTbl,pcr
mt@                 cmpa      ,x
                    lbeq      mod@
                    leax      3,x
                    tst       ,x
                    bne       mt@
                    tsta
                    bmi       ext@      ; an extended key that is not a modifier or arrow
                    cmpa      #$58      ; caps Lock?
                    beq       caps@
                    bitb      #PF.F0
                    bne       brk@
* An ordinary key goes down.
                    clr       V.CapsDn,u ; another key ends Caps Lock's repeat, so a lost Caps break cannot leave it stuck
                    lbsr      KeyLiveAdd ; record it as held (SS.LiveKeys $C6)
                    pshs      a         ; the scan code
                    leax      ScanMap,pcr
                    lda       a,x       ; the unshifted character
                    beq       none1@    ; an unpopulated scan code: no character (never buffer a NUL)
                    bmi       put@      ; a function key: no Shift, Ctrl or Caps fold
                    ldb       D.KySns
                    cmpa      #C$SPAC   ; space sets its sense bit
                    bne       sh@
                    orb       #SPACEBIT
                    stb       D.KySns
sh@                 bitb      #SHIFTBIT
                    beq       ctl@
* Shift: letters go to upper case; the rest of the main block from
* ShiftTbl.  The keypad ($69 up) is the same shifted.
                    cmpa      #'a
                    blo       sp0@
                    cmpa      #'z
                    bhi       sp0@
                    suba      #$20
                    bra       ctl@
sp0@                ldb       ,s
                    cmpb      #$69
                    bhs       ctl@
                    leax      ShiftTbl,pcr
sp@                 tst       ,x
                    beq       ctl@      ; not in the table: the same shifted
                    cmpa      ,x++
                    bne       sp@
                    lda       -1,x
ctl@                ldb       D.KySns
                    bitb      #CTRLBIT  ; is the CTRL key down?
                    beq       cap@      ; branch if not
                    suba      #$60      ; else subtract $60 from the character in A
cap@                tst       V.CAPSLck,u ; is the CAPS Lock on?
                    beq       put@      ; branch if not
                    cmpa      #'a       ; else compare the character to lowercase "a"
                    blt       put@      ; branch if the character is less than
                    suba      #$20      ; else make the character uppercase
put@                leas      1,s
                    lbra      BufferChar
none1@              leas      1,s
none@               comb
                    rts
* An ordinary key comes up.
brk@                lbsr      KeyLiveDel ; it is no longer held
                    cmpa      #$29      ; space?
                    bne       none@
                    ldb       D.KySns
                    andb      #^SPACEBIT
                    stb       D.KySns
                    bra       none@
* An extended key that is not in ModTbl: only Print Screen (E0 7C) is
* used - it resets the machine.  The fake shifts some keyboards wrap round
* the arrows (E0 12, E0 59), keypad Enter and /, and the editing keys
* send nothing.
ext@                cmpa      #$80+$7C
                    bne       none@
                    bitb      #PF.F0
                    bne       none@
                    lbra      ResetGo
* Caps Lock: toggle on the press, not on the key's own repeat, and set the
* LED: $ED now, the LED byte when its $FA arrives (DoAck).
caps@               bitb      #PF.F0
                    beq       capdn@
                    clr       V.CapsDn,u ; up: the next press toggles again
                    bra       none@
capdn@              tst       V.CapsDn,u
                    bne       none@     ; held: its repeat
                    inc       V.CapsDn,u
                    lda       V.LEDStates,u
                    anda      #^$04     ; the CAPS Lock LED bit
                    com       V.CAPSLck,u ; complement the CAPS lock flag in our static memory
                    beq       ledoff@   ; branch if the result is 0 (LED should be turned off)
                    ora       #$04      ; set the CAPS Lock LED bit
ledoff@             sta       V.LEDStates,u
                    lbsr      SendLED
                    bra       none@
* A modifier or an arrow (X = its ModTbl entry): set or clear its
* D.KySns bit; an arrow going down is also a character, and Alt+Left/Right
* switch terminals instead.
mod@                lda       1,x       ; the D.KySns bit
                    bitb      #PF.F0
                    bne       modup@
                    ldb       D.KySns
                    tst       2,x
                    beq       moddn@    ; a modifier: no character
                    bitb      #ALTBIT
                    beq       arrow@
                    bita      #LEFTBIT
                    lbne      changewindowl
                    bita      #RIGHTBIT
                    lbne      changewindowr
arrow@              pshs      a
                    orb       ,s+
                    stb       D.KySns
                    lda       2,x       ; the arrow's character
                    lbra      BufferChar
moddn@              pshs      a
                    orb       ,s+
                    stb       D.KySns
                    bra       none@
modup@              coma
                    anda      D.KySns
                    sta       D.KySns
                    bra       none@

* Modifiers and arrows: key code ($80+ if after $E0), D.KySns bit, the
* character the key types (0 = none).  Left and right Ctrl and Alt are the
* same bit; the arrows are only the extended codes (without $E0 they are
* the keypad).
ModTbl              fcb       $12,SHIFTBIT,0 left Shift
                    fcb       $59,SHIFTBIT,0 right Shift
                    fcb       $14,CTRLBIT,0 left Ctrl
                    fcb       $80+$14,CTRLBIT,0 right Ctrl
                    fcb       $11,ALTBIT,0 left Alt
                    fcb       $80+$11,ALTBIT,0 right Alt
                    fcb       $80+$75,UPBIT,$0C up
                    fcb       $80+$72,DOWNBIT,$0A down
                    fcb       $80+$6B,LEFTBIT,$08 left
                    fcb       $80+$74,RIGHTBIT,$09 right
                    fcb       0

* Shift in the main block: the character, then shifted.  Letters are
* done by arithmetic, and anything not here is the same shifted.
ShiftTbl            fcc       "`~1!2@3#4$5%6^7&8*9(0)-_=+[{]}\|;:"
                    fcb       '','"
                    fcc       ",<.>/?"
                    fcb       $08,$18   backspace
                    fcb       0

BufferChar
                    ldb       V.IBufH,u ; get buffer head pointer in B
                    leay      V.KSBuf,u
                    leay      b,y
                    leax      V.InBuf,u ; point X to the input buffer
                    abx                 ; x now holds address of the head pointer
                    lbsr      IncNCheck ; increment the pointer and check for tail wrap
                    cmpb      V.IBufT,u ; is B at the tail? (if so, the input buffer is full)
                    beq       bye@      ; branch if the input buffer is full (drop the character)
                    stb       V.IBufH,u ; update the buffer head pointer
                    sta       ,x        ; place the character in the buffer
* Store the KySns in the KSBuf
BufferKSns          pshs      a
                    lda       D.KySns
                    sta       ,y        ; place the D.KySns in the KS buffer
                    puls      a
bye@                clrb                ; clear carry
                    rts                 ; return

********************************************************************
* gr.KeyLive - the ordinary keys held down now (SS.LiveKeys $C6)
*
* PS/2 reports EVENTS, not state, so unlike keydrv_k2 - which clears the
* array and rebuilds it from the whole matrix on every FIFO event, and
* therefore cannot drift - this array is maintained incrementally and
* has to be right about every make and every break.  Modifiers and the
* arrows are not here; they stay in D.KySns.
*
* These are called from DoKey's ordinary-key path (before
* the Ctrl fold and the CapsLock fold, so one physical key has one
* identity), from DoKey's break path, and from Init and ResetKeys (the
* $AA self-test byte and the error bytes).  A stranded entry is not cosmetic: Joust edge-detects
* its flap from a level, so a key that never comes up disables that
* player's flap for the rest of the game.
********************************************************************

* KeyLiveAdd - record the key whose make code is in A
*
* Entry: A = PS/2 make code
* Exit:  all registers preserved; CC clobbered
*
* The code stored is ScanMap's - the UNSHIFTED one, looked up here and
* deliberately not through Y, which is shift-selected on every byte
* including break bytes: a key pressed with Shift and released without
* it would otherwise remove the wrong entry, or none.
KeyLiveAdd          pshs      d,x
                    tsta                ; cc here is the caller's compare
                    bmi       kladn@    ; a scan code past the map
                    leax      ScanMap,pcr ; never Y - see above
                    lda       a,x
                    beq       kladn@    ; an unpopulated scan code
                    ldx       #gr.KeyLive
                    ldb       #KeyLiveSz
klafnd@             cmpa      ,x        ; already down?
                    beq       kladn@    ; yes - typematic repeat sends
                    leax      1,x       ; make codes with no break, and
                    decb                ; would fill every slot
                    bne       klafnd@
                    ldx       #gr.KeyLive ; not there: first free slot
                    ldb       #KeyLiveSz
klafre@             tst       ,x
                    beq       klaput@
                    leax      1,x
                    decb
                    bne       klafre@
kladn@              puls      d,x,pc    ; no room - drop it
klaput@             sta       ,x
                    puls      d,x,pc

* KeyLiveDel - the key whose break code is in A is no longer held
*
* Entry: A = PS/2 break code (the byte after $F0)
* Exit:  all registers preserved; CC clobbered
*
* Harmless for anything that is not in the array: every modifier break
* code ($11, $12, $14, $58, $59) looks up 0 in ScanMap.
KeyLiveDel          pshs      d,x
                    tsta                ; cc here is the caller's compare
                    bmi       kldn@
                    leax      ScanMap,pcr
                    lda       a,x
                    beq       kldn@
                    ldx       #gr.KeyLive
                    ldb       #KeyLiveSz
kldfnd@             cmpa      ,x
                    beq       kldclr@
                    leax      1,x
                    decb
                    bne       kldfnd@
kldn@               puls      d,x,pc
kldclr@             clr       ,x
                    puls      d,x,pc

* KeyLiveClr - nothing is held
*
* Exit:  all registers preserved; CC clobbered
KeyLiveClr          pshs      b,x
                    ldx       #gr.KeyLive
                    ldb       #KeyLiveSz
klc@                clr       ,x+
                    decb
                    bne       klc@
                    puls      b,x,pc


* Named for the KEY, not the direction.  SwitchTerm's SW.Next walks UP
* the terminal ids (SwFindNext does inca) and SW.Prev walks down, so
* Alt+Right takes you toward /vt1, /vt2 and Alt+Left back toward /term.
* These two were the other way round until 2026-09-09; test tables dated
* before that in docs/wildbits-vtio-rewrite.md read the opposite way.
changewindowl       lda       #SW.Prev  ; alt+Left = previous terminal
                    sta       >gr.SwitchReq
                    andb      #^(LEFTBIT+RIGHTBIT) ; keep ALTBIT if Alt still down
                    stb       D.KySns
                    comb                ; do not treat as input
                    rts
changewindowr       lda       #SW.Next  ; alt+Right = next terminal
                    sta       >gr.SwitchReq
                    andb      #^(LEFTBIT+RIGHTBIT)
                    stb       D.KySns
                    comb                ; do not treat as input
                    rts


* This performs a proper reset of the Wildbits.
ResetGo             ldd       #$DEAD    ; get the sentinel values
                    sta       RST0      ; store the first value
                    stb       RST1      ; and the second value
                    lda       #$80      ; set the high bit
                    sta       SYS0      ; store the high bit in the register
                    clr       SYS0      ; then clear the high bit in the register
l@                  bra       l@        ; wait for the reset condition

* ScanMap: PS/2 key codes $00-$7F to the unshifted characters (ShiftTbl
* and DoKey do Shift).  Row 0: F7 ($83) uses slot $02; F9-F12 ($01, $09,
* $78, $07) send nothing, as the K2 has no such keys; $A1-$A8 = F1-F8, with
* or without Shift.  Tab ($0D) is $09, as on the K2; a program tells it
* from Right arrow by RIGHTBIT in D.KySns (te does).
ScanMap             fcb       0,0,$A7,$A5,$A3,$A1,$A2,0,0,0,$A8,$A6,$A4,$09,'`,0
                    fcb       0,0,0,0,0,'q,'1,0,0,0,'z,'s,'a,'w,'2,0
                    fcb       0,'c,'x,'d,'e,'4,'3,0,0,C$SPAC,'v,'f,'t,'r,'5,0
                    fcb       0,'n,'b,'h,'g,'y,'6,0,0,0,'m,'j,'u,'7,'8,0
                    fcb       0,C$COMA,'k,'i,'o,'0,'9,0,0,'.,'/,'l,';,'p,'-,0
                    fcb       0,0,'',0,'[,'=,0,0,0,0,C$CR,'],0,'\,0,0
                    fcb       0,0,0,0,0,0,$8,0,0,'1,0,'4,'7,0,0,0
                    fcb       '0,'.,'2,'5,'6,'8,$05,0,0,'+,'3,'-,'*,'9,$17,0


                    emod
eom                 equ       *
                    end
