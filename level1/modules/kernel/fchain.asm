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

                  IFEQ    Level-1 ; begin conditional assembly for Level-1

* F$Chain user state entry point.
FChain              bsr       DoChain   ; do the F$Chain
                    bcs       chainerr@ ; branch if error
                    orcc      #IntMasks ; mask interrupts
                    ldb       P$State,x ; get process state
                    andb      #^SysState ; turn off system state
                    stb       P$State,x ; save new state
resched@            ldu       <P$PModul,x ; get pointer to the module for the current process
                    os9       F$Unlink  ; unlink it
                    os9       F$AProc   ; add it to active process queue
                    os9       F$NProc   ; activate it
* F$Chain system state entry point.
SFChain             bsr       DoChain   ; do the F$Chain
                    bcc       resched@  ; branch if OK
chainerr@           pshs      b         ; save off B for now
                    stb       <P$Signal,x ; save off error code
                    ldb       P$State,x ; get process state
                    orb       #Condem   ; set the condemn bit
                    stb       P$State,x ; save new state
                    ldb       #255      ; get highest priority
                    stb       P$Prior,x ; set priority
                    comb                ; set carry
                    puls      pc,b      ; return error
DoChain             pshs      u         ; save off caller's SP
                    ldx       <D.Proc   ; get current process descriptor
                    ldu       ,s        ; get saved caller's SP
                    bsr       SetupPrc  ; create new child process
                    puls      pc,u      ; recover U and return

SetupPrc            ldx       <D.Proc   ; get current process descriptor
                    pshs      u,x       ; save off
                    ldd       <D.UsrSvc ; get user service table
                    std       <P$SWI,x  ; save off as process' SWI vector
                    std       <P$SWI2,x ; ... and SWI2 vector
                    std       <P$SWI3,x ; ... and SWI3 vector
                    clra                ; A = 0
                    clrb                ; D = 0
                    sta       <P$Signal,x ; clear the signal
                    std       <P$SigVec,x ; clear signal vector
                    lda       R$A,u     ; get caller's A
                    ldx       R$X,u     ; ... and X
                    os9       F$Link    ; link the module to chain to
                    bcc       chktype@  ; branch if OK
                    os9       F$Load    ; ... else load the module to chain to
                    bcs       ex@       ; ... and branch if error
chktype@            ldy       <D.Proc   ; get current process
                    stu       <P$PModul,y ; save off module pointer
                    cmpa      #Prgrm+Objct ; is this a program module?
                    beq       cmpmem@   ; branch if so
                    cmpa      #Systm+Objct ; is it a system module?
                    beq       cmpmem@   ; branch if so
                    comb                ; else set carry
                    ldb       #E$NEMod  ; set error in B
                    bra       ex@       ; and return
cmpmem@             leay      ,u        ; Y = address of module
                    ldu       2,s       ; get U off stack (caller regs)
                    stx       R$X,u     ; update X to point past name
                    lda       R$B,u     ; get caller's requested memory size in 256 byte pages
                    clrb                ; clear lower 8 bits of D
                    cmpd      M$Mem,y   ; compare passed memory to module's
                    bcc       alloc@    ; branch if requested amount is the same or greater than the module's memory
                    ldd       M$Mem,y   ; else load D with module's memory
alloc@              addd      #$0000    ; is this needed??
                    bne       allcmem@  ; and this???
allcmem@            os9       F$Mem     ; allocate requested memory
                    bcs       ex@       ; branch if error
                    subd      #R$Size   ; subtract registers
                    subd      R$Y,u     ; subtract parameter area
                    bcs       badfork@  ; branch if < 0
                    ldx       R$U,u     ; get parameter area
                    ldd       R$Y,u     ; get parameter size
                    pshs      b,a       ; save onto the stack
                    beq       setregs@  ; branch if parameter area is zero (nothing to copy)
                    leax      d,x       ; point to end of param area
loop@               lda       ,-x       ; get parameter byte and decrement X
                    sta       ,-y       ; save byte in data area and decrement Y
                    cmpx      R$U,u     ; at top of parameter area?
                    bhi       loop@     ; branch if not
