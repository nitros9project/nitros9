*******************************************************************
* GrfDrv256 - Graphics Driver for F256
*******************************************************************
                    nam       GrfDrv256
                    ttl       Wild 256 Graphics Driver

                    use       defsfile
                    use       wildbits_vtio.d


tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,entry,size
size                equ       .

name                fcs       /grfdrv256/
                    fcb       edition

*******************************************************************
* Main Entry Point
*
* Entry: B = Function code (from vtio via CallGrfDrv)
*        Other registers = function parameters
*        U = GrfMem pointer ($1100)
*        DP = $11 (set by caller)
*******************************************************************
entry               equ       *
* Set DP to GrfMem area
* CoCo3 version sets this to $11 so that can directly address gr. vars
* However, then you can't access global vars.
*                    pshs      a
*                    lda       #GrfMem/256 ; DP = $11
*                    tfr       a,dp
*                    puls      a
                    tfr       0,dp
                    lda       #EDIT_LUT_1+ACT_LUT_1 Make sure we can edit grfdrv LUT
                    sta       MMU_MEM_CTRL

*Where did this come from, and then where is the stack for GrfDrv?
* Coco GrfDrv does not move stack from D.Flip1, which is set to
* D.CCStk in vtio CallGrfDrv which is supposed to be $2000 and set in krn.asm
*                   lds       >gr.Stack
* Dispatch to function
                    leay      FuncTbl,pcr
                    aslb                ; B*2 for word table
                    jmp       [b,y]


******************************************************************
* WriteChar - outpout character to Live or Shadow Text Map
* THESE ARE DIRECT CALLS  and *NOI* in the function table
*
*	a:   character to output
*	b:   color for map
*	y:   offset in textmap
*
* Writing text is so common, calls are direct for extra speed
* and to reduce overhead.  Being direct, they take their arguments in
* CPU registers and use none of the gr.b*/gr.d* parameter block.
*
*******************************************************************
* Direct calls skip 'entry', so they must select LUT 1 for editing
* themselves - otherwise the stb MMU_SLOT_n below (and the fast-path
* check) hit LUT 0 and corrupt the SYSTEM task's memory map.
WriteCharLive       pshs      cc,d,y
                    orcc      #IntMasks           IRQ return clears EDIT_LUT: select, read and remap masked
                    lda       #EDIT_LUT_1+ACT_LUT_1
                    sta       MMU_MEM_CTRL
                    ldx       MMU_SLOT_1
                    cmpx      #TEXT_RAM_BLK*256+COLOR_RAM_BLK
                    beq       mapped@
                    clra
                    ldx       #gr.DATImg+2
                    ldb       #TEXT_RAM_BLK
                    stb       MMU_SLOT_1 $2000
                    std       ,x++
                    ldb       #COLOR_RAM_BLK
                    stb       MMU_SLOT_2 $4000
                    std       ,x++
mapped@             puls      cc,d,y
                    leax      $2000,y
		    sta	      ,x
		    leax      $4000,y
		    stb	      ,x
         	    clrb
                    jmp       >GrfMod+SysRet

WriteCharShadow	    pshs      cc,a,b,y
                    orcc      #IntMasks
                    lda	      #EDIT_LUT_1+ACT_LUT_1   select LUT 1 (direct call skips 'entry')
                    sta	      MMU_MEM_CTRL
                    clra
                    ldx       #gr.DATImg+6
                    ldb       >gr.TermBlk
                    stb       MMU_SLOT_3 $6000
                    std       ,x++
                    incb
                    stb       MMU_SLOT_4 $8000
                    std       ,x++
		    puls      cc,a,b,y
	    	    leax      $6000,y
		    sta	      ,x
		    leax      T.TXTCOLOR,x
		    stb	      ,x	    
         	    clrb
                    jmp       >GrfMod+SysRet

******************************************************************
* ScrollLive/Shadow - Scroll Live or Shadow Text Map
* THESE ARE DIRECT CALLS  and *NOI* in the function table
*
*	a:      width
*	gr.d1:  start offset - first cell of the row that goes away
*	gr.d2:  end offset   - V.ScreenSize (V.WWidth * V.WHeight)
*
* Every row from gr.d1+width up to gr.d2 moves up one row, on both
* planes, and the last row's glyphs are blanked (its colours are not).
* Scroll passes gr.d1 = 0; 1F 31 Delete Line passes CurRow * WWidth.
* B and Y are not inputs.  Count = d2 - d1 - width; gr.d1 must be at
* most the start of the last row, or the count goes negative.
*
* Writing text is so common, calls are direct for extra speed
* and to reduce overhead.  They skip the GF.* dispatch, but they do
* read gr.d1/gr.d2 - vtio calls them only from DoScroll, and both of
* DoScroll's callers load gr.d1 and gr.d2 immediately before.
*
*******************************************************************
ScrollLive          pshs      cc,a
                    orcc      #IntMasks           IRQ return clears EDIT_LUT: select, read and remap masked
                    lda       #EDIT_LUT_1+ACT_LUT_1
                    sta       MMU_MEM_CTRL
                    ldx       MMU_SLOT_1
                    cmpx      #TEXT_RAM_BLK*256+COLOR_RAM_BLK
                    beq       mapped@
                    clra
                    ldx       #gr.DATImg+2
                    ldb       #TEXT_RAM_BLK
                    stb       MMU_SLOT_1 $2000
                    std       ,x++
                    ldb       #COLOR_RAM_BLK
                    stb       MMU_SLOT_2 $4000
                    std       ,x++
mapped@             puls      cc,a
                    pshs      a                   ,s = width
                    ldd       >gr.d2              end offset
                    subd      >gr.d1              - start offset
                    subb      ,s                  - one row
                    sbca      #0
                    pshs      d                   ,s = count, 2,s = width
                    ldy       #$2000              text plane
                    bsr       ScrollPlane
                    lda       2,s                 Y = start of last row
                    ldb       #$20
loop@               stb       ,y+                 blank the last row's glyphs
                    deca
                    bne       loop@
                    ldy       #$4000              colour plane
                    bsr       ScrollPlane
                    leas      3,s
                    clrb
                    jmp       >GrfMod+SysRet




ScrollShadow	    pshs      cc,a,b,y
                    orcc      #IntMasks
                    lda	      #EDIT_LUT_1+ACT_LUT_1   select LUT 1 (direct call skips 'entry')
                    sta	      MMU_MEM_CTRL
                    clra
                    ldx       #gr.DATImg+6
                    ldb       >gr.TermBlk
                    stb       MMU_SLOT_3 $6000
                    std       ,x++
                    incb
                    stb       MMU_SLOT_4 $8000
                    std       ,x++
		    puls      cc,a,b,y
                    pshs      a                   ,s = width
                    ldd       >gr.d2              end offset
                    subd      >gr.d1              - start offset
                    subb      ,s                  - one row
                    sbca      #0
                    pshs      d                   ,s = count, 2,s = width
                    ldy       #$6000              text plane
                    bsr       ScrollPlane
                    lda       2,s                 Y = start of last row
                    ldb       #$20
loop@               stb       ,y+                 blank the last row's glyphs
                    deca
                    bne       loop@
                    ldy       #$6000+T.TXTCOLOR   colour plane
                    bsr       ScrollPlane
                    leas      3,s
                    clrb
                    jmp       >GrfMod+SysRet

