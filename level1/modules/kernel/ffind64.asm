;;; F$Find64
;;;
;;; Return the address of a 64 byte memory block.
;;;
;;; Entry:  A = The block number.
;;;         X = The base address of the page table.
;;;
;;; Exit:   Y = The address of the found block.
;;;        CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$Find64 locates a 64 byte block, such as a path or process descriptor, when
;;; given their block number. The block number can be any positive integer.

FFind64        lda       R$A,u               get the caller's block number
               ldx       R$X,u               and the base address of the page table
               bsr       FindBlock           perform the location
               bcs       ex@                 branch if error
               sty       R$Y,u               save found block to caller's Y
ex@            rts                           return to caller

FindBlock      pshs      b,a                 save off D
               tsta                          is the block greater than zero?
               beq       errex@              no; illegal block
               clrb                          else clear B
               lsra                          divide D
               rorb                          by 2 
               lsra                          then divide D
               rorb                          by 2 again, now D = D / 4
               lda       a,x                 move upper 8 bits of 16 bit address from page into A
               tfr       d,y                 D is now address of 64 byte block; move into Y
               beq       errex@              branch if Y is zero; error
               tst       ,y                  is first byte at block zero?
               bne       ex@                 branch if not; Y is our address!
errex@         coma                          set carry to indicate error
ex@            puls      pc,b,a              restore registers and return
