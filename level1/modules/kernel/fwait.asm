;;; F$Wait
;;;
;;; Suspend the calling process to wait for a child to terminate.
;;;
;;; Entry:  None
;;;
;;; Exit:   A = The process ID of the terminated child process.
;;;         B = The exit status of the terminated child process.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;;
;;; F$Wait suspends the calling process until one of its children terminates. The kerenel returns the child’s
;;; process ID and exit status. If the child terminated due to a signal, the exit status byte in B contains the
;;; signal code.
;;;
;;; If the caller has more than one child, the kernel activates the caller when the first one terminates. Therefore,
;;; you need call F$Wait to detect the termination of each child.
;;;
;;; The kernel immediately reactivates the caller if a child terminates before F$Wait. If the caller has no children,
;;; F$Wait returns an error.
;;; A return from F$Wait with the carry bit set indicates failure; otherwise, the call functioned properly and the
;;; child's exit status resides in B.

FWait          ldy       <D.Proc             get the current process descriptor
               ldx       <D.PrcDBT           get the pointer to the process descriptor table
               lda       P$CID,y             get the child ID of this process
               bne       findchild@          branch this process has a child
               comb                          else set the carry
               ldb       #E$NoChld           and return an error that this process has no children
               rts                           return to the caller
findchild@     os9       F$Find64            find the process descriptor for the child
               lda       P$State,y           get the state value
               bita      #Dead               has the child terminated?
               bne       terminated@         branch if so
               lda       P$SID,y             else check if the child has siblings
               bne       findchild@          branch if so
               clr       R$A,u               clear the A register
               ldx       <D.Proc             get the current process descriptor
               orcc      #FIRQMask+IRQMask   mask interrupts
               ldd       <D.WProcQ           get head wait queue pointer
               std       P$Queue,x           and set the current process' queue pointer to it
               stx       <D.WProcQ           store current process at the head of the wait queue
               lbra      SetupReturn
terminated@    ldx       <D.Proc             get the current process descriptor
SignalProcess  lda       P$ID,y              get process ID in process descriptor
               ldb       <P$Signal,y         and signal in process descriptor
               std       R$A,u               save both to caller's D register
               pshs      u,y,x,a             save registers
_stk1A@        set       0
_stk1X@        set       1
_stk1Y@        set       3
_stk1U@        set       5
               leay      P$PID,x             get parent process ID
               ldx       <D.PrcDBT           and pointer to process descriptor table
               bra       looptop@            branch to the top of the search loop
* Find the process
loop@          os9       F$Find64            find the process descriptor
looptop@       lda       P$SID,y             get that process' sibling ID
               cmpa      _stk1A@,s           is it the same as the one we're looking for?
               bne       loop@               if not, go get the next one
               ldu       _stk1Y@,s           get process descriptor saved earlier on the stack
               ldb       P$SID,u             get the sibling ID from the previous process descriptor
               stb       P$SID,y             save and store it in the next sibling
               os9       F$Ret64             return the process descriptor to the free pool
               puls      pc,u,y,x,a          pull all registers and return to the caller
