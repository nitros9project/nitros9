;;; F$CRC
;;;
;;; Compute the CRC of bytes in memory.
;;;
;;; Entry:  X = The starting address.
;;;         Y = The number of bytes.
;;;         U = The address of the 3 byte accumulator.
;;;
;;; Exit:   U = The address of the updated 3 byte accumulator.
;;;
;;; F$CRC calculates the Cyclic Redundancy Count (CRC) of a series of bytes in memory.
;;; Compilers, assemblers, and other module generators use this system call.
;;; The calculation begins at the starting address and continues over the specified number of bytes.
;;; You don't need to cover an entire module in one call since the CRC accumulates over several calls.
;;; The CRC accumulator can be any 3-byte memory area. You must initialize it to $FFFFFF before the first F$CRC call.
;;; The updated accumulator doesn't include the last three bytes of the module. The 3 CRC bytes are stored there.
;;; Initialize the CRC accumulator only once for each module check.

FCRC           ldx       R$X,u               get the starting address in X
               ldy       R$Y,u               and the number of bytes in Y
               beq       FCRCEx              if number of bytes is zero, return
               ldu       R$U,u               get the address of the 3 byte accumulator in U
FCRCLoop       lda       ,x+                 get the next byte at X and increment X
               bsr       CRCAlgo             perform the CRC algorithm
               leay      -1,y                decrement the count
               bne       FCRCLoop            branch if there are more bytes
FCRCEx         clrb                          clear the error code and carry
               rts                           return to the caller

CRCAlgo        eora      ,u                  XOR A with first byte of accumulator
               pshs      a                   push the result
               ldd       $01,u               get the second and third bytes of the accumulator
               std       ,u                  save in the first and second accumulator locations
               clra                          clear A
               ldb       ,s                  get XOR'ed value pushed earlier
               lslb                          left shift B
               rola                          left roll A
               eora      1,u                 XOR A with the second byte of the accumulator
               std       1,u                 and store D in the second and third bytes of the accumulator
               clrb                          clear B
               lda       ,s                  get the XOR'ed value pushed earlier
               lsra                          right shift A
               rorb                          right roll B
               lsra                          right shift A
               rorb                          right roll B
               eora      1,u                 XOR A with the second byte of the accumulator
               eorb      2,u                 XOR B with the third byte of the accumulator
               std       1,u                 store the result in the second and third bytes of the accumulator
               lda       ,s                  get the XOR'ed value pushed earlier
               lsla                          left shift A
               eora      ,s                  XOR A with the XOR'ed value pushed earlier
               sta       ,s                  and update the value on the stack
               lsla                          left shift A
               lsla                          left shift A
               eora      ,s                  XOR A with the XOR'ed value pushed earlier
               sta       ,s                  and update the value on the stack
               lsla                          left shift A
               lsla                          left shift A
               lsla                          left shift A
               lsla                          left shift A
               eora      ,s+                 XOR A with the XOR'ed value pushed earlier and pop the value
               bpl       ex@                 branch if the hi-bit is clear
               ldd       #$8021              else load D with this value
               eora      ,u                  XOR A with the first byte of the accumulator
               sta       ,u                  and save the result to the first byte of the accumulator
               eorb      2,u                 XOR B with the third byte of the accumulator
               stb       2,u                 and save the result to the third byte of the accumulator
ex@            rts                           return to the caller
