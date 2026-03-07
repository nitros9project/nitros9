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

                    ifeq      Level-1

* F$Chain user state entry point.
FChain              bsr       DoChain             do the F$Chain
                    bcs       chainerr@           branch if error
                    orcc      #IntMasks           mask interrupts
                    ldb       P$State,x           get process state
                    andb      #^SysState          turn off system state
                    stb       P$State,x           save new state
resched@            ldu       <P$PModul,x         get pointer to the module for the current process
                    os9       F$Unlink            unlink it
                    os9       F$AProc             add it to active process queue
                    os9       F$NProc             activate it
* F$Chain system state entry point.
SFChain             bsr       DoChain             do the F$Chain
                    bcc       resched@            branch if OK
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

                    else

FChain              pshs      u                   preserve register stack pointer
                    lbsr      AllPrc              allocate a new process descriptor
                    bcc       L03B7               do the chain if no error
                    puls      u,pc                return to caller with error

* Copy Process Descriptor Data
L03B7               ldx       <D.Proc             get pointer to current process
                    pshs      x,u                 save old & new descriptor pointers
                    ifne      H6309
                    leax      P$SP,x              point to source
                    leau      P$SP,u              point to destination
                    ldw       #$00fc              get size (P$SP+$FC)
                    tfm       x+,u+               move it
                    else
*
* LCB Proposed new 6809 code approx 750 cycles faster
* Appears to work (boot calls F$Chain twice).
                    leay      P$SP,u              Point to destination
                    leau      P$SP,x              Point to source
                    ldb       #84                 # of 3 byte sets to copy
L03C3               pulu      a,x                 Get 3 bytes
                    sta       ,y+                 copy them
                    stx       ,y++
                    decb                          Dec 3 byte ctr
                    bne       L03C3
                    endc
L03CB               ldu       2,s                 get new descriptor pointer
                    leau      <P$DATImg,u
                    ldx       ,s                  get old descriptor pointer
                    lda       P$Task,x            get task #
                    lsla                          2 bytes per entry
                    ldx       <D.TskIpt           get task image table pointer
                    stu       a,x                 save updated DAT image pointer for later
* Question: are the previous 7 lines necessary? The F$AllTsk call, below
* should take care of everything!
                    ldx       <D.Proc             get process descriptor
                    ifne      H6309
                    clrd                          Faster than 2 memory clears
                    else
                    clra
                    clrb
                    endc
                    stb       P$Task,x            old process has no task number
                    std       <P$SWI,x            clear out all sorts of signals and vectors
                    std       <P$SWI2,x
                    std       <P$SWI3,x
                    sta       <P$Signal,x
                    std       <P$SigVec,x
                    ldu       <P$PModul,x
                    os9       F$UnLink            unlink from the primary module
                    ldb       P$PagCnt,x          grab the page count
                    addb      #$1F                round up to the nearest block
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lsrb                          get number of blocks used
                    lda       #$08
                    ifne      H6309
                    subr      b,a                 A=number of blocks unused
                    else
                    pshs      b
                    suba      ,s+
                    endc
                    leay      <P$DATImg,x         set up the initial DAT image
                    lslb
                    leay      b,y                 go to the offset
                    ldu       #DAT.Free           mark the blocks as free
L040C               stu       ,y++                do all of them
                    deca
                    bne       L040C
                    ldu       2,s                 get new process descriptor pointer
                    stu       <D.Proc             make it the new process
                    ldu       4,s
                    lbsr      L04B1               link to new module & setup register stack
                    ifne      H6309
                    bcs       L04A1
                    else
                    lbcs      L04A1
                    endc
                    pshs      d                   somehow D = memory size? Or parameter size?
                    os9       F$AllTsk            allocate a new task number
* ignore errors here
                    ifne      picothing
* Debug: print chain F$AllTsk result
                    pshs      a,b
                    bcc       catok@
                    lda       #'c       debug: chain F$AllTsk failed
                    jsr       <D.BtBug
                    tfr       b,a
                    bra       ctsk@
catok@              lda       #'T       debug: chain F$AllTsk ok
                    jsr       <D.BtBug
                    ldx       <D.Proc
                    ldb       P$Task,x
                    tfr       b,a
ctsk@               lsra
                    lsra
                    lsra
                    lsra
                    adda      #'0
                    cmpa      #'9+1
                    blo       cth@
                    adda      #7
cth@                jsr       <D.BtBug
                    ldb       P$Task,x
                    andb      #$0F
                    addb      #'0
                    cmpb      #'9+1
                    blo       ctl@
                    addb      #7
ctl@                tfr       b,a
                    jsr       <D.BtBug
                    puls      a,b
                    endc
