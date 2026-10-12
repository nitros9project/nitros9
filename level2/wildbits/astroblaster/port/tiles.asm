* Native 6809 tile decoding. No I/O and no access to another VT's memory.
* Include equates.asm before this file.
*
* DecodeTile
*   A = palette base (0,4,...,60); X = eight low-plane bytes;
*   Y = eight high-plane bytes; U = 64-byte destination buffer.
*   Preserves D,X,Y,U. CC is scratch. No OS calls or global scratch storage.
*   Source bits run MSB first, matching segag80r.cpp charlayout.
*   The $E800 source plane supplies bit 0; $F800 supplies bit 1.
*   Output indexes retain all 64 original colors. Quantization to the
*   WildBits 16-color bitmap palette belongs to the final renderer.
DecodeTile          pshs      d,x,y,u
                    leas      -DT_FrameBytes,s
                    sta       DT_PaletteBase,s
                    ldb       #G80_TILE_HEIGHT
                    stb       DT_RowsLeft,s
DecodeTileRow       lda       ,x+
                    sta       DT_LowPlane,s
                    lda       ,y+
                    sta       DT_HighPlane,s
                    ldb       #G80_TILE_WIDTH
                    stb       DT_ColumnsLeft,s
DecodeTilePixel     clrb
                    lsl       DT_HighPlane,s
                    rolb
                    lsl       DT_LowPlane,s
                    rolb
                    orb       DT_PaletteBase,s
                    stb       ,u+
                    dec       DT_ColumnsLeft,s
                    bne       DecodeTilePixel
                    dec       DT_RowsLeft,s
                    bne       DecodeTileRow
                    leas      DT_FrameBytes,s
                    puls      d,x,y,u,pc
