                    export    _lockdata
                    export    _unlkdata
                    export    _datlink
                    export    _dunlink
                    
                    section   code

;;; int lockdata(char *datptr)
;;;
;;; Lock a data module.
;;;
;;; This function attempts to lock the data module by changing the lock byte pointed to by datptr from -1 to 0.
;;;
;;; A data module is considered locked when it's loaded. It must be set for use by a call to unlkdata() after the original loader is finished.
;;; A user determines if they're the original owner by the value returned from datlink().
;;; In all cases, datptr points to the lock byte. User free space begins at datptr + 1.
;;;
;;; Returns: 0 on success, or -1 if the data module couldn't be locked.

_lockdata           ldx       2,s
                    pshs      cc
                    orcc      #IRQMask
                    inc       ,x
                    beq       L001d
                    ldb       ,x
                    dec       ,x
L000e               sex
                    puls      cc,pc
                    
;;; int unlkdata(char *datptr)
;;;
;;; Unlock a data module.
;;;
;;; This function unlocks the data module.
;;;
;;; Returns: 0 on success, or -1 if the data module isn't locked.

_unlkdata           ldx       2,s
                    pshs      cc
                    orcc      #IRQMask
                    ldb       ,x
                    bne       L000e
                    dec       ,x
L001d               clra
                    clrb
                    puls      cc,pc
                    
;;; int datlink(char *name, char *datptr, int *space)
;;;
;;; Link to a data module.
;;;
;;; This function loads (if necessary) and links to a module of name and sets datptr to the address of the data section, and sets space to the free space available.
;;;
;;; Returns: 0 on success, or -1 on error.

_datlink            pshs      y,u
                    clr       ,-s
                    clr       ,-s
                    ldx       8,s
                    lda       #Data
                    os9       F$Link
                    bcc       L0045
                    cmpb      #E$MNF
                    beq       L003a
                    coma
L0035               puls      x,y,u
                    lbra      _os9err
L003a               ldx       8,s
                    lda       #Data
                    os9       F$Load
                    bcs       L0035
                    inc       1,s
L0045               pshs      y
                    tfr       u,d
                    subd      ,s++
                    std       ,y++
                    sty       [10,s]
                    addd      2,u
                    subd      #5
                    std       [12,s]
                    ldd       ,s
                    beq       L0067
                    pshs      y
                    bsr       _lockdata
                    std       ,s++
                    beq       L0067
                    clr       1,s
L0067               puls      d,y,u,pc

;;; int dunlink(char *datpr)
;;;
;;; Unlink a data module.
;;;
;;; This function unlinks the data module, reducing the link count by 1.
;;;
;;; Returns: 0 on success, or -1 on error.

_dunlink            pshs      u
                    ldu       4,s
                    ldd       ,--u
                    leau      d,u
                    os9       F$UnLink
                    puls      u
                    lbra      _sysret

                    endsect

