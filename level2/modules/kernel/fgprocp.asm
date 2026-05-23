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
FGProcP             lda       R$A,u     ; get process #
                    bsr       FGprocpTarget ; get ptr to process descriptor
                    bcs       FGprocpReturn ; if error, exit with it
                    sty       R$Y,u     ; save ptr in caller's Y
FGprocpReturn       rts                 ; return

* Entry: A=Process #
* Exit:  Y=Ptr to process descriptor
*  All others preserved
FGprocpTarget       pshs      d,x       ; preserve regs
                    ldb       ,s        ; get process # into B
                    beq       FGprocpBack ; 0, skip ahead
                    ldx       <D.PrcDBT ; get ptr to process descriptor block table
                    abx                 ; point to specific process' entry
                    lda       ,x        ; get MSB of process dsc. ptr
                    beq       FGprocpBack ; none there, exit with error
                    clrb                ; clear LSB of process dsc. ptr (always fall on $200
                    tfr       d,y       ; boundaries) & move ptr to Y
                    puls      d,x,pc    ; restore regs & return

FGprocpBack         puls      d,x       ; get regs back
                    comb                ; exit with Bad process ID error
                    ldb       #E$BPrcID ; load B from #E$BPrcID
                    rts                 ; return to caller
