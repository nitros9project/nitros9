**************************************************
* System Call: F$SSVC
*
* Function: Install system calls
*
* Input:  Y = Address of service request init table
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FSSvc               ldy       R$Y,u               get pointer to table
                    bra       SysSvc              start moving
* Main move loop
L036D               clra                          clear MSB of table offset
                    lslb                          multiply function # by 2 to get offset into table
                    tfr       d,u                 copy it to U
                    ldd       ,y++                get vector to function handler
                    leax      d,y                 offset X from current Y
                    ldd       <D.SysDis           get system dispatch table pointer
                    stx       d,u                 save vector into place
                    bcs       SysSvc              it was a privliged call, skip ahead
                    ldd       <D.UsrDis           get user displat table pointer
                    stx       d,u                 save vector into place
SysSvc              ldb       ,y+                 get callcode
                    cmpb      #$80                done?
                    bne       L036D               no, keep going
                    rts                           return
