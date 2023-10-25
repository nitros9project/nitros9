**************************************************
* System Call: F$AProc
*
* Function: Insert process into active process queue
*
* Input:  X = Address of process descriptor
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FAProc              ldx       R$X,u               Get ptr to process to activate
L0D11               clrb
                    pshs      cc,b,x,y,u
                    lda       P$Prior,x           Get process priority
                    sta       P$Age,x             Save it as age (How long it's been around)
                    orcc      #IntMasks           Shut down IRQ's
                    ldu       #(D.AProcQ-P$Queue) Get ptr to active process queue
                    bra       L0D29               Go through the chain
* Update active process queue
*  X=Process to activate
*  U=Current process in queue links
L0D1F               inc       P$Age,u             update current process age
                    bne       L0D25               wrap?
                    dec       P$Age,u             yes, reset it to max.
L0D25               cmpa      P$Age,u             match process ages??
                    bhi       L0D2B               no, skip update
L0D29               leay      ,u                  point Y to current process
L0D2B               ldu       P$Queue,u           get pointer to next process in chain
                    bne       L0D1F               Still more in chain, keep going
                    ldd       P$Queue,y
                    stx       P$Queue,y           save new process to chain
                    std       P$Queue,x
                    puls      cc,b,x,y,u,pc
