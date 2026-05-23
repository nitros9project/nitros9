;;; F$AProc
;;;
;;; Insert process into active process queue.
;;;
;;; Entry:  X = The address of the process descriptor to insert.
;;;
;;; Exit:   None.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$AProc inserts a process into the active process queue so that the kernel can schedule the process for execution.
;;; The kernel sorts all processes in the queue by process age (the count of how many process switches have occurred
;;; since the process’s last time slice). When a process moves to the active process queue, the kernel sets its age
;;; according to its priority. The higher the priority, the higher the age.
;;;
;;; An exception is a newly active process that was deactivated while in the system state. The kernel gives such a process
;;; higher priority because it's typically executing critical routines that affect shared system resources.

                  IFEQ    Level-1 ; begin conditional assembly for Level-1

FAProc              ldx       R$X,u     ; get the pointer to process the to insert
SFAProc             pshs      u,y       ; save U/Y on stack
                    ldu       #(D.AProcQ-P$Queue) ; load U with D.AProcQ-P$Queue so we're at the first process in the queue later
                    bra       getqueue@ ; start processing the active queue
* This loop increases the age of all active processes by 1.
ageloop@            ldb       P$Age,u   ; get process age
                    incb                ; update it
                    beq       getqueue@ ; branch if wrap
                    stb       P$Age,u   ; save it back to proc desc
getqueue@           ldu       P$Queue,u ; get pointer to next process in queue
                    bne       ageloop@  ; branch if process is in active queue
                    ldu       #(D.AProcQ-P$Queue) ; load U with D.AProcQ-P$Queue so we're at the first process in the queue later
                    lda       P$Prior,x ; get process priority of process to insert
                    sta       P$Age,x   ; save it as its age
                    orcc      #IntMasks ; mask interrupts
* This loop finds the process with the age lower than our age in the queue and inserts us
* in front of them.
loop2@              leay      ,u        ; point Y to process descriptor
                    ldu       P$Queue,u ; get pointer to next process in active queue
                    beq       ex@       ; branch if empty
                    cmpa      P$Age,u   ; compare passed process' age to current in queue
                    bls       loop2@    ; if lower or same, keep going
ex@                 stu       P$Queue,x ; insert process with lower age as the next one in P$Queue of passed process
                    stx       P$Queue,y ; and put passed process descriptor pointer in current
                    clrb                ; clear carry
                    puls      pc,u,y    ; restore U/Y and return

                  ELSE

FAProc              ldx       R$X,u     ; get ptr to process to activate
FAprocTarget        clrb                ; clear B
                    pshs      cc,b,x,y,u ; save cc,b,x,y,u on the stack
                    lda       P$Prior,x ; get process priority
                    sta       P$Age,x   ; save it as age (How long it's been around)
                    orcc      #IntMasks ; shut down IRQ's
                    ldu       #(D.AProcQ-P$Queue) ; get ptr to active process queue
                    bra       FAprocProcess ; go through the chain
* Update active process queue
*  X=Process to activate
*  U=Current process in queue links
FAprocProcessAge    inc       P$Age,u   ; update current process age
                    bne       FAprocMatchProcessAges ; wrap?
                    dec       P$Age,u   ; yes, reset it to max.
FAprocMatchProcessAges cmpa      P$Age,u   ; match process ages??
                    bhi       FAprocProcessChain ; no, skip update
FAprocProcess       leay      ,u        ; point Y to current process
FAprocProcessChain  ldu       P$Queue,u ; get pointer to next process in chain
                    bne       FAprocProcessAge ; still more in chain, keep going
                    ldd       P$Queue,y ; load D from P$Queue,y
                    stx       P$Queue,y ; save new process to chain
                    std       P$Queue,x ; store D at P$Queue,x
                    puls      cc,b,x,y,u,pc ; restore cc,b,x,y,u,pc from the stack

                  ENDC