* ScrollPlane - move one plane up a row, starting at gr.d1.
* Entry: Y = plane base.  2,s = count, 4,s = width (the caller's frame)
* Exit:  Y = base + d1 + count = start of the last row
ScrollPlane         tfr       y,d
                    addd      >gr.d1              dest = base + start
                    tfr       d,y
                    ldb       4,s                 width
                    clra
                    leau      d,y                 source = dest + one row
                    ldd       2,s                 count
                    lbra      CpyBlk              CpyBlk returns to our caller

*******************************************************************
* Function Dispatch Table
*******************************************************************
FuncTbl
                    fdb       GrfMod+Init         ; B=0
                    fdb       GrfMod+Term         ; B=1
                    fdb       GrfMod+StatUnk      ; B=2  was GSMouse (read back)
                    fdb       GrfMod+StatUnk      ; B=3  was GSDScrn (read back)
                    fdb       GrfMod+GSFntChar    ; B=4
                    fdb       GrfMod+SSFntChar    ; B=5
                    fdb       GrfMod+StatUnk      ; B=6  was SSDScrn (no mirror)
                    fdb       GrfMod+PushBuf      ; B=7
                    fdb       GrfMod+PullBuf      ; B=8
		    fdb	      GrfMod+EraseLine	  ; b=9
		    fdb	      GrfMod+ErEOLine	  ; b=10
		    fdb	      GrfMod+ErEOScrn	  ; b=11
		    fdb	      GrfMod+PSGInit	  ; b=12
		    fdb	      GrfMod+PSGBell      ; b=13
		    fdb	      GrfMod+PSGOff	  ; b=14
		    fdb	      GrfMod+GFCell	  ; b=15
		    fdb	      GrfMod+GFClrScrn	  ; b=16
		    fdb	      GrfMod+GFBlank	  ; b=17
		    fdb	      GrfMod+GFPal	  ; b=18
		    fdb	      GrfMod+GFBmEnable	  ; b=19
		    fdb	      GrfMod+GFBmFree	  ; b=20
		    fdb	      GrfMod+GFBmPalet	  ; b=21
                    fdb       GrfMod+GFInsLine    ; b=22
                    fdb       GrfMod+GFSwitch     ; b=23
                    fdb       GrfMod+GFTermGone   ; b=24
                    fdb       GrfMod+GFDfPal      ; b=25
                    fdb       GrfMod+GFAScrn      ; b=26
                    fdb       GrfMod+GFGetStt     ; b=27
                    fdb       GrfMod+GFSetStt     ; b=28
                    fdb       GrfMod+GFInitDisp   ; b=29
                    fdb       GrfMod+GFTermNew    ; b=30


*******************************************************************
* Init - Initialize graphics driver
*******************************************************************
Init
* Initialize F256 graphics hardware
* Setup default screen modes
* Initialize palettes
* etc.

* Example:
*   bsr   InitHardware
*   bsr   SetupDefaultScreen
*                    andcc	#^Carry
		    ldd  #GrfMod+WriteCharLive
                    std  gr.WriteCharLive
  		    ldd  #GrfMod+WriteCharShadow
  		    std  gr.WriteCharShadow
		    ldd	 #GrfMod+ScrollLive
		    std	 gr.ScrollLive
		    ldd  #GrfMod+ScrollShadow
		    std	 gr.ScrollShadow
                    clrb                ; No error
                    lbra      SysRet    ; Return to caller

*******************************************************************
* Term - Terminate graphics driver
*******************************************************************
Term
* Cleanup graphics hardware
* Reset to text mode
* etc.

                    clrb
                    lbra      SysRet


;;; GS.FntChar
;;;
;;; Copy a font character from font bank 0 or 1 to a user memory location
;;;
;;; Entry: R$A = font set 0 or 1
;;;        R$X = pointer to 8 byte memory
;;;        R$Y = font character to get (0-255)
;;;
;;; Exit:  B = non-zero error code
;;;       CC = carry flag clear to indicate success


;;; SS.FntChar
;;;
;;; Set a font character in font bank 0 or 1 from a user memory location
;;;
;;; Entry: R$A = font set 0 or 1
;;;        R$X = pointer to 8 byte memory
;;;        R$Y = font character to set (0-255)
;;;
;;; Exit:  B = non-zero error code
;;;       CC = carry flag clear to indicate success

;;; difference between get and set is just two lines specifying
;;; source and destination.  So procedures are combined.
GSFntChar           lda       #0
                    bra       DoFontGetSet
SSFntChar           lda       #1
DoFontGetSet        pshs      a         store get/set state on stack
                    pshs      cc
                    orcc      #IntMasks
                    lda       #EDIT_LUT_1+ACT_LUT_1
                    sta       MMU_MEM_CTRL
                    lda       #FONT_BLK map in font block
                    sta       MMU_SLOT_2
                    clr       gr.DATImg+4
                    sta       gr.DATImg+5
                    ldx       #gr.PDRGS load x with PDREGS to get shadow stack regs
                    ldx       R$X,x     setfont: source is x
                    ldy       #gr.PDAT
                    lbsr      GMapAddr2Blk
                    lda       #1
                    sta       MMU_MEM_CTRL
*		    ldy	      #$0104
*		    sty	      MMU_SLOT_3
                    ldx       #gr.PDRGS
                    ldd       R$Y,x     get the char# and mulitply by 8
                    lslb                because 8 bytes per character
                    rola
                    lslb
                    rola
                    lslb
                    rola                d now has the font character offset from 0
                    tfr       d,y       transfer result to y
*		    lbra      end@
                    lda       R$A,x     test for font bank 0 or 1
                    beq       font0@    and add appropriate offset
font1@              leay      FONT_1_OFFSET,y add offset for font 1
                    bra       cont@
font0@              leay      FONT_0_OFFSET,y add offset for font 0
cont@               leay      $4000,y
                    pshs      y         push character offset on stack
mapgood@            ldd       R$X,x
                    anda      #%00011111
                    tfr       d,x
                    tst       3,s
                    beq       getfont@
                    puls      y
                    leax      $2000,x   x=process memory
                    bra       contfont@
getfont@            leay      $2000,x
                    puls      x
contfont@           ldb       #4        copy 8 bytes
                    pshs      u
copy@               ldu       ,x++
                    stu       ,y++
                    decb
                    bne       copy@
end@                puls      u         pull blk addr and getset flag
                    puls      cc
                    puls      a
debugend@           jmp       >GrfMod+SysRet

;;; PushBuf
;;; Push Registers to Screen Backup Buffer
;;;
;;; Exit:  Nothing. This just copies values
;;;
PushBuf             lbsr      PushCore
                    jmp       >GrfMod+SysRet
* PushCore - GF.PushBuf's body, also called by GFSwitch.  Exit U = gr.U5.
PushCore            lbsr      SetBlkC2C3
                    pshs      y,u
                    ldy       #$6000+T.TXT copy text from $C2
                    ldu       #$2000
                    ldd       #4800
                    lbsr      CpyBlk
                    ldy       #$6000+T.TXTCOLOR copy color from $C3
                    ldu       #$4000
                    ldd       #4800
                    lbsr      CpyBlk
                    lbsr      SetBlkC0C1
* The four copies below READ Vicky memory back.  Each is gated on its own
* switch so they can be re-enabled one at a time on real hardware - see
* the TermSave* table in defs/wildbits_vtio.d.  SetBlkC0C1 maps $C0 at
* $2000 and $C1 at $4000.
                    ifne      TermSaveTextLUT
                    ldy       #$6000+T.FLUT   text LUT fg+bg, 2 x 64 bytes
                    ldu       #$2000+TEXT_LUT_FG  $C0+$1700, NOT $C1
                    ldd       #128
                    lbsr      CpyBlk
                    endc
* Sprite records are NOT captured here, and nothing replaces the capture:
* the program that draws them holds the only copy and has registered where
* it is (gr.SprTbl), so the terminal coming forward fills the registers
* from its own table and clears what that table does not cover.  The
* outgoing terminal's records are simply left alone until then.
                    ifne      TermSaveFont0
                    ldy       #$6000+T.FONT0  font memory bank 0
                    ldu       #$4000+FONT_0_OFFSET   $C1+$0000
                    ldd       #$800
                    lbsr      CpyBlk
                    endc
* CLUTs 0-3 are GRPH_LUT0_OFF ($1000) within FONT_BLK ($C1), which
* SetBlkC0C1 maps at $4000 - so $5000, not $2800.  $2800 is $C0+$0800,
* and 4096 bytes from there runs to $C0+$17FF: on Revision E that is
* gamma R, the mouse graphics, the BITMAP and TILE control registers,
* the memtext registers, all four sprite banks and the text LUTs.  A
* push/pull round trip was self-consistent, which is why nothing showed,
* but PullBuf was programming the bitmap and tile registers with
* whatever had been captured.
                    ifne      TermSaveCLUT
                    ldy       #$6000+T.CLUT0  graphics LUT0-3, $400 each
                    ldu       #$4000+GRPH_LUT0_OFF   $C1+$1000
                    ldd       #$1000
                    lbsr      CpyBlk
                    endc
* The 16 main display registers ($FFC0-$FFCF) are NOT read back here any
* more.  V.V_MCR / V.V_LayerCTL / V.BordBack are seeded by vtio's
* GF.InitDisp, inherited by GF.TermNew and updated by every writer
* (SetWin, ChgFont, SSDScrn, SSPScrn), so the mirror is already correct
* and authoritative - while reading a Vicky register back is not
* something the hardware owes us.  PullBuf still programs them from the
* mirror; it is only the capture that is gone.
* The bitmap registers ($C0+$1000) and the tile map / tile set registers
* ($1100 / $1180) are NOT read back here any more either, for the same
* reason $FFC0-$FFCF no longer are.  This block used to capture all three
* bitmaps' control byte and physical address and hand them to PullBuf,
* and on real hardware it came back wrong: a background image loaded on
* /vt1 displayed correctly, survived being switched away from, and came
* back as pure static - PushBuf had overwritten V.BM2Blk with whatever
* reading $3011 produced and PullBuf pointed the display at it.  MAME
* models the whole $C0 page as plain RAM, so the round trip is perfect
* there and the failure never appears.
*
* vtio owns these values now: SS.AScrn and SS.Palet write V.BMxCl_En /
* V.BMxBlk, SS.FScrn clears them, GF.TermNew zeroes the whole
* bitmap+tile mirror for a new terminal, and PullBuf below programs the
* registers from it.  A program that poked $C0+$1000 behind the driver's
* back would no longer have its bitmap carried per terminal - nothing
* does; SS.AScrn is the only way in.
*
* CORRECTION, 2026-09-20, READ FROM THE RTL AND NOT TESTED.  The reason
* recorded above and in c187585a - "reading a Vicky register back is not
* something the hardware owes us" - is WRONG for the bitmap registers,
* though the remedy was right and the failure was real.  They read back
* fine; the READ MAP IS THE WRITE MAP REVERSED.
*   write  +1,+2,+3 -> REG[1],REG[2],REG[3] = High, Mid, Low  (BmRegAddr)
*   read   +1,+2,+3 -> REG[3],REG[2],REG[1] = Low,  Mid, High
* (TinyVicky_BM_Registers.v, the Bus_D_o case: its comments label each
* read by what it MEANS, which is the opposite order from the write.)
* So the old capture read +1,+2,+3 and stored them as H,M,L, getting
* L,M,H - a bitmap at $1B0000 comes back as $00001B.  A wildly wrong
* address is fine-grained noise, which is exactly the "pure static"
* c187585a reported.
*
* Which means the capture COULD be made to work, with the byte swap, and
* then a bitmap would be carried per terminal again.  NOT DONE, and not
* to be done casually: this is the code path that put static on the
* user's board, so it wants a hardware run of its own.  See the open item
* in docs/status.md.
*
* THE TILE REGISTERS ARE A DIFFERENT CASE AND CANNOT BE CAPTURED AT ALL:
* TinyVicky_TL_Registers.v has no read path - "assign DataOut_Tile_MAP_o
* = 8'h33;" - so the whole $18_1100-$18_11FF page reads as $33 forever.
* Lumping the two together is what made the one look like the other.
                    puls      y,u
end@                clrb
                    rts

; Take a block number in a (b = 0) and return the high and middle bytes of
; its physical address in d.  Addr2Blk, the inverse, went with PushBuf's
; register capture - nothing reads a bitmap address back any more.
Blk2Addr            lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    rts

*******************************************************************
* BmGetAddr - where bitmap A lives, from this terminal's mirror.
*   Entry: A = bitmap # (0-2), U = the statics.
*   Exit:  A = its block, X = its offset within that block.  B clobbered.
*******************************************************************
BmGetAddr           lsla                          two bytes per bitmap in each
                    leax      V.BM0Blk,u
                    ldb       a,x                 its block
                    leax      V.BM0Off,u
                    ldx       a,x                 its offset
                    tfr       b,a
                    rts

*******************************************************************
* BmRegAddr - write a bitmap's 24-bit address into its registers.
*   Entry: A = block, X = offset (0-$1FFF), Y = the register base
*          ($3000, $3008 or $3010 with $C0 in slot 1).
*   Writes bits 23:16 at 1,y and bits 15:0 at 2,y.  Clobbers D and X.
*
* The address is block*$2000 + offset.  Blk2Addr gives bits 23:8 of the
* block part, whose low 13 bits are zero by construction, so an offset of
* $1FFF or less can never carry out of them and the high byte is the
* block's alone.  The 16-bit sum cannot overflow either: bits 15:13 come
* from the block's low three bits, so the most it can reach is $FFFF.
*******************************************************************
BmRegAddr           clrb
                    lbsr      Blk2Addr            D = address bits 23:8
                    pshs      a                   bits 23:16
                    tfr       b,a
                    clrb                          D = bits 15:0, low 13 clear
                    leax      d,x                 X = that plus the offset
                    puls      a
                    sta       1,y                 bits 23:16
                    stx       2,y                 bits 15:8 and 7:0
                    rts
;;; Pulluf
;;; Push Registers to Screen Backup Buffer
;;;
;;; Exit:  Nothing. This just copies values
;;;
PullBuf             lbsr      PullCore
                    jmp       >GrfMod+SysRet
* PullCore - GF.PullBuf's body, also called by GFSwitch.  Exit U = gr.U5.
PullCore            lbsr      SetBlkC2C3
                    pshs      y,u
                    ldu       #$6000+T.TXT restore text to $C2
                    ldy       #$2000
                    ldd       #4800
                    lbsr      CpyBlk
                    ldu       #$6000+T.TXTCOLOR restore color to $C3
                    ldy       #$4000
                    ldd       #4800
                    lbsr      CpyBlk
                    lbsr      SetBlkC0C1
* The counterparts of PushBuf's four read-back copies, gated the same
* way.  Whatever is switched off is global state that a switch simply
* leaves alone.  This is the block that blacked the screen on real
* hardware with all four on - it programs whatever PushBuf managed to
* read out of Vicky.
                    ifne      TermSaveTextLUT
                    ldu       #$6000+T.FLUT   text LUT fg+bg
                    ldy       #$2000+TEXT_LUT_FG  $C0+$1700, NOT $C1
                    ldd       #128
                    lbsr      CpyBlk
                    endc
* The sprite registers are filled from this terminal's REGISTERED table,
* not from a shadow - see SprRestore, called at the end of PullCore where
* the 16K buffer is finished with and slots 3/4 are free.
                    ifne      TermSaveFont0
                    ldu       #$6000+T.FONT0  font memory bank 0
                    ldy       #$4000+FONT_0_OFFSET   $C1+$0000
                    ldd       #$800
                    lbsr      CpyBlk
                    endc
* Restore is gated separately from PushBuf's capture: with TermSaveCLUT 0
* and TermRestCLUT 1, T.CLUT0-3 is a write-only mirror that vtio's
* SS.DfPal maintains and nothing ever reads out of Vicky.
                    ifne      TermRestCLUT
                    ldu       #$6000+T.CLUT0  graphics LUT0-3
                    ldy       #$4000+GRPH_LUT0_OFF   $C1+$1000, not $2800
                    ldd       #$1000
                    lbsr      CpyBlk
                    endc
* restore display registers
                    ldu       >gr.U5
                    leau      V.V_MCR,u  copy VICKY_MCR Regs, Layer, Backgroun
                    ldy       #$FFC0
                    ldd       #16
                    lbsr      CpyBlk
                    ldu       >gr.U5
* The three bitmaps, from the mirror.  BmRegAddr writes all three address
* bytes including the low one, which PullBuf used to have to clear by hand
* because GFBmEnable was the only other writer of it and does not run for
* a terminal that set its bitmap up while it was a shadow.  Now that a
* bitmap carries an offset within its block, that byte is real data.
                    lda       V.BM0Cl_En,u
                    sta       $3000
                    ldy       #$3000
                    clra                          bitmap 0
                    lbsr      BmGetAddr
                    lbsr      BmRegAddr
                    lda       V.BM1Cl_En,u
                    sta       $3008
                    ldy       #$3008
                    lda       #1
                    lbsr      BmGetAddr
                    lbsr      BmRegAddr
                    lda       V.BM2Cl_En,u
                    sta       $3010
                    ldy       #$3010
                    lda       #2
                    lbsr      BmGetAddr
                    lbsr      BmRegAddr
                    ldy       #$3100
                    leau      V.TM0,u   Copy Tile Map Regs
                    ldd       #36
                    lbsr      CpyBlk
                    ldu       >gr.U5
                    leau      V.TS0AddrH,u
                    ldy       #$3180
                    ldd       #32
                    lbsr      CpyBlk
                    puls      y,u
* The sprite registers last: SprRestore takes slots 3 and 4, which the 16K
* buffer had until now, and it needs $C0 where SetBlkC0C1 left it.
                    lbsr      SprRestore
end@                clrb
                    rts


EraseLine	    lbsr      SetBlkC2C3
	            clrb                          start erasing at column 0
                    lda       V.CurRow,u          of the current row
		    bsr       EraseLineCore
                    jmp       >GrfMod+SysRet
* Entry:  A = The row to erase.
*         B = The column to start erasing on.
EraseLineCore       pshs      u
		    pshs      b                   save the start column
                    ldb       V.WWidth,u
                    mul                           get the product
                    addb      ,s                  add the column to start erasing from
                    adca      #0                  consider the carry
                    tfr       d,x                 X = cell offset
                    lda       V.WWidth,u          get the number of columns
                    suba      ,s+                 A = cells to erase
                    tfr       a,b
                    clra
                    tfr       d,y                 Y = fill count
		    cmpy      #0
		    beq       elcexit
                    lda       #C$SPAC		  A=glyph, X=cell offset, Y=count
* b3 is scratch here, not a parameter: U is about to be reused as the
* colour-plane pointer, so V.FBCol has to be spilled somewhere first.
* Callers must not hold a live b3 across GF.EraseLine/ErEOLine/ErEOScrn.
		    ldb	      V.FBCol,u
		    stb	      >gr.b3               spill V.FBCol (colour attr)
                    ldb	      V.TermLive,u
		    beq	      EraseLineShadow
		    leau      $4000,x
		    leax      $2000,x
		    bra	      FillChars
EraseLineShadow	    leau      $6000+T.TXTCOLOR,x
		    leax      $6000,x
FillChars	    ldb	      >gr.b3               recover the colour attr
loop@		    sta	      ,x+
		    stb	      ,u+
		    leay      -1,y
		    bne	      loop@
elcexit		    puls      u
		    rts


ErEOLine	    lbsr      SetBlkC2C3
ErEOLine2           ldd       >V.CurRow,u         get the current row and column
                    bsr       EraseLineCore       go erase from that point to the end of line
                    jmp       >GrfMod+SysRet		    

ErEOScrn	    lbsr      SetBlkC2C3
		    ldd	      >V.CurRow,u
		    bsr	      EraseLineCore
                    lda       V.CurRow,u          get the current row
l@                  clrb                          clear the column
                    inca                          increment row
                    cmpa      V.WHeight,u         are we at the end?
                    bge       ex@                 branch if so
                    pshs      a                   save our row counter
                    bsr       EraseLineCore       go erase the line
                    puls      a                   recover our row counter
                    bra       l@                  go erase more
ex@                 jmp       >GrfMod+SysRet      return		    

*******************************************************************
* GF.InsLine (22) - 1F 30 Insert Line at V.CurRow.
* Rows CurRow..WHeight-2 move down one (the last row is lost), then
* row CurRow is erased to spaces in V.FBCol.  No parameters: reads the
* DSS through U like EraseLine.  vtio clamps V.CurRow below V.WHeight
* and refuses a zero width or height before calling.
*******************************************************************
GFInsLine           lbsr      SetBlkC2C3          U = this terminal's statics
                    lda       V.WHeight,u
                    deca
                    suba      V.CurRow,u          rows to move
                    ldb       V.WWidth,u
                    mul                           D = bytes to move per plane
                    beq       ilblank@            inserting at the last row
                    pshs      d,u                 count, statics
                    ldb       V.WWidth,u
                    clra
                    pshs      d                   ,s = width, 2,s = count, 4,s = statics
                    ldx       V.ScreenSize,u      X = dest end offset
                    tst       V.TermLive,u
                    beq       ilshad@
                    ldd       #$2000              live text plane
                    bsr       InsPlane
                    ldd       #$4000              live colour plane
                    bsr       InsPlane
                    bra       ildone@
ilshad@             ldd       #$6000              shadow text plane
                    bsr       InsPlane
                    ldd       #$6000+T.TXTCOLOR   shadow colour plane
                    bsr       InsPlane
ildone@             leas      4,s                 drop width, count
                    puls      u                   statics back
ilblank@            lda       V.CurRow,u
                    clrb                          from column 0
                    lbsr      EraseLineCore       row CurRow -> spaces, V.FBCol
                    jmp       >GrfMod+SysRet

* InsPlane - move one plane's rows down one row, copying end to start
* (CpyBlk copies upward, which would smear row CurRow down the screen).
* Entry: D = plane base, X = dest end offset (V.ScreenSize)
*        2,s = width, 4,s = count (the caller's frame)
* Preserves X.
InsPlane            pshs      x                   now 4,s = width, 6,s = count
                    leay      d,x                 Y = dest end
                    tfr       y,d
                    subd      4,s                 source end = dest end - one row
                    tfr       d,u
                    ldx       6,s                 count (never 0 - caller checks)
iplp@               lda       ,-u
                    sta       ,-y
                    leax      -1,x
                    bne       iplp@
                    puls      x,pc

*******************************************************************
* GFSwitch - GF.Switch (op 23): change the live terminal.
* Moved here from vtio's SwitchTerm to take it out of the bootfile;
* vtio's AltISR only checks gr.Busy and issues the op.
* gr.SwitchReq: SW.Next / SW.Prev walk the ids to the next T.Init
* entry, SW.Goto (1B 21) takes the id in gr.SwitchTerm.  The request is
* always cleared.  Everything touched is reachable from this map: gr.*
* and D.KbdSta in block 0, the cursor registers in the $FFxx I/O page,
* each terminal's statics through slot 5 (SetBlkC2C3).
* CC is saved and restored: SysRet hands grfdrv's CC back to the caller.
*******************************************************************
GFSwitch            pshs      cc
                    orcc      #IntMasks
                    lda       >gr.SwitchReq
                    lbeq      GSDone
                    lda       >gr.LiveTerm
                    cmpa      #$FF
                    lbeq      GSDone
                    ldb       >gr.SwitchReq
                    cmpb      #SW.Goto
                    beq       GSGoto
                    tfr       a,b
                    lslb
                    lslb
                    lslb                          B = ID * gr.TermSz
                    tst       >gr.SwitchReq
                    bmi       GSPrev
                    bra       GSNext
* SW.Goto: re-check T.Init - the terminal can have closed since DWSelect.
GSGoto              lda       >gr.SwitchTerm
                    cmpa      #G.TermMax
                    lbhs      GSDone
                    cmpa      >gr.LiveTerm
                    lbeq      GSDone
                    tfr       a,b
                    lslb
                    lslb
                    lslb
                    ldx       #gr.TermTbl
                    abx
                    pshs      a
                    lda       T.Flags,x
                    bita      #T.Init
                    puls      a
                    lbeq      GSDone
                    bra       GSFound
GSPrev              deca
                    subb      #gr.TermSz
                    bpl       GSChkPrev
                    lda       #G.TermMax-1
                    ldb       #(G.TermMax-1)*gr.TermSz
GSChkPrev           cmpa      >gr.LiveTerm
                    lbeq      GSDone
                    ldx       #gr.TermTbl
                    abx
                    pshs      a
                    lda       T.Flags,x
                    bita      #T.Init
                    puls      a
                    beq       GSPrev
                    bra       GSFound
GSNext              inca
                    addb      #gr.TermSz
                    cmpa      #G.TermMax
                    blo       GSChkNext
                    clra
                    clrb
GSChkNext           cmpa      >gr.LiveTerm
                    lbeq      GSDone
                    ldx       #gr.TermTbl
                    abx
                    pshs      a
                    lda       T.Flags,x
                    bita      #T.Init
                    puls      a
                    beq       GSNext
* A = new id, B = its table offset.  Save the live terminal first.
GSFound             pshs      d                   0,s = new id, 1,s = new offset
                    ldb       >gr.LiveTerm
                    lslb
                    lslb
                    lslb
                    ldx       #gr.TermTbl
                    abx                           X = old entry
                    lda       T.Flags,x
                    anda      #^T.Live
                    sta       T.Flags,x
                    lbsr      GSTermPtrs
                    lbsr      PushCore            exits U = old statics (slot 5)
                    clr       V.TermLive,u
* SS.WSig: stage "your terminal went background" for vtio's AltISR to send.
* D is already on the stack here, so A and B are scratch.
                    lda       V.WSigID,u
                    beq       wsbg@
                    ldb       V.WSigBg,u
                    beq       wsbg@
                    sta       >gr.SigBgID
                    stb       >gr.SigBgCode
wsbg@               puls      d
                    lbsr      GSEnter             then bring in the new one
GSDone              clr       >gr.SwitchReq
                    puls      cc
                    clrb
                    jmp       >GrfMod+SysRet
*******************************************************************
* GFTermGone - GF.TermGone (op 24): a terminal is closing (vtio TermTerm).
* Entry gr.b1 = its id, gr.d1 = the closing device's static (system
* address).  Nothing happens unless the entry has T.Init AND its T.StatPtr
* is that static: IOMan calls Term after a failed Init or /vt open, and a
* /vt factory static that never bound still has V.TermID 0 - /term's id.
* The flags are read once, THEN cleared - so the AltISR can no longer
* switch to this terminal - and the live decision uses the copy.  If it
* was live, the lowest open id takes over (the cleared entry fails the
* T.Init test, so the search skips it), else no terminal is live.  Then,
* with interrupts back on, the 16K buffer is freed, the rest of the entry
* cleared and gr.TermCnt counted down.
* gr.SwitchReq is left alone: a pending Alt+arrow still runs next tick.
*******************************************************************
GFTermGone          pshs      cc
                    orcc      #IntMasks
                    lda       >gr.b1
                    cmpa      #G.TermMax
                    bhs       GTDone
                    ldb       #gr.TermSz
                    mul
                    ldx       #gr.TermTbl
                    abx                           X = closing entry
                    ldd       T.StatPtr,x
                    cmpd      >gr.d1
                    bne       GTDone              not this static's terminal
                    ldb       T.Flags,x           B = its flags, read once
                    bitb      #T.Init
                    beq       GTDone              not open - nothing to do
                    clr       T.Flags,x           no switch can pick it now
                    pshs      x                   the closing entry, for the free
                    bitb      #T.Live
                    beq       GTFree              was not on screen
                    clra                          A = id, B = offset, from 0
                    clrb
GTFind              ldx       #gr.TermTbl
                    abx
                    pshs      a
                    lda       T.Flags,x
                    bita      #T.Init
                    puls      a
                    beq       GTSkip
                    lbsr      GSEnter
                    bra       GTFree
GTSkip              inca
                    addb      #gr.TermSz
                    cmpa      #G.TermMax
                    blo       GTFind
                    lda       #$FF                none left open
                    sta       >gr.LiveTerm
                    clra
                    clrb
                    std       >D.KbdSta
* Interrupts back on before the os9 call.  The entry has no T.Init, so no
* switch can pick it, and gr.Busy keeps the AltISR out of grfdrv anyway.
GTFree              puls      x
                    puls      cc
                    lbsr      GTFreeBms           bitmaps the driver owns die with it
                    ldb       T.Block,x
                    beq       GTClear
                    pshs      x
                    clra
                    tfr       d,x                 X = first block of the 16K
                    ldb       #2
                    os9       F$DelRAM
                    puls      x
* The registration dies with the terminal.  It names blocks the program
* owned, and a stale row would copy whatever owns them now onto the screen
* as sprite records.
GTClear             lda       >gr.b1
                    ldb       #SB.Size
                    mul
                    ldy       #gr.SprTbl
                    leay      d,y
                    clr       SB.Flags,y
                    clr       T.Block,x
                    clra
                    clrb
                    std       T.StatPtr,x
                    dec       >gr.TermCnt
                    clrb
                    jmp       >GrfMod+SysRet
GTDone              puls      cc
                    clrb
                    jmp       >GrfMod+SysRet

*******************************************************************
* GTFreeBms - free the bitmaps the DRIVER allocated for this closing
*   terminal.  Entry X = its gr.TermTbl entry, interrupts ENABLED (the
*   os9 calls need them).  Exit X kept; D clobbered.
*
* Without this the blocks leak, permanently and unrecoverably: a bitmap
* is recorded only in its own terminal's statics, and those go away with
* the device.  A program killed by a signal it cannot trap, or a /vt
* simply closed, took up to 30 blocks - 240 KB of the ~2 MB - with it.
* GF.TermGone was thorough about the 16K switch buffer and the sprite
* registration and never looked at V.BM0Blk-V.BM2Blk.
*
* This is the ONE lifetime hole the driver can close on its own, and the
* reason is worth keeping: a bitmap belongs to the TERMINAL, not to the
* process.  SS.AScrn is addressed to a path, the blocks are recorded in
* that terminal's statics, PullBuf reprograms them on a switch, and
* shellbg deliberately allocates one and exits so the shell keeps the
* wallpaper.  So "the terminal closed" is exactly the right moment, and
* GF.TermGone is exactly the right hook.  The tile and sprite lifetime
* hole is NOT like this - there the PROCESS owns the memory and the
* terminal outlives it, which is why that one still has no answer.
*
* Blocks a program owns (SS.BmDef) are left strictly alone: only the
* ownership bit in V.BMFlags says free these, and only SS.BmAlloc sets it.
*******************************************************************
* gr.VBlk and gr.U5 are SAVED AND PUT BACK.  By the time GTFree reaches
* here GSEnter may already have run and aimed them at whichever terminal
* took over the screen; leaving them pointing at the one that just closed
* would hand the next caller a dead terminal's statics.
GTFreeBms           pshs      x
                    ldd       >gr.U5
                    pshs      d
                    lda       >gr.VBlk
                    pshs      a
                    ldx       3,s                 the closing entry back
                    lda       T.VBlk,x            aim slot 5 at the CLOSING
                    sta       >gr.VBlk            terminal's statics
                    ldd       T.grU5,x
                    std       >gr.U5
                    clra                          bitmap # 0
GTFBlp              lbsr      SetBlkC2C3          U = its statics (keeps D and X)
                    pshs      a                   ,s = bitmap #
                    lbsr      BmFlagMask          A = BM.Small << bitmap #
                    pshs      a                   ,s = size bit, 1,s = bitmap #
                    lsla
                    lsla
                    lsla
                    lsla                          A = its ownership bit
                    anda      V.BMFlags,u
                    beq       GTFBnx              a program's blocks: not ours to free
                    lda       1,s                 bitmap #
                    lsla                          two mirror bytes each
                    leay      V.BM0Cl_En,u
                    leay      a,y                 Y -> V.BMxCl_En, block at 1,y
                    clra
                    ldb       1,y
                    beq       GTFBnx              nothing allocated
                    tfr       d,x                 X = first block
                    ldb       ,s                  its size bit
                    andb      V.BMFlags,u
                    beq       GTFBten
                    ldb       #BmBlk200
                    bra       GTFBdel
GTFBten             ldb       #BmBlk240
* Clear the mirror BEFORE the free: Y reaches it through slot 5, which the
* os9 call may disturb, and a switch must never reprogram a freed bitmap.
GTFBdel             clr       ,y
                    clr       1,y
                    os9       F$DelRAM
GTFBnx              leas      1,s                 drop the size bit
                    puls      a                   bitmap #
                    inca
                    cmpa      #3
                    blo       GTFBlp
                    puls      a                   gr.VBlk and gr.U5 back, so the
                    sta       >gr.VBlk            terminal GSEnter just brought in
                    puls      d                   is still what slot 5 reaches
                    std       >gr.U5
                    lbsr      SetBlkC2C3
                    puls      x,pc

* GSEnter - make a terminal live: pull its buffer, point the keyboard and
* gr.* at it, put the hardware cursor where it was.  Shared by GFSwitch
* and GFTermGone.  Entry A = id, B = its table offset.  Exit U = its
* statics (slot 5).
GSEnter             pshs      a
                    ldx       #gr.TermTbl
                    abx                           X = new entry
                    lda       T.Flags,x
                    ora       #T.Live
                    sta       T.Flags,x
                    lbsr      GSTermPtrs
* D.KbdSta takes T.StatPtr, the system address - never U, which is this
* map's slot-5 alias (keys go nowhere).
                    ldd       T.StatPtr,x
                    std       >D.KbdSta
                    lbsr      PullCore            exits U = new statics (slot 5)
* Drop any key repeat this terminal was left holding.  Repeat state is per
* terminal but keydrv only services the live one, so a key pressed here
* and released after a switch away never cleared it, and it fired on the
* next switch back.
                    clr       V.LastCh,u
                    lda       #1
                    sta       V.TermLive,u
* SS.WSig: stage "your terminal came forward".  A is about to be pulled
* back off the stack; B is saved because GSCalcPos follows.
                    pshs      b
                    lda       V.WSigID,u
                    beq       wsfg@
                    ldb       V.WSigFg,u
                    beq       wsfg@
                    sta       >gr.SigFgID
                    stb       >gr.SigFgCode
wsfg@               puls      b
                    puls      a
                    sta       >gr.LiveTerm
* Clamp V.CurRow and resync V.CurPos (a DWSet can leave the row past the
* window), then put the hardware cursor there.
                    lbsr      GSCalcPos
                    ldx       #TXT.Base
                    lda       V.CurCol,u
                    sta       VKY_TXT_CURSOR_X_REG_L,x
                    lda       V.CurRow,u
                    sta       VKY_TXT_CURSOR_Y_REG_L,x
                    rts
* GSTermPtrs - vtio's SetTermGrfPtrs: aim gr.TermBlk/VStaStorU/VBlk/U5
* at one terminal.  Entry X = its gr.TermTbl entry.  Clobbers D.
GSTermPtrs          ldb       T.Block,x
                    stb       >gr.TermBlk
                    ldd       T.StatPtr,x
                    std       >gr.VStaStorU
                    lda       T.VBlk,x
                    sta       >gr.VBlk
                    ldd       T.grU5,x
                    std       >gr.U5
                    rts
* GSCalcPos - vtio's CalcCurPos: clamp V.CurRow to V.WHeight-1, then
* V.CurPos = V.CurRow * V.WWidth + V.CurCol.  Entry U = statics.
GSCalcPos           lda       V.WHeight,u
                    beq       GSCPZero            degenerate window - cell 0
                    cmpa      V.CurRow,u
                    bhi       GSCPRow
                    deca
                    sta       V.CurRow,u
GSCPRow             lda       V.CurRow,u
                    ldb       V.WWidth,u
                    mul
                    addb      V.CurCol,u
                    adca      #0
                    std       V.CurPos,u
                    rts
GSCPZero            clra
                    clrb
                    std       V.CurPos,u
                    rts


*******************************************************************
* GF.DfPal (b25) - SS.DfPal for this terminal.  vtio aims gr.TermBlk,
*   gr.VBlk and gr.U5 first and calls through CallGrfDrv, so gr.PDRGS
*   holds the caller's R$X = CLUT # 0-3 and R$Y = 1K of palette data,
*   and gr.PDAT the caller's DAT image.
* The 1K goes to T.CLUTn in the terminal's 16K switch buffer - offset
* $1000+n*$400 of the SECOND block of the pair, the same offsets the
* CLUTs have in $C1 - and, when the terminal is live or has no buffer
* yet, to the live CLUT in $C1.
*   slot 1  the caller's block holding R$Y (source $2000 + R$Y&$1FFF)
*   slot 2  the caller's next block, only when the 1K crosses into it
*   slot 3  $C1              slot 4  second buffer block (SetBlkC2C3)
* Exit: B = 0, or carry + E$IllArg (CLUT # above 3, or the 1K runs off
*   the top of the caller's map).
*******************************************************************
GFDfPal             ldd       >gr.PDRGS+R$X       CLUT #
                    cmpd      #3
                    lbhi      DfPalBad
                    lslb
                    lslb                          B = high byte of n*$400
                    pshs      b
                    lbsr      SetBlkC2C3          U = this terminal's statics
                    lda       V.TermLive,u
                    ldb       V.TermBufBlk,u
                    pshs      d                   ,s = live  1,s = buffer blk  2,s = n*4
                    ldd       >gr.PDRGS+R$Y       source address in the caller
                    anda      #$1F
                    addd      #$2000
                    tfr       d,u                 U = source as seen through slot 1
                    ldb       >gr.PDRGS+R$Y
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lsrb                          B = caller slot 0-7
                    lslb
                    ldx       #gr.PDAT+1          low byte of each 2-byte entry
                    abx                           X -> caller's block for that slot
                    pshs      cc
                    orcc      #IntMasks
                    lda       #EDIT_LUT_1+ACT_LUT_1
                    sta       MMU_MEM_CTRL
                    clra
                    ldb       ,x
                    stb       MMU_SLOT_1 $2000
                    std       >gr.DATImg+2
                    cmpu      #$4000-$400         does the 1K end inside slot 1?
                    bls       DfPalMapped
                    cmpx      #gr.PDAT+15         slot 7 has no next block
                    beq       DfPalOff
                    ldb       2,x
                    stb       MMU_SLOT_2 $4000
                    std       >gr.DATImg+4
DfPalMapped         puls      cc
                    tst       1,s
                    beq       DfPalLive           no buffer yet: live CLUT only
                    lda       2,s
                    adda      #$90                $8000 + $1000 + n*$400
                    clrb
                    tfr       d,y
                    pshs      u
                    ldd       #$400
                    lbsr      CpyBlk
                    puls      u
                    tst       ,s                  live?
                    beq       DfPalDone           no - PullBuf programs it on the switch
DfPalLive           pshs      cc
                    orcc      #IntMasks
                    lda       #EDIT_LUT_1+ACT_LUT_1
                    sta       MMU_MEM_CTRL
                    clra
                    ldb       #FONT_BLK
                    stb       MMU_SLOT_3 $6000
                    std       >gr.DATImg+6
                    puls      cc
                    lda       2,s
                    adda      #$70                $6000 + $1000 + n*$400
                    clrb
                    tfr       d,y
                    ldd       #$400
                    lbsr      CpyBlk
DfPalDone           leas      3,s
                    clrb
                    jmp       >GrfMod+SysRet
DfPalOff            puls      cc
                    leas      3,s
DfPalBad            comb
                    ldb       #E$IllArg
                    jmp       >GrfMod+SysRet


*******************************************************************
* GF.AScrn (b26) - SS.AScrn for this terminal.  vtio aims gr.TermBlk,
*   gr.VBlk and gr.U5 and calls through CallGrfDrvRet, which copies
*   gr.PDRGS back to the caller's registers afterwards.
*   gr.PDRGS R$Y = bitmap # 0-2, R$X = screen type (0 = 320x240 needs
*   10 blocks, anything else 320x200, 8 blocks).
* Allocates the bitmap with F$AlHRAM, records it in the V.BMxCl_En /
* V.BMxBlk mirror pair PullBuf programs on every switch, and enables it
* now only if this terminal is live - a shadow terminal owns its mirror
* but not the registers.
* Exit: gr.PDRGS R$X = the bitmap's first block, also on E$WADef (the
*   bitmap already has one).  B = 0, or carry + E$IllArg / E$WADef /
*   E$MFull.
*******************************************************************
* SS.BmAlloc ($E3) and SS.AScrn ($8B) are ONE implementation, and the
* only thing that separates them is the control byte they leave behind.
* SS.BmAlloc allocates and defines and stops there; SS.AScrn additionally
* enables on CLUT 0, because that is its contract and Joust and jstview
* both depend on it - neither ever calls SS.Palet.  Putting the enable in
* the CoCo-named doorway is what lets that doorway be deleted later
* without taking anything else with it.
*
* SS.BmAlloc leaves the bitmap DEFINED BUT OFF on purpose.  The blocks
* hold whatever was in them, so enabling as a side effect of allocating
* means showing garbage; and visibility needs a layer and FX_BM anyway.
GFAScrn             lda       #%00000001          enable, CLUT 0
                    bra       BmAllocGo
