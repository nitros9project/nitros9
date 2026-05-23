**************************************************
* System Call: F$GModDr
*
* Function: Get copy of module directory
*
* Input:  X = 2048 byte buffer pointer
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FGModDr             ldd       <D.ModDir+2 ; get end ptr of module directory
                    subd      <D.ModDir ; calculate maximum size of module directory
                    tfr       d,y       ; put max. size in Y
                    ldd       <D.ModEnd ; get real end ptr of module dir
                    subd      <D.ModDir ; calculate real size of module dir
                    ldx       R$X,u     ; get requested buffer ptr to put it from caller
                  IFNE    H6309   ; begin conditional assembly for H6309
                    addr      d,x       ; calculate end addr. of directory after its copied
                  ELSE
                    leax      d,x       ; compute d,x into X
                  ENDC
                    stx       R$Y,u     ; preserve in caller's Y register
                    ldx       <D.ModDir ; get start ptr of module directory
                    stx       R$U,u     ; preserve in caller's U register

                    lda       <D.SysTsk ; get system task #
                    ldx       <D.Proc   ; get current process task #
                    ldb       P$Task,x  ; load B from P$Task,x
                    ldx       <D.ModDir ; get start ptr of module directory
                    bra       FGblkmpAddrPutRequested ; --- saves 4 bytes, adds 3 cycles
***         ldu   R$X,u       Get caller's buffer ptr
***         os9   F$Move      Copy module directory in caller's buffer
***         rts
