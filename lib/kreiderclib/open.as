                    export    _open
                    export    _close

                    section   code
                    
_open               ldx       2,s
                    lda       5,s
                    os9       I$Open
                    lblo      _os9err
                    tfr       a,b
                    clra
                    rts
                    
;;; void close(int pn)
;;;
;;; Close an open file.
;;;
;;; This function closes an open file. Closing files manages system resources and allows
;;; the re-use of path numbers.
;;;
;;; When a process terminates, the system closes is open files automatically.

_close              lda       3,s
                    os9       I$Close
                    lbra      _sysret

                    endsect

