**************************************************
* System Call: F$Sleep
*
* Function: Put the calling process to sleep
*
* Input:  X = Sleep time in ticks (0 = forever)
*
* Output: X = Decremented by the number of ticks that the process slept
*
* Error:  CC = C bit set; B = error code
*
FSleep              pshs      cc                  preserve interupt status
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
L071B               puls      cc
                    os9       F$AProc             activate the process
                    bra       L0780
L0722               ldd       R$X,u               get callers X (contains sleep tick count)
                    beq       L076D               done, wake it up
                    ifne      H6309
                    decd      subtract            1 from tick count
                    else
                    subd      #$0001
                    endc
                    std       R$X,u               save it back
                    beq       L071B               zero, wake up process
                    pshs      x,y
                    ldx       #(D.SProcQ-P$Queue)
L0732               std       R$X,u
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
L074F               puls      y,x
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
SkpSleep            puls      cc,pc

L076D               ldx       #D.SProcQ-P$Queue
L0770               leay      ,x
                    ldx       P$Queue,x
                    bne       L0770
                    ldx       <D.Proc
                    clra
                    clrb
                    stx       P$Queue,y
                    std       P$Queue,x
                    puls      cc

L0780               pshs      dp,x,y,u,pc
L0782               leax      <L079C,pc
                    stx       7,s
                    ldx       <D.Proc
                    ldb       P$Task,x            This is related to the 'one-byte hack'
                    cmpb      <D.SysTsk           that stops OS9p1 from doing an F$AllTsk on
                    beq       L0792               _every_ system call.
                    os9       F$DelTsk
L0792               ldd       P$SP,x
                    ifne      H6309
                    pshsw
                    endc
                    pshs      cc,d
                    sts       P$SP,x
                    os9       F$NProc

L079C               pshs      x
                    ldx       <D.Proc
                    std       P$SP,x
                    clrb
                    puls      x,pc
