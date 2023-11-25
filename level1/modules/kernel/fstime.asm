;;; F$STime
;;;
;;; Set the current system time.
;;;
;;; Entry:  X = The address of the current time.
;;;
;;; Exit:   The system's time is updated.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$STime sets the current system date and time. The packet format is:
;;;     - Year (one byte from 0-255 representing 1900-2155)
;;;     - Month (one byte from 1-12 representing the month)
;;;     - Day (one byte from 0-31 representing the day)
;;;     - Hour (one byte from 0-23 representing the hour)
;;;     - Minute (one byte from 0-59 representing the minute)
;;;     - Second (one byte from 0-59 representing the second)

               ifeq      Level-1

ClkName        fcs       /Clock/

FSTime         ldx       R$X,u               get caller's pointer to time packet
               ldd       ,x                  get year and month
               std       <D.Year             save to globals
               ldd       2,x                 get day and hour
               std       <D.Day              save to globals
               ldd       4,x                 get minute and second
               std       <D.Min              save to globals
               lda       #Systm+Objct        specify type and language
               leax      <ClkName,pcr        point to module name
               os9       F$Link              link to the module
               bcs       ex@                 branch if there's an error
               jmp       ,y                  jump into the initialization entry point
               clrb                          else clear B (this is useless and should be removed!)
ex@            rts

               else

FSTime         ldx       R$X,u               Get address that user wants time packet
***         tfr   dp,a            Set MSB of D to direct page
***         ldb   #D.Time         Offset to Time packet in direct page
***         tfr   d,u             Point U to it
               ldu       #D.Time             --- DP=0 always
               ldy       <D.Proc             Get ptr to process that called us
               lda       P$Task,y            Get task # from process
               ldb       <D.SysTsk           Get task # of system process
               ldy       #6                  6 byte packet to move
               os9       F$Move              Go move it
               ldx       <D.Proc             Get ptr to process that called us
               pshs      x                   Preserve it
               ldx       <D.SysPrc           Get ptr to system process
               stx       <D.Proc             Save as current process
               lda       #Systm+Objct        Link to Clock module
               leax      ClockNam,pc
               os9       F$Link
               puls      x                   Get back ptr to user's process
               stx       <D.Proc             Make it the active process again
               bcs       ex@                 If error in Link, exit with error code
               jmp       ,y                  Jump into Clock
ex@            rts

ClockNam       fcs       /Clock/

               endc