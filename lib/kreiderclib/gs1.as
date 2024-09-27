                    export    __gs_size
                    export    __gs_pos
                    
                    section   code

__gs_size           ldb       #2
                    bra       L0006
                    
__gs_pos            ldb       #5
L0006               pshs      u
                    lda       5,s
                    os9       I$GetStt
                    bcc       L0019
                    ldx       #-1
                    tfr       x,u
                    clra
                    std       errno,y
L0019               stx       _flacc,y
                    leax      _flacc,y
                    stu       2,x
                    puls      u,pc

                    endsect

