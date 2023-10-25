**************************************************
* System Call: F$GProcP
*
* Function: Get process pointer
*
* Input:  A = Process ID
*
* Output: Y = Pointer to process descriptor
*
* Error:  CC = C bit set; B = error code
*
FGProcP             lda       R$A,u               get process #
                    bsr       L0B2E               Get ptr to process descriptor
                    bcs       L0B2D               If error, exit with it
                    sty       R$Y,u               Save ptr in caller's Y
L0B2D               rts                           Return

* Entry: A=Process #
* Exit:  Y=Ptr to process descriptor
*  All others preserved
L0B2E               pshs      d,x                 Preserve regs
                    ldb       ,s                  Get process # into B
                    beq       L0B40               0, skip ahead
                    ldx       <D.PrcDBT           Get ptr to process descriptor block table
                    abx                           Point to specific process' entry
                    lda       ,x                  Get MSB of process dsc. ptr
                    beq       L0B40               None there, exit with error
                    clrb                          Clear LSB of process dsc. ptr (always fall on $200
                    tfr       d,y                 boundaries) & move ptr to Y
                    puls      d,x,pc              Restore regs & return

L0B40               puls      d,x                 Get regs back
                    comb                          Exit with Bad process ID error
                    ldb       #E$BPrcID
                    rts
