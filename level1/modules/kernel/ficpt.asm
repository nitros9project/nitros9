;;; F$Icpt
;;;
;;; Set a signal intercept routine.
;;;
;;; Entry:  X = The address of the intercept routine.
;;;         U = Starting address of the routine’s memory area.
;;;
;;; Exit:   None
;;;
;;; F$Icpt set a signal intercept routine that the kernel calls whenever the process receives a signal.
;;; Store the address of the signal handler routine in X and the base address of the routine’s storage area in U.
;;; Terminate the signal intercept routine with an RTI instruction.
;;;
;;; If a process doesn't used F$Icpt system call , the process terminates if it receives a signal.
;;;
;;; When the process receives a signal, the kernel sets U to the starting address of the intercept routine’s memory area,
;;; and B to the signal code, then calls the signal intercept routine.
;;;
;;; Note: The value of DP cannot be the same as it was when you called F$Icpt.

FIcpt          ldx       <D.Proc             get the current process descriptor
               ldd       R$X,u               get the address of the intercept routine from the caller
               ifne      H6309
               ldw       R$U,u               get the data area pointer for the intercept routine
               stq       P$SigVec,x          save them in the process descriptor
               else
               std       <P$SigVec,x         store it in the process descriptor
               ldd       R$U,u               get the caller's data pointer
               std       <P$SigDat,x         store it in the process descriptor
               endc
               clrb                          clear carry
               rts                           return to the caller
