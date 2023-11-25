;;; F$Ret64
;;;
;;; Deallocate a 64 byte block of memory.
;;;
;;; Entry:  A = The block number to deallocate.
;;;         X = The base address of the page table; 0 = allocate the page table.
;;;
;;; Exit:   None
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$Ret64 returns a previously allocated 64 byte block to the free pool.

FRet64         lda       R$A,u               get the block number to deallocate
               ldx       R$X,u               and the base address of the page table
               pshs      u,y,x,b,a           preserve registers
               clrb                          clear B
               lsra                          divide D by 2
               rorb                          then...
               lsra                          divide D by 2 again
               rorb                          D = D/4
               pshs      a                   A now holds the offset in the page table
               lda       a,x                 get the byte in the page table
               beq       ex@                 branch if 0; already deallocated, so nothing to do
               tfr       d,y                 else copy D in to Y
               clr       ,y                  and clear first byte of 64 byte block at Y to mark it free
               clrb                          clear B, now D holds address of 256 byte page for this 64 byte block
               tfr       d,u                 put D into U
               clra                          clear A
* Check if all 64 byte blocks in this 256 byte page are deallocated. If so, free the entire 256 byte block.
loop@          tst       d,u                 test first byte of 64 byte block
               bne       ex@                 if not zero, it's allocated; just exit
               addb      #64                 else add 64 to B
               bne       loop@               and check the next 64 byte block
               inca                          increment A
               os9       F$SRtMem            return 256 byte block to free pool
               lda       ,s                  get block number saved earlier
               clr       a,x                 clear block number in page table to indicate deallocated                  
ex@            clr       ,s+                 clear byte and increment stack
               puls      pc,u,y,x,b,a        restore registers and return

