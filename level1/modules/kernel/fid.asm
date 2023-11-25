;;; F$ID
;;;
;;; Return a caller’s process ID and user ID.
;;;
;;; Entry:  None
;;;
;;; Exit:   A = The process ID of the caller's process.
;;;         Y = The user ID of the caller's process.
;;;        CC = Carry flag clear to indicate success.
;;;
;;; The process ID is a byte value in the range 1 to 255. The kernel assigns each process a unique process ID.
;;; The user ID is an integer from 0 to 65535. Several processes can have the same user ID.

FID            ldx       <D.Proc             get the current process descriptor
               lda       P$ID,x              get the process ID
               sta       R$A,u               put in in the caller's A
               ldd       P$User,x            get the user ID
               std       R$Y,u               put it in the caller's Y
               clrb                          clear carry
               rts                           return to the caller

