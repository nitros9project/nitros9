* Disassembly by Os9disasm of defdrive.r

* class D external label equates

D0000               equ       $0000

* class X external label equates

X0000               equ       $0000

                    section   bss

* Uninitialized data (class B)
B0000               rmb       12
* Initialized Data (class G)

                    endsect

                    section   code

getdrive            pshs      u
                    leas      -7,s
                    clra
                    clrb
                    pshs      d
                    ldd       #$000c
                    pshs      d
                    leax      >L0061,pcr
                    pshs      x
                    lbsr      modlink
                    leas      6,s
                    std       ,s
                    cmpd      #-1
                    beq       L005b
                    ldd       ,s
                    ldx       ,s
                    addd      16,x
                    std       5,s
                    leau      B0000,y
                    bra       L0033
L002f               ldb       4,s
                    stb       ,u+
L0033               ldx       5,s
                    leax      1,x
                    stx       5,s
                    ldb       -1,x
                    stb       4,s
                    bgt       L002f
                    ldb       4,s
                    clra
                    andb      #$7f
                    stb       ,u+
                    clra
                    clrb
                    stb       ,u
                    ldd       ,s
                    pshs      d
                    lbsr      munlink
                    leas      2,s
                    leax      B0000,y
                    tfr       x,d
                    bra       L005d
L005b               clra
                    clrb
L005d               leas      7,s
                    puls      u,pc
L0061               rola
                    jmp       9,s
                    fcb       $74
                    fcb       $00

                    endsect

