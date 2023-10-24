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
FDelImg             ldx       R$X,u               get process pointer
                    ldd       R$D,u               get start block & block count
                    leau      <P$DATImg,x         point to DAT image
                    lsla                          2 bytes per block entry
                    leau      a,u                 Point U to block entry
* Block count in B
L0B55
                    ifne      H6309
                    ldw       ,u                  Get block #
                    addw      <D.BlkMap           Add it to map ptr
                    aim       #^RAMinUse,0,w
                    ldw       #DAT.Free           get empty block marker
                    stw       ,u++                save it to process descriptor
                    decb                          done?
                    bne       L0B55               No, keep going
                    oim       #ImgChg,P$State,x
                    else
                    clra
                    tfr       d,y
                    pshs      x
L0BLoop             ldd       ,u
                    addd      <D.BlkMap
                    tfr       d,x
                    lda       ,x
                    anda      #^RAMinUse
                    sta       ,x
                    ldd       #DAT.Free
                    std       ,u++
                    leay      -1,y
                    bne       L0BLoop

                    puls      x
                    lda       P$State,x
                    ora       #ImgChg
                    sta       P$State,x
                    endc
                    clrb
                    rts
