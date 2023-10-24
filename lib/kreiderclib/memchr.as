* Disassembly by Os9disasm of memchr.r

                    section   code

memchr              pshs      x,u
                    ldu       6,s
                    ldx       10,s
                    beq       L0018
L0008               lda       ,u+
                    cmpa      9,s
                    bne       L0014
                    leau      -1,u
                    tfr       u,d
                    bra       L001a
L0014               leax      -1,x
                    bne       L0008
L0018               clra
                    clrb
L001a               puls      x,u,pc

                    endsect

