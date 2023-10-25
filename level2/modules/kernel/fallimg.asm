**************************************************
* System Call: F$AllImg
*
* Function: Allocate image RAM blocks
*
* Input:  A = Starting block number
*         B = Number of blocks
*         X = Process descriptor pointer
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FAllImg             ldd       R$D,u               get starting block # & # of blocks
                    ldx       R$X,u               get process descriptor pointer
* Entry point from F$SRqMem
*
* 6309 NOTE: IF W IS USED HERE, TRY TO PRESERVE IT AS F$SRQMEM WILL
*   PROBABLY END UP USING IT
L09BE               pshs      d,x,y,u
                    lsla
                    leay      P$DATImg,x
                    leay      a,y
                    clra
                    tfr       d,x
                    ldu       <D.BlkMap
                    pshs      d,x,y,u
L09CD               ldd       ,y++
                    cmpd      #DAT.Free
                    beq       L09E2
                    lda       d,u
                    cmpa      #RAMinUse
                    puls      d
                    bne       L09F7
                    ifne      H6309
                    decd
                    else
                    subd      #$0001
                    endc
                    pshs      d
L09E2               leax      -1,x
                    bne       L09CD
                    ldx       ,s++
                    beq       L0A00
L09EA               lda       ,u+
                    bne       L09F2
                    leax      -1,x
                    beq       L0A00
L09F2               cmpu      <D.BlkMap+2
                    bcs       L09EA
L09F7               ldb       #E$MemFul
                    leas      6,s
                    stb       1,s
                    comb
                    puls      d,x,y,u,pc

L0A00               puls      x,y,u
L0A02               ldd       ,y++
                    cmpd      #DAT.Free
                    bne       L0A16
L0A0A               lda       ,u+
                    bne       L0A0A
                    inc       ,-u
                    tfr       u,d
                    subd      <D.BlkMap
                    std       -2,y
L0A16               leax      -1,x
                    bne       L0A02
                    ldx       2,s
                    ifne      H6309
                    oim       #ImgChg,P$State,x
                    else
                    lda       P$State,x
                    ora       #ImgChg
                    sta       P$State,x
                    endc
                    clrb
                    puls      d,x,y,u,pc
