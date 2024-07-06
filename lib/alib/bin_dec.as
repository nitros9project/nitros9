* BGP - 04/11/2009 - Fixed issue where BIN_DEC was printing negative
* sign in certain cases.  Cleared nega flag to fix issue.


                    section   .bss
nega                rmb       1
                    endsect

                    section   .text

;;; BIN_SDEC
;;;
;;; Binary to signed decimal string conversion.
;;;
;;; OTHER MODULES NEEDED: DECTAB$
;;;
;;; Entry:  D = The binary value to convert.
;;;         X = The address of the buffer that holds the ASCII string.
;;;
;;; Exit:  None.
;;;
;;; All registers (except CC) are preserved.

BIN_SDEC:
                    clr       nega,u
                    tsta
                    bpl       BIN_DEC
                    sta       nega,u
                    comb
                    coma
                    addd      #$0001
                    bra       BIN_DEC_COMMON      +++ added BGP

;;; BIN_DEC
;;;
;;; Binary to unsigned decimal string conversion.
;;;
;;; OTHER MODULES NEEDED: DECTAB$
;;;
;;; Entry:  D = The binary value to convert.
;;;         X = The address of the buffer that holds the ASCII string.
;;;
;;; Exit:  None.
;;;
;;; All registers (except CC) are preserved.

BIN_DEC:
                    clr       nega,u              +++ added BGP
BIN_DEC_COMMON
                    pshs      a,b,x,y
                    lda       #7                  clear out 7 bytes in buffer

bindc1
                    clr       ,x+
                    deca
                    bne       bindc1
                    ldx       2,s                 restore buffer start address
                    ldd       ,s                  get data
                    bne       bindc2              not 0, do convert
                    lda       #'0
                    sta       ,x
                    bra       bindc8              exit

bindc2
                    tst       nega,u
                    beq       bindc25
                    pshs      a
                    lda       #'-
                    sta       ,x+
                    puls      a
bindc25
                    leay      DECTAB$,pcr         point to conversion table
                    clr       ,--s                temps, flag 1st dgt not placed

bindc3
                    clr       1,s                 current digit=0

bindc4
                    subd      ,y                  sub table element
                    bcs       bindc5              too far, correct
                    inc       1,s                 bump digit
                    bra       bindc4              loop til done

bindc5
                    addd      ,y                  restore, 1 too many subtracts
                    pshs      a,b                 save rest of number
                    lda       3,s                 get the digit
                    adda      #$30                make it ascii
                    cmpa      #'0                 is it zero?
                    bne       bindc6              no, skip
                    tst       2,s                 is it 1st digit in string?
                    beq       bindc7              yes, don't do leading 0s

bindc6
                    inc       2,s                 indicate at least 1 digit
                    sta       ,x+                 save in buffer

bindc7
                    leay      2,y                 next table entry
                    tst       1,y                 end of table
                    puls      a,b                 restore data
                    bne       bindc3              no..loop
                    leas      2,s

bindc8
                    puls      a,b,x,y,pc          restore and return

                    endsect