SSBmAlloc           clra                          defined, but not enabled
BmAllocGo           sta       >gr.b3              the control byte to leave
                    ldd       >gr.PDRGS+R$Y       bitmap #
                    cmpd      #2
                    bhi       AScrnBad
                    lbsr      SetBlkC2C3          U = this terminal's statics
                    stb       >gr.b2              bitmap #, for the helpers below
                    lslb
                    leax      V.BM0Cl_En,u
                    abx                           X -> V.BMxCl_En, V.BMxBlk at 1,x
                    ldb       1,x
                    beq       AScrnNew
                    clra
                    std       >gr.PDRGS+R$X       return the existing block
                    ldb       #E$WADef
                    bra       AScrnErr
* ALWAYS TEN BLOCKS (user, 2026-09-20).  R$X's screen type is still
* ACCEPTED AND IGNORED - every existing caller passes 0 anyway.
*
* The type is only a REQUEST.  How many rows VICKY actually fetches comes
* from the video mode, independently: TinyVickyCoreModule.v:1000 counts to
* 400 or 480 lines by Video_Mode_i[0] and halves that to 200 or 240 rows,
* against a hard-wired 320-byte stride.  So the two can disagree, and the
* disagreement is not symmetric.  Ten blocks displayed at 70 Hz wastes two
* of them.  EIGHT BLOCKS DISPLAYED AT 60 HZ makes VICKY read 12,800 bytes
* PAST THE END of the allocation and put whoever owns them on the screen.
*
* It cannot be settled at allocation time, because the mode may legally
* change afterwards - joust allocates its bitmaps in GfxInit and sets the
* mode last.  Over-allocating is the only choice under which the wrong
* combination cannot exist, and it costs two blocks of about 2 MB in the
* mode nothing in either tree asks for: every caller passes type 0.
AScrnNew            ldb       #BmBlk240
* The block count is kept on the stack across the allocation because
* SS.FScrn now frees exactly this number instead of re-deriving it from
* the display mode, which may have changed in between.  ,s = the count,
* 1,s = the mirror pointer.  PULS does not touch CC, and SetBlkC2C3 keeps
* it, so the carry from F$AlHRAM survives to the test below.
alloc@              pshs      b,x
                    os9       F$AlHRAM            D = first block
                    lbsr      SetBlkC2C3          remap slot 5 and reload U (keeps D, X, CC)
                    bcc       got@
                    leas      3,s
                    ldb       #E$MFull
                    bra       AScrnErr
got@                ldx       1,s                 the mirror pointer back
                    clra
                    std       >gr.PDRGS+R$X       return the block
                    stb       1,x                 V.BMxBlk
                    lbsr      BmClrOff            a driver-allocated bitmap starts
                    lda       >gr.b3              at offset 0 of its first block
                    sta       ,x                  V.BMxCl_En
                    lbsr      AScrnRec            record the size and the ownership
                    leas      3,s                 done with the count and the pointer
                    tst       V.TermLive,u
                    beq       ok@                 shadow: PullBuf programs it on the switch
                    lbsr      BmEnCore            gr.b3 and the mirror's address
ok@                 clrb
                    jmp       >GrfMod+SysRet
AScrnBad            ldb       #E$IllArg
AScrnErr            coma
                    jmp       >GrfMod+SysRet

