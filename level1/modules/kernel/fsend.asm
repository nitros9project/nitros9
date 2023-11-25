;;; F$Send
;;;
;;; Send a signal to a process.
;;;
;;; Entry:  A = The process ID of the process to receive the signal.
;;;         B = The signal to send.
;;;
;;; Exit:  CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; The signal is a single byte value in the rage 0 through 255. If the destination process
;;; is sleeping or waiting, the kernel activates the process so that it can process the signal.
;;; If the process installed a signal intercept routine using F$Icpt, F$Send calls into it.
;;; Otherwise, the signal terminates the receiving process, and the process returns that
;;; signal as its exit status. An exception is the wakeup signal: S$Wake. It doesn't cause
;;; the kernel to invoke signal intercept routine.
;;;
;;; The signal codes are:
;;;
;;;            - S$Kill - terminate the process (cannot be intercepted)
;;;            - S$Wake - wake up the process.
;;;            - S$Abort - keyboard termination sequence typed
;;;            - S$Intrpt - keyboard interrupt sequence typed
;;;
;;; The kernel reserves all signal between 0 and 127. Signals 128 to 255 are user-defined
;;; and can be used for interprocess communication.
;;;
;;; If you call F$Send for a process that has a signal pending, the kernel returns an error.
;;; In that case, call F$Sleep for a few ticks to save CPU time, then try F$Send again.

               ifeq      Level-1

FSend          lda       R$A,u               get the process ID of recipient
               bne       getprocess@         if not 0, go find the process descriptor
               inca                          else increment A
L0242          ldx       <D.Proc             get the current process descriptor
               cmpa      P$ID,x              and the process ID
               beq       L024A               branch if 0
               bsr       getprocess@         else go find the process descriptor
L024A          inca                          increase A by 1
               bne       L0242               branch if not error
               clrb                          clear the carry
               rts                           return to the caller
getprocess@    ldx       <D.PrcDBT           get the process descriptor table pointer
               os9       F$Find64            find the 64 byte page associated with the process iD
               bcc       L025E               branch if found
               ldb       #E$IPrcID           else return an illegal process ID error
               rts                           return to the caller
badid@         comb                          set the carry flag
               ldb       #E$IPrcID           return an illegal process ID error
               puls      pc,y,a              recover the stack and return to the caller
* Entry: A = recipient process ID
L025E          pshs      y,a                 save the receipient process descriptor and
               ldb       R$B,u               get the signal to send from the caller
               bne       checkpending@       branch if not S$Kill
               ldx       <D.Proc             else get current process descriptor
               ldd       P$User,x            and its user id
               beq       condemn@            branch if super user ID (it can send S$Kill)
               cmpd      P$User,y            same as user of recipient process?
               bne       badid@              no, cannot send S$Kill to another user's process
condemn@       lda       P$State,y           get state of recipient
               ora       #Condem             set condemn bit
               sta       P$State,y           and set it back
checkpending@  orcc      #FIRQMask+IRQMask   mask interrupts
               lda       <P$Signal,y         get the recipient's pending signal, if any
               beq       sendit@             branch if there is none
               deca                          is the pending signal the wake signal?
               beq       sendit@             branch if so
               comb                          else set the carry flag
               ldb       #E$USigP            indicate signal already pending
               puls      pc,y,a              recover the stack and return to the caller
sendit@        ldb       R$B,u               get the signal to send from the caller
               stb       <P$Signal,y         store it in the recipient process descriptor
               ldx       #(D.SProcQ-P$Queue) get pointer to sleep queue
               bra       findprocess@        go find the process
match@         cmpx      $01,s               same as process descriptor of recipient?
               bne       findprocess@        branch if not
               lda       P$State,x           else get state of recipient
               bita      #TimSleep           is it in a timed sleep?
               beq       activate@           branch if not
               ldu       P$SP,x              else get recipient stack pointer
               ldd       R$X,u               get the number of ticks it's sleeping
               beq       activate@           if X == 0 (sleep forever), then branch
               ldu       P$Queue,x           get the queue pointer of the recipient
               beq       activate@           branch if empty
               pshs      b,a                 save off D temporarily
               lda       P$State,u           get the process' state
               bita      #TimSleep           is it in a timed sleep
               puls      b,a                 restore D
               beq       activate@           branch if it isn't
               ldu       P$SP,u              else get recipient stack pointer
               addd      P$SP,u              add it to D
               std       P$SP,u              save it back
               bra       activate@           and continue
findprocess@   leay      ,x                  point Y to the sender's process descriptor
               ldx       P$Queue,y           get the pointer to its current queue
               bne       match@              branch if not empty
               ldx       #(D.WProcQ-P$Queue) else load X with the wait queue pointer
loop@          leay      ,x                  set Y to that entry
               ldx       P$Queue,y           and load X with the queue pointer of that process
               beq       ex@                 branch if empty
               cmpx      $01,s               is it the recipient process descriptor?
               bne       loop@               branch if not
activate@      ldd       P$Queue,x           get the queue pointer in the first process descriptor
               std       P$Queue,y           and save it to the second process descriptor
               lda       <P$Signal,x         get the signal from the first process descriptor
               deca                          decrement it
               bne       noclear@            branch if not 0 (wasn't S$Wake)
               sta       <P$Signal,x         clear the signal in the first process descriptor
noclear@       os9       F$AProc             insert it into the active queue
ex@            clrb                          clear carry
               puls      pc,y,a              restore registers and return to the caller

               else

FSend          ldx       <D.Proc             get current process pointer
               lda       R$A,u               get destination ID
               bne       L0652               it's ok, go on
               inca                          add one
* Send signal to ALL process's
L0647          cmpa      P$ID,x              find myself?
               beq       L064D               yes, skip it
               bsr       L0652               send the signal
L064D          inca                          move to next process
               bne       L0647               go send it
               clrb                          clear errors
               rts                           return

* X   = process descriptor ptr of singal sender
* A   = process ID to send signal to
* R$B = signal code
L0652          lbsr      L0B2E               get pointer to destination descriptor
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
L066A          puls      cc,a,y,u,pc         return

* Y = process descriptor of process receiving signal
L066D          orcc      #IntMasks           shut down IRQ's
               ldb       R$B,u               get signal code
               bne       L067B               not a kill signal, skip ahead
               ldb       #E$PrcAbt           get error 228
               ifne      H6309
               oim       #Condem,P$State,y   condem process
L067B          aim       #^Suspend,P$State,y take process out of suspend state
               else
               lda       P$State,y
               ora       #Condem
               sta       P$State,y
L067B          lda       P$State,y
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
L068F          stb       P$Signal,y          save signal code in descriptor
               ldx       #(D.SProcQ-P$Queue) get pointer to sleeping process queue
               ifne      H6309
               clrd                          Faster than 2 memory clears
               else
               clra
               clrb
               endc
L0697          leay      ,x                  point Y to this process
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
L06CF          leas      2,s
               bra       L06E0
L06D3          ldx       #(D.WProcQ-P$Queue)
L06D6          leay      ,x
               ldx       P$Queue,x
               beq       L06F4
               cmpx      2,s
               bne       L06D6
L06E0          ldd       P$Queue,x
               std       P$Queue,y
               lda       P$Signal,x
               deca
               bne       L06F1
               sta       P$Signal,x
               lda       ,s
               tfr       a,cc
L06F1          os9       F$AProc             activate the process
L06F4          puls      cc,a,y,u,pc         restore & return

               endc