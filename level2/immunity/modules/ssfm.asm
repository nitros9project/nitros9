********************************************************************
* ssfm.asm - V9958 (SuperSprite-FM+) screens inside CoVDG
*
* DRAFT: lwasm syntax, NOT assembled, NOT tested.
*
* Included at the end of covdg.asm when assembled with -DSSFM=1. VTIO
* links a module named CoVDG for every device whose parity byte has bit 7
* clear, so a V9958 screen has to be a "personality" of CoVDG. The
* descriptor of a V9958 screen sets bit 6 of its parity byte (V.TYPE),
* and bit 5 for 80 columns (40 otherwise). The hooks in covdg.asm test
* that bit at Init, Term, Write, GetStat, SetStat and the select entry.
*
* SSFM=1: one extra V9958 screen (/V9, page 0) next to the VDG consoles.
* SSFM=2: every VDG-type console (/Term and /V1../V7) is a V9958 screen,
* in its own VRAM page, n*$2000 with n = 0 for /Term and 1-7 for /V1-/V7.
* All screens share one geometry, V9COLS (40 or 80), because the VDP has a
* single mode. The VDG keeps running (it still drives the clock); only the
* picture is routed away.
*
* A V9958 text screen uses none of the VDG graphics statics, so the few
* variables it needs live in unused VD.* fields.
********************************************************************

V9.Cols             equ       VD.Col    40 or 80 (also what SS.ScSiz returns)
V9.CurX             equ       VD.GCrsX  cursor column, 0-based
V9.CurY             equ       VD.GCrsY  cursor row, 0-based
V9.CurSv            equ       VD.CChar  screen code hidden under the cursor
V9.CurOn            equ       VD.CColr  0 = cursor off
V9.VNest            equ       VD.FFFlg  VdpOpen nesting depth
V9.SvCC             equ       VD.FF1    interrupt masks at the outer VdpOpen
V9.SvSlot           equ       VD.FF2    MPI slot at the outer VdpOpen (SLOTSW=1)
V9.Base             equ       VD.FFMem  2 bytes: VRAM address of this screen's page
V9.Page             equ       VD.FFSPt  screen number 0-7
V9.R7               equ       VD.Msk1   R#7: text colour (high nibble) / background
V9.Attr             equ       VD.Msk2   text attributes: $80 = reverse video, else 0
V9.Alt              equ       VD.MCol   1 = characters are flagged (alternate colours)
V9.AltUsed          equ       VD.MCol2  1 = some cell of the screen may be flagged
V9.R12              equ       VD.PMask  R#12: alternate text / background colours
V9.St               equ       VD.FF6    escape-sequence state, see V9Swallow
V9.Skip             equ       VD.FFSTp  2 bytes: parameter bytes still to swallow

* Working area, device window and scratch (VD.Palet is 16 unused bytes,
* VD.HR2 / VD.HR3 / VD.MTabl / VD.PixBt are unused too). Coordinates are
* screen cells.
V9.AX               equ       VD.Palet  working area: column, row, width, height
V9.AY               equ       VD.Palet+1
V9.AW               equ       VD.Palet+2
V9.AH               equ       VD.Palet+3
V9.DX               equ       VD.Palet+4 device window: column, row, width, height
V9.DY               equ       VD.Palet+5
V9.DW               equ       VD.Palet+6
V9.DH               equ       VD.Palet+7
V9.OvTop            equ       VD.Palet+8 2 bytes: top overlay record in VRAM (0 = none)
V9.BAl              equ       VD.Palet+10 1 = area aligned to 8 columns (flags movable)
V9.NX               equ       VD.Palet+11 new area being set: column, row, width, height
V9.NY               equ       VD.Palet+12
V9.NW               equ       VD.Palet+13
V9.NH               equ       VD.Palet+14
V9.Err              equ       VD.PlFlg  error code to return with the last byte of a command
V9.WX               equ       VD.SBAdd  current window (device window or top overlay):
V9.WY               equ       VD.SBAdd+1 column, row, width, height
V9.WW               equ       VD.AGBuf
V9.WH               equ       VD.AGBuf+1
V9.OvEnd            equ       VD.MTabl  2 bytes: first free byte of the overlay save area
V9.Sv               equ       VD.HiRes  save switch of the OWSet being read
V9.Hi               equ       VD.Blk    address bit 16 for VdpSetWr/Rd (4 or 0)
V9.SHi              equ       VD.GBuff  ditto for VdpChunk's source
V9.DHi              equ       VD.NBlk   ditto for VdpChunk's destination
V9.RMode            equ       VD.Mode   rectangle transfer: 0 save, 1 restore
V9.RRow             equ       VD.Chr1
V9.RPtr             equ       VD.ScrnA  2 bytes: save-area pointer for the cells
V9.RFPtr            equ       VD.ScrnE  2 bytes: ... for the flag bytes
V9.RFl              equ       VD.Alpha  1 = flag bytes are transferred too
V9.CwClr            equ       VD.TFlg1  1 = CWArea clears the whole window
V9.T1               equ       VD.HR2    scratch, 2 bytes
V9.T2               equ       VD.HR3    scratch, 2 bytes
V9.T4               equ       VD.PixBt  scratch, 1 byte

                  IFEQ    SSFM-2
