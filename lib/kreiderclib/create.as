                    export    _creat
                    export    _create
                    export    _ocreat
                    
                    section   code

_creat              ldx       2,s
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

_create             ldx       2,s
                    lda       5,s
                    ldb       7,s
                    os9       I$Create
                    bcs       L0039
                    bra       L005d
L0049               cmpb      #$da
                    bne       L0039
                    os9       I$Delete
                    bcs       L0039
                    
_ocreat             ldx       2,s
                    lda       5,s
                    ldb       7,s
                    os9       I$Create
                    bcs       L0049
L005d               tfr       a,b
                    clra
                    rts

                    endsect

