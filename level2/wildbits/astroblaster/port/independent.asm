* Four independently scripted enemies, original $2DD7..$2EB8.
* X game, Y video, preserve all. A seven-byte RAM record owns each
* subpixel position, velocity, countdown and native motion cursor.
UpdateIndependentFormation
                    pshs      d,x,y,u
                    leas      -IF_FrameBytes,s
                    leay      GS_IndependentObjects,x
                    sty       IF_Record,s ; stack offset
                    leay      GS_FormationPositions,x
                    sty       IF_Position,s ; stack offset
                    lda       #IM_Count
                    sta       IF_Count,s ; stack offset
                    lda       GS_IndependentBank,x
                    eora      #4        $1725 selects the opposite bank before drawing
                    sta       IF_Bank,s ; stack offset
IndependentNext ldy       IF_Position,s ; stack offset
                    lda       ,y
                    cmpa      #FORMATION_END
                    lbeq      IndependentAdvance
                    ldx       IF_Game,s ; stack offset
                    ldd       ,y
                    std       GS_EnemyObject+OB_TileX,x
                    ldy       IF_Record,s ; stack offset
* $2E14 copies the old velocity before advancing the script; the new
* tuple starts affecting motion on the following frame.
                    ldd       IM_DeltaX,y
                    std       GS_EnemyObject+OB_DeltaX,x
                    dec       IM_Timer,y
                    bne       IndependentMove
                    ldu       IM_Cursor,y
                    leau      3,u
                    lda       ,u
                    cmpa      #FORMATION_END
                    bne       IndependentScriptReady
                    ldu       GS_XMotionLoop,x
IndependentScriptReady stu IM_Cursor,y
                    lda       ,u
                    sta       IM_DeltaY,y
                    lda       1,u
                    sta       IM_DeltaX,y
                    lda       2,u
                    sta       IM_Timer,y
IndependentMove ldd       IM_PixelX,y
                    std       GS_EnemyObject+OB_PixelX,x
                    leax      GS_EnemyObject,x
                    ldy       OB_ShapePointer,x
                    ldu       IF_Video,s ; stack offset
                    lbsr      MoveObject
* Override the original per-enemy bank selection without making a
* mutable copy of a shape containing relocatable source offsets.
                    lda       IF_Bank,s ; stack offset
                    sta       OB_TargetTile,x
                    lbsr      AdvanceObjectPattern
                    lbsr      RenderObjectPatterns
                    lbsr      DrawObjectTiles
                    ldy       IF_Record,s ; stack offset
                    ldd       OB_PixelX,x
                    std       IM_PixelX,y
                    ldy       IF_Position,s ; stack offset
                    ldd       OB_TileX,x
                    std       ,y
IndependentAdvance
                    ldd       IF_Record,s ; stack offset
                    addd      #IM_Bytes
                    std       IF_Record,s ; stack offset
                    ldd       IF_Position,s ; stack offset
                    addd      #FORMATION_POSITION_BYTES
                    std       IF_Position,s ; stack offset
                    lda       IF_Bank,s ; stack offset
                    adda      #8
                    sta       IF_Bank,s ; stack offset
                    dec       IF_Count,s ; stack offset
                    lbne      IndependentNext
                    ldx       IF_Game,s ; stack offset
                    lda       GS_IndependentBank,x
                    eora      #4        original $2EA0: flip after all four draws
                    sta       GS_IndependentBank,x
                    clr       GS_EnemyObject+OB_TileX,x
                    clr       GS_EnemyObject+OB_TileY,x
                    leas      IF_FrameBytes,s
                    puls      d,x,y,u,pc