* Hmmm.. the code above FORCES the new process to have the same DAT image ptr
* as the old process, not that it matters...

                    ifne      H6309
                    fcb       $24,$00             TODO: Identify this!
                    endc
                    ldu       <D.Proc             get nre process
                    lda       P$Task,u            new task number
                    ldb       P$Task,x            old task number
                    leau      >(P$Stack-R$Size),x set up the stack for the new process
                    leax      ,y
                    ldu       R$X,u               where to copy from
                    ifne      H6309
                    cmpr      x,u                 check From/To addresses
                    else
                    pshs      x                   src ptr
                    cmpu      ,s++                dest ptr
                    endc
                    puls      y                   size
                    bhi       L0471               To < From: do F$Move
                    beq       L0474               To == From, skip F$Move

* To > From: do special copy
                    leay      ,y                  any bytes to move?
                    beq       L0474               no, skip ahead
                    ifne      H6309
                    pshs      x                   save address
                    addr      y,x                 add size to FROM address
                    cmpr      x,u                 is it
                    puls      x
                    else
                    pshs      d,x
                    tfr       y,d
                    leax      d,x
                    pshs      x
                    cmpu      ,s++
                    puls      d,x
                    endc
                    bls       L0471               end of FROM <= start of TO: do F$Move

* The areas to copy overlap: do special move routine
                    pshs      d,x,y,u             save regs
                    ifne      H6309
                    addr      y,x                 go to the END of the area to copy FROM
                    addr      y,u                 end of area to copy TO
                    else
                    tfr       y,d
                    leax      d,x
                    leau      d,u
                    endc

* This all appears to be doing a copy where destination <= source,
* in the same address space.
L0457               ldb       ,s                  grab ??
                    leax      -1,x                back up one
                    os9       F$LDABX
                    exg       x,u
                    ldb       1,s
                    leax      -1,x                back up another one
                    os9       F$STABX
                    exg       x,u
                    leay      -1,y
                    bne       L0457

                    puls      d,x,y,u             restore regs
                    bra       L0474               skip over F$Move

L0471               os9       F$Move              move data over?
L0474               lda       <D.SysTsk           get system task number
                    ldx       ,s                  old process dsc ptr
                    ldu       P$SP,x
                    leax      >(P$Stack-R$Size),x
                    ldy       #R$Size
                    os9       F$Move              move the stack over
                    ifne      picothing
                    pshs      a
                    lda       #'S       debug: chain stack F$Move done
                    jsr       <D.BtBug
                    puls      a
                    endc
                    puls      u,x                 restore new, old process dsc's
                    lda       P$ID,u
                    lbsr      L0386               check alarms
                    os9       F$DelTsk            delete the old task
                    orcc      #IntMasks
                    ldd       <D.SysPrc
                    std       <D.Proc
                    ifne      H6309
                    aim       #^SysState,P$State,x
                    else
                    lda       P$State,x
                    anda      #^SysState
                    sta       P$State,x
                    endc
                    ifne      picothing
                    pshs      a
                    lda       #'R       debug: chain about to F$AProc
                    jsr       <D.BtBug
                    puls      a
                    endc
                    os9       F$AProc             activate the process
                    ifne      picothing
                    pshs      a
                    lda       #'G       debug: chain going to F$NProc
                    jsr       <D.BtBug
                    puls      a
                    endc
                    os9       F$NProc             go to it

* comes here on error with link to new module
L04A1               puls      u,x
                    stx       <D.Proc
                    pshs      b
                    ifne      picothing
* Debug: print 'Y' + 2-hex-digit error code when F$Chain's L04B1 fails
                    pshs      a,b
                    lda       #'Y
                    jsr       <D.BtBug
                    puls      a         get error code (was in B)
                    pshs      a         save for low nibble
                    lsra
                    lsra
                    lsra
                    lsra
                    adda      #'0
                    cmpa      #'9+1
                    blo       yh@
                    adda      #7
yh@                 jsr       <D.BtBug
                    puls      a         get error code again
                    anda      #$0F
                    adda      #'0
                    cmpa      #'9+1
                    blo       yl@
                    adda      #7
yl@                 jsr       <D.BtBug
                    endc
                    lda       ,u
                    lbsr      L0386               kill signals
                    puls      b
                    os9       F$Exit              exit from the process with error condition

* Setup new process DAT image with module
L04B1               pshs      d,x,y,u             preserve everything
                    ldd       <D.Proc             get pointer to current process
                    pshs      d                   save it
                    stx       <D.Proc             save pointer to new process
                    lda       R$A,u               get module type
                    ldx       R$X,u               get pointer to module name
                    ldy       ,s                  get pointer to current process
                    leay      P$DATImg,y          point to DAT image
                    os9       F$SLink             map it into new process DAT image
                    bcc       L04D7               no error, keep going
                    ldd       ,s                  restore to current process
                    std       <D.Proc
                    ldu       4,s                 get pointer to new process
                    os9       F$Load              try & load it
                    bcc       L04D7               no error, keep going
                    leas      4,s                 purge stack
                    puls      x,y,u,pc            restore & return
