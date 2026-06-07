********************************************************************
* scrn - Kings Quest III screen module
*
* Note the header shows a data size of 0 called from the sierra module
* and accesses data set up in that module.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2003/03/06  Paul W. Zibaila
* Disassembly of original distribution.
* Annotated by /annotate-asm (Claude Code) 2026-05-12:
*   - Renamed disassembled labels to meaningful names
*   - Added inline comments to every instruction

                    nam       scrn
                    ttl       Kings Quest III screen module

* Disassembled 00/00/00 00:15:39 by Disasm v1.6 (C) 1988 by RML

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

*  equates for common data used in this module

MmuBlkNum           equ       $0012     map block value (word)
BlkMapLow           equ       $001C
BlkMapHigh          equ       $001E
u0024               equ       $0024
HiResBase           equ       $002C
u0030               equ       $0030
u0038               equ       $0038
u003E               equ       $003E
SprCurRow           equ       $0040
SprCurCol           equ       $0041
SierraPdBlk         equ       $0042     Sierra process descriptor block
Sierra2ndBlk        equ       $0043     Sierra 2nd 8K data block
PaletteFlag         equ       $0045     flag for palettes in sierra
ScrAddrHi           equ       $0046     first byte of hi res screen mem addr
ScrAddrLo           equ       $0047     second byte of hi res screen mem addr
u007E               equ       $007E
u0080               equ       $0080
u0081               equ       $0081
RowCount            equ       $00A0     busy address here
StripWidth          equ       $00A1
RowStride           equ       $00A2
ViewRightX          equ       $00A3
DrawY1              equ       $00A4
ClipLeft            equ       $00A5
ClipRight           equ       $00A6
ClipHeight          equ       $00A7
ClipBottom          equ       $00A8
ClipWidth           equ       $00A9
OverlapLeft         equ       $00AA
OverlapTop          equ       $00AB
OverlapSize         equ       $00AC
u00C0               equ       $00C0
u00C6               equ       $00C6
u00CC               equ       $00CC
u00DE               equ       $00DE
u00E0               equ       $00E0
u00F6               equ       $00F6
u00F8               equ       $00F8
u00FC               equ       $00FC
u00FE               equ       $00FE
u00FF               equ       $00FF

PicVisible          equ       $0100     pic_visible
SierraPalette       equ       $024D
DatTask1Slot1       equ       $FFA9


size                equ       .
name                equ       *
                    fcs       /scrn/
                    fcb       $00

* This module is linked to in sierra
* upon entry
*   a -> type language
*   b -> attributes / revision level
*   x -> address of the last byte of the module name + 1
*   y -> module entry point absolute address
*   u -> module header absolute address

start               equ       *
                    lbra      DrawStrip dispatch 0: blit picture strip to screen
                    lbra      SetupDrawStrip dispatch 1: forward args and call DrawStrip
                    lbra      ClearScreen dispatch 2: fill screen with value in D
                    lbra      ClearScreenBlack dispatch 3: clear screen to black
                    lbra      DrawBorder dispatch 4: draw 4-sided rectangle border
                    lbra      DrawSprites dispatch 5: render 8×8 font glyphs
                    lbra      CopyStrip dispatch 6: copy background strip
                    lbra      ClearWithPalette dispatch 7: fill screen with palette color
                    lbra      UpdateViewList dispatch 8: update all views in linked list
                    lbra      DrawView  dispatch 9: render one view/cel to screen

* probably was an info directive for an include file
CopyrightStr        fcc       'AGI (c) copyright 1988 SIERRA On-Line'
                    fcc       'CoCo3 version by Chris Iden'
                    fcb       $00
Infosz              equ       *-CopyrightStr



* map block check and sets
* MmuBlkNum is set in code in DrawStrip sub
* entry:
*      a -> value to be tested

SetMapBlock         cmpa      <MmuBlkNum check MMU block
                    beq       MapBlockOk if block 0  OK to leave
                    orcc      #IntMasks Turn off interrupts
                    sta       <MmuBlkNum store the value passed in by a
                    lda       <SierraPdBlk get sierra process descriptor map block
                    sta       >DatTask1Slot1 map it in to $2000-$3FFF
                    ldx       <Sierra2ndBlk 2nd 8K data block in Sierra
                    lda       <MmuBlkNum get mmu block num
                    sta       ,x        store block number at slot 0
                    stb       $02,x     store block number at slot 2
                    std       >DatTask1Slot1 Map it into task 1 block 2
                    andcc     #^IntMasks turn on interrupts $AF
MapBlockOk          rts


