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

                  IFEQ    Level-1 ; begin conditional assembly for Level-1

FSleep              ldx       <D.Proc   ; get the process descriptor
                    orcc      #FIRQMask+IRQMask ; mask interrupts
                    lda       P$Signal,x ; get the process' signal
                    beq       nosig@    ; branch if there is no signal
                    deca                ; else decrement the signal number
                    bne       activate@ ; branch if not 0 (S$Wake)
                    sta       P$Signal,x ; clear the process' signal
activate@           os9       F$AProc   ; insert into the active queue
                    bra       SetupReturn ; and set up the return step
nosig@              ldd       R$X,u     ; get the passed timeout
                    beq       sleepforever@ ; branch if 0 (sleep forever)
                    subd      #$0001    ; else subtract 1
                    std       R$X,u     ; save back to caller
                    beq       activate@ ; branch if 0 (sleep for the remainder of the timeslice)
                    pshs      u,x       ; save these registers
                    ldx       #(D.SProcQ-P$Queue) ; position X so that the next access is at the sleep queue head
loop@               leay      ,x        ; point Y to X
                    ldx       P$Queue,x ; get the next queue pointer
                    beq       eoq@      ; branch if zero (at the end of the queue)
                    pshs      b,a       ; save the tick count
                    lda       P$State,x ; get the state of the process (ONLY NEED TO PUSH A)
                    bita      #TimSleep ; is this process already asleep?
                    puls      b,a       ; restore the tick count (ONLY NEED TO PULL A)
                    beq       eoq@      ; branch if the timed sleep flag was clear
                    ldu       P$SP,x    ; else get the process' stack pointer in U
                    subd      R$X,u     ; get the difference in ticks slept
                    bcc       loop@     ; branch if >= 0
                    addd      R$X,u     ; else add it back
eoq@                puls      u,x       ; recover the registers saved earlier
                    std       R$X,u     ; save the tick count back to the caller