*
L04D7               stu       2,s                 save pointer to module
                    pshs      a,y                 save module type & entry point
                    ldu       $0B,s               restore register stack pointer
                    stx       R$X,u               save updated name pointer
                    ldx       $07,s               restore process pointer
                    stx       <D.Proc             make it current
                    ldd       5,s                 get pointer to new module
                    std       P$PModul,x          save it into process descriptor
                    puls      a                   restore module type
                    cmpa      #Prgrm+Objct        regular module?
                    beq       L04FB               yes, go
                    cmpa      #Systm+Objct        system module?
                    beq       L04FB
                    ifne      H6309
*--- these lines added to allow 6309 native mode modules to be executed
                    cmpa      #Prgrm+Obj6309      regular module?
                    beq       L04FB               yes, go
                    cmpa      #Systm+Obj6309      system module?
                    beq       L04FB
*---
                    endc
                    ldb       #E$NEMod            return unknown module
L04F4               leas      2,s                 purge stack
                    stb       3,s                 save error
                    comb                          set carry
                    lbra      L053E               return (lbra: range extended by IFNE picothing block)
* Setup up data memory
L04FB               ldd       #M$Mem              get offset to module memory size
                    leay      P$DATImg,x          get pointer to DAT image
                    ldx       P$PModul,x          get pointer to module header
                    os9       F$LDDDXY            get module memory size
                    cmpa      R$B,u               bigger or smaller than callers request?
                    bcc       L050E               bigger, use it instead
                    lda       R$B,u               get callers memory size instead
                    clrb                          clear LSB of mem size
L050E               os9       F$Mem               try & get the data memory
                    bcs       L04F4               can't do it, exit with error
                    ldx       6,s                 restore process pointer
                    leay      (P$Stack-R$Size),x  point to new register stack
                    pshs      d                   preserve memory size
                    subd      R$Y,u               take off size of paramater area
                    std       R$X,y               save pointer to parameter area
                    subd      #R$Size             take off size of register stack
                    std       P$SP,x              save new SP
                    ldd       R$Y,u               get parameter count
                    std       R$A,y               save it to new process
                    std       6,s                 save it for myself to
                    puls      d,x                 restore top of mem & program entry point
                    std       R$Y,y               set top of mem pointer
                    ldd       R$U,u               get pointer to parameters
                    std       6,s
                    lda       #Entire
                    sta       R$CC,y              save condition code
                    clra
                    sta       R$DP,y              save direct page
                    clrb
                    std       R$U,y               save data area start
                    stx       R$PC,y              save program entry point
                    ifne      picothing
* Print 'E' + 4-hex-digit entry PC whenever F$Fork or F$Chain links a module.
* Uses D.IRQTmp as scratch; jsr <D.BtBug (not lbsr PicoBtBug: fchain is
* also used by krnp2 where PicoBtBug is out of lbsr range).
* X holds the program entry point at this point.
                    pshs      a,b       save temporaries
                    lda       #'E       print 'E' token
                    jsr       <D.BtBug
                    tfr       x,d       D = entry PC (A = high byte, B = low byte)
                    sta       <D.IRQTmp save high byte
                    lsra                shift high nibble of high byte
                    lsra
                    lsra
                    lsra
                    anda      #$0F      mask to nibble
                    adda      #'0       convert to ASCII
                    cmpa      #'9+1     past '9'?
                    blo       eh@       no
                    adda      #'A-'9-1  yes, shift to A-F
eh@                 jsr       <D.BtBug  print high nibble of high byte
                    lda       <D.IRQTmp reload high byte
                    anda      #$0F      mask low nibble
                    adda      #'0       convert to ASCII
                    cmpa      #'9+1     past '9'?
                    blo       el@       no
                    adda      #'A-'9-1  yes, shift to A-F
el@                 jsr       <D.BtBug  print low nibble of high byte
                    stb       <D.IRQTmp save low byte (from tfr x,d above)
                    lsrb                shift high nibble of low byte
                    lsrb
                    lsrb
                    lsrb
                    andb      #$0F      mask to nibble
                    addb      #'0       convert to ASCII
                    cmpb      #'9+1     past '9'?
                    blo       ehl@      no
                    addb      #'A-'9-1  yes, shift to A-F
ehl@                tfr       b,a       move to A for jsr <D.BtBug
                    jsr       <D.BtBug  print high nibble of low byte
                    ldb       <D.IRQTmp reload low byte
                    andb      #$0F      mask low nibble
                    addb      #'0       convert to ASCII
                    cmpb      #'9+1     past '9'?
                    blo       ell@      no
                    addb      #'A-'9-1  yes, shift to A-F
ell@                tfr       b,a       move to A for jsr <D.BtBug
                    jsr       <D.BtBug  print low nibble of low byte
                    puls      a,b       restore temporaries
                    andcc     c         clear carry corrupted by cmpb in hex print
                    endc
L053E               puls      d                   restore process pointer
                    std       <D.Proc             save it as current
                    puls      d,x,y,u,pc

                    endc
