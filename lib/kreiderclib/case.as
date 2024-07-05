                    export    _toupper
                    export    _tolower
                    
                    section   code

;;; #include <ctype.h>
;;;
;;; int toupper(int c)
;;;
;;; Convert a character to its uppercase representation.
;;;
;;; This function returns the uppercase value of the passed character.
;;;
;;; Returns: The uppercase representation if c is between a and z, or the passed character.

_toupper            clra
                    ldb       3,s
                    leax      _chcodes,y
                    lda       d,x
                    anda      #4
                    beq       L0022
                    andb      #$df
                    clra
                    rts

;;; #include <ctype.h>
;;;
;;; int tolower(int c)
;;;
;;; Convert a character to its lowercase representation.
;;;
;;; This function returns the lowercase value of the passed character.
;;;
;;; Returns: The lowercase representation if c is between A and Z, or the passed character.

_tolower            clra
                    ldb       3,s
                    leax      _chcodes,y
                    lda       d,x
                    anda      #2
                    beq       L0022
                    orb       #$20
                    clra
                    rts
L0022               ldd       2,s
                    rts

                    endsect

