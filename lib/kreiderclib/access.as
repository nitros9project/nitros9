* Disassembly by Os9disasm of access.r

                    section   code

* OS-9 system function equates

I$Dup               equ       $82
I$Open              equ       $84
I$MakDir            equ       $85
I$Close             equ       $8f
I$DeletX            equ       $90

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

