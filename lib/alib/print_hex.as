;;; PRINT_HEX
;;;
;;; Print a hexadecimal number to the standard output.
;;;
;;; Entry:  D = The value to print.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

PRINT_HEX:          pshs      a,x
                    leas      -6,s                buffer
                    tfr       s,x
                    lbsr      BIN_HEX             convert to hex
                    lbsr      PUTS                print to standard out
                    leas      6,s                 clean stack
                    puls      a,x,pc              return with error in B

                    endsect

