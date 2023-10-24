* Disassembly by Os9disasm of rand.r

* class D external label equates

D0000               equ       $0000

                    section   bss

* Initialized Data (class G)
G0000               fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $01

                    endsect

                    section   code

rand                pshs      u
                    leax      G0000,y
                    ldd       ,x
                    ldu       2,x
                    pshs      d,u
                    leax      >L003d,pcr
                    lbsr      _lmul
                    ldd       ,x
                    ldu       2,x
                    pshs      d,u
                    leax      >L0041,pcr
                    lbsr      _ladd
                    leau      G0000,y
                    ldd       ,x
                    ldx       2,x
                    std       ,u
                    stx       2,u
                    anda      #$7f
                    puls      u,pc
srand               leax      G0000,y
                    ldd       2,s
                    std       2,x
                    clra
                    clrb
                    std       ,x
                    rts
L003d               fcb       $41
                    ldb       #$4e
                    fcb       $6d
L0041               neg       D0000
                    leax      -7,y

                    endsect