*******************************************************************
* AScrnRec - record in V.BMFlags what GFAScrn just allocated: the block
*   count, so SS.FScrn frees exactly this many rather than re-deriving
*   the number from a display mode that may have changed since, and the
*   ownership, so a bitmap the DRIVER allocated is told apart from one
*   SS.BmDef merely points at.
* Entry: U = this terminal's statics, gr.PDRGS+R$Y+1 = the bitmap #, and
*   the block count at 4,s (2 for this bsr's return address, 2 for the D
*   saved below, then GFAScrn's own pshs b,x).
* PRESERVES A AND B, which GFAScrn still needs: A is the control byte it
*   is about to put in gr.b3 and B is the first block it feeds Blk2Addr.
*******************************************************************
AScrnRec            pshs      d
                    lda       >gr.b2              bitmap #
                    lbsr      BmFlagMask          A = its size bit
                    tfr       a,b                 keep the size bit in B
                    lsla
                    lsla
                    lsla
                    lsla                          A = its ownership bit
                    ora       V.BMFlags,u
                    sta       V.BMFlags,u         the driver owns these blocks
                    lda       4,s                 the block count asked for
                    cmpa      #BmBlk200
                    beq       ARsml@
                    comb                          the 10-block size: bit clear
                    andb      V.BMFlags,u
                    stb       V.BMFlags,u
                    puls      d,pc
ARsml@              orb       V.BMFlags,u         the 8-block size: bit set
                    stb       V.BMFlags,u
                    puls      d,pc


*******************************************************************
* GF.GetStt (b27) / GF.SetStt (b28) - every GetStat and SetStat code
*   vtio does not keep itself.  vtio puts the code in gr.b1, aims
*   gr.TermBlk, gr.VBlk and gr.U5, and calls through CallGrfDrvRet: on
*   entry gr.PDRGS holds the caller's registers, and whatever a handler
*   leaves there is copied back to the caller afterwards.
* Handlers run with U = this terminal's statics (SetBlkC2C3) and
*   X = gr.PDRGS, so R$ offsets read as vtio's did off PD.RGS, and end
*   with B/carry the result and jmp >GrfMod+SysRet.
* An unknown code is carry + E$UnkSvc.  SCF's CallComStatus tolerates
*   exactly that, and tmode/xmode depend on it.
*******************************************************************
GFGetStt            leay      GetSttTbl,pcr
                    bra       StatDisp
GFSetStt            leay      SetSttTbl,pcr
StatDisp            lbsr      SetBlkC2C3          U = this terminal's statics
                    ldx       #gr.PDRGS
                    lda       >gr.b1              status code
sdlp@               tst       ,y                  0 ends the table (SS.Opt is 0)
                    beq       StatUnk
                    cmpa      ,y+
                    beq       sdhit@
                    leay      2,y
                    bra       sdlp@
sdhit@              jmp       [,y]
* StatUnk also fills the retired FuncTbl slots 2, 3 and 6.
StatUnk             comb
                    ldb       #E$UnkSvc
                    jmp       >GrfMod+SysRet

* code, handler
GetSttTbl           fcb       SS.ScSiz
                    fdb       GrfMod+GSScSiz
                    fcb       SS.ScTyp
                    fdb       GrfMod+GSScTyp
                    fcb       SS.KySns
                    fdb       GrfMod+GSKySns
                    fcb       SS.LiveKeys
                    fdb       GrfMod+GSLiveKeys
                    fcb       SS.Joy
                    fdb       GrfMod+GSJoy
                    fcb       SS.Mouse
                    fdb       GrfMod+GSMouse
                    fcb       SS.DScrn
                    fdb       GrfMod+GSDScrn
                    fcb       SS.FntChar
                    fdb       GrfMod+GSFntChar
                    fcb       SS.Palet
                    fdb       GrfMod+GSFBRgs
                    fcb       SS.FBRgs
                    fdb       GrfMod+GSFBRgs
                    fcb       SS.DfPal
                    fdb       GrfMod+StatOK
                    fcb       SS.BmBlk
                    fdb       GrfMod+GSBmBlk
                    fcb       SS.BmClear
                    fdb       GrfMod+GSBmClear
                    fcb       SS.BmLine
                    fdb       GrfMod+GSBmLine
                    fcb       0
* The bitmap calls go first: StatDisp searches this table linearly, and a
* game's set-up walks all of them.
SetSttTbl           fcb       SS.AScrn
                    fdb       GrfMod+GFAScrn
                    fcb       SS.BmAlloc
                    fdb       GrfMod+SSBmAlloc
                    fcb       SS.BmDef
                    fdb       GrfMod+SSBmDef
                    fcb       SS.BmCfg
                    fdb       GrfMod+SSBmCfg
                    fcb       SS.BmKill
                    fdb       GrfMod+SSBmKill
                    fcb       SS.BmClear
                    fdb       GrfMod+SSBmClear
                    fcb       SS.BmLine
                    fdb       GrfMod+SSBmLine
                    fcb       SS.GfxAlloc
                    fdb       GrfMod+SSGfxAlloc
                    fcb       SS.GfxFree
                    fdb       GrfMod+SSGfxFree
                    fcb       SS.DfPal
                    fdb       GrfMod+GFDfPal
                    fcb       SS.FntChar
                    fdb       GrfMod+SSFntChar
                    fcb       SS.DScrn
                    fdb       GrfMod+SSDScrn
                    fcb       SS.PScrn
                    fdb       GrfMod+SSPScrn
                    fcb       SS.Palet
                    fdb       GrfMod+SSPalet
                    fcb       SS.FScrn
                    fdb       GrfMod+SSFScrn
                    fcb       SS.TermSel
                    fdb       GrfMod+SSTermSel
                    fcb       SS.SprReg
                    fdb       GrfMod+SSSprReg
                    fcb       SS.SprPush
                    fdb       GrfMod+SSSprPush
                    fcb       SS.TsSet
                    fdb       GrfMod+SSTsSet
                    fcb       SS.TmSet
                    fdb       GrfMod+SSTmSet
                    fcb       SS.TmScrl
                    fdb       GrfMod+SSTmScrl
                    fcb       SS.ClutWrite
                    fdb       GrfMod+SSClutWrite
                    fcb       0

* GetStat SS.ScSiz - R$X = columns, R$Y = rows
GSScSiz             clra
                    ldb       V.WWidth,u
                    std       R$X,x
                    ldb       V.WHeight,u
                    std       R$Y,x
* GetStat SS.DfPal - nothing to return
StatOK              clrb
                    jmp       >GrfMod+SysRet

* GetStat SS.ScTyp - R$A = screen type
GSScTyp             lda       V.ScTyp,u
                    bra       RetA
* GetStat SS.KySns - R$A = key sense bits at the last character read
GSKySns             lda       V.KySns,u
RetA                sta       R$A,x
                    bra       StatOK

* GetStat SS.LiveKeys - the keyboard as a game sees it.  R$A = the key
* sense bits as the keyboard driver holds them now (D.KySns: Shift, Ctrl,
* Alt, arrows, space); R$X/R$Y/R$U = the six gr.KeyLive slots: the
* unshifted codes of the ordinary keys held down now, unordered, 0 = an
* empty slot.  All read 0 when this terminal is not live.  It also empties
* the terminal's input buffer, live or not: a program reading live keys
* does not want queued characters, and they would reach the shell when it
* exits.  Moving the tail to the head is safe unmasked - the keyboard ISR
* moves only the head, so a key that lands in between simply stays queued.
* SS.KySns stays as it is: it is buffered with each character, and fm and
* hexed rely on that.  Y is free: StatDisp dispatched here with jmp [,y].
GSLiveKeys          lda       V.IBufH,u           empty the input buffer
                    sta       V.IBufT,u
                    tst       V.TermLive,u
                    bne       lklive@
                    clra                          not live: nothing held
                    clrb
                    std       R$X,x
                    std       R$Y,x
                    std       R$U,x
                    bra       RetA
lklive@             ldy       #gr.KeyLive
                    ldd       ,y
                    std       R$X,x
                    ldd       2,y
                    std       R$Y,x
                    ldd       4,y
                    std       R$U,x
                    lda       >D.KySns
                    bra       RetA

* GetStat SS.Palet, SS.FBRgs - R$A = foreground/background, R$X = 0 (border)
GSFBRgs             lda       V.FBCol,u
                    clr       R$X,x
                    clr       R$X+1,x
                    bra       RetA

* GetStat SS.DScrn - R$X = MCR low byte, R$Y = MCR high byte.  From the
* mirror, not the registers: they hold the LIVE terminal's state, which is
* not this caller's on a shadow terminal, and they do not read back.
GSDScrn             clra
                    ldb       V.V_MCR,u
                    std       R$X,x
                    ldb       V.V_MCR+1,u
                    std       R$Y,x
                    bra       StatOK

* GetStat SS.Mouse - R$X/R$Y = position, R$A = buttons
GSMouse             lda       MS_XH
                    ldb       MS_XL
                    std       R$X,x
                    lda       MS_YH
                    ldb       MS_YL
                    std       R$Y,x
                    lda       V.MSButtons,u
                    bra       RetA

* GetStat SS.Joy - R$X = the mode (JY.* modes, wildbits.d; spec in joust
*   docs/grfdrv256-api.md).  Above 6: E$IllArg.
*   0, 1  one Atari stick, compatibility: R$X = 0 left, 128 centered, 255
*         right, R$Y = 0 up, 128 centered, 255 down, R$A = buttons 0-2 in
*         bits 0-2 (1 = pressed); all three always set.
*   2     both sticks: R$X = stick 0, R$Y = stick 1, as JY.* bits.
*   3, 4  NES / SNES pads 0 and 1: R$X, R$Y = their JY.* words.
*   5, 6  NES / SNES pads 0-3: four JY.* words (big-endian) into the
*         8-byte buffer at R$Y; E$IllArg if it runs off the caller's map.
* The sticks: VIA0 port B = header 0, port A = header 1, bits 0-6 = up,
* down, left, right, buttons 0-2, 0 = closed (F256 manual, chapter 12) -
* already the JY.* order, so a coma and a mask.  A terminal that is not
* live reads nothing held (modes 0 and 1: centered) and leaves the pad
* port alone.  Y is free: StatDisp dispatched here with jmp [,y].
GSJoy               ldd       R$X,x               the mode
                    cmpd      #JOY.SNES4
                    lbhi      joyerr
                    cmpb      #JOY.Sticks
                    lbhs      JoyNew
                    lda       #$FF                not live: all switches open
                    tst       V.TermLive,u
                    beq       j1@
                    lda       VIA0.Base+VIA_ORB_IRB header 0
                    tstb
                    beq       j1@
                    lda       VIA0.Base+VIA_ORA_IRA header 1
j1@                 coma                          1 = closed
                    ldb       #128                vertical
                    bita      #%00000001
                    beq       j2@
                    clrb                          up
j2@                 bita      #%00000010
                    beq       j3@
                    ldb       #255                down
j3@                 clr       R$Y,x
                    stb       R$Y+1,x
                    ldb       #128                horizontal
                    bita      #%00000100
                    beq       j4@
                    clrb                          left
j4@                 bita      #%00001000
                    beq       j5@
                    ldb       #255                right
j5@                 clr       R$X,x
                    stb       R$X+1,x
                    lsra
                    lsra
                    lsra
                    lsra
                    anda      #%00000111          buttons 0-2
                    lbra      RetA
joyerr              comb
                    ldb       #E$IllArg
                    jmp       >GrfMod+SysRet

* Modes 2-6.  The words are built in an 8-byte frame, zero unless live,
*   then go to R$X/R$Y or the caller's buffer.  B = the mode.
JoyNew              leas      -8,s                ,s = the four words
                    clra
                    sta       ,s
                    sta       1,s
                    sta       2,s
                    sta       3,s
                    sta       4,s
                    sta       5,s
                    sta       6,s
                    sta       7,s
                    tst       V.TermLive,u
                    beq       jnout@              not live: nothing held, the port untouched
                    cmpb      #JOY.Sticks
                    bne       jnpad@
                    lda       VIA0.Base+VIA_ORB_IRB stick 0
                    coma
                    anda      #%01111111
                    sta       1,s
                    lda       VIA0.Base+VIA_ORA_IRA stick 1
                    coma
                    anda      #%01111111
                    sta       3,s
                    bra       jnout@
jnpad@              pshs      b
                    lbsr      PadRead             the words at 1,s
                    puls      b
jnout@              cmpb      #JOY.NES4
                    bhs       jnbuf@
                    ldd       ,s                  modes 2-4: registers
                    std       R$X,x
                    ldd       2,s
                    std       R$Y,x
                    leas      8,s
                    lbra      StatOK
jnbuf@              ldd       R$Y,x               modes 5 and 6: the caller's buffer
                    ldy       #8
                    lbsr      MapCallBuf          U = the buffer through slot 1
                    bcs       jnbad@
                    tfr       u,y
                    tfr       s,u
                    ldd       #8
                    lbsr      CpyBlk
                    leas      8,s
                    lbra      StatOK
jnbad@              leas      8,s
                    bra       joyerr

* PadRead - read the pad port into the 8-byte word frame at 3,s (the
*   caller's 1,s under this return address).  B = mode 3-6: 3 and 5 NES,
*   4 and 6 SNES.  If the port is off or set to the other type it is set
*   and triggered, and the words stay zero: the first reading after a
*   change is empty.  Otherwise the reading is taken once NES_DONE is set
*   (it takes microseconds, so a frame apart it always is; the loop is for
*   callers faster than that), then the next reading is triggered, so no
*   call waits for its own.  Uses A, B, Y, U.
PadRead             lda       #NES_EN
                    andb      #1                  3, 5 odd = NES; 4, 6 even = SNES
                    bne       nes@
                    ora       #NES_MODE
nes@                pshs      a                   ,s = the control byte wanted
                    lda       NES.Base+NES_CTRL
                    anda      #NES_EN+NES_MODE
                    cmpa      ,s
                    bne       trig@               off or the wrong type
                    ldy       #256                about 600 us at most
wait@               lda       NES.Base+NES_CTRL
                    bita      #NES_DONE
                    bne       done@
                    leay      -1,y
                    bne       wait@
                    bra       trig@               no reading: leave them zero
done@               ldu       #NES.Base+NES_PAD0
                    leay      4,s                 Y = the frame (4,s under ,s and the return)
                    lda       #4
                    pshs      a,y                 ,s = pads left, 1,s = the frame
pad@                lda       ,u                  the first byte
                    coma                          1 = pressed
                    ldb       1,u                 SNES: A X L R in the low nibble
                    comb
                    andb      #%00001111
                    pshs      a
                    lda       4,s                 the control byte wanted
                    bita      #NES_MODE
                    puls      a
                    bne       snes@
                    clrb                          NES: the second byte is not a pad's
snes@               bsr       PadWord
                    ldy       1,s
                    std       ,y++
                    sty       1,s
                    leau      2,u
                    dec       ,s
                    bne       pad@
                    leas      3,s
trig@               puls      a
                    ora       #NES_TRIG           start the next reading
                    sta       NES.Base+NES_CTRL
                    rts

* PadWord - one pad's port bytes as a JY.* word.
* Entry: A = the first byte, B = the second byte's low nibble (0 for NES),
*        both already 1 = pressed.
* Exit:  D = the word (A = high byte).  Uses Y.
* The port sends the directions reversed (up in bit 3), and the buttons in
* serial order; Rev4 turns a nibble round and the shifts place the rest:
*   rev(A >> 4) = button 0, button 1, Select, Start in bits 0-3
*   rev(A & $F) = up, down, left, right
*   rev(B)      = SNES A, X, L, R
PadWord             pshs      d                   ,s = first byte, 1,s = nibble
                    leay      Rev4,pcr
                    lsra
                    lsra
                    lsra
                    lsra
                    lda       a,y                 buttons 0, 1, Select, Start
                    tfr       a,b
                    lsrb
                    lsrb                          B = Select, Start: high byte bits 0-1
                    anda      #%00000011
                    lsla
                    lsla
                    lsla
                    lsla                          buttons 0, 1: bits 4-5
                    pshs      a                   ,s = low byte so far
                    lda       1,s
                    anda      #%00001111
                    lda       a,y                 up, down, left, right: bits 0-3
                    ora       ,s
                    sta       ,s
                    lda       2,s
                    lda       a,y                 SNES A, X, L, R in bits 0-3
                    pshs      a
                    anda      #%00000011          A, X: low byte bits 6-7
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       1,s
                    sta       1,s
                    puls      a
                    anda      #%00001100          L, R: already high byte bits 2-3
                    pshs      b
                    ora       ,s+
                    ldb       ,s                  the low byte
                    leas      3,s
                    rts

Rev4                fcb       %0000,%1000,%0100,%1100,%0010,%1010,%0110,%1110
                    fcb       %0001,%1001,%0101,%1101,%0011,%1011,%0111,%1111

* SetStat SS.DScrn - R$X+1 = MCR low byte, R$Y+1 = MCR high byte;
* FX_OMIT/FT_OMIT leave that byte alone.  The mirror always, the register
* only for the live terminal: PullBuf programs $FFC0-$FFCF from V.V_MCR
* when a shadow terminal comes up.
SSDScrn             lda       R$X+1,x
                    ldb       R$Y+1,x
                    ldy       #TXT.Base
                    cmpa      #FX_OMIT
                    beq       hi@
                    sta       V.V_MCR,u
                    tst       V.TermLive,u
                    beq       hi@
                    sta       MASTER_CTRL_REG_L,y
hi@                 cmpb      #FT_OMIT
                    beq       ok@
                    stb       V.V_MCR+1,u
                    tst       V.TermLive,u
                    beq       ok@
                    stb       MASTER_CTRL_REG_H,y
ok@                 lbra      StatOK

* SetStat SS.PScrn - R$X = layer 0-2, R$Y+1 = bitmap # 0-2 or tile map 4-6.
* V.V_LayerCTL is both source and destination: the register never reads
* back, and it holds the live terminal's layers.  Written only when live.
*
* SOURCE 3 OR 7 BLANKS THE LAYER, and that is worth knowing because it is
* the only way to hide a bitmap today.  The core decodes the source as
* {Slot_Type, Plane_2_Render} and 3'b011 / 3'b111 fall to the default arm,
* which sets Actual_BM_Enabled = 0 AND Actual_TM_Enabled = 0
* (TinyVickyCoreModule.v:775-782).  wildbits_vtio.d documents only 000-110,
* so nobody has used it.  Layer 0 is in FRONT; layer 2 is furthest back.
* The source is MASKED to three bits.  It used to be added in whole, so a
* value of 8 or more carried straight into the neighbouring layer's field
* and silently repointed it.  Nothing in the tree passes one, but nothing
* stopped it either.
SSPScrn             ldy       R$X,x
                    lda       V.V_LayerCTL,u
                    cmpy      #0
                    bne       l1@
                    anda      #%11111000          layer 0: bits 2:0
                    pshs      a
                    lda       R$Y+1,x
                    anda      #%00000111
                    ora       ,s+
                    bra       st0@
l1@                 cmpy      #1
                    bne       l2@
                    anda      #%10001111          layer 1: bits 6:4
                    pshs      a
                    lda       R$Y+1,x
                    anda      #%00000111
                    ldb       #16
                    mul
                    addb      ,s+
                    tfr       b,a
st0@                sta       V.V_LayerCTL,u
                    tst       V.TermLive,u
                    beq       ok@
                    sta       VKY_LAYER_CTRL_0
                    bra       ok@
l2@                 cmpy      #2
                    bne       ok@
                    lda       V.V_LayerCTL+1,u
                    anda      #%11111000          layer 2: bits 2:0
                    ldb       R$Y+1,x
                    andb      #%00000111
                    pshs      a
                    orb       ,s+
                    stb       V.V_LayerCTL+1,u
                    tst       V.TermLive,u
                    beq       ok@
                    stb       VKY_LAYER_CTRL_1
ok@                 lbra      StatOK

* SetStat SS.Palet - R$Y = bitmap # 0-2, R$X+1 = CLUT # 0-3.  GF.BmPalet
* rewrites the whole control byte, so the mirror takes the same value or
* the next PullBuf undoes the assignment (and, with the enable bit in that
* byte, turns the bitmap off).
SSPalet             ldd       R$Y,x
                    cmpd      #2
                    bhi       BmBad
                    stb       >gr.b2              bitmap # 0-2
                    lslb                          two mirror bytes per bitmap
                    leay      V.BM0Cl_En,u
                    leay      b,y
                    ldb       R$X+1,x             CLUT #
                    orcc      #Carry
                    rolb                          CLUT# | enable
                    andb      #%00001111          enable and CLUT only
* Keep HIRES4 and GROUP.  This used to rewrite the WHOLE control byte, so
* once those bits meant something, assigning a CLUT would have silently
* dropped a bitmap out of 640x240 4bpp mode.  It still forces the enable
* bit on, which is its long-standing contract and what shellbg, drawtest,
* pixview and view all rely on; SS.BmCfg is the call that can leave it
* alone, and the one to use in new code.
                    lda       ,y
                    anda      #%11110000
                    pshs      a
                    orb       ,s+
                    stb       >gr.b3
                    stb       ,y                  V.BMxCl_En
                    tst       V.TermLive,u
                    lbne      GFBmPalet           live: program it now
                    lbra      StatOK
BmBad               comb
                    ldb       #E$IllArg
                    jmp       >GrfMod+SysRet

* SetStat SS.FScrn - R$Y = bitmap # 0-2.  Frees its blocks, clears the
* V.BMxCl_En/V.BMxBlk mirror pair (the mirror, not the register) and
* zeroes the bitmap registers if the terminal is live.
*
* IT NOW FREES EXACTLY WHAT WAS ALLOCATED.  It used to take the count
* from the CURRENT display mode's CLK_70 bit while GFAScrn took it from
* the CALLER'S screen type - two sources of truth for one number.  A
* program that changed the display mode in between freed the wrong count:
* too few leaked two blocks, and too many handed two LIVE blocks back to
* the free pool while their owner was still using them, which is memory
* corruption rather than a leak.  src/gfx.a and jstview both worked around
* it by freeing their bitmaps before restoring the display mode, in a
* comment that explained the symptom and not the cause.  The count now
* comes from V.BMFlags, where GFAScrn recorded it.
* IT ALSO FREES ONLY WHAT THE DRIVER OWNS.  A bitmap the program pointed
* at its own blocks with SS.BmDef is undefined and switched off, and its
* blocks are left strictly alone - they are the program's to free with
* SS.GfxFree or F$DelRAM.  That is the whole of the ownership rule:
* whoever allocated, frees, and the driver knows which it was without the
* caller having to say.
*
* SS.BmKill dispatches here too - the two codes are one handler, not two
* implementations.
SSFScrn
SSBmKill            ldd       R$Y,x
                    cmpd      #2
                    bhi       BmBad
                    stb       >gr.b2              bitmap # 0-2
                    lslb
                    leay      V.BM0Cl_En,u
                    leay      b,y                 Y -> V.BMxCl_En, V.BMxBlk at 1,y
                    ldb       1,y
                    bne       defd@
                    ldb       #E$WUndef           no bitmap defined
                    coma
                    jmp       >GrfMod+SysRet
defd@               lda       >gr.b2              bitmap #
                    lbsr      BmFlagMask          A = its bit in V.BMFlags
                    pshs      a                   ,s = its size bit
                    lsla
                    lsla
                    lsla
                    lsla                          A = its ownership bit
                    anda      V.BMFlags,u
                    beq       undef@              the program's blocks: not ours
                    clra
                    ldb       1,y                 its first block
                    tfr       d,x                 X = first block
                    ldb       ,s                  its size bit
                    andb      V.BMFlags,u
                    beq       ten@                clear = the 10-block size
                    ldb       #BmBlk200
                    bra       del@
ten@                ldb       #BmBlk240
del@                pshs      y
                    os9       F$DelRAM
                    lbsr      SetBlkC2C3          remap slot 5 and reload U
                    puls      y
undef@              leas      1,s                 drop the size bit
                    clr       ,y                  both mirror bytes, or PullBuf
                    clr       1,y                 re-enables a freed bitmap
                    lbsr      BmFlagClr           no longer owned, no longer small
                    lbsr      BmClrOff            and no longer at any offset
                    tst       V.TermLive,u
                    lbne      GFBmFree            live: zero the registers
                    lbra      StatOK

*******************************************************************
* SetStat SS.BmCfg ($ED) - configure one bitmap.  THE call that was
*   missing, and the reason this rework happened.
*   R$Y      = bitmap # (0-2)
*   R$X high = enable: 0 off, 1 on, $FF leave alone
*   R$X low  = CLUT #: 0-3, $FF leave alone
*   R$U high = HIRES4: 0 off, 1 on (640x240 4bpp), $FF leave alone
*   R$U low  = palette GROUP: 0-7, $FF leave alone
*
* Until now NOTHING COULD HIDE A BITMAP AND KEEP IT.  SS.AScrn set the
* enable bit as a side effect of allocating, SS.FScrn cleared it only by
* freeing the memory, and SS.Palet FORCED IT ON every time it assigned a
* CLUT - so assigning a CLUT silently re-enabled a bitmap and there was no
* way at all to turn one off.  Joust pays about 164 ms clearing both its
* bitmaps at every screen transition where a hide would have done, while
* doing exactly that cheap hide for the tile map beside them (src/gfx.a
* SCCLR).  That asymmetry is the whole argument for this call.
*
* $FF means "leave this field alone", the same convention SS.DScrn's
* FX_OMIT/FT_OMIT already use, so one call sets everything at start-up and
* the same call toggles one field later without disturbing the rest.
*
* Visibility needs THREE independent things and this is only one of them:
* the enable bit here, a layer pointing at the bitmap (SS.Layer), and
* FX_BM in the master control register (SS.MCR).
*******************************************************************
SSBmCfg             ldd       R$Y,x               bitmap #
                    cmpd      #2
                    lbhi      BmBad
                    stb       >gr.b2
                    lslb
                    leay      V.BM0Cl_En,u
                    leay      b,y                 Y -> V.BMxCl_En
                    lda       ,y                  the control byte as it stands
* Enable, bit 0.
                    ldb       R$X,x
                    cmpb      #$FF
                    beq       bcclut@
                    anda      #%11111110
                    tstb
                    beq       bcclut@
                    ora       #%00000001
bcclut@             ldb       R$X+1,x             CLUT #, bits 3:1
                    cmpb      #$FF
                    beq       bchi@
                    cmpb      #3
                    lbhi      BmBad
                    anda      #%11110001
                    lslb
                    pshs      b
                    ora       ,s+
bchi@               ldb       R$U,x               HIRES4, bit 4
                    cmpb      #$FF
                    beq       bcgrp@
                    anda      #%11101111
                    tstb
                    beq       bcgrp@
                    ora       #%00010000
bcgrp@              ldb       R$U+1,x             palette GROUP, bits 7:5
                    cmpb      #$FF
                    beq       bcset@
                    cmpb      #7
                    lbhi      BmBad
                    anda      #%00011111
                    lslb
                    lslb
                    lslb
                    lslb
                    lslb
                    pshs      b
                    ora       ,s+
bcset@              sta       ,y                  the mirror always
                    tst       V.TermLive,u
                    lbeq      StatOK              a shadow: PullBuf programs it
                    sta       >gr.b3
                    lbsr      BmEnCore            live: control byte and address
                    lbra      StatOK

*******************************************************************
* SetStat SS.BmDef ($E6) - point a bitmap at memory the PROGRAM owns.
*   R$Y high = mode: bit 0 HIRES4, bits 3:1 palette GROUP
*   R$Y low  = bitmap # (0-2)
*   R$X      = block number, or 0 to clear this bitmap
*   R$U      = offset within that block, $0000-$1FFF
*
* The same addressing rule the tile calls have used since the tile rework
* (docs/tile-api.md): a block and an offset, never a 24-bit address, with
* the driver doing the multiply.  A bitmap was the one asset whose address
* the API could not express that way, so a program that allocated one slab
* for a slew of assets had to spend a whole block boundary on the bitmap.
*
* The blocks stay the PROGRAM's.  This never sets the ownership bit, so
* SS.BmKill and a terminal close undefine the bitmap and leave the memory
* alone.  The lifetime rule that applies to every asset the hardware reads
* directly applies here too: switch it off before you free it, or VICKY
* goes on drawing whatever the next owner puts there.
*
* It does NOT touch the enable or CLUT bits, so pointing a bitmap at new
* pixels never makes it appear by itself - that is SS.BmCfg's job.
*******************************************************************
SSBmDef             ldd       R$Y,x               A = mode, B = bitmap #
                    cmpb      #2
                    lbhi      BmBad
                    stb       >gr.b2
                    ldd       R$U,x               offset within the block
                    cmpd      #$1FFF
                    lbhi      BmBad
                    ldd       R$X,x               block
                    tsta
                    lbne      BmBad               a block number is one byte
* Refuse to re-point a bitmap whose blocks the DRIVER allocated: nothing
* would ever free them again.  SS.BmKill first.
                    lda       >gr.b2
                    lbsr      BmFlagMask
                    lsla
                    lsla
                    lsla
                    lsla                          A = its ownership bit
                    anda      V.BMFlags,u
                    beq       bdset@
                    ldb       #E$WADef            the driver's - kill it first
                    coma
                    jmp       >GrfMod+SysRet
bdset@              lda       >gr.b2
                    lsla                          two offset bytes per bitmap
                    leay      V.BM0Off,u
                    leay      a,y
                    ldd       R$U,x
                    std       ,y                  its offset
                    lda       >gr.b2
                    lsla                          two mirror bytes per bitmap
                    leay      V.BM0Cl_En,u
                    leay      a,y                 Y -> V.BMxCl_En, block at 1,y
                    ldb       R$X+1,x             its block
                    stb       1,y
                    bne       bdmode@
                    clr       ,y                  block 0 clears the bitmap outright
                    bra       bdlive@
bdmode@             lda       R$Y,x               mode
                    anda      #%00001111
                    lsla
                    lsla
                    lsla
                    lsla                          HIRES4 to bit 4, GROUP to 7:5
                    ldb       ,y
                    andb      #%00001111          keep the enable and CLUT bits
                    stb       ,y
                    ora       ,y
                    sta       ,y
bdlive@             tst       V.TermLive,u
                    lbeq      StatOK              a shadow: PullBuf programs it
                    lda       ,y                  the control byte
                    sta       >gr.b3
                    lbsr      BmEnCore
                    lbra      StatOK

*******************************************************************
* SetStat SS.BmClear ($E5) - fill a bitmap with one colour, using the
*   rc16's DMA engine.
*   R$Y low  = bitmap # (0-2)
*   R$Y high = ARMING LINE.  0 = arm as soon as the arguments are ready,
*              which is what every shipping caller passes and what this
*              has always done; 1-255 = wait for that raster line first.
*              It exists to MEASURE the vertical-blanking window rather
*              than to avoid it - see DMA_ArmWrap in wildbits.d.
*   R$A out  = the line it ACTUALLY armed on, $FF if past 255.  An
*              interrupt during the spin costs several lines, so this and
*              the line asked for are different numbers and only this one
*              is a measurement.  Set on every call, free-running too.
*   R$X high = FLAGS.
*                bit 0    do a 16-bit transfer
*                bits 3-1 RESERVED, must be 0
*                bits 6-4 the WAIT MODE, DmaWt.* in wildbits.d: 0 arm and
*                         return (the default, and what every shipping
*                         caller passes), 1 CWAI, 2 CWAI + re-check,
*                         3 SYNC, 4 register loop, 5 I/O loop, 6 RAM
*                         loop, 7 poll the status register
*                bit 7    RESERVED, must be 0
*              Mode 7 is the SHIPPING wait on a core with the DMA fix
*              (2026-09-22): it returns when the fill is done, or
*              E$DevBsy if it never finishes.  Modes 1-6 are DIAGNOSTICS for dmafilltest and
*              bmtest.  On an unfixed core, 4-7 wedge the machine.  This
*              was a bitmask until 2026-09-21 and the note beside DmaWt.*
*              says why it stopped being one.
*              16-bit is twice the rate, 384 us against 768 for a
*              whole bitmap, and it is a SEPARATE PATH THROUGH THE ENGINE
*              - Double_Speed_DMA, with its own end comparison and its
*              own byte-lane handling - so it is opt-in until it has been
*              run.  A 16-bit request against an ODD destination is
*              quietly done 8-bit, because the engine masks address bit 0
*              and would otherwise write the byte before the bitmap.
*   R$X low  = the fill value (a CLUT index; 0 = transparent)
*   R$U high = FIRST ROW, 0-239
*   R$U low  = ROWS to fill.  0 means "to the end of the bitmap", which
*              is the whole 240 when the first row is 0.
*
* THE FIRST ROW IS BACKWARD COMPATIBLE.  R$U's high byte used to have to
* be zero and every caller passed it that way, so every one of them still
* means "start at row 0" and behaves exactly as before.  It is there so a
* caller can clear a BAND - which is what Joust's SCCLR actually wants -
* and so a big fill can be split, which is what asked for it.
*
* THE ROW COUNT EXISTS BECAUSE THE ENGINE CANNOT SAFELY BE INTERRUPTED.
* If a transfer does not finish inside one vertical-blanking window the
* state machine parks in WAIT_NEXT_SOF with Write_Strobe STILL HIGH, and
* the destination pointer goes on incrementing every 100 MHz clock for
* the whole visible frame - about 1.5 million clocks, some 3 MB past the
* end.  On resume Write_Reached_End is already false, so it reports
* complete having written only part of the bitmap, and the writes it made
* while running away landed wherever the pointer had got to.  So the
* caller must ask for an amount that FITS, and until the real throughput
* is measured only the caller knows what that is.
*
* ASYNCHRONOUS.  Carry clear means ACCEPTED, not done.  The call arms
* the engine and returns; THE CALLER MUST F$Sleep AND THEN READ THE
* STATUS, and must do nothing else in between - any CPU bus activity
* when HALT asserts can wedge the machine unrecoverably.  The rule and
* the evidence are beside DMA_STATUS_TRF_IP in wildbits.d.
*
* IT WAS BRIEFLY MADE SYNCHRONOUS, parking here with CWAI so the caller
* needed no rule, and a second clear started before the first reported
* complete crashed the machine.  BLOCKING HERE IS NOT THE REASON:
* grfdrv is designed to be synchronous and process one call at a time,
* so holding it is what it is for (user, 2026-09-21).
*
* The reason is that A BARE CWAI IS WOKEN BY ANY INTERRUPT.  A keypress
* wakes it long before the transfer window opens, and the CPU is then
* executing when HALT asserts.  Worse, the 60 Hz tick fires at line 0 -
* the same instant HALT asserts - so every frame the CPU is woken into
* the clock ISR at exactly the wrong moment.  Parking reduces exposure;
* it does not remove it, and no arrangement of software can, because
* interrupts are asynchronous and one of them coincides with the halt
* by construction.
*
* Bit 6 is the answer being tried: park, read the status, park again if
* it still says busy - so a spurious wake costs one lda instead of
* leaving the CPU running.  If that holds up it should become the
* default and this call becomes synchronous again.
*
* GetStat SS.BmClear remains, but only as a diagnostic: it reports the
* destination the engine holds, and by the time anyone can call it the
* transfer is long over.
*
* IT ALWAYS FILLS BmPixels (76,800) BYTES - see the note beside that equ
* in wildbits_vtio.d for why that is neither the allocation nor what the
* current video mode fetches.
*
* WHY THIS IS A DRIVER CALL AT ALL: $FEC0 is inside $FD00-$FFFF, which is
* not in a Level 2 process's address space.  A program cannot reach the
* DMA at any price, and clearing a bitmap by hand costs ~82 ms.
*
* THE BUSY CHECK IS ALSO THE CORE CHECK, and no start-up probe is needed.
* On a core whose DMA halt is not wired to Drive_RDY the transfer machine
* waits for ever in CPU_STOPPED_ST0 - which sits in front of every state
* that raises Write_Strobe - so it writes NOTHING and the busy bit never
* clears.  A caller whose fill never completes therefore learns the
* engine is dead with nothing corrupted, and every later call fails
* loudly with E$DevBsy instead of the first one lying.
*
* A BACKGROUND TERMINAL MAY CLEAR ITS BITMAP: the destination comes from
* the mirror, not from the live registers.  SS.BmLine cannot, and that
* difference is exactly why.
*******************************************************************
SSBmClear           ldd       R$Y,x               A = arming line, B = bitmap # 0-2
                    cmpb      #2
                    lbhi      BmBad
                    stb       >gr.b2
* The arming line rides in gr.d2, which no part of this call uses, until
* the parameter block exists to put it in.
                    sta       >gr.d2
                    ldd       R$X,x               A = flags, B = the fill value
                    bita      #DmaWt.Rsvd         bit 0 is the width; 6-4 the wait mode
                    lbne      BmBad
                    sta       >gr.d1              the width flag
                    stb       >gr.b3
* The first row and the row count, and the band they describe has to fit
* inside the bitmap.
                    ldd       R$U,x               A = first row, B = row count
                    cmpa      #BmPixels/320-1
                    lbhi      BmBad               a first row past the last one
                    sta       >gr.b5
                    tstb
                    bne       bcrow@
                    ldb       #BmPixels/320       0 = to the end of the bitmap
                    subb      >gr.b5
                    bra       bcrow2@
* first + count must not run off the end, and that sum reaches 494, so it
* is checked in 16 bits rather than in B.
bcrow@              pshs      b
                    ldb       >gr.b5
                    clra
                    addb      ,s
                    adca      #0
                    cmpd      #BmPixels/320
                    puls      b                   PULS leaves the flags alone
                    lbhi      BmBad
bcrow2@             stb       >gr.b4              the row count
                    lda       DMA.Base+DMA_STATUS_REG
                    lbmi      BmClrBsy            a fill is still outstanding
                    lda       >gr.b2
                    lbsr      BmGetAddr           A = block, X = offset
                    tsta
                    lbeq      BmClrUnd            no blocks: nothing to fill
* Build DmaFill's parameter block.  X stopped being the caller's register
* image at BmGetAddr, which is why nothing below uses it.
                    leas      -12,s
                    ldb       >gr.b3
                    stb       6,s                 the fill value
                    ldb       >gr.d1
                    stb       7,s                 the width flag
                    ldb       >gr.d2
                    stb       11,s                the arming line, 0 = free-running
* THE DESTINATION FIRST, while A is still the block BmGetAddr returned.
* The row arithmetic below uses MUL, and MUL DESTROYS A - putting it
* first cost a hardware run: the block $E2 became the $3A that rows*64
* left in A, so Blk2Addr produced $07 where it should have produced $1C
* and the engine filled $075000 instead of $1C5000.  Low memory, not the
* bitmap, which is why nothing appeared and the machine fell over.
* block*$2000 + offset - the same arithmetic as BmRegAddr, and the same
* argument that it cannot carry out of the high byte.
                    clrb
                    lbsr      Blk2Addr            D = address bits 23:8
                    sta       ,s                  destination bits 23:16
                    tfr       b,a
                    clrb                          D = bits 15:0, low 13 clear
                    leax      d,x                 X = that plus the offset
                    stx       1,s                 destination bits 15:8 and 7:0
* THE FIRST ROW'S OFFSET, built in 7,8,9 and added in 24 bits.  This is
* the one place a carry out of the middle byte is real: the argument that
* a bitmap offset cannot carry rests on the block part's low 13 bits
* being zero, and firstrow*320 reaches $12AC0, which is far larger than
* an offset ever is.
                    lda       >gr.b5              the first row
                    leax      8,s
                    lbsr      Rows2Byt
                    ldd       1,s
                    addd      9,s
                    std       1,s                 STD leaves the carry alone
                    lda       ,s
                    adca      8,s
                    sta       ,s
* NOW the count, because from here A is expendable.
                    lda       >gr.b4              rows
                    leax      3,s
                    lbsr      Rows2Byt
                    leax      ,s
                    lbsr      DmaFill             armed; it runs in the next vblank
* HAND BACK THE LINE IT ACTUALLY ARMED ON, not the one that was asked
* for.  An interrupt during the spin costs several lines, so the two are
* different numbers and only the second one is a measurement.  X stopped
* being the caller's register image at BmGetAddr, which is why this goes
* through gr.PDRGS - the same way SS.BmLine returns its drawn count.
                    lda       11,s
                    sta       >gr.PDRGS+R$A
                    leas      12,s
* THE EXPERIMENT, bit 1 of the flags, and it is OFF unless asked for.
* A driver-side POLL of $FEC1 wedges the machine at once; sleeping and
* polling afterwards is reliable.  What that cannot tell apart is
* whether the harm is EXECUTING during the pending window or TOUCHING
* THE DMA'S OWN REGISTERS during it, because the poll did both.
*
* This loop does the first and not the second.  "leay -1,y / bne" is 7
* cycles - 4 instruction fetches from this module's code, 3 dead cycles
* - so it hits fetch boundaries at the same rate the poll did, while
* never going near $FEC0-$FECF.  It does NOT read the status afterwards:
* the caller still sleeps and polls as before, so the only new thing
* under test is the executing.
*
* Survives  -> the hazard is the register access, and a caller may work
*              during the window as long as it stays away from the DMA.
* Wedges    -> the hazard is executing at all, and only the woken-from-
*              idle path is safe.
* THE WAIT MODE IS A NUMBER NOW, not a mask - see DmaWt.* in wildbits.d
* for why.  Every branch here is long: this block sits in front of all
* seven wait routines, and inserting into this file has put short
* branches out of range twice already.
                    lda       >gr.d1
                    lsra
                    lsra
                    lsra
                    lsra
                    anda      #DmaWt.Mask
                    lbeq      bcnod@              0: ARM AND RETURN, the default
                    cmpa      #DmaWt.Cwai
                    lbeq      bccwai@
                    cmpa      #DmaWt.CwChk
                    lbeq      bccwck@
                    cmpa      #DmaWt.Sync
                    lbeq      bcsync@
                    cmpa      #DmaWt.Reg
                    lbeq      bcdly@
                    cmpa      #DmaWt.Io
                    lbeq      bcdio@
                    cmpa      #DmaWt.Ram
                    lbeq      bcdram@
                    lbra      bcpoll@             7: poll the status register
* THE DEFAULT, AND WHY THIS CALL IS SYNCHRONOUS: park the CPU until the
* transfer has run.  CWAI puts it at $FFFF with rAVMA = 0 - NO VALID BUS
* CYCLES - and waits for an interrupt.  The 60 Hz tick fires at line 0,
* the same instant the window opens and HALT asserts, so the CPU is
* already parked when the engine asks for the bus.  It takes HALT during
* the clock ISR, the fill runs, and by the time this returns the pixels
* are there.
*
* Seven variants were tried and the split is total: every one that left
* the CPU issuing bus cycles wedged the machine unrecoverably, and every
* one that did not - CWAI here, SYNC here, or the kernel's idle CWAI
* reached by the caller sleeping - worked.  DMA_STATUS_TRF_IP in
* wildbits.d has the table.
*
* Blocking here is safe because grfdrv processes one call at a time by
* design (user, 2026-09-21): a second caller serialises behind this one
* rather than re-entering it.
bccwai@             cwai      #^IntMasks
                    bra       bcnod@
* BIT 6 - PARK, CHECK, PARK AGAIN UNTIL THE ENGINE SAYS IT IS DONE.
*
* A bare CWAI is woken by ANY interrupt, not only the tick, so a
* keystroke can put the CPU back to executing long before the transfer
* window even opens.  This costs one lda per wake instead: if the status
* still reads busy, park again.  The CPU is running for a handful of
* cycles per interrupt rather than continuously.
*
* IT DOES READ $FEC1 WHILE A TRANSFER IS PENDING, which is the access
* that wedges the machine when done in a tight loop.  The bet is that
* frequency is what matters - one read per interrupt against one every
* seven cycles - and that is exactly what this measures.
*
* Counted, because a wedged engine never clears the bit.
bccwck@             ldy       #DmaCwChk
bccwc2@             cwai      #^IntMasks
                    lda       DMA.Base+DMA_STATUS_REG
                    bpl       bcnod@              done
                    leay      -1,y
                    bne       bccwc2@
                    bra       bcnod@
bcdly@              ldy       #DmaDly7
bcdly2@             leay      -1,y
                    bne       bcdly2@
                    bra       bcnod@
* BIT 2 - THE SAME LOOP WITH AN I/O READ THAT IS NOT THE DMA BLOCK.
* Bit 1's loop touches no memory at all and is safe; a poll of $FEC1 is
* not.  That leaves two possibilities and this separates them: is the
* hazard reading THE DMA'S OWN REGISTERS, or reading ANY I/O during a
* live transfer?  $FE20 is the interrupt-pending register - a real I/O
* read, on the same bus, through the same decode, but nowhere near
* $FEC0-$FECF.  Reading it has no side effect; clearing is write-1.
*
* Safe   -> the fault is specific to the DMA register block.
* Wedges -> it is any I/O access during a transfer, which is a much
*           broader finding and points at the bus rather than the DMA.
bcdio@              ldy       #DmaDly12
bcdio2@             lda       INT_PENDING_0
                    leay      -1,y
                    bne       bcdio2@
                    bra       bcnod@
* BIT 3 - THE SAME LOOP AGAIN, READING RAM INSTEAD OF I/O.
* Bit 2's loop wedged the machine, which says the hazard is not the DMA's
* own registers.  But its loop is 12 cycles against bit 1's 7, so it also
* ran 70% longer, and DURATION is not ruled out.  This one is byte for
* byte the same shape as bit 2 - "lda" 5 cycles, leay 4, bne 3 - and
* differs in ONE thing: the address is RAM, not I/O.  X points at this
* module's own code, which is read-only and always mapped.
*
* Safe   -> it is I/O SPACE, and the duration confound is dead.
* Wedges -> it is any data access, or simply time in the window, and
*           bit 1's loop was only safe because it was shorter.
bcdram@             leax      <bcdram@,pcr
                    ldy       #DmaDly12
bcdrm2@             lda       ,x
                    leay      -1,y
                    bne       bcdrm2@
                    bra       bcnod@
* BIT 4 - SYNC, WHICH IS THE ONLY ONE OF THESE THAT IS NOT A LOOP.
* Every counted loop above wedges the machine, and the one state that
* never has is the CPU issuing NO VALID BUS CYCLES - which is what the
* kernel's idle CWAI does.  CWAI cannot be used here: it ENABLES
* interrupts, and grfdrv is not reentrant with the MMU flipped onto a
* shared stack.  SYNC gives the same bus behaviour without that -
* CPUSTATE_SYNC sets rAVMA = 0 with the address parked at $FFFF, and
* with I set the core leaves SYNC and runs the NEXT INSTRUCTION rather
* than vectoring.
*
* It should land exactly right: SYNC exits when an interrupt LINE
* asserts, and the 60 Hz tick fires at line 0 - the same instant the
* transfer window opens and HALT asserts.  So the CPU is parked with no
* bus cycles right up to the moment it is asked for the bus, then takes
* HALT at the next fetch.
*
* TWO HAZARDS.  SYNC exits at once if a line is ALREADY asserted, not on
* an edge, so a tick latched but not yet serviced makes it a no-op -
* hence DmaSyncs of them rather than one.  And SYNC has NO
* TIMEOUT: if no interrupt ever arrives the CPU stays there for ever.
* The tick makes that very unlikely; it is not impossible.  This is an
* experiment, not something to ship.
bcsync@             sync
                    lbra      bcnod@
* MODE 7 - POLL THE DMA'S OWN STATUS REGISTER UNTIL THE FILL IS DONE.
* THIS IS THE SHIPPING MODE NOW (2026-09-22): Joust clears with it.  On
* the core this was written against it wedged a K2 on the FIRST attempt.
* The FPGA developer's fix waits for HALT to be acknowledged before taking
* the bus, and grants it only at a safe point, so the CPU may execute
* whatever it likes while a transfer is pending.  All ten dmafilltest
* cases pass on the fixed core, this one included.
*
* It is the fastest correct wait.  The call returns within one poll of
* the transfer ending, where F$Sleep plus a GetStat costs a second system
* call and up to a tick more, and a CWAI only notices at the next
* interrupt.  The CPU is halted for the transfer itself, so the
* only CPU this burns is the wait for line 0, and nothing else could run
* in that time anyway: grfdrv is synchronous by design.
*
* ON AN UNFIXED CORE THIS STILL WEDGES THE MACHINE, and there is no
* register that says which core is running.
*
* It is bounded by DmaDly12, about 18 cycles a pass, so 47 ms at 8 MHz,
* against a worst case of 15 ms to line 0 plus 0.4 ms of transfer.  A bit
* that never clears returns E$DevBsy rather than a false success.
bcpoll@             ldy       #DmaDly12
bcpol2@             lda       DMA.Base+DMA_STATUS_REG
                    lbpl      bcnod@              done - it cleared
                    leay      -1,y
                    bne       bcpol2@
                    lbra      BmClrBsy            never cleared: the engine is dead
bcnod@              lbra      StatOK
BmClrBsy            comb
                    ldb       #E$DevBsy
                    jmp       >GrfMod+SysRet
BmClrUnd            comb
                    ldb       #E$WUndef
                    jmp       >GrfMod+SysRet

*******************************************************************
* Rows2Byt - rows of a 320-byte bitmap as a 24-bit byte count.
*   Entry: A = rows (0-240), X -> three bytes.
*   Exit:  ,X 1,X 2,X = rows*320, bits 23:16, 15:8, 7:0.  X and A kept.
*
* rows*320 = rows*256 + rows*64, and the product reaches 76,800, so it
* does not fit in 16 bits and has to be built a byte at a time.  Both the
* first row's offset and the byte count are this same sum, which is why
* it is a subroutine now rather than written out twice.
*******************************************************************
Rows2Byt            pshs      a
                    ldb       #64
                    mul                           D = rows*64
                    std       1,x
                    clr       ,x
                    ldb       ,s                  + rows*256: add rows to the M byte
                    addb      1,x
                    stb       1,x
                    bcc       r2b@
                    inc       ,x
r2b@                puls      a,pc

*******************************************************************
* DmaFill - arm a 1D fill on the DMA engine and return.  Factored out of
*   SS.BmClear so that the 2D blit this engine can also do grows from the
*   same place: a blit adds a source, two strides and the 2D control bit,
*   and changes nothing here.
*   Entry: X -> an 8-byte parameter block
*            0,1,2  destination address, bits 23:16, 15:8, 7:0
*            3,4,5  byte count,          bits 23:16, 15:8, 7:0
*            6      the fill value
*            7      flags: bit 0 = 16-bit transfer
*   Exit:  armed.  B = 0.  A, B and X clobbered.
*
* THIS IS THE USER'S OWN 2025 BARE-METAL TEST SEQUENCE, INSTRUCTION FOR
* INSTRUCTION, on this tree's register map.
* /home/magnus/projects/f256/jfed/dma/dmakeytest.asm DMA_Fill_Test_1D
* fills $012C00 bytes - 76,800, exactly a bitmap - at a destination it
* sets with no regard whatever for where the raster is, and it worked.
* Whatever is wrong with SS.BmClear, that is the reference behaviour, and
* the driver is now the same shape as it.  Three things changed to get
* here and all three were mine:
*
*   1. 8-BIT ONLY.  The reference never sets bit 6; its own defs file
*      calls that bit DMA_CTRL_NotUsed2.  This driver used to set it
*      whenever the destination was even, on the strength of the RTL
*      naming it Double_Speed_DMA - a SEPARATE path through the engine,
*      with its own end comparison ({ptr[23:1],0} < {Stop[23:1],0}) and
*      its own byte-lane handling, that NOTHING HAS EVER RUN on this
*      hardware.  8-bit costs 768 us against 384, which is still 24 of
*      the 43 lines in a window and still about 100x better than the CPU
*      loop, so the speed was never worth the risk.
*   2. THE CONTROL REGISTER IS CLEARED FIRST.  The reference disables the
*      DMA after every transfer; doing it before the next one is the same
*      thing for a driver that never sees the end, and it means the start
*      edge is always made from a known-idle register rather than from
*      whatever the last call left behind.
*   3. NO RASTER GUARD.  It was built against a hazard read out of the
*      RTL, and the reference is direct evidence that the hazard does not
*      bite: a full-size fill armed at arbitrary moments, repeatedly,
*      with no trouble.  The reasoning is kept in
*      docs/bmline-bmclear-plan.md section 2 in case it is needed again.
*
* THE START BIT IS EDGE-TRIGGERED (Fire_Transfer[1:0] == 2'b01), so the
* control register is written twice: once with the mode and the start bit
* CLEAR, then once with it set.
*
* The count is NOT three consecutive registers.  Count1D is
* {Y_Size[7:0], X_Size}, so its three bytes live at $FECF, $FECC and
* $FECD - which is what the DMA_SIZE_1D_* aliases in wildbits.d say.
* NOTE that the reference's map is NOT this one - it puts the destination
* at $FEC8/9/A and the size at $FECC/D/E - and this one is right for
* rc16: it is what TinyVKY_DMA_Reg_Block.v assembles the address from,
* and "dma dst $1C5000" read back correctly on K2 hardware.  So the map
* changed between the core the reference ran on and this one, and only
* the SEQUENCE is being copied from it, not the addresses.
*******************************************************************
DmaFill             clr       DMA.Base+DMA_CTRL_REG   start from a known-idle register
                    ldb       #DMA_CTRL_Enable+DMA_CTRL_Fill
                    lda       7,x                 the width flag
                    bita      #1
                    beq       dfmode@             8-bit, the reference's own mode
* 16-bit masks address bit 0, so an odd destination would take the byte
* BEFORE the bitmap with it - and SS.BmDef allows any offset, so that is
* reachable.  An odd destination is quietly done 8-bit rather than
* refused: the caller asked for speed, not for a different result.
                    lda       2,x
                    bita      #1
                    bne       dfmode@
                    orb       #DMA_CTRL_16Bit
dfmode@             stb       DMA.Base+DMA_CTRL_REG   the mode, start bit clear
                    bitb      #DMA_CTRL_16Bit
                    beq       df8@
                    lda       6,x                 16-bit: the value in BOTH halves
                    sta       DMA.Base+DMA_FILL_16_H
                    sta       DMA.Base+DMA_FILL_16_L
                    bra       dfadr@
df8@                lda       6,x
                    sta       DMA.Base+DMA_DATA_2_WRITE
dfadr@              lda       ,x
                    sta       DMA.Base+DMA_DEST_ADDR_H
                    lda       1,x
                    sta       DMA.Base+DMA_DEST_ADDR_M
                    lda       2,x
                    sta       DMA.Base+DMA_DEST_ADDR_L
                    lda       3,x
                    sta       DMA.Base+DMA_SIZE_1D_H
                    lda       4,x
                    sta       DMA.Base+DMA_SIZE_1D_M
                    lda       5,x
                    sta       DMA.Base+DMA_SIZE_1D_L
* THE ARMING LINE.  11,x is 0 for free-running - every caller but
* dmafilltest - or a raster line to wait for.  DMA_ArmWrap in wildbits.d
* carries the argument for both the two phases and the ceiling; the short
* version is that this is safe HERE and only here, because the start bit
* below has not been written yet and so nothing can halt the CPU while it
* turns.
                    lda       11,x
                    beq       dfgo@
                    pshs      b                   the control byte, start bit still clear
                    clra
                    ldb       11,x
                    pshs      d                   ,s = the requested line, 16-bit
                    ldy       #DMA_ArmWrap
dfbef@              lbsr      DmaLine
                    cmpd      ,s
                    blo       dfat@               before the target: now wait for it
                    leay      -1,y
                    bne       dfbef@
                    bra       dfarm@
dfat@               ldy       #DMA_ArmWrap
dfat2@              lbsr      DmaLine
                    cmpd      ,s
                    bhs       dfarm@
                    leay      -1,y
                    bne       dfat2@
dfarm@              leas      2,s                 drop the requested line
                    puls      b                   the control byte again
* READ THE LINE AS LATE AS IT CAN BE READ - the next thing written is the
* start bit - and leave it in 11,x for the caller.  A line past 255 comes
* back as $FF: the scale this is reported on is one byte, and every line
* the window question is about is far below 255.
dfgo@               pshs      b                   the control byte
                    lbsr      DmaLine
                    tsta
                    beq       dfrec@
                    ldb       #$FF
dfrec@              stb       11,x
                    puls      b
                    orb       #DMA_CTRL_Start_Trf
                    stb       DMA.Base+DMA_CTRL_REG
                    clrb                          and CLRB clears the carry
                    rts

*******************************************************************
* DmaLine - the raster line in D, 0 to VTOTAL (524 at 60 Hz, 448 at 70).
*   X and Y kept.
*
* $FFDA is HLineCount[11:8] and $FFDB is [7:0].  The middle two of these
* four read-back registers were documented the wrong way round in
* wildbits.d until 2026-09-21; nothing had used them, so the swap was
* dormant.  TinyVickyControl_Registers.v:151-154 is the whole map.
*
* It is the WHOLE FRAME's line, counting from 0 at the top of vertical
* blanking - not the visible line - which is the number DMA_ArmLine and
* the transfer window are both measured in.
*******************************************************************
DmaLine             lda       TXT.Base+VKY_LINE_Y_POS_HI
                    anda      #$0F
                    ldb       TXT.Base+VKY_LINE_Y_POS_LO
                    rts

*******************************************************************
* SetStat SS.BmLine ($E7) - draw a BATCH of lines into a bitmap with the
*   rc16's hardware line engine (source/LineDraw.v).
*   R$Y = bitmap # (0-2)
*   R$X = the caller's array of 8-byte records
*   R$U = record count, 1-255; RETURNS the number actually drawn
*
*   Record:  +0,1 X0 (0-319; 0-639 on a HIRES4 plane)  +2,3 X1
*            +4 Y0 (0-239)  +5 Y1  +6 colour (its low nibble on a
*            HIRES4 plane)  +7 reserved, write 0
*
* A BATCH, NOT A LINE.  The engine walks a 320-pixel line in 3.2 us and
* an I$SetStt costs ~474 us, so one line per call would be 99% transport
* - the per-sprite-call mistake again.  Three separate changes have now
* shown CALL COUNT is the only lever that moves (docs/driver-work.md).
*
* COLOUR IS PER RECORD AND THAT IS FREE: the address and the colour are
* baked into each FIFO entry as it is enqueued, so changing colour or
* plane between lines needs no flush and no wait.
*
* IT STOPS EARLY RATHER THAN OVERFLOWING.  The pixel FIFO holds 4,096
* entries, its full flag is NOT connected and its write enable is
* unconditional, so an overrun loses pixels silently - and the engine
* enqueues about four times faster than the video engine drains it.  So
* the count is read before each record and a batch that would run it
* short stops, with R$U = the number drawn for the caller to resume from.
* GetStat SS.BmLine reports the count for a caller that would rather pace
* itself than be told it came up short.
*
* LIVE TERMINAL ONLY.  The plane's start-address registers hold whichever
* terminal is on screen, so a line drawn on behalf of a background
* terminal would land in the FOREGROUND one's bitmap.  E$NotRdy.
*
* R$U IS SET ON EVERY PATH, errors included, so a caller that got
* E$IllArg knows which record was bad without a second call.
*******************************************************************
SSBmLine            ldd       R$Y,x               bitmap # 0-2
                    cmpd      #2
                    lbhi      BmLnArg
                    stb       >gr.b2
                    lslb
                    lslb                          the plane select, bits 3:2
                    stb       >gr.b3
                    ldd       R$U,x               the record count
                    tsta
                    lbne      BmLnArg
                    tstb
                    lbeq      BmLnArg             a count of 0 is an error
                    pshs      b                   1,s = records left
                    clr       ,-s                 ,s = records drawn
* The bitmap must have blocks, and this terminal must be on screen.
                    lda       >gr.b2
                    lsla                          two mirror bytes per bitmap
                    leay      V.BM0Cl_En,u
                    leay      a,y
                    tst       1,y                 its block
                    lbeq      BmLnUnd
                    tst       V.TermLive,u
                    lbeq      BmLnNRdy
* A HIRES4 plane (control byte bit 4, SS.BmCfg) is 640 dots wide: the
* engine takes X to 639 there (LineDraw.v valid_coords), and a line can
* be 640 pixels long, so the FIFO needs that much room before a record.
* gr.d1 = the last X, gr.d2 = the room.  $FFCB's global bit is never
* set by this driver, so the plane's own bit is the whole answer.
                    ldd       #LD.MaxX
                    std       >gr.d1
                    ldd       #LD.Room
                    std       >gr.d2
                    lda       ,y                  the control byte
                    bita      #%00010000
                    beq       BmLnLo
                    ldd       #LD.MaxX4
                    std       >gr.d1
                    ldd       #LD.Room4
                    std       >gr.d2
BmLnLo
* The engine's real enable, $FFCA bit 0, in the mirror and in the live
* register.  It sits inside the $FFC0-$FFCF block PullCore copies, so
* this survives a terminal switch, and it costs nothing while idle: with
* it clear the video master engine goes DrawingLine_Begin ->
* WAIT4LINE2FINISH, with it set DrawingLine_Begin -> DrawingLine_End ->
* WAIT4LINE2FINISH, and both wait out the rest of the scanline.
                    lda       V.V_MCR2,u
                    bita      #VKY_MCR2_LineDraw
                    bne       BmLnOn
                    ora       #VKY_MCR2_LineDraw
                    sta       V.V_MCR2,u
                    sta       TXT.Base+VKY_MCR2
* The caller's array through slots 1 and 2, then $C0 through slot 3.
BmLnOn              ldb       1,s                 records left
                    lda       #8
                    mul                           D = the array's length in bytes
                    tfr       d,y
                    ldd       R$X,x               the array, in the caller
                    lbsr      MapCallBuf          U = it, through slot 1
                    bcs       BmLnMap             it runs off the top of the map
                    lbsr      LineMapC0           X = $7080, the line registers
* The record loop.  ,s = drawn, 1,s = left, U = this record, X = the
* registers.  U stopped being the statics at MapCallBuf and X stopped
* being the register image at LineMapC0; the exits use gr.PDRGS directly.
BmLnLp              tst       1,s
                    beq       BmLnOK              all of them drawn
* Room in the FIFO?  Stop rather than lose pixels silently.
                    lda       LD.FifoH,x
                    ldb       LD.FifoL,x
                    cmpd      >gr.d2
                    bhs       BmLnOK              short: R$U tells the caller
* Range-check the record.  An endpoint outside 0-319 (0-639 on a HIRES4
* plane) / 0-239 means the engine NEVER STARTS and never signals
* complete, so this check is what stands between the poll below and a
* hang.
                    ldd       ,u                  X0
                    cmpd      >gr.d1
                    bhi       BmLnRng
                    ldd       2,u                 X1
                    cmpd      >gr.d1
                    bhi       BmLnRng
                    lda       4,u                 Y0
                    cmpa      #LD.MaxY
                    bhi       BmLnRng
                    lda       5,u                 Y1
                    cmpa      #LD.MaxY
                    bhi       BmLnRng
* The endpoints, and then GO in a store of its own: the endpoint
* registers are NOT resynchronised into the engine's 100 MHz clock
* domain, so they have to be stable before GO rises.
                    lda       6,u                 colour
                    sta       LD.Color,x
                    ldd       ,u
                    sta       LD.X0H,x
                    stb       LD.X0L,x
                    ldd       2,u
                    sta       LD.X1H,x
                    stb       LD.X1L,x
                    lda       4,u
                    sta       LD.Y0,x
                    lda       5,u
                    sta       LD.Y1,x
                    lda       >gr.b3              the plane bits
                    ora       #LD_CTRL_Go
                    sta       LD.Ctrl,x
* COMPLETE means the Bresenham WALK finished, not that a pixel reached
* memory: the pixels are in the FIFO and the video engine drains them on
* odd visible lines.  It arrives in about 3.2 us, ~26 cycles at 8 MHz, so
* LD.Poll is fifty times the headroom it needs and cannot hang.
                    ldb       #LD.Poll
BmLnPoll            lda       LD.Ctrl,x
                    bmi       BmLnGot
                    decb
                    bne       BmLnPoll
* It never came.  The machine is still in IDLE - the only way that can
* happen once GO is up, since RUN always terminates - so LOWERING GO IS
* THE WHOLE RECOVERY.  LD_CTRL_RstFIFO would clear the FIFO as well and
* discard pixels belonging to lines already counted as drawn, so it is
* not used here, and nowhere else either.
                    lda       >gr.b3
                    sta       LD.Ctrl,x
                    ldb       #E$DevBsy
                    bra       BmLnX
BmLnGot             lda       >gr.b3
                    sta       LD.Ctrl,x           GO down: DONE -> IDLE
                    inc       ,s                  one more drawn
                    dec       1,s
                    leau      8,u                 the next record
                    bra       BmLnLp
* Exits.  B = the error code, 0 = none; ,s = drawn, 1,s = left.
BmLnRng             ldb       #E$IllArg
                    bra       BmLnX
BmLnMap             ldb       #E$IllArg
                    bra       BmLnX
BmLnUnd             ldb       #E$WUndef
                    bra       BmLnX
BmLnNRdy            ldb       #E$NotRdy
                    bra       BmLnX
BmLnOK              clrb
BmLnX               pshs      b                   ,s = err, 1,s = drawn
                    ldb       1,s
                    clra
                    std       >gr.PDRGS+R$U       the records actually drawn
                    puls      b                   PULS does not touch CC
                    leas      2,s
                    tstb
                    bne       BmLnErr
                    andcc     #^Carry
                    jmp       >GrfMod+SysRet
BmLnErr             orcc      #Carry
                    jmp       >GrfMod+SysRet
* A malformed call, before anything was pushed or drawn.  R$U is still
* set, so the answer to "how many did you draw" is never undefined.
BmLnArg             clra
                    clrb
                    std       R$U,x
                    lbra      BmBad

*******************************************************************
* LineMapC0 - $C0 through slot 3, so the line drawing registers are at
*   $7080: $6000 for the slot, $1000 for the bitmap register page inside
*   the block, $80 for the line half of it.  SLOTS 1 AND 2 ARE LEFT
*   ALONE, because SS.BmLine needs them for the caller's array -
*   SetBlkC0C1 wants slot 1 for $C0 and so cannot be used here.  GFDfPal
*   already reaches $C1 through slot 3 exactly this way.
*   Exit: X = $7080.  Every other register is kept.
*******************************************************************
LineMapC0           pshs      cc,d
                    orcc      #IntMasks
                    lda       #EDIT_LUT_1+ACT_LUT_1
                    sta       MMU_MEM_CTRL
                    clra
                    ldb       #VICKY_BLK
                    stb       MMU_SLOT_3          $6000
                    std       >gr.DATImg+6
                    ldx       #$7080
                    puls      cc,d,pc

*******************************************************************
* SetStat SS.GfxAlloc ($D4) - N consecutive blocks of graphics memory.
*   R$X = block count (1-255) in, the first block out.
*
* Deliberately NOT a bitmap call: one allocator serves bitmaps, tile sets
* and tile maps alike, which is why a program can ask once for a slab big
* enough for a slew of assets and then lay them out inside it with
* SS.BmDef, SS.TsSet and SS.TmSet, all of which take a block and an
* offset.  It exists at all because F$AlHRAM is registered
* F$AlHRAM+SysState in krnp2.asm's svctab, so an application cannot reach
* it and the driver can - and the convention is that graphics allocate
* from the top of the block map down, leaving the low contiguous space
* free.
*
* THE BLOCKS BELONG TO THE PROGRAM.  It frees them with SS.GfxFree, and
* the driver never does: no terminal close, no SS.BmKill.  The other half
* of the rule is SS.BmAlloc, whose blocks belong to the driver.  Whoever
* allocated, frees.
*
* The blocks are physically consecutive, so an object may run past the end
* of one - which is how a 76,800-byte bitmap fits in ten of them.
*******************************************************************
SSGfxAlloc          ldd       R$X,x               block count
                    tsta
                    lbne      BmBad               more than 255 blocks
                    tstb
                    lbeq      BmBad               none
                    pshs      x                   os9 may clobber it
                    os9       F$AlHRAM            D = first block
                    lbsr      SetBlkC2C3          remap slot 5, reload U (keeps D, X, CC)
                    puls      x
                    bcc       gaok@
                    ldb       #E$MFull
                    coma
                    jmp       >GrfMod+SysRet
gaok@               clra
                    std       R$X,x               the first block back
                    lbra      StatOK

*******************************************************************
* SetStat SS.GfxFree ($D5) - give those blocks back.
*   R$X = first block, R$U = count.
*
* It REFUSES a range that overlaps a bitmap the driver allocated, which is
* what keeps the two ownership models from colliding: a program that
* freed the blocks SS.BmBlk reported would otherwise double-free them the
* moment the terminal closed.  E$IllArg, and nothing is freed.
*******************************************************************
SSGfxFree           ldd       R$U,x               count
                    tsta
                    lbne      BmBad
                    tstb
                    lbeq      BmBad
                    pshs      b                   ,s = the count
                    ldd       R$X,x               first block
                    tsta
                    bne       gfbad@              a block number is one byte
                    tstb
                    beq       gfbad@              block 0 is the system block
                    lda       ,s                  the count
                    exg       a,b                 A = first block, B = count
                    lbsr      GfxChkOwn
                    bcs       gfbad@              overlaps a bitmap we own
                    ldx       #gr.PDRGS           GfxChkOwn clobbers X
                    clra
                    ldb       R$X+1,x             first block
                    tfr       d,x                 X = first block
                    puls      b                   the count
                    os9       F$DelRAM
                    lbsr      SetBlkC2C3          remap slot 5 and reload U
                    bcs       gferr@
                    lbra      StatOK
gferr@              coma
                    jmp       >GrfMod+SysRet
gfbad@              leas      1,s
                    lbra      BmBad

*******************************************************************
* GfxChkOwn - does the block range [A, A+B) overlap a bitmap the DRIVER
*   allocated?  Entry A = first block, B = count, U = the statics.
*   Exit: carry SET if it overlaps.  Clobbers D, X, Y.
*
* Two containment tests make the full overlap test, and both are 8-bit:
* either the bitmap's first block falls inside the request, or the
* request's first block falls inside the bitmap.
*******************************************************************
GfxChkOwn           pshs      d                   ,s = first block, 1,s = count
                    clra                          bitmap # 0
gco1@               pshs      a                   ,s = bitmap #
                    lbsr      BmFlagMask
                    pshs      a                   ,s = its size bit
                    lsla
                    lsla
                    lsla
                    lsla                          A = its ownership bit
                    anda      V.BMFlags,u
                    beq       gco8@               a program's, or undefined
                    lda       1,s                 bitmap #
                    lsla
                    leay      V.BM0Blk,u
                    lda       a,y                 A = its first block
                    beq       gco8@               not defined
                    ldb       ,s                  its size bit
                    andb      V.BMFlags,u
                    beq       gco2@
                    ldb       #BmBlk200
                    bra       gco3@
gco2@               ldb       #BmBlk240
* After the push: ,s = the bitmap's first block, 1,s = its length,
* 2,s = its size bit, 3,s = the bitmap #, 4,s = the request's first block,
* 5,s = the request's count.
gco3@               pshs      d                   ,s = bm block, 1,s = bm length
                    lda       ,s                  bitmap start
                    suba      4,s                 minus the request's start
                    bcs       gco4@               below it - try the other way
                    cmpa      5,s                 inside the request's length?
                    blo       gco7@               yes: they overlap
gco4@               lda       4,s                 the request's start
                    suba      ,s                  minus the bitmap's
                    bcs       gco6@               below it - no overlap
                    cmpa      1,s                 inside the bitmap's length?
                    blo       gco7@               yes: they overlap
gco6@               leas      2,s                 drop the bitmap's block/length
                    bra       gco8@
gco7@               leas      6,s                 drop everything: block, length,
                    orcc      #Carry              size bit, bitmap #, and the
                    rts                           request's own two bytes
gco8@               leas      1,s                 drop the size bit
                    puls      a                   bitmap #
                    inca
                    cmpa      #3
                    blo       gco1@
                    leas      2,s                 drop the request
                    andcc     #^Carry
                    rts

*******************************************************************
* GF.InitDisp (b29) - display setup for the first terminal, issued by
*   GF.TermNew's first-terminal branch.  (Not the GF.InitDisp deleted
*   earlier for writing the text LUTs to the wrong block; this one
*   touches no LUT.)
* V.V_MCR / V.V_LayerCTL / V.BordBack are the 16-byte mirror of
* $FFC0-$FFCF that PullBuf programs on a terminal switch.  Each DispRegs
* byte goes to the mirror and to its register together, so the two agree
* by construction and nothing has to read a Vicky register back - they
* are not guaranteed readable.  Every writer must keep the mirror in
* step; every reader must use the mirror.  Later terminals inherit the
* mirror from the live console in GF.TermNew.
* Then the text cursor: enabled, flashing, '_' at 0,0.
*******************************************************************
GFInitDisp          lbsr      SetBlkC2C3          U = this terminal's statics
                    leax      DispRegs,pcr
                    leay      V.V_MCR,u
                    ldu       #TXT.Base
                    ldb       #16
seed@               lda       ,x+
                    sta       ,y+                 mirror
                    sta       ,u+                 register
                    decb
                    bne       seed@
                    ldx       #TXT.Base
                    lda       #Vky_Cursor_Enable|Vky_Cursor_Flash_Rate0|Vky_Cursor_Flash_Rate1
                    sta       VKY_TXT_CURSOR_CTRL_REG,x
                    clra
                    clrb
                    std       VKY_TXT_CURSOR_Y_REG_H,x
                    std       VKY_TXT_CURSOR_X_REG_H,x
                    lda       #'_
                    sta       VKY_TXT_CURSOR_CHAR_REG,x
* Every sprite record off, once, so gr.SprDirty's "they are all clear" is
* true from the start rather than a guess about what the core left behind.
                    lbsr      SprMapC0            $C0 in slot 1
                    ldx       #$2000+SPRITE_REC_OFF
                    clrb
                    lbsr      SprClrFrom
                    clr       >gr.SprDirty
                    clrb
                    jmp       >GrfMod+SysRet

* The 16 bytes of $FFC0-$FFCF, in register order: MASTER_CTRL_REG_L/H,
* VKY_LAYER_CTRL_L/H, BORDER_CTRL_REG, BORDER_COLOR_B/G/R,
* BORDER_X_SIZE, BORDER_Y_SIZE, VKY_RESERVED_02/03/04,
* BACKGROUND_COLOR_B/G/R.  Text mode on, 80x60 (no DBL_X/DBL_Y), no
* layers, border off and sized 0, black background.
DispRegs            fcb       Mstr_Ctrl_Text_Mode_En,$00
* VKY_LAYER_CTRL: $FF,$FF, which is source 7 in each of the three 3-bit
* fields.  The core's default arm reads 3 and 7 as neither a bitmap nor a
* tile map, so every layer starts DRAWING NOTHING.
*
* This used to be $00,$00 - source 0 in all three, which is BITMAP 0.  So
* every layer pointed at bitmap 0 and merely enabling it put it on all
* three.  Nothing noticed because every program assigns its layers and
* turns FX_BM on last, but it made the enable bit a proxy for "shows",
* which it should not be: a bitmap appears only when its enable bit is
* set AND a layer points at it AND FX_BM is on, and those are now three
* independent things.  That is what makes SS.BmAlloc safe to leave a
* bitmap defined but off.
*
* The hardware's own reset value is $40,$15 - bitmap 0, tile map 0, tile
* map 1 - so the driver was overriding a sane default with a worse one.
                    fcb       $FF,$FF
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00
                    fcb       $00,$00,$00
                    fcb       $00,$00,$00


*******************************************************************
* GF.TermNew (b30) - set up terminal gr.b1 for the device static at gr.d1
*   (its system address).  Issued by vtio's InitTerm - a named INIZ, or
*   the /vt factory's SS.Open - which has already stored V.TermID.
* The whole setup runs inside the op, so the AltISR (it declines while
* gr.Busy is set) cannot switch in the middle of it, and T.Init is the
* LAST thing written: until then GFSwitch and GFTermGone skip the entry.
* vtio used to set T.Init first, with interrupts on, before T.StatPtr,
* T.VBlk and T.grU5 were stored - an Alt+arrow in that window could make a
* half-built terminal live.
*   1. the id is in range and not open, else E$DevBsy;
*   2. F$AlHRAM the 16K switch buffer (2 blocks);
*   3. the entry: T.Block, T.StatPtr, T.grU5 (the $A0xx alias) and T.VBlk
*      from the system DAT image - D.SysPrc is $0600, so D.SysDAT is in
*      block 0;
*   4. the statics' defaults (what vtio's InitTermStatic did).  IOMan zeroes a new
*      static, so most of the clears are redundant; they are kept to be safe;
*   5. the first terminal (gr.TermCnt 0) goes live and gets GF.InitDisp's
*      body.  A later one inherits from the live terminal (InhRuns), then
*      PushCore puts the live font, sprite bank 0 and CLUTs in its buffer
*      (the TermSave* switches) and the buffer's text is blanked in V.FBCol.
* Log for the MAME dump: $12F5 = V.TermLive, $12F6 = gr.TermCnt,
*   $12F7 = 'K' or 'E', $12F8 = error, $12EC = a later terminal's buffer.
* Exit: B = 0, or carry + E$DevBsy / F$AlHRAM's error.
*******************************************************************
GFTermNew           lda       >gr.b1
                    cmpa      #G.TermMax
                    lbhs      TNBusy
                    ldb       #gr.TermSz
                    mul
                    ldx       #gr.TermTbl
                    abx                           X = this terminal's entry
                    lda       T.Flags,x
                    bita      #T.Init
                    lbne      TNBusy
                    pshs      x
                    ldd       #2
                    os9       F$AlHRAM            D = first block of the 16K buffer
                    puls      x
                    lbcs      TNErr
                    stb       T.Block,x
                    ldd       >gr.d1
                    std       T.StatPtr,x
                    anda      #$1F
                    ora       #$A0
                    std       T.grU5,x            the static through slot 5
                    lda       >gr.d1
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                          A = system slot (U >> 13)
                    lsla
                    inca                          -> block-number byte of that DAT entry
                    ldy       >D.SysDAT
                    lda       a,y
                    sta       T.VBlk,x            block holding the static
                    lbsr      GSTermPtrs          aim gr.TermBlk/VStaStorU/VBlk/U5 (keeps X)
                    lbsr      SetBlkC2C3          U = the new statics, slots 3/4 = its buffer
                    ldb       T.Block,x
                    stb       V.TermBufBlk,u
* It has registered no sprite table.  A row is never inherited: it names
* another process's memory.
                    lda       >gr.b1
                    ldb       #SB.Size
                    mul
                    ldy       #gr.SprTbl
                    leay      d,y
                    clr       SB.Flags,y
* Defaults.  80x60 is also what GF.InitDisp's DispRegs program.
                    clr       V.WriteState,u      escape collector idle
                    ldb       #$10
                    stb       V.FBCol,u
                    ldd       #80*256+60
                    std       V.WWidth,u
                    ldd       #80*60
                    std       V.ScreenSize,u      SetScreenSize's product
* V.CurPos is the cached V.CurRow*V.WWidth+V.CurCol that PutGlyph paints
* at; clearing row/col without it leaves a stale cell offset behind.
                    clr       V.CurRow,u
                    clr       V.CurCol,u
                    clr       V.CurPos,u
                    clr       V.CurPos+1,u
                    clr       V.IBufH,u
                    clr       V.IBufT,u
                    clr       V.LastCh,u
                    clr       V.Reverse,u
                    clr       V.ST,u
* The bitmap / CLUT-block / tile mirror starts "everything off" and is
* never inherited: a new terminal has no bitmaps of its own, and pointing
* it at another terminal's is the bug the mirror exists to prevent.
                    leay      V.BM0Cl_En,u
                    ldb       #V.GCX-V.BM0Cl_En
tnclr@              clr       ,y+
                    decb
                    bne       tnclr@
                    tst       >gr.TermCnt
                    bne       TNInherit
* First terminal: live now, then GF.InitDisp's body seeds and programs the
* $FFC0-$FFCF mirror and the cursor, and returns for us.
                    lda       >gr.b1
                    sta       >gr.LiveTerm
                    lda       #1
                    sta       V.TermLive,u
                    lda       #T.Init+T.Live
                    sta       T.Flags,x
                    inc       >gr.TermCnt
                    lbsr      TNLog
                    lbra      GFInitDisp
* A later terminal matches the live one.  Its statics go in slot 1 (the
* $A0xx alias less $8000) beside the new ones in slot 5; one block in both
* slots is fine.  Interrupts stay masked through the copy, because the
* AltISR's keydrv call writes the live V.KeyDrvStat.
TNInherit           clr       V.TermLive,u
                    pshs      x
                    ldb       >gr.LiveTerm
                    cmpb      #G.TermMax
                    bhs       TNPush              no live terminal to copy from
                    lda       #gr.TermSz
                    mul
                    ldx       #gr.TermTbl
                    abx                           X = the live terminal's entry
                    ldb       T.VBlk,x
                    ldx       T.grU5,x
                    leax      -$8000,x            X = its statics through slot 1
                    pshs      cc
                    orcc      #IntMasks
                    lda       #EDIT_LUT_1+ACT_LUT_1
                    sta       MMU_MEM_CTRL
                    clra
                    stb       MMU_SLOT_1 $2000
                    std       >gr.DATImg+2
                    leay      InhRuns,pcr
inhrun@             ldb       ,y+                 field offset, 0 ends the table
                    beq       inhdone@
                    pshs      x,u
                    abx                           X -> the live field
                    clra
                    leau      d,u                 U -> the new field
                    lda       ,y+                 length
inhcp@              ldb       ,x+
                    stb       ,u+
                    deca
                    bne       inhcp@
                    puls      x,u
                    bra       inhrun@
inhdone@            puls      cc
* The display mode is inherited; THE LAYER ASSIGNMENT IS NOT.  A new
* terminal has no bitmaps and no tile maps - GF.TermNew wipes that whole
* mirror above - so inheriting the console's layers would point them at
* things this terminal does not have, and the moment it allocated bitmap
* 0 it would appear on whichever layers the last program happened to
* leave aimed at it.  Source 7 in all three fields draws nothing.
                    ldd       #$FFFF
                    std       V.V_LayerCTL,u
* PushCore remaps slots 1/2 and exits U = gr.U5.  Its text and colour
* copies into the new buffer are blanked straight after.
TNPush              lbsr      PushCore
                    ldx       ,s
                    ldb       T.Block,x
                    stb       $12EC
                    lda       #C$SPAC             fill glyph
                    ldb       V.FBCol,u           fill colour, as inherited
                    lbsr      BlankCore
                    puls      x
                    lda       #T.Init
                    sta       T.Flags,x           open: switchable from here on
                    inc       >gr.TermCnt
                    bsr       TNLog
                    clrb
                    jmp       >GrfMod+SysRet
TNLog               lda       V.TermLive,u
                    sta       $12F5
                    lda       >gr.TermCnt
                    sta       $12F6
                    lda       #'K
                    sta       $12F7
                    rts
TNBusy              ldb       #E$DevBsy
TNErr               stb       $12F8
                    lda       #'E
                    sta       $12F7
                    coma                          carry: the error in B
                    jmp       >GrfMod+SysRet
* Runs inherited from the live terminal's statics: offset, length.
InhRuns             fcb       V.WWidth,V.MouseVect-V.WWidth   size, V.ScreenSize, colours, keydrv/mouse ptrs
                    fcb       V.KeyDrvStat,8                  keydrv state
                    fcb       V.ST,V.BordBack+12-V.ST         V.ST and the $FFC0-$FFCF mirror
                    fcb       0


*******************************************************************
* GF.PSGInit (b12) - sound hardware setup, once from vtio's Init.
*   Stereo bits in SYS1, the WM8776 CODEC, then silence the PSG (fixed port PSG_BOTH_PORT).
*   SYS1 and CODEC.Base are in the fixed $FExx I/O page.
*******************************************************************
* WM8776 CODEC chip registers
* R00 = [0000000][U][Z][AAAAAAA]             Headphone attenuation: U=Update, Z=Zero Crossing Detection, A=bB 1111001 default for 0dB
* R10 = [0001010][XXX][DS][0][0][DF]         DS=DAC input size 16/20/24/32, DF=DAC Format  Right/Left/I2S/DSP
* R12 = [0001100][0][0][DAC][0][ADC]         DAC rate  ADC rate, both are custom 101 in original vtio
* R13 = [0001101][XX][1][XX][H][D][A][C]     Headphones/DAC/ADC/Chip 0=Enabled 1=Muted
* R22 = [0010110][MUX]                       MUX  Bypass,Aux,DAC (bits 2,1,0)
* R23 = Write anything to Reset WM8776

PSGInit             lda       SYS1                get the byte at SYS1
*                    anda      #^SYS_PSG_ST clear the stereo flag
                    ora       #SYS_PSG_ST|SYS_SID_ST
                    sta       SYS1                and save it back
                    ldx       #CODEC.Base

* The two boards wire the WM8776 differently: one independent register sequence per machine,
* never share or copy values.  Bits: [15:9] register, [8] update/zero-cross/LRBOTH, [7:0] value.
* The recipe builds for one machine (PLATFORM=jr2 or k2 -> -Djr2 / -Dk2).
* Tune by ear before touching this table: the wmset command writes any register live,
* usage  wmset R# V#  (both hex, e.g. wmset 0E E7 = R14 to $E7).  A wmset write lasts only
* until the next boot, when this runs again and rewrites every register below.
                    ifne      jr2
* ------------------- Jr2 InitCODEC -------------------
* This is the sequence that is KNOWN GOOD on the Jr2 (bell audible, keyboard fine), with one
* deliberate experiment in it: R21 (below).  History, all on Jr2 hardware 2026-09-18:
*   R21 $03, R22 $07  bell works, keyboard fine, VS1053 silent   <- the baseline restored here
*   R21 $1F, R22 $07  KEYBOARD DEAD, 99999999 until lockup       <- the dying keyboard (below)
*   the user's own InitCODEC (R21 $C0 muted, R22 $01 DAC-only, R10 $0A, R11/R12 added,
*                             R13 dropped)  NO BELL, NO SOUND    <- kills the DAC path too,
*     so it is not describing this machine; the suspects there are R10 bit 3 or the missing
*     R13 "power down: everything on".  Do not re-apply it without splitting those apart.
* R Taylor (2026-09-18): on the Jr2 the VS1053 and SAM2695 DO reach the output through the
* codec's AIN analogue inputs (on the K2 they do not).  So the VS1053 needs its AMX bit set
* in R21 and the bypass kept in R22 ($07, MX bit 2).  AIN1+AIN2 are the SAM2695, leaving
* AIN3/AIN4/AIN5 - bits 2/3/4, values $07/$0B/$13, which were tried one at a time.
* R21 = $0B (AIN1+AIN2+AIN4).  ESTABLISHED 2026-09-19: the VS1053 is on AIN4.  On a Jr2 whose
* VS1053 strap has been bridged (pins 33-34) so the chip boots as a stream decoder, and with a
* working keyboard, the same boot and game with only this byte changed:
*   $0B  Joust has sound
*   $03  Joust silent, keyboard fine
* The earlier "$03 storms the keyboard" trials were a dying keyboard, not this register (see
* the joust docs/status.md); no ADC mux setting has ever been shown to affect the keyboard.
* $1F (all five inputs) is still untried on a good keyboard and not needed.
* Sound on the Jr2 needed the strap mod first: a synth-mode chip decodes no stream at all, so
* the PCM could never be heard whatever R21 held.
* Knobs, tuned by ear 2026-08-29/30: DAC $FD (-1 dB), headphones $60 (-25 dB); this synth
* runs ~12 dB hotter than the K2 one, hence the deep cut.
                    ldd       #%0010111000000000                    R23 - Reset chip
                    lbsr      SendToCODEC
                    ldd       #%0001010000000010                    R10 - DAC Interface Control 16-bit i2s
                    lbsr      SendToCODEC
                    ldd       #%0010001100000001                    R17 - ALC Control 2
                    lbsr      SendToCODEC
                    ldd       #%0010101000001011                    R21 - ADC Mux Control   AIN1+AIN2+AIN4
                    lbsr      SendToCODEC
                    ldd       #%0010110000000111                    R22 - Output Mux MX[2:0] = "111"
                    lbsr      SendToCODEC
                    ldd       #%0001101000000000                    R13 - PWR Down Control, Everything on
                    lbsr      SendToCODEC
                    ldd       #%0000011111111101                    R03 - Left DAC Attenuation ($FD = -1.0dB)
                    lbsr      SendToCODEC
                    ldd       #%0000100111111101                    R04 - Right DAC Attenuation ($FD = -1.0dB)
                    lbsr      SendToCODEC
                    ldd       #%0000000101100000                    R00 - Left Headphone Attenuation ($60 = -25dB)
                    lbsr      SendToCODEC
                    ldd       #%0000001101100000                    R01 - Right Headphone Attenuation ($60 = -25dB)
                    lbsr      SendToCODEC

                    else
