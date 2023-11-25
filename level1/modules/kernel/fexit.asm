;;; F$Exit
;;;
;;; Terminate the calling process.
;;;
;;; Entry:  B = The status code to return to the parent process.
;;;
;;; Exit:   The process is terminated.
;;;
;;; F$Exit is the only way a process can terminate itself. F$Exit deallocates the process’ data memory area and
;;; unlinks the process' primary module. It also closes all open paths automatically.
;;;
;;; F$Wait always returns to the parent the status code passed by the child when it exits. Therefore, if the parent
;;; calls F$Wait and receives the status code, it knows the child has died.
;;;
;;; Exit unlinks only the primary module. Unlink any module that is loaded or linked to by the process before
;;; calling F$Exit.

               ifeq      Level-1

FExit          ldx       <D.Proc             get pointer to current process descriptor
               ldb       R$B,u               get exit code
               stb       P$Signal,x          save it as the process' signal
* Close all open paths that this process has
               ldb       #NumPaths           get the number pf paths
               leay      P$PATH,x            point Y to the base of the path table in the process descriptor
loop@          lda       ,y+                 get a path
               beq       empty@              branch if empty
               pshs      b                   else save off counter
               os9       I$Close             close the path
               puls      b                   recover the counter
empty@         decb                          decrement
               bne       loop@               branch if more paths to close
* Free any allocated memory associated with this process
               lda       P$ADDR,x            get 256 byte page number of allocated memory
               tfr       d,u                 transfer to D to U
               lda       P$PagCnt,x          get allocated page count in A
               os9       F$SRtMem            return that memory to the system
               ldu       P$PModul,x          get the pointer to the primary module
               os9       F$UnLink            unlink it
* Go through the siblings of this process
               ldu       <D.Proc             get the current process pointer
               leay      P$PID,u             point Y to the start of the process descriptor
               ldx       <D.PrcDBT           and X to the process descriptor table
               bra       clearsid@           go clear the sibling ID
retprocdesc@   clr       P$SID,y             clear the sibling ID
               os9       F$Find64            find the sibling's process descriptor and put it in Y
               lda       P$State,y           load the sibling process' state
               bita      #Dead               is it dead?
               beq       clearids@           branch if not
               lda       P$ID,y              else get the sibling's process ID
               os9       F$Ret64             and free the sibling's process descriptor
clearids@      clr       P$PID,y             clear the parent ID
clearsid@      lda       P$SID,y             get the sibling ID
               bne       retprocdesc@        branch if there is one
* Start sifting through the wait queue if there's a parent
               ldx       #(D.WProcQ-P$Queue) load U with D.WProcQ-P$Queue so we're at the first process in the queue later
               lda       P$PID,u             get the parent ID
               bne       fixparent@          branch if there is a parent
* This process doesn't have a parent. Just return its process descriptor and exit
               ldx       <D.PrcDBT           get process descriptor pointer table in X
               lda       P$ID,u              get ID of process
               os9       F$Ret64             and return the 64 byte block for this process descriptor
               bra       ex@                 then return to the caller
* Go through wait queue and alert the parent
loop2@         cmpa      P$ID,x              is this the parent?
               beq       foundparent@        branch if so
fixparent@     leay      ,x                  point Y to the process descriptor
               ldx       P$Queue,x           get the queue this process is in
               bne       loop2@              branch if not empty
               lda       P$State,u           get state
               ora       #Dead               mark it as dead
               sta       P$State,u           save state
               bra       ex@                 then exit
* X = parent process descriptor for process that is exiting
* Y = process descriptor in front of parent process in queue
* U = ???
foundparent@   ldd       P$Queue,x           get the queue that the parent is in
               std       P$Queue,y           and store it in the previous process descriptor (removes the parent from the qeue)
               os9       F$AProc             then put parent process back in the active queue
               leay      ,u                  point Y to U
               ldu       P$SP,x              get caller's stack pointer
               ldu       R$D,u               get caller's D register
               lbsr      SignalProcess       signal the process
ex@            clra                          clear A
               clrb                          clear B
               std       <D.Proc             clear out current process descriptor
               rts                           return to caller

               else

FExit          ldx       <D.Proc             get current process pointer
               bsr       L05A5               close all the paths
               ldb       R$B,u               get exit signal
               stb       <P$Signal,x         and save in proc desc
               leay      P$PID,x
               bra       L0563               go find kids...

L0551          clr       P$SID,y             clear child ID
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
L0563          lda       P$SID,y             get child ID
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
L0580          cmpa      P$ID,x              is proc desc our parent's?
               beq       L0592               ...yes!

L0584          leau      ,x                  U is base desc
               ldx       P$Queue,x           X is next waiter
               bne       L0580               see if parent
               puls      cc                  restore CC
               lda       #(SysState!Dead)    set us to system state
               sta       P$State,y           and mark us as dead
               bra       L05A2               so F$Wait will find us; next proc

* Found Parent (X)
L0592          ldd       P$Queue,x           take parent out of wait queue
               std       P$Queue,u
               puls      cc                  restore CC
               ldu       P$SP,x              get parent's stack register
               ldu       R$U,u
               lbsr      L036C               get child's death signal to parent
               os9       F$AProc             move parent to active queue
L05A2          os9       F$NProc             start next proc in active queue

* Close Proc I/O Paths & Unlink Mem
* Entry: U=Register stack pointer
L05A5          pshs      u                   preserve register stack pointer
               ldb       #NumPaths           get maximum # of paths
               leay      P$Path,x            point to path table
L05AC          lda       ,y+                 path open?
               beq       L05B9               no, skip ahead
               clr       -1,y                clear the path block #
               pshs      b                   preserve count
               os9       I$Close             close the path
               puls      b                   restore count
L05B9          decb                          done?
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
L05CB          ldd       <D.Proc
               pshs      d
               stx       <D.Proc             set bad proc
               ldu       P$PModul,x          program pointer
               os9       F$UnLink            unlink aborted program
               puls      u,b,a
               std       <D.Proc             reset parent proc
               os9       F$DelTsk            release X's task #
               rts

               endc