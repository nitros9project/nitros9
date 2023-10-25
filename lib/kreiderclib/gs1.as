* Disassembly by Os9disasm of gs1.r

                    section   code

* OS-9 system function equates

I$GetStt            equ       $8d

_gs_size            ldb       #2
                    bra       L0006
_gs_pos             ldb       #5
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

