                    export    _allocset
                    export    _addc2set
                    export    _adds2set
                    export    _rmfmset
                    export    _smember
                    export    _dupset
                    export    _copyset
                    export    _sunion
                    export    _sinterse
                    export    _sdiffere
                    
                    section   code

_allocset           ldd       #$0020
                    pshs      d
                    lbsr      _malloc
                    puls      x,pc
                    
_addc2set           bsr       L003a
                    orb       a,x
                    stb       a,x
                    tfr       x,d
                    rts
                    
_adds2set           pshs      u
                    ldu       6,s
                    ldx       4,s
                    bra       L0021
L001b               bsr       L003e
                    orb       a,x
                    stb       a,x
L0021               lda       ,u+
                    bne       L001b
                    ldd       4,s
                    puls      u,pc
                    
_rmfmset            bsr       L003a
                    comb
                    andb      a,x
                    stb       a,x
                    clrb
                    tfr       x,d
                    rts
                    
_smember            bsr       L003a
                    andb      a,x
                    clra
                    rts
L003a               ldx       4,s
                    lda       7,s
L003e               pshs      a
                    ldb       #1
                    anda      #7
                    beq       L004a
L0046               lslb
                    deca
                    bne       L0046
L004a               puls      a
                    asra
                    asra
                    asra
                    rts
                    
_dupset             bsr       _allocset
                    ldx       2,s
                    pshs      d,x
                    bsr       _copyset
                    puls      d,x,pc
                    
_copyset            pshs      u
                    ldx       4,s
                    ldu       6,s
                    ldb       #$20
L0062               lda       ,u+
                    sta       ,x+
                    decb
                    bne       L0062
                    ldd       4,s
                    puls      u,pc
                    
_sunion             pshs      u
                    ldu       4,s
                    ldx       6,s
                    ldb       #$20
L0075               lda       ,x+
                    ora       ,u
                    sta       ,u+
                    decb
                    bne       L0075
                    ldd       4,s
                    puls      u,pc

_sinterse           pshs      u
                    ldu       4,s
                    ldx       6,s
                    ldb       #$20
L008a               lda       ,x+
                    anda      ,u
                    sta       ,u+
                    decb
                    bne       L008a
                    ldd       4,s
                    puls      u,pc

_sdiffere           pshs      u
                    ldu       4,s
                    ldx       6,s
                    ldb       #$20
L009f               lda       ,x+
                    eora      ,u
                    sta       ,u+
                    decb
                    bne       L009f
                    ldd       4,s
                    puls      u,pc

                    endsect

