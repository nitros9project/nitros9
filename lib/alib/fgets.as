                    section   .text

;;; FGETC_NOCR
;;;
;;; Read a string from a device and removes the carriage return from the input.
;;;
;;; Entry:  A = The path to read the string from.
;;;         X = The address of the buffer that holds the string.
;;;         Y = The maximum buffer size minus 1 (for the null character).
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; The string entered must end with an end-of-record char (usually a $0D). The null is appended for ease in string handling.

FGETS_NOCR:         pshs      d,x
                    bsr       FGETS
                    bcs       bye
                    tfr       y,d
                    leax      -1,x
                    clr       d,x
bye                 puls      d,x,pc

;;; FGETC
;;;
;;; Read a string from a device.
;;;
;;; Entry:  A = The path to read the string from.
;;;         X = The address of the buffer that holds the string.
;;;         Y = The maximum buffer size minus 1 (for the null character).
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; The string entered must end with an end-of-record char (usually a $0D). The null is appended for ease in string handling.

FGETS:              pshs      a,x
                    os9       I$ReadLn            get line
                    bcs       exit                return error code
                    tfr       y,d
                    clr       d,x                 add null
                    clrb                          no error..

exit                puls      a,x,pc

                    endsect

