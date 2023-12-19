;;; F$MapBlk
;;;
;;; Map one or more blocks into the calling process' address space.
;;;
;;; Entry:  B = The number of blocks to map in.
;;;         X = The starting block number.
;;;
;;; Exit:   U = The address of the first block in the caller's address space.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

stackbuff           set       DAT.BlCt*2

FMapBlk             lda       R$B,u               get the number of blocks from the caller's B
                    beq       IllBlkErr           if zero, we can't map 0 blocks, so return an error
                    cmpa      #DAT.BlCt           is the block count within range of DAT image?
                    bhi       IllBlkErr           no, return an error
                    leas      -stackbuff,s        make a buffer on the stack to hold the DAT image
                    ldx       R$X,u               get the start block number from the caller's X
                    ldb       #1                  load the block increment value
                    ifne      H6309
* Change to W 05/19/93 - used W since one cycle faster per block
                    tfr       s,w                 point to the buffer
loop@               stx       ,w++                save the block number to the buffer
                    else
                    tfr       s,y                 point to the buffer
loop@               stx       ,y++                save the block number to the buffer
                    endc
                    abx                           add the block increment
                    deca                          decrement the number of blocks we need
                    bne       loop@               branch if we need more
                    ldb       R$B,u               get the block count again
                    ldx       <D.Proc             get the current process pointer
                    leay      <P$DATImg,x         point to the DAT image
                    os9       F$FreeHB            find the highest free block offset
                    bcs       L0BA6               return with error if carry is set (no room)
                    ifne      H6309
                    tfr       d,w                 preserve the starting block number and the number of blocks
                    else
                    pshs      d                   preserve the starting block number and the number of blocks
                    endc
                    lsla                          multiply the start block number by 2
                    lsla                          and by 2 again (total is 4)
                    lsla                          and by 2 again (total is 8)
                    lsla                          and by 2 again (total is 16)
                    lsla                          and by 2 again (total is 32)
                    clrb                          clear the lower 8 bits
                    std       R$U,u               save the address of the first block
                    ifne      H6309
                    tfr       w,d                 restore the offset
                    else
                    puls      d                   restore the offset
                    endc
                    leau      ,s                  move the DAT image into the process descriptor
                    os9       F$SetImg            change the process descriptor to reflect new blocks
L0BA6               leas      <stackbuff,s        eat the DAT image copy on the stack
                    rts                           return to the caller

IllBlkErr           comb                          set the carry
                    ldb       #E$IBA              illegal block address error
                    rts                           return to the caller
