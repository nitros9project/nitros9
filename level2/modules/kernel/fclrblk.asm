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
FClrBlk             ldb       R$B,u
                    beq       L0BE9
                    ldd       R$U,u
                    tstb
                    bne       IllBlkErr
                    bita      #$1F
                    bne       IllBlkErr
                    ldx       <D.Proc
                    lda       P$SP,x
                    anda      #$E0
                    suba      R$U,u
                    bcs       L0BCE
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    cmpa      R$B,u
                    bcs       IllBlkErr
L0BCE
                    ifne      H6309
                    oim       #ImgChg,P$State,x
                    else
                    lda       P$State,x
                    ora       #ImgChg
                    sta       P$State,x
                    endc
                    lda       R$U,u
                    lsra
                    lsra
                    lsra
                    lsra
                    leay      P$DATImg,x
                    leay      a,y
                    ldb       R$B,u
                    ldx       #DAT.Free
L0BE4               stx       ,y++
                    decb
                    bne       L0BE4
L0BE9               clrb
                    rts
