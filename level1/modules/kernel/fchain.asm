;;; F$Chain
;;;
;;; Links or loads a module and replaces the calling process.
;;;
;;; Entry:  A = The type/language byte.
;;;         B = Size of the optional data area (in pages).
;;;         X = Address of the module name or filename.
;;;         Y = Size of the parameter area (in pages). The default is 0.
;;;         U = Starting address of the parameter area. This must be at least one page.
;;;
;;; Exit:   None.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$Chain loads and executes a new primary module, but doesn't create a new process. F$Chain is similar to F$Fork followed
;;; by F$Exit, but has less processing overhead. F$Chain resets the calling process' program and data memory areas, then begins
;;;
;;; F$Chain unlinks the process’ old primary module, then parses the name of the new process’ primary module  It searches the system module
;;; directory for module with the same name, type, and language already in memory.
;;; If the module is in memory, F$Chain links to it. If the module isn't in memory, F$Chain uses the name string as the pathlist
;;; of a file to load into memory. Then, it links to the first module in this file. (Several modules can be loaded from a single file.)
;;;
;;; F$Chain then reconfigures the data memory area to the size specified in the new primary module’s header. Finally, it intercepts
;;; and erases any pending signals.

* F$Chain user state entry point.
FChain              bsr       DoChain             do the F$Chain
                    bcs       chainerr@           branch if error
                    orcc      #IntMasks           mask interrupts
                    ldb       P$State,x           get process state
                    andb      #^SysState          turn off system state
                    stb       P$State,x           save new state
actproc@            os9       F$AProc             add it to active process queue
                    os9       F$NProc             activate it
* F$Chain system state entry point.
SFChain             bsr       DoChain             do the F$Chain
                    bcc       actproc@            branch if OK
chainerr@           pshs      b                   save off B for now
                    stb       <P$Signal,x         save off error code
                    ldb       P$State,x           get process state
                    orb       #Condem             set the condemn bit
                    stb       P$State,x           save new state
                    ldb       #255                get highest priority
                    stb       P$Prior,x           set priority
                    comb                          set carry
                    puls      pc,b                return error
DoChain             pshs      u                   save off caller's SP
                    ldx       <D.Proc             get current process descriptor
                    ldu       <P$PModul,x         get pointer to module for current process
                    os9       F$UnLink            unlink the module
                    ldu       ,s                  get saved caller's SP
                    bsr       SetupPrc            create new child process
                    puls      pc,u                recover U and return

SetupPrc            ldx       <D.Proc             get current process descriptor
                    pshs      u,x                 save off
                    ldd       <D.UsrSvc           get user service table
                    std       <P$SWI,x            save off as process' SWI vector
                    std       <P$SWI2,x           ... and SWI2 vector
                    std       <P$SWI3,x           ... and SWI3 vector
                    clra                          A = 0
                    clrb                          D = 0
                    sta       <P$Signal,x         clear the signal
                    std       <P$SigVec,x         clear signal vector
                    lda       R$A,u               get caller's A
                    ldx       R$X,u               ... and X
                    os9       F$Link              link the module to chain to
                    bcc       chktype@            branch if OK
                    os9       F$Load              ... else load the module to chain to
                    bcs       ex@                 ... and branch if error
chktype@            ldy       <D.Proc             get current process
                    stu       <P$PModul,y         save off module pointer
                    cmpa      #Prgrm+Objct        is this a program module?
                    beq       cmpmem@             branch if so
                    cmpa      #Systm+Objct        is it a system module?
                    beq       cmpmem@             branch if so
                    comb                          else set carry
                    ldb       #E$NEMod            set error in B
                    bra       ex@                 and return
cmpmem@             leay      ,u                  Y = address of module
                    ldu       2,s                 get U off stack (caller regs)
                    stx       R$X,u               update X to point past name
                    lda       R$B,u               get caller's requested memory size in 256 byte pages
                    clrb                          clear lower 8 bits of D
                    cmpd      M$Mem,y             compare passed memory to module's
                    bcc       alloc@              branch if requested amount is the same or greater than the module's memory
                    ldd       M$Mem,y             else load D with module's memory
alloc@              addd      #$0000              is this needed??
                    bne       allcmem@            and this???
allcmem@            os9       F$Mem               allocate requested memory
                    bcs       ex@                 branch if error
                    subd      #R$Size             subtract registers
                    subd      R$Y,u               subtract parameter area
                    bcs       badfork@            branch if < 0
                    ldx       R$U,u               get parameter area
                    ldd       R$Y,u               get parameter size
                    pshs      b,a                 save onto the stack
                    beq       setregs@            branch if parameter area is zero (nothing to copy)
                    leax      d,x                 point to end of param area
loop@               lda       ,-x                 get parameter byte and decrement X
                    sta       ,-y                 save byte in data area and decrement Y
                    cmpx      R$U,u               at top of parameter area?
                    bhi       loop@               branch if not
* Set up registers for return of F$Fork/F$Chain.
setregs@            ldx       <D.Proc             get pointer to current process descriptor
                    sty       -R$Size+R$X,y       put in X on caller stack
                    leay      -R$Size,y           back up the size of the register file
                    sty       P$SP,x              save Y as the stack pointer
                    lda       P$ADDR,x            get the starting page number
                    clrb                          clear lower 8 bits of D
                    std       R$U,y               save it as the lowest address in the caller's U
                    sta       R$DP,y              and set direct page in the caller's DP
                    adda      P$PagCnt,x          add the memory page count
                    std       R$Y,y               store it in the caller's Y
                    puls      b,a                 recover the size of the parameter area
                    std       R$D,y               and store it in the caller's D
                    ldb       #Entire             set the entire flag
                    stb       R$CC,y              in the caller's CC
                    ldu       <P$PModul,x         get the address of the primary module
                    ldd       M$Exec,u            get the execution offset
                    leau      d,u                 point U to that
                    stu       R$PC,y              put that offset in the caller's PC
                    clrb                          B = 0
badfork@            ldb       #E$IForkP           illegal fork parameter
ex@                 puls      pc,u,x              return to caller
