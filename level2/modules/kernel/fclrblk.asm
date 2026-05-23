**************************************************
* System Call: F$ClrBlk
*
* Function: Clear RAM blocks
*
* Input:  B = Number of blocks
*         U = Address of first block
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FClrBlk             ldb       R$B,u     ; load B from R$B,u
                    beq       L0BE9     ; branch if zero is set to L0BE9
                    ldd       R$U,u     ; load D from R$U,u
                    tstb                ; test B and update condition codes
                    bne       IllBlkErr ; branch if zero is clear to IllBlkErr
                    bita      #$1F      ; test bits in A against #$1F
                    bne       IllBlkErr ; branch if zero is clear to IllBlkErr
                    ldx       <D.Proc   ; load X from <D.Proc
                    lda       P$SP,x    ; load A from P$SP,x
                    anda      #$E0      ; mask A with #$E0
                    suba      R$U,u     ; subtract R$U,u from A
                    bcs       L0BCE     ; branch if carry is set to L0BCE
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    cmpa      R$B,u     ; compare A with R$B,u
                    bcs       IllBlkErr ; branch if carry is set to IllBlkErr
L0BCE
                  IFNE    H6309   ; begin conditional assembly for H6309
                    oim       #ImgChg,P$State,x ; apply immediate bit operation #ImgChg,P$State,x
                  ELSE
                    lda       P$State,x ; load A from P$State,x
                    ora       #ImgChg   ; merge #ImgChg into A
                    sta       P$State,x ; store A at P$State,x
                  ENDC
                    lda       R$U,u     ; load A from R$U,u
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    leay      P$DATImg,x ; compute P$DATImg,x into Y
                    leay      a,y       ; compute a,y into Y
                    ldb       R$B,u     ; load B from R$B,u
                    ldx       #DAT.Free ; load X from #DAT.Free
L0BE4               stx       ,y++      ; store X at ,y++
                    decb                ; decrement B
                    bne       L0BE4     ; branch if zero is clear to L0BE4
L0BE9               clrb                ; clear B
                    rts                 ; return to caller
