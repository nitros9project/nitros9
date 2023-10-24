* Disassembly by Os9disasm of memory.r

                    section   bss

* Uninitialized data (class B)
B0000               rmb       2
B0002               rmb       2
* Initialized Data (class G)
G0000               fcb       $00
                    fcb       $00

                    endsect

                    section   code

L0000               ldd       2,s
                    addd      #$00ff
                    clrb
                    pshs      d
                    lslb
                    rola
                    lslb
                    rola
                    pshs      d
                    lbsr      sbrk
                    leas      2,s
                    puls      u
                    cmpd      #-1
                    beq       L002b
                    exg       d,u
                    std       2,u
                    leau      4,u
                    pshs      u
                    bsr       free
                    leas      2,s
                    ldu       G0000,y
L002b               rts
malloc              pshs      d,u
                    ldd       6,s
                    addd      #3
                    lsra
                    rorb
                    lsra
                    rorb
                    addd      #1
                    std       ,s
                    ldx       G0000,y
                    bne       L0054
                    leax      B0000,y
                    stx       G0000,y
                    stx       B0000,y
                    clra
                    clrb
                    std       B0002,y
L0054               ldu       ,x
                    bra       L005c
L0058               tfr       u,x
                    ldu       ,u
L005c               ldd       2,u
                    cmpd      ,s
                    bcs       L0085
                    bne       L006b
                    ldd       ,u
                    std       ,x
                    bra       L007b
L006b               ldd       2,u
                    subd      ,s
                    std       2,u
                    lslb
                    rola
                    lslb
                    rola
                    leau      d,u
                    ldd       ,s
                    std       2,u
L007b               stx       G0000,y
                    leau      4,u
                    tfr       u,d
                    bra       L0093
L0085               cmpu      G0000,y
                    bne       L0058
                    lbsr      L0000
                    bne       L0058
                    clra
                    clrb
L0093               leas      2,s
                    puls      u,pc
free                pshs      d,u
                    ldu       6,s
                    leau      -4,u
                    ldx       G0000,y
                    bra       L00b3
L00a3               cmpx      ,x
                    bcs       L00b1
                    cmpu      ,s
                    bhi       L00bf
                    cmpu      ,x
                    bcs       L00bf
L00b1               ldx       ,x
L00b3               stx       ,s
                    cmpu      ,s
                    bls       L00a3
                    cmpu      ,x
                    bcc       L00a3
L00bf               pshs      u
                    ldd       2,u
                    lslb
                    rola
                    lslb
                    rola
                    addd      ,s++
                    cmpd      ,x
                    bne       L00de
                    pshs      x
                    ldx       ,x
                    ldd       2,x
                    puls      x
                    addd      2,u
                    std       2,u
                    ldd       [,x]
                    bra       L00e0
L00de               ldd       ,x
L00e0               std       ,u
                    ldd       2,x
                    lslb
                    rola
                    lslb
                    rola
                    addd      ,s
                    pshs      d
                    cmpu      ,s++
                    bne       L00fd
                    ldd       2,x
                    addd      2,u
                    std       2,x
                    ldd       ,u
                    std       ,x
                    bra       L00ff
L00fd               stu       ,x
L00ff               stx       G0000,y
                    bra       L0093

                    endsect

