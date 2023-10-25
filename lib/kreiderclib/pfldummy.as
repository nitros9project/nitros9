* Disassembly by Os9disasm of pfldummy.r

                    section   bss

* Initialized Data (class G)
                    fcb       $6c
                    fcb       $78
G0002               fcb       $00

                    endsect

                    section   code

pflong              ldb       3,s
                    leax      G0002,y
                    cmpb      #$64
                    beq       L001a
                    cmpb      #$6f
                    beq       L001a
                    cmpb      #$78
                    beq       L001a
                    cmpb      #$58
                    beq       L001a
                    leax      -2,x
                    stb       1,x
L001a               tfr       x,d
                    rts

                    endsect

