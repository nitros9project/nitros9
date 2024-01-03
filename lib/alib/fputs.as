;;; FPUTS
;;;
;;; Prints a null-terminated string to a device.
;;;
;;; Entry:  A = The path to print to.
;;;         X = The address of the string to print.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; I$WritLn prints the string, so additional character processing may occur.

                    section   .text

FPUTS:              pshs      a,x,y,u
                    tfr       x,u                 start of 1st segment to print

loop                pshs      u                   start of this segment
                    ldy       #-1                 size of this seg.

l1                  leay      1,y                 count size
                    ldb       ,u+                 check for null/cr
                    beq       doit                null=do last seg.
                    cmpb      #$0d                cr=do this seg.
                    bne       l1
                    leay      1,y                 count CR as one of the ones to print

doit                puls      x                   get start of this segment
                    os9       I$WritLn
                    bcs       exit
                    tst       -1,u                at end?
                    bne       loop

exit                puls      a,x,y,u,pc          return with status in CC,error code in B

                    endsect
