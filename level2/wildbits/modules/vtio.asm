*******************************************************************
* VTIO - NitrOS-9 video terminal I/O driver for the Wildbits 6809
*
* https://wiki.osdev.org/PS2_Keyboard
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2013/08/20  Boisy G. Pitre
* Started.
*
*  2       2013/12/-6  Boisy G. Pitre
* Added SS.Joy support.
*
* 3        2025-10-08  John Federico
* Changed behavior of line wrap to not erase line

                    use       defsfile
                    use       wildbits_vtio.d

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       3

PSG.Base            equ       PSG_BOTH_PORT

* Level 2 VTIO. Level 1 is vtio_l1.asm (MAPSLOT 7, no grfdrv256).
* Do not alias 1-byte D.Boot. D.KbdSta is the 2-byte overlay at $18
* from wildbits_vtio.d.

* System LUT 0 slot 2 home is SRAM $03. Glyph/erase/scroll/blank,
* display setup / text palettes, bitmap SetStat and PSG all
* go through GF.Write (LUT 1). Do not map system MAPSLOT.

                    mod       eom,name,tylg,atrv,start,size

size                equ       V.Last

                    fcb       UPDAT.+EXEC.

name                fcs       /vtio/
                    fcb       edition

start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

* The 'font' and 'palette' data modules used to be F$Linked here by
* InitDisplayMem and installed by GF.InitDisp.  Both are gone: the FPGA
* preloads the font into FONT_BLK and the text palettes into VICKY_BLK at reset.
keydrvmod           fcs       /keydrv/
msdrvmod            fcs       /mousedrv/             mouse driver module
llpath              fcc       "/dd/CMDS/"
llnam               fcs       "grfdrv256"
                    fcb       $0D

*
* VTIO Alternate IRQ routine - Entered from Clock every 1/60th of a second
*
* The interrupt service routine is responsible for:
*   - handling the K keyboard (if available)
*   - decrementing the tone counter
*   - select the new active window if needed (when that time comes)
*   - updating graphics cursors if needed (when that time comes)
*   - checking for mouse update (when that time comes)

AltISR              
                    ldu       D.KbdSta
* Handle keyboard (if available)
                    ldx       V.KeyDrvEPtr,u             Computer have polling keybard?
                    cmpx      #$0000
                    beq       HandleMSTimer		 No, just handle mouse
                    lda       V.LastCh,u                 if LastCh=0, skip keyrepeat handling
                    beq       HandleKeyboard@            
                    dec       V.KRTimer,u                decrement repeat timer
                    bne       HandleKeyboard@            if not 0, then don't repeat yet
                    ldx       V.KeyDrvEPtr,u             
                    jsr       9,x                        else jmp to keyrepeat routine
HandleKeyboard@     ldx       V.KeyDrvEPtr,u                
                    jsr       6,x                        call AltIRQ routine in keydrv