V9ALL               equ       1         every console is a V9958 screen
                  ELSE
V9ALL               equ       0
                  ENDC

                    IFNDEF    SSFMDBG
SSFMDBG             equ       0         1 = route the monitor to the V9958 at INIZ /V9
                  ENDC

                    use       vdp9958.asm

********************************************************************
* Init - entered from the hook at the top of CoVDG's Init, with
* U,Y,X already pushed (we return through them).
********************************************************************
V9Init
                  IFNE    V9ALL
                    lda       #V9COLS   ; one geometry for all screens (build option)
                  ELSE
                    ldb       <V.TYPE,u
                    lda       #40
                    bitb      #$20
                    beq       V9I1
                    lda       #80
V9I1
                  ENDC
                    sta       <V9.Cols,u
                    lda       #V9COL
                    sta       <V9.R7,u  ; default text / background colours
                    lda       #V9ALT
                    sta       <V9.R12,u ; default alternate colours
                    lda       #V9CWCLR
                    sta       <V9.CwClr,u
                    lda       <V9.Cols,u
                    sta       <V9.AW,u  ; the working area and the device window are
                    sta       <V9.DW,u  ; the whole screen
                    sta       <V9.WW,u
                    lda       #V9ROWS
                    sta       <V9.AH,u
                    sta       <V9.DH,u
                    sta       <V9.WH,u
                    lda       #1
                    sta       <V9.BAl,u
                  IFNE    V9ALL
                    lda       <V.PORT+1,u ; device address low byte: $C0 = /Term,
                    suba      #A.TermV&$FF ; $C1-$C7 = /V1-/V7
                    anda      #7
                    sta       <V9.Page,u ; screen number
                    asla
                    asla
                    asla
                    asla
                    asla                ; n*32 = high byte of n*$2000
                    clrb
                    std       <V9.Base,u
                  ENDC
                    ldd       <V9.Base,u
                    addd      #16
                    std       <V9.OvEnd,u ; first record of the overlay save area
                    lda       #V9ROWS
                    sta       <VD.Row,u
                    lda       #1
                    sta       <VD.Rdy,u ; device ready
*                               VD.Start (= V.InfVld) is set at SS.Open, not
*                               here: see V9SetStat
                    sta       <V9.CurOn,u ; cursor on
                    leax      <VD.NChar,u ; where VTIO stores parameter bytes
                    stx       <VD.EPlt1,u
                    stx       <VD.EPlt2,u
                  IFNE    V9ALL
                    tst       <V9.Page,u
                    bne       V9I2
                    lbsr      VdpInitMode ; first screen (/Term): program the VDP once
                    lbsr      VdpInitPage
                    lbsr      VdpShow   ; and show it, so the console is visible
                    bra       V9I3
V9I2                lbsr      VdpInitPage ; other screens: only their own page
V9I3
                  ELSE
                    lbsr      VdpInitMode
                    lbsr      VdpInitPage
                  IFNE    SSFMDBG
                    lbsr      VdpShow   ; debug: show the V9958 right away
                  ENDC
                  ENDC
                    ldu       <D.CCMem  ; global memory
                    ldb       <G.BCFFlg,u
                    orb       #$02      ; flag VDGINT found, as CoVDG's Init does
                    stb       <G.BCFFlg,u
                    clrb
                    puls      pc,u,y,x

