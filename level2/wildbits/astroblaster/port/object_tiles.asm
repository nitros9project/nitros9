* Native tile placement from original $18F3..$1A48.
* X object, Y converted shape, U owned video buffer; preserve D,X,Y,U.
* Erase only the edges exposed by a crossed cell, then stamp the new
* shape. Protected border/status/foreground cells retain their tile.
DrawObjectTiles  lbsr      EraseObjectTrail
                    lbra      StampObjectTiles

* Formation updates erase ALL old edges before stamping ANY new object,
* as original $17C7 does; otherwise neighbors can erase one another.
EraseObjectTrail pshs      d,x,y,u
                    leas      -OT_FrameBytes,s
                    clr       OT_ProtectTen,s ; stack offset
                    clr       OT_Advance,s ; stack offset: constant blank
                    lda       #G80_ERASE_TILE
                    sta       OT_Tile,s ; stack offset
                    lda       OB_MoveFlags,x
                    bita      #OB_CROSSED_X_MINUS
                    beq       ObjectEraseXPlus
                    ldb       OB_TileX,x
                    addb      SH_TileWidth,y
                    bsr       EraseObjectColumn
ObjectEraseXPlus ldx       OT_SavedObject,s ; stack offset
                    ldy       OT_SavedShape,s ; stack offset
                    lda       OB_MoveFlags,x
                    bita      #OB_CROSSED_X_PLUS
                    beq       ObjectEraseYPlus
                    ldb       OB_TileX,x
                    decb
                    bsr       EraseObjectColumn
ObjectEraseYPlus ldx       OT_SavedObject,s ; stack offset
                    ldy       OT_SavedShape,s ; stack offset
                    lda       OB_MoveFlags,x
                    bita      #OB_CROSSED_Y_PLUS
                    beq       ObjectEraseYMinus
                    lda       OB_TileY,x
                    deca
                    bsr       EraseObjectRow
ObjectEraseYMinus ldx      OT_SavedObject,s ; stack offset
                    ldy       OT_SavedShape,s ; stack offset
                    lda       OB_MoveFlags,x
                    bita      #OB_CROSSED_Y_MINUS
                    beq       ObjectTrailReturn
                    lda       OB_TileY,x
                    adda      SH_TileHeight,y
                    bsr       EraseObjectRow
ObjectTrailReturn leas     OT_FrameBytes,s
                    puls      d,x,y,u,pc

StampObjectTiles pshs      d,x,y,u
                    leas      -OT_FrameBytes,s
                    clr       OT_ProtectTen,s ; stack offset
                    lda       #1
                    sta       OT_Advance,s ; stack offset: sequential glyphs
                    lda       OB_TileX,x
                    sta       OT_OriginX,s ; stack offset
                    lda       OB_TileY,x
                    sta       OT_OriginY,s ; stack offset
                    lda       OB_TargetTile,x
                    sta       OT_Tile,s ; stack offset
                    lda       SH_TileWidth,y
                    sta       OT_ColumnsLeft,s ; stack offset
                    lda       SH_TileHeight,y
                    sta       OT_Height,s ; stack offset
                    leax      ,s
                    lbsr      StampObjectRectangle
                    leas      OT_FrameBytes,s
                    puls      d,x,y,u,pc

* Original $1A68: erase the complete object, retaining tile classes
* $00, $10, $40, $50 and $60. X object, Y shape, U video; preserve all.
EraseObjectBody  pshs      d,x,y,u
                    leas      -OT_FrameBytes,s
                    ldd       OB_TileX,x
                    std       OT_OriginX,s ; stack offset: X/Y pair
                    lda       SH_TileWidth,y
                    sta       OT_ColumnsLeft,s ; stack offset
                    lda       SH_TileHeight,y
                    sta       OT_Height,s ; stack offset
                    lda       #G80_BLANK_TILE
                    sta       OT_Tile,s ; stack offset
                    clr       OT_Advance,s ; stack offset
                    lda       #1
                    sta       OT_ProtectTen,s ; stack offset
                    leax      ,s
                    lbsr      StampObjectRectangle
                    leas      OT_FrameBytes,s
                    puls      d,x,y,u,pc

* These private entries see the caller's local frame above the 2-byte
* return address. B = exposed column, or A = exposed row.
EraseObjectColumn
                    stb       OT_OriginX+2,s ; stack offset past return PC
                    ldb       #1
                    stb       OT_ColumnsLeft+2,s ; stack offset
                    ldb       SH_TileHeight,y
                    stb       OT_Height+2,s ; stack offset
                    lda       OB_TileY,x
                    ldb       OB_MoveFlags,x
                    bitb      #OB_CROSSED_Y_PLUS
                    beq       EraseColumnCheckMinus
                    deca
EraseColumnCheckMinus
                    bitb      #OB_CROSSED_Y_MINUS
                    beq       EraseColumnRowReady
                    inca
EraseColumnRowReady
                    sta       OT_OriginY+2,s ; stack offset
                    leax      2,s       stack offset: parent's local frame
                    lbra      StampObjectRectangle
EraseObjectRow   sta       OT_OriginY+2,s ; stack offset past return PC
                    lda       OB_TileX,x
                    sta       OT_OriginX+2,s ; stack offset
                    lda       SH_TileWidth,y
                    sta       OT_ColumnsLeft+2,s ; stack offset
                    lda       #1
                    sta       OT_Height+2,s ; stack offset
                    leax      2,s       stack offset: parent's local frame
                    lbra      StampObjectRectangle

* X = OT rectangle packet, U video base. D,Y scratch; X,U preserved.
* Original tile order: down rows by +32, then next column by +1.
* Rows outside the visible 28 still exist in the original 32-row map.
StampObjectRectangle
                    lda       OT_OriginX,x
                    sta       OT_CurrentX,x
StampNextColumn  lda       OT_OriginY,x
                    sta       OT_CurrentY,x
                    lda       OT_Height,x
                    sta       OT_RowsLeft,x
StampNextRow     lda       OT_CurrentY,x
                    cmpa      #G80_DRAW_ROWS
                    bhs       StampAdvanceRow
                    ldb       OT_CurrentX,x
                    cmpb      #G80_DRAW_FIRST_COL
                    blo       StampAdvanceRow
                    cmpb      #G80_TILEMAP_STRIDE
                    bhs       StampAdvanceRow
                    ldb       #G80_TILEMAP_STRIDE
                    mul
                    orb       OT_CurrentX,x
                    leay      d,u
                    lda       ,y
                    anda      #$F0
                    beq       StampAdvanceRow
                    cmpa      #$10
                    bne       StampCheckForeground
                    tst       OT_ProtectTen,x
                    bne       StampAdvanceRow
StampCheckForeground
                    cmpa      #$70
                    beq       StampWriteCell
                    anda      #$C0
                    cmpa      #$40
                    beq       StampAdvanceRow
StampWriteCell   lda       OT_Tile,x
                    sta       ,y
StampAdvanceRow  lda       OT_Tile,x
                    adda      OT_Advance,x
                    sta       OT_Tile,x
                    inc       OT_CurrentY,x
                    dec       OT_RowsLeft,x
                    bne       StampNextRow
                    inc       OT_CurrentX,x
                    dec       OT_ColumnsLeft,x
                    bne       StampNextColumn
                    rts