* -------------- K2: independently tunable InitCODEC --------------
* Knobs: DAC att R03/R04 = the .mus/SID path only; headphone att R00/R01 = headphone jack
* only; ADC gain R14/R15 ($CF = 0 dB, 0.5 dB/step, $FF = +24 dB) = every analogue input on
* BOTH jacks, because AINs reach VOUT (RCA) and the headphone PGA through the bypass (R22 MX
* bit 2).  Tuned by ear on the headphone jack 2026-09-05: DAC $D7 (-20 dB), headphones $79
* (0 dB); RCA not tuned.
* Analogue inputs (R21 AMX bit n = AIN n+1; extend as sources are identified):
*   AIN1, AIN2  SAM2695 MIDI synth (.lyr)      AIN4  VS1053 (wmset 15 08, 2026-09-07)
*   AIN3, AIN5  not identified yet
* R21 = $1F (all five in), the value the Level 1 deploy overlay codec_inputs writes: this tree
* has no overlay, and without AIN4 the VS1053 is silent.  R21 bit 8 = LRBOTH (R14 then serves
* both channels), bits 7/6 = mutes.
                    ldd       #%0010111000000000                    R23 - Reset chip
                    lbsr      SendToCODEC
                    ldd       #%0001010000000010                    R10 - DAC Interface Control 16-bit i2s
                    lbsr      SendToCODEC
                    ldd       #%0010001100000001                    R17 - ALC Control 2
                    lbsr      SendToCODEC
                    ldd       #%0010101000011111                    R21 - ADC Mux Control   AIN1-AIN5
                    lbsr      SendToCODEC
                    ldd       #%0010110000000111                    R22 - Output Mux MX[2:0] = "111"
                    lbsr      SendToCODEC
                    ldd       #%0001101000000000                    R13 - PWR Down Control, Everything on
                    lbsr      SendToCODEC
                    ldd       #%0000011111010111                    R03 - Left DAC Attenuation ($D7 = -20dB)
                    lbsr      SendToCODEC
                    ldd       #%0000100111010111                    R04 - Right DAC Attenuation ($D7 = -20dB)
                    lbsr      SendToCODEC
                    ldd       #%0000000101111001                    R00 - Left Headphone Attenuation ($79 = 0dB)
                    lbsr      SendToCODEC
                    ldd       #%0000001101111001                    R01 - Right Headphone Attenuation ($79 = 0dB)
                    lbsr      SendToCODEC
                    endc
