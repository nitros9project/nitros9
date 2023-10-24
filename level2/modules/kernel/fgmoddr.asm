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
FGModDr             ldd       <D.ModDir+2         Get end ptr of module directory
                    subd      <D.ModDir           Calculate maximum size of module directory
                    tfr       d,y                 Put max. size in Y
                    ldd       <D.ModEnd           Get real end ptr of module dir
                    subd      <D.ModDir           Calculate real size of module dir
                    ldx       R$X,u               Get requested buffer ptr to put it from caller
                    ifne      H6309
                    addr      d,x                 Calculate end addr. of directory after its copied
                    else
                    leax      d,x
                    endc
                    stx       R$Y,u               Preserve in caller's Y register
                    ldx       <D.ModDir           Get start ptr of module directory
                    stx       R$U,u               Preserve in caller's U register

                    lda       <D.SysTsk           Get system task #
                    ldx       <D.Proc             Get current process task #
                    ldb       P$Task,x
                    ldx       <D.ModDir           Get start ptr of module directory
                    bra       L0978               --- saves 4 bytes, adds 3 cycles
***         ldu   R$X,u       Get caller's buffer ptr
***         os9   F$Move      Copy module directory in caller's buffer
***         rts
