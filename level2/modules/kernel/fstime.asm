**************************************************
* System Call: F$STime
*
* Function: Set system time
*
* Input:  X = Address of time packet:
*
*        Offset 0 = Year
*        Offset 1 = Month
*        Offset 2 = Day
*        Offset 3 = Hour
*        Offset 4 = Minute
*        Offset 5 = Second
*
* Output: System time/date set
*
* Error:  CC = C bit set; B = error code
*
FSTime              ldx       R$X,u               Get address that user wants time packet
***         tfr   dp,a            Set MSB of D to direct page
***         ldb   #D.Time         Offset to Time packet in direct page
***         tfr   d,u             Point U to it
                    ldu       #D.Time             --- DP=0 always
                    ldy       <D.Proc             Get ptr to process that called us
                    lda       P$Task,y            Get task # from process
                    ldb       <D.SysTsk           Get task # of system process
                    ldy       #6                  6 byte packet to move
                    os9       F$Move              Go move it
                    ldx       <D.Proc             Get ptr to process that called us
                    pshs      x                   Preserve it
                    ldx       <D.SysPrc           Get ptr to system process
                    stx       <D.Proc             Save as current process
                    lda       #Systm+Objct        Link to Clock module
                    leax      ClockNam,pc
                    os9       F$Link
                    puls      x                   Get back ptr to user's process
                    stx       <D.Proc             Make it the active process again
                    bcs       ex@                 If error in Link, exit with error code
                    jmp       ,y                  Jump into Clock
ex@                 rts

ClockNam            fcs       /Clock/
