**************************************************
* System Call: F$Icpt
*
* Function: Sets the function to be called when a signal arrives.
*
*
* Input:  X = Address of intercept routine
*         U = Address of intercept routine data area
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FIcpt               ldx       <D.Proc             get current process pointer
                    ldd       R$X,u               Get vector for signal trap handler
                    ifne      H6309
                    ldw       R$U,u               Get data area ptr for signal trap handler
                    stq       P$SigVec,x          Save them in descriptor
                    else
                    std       P$SigVec,x
                    ldd       R$U,u
                    std       P$SigDat,x
                    endc
                    clrb                          clear errors
                    rts                           return
