* This is called when there's no signal handler.
* The process exits with signal value as exit code.
NoSigHandler        ldb       P$State,x           get process state in process descriptor
                    orb       #SysState           OR in system state flag
                    stb       P$State,x           and save it back
                    ldb       <P$Signal,x         get the signal sent to the process
                    andcc     #^(IntMasks)        unmask interrupts
                    os9       F$Exit              perform exit on this process

;;; F$NProc
;;;
;;; Execute the next process in the active process queue.
;;;
;;; Entry: None.
;;;
;;; Exit:  None. Control doesn't return to the caller.
;;;
;;; F$NProc takes the next process out of the active process queue and initiates its execution.
;;; If the queue doesn't contain a process, the kernel waits for an interrupt and then checks the
;;; queue again. The process calling F$NProc must already be in one of the three process queues.
;;; If it isn't, it becomes unknown to the system even though the process descriptor still exists
;;; and can be displayed by `procs`.

FNProc              clra                          A = 0
                    clrb                          D = $0000
                    std       <D.Proc             clear out current process descriptor pointer
                    bra       nextactive@         branch to get next active process
* Execution goes here when there are no active processes.
wait@               cwai      #^(IntMasks)        halt processor waiting for an interrupt
nextactive@         orcc      #IntMasks           mask interrupts
                    ldx       <D.AProcQ           get next active process
                    beq       wait@               CWAI if none
                    ldd       P$Queue,x           get queue ptr
                    std       <D.AProcQ           store in active queue
                    stx       <D.Proc             store in current process
                    lds       P$SP,x              get process' stack ptr
CheckState          ldb       P$State,x           get state
                    bmi       exit@               branch if system state
                    bitb      #Condem             process condemned?
                    bne       NoSigHandler        branch if so...
                    ldb       <P$Signal,x         get signal no
                    beq       restorevec@         branch if none
                    decb                          decrement
                    beq       savesig@            branch if wake up
                    ldu       <P$SigVec,x         get signal handler address
                    beq       NoSigHandler        branch if none
                    ldy       <P$SigDat,x         get data address
                    ldd       R$Y,s               get caller's Y
* Set up new return stack for RTI.
                    pshs      u,y,d               new PC (sigvec), new U (sigdat), same Y
                    ldu       6+R$X,s             old X via U
                    lda       <P$Signal,x         signal ...
                    ldb       6+R$DP,s            and old DP ...
                    tfr       d,y                 via Y
                    ldd       6+R$CC,s            old CC and A via D
                    pshs      u,y,d               same X, same DP / new B (signal), same A / CC
                    clrb                          clear B
savesig@            stb       <P$Signal,x         clear process's signal
restorevec@         ldd       <P$SWI2,x           get SWI2 vector stored in process descriptor
                    std       <D.SWI2             and restore it to system globals
                    ldd       <D.UsrIRQ           get user state IRQ vector
                    std       <D.SvcIRQ           and restore it to the main service vector
exit@               rti                           return from the interrupt

