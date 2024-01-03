;;; FTOEOF
;;;
;;; Seek to end of file.
;;;
;;; Entry:  A = The path to print to.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

                    section   .text

FTOEOF:             pshs      x,u
                    ldb       #SS.Size            first get filesize
                    os9       I$GetStt
                    bcs       exit
                    os9       I$Seek              seek to end of file
exit:               puls      x,u,pc

                    endsect