*                   ldd       #%0001011000000010                    R11 - ADC Interface Control
*                   lbsr      SendToCODEC
*                   ldd       #%0001100111010101                    R12 - Master Mode Control
*                   lbsr      SendToCODEC

                    lda       #%10011111
                    sta       >PSG_BOTH_PORT
                    lda       #%10111111
                    sta       >PSG_BOTH_PORT
                    lda       #%11011111
                    sta       >PSG_BOTH_PORT
                    lda       #%11111111
                    sta       >PSG_BOTH_PORT
                    jmp       >GrfMod+SysRet

* Send data to CODEC and await its digestion.
*
* Entry: D = Value to send to CODEC.
*        X = Base address of CODEC.
SendToCODEC         pshs      d
w@                  lda       CODECCtrl,x
                    lsra
                    bcs       w@
                    puls      d
                    sta       CODECCmdHi,x
                    stb       CODECCmdLo,x
                    lda       #$01
                    sta       CODECCtrl,x
                    rts


*******************************************************************
* GF.PSGBell (b14) - fire-and-forget tone on the PSG (PSG_BOTH_PORT).
*   b3 = volume 0-15 (inverted below)   d1 = frequency
*******************************************************************
PSGBell             ldx       #PSG_BOTH_PORT
                    lda       #%10111111
                    sta       ,x
                    lda       #%11011111
                    sta       ,x
                    lda       #%11111111
                    sta       ,x
                    lda       >gr.b3              volume 0-15
                    coma
                    anda      #%00001111
                    ora       #%10010000
                    sta       ,x
                    ldd       >gr.d1              frequency
                    coma
                    comb
                    pshs      d
                    andb      #%00001111
                    orb       #%10000000
                    stb       ,x
                    puls      d
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lsla
                    lsla
                    lsla
                    lsla
                    anda      #%00110000
                    pshs      a
                    orb       ,s+
                    stb       ,x
                    jmp       >GrfMod+SysRet

