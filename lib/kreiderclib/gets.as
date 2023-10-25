* Disassembly by Os9disasm of gets.r

                    section   code

gets                pshs      u
                    ldu       4,s
                    bra       L0008
L0006               stb       ,u+
L0008               leax      _iob,y
                    pshs      x
                    lbsr      getc
                    leas      2,s
                    cmpb      #$0d
                    beq       L0021
                    cmpd      #-1
                    bne       L0006
                    clra
                    clrb
                    bra       L0025
L0021               clr       ,u
                    ldd       4,s
L0025               puls      u,pc
fgets               pshs      u
                    ldx       4,s
                    clr       ,x
                    ldu       6,s
                    beq       L0060
                    pshs      x
                    bra       L003f
L0035               ldx       ,s
                    stb       ,x+
                    stx       ,s
                    cmpb      #$0d
                    beq       L0054
L003f               leau      -1,u
                    stu       -2,s
                    beq       L0054
                    ldd       10,s
                    pshs      d
                    lbsr      getc
                    leas      2,s
                    cmpd      #-1
                    bne       L0035
L0054               clr       [,s]
                    cmpd      #-1
                    bne       L0060
                    clra
                    clrb
                    bra       L0062
L0060               ldd       6,s
L0062               leas      2,s
                    puls      u,pc

                    endsect

