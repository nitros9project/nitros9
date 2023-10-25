;;; F$SSWI
;;;
;;; Set software interrupt vectors for a process.
;;;
;;; Entry:  A = The software interrupt code (1 - 3).
;;;         X = The address of the new software interrupt routine.
;;;
;;; Exit:   None.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$SSWI sets the interrupt vectors for SWI, SWI2, and SWI3 instructions. Each process descriptor has its own
;;; local vectors that the kernel sets up at creation. Set the appropriate vector according to the code you pass
;;; in A:
;;;
;;;     1 = SWI
;;;     2 = SWI2
;;;     3 = SWI3
;;;
;;; Note: kernel system calls are invoked using SWI2. If you change this vector, system calls stop working.

FSSWI               ldx       <D.Proc             get current process descriptor
                    leay      P$SWI,x             point to the SWI vectors
                    ldb       R$A,u               get the desired interrupt code to change from the caller's A
                    decb                          decrement it
                    cmpb      #$03                is it higher than the allowed value?
                    bcc       errex@              branch if so, it's an error
                    lslb                          else multiply by 2 to get the 16-bit offset
                    ldx       R$X,u               get the address of the new software interrupt routine from the caller's X
                    stx       b,y                 and store it in the appropriate vector in the process descriptor
                    rts                           return to the caller
errex@              comb                          set the carry to indicate an error
                    ldb       #E$ISWI             invalid SWI number
                    rts                           return to the caller
