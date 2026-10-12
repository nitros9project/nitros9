* Native equivalent of original $1B5F..$1B72 (unshifted column copier).
* The Z80 uses EXX to keep two pointers and row strides; the 6809 uses
* X and Y directly. This copies GAME BUFFERS, not hardware registers.
*
* X = source, Y = destination, U = SC_Parameters record of signed strides.
* A = column count, B = row count; 0 means 256, matching Z80 DJNZ.
* Adjacent columns start at base+1, irrespective of the row stride.
* Caller validates both rectangles against its allocated storage.
* Preserves D,X,Y,U. CC scratch. No shared scratch and no interrupt masking.
CopyStridedColumns pshs      d,x,y,u
                    leas      -SC_FrameBytes,s
                    sta       SC_ColumnsLeft,s
                    stb       SC_RowsPerColumn,s
CopyStridedColumn  ldb       SC_RowsPerColumn,s
                    stb       SC_RowsLeft,s
                    pshs      x,y
CopyStridedRow     lda       ,x
                    sta       ,y
                    ldd       SC_SourceStride,u
                    leax      d,x
                    ldd       SC_TargetStride,u
                    leay      d,y
                    dec       SC_BasePointers+SC_RowsLeft,s ; stack offset past saved X,Y
                    bne       CopyStridedRow
                    puls      x,y
                    leax      1,x
                    leay      1,y
                    dec       SC_ColumnsLeft,s
                    bne       CopyStridedColumn
                    leas      SC_FrameBytes,s
                    puls      d,x,y,u,pc

* Native counterparts of original $1B73,$1B95,$1BBC,$1BE3,$1C02,
* $1C29,$1C4F. U extends SC_Parameters with SSC_Shift (0..7).
* The input registers and preservation contract match CopyStridedColumns.
* For a nonzero shift the caller supplies ONE EXTRA destination row.
* The original RRD tails for shifts 3/4/5 preserve some preexisting tail
* bits; these are deliberately retained, even when a caller clears first.
CopyShiftedColumns tst       SSC_Shift,u
                    lbeq      CopyStridedColumns
                    pshs      d,x,y,u
                    leas      -SSC_FrameBytes,s
                    sta       SSC_ColumnsLeft,s
                    stb       SSC_RowsPerColumn,s
ShiftedCopyColumn ldb       SSC_RowsPerColumn,s
                    stb       SSC_RowsLeft,s
                    clr       SSC_CarryPixels,s
                    pshs      x,y
ShiftedCopyRow    lda       SSC_Shift,u
                    sta       SSC_BasePointers+SSC_ShiftsLeft,s ; stack offset past X,Y
                    lda       ,x
                    clrb
* D starts as source<<8. Shift it right: A becomes the output bits and
* B receives the low source bits aligned for the next destination row.
ShiftedCopyBit    lsra
                    rorb
                    dec       SSC_BasePointers+SSC_ShiftsLeft,s ; stack offset
                    bne       ShiftedCopyBit
                    ora       SSC_BasePointers+SSC_CarryPixels,s ; stack offset
                    sta       ,y
                    stb       SSC_BasePointers+SSC_CarryPixels,s ; stack offset
                    ldd       SC_SourceStride,u
                    leax      d,x
                    ldd       SC_TargetStride,u
                    leay      d,y
                    dec       SSC_BasePointers+SSC_RowsLeft,s ; stack offset
                    bne       ShiftedCopyRow
                    lda       SSC_Shift,u
                    cmpa      #3
                    blo       ShiftedCopyPlainTail
                    cmpa      #5
                    bhi       ShiftedCopyPlainTail
                    tfr       a,b
                    lda       ,y
                    lsra
                    lsra
                    lsra
                    lsra
                    cmpb      #5
                    bne       ShiftedCopyMergeTail
                    lsra
ShiftedCopyMergeTail
                    ora       SSC_BasePointers+SSC_CarryPixels,s ; stack offset
                    bra       ShiftedCopyStoreTail
ShiftedCopyPlainTail
                    lda       SSC_BasePointers+SSC_CarryPixels,s ; stack offset
ShiftedCopyStoreTail
                    sta       ,y
                    puls      x,y
                    leax      1,x
                    leay      1,y
                    dec       SSC_ColumnsLeft,s
                    bne       ShiftedCopyColumn
                    leas      SSC_FrameBytes,s
                    puls      d,x,y,u,pc
