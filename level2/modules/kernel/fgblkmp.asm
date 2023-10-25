**************************************************
* System Call: F$GBlkMp
*
* Function:
*
* Input:  X = 1024 byte buffer pointer
*
* Output: D = Number of bytes per block
*         Y = Size of system's memory block map
*
*
* Error:  CC = C bit set; B = error code
*
FGBlkMp             ldd       #DAT.BlSz           # bytes per MMU block (8k)
                    std       R$D,u               Put into caller's D register
                    ldd       <D.BlkMap+2         Get end of system block map ptr
                    subd      <D.BlkMap           Subtract start of system block map ptr
                    std       R$Y,u               Store size of system block map in caller's Y reg.
                    tfr       d,y
                    lda       <D.SysTsk           Get system task #
                    ldx       <D.Proc             Get caller's task #
                    ldb       P$Task,x            get task # of caller
                    ldx       <D.BlkMap           Get start ptr of system block map
L0978               ldu       R$X,u               Get addr to put it that caller requested
                    os9       F$Move              Move it into caller's space
                    rts
