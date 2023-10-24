* Disassembly by Os9disasm of devtyp.r

                    section   code

* OS-9 system function equates

I$GetStt            equ       $8d

isatty              ldd       2,s
                    pshs      d
                    bsr       devtyp
                    std       ,s++
                    beq       L000c
                    clrb
                    rts
L000c               incb
                    rts
devtyp              lda       3,s
                    clrb
                    leas      -32,s
                    leax      ,s
                    os9       I$GetStt
                    lda       ,s
                    leas      32,s
                    lblo      _os9err
                    tfr       a,b
                    clra
                    rts

                    endsect

