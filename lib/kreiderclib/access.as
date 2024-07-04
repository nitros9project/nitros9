                    export    access
                    export    mknod
                    export    unlinkx
                    export    unlink
                    export    dup
                    
                    section   code

access              ldx       2,s
                    lda       5,s
                    os9       I$Open
                    bcs       L000c
                    os9       I$Close
L000c               lbra      _sysret

mknod               ldx       2,s
                    ldb       5,s
                    os9       I$MakDir
                    lbra      _sysret
                    
unlinkx             lda       5,s
                    bra       L001f
                    
unlink              lda       #2
L001f               ldx       2,s
                    os9       I$DeletX
                    lbra      _sysret
                    
dup                 lda       3,s
                    os9       I$Dup
                    lblo      _os9err
                    tfr       a,b
                    clra
                    rts

                    endsect

