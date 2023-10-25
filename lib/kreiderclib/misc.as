* Disassembly by Os9disasm of misc.r

                    section   code

* OS-9 system function equates

F$Sleep             equ       $0a
F$PErr              equ       $0f
F$CRC               equ       $17

lock                rts
pause               ldx       #0
                    clrb
                    os9       F$Sleep
                    lbra      _os9err
sync                rts
crc                 pshs      y,u
                    ldx       6,s
                    ldy       8,s
                    ldu       10,s
                    os9       F$CRC
                    puls      y,u,pc
prerr               lda       3,s
                    ldb       5,s
                    os9       F$PErr
                    lblo      _os9err
                    rts
tsleep              ldx       2,s
                    os9       F$Sleep
                    lblo      _os9err
                    tfr       x,d
                    rts

                    endsect

