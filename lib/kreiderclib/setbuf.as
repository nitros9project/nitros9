* Disassembly by Os9disasm of setbuf.r

                    section   code

setbuf              pshs      u
                    ldu       4,s
                    lda       6,u
                    anda      #1
                    beq       L0011
                    pshs      u
                    lbsr      fflush
                    leas      2,s
L0011               ldd       6,u
                    anda      #254
                    andb      #$f3
                    std       6,u
                    ldx       6,s
                    beq       L002e
                    ldd       11,u
                    bne       L0026
                    ldd       #$0100
                    std       11,u
L0026               stx       2,u
                    leax      d,x
                    ldb       #8
                    bra       L0032
L002e               leax      11,u
                    ldb       #4
L0032               orb       7,u
                    stb       7,u
                    stx       4,u
                    stx       ,u
                    puls      u,pc

                    endsect