* 16 marker bytes for some thing
* coco_view_pal[]     vid_render.c
CocoViewPal         fcb       $00
                    fcb       $11
                    fcb       $22
                    fcb       $33
                    fcb       $44
                    fcb       $55
                    fcb       $66
                    fcb       $77
                    fcb       $88
                    fcb       $99
                    fcb       $AA
                    fcb       $BB
                    fcb       $CC
                    fcb       $DD
                    fcb       $EE
                    fcb       $FF


* Clears the area allocated to the screen in sierra
* entry:
*      d -> value to be written to screen
*      x -> may contain a value so we save it
* exit:
*      d -> preserved
*      x -> restored to initial value
*      u -> contains starting address of the screen

ClearScreen         pshs      x         save the x values as this routine uses it
ClearScreenInit     ldu       #$D800    end address of high res screen
                    ldx       #$7800    Scrn is from $6000 to $D800
ClearWordLoop       std       ,--u      set it to value passed us in d & dec d
                    leax      -$02,x    decrement x
                    bne       ClearWordLoop keep going till all of screen is cleared
                    puls      x         restore x`
                    rts                 move on

* Loads D to clear screen
ZeroClearScreen     ldd       #$0000    zeros screen bytes
                    bsr       ClearScreen go clear it
                    rts

ClearScreenBlack    bsr       ZeroClearScreen clear screen to black
                    ldd       #$A8A0    Y2=$A8, Y1=$A0 (screen rows)
                    pshs      d         push row args onto stack
                    ldd       #$00A7    X2=$00, X1=$A7 (screen columns)
                    pshs      d         push column args onto stack
                    lbsr      DrawStrip
                    leas      $04,s     pop 4 bytes of args
                    rts

ClearWithPalette    lda       >SierraPalette load palette color byte
                    tfr       a,b       duplicate into both bytes of D
                    bsr       ClearScreen fill screen with that color word
                    ldd       #$0000    clears value at SprCurRow
                    std       <SprCurRow reset sprite row/col position
                    rts

DrawBorder          ldd       $06,s     load top-left row arg
                    pshs      d         push row start
                    ldd       $06,s     reload arg (stack shifted)
                    pshs      d         push row end
                    ldd       $06,s     reload arg (stack shifted)
                    pshs      d         push color arg
                    lbsr      FillSolidRect draw top edge
                    leas      $06,s     pop 6 bytes of args
                    clra                A=0 for column start
                    ldb       $06,s     load height arg
                    pshs      d         push row params
                    lda       #$01      col start = 1
                    ldb       $07,s     load height (stack adjusted)
                    subb      #$02      subtract 2 to skip top/bottom
                    pshs      d         push height-2
                    ldd       $06,s     load position arg
                    inca                advance row by 1
                    decb                reduce column by 1
                    pshs      d         push adjusted position
                    lbsr      FillSolidRect draw left edge
                    leas      $06,s     pop 6 bytes of args
                    clra                A=0 for column start
                    ldb       $06,s     load next arg
                    pshs      d         push row
                    lda       $06,s     load X position
                    suba      #$04      subtract 4 for right edge position
                    ldb       #$01      column width = 1
                    pshs      d         push right edge position
                    ldd       $06,s     load base position
                    adda      $09,s     add height to get bottom
                    suba      #$02      adjust for edges
                    subb      #$02      adjust column
                    pshs      d         push bottom position
                    lbsr      FillSolidRect draw right edge
                    leas      $06,s     pop 6 bytes of args
                    clra                A=0
                    ldb       $06,s     load arg
                    pshs      d
                    lda       #$01      col start = 1
                    ldb       $07,s
                    subb      #$02      height - 2
                    pshs      d
                    ldd       $06,s
                    inca                advance row
                    subb      $08,s     subtract width
                    addb      #$02      adjust for border
                    pshs      d
                    lbsr      FillSolidRect draw bottom-left corner edge
                    leas      $06,s     pop 6 bytes of args
                    clra
                    ldb       $06,s
                    pshs      d
                    lda       $06,s
                    suba      #$04
                    ldb       #$01
                    pshs      d
                    ldd       $06,s
                    inca
                    subb      #$02
                    pshs      d
                    lbsr      FillSolidRect draw bottom edge
                    leas      $06,s     pop 6 bytes of args
                    rts

SetupDrawStrip      ldd       $04,s     load row args from caller's frame
                    pshs      d         push first arg
                    ldd       $04,s     reload same arg (stack shifted)
                    pshs      d         push second arg
                    lbsr      DrawStrip
                    leas      $04,s     pop 4 bytes of args
                    rts

* first call in module is here
* who put what on the stack for us ?
DrawStrip           pshs      y         save Y (module entry absolute address)

                    ldd       $04,s     load row/column args
                    sta       <ScrAddrLo save row as screen address low byte
                    incb                B = bottom row + 1
                    subb      $06,s     B = height of strip in rows
                    lda       #$A0      A = 160 (bytes per screen row)
                    mul                 D = height × 160
                    addd      <ScrAddrHi add hi-res screen high byte
                    tfr       d,x       X = source pixel address
                    addd      <HiResBase add screen base offset
                    tfr       d,y       Y = destination screen address
                    leax      <$40,x    advance X by $40 (source offset)
                    ldd       $06,s     load strip dimension
                    std       <RowCount save row count and strip width

                    ldb       #$A0      B = 160 (full row width)
                    subb      <StripWidth B = stride = 160 - strip pixel width
                    clra                clear A for full D
                    std       <RowStride save row stride
                    sta       <MmuBlkNum clear MMU block tracking variable

                    orcc      #IntMasks disable interrupts
                    lda       <SierraPdBlk load Sierra process descriptor block#
                    sta       >DatTask1Slot1 second block in task 1
                    cmpx      #$A000    check if X is in high 8K window
                    bcs       MapBlockLow branch if X < $A000 (low window)

                    ldd       <BlkMapHigh load high-address block map entry
                    leax      >-$8000,x adjust X for high window (-$8000)
                    bra       MapBlockAndRender
MapBlockLow         ldd       <BlkMapLow load low-address block map entry
                    leax      >-$4000,x adjust X for low window (-$4000)
MapBlockAndRender   ldu       <Sierra2ndBlk load Sierra 2nd 8K data block ptr
                    sta       ,u        store block A at slot 0
                    stb       $02,u     store block B at slot 2
                    std       >DatTask1Slot1 map block into task 1
                    andcc     #^IntMasks re-enable interrupts

                    leau      >CocoViewPal,pcr point U to CoCo view palette table
DrawRowOuter        ldb       <StripWidth load pixel count for this row
DrawPixelInner      lda       ,x+       fetch source pixel byte, advance X
                    anda      #$0F      mask to 4-bit palette index
                    lda       a,u       translate through CoCo palette
                    sta       ,y+       write translated pixel, advance Y
                    decb                one fewer pixel this row
                    bne       DrawPixelInner loop until row complete
                    dec       <RowCount one fewer row remaining
                    beq       DrawStripDone pull our y and exit routine
                    ldd       <RowStride load row stride
                    leay      d,y       advance Y to next screen row
                    abx                 advance X by B (stride)
                    cmpx      #$6000    check if X wrapped below screen base
                    bcs       DrawRowOuter branch if still in range

                    orcc      #IntMasks disable interrupts for block remap
                    lda       <SierraPdBlk reload Sierra PD block#
                    sta       >DatTask1Slot1 second block in task 1
                    ldd       <BlkMapHigh load high block map for remap
                    leax      >-$4000,x adjust X by -$4000 for new window
                    bra       MapBlockAndRender remap and continue rendering
DrawStripDone       puls      y         restore Y
                    rts


FillSolidRect       ldd       $02,s     load row/column args from stack
                    sta       <ScrAddrLo save row as screen address low
                    incb                B = bottom row + 1
                    subb      $04,s     B = strip height
                    lda       #$A0      A = 160
                    mul                 D = height × 160
                    addd      <ScrAddrHi Hi res screen mem address ($6000)
                    addd      <HiResBase add base screen offset
                    tfr       d,x       X = starting screen address
                    ldd       $04,s     load dimension arg
                    std       <RowCount save row count / strip width
                    ldb       #$A0      B = 160
                    subb      <StripWidth B = stride = 160 - strip width
                    stb       <RowStride save row stride
                    leau      >CocoViewPal,pcr point U to CoCo palette table
                    lda       $07,s     load fill color index
                    anda      #$0F      mask to 4-bit palette index
                    lda       a,u       look up translated fill color

FillRowOuter        ldb       <StripWidth pixels to fill in this row
FillPixelInner      sta       ,x+       write fill color, advance X
                    decb                one fewer pixel this row
                    bne       FillPixelInner loop until row filled

                    dec       <RowCount one fewer row remaining
                    beq       FillRectDone done when all rows filled
                    ldb       <RowStride load row stride
                    abx                 advance X to next row
                    bra       FillRowOuter fill next row
FillRectDone        rts


CopyStrip           leas      -$04,s    allocate 4 scratch bytes on stack
                    ldd       $0A,s     load destination arg (shifted by alloc)
                    std       $02,s     stash destination in scratch[2]
                    ldd       $08,s     load source arg
                    std       ,s        stash source in scratch[0]
                    lda       $07,s     load destination row
                    lsla                row × 2
                    lsla                row × 4
                    lsla                row × 8
                    ldb       #$A0      B = 160
                    mul                 D = row × 8 × 160 = row × 1280
                    std       <DrawY1   save Y pixel offset for destination
                    clra                clear A
                    ldb       $01,s     load scratch[1]
                    lslb                × 2
                    lslb                × 4 (column × 4 bytes per glyph col)
                    addd      <DrawY1   add Y offset to screen address
                    tfr       d,u       transfer result to U (source pointer)
                    leau      >$6000,u  add screen base $6000
                    ldb       $02,s     load scratch[2]
                    lslb                × 2
                    lslb                × 4
                    lslb                × 8 (source col × 8)
                    lda       #$A0      A = 160
                    mul                 D = source col × 8 × 160
                    leax      d,u       X = source screen address
                    lda       $03,s     load source row
                    lsla
                    lsla
                    lsla                source row × 8
                    ldb       ,s        load scratch[0] (src col)
                    subb      $01,s     subtract scratch[1] (dest col)
                    incb                +1 for pixel width
                    lslb                × 2
                    lslb                × 4
                    abx                 advance X by col delta
                    exg       u,x       swap src/dst pointers
                    abx                 advance X (was U) by col delta
                    exg       u,x       swap back
CopyRowOuter        pshs      u,x,b,a   save pointers, col count, row count
CopyPixelInner      lda       ,-x       read source pixel (reverse scan)
                    sta       ,-u       write to destination (reverse scan)
                    decb                step back one pixel
                    bne       CopyPixelInner loop until col count zero
                    puls      u,x,b,a   restore pointers and counts
                    leau      >$00A0,u  advance U to next source row
                    leax      >$00A0,x  advance X to next dest row
                    cmpx      #$D800    check if X reached screen end
                    bcc       CopyStripDone done if past end of screen
                    deca                one fewer row
                    bne       CopyRowOuter loop while rows remain
CopyStripDone       leas      $04,s     free scratch bytes
                    rts



UpdateViewList      leas      -$04,s    allocate 4 scratch bytes
                    ldx       $06,s     load pointer to view list head
                    ldu       ,x        load first node pointer
ViewListLoop        stu       ,s        save current node in scratch
                    beq       ViewListDone null pointer = end of list
                    ldu       $04,u     load next node's data pointer
                    stu       $02,s     save next pointer in scratch[2]
                    pshs      u         push view ptr as DrawView arg
                    lbsr      DrawView  render this view
                    leas      $02,s     pop DrawView arg
                    ldu       $02,s     reload next pointer
                    lda       $01,u     load view attribute byte
                    cmpa      ,u        compare with previous attribute
                    bne       ViewListNext skip coord update if changed
                    ldd       $03,u     load current X,Y coords
                    cmpd      <$1A,u    compare with previous coords
                    bne       UpdateViewCoords branch if position changed
                    lda       <$25,u    load view flags byte
                    ora       #$40      set bit 6 (stable/unchanged flag)
                    sta       <$25,u    store updated flags
                    bra       ViewListNext
UpdateViewCoords    std       <$1A,u    save new coords as previous
                    lda       <$25,u    load view flags
                    anda      #$BF      clear bit 6 (position changed)
                    sta       <$25,u    store updated flags
ViewListNext        ldu       ,s        load current node from scratch
                    ldu       ,u        follow next-node link
                    bra       ViewListLoop process next node
ViewListDone        leas      $04,s     free scratch bytes
                    rts


DrawView            lda       >PicVisible pic_visible
                    lbeq      DrawViewDone skip draw if picture not visible
                    ldu       $02,s     load view structure pointer
                    ldd       $08,u     load block number from view struct
                    lbsr      SetMapBlock map the block for source data
                    ldx       <$10,u    load pointer from view struct offset $10
                    ldd       ,x        load word at that pointer (view width)
                    std       <RowStride save as row stride
                    ldd       <$14,u    load block number from view+$14
                    lbsr      SetMapBlock map the second block
                    ldx       <$12,u    load pointer from view struct offset $12
                    ldd       ,x        load word at that pointer (view height)
                    std       <RowCount save as row count
                    ldd       <$10,u    reload view+$10
                    std       <$12,u    update view+$12 with it
                    ldd       $08,u     reload view block number
                    std       <$14,u    update view+$14 with it
                    lda       $04,u     load view X position
                    ldb       <ViewRightX load right-edge clip X
                    cmpa      <$1B,u    compare X with view's prev X
                    bcs       ClipXSmall branch if cur X < prev X
                    sta       <ClipLeft save X as left clip boundary
                    stb       <ClipRight save right-edge as clip right
                    lda       <$1B,u    load previous X
                    ldb       <StripWidth load strip pixel width
                    bra       ComputeClipWidth
ClipXSmall          ldb       <$1B,u    load previous X as left clip
                    stb       <ClipLeft save as left boundary
                    ldb       <StripWidth load strip width
                    stb       <ClipRight save as right boundary
                    ldb       <ViewRightX load right-edge X
ComputeClipWidth    stb       <OverlapLeft save overlap left boundary
                    inca                A = cur X + 1
                    suba      <OverlapLeft A = overlap width candidate
                    ldb       <ClipLeft load clip left
                    incb                B = ClipLeft + 1
                    subb      <ClipRight B = clip width
                    stb       <ClipWidth save clip width
                    cmpa      <ClipWidth compare overlap vs clip width
                    bcs       AdjustClipWidth use clip width if overlap is smaller
                    lda       <ClipWidth use clip width as limit
AdjustClipWidth     nega                negate to invert
                    adda      <ClipLeft A = ClipLeft - overlap width
                    inca                adjust for final right clip
                    sta       <ClipRight save computed clip right
                    lda       $03,u     load view Y position
                    ldb       <RowStride load row stride
                    cmpa      <$1A,u    compare Y with view's prev Y
                    bhi       ClipYGreater branch if cur Y > prev Y
                    sta       <DrawY1   save Y as top of draw region
                    stb       <OverlapTop save row stride as overlap top
                    lda       <$1A,u    load previous Y
                    ldb       <RowCount load row count
                    bra       ComputeClipHeight
ClipYGreater        ldb       <$1A,u    load previous Y as draw start
                    stb       <DrawY1   save as top of draw region
                    ldb       <RowCount load row count
                    stb       <OverlapTop save as overlap top
                    ldb       <RowStride load row stride
ComputeClipHeight   stb       <OverlapSize save overlap size
                    adda      <OverlapSize A = Y + overlap = bottom extent
                    sta       <ClipBottom save as clip bottom
                    lda       <DrawY1   load draw start Y
                    adda      <OverlapTop add overlap top to get draw bottom
                    cmpa      <ClipBottom compare against clip bottom
                    bhi       SetupDrawCall use draw bottom if it exceeds clip
                    lda       <ClipBottom use clip bottom as limit
SetupDrawCall       suba      <DrawY1   height = bottom - top
                    sta       <ClipHeight save computed clip height
                    ldd       <ClipRight load clip right/left pair
                    pshs      b,a       push column args for DrawStrip
                    ldd       <DrawY1   load draw Y start / clip height
                    pshs      b,a       push row args for DrawStrip
                    lbsr      DrawStrip render clipped view to screen
                    leas      $04,s     pop 4 bytes of args
DrawViewDone        rts

* This jumbled mass of bytes disassembles
* but looks like a data block
* or probably a bit map ???
* BitmapFont - DrawSprites is 1024 bytes of data

BitmapFont          fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $7E,$81,$A5,$81
                    fcb       $BD,$99,$81,$7E
                    fcb       $7E,$FF,$DB,$FF
                    fcb       $C3,$E7,$FF,$7E
                    fcb       $6C,$FE,$FE,$FE
                    fcb       $7C,$38,$10,$00
                    fcb       $10,$38,$7C,$FE
                    fcb       $7C,$38,$10,$00
                    fcb       $38,$7C,$38,$FE
                    fcb       $FE,$7C,$38,$7C
                    fcb       $10,$10,$38,$7C
                    fcb       $FE,$7C,$38,$7C
                    fcb       $00,$00,$18,$3C
                    fcb       $3C,$18,$00,$00
                    fcb       $FF,$FF,$E7,$C3
                    fcb       $C3,$E7,$FF,$FF
                    fcb       $00,$3C,$66,$42
                    fcb       $42,$66,$3C,$00
                    fcb       $FF,$C3,$99,$BD
                    fcb       $BD,$99,$C3,$FF
                    fcb       $0F,$07,$0F,$7D
                    fcb       $CC,$CC,$CC,$78
                    fcb       $3C,$66,$66,$66
                    fcb       $3C,$18,$7E,$18
                    fcb       $3F,$33,$3F,$30
                    fcb       $30,$70,$F0,$E0
                    fcb       $7F,$63,$7F,$63
                    fcb       $63,$67,$E6,$C0
                    fcb       $99,$5A,$3C,$E7
                    fcb       $E7,$3C,$5A,$99
                    fcb       $80,$E0,$F8,$FE
                    fcb       $F8,$E0,$80,$00
                    fcb       $02,$0E,$3E,$FE
                    fcb       $3E,$0E,$02,$00
                    fcb       $18,$3C,$7E,$18
                    fcb       $18,$7E,$3C,$18
                    fcb       $66,$66,$66,$66
                    fcb       $66,$00,$66,$00
                    fcb       $7F,$DB,$DB,$7B
                    fcb       $1B,$1B,$1B,$00
                    fcb       $3E,$63,$38,$6C
                    fcb       $6C,$38,$CC,$78
                    fcb       $00,$00,$00,$00
                    fcb       $7E,$7E,$7E,$00
                    fcb       $18,$3C,$7E,$18
                    fcb       $7E,$3C,$18,$FF
                    fcb       $18,$3C,$7E,$18
                    fcb       $18,$18,$18,$00
                    fcb       $18,$18,$18,$18
                    fcb       $7E,$3C,$18,$00
                    fcb       $00,$18,$0C,$FE
                    fcb       $0C,$18,$00,$00
                    fcb       $00,$30,$60,$FE
                    fcb       $60,$30,$00,$00
                    fcb       $00,$00,$C0,$C0
                    fcb       $C0,$FE,$00,$00
                    fcb       $00,$24,$66,$FF
                    fcb       $66,$24,$00,$00
                    fcb       $00,$18,$3C,$7E
                    fcb       $FF,$FF,$00,$00
                    fcb       $00,$FF,$FF,$7E
                    fcb       $3C,$18,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $30,$78,$78,$30
                    fcb       $30,$00,$30,$00
                    fcb       $6C,$6C,$6C,$00
                    fcb       $00,$00,$00,$00
                    fcb       $6C,$6C,$FE,$6C
                    fcb       $FE,$6C,$6C,$00
                    fcb       $30,$7C,$C0,$78
                    fcb       $0C,$F8,$30,$00
                    fcb       $00,$C6,$CC,$18
                    fcb       $30,$66,$C6,$00
                    fcb       $38,$6C,$38,$76
                    fcb       $DC,$CC,$76,$00
                    fcb       $60,$60,$C0,$00
                    fcb       $00,$00,$00,$00
                    fcb       $18,$30,$60,$60
                    fcb       $60,$30,$18,$00
                    fcb       $60,$30,$18,$18
                    fcb       $18,$30,$60,$00
                    fcb       $00,$66,$3C,$FF
                    fcb       $3C,$66,$00,$00
                    fcb       $00,$30,$30,$FC
                    fcb       $30,$30,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$30,$30,$60
                    fcb       $00,$00,$00,$FC
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$30,$30,$00
                    fcb       $06,$0C,$18,$30
                    fcb       $60,$C0,$80,$00
                    fcb       $7C,$C6,$CE,$DE
                    fcb       $F6,$E6,$7C,$00
                    fcb       $30,$70,$30,$30
                    fcb       $30,$30,$FC,$00
                    fcb       $78,$CC,$0C,$38
                    fcb       $60,$CC,$FC,$00
                    fcb       $78,$CC,$0C,$38
                    fcb       $0C,$CC,$78,$00
                    fcb       $1C,$3C,$6C,$CC
                    fcb       $FE,$0C,$1E,$00
                    fcb       $FC,$C0,$F8,$0C
                    fcb       $0C,$CC,$78,$00
                    fcb       $38,$60,$C0,$F8
                    fcb       $CC,$CC,$78,$00
                    fcb       $FC,$CC,$0C,$18
                    fcb       $30,$30,$30,$00
                    fcb       $78,$CC,$CC,$78
                    fcb       $CC,$CC,$78,$00
                    fcb       $78,$CC,$CC,$7C
                    fcb       $0C,$18,$70,$00
                    fcb       $00,$30,$30,$00
                    fcb       $00,$30,$30,$00
                    fcb       $00,$30,$30,$00
                    fcb       $00,$30,$30,$60
                    fcb       $18,$30,$60,$C0
                    fcb       $60,$30,$18,$00
                    fcb       $00,$00,$FC,$00
                    fcb       $00,$FC,$00,$00
                    fcb       $60,$30,$18,$0C
                    fcb       $18,$30,$60,$00
                    fcb       $78,$CC,$0C,$18
                    fcb       $30,$00,$30,$00
                    fcb       $7C,$C6,$DE,$DE
                    fcb       $DE,$C0,$78,$00
                    fcb       $30,$78,$CC,$CC
                    fcb       $FC,$CC,$CC,$00
                    fcb       $FC,$66,$66,$7C
                    fcb       $66,$66,$FC,$00
                    fcb       $3C,$66,$C0,$C0
                    fcb       $C0,$66,$3C,$00
                    fcb       $F8,$6C,$66,$66
                    fcb       $66,$6C,$F8,$00
                    fcb       $FE,$62,$68,$78
                    fcb       $68,$62,$FE,$00
                    fcb       $FE,$62,$68,$78
                    fcb       $68,$60,$F0,$00
                    fcb       $3C,$66,$C0,$C0
                    fcb       $CE,$66,$3E,$00
                    fcb       $CC,$CC,$CC,$FC
                    fcb       $CC,$CC,$CC,$00
                    fcb       $78,$30,$30,$30
                    fcb       $30,$30,$78,$00
                    fcb       $1E,$0C,$0C,$0C
                    fcb       $CC,$CC,$78,$00
                    fcb       $E6,$66,$6C,$78
                    fcb       $6C,$66,$E6,$00
                    fcb       $F0,$60,$60,$60
                    fcb       $62,$66,$FE,$00
                    fcb       $C6,$EE,$FE,$FE
                    fcb       $D6,$C6,$C6,$00
                    fcb       $C6,$E6,$F6,$DE
                    fcb       $CE,$C6,$C6,$00
                    fcb       $38,$6C,$C6,$C6
                    fcb       $C6,$6C,$38,$00
                    fcb       $FC,$66,$66,$7C
                    fcb       $60,$60,$F0,$00
                    fcb       $78,$CC,$CC,$CC
                    fcb       $DC,$78,$1C,$00
                    fcb       $FC,$66,$66,$7C
                    fcb       $6C,$66,$E6,$00
                    fcb       $78,$CC,$E0,$70
                    fcb       $1C,$CC,$78,$00
                    fcb       $FC,$B4,$30,$30
                    fcb       $30,$30,$78,$00
                    fcb       $CC,$CC,$CC,$CC
                    fcb       $CC,$CC,$FC,$00
                    fcb       $CC,$CC,$CC,$CC
                    fcb       $CC,$78,$30,$00
                    fcb       $C6,$C6,$C6,$D6
                    fcb       $FE,$EE,$C6,$00
                    fcb       $C6,$C6,$6C,$38
                    fcb       $38,$6C,$C6,$00
                    fcb       $CC,$CC,$CC,$78
                    fcb       $30,$30,$78,$00
                    fcb       $FE,$C6,$8C,$18
                    fcb       $32,$66,$FE,$00
                    fcb       $78,$60,$60,$60
                    fcb       $60,$60,$78,$00
                    fcb       $C0,$60,$30,$18
                    fcb       $0C,$06,$02,$00
                    fcb       $78,$18,$18,$18
                    fcb       $18,$18,$78,$00
                    fcb       $10,$38,$6C,$C6
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$FF
                    fcb       $30,$30,$18,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$78,$0C
                    fcb       $7C,$CC,$76,$00
                    fcb       $E0,$60,$60,$7C
                    fcb       $66,$66,$DC,$00
                    fcb       $00,$00,$78,$CC
                    fcb       $C0,$CC,$78,$00
                    fcb       $1C,$0C,$0C,$7C
                    fcb       $CC,$CC,$76,$00
                    fcb       $00,$00,$78,$CC
                    fcb       $FC,$C0,$78,$00
                    fcb       $38,$6C,$60,$F0
                    fcb       $60,$60,$F0,$00
                    fcb       $00,$00,$76,$CC
                    fcb       $CC,$7C,$0C,$F8
                    fcb       $E0,$60,$6C,$76
                    fcb       $66,$66,$E6,$00
                    fcb       $30,$00,$70,$30
                    fcb       $30,$30,$78,$00
                    fcb       $0C,$00,$0C,$0C
                    fcb       $0C,$CC,$CC,$78
                    fcb       $E0,$60,$66,$6C
                    fcb       $78,$6C,$E6,$00
                    fcb       $70,$30,$30,$30
                    fcb       $30,$30,$78,$00
                    fcb       $00,$00,$CC,$FE
                    fcb       $FE,$D6,$C6,$00
                    fcb       $00,$00,$F8,$CC
                    fcb       $CC,$CC,$CC,$00
                    fcb       $00,$00,$78,$CC
                    fcb       $CC,$CC,$78,$00
                    fcb       $00,$00,$DC,$66
                    fcb       $66,$7C,$60,$F0
                    fcb       $00,$00,$76,$CC
                    fcb       $CC,$7C,$0C,$1E
                    fcb       $00,$00,$DC,$76
                    fcb       $66,$60,$F0,$00
                    fcb       $00,$00,$7C,$C0
                    fcb       $78,$0C,$F8,$00
                    fcb       $10,$30,$7C,$30
                    fcb       $30,$34,$18,$00
                    fcb       $00,$00,$CC,$CC
                    fcb       $CC,$CC,$76,$00
                    fcb       $00,$00,$CC,$CC
                    fcb       $CC,$78,$30,$00
                    fcb       $00,$00,$C6,$D6
                    fcb       $FE,$FE,$6C,$00
                    fcb       $00,$00,$C6,$6C
                    fcb       $38,$6C,$C6,$00
                    fcb       $00,$00,$CC,$CC
                    fcb       $CC,$7C,$0C,$F8
                    fcb       $00,$00,$FC,$98
                    fcb       $30,$64,$FC,$00
                    fcb       $1C,$30,$30,$E0
                    fcb       $30,$30,$1C,$00
                    fcb       $18,$18,$18,$00
                    fcb       $18,$18,$18,$00
                    fcb       $E0,$30,$30,$1C
                    fcb       $30,$30,$E0,$00
                    fcb       $76,$DC,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$10,$38,$6C
                    fcb       $C6,$C6,$FE,$00

DrawSprites         leas      -$02,s    allocate 2 scratch bytes
                    pshs      y         save Y register
                    ldx       $06,s     load pointer to glyph data
                    ldu       #SierraPalette point U to Sierra palette table
                    lda       <SprCurRow load current sprite row
                    lsla                row × 2
                    lsla                row × 4
                    lsla                row × 8
                    ldb       #$A0      B = 160
                    mul                 D = row × 8 × 160 = pixel row offset
                    tfr       d,y       Y = row pixel offset
                    clra                clear A for column calculation
                    ldb       <SprCurCol load current sprite column
                    lslb                col × 2
                    lslb                col × 4 (bytes per glyph col)
                    addd      #$6000    add screen base $6000
                    leay      d,y       Y = screen address for this glyph
DrawSpriteLoop      tst       ,x        test next glyph byte
                    lbeq      DrawSpritesDone zero byte = end of glyph data
                    ldb       ,x+       load glyph index, advance X
                    stx       $06,s     save updated X pointer in scratch
                    leax      >BitmapFont,pcr point X to bitmap font table
                    lslb                index × 2
                    abx                 advance X by index×2
                    abx                 advance X by index×2 again
                    abx                 advance X by index×2 again
                    abx                 X now points to glyph (index × 8)
                    lda       #$08      A = 8 rows per glyph
                    sta       $02,s     save row counter in scratch
DrawSpriteRow       ldb       ,x+       load 8-bit row bitmap, advance X
                    lda       #$04      A = 4 pixel pairs per row
                    sta       $03,s     save pixel pair counter
DrawSpritePixel     sex                 sign-extend B into A (B MSB → A)
                    lda       a,u       look up high nibble color in palette
                    anda      #$F0      keep high nibble only
                    sta       ,y        write high-color pixel to screen
                    lslb                shift next pixel bit into sign
                    sex                 sign-extend B for low nibble
                    lda       a,u       look up low nibble color in palette
                    anda      #$0F      keep low nibble only
                    ora       ,y        merge with high nibble on screen
                    ora       <PaletteFlag flag for palettes set in sierra
                    sta       ,y+       write merged pixel byte, advance Y
                    lslb                shift next pixel bits
                    dec       $03,s     one fewer pixel pair this row
                    bne       DrawSpritePixel loop for all 4 pairs
                    lda       <PaletteFlag flag for palettes set in sierra
                    beq       FlipPaletteFlag skip invert if flag already zero
                    coma                invert A ($FF → $00)
                    sta       <PaletteFlag flag for palettes set in sierra
FlipPaletteFlag     leay      >$009C,y  advance Y to next glyph row ($9C = 156)
                    dec       $02,s     one fewer glyph row remaining
                    bne       DrawSpriteRow loop for all 8 glyph rows
                    ldx       $06,s     restore X pointer to glyph list
                    inc       <SprCurCol advance to next sprite column slot
                    leay      >-$04FC,y rewind Y back to top of this glyph col
                    bra       DrawSpriteLoop process next glyph
DrawSpritesDone     puls      y         restore Y register
                    leas      $02,s     free scratch bytes
                    rts

EndPad              fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
EndName             fcc       /scrn/
EndNull             fcb       $00

                    emod
eom                 equ       *
                    end

