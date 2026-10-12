* Native object movement/glyph preparation, original $1725..$17C6.
* These routines operate on owned game buffers. No hardware sprite engine
* is substituted: original per-pixel graphics and collision shapes remain.

* X = object, Y = its converted shape; preserve D,X,Y,U. Original $1725
* through $178B updates subcell positions, crossing flags, and tile bank.
* Velocity is constrained by the original game to at most one cell/step.
MoveObject       pshs      d
                    lda       OB_MoveFlags,x
                    anda      #OB_PERSIST_FLAGS
                    sta       OB_MoveFlags,x
                    lda       OB_PixelX,x
                    adda      OB_DeltaX,x
                    tfr       a,b
                    anda      #G80_COLUMN_MASK
                    sta       OB_PixelX,x
                    tstb
                    bpl       ObjectXNonnegative
                    lda       OB_MoveFlags,x
                    ora       #OB_CROSSED_X_MINUS
                    sta       OB_MoveFlags,x
                    dec       OB_TileX,x
                    bra       ObjectMoveY
ObjectXNonnegative cmpb    #G80_TILE_WIDTH
                    blo       ObjectMoveY
                    lda       OB_MoveFlags,x
                    ora       #OB_CROSSED_X_PLUS
                    sta       OB_MoveFlags,x
                    inc       OB_TileX,x
ObjectMoveY      lda       OB_PixelY,x
                    adda      OB_DeltaY,x
                    tfr       a,b
                    anda      #G80_COLUMN_MASK
                    sta       OB_PixelY,x
                    tstb
                    bpl       ObjectYNonnegative
                    lda       OB_MoveFlags,x
                    ora       #OB_CROSSED_Y_MINUS
                    sta       OB_MoveFlags,x
                    dec       OB_TileY,x
                    bra       ObjectSelectTileBank
ObjectYNonnegative cmpb    #G80_TILE_HEIGHT
                    blo       ObjectSelectTileBank
                    lda       OB_MoveFlags,x
                    ora       #OB_CROSSED_Y_PLUS
                    sta       OB_MoveFlags,x
                    inc       OB_TileY,x
ObjectSelectTileBank lda   SH_TileBankA,y
                    cmpa      OB_TargetTile,x
                    bne       ObjectTileBankReady
                    lda       SH_TileBankB,y
ObjectTileBankReady sta    OB_TargetTile,x
                    puls      d,pc

* Original $1792..$17A2. X object, Y shape. Preserve D,X,Y,U.
AdvanceObjectPattern
                    pshs      d
                    ldb       SH_LastFrame,y
                    beq       ObjectPatternZero
                    lda       OB_Frame,x
                    inca
                    incb
                    pshs      b
                    cmpa      ,s+       stack offset 0: exclusive upper bound
                    blo       ObjectPatternReady
ObjectPatternZero clra
ObjectPatternReady sta     OB_Frame,x
                    puls      d,pc

* X object, Y converted shape, U owned G80 video base. Preserve D,X,Y,U.
* Original $178E..$17C6 and $1AEA..$1B46: select two source planes,
* clear each target glyph bank, and copy with subcell X/Y shifts.
* Shape ranges/counts must be validated when native asset records are
* generated. Source words are shape-relative offsets, not Z80 addresses.
RenderObjectPatterns
                    pshs      d,x,y,u
                    leas      -OP_FrameBytes,s
                    lda       OB_PixelX,x
                    sta       OP_CopyParameters+SSC_Shift,s ; stack offset
                    lda       #G80_GLYPH_BYTES
                    ldb       OB_TargetTile,x
                    mul
                    addd      #G80_PLANE0_OFFSET
                    addd      OP_SavedVideo,s ; stack offset: video base
                    std       OP_TargetBase,s ; stack offset
                    lda       #SH_FrameBytes
                    ldb       OB_Frame,x
                    mul
                    leau      SH_FrameSources,y
                    leau      d,u
                    stu       OP_Sources,s ; stack offset
                    ldd       SH_SourceStride,y
                    std       OP_CopyParameters+SC_SourceStride,s ; stack offset
                    ldd       SH_TargetStride,y
                    std       OP_CopyParameters+SC_TargetStride,s ; stack offset
                    clr       OP_Plane,s ; stack offset
ObjectCopyPlane  ldy       OP_SavedShape,s ; stack offset
                    clra
                    ldb       SH_ClearBytes,y
                    tfr       d,u
                    ldx       OP_TargetBase,s ; stack offset
                    lbsr      FillBytes
                    ldx       OP_Sources,s ; stack offset
                    tst       OP_Plane,s ; stack offset
                    beq       ObjectFirstSource
                    ldd       SH_Plane1Source,x
                    bne       ObjectSourceReady
                    leax      OriginalPattern1A9A,pcr
                    bra       ObjectSourceResolved
ObjectFirstSource ldd      ,x
ObjectSourceReady leax     d,y       Y is the runtime shape base
ObjectSourceResolved ldu   OP_SavedObject,s ; stack offset
                    clra
                    ldb       OB_PixelY,u
                    ldy       OP_TargetBase,s ; stack offset
                    leay      d,y
                    ldu       OP_SavedShape,s ; stack offset
                    lda       SH_Columns,u
                    ldb       SH_Rows,u
                    leau      OP_CopyParameters,s ; stack offset: stride/shift record
                    lbsr      CopyShiftedColumns
                    tst       OP_Plane,s ; stack offset
                    bne       ObjectPatternsDone
                    inc       OP_Plane,s ; stack offset
                    ldd       OP_TargetBase,s ; stack offset
                    addd      #G80_PLANE_SPACING
                    std       OP_TargetBase,s ; stack offset
                    bra       ObjectCopyPlane
ObjectPatternsDone leas    OP_FrameBytes,s
                    puls      d,x,y,u,pc
