**************************************************
* System Call: F$Exit
*
* Function: Causes a process to cease execution and exit
*
* Input:  B = Status code to be returned to parent process
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FExit               ldx       <D.Proc             get current process pointer
                    bsr       L05A5               close all the paths
                    ldb       R$B,u               get exit signal
                    stb       <P$Signal,x         and save in proc desc
                    leay      P$PID,x
                    bra       L0563               go find kids...

L0551               clr       P$SID,y             clear child ID
                    lbsr      L0B2E               find its proc desc
                    clr       1,y                 clear sibling ID
                    ifne      H6309
                    tim       #Dead,P$State,y
                    else
                    lda       P$State,y           get child's state
                    bita      #Dead               is it dead?
                    endc
                    beq       L0563               ...no
                    lda       P$ID,y              else get its ID
                    lbsr      L0386               and destroy its proc desc
L0563               lda       P$SID,y             get child ID
                    bne       L0551               ...yes, loop

                    leay      ,x                  kid's proc desc
                    ldx       #D.WProcQ-P$Queue
                    lds       <D.SysStk           use system stack
                    pshs      cc                  save CC
                    orcc      #IntMasks           halt interrupts
                    lda       P$PID,y             get our parent ID
                    bne       L0584               and wake him up

                    puls      cc                  restore CC
                    lda       P$ID,y              get our ID
                    lbsr      L0386               give up our proc desc
                    bra       L05A2               and start next active process

* Search for Waiting Parent
L0580               cmpa      P$ID,x              is proc desc our parent's?
                    beq       L0592               ...yes!

L0584               leau      ,x                  U is base desc
                    ldx       P$Queue,x           X is next waiter
                    bne       L0580               see if parent
                    puls      cc                  restore CC
                    lda       #(SysState!Dead)    set us to system state
                    sta       P$State,y           and mark us as dead
                    bra       L05A2               so F$Wait will find us; next proc

* Found Parent (X)
L0592               ldd       P$Queue,x           take parent out of wait queue
                    std       P$Queue,u
                    puls      cc                  restore CC
                    ldu       P$SP,x              get parent's stack register
                    ldu       R$U,u
                    lbsr      L036C               get child's death signal to parent
                    os9       F$AProc             move parent to active queue
L05A2               os9       F$NProc             start next proc in active queue

* Close Proc I/O Paths & Unlink Mem
* Entry: U=Register stack pointer
L05A5               pshs      u                   preserve register stack pointer
                    ldb       #NumPaths           get maximum # of paths
                    leay      P$Path,x            point to path table
L05AC               lda       ,y+                 path open?
                    beq       L05B9               no, skip ahead
                    clr       -1,y                clear the path block #
                    pshs      b                   preserve count
                    os9       I$Close             close the path
                    puls      b                   restore count
L05B9               decb                          done?
                    bne       L05AC               no, continue looking

* Clean up memory process had
                    clra                          get starting block
                    ldb       P$PagCnt,x          get page count
                    beq       L05CB               none there, skip ahead
                    addb      #$1F                round it up
                    lsrb                          divide by 32 to get block count
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    os9       F$DelImg            delete the ram & DAT image
* Unlink the module
L05CB               ldd       <D.Proc
                    pshs      d
                    stx       <D.Proc             set bad proc
                    ldu       P$PModul,x          program pointer
                    os9       F$UnLink            unlink aborted program
                    puls      u,b,a
                    std       <D.Proc             reset parent proc
                    os9       F$DelTsk            release X's task #
                    rts
