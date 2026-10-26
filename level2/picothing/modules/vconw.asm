********************************************************************
* VConW - multi-window SCF driver for the Pico-Thing /W0../W7 video windows
*
* The single video console driver for the M5 window model.  Each device
* carries a window number in its descriptor (IT.WND) plus its geometry
* (IT.CPX, IT.CPY, IT.COL, IT.ROW).  Window 0 is the root/panel and its
* device is /W0 (the base console); windows 1..7 are the overlays /W1../W7.
* On the first write to an overlay window VConW defines it (DWSet from the
* descriptor); before every write burst it makes the target window the
* output target (Select) - both output-target-only ops, so a write to a
* background window accumulates off-screen without stealing the display.
* The root is predefined by the firmware, so window 0 is never DWSet.
* One driver means one owner of the single keyboard stream: /W0 folds in
* here as window 0 rather than a separate vcon with its own input poll.
*
* State common to every device - the current output target, which windows
* have been defined, the single keyboard input ring and where it is routed
* - lives in a small shared global at the base of the kernel's global
* memory region (its address is in D.CCMem; the CoCo3 window system's own
* mechanism, unused on the shipping Pico-Thing until now).
*
* Read returns one input byte to the focused window (others block until
* focus arrives); the function keys switch focus.  See WVIRQSvc.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2026       Created for the /W multi-window model (M5 phase 1)

                  IFP1
                    use       defsfile
                  ENDC

WBOuter             equ       4         Write TDRE wait: a few seconds bound

* Shared window global.  It lives at the base of the kernel's global
* memory region, whose address the kernel leaves in D.CCMem ($1000 on the
* Pico-Thing) and whose first 4K is zeroed at cold start.  The region is
* the CoCo3 window system's own scratch; it is free on the Pico-Thing
* until the (deferred) vtio co-module is loaded.  We only READ D.CCMem -
* never overwrite it - and key "already set up" off our own GbInit flag,
* which the boot-time clear leaves zero until the first /W device claims it.
* Holds the state common to every /W device: output target, defined
* windows, and the single keyboard input stream and where it is routed.
GbRSize             equ       64        input ring size (a power of two)
GbRMask             equ       GbRSize-1 ring wrap mask
GbInit              equ       0         nonzero once the first /W has set us up
GbLSel              equ       1         last window selected as output target
GbDef               equ       2         bitmap of defined windows (bit n = window n)
GbFocus             equ       3         focused window (gets the keyboard; $FF = none)
GbHead              equ       4         input ring head (poll routine puts)
GbTail              equ       5         input ring tail (Read gets)
GbRing              equ       6         input ring buffer base
GbSPid              equ       GbRing+GbRSize per-window SS.SSig target pid (8, by window)
GbSSig              equ       GbSPid+8  per-window SS.SSig signal code (8, by window)
GbStat              equ       GbSSig+8  per-window device static (8 words, by window)
GbSigS              equ       GbStat+16 nonzero when the last key sent a signal or paused
GbSize              equ       GbSigS+1  size of the shared global

                    org       V.SCF     per-device static starts after SCF's
WMem                equ       .         no per-device state; window state is shared

rev                 set       $00
edition             set       1

                    mod       WEnd,WName,Drivr+Objct,ReEnt+rev,WEntry,WMem

                    fcb       UPDAT.    access modes: read + write

WName               fcs       "VConW"
                    fcb       edition

* SCF low-level entry table: Init, Read, Write, GetStat, SetStat, Term
WEntry              lbra      WInit
                    lbra      WRead
                    lbra      WWrite
                    lbra      WGetSt
                    lbra      WSetSt
                    lbra      WTerm

* Poll packet consulted by DoPoll: (VID.Stat and RDRF) nonzero => a key
* is waiting.  RDRF is active high, so no flip byte.
VIRQPk              fcb       $00       flip byte
                    fcb       VID.RDRF  mask byte: receive data available
                    fcb       $0A       poll priority

