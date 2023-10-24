* Disassembly by Os9disasm of strlen.r

                    section   code

strlen              pshs      u
                    ldu       4,s
L0004               ldb       ,u+
                    bne       L0004
                    leau      -1,u
                    tfr       u,d
                    subd      4,s
                    puls      u,pc

                    endsect