* Set up registers for return of F$Fork/F$Chain.
setregs@            ldx       <D.Proc   ; get pointer to current process descriptor
                    sty       -R$Size+R$X,y ; put in X on caller stack
                    leay      -R$Size,y ; back up the size of the register file
                    sty       P$SP,x    ; save Y as the stack pointer
                    lda       P$ADDR,x  ; get the starting page number
                    clrb                ; clear lower 8 bits of D
                    std       R$U,y     ; save it as the lowest address in the caller's U
                    sta       R$DP,y    ; and set direct page in the caller's DP
                    adda      P$PagCnt,x ; add the memory page count
                    std       R$Y,y     ; store it in the caller's Y
                    puls      b,a       ; recover the size of the parameter area
                    std       R$D,y     ; and store it in the caller's D
                    ldb       #Entire   ; set the entire flag
                    stb       R$CC,y    ; in the caller's CC
                    ldu       <P$PModul,x ; get the address of the primary module
                    ldd       M$Exec,u  ; get the execution offset
                    leau      d,u       ; point U to that
                    stu       R$PC,y    ; put that offset in the caller's PC
                    clrb                ; B = 0
badfork@            ldb       #E$IForkP ; illegal fork parameter
ex@                 puls      pc,u,x    ; return to caller

                  ELSE

FChain              pshs      u         ; preserve register stack pointer
                    lbsr      AllPrc    ; allocate a new process descriptor
                    bcc       FChainProcess ; do the chain if no error
                    puls      u,pc      ; return to caller with error

* Copy Process Descriptor Data
FChainProcess       ldx       <D.Proc   ; get pointer to current process
                    pshs      x,u       ; save old & new descriptor pointers
                  IFNE    H6309   ; begin conditional assembly for H6309
                    leax      P$SP,x    ; point to source
                    leau      P$SP,u    ; point to destination
                    ldw       #$00fc    get size (P$SP+$FC)
                    tfm       x+,u+     move it
                  ELSE
*
* LCB Proposed new 6809 code approx 750 cycles faster
* Appears to work (boot calls F$Chain twice).
                    leay      P$SP,u    ; point to destination
                    leau      P$SP,x    ; point to source
                    ldb       #84       ; # of 3 byte sets to copy
FChainBytes         pulu      a,x       ; get 3 bytes
                    sta       ,y+       ; copy them
                    stx       ,y++      ; store X at ,y++
                    decb                ; dec 3 byte ctr
                    bne       FChainBytes ; branch if zero is clear to FChainBytes
                  ENDC
FChainNewDescriptor ldu       2,s       ; get new descriptor pointer
                    leau      <P$DATImg,u ; compute <P$DATImg,u into U
                    ldx       ,s        ; get old descriptor pointer
                    lda       P$Task,x  ; get task #
                    lsla                ; 2 bytes per entry
                    ldx       <D.TskIpt ; get task image table pointer
                    stu       a,x       ; save updated DAT image pointer for later
* Question: are the previous 7 lines necessary? The F$AllTsk call, below
* should take care of everything!
                    ldx       <D.Proc   ; get process descriptor
                  IFNE    H6309   ; begin conditional assembly for H6309
                    clrd                ; faster than 2 memory clears
                  ELSE
                    clra                ; clear A
                    clrb                ; clear B
                  ENDC
                    stb       P$Task,x  ; old process has no task number
                    std       <P$SWI,x  ; clear out all sorts of signals and vectors
                    std       <P$SWI2,x ; store D at <P$SWI2,x
                    std       <P$SWI3,x ; store D at <P$SWI3,x
                    sta       <P$Signal,x ; store A at <P$Signal,x
                    std       <P$SigVec,x ; store D at <P$SigVec,x
                    ldu       <P$PModul,x ; load U from <P$PModul,x
                    os9       F$UnLink  ; unlink from the primary module
                    ldb       P$PagCnt,x ; grab the page count
                    addb      #$1F      ; round up to the nearest block
                    lsrb                ; shift or rotate and update condition codes
                    lsrb                ; shift or rotate and update condition codes
                    lsrb                ; shift or rotate and update condition codes
                    lsrb                ; shift or rotate and update condition codes
                    lsrb                ; get number of blocks used
                    lda       #$08      ; load A from #$08
                  IFNE    H6309   ; begin conditional assembly for H6309
                    subr      b,a       A=number of blocks unused
                  ELSE
                    pshs      b         ; save b on the stack
                    suba      ,s+       ; subtract ,s+ from A
                  ENDC
                    leay      <P$DATImg,x ; set up the initial DAT image
                    lslb                ; shift or rotate and update condition codes
                    leay      b,y       ; go to the offset
                    ldu       #DAT.Free ; mark the blocks as free