PSGOff              lda       #%10011111
                    sta       >PSG_BOTH_PORT
                    jmp       >GrfMod+SysRet

*******************************************************************
* GF.Cell (b16) - write one cell.
*   b2 = glyph          b3 = colour attr        d1 = cell offset
*   b4 = WD.Buf (16K terminal buffer) / WD.Vicky (live $C2/$C3)
*******************************************************************
GFCell              lbsr      SetBlkC2C3
                    ldx       >gr.d1              cell offset
                    tst       >gr.b4              live or 16K buffer?
                    beq       GFCellBuf
                    lda       >gr.b2              glyph
                    sta       $2000,x
                    lda       >gr.b3              colour attr
                    sta       $4000,x
                    bra       GWRet
GFCellBuf           lda       >gr.b2              glyph
                    sta       $6000,x            T.TXT origin 0
                    leax      T.TXTCOLOR,x
                    lda       >gr.b3              colour attr
                    sta       $6000,x
GWRet               clrb
                    jmp       >GrfMod+SysRet

*******************************************************************
* GF.ClrScrn (b17) - fill the whole screen with spaces + V.FBCol.
* Dimensions / colour / live-flag read from the DSS (slot 5).
*******************************************************************
GFClrScrn           lbsr      SetBlkC2C3
                    lda       V.WHeight,u
                    beq       GWRet
                    ldb       V.WWidth,u
                    beq       GWRet
                    mul
                    cmpd      #4800
                    bls       GFCSok
                    ldd       #4800
GFCSok              tfr       d,y               Y = cell count
* b3 is scratch here, not a parameter - same spill as EraseLineCore.
                    lda       V.FBCol,u         grab colour before U is reused
                    sta       >gr.b3            spill V.FBCol (colour attr)
                    ldb       V.TermLive,u
                    beq       GFCSbuf
                    ldx       #$2000
                    ldu       #$4000
                    bra       GFCSgo
GFCSbuf             ldx       #$6000
                    ldu       #$6000+T.TXTCOLOR
GFCSgo              lda       #C$SPAC
                    ldb       >gr.b3            recover the colour attr
GFCSlp              sta       ,x+
                    stb       ,u+
                    leay      -1,y
                    bne       GFCSlp
                    jmp       >GrfMod+SysRet

*******************************************************************
* GF.Blank (b18) - blank the 16K terminal buffer.
*   b2 = fill glyph -> T.TXT     b3 = fill colour -> T.TXTCOLOR
*******************************************************************
GFBlank             lbsr      SetBlkC2C3
                    lda       >gr.b2
                    ldb       >gr.b3
                    bsr       BlankCore
                    jmp       >GrfMod+SysRet
* BlankCore - GF.Blank's body, also called by GFTermNew.  A = fill glyph,
* B = fill colour, the buffer mapped at slots 3/4.  Clobbers X and Y.
BlankCore           ldx       #$6000
                    ldy       #4800
GFBlkT              sta       ,x+
                    leay      -1,y
                    bne       GFBlkT
                    ldx       #$6000+T.TXTCOLOR
                    ldy       #4800
GFBlkC              stb       ,x+
                    leay      -1,y
                    bne       GFBlkC
                    rts


*******************************************************************
* GF.Pal (b19) - one 4-byte text-LUT entry.
*   b2 = palette register # (0-15)
*   b4 = WD.Vicky -> live $C1 / WD.Buf -> 16K T.FLUT/T.BLUT
*   b5 = 0 foreground LUT, 1 background LUT
*   d1 = LUT bytes 0-1 (blue, green)   d2 = LUT bytes 2-3 (red, alpha)
*******************************************************************
GFPal               tst       >gr.b4              live $C1 or 16K buffer?
                    beq       GFPalBuf
                    lbsr      SetBlkC0C1
                    ldx       #$2000+TEXT_LUT_FG  $C0, not $C1
                    tst       >gr.b5              0 = FG LUT, 1 = BG LUT
                    beq       GFPalIdx
                    ldx       #$2000+TEXT_LUT_BG  $C0, not $C1
                    bra       GFPalIdx
GFPalBuf            lbsr      SetBlkC2C3
                    ldx       #$6000+T.FLUT
                    tst       >gr.b5              0 = FG LUT, 1 = BG LUT
                    beq       GFPalIdx
                    ldx       #$6000+T.BLUT
GFPalIdx            ldb       >gr.b2              palette register #
                    lslb                          4 bytes per entry
                    lslb
                    abx
                    lda       >gr.d1              blue
                    sta       ,x
                    lda       >gr.d1+1            green
                    sta       1,x
                    lda       >gr.d2              red
                    sta       2,x
                    lda       >gr.d2+1            alpha
                    sta       3,x
                    jmp       >GrfMod+SysRet

*******************************************************************
* GF.BmEnable (b20) / GF.BmFree (b21) / GF.BmPalet (b22)
* Poke the bitmap registers at $3000 + b2*8 on $C0.  b2 = bitmap # (0-2).
*   Enable: b3 = control byte -> ctrl, d1 = phys addr -> 1,x, clr 3,x
*   Free  : zero all four bytes
*   Palet : b3 = CLUT# rolled with the enable bit -> ctrl
*******************************************************************
GFBmEnable          bsr       BmEnCore
                    jmp       >GrfMod+SysRet
* BmEnCore - GF.BmEnable's body, also called by GFAScrn and the new
*   bitmap calls.  Programs bitmap gr.b2's control byte from gr.b3 and its
*   24-bit address FROM THE MIRROR, which is now the only source for that
*   address: gr.d1 is no longer part of it, and neither is the caller.
*   Every writer keeps V.BMxBlk / V.BMxOff right and this reads them, so
*   the registers cannot disagree with the mirror PullBuf restores from.
*   SetBlkC0C1 touches only slots 1 and 2, so U still reaches the statics.
BmEnCore            bsr       GFBmX               X = $3000 + bitmap*8
                    lda       >gr.b3              control byte
                    sta       ,x
                    tfr       x,y                 Y = the register base
                    lda       >gr.b2              bitmap #
                    lbsr      BmGetAddr           A = block, X = offset
                    lbsr      BmRegAddr           bits 23:0 at 1,y and 2,y
                    rts
GFBmFree            bsr       GFBmX
                    clr       ,x
                    clr       1,x
                    clr       2,x
                    clr       3,x
                    clrb
                    jmp       >GrfMod+SysRet
GFBmPalet           bsr       GFBmX
                    lda       >gr.b3              CLUT# | enable
                    sta       ,x
                    clrb
                    jmp       >GrfMod+SysRet
* GFBmX - map $C0/$C1, return X = $3000 + b2*8 (b2 = bitmap #).
GFBmX               lbsr      SetBlkC0C1
                    ldb       >gr.b2              bitmap # 0-2
                    lda       #8
                    mul
                    addd      #$3000
                    tfr       d,x
                    rts

*******************************************************************
* V.BMFlags helpers.  One byte holds, per bitmap, its size (bits 0-2,
* set = the 8-block 320x200 size) and its ownership (bits 4-6, set =
* the DRIVER allocated the blocks and must free them).  See the comment
* beside V.BMFlags in wildbits_vtio.d for why both are needed.
*
* BmFlagMask - A = bitmap # (0-2) in, A = BM.Small shifted left by it out.
*   Shift left another four for the ownership bit.  B, X, Y, U kept.
*******************************************************************
BmFlagMask          pshs      b
                    ldb       #BM.Small
                    tsta
                    beq       bfmx@
bfml@               lslb
                    deca
                    bne       bfml@
bfmx@               tfr       b,a
                    puls      b,pc

* BmClrOff - zero bitmap gr.b2's offset, so a bitmap that is allocated,
*   freed and allocated again does not inherit the last one's.  U = the
*   statics.  Clobbers A and Y; X is left alone because GFAScrn needs it.
BmClrOff            lda       >gr.b2              bitmap #
                    lsla                          two offset bytes each
                    leay      V.BM0Off,u
                    leay      a,y
                    clr       ,y
                    clr       1,y
                    rts

* BmFlagClr - clear BOTH of bitmap gr.b2's bits, so a freed bitmap is
*   neither owned nor remembered as the small size.  U = the statics.
BmFlagClr           lda       >gr.b2              bitmap #
                    bsr       BmFlagMask          A = its size bit
                    tfr       a,b
                    lsla
                    lsla
                    lsla
                    lsla                          A = its ownership bit
                    pshs      a
                    orb       ,s+                 B = both bits
                    comb
                    andb      V.BMFlags,u
                    stb       V.BMFlags,u
                    rts

SetBlkC0C1          pshs      cc
                    orcc      #IntMasks
		    lda	      #EDIT_LUT_1+ACT_LUT_1
		    sta	      MMU_MEM_CTRL
                    clra
                    ldx       #gr.DATImg+2
                    ldb       #VICKY_BLK
                    stb       MMU_SLOT_1 $2000
                    std       ,x++
                    ldb       #FONT_BLK
                    stb       MMU_SLOT_2 $4000
                    std       ,x
                    puls      cc,pc

SetBlkC2C3          pshs      cc,d,x
                    orcc      #IntMasks
		    lda	      #EDIT_LUT_1+ACT_LUT_1
		    sta	      MMU_MEM_CTRL
                    clra
                    ldx       #gr.DATImg+2
                    ldb       #TEXT_RAM_BLK
                    stb       MMU_SLOT_1 $2000
                    std       ,x++
                    ldb       #COLOR_RAM_BLK
                    stb       MMU_SLOT_2 $4000
                    std       ,x++
                    ldb       >gr.TermBlk
                    stb       MMU_SLOT_3 $6000
                    std       ,x++
                    incb
                    stb       MMU_SLOT_4 $8000
                    std       ,x++
                    ldb       >gr.VBlk
                    stb       MMU_SLOT_5 $A000
                    std       ,x
		    ldu	      >gr.U5
                    puls      cc,d,x,pc






* SetStat SS.TermSel - R$X = terminal id 0-8: show that terminal on the
*   AltISR's next tick, as 1B 21 does, without any I/O on the target.  SCF
*   queues a write, SetStat, open or close to a device behind the process
*   that holds it busy while reading (BASIC09 at its prompt does), so vt
*   sends this on its own path.  Not open or out of range = E$IllArg; the
*   live terminal = nothing to do.  Target first, then the request.
SSTermSel           ldd       R$X,x
                    cmpd      #G.TermMax
                    bhs       bad@
                    pshs      b                   the id
                    lda       #gr.TermSz
                    mul
                    ldx       #gr.TermTbl
                    abx                           X = its entry
                    puls      b
                    lda       T.Flags,x
                    bita      #T.Init
                    beq       bad@
                    cmpb      >gr.LiveTerm        already on screen?
                    beq       ok@
                    stb       >gr.SwitchTerm
                    lda       #SW.Goto
                    sta       >gr.SwitchReq
ok@                 clrb
                    jmp       >GrfMod+SysRet
bad@                comb
                    ldb       #E$IllArg
                    jmp       >GrfMod+SysRet

*******************************************************************
* The sprite calls.  A program keeps the ONLY copy of its records and
* registers where it is; the driver keeps no copy at all, and a terminal
* switch fills the registers from the incoming terminal's own table
* (gr.SprTbl, defs/wildbits_vtio.d).  SS.SprSet - records pushed from a
* caller's buffer - is gone: it was a second writer the switch could not
* reproduce, so a switch away and back silently undid it.
*
* One mapping convention throughout, so the same base serves every path:
*   slot 1  $C0, records at $2000+SPRITE_REC_OFF (PullCore's SetBlkC0C1
*           already leaves $C0 there; SprMapC0 puts it there otherwise)
*   slots 3, 4  the registered table, at $6000 - consecutive, so a table
*           that crosses a block boundary is still one straight copy
* Both pairs are scratch in the paths that use them: a SetStat handler has
* finished with $C2/$C3 and the 16K buffer, and PullCore has finished with
* the buffer by the time the sprites are restored.
*
* SetStat SS.SprReg - register this terminal's record table, or give it up.
*   R$U = records, 1-128; 0 gives the table up, whatever else is passed.
*   R$Y = 0    AUTO: R$X is the table's address in the caller's own map,
*                    and the blocks come from its DAT image (gr.PDAT) -
*                    the one moment that image is there to read.
*   R$Y <> 0   MANUAL: R$Y = the first block in the high byte, the block
*                    the table crosses into in the low byte, and R$X is
*                    the offset WITHIN the first block, $0000-$1FFF.
*                    For a table in memory the program owns but has not
*                    mapped - an F$AllRAM block it maps only to edit -
*                    which auto cannot see.  A program with no window to
*                    spare should not have to open one just to register.
* The two are told apart by R$Y alone, which is sound because the high
* byte is a block number and block 0 is the system block: no table can
* ever live there, so R$Y = 0 is never a legitimate manual call.
* R$A is not a parameter - in a SetStat it is the path.
*
* Nothing is checked about the blocks themselves.  The driver cannot: the
* kernel's block map records allocated/free, not WHO owns a block.  It is
* no new exposure either - F$MapBlk maps any block a caller names with no
* ownership check at all (fmapblk.asm) - and the driver only ever READS
* these blocks, so the worst a wrong registration does is draw rubbish.
*
* On a LIVE terminal registering also turns off the records the table does
* not cover, so the last program's sprites do not outlive it; giving the
* table up on a live terminal turns them all off.
* Exit: B = 0, or carry + E$IllArg (a count above 128; a manual offset
*   past $1FFF or first block 0; or a table that crosses into a block the
*   call did not name - slot 7 in auto, a zero low byte in manual).
*******************************************************************
SSSprReg            ldd       R$U,x               records, 0 = give the table up
                    lbeq      SRDereg
                    cmpd      #SPR.Max
                    lbhi      SRBad
                    pshs      b                   ,s = the count
                    lbsr      SprRow              Y = this terminal's row
                    ldd       R$Y,x               0 = auto, otherwise the blocks
                    bne       SRMan
                    ldd       R$X,x               auto: the table's address
                    pshs      d                   ,s = the address  2,s = the count
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                          A = the caller's slot 0-7
                    lsla
                    ldx       #gr.PDAT+1          low byte of each 2-byte entry
                    leax      a,x                 X -> its block for that slot
                    lda       ,x
                    sta       SB.Blk0,y
                    clra                          slot 7 has no next block
                    cmpx      #gr.PDAT+15
                    beq       SRAuto1
                    lda       2,x
SRAuto1             sta       SB.Blk1,y
                    puls      d                   the address again
                    anda      #$1F
                    std       SB.Off,y            the offset within that block
                    bra       SRSpan
SRMan               tsta                          block 0 is the system block
                    beq       SRBad1
                    sta       SB.Blk0,y
                    stb       SB.Blk1,y
                    ldd       R$X,x               the offset within the first block
                    cmpd      #$2000
                    bhs       SRBad1
                    std       SB.Off,y
SRSpan              ldb       ,s
                    stb       SB.Cnt,y            the count
                    lda       #SPR.RecL
                    mul
                    addd      SB.Off,y            D = where the table ends
                    ldb       #SB.Reg
                    cmpd      #$2000
                    bls       SRStore             it ends inside the one block
                    tst       SB.Blk1,y
                    beq       SRBad1              it crosses into a block we were not given
                    ldb       #SB.Reg+SB.Span
SRStore             stb       SB.Flags,y
                    leas      1,s
* The live terminal's leftover records - the ones this table does not
* cover - go off now, so the program that had the terminal before this one
* does not keep its sprites on screen.
                    tst       V.TermLive,u
                    beq       SROK
                    lbsr      SprMapC0            $C0 in slot 1
                    lbsr      SprRow
                    ldx       #$2000+SPRITE_REC_OFF
                    ldb       SB.Cnt,y
                    lbsr      SprClrFrom
                    lda       #1
                    sta       >gr.SprDirty
SROK                clrb
                    jmp       >GrfMod+SysRet
SRDereg             lbsr      SprRow              Y = this terminal's row
                    clr       SB.Flags,y
                    tst       V.TermLive,u
                    beq       SROK
                    lbsr      SprMapC0            $C0 in slot 1
                    ldx       #$2000+SPRITE_REC_OFF
                    clrb                          every record off
                    lbsr      SprClrFrom
                    clr       >gr.SprDirty
                    clrb
                    jmp       >GrfMod+SysRet
SRBad1              leas      1,s
SRBad               comb
                    ldb       #E$IllArg
                    jmp       >GrfMod+SysRet

*******************************************************************
* SetStat SS.SprPush - put part of the registered table on screen.
*   R$Y = first record     R$U = count, first + count <= SB.Cnt
* No caller buffer: the records come from the registered table.
* On a BACKGROUND terminal it does nothing and returns clean - the table
* already holds the truth and the switch back copies all of it.
* Exit: B = 0, or carry + E$NotRdy (nothing registered) / E$IllArg (a
*   range outside the registered count).
*******************************************************************
SSSprPush           lbsr      SprRow              Y = this terminal's row
                    lda       SB.Flags,y
                    bita      #SB.Reg
                    beq       SPNone
* Both ends are checked before they are added: a first or a count large
* enough to wrap the addition would otherwise pass a check on the sum and
* copy from somewhere else entirely.
                    ldd       R$Y,x               first record
                    cmpd      #SPR.Max-1
                    bhi       SPBad
                    ldd       R$U,x               the count
                    beq       SPBad
                    cmpd      #SPR.Max
                    bhi       SPBad
                    addd      R$Y,x               first + count, which cannot wrap now
                    pshs      d
                    clra
                    ldb       SB.Cnt,y
                    cmpd      ,s++                past the end of the table?
                    blo       SPBad
                    tst       V.TermLive,u
                    beq       SPOK                not on screen: the table is the truth
                    ldd       R$Y,x               first record
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola                          D = 8 * first
                    pshs      d                   ,s = it, twice over
                    pshs      d
                    lbsr      SprMapTbl           slots 3/4 = the table, U = record 0
                    puls      d
                    leau      d,u                 U = the first record to send
                    lbsr      SprMapC0            $C0 in slot 1
                    puls      d
                    addd      #$2000+SPRITE_REC_OFF
                    tfr       d,y                 Y = where it lands in Vicky
                    ldx       #gr.PDRGS
                    ldd       R$U,x
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola                          D = 8 * count
                    lbsr      CpyBlk
                    lda       #1
                    sta       >gr.SprDirty
SPOK                clrb
                    jmp       >GrfMod+SysRet
SPBad               comb
                    ldb       #E$IllArg
                    jmp       >GrfMod+SysRet
SPNone              comb
                    ldb       #E$NotRdy
                    jmp       >GrfMod+SysRet

*******************************************************************
* SprRestore - a terminal is coming forward (GSEnter, after PullCore):
*   the sprite registers get its registered table, and the records that
*   table does not cover are turned off.  A terminal with no registration
*   has every record turned off - and nothing done at all when
*   gr.SprDirty says they are already clear.
* Entry: U = the incoming terminal's statics, $C0 at $2000 (PullCore's
*   SetBlkC0C1 leaves it there).
* Exit: U as it was.  D, X and Y are destroyed.
*******************************************************************
SprRestore          pshs      u                   the statics, for the exit
                    lbsr      SprRow              Y = its row
                    lda       SB.Flags,y
                    bita      #SB.Reg
                    bne       SRSTbl
                    tst       >gr.SprDirty        nothing registered
                    beq       SRSX                and nothing on screen either
                    ldx       #$2000+SPRITE_REC_OFF
                    clrb                          every record off
                    lbsr      SprClrFrom
                    clr       >gr.SprDirty
