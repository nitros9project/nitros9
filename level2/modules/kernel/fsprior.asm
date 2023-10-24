**************************************************
* System Call: F$SPrior
*
* Function: Set a process' priority
*
* Input:  A = Process ID
*         B = Priority (0 = lowest, 255 = highest)
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FSPrior             lda       R$A,u               get process #
                    lbsr      L0B2E               get pointer to it
                    bcs       L07C0               error, return
                    ldx       <D.Proc             get current process
                    ldd       P$User,x            get user #
                    beq       L07B7               super user, go set priority
                    cmpd      P$User,y            user #'s match?
                    bne       L07BD               no, return error
L07B7               lda       R$B,u               get new priority
                    sta       P$Prior,y           set it
                    clrb                          clear errors
                    rts                           return
L07BD               comb                          set carry for error
                    ldb       #E$BPrcID
L07C0               rts
