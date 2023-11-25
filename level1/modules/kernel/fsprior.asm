;;; F$SPrior
;;;
;;; Change a process' priority.
;;;
;;; Entry:  A = The process ID to modify.
;;;         B = The new priority.
;;;
;;; Exit:  CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$SPrior modifies a process’s priority to a value between 0 (lowest) and 255 (highest).
;;; A process can change another process’s priority only if it has the same user ID.

               ifeq      Level-1
FSPrior        lda       R$A,u               get the process ID from the caller
               ldx       <D.PrcDBT           get the pointer to the process descriptor table
               os9       F$Find64            find the 64 byte page associated with this process ID
               bcs       ex@                 branch if it can't be found
               ldx       <D.Proc             else get the current process descriptor
               ldd       P$User,x            and its user ID
               cmpd      P$User,y            is it the same as the process to change?
               bne       ex@                 branch if not
               lda       R$B,u               else the owners are the same user ID, so allow the change
               sta       P$Prior,y           and store the new priority in the target process descriptor
               rts                           return to the caller
ex@            comb                          set carry to indicate error
               ldb       #E$IPrcID           illegal process ID
               rts                           return to the caller

               else

FSPrior        lda       R$A,u               get process #
               lbsr      L0B2E               get pointer to it
               bcs       L07C0               error, return
               ldx       <D.Proc             get current process
               ldd       P$User,x            get user #
               beq       L07B7               super user, go set priority
               cmpd      P$User,y            user #'s match?
               bne       L07BD               no, return error
L07B7          lda       R$B,u               get new priority
               sta       P$Prior,y           set it
               clrb                          clear errors
               rts                           return
L07BD          comb                          set carry for error
               ldb       #E$BPrcID
L07C0          rts

               endc