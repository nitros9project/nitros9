* Disassembly by Os9disasm of write.r

                    section   code

* OS-9 system function equates

I$Write             equ       $8a
I$WritLn            equ       $8c

write               pshs      y
                    ldy       8,s
                    beq       L0015
                    lda       5,s
                    ldx       6,s
                    os9       I$Write
L000e               bcc       L0015
                    puls      y
                    lbra      _os9err
L0015               tfr       y,d
                    puls      y,pc
writeln             pshs      y
                    ldy       8,s
                    beq       L0015
                    lda       5,s
                    ldx       6,s
                    os9       I$WritLn
                    bra       L000e

                    endsect

