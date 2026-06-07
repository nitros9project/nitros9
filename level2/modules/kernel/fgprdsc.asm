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
FGPrDsc             ldx       <D.Proc   ; get current process dsc. ptr.
                    ldb       P$Task,x  ; get task number
                    lda       R$A,u     ; get requested process ID #
                    os9       F$GProcP  ; get ptr to process to descriptor
                    bcs       FGprdscReturn ; error, exit with it
                    lda       <D.SysTsk ; get system task #
                    leax      ,y        ; point X to the process descriptor
                    ldy       #P$Size   ; Y=Size of process descriptor (512 bytes)
                    ldu       R$X,u     ; get requested place to put copy of process dsc.
                    os9       F$Move    ; move it into caller's space
FGprdscReturn       rts                 ; return to caller
