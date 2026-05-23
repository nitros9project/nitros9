**************************************************
* System Call: F$AllTsk
*
* Function: Allocate process task number
*
* Input:  X = Process descriptor pointer
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FAllTsk             ldx       R$X,u     ; get pointer to process descriptor
L0C58               ldb       P$Task,x  ; already have a task #?
                    bne       L0C64     ; yes, return
                    bsr       L0CA6     ; find a free task
                    bcs       L0C65     ; error, couldn't get one, return
                    stb       P$Task,x  ; save task #
                    bsr       L0C79     ; load MMU with task
L0C64               clrb                ; clear errors
L0C65               rts                 ; return

**************************************************
* System Call: F$DelTsk
*
* Function: Deallocate process task number
*
* Input:  X = Process descriptor pointer
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FDelTsk             ldx       R$X,u     ; load X from R$X,u
L0C68               ldb       P$Task,x  ; grab the current task number
                    beq       L0C64     ; if system (or released), exit
                    clr       P$Task,x  ; force the task number to be zero
                    bra       L0CC3     ; do a F$RelTsk

TstImg              equ       *         ; define assembler symbol TstImg
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tim       #ImgChg,P$State,x ; dAT image change flagged in process desc?
                  ELSE
                    ldb       P$State,x ; dAT image change flagged in process desc?
                    bitb      #ImgChg   ; test bits in B against #ImgChg
                  ENDC
                    beq       L0C65     ; if not, exit now: (clear carry not needed)
                    fcb       $8C       ; skip LDX, below
**************************************************
* System Call: F$SetTsk
*
* Function: Set process task DAT registers
*
* Input:  X = Process descriptor pointer
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FSetTsk             ldx       R$X,u     ; get process descriptor pointer
L0C79               equ       *         ; define assembler symbol L0C79
                  IFNE    H6309   ; begin conditional assembly for H6309
                    aim       #^ImgChg,P$State,x ; flag DAT image change in process descriptor
                  ELSE
                    ldb       P$State,x ; flag DAT image change in process descriptor
                    andb      #^ImgChg  ; mask B with #^ImgChg
                    stb       P$State,x ; store B at P$State,x
                  ENDC
                    clr       <D.Task1N ; task 1 DAT image has changed
                    andcc     #^Carry   ; clear carry
                    pshs      cc,d,x,u  ; preserve everything
                    ldb       P$Task,x  ; get task #
                    leau      <P$DATImg,x ; point to DAT image
                    ldx       <D.TskIPt ; get task image table pointer
                    lslb                ; account for 2 bytes/entry
                    stu       b,x       ; save DAT image pointer in task table
                    cmpb      #2        ; is it either system or GrfDrv?
                    bhi       L0C9F     ; no, return
                    ldx       #DAT.Regs ; update system DAT image
                    lbsr      L0E93     ; go bash the hardware
L0C9F               puls      cc,d,x,u,pc ; restore cc,d,x,u,pc from the stack

**************************************************
* System Call: F$ResTsk
*
* Function: Reserve task number
*
* Input:  None
*
* Output: B = Task number
*
* Error:  CC = C bit set; B = error code
*
FResTsk             bsr       L0CA6     ; call local routine L0CA6
                    stb       R$B,u     ; store B at R$B,u
L0CA5               rts                 ; return to caller


* Find a free task in task map
* Entry: None
* Exit : B=Task #
L0CA6               pshs      x         ; preserve X
                    ldb       #$02      ; get starting task # (skip System/Grfdrv)
                    ldx       <D.Tasks  ; get task table pointer
L0CAC               lda       b,x       ; task allocated?
                    beq       L0CBA     ; no, allocate it & return
                    incb                ; move to next task
                    cmpb      #$20      ; end of task list?
                    bne       L0CAC     ; no, keep looking
                    comb                ; set carry for error
                    ldb       #E$NoTask ; get error code
                    puls      x,pc      ; restore x,pc from the stack

L0CBA               stb       b,x       ; flag task used (1 cycle faster than inc)
                    clra                ; clear carry
L0CBF               puls      x,pc      ; restore & return


**************************************************
* System Call: F$RelTsk
*
* Function: Release task number
*
* Input:  B = Task number
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FRelTsk             ldb       R$B,u     ; get task # to release
L0CC3               pshs      b,x       ; preserve it & X
                    tstb                ; check out B
                    beq       L0CD0     ; if system task, don't bother deleting the task
                    ldx       <D.Tasks  ; get task table ptr
                    clr       b,x       ; clear out the task
L0CD0               puls      b,x,pc    ; restore regs & return

* Sleeping process update (Gets executed from clock)
* Could move this code into Clock, but what about the call to F$AProc (L0D11)?
* It probably will be OK... but have to check.
*   Possible, move ALL software-clock code into OS9p2, and therefore
* have it auto-initialize?  All hardware clocks would then be called
* just once a minute.
L0CD2               ldx       <D.SProcQ ; get sleeping process Queue ptr
                    beq       L0CFD     ; none (no one sleeping), so exit
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tim       #TimSleep,P$State,x ; is it a timed sleep?
                  ELSE
                    ldb       P$State,x ; is it a timed sleep?
                    bitb      #TimSleep ; test bits in B against #TimSleep
                  ENDC
                    beq       L0CFD     ; no, exit: waiting for signal/interrupt
                    ldu       P$SP,x    ; yes, get his stack pointer
                    ldd       R$X,u     ; get his sleep tick count
                  IFNE    H6309   ; begin conditional assembly for H6309
                    decd      ; decrement           sleep count
                  ELSE
                    subd      #$0001    ; subtract #$0001 from D
                  ENDC
                    std       R$X,u     ; save it back
                    bne       L0CFD     ; still more ticks to go, so exit
* Process needs to wake up, update queue pointers
L0CE7               ldu       P$Queue,x ; get next process in Queue
                    bsr       L0D11     ; activate it
                    leax      ,u        ; point to new process
                    beq       L0CFB     ; don't exist, go on
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tim       #TimSleep,P$State,x ; is it in a timed sleep?
                  ELSE
                    ldb       P$State,x ; is it a timed sleep?
                    bitb      #TimSleep ; test bits in B against #TimSleep
                  ENDC
                    beq       L0CFB     ; no, go update process table
                    ldu       P$SP,x    ; get it's stack pointer
                    ldd       R$X,u     ; any sleep time left?
                    beq       L0CE7     ; no, go activate next process in queue
L0CFB               stx       <D.SProcQ ; store new sleeping process pointer
L0CFD               dec       <D.Slice  ; any time remaining on process?
                    bne       L0D0D     ; yes, exit
                    inc       <D.Slice  ; reset slice count
                    ldx       <D.Proc   ; get current process pointer
                    beq       L0D0D     ; none, return
                  IFNE    H6309   ; begin conditional assembly for H6309
                    oim       #TimOut,P$State,x ; put him in a timeout state
                  ELSE
                    ldb       P$State,x ; put him in a timeout state
                    orb       #TimOut   ; merge #TimOut into B
                    stb       P$State,x ; store B at P$State,x
                  ENDC
L0D0D               clrb                ; clear B
                    rts                 ; return to caller
