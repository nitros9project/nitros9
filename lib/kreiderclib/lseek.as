* Disassembly by Os9disasm of lseek.r

                    section   code

* OS-9 system function equates

I$Seek              equ       $88
I$GetStt            equ       $8d

lseek               pshs      u
                    ldd       10,s
                    bne       L000e
                    ldu       #0
                    ldx       #0
                    bra       L0042
L000e               cmpd      #1
                    beq       L0039
                    cmpd      #2
                    beq       L002e
                    ldb       #247
L001c               clra
                    std       errno,y
                    ldd       #-1
                    leax      _flacc,y
                    std       ,x
                    std       2,x
                    puls      u,pc
L002e               lda       5,s
                    ldb       #2
                    os9       I$GetStt
                    bcs       L001c
                    bra       L0042
L0039               lda       5,s
                    ldb       #5
                    os9       I$GetStt
                    bcs       L001c
L0042               tfr       u,d
                    addd      8,s
                    std       _flacc+2,y
                    tfr       d,u
                    tfr       x,d
                    adcb      7,s
                    adca      6,s
                    bmi       L001c
                    tfr       d,x
                    std       _flacc,y
                    lda       5,s
                    os9       I$Seek
                    bcs       L001c
                    leax      _flacc,y
                    puls      u,pc

                    endsect

