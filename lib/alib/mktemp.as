;;; MKTEMP
;;;
;;; Create a temporary file.
;;;
;;; Other modules needed: BIN_HEX
;;;
;;; Entry:  D = The address of the filename.
;;;
;;; All registers except CC are preserved.
;;;
;;; This subroutine creates a temporary filename by adding a "." and a two digit hexadecimal
;;; value based on the process ID.
;;;
;;; IMPORTANT: there must be room after the filename
;;; for at least 6 bytes. Filenames must be in variable
;;; area, not parameter or program sections.

                    section   .text

MKTEMP:             pshs      d,x,y

                    os9       F$PrsNam            find end of name
                    tfr       y,x

                    lda       #'.
                    sta       ,x+                 put "." in name

                    os9       F$ID
                    tfr       a,b                 convert to 4 digit hex
                    lbsr      BIN2HEX
                    std       ,x++
                    lda       #$0d                end name with cr
                    sta       ,x
                    puls      d,x,y,pc

                    endsect