SRSX                puls      u,pc
SRSTbl              ldb       SB.Cnt,y
                    pshs      b                   ,s = the count  1,s = the statics
                    lbsr      SprMapTbl           slots 3/4 = the table, U = record 0
                    ldb       ,s
                    lda       #SPR.RecL
                    mul                           D = the table's length
                    ldy       #$2000+SPRITE_REC_OFF
                    lbsr      CpyBlk
                    ldx       #$2000+SPRITE_REC_OFF
                    ldb       ,s+
                    lbsr      SprClrFrom          the records it does not cover, off
                    lda       #1
                    sta       >gr.SprDirty
                    puls      u,pc

*******************************************************************
* SprRow - Y = this terminal's gr.SprTbl row, from V.TermID.  U must be
*   the terminal's statics.  Only Y changes.
*******************************************************************
SprRow              pshs      d
                    lda       V.TermID,u
                    ldb       #SB.Size
                    mul
                    ldy       #gr.SprTbl
                    leay      d,y
                    puls      d,pc

*******************************************************************
* SprMapTbl - the registered table of the row at Y into slots 3 and 4
*   ($6000 and $8000, consecutive, so a table that crosses a block
*   boundary stays one run of bytes).  Exit U = its record 0.
*   D, X and Y are kept.
*******************************************************************
SprMapTbl           pshs      cc,d,x
                    orcc      #IntMasks
                    lda       #EDIT_LUT_1+ACT_LUT_1
                    sta       MMU_MEM_CTRL
                    ldx       #gr.DATImg+6
                    clra
                    ldb       SB.Blk0,y
                    stb       MMU_SLOT_3          $6000
                    std       ,x++
                    ldb       SB.Blk1,y
                    stb       MMU_SLOT_4          $8000
                    std       ,x
                    ldd       SB.Off,y
                    addd      #$6000
                    tfr       d,u                 U = the table through slot 3
                    puls      cc,d,x,pc

*******************************************************************
* SprMapC0 - $C0 in slot 1, so the sprite records are at
*   $2000+SPRITE_REC_OFF - where SetBlkC0C1 leaves them, so the restore
*   and the push share one base.  Every register is kept.
*******************************************************************
SprMapC0            pshs      cc,d
                    orcc      #IntMasks
                    lda       #EDIT_LUT_1+ACT_LUT_1
                    sta       MMU_MEM_CTRL
                    clra
                    ldb       #VICKY_BLK
                    stb       MMU_SLOT_1          $2000
                    std       >gr.DATImg+2
                    puls      cc,d,pc

*******************************************************************
* SprClrFrom - turn off sprite records B..127: the control byte of each,
*   stride 8.  B = 128 or more does nothing.
*   Entry: B = the first record to clear
*          X = the mapped address of record 0's control byte
*   Every register is kept.
*******************************************************************
SprClrFrom          pshs      cc,d,x
                    cmpb      #SPR.Max
                    bhs       SCFX
                    pshs      b                   the first record
                    lda       #SPR.RecL
                    mul                           D = 8 * first
                    leax      d,x                 X = its control byte
                    ldb       #SPR.Max
                    subb      ,s+                 B = records left
SCF1                clr       ,x
                    leax      SPR.RecL,x
                    decb
                    bne       SCF1
SCFX                puls      cc,d,x,pc

*******************************************************************
* SetStat SS.TsSet - define tile set R$Y from REGISTERS.  No caller
*   buffer: three values need no record, so this call maps nothing.
*   R$Y  high byte = CFG (bit 3 SQUARE - bits 7:4 are wired to nothing
*        in the core), low byte = the tile set number 0-7
*   R$X  the block holding the start of the tile set, 1-255.  Block 0
*        clears the tile set, and the offset is then ignored.
*   R$U  the offset WITHIN that block, $0000-$1FFF.  Any offset is
*        legal: TyVKY_TileMap_SM.v adds the base at full width with no
*        alignment.
* No program holds a 24-bit physical address - it holds a block and an
*   offset - so this is the only place the conversion happens.  The
*   V.TSn mirror keeps the four bytes in REGISTER order (CFG, ADDR
*   hi/mid/lo) so PullBuf's straight copy is unchanged; the registers at
*   $C0 $1180+4*n are written only when live.  See docs/tile-api.md.
*******************************************************************
SSTsSet             ldb       R$Y+1,x             tile set #
                    cmpb      #7
                    bhi       TsBad
                    lslb
                    lslb                          B = 4*n
                    pshs      b                   ,s = 4*n
                    ldd       R$U,x               the offset
                    cmpd      #$1FFF
                    bhi       TsOff
                    ldd       R$X,x               the block
                    cmpd      #$FF
                    bhi       TsOff
                    ldy       >gr.U5              this terminal's statics (slot 5)
                    leay      V.TS0AddrH,y
                    ldb       ,s
                    leay      b,y                 Y -> V.TSn
                    lda       R$Y,x               CFG
                    sta       ,y
                    ldb       R$X+1,x             B = block
                    bne       tsad@
                    clr       1,y                 block 0 clears the set
                    clr       2,y
                    clr       3,y
                    bra       tslv@
* address = block * $2000 + offset, so ADDR hi = block >> 3, ADDR mid =
* (block & 7) << 5 with the offset's high byte (<= $1F) in the low bits,
* and ADDR lo is the offset's low byte unchanged.
tsad@               tfr       b,a
                    lsra
                    lsra
                    lsra                          A = block >> 3
                    sta       1,y                 ADDR hi
                    andb      #7
                    lslb
                    lslb
                    lslb
                    lslb
                    lslb                          B = (block & 7) << 5
                    lda       R$U,x               the offset's high byte
                    pshs      a
                    orb       ,s+
                    stb       2,y                 ADDR mid
                    lda       R$U+1,x
                    sta       3,y                 ADDR lo
tslv@               ldu       >gr.U5
                    tst       V.TermLive,u
                    beq       done@
                    lbsr      SetBlkC0C1          $C0 at $2000
                    ldu       >gr.U5
                    leau      V.TS0AddrH,u
                    ldb       ,s
                    leau      b,u
                    ldy       #$3180
                    leay      b,y
                    ldd       #4
                    lbsr      CpyBlk
done@               leas      1,s
                    clrb
                    jmp       >GrfMod+SysRet
TsOff               leas      1,s
TsBad               comb
                    ldb       #E$IllArg
                    jmp       >GrfMod+SysRet

*******************************************************************
* SetStat SS.TmSet - define tile map R$Y (0-2) from the caller's 12-byte
*   record at R$X: CTRL (bit 0 enable, bit 4 TILE_SIZE 1=8x8), then
*   BLOCK and a 2-byte OFFSET within it, SIZE_X (2), SIZE_Y (2), X
*   position (2), Y position (2); the 16-bit fields are high byte first.
*   No program holds a 24-bit physical address, so bytes 1-3 are a block
*   and an offset and this handler converts them.  The V.TMn mirror keeps
*   the REGISTER order (its MapX/RSRV/MapY/RESRV names predate it), so
*   PullBuf's straight copy is unchanged.  SIZE_X/Y are 10-bit fields,
*   up to 1024 tiles.  See docs/tile-api.md.
* The mirror (V.TMn, same order) always; the registers at $C0 $1100+12*n
*   only when live.  PullBuf reprograms the
*   tile map registers from the mirror on a switch.
*******************************************************************
SSTmSet             ldd       R$Y,x               tile map #
                    cmpd      #2
                    bhi       TmBad
                    pshs      b                   ,s = n
                    ldd       R$X,x
                    ldy       #12
                    lbsr      MapCallBuf          U = record through slot 1
                    bcs       TmOff
                    ldy       >gr.U5              this terminal's statics (slot 5)
                    leay      V.TM0,y
                    lda       #12
                    ldb       ,s
                    mul                           B = 12*n
                    leay      b,y                 Y -> V.TMn
                    ldb       #12
loop@               lda       ,u+
                    sta       ,y+
                    decb
                    bne       loop@
* Y is now past V.TMn+12.  Bytes 1-3 arrived as block, offset hi, offset
* lo; turn them into the address the hardware wants.  ADDR lo needs no
* work - the offset's low byte IS the address's low byte.
                    ldd       -10,y               the offset
                    cmpd      #$1FFF
                    bhi       TmOff
                    ldb       -11,y               B = block
                    beq       tmz@
                    tfr       b,a
                    lsra
                    lsra
                    lsra                          A = block >> 3
                    andb      #7
                    lslb
                    lslb
                    lslb
                    lslb
                    lslb                          B = (block & 7) << 5
                    orb       -10,y               in the offset's high byte
                    std       -11,y               ADDR hi and ADDR mid
                    bra       tmlv@
* Block 0 is address 0.  A record of twelve zeroes is how a program turns
* a map off, so this must not be an error.
tmz@                clr       -11,y
                    clr       -10,y
                    clr       -9,y
tmlv@               ldu       >gr.U5
                    tst       V.TermLive,u
                    beq       done@
                    lbsr      SetBlkC0C1          $C0 at $2000
                    lda       #12
                    ldb       ,s
                    mul                           B = 12*n
                    ldu       >gr.U5
                    leau      V.TM0,u
                    leau      b,u
                    ldy       #$3100
                    leay      b,y
                    ldd       #12
                    lbsr      CpyBlk
done@               leas      1,s
                    clrb
                    jmp       >GrfMod+SysRet
TmOff               leas      1,s
TmBad               comb
                    ldb       #E$IllArg
                    jmp       >GrfMod+SysRet

*******************************************************************
* SetStat SS.TmScrl - scroll tile map R$Y (0-2).
*   R$Y = tile map # 0-2
*   R$X = X scroll, the layout of record bytes 8-9
*   R$U = Y scroll, record bytes 10-11
* This is the ONE tile operation with no program-owned buffer behind
*   it.  Everything else a program does to a tile map - the cells, the
*   pixels, the size - it does to its own memory, and the call only
*   says where that memory is.  The scroll position exists nowhere but
*   these registers, so without this call a scrolling game has to
*   re-send the whole 12-byte SS.TmSet record through MapCallBuf, 60
*   times a second, to change two bytes.  tmtest2 in the joust tree
*   measured that at about 660 us a frame for three layers.
* The mirror (V.TMnScrlX/Y) always; the registers at $C0 $1108+12*n
*   only when live.  PullBuf reprograms the whole 36-byte tile map
*   image from the mirror on a switch, so the scroll comes back with
*   everything else and nothing extra is needed there.
*******************************************************************
SSTmScrl            ldd       R$Y,x               tile map #
                    cmpd      #2
                    bhi       TmBad
                    lda       #12
                    mul                           B = 12*n, n is 0-2
                    pshs      b                   ,s = 12*n
                    ldy       >gr.U5              this terminal's statics
                    leay      V.TM0ScrlX,y
                    ldb       ,s
                    leay      b,y                 Y -> V.TMnScrlX
                    ldd       R$X,x               X scroll
                    std       ,y
                    ldd       R$U,x               Y scroll
                    std       2,y
                    ldu       >gr.U5
                    tst       V.TermLive,u
                    beq       tscx@
                    lbsr      SetBlkC0C1          $C0 at $2000
                    ldu       >gr.U5
                    leau      V.TM0ScrlX,u
                    ldb       ,s
                    leau      b,u
                    ldy       #$3108
                    leay      b,y
                    ldd       #4
                    lbsr      CpyBlk
tscx@               leas      1,s
                    clrb
                    jmp       >GrfMod+SysRet

*******************************************************************
* SetStat SS.ClutWrite - write CLUT entries from the caller's buffer.
*   R$X = count x 4 bytes: blue, green, red, alpha
*   R$Y = CLUT # 0-3 (high byte), first entry 0-255 (low byte)
*   R$U = count 1-256, first+count <= 256
* The SS.DfPal targets: T.CLUTn in the terminal's 16K switch buffer
*   (slot 4, which PullBuf restores on a switch) when it has one, and the
*   live CLUT at $C1 $1000+$400*n (in slot 3) when the terminal is live or
*   has no buffer yet.  The entries come in through slots 1-2 (MapCallBuf).
*******************************************************************
SSClutWrite         lda       R$Y,x               CLUT #
                    cmpa      #3
                    lbhi      ClutBad
                    ldd       R$U,x               count
                    lbeq      ClutBad
                    cmpd      #256
                    lbhi      ClutBad
                    addb      R$Y+1,x
                    adca      #0                  D = first + count
                    cmpd      #256
                    lbhi      ClutBad
                    ldd       R$U,x
                    lslb
                    rola
                    lslb
                    rola                          D = 4*count
                    pshs      d                   ,s = length
                    lda       R$Y,x
                    lsla
                    lsla                          A = high byte of n*$400
                    pshs      a
                    clra
                    ldb       R$Y+1,x
                    lslb
                    rola
                    lslb
                    rola                          D = 4*first
                    adda      ,s+                 D = n*$400 + 4*first
                    pshs      d                   ,s = entry offset  2,s = length
                    lda       V.TermLive,u
                    ldb       V.TermBufBlk,u
                    pshs      d                   ,s = live  1,s = buffer blk  2,s = offset  4,s = length
                    ldd       R$X,x               entries in the caller's map
                    ldy       4,s
                    lbsr      MapCallBuf          U = entries through slot 1
                    bcs       ClutOff
                    tst       1,s
                    beq       ClutLive            no buffer yet: live CLUT only
                    ldd       2,s
                    addd      #$6000+T.CLUT0      T.CLUTn entry in the buffer
                    tfr       d,y
                    pshs      u
                    ldd       6,s                 length
                    lbsr      CpyBlk
                    puls      u
                    tst       ,s                  live?
                    beq       ClutDone            no - PullBuf programs it on the switch
ClutLive            pshs      cc
                    orcc      #IntMasks
                    lda       #EDIT_LUT_1+ACT_LUT_1
                    sta       MMU_MEM_CTRL
                    clra
                    ldb       #FONT_BLK
                    stb       MMU_SLOT_3          $C1 at $6000
                    std       >gr.DATImg+6
                    puls      cc
                    ldd       2,s
                    addd      #$6000+GRPH_LUT0_OFF
                    tfr       d,y
                    ldd       4,s                 length
                    lbsr      CpyBlk
ClutDone            leas      6,s
                    clrb
                    jmp       >GrfMod+SysRet
ClutOff             leas      6,s
ClutBad             comb
                    ldb       #E$IllArg
                    jmp       >GrfMod+SysRet

*******************************************************************
* GetStat SS.BmBlk - bitmap R$Y (0-2): R$X = first block (0 = not
*   allocated), R$A = the control byte.
* From the V.BMxCl_En / V.BMxBlk mirror, so it answers for a background
*   terminal too.
*
* THE CONTROL BYTE, corrected 2026-09-20 from the rc16 RTL.  This comment
* and docs/grfdrv256-api.md both used to say "bits 2:1 CLUT, bit 0 enable",
* which is wrong in a way that matters: it implies bit 3 is free, and it is
* not.  The live decode is TinyVickyCoreModule.v:484-495 feeding
* TyVky_BitMap_State_Machine.v:136-147 (NOT the X-offset/priority block in
* TinyVicky_BM_Registers.v, which is inside a /* */ comment and is dead):
*
*   bit  0   layer enable
*   bits 3:1 CLUT number.  THREE bits, but the LUT BRAM address is only
*            [9:0], so LUT 4-7 alias 0-3 - there are just 4 CLUTs.
*   bit  4   HIRES4: this plane is 640x240 4bpp, one byte = two dots,
*            high nibble the LEFT dot, nibble 0 transparent per dot.
*   bits 7:5 palette GROUP, used when HIRES4 is set: the colour is
*            entry (LUT mod 4)*256 + GROUP*16 + nibble.
*
* So there are NO spare bits in this byte.  The global equivalent of bits
* 4 and 7:5 is $FFCB (TinyVickyControl_Registers.v:138, "GFX MODE"), which
* wildbits.d still calls VKY_RESERVED_03; setting the global bit forces
* ALL THREE planes to 4bpp, while the per-plane bit turns one plane hi-res
* on its own, so per-plane is strictly more capable and $FFCB is best left
* alone.  A hi-res bitmap is the same 76,800 bytes as a 320x240 8bpp one -
* the per-line stride is a hard-wired 320 - so the mode costs no extra
* memory and is a display attribute, not an allocation parameter.
*******************************************************************
GSBmBlk             ldd       R$Y,x               bitmap #
                    cmpd      #2
                    lbhi      BmBad
                    lslb                          two mirror bytes per bitmap
                    leay      V.BM0Cl_En,u
                    leay      b,y                 Y -> V.BMxCl_En, V.BMxBlk at 1,y
                    lda       ,y
                    sta       R$A,x
                    clra
                    ldb       1,y
                    std       R$X,x
                    lbra      StatOK

* GetStat SS.BmClear - R$X = 0 idle, 1 a fill is still outstanding.
*   The companion to the SetStat, which is asynchronous: a program that
*   means to write pixels into the bitmap itself must wait for this to
*   read 0 or have them erased.  It is also the core check - see the
*   SetStat's header for why a fill that never finishes is the safe
*   failure and not a corrupting one.
GSBmClear           clra
                    ldb       DMA.Base+DMA_STATUS_REG
                    andb      #$80
                    beq       GSBmClrX
                    ldb       #1
GSBmClrX            std       R$X,x
* And hand back the destination the ENGINE is holding, not the driver's
* idea of it, read through the permuted read map (see DMA_DEST_RD_* in
* wildbits.d).  R$Y = the high byte, R$U = mid:low.  Diagnostic: it is
* the only way to see what actually reached the registers.
                    clra
                    ldb       DMA.Base+DMA_DEST_RD_H
                    std       R$Y,x
                    lda       DMA.Base+DMA_DEST_RD_M
                    ldb       DMA.Base+DMA_DEST_RD_L
                    std       R$U,x
                    lbra      StatOK

* GetStat SS.BmLine - R$X = the pixels still queued in the line engine's
*   FIFO, 0 to LD.Depth.  For a caller that would rather pace itself
*   across frames than be told its batch came up short.  The FIFO is one
*   piece of hardware shared by every terminal, so this answers for the
*   machine and not for this terminal.
GSBmLine            lbsr      LineMapC0           X = the line registers
                    lda       LD.FifoH,x
                    ldb       LD.FifoL,x
                    std       >gr.PDRGS+R$X
                    lbra      StatOK


*******************************************************************
* SysRet - Return to System
* Call this instead of jmp [>D.Flip0]
*******************************************************************
SysRet
                    tfr       cc,a      ; Save CC status
                    orcc      #IntMasks ; Disable interrupts
                    ldx       >gr.Stack ; Get saved system stack
                    clr       >gr.Busy  ; Clear busy flag

* Reset DP to 0 for system
                    pshs      a
                    clra
                    tfr       a,dp
                    puls      a

                    jmp       [>D.Flip0] ; Return to system


*******************************************************************
* Helper Routines
*******************************************************************

* Add your F256-specific helper routines here

;;; y=DAT Image Address
;;; x=logical address in process
;;; find the block where x is and map it into Slot 1
GMapAddr2Blk        pshs      cc,d,x    x=address in process;y=Process DAT
                    tfr       x,d
                    lsra
                    lsra
                    lsra
                    lsra
                    anda      #%0001110
                    inca
                    lda       a,y
                    orcc      #IntMasks IRQ return clears EDIT_LUT: select and write masked
                    ldb       #EDIT_LUT_1+ACT_LUT_1
                    stb       MMU_MEM_CTRL
                    sta       MMU_SLOT_1
                    clr       gr.DATImg+2
                    sta       gr.DATImg+3
                    puls      cc,d,x,pc


*******************************************************************
* MapCallBuf - map a caller buffer into slot 1 ($2000), plus the caller's
*   next block into slot 2 ($4000) when the buffer runs into it.  The
*   SS.DfPal mapping, for any length up to $2000.
* Entry: D = buffer address in the caller's map, Y = length (1-$2000)
*        gr.PDAT = the caller's DAT image (vtio's CallGrfDrv)
* Exit:  U = buffer address as seen through slot 1
*        carry set = the buffer runs off the top of the caller's map
*******************************************************************
MapCallBuf          pshs      d,x
                    anda      #$1F
                    addd      #$2000
                    tfr       d,u                 U = buffer through slot 1
                    ldb       ,s                  caller address high byte
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lsrb                          B = caller slot 0-7
                    lslb
                    ldx       #gr.PDAT+1          low byte of each 2-byte entry
                    abx                           X -> caller's block for that slot
                    pshs      cc
                    orcc      #IntMasks
                    lda       #EDIT_LUT_1+ACT_LUT_1
                    sta       MMU_MEM_CTRL
                    clra
                    ldb       ,x
                    stb       MMU_SLOT_1          $2000
                    std       >gr.DATImg+2
                    tfr       y,d                 D = length
                    pshs      u
                    addd      ,s++                D = end of buffer + 1
                    cmpd      #$4000
                    bls       mapped@             ends inside slot 1
                    cmpx      #gr.PDAT+15         slot 7 has no next block
                    beq       off@
                    clra
                    ldb       2,x
                    stb       MMU_SLOT_2          $4000
                    std       >gr.DATImg+4
mapped@             puls      cc
                    andcc     #^Carry
                    puls      d,x,pc
off@                puls      cc
                    orcc      #Carry
                    puls      d,x,pc


* This is from L1 Coco vtio
* CpyBlk - Copy contiguous block of memory with a byte value (for screen scrolling, insert/delete line,etc.)
* New, more optimized version (I hope) as of March 12, 2018
* Entry: D=size of copy
*        Y=ptr to destination of copy
*        U=ptr to source of copy (PULU from here on 6809 version)
*  Exit: U=Ptr to end of source copy+1
*        Y=Ptr to end of dest copy+1
*        D=NOTE: NEW CODE WILL HAVE D AS END ADDRESS OF SOURCE OF COPY
CpyBlk              leax      d,u       Calculate source end address
                    pshs      x         Save on stack to compare with so we know when to stop
                    andb      #$03      Check if we have odd bytes leftover (1-3)
                    beq       CpyLpSt   No, skip to check if copy is done, and stack blast 4 byte chunks if yes
CpyLp2              lda       ,u+       (6) Copy extra 1-3 bytes
                    sta       ,y+       (6)
                    decb                (2)
                    bne       CpyLp2    (3)
                    bra       CpyLpSt   Start with cmpu to end of copy (if copy was only 1-3 bytes, we are done already)

* Now, copy all 4 byte chunks. End address remains the same, so we can eliminate some stuff we had before
CpyLp               pulu      d,x       Get 4 bytes from source (ascending order)
                    std       ,y++      Copy to destination
                    stx       ,y++
CpyLpSt             cmpu      ,s        Done 4 byte blast copy?
                    blo       CpyLp     No, keep doing until done
                    puls      pc,d      Get end address of source copy and return


                    emod
eom                 equ       *
                    end
