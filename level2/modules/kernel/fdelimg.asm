**************************************************
* System Call: F$DelImg
*
* Function: Deallocate image RAM blocks
*
* Input:  A = Beginning block number
*         B = Block count
*         X = Process descriptor pointer
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FDelImg             ldx       R$X,u     ; get process pointer
                    ldd       R$D,u     ; get start block & block count
                    leau      <P$DATImg,x ; point to DAT image
                    lsla                ; 2 bytes per block entry
                    leau      a,u       ; point U to block entry
* Block count in B
L0B55
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldw       ,u        ; get block #
                    addw      <D.BlkMap ; add it to map ptr
                    aim       #^RAMinUse,0,w ; apply immediate bit operation #^RAMinUse,0,w
                    ldw       #DAT.Free ; get empty block marker
                    stw       ,u++      ; save it to process descriptor
                    decb                ; done?
                    bne       L0B55     ; no, keep going
                    oim       #ImgChg,P$State,x ; apply immediate bit operation #ImgChg,P$State,x
                  ELSE
                    clra                ; clear A
                    tfr       d,y       ; transfer register value d,y
                    pshs      x         ; save x on the stack
L0BLoop             ldd       ,u        ; load D from ,u
                    addd      <D.BlkMap ; add <D.BlkMap to D
                    tfr       d,x       ; transfer register value d,x
                    lda       ,x        ; load A from ,x
                    anda      #^RAMinUse ; mask A with #^RAMinUse
                    sta       ,x        ; store A at ,x
                    ldd       #DAT.Free ; load D from #DAT.Free
                    std       ,u++      ; store D at ,u++
                    leay      -1,y      ; compute -1,y into Y
                    bne       L0BLoop   ; branch if zero is clear to L0BLoop

                    puls      x         ; restore x from the stack
                    lda       P$State,x ; load A from P$State,x
                    ora       #ImgChg   ; merge #ImgChg into A
                    sta       P$State,x ; store A at P$State,x
                  ENDC
                    clrb                ; clear B
                    rts                 ; return to caller