* Term - entered with U,Y,X pushed; ClrStat clears the statics and returns
V9Term
                    clr       <VD.Start,u ; no screen in use (CoVDG's Term does the same)
                    lbra      ClrStat

* Select entry (A = function code). 0 = this screen becomes the active
* one: point the VDP at its page and route the monitor to the V9958.
* Nothing else applies to a text screen (1 = update mouse packet).
V9Spec
                    tsta
                    bne       V9Sp9
                    lbsr      VdpOpen
                    lbsr      VdpSelPage
                    lbsr      VdpClose
                    lbsr      VdpShow
V9Sp9               clrb
                    rts

********************************************************************
* Write - A = character. VTIO has already gathered the parameter bytes
* of $02 (2), $05 and $1B (1) before calling here.
********************************************************************
V9Write
                    cmpa      #$20
                    blo       V9Ctl
                    lbsr      VdpPutChar
                    clrb
                    rts

V9Ctl               leax      V9Tbl,pcr
                    lsla
                    ldd       a,x
                    jmp       d,x

V9Tbl               fdb       V9Nop-V9Tbl $00
                    fdb       V9Home-V9Tbl $01 home cursor
                    fdb       V9XY-V9Tbl $02 move cursor
                    fdb       V9DelL-V9Tbl $03 delete line
                    fdb       V9EOL-V9Tbl $04 erase to end of line
                    fdb       V9Crsr-V9Tbl $05 cursor on/off
                    fdb       V9Right-V9Tbl $06
                    fdb       V9Nop-V9Tbl $07 bell (VTIO)
                    fdb       V9Left-V9Tbl $08
                    fdb       V9Up-V9Tbl $09
                    fdb       V9Down-V9Tbl $0A
                    fdb       V9EOS-V9Tbl $0B erase to end of screen
                    fdb       V9Cls-V9Tbl $0C clear screen
                    fdb       V9CR-V9Tbl $0D
                    fdb       V9Nop-V9Tbl $0E-$1A: graphics codes, not supported
                    fdb       V9Nop-V9Tbl
                    fdb       V9Nop-V9Tbl
                    fdb       V9Nop-V9Tbl
                    fdb       V9Nop-V9Tbl
                    fdb       V9Nop-V9Tbl
                    fdb       V9Nop-V9Tbl
                    fdb       V9Nop-V9Tbl
                    fdb       V9Nop-V9Tbl
                    fdb       V9Nop-V9Tbl
                    fdb       V9Nop-V9Tbl
                    fdb       V9Nop-V9Tbl
                    fdb       V9Nop-V9Tbl
                    fdb       V9Esc-V9Tbl $1B escape
                    fdb       V9Nop-V9Tbl $1C-$1E
                    fdb       V9Nop-V9Tbl
                    fdb       V9Nop-V9Tbl
                    fdb       V9Attr-V9Tbl $1F attributes (VTIO has gathered the byte)

V9Nop               clrb
                    rts

V9Run               lbsr      VdpDo
                    clrb
                    rts

V9Home              leay      OpHome,pcr
                    bra       V9Run
V9DelL              leay      OpDelLine,pcr
                    bra       V9Run
V9EOL               leay      OpEraseEOL,pcr
                    lbra      V9Run
V9Right             leay      OpRight,pcr
                    lbra      V9Run
V9Left              leay      OpLeft,pcr
                    lbra      V9Run
V9Up                leay      OpUp,pcr
                    lbra      V9Run
V9Down              leay      OpDown,pcr
                    lbra      V9Run
V9EOS               leay      OpEraseEOS,pcr
                    lbra      V9Run
V9Cls               leay      OpCls,pcr
                    lbra      V9Run
V9CR                leay      OpCR,pcr
                    lbra      V9Run

* $02 col row: VTIO gathers the two bytes (ASCII + $20) into VD.NChar and
* VD.NChr2 and calls V9DoXY through the vector set by GChar.
V9XY                ldb       #2
                    leax      V9DoXY,pcr
                    lbra      GChar

V9DoXY              ldb       <VD.NChr2,u ; row
                    subb      #$20
                    lda       <VD.NChar,u ; column
                    suba      #$20
                    leay      OpGoto,pcr
                    lbra      V9Run

* $05 x: cursor off (x = $20) or on (anything else)
V9Crsr              lda       <VD.NChar,u
                    suba      #$20
                    sta       <V9.CurOn,u
                    leay      OpNone,pcr
                    lbra      V9Run

********************************************************************
* $1F x: VTIO has gathered x into VD.NChar. $20 turns reverse video on,
* $21 off. $24 flags the characters printed from now on (alternate colours
* or blink, 80 columns only), $25 stops. $30 inserts a line, $31 deletes
* one. Underline ($22, $23) is accepted and ignored.
********************************************************************
V9Attr              lda       <VD.NChar,u
                    cmpa      #$20
                    beq       V9RevOn
                    cmpa      #$21
                    beq       V9RevOff
                    cmpa      #$24
                    beq       V9AltOn
                    cmpa      #$25
                    beq       V9AltOff
                    cmpa      #$30
                    beq       V9Ins
                    cmpa      #$31
                    lbne      V9Nop
                    leay      OpDelLn,pcr
                    lbra      V9Run
V9Ins               leay      OpInsLn,pcr
                    lbra      V9Run
V9AltOn             lda       #1
                    sta       <V9.Alt,u
                    sta       <V9.AltUsed,u
                    clrb
                    rts
V9AltOff
                    clr       <V9.Alt,u
                    clrb
                    rts
V9RevOn             lda       #$80
                    sta       <V9.Attr,u
                    clrb
                    rts
V9RevOff
                    clr       <V9.Attr,u
                    clrb
                    rts

********************************************************************
* $1B x ...: VTIO has gathered x (the command) into VD.NChar; the rest
* of the parameters have to be requested with GChar. GChar's buffer holds
* two bytes, so longer parameter lists are swallowed two bytes at a time
* by V9Swallow, without storing them.
*
* Honoured: $20 DWSet (area and colours), $21 Select, $22 OWSet, $23 OWEnd,
*   $25 CWArea,
*   $30 DefColr, $31 Palette, $32 FColor, $33 BColor.
* Private commands (not in the manual; $28, $37, $38, $3B and $3E are
* unused there), parameters are raw bytes (no +$20 offset):
*   $1B $28 n          CWArea clears the whole window (n <> 0)
*   $1B $3E reg val    writes a VDP register
*   $1B $3B hi lo val  writes a VRAM byte
*   $1B $38 hi lo      prints the VRAM byte at $hilo as two hex digits
*   $1B $37            prints Alt, AltUsed, Cols, Page and Attr (hex)
* Accepted without effect, so their bytes are not printed: all the others
* listed in V9EscTab (border colour, windows, working area, buffers,
* fonts, drawing, ...).
********************************************************************
V9Esc               lda       <VD.NChar,u
                    cmpa      #$20
                    lbeq      V9DWSet
                    cmpa      #$21
                    lbeq      L0209     ; coVDG's Select code, with A = $21
                    cmpa      #$22
                    lbeq      V9OWSet
                    cmpa      #$23
                    lbeq      V9OWEnd
                    cmpa      #$25
                    lbeq      V9CWArea
                    cmpa      #$28
                    lbeq      V9CwClrCmd
                    cmpa      #$2B
                    lbeq      V9GPLoad
                    cmpa      #$30
                    lbeq      V9DefCol
                    cmpa      #$31
                    lbeq      V9Palette
                    cmpa      #$32
                    lbeq      V9FColor
                    cmpa      #$33
                    lbeq      V9BColor
                    cmpa      #$37
                    lbeq      V9Stat
                    cmpa      #$38
                    lbeq      V9VDump
                    cmpa      #$3B
                    lbeq      V9VPoke
                    cmpa      #$3E
                    lbeq      V9RPoke
                    cmpa      #$20
                    lblo      V9Nop
                    cmpa      #$52
                    lbhi      V9Nop
                    suba      #$20
                    leax      V9EscTab,pcr
                    ldb       a,x       ; number of parameter bytes
                    lbeq      V9Nop
                    clra
                    clr       <V9.St,u
                    lbra      V9Swallow

* Number of parameter bytes of $1B $20 ... $1B $52 (from the NitrOS-9
* windowing manual). $2B (GPLoad) is variable and handled separately.
V9EscTab
                    fcb       8,0,7,0,0,4,0,0 ; $20-$27
                    fcb       0,4,2,0,10,6,2,1 ; $28-$2F
                    fcb       0,2,1,1,1,1,1,0 ; $30-$37
                    fcb       0,2,2,0,1,1,0,1 ; $38-$3F
                    fcb       4,4,4,4,4,4,4,4 ; $40-$47
                    fcb       4,4,4,4,0,0,4,0 ; $48-$4F
                    fcb       2,4,12    ; $50-$52

********************************************************************
* V9Swallow - swallow D parameter bytes (they have to arrive before the
* next command), two at a time because GChar's buffer holds two bytes.
* V9.St says what follows when they are all in:
*   0 nothing, 1 DWSet: read the two colour bytes, 2 GPLoad: read the
*   two length bytes and swallow that many.
********************************************************************
V9Swallow
                    std       <V9.Skip,u
V9SwLp              ldd       <V9.Skip,u
                    lbeq      V9SwEnd
                    cmpd      #2
                    blo       V9Sw1
                    ldb       #2
                    bra       V9SwG
V9Sw1               ldb       #1
V9SwG               pshs      b
                    ldd       <V9.Skip,u
                    subb      ,s
                    sbca      #0
                    std       <V9.Skip,u
                    puls      b
                    leax      V9SwNext,pcr
                    lbra      GChar     ; gather B bytes, then continue at V9SwNext

V9SwNext
                    lbra      V9SwLp

V9SwEnd             lda       <V9.St,u
                    lbeq      V9SwFin   ; plain swallow finished
                    cmpa      #1
                    beq       V9SwDW
                    ldb       #2        ; gpload: the length bytes
                    leax      V9GpLen,pcr
                    lbra      GChar
V9SwDW              ldb       #2        ; dwset: PRN1 and PRN2
                    leax      V9DwCol,pcr
                    lbra      GChar

* End of a command: return the error code left in V9.Err (illegal window
* definition for DWSet, illegal coordinates or no memory for OWSet), if any.
V9SwFin             ldb       <V9.Err,u
                    lbeq      V9Nop
                    clr       <V9.Err,u
                    orcc      #1        ; carry set, B = the error code
                    rts

* $1B $20 STY CPX CPY SZX SZY PRN1 PRN2 PRN3: the rectangle CPX,CPY,SZX,SZY
* becomes the device window and the working area (cleared, cursor at its
* top left). STY is ignored (every screen is a text page). A rectangle that
* does not fit on the screen is ignored. PRN1 and PRN2 set the colours.
V9DWSet             ldb       #1        ; sty
                    leax      V9Dw1,pcr
                    lbra      GChar

V9Dw1               ldb       #2        ; cpx CPY
                    leax      V9Dw2,pcr
                    lbra      GChar

V9Dw2               ldd       <VD.NChar,u
                    std       <V9.NX,u
                    ldb       #2        ; szx SZY
                    leax      V9Dw3,pcr
                    lbra      GChar

V9Dw3               ldd       <VD.NChar,u
                    std       <V9.NW,u
                    lda       <V9.NW,u
                    beq       V9Dw3e
                    lda       <V9.NH,u
                    beq       V9Dw3e
                    lda       <V9.NX,u
                    adda      <V9.NW,u
                    bcs       V9Dw3e
                    cmpa      <V9.Cols,u
                    bhi       V9Dw3e
                    lda       <V9.NY,u
                    adda      <V9.NH,u
                    bcs       V9Dw3e
                    cmpa      #V9ROWS
                    bhi       V9Dw3e
                    leay      OpSetDW,pcr
                    lbsr      VdpDo
                    bra       V9Dw4
V9Dw3e              lda       #E$IWDef  ; invalid: the error is returned with the last
                    sta       <V9.Err,u ; byte of the command
V9Dw4               lbsr      V9SetPag
                    ldb       #2        ; prn1 PRN2
                    leax      V9DwCol,pcr
                    lbra      GChar

* $1B $28 n (private): n <> 0: CWArea clears the whole window,
* n = 0: it leaves the text as it is (CoWin's behaviour).
V9CwClrCmd
                    ldb       #1
                    leax      V9CwC1,pcr
                    lbra      GChar
V9CwC1              lda       <VD.NChar,u
                    beq       V9CwC2
                    lda       #1
V9CwC2              sta       <V9.CwClr,u
                    clrb
                    rts

* $1B $25 CPX CPY SZX SZY (CWArea): the working area becomes this rectangle,
* relative to the current window (the device window or the top overlay);
* cursor to its top left. An empty rectangle, or one outside the window, is
* an illegal window definition
* (error returned, nothing changed). The same for a DWSet that does not fit
* on the screen.
V9CWArea
                    ldb       #2
                    leax      V9Cw1,pcr
                    lbra      GChar

V9Cw1               ldd       <VD.NChar,u
                    std       <V9.NX,u
                    ldb       #2
                    leax      V9Cw2,pcr
                    lbra      GChar

V9Cw2               ldd       <VD.NChar,u
                    std       <V9.NW,u
                    lda       <V9.NW,u
                    beq       V9Cw8
                    lda       <V9.NH,u
                    beq       V9Cw8
                    lda       <V9.NX,u
                    adda      <V9.NW,u
                    bcs       V9Cw8
                    cmpa      <V9.WW,u
                    bhi       V9Cw8
                    lda       <V9.NY,u
                    adda      <V9.NH,u
                    bcs       V9Cw8
                    cmpa      <V9.WH,u
                    bhi       V9Cw8
                    leay      OpSetCW,pcr
                    lbsr      VdpDo
                    lbsr      V9SetPag
                    clrb
                    rts
V9Cw8               comb                ; illegal window definition (the rectangle is
                    ldb       #E$IWDef  ; empty or outside the device window)
                    rts

* $1B $22 SVS CPX CPY SZX SZY PRN1 PRN2 (OWSet): open an overlay window on
* the rectangle CPX,CPY,SZX,SZY, relative to the device window. With SVS <> 0
* the area under it is saved and the overlay cleared; with SVS = 0 neither.
* PRN1 and PRN2 are ignored: an overlay uses its parent's colours. Illegal
* coordinates, or no room left to save the area, are returned as errors.
V9OWSet             ldb       #1        ; svs
                    leax      V9Ow1,pcr
                    lbra      GChar

V9Ow1               lda       <VD.NChar,u
                    sta       <V9.Sv,u
                    ldb       #2        ; cpx CPY
                    leax      V9Ow2,pcr
                    lbra      GChar

V9Ow2               ldd       <VD.NChar,u
                    std       <V9.NX,u
                    ldb       #2        ; szx SZY
                    leax      V9Ow3,pcr
                    lbra      GChar

V9Ow3               ldd       <VD.NChar,u
                    std       <V9.NW,u
                    lda       <V9.NW,u
                    beq       V9Ow3e
                    lda       <V9.NH,u
                    beq       V9Ow3e
                    lda       <V9.NX,u
                    adda      <V9.NW,u
                    bcs       V9Ow3e
                    cmpa      <V9.DW,u
                    bhi       V9Ow3e
                    lda       <V9.NY,u
                    adda      <V9.NH,u
                    bcs       V9Ow3e
                    cmpa      <V9.DH,u
                    bhi       V9Ow3e
                    leay      OpOvSet,pcr
                    lbsr      VdpDo
                    lbsr      V9SetPag
                    bra       V9Ow4
V9Ow3e              lda       #E$ICoord
                    sta       <V9.Err,u
V9Ow4               ldb       #2        ; prn1 PRN2 (ignored)
                    leax      V9OwCol,pcr
                    lbra      GChar

V9OwCol             lbra      V9SwFin

* $1B $23 (OWEnd): close the top overlay window. Illegal window definition
* if there is none (the current window is the device window).
V9OWEnd             ldd       <V9.OvTop,u
                    beq       V9Oe8
                    leay      OpOvEnd,pcr
                    lbsr      VdpDo
                    lbsr      V9SetPag
                    clrb
                    rts
V9Oe8               comb
                    ldb       #E$IWDef
                    rts

* V9SetPag: SCF pauses output every PD.PAG lines, counting down V.LINE.
* After the area's height changes, set both to it for this device, and
* for every path open on it, as CoWin does.
V9SetPag
                    lda       <V9.AH,u
                    sta       V.LINE,u
                    ldx       V.PDLHd,u
V9Pg1               beq       V9Pg9
                    sta       PD.PAG,x
                    ldx       PD.PLP,x
                    bra       V9Pg1
V9Pg9               rts

V9DwCol             ldd       <VD.NChar,u ; a = foreground, B = background (palette #)
                    anda      #$0F
                  IFNE    V9FG0
                    bne       V9Fa
                    lda       #8        ; foreground 0 -> entry 8
V9Fa
                  ENDC
                    asla
                    asla
                    asla
                    asla
                    andb      #$0F
                    pshs      b
                    ora       ,s+
                    sta       <V9.R7,u
                    lbsr      V9ApplyR7
                    clr       <V9.St,u
                    ldd       #1        ; prn3 (border): swallow
                    lbra      V9Swallow

* $1B $2B GRP BFN STY HSX LSX HSY LSY HBL LBL data...: swallowed
V9GPLoad
                    lda       #2
                    sta       <V9.St,u
                    ldd       #7
                    lbra      V9Swallow

V9GpLen             clr       <V9.St,u
                    ldd       <VD.NChar,u ; hbl:LBL = number of data bytes
                    lbra      V9Swallow

* $1B $30: default palette
V9DefCol
                    lbsr      VdpOpen
                    lbsr      VdpPalette
                    lbsr      VdpClose
                    clrb
                    rts

* $1B $31 PRN CTN: palette register PRN := CoCo 3 colour CTN
V9Palette
                    ldb       #2
                    leax      V9DoPal,pcr
                    lbra      GChar

V9DoPal             ldd       <VD.NChar,u
                    lbsr      VdpOpen
                    lbsr      VdpSetPal
                  IFNE    V9FG0
                    anda      #$0F
                    bne       V9Dp9
                    lda       #8        ; entry 8 follows entry 0 (see V9FG0)
                    lbsr      VdpSetPal
V9Dp9
                  ENDC
                    lbsr      VdpClose
                    clrb
                    rts

* $1B $32 PRN: foreground colour, $1B $33 PRN: background colour. They
* are per screen (R#7); the border ($1B $34) follows the background, so
* it is accepted and ignored.
V9FColor
                    ldb       #1
                    leax      V9DoFC,pcr
                    lbra      GChar

V9BColor
                    ldb       #1
                    leax      V9DoBC,pcr
                    lbra      GChar

V9DoFC              tst       <V9.Alt,u
                    lbne      V9DoFA
                    ldb       <VD.NChar,u
                    andb      #$0F
                  IFNE    V9FG0
                    bne       V9Fb
                    ldb       #8
V9Fb
                  ENDC
                    aslb
                    aslb
                    aslb
                    aslb
                    lda       <V9.R7,u
                    anda      #$0F
                    pshs      b
                    ora       ,s+
                    sta       <V9.R7,u
                    lbra      V9ApplyR7

V9DoBC              tst       <V9.Alt,u
                    lbne      V9DoBA
                    lda       <VD.NChar,u
                    anda      #$0F
                    ldb       <V9.R7,u
                    andb      #$F0
                    pshs      b
                    ora       ,s+
                    sta       <V9.R7,u
                    lbra      V9ApplyR7

* $1B $3E RR VV (debugging): VDP register RR := VV. A wrong value can
* blank or scramble the display; select the screen again (CLEAR) to get
* R#2, R#3, R#7 and R#10 back.
V9RPoke             ldb       #2
                    leax      V9RP1,pcr
                    lbra      GChar

V9RP1               ldd       <VD.NChar,u ; a = register, B = value
                    exg       a,b       ; a = value, B = register
                    andb      #$3F
                    lbsr      VdpOpen
                    lbsr      VdpReg
                    lbsr      VdpClose
                    clrb
                    rts

* $1B $37 (debugging): prints five state bytes of this screen in hex
V9Stat              lda       <V9.Alt,u
                    lbsr      V9Hex
                    lda       <V9.AltUsed,u
                    lbsr      V9Hex
                    lda       <V9.Cols,u
                    lbsr      V9Hex
                    lda       <V9.Page,u
                    lbsr      V9Hex
                    lda       <V9.Attr,u
                    lbsr      V9Hex
                    clrb
                    rts

* $1B $38 HH LL (debugging): print the VRAM byte at $HHLL in hex
V9VDump             ldb       #2
                    leax      V9VD1,pcr
                    lbra      GChar

V9VD1               ldx       <VD.NChar,u ; the two bytes HH,LL form the address
                    lbsr      VdpOpen
                    lbsr      VdpGetAt
                    lbsr      VdpClose
                    lbsr      V9Hex
                    clrb
                    rts

* V9Hex: print A as two hex digits at the cursor
V9Hex               pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    lbsr      V9Nib
                    puls      a
                    anda      #$0F
V9Nib               adda      #$30
                    cmpa      #$39
                    bls       V9Nb1
                    adda      #7
V9Nb1               lbra      VdpPutChar

* $1B $3B HH LL VV (debugging): VRAM byte at $HHLL := VV (A16 = 0)
V9VPoke             ldb       #2
                    leax      V9VP1,pcr
                    lbra      GChar

V9VP1               ldd       <VD.NChar,u ; hh:LL
                    std       <V9.Skip,u ; keep the address while the value arrives
                    ldb       #1
                    leax      V9VP2,pcr
                    lbra      GChar

V9VP2               lda       <VD.NChar,u ; value
                    ldx       <V9.Skip,u
                    lbsr      VdpOpen
                    lbsr      VdpPutAt
                    lbsr      VdpClose
                    clrb
                    rts

* The same two commands while the flag is on ($1F $24): they set the
* foreground or background of the alternate pair (R#12).
V9DoFA              ldb       <VD.NChar,u
                    andb      #$0F
                  IFNE    V9FG0
                    bne       V9Fc
                    ldb       #8
V9Fc
                  ENDC
                    aslb
                    aslb
                    aslb
                    aslb
                    lda       <V9.R12,u
                    anda      #$0F
                    pshs      b
                    ora       ,s+
                    sta       <V9.R12,u
                    lbra      V9ApplyR7

V9DoBA              lda       <VD.NChar,u
                    anda      #$0F
                    ldb       <V9.R12,u
                    andb      #$F0
                    pshs      b
                    ora       ,s+
                    sta       <V9.R12,u
                    lbra      V9ApplyR7

* Write R#7 now if this screen is the displayed one; otherwise it is
* written when the screen is selected.
V9ApplyR7
                    tst       >WGlobal+G.CrDvFl
                    beq       V9Ar9
                    lbsr      VdpOpen
                    lda       <V9.R7,u
                    ldb       #7
                    lbsr      VdpReg
                    lda       <V9.R12,u
                    ldb       #12
                    lbsr      VdpReg
                    lbsr      VdpClose
V9Ar9               clrb
                    rts

********************************************************************
* GetStat - A = function code
********************************************************************
V9GetStat
                    ldx       PD.RGS,y
                    cmpa      #SS.ScSiz
                    beq       V9ScSiz
                    cmpa      #SS.Cursr
                    lbeq      V9Cursr
                    comb
                    ldb       #E$UnkSvc
                    rts

V9ScSiz             clra
                    ldb       <V9.AW,u
                    std       R$X,x
                    clra
                    ldb       <V9.AH,u
                    std       R$Y,x
                    clrb
                    rts

V9Cursr             clra
                    ldb       <V9.CurX,u
                    addb      #$20
                    std       R$X,x
                    clra
                    ldb       <V9.CurY,u
                    addb      #$20
                    std       R$Y,x
                    lda       <V9.CurSv,u
                    adda      #$20      ; screen code back to ASCII
                    sta       R$A,x
                    clrb
                    rts

********************************************************************
* SetStat - A = function code. SS.Open marks the device as selectable by
* CLEAR. SS.ComSt (xmode/tmode) is accepted and ignored, since this screen
* always has true lower case.
********************************************************************
V9SetStat
                    cmpa      #SS.Open
                    beq       V9SSOp
                    cmpa      #SS.ComSt
                    beq       V9SS9
                    comb
                    ldb       #E$UnkSvc
                    rts
* SS.Open: VTIO has just replaced V.PORT by the device table entry, which
* its CLEAR search relies on. V.InfVld (= VD.Start) tells CLEAR that a
* device may be selected, so it is set here and not at Init: a device that
* was only INIZed has no valid V.PORT and selecting it hangs the machine.
V9SSOp              lda       #1
                    sta       <VD.Start,u
                    lda       <V9.AH,u
                    sta       PD.PAG,y  ; the new path pauses every AH lines
                    lbsr      V9SetPag
V9SS9               clrb
                    rts