* Init - the first /W device sets up the shared global (in the kernel's
* already-zeroed global memory region at D.CCMem), resets the video pico
* once, and registers the ONE shared input poll with U = that region base,
* so the poll routine is handed the global as its static.  Later /W inits
* find GbInit already set and do nothing.  Entry: U = device static,
* DP = system.  The region is zeroed at cold start, so only the two $FF
* sentinels need writing; everything else is already clear.
WInit               ldx       >D.CCMem  ; base of the kernel's global memory
                    ldb       IT.WND,y  ; this window's number (y = descriptor)
                    aslb                ; two bytes per window
                    pshs      x         ; keep the global
                    leax      GbStat,x  ; per-window static table
                    stu       b,x       ; record this window's static for the poll
                    puls      x
                    lda       GbInit,x  ; window global already set up?
                    bne       WInOK     ; yes, nothing to do
                    inc       GbInit,x  ; claim it (the region is zeroed at boot)
                    lda       #$FF      ; no window selected as output target yet
                    sta       GbLSel,x
                    sta       GbFocus,x ; and no window focused yet
                    lda       #VID.Rset ; reset the pico once
                    sta       >VID.Stat
                    tfr       x,u       ; the poll's static is the global base
                    ldd       #VID.Stat ; register the shared input poll
                    leax      VIRQPk,pcr
                    leay      WVIRQSvc,pcr
                    os9       F$IRQ     ; poll runs with U = the global
                    rts                 ; return the F$IRQ status
WInOK               clrb
                    rts

* Read - return one input byte to the FOCUSED window, blocking others.
* Entry: A ignored, Y = path descriptor, U = static, DP = system.  A /W
* path reads the shared ring only while its window is the focused one;
* otherwise it naps until focus arrives.  Napping a tick when idle keeps
* a waiting read cheap; an abort/quit signal ends it so it never hangs.
WRead               ldu       PD.DEV,y  ; device table entry
                    ldu       V$DESC,u  ; descriptor module
                    lda       IT.WND,u  ; this window's number
                    pshs      a         ; keep it across the wait loop
WRdLp               ldx       >D.CCMem  ; shared global
                    lda       ,s        ; our window number
                    cmpa      GbFocus,x ; are we the focused window?
                    bne       WRdNap    ; no - wait for focus
                    lda       GbTail,x  ; focused: is the ring empty?
                    cmpa      GbHead,x
                    bne       WRdGot    ; no - take a byte
WRdNap              ldx       #$0001    ; nap one tick (a signal wakes us early)
                    os9       F$Sleep
                    ldx       >D.Proc   ; our process descriptor
                    lda       P$Signal,x ; abort/quit pending?
                    beq       WRdLp     ; none - retry
                    leas      $01,s     ; drop the window number
                    comb                ; signalled - end the read
                    ldb       #E$NotRdy
                    rts
WRdGot              lda       GbTail,x  ; tail index
                    leau      GbRing,x  ; ring base
                    ldb       a,u       ; the byte
                    inca                ; advance the tail
                    anda      #GbRMask  ; wrap it
                    sta       GbTail,x  ; publish it
                    leas      $01,s     ; drop the window number
                    tfr       b,a       ; return the byte in A
                    clrb                ; no error
                    rts

* Write - ensure this window is defined and the current output target,
* then send the byte.  Entry A = char, Y = path descriptor, DP = system.
* The window number stays in B (PutB preserves it) across the sub-code
* emissions; the char rides the stack.
WWrite              pshs      a         ; hold the char
                    ldu       PD.DEV,y  ; device table entry
                    ldu       V$DESC,u  ; descriptor module
                    ldx       >D.CCMem  ; shared global
                    ldb       IT.WND,u  ; this window's number
* build the window's bit mask in A (1 << window number)
                    lda       #$01
                    pshs      b         ; keep the window number
                    tstb
                    beq       WMkD
WMkL                lsla
                    decb
                    bne       WMkL
WMkD                puls      b         ; restore the window number; A = mask
                    tstb                ; window 0 is the root/panel: predefined,
                    beq       WSel      ; so never DWSet it (that would clear it)
