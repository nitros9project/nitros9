**************************************************
* System Call: F$ID
*
* Function: Return's caller's process ID
*
* Input:  None
*
* Output: A = Caller's process ID
*         Y = User ID
*
* Error:  CC = C bit set; B = error code
*
FID                 ldx       <D.Proc             get current process pointer
                    lda       P$ID,x              get ID
                    sta       R$A,u               save it
                    ldd       P$User,x            get user #
                    std       R$Y,u               save it
                    clrb                          clear error
                    rts
