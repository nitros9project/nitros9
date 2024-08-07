                    section   code
                    
                    export    _chdir
                    export    _chxdir

;;; int chdir(char *dirname)
;;;
;;; Change the data directory.
;;;
;;; This function changes the data directory of the calling process.
;;;
;;; Returns: 0 on success, or -1 on error.

_chdir              lda       #1
chex                ldx       2,s
                    os9       I$ChgDir
                    lbra      _sysret

;;; int chxir(char *dirname)
;;;
;;; Change the execution directory.
;;;
;;; This function changes the execution directory of the calling process.
;;;
;;; Returns: 0 on success, or -1 on error.

_chxdir             lda       #4
                    bra       chex

                    endsect

