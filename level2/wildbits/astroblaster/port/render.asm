* Gameplay rows keep their 1:1 vertical scale. Only borders and fuel
* pattern thickness shrink: top/bottom 8->2, fuel strip 8->4 = 16 rows.
* X doubles horizontally. Scores, lives and panel text keep all eight rows.
InitializeRenderPointers
                    leax AD_GlyphPointers,u
                    leay AD_GlyphCache,u
                    clrb
RenderPointerGlyph sty ,x++
                    leay 16,y
                    decb
                    bne RenderPointerGlyph
                    rts
RenderPortraitFrame
                    lbsr InvalidatePortraitFrame
RenderDirtyPortraitFrame
                    leas -RP_FrameBytes,s
                    leax RenderStripRows,pcr
                    stx AD_StripTable,u
                    lda #31
                    sta AD_StripColumn,u
RenderStrip
                    ldb AD_StripColumn,u
                    leax AD_DirtyColumns,u
                    tst b,x
                    lbeq RenderNextStrip
                    lbsr WaitForTerminal
                    lbcs RenderReturnError
                    lbsr ServiceSpeech
                    ldx AD_StripTable,u
                    lda RS_Count,x
                    sta RP_Rows,s
                    leax RS_CacheRows,x
                    stx RP_RowList,s
                    ldx AD_StripTable,u
                    ldb RS_FirstRow,x
                    ldx #ASTRO_PLAYFIELD_BYTE_X
                    lbsr BitmapByteAddress
                    lbcs RenderReturnError
                    stx RP_Block,s
                    std RP_Offset,s
                    clra
                    ldb AD_StripColumn,u
                    leax AD_Video,u
                    leax d,x
                    stx AD_FastRender+FR_Cell,u
                    leax AD_DirtyCells,u
                    leax d,x
                    stx AD_FastRender+FR_Dirty,u
                    lda #G80_VISIBLE_TILE_ROWS
                    sta RP_Left,s
                    clr RP_Count,s
                    clr RP_ByteX,s
                    leax RP_Packets,s
                    stx RP_Write,s
* Cache pointers once per DIRTY cell, then emit all cell rows scanline-wise.
RenderScanCell
                    ldx AD_FastRender+FR_Dirty,u
                    tst ,x
                    beq RenderSkipCell
                    inc RP_Count,s
                    ldy RP_Write,s
                    lda RP_ByteX,s
                    sta ,y+
                    ldx AD_FastRender+FR_Cell,u
                    clra
                    ldb ,x
                    lslb
                    rola
                    leax AD_GlyphPointers,u
                    ldx d,x
                    stx ,y++
                    anda #1
                    andb #$E0
                    leax AD_PairColors,u
                    leax d,x
                    stx ,y++
                    ldx AD_FastRender+FR_Dirty,u
                    lda ,x
                    sta ,y+
                    sty RP_Write,s
RenderSkipCell
                    ldx AD_FastRender+FR_Dirty,u
                    leax G80_TILEMAP_STRIDE,x
                    stx AD_FastRender+FR_Dirty,u
                    ldx AD_FastRender+FR_Cell,u
                    leax G80_TILEMAP_STRIDE,x
                    stx AD_FastRender+FR_Cell,u
                    lda RP_ByteX,s
                    adda #8
                    sta RP_ByteX,s
                    dec RP_Left,s
                    bne RenderScanCell
                    tst RP_Count,s
                    lbeq RenderStripComplete
RenderPacketRow
                    lbsr FeedSpeech
                    ldx RP_RowList,s
                    lda ,x+
                    stx RP_RowList,s
                    sta RP_Subrow,s
                    lsra
                    leax RenderColumnMasks,pcr
                    lda a,x
                    sta RP_RowMask,s
                    lda RP_Count,s
                    sta RP_Left,s
                    leax RP_Packets,s
                    stx RP_Read,s
