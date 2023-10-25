**************************************************
* System Call: F$Send
*
* Function: Send a signal to a process
*
* Input:  A = Receiver's process ID
*         B = Signal code
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FSend               ldx       <D.Proc             get current process pointer
                    lda       R$A,u               get destination ID
                    bne       L0652               it's ok, go on
                    inca                          add one
* Send signal to ALL process's
L0647               cmpa      P$ID,x              find myself?
                    beq       L064D               yes, skip it
                    bsr       L0652               send the signal
L064D               inca                          move to next process
                    bne       L0647               go send it
                    clrb                          clear errors
                    rts                           return

* X   = process descriptor ptr of singal sender
* A   = process ID to send signal to
* R$B = signal code
L0652               lbsr      L0B2E               get pointer to destination descriptor
                    pshs      cc,a,y,u            preserve registers
                    bcs       L066A               error, can't get pointer return
                    tst       R$B,u               kill signal?
                    bne       L066D               no, go on
                    ldd       P$User,x            get user #
                    beq       L066D               he's super user, go on
                    cmpd      P$User,y            does he own the process?
                    beq       L066D               yes, send the signal
                    ldb       #E$BPrcID           get bad process error
                    inc       ,s                  set Carry in CC on stack
L066A               puls      cc,a,y,u,pc         return

* Y = process descriptor of process receiving signal
L066D               orcc      #IntMasks           shut down IRQ's
                    ldb       R$B,u               get signal code
                    bne       L067B               not a kill signal, skip ahead
                    ldb       #E$PrcAbt           get error 228
                    ifne      H6309
                    oim       #Condem,P$State,y   condem process
L067B               aim       #^Suspend,P$State,y take process out of suspend state
                    else
                    lda       P$State,y
                    ora       #Condem
                    sta       P$State,y
L067B               lda       P$State,y
                    anda      #^Suspend
                    sta       P$State,y
                    endc
                    lda       <P$Signal,y         already have a pending signal?
                    beq       L068F               nope, go on
                    deca                          is it a wakeup signal?
                    beq       L068F               yes, skip ahead
                    inc       ,s                  set carry on stack
                    ldb       #E$USigP            get pending signal error
                    puls      cc,a,y,u,pc         return

* Update sleeping process queue
L068F               stb       P$Signal,y          save signal code in descriptor
                    ldx       #(D.SProcQ-P$Queue) get pointer to sleeping process queue
                    ifne      H6309
                    clrd                          Faster than 2 memory clears
                    else
                    clra
                    clrb
                    endc
L0697               leay      ,x                  point Y to this process
                    ldx       P$Queue,x           get pointer to next process in chain
                    beq       L06D3               last one, go check waiting list
                    ldu       P$SP,x              get process stack pointer
                    addd      R$X,u               add his sleep count
                    cmpx      2,s                 is it destination process?
                    bne       L0697               no, skip to next process
                    pshs      d                   save sleep count
                    ifne      H6309
                    tim       #TimSleep,P$State,x
                    else
                    lda       P$State,x
                    bita      #TimSleep
                    endc
                    beq       L06CF               no, update queue
                    ldd       ,s
                    beq       L06CF
                    ldd       R$X,u
                    ifne      H6309
                    ldw       ,s
                    stw       R$X,u
                    else
                    pshs      d
                    ldd       2,s
                    std       R$X,u
                    puls      d
                    endc
                    ldu       P$Queue,x
                    beq       L06CF
                    std       ,s
                    ifne      H6309
                    tim       #TimSleep,P$State,u
                    else
                    lda       P$State,u
                    bita      #TimSleep
                    endc
                    beq       L06CF
                    ldu       P$SP,u
                    ldd       ,s
                    addd      R$X,u
                    std       R$X,u
L06CF               leas      2,s
                    bra       L06E0
L06D3               ldx       #(D.WProcQ-P$Queue)
L06D6               leay      ,x
                    ldx       P$Queue,x
                    beq       L06F4
                    cmpx      2,s
                    bne       L06D6
L06E0               ldd       P$Queue,x
                    std       P$Queue,y
                    lda       P$Signal,x
                    deca
                    bne       L06F1
                    sta       P$Signal,x
                    lda       ,s
                    tfr       a,cc
L06F1               os9       F$AProc             activate the process
L06F4               puls      cc,a,y,u,pc         restore & return
