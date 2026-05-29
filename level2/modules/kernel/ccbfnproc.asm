**************************************************
* System Call: F$NProc
*
* Function: Start the next process in the active queue
*
* Input:  None
*
* Output: Control does not return to the caller
*
FNProc
                  IFGT    Level-1 ; begin conditional assembly for Level-1
                    ldx       <D.SysPrc ; get system process descriptor
                    stx       <D.Proc   ; save it as current
                    lds       <D.SysStk ; get system stack pointer
                    andcc     #^IntMasks ; re-enable IRQ's (to allow pending one through)
                  ELSE
                    clra                ; clear A
                    clrb                ; clear B
                    std       <D.Proc   ; store D at <D.Proc
                  ENDC
                    fcb       $8C       ; skip the next 2 bytes

FNprocReEnblIrqs    cwai      #^IntMasks ; re-enable IRQ's and wait for one
FNprocShutOffInts   orcc      #IntMasks ; shut off interrupts again
                    lda       #Suspend  ; get suspend suspend state flag
                    ldx       #D.AProcQ-P$Queue ; for start of loop, setup to point to current process

* Loop to find next active process that is not Suspended
FNprocPrvsLinkProc  leay      ,x        ; point y to previous link (process dsc. ptr)
                    ldx       P$Queue,y ; get process dsc. ptr for next active process
                    beq       FNprocReEnblIrqs ; none, allow any pending IRQ thru & try again
                    bita      P$State,x ; there is one, is it Suspended?
                    bne       FNprocPrvsLinkProc ; yes, skip it & try next one

* Found a process in line ready to be started
                    ldd       P$Queue,x ; get next process dsc. ptr in line after found one
                    std       P$Queue,y ; save the next one in line in previous' next ptr
                    stx       <D.Proc   ; make new process dsc. the current one
                    lbsr      FAlltskHasHaveTask ; go check or make a task # for the found process
                    bcs       KrnActivateProcess ; couldn't get one, go to next process in line
                    lda       <D.TSlice ; reload # ticks this process can run
                    sta       <D.Slice  ; save as new tick counter for process
                    ldu       P$SP,x    ; get the process stack pointer
                    lda       P$State,x ; get it's state
                    lbmi      KrnFrcSysTask ; if in System State, switch to system task (0)
FNprocCndmnByDdly   bita      #Condem   ; was it condemned by a deadly signal?
                    bne       FNprocJoin2 ; yes, go exit with Error=the signal code #
                    lbsr      TstImg    ; do a F$SetTsk if the ImgChg flag is set
FNprocSignals       ldb       <P$Signal,x ; any signals?
                    beq       FNprocJoin ; no, go on
                    decb                ; is it a wake up signal?
                    beq       FNprocSignal ; yes, go wake it up
                    leas      -R$Size,s ; make a register buffer on stack
                    leau      ,s        ; point to it
                    lbsr      CpUsrStkTo ; copy the stack from process to our copy of it
                    lda       <P$Signal,x ; get last signal
                    sta       R$B,u     ; save it to process' B

                    ldd       <P$SigVec,x ; any intercept trap?
                    beq       FNprocJoin2 ; no, go force the process to F$Exit
                    std       R$PC,u    ; save vector to it's PC
                    ldd       <P$SigDat,x ; get pointer to intercept data area
                    std       R$U,u     ; save it to it's U
                    ldd       P$SP,x    ; get it's stack pointer
                    subd      #R$Size   ; take off register stack
                    std       P$SP,x    ; save updated SP
                    lbsr      CpSysStkTo ; copy modified stack back overtop process' stack
                    leas      R$Size,s  ; purge temporary stack
FNprocSignal        clr       <P$Signal,x ; clear the signal

* No signals go here
FNprocJoin          equ       *         ; define assembler symbol FNprocJoin
                  IFNE    H6309   ; begin conditional assembly for H6309
                    oim       #$01,<D.Quick ; apply immediate bit operation #$01,<D.Quick
                  ELSE
                    ldb       <D.Quick  ; load B from <D.Quick
                    orb       #$01      ; merge #$01 into B
                    stb       <D.Quick  ; store B at <D.Quick
                  ENDC
BackTo1             equ       *         ; define assembler symbol BackTo1
FNprocUsrsSysCall   ldu       <D.UsrSvc ; get current User's system call service routine ptr
                    stu       <D.XSWI2  ; save as SWI2 service routine ptr
                    ldu       <D.UsrIRQ ; get IRQ entry point for user state
                    stu       <D.XIRQ   ; save as IRQ service routine ptr

                    ldb       P$Task,x  ; get task number
                    lslb                ; 2 bytes per entry in D.TskIpt
                    ldy       P$SP,x    ; get stack pointer
                    lbsr      KrnWeGngBack ; re-map the DAT image, if necessary

                    ldb       <D.Quick  ; get quick return flag
                    lbra      KrnJoin2  ; go switch GIME over to new process & run

* Process a signal (process had no signal trap)
FNprocJoin2         equ       *         ; define assembler symbol FNprocJoin2
                  IFNE    H6309   ; begin conditional assembly for H6309
                    oim       #SysState,P$State,x ; put process into system state
                  ELSE
                    ldb       P$State,x ; load B from P$State,x
                    orb       #SysState ; merge #SysState into B
                    stb       P$State,x ; store B at P$State,x
                  ENDC
                    leas      >P$Stack,x ; point SP to process' stack
                    andcc     #^IntMasks ; turn interrupts on
                    ldb       <P$Signal,x ; get signal that process received
                    clr       <P$Signal,x ; clear out the one in process dsc.
                    os9       F$Exit    ; exit with signal # being error code

S.SvcIRQ            jmp       [>D.Poll] ; call IOMAN for IRQ polling
