* Disassembly by Os9disasm of findstr.r

                    section   code

findstr             pshs      y,u
                    bsr       L002c
                    bra       L0008
L0006               bsr       L000e
L0008               ldb       ,x
                    bne       L0006
                    bra       L0046
L000e               pshs      x,y
                    bsr       findastr
                    puls      x,y
                    bne       L001b
                    leau      1,u
                    leax      1,x
                    rts
L001b               tfr       u,d
                    puls      x,y,u,pc
findnstr            pshs      y,u
                    bsr       L002c
L0023               bsr       L000e
                    cmpu      12,s
                    ble       L0023
                    bra       L0046
L002c               ldu       8,s
                    tfr       u,d
                    ldx       10,s
                    leax      d,x
                    leax      -1,x
                    ldy       12,s
                    rts
findastr            pshs      y,u
                    ldu       6,s
                    ldx       8,s
                    bra       L004a
L0042               cmpb      ,u+
                    beq       L004a
L0046               clra
                    clrb
                    puls      y,u,pc
L004a               ldb       ,x+
                    bne       L0042
                    ldd       #1
                    puls      y,u,pc

                    endsect

