* Original $2322..$23B7: compare actual plane-0 pixels, merge noncolliding
* background pixels into the new player glyph, and record a ship hit.
* X game, Y video. Preserve all registers. Call after rendering new
* player glyphs and before stamping their tile numbers over the old map.
CheckPlayerCollision
                    pshs      d,x,y,u
                    leas      -PH_FrameBytes,s
                    ldu       GS_PlayerObject+OB_ShapePointer,x
                    lda       SH_TileWidth,u
                    sta       PH_Columns,s ; stack offset
                    lda       SH_TileHeight,u
                    sta       PH_Height,s ; stack offset
                    lda       GS_PlayerObject+OB_TargetTile,x
                    sta       PH_Tile,s ; stack offset
                    lda       GS_PlayerObject+OB_TileX,x
                    sta       PH_X,s ; stack offset
PlayerCollisionColumn
                    ldx       PH_Game,s ; stack offset
                    lda       GS_PlayerObject+OB_TileY,x
                    sta       PH_Y,s ; stack offset
                    lda       PH_Height,s ; stack offset
                    sta       PH_Rows,s ; stack offset
PlayerCollisionCell
                    lda       PH_Y,s ; stack offset
                    ldb       #G80_TILEMAP_STRIDE
                    mul
                    orb       PH_X,s ; stack offset
                    ldy       PH_Video,s ; stack offset
                    leay      d,y
                    lda       ,y
                    sta       PH_UnderTile,s ; stack offset
                    ldx       PH_Game,s ; stack offset
                    ldb       GS_WaveState,x
                    cmpb      #SHOT_LAST_WAVE
                    bne       PlayerCollisionClass
                    cmpa      #$A0
                    beq       PlayerDockContact
                    cmpa      #$A9
                    bne       PlayerCollisionClass
PlayerDockContact inc     GS_DockTouch,x
PlayerCollisionClass
                    anda      #$E0
                    cmpa      #$20
                    beq       PlayerCollisionNext
                    cmpa      #$C0
                    beq       PlayerCollisionNext
                    cmpa      #$E0
                    beq       PlayerCollisionNext
                    ldb       PH_UnderTile,s ; stack offset
                    lda       #G80_GLYPH_BYTES
                    mul
                    addd      #G80_PLANE0_OFFSET
                    ldu       PH_Video,s ; stack offset
                    leay      d,u
                    lda       #G80_GLYPH_BYTES
                    ldb       PH_Tile,s ; stack offset
                    mul
                    addd      #G80_PLANE0_OFFSET
                    leau      d,u
                    ldb       #G80_GLYPH_BYTES
PlayerCollisionPixel
                    lda       ,y
                    anda      ,u
                    bne       PlayerCollisionHit
                    lda       ,y+
                    ora       ,u
                    sta       ,u+
                    decb
                    bne       PlayerCollisionPixel
PlayerCollisionNext
                    inc       PH_Tile,s ; stack offset
                    inc       PH_Y,s ; stack offset
                    dec       PH_Rows,s ; stack offset
                    bne       PlayerCollisionCell
                    inc       PH_X,s ; stack offset
                    dec       PH_Columns,s ; stack offset
                    bne       PlayerCollisionColumn
                    bra       PlayerCollisionReturn
PlayerCollisionHit
                    ldx       PH_Game,s ; stack offset
                    lda       PH_UnderTile,s ; stack offset
                    sta       GS_LastHitTile,x
                    lda       PH_X,s ; stack offset
                    ldb       PH_Y,s ; stack offset
                    std       GS_ShipHitX,x
                    lda       #1
                    sta       GS_PlayerDisabled,x
PlayerCollisionReturn
                    leas      PH_FrameBytes,s
                    puls      d,x,y,u,pc
