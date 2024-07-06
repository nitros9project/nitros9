;;; PRINT_ASC
;;;
;;; Print a binary number to the standard output.
;;;
;;; Entry:  D = The value to print.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

PRINT_ASC:          pshs      a,x
                    leas      -18,s               buffer
                    tfr       s,x
                    lbsr      BIN_ASC             convert to ascii
                    lbsr      PUTS                print to standard out
                    leas      18,s                clean stack
                    puls      a,x,pc              return with error in B

                    endsect