FChainThem          stu       ,y++      ; do all of them
                    deca                ; decrement A
                    bne       FChainThem ; branch if zero is clear to FChainThem
                    ldu       2,s       ; get new process descriptor pointer
                    stu       <D.Proc   ; make it the new process
                    ldu       4,s       ; load U from 4,s
                    lbsr      FChainEverything ; link to new module & setup register stack
                  IFNE    H6309   ; begin conditional assembly for H6309
                    bcs       FChainTarget ; branch if carry is set to FChainTarget
                  ELSE
                    lbcs      FChainTarget ; branch if carry is set to FChainTarget
                  ENDC
                    pshs      d         ; somehow D = memory size? Or parameter size?
                    os9       F$AllTsk  ; allocate a new task number
* ignore errors here
* Hmmm.. the code above FORCES the new process to have the same DAT image ptr
* as the old process, not that it matters...

                  IFNE    H6309   ; begin conditional assembly for H6309
                    fcb       $24,$00   ; tODO: Identify this!
                  ENDC
                    ldu       <D.Proc   ; get nre process
                    lda       P$Task,u  ; new task number
                    ldb       P$Task,x  ; old task number
                    leau      >(P$Stack-R$Size),x ; set up the stack for the new process
                    leax      ,y        ; compute ,y into X
                    ldu       R$X,u     ; where to copy from
                  IFNE    H6309   ; begin conditional assembly for H6309
                    cmpr      x,u       check From/To addresses
                  ELSE
                    pshs      x         ; src ptr
                    cmpu      ,s++      ; dest ptr
                  ENDC
                    puls      y         ; size
                    bhi       FChainDataOver ; to < From: do F$Move
                    beq       FChainSysTaskNum ; to == From, skip F$Move

* To > From: do special copy
                    leay      ,y        ; any bytes to move?
                    beq       FChainSysTaskNum ; no, skip ahead
                  IFNE    H6309   ; begin conditional assembly for H6309
                    pshs      x         ; save address
                    addr      y,x       ; add size to FROM address
                    cmpr      x,u       is it
                    puls      x         ; restore x from the stack
                  ELSE
                    pshs      d,x       ; save d,x on the stack
                    tfr       y,d       ; transfer register value y,d
                    leax      d,x       ; compute d,x into X
                    pshs      x         ; save x on the stack
                    cmpu      ,s++      ; compare U with ,s++
                    puls      d,x       ; restore d,x from the stack
                  ENDC
                    bls       FChainDataOver ; end of FROM <= start of TO: do F$Move

* The areas to copy overlap: do special move routine
                    pshs      d,x,y,u   ; save regs
                  IFNE    H6309   ; begin conditional assembly for H6309
                    addr      y,x       ; go to the END of the area to copy FROM
                    addr      y,u       ; end of area to copy TO
                  ELSE
                    tfr       y,d       ; transfer register value y,d
                    leax      d,x       ; compute d,x into X
                    leau      d,u       ; compute d,u into U
                  ENDC

* This all appears to be doing a copy where destination <= source,
* in the same address space.
FChainGrab          ldb       ,s        ; grab ??
                    leax      -1,x      ; back up one
                    os9       F$LDABX   ; call OS-9 service F$LDABX
                    exg       x,u       ; exchange register values x,u
                    ldb       1,s       ; load B from 1,s
                    leax      -1,x      ; back up another one
                    os9       F$STABX   ; call OS-9 service F$STABX
                    exg       x,u       ; exchange register values x,u
                    leay      -1,y      ; compute -1,y into Y
                    bne       FChainGrab ; branch if zero is clear to FChainGrab

                    puls      d,x,y,u   ; restore regs
                    bra       FChainSysTaskNum ; skip over F$Move

FChainDataOver      os9       F$Move    ; move data over?
FChainSysTaskNum    lda       <D.SysTsk ; get system task number
                    ldx       ,s        ; old process dsc ptr
                    ldu       P$SP,x    ; load U from P$SP,x
                    leax      >(P$Stack-R$Size),x ; compute >(P$Stack-R$Size),x into X
                    ldy       #R$Size   ; load Y from #R$Size
                    os9       F$Move    ; move the stack over
                    puls      u,x       ; restore new, old process dsc's
                    lda       P$ID,u    ; load A from P$ID,u
                    lbsr      FAllprcTarget2 ; check alarms
                    os9       F$DelTsk  ; delete the old task
                    orcc      #IntMasks ; set condition-code bits using #IntMasks
                    ldd       <D.SysPrc ; load D from <D.SysPrc
                    std       <D.Proc   ; store D at <D.Proc
                  IFNE    H6309   ; begin conditional assembly for H6309
                    aim       #^SysState,P$State,x
                  ELSE
                    lda       P$State,x ; load A from P$State,x
                    anda      #^SysState ; mask A with #^SysState
                    sta       P$State,x ; store A at P$State,x
                  ENDC
                    os9       F$AProc   ; activate the process
                    os9       F$NProc   ; go to it