RenderPacket
                    ldx RP_Read,s
                    lda 5,x
                    bita RP_RowMask,s
                    bne RenderPacketDraw
                    leax RP_RecordBytes,x
                    stx RP_Read,s
                    lbra RenderPacketDone
RenderPacketDraw
                    clra
                    ldb ,x
                    addd RP_Offset,s
                    ldx RP_Block,s
                    cmpd #SCREEN_BLOCK_BYTES
                    blo RenderPacketAddress
                    subd #SCREEN_BLOCK_BYTES
                    leax 1,x
RenderPacketAddress
                    stx AD_FastRender+FR_Block,u
                    std AD_FastRender+FR_Offset,u
                    lbsr MapRenderBlock
                    lbcs RenderReturnError
                    ldx RP_Read,s
                    ldy 1,x
                    ldb RP_Subrow,s
                    ldd b,y
                    std AD_FastRender+FR_Packed,u
                    ldy 3,x
                    leax RP_RecordBytes,x
                    stx RP_Read,s
                    ldx AP_MapAddress,u
                    ldd AD_FastRender+FR_Offset,u
                    leax d,x
                    ldb AD_FastRender+FR_Packed,u
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lslb
                    ldd b,y
                    std ,x
                    ldb AD_FastRender+FR_Packed,u
                    andb #15
                    lslb
                    ldd b,y
                    std 2,x
                    ldb AD_FastRender+FR_Packed+1,u
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lslb
                    ldd b,y
                    std 4,x
                    ldb AD_FastRender+FR_Packed+1,u
                    andb #15
                    lslb
                    ldd b,y
                    std 6,x
RenderPacketDone    dec RP_Left,s
                    lbne RenderPacket
                    ldd RP_Offset,s
                    addd #SCREEN_STRIDE
                    cmpd #SCREEN_BLOCK_BYTES
                    blo RenderRowOffset
                    subd #SCREEN_BLOCK_BYTES
                    inc RP_Block+1,s
RenderRowOffset std RP_Offset,s
                    dec RP_Rows,s
                    lbne RenderPacketRow
* Keep the block mapped across strips: they run in bitmap order, so each
* block is mapped once per frame. Released when the frame is complete.
RenderStripComplete
                    clra
                    ldb AD_StripColumn,u
                    leax AD_DirtyColumns,u
                    clr b,x
                    leax AD_DirtyCells,u
                    leax d,x
                    ldb #28
RenderClearStrip clr ,x
                    leax 32,x
                    decb
                    bne RenderClearStrip
RenderNextStrip     ldx AD_StripTable,u
                    leax RS_Bytes,x
                    stx AD_StripTable,u
                    dec AD_StripColumn,u
                    lbpl RenderStrip
                    lbsr ReleaseDisplayMapping
                    bcs RenderReturnError
                    clrb
                    leas RP_FrameBytes,s
                    rts
RenderReturnError pshs b
                    lbsr ReleaseDisplayMapping
                    puls b
                    leas RP_FrameBytes,s
                    orcc #1
                    rts
* MapRenderBlock is also called below the local stack frame.
RenderReturn rts

MapRenderBlock  ldx       AD_FastRender+FR_Block,u
                    tst       AP_HasMapping,u
                    beq       RenderMapNew
                    cmpx      AD_FastRender+FR_MappedBlock,u
                    beq       RenderMapReady
                    lbsr      ReleaseDisplayMapping
                    lbcs      RenderReturn
RenderMapNew    ldx       AD_FastRender+FR_Block,u
                    stx       AD_FastRender+FR_MappedBlock,u
                    ldb       #1
                    pshs      u
                    os9       F$MapBlk
                    tfr       u,x
                    puls      u
                    lbcs      RenderReturn
                    stx       AP_MapAddress,u
                    inc       AP_HasMapping,u
                    cmpx      #LAST_SAFE_BLOCK_MAP
                    bls       RenderMapReady
                    ldb       #E$MemFul
                    orcc      #1
                    rts
