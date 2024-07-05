;;; void abort(void)
;;;
;;; Stop the program and produce a core dump.
;;;
;;; Calling this function causes a memory image to be written out to the file "core" in the current directory.
;;; The program then exits with a status of 1.

                    export    _abort
                    
                    section   code

_abort              pshs      d,x,y,u
                    leax      >corename,pcr
                    ldb       #3
                    clra
                    pshs      d
                    pshs      x
                    lbsr      creat
                    cmpd      #-1
                    bne       L001d
                    ldd       errno,y
                    os9       F$Exit
L001d               leas      4,s
                    pshs      b
                    leax      1,s
                    ldd       #$0010
                    bsr       L004e
                    leax      _cstart,pcr
                    ldd       #etext
                    subd      #_cstart
                    bsr       L004e
                    tfr       dp,a
                    clrb
                    tfr       d,x
                    subd      memend,x
                    nega
                    negb
                    sbca      #0
                    bsr       L004e
                    ldb       #255
                    os9       F$Exit
                    
corename            fcc       "core "
                    fcb       C$CR

L004e               pshs      d,x
                    lda       6,s
                    leax      2,s
                    ldy       #2
                    os9       I$Write
L005b               leax      ,s
                    lda       6,s
                    ldy       #2
                    os9       I$Write
                    puls      y
                    puls      x
                    cmpy      #0
                    beq       L0075
                    lda       2,s
                    os9       I$Write
L0075               rts

                    endsect

