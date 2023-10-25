**************************************************
* System Call: F$Chain
*
* Function: Starts a new child process and terminates the calling process.
*
* Input:  X = Address of module or filename
*         Y = Parameter area size (256 byte pages)
*         U = Address of parameter area
*         A = Language/Type code
*         B = Optional data area size (256 byte pages)
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FChain              pshs      u                   preserve register stack pointer
                    lbsr      AllPrc              allocate a new process descriptor
                    bcc       L03B7               do the chain if no error
                    puls      u,pc                return to caller with error

* Copy Process Descriptor Data
L03B7               ldx       <D.Proc             get pointer to current process
                    pshs      x,u                 save old & new descriptor pointers
                    leax      P$SP,x              point to source
                    leau      P$SP,u              point to destination
                    ifne      H6309
                    ldw       #$00fc              get size (P$SP+$FC)
                    tfm       x+,u+               move it
                    else
                    ldy       #$00FC
L03C3               ldd       ,x++                copy bytes
                    std       ,u++
                    leay      -2,y
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
                    os9       F$AProc             activate the process
                    os9       F$NProc             go to it

* comes here on error with link to new module
L04A1               puls      u,x
                    stx       <D.Proc
                    pshs      b
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
                    bra       L053E               return
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
L053E               puls      d                   restore process pointer
                    std       <D.Proc             save it as current
                    puls      d,x,y,u,pc
