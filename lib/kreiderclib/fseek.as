* Disassembly by Os9disasm of fseek.r

                    section   code

* class D external label equates

D0000               equ       $0000

* class X external label equates

X4f5f               equ       $4f5f
Xffff               equ       $ffff

fseek               pshs      u
                    ldu       4,s
                    leas      -6,s
                    lbeq      L0114
                    ldd       6,u
                    bitb      #3
                    lbeq      L0114
                    bita      #$80
                    bne       L0020
                    pshs      u
                    lbsr      _setbase
                    leas      2,s
                    lbra      L00e5
L0020               bita      #1
                    beq       L003a
                    pshs      u
                    lbsr      fflush
                    leas      2,s
                    lda       6,u
                    anda      #254
                    sta       6,u
                    ldd       2,u
                    addd      11,u
                    std       4,u
                    lbra      L00e3
L003a               ldd       ,u
                    cmpd      4,u
                    lbhs      L00e5
                    leax      2,s
                    pshs      x
                    leax      14,s
                    lbsr      _lmove
                    ldx       16,s
                    beq       L0059
                    cmpx      #1
                    beq       L0072
                    lbra      L00c8
L0059               leax      2,s
                    pshs      x
                    ldd       2,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    pshs      u
                    lbsr      ftell
                    leas      2,s
                    lbsr      _lsub
                    lbsr      _lmove
L0072               ldd       11,u
                    lbsr      _litol
                    ldd       2,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    leax      6,s
                    ldd       2,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    leax      L011f,pcr
                    lbsr      _lcmpr
                    bge       L0099
                    leax      6,s
                    lbsr      _lneg
                    bra       L009b
L0099               leax      6,s
L009b               lbsr      _lcmpr
                    blt       L00bf
                    ldd       4,s
                    addd      ,u
                    std       ,s
                    cmpd      2,u
                    bcs       L00bf
                    ldd       ,s
                    cmpd      4,u
                    bcc       L00bf
                    ldd       ,s
                    std       ,u
                    ldb       7,u
                    andb      #$ef
                    stb       7,u
                    lbra      L0119
L00bf               ldd       16,s
                    cmpd      #1
                    bne       L00e1
L00c8               leax      12,s
                    pshs      x
                    ldd       2,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       4,u
                    subd      ,u
                    lbsr      _litol
                    lbsr      _lsub
                    lbsr      _lmove
L00e1               ldd       4,u
L00e3               std       ,u
L00e5               ldb       7,u
                    andb      #$ef
                    stb       7,u
                    ldd       16,s
                    pshs      d
                    leax      14,s
                    ldd       2,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    ldd       8,u
                    pshs      d
                    lbsr      lseek
                    leas      8,s
                    ldd       2,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    leax      >L0123,pcr
                    lbsr      _lcmpr
                    bne       L0119
L0114               ldd       #-1
                    bra       L011b
L0119               clra
                    clrb
L011b               leas      6,s
                    puls      u,pc
L011f               neg       D0000
                    neg       D0000
L0123               stu       Xffff
                    stu       X4f5f
rewind              equ       *-2
                    tfr       d,x
                    pshs      d,x
                    ldd       6,s
                    pshs      d,x
                    lbsr      fseek
                    leas      8,s
                    rts
ftell               pshs      u
                    ldu       4,s
                    beq       L0143
                    ldd       6,u
                    andb      #3
                    bne       L0150
L0143               leax      _flacc,y
                    ldd       #-1
                    std       ,x
                    std       2,x
                    puls      u,pc
L0150               anda      #$80
                    bne       L015b
                    pshs      u
                    lbsr      _setbase
                    leas      2,s
L015b               ldd       #1
                    pshs      d
                    clrb
                    pshs      d
                    pshs      d
                    ldd       8,u
                    pshs      d
                    lbsr      lseek
                    leas      8,s
                    ldd       2,x
                    pshs      d
                    ldd       ,x
                    pshs      d
                    lda       6,u
                    anda      #1
                    beq       L0180
                    ldd       2,u
                    bra       L0182
L0180               ldd       4,u
L0182               pshs      d
                    ldd       ,u
                    subd      ,s++
                    lbsr      _litol
                    lbsr      _ladd
                    puls      u,pc

                    endsect