* define the window on first use (DWSet clears it, so only once)
                    pshs      a         ; keep the mask
                    anda      GbDef,x   ; already defined?
                    bne       WDefd
                    lda       ,s        ; mask
                    ora       GbDef,x   ; mark it defined
                    sta       GbDef,x
                    bsr       DoDWSet   ; define window B from the descriptor
* a DWShow sent before the window existed (the user switched to it before
* its first output) was lost, so show it now if it holds the focus
                    cmpb      GbFocus,x ; is this the focused window?
                    bne       WDefd     ; no - it stays hidden until switched to
                    tfr       b,a       ; yes - show it
                    lbsr      WShow
WDefd               puls      a         ; drop the mask
* make it the output target if it is not already
WSel                cmpb      GbLSel,x
                    beq       WSeld
                    stb       GbLSel,x
                    bsr       DoSelect
WSeld               puls      a         ; recover the char
                    lbsr      PutB
                    clrb
                    rts

* DoDWSet - emit DWSet for window B from descriptor U.
* $1B $20 id type x y w h fg bg.  Preserves B, X, U (via PutB).
DoDWSet             lda       #$1B
                    lbsr      PutB
                    lda       #$20
                    lbsr      PutB
                    tfr       b,a       ; window id
                    lbsr      PutB
                    clra                ; type 0
                    lbsr      PutB
                    lda       IT.CPX,u  ; column start
                    lbsr      PutB
                    lda       IT.CPY,u  ; row start
                    lbsr      PutB
                    lda       IT.COL,u  ; width
                    lbsr      PutB
                    lda       IT.ROW,u  ; height
                    lbsr      PutB
                    clra                ; foreground 0
                    lbsr      PutB
                    clra                ; background 0
                    lbsr      PutB
                    rts

* DoSelect - emit Select for window B ($1B $21 id).  Preserves B.
DoSelect            lda       #$1B
                    lbsr      PutB
                    lda       #$21
                    lbsr      PutB
                    tfr       b,a
                    lbsr      PutB
                    rts

