;;; GETFMD
;;;
;;; Get the last modified date/time of a file.
;;
;;; Entry:  A = The path of the file.
;;;         X = A 6-byte buffer that holds the date/time.
;;;
;;; Exit:   None.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; Even though OS-9 doesn't save seconds in its files, this routine stores a zero in this position.
;;; This is done to make the routine compatible with DATESTR.

                    section   .text

BUFSIZ              equ       8

GETFMD:             pshs      x,y
                    leas      -BUFSIZ,s           where to put FD sector info
                    tfr       s,x                 pointer for FD sector info
                    ldy       #BUFSIZ             bytes to read from FD sector
                    ldb       #$0F                SS.FD
                    os9       I$GetStt
                    bcs       exit
                    ldy       BUFSIZ,s            get back orig X
                    ldx       3,s                 get 2 bytes
                    stx       ,y++                move year,month
                    ldx       5,s
                    stx       ,y++                move date,hour
                    lda       7,s
                    sta       ,y+                 move minutes
                    clr       ,y                  null for seconds

exit                leas      BUFSIZ,s
                    puls      x,y,pc

                    endsect