* Insert the process descriptor in X in front of the process descriptor in D
                    ldd       P$Queue,y ; get the previous queue entry
                    stx       P$Queue,y ; store the current queue entry in front
                    std       P$Queue,x ; and the previous queue entry after
                    lda       P$State,x ; get the process' state byte
                    ora       #TimSleep ; set the timed sleep flag
                    sta       P$State,x ; save it back
                    ldx       P$Queue,x ; get the next process in the queue
                    beq       SetupReturn ; branch if we're at the end
                    lda       P$State,x ; get the process' state byte
                    bita      #TimSleep ; test for the timed sleep flag
                    beq       SetupReturn ; branch if clear (this process isn't sleeping)
                    ldx       P$SP,x    ; else get the process' stack pointer
                    ldd       P$SP,x    ; get the stack pointer there
                    subd      R$X,u     ; subtract the caller's X
                    std       P$SP,x    ; and store the stack pointer
                    bra       SetupReturn ; prepare to return
sleepforever@       lda       P$State,x ; get the process' state byte
                    anda      #^TimSleep ; turn off the timed sleep flag
                    sta       P$State,x ; save it back
                    ldd       #(D.SProcQ-P$Queue) ; position XDso that the next access is at the sleep queue head
loop2@              tfr       d,y       ; copy the process descriptor pointer to Y
                    ldd       P$Queue,y ; get the next queue entry
                    bne       loop2@    ; branch if we're not at the end
                    stx       P$Queue,y ; store this process descriptor at the end of the queue
                    std       P$Queue,x ; and terminate it (D = $0000)
SetupReturn         leay      <callreturn@,pcr ; point to the return code
                    pshs      y         ; save the pointer as the program counter on the return stack
                    ldy       <D.Proc   ; get the current process descriptor
                    ldd       P$SP,y    ; and get the stack pointer
                    ldx       R$X,u     ; get the caller's X
                  IFNE    H6309   ; begin conditional assembly for H6309
*[[[ H6309
                    pshs      u,y,x,dp  ; push 6809 registers
                    pshsw     then      the 6309 W
                    pshs      b,a,cc    ; then the rest
*]]] H6309
                  ELSE
*[[[ M6809
                    pshs      u,y,x,dp,b,a,cc ; push registers on the stack
*]]] M6809
                  ENDC
                    sts       P$SP,y    ; save the stack pointer
                    os9       F$NProc   ; execute the next process in the active queue
callreturn@         std       P$SP,y    ; save off the stack pointer
                    stx       R$X,u     ; and the updated tick count
                    clrb                ; clear the carry
                    rts                 ; return to the caller

                  ELSE

FSleep              pshs      cc        ; preserve interupt status
                    ldx       <D.Proc   ; get current process pointer

* F$Sleep bug fix.  Check if we're in system state.  If so return because you
* should never sleep in system state.
                    cmpx      <D.SysPrc ; is it system process?
                    beq       SkpSleep  ; skip sleep call
                    orcc      #IntMasks ; disable interupts
                    lda       P$Signal,x ; get pending signal
                    beq       FSleepHasSlpTick ; none there, skip ahead
                    deca                ; wakeup signal?
                    bne       WakeFromSignal ; no, skip ahead
                    sta       P$Signal,x ; clear pending signal so we can wake up process
WakeFromSignal
                  IFNE    H6309   ; begin conditional assembly for H6309
                    aim       #^Suspend,P$State,x
                  ELSE
                    lda       P$State,x ; load A from P$State,x
                    anda      #^Suspend ; mask A with #^Suspend
                    sta       P$State,x ; store A at P$State,x
                  ENDC
FSleepTarget        puls      cc        ; restore cc from the stack
                    os9       F$AProc   ; activate the process
                    bra       FSleepTarget4 ; branch unconditionally to FSleepTarget4
FSleepHasSlpTick    ldd       R$X,u     ; get callers X (contains sleep tick count)
                    beq       FSleepDsprocqPqueue ; done, wake it up
                  IFNE    H6309   ; begin conditional assembly for H6309
                    decd      subtract  1 from tick count
                  ELSE
                    subd      #$0001    ; subtract #$0001 from D
                  ENDC
                    std       R$X,u     ; save it back
                    beq       FSleepTarget ; zero, wake up process
                    pshs      x,y       ; save x,y on the stack
                    ldx       #(D.SProcQ-P$Queue) ; load X from #(D.SProcQ-P$Queue)
FSleepRx            std       R$X,u     ; store D at R$X,u
                    stx       2,s       ; store X at 2,s
                    ldx       P$Queue,x ; load X from P$Queue,x
                    beq       FSleepTarget2 ; branch if zero is set to FSleepTarget2
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tim       #TimSleep,P$State,x
                  ELSE
                    lda       P$State,x ; load A from P$State,x
                    bita      #TimSleep ; test bits in A against #TimSleep
                  ENDC
                    beq       FSleepTarget2 ; branch if zero is set to FSleepTarget2
                    ldy       P$SP,x    ; get process stack pointer
                    ldd       R$X,u     ; load D from R$X,u
                    subd      R$X,y     ; subtract R$X,y from D
                    bcc       FSleepRx  ; branch if carry is clear to FSleepRx
                  IFNE    H6309   ; begin conditional assembly for H6309
                    negd                ; update processor state
                  ELSE
                    nega                ; update processor state
                    negb                ; update processor state
                    sbca      #0        ; update processor state
                  ENDC
                    std       R$X,y     ; store D at R$X,y
FSleepTarget2       puls      y,x       ; restore y,x from the stack
                  IFNE    H6309   ; begin conditional assembly for H6309
                    oim       #TimSleep,P$State,x
                  ELSE
                    lda       P$State,x ; load A from P$State,x
                    ora       #TimSleep ; merge #TimSleep into A
                    sta       P$State,x ; store A at P$State,x
                  ENDC
                    ldd       P$Queue,y ; load D from P$Queue,y
                    stx       P$Queue,y ; store X at P$Queue,y
                    std       P$Queue,x ; store D at P$Queue,x
                    ldx       R$X,u     ; load X from R$X,u
                    bsr       FSleepTarget4 ; call local routine FSleepTarget4
                    stx       R$X,u     ; store X at R$X,u
                    ldx       <D.Proc   ; load X from <D.Proc
                  IFNE    H6309   ; begin conditional assembly for H6309
                    aim       #^TimSleep,P$State,x
                  ELSE
                    lda       P$State,x ; load A from P$State,x
                    anda      #^TimSleep ; mask A with #^TimSleep
                    sta       P$State,x ; store A at P$State,x
                  ENDC
SkpSleep            puls      cc,pc     ; restore cc,pc from the stack

FSleepDsprocqPqueue ldx       #D.SProcQ-P$Queue ; load X from #D.SProcQ-P$Queue
FSleepTarget3       leay      ,x        ; compute ,x into Y
                    ldx       P$Queue,x ; load X from P$Queue,x
                    bne       FSleepTarget3 ; branch if zero is clear to FSleepTarget3
                    ldx       <D.Proc   ; load X from <D.Proc
                    clra                ; clear A
                    clrb                ; clear B
                    stx       P$Queue,y ; store X at P$Queue,y
                    std       P$Queue,x ; store D at P$Queue,x
                    puls      cc        ; restore cc from the stack

FSleepTarget4       pshs      dp,x,y,u,pc ; save dp,x,y,u,pc on the stack
FSleepL079c         leax      <FSleepTarget5,pc ; compute <FSleepTarget5,pc into X
                    stx       7,s       ; store X at 7,s
                    ldx       <D.Proc   ; load X from <D.Proc
                    ldb       P$Task,x  ; this is related to the 'one-byte hack'
                    cmpb      <D.SysTsk ; that stops OS9p1 from doing an F$AllTsk on
                    beq       FSleepPsp ; _every_ system call.
                    os9       F$DelTsk  ; call OS-9 service F$DelTsk
FSleepPsp           ldd       P$SP,x    ; load D from P$SP,x
                  IFNE    H6309   ; begin conditional assembly for H6309
                    pshsw
                  ENDC
                    pshs      cc,d      ; save cc,d on the stack
                    sts       P$SP,x    ; store S at P$SP,x
                    os9       F$NProc   ; call OS-9 service F$NProc

FSleepTarget5       pshs      x         ; save x on the stack
                    ldx       <D.Proc   ; load X from <D.Proc
                    std       P$SP,x    ; store D at P$SP,x
                    clrb                ; clear B
                    puls      x,pc      ; restore x,pc from the stack

                  ENDC
