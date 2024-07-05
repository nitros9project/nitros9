                    export    _chown
                    
                    section   code

;;; int chown(char *fname, int id)
;;;
;;; Change a file's permissions.
;;;
;;; This function changes the ownership of a file by changing the ID in the file descriptor. Only the
;;; super user can successfully call this function.
;;;
;;; Returns: 0 on success, or -1 on error.

_chown              pshs      y,u
                    leas      -16,s
                    os9       F$ID
                    bcs       L002a
                    ldb       #$d6
                    cmpy      #0
                    orcc      #1
                    bne       L002a
                    bsr       L0032
                    bcs       L002a
                    pshs      a
                    ldd       25,s
                    std       1,x
                    puls      a
                    ldb       #$0f
                    os9       I$SetStt
                    bcs       L002a
                    os9       I$Close
L002a               leas      16,s
                    puls      y,u
                    lbra      _sysret
L0032               lda       #2
                    ldx       24,s
                    os9       I$Open
                    bcc       L003d
                    rts
L003d               leax      2,s
                    ldy       #$0010
                    ldb       #$0f
                    os9       I$GetStt
                    rts

                    endsect

