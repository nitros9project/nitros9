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
FGBlkMp             ldd       #DAT.BlSz ; # bytes per MMU block (8k)
                    std       R$D,u     ; put into caller's D register
                    ldd       <D.BlkMap+2 ; get end of system block map ptr
                    subd      <D.BlkMap ; subtract start of system block map ptr
                    std       R$Y,u     ; store size of system block map in caller's Y reg.
                    tfr       d,y       ; transfer register value d,y
                    lda       <D.SysTsk ; get system task #
                    ldx       <D.Proc   ; get caller's task #
                    ldb       P$Task,x  ; get task # of caller
                    ldx       <D.BlkMap ; get start ptr of system block map
FGblkmpAddrPutReq   ldu       R$X,u     ; get addr to put it that caller requested
                    os9       F$Move    ; move it into caller's space
                    rts                 ; return to caller