RenderMapReady  clrb
                    rts

* Expand pairs once per palette change; remove shifts from the pixel loop.
BuildPairColors pshs      d,x,y
                    leax      AD_Palette+PW_Map,u
                    leay      AD_PairColors,u
                    ldb       #16
                    pshs      b         stack offset 0: groups remaining
BuildPairGroup  clrb
BuildPairEntry  pshs      b         stack offset 0: pair index 0..15
                    lsrb
                    lsrb
                    lda       b,x
                    ldb       #17
                    mul
                    stb       ,y+
                    ldb       ,s
                    andb      #3
                    lda       b,x
                    ldb       #17
                    mul
                    stb       ,y+
                    puls      b
                    incb
                    cmpb      #16
                    blo       BuildPairEntry
                    leax      4,x
                    dec       ,s
                    bne       BuildPairGroup
                    leas      1,s
                    puls      d,x,y,pc
RenderStripRows
                    fcb 0,2,12,4,0,0,0,0,0,0 ; source tile column 31
                    fcb 2,8,14,12,10,8,6,4,2,0 ; source tile column 30
                    fcb 10,8,14,12,10,8,6,4,2,0 ; source tile column 29
                    fcb 18,8,14,12,10,8,6,4,2,0 ; source tile column 28
                    fcb 26,8,14,12,10,8,6,4,2,0 ; source tile column 27
                    fcb 34,8,14,12,10,8,6,4,2,0 ; source tile column 26
                    fcb 42,8,14,12,10,8,6,4,2,0 ; source tile column 25
                    fcb 50,8,14,12,10,8,6,4,2,0 ; source tile column 24
                    fcb 58,8,14,12,10,8,6,4,2,0 ; source tile column 23
                    fcb 66,8,14,12,10,8,6,4,2,0 ; source tile column 22
                    fcb 74,8,14,12,10,8,6,4,2,0 ; source tile column 21
                    fcb 82,8,14,12,10,8,6,4,2,0 ; source tile column 20
                    fcb 90,8,14,12,10,8,6,4,2,0 ; source tile column 19
                    fcb 98,8,14,12,10,8,6,4,2,0 ; source tile column 18
                    fcb 106,8,14,12,10,8,6,4,2,0 ; source tile column 17
                    fcb 114,8,14,12,10,8,6,4,2,0 ; source tile column 16
                    fcb 122,8,14,12,10,8,6,4,2,0 ; source tile column 15
                    fcb 130,8,14,12,10,8,6,4,2,0 ; source tile column 14
                    fcb 138,8,14,12,10,8,6,4,2,0 ; source tile column 13
                    fcb 146,8,14,12,10,8,6,4,2,0 ; source tile column 12
                    fcb 154,8,14,12,10,8,6,4,2,0 ; source tile column 11
                    fcb 162,8,14,12,10,8,6,4,2,0 ; source tile column 10
                    fcb 170,8,14,12,10,8,6,4,2,0 ; source tile column 9
                    fcb 178,8,14,12,10,8,6,4,2,0 ; source tile column 8
                    fcb 186,8,14,12,10,8,6,4,2,0 ; source tile column 7
                    fcb 194,8,14,12,10,8,6,4,2,0 ; source tile column 6
                    fcb 202,8,14,12,10,8,6,4,2,0 ; source tile column 5
                    fcb 210,8,14,12,10,8,6,4,2,0 ; source tile column 4
                    fcb 218,4,14,10,4,0,0,0,0,0 ; source tile column 3
                    fcb 222,8,14,12,10,8,6,4,2,0 ; source tile column 2
                    fcb 230,8,14,12,10,8,6,4,2,0 ; source tile column 1
                    fcb 238,2,12,4,0,0,0,0,0,0 ; source tile column 0

RenderColumnMasks fcb $80,$40,$20,$10,$08,$04,$02,$01
