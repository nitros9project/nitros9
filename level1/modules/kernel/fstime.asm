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

ClkName             fcs       /Clock/

FSTime              ldx       R$X,u               get caller's pointer to time packet
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
ex@                 rts
