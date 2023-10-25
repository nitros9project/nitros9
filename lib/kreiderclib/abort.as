* Disassembly by Os9disasm of abort.r

                    section   code

* OS-9 system function equates

F$Exit              equ       $06
I$Write             equ       $8a

abort               pshs      d,x,y,u
                    leax      >L0048,pcr
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
L0048               com       15,s
                    fcb       $72
                    fcb       $65
                    bra       L005b
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

