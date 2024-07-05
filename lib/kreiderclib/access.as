;;; int access(char *fname, int perms)
;;;
;;; Set a file's accessibility.
;;;
;;; This function returns zero if the access modes are correct for the user to access the file.
;;; If the file isn't accessible, the function returns -1.
;;;
;;; This function is useful to test the existence of a file without actually opening the file.
;;;
;;; The permissions value may be any legal OS-9 mode as used for open() or creat(). If it's 0, the
;;; function tests whether the file exists or the path to it is searchable.
;;;
;;;
;;; Note: The values for perms are NOT compatible with non-OS-9 systems.
;;;
;;; Returns: 0 on success, or -1 on error.

                    export    _access
                    export    _mknod
                    export    _unlinkx
                    export    _unlink
                    export    _dup
                    
                    section   code

_access             ldx       2,s
                    lda       5,s
                    os9       I$Open
                    bcs       L000c
                    os9       I$Close
L000c               lbra      _sysret

_mknod              ldx       2,s
                    ldb       5,s
                    os9       I$MakDir
                    lbra      _sysret
                    
_unlinkx            lda       5,s
                    bra       L001f
                    
_unlink             lda       #2
L001f               ldx       2,s
                    os9       I$DeletX
                    lbra      _sysret
                    
_dup                lda       3,s
                    os9       I$Dup
                    lblo      _os9err
                    tfr       a,b
                    clra
                    rts

                    endsect

