**************************************************
* System Call: F$GPrDsc
*
* Function: Get copy of process descriptor
*
* Input:  A = Desired process ID
*         X = 512 byte buffer pointer
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FGPrDsc             ldx       <D.Proc             Get current process dsc. ptr.
                    ldb       P$Task,x            Get task number
                    lda       R$A,u               Get requested process ID #
                    os9       F$GProcP            Get ptr to process to descriptor
                    bcs       L0962               Error, exit with it
                    lda       <D.SysTsk           Get system task #
                    leax      ,y                  Point X to the process descriptor
                    ldy       #P$Size             Y=Size of process descriptor (512 bytes)
                    ldu       R$X,u               Get requested place to put copy of process dsc.
                    os9       F$Move              Move it into caller's space
L0962               rts
