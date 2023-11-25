;; F$Sleep
;;;
;;; Suspend the calling process and put it in the sleep queue.
;;;
;;; Entry:  X = The number of ticks to sleep.
;;;
;;; Exit:   X = The requested ticks to sleep minus the number of ticks the process slept.
;;;        CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; If X contains 0, the kernel puts the process to sleep until it receives a signal. Putting a process to sleep
;;; is the correct way to wait for a signal or interrupt without wasting CPU time.
;;;
;;; If X contains 1, the kernel puts the process to sleep for the remainder of its current time slice. The kernel
;;; inserts the process into the active process queue immediately. The process resumes execution when it reaches the
;;; front of the queue.
;;;
;;; If X contains any other value, the kernel puts the process to for the specified number of ticks. The kernel
;;; inserts the process into the active process queue after the second to last tick. The process resumes execution
;;; when it reaches the front of the queue.
;;;
;;; If the process receives a signal, it awakens before the time has elapsed. When you select processes among
;;; multiple windows, you might need to sleep for two ticks.

               ifeq      Level-1

FSleep         ldx       <D.Proc             get the process descriptor
               orcc      #FIRQMask+IRQMask   mask interrupts
               lda       P$Signal,x          get the process' signal
               beq       nosig@              branch if there is no signal
               deca                          else decrement the signal number
               bne       activate@           branch if not 0 (S$Wake)
               sta       P$Signal,x          clear the process' signal
activate@      os9       F$AProc             insert into the active queue
               bra       SetupReturn         and set up the return step
nosig@         ldd       R$X,u               get the passed timeout
               beq       sleepforever@       branch if 0 (sleep forever)
               subd      #$0001              else subtract 1
               std       R$X,u               save back to caller
               beq       activate@           branch if 0 (sleep for the remainder of the timeslice)
               pshs      u,x                 save these registers
               ldx       #(D.SProcQ-P$Queue) position X so that the next access is at the sleep queue head
loop@          leay      ,x                  point Y to X
               ldx       P$Queue,x           get the next queue pointer
               beq       eoq@                branch if zero (at the end of the queue)
               pshs      b,a                 save the tick count
               lda       P$State,x           get the state of the process (ONLY NEED TO PUSH A)
               bita      #TimSleep           is this process already asleep?
               puls      b,a                 restore the tick count (ONLY NEED TO PULL A)
               beq       eoq@                branch if the timed sleep flag was clear
               ldu       P$SP,x              else get the process' stack pointer in U
               subd      R$X,u               get the difference in ticks slept
               bcc       loop@               branch if >= 0
               addd      R$X,u               else add it back
eoq@           puls      u,x                 recover the registers saved earlier
               std       R$X,u               save the tick count back to the caller
