************************************************
* Path option routines for SCF

                    use       scf.d

                    section   .bss
orgopts             rmb       OPTCNT
modopts             rmb       OPTCNT
                    endsect

                    section   .text

getopts             leax      modopts,u
getnonmodopts       ldb       #SS.Opt
                    os9       I$GetStt
                    rts

setopts             leax      modopts,u
setnonmodopts       ldb       #SS.Opt
                    os9       I$SetStt
                    rts

;;; SAVEOPTS
;;;
;;; Save path options.
;;;
;;; Entry:  A = The path to save the options for.
;;;
;;; Exit:   None.

SAVEOPTS            pshs      d,x
                    leax      orgopts,u           point to original options buffer
                    bsr       getnonmodopts
                    bcs       ex@                 branch if error
                    bsr       getopts
ex@                 puls      d,x,pc

;;; RESTOREOPTS
;;;
;;; Save path options.
;;;
;;; Entry:  A = The path to restore the options for.
;;;
;;; Exit:   None.

RESTOREOPTS         pshs      d,x
                    leax      orgopts,u           point to original options buffer
                    bsr       setnonmodopts
ex@                 puls      d,x,pc


;;; MAKERAW
;;;
;;; Put the path in a raw state.
;;;
;;; Entry:  A = The path to set the raw state for.
;;;
;;; Exit:   None.

MAKERAW             pshs      d,x
                    leax      modopts,u
                    leax      PD.UPC-PD.OPT,x
                    ldb       #PD.QUT-PD.UPC
l@                  clr       ,x+
                    decb
                    bpl       l@
                    bsr       setopts
ex@                 puls      d,x,pc

;;; SETQUITCHAR
;;;
;;; Set the Quit character.
;;;
;;; Entry:  A = The path to set the character.
;;;         B = The quit character to set.
;;;
;;; Exit:   None.

SETQUITCHAR         pshs      d,x
                    leax      modopts,u
                    stb       PD.QUT-PD.OPT,x
                    bsr       setopts
ex@                 puls      d,x,pc

;;; SETECHO
;;;
;;; Set the echo for the path.
;;;
;;; Entry:  A = The path to set the echo for.
;;;         B = The echo flag (1 = echo, 0 = don't echo).
;;;
;;; Exit:   None.

SETECHO             pshs      d,x
                    leax      modopts,u
                    stb       PD.EKO-PD.OPT,x
                    bsr       setopts
ex@                 puls      d,x,pc

                    endsect
