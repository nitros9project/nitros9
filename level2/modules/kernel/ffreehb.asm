;;; F$FreeHB
;;;
;;; Get the highest free block in a process' address space.
;;;
;;; Entry:  B = The block count.
;;;         Y = The DAT image pointer.
;;;
;;; Exit:   A = The highest free block number.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

FFreeHB             ldb       R$B,u               get the number blocks requested
                    ldy       R$Y,u               get the DAT image pointer
                    bsr       L0A31               go find free blocks in high part of DAT
L0A2C               bcs       L0A30               couldn't find any, exit with error
                    sta       R$A,u               save the starting block number
L0A30               rts                           return

L0A31               tfr       b,a                 copy the number blocks requested to A
* This gets called directly from within F$Link
L0A33               suba      #$09                invert within 8
                    nega                          negate
                    pshs      x,d                 save X, the block number and the block count
                    ldd       #$FFFF              -1
L0A56               pshs      d                   save the value on the stack

* Move to next block - SHOULD OPTIMIZE WITH W
L0A58               clra                          number free blocks found so far=0
                    ldb       2,s                 get the block number
                    addb      ,s                  add the block increment (point to next block)
                    stb       2,s                 save the new block number to check
                    cmpb      1,s                 same as block count?
                    bne       L0A75               no, skip ahead
                    ldb       #E$MemFul           preset error for 207 (process memory full)
                    cmpy      <D.SysDAT           is it the system process?
                    bne       L0A6C               no, exit with error 207
                    ldb       #E$NoRAM            system memory full (237)
L0A6C               stb       3,s                 save the error code
                    comb                          set the carry
                    bra       L0A82               exit with error

L0A71               tfr       a,b                 copy the number of blocks to B
                    addb      2,s                 add the current start block number
L0A75               lslb                          multiply the block number by 2
                    ldx       b,y                 get the DAT marker for that block
                    cmpx      #DAT.Free           is it an empty block?
                    bne       L0A58               no, move to the next block
                    inca                          bump up the number blocks free counter
                    cmpa      3,s                 have we got enough?
                    bne       L0A71               no, keep looking
L0A82               leas      2,s                 eat the temporary stack
                    puls      d,x,pc              restore registers, error code, and return


;;; F$FreeLB
;;;
;;; Get the lowest free block in a process' address space.
;;;
;;; Entry:  B = The block count.
;;;         Y = The DAT image pointer.
;;;
;;; Exit:   A = The lowest free block number.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

* WHERE DOES THIS EVER GET CALLED FROM???
* Rodney says: "It's called via os9p1 syscall vector in line 393"
FSFreeLB            ldb       R$B,u               get the block count
                    ldy       R$Y,u               get the pointer to DAT Image
                    bsr       L0A4B               go find the block numbers
                    bra       L0A2C               do error checking and exit

L0A4B               lda       #$FF                the value to start the loop at block 0
                    pshs      x,d                 preserve X, flag, and block count
*         lda   #$01           number to add to go to the next block (positive here)
                    nega                          -(-1)=+1
                    subb      #9                  drop the block count to -8 to -1 (invert within 8)
                    negb                          negate so it is a positive number again
                    bra       L0A56               go into the main find loop


;;; F$SetImg
;;;
;;; Copy all or part of the DAT image into a process descriptor.
;;;
;;; Entry:  A = The starting image block number.
;;;         B = The block count.
;;;         X = The process descriptor pointer.
;;;         U = The new image pointer.
;;;
;;; Exit:   None
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

FSetImg             ldd       R$D,u               get the starting image block number and blcok count
                    ldx       R$X,u               get the process descriptor pointer
                    ldu       R$U,u               get the new image pointer
L0A8C               pshs      d,x,y,u             save these onto the stack
                    leay      <P$DATImg,x         point to the DAT image within the process descriptor
                    lsla                          multiply the starting image block number by 2
                    leay      a,y                 point Y into the starting point of the DAT image area of the process descriptor
                    ifne      H6309
                    clra                          clear the upper 8 bits
                    lslb                          and multiply the lower 8 bits by 2
                    tfr       d,w                 transfer the count to W
                    tfm       u+,y+               perform the transfer
                    oim       #ImgChg,P$State,x   set the "image changed" flag
                    else
                    lslb                          multiply the block count by 2
loop@               lda       ,u+                 get the new image value
                    sta       ,y+                 and store it in the process descriptor image area
                    decb                          decrement the counter
                    bne       loop@               branch if not done
                    lda       P$State,x           get the process' state
                    ora       #ImgChg             set the "image changed" flag
                    sta       P$State,x           and store it back
                    endc
                    clrb                          clear the carry
                    puls      d,x,y,u,pc          restore the registers and return to the caller