* GetStat - answer the same set sc6850 does: SS.Ready, SS.ScSiz (from
* the window's descriptor geometry) and SS.EOF (never at end of file),
* plus SS.ScTyp, which tells callers they are on a CoCo3-style window;
* anything else is not a window service.  Answering "success" to codes
* we do not implement misled callers - SS.ComSt (which SCF calls inside
* every SS.Opt read) had SCF copy the caller's stray Y into PD.PAR.  SCF
* tolerates an SS.ComSt error, leaving the options alone.  Entry A =
* code, Y = path.
WGetSt              cmpa      #SS.Ready
                    beq       WGRdy
                    cmpa      #SS.ScSiz
                    beq       WGSz
                    cmpa      #SS.EOF
                    beq       WGOk      ; scf devices never report end of file
                    cmpa      #SS.ScTyp
                    beq       WGTyp
                    comb                ; not a service this driver provides
                    ldb       #E$UnkSvc
                    rts
WGOk                clrb
                    rts
* SS.Ready - count the bytes waiting for THIS window.  The shared ring holds
* input for the focused window only, so any other window has none.  Report
* the count in the caller's B, or not-ready, as sc6850 does.
WGRdy               ldu       PD.DEV,y  ; device table entry
                    ldu       V$DESC,u  ; descriptor module
                    lda       IT.WND,u  ; this window's number
                    ldx       >D.CCMem  ; shared global
                    cmpa      GbFocus,x ; is it the focused window?
                    bne       WGNot     ; no - nothing is routed to it
                    lda       GbHead,x  ; bytes waiting = head - tail, mod ring
                    suba      GbTail,x
                    anda      #GbRMask
                    beq       WGNot     ; ring empty
                    ldx       PD.RGS,y  ; caller's register stack
                    sta       R$B,x     ; return the count in B
                    clrb
                    rts
WGNot               comb                ; nothing waiting
                    ldb       #E$NotRdy
                    rts
* SS.ScTyp - report a text screen the way CoWin does for anything but its
* 40 column mode: type 2.  A window here is a text screen over the shared
* graphics plane, and the pico handles the CoCo3 window codes such as the
* $1F insert and delete line that minted uses once it sees a window.
WGTyp               ldx       PD.RGS,y  ; caller's register stack
                    lda       #$02      ; text screen, as CoWin reports it
                    sta       R$A,x     ; return the type in A
                    clrb
                    rts
WGSz                ldu       PD.DEV,y  ; device table entry
                    ldu       V$DESC,u  ; descriptor module
                    ldx       PD.RGS,y  ; caller's register stack
                    clra
                    ldb       IT.COL,u  ; columns
                    std       R$X,x     ; return width in X
                    ldb       IT.ROW,u  ; rows
                    std       R$Y,x     ; return height in Y
                    clrb
                    rts

* SetStat - SS.SSig registers this window's data-ready signal; SS.Relea
* forgets it; SS.Tone plays a note; other codes succeed.  Entry A = code,
* Y = path descriptor.
WSetSt              cmpa      #SS.SSig
                    beq       WSSsig
                    cmpa      #SS.Relea
                    beq       WSSrel
                    cmpa      #SS.Tone
                    beq       WSTone
                    clrb                ; other codes: nothing to do
                    rts
* SS.Tone - caller Y = pitch (1-4095, CoCo 3 relative pitch), X = volume
* (high byte, 0-63) and duration (low byte, 1/60 s).  As the CoCo 3 sound
* driver does: refuse a pitch outside 1-4095, keep six bits of volume, do
* nothing at volume 0, and return only when the note has finished.  The
* pico plays it ($1B $27 pitch duration volume) without holding up the
* byte stream, so wait here for the duration in 50 Hz ticks: 1/60 s ticks
* times 215/256 is within a tick of times 5/6.  A single-tick note
* returns at once, since F$Sleep 0 would sleep for ever.
WSTone              ldu       PD.RGS,y  ; caller's register stack
                    ldd       R$Y,u     ; pitch
                    beq       WSTbad    ; 0 is out of range
                    cmpd      #4095
                    bhi       WSTbad    ; so is anything above 4095
                    lda       R$X,u     ; volume
                    anda      #$3F      ; six bits, as on a CoCo 3
                    beq       WSTok     ; volume 0: nothing to play
                    lda       #$1B      ; tone command
                    lbsr      PutB
                    lda       #$27
                    lbsr      PutB
                    lda       R$Y,u     ; pitch, high byte first
                    lbsr      PutB
                    lda       R$Y+1,u
                    lbsr      PutB
                    lda       R$X+1,u   ; duration
                    lbsr      PutB
                    lda       R$X,u     ; volume
                    anda      #$3F
                    lbsr      PutB
                    ldb       R$X+1,u   ; duration in 1/60 s
                    lda       #215      ; to 50 Hz ticks, in A
                    mul
                    tsta                ; less than one tick?
                    beq       WSTok     ; yes - do not wait
                    tfr       a,b
                    clra
                    tfr       d,x       ; ticks to sleep
                    os9       F$Sleep   ; wait for the note to end
WSTok               clrb
                    rts
WSTbad              comb
                    ldb       #E$IllArg
                    rts
WSSsig              ldu       PD.DEV,y
                    ldu       V$DESC,u  ; descriptor
                    ldb       IT.WND,u  ; b = this window number
                    ldx       >D.CCMem  ; shared global
                    lda       PD.CPR,y  ; requesting process id
                    leau      GbSPid,x
                    sta       b,u       ; remember its pid, by window
                    ldu       PD.RGS,y  ; caller register stack
                    lda       R$X+1,u   ; signal code (low byte of caller X)
                    leau      GbSSig,x
                    sta       b,u       ; remember its signal, by window
                    lda       GbFocus,x ; is any window focused yet?
                    cmpa      #$FF
                    bne       WSSok     ; yes - leave focus alone
                    stb       GbFocus,x ; no - focus this first reader's window
                    tfr       b,a       ; and display it
                    lbsr      WShow
WSSok               clrb
                    rts
WSSrel              ldu       PD.DEV,y
                    ldu       V$DESC,u
                    ldb       IT.WND,u
                    ldx       >D.CCMem
                    leau      GbSPid,x
                    clr       b,u       ; forget this window's signal target
                    clrb
                    rts

* Term - leave the shared global in place; other windows still use it
WTerm               ldx       >D.CCMem  ; shared global
                    leax      GbStat,x  ; per-window static table
                    ldb       #$08      ; eight windows
WTScan              cmpu      ,x        ; this window's static?
                    bne       WTNext
                    clra                ; yes - forget it before it is freed
                    sta       ,x        ; (the poll ignores a zero entry)
                    sta       $01,x
WTNext              leax      $02,x
                    decb
                    bne       WTScan
                    clrb
                    rts

* WVIRQSvc - the ONE shared input poll, called by DoPoll each tick while a
* key is waiting.  U = the global (set at F$IRQ).  Drain every waiting
* byte: F1-F8 ($80-$87) switch the focused/displayed window to window
* 0..7 - F1 is the root/panel (/W0), F2-F8 the overlay windows /W1../W7;
* F9-F12 ($88-$8B) are reserved and dropped; anything else (including the
* pound $9C and not-sign $AA the keyboard also emits) goes into the ring,
* unless it was the focused window's interrupt or quit character, which
* raises its signal instead.  Then poke the focused window's registered
* reader.  Version-gated like
* vcon so an absent/floating pico rings no phantom keys.
WVIRQSvc            pshs      dp
                    tfr       u,d       ; u = the global
                    tfr       a,dp      ; our direct page = the global's page
WVdrn               lda       >VID.Stat
                    tfr       a,b
                    andb      #VID.VerMsk
                    cmpb      #VID.Ver1 ; pico present (version 1)?
                    bne       WVsig     ; no - a float fakes RDRF, ignore it
                    bita      #VID.RDRF ; a key waiting?
                    beq       WVsig     ; no - done draining
                    lda       >VID.Data ; take the byte
                    cmpa      #$80
                    blo       WVput     ; ordinary byte - ring it
                    cmpa      #$8B
                    bhi       WVput     ; above the function-key block - ring it
                    cmpa      #$87
                    bhi       WVdrn     ; f9-F12 - reserved, drop
                    suba      #$80      ; f1-F8 -> window 0..7 (0 = root/panel)
                    bsr       WSwitch   ; switch focus and display
                    bra       WVdrn
* An ordinary byte: act on the focused window's interrupt, quit and pause
* characters - signal the window's last process, or pause its echo device.
* A key that raised a signal is consumed by it rather than also ringed as
* data, so a Ctrl-C that kills a program does not reappear at the start of
* the next command line (sc6850 and VTIO ring it too, which does exactly
* that).  A pause character that pauses the echo device is consumed the
* same way; a key with no process or device to act on stays data.  SCF sets
* these characters from the path options (Shell+ rebinds interrupt and quit
* to the down and up arrows for its history), so nothing here is fixed.
WVput               tsta                ; a null is only ever data
                    beq       WVring
                    clr       <GbSigS   ; this byte has sent no signal yet
                    ldb       <GbFocus  ; which window has the keyboard?
                    cmpb      #$FF
                    beq       WVring    ; none - just data
                    aslb
                    leax      GbStat,u
                    ldx       b,x       ; that window's device static
                    beq       WVring    ; not attached - just data
                    cmpa      V.INTR,x  ; interrupt character?
                    bne       WVquit
                    ldb       #S$Intrpt
                    bra       WVsend
WVquit              cmpa      V.QUIT,x  ; quit character?
                    bne       WVpaus
                    ldb       #S$Abort
WVsend              pshs      a,u       ; keep the byte and the global
                    lda       V.LPRC,x  ; the window's last process
                    beq       WVnone    ; none - no one to signal, so it is data
                    os9       F$Send
                    puls      a,u
                    inc       <GbSigS   ; so no data-ready signal follows
                    bra       WVdrn     ; the signal consumed the key: not data
WVnone              puls      a,u
                    bra       WVring
WVpaus              cmpa      V.PCHR,x  ; pause character?
                    bne       WVring
                    ldx       V.DEV2,x  ; the attached (echo) device
                    beq       WVring
                    sta       V.PAUS,x  ; pause its output
                    inc       <GbSigS   ; so no data-ready signal follows
                    bra       WVdrn     ; the pause consumed the key: not data
WVring              ldb       <GbHead   ; current head
                    leax      GbRing,u  ; ring base
                    abx                 ; point at the head slot
                    incb                ; proposed next head
                    andb      #GbRMask  ; wrap it
                    cmpb      <GbTail   ; would it collide with the tail (full)?
                    beq       WVdrn     ; yes - drop, keep draining
                    sta       ,x        ; store the byte
                    stb       <GbHead   ; publish the new head
                    bra       WVdrn
WVsig               tst       <GbSigS   ; did the last key send abort/interrupt?
                    bne       WVx       ; yes - that signal is the wake-up
                    lda       <GbFocus  ; anyone focused?
                    cmpa      #$FF
                    beq       WVx       ; no
                    leax      GbSPid,u
                    ldb       a,x       ; pid registered for the focused window
                    beq       WVx       ; nobody waiting
                    clr       a,x       ; one-shot: they re-arm after reading
                    pshs      b         ; save the pid
                    leax      GbSSig,u
                    ldb       a,x       ; its signal code
                    puls      a         ; a = pid
                    pshs      u         ; keep the global across the call
                    os9       F$Send
                    puls      u
WVx                 clrb                ; poll serviced
                    puls      dp,pc

* WSwitch - A = window 1..7: make it the focused window and display it.
* WShow - A = window: emit DWShow.  Both preserve B, X, Y, U (via PutB).
WSwitch             sta       <GbFocus  ; focus follows the switch
WShow               pshs      a         ; hold the window number
                    lda       #$1B
                    lbsr      PutB
                    lda       #$26
                    lbsr      PutB
                    puls      a         ; window number
                    lbsr      PutB      ; dwshow it
                    rts

* PutB - send the byte in A to the video pico with flow control.  This is
* a FRAMED command stream, so a single dropped byte desynchronises every
* byte after it - unlike a glass TTY, we must never drop while the pico is
* alive.  So wait for transmit space as long as the pico stays present; if
* PWait times out but the pico is still the live version, keep waiting.
* Only a pico that has gone away (wrong/floating version) drops the byte,
* which is the one case where waiting would hang forever.  Preserves B,X,Y,U.
PutB                pshs      b,x,y,u
                    pshs      a         ; hold the byte
PBwait              lda       >VID.Stat ; is the pico present?
                    anda      #VID.VerMsk
                    cmpa      #VID.Ver1 ; version 1 = live device?
                    bne       PBGone    ; no - the pico is gone, drop the byte
                    ldb       #VID.TDRE ; wait for transmit space
                    bsr       PWait
                    bcs       PBwait    ; timed out but still alive - keep waiting
                    puls      a         ; recover the byte
                    sta       >VID.Data ; transmit it
                    puls      b,x,y,u
                    rts
PBGone              puls      a         ; drop the byte
                    puls      b,x,y,u
                    rts

* PWait - wait for (VID.Stat and B) nonzero; carry set on timeout.
* Preserves B; saves X,U.
PWait               pshs      x,u
                    ldu       #WBOuter
PW1                 ldx       #$0000
PW2                 lda       >VID.Stat
                    pshs      b
                    anda      ,s+
                    bne       PWok
                    leax      -$01,x
                    bne       PW2
                    leau      -$01,u
                    bne       PW1
                    orcc      #Carry
                    puls      x,u,pc
PWok                andcc     #^Carry
                    puls      x,u,pc

                    emod
WEnd                equ       *
                    end
