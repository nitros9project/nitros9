;;; PRINT_DEC
;;;
;;; Print a decimal number to the standard output.
;;;
;;; Entry:  D = The value to print.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

PRINT_DEC:          pshs      a,x
                    leas      -8,s                buffer
                    tfr       s,x
                    lbsr      BIN_DEC             convert to decimal
                    lbsr      PUTS                print to standard out
                    leas      8,s                 clean stack
                    puls      a,x,pc              return with error in B

                    endsect