* comes here on error with link to new module
FChainTarget        puls      u,x       ; restore u,x from the stack
                    stx       <D.Proc   ; store X at <D.Proc
                    pshs      b         ; save b on the stack
                    lda       ,u        ; load A from ,u
                    lbsr      FAllprcTarget2 ; kill signals
                    puls      b         ; restore b from the stack
                    os9       F$Exit    ; exit from the process with error condition

* Setup new process DAT image with module
FChainEverything    pshs      d,x,y,u   ; preserve everything
                    ldd       <D.Proc   ; get pointer to current process
                    pshs      d         ; save it
                    stx       <D.Proc   ; save pointer to new process
                    lda       R$A,u     ; get module type
                    ldx       R$X,u     ; get pointer to module name
                    ldy       ,s        ; get pointer to current process
                    leay      P$DATImg,y ; point to DAT image
                    os9       F$SLink   ; map it into new process DAT image
                    bcc       FChainModule ; no error, keep going
                    ldd       ,s        ; restore to current process
                    std       <D.Proc   ; store D at <D.Proc
                    ldu       4,s       ; get pointer to new process
                    os9       F$Load    ; try & load it
                    bcc       FChainModule ; no error, keep going
                    leas      4,s       ; purge stack
                    puls      x,y,u,pc  ; restore & return
*
FChainModule        stu       2,s       ; save pointer to module
                    pshs      a,y       ; save module type & entry point
                    ldu       $0B,s     ; restore register stack pointer
                    stx       R$X,u     ; save updated name pointer
                    ldx       $07,s     ; restore process pointer
                    stx       <D.Proc   ; make it current
                    ldd       5,s       ; get pointer to new module
                    std       P$PModul,x ; save it into process descriptor
                    puls      a         ; restore module type
                    cmpa      #Prgrm+Objct ; regular module?
                    beq       FChainOffModMem ; yes, go
                    cmpa      #Systm+Objct ; system module?
                    beq       FChainOffModMem ; branch if zero is set to FChainOffModMem
                  IFNE    H6309   ; begin conditional assembly for H6309
*--- these lines added to allow 6309 native mode modules to be executed
                    cmpa      #Prgrm+Obj6309 ; regular module?
                    beq       FChainOffModMem ; yes, go
                    cmpa      #Systm+Obj6309 ; system module?
                    beq       FChainOffModMem ; branch if zero is set to FChainOffModMem
*---
                  ENDC
                    ldb       #E$NEMod  ; return unknown module
FChainPurge         leas      2,s       ; purge stack
                    stb       3,s       ; save error
                    comb                ; set carry
                    bra       FChainProcess2 ; return
* Setup up data memory
FChainOffModMem     ldd       #M$Mem    ; get offset to module memory size
                    leay      P$DATImg,x ; get pointer to DAT image
                    ldx       P$PModul,x ; get pointer to module header
                    os9       F$LDDDXY  ; get module memory size
                    cmpa      R$B,u     ; bigger or smaller than callers request?
                    bcc       FChainTryDataMemory ; bigger, use it instead
                    lda       R$B,u     ; get callers memory size instead
                    clrb                ; clear LSB of mem size
FChainTryDataMemory os9       F$Mem     ; try & get the data memory
                    bcs       FChainPurge ; can't do it, exit with error
                    ldx       6,s       ; restore process pointer
                    leay      (P$Stack-R$Size),x ; point to new register stack
                    pshs      d         ; preserve memory size
                    subd      R$Y,u     ; take off size of paramater area
                    std       R$X,y     ; save pointer to parameter area
                    subd      #R$Size   ; take off size of register stack
                    std       P$SP,x    ; save new SP
                    ldd       R$Y,u     ; get parameter count
                    std       R$A,y     ; save it to new process
                    std       6,s       ; save it for myself to
                    puls      d,x       ; restore top of mem & program entry point
                    std       R$Y,y     ; set top of mem pointer
                    ldd       R$U,u     ; get pointer to parameters
                    std       6,s       ; store D at 6,s
                    lda       #Entire   ; load A from #Entire
                    sta       R$CC,y    ; save condition code
                    clra                ; clear A
                    sta       R$DP,y    ; save direct page
                    clrb                ; clear B
                    std       R$U,y     ; save data area start
                    stx       R$PC,y    ; save program entry point
FChainProcess2      puls      d         ; restore process pointer
                    std       <D.Proc   ; save it as current
                    puls      d,x,y,u,pc ; restore d,x,y,u,pc from the stack

                  ENDC
