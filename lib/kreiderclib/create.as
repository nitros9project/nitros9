* Disassembly by Os9disasm of create.r

                    section   code

* OS-9 system function equates

I$Create            equ       $83
I$Open              equ       $84
I$Delete            equ       $87
I$SetStt            equ       $8e
I$Close             equ       $8f

creat               ldx       2,s
                    lda       5,s
                    tfr       a,b
                    andb      #$24
                    orb       #$0b
                    os9       I$Create
                    bcc       L005d
                    cmpb      #$da
                    bne       L0039
                    lda       5,s
                    bita      #$80
                    bne       L0039
                    anda      #7
                    ldx       2,s
                    os9       I$Open
                    bcs       L0039
                    pshs      a,u
                    ldx       #0
                    leau      ,x
                    ldb       #2
                    os9       I$SetStt
                    puls      a,u
                    bcc       L005d
                    pshs      b
                    os9       I$Close
                    puls      b
L0039               lbra      _os9err
create              ldx       2,s
                    lda       5,s
                    ldb       7,s
                    os9       I$Create
                    bcs       L0039
                    bra       L005d
L0049               cmpb      #$da
                    bne       L0039
                    os9       I$Delete
                    bcs       L0039
ocreat              ldx       2,s
                    lda       5,s
                    ldb       7,s
                    os9       I$Create
                    bcs       L0049
L005d               tfr       a,b
                    clra
                    rts

                    endsect