* Handle Mouse Timer. When timer wraps to zero, turn it off
* Mouse does not hide correctly, so park it at right side of screen
* Check if mouse is already off, if it is, then skip timer code
* Mouse timer reset is in mousedrv_ps2.asm interrupt procedure
* Mouse timer resets on every mouse interrupt
* This should hide the mouse after 4 to 5 seconds of inactivity
HandleMSTimer       tst       MS_MEN             check if mouse cursor already off
                    beq       HandleKeySwtchTrm  mouse off: still check switch (glue #10)
                    inc       V.MSTimer,u                increment mouse auto-hide timer
                    bne       HandleKeySwtchTrm  timer not wrapped: still check switch
                    clr       MS_MEN             if timer flips to 0, turn off mouse cursor
                    ldd       #640               park mouse at right border
                    std       MS_XH     turning off cursor doesn't work correctly at the moment

* Handle Terminal Switching
HandleKeySwtchTrm   lda       >gr.SwitchReq
                    beq       AltISRCont
                    tst       >gr.Busy
                    bne       AltISRCont
* The switch itself lives in grfdrv (GF.Switch); CallGrfDrv2 keeps U.
                    ldb       #GF.Switch
                    lbsr      CallGrfDrvNoPD
* SS.WSig: the switch staged up to two signals in GrfMem (grfdrv256 makes
* no OS-9 calls).  Send them here, where S$Wake for sound is already sent.
* Each id is cleared BEFORE the send, so a failing F$Send - a process that
* has exited - cannot leave the request pending for ever.
                    pshs      x,y,u               F$Send's register use is not documented
                    lda       >gr.SigBgID
                    beq       nobg@
                    ldb       >gr.SigBgCode
                    clr       >gr.SigBgID
                    lbsr      SendWSig
nobg@               lda       >gr.SigFgID
                    beq       nofg@
                    ldb       >gr.SigFgCode
                    clr       >gr.SigFgID
                    lbsr      SendWSig
nofg@               puls      x,y,u
AltISRCont

* Handle sound. PSG (PSG_BOTH_PORT) via GF.Write. AltISR cannot F$Sleep, so
* skip Flip1 when gr.Busy and retry next tick (do not put WaitWrite
* inside CallGrfDrvNoPD).
HandleSound
                    tst       D.TnCnt            get the tone counter
                    beq       AltSndEx           branch if zero
                    dec       D.TnCnt            else decrement the counter
                    bne       AltSndEx           branch not zero; leave the sound on
sndoff              pshs      cc                 save the condition code register
                    orcc      #IntMasks          mask interrupts
                    tst       >gr.Busy
                    bne       AltSndBusy
                    ldb       #GF.PSGOff
                    lbsr      CallGrfDrvNoPD
                    lda       D.SndPrcID
                    beq       AltSndWake
                    ldb       #S$Wake
                    os9       F$Send
                    clr       D.SndPrcID
AltSndWake          puls      cc
                    jmp       [D.OrgAlt]
AltSndBusy          inc       D.TnCnt            Flip1 held; retry next 1/60s
                    puls      cc
AltSndEx            jmp       [D.OrgAlt]         branch to the original alternate IRQ routine

********************************************************************
* SendWSig - send signal B to process A for SS.WSig.
*
* Entry: A = process id, B = signal code.  Reached only from the switch
*        above, and only for a terminal whose V.WSigID is non-zero -
*        which no terminal has until a process asks for it with SS.WSig.
*        A process that never registered is never sent anything.
*
* Two more guards, because an unexpected signal FORCE-QUITS a process
* that has no intercept for it:
*   - code 0 is S$Kill, a non-interceptable abort, and is never sent;
*   - the process must still exist.  D.PrcDBT[id] holds the page of its
*     descriptor and reads 0 once it is gone - the same test the CoCo 3
*     vtio makes before handing a window to a process (vtio.asm 983).
*
* What is left: a process id can be REUSED between a registrant dying
* WITHOUT deregistering and the next terminal switch, and the new owner
* of that id would then be signalled.  SS.Relea, SS.WSig with R$X = 0,
* and the registrant's own exit path are what close that; joust
* deregisters in Cleanup on every exit path it has.
*
* Exit: A, B, X, Y, U preserved; CC clobbered.
********************************************************************
SendWSig            tstb                          signal 0 would abort, not notify
                    beq       swx@
                    pshs      a,x
                    ldx       <D.PrcDBT           process descriptor table
                    lda       a,x                 the page its descriptor lives on
                    tsta                          0 = that process is gone
                    puls      a,x                 (PULS does not touch CC)
                    beq       swx@
                    os9       F$Send
swx@                rts


           

*********************************************************************************
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
* First INIZ (/term): hardware + InitTerm (IT.WND=0). Old Write still owns TEXT_RAM_BLK.
* Later named INIZ (/vtN): skip hardware, InitTerm only.
* Factory INIZ (/vt, IT.WND=$FF): skip hardware and InitTerm; SS.Open binds.
* GF.TermNew's log (read by the MAME dump): $12F5=active $12F6=cnt $12F7=K/E $12F8=err
Init
                    pshs      y
                    lda       >gr.FirstInitDone
                    cmpa      #$FF
                    beq       SkipHwInit
                    stu       >D.KbdSta pointer to this device's static
		    lbsr      ClrGrfMem
                    clr       >gr.SwitchReq
                    bsr       InitSound initialize the sound
                    bsr       InitKeyboard initialize the keyboad
                    bsr       InitMouse
                    lbsr      InitGrfDrv
                    bsr       InitPSG             PSG silence
                    ldx       >D.AltIRQ get the current alternate IRQ vector
                    stx       >D.OrgAlt save it off in the original vector
                    leax      AltISR,pcr get our alternate interrupt service routine
                    stx       >D.AltIRQ and place it in the global vector
                    lda       #$FF
                    sta       >gr.FirstInitDone	         Hardware init done, don't do this on later terminals

SkipHwInit
                    puls      y
HaveIdStart
                    ldb       IT.WND,y  Y is the device descriptor (IOMAN Attach)
                    bpl       HaveId
* IT.WND=$FF is the /vt factory. Do not InitTerm,
* never pass $FF into id*4. Slot is bound later by SS.Open.
                    bra       InitOk
HaveId
                    lbsr      InitTerm
                    bcs       InitFail
InitOk
                    clrb                clear the carry and error code
                    rts                 return to the caller
InitFail
                    rts                 carry and B already set


* Initialize the sound state.  SYS1 and the CODEC are programmed by
* grfdrv256's GF.PSGInit (InitPSG, after InitGrfDrv).
InitSound           clr       D.SndPrcID          clear the process ID of the current sound emitter (none)

InitBELL            leax      Bell,pcr point to the bell emission code
                    stx       >D.Bell   save it in the system global's bell vector
                    rts

* SYS1, CODEC and PSG silence via GF.PSGInit. Call after InitGrfDrv. Never system MAPSLOT.
InitPSG             ldb       #GF.PSGInit
		    lbsr      CallGrfDrvNoPD
		    rts
                    
* Keyboard initialization  
* NOTE: If we fail to find the 'keydrv' module, carry is returned set, but
* the caller can chose to ignore the error condition.
InitKeyboard        clr       D.KySns
                    clr       V.KySns,u
                    clr       V.IBufH,u
                    clr       V.IBufT,u
                    clr       V.LastCh,u          clear LastCh so no keyrepeat
                    leax      keydrvmod,pcr       point to the keydrv module name
                    lda       #Systm+Objct        it's a system module
                    pshs      u                   save U on the stack
                    os9       F$Link              link to it
                    tfr       u,x                 move the module address to X
                    puls      u                   restore U from the stack
                    bcs       ex@                 branch if the link failed
                    stx       V.KeyDrvMPtr,u      save the module pointer
                    sty       V.KeyDrvEPtr,u      save the entry pointer
                    jsr       ,y                  call the subroutine's Init entry point
                    rts                           return to the caller
ex@                 ldd       #0                  set D to 0
                    std       V.KeyDrvMPtr,u      clear the module pointer
                    std       V.KeyDrvEPtr,u      clear the entry pointer
                    rts                           return to the caller

                    ifgt      Level-1
* Mouse initialization  
* NOTE: If we fail to find the 'msdrv' module, carry is returned set, but
* the caller can chose to ignore the error condition.
InitMouse           leax      msdrvmod,pcr        point to the keydrv module name
                    lda       #Systm+Objct        it's a system module
                    pshs      u                   save U on the stack
                    os9       F$Link              link to it
                    tfr       u,x                 move the module address to X
                    puls      u                   restore U from the stack
                    bcs       ex@                 branch if the link failed
                    stx       V.MSDrvMPtr,u       save the module pointer
                    sty       V.MSDrvEPtr,u       save the entry pointer
                    jsr       ,y                  call the subroutine's Init entry point
                    rts                           return to the caller
ex@                 ldd       #0                  set D to 0
                    std       V.MSDrvMPtr,u       clear the module pointer
                    std       V.MSDrvEPtr,u       clear the entry pointer
                    rts                           return to the caller
                    endc

****************************************************************
******             Start GrfDrv Init Routines             ******
****************************************************************
ClrGrfMem           ldx       #GrfMem   point to GrfMem
                    ldy       #512      Size
clrgrf              clr       ,x+
                    leay      -1,y
                    bne       clrgrf
		    rts


****************************************************************
* Init GrfDrv — from wildbits vtio. Module name is grfdrv256.
* Clears GrfMem ($1100, 512 bytes) so call before gr.FirstInitiDone=$FF
* and before InitTerm. Task 1 / LUT 1; not system-task $6000.
****************************************************************
InitGrfDrv          pshs      u,y
                    leas      -2,s      buffer for process swap
                    lbsr      tosysproc swap to system process
                    lda       #Systm+Objct
                    leax      llnam,pcr
                    os9       F$NMLink
                    lbsr      toproc
                    bcc       setupgrfdrv
                    tfr       b,a
                    cmpb      #E$MNF
                    lbne      initerr
                    lbsr      tosysproc
                    lda       #Systm+Objct
                    leax      llpath,pcr
                    ldu       <D.Proc
                    os9       F$NMLoad
                    lbsr      toproc
                    lbcs      initerr
setupgrfdrv         leas      2,s       clean process buffer
                    pshs      a
                    lda       #GrfMem/256
                    tfr       a,dp
                    puls      a
                    ldu       #GrfMem
                    ldx       #gr.DATImg
                    clra
                    clrb
                    std       ,x++
                    ldd       #DAT.Free
                    std       ,x++
                    std       ,x++
                    std       ,x++
                    std       ,x++
                    std       ,x++
                    pshs      x
                    lda       #Systm+Objct
                    leax      llnam,pcr
                    ldy       >D.SysPrc
                    leay      P$DATImg,y
                    os9       F$FModul
                    puls      x
                    bcs       initerr2
                    ldy       MD$MPDAT,u
                    clra
                    ldd       ,y
                    std       ,x++
                    ldd       2,y
                    bne       has2
                    clra
		    ldb	      #7
                    bra       store7
has2
                    clra
store7
                    std       ,x++
                    ldy       >D.TskIPt
                    ldx       #gr.DATImg
                    stx       2,y
                    ldd       #$1CB0
                    std       gr.Stack
                    clra
                    tfr       a,dp
                    inc       MD$Link+1,u
                    ldd       #0
                    ldx       #M$Exec
                    ldy       #gr.DATImg+12
                    os9       F$LDDDXY
                    ora       #$C0
                    std       >gr.Entry
                    lda       #$FF
                    sta       gr.LiveTerm
                    ldb       #GF.Init           populate gr.WriteCharLive/Shadow + gr.ScrollLive/Shadow
                    bsr       CallGrfDrvNoPD
                    bcs       initerr3
                    clrb
                    puls      y,u,pc
initerr2            leas      4,s
initerr             leas      2,s
initerr3            coma
                    puls      y,u,pc

InitDevice          ldu       2,s
                    ldy       ,s
                    clrb
                    puls      y,u,pc

tosysproc
                    pshs      d
                    ldd       <D.Proc
                    std       4,s
                    ldd       <D.SysPrc
                    std       <D.Proc
                    puls      d,pc

toproc
                    pshs      d
                    ldd       4,s
                    std       <D.Proc
                    puls      d,pc

*******************************************************************
* CallGrfDrv - B = GF.*  Y = path descriptor (copies PD.RGS)
* CallGrfDrvRet - CallGrfDrv, then copies the caller's registers back
* CallGrfDrvNoPD - B = GF.*  no PD (ISR / switch)
*******************************************************************
CallWriteCharLive   ldx	     gr.WriteCharLive
		    bra	     CallGrfDrv2
CallWriteCharShadow ldx	     gr.WriteCharShadow
		    bra	     CallGrfDrv2
CallScrollLive      ldx	     gr.ScrollLive
		    bra	     CallGrfDrv2
CallScrollShadow    ldx	     gr.ScrollShadow
		    bra	     CallGrfDrv2
		    
* CallGrfDrvRet - CallGrfDrv, then copy the caller's R$A..R$U back from
* gr.PDRGS so a grfdrv op can return values in the caller's registers.
* Entry as CallGrfDrv (B = GF.* op, Y = path descriptor).  B and carry
* (grfdrv's error) are preserved across the copy.  R$CC/R$PC are not
* copied: IOMan reports the error in R$CC.
CallGrfDrvRet       bsr       CallGrfDrv
                    pshs      cc,b
                    ldx       #gr.PDRGS+R$A
                    ldy       >gr.RGSADR
                    leay      R$A,y
                    ldb       #R$PC-R$A
cgrloop             lda       ,x+
                    sta       ,y+
                    decb
                    bne       cgrloop
                    puls      cc,b,pc
CallGrfDrv
                    pshs      x,u,y,b
                    ldx       PD.RGS,y
                    stx       >gr.RGSADR
                    ldb       #R$Size/2
                    ldy       #gr.PDRGS
cpyloop             ldu       ,x++
                    stu       ,y++
                    decb
                    bne       cpyloop
                    ldx       >D.Proc
                    leax      P$DATImg,x
                    ldb       #8
                    ldy       #gr.PDAT
datcopy             ldu       ,x++
                    stu       ,y++
                    decb
                    bne       datcopy
                    puls      x,u,y,b
CallGrfDrvNoPD
                    ldx       gr.Entry
* U (the device static storage pointer) must survive the flip.  The
* return path is SysRet -> D.Flip0 -> R.Flip0, which restores only S
* (from gr.Stack) and CC (from A); D/X/Y/U/DP come back holding what-
* ever grfdrv left in them.  SetBlkC2C3 ends with 'ldu >gr.U5' (the
* $A0xx slot-5 alias), GFClrScrn leaves U past the end of the fill,
* and ScrollLive/ScrollShadow leave U from leau/CpyBlk - so without
* this the caller's next V.xxx,u access lands in the SYSTEM map.  The
* prior vtio did this at its single CallWrite funnel; keep it here so
* no new call site can forget it.  gr.Stack/R.Flip0 return to the bsr
* below, which then restores U and returns to the real caller.
CallGrfDrv2         pshs      u
                    bsr       CallGrfDrvGo
                    puls      u,pc
CallGrfDrvGo        orcc      #Entire
                    pshs      d
                    tfr       cc,a
                    sta       gr.Temp
                    puls      d
                    orcc      #IntMasks
                    sts       gr.Stack
                    lds       <D.CCStk
                    pshs      dp,x,y,u,pc
                    pshs      cc,d
                    stx       R$PC,s
                    lda       gr.Temp
                    sta       R$CC,s
* Re-entrancy DETECTOR, not a gate.  grfdrv's context is single-instance:
* gr.Stack holds one caller's S and lds <D.CCStk resets to the top of one
* shared stack, so a second entrant silently overwrites the first.  The
* gbusy path below is deliberately still unused - gating here would turn
* silent corruption into a stall, and because gr.Busy is what the AltISR
* tests before GF.Switch (line 105) and PSGOff (line 126), that stall
* would freeze Alt-arrow switching for its duration.
*
* It should be unreachable: a driver cannot be preempted mid-call (slice
* expiry only sets P$State|TimOut in falltsk.asm, and the switch is taken
* in the system-call RETURN path, krn.asm KrnShutDownInts), and the
* window before Flip1 is covered by the orcc #IntMasks above.  It opens
* only if something inside the grfdrv window blocks.  So count it instead
* of guessing: $12E2 = count, $12E3 = the GF.* code of the second entrant
* (B still holds it here).  A/X/Y are untouched - the sta gr.Busy below
* still needs A.
                    tst       >gr.Busy
                    beq       notreent@
                    inc       $12E2
                    stb       $12E3
notreent@           sta       gr.Busy
                    jmp       [>D.Flip1]
                    rts

nogrf               comb
                    ldb       #E$UnkSvc
                    rts

gbusy               comb
                    ldb       #E$NotRdy
                    rts

*******************************************************************
* SetThisTermGrfPtrs — Sets index for this term and falls through
* to SetTermGrfPts
*******************************************************************
SetThisTermGrfPtrs  lda       V.TermID,u
		    ldb	      #gr.TermSz
		    mul
		    ldx       #gr.TermTbl
		    leax      d,x
*******************************************************************
* SetTermGrfPtrs — copied from wildbits vtio. Do not rewrite.
* Entry: X = gr.TermTbl entry
* Sets gr.TermBlk, gr.VStaStorU, gr.VBlk from that entry
*******************************************************************
SetTermGrfPtrs      pshs      d,x,y,u
                    ldb       T.Block,x
                    stb       >gr.TermBlk
                    ldu       T.StatPtr,x
                    stu       >gr.VStaStorU
		    lda	      T.VBlk,x
                    sta       >gr.VBlk
		    ldd	      T.grU5,x
		    std	      >gr.U5
                    puls      d,x,y,u,pc

*******************************************************************
* InitTerm - set up terminal B (0-8, never $FF) for this static.
* TermTerm - release this device's terminal.
* Both are grfdrv ops.  GF.TermNew allocates the 16K buffer, fills the
* gr.TermTbl entry, sets the statics up (inheriting from the live
* terminal) and marks the entry open last.  GF.TermGone takes it off the
* switch list, brings in another terminal if it was live, frees the
* buffer, clears the entry and counts gr.TermCnt down.  Each gets the id
* in gr.b1 and this static in gr.d1; GF.TermGone does nothing unless
* T.StatPtr is this static, because IOMan calls Term after a failed Init
* or /vt open, and V.TermID need not be ours then.
* V.TermID is stored before the call so Term always has an id to offer.
* Exit: B and carry from grfdrv.  CallGrfDrv2 keeps U, so Term's later
* V.KeyDrvEPtr,u is still this static; A, X and Y are grfdrv's.  IOMan
* reloads what it needs after D$INIT and D$TERM, and SSOpen reloads Y.
*******************************************************************
InitTerm            stb       V.TermID,u
                    lda       #GF.TermNew
TermCall            stb       >gr.b1              terminal id
                    stu       >gr.d1              this static, as a system address
                    tfr       a,b
                    bra       CallGrfDrvNoPD
TermTerm            ldb       V.TermID,u
                    lda       #GF.TermGone
                    bra       TermCall





* Term — glue #9: unlink keydrv/IRQ only when gr.TermCnt==0.
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term
                    bsr       TermTerm
                    lda       >gr.TermCnt
                    bne       TermEx
                    ldx       >D.OrgAlt
                    stx       <D.AltIRQ
                    ldx       V.KeyDrvEPtr,u
                    cmpx      #0000
                    beq       NoUnlink
                    jsr       3,x
                    ldd       #0
                    std       V.KeyDrvEPtr,u
                    pshs      u
                    ldu       V.KeyDrvMPtr,u
                    os9       F$Unlink
                    puls      u
NoUnlink
                    ldx       V.MSDrvEPtr,u
                    cmpx      #0000
                    beq       NoMouse
                    ldd       #0
                    std       V.MSDrvEPtr,u
                    pshs      u
                    ldu       V.MSDrvMPtr,u
                    os9       F$Unlink
                    puls      u
                    ldd       #0
                    std       V.MSDrvMPtr,u
NoMouse
                    clr       >gr.FirstInitDone
                    ldd       #0
                    std       >D.KbdSta

TermEx              clrb
                    rts

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
* Check to see if there is a signal-on-data-ready set for this path.
* If so, we return E$NotRdy.
read1               lda       <V.SSigID,u         data ready signal trap set up?
                    lbne      NotReady            yes, exit with not ready error
                    leax      V.InBuf,u           point X to the input buffer
                    ldb       V.IBufT,u           get the buffer tail pointer
                    orcc      #IRQMask            mask interrupts
                    cmpb      V.IBufH,u           is the tail pointer the same as the head pointer?
                    beq       nitenite@           if so, the buffer is empty, so put the reader to sleep
                    abx                           X now points to the current character to fetch from the buffer
                    lda       ,x                  get that character now
                    pshs      a,x                 store character
                    leax      V.KSBuf,u           update V.KySns
                    abx
                    lda       ,x
                    sta       V.KySns,u
                    puls      a,x
                    bsr       IncNCheck           check for tail wrap
                    stb       V.IBufT,u           store the updated tail
                    andcc     #^(IRQMask+Carry)   unmask interrupts
                    rts                           and return to the caller
* Here, the calling process gets put to sleep waiting for input.
nitenite@           lda       V.BUSY,u            get the calling process ID
                    sta       V.WAKE,u            store it in V.WAKE
                    andcc     #^IRQMask           clear interrupts
                    ldx       #$0000              we want to..
                    os9       F$Sleep             sleep forever (until we get a wakup signal)
                    clr       V.WAKE,u            we're awake... clear our process ID
                    ldx       <D.Proc             get the current process descriptor
                    ldb       <P$Signal,x         and the signal we received
                    beq       Read                branch if there was no signal
                    cmpb      #S$Window           was it the window signal?
                    bcc       Read                branch if that, or higher
                    coma                          set the carry
                    rts                           and return to the caller

* Check if we need to wrap around tail pointer to zero.
IncNCheck           incb                          increment the next character pointer
                    cmpb      #KBufSz-1           are we pointing to the end of the buffer?
                    bls       ex@                 branch if not
                    clrb                          else clear the pointer (wraps to head)
ex@                 rts                           return


*******************************************************************
* SetWDest - WDest/TermBlk from V.TermLive / V.TermBufBlk.
* Snapshot into gr.W* before Flip1. Do not index U in LUT 1.
*******************************************************************
SetWDest            lda       V.TermLive,u
                    bne       SWVicky
                    lda       V.TermBufBlk,u
                    beq       SWVicky
                    sta       >gr.TermBlk
                    clr       >gr.b4              WD.Buf - the 16K terminal buffer
                    rts
SWVicky             lda       #WD.Vicky
                    sta       >gr.b4              WD.Vicky - the live TEXT_RAM_BLK/COLOR_RAM_BLK planes
                    lda       V.TermBufBlk,u
                    beq       SWDestX
                    sta       >gr.TermBlk         keep SetBlkC2C3 off block 0
SWDestX             rts

*******************************************************************
* SetShadowBlk - point gr.TermBlk at THIS terminal's 16K buffer.
*
* WriteCharShadow / ScrollShadow are direct calls: they bypass the
* gr.b*/gr.d* block entirely and take A/B/Y in registers, so gr.TermBlk
* is their ONLY parameter out of GrfMem.  Nothing else on the PutGlyph
* path refreshes it - the last writer could have been another terminal's
* EraseLine (SetThisTermGrfPtrs) or PutCell/ChgPal (SetWDest) - so
* without this a shadow glyph lands in the wrong terminal's backup
* buffer.  With one terminal it could never be wrong; with two it is
* wrong most of the time.
*
* Exit: Z clear = gr.TermBlk loaded, go ahead.  Z set = V.TermBufBlk is
* 0, so there is no buffer and the caller must skip the write; block 0
* at LUT 1 $6000 is the kernel.
* STA/LDA both set Z and PULS does not touch CC, so the flag survives.
* Preserves A/B/X/Y/U - PutGlyph needs all of them.
*******************************************************************
SetShadowBlk        pshs      a
                    lda       V.TermBufBlk,u
                    beq       SSBlkX
                    sta       >gr.TermBlk
SSBlkX              puls      a,pc

*******************************************************************
* DoScroll - move rows up one: gr.d1 = start offset (first cell of the
* row that goes away), gr.d2 = end offset (V.ScreenSize), A = width.
* Picks ScrollLive or ScrollShadow for THIS terminal.  Used by the
* line-feed scroll (gr.d1 = 0) and 1F 31 Delete Line.
* CallScroll* preserve U.
*******************************************************************
DoScroll            tst       V.TermLive,u
                    bne       dslive@
                    bsr       SetShadowBlk        aim at THIS term's 16K buffer (keeps A)
                    beq       dsx@                no buffer: nothing to scroll
                    lbra      CallScrollShadow
dslive@             lbra      CallScrollLive
dsx@                rts

*******************************************************************
* PutCell - A = glyph, X = cell offset.  Snapshot + GF.Cell.
* Colour = V.FBCol; dest via SetWDest.  Used by EraseChar.
*   -> b2 glyph, b3 colour attr, d1 cell offset, b4 dest
*******************************************************************
PutCell             pshs      d,x
                    sta       >gr.b2              glyph
                    stx       >gr.d1              cell offset
                    lda       V.FBCol,u
                    sta       >gr.b3              colour attr
                    bsr       SetWDest            sets b4
                    ldb       #GF.Cell
                    lbsr      CallGrfDrvNoPD
                    puls      d,x,pc

* Write — glyph paint is GF.Write (LUT 1). Cursor I/O stays here.
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
Write
	            tst       V.WriteState,u		      
                    beq	      DefaultState
		    ldb	      V.EscCount,u
		    leax      V.EscParms,u
		    sta	      b,x
		    inc	      V.EscCount,u
		    dec	      V.EscNeed,u
		    lbeq      EscCodeComplete
		    bra	      UpdateLiveCursor

DefaultState	    cmpa      #C$SPAC             is the character a space or greater?
                    lbcs      ChkESC              branch if not; go check for escape codes
* PutGlyph - paint A at the cursor and advance (bypasses the control-code
* check).  Entry from Do1C for the $1C "write next byte literally" code.
PutGlyph	    ldy	      V.CurPos,u
		    ldb	      V.FBCol,u
		    tst	      V.TermLive,u
		    bne	      writelive
		    bsr       SetShadowBlk          aim at THIS term's 16K buffer
		    beq	      cont@                 no buffer: drop the glyph
		    lbsr      CallWriteCharShadow
		    bra	      cont@
writelive	    lbsr      CallWriteCharLive
* BUG FIX: V.CurPos is a 2-byte field; `inc V.CurPos,u` only touched the
* high byte (6809 words are big-endian), adding 256 - not 1 - per char.
* That desynced it from V.CurRow/V.CurCol (advanced correctly below),
* so each glyph landed WWidth-dependent rows/cols away from the last.
cont@		    ldd	      V.CurPos,u
		    addd      #1
		    std	      V.CurPos,u            increment cursor poisition in text map
                    ldd       V.CurRow,u          get the current row and column (xy coordinates)
                    incb                          increment the column
                    cmpb      V.WWidth,u          compare it against the number of columns
                    blt       savecursor                  branch if we're less than
                    clrb                          else the column goes to 0
incrow              inca                          and we increment the row
                    cmpa      V.WHeight,u         compare it against the number of rows
                    blt       savecursor         branch if we're less than (don't clear the new line we're on)

* Always land on the last row of THIS term. CurRow can be 50 on a
* 80x30 after DWSet 80x60. Height 0 would decb to $FF and CpyBlk
* 80*255 bytes through LUT 1 $A000 (path table / DevTbl).
* B is already the column we want to land on: PutGlyph's line wrap clrb's
* just above, and CurDown ($0A at the bottom row) enters incrow with
* B = V.CurCol so a plain line feed keeps its column.
                    lda       V.WHeight,u
                    lbeq      CurHome
                    deca
                    pshs      d                   last row, column from B
* B = height, which the two guards that follow need.  There used to be a
* 'sta >gr.b5' here feeding the old GF.Write WO.Scroll op; ScrollLive/
* ScrollShadow never read it, so it is gone.
                    ldd       V.WWidth,u
                    tstb
                    beq       noscroll
                    decb
                    beq       noscroll
                    clra
                    clrb
                    std       >gr.d1              start: row 0
                    ldd       V.ScreenSize,u
                    std       >gr.d2              end: bottom of screen
                    lda       V.WWidth,u          A = width
                    lbsr      DoScroll
noscroll            puls      d

* clear line
clrline             std       V.CurRow,u          save the current row/column value
                    lbsr      CalcCurPos          resync V.CurPos (scroll moved us)
                    lbsr      EraseLine           erase the line
                    bra	      UpdateLiveCursor   and return to the caller
savecursor          std       V.CurRow,u          save the current row/column value

UpdateLiveCursor    tst       V.TermLive,u
                    beq       WrNoCur
                    pshs      d
                    lda       V.CurCol,u
                    ldx       #TXT.Base
                    sta       VKY_TXT_CURSOR_X_REG_L,x
                    lda       V.CurRow,u
                    sta       VKY_TXT_CURSOR_Y_REG_L,x
                    puls      d
* 6809 TST/STD leave C dirty; SCF Write does bcs after D$WRIT.
WrNoCur		    andcc     #^Carry
                    rts

**************************************************************************
* ChkESC - dispatch a control byte (A < $20).  Prefix codes ($1B/$1C/$1F)
* and the two parameterised single-byte codes ($02/$05, via DCodeTbl) arm
* the escape-parameter collector (V.WriteState / V.EscNeed / V.EscHandler);
* everything else runs immediately.  Returns to SCF with carry clear, B=0.
ChkESC              cmpa      #$1B                is the character ESC?
                    lbeq      Arm1B              if so, gather the sub-code
                    cmpa      #$1C               literal-write next byte?
                    lbeq      Arm1C
                    cmpa      #$1F               display-attribute prefix?
                    lbeq      Arm1F
                    cmpa      #C$CR              is it a carriage return?
                    bhi       ChkRet            $0E..$1A / $1D / $1E - ignore
                    leax      <DCodeTbl,pcr     else deal with screen codes
                    lsla                          adjust A for the table entry size
                    ldd       a,x                 get the address offset in D
* jsr, not jmp: the handler must come back so the hardware cursor gets
* refreshed.  A bare jmp rts'd straight to SCF, so CurHome/CurRght/
* CurLeft/CurUp/Retrn/ClrScrn/the erase codes all moved V.CurRow/V.CurCol
* without ever touching VKY_TXT_CURSOR_X/Y and the cursor lagged the text.
* UpdateLiveCursor ends andcc #^Carry / rts, which also scrubs the dirty
* carry CurRght's bye@ path used to hand back to SCF.
                    jsr       d,x                 run the handler...
                    clrb
                    bra       UpdateLiveCursor   ...then refresh the hw cursor and rts
ChkRet              clrb
                    andcc     #^Carry
                    rts

* Display functions dispatch table.
DCodeTbl            fdb       NoOp-DCodeTbl       $00:no-op (null)
                    fdb       CurHome-DCodeTbl    $01:HOME cursor
                    fdb       Arm02-DCodeTbl      $02:CURSOR XY (2 params)
                    fdb       EraseLine-DCodeTbl  $03:ERASE LINE
                    fdb       ErEOLine-DCodeTbl   $04:CLEAR TO EOL
                    fdb       Arm05-DCodeTbl      $05:CURSOR CONTROL (sub-code)
                    fdb       CurRght-DCodeTbl    $06:CURSOR RIGHT
                    fdb       Bell-DCodeTbl       $07:Bell
                    fdb       CurLeft-DCodeTbl    $08:CURSOR LEFT
                    fdb       CurUp-DCodeTbl      $09:CURSOR UP
                    fdb       CurDown-DCodeTbl    $0A:CURSOR DOWN
                    fdb       ErEOScrn-DCodeTbl   $0B:ERASE TO EOS
                    fdb       ClrScrn-DCodeTbl    $0C:CLEAR SCREEN
                    fdb       Retrn-DCodeTbl      $0D:RETURN

**********************************************************************
* Sub-code tables.  {fcb matchbyte, fcb nparm, fdb handler-<table>}
* nparm = parameter bytes that follow the sub-code.  fcb $00 ends.
**********************************************************************
Esc1BTbl            fcb       $20,8
                    fdb       DWSet-Esc1BTbl     DWSet STY CPX CPY SZX SZY FG BG BDR
                    fcb       $21,0
                    fdb       DWSelect-Esc1BTbl  select this terminal
                    fcb       $24,0
                    fdb       DWEnd-Esc1BTbl     end device window (no-op)
                    fcb       $30,0
                    fdb       DefColr-Esc1BTbl   default palette (no-op)
                    fcb       $32,1
                    fdb       FColor-Esc1BTbl    foreground colour slot
                    fcb       $33,1
                    fdb       BColor-Esc1BTbl    background colour slot
                    fcb       $34,1
                    fdb       Border-Esc1BTbl    border colour slot
                    fcb       $3D,1
                    fdb       BoldSw-Esc1BTbl    bold on/off (consumes 1, no-op)
                    fcb       $60,5
                    fdb       ChgForePal-Esc1BTbl fg palette  PRN R G B A
                    fcb       $61,5
                    fdb       ChgBackPal-Esc1BTbl bg palette  PRN R G B A
                    fcb       $62,0
                    fdb       ChgFont0-Esc1BTbl   select font set 0
                    fcb       $63,0
                    fdb       ChgFont1-Esc1BTbl   select font set 1
                    fcb       $00

Esc05Tbl            fcb       $20,0
                    fdb       CurOff-Esc05Tbl     cursor hide
                    fcb       $21,0
                    fdb       CurOn-Esc05Tbl      cursor show
                    fcb       $22,1
                    fdb       CurChar-Esc05Tbl    set cursor character
                    fcb       $23,1
                    fdb       CurRate-Esc05Tbl    set cursor flash rate
                    fcb       $00

Esc1FTbl            fcb       $20,0
                    fdb       RevOn-Esc1FTbl      reverse video on
                    fcb       $21,0
                    fdb       RevOff-Esc1FTbl     reverse video off
                    fcb       $22,0
                    fdb       ULOn-Esc1FTbl       underline on (stub)
                    fcb       $23,0
                    fdb       ULOff-Esc1FTbl      underline off (stub)
                    fcb       $24,0
                    fdb       BlkOn-Esc1FTbl      blink on (stub)
                    fcb       $25,0
                    fdb       BlkOff-Esc1FTbl     blink off (stub)
                    fcb       $30,0
                    fdb       InsLine-Esc1FTbl    insert line
                    fcb       $31,0
                    fdb       DelLine-Esc1FTbl    delete line
                    fcb       $00


**********************************************************************
* Escape-parameter collector plumbing
**********************************************************************

* Arm stubs.  Reached from ChkESC ($1B/$1C/$1F) or DCodeTbl ($02/$05).
* Load B = parameter-byte count, X = completion handler, fall into EscArm.
Arm02               ldb       #2
                    leax      CurXY,pcr
                    bra       EscArm
Arm05               ldb       #1
                    leax      Disp05,pcr
                    bra       EscArm
Arm1B               ldb       #1
                    leax      Disp1B,pcr
                    bra       EscArm
Arm1C               ldb       #1
                    leax      Do1C,pcr
                    bra       EscArm
Arm1F               ldb       #1
                    leax      Disp1F,pcr
* fall through

* EscArm - B = param bytes to gather, X = handler (absolute).
* B=0 runs the handler now; otherwise arm the collector and return to SCF.
EscArm              tstb
                    beq       EscRun
                    stb       V.EscNeed,u
                    clr       V.EscCount,u
                    lda       #1
                    sta       V.WriteState,u
                    stx       V.EscHandler,u
                    clrb
                    andcc     #^Carry
                    rts
EscRun              jmp       ,x                  0 params: run handler, rts to SCF

* EscCodeComplete - all parameter bytes gathered (from the Write front end).
* Params sit at V.EscParms+0..  A sub-dispatcher may re-arm the collector.
EscCodeComplete     clr       V.WriteState,u     disarm first
                    ldx       V.EscHandler,u
                    jsr       ,x                  run the completion handler
                    lbsr      UpdateLiveCursor   refresh the hardware cursor
                    clrb
                    andcc     #^Carry
                    rts

* EscScan - linear search of a sub-code table.
* Entry: A = sub-code byte
*        X = table base; entries {fcb byte, fcb nparm, fdb handler-base},
*            terminated by fcb $00
* Exit : carry set  = not found
*        carry clear = B = nparm, X = absolute handler address
EscScan             pshs      x                   ,s = table base
escsl@              ldb       ,x                  entry match byte
                    beq       escsnf@             $00 sentinel - not found
                    pshs      b
                    cmpa      ,s+                 A = sub-code?  (pops the byte)
                    beq       escsh@
                    leax      4,x                 next entry
                    bra       escsl@
escsh@              ldb       1,x                 B = nparm
                    pshs      b
                    ldd       2,x                 D = handler offset
                    addd      1,s                 + table base
                    tfr       d,x                 X = absolute handler
                    puls      b                   B = nparm
                    leas      2,s                 drop saved base
                    andcc     #^Carry
                    rts
escsnf@             leas      2,s                 drop saved base
                    orcc      #Carry
                    rts

* Sub-code dispatchers for $1B / $05 / $1F.  Entered from EscCodeComplete
* with the sub-code byte at V.EscParms+0.  Look it up; run now if it takes
* no further params, else re-arm the collector for the leaf handler.
Disp1B              leax      Esc1BTbl,pcr
                    bra       DispCom
Disp05              leax      Esc05Tbl,pcr
                    bra       DispCom
Disp1F              leax      Esc1FTbl,pcr
DispCom             lda       V.EscParms,u       the sub-code byte
                    bsr       EscScan
                    bcs       DispNF             unknown sub-code - ignore
                    tstb                          leaf needs parameter bytes?
                    beq       EscRun             no - run it now (X = handler)
                    stb       V.EscNeed,u        yes - re-arm for the leaf
                    clr       V.EscCount,u
                    lda       #1
                    sta       V.WriteState,u
                    stx       V.EscHandler,u
DispNF              clrb
                    andcc     #^Carry
                    rts

* Do1C - $1C: write the following byte to the screen literally.
Do1C                lda       V.EscParms,u
                    lbra      PutGlyph


**********************************************************************
*                      Code Handling Routines
**********************************************************************

**********************************************************************
* 00 - NoOp
*
NoOp                rts


**********************************************************************
* 01 - CurHome  Moves the cursor to the home location 0,0
*
CurHome             clr       V.CurCol,u
                    clr       V.CurRow,u
* V.CurPos is a 2-byte field; a single clr only zeroed the high byte
* (6809 words are big-endian), so home left the low byte behind.
                    clr       V.CurPos,u
                    clr       V.CurPos+1,u
                    rts
		    
***********************************************************************
*** Cursor Utility Function Used by 02, 06, 08. 09, 0A, 0D, and Write
************************************************************************
*** CalcCurPos - recompute V.CurPos from V.CurRow / V.CurCol.
*** V.CurPos = V.CurRow * V.WWidth + V.CurCol  (linear text-map cell).
*** Call after any handler that moves the cursor without going through
*** PutGlyph.  Clobbers D.  Returns carry clear (SCF Write checks it).
***
*** Also clamps V.CurRow to V.WHeight-1.  DWSet 80x60 then 80x30 can leave
*** CurRow at 50; the prior tree re-clamped on every character in RawWrite
*** and the rewrite dropped it, so do it here - the one point every cursor
*** handler already routes through.
***
CalcCurPos          lda       V.WHeight,u
                    beq       CCPzero             degenerate window - cell 0
                    cmpa      V.CurRow,u
                    bhi       CCProw              CurRow < WHeight, fine
                    deca                          else clamp to the last row
                    sta       V.CurRow,u
CCProw              lda       V.CurRow,u
                    ldb       V.WWidth,u
                    mul
                    addb      V.CurCol,u
                    adca      #0
                    std       V.CurPos,u
                    andcc     #^Carry
                    rts
CCPzero             clra
                    clrb
                    std       V.CurPos,u
                    andcc     #^Carry
                    rts

***********************************************************************
*** SetScreenSize - V.ScreenSize = V.WWidth * V.WHeight (cells to scroll).
*** MUST be called after every write to V.WWidth/V.WHeight.  grfdrv's
*** ScrollLive/ScrollShadow take it in Y and subtract one row from it; a
*** zero here makes the count 0-WWidth, CpyBlk's source-end address wraps
*** below the source start so it copies nothing, and the "blank the
*** exposed row" loop then wipes row 0 instead of the last row.
*** Preserves D.
***
SetScreenSize       pshs      d
                    ldd       V.WWidth,u
                    mul
                    std       V.ScreenSize,u
                    puls      d,pc

**********************************************************************
* 02 - Cursor XY  - 02 LCX LCY
* Positions the cursor at the specified coordinates.
* V.EscParms+0 (LCX) = desired column + 32.
* V.EscParms+1 (LCY) = desired row + 32.
* EscCodeComplete calls UpdateLiveCursor after us.
*
CurXY               lda       V.EscParms,u        LCX
                    suba      #$20
                    bpl       CXYcol@
                    clra                          malformed (<32) -> column 0
CXYcol@             cmpa      V.WWidth,u
                    blo       CXYcolok@
                    lda       V.WWidth,u          clamp to last column
                    deca
CXYcolok@           sta       V.CurCol,u
                    lda       V.EscParms+1,u      LCY
                    suba      #$20
                    bpl       CXYrow@
                    clra
CXYrow@             cmpa      V.WHeight,u
                    blo       CXYrowok@
                    lda       V.WHeight,u         clamp to last row
                    deca
CXYrowok@           sta       V.CurRow,u
                    bra       CalcCurPos


**********************************************************************
* 03 - Erase Line - Erase the current line
*
EraseLine           lbsr      SetThisTermGrfPtrs
		    ldb	      #GF.EraseLine
		    lbsr      CallGrfDrvNoPD
		    rts
		    
**********************************************************************
* 04 - Clear to EOL
* Erase from the current cursor position to the end of the line.
*
ErEOLine	    lbsr      SetThisTermGrfPtrs
		    ldb	      #GF.ErEOLine
		    lbsr      CallGrfDrvNoPD
		    rts

***********************************************************************
* 05 - Cursor Control
*
***********************************************************************
*** 05 20 - Cursor Off/Hide - Turns the Cursor Off
***
CurOff              tst       V.TermLive,u
                    beq       CurOffX
                    ldx       #TXT.Base
                    ldb       VKY_TXT_CURSOR_CTRL_REG,x
                    andb      #~Vky_Cursor_Enable
                    stb       VKY_TXT_CURSOR_CTRL_REG,x
CurOffX             rts

************************************************************************
*** 05 21 - Cursor On/Show - Turns Cursor On
***
CurOn               tst       V.TermLive,u
                    beq       CurOnX
                    ldx       #TXT.Base
                    lda       VKY_TXT_CURSOR_CTRL_REG,x
                    ora       #Vky_Cursor_Enable
                    sta       VKY_TXT_CURSOR_CTRL_REG,x
CurOnX              rts

************************************************************************
*** 05 22 - Set Cursor Character - 05 22 CHR
***
* Guarded like CurOff/CurOn: a shadow terminal must not reach the live
* cursor registers, or it changes the cursor of whatever is actually on
* screen.  Unlike ChgFont0/1 below this can only DROP the request, not
* defer it: PushBuf/PullBuf carry $FFC0-$FFCF (V.V_MCR + V.V_LayerCTL +
* V.BordBack), and the cursor registers start at $FFD0, so there is no
* per-terminal mirror to stage it in.  Cursor character, colour, enable
* and flash rate are therefore global - see the doc's gap list.
CurChar             tst       V.TermLive,u
                    beq       CurCharX
                    ldx       #TXT.Base
		    lda       V.EscParms,u
                    sta       VKY_TXT_CURSOR_CHAR_REG,x
CurCharX            rts
		    
************************************************************************
*** 05 23 - Set Cursor Flash Rate
***
*** Parameter: BYT
***
***   XXXXX1XX = cursor flashing disabled
***   XXXXX000 = 1 second flash interval
***   XXXXX001 = .5 second flash interval
***   XXXXX010 = .25 second flash interval
***   XXXXX011 = .2 second flash interval
* Guarded like CurChar/CurOff/CurOn: the cursor registers start at $FFD0,
* past the 16 bytes PushBuf/PullBuf carry, so there is no per-terminal
* mirror to defer into - a shadow terminal can only be stopped from
* changing the live cursor's flash rate.
CurRate             tst       V.TermLive,u
                    beq       CurRateX
                    ldx       #TXT.Base
                    ldb       VKY_TXT_CURSOR_CTRL_REG,x
                    andb      #$01                preserve the cursor enable bit
                    lsla                          shift bits to the left
                    pshs      a                   save the value to OR in on the stack
                    orb       ,s+                 OR it in with the contents of the register
                    stb       VKY_TXT_CURSOR_CTRL_REG,x save it to the hardware
CurRateX            rts

**********************************************************************
* 06 - Cursor Right
* If the cursor is at the last column, it moves to the first column of the next line.
* If the cursor is at the last column of the last line, it stays there
*
CurRght             ldd       V.CurRow,u
                    incb                          increment the column
* bhs, not bgt: at the last column incb makes B = WWidth, which bgt let
* through and stored as V.CurCol - one cell off the end of the row.
                    cmpb      V.WWidth,u          is it >= the number of columns?
                    bhs       nextrow@
ex@                 std       V.CurRow,u
                    lbsr      CalcCurPos
bye@                rts
nextrow@            ldb       V.WHeight,u
                    decb
                    pshs      b
                    cmpa      ,s+                 are we at the last row?
                    bhs       bye@                yep, nothing to change.
                    clrb                          else clear the column
                    inca                          increment the row
                    bra       ex@                 save and return

**********************************************************************
* 07 - Bell
* Bell ($07) (called via Bell vector D.Bell):
*
Bell                ldd       #$0F1F              A = start volume (15), B = duration counter
                    ldy       #%0000000100000011              bell frequency

* Common SS.Tone and Bell routine
*
* Entry: A = Volume byte (0-15).
*        B = Cycle repeats (1 means use D.TnCnt as countdown).
*        Y = Frequency.
BellTone            tst       D.SndPrcID
                    bne       BellBusy
                    stb       D.TnCnt             store the duration counter in the global
                    sta       >gr.b3              volume 0-15; LUT 1 inverts
                    sty       >gr.d1              frequency
                    ldb	      #GF.PSGBell
		    lbsr      CallGrfDrvNoPD
BellBusy            clrb
                    rts
	    
**********************************************************************
* 08 - Cursor Left
* If the cursor is at the first column, it moves to the last column of the previous line.
*
CurLeft             ldd       V.CurRow,u          get the current row and column values
                    beq       leave               branch if they're zero
                    decb                          decrement the column value
                    bpl       EraseChar           erase the character
                    ldb       V.WWidth,u          get the number of columns
                    decb                          minus 1
                    deca                          decrement the counter
                    bpl       EraseChar           branch until done
                    clra                          clear A

* Entry:  A = The row of the character to erase.
*         B = The column of the character to erase.
EraseChar           std       V.CurRow,u          save D to the current row and column
                    lbsr      CalcCurPos          resync (and row-clamp) V.CurPos
                    ldx       V.CurPos,u          X = cell offset
                    lda       #C$SPAC
                    lbsr      PutCell             erase the one cell
leave               rts                           return

**********************************************************************
* 09 - Cursor Up
* If the cursor is at the top-most line, it stays at its current position.
*
CurUp               lda       V.CurRow,u
                    deca
                    bmi       ex@
                    sta       V.CurRow,u
                    lbsr      CalcCurPos
ex@                 rts


**********************************************************************
* 0A - Cursor Down
*
CurDown             ldd       V.CurRow,u          get the current row and column
                    inca                          try to move down one row
                    cmpa      V.WHeight,u
                    blt       CDmv@               room below - just move
                    ldd       V.CurRow,u          at bottom - scroll (shared path)
                    lbra      incrow
* ChkESC's jsr dispatch refreshes the hardware cursor on the way out now.
CDmv@               sta       V.CurRow,u
                    lbra      CalcCurPos



**********************************************************************
* 0B - Erase to EOS
* Erase from the current cursor position to the end of the screen.
*
ErEOScrn	    lbsr      SetThisTermGrfPtrs
		    ldb	      #GF.ErEOScrn
		    lbsr      CallGrfDrvNoPD
		    rts
		    

**********************************************************************
* 0C - Clear Screen
*
ClrScrn             lbsr      SetThisTermGrfPtrs
                    ldb       #GF.ClrScrn
                    lbsr      CallGrfDrvNoPD
                    lbra      CurHome

**********************************************************************
* 0D - Return
*
Retrn               clr       V.CurCol,u          clear the current column
                    lbra      CalcCurPos          resync V.CurPos, then rts

**********************************************************************
* 1B - Window Settings, FG, BG, Palette, Font, Border
*

************************************************************************
*** 1B 20 - DWSet
***
*** STY = screen type: $01 = 40x30, $02 = 80x30, $03 = 40x60, $04 = 80x60.
*** CPX = starting position X.
*** CPY = starting position Y.
*** SZX = width starting at X.
*** SZY = height starting at Y.
*** PRN1 = foreground color.
*** PRN2 = background color.
*** PRN3 = border color.
***
DWSet               lda       V.DWType,u
                    sta       V.ScTyp,u
                    cmpa      #$01                40x30?
                    bne       IsIt80x30
                    bsr       SetWin40x30
                    bra       setcols@
IsIt80x30           cmpa      #$02
                    bne       IsIt40x60
                    bsr       SetWin80x30
                    bra       setcols@
IsIt40x60           cmpa      #$03
                    bne       IsIt80x60
                    bsr       SetWin40x60
                    bra       setcols@
IsIt80x60           bsr       SetWin80x60                    
setcols@            lda       V.DWFore,u
                    bsr       FColor
                    lda       V.DWBack,u
                    bsr       BColor
                    lda       V.DWBorder,u
                    bsr       Border
                    bsr       ClrScrn
                    rts

SetWin40x30         ldb       #DBL_Y|DBL_X
                    ldx       #40*256+30
* DBL_Y/X belong to THIS term. Do not poke live Vicky when inactive
* (that made /term 80x60, and the next PushBuf saved it into the
* active term's V.V_MCR). PullBuf restores V.V_MCR.
* Both legs now read the MIRROR - never MASTER_CTRL_REG_H - so the only
* difference is whether the hardware is touched.  For the live terminal
* the mirror and the register are the same value by construction; for a
* shadow terminal the register belongs to somebody else, and reading a
* Vicky register back is not something to rely on in any case.
SetWin              stx       V.WWidth,u
                    lbsr      SetScreenSize
                    pshs      b
                    ldb       V.V_MCR+1,u
                    andb      #~(DBL_Y|DBL_X|CLK_70)
                    orb       ,s
                    stb       V.V_MCR+1,u
                    tst       V.TermLive,u
                    beq       SetWinSt
                    ldx       #TXT.Base
                    stb       MASTER_CTRL_REG_H,x
SetWinSt            puls      b,pc

SetWin40x60         ldb       #DBL_X
                    ldx       #40*256+60
                    bra       SetWin

SetWin80x30         ldb       #DBL_Y
                    ldx       #80*256+30
                    bra       SetWin

SetWin80x60         clrb
                    ldx       #80*256+60
                    bra       SetWin

************************************************************************
*** 1B 21 - DWSelect
***
*** Select the terminal this path writes to.  U is already that
*** terminal's static, and the open that produced the path ran InitTerm,
*** so there is no "not open" case.  The switch itself is left to the
*** AltISR (SW.Goto) like Alt+arrow, so it waits out gr.Busy.
*** P$SelP is recorded as CoWin does, but not acted on (no Nobel rule).
*** Y survives from SCF's D$WRIT to here, so PD.RGS,y is the caller's
*** register stack; R$A is still the local path (S2UPath never writes it).
DWSelect            ldx       PD.RGS,y            caller's registers
                    lda       R$A,x               local path the 1B 21 came in on
                    ldx       >D.Proc
                    sta       P$SelP,x            this process's selected window
                    tst       V.TermLive,u        already on screen?
                    bne       selx@
                    lda       V.TermID,u
                    sta       >gr.SwitchTerm      target first, then the request
                    lda       #SW.Goto
                    sta       >gr.SwitchReq
selx@               clrb
                    rts
************************************************************************
*** 1B 24 - DWEnd
***
DWEnd               rts
************************************************************************
*** 1B 30 - DefColor
***
DefColr             rts
************************************************************************
*** 1B 32 - Foreground Color Slot
***
FColor		    lsla                          A = A / 2
                    lsla                          A = A / 2
                    lsla                          A = A / 2
                    lsla                          A = A / 2
                    pshs      a                   save the register
                    ldb       V.FBCol,u           load the foreground/background color
                    andb      #$0F                mask out the upper 4 bits
FGCUpdate           orb       ,s+                 OR in the foreground color bits
                    stb       V.FBCol,u           save the updated color
                    rts                           return
************************************************************************
*** 1B 33 - Background Color Slot
***
BColor              anda      #$0F                mask out the upper 4 bits
                    pshs      a                   save the register
                    ldb       V.FBCol,u           load the foreground/background color
                    andb      #$F0                mask out the lower 4 bits
                    bra       FGCUpdate           and do the OR (in FColor)

************************************************************************
*** 1B 34 - Border color Slot
***
Border              rts

************************************************************************
*** 1B 3D - Bold On/Off (No Bold available in TextMap)
***
BoldSw	            rts

************************************************************************
*** 1B 60 - Foreground Palette  PRN R G B A
*** 1B 61 - Background Palette  PRN R G B A
*** PRN = palette register number (0-15).
*** R G B A = red / green / blue / alpha components.
*** FG vs BG is set by the entry point, not a parameter.
***
*** -> b2 palette reg #, b4 dest, b5 FG/BG select,
***    d1 LUT bytes 0-1 (blue, green), d2 LUT bytes 2-3 (red, alpha).
ChgForePal	    clrb                          0 = foreground LUT
                    bra       ChgPal
ChgBackPal          ldb       #1                  1 = background LUT
ChgPal              pshs      d,x
                    stb       >gr.b5              FG/BG LUT select
                    lda       V.EscParms+0,u      PRN
                    sta       >gr.b2              palette register #
                    lda       V.EscParms+3,u
                    sta       >gr.d1              blue     (LUT byte 0)
                    lda       V.EscParms+2,u
                    sta       >gr.d1+1            green    (LUT byte 1)
                    lda       V.EscParms+1,u
                    sta       >gr.d2              red      (LUT byte 2)
                    lda       V.EscParms+4,u
                    sta       >gr.d2+1            alpha    (LUT byte 3)
                    lbsr      SetWDest            sets b4
                    ldb       #GF.Pal
                    lbsr      CallGrfDrvNoPD
                    puls      d,x
                    rts


************************************************************************
*** 1B 62 - Select Font Set 0
***
ChgFont0            clrb                          FT_FSET clear = font set 0
                    bra       ChgFont
************************************************************************
*** 1B 63 - Select Font Set 1
***
ChgFont1            ldb       #FT_FSET            FT_FSET set = font set 1
* The font set is a bit in MASTER_CTRL_REG_H, which belongs to THIS
* terminal, not to the hardware: V.V_MCR mirrors $FFC0-$FFC1 and PullBuf
* writes it back on a switch.  Both entries used to poke the live
* register unconditionally, so 1B 62 / 1B 63 from a shadow terminal
* changed the font under whatever was actually on screen - and the next
* PushBuf then captured it into that other terminal's V.V_MCR, making it
* stick.  That is exactly the failure SetWin's comment describes, so use
* SetWin's split: live updates the register and the mirror, shadow
* updates only the mirror, and the change lands when the terminal is
* switched in.  tst (not lda) so A survives for the escape dispatcher.
ChgFont             pshs      b                   requested font-set bit
                    ldb       V.V_MCR+1,u         the mirror, never the register
                    andb      #~(FT_FSET)
                    orb       ,s
                    stb       V.V_MCR+1,u
                    tst       V.TermLive,u
                    beq       ChgFontSt
                    ldx       #TXT.Base
                    stb       MASTER_CTRL_REG_H,x
ChgFontSt           puls      b,pc

**********************************************************************
* 1F - Misc Font and Line Controls
*

************************************************************************
*** 1F 20 - Reverse Video On
***
RevOn               tst       V.Reverse,u         is reverse already on?
                    bne       revend              branch if so
                    com       V.Reverse,u
DoReverse
* swap foreground and background color bits
                    lda       V.FBCol,u           else get the fore/background color
                    lsra                          shift all...
                    lsra                          of the foreground..
                    lsra                          color bits into the...
                    lsra                          lower nibble
                    pshs      a
                    lda       V.FBCol,u
                    lsla                          shift all...
                    lsla                          of the background...
                    lsla                          color bits into the...
                    lsla                          upper nibble
                    ora       ,s+
                    sta       V.FBCol,u
revend              rts
************************************************************************
*** 1F 21 - Reverse Video Off
***
RevOff              tst       V.Reverse,u         is reverse already off?
                    beq       revend
                    com       V.Reverse,u
                    bra       DoReverse	          Do Reverse is in RevOn

************************************************************************
*** 1F 22 - Underline On
***
ULOn                rts

************************************************************************
*** 1F 23 - Underline Off
***
ULOff               rts

************************************************************************
*** 1F 24 - Blink On
***
BlkOn               rts

************************************************************************
*** 1F 25 - Blink Off
***
BlkOff              rts

************************************************************************
*** 1F 30 - Insert Line
*** Opens a blank line (spaces in V.FBCol) at the cursor's row; that row
*** and the rows below move down one and the last row is lost.  The
*** cursor does not move.  grfdrv reads CurRow/WWidth/WHeight/TermLive
*** from the DSS, so this only guards, clamps and aims gr.* at this term.
***
InsLine             lda       V.WHeight,u
                    beq       ilx@                no rows
                    ldb       V.WWidth,u
                    beq       ilx@                no columns
                    lbsr      CalcCurPos          clamps V.CurRow below V.WHeight
                    lbsr      SetThisTermGrfPtrs  gr.TermBlk/VBlk/U5 for THIS term
                    ldb       #GF.InsLine
                    lbsr      CallGrfDrvNoPD      preserves U
ilx@                rts

************************************************************************
*** 1F 31 - Delete Line
*** Removes the cursor's row; the rows below move up one and the last
*** row's glyphs are blanked (its colours are left for the program to
*** rewrite).  The cursor does not move.
***
DelLine             lda       V.WHeight,u
                    beq       dlx@                no rows
                    ldb       V.WWidth,u
                    beq       dlx@                no columns (blank loop would run 256)
                    lbsr      CalcCurPos          clamps V.CurRow below V.WHeight
                    lda       V.CurRow,u
                    ldb       V.WWidth,u
                    mul
                    std       >gr.d1              start: CurRow,0
                    ldd       V.ScreenSize,u
                    std       >gr.d2              end: bottom of screen
                    lda       V.WWidth,u          A = width
                    lbsr      DoScroll
dlx@                rts

**********************************************************************
****************** End Code Handling Routines ************************
**********************************************************************



**********************************************************************
*                      GetStt Routines
**********************************************************************

**********************************************************************
* GetStat
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
****************************
* Get status entry point
* Entry: A=Function call #
*
GetStat             cmpa      #SS.EOF             is this the EOF call?
                    beq       SSEOF               yes, exit without error
                    ldx       PD.RGS,y            else get the pointer to caller's registers (all other calls require this)
                    cmpa      #SS.Ready           is this the data ready call? (keyboard buffer)
                    beq       SSReady             branch if so
* The rest are grfdrv's: GF.GetStt dispatches on the code in gr.b1 and
* leaves its results in gr.PDRGS, which CallGrfDrvRet copies back.
                    ldb       #GF.GetStt
                    bra       StatFwd

**********************************************************************
* SS.EOF    $06	
* SS.Ready  $01
*
* Tests for data available on SCF-supported devices.
*
* Entry:  A = The path number.
*         B = SS.Ready ($01)
*
* Exit:   B = The number of characters ready to read.
*        CC = Carry flag clear to indicate success.
*
* Error:  B = E$NotRdy if there are no bytes ready to read.
*        CC = Carry flag set to indicate error.
*
SSReady             lda       V.IBufH,u           else get get the buffer tail ptr
                    suba      V.IBufT,u           A = the number of characters ready to read
                    sta       R$B,x               save in the caller's B
                    beq       NotReady            if there's no data in keyboard buffer, return the "not ready" error
SSEOF               clrb                          clear the error code and carry
                    rts                           return
NotReady            comb                          set the carry
                    ldb       #E$NotRdy           load the "not ready" error
                    rts                           return


*
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
SetStat             ldx       PD.RGS,y            get caller's registers in X
                  IFGT    Level-1
                    cmpa      #SS.Open            path open (SCF); /vt factory here
                    beq       SSOpen
                  ENDC
                    cmpa      #SS.SSig            send signal on data ready?
                    lbeq      SSSig               yes, go process
                    cmpa      #SS.Relea           release signal on data ready?
                    lbeq      SSRelea             yes, go process
                    cmpa      #SS.WSig            signal on a visibility change?
                    lbeq      SSWSig              yes, go process
                    cmpa      #SS.Tone
                    lbeq      SSTone
                    cmpa      #SS.FntLoadF        blocks on file I/O, so not grfdrv's
                    lbeq      SSFntLoadF
* Everything else goes to grfdrv's GF.SetStt, and GetStat's remainder
* joins here with GF.GetStt.  The code travels in gr.b1, not R$B: SCF's
* own calls (SS.ComSt from CallComStatus) do not put it in the caller's
* B.  SetThisTermGrfPtrs clobbers D, so the op number waits on the stack.
                    ldb       #GF.SetStt
StatFwd             sta       >gr.b1              status code
                    pshs      b                   GF.GetStt or GF.SetStt
                    lbsr      SetThisTermGrfPtrs
                    puls      b
                    lbra      CallGrfDrvRet       results, B and carry back to the caller

                  IFGT    Level-1
* SS.Open — SCF calls this on every I$Open.
* Named (/term, /vt1../vt8): success (already InitTerm'd).
* Factory (/vt, IT.WND=$FF): F$SLink /vtN, InitTerm id 1-8, swap
* V$DESC, UnLink factory. Name at $12D8 (not $1200). Y = system
* DAT image; tosysproc so the module maps in system space.
* Never pass $FF into id*4. Slot 0 is /term; start at id 1.
SSOpen              ldx       PD.DEV,y
                    ldx       V$DESC,x
                    ldb       IT.WND,x
                    lbpl      SSOpenNamed
                    pshs      x,y,u
                    ldb       #1
SSOpenFind          cmpb      #G.TermMax
                    bhs       SSOpenNone
                    pshs      b
                    lda       #gr.TermSz
                    mul
                    ldx       #gr.TermTbl
                    leax      d,x
                    lda       T.Flags,x
                    bita      #T.Init
                    puls      b
                    beq       SSOpenGot
                    incb
                    bra       SSOpenFind
SSOpenNone          comb                          set carry first: comb after ldb turned 221 into 34
                    ldb       #E$MNF
                    puls      x,y,u,pc
SSOpenGot           lda       #'v
                    sta       $12D8
                    lda       #'t
                    sta       $12D9
                    tfr       b,a
                    adda      #$B0
                    sta       $12DA
                    pshs      b
                    leas      -2,s
                    lbsr      tosysproc
                    ldx       >D.SysPrc
                    leay      P$DATImg,x
                    ldx       #$12D8
                    lda       #Devic+Objct
                    os9       F$SLink
                    lbsr      toproc
                    leas      2,s
                    bcc       SSOpenLnk
                    puls      b
                    incb
                    bra       SSOpenFind
SSOpenLnk           pshs      u
                    ldb       2,s
                    ldu       7,s
                    lbsr      InitTerm
                    bcs       SSOpenITFail
                    puls      u
                    ldy       3,s
                    ldx       PD.DEV,y
                    stu       V$DESC,x
                    ldu       1,s
                    os9       F$UnLink
                    ldu       5,s
                    leas      7,s
                    clrb
                    andcc     #^Carry
                    rts
SSOpenITFail        puls      u
                    pshs      cc,b
                    os9       F$UnLink
                    puls      cc,b
                    leas      1,s
                    puls      x,y,u,pc
SSOpenNamed         clrb
                    andcc     #^Carry
                    rts
                  ENDC

SSTone              ldy       R$Y,x               check for 0-1023 range
                    cmpy      #1023
                    bgt       BadArgs
                    ldd       R$X,x               get vol, duration
                    cmpa      #15
                    bgt       BadArgs
                    lbra      BellTone            do it
 
BadArgs             comb                          Exit with Illegal Argument error
                    ldb       #E$IllArg
                    rts

* SS.SSig - send signal on data ready
SSSig               pshs      cc                  save interrupt status
                    lda       V.IBufH,u           get get the buffer tail ptr
                    suba      V.IBufT,u           A = the number of characters ready to read
                    pshs      a                   save it temporarily
                    bsr       GetCPR              get current process ID
                    tst       ,s+                 anything in buffer?
                    bne       SendSig             yes, go send the signal
                    std       <V.SSigID,u         save process ID & signal
                    puls      pc,cc               restore interrupts & return

GetCPR              orcc      #IntMasks           disable interrupts
                    lda       PD.CPR,y            get curr proc #
                    ldb       R$X+1,x             get user signal code
                    rts                           return

SendSig             puls      cc                  restore interrupts
                    os9       F$Send              send the signal
                    rts                           return

* SS.WSig ($E1) - signal me when this terminal's visibility changes.
*
* Entry: R$X MSB = the code to send when this terminal goes background
*        R$X LSB = the code to send when it comes forward
*        Either half 0 = do not signal that transition.  R$X = 0 both
*        halves, which is the natural "stop" value, deregisters.
*
* The registrant is the calling process.  One registrant per terminal
* (each terminal is its own device with its own static, so terminals do
* not interfere): a second caller gets E$DevBsy rather than stealing it,
* unless the process holding it has exited.
* A code below S$Window ($04) is accepted but is a poor choice - both
* vtios abort a blocked read on anything lower, so a game asleep in a
* read would be killed by its own notification.
SSWSig              ldd       R$X,x               A = background code, B = forward code
                    tsta                          both codes 0 = deregister
                    bne       reg@
                    tstb
                    bne       reg@
* Only the registrant may release it, so a stray call cannot cancel
* somebody else's registration.  Releasing one nobody holds is not an
* error - it is what a program's exit path does whether or not it ever
* registered.
                    lda       PD.CPR,y
                    cmpa      V.WSigID,u
                    bne       wsok@
                    clr       V.WSigID,u
                    clr       V.WSigBg,u
                    clr       V.WSigFg,u
wsok@               clrb
                    rts
* One registrant per terminal, and it is NOT taken silently: the loser of
* a silent overwrite would simply never be told again, with no error and
* no way to find out.  A registrant that has exited does not keep the
* terminal - D.PrcDBT[id] reads 0 once a process is gone, and its slot is
* taken over.
reg@                lda       V.WSigID,u
                    beq       take@               nobody holds it
                    cmpa      PD.CPR,y            ours already?  re-registering is fine
                    beq       take@
                    pshs      a,x
                    ldx       <D.PrcDBT           is that process still alive?
                    lda       a,x
                    tsta
                    puls      a,x                 (PULS does not touch CC)
                    beq       take@               no - the slot is free after all
                    comb
                    ldb       #E$DevBsy           yes - it is not ours to take
                    rts
take@               ldd       R$X,x
                    std       V.WSigBg,u
                    lda       PD.CPR,y            the calling process
                    sta       V.WSigID,u
                    clrb
                    rts

* SS.Relea - release a path from SS.SSig and from SS.WSig
SSRelea             lda       PD.CPR,y            get the current process ID
                    cmpa      V.WSigID,u         is it the visibility registrant?
                    bne       ckss@               branch if not
                    clr       V.WSigID,u         else clear the process ID
ckss@               cmpa      <V.SSigID,u         is it the same as the keyboard?
                    bne       ex@                 branch if not
                    clr       <V.SSigID,u         else clear process the ID
* cmpa leaves the carry set whenever A is below the stored id, which SCF
* reads as an error with a junk code.  Nothing ever noticed because the
* call is rare, but the exit has to be deliberate.
ex@                 clrb
                    rts

                    ifgt      Level-1
;;; SS.FntLoadF
;;;
;;; Load a font from a file.  File should be full path.
;;; Don't load module into memory, just read directly from file.
;;;
;;; Entry: R$X = pointer to font name
;;;        R$Y = font set 0 or 1
;;;
;;; Exit:  B = non-zero error code
;;;       CC = carry flag clear to indicate success

SSFntLoadF          ldy       R$Y,x
                    beq       font0@
font1@              ldy       #$800               FONT_1_OFFSET   $0800
                    bra       storeaddr@
font0@              ldy       #FONT_0_OFFSET      $0000
storeaddr@          pshs      y                   store font offset on stack [O]      
                    leas      -2,s                reserve 2 bytes on stack for mapped addr [MO]
* s= ADDR|OFFSET|                   
*                   ****      map block into user dat and store address on stack
                    pshs      x,u                 preserve x,u
                    ldx       #FONT_BLK           map in FONT_BLK
                    ldb       #$01                map 1 block at address x (x set on entry)
                    os9       F$MapBlk
                    bcc       mapgood@            if success, then continue
                    puls      x,u                 else: error
                    bra       error@
mapgood@            stu       4,s                 store mapped address on stack [XUMO]
                    puls      x,u                 restore x,u [MO]
*                   ****      open file to read             
endcopy@            ldx       R$X,x               pointer to file name in caller memory
                    lda       #READ.              READ access mode
                    os9       I$Open              
                    bcc       modulecheck@
                    bra       errormap@
* Verify that file is module.
* Load file's first two bytes onto the stack to verify and check for $87DC
modulecheck@        leas      -2,s                 add space to stack to store 2 bytes [DMO]
                    leax      ,s                   load x with stack address
                    bsr       Rd2B2Mem
                    puls      x                    load x with the data [MO]
                    cmpx      #$87CD               check if module
                    bcc       getstart@            if module, get start of data
                    ldb       #3
                    bra       errorclose@          else, error
* Module header byte $09-0A = Execution Offset.
* This is the start of the data in a data module
getstart@           pshs      u                    seek to data start address in file [UMO]
                    ldx       #$00                 set high byte addr
                    ldu       #$09                 set low byte
                    os9       I$Seek
                    bcc       readaddr@            if success, read font
                    puls      u                    else error  [MO]
                    ldb       #4
                    bra       errorclose@
* s= u|addr|offset                  
readaddr@           leas      -2,s                 add 2 bytes stack storage [DUMO]
                    leax      ,s                   use the 2 bytes in stack to store addr
                    bsr       Rd2B2Mem             read 2 bytes from file
                    bcc       seekaddr@            if success, seek to data address
                    leas      4,s                  else: clean stack and error [MO]
                    bra       errorclose@
* s= addr|u|addr|offset             
seekaddr@           puls      u                    load u with low byte addr [UMO]
* s= u|addr|offset
                    ldx       #0                   load x high byte
                    os9       I$Seek
                    puls      u                    restore u [MO]
* s=addr|offset             
*                   ldx       ,s                   ldx with mapblock address
                    pshs      a                    store path# on stack [AMO]
                    ldd       1,s                  put offset in d
                    addd      3,s
                    tfr       d,x
*                   leax      d,x                  add offset to x
                    puls      a                    restore path# [MO]
                    ldy       #$800                read 2K of font data into it
                    os9       I$Read               a=path x=addr y=#bytes
errorclose@         pshs      b                    [BMO]
                    os9       I$Close              close the file
                    puls      b                    [MO]
errormap@           ldu       ,s
                    pshs      b
                    ldb       #$01
                    os9       F$ClrBlk             Clear block from user space
                    puls      b
error@              leas      4,s                  clear stack
                    tstb
                    beq       quit@
                    coma
quit@               rts
                    

;;; Rd2B2Mem
;;; Read 2 bytes to addr
;;;
;;; Entry:  A = path #
;;;         X = memory address to read to
;;;
;;; Exit:   B = a non-zero error code (F$MapBlk)
;;;        CC = carry flag clear=success set=error
;;;
;;; I$Read reads data into the current process in D.Proc
;;; To use I$Read for the system, assign system to D.Proc
;;; Call I$Read, then change the processes back
;;; Make sure to mask interrupts so processes don't switch while
;;; the change is happening
;;;
Rd2B2Mem            pshs      cc                  push cc and mask interrupts
                    orcc      #IntMasks
                    ldy       <D.Proc             ldy with current process descriptor
                    pshs      y                   store current proc descriptor on stack
                    ldy       <D.SysPrc           copy system proc descriptor to current
                    sty       <D.Proc
                    ldy       #$02                read 2 bytes from file 
                    os9       I$Read
                    puls      y                   pull current proc descriptor from stack
                    sty       <D.Proc             and save it back
                    bcs       errnomap@           if I$Read error, then handle error
                    puls      cc,pc               if no error, pull cc and return
errnomap@           puls      cc                  if error, pull cc
                    coma                          set carry bit
                    rts                           and return

                    
                    endc


                    emod
eom                 equ       *
                    end
