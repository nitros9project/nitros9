                    export    _getpid
                    export    _getuid
                    export    _asetuid
                    export    _setuid
                    
                    section   code

* class X external label equates

X004b               equ       $004b

_getpid             pshs      y
                    os9       F$ID
                    puls      y
                    tfr       a,b
                    clra
                    rts
                    
_getuid             pshs      y
                    os9       F$ID
                    tfr       y,d
                    puls      y,pc
                    
;;; void asetuid(int uid)
;;;
;;; Set the user ID for the current process.
;;;
;;; This function sets the user ID number for the current task. Unlike setuid(), this call can be used even;;; if the user is not the super user.

_asetuid            pshs      y
                    bra       L0027
                    
_setuid             pshs      y
                    bsr       _getuid
                    std       -2,s
                    beq       L0027
                    ldb       #$d6
L0022               puls      y
                    lbra      _os9err
L0027               ldy       4,s
                    os9       F$SUser
                    bcc       L003b
                    cmpb      #$d0
                    bne       L0022
                    tfr       y,d
                    ldy       X004b
                    std       9,y
L003b               clra
                    clrb
                    puls      y,pc

                    endsect

