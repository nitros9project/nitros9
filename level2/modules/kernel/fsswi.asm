**************************************************
* System Call: F$SSWI
*
* Function: Sets the SWI vector specified for the calling process.
*
* Input:  B = SWI vector (1-3) to modify
*         U = Address of new SWI vector for process
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FSSWI               ldx       <D.Proc             get current process
                    ldb       R$A,u               get type code
                    decb                          adjust for offset
                    cmpb      #3                  legal value?
                    bcc       BadSWI              no, return error
                    lslb                          account for 2 bytes entry
                    addb      #P$SWI              go to start of P$SWI pointers
                    ldu       R$X,u               get address
                    stu       b,x                 save to descriptor
                    rts                           return

BadSWI              comb
                    ldb       #E$ISWI
                    rts