* Insert the process descriptor in X in front of the process descriptor in D
               ldd       P$Queue,y           get the previous queue entry
               stx       P$Queue,y           store the current queue entry in front
               std       P$Queue,x           and the previous queue entry after
               lda       P$State,x           get the process' state byte
               ora       #TimSleep           set the timed sleep flag
               sta       P$State,x           save it back
               ldx       P$Queue,x           get the next process in the queue
               beq       SetupReturn         branch if we're at the end
               lda       P$State,x           get the process' state byte
               bita      #TimSleep           test for the timed sleep flag
               beq       SetupReturn         branch if clear (this process isn't sleeping)
               ldx       P$SP,x              else get the process' stack pointer
               ldd       P$SP,x              get the stack pointer there
               subd      R$X,u               subtract the caller's X
               std       P$SP,x              and store the stack pointer
               bra       SetupReturn         prepare to return
sleepforever@  lda       P$State,x           get the process' state byte
               anda      #^TimSleep          turn off the timed sleep flag
               sta       P$State,x           save it back
               ldd       #(D.SProcQ-P$Queue) position XDso that the next access is at the sleep queue head
loop2@         tfr       d,y                 copy the process descriptor pointer to Y
               ldd       P$Queue,y           get the next queue entry
               bne       loop2@              branch if we're not at the end
               stx       P$Queue,y           store this process descriptor at the end of the queue
               std       P$Queue,x           and terminate it (D = $0000)
SetupReturn    leay      <callreturn@,pcr    point to the return code
               pshs      y                   save the pointer as the program counter on the return stack
               ldy       <D.Proc             get the current process descriptor
               ldd       P$SP,y              and get the stack pointer
               ldx       R$X,u               get the caller's X
               ifne      H6309
*>>>>>>>>>> H6309
               pshs      u,y,x,dp            push 6809 registers
               pshsw                         then the 6309 W
               pshs      b,a,cc              then the rest
*<<<<<<<<<< H6309
               else
*>>>>>>>>>> M6809
               pshs      u,y,x,dp,b,a,cc     push registers on the stack
*<<<<<<<<<< M6809
               endc
               sts       P$SP,y              save the stack pointer
               os9       F$NProc             execute the next process in the active queue
callreturn@    std       P$SP,y              save off the stack pointer
               stx       R$X,u               and the updated tick count
               clrb                          clear the carry
               rts                           return to the caller

               else

FSleep         pshs      cc                  preserve interupt status
               ldx       <D.Proc             Get current process pointer

* F$Sleep bug fix.  Check if we're in system state.  If so return because you
* should never sleep in system state.
               cmpx      <D.SysPrc           is it system process?
               beq       SkpSleep            skip sleep call
               orcc      #IntMasks           disable interupts
               lda       P$Signal,x          get pending signal
               beq       L0722               none there, skip ahead
               deca                          wakeup signal?
               bne       L0715               no, skip ahead
               sta       P$Signal,x          clear pending signal so we can wake up process
L0715
               ifne      H6309
               aim       #^Suspend,P$State,x
               else
               lda       P$State,x
               anda      #^Suspend
               sta       P$State,x
               endc
L071B          puls      cc
               os9       F$AProc             activate the process
               bra       L0780
L0722          ldd       R$X,u               get callers X (contains sleep tick count)
               beq       L076D               done, wake it up
               ifne      H6309
               decd                          subtract 1 from tick count
               else
               subd      #$0001
               endc
               std       R$X,u               save it back
               beq       L071B               zero, wake up process
               pshs      x,y
               ldx       #(D.SProcQ-P$Queue)
L0732          std       R$X,u
               stx       2,s
               ldx       P$Queue,x
               beq       L074F
               ifne      H6309
               tim       #TimSleep,P$State,x
               else
               lda       P$State,x
               bita      #TimSleep
               endc
               beq       L074F
               ldy       P$SP,x              get process stack pointer
               ldd       R$X,u
               subd      R$X,y
               bcc       L0732
               ifne      H6309
               negd
               else
               nega
               negb
               sbca      #0
               endc
               std       R$X,y
L074F          puls      y,x
               ifne      H6309
               oim       #TimSleep,P$State,x
               else
               lda       P$State,x
               ora       #TimSleep
               sta       P$State,x
               endc
               ldd       P$Queue,y
               stx       P$Queue,y
               std       P$Queue,x
               ldx       R$X,u
               bsr       L0780
               stx       R$X,u
               ldx       <D.Proc
               ifne      H6309
               aim       #^TimSleep,P$State,x
               else
               lda       P$State,x
               anda      #^TimSleep
               sta       P$State,x
               endc
SkpSleep       puls      cc,pc

L076D          ldx       #D.SProcQ-P$Queue
L0770          leay      ,x
               ldx       P$Queue,x
               bne       L0770
               ldx       <D.Proc
               clra
               clrb
               stx       P$Queue,y
               std       P$Queue,x
               puls      cc

L0780          pshs      dp,x,y,u,pc
L0782          leax      <L079C,pc
               stx       7,s
               ldx       <D.Proc
               ldb       P$Task,x            This is related to the 'one-byte hack'
               cmpb      <D.SysTsk           that stops OS9p1 from doing an F$AllTsk on
               beq       L0792               _every_ system call.
               os9       F$DelTsk
L0792          ldd       P$SP,x
               ifne      H6309
               pshsw
               endc
               pshs      cc,d
               sts       P$SP,x
               os9       F$NProc

L079C          pshs      x
               ldx       <D.Proc
               std       P$SP,x
               clrb
               puls      x,pc

               endc